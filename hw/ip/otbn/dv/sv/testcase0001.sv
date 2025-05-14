// Copyright "Towards ML-KEM & ML-DSA on OpenTitan" Authors
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

$fwrite(f,"----------------------------------------------------------------\n");   
$fwrite(f,"-- Testcase 1 - Smoketest\n");
$fwrite(f,"----------------------------------------------------------------\n");

// Write IMEM from File
write_imem_from_file_tl_ul(.log_filehandle(f), .imem_file_path({mem_path, "imem_smoke_test.txt"}), .clk(clk_i), .clk_cycles(cc), .start_address(0), .tl_o(tl_o), .tl_i(tl_i_d) );

$fwrite(f,"-- IMEM\n");
// Read IMEM  
for (int i=0 ; i<129 ; i++) begin 
    read_tl_ul(.log_filehandle(f), .data(rdbk), .clk(clk_i), .clk_cycles(cc), .address(OTBN_IMEM_OFFSET+4*i), .tl_o(tl_o), .tl_i(tl_i_d) );
end     

 // Write DMEM from File
write_dmem_from_file_tl_ul(.log_filehandle(f), .dmem_file_path({mem_path, "dmem_smoke_test.txt"}), .clk(clk_i), .clk_cycles(cc), .start_address(0), .tl_o(tl_o), .tl_i(tl_i_d) );

// Additional write to provide some seed for RND:
wdr_word = 256'hAAAAAAAA_99999999_AAAAAAAA_99999999_AAAAAAAA_99999999_AAAAAAAA_99999999;
for (int i=0; i<8; ++i) begin
  write_tl_ul(.log_filehandle(f), .clk(clk_i), .clk_cycles(cc), .data(wdr_word[32*i+:32]), .address(OTBN_DMEM_OFFSET+4*i+256), .tl_o(tl_o), .tl_i(tl_i_d) );
end

// Additional write to provide some seed for KEY_S0L:
wdr_word = 256'hdeadbeef_deadbeef_deadbeef_deadbeef_deadbeef_deadbeef_deadbeef_deadbeef;
for (int i=0; i<8; ++i) begin
  write_tl_ul(.log_filehandle(f), .clk(clk_i), .clk_cycles(cc), .data(wdr_word[32*i+:32]), .address(OTBN_DMEM_OFFSET+4*i+288), .tl_o(tl_o), .tl_i(tl_i_d) );
end

// Additional write to provide some seed for KEY_S0H:
wdr_word = 256'hdeadbeef_deadbeef_deadbeef_deadbeef;
for (int i=0; i<8; ++i) begin
  write_tl_ul(.log_filehandle(f), .clk(clk_i), .clk_cycles(cc), .data(wdr_word[32*i+:32]), .address(OTBN_DMEM_OFFSET+4*i+320), .tl_o(tl_o), .tl_i(tl_i_d) );
end

// Additional write to provide some seed for KEY_S1L:
wdr_word = 256'hbaadf00d_baadf00d_baadf00d_baadf00d_baadf00d_baadf00d_baadf00d_baadf00d;
for (int i=0; i<8; ++i) begin
  write_tl_ul(.log_filehandle(f), .clk(clk_i), .clk_cycles(cc), .data(wdr_word[32*i+:32]), .address(OTBN_DMEM_OFFSET+4*i+352), .tl_o(tl_o), .tl_i(tl_i_d) );
end

// Additional write to provide some seed for KEY_S1H:
wdr_word = 256'hbaadf00d_baadf00d_baadf00d_baadf00d;
for (int i=0; i<8; ++i) begin
  write_tl_ul(.log_filehandle(f), .clk(clk_i), .clk_cycles(cc), .data(wdr_word[32*i+:32]), .address(OTBN_DMEM_OFFSET+4*i+384), .tl_o(tl_o), .tl_i(tl_i_d) );
end

$fwrite(f,"-- DMEM\n");
// Read DMEM  
for (int i=0 ; i<16 ; i++) begin 
    read_tl_ul(.log_filehandle(f), .data(rdbk), .clk(clk_i), .clk_cycles(cc), .address(OTBN_DMEM_OFFSET+4*i), .tl_o(tl_o), .tl_i(tl_i_d) );
end   
	   
$fwrite(f,"----------------------------------------------------------------\n");   

