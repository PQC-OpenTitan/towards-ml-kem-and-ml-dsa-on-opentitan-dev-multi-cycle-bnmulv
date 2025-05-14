// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
// Modified by Authors of "Towards ML-KEM & ML-DSA on OpenTitan" (https://eprint.iacr.org/2024/1192)
// Copyright "Towards ML-KEM & ML-DSA on OpenTitan" Authors

module kmac_top_sim (
  input logic clk_i,
  input logic rst_ni,

  input logic        app_req_valid_i,
  input logic [63:0] app_req_data_i,
  input logic [7:0]  app_req_strb_i,
  input logic        app_req_last_i,
  input logic        app_req_hold_i,
  input logic        app_req_next_i,

  output logic app_rsp_ready_o,
  output logic app_rsp_done_o,
  output logic [255:0] app_rsp_digest_share0_o,
  output logic [255:0] app_rsp_digest_share1_o,
  output logic app_rsp_error_o,

  output logic intr_kmac_done_o,
  output logic intr_fifo_empty_o,
  output logic intr_kmac_err_o,

  output logic idle_o,
  output logic err_o,
  output logic en_masking_o,
  output logic alert_o
  );
  import kmac_pkg::*;
  import kmac_reg_pkg::*;
  import edn_pkg::*;
  import tlul_pkg::*;
  import prim_alert_pkg::*;
  import prim_mubi_pkg::*;
  import lc_ctrl_pkg::*;

  prim_mubi_pkg::mubi4_t idle;
  // keymgr/kmac sideload wires
  keymgr_pkg::hw_key_req_t kmac_sideload_key;
  // kmac_app interfaces
  kmac_pkg::app_req_t [kmac_pkg::NumAppIntf-1:0] app_req;
  kmac_pkg::app_rsp_t [kmac_pkg::NumAppIntf-1:0] app_rsp;
  // edn interface
  edn_pkg::edn_req_t edn_req;
  edn_pkg::edn_rsp_t edn_rsp;
  // alert interface
  prim_alert_pkg::alert_rx_t [kmac_reg_pkg::NumAlerts-1:0] alert_rx;
  prim_alert_pkg::alert_tx_t [kmac_reg_pkg::NumAlerts-1:0] alert_tx;
  logic [kmac_reg_pkg::NumAlerts-1:0] alerts;
  // tlul interface
  tlul_pkg::tl_h2d_t tl_i_d,tl_i_q;
  tlul_pkg::tl_d2h_t tl_o;
  // lc escalate interface
  lc_ctrl_pkg::lc_tx_t lc_escalate_en;
  logic err_tl;

  // dut
  kmac #(
    .EnMasking(1),
    .SwKeyMasked(1)
  ) dut (
    .clk_i              (clk_i  ),
    .rst_ni             (rst_ni ),
    .rst_shadowed_ni    (rst_ni ),

    // TLUL interface
    .tl_i               (tl_i_q ),
    .tl_o               (tl_o   ),

    // Alerts
    .alert_rx_i         (alert_rx ),
    .alert_tx_o         (alert_tx ),

    // life cycle escalation input
    .lc_escalate_en_i   (lc_escalate_en ),

    // KeyMgr sideload key interface
    .keymgr_key_i       (kmac_sideload_key),

    // KeyMgr KDF datapath
    .app_i              (app_req ),
    .app_o              (app_rsp ),

    // Interrupts
    .intr_kmac_done_o   (intr_kmac_done_o   ),
    .intr_fifo_empty_o  (intr_fifo_empty_o  ),
    .intr_kmac_err_o    (intr_kmac_err_o    ),

    // Idle interface
    .idle_o             (idle ),

    .en_masking_o       (en_masking_o ),

    // EDN interface
    .clk_edn_i          (clk_i     ),
    .rst_edn_ni         (rst_ni    ),
    .entropy_o          (edn_req   ),
    .entropy_i          (edn_rsp   )
  );

  assign app_req[0] = kmac_pkg::APP_REQ_DEFAULT;
  assign app_req[1] = kmac_pkg::APP_REQ_DEFAULT;
  assign app_req[2] = kmac_pkg::APP_REQ_DEFAULT;

  assign app_req[3].valid   = app_req_valid_i;
  assign app_req[3].data    = app_req_data_i;
  assign app_req[3].strb    = app_req_strb_i;
  assign app_req[3].last    = app_req_last_i;
  assign app_req[3].hold    = app_req_hold_i;
  assign app_req[3].next    = app_req_next_i;

  assign app_rsp_ready_o          = app_rsp[3].ready;
  assign app_rsp_done_o           = app_rsp[3].done;
  assign app_rsp_digest_share0_o  = app_rsp[3].digest_share0[255:0];
  assign app_rsp_digest_share1_o  = app_rsp[3].digest_share1[255:0];
  assign app_rsp_error_o          = app_rsp[3].error;

  assign idle_o = (idle == prim_mubi_pkg::MuBi4True);

  genvar i;
  generate
    for (i=0; i < kmac_reg_pkg::NumAlerts; i++) begin
      assign alert_rx[i] = ALERT_RX_DEFAULT;
      assign alerts[i] = alert_tx[i].alert_p | ~alert_tx[i].alert_n;
    end
  endgenerate
  assign alert_o = |alerts;

  // kmac sideload interface
  assign kmac_sideload_key.key = {2{{256{1'b0}}}};
  assign kmac_sideload_key.valid = 1'b1;

  // lc escalate interface
  assign lc_escalate_en = lc_ctrl_pkg::LC_TX_DEFAULT;

  assign err_o = err_tl | (app_rsp[0] != kmac_pkg::APP_RSP_DEFAULT)
                        | (app_rsp[1] != kmac_pkg::APP_RSP_DEFAULT)
                        | (app_rsp[2] != kmac_pkg::APP_RSP_DEFAULT);

  // tlul adapter
  assign tl_i_d = tlul_pkg::TL_H2D_DEFAULT;

  tlul_cmd_intg_gen u_tlul_cmd_intg_gen (
    .tl_i(tl_i_d),
    .tl_o(tl_i_q)
  );

  tlul_rsp_intg_chk u_tlul_rsp_intg_chk (
    .tl_i (tl_o),
    .err_o(err_tl)
  );

  // edn response generation
  always_ff @ (posedge clk_i) begin
    edn_rsp <= edn_pkg::EDN_RSP_DEFAULT;
    if (edn_req.edn_req == 1'b1) begin
      edn_rsp.edn_ack <= edn_req.edn_req;
      edn_rsp.edn_bus <= $urandom();
    end
  end

endmodule
