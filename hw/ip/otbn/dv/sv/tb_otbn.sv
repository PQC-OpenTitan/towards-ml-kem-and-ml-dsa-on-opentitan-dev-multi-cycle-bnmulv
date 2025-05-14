// Copyright "Towards ML-KEM & ML-DSA on OpenTitan" Authors
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

`timescale 1ns / 1ps


module tb_otbn

    import prim_alert_pkg::*;
    import otbn_pkg::*;
    import otbn_reg_pkg::*;
    import tb_tl_ul_pkg::*;

    (
    
    );
    
    // Parameter
    localparam bit                   Stub         = 1'b0;
    localparam regfile_e             RegFile      = RegFileFF;
    localparam logic [NumAlerts-1:0] AlertAsyncOn = {NumAlerts{1'b0}};
    
    // Default seed and permutation for URND LFSR
    localparam urnd_prng_seed_t RndCnstUrndPrngSeed = RndCnstUrndPrngSeedDefault; 
     
    localparam string                 log_path = "/home/stelzer/projects/mpi/2024-pqc-opentitan/hw/ip/otbn/dv/sv/log/";
    localparam string                 mem_path = "/home/stelzer/projects/mpi/2024-pqc-opentitan/hw/ip/otbn/dv/sv/mem/";
    
    // Filehandle, clock cycle counter, readback data variable, teststate
    integer                                     f;   
    integer                                     cc;
    integer                                     cc_start;
    integer                                     cc_stop;
//    integer                                     cc_count_dilithium;
//    integer                                     cc_count_kyber;
    
//    integer                                     cc_count_dilithium_indirect;
//    integer                                     cc_count_kyber_indirect;
    
//    integer                                     cc_count_dilithium_inv;
//    integer                                     cc_count_kyber_inv;    
    
//    integer                                     cc_count_dilithium_inv_indirect;
//    integer                                     cc_count_kyber_inv_indirect;    
 
//    integer                                     cc_count_falcon512_indirect;
//    integer                                     cc_count_falcon1024_indirect;

//    integer                                     cc_count_falcon512_inv_indirect;
//    integer                                     cc_count_falcon1024_inv_indirect;

//    integer                                     cc_count_dilithium_pointwise_mul;
//    integer                                     cc_count_kyber_base_mul;
//    integer                                     cc_count_falcon512_pointwise_mul;
//    integer                                     cc_count_falcon1024_pointwise_mul;

//    integer                                     cc_count_keccak;
//    integer                                     cc_count_shake128;
//    integer                                     cc_count_shake256;
//    integer                                     cc_count_sampleinball;
//    integer                                     cc_count_poly_uniform;

//    integer                                     cc_count_usehint2;
//    integer                                     cc_count_poly_usehint2;
//    integer                                     cc_count_packw12;

//    integer                                     cc_count_usehint35;
//    integer                                     cc_count_poly_usehint35;
//    integer                                     cc_count_packw135;

//    integer                                     cc_count_dilithium_2;
//    integer                                     cc_count_dilithium_3;
//    integer                                     cc_count_dilithium_5;

    logic                       [31:0]          rdbk;
    logic                       [255:0]         wdr_word;
    logic                       [255:0]         wdr_op0[7:0];
    logic                       [255:0]         wdr_op1[7:0];
    logic                       [255:0]         wdr_res[7:0];
    string                                      teststate;  
    integer                                     error_count;
    integer                                     error_count_total;

    // Clock and Reset
    logic                                       clk_i;
    logic                                       rst_ni;

    // Bus Signals    
    tlul_pkg::tl_h2d_t                          tl_i_d,tl_i_q;
    tlul_pkg::tl_d2h_t                          tl_o;
    logic                                       err_tl;
       
    // Inter-module signals
    prim_mubi_pkg::mubi4_t                      idle_o;
    
    // Interrupts
    logic                                       intr_done_o;
    
    // Alerts
    prim_alert_pkg::alert_rx_t [NumAlerts-1:0] alert_rx_i;
    prim_alert_pkg::alert_tx_t [NumAlerts-1:0] alert_tx_o;
    
    // Memory configuration
    prim_ram_1p_pkg::ram_1p_cfg_t ram_cfg_i;

    
    // EDN clock and interface
    logic                                       clk_edn_i;
    logic                                       rst_edn_ni;
    
    edn_pkg::edn_req_t                          edn_rnd_o;
    edn_pkg::edn_rsp_t                          edn_rnd_i;
    
    edn_pkg::edn_req_t                          edn_urnd_o;
    edn_pkg::edn_rsp_t                          edn_urnd_i;
    
    lc_ctrl_pkg::lc_tx_t                        lc_rma_req_i,lc_escalate_en_i;   

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
    
    // DUT   
    otbn #(.Stub(Stub),
        .RegFile(RegFile),
        .AlertAsyncOn(AlertAsyncOn),
        
        // Default seed and permutation for URND LFSR
        .RndCnstUrndPrngSeed(RndCnstUrndPrngSeed),
        .RndCnstOtbnKey(RndCnstOtbnKeyDefault),
        .RndCnstOtbnNonce(RndCnstOtbnNonceDefault))
    DUT (
        .clk_i(clk_i),
        .rst_ni(rst_ni),
        
        .tl_i(tl_i_q),
        .tl_o(tl_o),
        
          // Inter-module signals
        .idle_o(idle_o),
        
          // Interrupts
        .intr_done_o(intr_done_o),
        
          // Alerts
        .alert_rx_i(alert_rx_i),
        .alert_tx_o(alert_tx_o),

         // Lifecycle interfaces
         .lc_escalate_en_i(lc_escalate_en_i),

         .lc_rma_req_i(lc_rma_req_i),
         .lc_rma_ack_o(),
        
          // Memory configuration
        .ram_cfg_i(ram_cfg_i),
        
          // EDN clock and interface
        .clk_edn_i(clk_edn_i),
        .rst_edn_ni(rst_edn_ni),
        .edn_rnd_o(edn_rnd_o),
        .edn_rnd_i(edn_rnd_i),
        
        .edn_urnd_o(edn_urnd_o),
        .edn_urnd_i(edn_urnd_i),
          // Key request to OTP (running on clk_fixed)
        .clk_otp_i(clk_edn_i),
        .rst_otp_ni(rst_edn_ni),
        .otbn_otp_key_o(),
        .otbn_otp_key_i('b0),

        .keymgr_key_i('b0)
        
    );
    
    // Clock Generation
    initial begin 
        clk_i = 0;

        forever begin
            #1 clk_i = ~clk_i;

        end
    end
    
    initial begin 

        cc = 0;
        forever begin
            @(posedge clk_i) ;
            cc = cc + 1;
        end
    end    
    
    initial begin 
        clk_edn_i = 0;
        forever begin
            #1 clk_edn_i = ~clk_edn_i;
        end
    end



    
    // EDN Response Generation
    
    always_ff @ (posedge clk_edn_i)
        begin
            edn_urnd_i = edn_pkg::EDN_RSP_DEFAULT;
            edn_rnd_i = edn_pkg::EDN_RSP_DEFAULT; 
            
            if (edn_urnd_o.edn_req == 1'b1)
                begin
                    edn_urnd_i.edn_ack = edn_urnd_o.edn_req;
                    edn_urnd_i.edn_bus = $urandom();
                end
                
            if (edn_rnd_o.edn_req == 1'b1)
                begin
                    edn_rnd_i.edn_ack = edn_rnd_o.edn_req;
                    edn_rnd_i.edn_bus = $urandom();
                end
             
        end
    
    
    // Tester

    initial begin 
        //Inital Bus Signals
        tl_i_d.a_address = 32'h0;
        tl_i_d.a_data = 32'h0;
        tl_i_d.a_mask = 4'hF;
        tl_i_d.a_opcode = tlul_pkg::PutFullData;
        tl_i_d.a_size = 2'b10;
        tl_i_d.a_source = 7'h0;
        tl_i_d.a_valid = 1'b0;
        tl_i_d.a_user = tlul_pkg::TL_A_USER_DEFAULT;
        
        rst_ni = 1;   
        rst_edn_ni = 1;
        #5
        rst_ni = 0;
        rst_edn_ni = 0;
        #5
        rst_ni = 1;   
        rst_edn_ni = 1;
        
        lc_escalate_en_i = lc_ctrl_pkg::LC_TX_DEFAULT;
        lc_rma_req_i = lc_ctrl_pkg::LC_TX_DEFAULT;
        
        f = $fopen({log_path, "tl_output.txt"},"w");
        
        error_count = 0;
        error_count_total = '0;
        // Header 
        $fwrite(f,"----------------------------------------------------------------\n");
        $fwrite(f,"-- OTBN - RTL - Testbench                                       \n");
        $fwrite(f,"----------------------------------------------------------------\n");

        // Read Registers
        for (int i=0 ; i<6 ; i++) begin
            read_tl_ul(.log_filehandle(f), .data(rdbk), .clk(clk_i), .clk_cycles(cc), .address(4*i), .tl_o(tl_o), .tl_i(tl_i_d) );
        end
        
        // Interrupt Test Register
        read_tl_ul(.log_filehandle(f), .data(rdbk), .clk(clk_i), .clk_cycles(cc), .address(0), .tl_o(tl_o), .tl_i(tl_i_d) );
        
        teststate = "Run Application";
        // Write Programm to IMEM  
        for (int i=0 ; i<128 ; i++) begin 
            // NOP Instruction
            write_tl_ul(.log_filehandle(f), .clk(clk_i), .clk_cycles(cc), .data(32'b10011), .address(OTBN_IMEM_OFFSET+4*i), .tl_o(tl_o), .tl_i(tl_i_d) );   
        end
        // ECALL Instruction
        write_tl_ul(.log_filehandle(f), .clk(clk_i), .clk_cycles(cc), .data(32'b1110011), .address(OTBN_IMEM_OFFSET+4*128), .tl_o(tl_o), .tl_i(tl_i_d) );
        
        // Read IMEM  
        for (int i=0 ; i<129 ; i++) begin 
            //NOP
            read_tl_ul(.log_filehandle(f), .data(rdbk), .clk(clk_i), .clk_cycles(cc), .address(OTBN_IMEM_OFFSET+4*i), .tl_o(tl_o), .tl_i(tl_i_d) );
        end        
        // Set Instruction Counter to zero (optional)
        write_tl_ul(.log_filehandle(f), .clk(clk_i), .clk_cycles(cc), .data(32'h0), .address(OTBN_INSN_CNT_OFFSET), .tl_o(tl_o), .tl_i(tl_i_d) );
        
        // Start Programm in IMEM
        write_tl_ul(.log_filehandle(f), .clk(clk_i), .clk_cycles(cc), .data(CmdExecute), .address(OTBN_CMD_OFFSET), .tl_o(tl_o), .tl_i(tl_i_d) );
        
        // Poll on Status Register until Programm is finished
        rdbk = '1;
        while (rdbk != '0) begin 
            read_tl_ul(.log_filehandle(f), .data(rdbk), .clk(clk_i), .clk_cycles(cc), .address(OTBN_STATUS_OFFSET), .tl_o(tl_o), .tl_i(tl_i_d) );
        end 

	      $display("Begin Testcase 0000: MUL256\n");	
        `include "testcase0000.sv"
        $fwrite(f,"----------------------------------------------------------------\n");           
        $fwrite(f,"Errors in Testcase 0000: %d \n",error_count);
        $fwrite(f,"----------------------------------------------------------------\n");  
        error_count_total = error_count_total + error_count;
        error_count = '0;

	      $display("Begin Testcase 0001: Smoktetest\n");	
         `include "testcase0001.sv"
        $fwrite(f,"----------------------------------------------------------------\n");           
        $fwrite(f,"Errors in Testcase 0001: %d \n",error_count);
        $fwrite(f,"----------------------------------------------------------------\n");  
        error_count_total = error_count_total + error_count;
        error_count = '0;

	      $display("Begin Testcase 0002: BN.ADDV\n");	
         `include "testcase0002.sv"
        $fwrite(f,"----------------------------------------------------------------\n");           
        $fwrite(f,"Errors in Testcase 0002: %d \n",error_count);
        $fwrite(f,"----------------------------------------------------------------\n");  
        error_count_total = error_count_total + error_count;
        error_count = '0;

	      $display("Begin Testcase 0003: BN.ADDVM\n");	
         `include "testcase0003.sv" 
        $fwrite(f,"----------------------------------------------------------------\n");           
        $fwrite(f,"Errors in Testcase 0003: %d \n",error_count);
        $fwrite(f,"----------------------------------------------------------------\n");  
        error_count_total = error_count_total + error_count;
        error_count = '0;

	      $display("Begin Testcase 0004: BN.ADDVM\n");	
         `include "testcase0004.sv" 
        $fwrite(f,"----------------------------------------------------------------\n");           
        $fwrite(f,"Errors in Testcase 0004: %d \n",error_count);
        $fwrite(f,"----------------------------------------------------------------\n");    
        error_count_total = error_count_total + error_count;
        error_count = '0;

	      $display("Begin Testcase 0005: BN.ADDV\n");	
         `include "testcase0005.sv" 
        $fwrite(f,"----------------------------------------------------------------\n");           
        $fwrite(f,"Errors in Testcase 0005: %d \n",error_count);
        $fwrite(f,"----------------------------------------------------------------\n");    
        error_count_total = error_count_total + error_count;
        error_count = '0;

	     $display("Begin Testcase 0006: BN.SHV\n");	
         `include "testcase0006.sv" 
        $fwrite(f,"----------------------------------------------------------------\n");           
        $fwrite(f,"Errors in Testcase 0006: %d \n",error_count);
        $fwrite(f,"----------------------------------------------------------------\n");           
	     
	     $display("Begin Testcase 0008: BN.TRN\n");	
         `include "testcase0008.sv" 
        $fwrite(f,"----------------------------------------------------------------\n");           
        $fwrite(f,"Errors in Testcase 0008: %d \n",error_count);
        $fwrite(f,"----------------------------------------------------------------\n");    
        error_count_total = error_count_total + error_count;
        error_count = '0;
        
	      $display("Begin Testcase 0009: BN.TRN\n");	
         `include "testcase0009.sv" 
        $fwrite(f,"----------------------------------------------------------------\n");           
        $fwrite(f,"Errors in Testcase 0009: %d \n",error_count);
        $fwrite(f,"----------------------------------------------------------------\n");    
        error_count_total = error_count_total + error_count;
        error_count = '0;
        
	      $display("Begin Testcase 0010: BN.MULV\n");	
         `include "testcase0010.sv" 
        $fwrite(f,"----------------------------------------------------------------\n");           
        $fwrite(f,"Errors in Testcase 0010: %d \n",error_count);
        $fwrite(f,"----------------------------------------------------------------\n");    
        error_count_total = error_count_total + error_count;
        error_count = '0;

	      $display("Begin Testcase 0008: BN.TRN\n");	
         `include "testcase0008.sv" 
        $fwrite(f,"----------------------------------------------------------------\n");           
        $fwrite(f,"Errors in Testcase 0008: %d \n",error_count);
        $fwrite(f,"----------------------------------------------------------------\n");    
        error_count_total = error_count_total + error_count;
        error_count = '0;
        
	      $display("Begin Testcase 0009: BN.TRN\n");	
         `include "testcase0009.sv" 
        $fwrite(f,"----------------------------------------------------------------\n");           
        $fwrite(f,"Errors in Testcase 0009: %d \n",error_count);
        $fwrite(f,"----------------------------------------------------------------\n");    
        error_count_total = error_count_total + error_count;
        error_count = '0;
        
	      $display("Begin Testcase 0010: BN.MULV\n");	
         `include "testcase0010.sv" 
        $fwrite(f,"----------------------------------------------------------------\n");           
        $fwrite(f,"Errors in Testcase 0010: %d \n",error_count);
        $fwrite(f,"----------------------------------------------------------------\n");    
        error_count_total = error_count_total + error_count;
        error_count = '0;

	      $display("Begin Testcase 0011: BN.MULVM\n");	
         `include "testcase0011.sv" 
        $fwrite(f,"----------------------------------------------------------------\n");           
        $fwrite(f,"Errors in Testcase 0011: %d \n",error_count);
        $fwrite(f,"----------------------------------------------------------------\n");    
        error_count_total = error_count_total + error_count;
        error_count = '0;

	      $display("Begin Testcase 0012: BN.MULV.L\n");	
         `include "testcase0012.sv" 
        $fwrite(f,"----------------------------------------------------------------\n");           
        $fwrite(f,"Errors in Testcase 0012: %d \n",error_count);
        $fwrite(f,"----------------------------------------------------------------\n");    
        error_count_total = error_count_total + error_count;
        error_count = '0;

	      $display("Begin Testcase 0013: BN.MULVM.L\n");	
         `include "testcase0013.sv" 
        $fwrite(f,"----------------------------------------------------------------\n");           
        $fwrite(f,"Errors in Testcase 0013: %d \n",error_count);
        $fwrite(f,"----------------------------------------------------------------\n");    
        error_count_total = error_count_total + error_count;
        error_count = '0;

        $fwrite(f,"----------------------------------------------------------------\n");           
        $fwrite(f,"Errors in total: %d \n",error_count_total);
        $fwrite(f,"----------------------------------------------------------------\n");  
        
         
        $fclose(f);
        $stop;
    end
 
    assign ram_cfg_i.ram_cfg.cfg_en = 1'b0;
    assign ram_cfg_i.ram_cfg.cfg = 4'b0;   
    assign ram_cfg_i.rf_cfg.cfg_en = 1'b0;
    assign ram_cfg_i.rf_cfg.cfg = 4'b0; 
       
    assign alert_rx_i[0].ack_n  = 1'b1;
    assign alert_rx_i[0].ack_p  = 1'b0;
    assign alert_rx_i[0].ping_n = 1'b1;
    assign alert_rx_i[0].ping_p = 1'b0;
    assign alert_rx_i[1].ack_n  = 1'b1;
    assign alert_rx_i[1].ack_p  = 1'b0;
    assign alert_rx_i[1].ping_n = 1'b1;
    assign alert_rx_i[1].ping_p = 1'b0;
  
   // Generate integrity signals for bus
  // to otbn
  assign tl_i_d.a_param = 3'b0;

  assign tl_i_d.d_ready = 1'b1;
  
  tlul_cmd_intg_gen u_tlul_cmd_intg_gen (
      .tl_i(tl_i_d),
      .tl_o(tl_i_q)
  );

  // Check integrity of transmission from
  // otbn
  tlul_rsp_intg_chk u_tlul_rsp_intg_chk (
      .tl_i (tl_o),
      .err_o(err_tl)
  );
   
endmodule

