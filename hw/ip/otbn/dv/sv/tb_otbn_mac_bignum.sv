// Copyright "Towards ML-KEM & ML-DSA on OpenTitan" Authors
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0


`resetall
//`timescale 1ns/10ps

`define PERIOD 5 // 100 MHz

module tb_otbn_mac_bignum
  import otbn_pkg::*;
#(
  parameter LOG_FILE = "../sim_results.log"
)(

);
    logic                   clk;
    logic                   rst;

    mac_bignum_operation_t  operation;
    logic                   mac_en;
    logic                   mac_commit;

    logic [WLEN-1:0]        operation_result;
    flags_t                 operation_flags;
    flags_t                 operation_flags_en;
    logic                   operation_intg_violation_err;

    mac_predec_bignum_t     mac_predec_bignum;
    logic                   predec_error;

    logic [WLEN-1:0]        urnd_data;
    logic                   sec_wipe_acc_urnd;

    logic [ExtWLEN-1:0]     ispr_acc_intg;
    logic [ExtWLEN-1:0]     ispr_acc_wr_data_intg;
    logic                   ispr_acc_wr_en;

  // Unit under Test
  otbn_mac_bignum #(
  ) UUT (
    .clk_i(clk),
    .rst_ni(rst),

    .operation_i(operation),
    .mac_en_i(mac_en),
    .mac_commit_i(mac_commit),

    .operation_result_o(operation_result),
    .operation_flags_o(operation_flags),
    .operation_flags_en_o(operation_flags_en),
    .operation_intg_violation_err_o(operation_intg_violation_err),

    .mac_predec_bignum_i(mac_predec_bignum),
    .predec_error_o(predec_error),

    .urnd_data_i(urnd_data),
    .sec_wipe_acc_urnd_i(sec_wipe_acc_urnd),

    .ispr_acc_intg_o(ispr_acc_intg),
    .ispr_acc_wr_data_intg_i(ispr_acc_wr_data_intg),
    .ispr_acc_wr_en_i(ispr_acc_wr_en)
  );

  // Tester 
  tester_otbn_mac_bignum #(
  ) U_TESTER (
    .clk_o(clk),
    .rst_no(rst),

    .operation_o(operation),
    .mac_en_o(mac_en),
    .mac_commit_o(mac_commit),

    .operation_result_i(operation_result),
    .operation_flags_i(operation_flags),
    .operation_flags_en_i(operation_flags_en),
    .operation_intg_violation_err_i(operation_intg_violation_err),

    .mac_predec_bignum_o(mac_predec_bignum),
    .predec_error_i(predec_error),

    .urnd_data_o(urnd_data),
    .sec_wipe_acc_urnd_o(sec_wipe_acc_urnd),

    .ispr_acc_intg_i(ispr_acc_intg),
    .ispr_acc_wr_data_intg_o(ispr_acc_wr_data_intg),
    .ispr_acc_wr_en_o(ispr_acc_wr_en)
  );

endmodule
