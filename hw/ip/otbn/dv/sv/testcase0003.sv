// Copyright "Towards ML-KEM & ML-DSA on OpenTitan" Authors
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

$fwrite(f,"----------------------------------------------------------------\n");   
$fwrite(f,"-- Testcase 3 - BNADDVM\n");
$fwrite(f,"----------------------------------------------------------------\n");

// Write IMEM from File
write_imem_from_file_tl_ul(.log_filehandle(f), .imem_file_path({mem_path, "imem_bnaddvm_test.txt"}), .clk(clk_i), .clk_cycles(cc), .start_address(0), .tl_o(tl_o), .tl_i(tl_i_d) );

$fwrite(f,"-- IMEM\n");
// Read IMEM  
for (int i=0 ; i<16 ; i++) begin 
    read_tl_ul(.log_filehandle(f), .data(rdbk), .clk(clk_i), .clk_cycles(cc), .address(OTBN_IMEM_OFFSET+4*i), .tl_o(tl_o), .tl_i(tl_i_d) );
end     

 // Write DMEM from File
write_dmem_from_file_tl_ul(.log_filehandle(f), .dmem_file_path({mem_path, "dmem_bnaddvm_test.txt"}), .clk(clk_i), .clk_cycles(cc), .start_address(0), .tl_o(tl_o), .tl_i(tl_i_d) );


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
for (int i=0 ; i<64 ; i++) begin 
    read_tl_ul(.log_filehandle(f), .data(rdbk), .clk(clk_i), .clk_cycles(cc), .address(OTBN_DMEM_OFFSET+4*i+512), .tl_o(tl_o), .tl_i(tl_i_d) );
    
    case(i)
      0   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result! Act: %d\n", rdbk); error_count ++; end
      1   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result! Act: %d\n", rdbk); error_count ++; end
      2   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result! Act: %d\n", rdbk); error_count ++; end
      3   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result! Act: %d\n", rdbk); error_count ++; end
      4   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result! Act: %d\n", rdbk); error_count ++; end
      5   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result! Act: %d\n", rdbk); error_count ++; end
      6   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result! Act: %d\n", rdbk); error_count ++; end
      7   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result! Act: %d\n", rdbk); error_count ++; end

      8   :   assert (rdbk == 32'h2) else begin $fwrite(f,"Wrong Result! Act: %d\n", rdbk); error_count ++; end
      9   :   assert (rdbk == 32'h4) else begin $fwrite(f,"Wrong Result! Act: %d\n", rdbk); error_count ++; end
      10  :   assert (rdbk == 32'h6) else begin $fwrite(f,"Wrong Result! Act: %d\n", rdbk); error_count ++; end
      11  :   assert (rdbk == 32'h8) else begin $fwrite(f,"Wrong Result! Act: %d\n", rdbk); error_count ++; end
      12  :   assert (rdbk == 32'd10) else begin $fwrite(f,"Wrong Result! Act: %d\n", rdbk); error_count ++; end
      13  :   assert (rdbk == 32'd12) else begin $fwrite(f,"Wrong Result! Act: %d\n", rdbk); error_count ++; end
      14  :   assert (rdbk == 32'd14) else begin $fwrite(f,"Wrong Result! Act: %d\n", rdbk); error_count ++; end
      15  :   assert (rdbk == 32'd16) else begin $fwrite(f,"Wrong Result! Act: %d\n", rdbk); error_count ++; end

      16   :  assert (rdbk == 32'h007FDFFF) else begin $fwrite(f,"Wrong Result! Act: %d\n", rdbk); error_count ++; end
      17   :  assert (rdbk == 32'h007FDFFE) else begin $fwrite(f,"Wrong Result! Act: %d\n", rdbk); error_count ++; end
      18  :   assert (rdbk == 32'h007FDFFD) else begin $fwrite(f,"Wrong Result! Act: %d\n", rdbk); error_count ++; end
      19  :   assert (rdbk == 32'h007FDFFC) else begin $fwrite(f,"Wrong Result! Act: %d\n", rdbk); error_count ++; end
      20  :   assert (rdbk == 32'h007FDFFB) else begin $fwrite(f,"Wrong Result! Act: %d\n", rdbk); error_count ++; end
      21  :   assert (rdbk == 32'h007FDFFA) else begin $fwrite(f,"Wrong Result! Act: %d\n", rdbk); error_count ++; end
      22  :   assert (rdbk == 32'h007FDFF9) else begin $fwrite(f,"Wrong Result! Act: %d\n", rdbk); error_count ++; end
      23  :   assert (rdbk == 32'h007FDFF8) else begin $fwrite(f,"Wrong Result! Act: %d\n", rdbk); error_count ++; end

      24   :  assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result! Act: %d\n", rdbk); error_count ++; end
      25   :  assert (rdbk == 32'h1) else begin $fwrite(f,"Wrong Result! Act: %d\n", rdbk); error_count ++; end
      26  :   assert (rdbk == 32'h2) else begin $fwrite(f,"Wrong Result! Act: %d\n", rdbk); error_count ++; end
      27  :   assert (rdbk == 32'h3) else begin $fwrite(f,"Wrong Result! Act: %d\n", rdbk); error_count ++; end
      28  :   assert (rdbk == 32'd4) else begin $fwrite(f,"Wrong Result! Act: %d\n", rdbk); error_count ++; end
      29  :   assert (rdbk == 32'd5) else begin $fwrite(f,"Wrong Result! Act: %d\n", rdbk); error_count ++; end
      30  :   assert (rdbk == 32'd6) else begin $fwrite(f,"Wrong Result! Act: %d\n", rdbk); error_count ++; end
      31  :   assert (rdbk == 32'd7) else begin $fwrite(f,"Wrong Result! Act: %d\n", rdbk); error_count ++; end

      32  :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result! Act: %d\n", rdbk); error_count ++; end
      33  :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result! Act: %d\n", rdbk); error_count ++; end
      34  :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result! Act: %d\n", rdbk); error_count ++; end
      35  :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result! Act: %d\n", rdbk); error_count ++; end
      36  :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result! Act: %d\n", rdbk); error_count ++; end
      37  :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result! Act: %d\n", rdbk); error_count ++; end
      38  :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result! Act: %d\n", rdbk); error_count ++; end
      39  :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result! Act: %d\n", rdbk); error_count ++; end

      40  :   assert (rdbk == 32'h00040002) else begin $fwrite(f,"Wrong Result! Act: %d\n", rdbk); error_count ++; end
      41  :   assert (rdbk == 32'h00080006) else begin $fwrite(f,"Wrong Result! Act: %d\n", rdbk); error_count ++; end
      42  :   assert (rdbk == 32'h000c000a) else begin $fwrite(f,"Wrong Result! Act: %d\n", rdbk); error_count ++; end
      43  :   assert (rdbk == 32'h0010000e) else begin $fwrite(f,"Wrong Result! Act: %d\n", rdbk); error_count ++; end
      44  :   assert (rdbk == 32'h00140012) else begin $fwrite(f,"Wrong Result! Act: %d\n", rdbk); error_count ++; end
      45  :   assert (rdbk == 32'h00180016) else begin $fwrite(f,"Wrong Result! Act: %d\n", rdbk); error_count ++; end
      46  :   assert (rdbk == 32'h001c001a) else begin $fwrite(f,"Wrong Result! Act: %d\n", rdbk); error_count ++; end
      47  :   assert (rdbk == 32'h0020001e) else begin $fwrite(f,"Wrong Result! Act: %d\n", rdbk); error_count ++; end

      48   :  assert (rdbk == 32'h0CFE0CFF) else begin $fwrite(f,"Wrong Result! Act: %d\n", rdbk); error_count ++; end
      49   :  assert (rdbk == 32'h0CFC0CFD) else begin $fwrite(f,"Wrong Result! Act: %d\n", rdbk); error_count ++; end
      50  :   assert (rdbk == 32'h0CFA0CFB) else begin $fwrite(f,"Wrong Result! Act: %d\n", rdbk); error_count ++; end
      51  :   assert (rdbk == 32'h0CF80CF9) else begin $fwrite(f,"Wrong Result! Act: %d\n", rdbk); error_count ++; end
      52  :   assert (rdbk == 32'h0CF60CF7) else begin $fwrite(f,"Wrong Result! Act: %d\n", rdbk); error_count ++; end
      53  :   assert (rdbk == 32'h0CF40CF5) else begin $fwrite(f,"Wrong Result! Act: %d\n", rdbk); error_count ++; end
      54  :   assert (rdbk == 32'h0CF20CF3) else begin $fwrite(f,"Wrong Result! Act: %d\n", rdbk); error_count ++; end
      55  :   assert (rdbk == 32'h0CF00CF1) else begin $fwrite(f,"Wrong Result! Act: %d\n", rdbk); error_count ++; end

      56   :  assert (rdbk == 32'h00010000) else begin $fwrite(f,"Wrong Result! Act: %d\n", rdbk); error_count ++; end
      57   :  assert (rdbk == 32'h00030002) else begin $fwrite(f,"Wrong Result! Act: %d\n", rdbk); error_count ++; end
      58  :   assert (rdbk == 32'h00050004) else begin $fwrite(f,"Wrong Result! Act: %d\n", rdbk); error_count ++; end
      59  :   assert (rdbk == 32'h00070006) else begin $fwrite(f,"Wrong Result! Act: %d\n", rdbk); error_count ++; end
      60  :   assert (rdbk == 32'h00090008) else begin $fwrite(f,"Wrong Result! Act: %d\n", rdbk); error_count ++; end
      61  :   assert (rdbk == 32'h000b000a) else begin $fwrite(f,"Wrong Result! Act: %d\n", rdbk); error_count ++; end
      62  :   assert (rdbk == 32'h000d000c) else begin $fwrite(f,"Wrong Result! Act: %d\n", rdbk); error_count ++; end
      63  :   assert (rdbk == 32'h000f000e) else begin $fwrite(f,"Wrong Result! Act: %d\n", rdbk); error_count ++; end

    endcase    

end