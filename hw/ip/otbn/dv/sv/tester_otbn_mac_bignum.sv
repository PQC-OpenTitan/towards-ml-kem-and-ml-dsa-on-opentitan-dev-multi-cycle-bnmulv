// Copyright "Towards ML-KEM & ML-DSA on OpenTitan" Authors
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

`resetall
//`timescale 1ns/10ps

module tester_otbn_mac_bignum
  import otbn_pkg::*;
#(
  parameter LOG_FILE = "../sim_results.log"
) (
  output logic clk_o,
  output logic rst_no,

  output mac_bignum_operation_t operation_o,
  output logic                  mac_en_o,
  output logic                  mac_commit_o,

  input logic [WLEN-1:0] operation_result_i,
  input flags_t          operation_flags_i,
  input flags_t          operation_flags_en_i,
  input logic            operation_intg_violation_err_i,

  output mac_predec_bignum_t mac_predec_bignum_o,
  input logic               predec_error_i,

  output logic [WLEN-1:0] urnd_data_o,
  output logic            sec_wipe_acc_urnd_o,

  input logic [ExtWLEN-1:0] ispr_acc_intg_i,
  output logic [ExtWLEN-1:0] ispr_acc_wr_data_intg_o,
  output logic               ispr_acc_wr_en_o
);
  // Tasks for verification
  task automatic resetsim(
    ref int errors
  );
    begin 
      errors = 0;   
    end  
  endtask : resetsim

  task automatic verify_output(
    input logic[WLEN-1:0] simulated_value,
    input logic[WLEN-1:0] expected_value,
    ref int errors
  );
  begin
      if((simulated_value != expected_value) || ($isunknown(simulated_value)))
      begin
        errors = errors+1;
	      $display("Simulated Value = %h, Expected Value = %h, Errors %d, at time %d \n", simulated_value,expected_value,errors,$time);
      end
    end

  endtask : verify_output

  function logic [15:0] mont_mul_16(
      input logic [15:0] op0_i,
      input logic [15:0] op1_i,
      input logic [15:0] q_i,
      input logic [15:0] q_dash_i);


      logic   [2*16-1:0]          p;
      logic   [2*16-1:0]               m;
      logic   [16+16:0]        s;
      logic   [16:0]              t;
      
      p = op0_i * op1_i;
      m = p[16-1:0] * q_dash_i;
      s = p + (m[16-1:0] * q_i);
      t = s[16+16:16];
      if (q_i <= t) begin
          return t-q_i;
      end else begin
          return t[15:0];
      end
      
  endfunction

  function logic [31:0] mont_mul_32(
      input logic [31:0] op0_i,
      input logic [31:0] op1_i,
      input logic [31:0] q_i,
      input logic [31:0] q_dash_i);


      logic   [2*32-1:0]          p;
      logic   [2*32-1:0]               m;
      logic   [32+32:0]        s;
      logic   [32:0]              t;
      
      p = op0_i * op1_i;
      m = p[32-1:0] * q_dash_i;
      s = p + (m[32-1:0] * q_i);
      t = s[32+32:32];
      if (q_i <= t) begin
          return t-q_i;
      end else begin
          return t[31:0];
      end
      
  endfunction

  task automatic mulv(
    input mulv_type_t mulv_type
  );
  begin
    // if ( !((mulv_type==mulv_m8s) | (mulv_type==mulv_m16h)) ) begin
    //   $finish();
    // end
    for (int i=0; i<4; ++i) begin
      @(negedge clk_o);
      // Clock cycle 0
      operation_o.mac_mulv_en = 1'b1;
      operation_o.vector_type = mulv_type;
      mac_en_o = 1'b1;
      mac_commit_o = 1'b1;
      mac_predec_bignum_o.op_en = 'b1;
      mac_predec_bignum_o.acc_rd_en = 'b1;
      mac_predec_bignum_o.mac_mulv_en = 'b1;
      mac_predec_bignum_o.mulv_type = mulv_type;
    end
    for (int i=0; i<16; ++i) begin
      $display("OP_A: %h",operation_o.operand_a[i*16+:16]);
      $display("OP_B: %h",operation_o.operand_b[i*16+:16]);
      $display("RES_EXP: %h", res_exp[i*16+:16]);
      verify_output(tb_otbn_mac_bignum.UUT.operation_result_o[i*16+:16],res_exp[i*16+:16],errors);
    end
    operation_o.mac_mulv_en = 1'b0;
    mac_commit_o = 1'b0;
    mac_en_o = 1'b0;
    mac_predec_bignum_o.op_en = 'b0;
    mac_predec_bignum_o.acc_rd_en = '0;
    mac_predec_bignum_o.mac_mulv_en = 'b0;
    @(negedge clk_o);
  end
  endtask : mulv

  task automatic mulvl(
    input mulv_type_t mulv_type,
    input logic [3:0] lane_idx
  );
  begin
    // if ( !((mulv_type==mulv_m8s) | (mulv_type==mulv_m16h)) ) begin
    //   $finish();
    // end
    operation_o.lane_idx = lane_idx;
    for (int i=0; i<4; ++i) begin
      @(negedge clk_o);
      // Clock cycle 0
      operation_o.mac_mulv_en = 1'b1;
      operation_o.vector_type = mulv_type;
      mac_en_o = 1'b1;
      mac_commit_o = 1'b1;
      mac_predec_bignum_o.op_en = 'b1;
      mac_predec_bignum_o.acc_rd_en = 'b1;
      mac_predec_bignum_o.mac_mulv_en = 'b1;
      mac_predec_bignum_o.mulv_type = mulv_type;
    end
    for (int i=0; i<16; ++i) begin
      $display("OP_A: %h",operation_o.operand_a[i*16+:16]);
      $display("OP_B: %h",operation_o.operand_b[i*16+:16]);
      $display("RES_EXP: %h", res_exp[i*16+:16]);
      verify_output(tb_otbn_mac_bignum.UUT.operation_result_o[i*16+:16],res_exp[i*16+:16],errors);
    end
    operation_o.lane_idx = 'b0;
    operation_o.mac_mulv_en = 1'b0;
    mac_commit_o = 1'b0;
    mac_en_o = 1'b0;
    mac_predec_bignum_o.op_en = 'b0;
    mac_predec_bignum_o.acc_rd_en = '0;
    mac_predec_bignum_o.mac_mulv_en = 'b0;
    @(negedge clk_o);
  end
  endtask : mulvl

  task automatic mulvm(
    input mulv_type_t mulv_type
  );
  begin
    // if ( !((mulv_type==mulv_m8s) | (mulv_type==mulv_m16h)) ) begin
    //   $finish();
    // end
    for (int i=0; i<4; ++i) begin
      @(negedge clk_o);
      // Clock cycle 0
      operation_o.mac_mulv_en = 1'b1;
      operation_o.vector_type = mulv_type;
      mac_en_o = 1'b1;
      mac_commit_o = 1'b0;
      mac_predec_bignum_o.op_en = 'b1;
      mac_predec_bignum_o.acc_rd_en = 'b0;
      mac_predec_bignum_o.mac_mulv_en = 'b1;
      mac_predec_bignum_o.mulv_type = mulv_type;
      @(negedge clk_o);
      // Clock cycle 1
      @(negedge clk_o);
      // Clock cycle 2
      mac_commit_o = 1'b1;
      mac_predec_bignum_o.acc_rd_en = '1;
    end
    for (int i=0; i<16; ++i) begin
      $display("OP_A: %h",operation_o.operand_a[i*16+:16]);
      $display("OP_B: %h",operation_o.operand_b[i*16+:16]);
      $display("RES_EXP: %h", res_exp[i*16+:16]);
      verify_output(tb_otbn_mac_bignum.UUT.operation_result_o[i*16+:16],res_exp[i*16+:16],errors);
    end
    operation_o.mac_mulv_en = 1'b0;
    mac_commit_o = 1'b0;
    mac_en_o = 1'b0;
    mac_predec_bignum_o.op_en = 'b0;
    mac_predec_bignum_o.acc_rd_en = '0;
    mac_predec_bignum_o.mac_mulv_en = 'b0;
    @(negedge clk_o);
  end
  endtask : mulvm

  task automatic mulvml(
    input mulv_type_t mulv_type,
    input logic [3:0] lane_idx
  );
  begin
    // if ( !((mulv_type==mulv_ml8s) | (mulv_type==mulv_ml16h)) ) begin
    //   $finish();
    // end
    operation_o.lane_idx = lane_idx;
    for (int i=0; i<4; ++i) begin
      @(negedge clk_o);
      // Clock cycle 0
      operation_o.mac_mulv_en = 1'b1;
      operation_o.vector_type = mulv_type;
      mac_en_o = 1'b1;
      mac_commit_o = 1'b0;
      mac_predec_bignum_o.op_en = 'b1;
      mac_predec_bignum_o.acc_rd_en = 'b0;
      mac_predec_bignum_o.mac_mulv_en = 'b1;
      mac_predec_bignum_o.mulv_type = mulv_type;
      @(negedge clk_o);
      // Clock cycle 1
      @(negedge clk_o);
      // Clock cycle 2
      mac_commit_o = 1'b1;
      mac_predec_bignum_o.acc_rd_en = '1;
    end
    for (int i=0; i<16; ++i) begin
      $display("OP_A: %h",operation_o.operand_a[i*16+:16]);
      $display("OP_B: %h",operation_o.operand_b[i*16+:16]);
      $display("RES_EXP: %h", res_exp[i*16+:16]);
      verify_output(tb_otbn_mac_bignum.UUT.operation_result_o[i*16+:16],res_exp[i*16+:16],errors);
    end
    operation_o.mac_mulv_en = 1'b0;
    mac_commit_o = 1'b0;
    mac_en_o = 1'b0;
    mac_predec_bignum_o.op_en = 'b0;
    mac_predec_bignum_o.acc_rd_en = '0;
    mac_predec_bignum_o.mac_mulv_en = 'b0;
    operation_o.lane_idx = 'b0;
    @(negedge clk_o);
  end

  endtask : mulvml

  localparam string uut_name = "OTBN-MAC-BIGNUM";
  localparam integer NOF_TESTS = 1;
  integer logfile;  
  int errors,errors_total;
  logic [3:0] lane;
  logic [WLEN-1:0]  lane_op;

  // Clock Generation
  initial begin 
      clk_o = 0;

      forever begin
          #1 clk_o = ~clk_o;

      end
  end

  logic [63:0] tmp;
  logic [31:0] tmp1;
  logic [31:0] tmp2;
  logic [WLEN-1:0] res_exp;

  initial begin
    // Reset
    rst_no = 'b0;
    #2
    rst_no = 'b1;
    // Initial inputs
    operation_o.operand_a = '0;
    operation_o.operand_b = '0;
    operation_o.operand_a_qw_sel = '0;
    operation_o.operand_b_qw_sel = '0;
    operation_o.wr_hw_sel_upper = '0;
    operation_o.pre_acc_shift_imm = '0;
    operation_o.zero_acc = '0;
    operation_o.shift_acc = '0;
    operation_o.mod = '0;
    operation_o.vector_type = mulv_type_t'('0);
    operation_o.lane_idx = '0;
    operation_o.mac_mulv_en = '0;
    
    mac_en_o = '0;
    mac_commit_o = '0;

    mac_predec_bignum_o.op_en = '0;
    mac_predec_bignum_o.acc_rd_en = '0;
    mac_predec_bignum_o.mac_mulv_en = '0;
    mac_predec_bignum_o.mulv_type = mulv_type_t'('0);

    urnd_data_o = '0;
    sec_wipe_acc_urnd_o = '0;
    ispr_acc_wr_data_intg_o = '0;
    ispr_acc_wr_en_o = '0;
    #1
    $display("Initialized inputs\n");

    // Access logfile
    logfile = $fopen({LOG_FILE},"a");

    // Testcases for 16-bit vector multiplication with reduction
    resetsim(errors); 
    operation_o.mod[31:0] ='d3329;
    operation_o.mod[63:32]='d3327;
    @(negedge clk_o);
    for (int i=0; i<16; ++i) begin
      tmp1 = $urandom(3*i)%'d3329;
      tmp2 = $urandom(8*i)%'d3329;
      tmp = (tmp1 * tmp2);
      operation_o.operand_a[i*16+:16] = tmp1;
      operation_o.operand_b[i*16+:16] = mont_mul_16(
        .op0_i(tmp2), 
        .op1_i(16'd1353), 
        .q_i(16'd3329), 
        .q_dash_i(16'd3327));
      res_exp[i*16+:16] =  tmp % 'd3329;
    end
    mulvm(mulv_m16h);
    @(negedge clk_o);

    errors_total = errors_total + errors;
    $display("Simulation of 16-bit Vector-Multiplication with Reduction completed with %d errors",errors);

    // Testcases for 16-bit scalar-vector multiplication with reduction
    operation_o.mod[31:0] ='d3329;
    operation_o.mod[63:32]='d3327;
    @(negedge clk_o);
    lane = $urandom(16)%'d16;
    for (int i=0; i<16; ++i) begin
      tmp1 = $urandom(3*i)%'d3329;
      tmp2 = $urandom(8*i)%'d3329;
      lane_op[i*16+:16] = tmp2;
      operation_o.operand_a[i*16+:16] = tmp1;
      operation_o.operand_b[i*16+:16] = mont_mul_16(
        .op0_i(tmp2), 
        .op1_i(16'd1353), 
        .q_i(16'd3329), 
        .q_dash_i(16'd3327));
    end
    for (int i=0; i<16; ++i) begin
      tmp = (operation_o.operand_a[i*16+:16] * lane_op[lane*16+:16]);
      res_exp[i*16+:16] =  tmp %'d3329;
    end
    mulvml(mulv_ml16h,lane);
    @(negedge clk_o);    
    
    resetsim(errors); 
    errors_total = errors_total + errors;
    $display("Simulation of 16-bit Scalar-Vector-Multiplication with Reduction completed with %d errors",errors);


    // Testcases for 16-bit vector multiplication with truncation
    resetsim(errors); 
    operation_o.mod[31:0] ='d3329;
    operation_o.mod[63:32]='d3327;
    @(negedge clk_o);
    lane = $urandom(16)%'d16;
    for (int i=0; i<16; ++i) begin
      tmp1 = $urandom(3*i);
      tmp2 = $urandom(8*i);
      tmp = (tmp1[15:0] * tmp2[15:0]);
      operation_o.operand_a[i*16+:16] = tmp1;
      operation_o.operand_b[i*16+:16] = tmp2;
      res_exp[i*16+:16] =  tmp[15:0];
    end
    mulv(mulv_16h);
    @(negedge clk_o);
    errors_total = errors_total + errors;
    $display("Simulation of 16-bit Vector-Multiplication with Truncation completed with %d errors",errors);

  // Testcases for 16-bit scalar-vector multiplication with truncation
    resetsim(errors); 
    operation_o.mod[31:0] ='d3329;
    operation_o.mod[63:32]='d3327;
    lane = $urandom(16)%'d16;
    @(negedge clk_o);
    for (int i=0; i<16; ++i) begin
      tmp1 = $urandom(3*i);
      tmp2 = $urandom(8*i);
      lane_op[i*16+:16] = tmp2;
      operation_o.operand_a[i*16+:16] = tmp1;
      operation_o.operand_b[i*16+:16] = tmp2;
    end
    for (int i=0; i<16; ++i) begin
      tmp = (operation_o.operand_a[i*16+:16] * lane_op[lane*16+:16]);
      res_exp[i*16+:16] = tmp[15:0];
    end
    mulvl(mulv_l16h,lane);
    @(negedge clk_o);
    errors_total = errors_total + errors;
    $display("Simulation of 16-bit Scalar-Vector-Multiplication with Truncation completed with %d errors",errors);


    // Testcases for 32-bit vector multiplication with reduction
    resetsim(errors);  
    operation_o.mod[31:0] ='d8380417;
    operation_o.mod[63:32]='d4236238847;
    @(negedge clk_o);
    for (int i=0; i<8; ++i) begin
      tmp1 = $urandom(3*i)%32'h7fe001;
      tmp2 = $urandom(8*i)% ('h7fe001);
      tmp = (tmp1 * tmp2);
      operation_o.operand_a[i*32+:32] = tmp1;
      operation_o.operand_b[i*32+:32] = mont_mul_32(
        .op0_i(tmp2), 
        .op1_i(32'd2365951), 
        .q_i(32'd8380417), 
        .q_dash_i(32'd4236238847));
      res_exp[i*32+:32] =  tmp % 'h7fe001;
    end
    mulvm(mulv_m8s);
    @(negedge clk_o);  
    resetsim(errors);   
    errors_total = errors_total + errors;
    $display("Simulation of 32-bit Vector-Multiplication with Reduction completed with %d errors",errors);


    // Testcases for 32-bit scalar-vector multiplication with reduction
    resetsim(errors);   
    operation_o.mod[31:0] ='d8380417;
    operation_o.mod[63:32]='d4236238847;
    lane = $urandom(16)%'d8;
    @(negedge clk_o);
    for (int i=0; i<8; ++i) begin
      tmp1 = $urandom(3*i)%32'h7fe001;
      tmp2 = $urandom(8*i)% ('h7fe001);
      operation_o.operand_a[i*32+:32] = tmp1;
      lane_op[i*32+:32] = tmp2;
      operation_o.operand_b[i*32+:32] = mont_mul_32(
        .op0_i(tmp2), 
        .op1_i(32'd2365951), 
        .q_i(32'd8380417), 
        .q_dash_i(32'd4236238847));
    end
    for (int i=0; i<8; ++i) begin
      tmp = (operation_o.operand_a[i*32+:32] * lane_op[lane*32+:32]);
      res_exp[i*32+:32] =  tmp %'d8380417;
    end
    mulvml(mulv_ml8s,lane);
    @(negedge clk_o);
    errors_total = errors_total + errors;
    $display("Simulation of 32-bit Scalar-Vector-Multiplication with Reduction completed with %d errors",errors);

 
    // Testcases for 32-bit vector multiplication with truncation
    resetsim(errors);   
    operation_o.mod[31:0] ='d8380417;
    operation_o.mod[63:32]='d4236238847;

    @(negedge clk_o);
    for (int i=0; i<8; ++i) begin
      tmp1 = $urandom(3*i)%32'h7fe001;
      tmp2 = $urandom(8*i)% ('h7fe001);
      operation_o.operand_a[i*32+:32] = tmp1[31:0];
      operation_o.operand_b[i*32+:32] = tmp2[31:0];
      tmp = (tmp1[31:0] * tmp2[31:0]);
      res_exp[i*32+:32] = tmp[31:0];
    end
    mulv(mulv_8s);
    @(negedge clk_o);
    errors_total = errors_total + errors;
    $display("Simulation of 32-bit Vector-Multiplication with Truncation completed with %d errors",errors);

    // Testcases for 32-bit scalar-vector multiplication with truncation
    resetsim(errors);   
    operation_o.mod[31:0] ='d8380417;
    operation_o.mod[63:32]='d4236238847;
    lane = $urandom(16)%'d8;
    @(negedge clk_o);
    for (int i=0; i<8; ++i) begin
      tmp1 = $urandom(3*i)%32'h7fe001;
      tmp2 = $urandom(8*i)% ('h7fe001);
      lane_op[i*32+:32] = tmp2;
      operation_o.operand_a[i*32+:32] = tmp1[31:0];
      operation_o.operand_b[i*32+:32] = tmp2[31:0];
    end
    for (int i=0; i<8; ++i) begin
      tmp = (operation_o.operand_a[i*32+:32] * lane_op[lane*32+:32]);
      res_exp[i*32+:32] =  tmp[31:0];
    end
    mulvl(mulv_l8s,lane);
    @(negedge clk_o);
    errors_total = errors_total + errors;
    $display("Simulation of 32-bit Scalar-Vector-Multiplication with Truncation completed with %d errors",errors);


    $display("Simulation of %s completed with %d errors",uut_name,errors_total);
    $fclose(logfile);
    $stop;

  end

endmodule
