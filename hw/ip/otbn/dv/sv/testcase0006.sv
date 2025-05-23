// Copyright "Towards ML-KEM & ML-DSA on OpenTitan" Authors
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

$fwrite(f,"----------------------------------------------------------------\n");   
$fwrite(f,"-- BN.SHV TEST\n");
$fwrite(f,"----------------------------------------------------------------\n");

// Write IMEM from File
write_imem_from_file_tl_ul(.log_filehandle(f), .imem_file_path({mem_path, "imem_bnshv_test.txt"}), .clk(clk_i), .clk_cycles(cc), .start_address(0), .tl_o(tl_o), .tl_i(tl_i_d) );

$fwrite(f,"-- IMEM\n");
// Read IMEM
for (int i=0 ; i<16 ; i++) begin
    read_tl_ul(.log_filehandle(f), .data(rdbk), .clk(clk_i), .clk_cycles(cc), .address(OTBN_IMEM_OFFSET+4*i), .tl_o(tl_o), .tl_i(tl_i_d) );
end

 // Write DMEM from File
write_dmem_from_file_tl_ul(.log_filehandle(f), .dmem_file_path({mem_path, "dmem_bnshv_test.txt"}), .clk(clk_i), .clk_cycles(cc), .start_address(0), .tl_o(tl_o), .tl_i(tl_i_d) );

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
for (int i=0 ; i<8 ; i++) begin
    read_tl_ul(.log_filehandle(f), .data(rdbk), .clk(clk_i), .clk_cycles(cc), .address(OTBN_DMEM_OFFSET+4*i+512), .tl_o(tl_o), .tl_i(tl_i_d) );

    case(i)
      0   :   assert (rdbk == 32'h10) else begin $fwrite(f,"Wrong Result! Act: %d\n", rdbk); error_count ++; end
      1   :   assert (rdbk == 32'h10) else begin $fwrite(f,"Wrong Result! Act: %d\n", rdbk); error_count ++; end
      2   :   assert (rdbk == 32'h10) else begin $fwrite(f,"Wrong Result! Act: %d\n", rdbk); error_count ++; end
      3   :   assert (rdbk == 32'h10) else begin $fwrite(f,"Wrong Result! Act: %d\n", rdbk); error_count ++; end
      4   :   assert (rdbk == 32'h10) else begin $fwrite(f,"Wrong Result! Act: %d\n", rdbk); error_count ++; end
      5   :   assert (rdbk == 32'h10) else begin $fwrite(f,"Wrong Result! Act: %d\n", rdbk); error_count ++; end
      6   :   assert (rdbk == 32'h10) else begin $fwrite(f,"Wrong Result! Act: %d\n", rdbk); error_count ++; end
      7   :   assert (rdbk == 32'h10) else begin $fwrite(f,"Wrong Result! Act: %d\n", rdbk); error_count ++; end
    endcase

end