// Set Instruction Counter to zero (optional)
write_tl_ul(.log_filehandle(f), .clk(clk_i), .clk_cycles(cc), .data(32'h0), .address(OTBN_INSN_CNT_OFFSET), .tl_o(tl_o), .tl_i(tl_i_d) );

// Start Programm in IMEM
write_tl_ul(.log_filehandle(f), .clk(clk_i), .clk_cycles(cc), .data(CmdExecute), .address(OTBN_CMD_OFFSET), .tl_o(tl_o), .tl_i(tl_i_d) );

// Poll on Status Register until Programm is finished
rdbk = '1;
while (rdbk != '0) begin 
    read_tl_ul(.log_filehandle(f), .data(rdbk), .clk(clk_i), .clk_cycles(cc), .address(OTBN_STATUS_OFFSET), .tl_o(tl_o), .tl_i(tl_i_d) );
end 

// Read DMEM  
for (int i=0 ; i<30 ; i++) begin 
    read_tl_ul(.log_filehandle(f), .data(rdbk), .clk(clk_i), .clk_cycles(cc), .address(OTBN_DMEM_OFFSET+4*i+512), .tl_o(tl_o), .tl_i(tl_i_d) );
    
    case(i)
      0   :   assert (rdbk == 32'hd0beb513) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
      1   :   assert (rdbk == 32'ha0be911a) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
      2   :   assert (rdbk == 32'h717d462d) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
      3   :   assert (rdbk == 32'hcfffdc07) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
      4   :   assert (rdbk == 32'hf0beb51b) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
      5   :   assert (rdbk == 32'h80be9112) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
      6   :   assert (rdbk == 32'h70002409) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
      7   :   assert (rdbk == 32'hd0beb533) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
      8   :   assert (rdbk == 32'h00000510) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
      9   :   assert (rdbk == 32'hd0beb169) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
      10  :   assert (rdbk == 32'hfad44c00) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
      11  :   assert (rdbk == 32'h000685f5) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
      12  :   assert (rdbk == 32'hffa17d6a) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
      13  :   assert (rdbk == 32'h4c000000) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
      14  :   assert (rdbk == 32'h00000034) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
      15  :   assert (rdbk == 32'hfffffff4) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end

      16  :   assert (rdbk == 32'hfacefeed) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
      17  :   assert (rdbk == 32'hd0beb533) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
      18  :   assert (rdbk == 32'h00000123) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
      19  :   assert (rdbk == 32'h00000123) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
      20  :   assert (rdbk == 32'hcafef010) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
      21  :   assert (rdbk == 32'h89c9b54f) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
      22  :   assert (rdbk == 32'h00000052) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
      23  :   assert (rdbk == 32'h00000020) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
      24  :   assert (rdbk == 32'h00000016) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
      25  :   assert (rdbk == 32'h0000001a) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
      26  :   assert (rdbk == 32'h00400000) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
      27  :   assert (rdbk == 32'h00018000) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
      28  :   assert (rdbk == 32'h00000000) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
      29  :   assert (rdbk == 32'h00000804) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end

    endcase    

end

// Read DMEM  
for (int i=0 ; i<32 ; i++) begin     
    for (int j=0; j<8; ++j) begin
      read_tl_ul(.log_filehandle(f), .data(rdbk), .clk(clk_i), .clk_cycles(cc), .address(OTBN_DMEM_OFFSET+(4*j+1024)+(32*i)), .tl_o(tl_o), .tl_i(tl_i_d) );
      wdr_word[j*32+:32] = rdbk;
    end
    
    case(i)
      0   :   assert (wdr_word == 256'h37adadae_f9dbff5e_73880075_5466a52c_67a8c221_6978ad1b_25769434_0f09b7c8) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
      1   :   assert (wdr_word == 256'h00000000_00000000_00000000_00000000_baadf00d_baadf00d_baadf00d_baadf00d) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
      2   :   assert (wdr_word == 256'h440659a8_32f54897_440659a8_32f54898_dd6208a5_cc50f794_dd6208a5_cc50f791) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
      3   :   assert (wdr_word == 256'h23a776b0_bbc28370_34745ffa_22168ae8_7245a2d0_0357f208_431165e5_ed103473) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
      4   :   assert (wdr_word == 256'hce52215b_888f503c_df1f0aa4_eee357b5_1cf04d7a_d024bed4_edbc1090_b9dd0141) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
      5   :   assert (wdr_word == 256'hfafeeeae_bbb9f9df_abebbfef_99fdf9df_efbafaaf_f9bfd9ff_baeebbbb_dbff9bdb) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
      6   :   assert (wdr_word == 256'h28a88802_00088990_8888a00a_88189108_828aa820_09981808_8822aa2a_11109898) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
      7   :   assert (wdr_word == 256'hd25666ac_bbb1704f_23631fe5_11e568d7_6d30528f_f027c1f7_32cc1191_caef0343) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
      8   :   assert (wdr_word == 256'h870333f9_ddd71629_76364ab0_77830eb1_386507da_9641a791_679944c4_ac896525) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
      9   :   assert (wdr_word == 256'hd7c12b4d_f2c374c3_35d9da9b_b4d6d555_555554cc_cccccd55_555554cc_cccccd55) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
      10   :   assert (wdr_word == 256'h05011151_1112d2ed_54144010_32ced2ed_1045054f_d30cf2cd_45114443_f0cd30f0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
      11   :   assert (wdr_word == 256'hd75777fd_ccc4433c_77775ff5_44b43bc4_7d7557df_c334b4c4_77dd55d5_bbbc3433) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
      12  :   assert (wdr_word == 256'h2caccd53_332aa9a2_ccccb54a_ab1aa22a_d2caad35_299b1b2a_cd32ab2b_22229a9a) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
      13  :   assert (wdr_word == 256'ha1a55408_5564a69a_1252555a_43c8b58a_4a25a045_a689a3aa_20896565_97ba66a7) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
      14  :   assert (wdr_word == 256'h5ec45f47_d09a8aec_ac10254c_2c59e406_8dba5ca7_630e74e6_bcee9991_7956327a) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
      15:   assert (wdr_word == 256'hdc58894e_ddd71629_cb8ba005_77830eb1_8dba5d2f_9641a791_bcee9a19_ac896524) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
      16   :   assert (wdr_word == 256'hce52215b_888f503c_df1f0aa4_eee357b5_1cf04d7a_d024bed4_edbc1090_b9dd0141) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
      17  :   assert (wdr_word == 256'h55555555_33333333_55555555_33333333_55555555_33333333_55555555_33333331) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
      18  :   assert (wdr_word == 256'h23a7769f_bbc28381_34745fe9_22168a4e_c79af825_69be586e_9866bb3b_53769ada) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
      19  :   assert (wdr_word == 256'h28a88800_00088982_8888a009_8818910a_828aa801_09981800_00000000_00000000) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
      20   :   assert (wdr_word == 256'h78fccc06_2228e9d6_89c9b54f_887cf14e_c79af825_69be57c3_edbc10a1_b9dd0130) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
      21  :   assert (wdr_word == 256'h78fccc06_2228e9d6_89c9b54f_887cf1ee_efbafabd_f9bfd9ee_baeebbbb_dbff9bfa) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
      22  :   assert (wdr_word == 256'h78fccc06_2228e9d6_89c9b54f_887cf1ee_efbafabd_f9bfd9ee_baeebbbb_dbff9db7) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
      23  :   assert (wdr_word == 256'h78fccc06_2228e9d6_89c9b54f_887cf1ee_efbafabd_f9bfd9ee_baeebbbb_dbff99f3) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
      24  :   assert (wdr_word == 256'hcccccccc_bbbbbbbb_aaaaaaaa_facefeed_deadbeef_cafed00d_d0beb533_1234abcd) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
      25  :   assert (wdr_word == 256'hcccccccc_bbbbbbbb_aaaaaaaa_facefeed_deadbeef_cafed00d_d0beb533_1234abcd) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
      26  :   assert (wdr_word == 256'h78fccc06_2228e9d6_89c9b54f_887cf1ee_efbafabd_f9bfd9ee_baeebbbb_dbff9bfa) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
      27  :   assert (wdr_word == 256'h28a88802_00088990_8888a00a_88189108_828aa820_09981808_8822aa2a_11109898) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
      28  :   assert (wdr_word == 256'hd25666ac_bbb1704f_23631fe5_11e568d7_6d30528f_f027c1f7_32cc1191_caef0343) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
      29  :   assert (wdr_word == 256'h4f0d4b81_9f24f0c1_64341d3c_26628bdb_5763bcdf_63388709_e0654fef_eb0953c2) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
      30  :   assert (wdr_word == 256'h2167f87d_e9ee7ac7_ffa3d88b_ab123192_aee49292_4efa2ec9_b55098e0_68ba2fa1) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
      31  :   assert (wdr_word == 256'h37adadae_f9dbff5e_73880075_5466a52c_67a8c221_6978ad1b_25769434_0f09b7c8) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end

    endcase    
    
end
