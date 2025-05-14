// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
// Modified by Authors of "Towards ML-KEM & ML-DSA on OpenTitan" (https://eprint.iacr.org/2024/1192)
// Copyright "Towards ML-KEM & ML-DSA on OpenTitan" Authors

`include "prim_assert.sv"

/* verilator lint_off UNOPTFLAT */

module otbn_mac_bignum
  import otbn_pkg::*;
(
  input logic clk_i,
  input logic rst_ni,

  input mac_bignum_operation_t operation_i,
  input logic                  mac_en_i,
  input logic                  mac_commit_i,

  output logic [WLEN-1:0] operation_result_o,
  output flags_t          operation_flags_o,
  output flags_t          operation_flags_en_o,
  output logic            operation_intg_violation_err_o,

  output logic            operation_mulv_done_o,

  input  mac_predec_bignum_t mac_predec_bignum_i,
  output logic               predec_error_o,

  input logic [WLEN-1:0] urnd_data_i,
  input logic            sec_wipe_acc_urnd_i,
  input logic            sec_wipe_tmp_urnd_i,
  output logic [ExtWLEN-1:0] ispr_acc_intg_o,
  input  logic [ExtWLEN-1:0] ispr_acc_wr_data_intg_i,
  input  logic               ispr_acc_wr_en_i
);
  // The MAC operates on quarter-words, QWLEN gives the number of bits in a quarter-word.
  localparam int unsigned QWLEN = WLEN / 4;

  logic [WLEN-1:0] adder_op_a;
  logic [WLEN-1:0] adder_op_b;
  logic [WLEN-1:0] adder_result;
  logic [1:0]      adder_result_hw_is_zero;

  logic [QWLEN-1:0]  mul_op_a;
  logic [QWLEN-1:0]  mul_op_b;
  logic [WLEN/2-1:0] mul_res;
  logic [WLEN-1:0]   mul_res_shifted;

  logic [ExtWLEN-1:0] acc_intg_d;
  logic [ExtWLEN-1:0] acc_intg_q;
  logic [WLEN-1:0]    acc_blanked;
  logic               acc_en;

  logic [ExtWLEN/4-1:0]   res_tmp_intg_d;
  logic [ExtWLEN/4-1:0]   res_tmp_intg_q;
  
  logic [QWLEN-1:0]   res_tmp_blanked;

  logic [ExtWLEN/2-1:0] p_tmp_intg_d;
  logic [ExtWLEN/2-1:0] p_tmp_intg_q;
  
  logic [WLEN/2-1:0]    p_tmp_blanked;

  logic [WLEN-1:0] operand_a_blanked, operand_b_blanked;

  logic expected_acc_rd_en, expected_op_en, expected_mulv_en;
  mulv_type_t expected_type;

  // SEC_CM: DATA_REG_SW.SCA
  prim_blanker #(.Width(WLEN)) u_operand_a_blanker (
    .in_i (operation_i.operand_a),
    .en_i (mac_predec_bignum_i.op_en | operation_i.mac_mulv_en),
    .out_o(operand_a_blanked)
  );

  // SEC_CM: DATA_REG_SW.SCA
  prim_blanker #(.Width(WLEN)) u_operand_b_blanker (
    .in_i (operation_i.operand_b),
    .en_i (mac_predec_bignum_i.op_en | operation_i.mac_mulv_en),
    .out_o(operand_b_blanked)
  );

  // Extract QWLEN multiply operands from WLEN operand inputs based on chosen quarter word from the
  // instruction (operand_[a|b]_qw_sel).
  always_comb begin
    mul_op_a = '0;
    mul_op_b = '0;

    unique case (operation_i.operand_a_qw_sel)
      2'd0: mul_op_a = operand_a_blanked[QWLEN*0+:QWLEN];
      2'd1: mul_op_a = operand_a_blanked[QWLEN*1+:QWLEN];
      2'd2: mul_op_a = operand_a_blanked[QWLEN*2+:QWLEN];
      2'd3: mul_op_a = operand_a_blanked[QWLEN*3+:QWLEN];
      default: mul_op_a = '0;
    endcase

    unique case (operation_i.operand_b_qw_sel)
      2'd0: mul_op_b = operand_b_blanked[QWLEN*0+:QWLEN];
      2'd1: mul_op_b = operand_b_blanked[QWLEN*1+:QWLEN];
      2'd2: mul_op_b = operand_b_blanked[QWLEN*2+:QWLEN];
      2'd3: mul_op_b = operand_b_blanked[QWLEN*3+:QWLEN];
      default: mul_op_b = '0;
    endcase
  end

  `ASSERT_KNOWN_IF(OperandAQWSelKnown, operation_i.operand_a_qw_sel, mac_en_i)
  `ASSERT_KNOWN_IF(OperandBQWSelKnown, operation_i.operand_b_qw_sel, mac_en_i)

  // The reset signal is not used for any registers in this module but for assertions.  As those
  // assertions are not visible to EDA tools working with the synthesizable subset of the code
  // (e.g., Verilator), they cause lint errors in some of those tools.  Prevent these errors by
  // assigning the reset signal to a signal that is okay to be unused.
  logic unused_ok;
  assign unused_ok = ^(rst_ni);

  // Operands and results for first multiplier
  // Computes p = op0_i * op1_i;
  logic [WLEN-1:0] op0, op1;
  assign op0 = operand_a_blanked;

  // Replace multiplication with custom multiplier
  logic [QWLEN-1:0] mux2mul_op_a;
  logic [QWLEN-1:0] mux2mul_op_b;

  // Select op1 depening on lane and lane_idx
  logic [WLEN-1:0] multiplier_op_lane;
  logic [15:0] lane16 [15:0];
  logic [31:0] lane32 [7:0];
  logic [WLEN-1:0] multiplier_op_lane16;
  logic [WLEN-1:0] multiplier_op_lane32;

  generate;
      for (genvar i=0; i<16; ++i) begin : g_lane16
          assign lane16[i] = operand_b_blanked[i*16+:16];
      end : g_lane16

      for (genvar i=0; i<8; ++i) begin : g_lane32
          assign lane32[i] = operand_b_blanked[i*32+:32];
      end : g_lane32
  endgenerate

  always_comb begin
    for (int i=0; i<16; ++i) begin
      multiplier_op_lane16[i*16+:16] = lane16[operation_i.lane_idx];
    end
    for (int i=0; i<8; ++i) begin
      multiplier_op_lane32[i*32+:32] = lane32[operation_i.lane_idx[2:0]];
    end      
  end

  assign multiplier_op_lane = operation_i.vector_type[0] ? multiplier_op_lane16 : multiplier_op_lane32;

  assign op1 = operation_i.vector_type[1] ? multiplier_op_lane : operand_b_blanked;

  // Stall state register
  logic [1:0] stall_state;
  always_ff @(posedge clk_i) begin
    if (operation_i.mac_mulv_en & operation_i.vector_type[2]) begin
      if (stall_state == 2'b10) begin
        stall_state <= '0;
      end else begin
        stall_state <= stall_state + 1;
      end
    end else begin
      stall_state <= '0;
    end
  end

  // Stall state qword_sel register
  logic [1:0] stall_state_qwsel;
  always_ff @(posedge clk_i) begin
    if (operation_i.mac_mulv_en & ((stall_state == 2'b10) | !operation_i.vector_type[2])) begin
      if (stall_state_qwsel == 2'b11) begin
        stall_state_qwsel <= '0;
      end else begin
        stall_state_qwsel <= stall_state_qwsel + 1;
      end
    end else if(!operation_i.mac_mulv_en) begin
      stall_state_qwsel <= '0;
    end
  end

  always_comb begin
    operation_mulv_done_o = 1'b0;
    if (operation_i.mac_mulv_en & ((stall_state == 2'b10) | !operation_i.vector_type[2])) begin
      if (stall_state_qwsel == 2'b11) begin
        operation_mulv_done_o = 1'b1;
      end else begin
        operation_mulv_done_o = 1'b0;
      end
    end else begin
        operation_mulv_done_o = 1'b0;      
    end
  end
  

  // Select input of multiplier depending on stall state
  logic [QWLEN-1:0] r2mul_16;
  logic [QWLEN-1:0] r2mul_32;
  logic [QWLEN-1:0] r2mul;

  logic [QWLEN-1:0] q2mul_16;
  logic [QWLEN-1:0] q2mul_32;
  logic [QWLEN-1:0] q2mul;

  for (genvar i=0; i<4; ++i) begin
    assign r2mul_16[i*16+:16] = operation_i.mod[47:32];
    assign q2mul_16[i*16+:16] = operation_i.mod[15:0];
  end

  for (genvar i=0; i<2; ++i) begin
    assign r2mul_32[i*32+:32] = operation_i.mod[63:32];
    assign q2mul_32[i*32+:32] = operation_i.mod[31:0];
  end
  

  /************************************
  * 1: compute p=a*b and [p]_l,
  * 2: compute m=[p*R]_l,
  * 3: compute t=[m*q+p]^l,
  * 4: compute t-q if necessary.
  * ToDo: Maybe merge 3 and 4
  ************************************/
  always_comb begin
    mux2mul_op_a = '0;
    unique case (stall_state)
      2'd0: mux2mul_op_a = op0[stall_state_qwsel*64+:64];
      2'd1: mux2mul_op_a = res_tmp_blanked;
      2'd2: mux2mul_op_a = res_tmp_blanked;
    default : mux2mul_op_a = '0;
    endcase
  end

  assign r2mul = operation_i.vector_type[0] ? r2mul_16 : r2mul_32;
  assign q2mul = operation_i.vector_type[0] ? q2mul_16 : q2mul_32;

  always_comb begin
    mux2mul_op_b = '0;
    unique case (stall_state)
      2'd0: mux2mul_op_b = op1[stall_state_qwsel*64+:64];
      2'd1: mux2mul_op_b = r2mul;
      2'd2: mux2mul_op_b = q2mul;
    default : mux2mul_op_b = '0;
    endcase
  end
  logic [QWLEN-1:0]  multiplier_op_a;
  logic [QWLEN-1:0]  multiplier_op_b;

  assign multiplier_op_a = operation_i.mac_mulv_en ? mux2mul_op_a : mul_op_a;
  assign multiplier_op_b = operation_i.mac_mulv_en ? mux2mul_op_b : mul_op_b;

  // ToDo: Add wider multiplication for Kyber
  // assign mul_res = mul_op_a * mul_op_b;
  otbn_mul U_MUL (
    .multiplier_op_a_i(multiplier_op_a),
    .multiplier_op_b_i(multiplier_op_b),
    .multiplier_vector_i(operation_i.mac_mulv_en),
    .multiplier_selvector_i(operation_i.vector_type[0]),
    .multiplier_res_o(mul_res)
  );

  // Shift the QWLEN multiply result into a WLEN word before accumulating using the shift amount
  // supplied in the instruction (pre_acc_shift_imm).
  always_comb begin
    mul_res_shifted = '0;

    unique case (operation_i.pre_acc_shift_imm)
      2'd0: mul_res_shifted = {{QWLEN * 2{1'b0}}, mul_res};
      2'd1: mul_res_shifted = {{QWLEN{1'b0}}, mul_res, {QWLEN{1'b0}}};
      2'd2: mul_res_shifted = {mul_res, {QWLEN * 2{1'b0}}};
      2'd3: mul_res_shifted = {mul_res[63:0], {QWLEN * 3{1'b0}}};
      default: mul_res_shifted = '0;
    endcase
  end

  `ASSERT_KNOWN_IF(PreAccShiftImmKnown, operation_i.pre_acc_shift_imm, mac_en_i)

  // ToDo: Add [ ]_16 and [ ]_32 function
  logic [15:0] red_16 [3:0]; //[7:0];
  logic [31:0] red_32 [1:0];

  always_comb begin
    for (int i=0; i<4; ++i) begin
      red_16[i] = mul_res[i*32+:16];
    end

    for (int i=0; i<2; ++i) begin
      red_32[i] = mul_res[i*64+:32];
    end
  end

  logic [QWLEN-1:0] trunc_result;
  logic [QWLEN-1:0] trunc_result_16;
  logic [QWLEN-1:0] trunc_result_32;
  generate;
      for (genvar i=0; i<4; ++i) begin : g_shift16_p
          assign trunc_result_16[i*16+:16] = red_16[i];
      end : g_shift16_p

      for (genvar i=0; i<2; ++i) begin : g_shift32_p
          assign trunc_result_32[i*32+:32] = red_32[i];
      end : g_shift32_p
  endgenerate
  assign trunc_result = operation_i.vector_type[0] ? trunc_result_16 : trunc_result_32;

  // Add register for intermediate result
  // ECC encode and decode of accumulator register
  logic [QWLEN-1:0]                res_tmp_no_intg_d;
  logic [QWLEN-1:0]                res_tmp_no_intg_q;
  logic [ExtWLEN/4-1:0]            res_tmp_intg_calc;
  logic [BaseWordsPerWLEN/2-1:0]   res_tmp_intg_err;
  logic [BaseWordsPerWLEN/2-1:0]   unused_res_tmp_intg_err;
  assign unused_res_tmp_intg_err = res_tmp_intg_err;
  // ToDo: Optimization for Kyber
  //assign res_tmp_no_intg_d[QWLEN-1:0] = '0;

  for (genvar i_word = 0; i_word < BaseWordsPerWLEN/4; i_word++) begin : g_res_tmp_words
    prim_secded_inv_39_32_enc i_secded_enc (
      .data_i (res_tmp_no_intg_d[i_word*32+:32]),
      .data_o (res_tmp_intg_calc[i_word*39+:39])
    );
    prim_secded_inv_39_32_dec i_secded_dec (
      .data_i     (res_tmp_intg_q[i_word*39+:39]),
      .data_o     (/* unused because we abort on any integrity error */),
      .syndrome_o (/* unused */),
      .err_o      (res_tmp_intg_err[i_word*2+:2])
    );
    assign res_tmp_no_intg_q[i_word*32+:32] = res_tmp_intg_q[i_word*39+:32];
  end

  // Select intermediate results
  always_comb begin
    res_tmp_no_intg_d = '0;
    unique case (1'b1)
      // Non-encoded inputs have to be encoded before writing to the register.
      sec_wipe_tmp_urnd_i: begin
        res_tmp_no_intg_d = urnd_data_i[63:0];
        res_tmp_intg_d = res_tmp_intg_calc;
      end
      default: begin
          for (int i=0; i<2; ++i) begin
            res_tmp_no_intg_d[i*32+:32] = operation_i.vector_type[0] ? {red_16[2*i+1],red_16[2*i]} : red_32[i];
          end
          res_tmp_intg_d = res_tmp_intg_calc;
        end
    endcase
  end

  always_ff @(posedge clk_i) begin
    if (operation_i.mac_mulv_en) begin
      res_tmp_intg_q <= res_tmp_intg_d;
    end
  end

  // Add register for intermediate result
  // ECC encode and decode of accumulator register
  logic [WLEN/2-1:0]                p_tmp_no_intg_d;
  logic [WLEN/2-1:0]                p_tmp_no_intg_q;
  logic [ExtWLEN/2-1:0]             p_tmp_intg_calc;
  logic [BaseWordsPerWLEN-1:0]      p_tmp_intg_err;
  logic [BaseWordsPerWLEN-1:0]      unused_p_tmp_intg_err;
  assign unused_p_tmp_intg_err = p_tmp_intg_err;
  
  // ToDo: Optimization for Kyber
  //assign p_tmp_no_intg_d[WLEN/2-1:QWLEN] = '0;

  for (genvar i_word = 0; i_word < BaseWordsPerWLEN/2; i_word++) begin : g_p_tmp_words
    prim_secded_inv_39_32_enc i_secded_enc (
      .data_i (p_tmp_no_intg_d[i_word*32+:32]),
      .data_o (p_tmp_intg_calc[i_word*39+:39])
    );
    prim_secded_inv_39_32_dec i_secded_dec (
      .data_i     (p_tmp_intg_q[i_word*39+:39]),
      .data_o     (/* unused because we abort on any integrity error */),
      .syndrome_o (/* unused */),
      .err_o      (p_tmp_intg_err[i_word*2+:2])
    );
    assign p_tmp_no_intg_q[i_word*32+:32] = p_tmp_intg_q[i_word*39+:32];
  end

  always_comb begin
    p_tmp_intg_d = '0;
    unique case (1'b1)
      // Non-encoded inputs have to be encoded before writing to the register.
      sec_wipe_tmp_urnd_i: begin
        p_tmp_no_intg_d = urnd_data_i[255:128];
        p_tmp_intg_d = p_tmp_intg_calc;
      end
      default: begin
          if ((operation_i.mac_mulv_en) & (stall_state ==2'b0)) begin
              // ToDo: Accumulate end result (vector)
              p_tmp_no_intg_d = mul_res;
              p_tmp_intg_d = p_tmp_intg_calc;
          end else begin
              p_tmp_no_intg_d = '0;
              p_tmp_intg_d = p_tmp_intg_calc;
          end
      end
    endcase
  end


  always_ff @(posedge clk_i) begin
    if ((operation_i.mac_mulv_en) & (stall_state ==2'b0)) begin
      p_tmp_intg_q <= p_tmp_intg_d;
    end
  end

  // SEC_CM: DATA_REG_SW.SCA
  // acc_rd_en is so if .Z set in MULQACC (zero_acc) so accumulator reads as 0
  prim_blanker #(.Width(WLEN/2)) u_p_blanker (
    .in_i (p_tmp_no_intg_q),
    .en_i (mac_predec_bignum_i.mac_mulv_en),
    .out_o(p_tmp_blanked)
  );

  // SEC_CM: DATA_REG_SW.SCA
  prim_blanker #(.Width(QWLEN)) u_res_tmp_blanker (
    .in_i (res_tmp_no_intg_q),
    .en_i (mac_predec_bignum_i.mac_mulv_en),
    .out_o(res_tmp_blanked)
  );

  // ECC encode and decode of accumulator register
  logic [WLEN-1:0]                acc_no_intg_d;
  logic [WLEN-1:0]                acc_no_intg_q;
  logic [ExtWLEN-1:0]             acc_intg_calc;
  logic [2*BaseWordsPerWLEN-1:0]  acc_intg_err;
  for (genvar i_word = 0; i_word < BaseWordsPerWLEN; i_word++) begin : g_acc_words
    prim_secded_inv_39_32_enc i_secded_enc (
      .data_i (acc_no_intg_d[i_word*32+:32]),
      .data_o (acc_intg_calc[i_word*39+:39])
    );
    prim_secded_inv_39_32_dec i_secded_dec (
      .data_i     (acc_intg_q[i_word*39+:39]),
      .data_o     (/* unused because we abort on any integrity error */),
      .syndrome_o (/* unused */),
      .err_o      (acc_intg_err[i_word*2+:2])
    );
    assign acc_no_intg_q[i_word*32+:32] = acc_intg_q[i_word*39+:32];
  end

  // Propagate integrity error only if accumulator register is used: `acc_intg_q` flows into
  // `operation_result_o` via `acc`, `adder_op_b`, and `adder_result` iff the MAC is enabled and the
  // current operation does not zero the accumulation register.
  logic acc_used;
  assign acc_used = mac_en_i & ~operation_i.zero_acc;
  assign operation_intg_violation_err_o = (acc_used & |(acc_intg_err));
  // |                                         (operation_i.mac_mulv_en & |{p_tmp_intg_err,res_tmp_intg_err});

  // Accumulator logic

  // SEC_CM: DATA_REG_SW.SCA
  // acc_rd_en is so if .Z set in MULQACC (zero_acc) so accumulator reads as 0

  logic mulv_acc_en;

  assign mulv_acc_en = operation_i.mac_mulv_en & ((stall_state == 2'b10) | !(operation_i.vector_type[2]));

  prim_blanker #(.Width(WLEN)) u_acc_blanker (
    .in_i (acc_no_intg_q),
    .en_i (mac_predec_bignum_i.acc_rd_en | mulv_acc_en),
    .out_o(acc_blanked)
  );

  // ToDo: Select adder inputs
  // Add shifted multiplier result to current accumulator.
  assign adder_op_a = (operation_i.mac_mulv_en) ? {128'b0,mul_res} : mul_res_shifted;
  assign adder_op_b = (operation_i.mac_mulv_en) ? {128'b0,p_tmp_blanked} : acc_blanked;

  // Splitt 256-bit addition into 16 x 16-bit additions
  logic          adder_x_carry_in;
  assign adder_x_carry_in = 'b0;

  logic          adder_x_op_b_invert;
  assign adder_x_op_b_invert = 'b0;

  logic [WLEN:0] adder_x_res;

  logic [31:0] adder_x_op_a [7:0];
  logic [32:0] adder_x_op_b [7:0];
  logic [32:0] adder_x_op_a_blanked [7:0];
  logic [32:0] adder_x_op_b_blanked [7:0];

  logic [7:0] adder_x_vcarry_in;
  logic [31:0] adder_x_sum [7:0];
  logic [7:0] adder_x_carry_out;
  logic [7:0] adder_x_carry2mux;
  logic [7:0] unused_adder_x_carry2mux;
  assign adder_x_carry2mux = 'b0;
  assign unused_adder_x_carry2mux = adder_x_carry2mux;
  logic [7:0] adder_x_carry_in_unused;

  logic adder_selvector_i;
  logic adder_vector_i;

  assign adder_selvector_i = operation_i.vector_type[0];
  //assign adder_selvector_i = 'b0;
  // assign adder_vector_i = operation_i.vector_sel;
  assign adder_vector_i = operation_i.mac_mulv_en;

  // For Kyber :    32-bit + 16-bit addition
  // For Dilitihum: 64-bit + 32-bit addition
  // Support for 32-bit additions(Kyber) and 64-bit additions(Dilitihum)
  for (genvar i=0; i<8; ++i) begin

    // Depending on mode, select carry input for the 16-bit adders
    // ToDo: cleaner and better readbable code, very ugly --> UNOPTFLAT
    // ToDo: carry in vector as input
    assign adder_x_vcarry_in[i] = adder_vector_i ? (adder_selvector_i ? adder_x_carry_in : 
                                                                        ((i%2==0) ? adder_x_carry_in : adder_x_carry_out[i-1])) :
                                                ((i==0) ?   adder_x_carry_in : 
                                                            adder_x_carry_out[i-1]);

    assign adder_x_op_a[i] = adder_op_a[i*32+:32];

    // SEC_CM: DATA_REG_SW.SCA
    prim_blanker #(.Width(33)) u_adder_op_a_blanked (
      .in_i ({adder_x_op_a[i], 1'b1}),
      .en_i (1'b1),
      .out_o(adder_x_op_a_blanked[i])
    );

    assign adder_x_op_b[i] = {adder_x_op_b_invert ? ~adder_op_b[i*32+:32] :  adder_op_b[i*32+:32],
                              adder_x_vcarry_in[i]};

    // SEC_CM: DATA_REG_SW.SCA
    prim_blanker #(.Width(33)) u_adder_op_b_blanked (
      .in_i (adder_x_op_b[i]),
      .en_i (1'b1),
      .out_o(adder_x_op_b_blanked[i])
    );

    assign {adder_x_carry_out[i],adder_x_sum[i],adder_x_carry_in_unused[i]} = adder_x_op_a_blanked[i] + adder_x_op_b_blanked[i];

    // Combine all sums to 256-bit vector
    assign adder_x_res[1+i*32+:32] = adder_x_sum[i][31:0];

  end

  // The LSb of the adder results are unused.
  logic unused_adder_x_res_lsb;
  assign unused_adder_x_res_lsb = adder_x_res[0];
  assign adder_x_res[0] = 1'b0;
  assign adder_result = adder_x_res[WLEN:1];

  // Split zero check between the two halves of the result. This is used for flag setting (see
  // below).
  assign adder_result_hw_is_zero[0] = adder_result[WLEN/2-1:0] == 'h0;
  assign adder_result_hw_is_zero[1] = adder_result[WLEN/2+:WLEN/2] == 'h0;

  assign operation_flags_o.L    = adder_result[0];
  // L is always updated for .WO, and for .SO when writing to the lower half-word
  assign operation_flags_en_o.L = operation_i.shift_acc ? ~operation_i.wr_hw_sel_upper : 1'b1;

  // For .SO M is taken from the top-bit of shifted out half-word, otherwise it is taken from the
  // top-bit of the full result.
  assign operation_flags_o.M    = operation_i.shift_acc ? adder_result[WLEN/2-1] :
                                                          adder_result[WLEN-1];
  // M is always updated for .WO, and for .SO when writing to the upper half-word.
  assign operation_flags_en_o.M = operation_i.shift_acc ? operation_i.wr_hw_sel_upper : 1'b1;

  // For .SO Z is calculated from the shifted out half-word, otherwise it is calculated on the full
  // result.
  assign operation_flags_o.Z    = operation_i.shift_acc ? adder_result_hw_is_zero[0] :
                                                          &adder_result_hw_is_zero;

  // Z is updated for .WO. For .SO updates are based upon result and half-word:
  // - When writing to lower half-word always update Z.
  // - When writing to upper half-word clear Z if result is non-zero otherwise leave it alone.
  assign operation_flags_en_o.Z =
      operation_i.shift_acc & operation_i.wr_hw_sel_upper ? ~adder_result_hw_is_zero[0] :
                                                            1'b1;

  // MAC never sets the carry flag
  assign operation_flags_o.C    = 1'b0;
  assign operation_flags_en_o.C = 1'b0;

  // Select if reduced or truncated result is selected as output
  logic [QWLEN-1:0] multiplier_result_red;
  logic [QWLEN-1:0] multiplier_result_trunc;
  logic [QWLEN-1:0] multiplier_result;

  always_comb begin
    acc_no_intg_d = '0;
    unique case (1'b1)
      // Non-encoded inputs have to be encoded before writing to the register.
      sec_wipe_acc_urnd_i: begin
        acc_no_intg_d = urnd_data_i;
        acc_intg_d = acc_intg_calc;
      end
      default: begin
        // If performing an ACC ISPR write the next accumulator value is taken from the ISPR write
        // data, otherwise it is drawn from the adder result. The new accumulator can be optionally
        // shifted right by one half-word (shift_acc).
        if (ispr_acc_wr_en_i) begin
          acc_intg_d = ispr_acc_wr_data_intg_i;
        end else begin
          if ((operation_i.mac_mulv_en) & ((stall_state == 2'b10) | !operation_i.vector_type[2])) begin
            // ToDo: Accumulate end result (vector)
            unique case (stall_state_qwsel)
              2'd0: acc_no_intg_d = {acc_no_intg_q[WLEN-1:64], multiplier_result};
              2'd1: acc_no_intg_d = {acc_no_intg_q[WLEN-1:128], multiplier_result, acc_no_intg_q[63:0]};
              2'd2: acc_no_intg_d = {acc_no_intg_q[WLEN-1:192], multiplier_result, acc_no_intg_q[127:0]};
              2'd3: acc_no_intg_d = {multiplier_result, acc_no_intg_q[191:0]};
              default: acc_no_intg_d = '0;
            endcase
            acc_intg_d = acc_intg_calc;
          end else begin
            acc_no_intg_d = operation_i.shift_acc ? {{QWLEN*2{1'b0}}, adder_result[QWLEN*2+:QWLEN*2]}
                                                  : adder_result;
            acc_intg_d = acc_intg_calc;
          end

        end
      end
    endcase
  end

  // Only write to accumulator if the MAC is enabled or an ACC ISPR write is occuring or secure
  // wipe of the internal state is occuring.
  assign acc_en = (mac_en_i & mac_commit_i) | ispr_acc_wr_en_i | sec_wipe_acc_urnd_i | mulv_acc_en;

  always_ff @(posedge clk_i) begin
    if (acc_en) begin
      acc_intg_q <= acc_intg_d;
    end
  end

  assign ispr_acc_intg_o = acc_intg_q;

  // ToDo: Add [ ]^16 and [ ]^32 function and multiplexer
    logic [32:0] s16 [7:0];
    logic [64:0] s32 [1:0];

    logic [16:0] t16 [7:0];
    logic [32:0] t32 [1:0];

   
    // Extract t from s for LOG_R=DATA_WIDTH = 16(32)
    // Todo: t_not correct --> maybe byteselect wrong!
    // Computes t = s[LOG_R+DATA_WIDTH:LOG_R];
    //logic [17*16-1:0] t_16, t_32;
    generate;
        for (genvar i=0; i<4; ++i) begin : g_t_16
            assign s16[i] = {adder_x_carry_out[i],adder_x_sum[i]}; //s[i*33+:33];
            assign t16[i] = s16[i][32:16];
            //assign t_16[i*17+:17] = s16[i][32:16];
        end : g_t_16

        for (genvar i=0; i<2; ++i) begin : g_t_32
            assign s32[i] = {adder_x_carry_out[2*i+1],adder_x_sum[2*i+1],adder_x_sum[2*i]};//s[i*65+:65];
            //assign t_32[i*34+:33] = s32[i][64:32];
            assign t32[i] = s32[i][64:32];
            //assign t_32[33+i*34] = 1'b0;
        end : g_t_32
    endgenerate

    logic [16:0] t [15:0];
    
    for (genvar i=0; i<4; ++i) begin
      assign t[i] = operation_i.vector_type[0] ? t16[i] : 
                                             ((i%2==0) ? t32[i>>1][16:0] : {1'b0,t32[i>>1][32:17]});   
    end


    // Conditional subtraction if t needs to be reduced via carry select subtractor
    // Splitt 256-bit addition into 16 x 16-bit additions
    // Computes (q_i <= t) ? t : t-q_i

    logic [16:0] subtractor_op_a [15:0];
    logic [17:0] subtractor_op_b [15:0];

    logic [17:0] subtractor_op_a_blanked [15:0];
    logic [17:0] subtractor_op_b_blanked [15:0];

    logic [15:0] subtractor_carry_in;
    logic [16:0] subtractor_sum [15:0];
    logic [15:0] subtractor_carry_out;
    logic [15:0] subtractor_carry_in_unused;

    logic subtractor_carry_i;
    assign subtractor_carry_i = 1'b1;


    logic subtractor_en_i;
    assign subtractor_en_i = 1'b1;
    
    // Select t or t-q
    logic [3:0] tq_cond_16;
    logic [3:0] tq_cond_32;

    for (genvar i=0; i<4; ++i) begin
      assign tq_cond_16[i] = ({1'b0,operation_i.mod[15:0]} <= t16[i]) ? 1'b1 : 1'b0;
    end

    for (genvar i=0; i<2; ++i) begin
      assign tq_cond_32[2*i] = ({1'b0,operation_i.mod[31:0]} <= t32[i]) ? 1'b1 : 1'b0;
      assign tq_cond_32[2*i+1] = ({1'b0,operation_i.mod[31:0]}  <= t32[i]) ? 1'b1 : 1'b0;
    end

    for (genvar i=0; i<16; ++i) begin

        // Depending on mode, select carry input for the 32-bit subtractors
        // ToDo: cleaner and better readbable code
        // ToDo: carry in vector as input
        assign subtractor_carry_in[i] = operation_i.vector_type[0] ? subtractor_carry_i : ((i%2==0) ? subtractor_carry_i : subtractor_carry_out[i-1]);

        
        assign subtractor_op_a[i] = t[i];

        // SEC_CM: DATA_REG_SW.SCA
        prim_blanker #(.Width(18)) u_subtractor_op_a_blanked (
        .in_i ({subtractor_op_a[i], 1'b1}),
        .en_i (subtractor_en_i),
        .out_o(subtractor_op_a_blanked[i])
        );

        assign subtractor_op_b[i] = operation_i.vector_type[0] ? {1'b1,~q2mul[(i%2)*16+:16], subtractor_carry_in[i]} : 
                                                      (i%2==0) ? {~q2mul[16:0], subtractor_carry_in[i]} : 
                                                                 {2'b11,~q2mul[31:17], subtractor_carry_in[i]};

        // SEC_CM: DATA_REG_SW.SCA
        prim_blanker #(.Width(18)) u_subtractor_op_b_blanked (
        .in_i (subtractor_op_b[i]),
        .en_i (subtractor_en_i),
        .out_o(subtractor_op_b_blanked[i])
        );

        assign {subtractor_carry_out[i],subtractor_sum[i],subtractor_carry_in_unused[i]} = subtractor_op_a_blanked[i] + subtractor_op_b_blanked[i];

        // Combine all sums to 256-bit vector
        //assign subtractor_res_o[i*32+:32] = subtractor_sum[i][31:0];
        //assign subtractor_carry_o[i] = subtractor_carry_out[i];

    end

    // Select if 16-bit or 32-bit results
    logic [3:0] tq_cond;
    assign tq_cond = operation_i.vector_type[0] ? tq_cond_16 : tq_cond_32;

    always_comb
    begin
        for (int i=0; i<4; ++i) begin
          multiplier_result_trunc[16*i+:16] = trunc_result[16*i+:16];
          if (tq_cond[i]==1'b1) begin
            multiplier_result_red[16*i+:16] = operation_i.vector_type[0] ? subtractor_sum[i][15:0] : ((i%2==0) ? subtractor_sum[i][15:0] : {subtractor_sum[i][14:0],subtractor_sum[i-1][16] });
          end else begin
            multiplier_result_red[16*i+:16] = operation_i.vector_type[0] ? t[i][15:0] : ((i%2==0) ? t[i][15:0] : {t[i][14:0],t[i-1][16]});
          end          
        end
    end

    assign multiplier_result = operation_i.vector_type[2] ? multiplier_result_red : multiplier_result_trunc;


  // The operation result is taken directly from the adder, shift_acc only applies to the new value
  // written to the accumulator.
  assign operation_result_o = operation_i.mac_mulv_en ? {multiplier_result, acc_no_intg_q[191:0]} : adder_result;

  assign expected_op_en     = mac_en_i;
  assign expected_acc_rd_en = ~operation_i.mac_mulv_en & (~operation_i.zero_acc & mac_en_i);
  assign expected_type = operation_i.vector_type;
  assign expected_mulv_en = operation_i.mac_mulv_en;

  // SEC_CM: CTRL.REDUN
  assign predec_error_o = |{expected_op_en     != mac_predec_bignum_i.op_en,
                            expected_acc_rd_en != mac_predec_bignum_i.acc_rd_en,
                            expected_type      != mac_predec_bignum_i.mulv_type,
                            expected_mulv_en   != mac_predec_bignum_i.mac_mulv_en};

  `ASSERT(NoISPRAccWrAndMacEn, ~(ispr_acc_wr_en_i & mac_en_i))
endmodule
/* verilator lint_on UNOPTFLAT */
