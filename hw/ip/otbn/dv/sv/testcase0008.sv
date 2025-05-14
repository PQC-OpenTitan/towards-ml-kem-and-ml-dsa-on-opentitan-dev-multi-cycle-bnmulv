// Copyright "Towards ML-KEM & ML-DSA on OpenTitan" Authors
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

$fwrite(f,"----------------------------------------------------------------\n");   
$fwrite(f,"-- Testcase 8 - BNTRN\n");
$fwrite(f,"----------------------------------------------------------------\n");

// Write IMEM from File
write_imem_from_file_tl_ul(.log_filehandle(f), .imem_file_path({mem_path, "imem_bntrn_test.txt"}), .clk(clk_i), .clk_cycles(cc), .start_address(0), .tl_o(tl_o), .tl_i(tl_i_d) );

$fwrite(f,"-- IMEM\n");
// Read IMEM  
for (int i=0 ; i<16 ; i++) begin 
    read_tl_ul(.log_filehandle(f), .data(rdbk), .clk(clk_i), .clk_cycles(cc), .address(OTBN_IMEM_OFFSET+4*i), .tl_o(tl_o), .tl_i(tl_i_d) );
end     

 // Write DMEM from File
write_dmem_from_file_tl_ul(.log_filehandle(f), .dmem_file_path({mem_path, "dmem_bntrn_test.txt"}), .clk(clk_i), .clk_cycles(cc), .start_address(0), .tl_o(tl_o), .tl_i(tl_i_d) );



// Generate Random Testvectors

// Operand 1
for (int i=0 ; i<16 ; i++) begin 
    wdr_word[i*16+:16] = i;
end
for (int i=0 ; i<8 ; i++) begin 
    write_tl_ul(.log_filehandle(f), .clk(clk_i), .clk_cycles(cc), .data(wdr_word[i*32+:32]), .address(OTBN_DMEM_OFFSET+4*i), .tl_o(tl_o), .tl_i(tl_i_d) );
end
wdr_op0[0] = wdr_word;

// Operand 2
for (int i=0 ; i<16 ; i++) begin 
    wdr_word[i*16+:16] = i;
end
for (int i=0 ; i<8 ; i++) begin 
    write_tl_ul(.log_filehandle(f), .clk(clk_i), .clk_cycles(cc), .data(wdr_word[i*32+:32]), .address(OTBN_DMEM_OFFSET+4*i+32), .tl_o(tl_o), .tl_i(tl_i_d) );
end
wdr_op1[0] = wdr_word;

// Operand 3
for (int i=0 ; i<8 ; i++) begin 
    wdr_word[i*32+:32] = i;
end
for (int i=0 ; i<8 ; i++) begin 
    write_tl_ul(.log_filehandle(f), .clk(clk_i), .clk_cycles(cc), .data(wdr_word[i*32+:32]), .address(OTBN_DMEM_OFFSET+4*i+64), .tl_o(tl_o), .tl_i(tl_i_d) );
end
wdr_op0[1] = wdr_word;

// Operand 4
for (int i=0 ; i<8 ; i++) begin 
    wdr_word[i*32+:32] = i;
end
for (int i=0 ; i<8 ; i++) begin 
    write_tl_ul(.log_filehandle(f), .clk(clk_i), .clk_cycles(cc), .data(wdr_word[i*32+:32]), .address(OTBN_DMEM_OFFSET+4*i+96), .tl_o(tl_o), .tl_i(tl_i_d) );
end
wdr_op1[1] = wdr_word;

// Operand 5
for (int i=0 ; i<4 ; i++) begin 
    wdr_word[i*64+:64] = i;
end
for (int i=0 ; i<8 ; i++) begin 
    write_tl_ul(.log_filehandle(f), .clk(clk_i), .clk_cycles(cc), .data(wdr_word[i*32+:32]), .address(OTBN_DMEM_OFFSET+4*i+128), .tl_o(tl_o), .tl_i(tl_i_d) );
end
wdr_op0[2] = wdr_word;

// Operand 6
for (int i=0 ; i<4 ; i++) begin 
    wdr_word[i*64+:64] = i;
end
for (int i=0 ; i<8 ; i++) begin 
    write_tl_ul(.log_filehandle(f), .clk(clk_i), .clk_cycles(cc), .data(wdr_word[i*32+:32]), .address(OTBN_DMEM_OFFSET+4*i+160), .tl_o(tl_o), .tl_i(tl_i_d) );
end
wdr_op1[2] = wdr_word;


// Operand 7
for (int i=0 ; i<2 ; i++) begin 
    wdr_word[i*128+:128] = i;
end
for (int i=0 ; i<8 ; i++) begin 
    write_tl_ul(.log_filehandle(f), .clk(clk_i), .clk_cycles(cc), .data(wdr_word[i*32+:32]), .address(OTBN_DMEM_OFFSET+4*i+192), .tl_o(tl_o), .tl_i(tl_i_d) );
end
wdr_op0[3] = wdr_word;


// Operand 8
for (int i=0 ; i<2 ; i++) begin 
    wdr_word[i*128+:128] = i;
end
for (int i=0 ; i<8 ; i++) begin 
    write_tl_ul(.log_filehandle(f), .clk(clk_i), .clk_cycles(cc), .data(wdr_word[i*32+:32]), .address(OTBN_DMEM_OFFSET+4*i+224), .tl_o(tl_o), .tl_i(tl_i_d) );
end
wdr_op1[3] = wdr_word;

// Compute Expected Results for Dilithium
for (int i=0 ; i<8 ; i++) begin 
    wdr_res[1][i*32+:32] = {wdr_op1[0][2*i*16+:16],wdr_op0[0][2*i*16+:16]};
    wdr_res[0][i*32+:32] = {wdr_op1[0][(2*i+1)*16+:16],wdr_op0[0][(2*i+1)*16+:16]};
end
for (int i=0 ; i<4 ; i++) begin 
    wdr_res[3][i*64+:64] = {wdr_op1[1][2*i*32+:32],wdr_op0[1][2*i*32+:32]};
    wdr_res[2][i*64+:64] = {wdr_op1[1][(2*i+1)*32+:32],wdr_op0[1][(2*i+1)*32+:32]};
end
for (int i=0 ; i<2 ; i++) begin 
    wdr_res[5][i*128+:128] = {wdr_op1[2][2*i*64+:64],wdr_op0[2][2*i*64+:64]};
    wdr_res[4][i*128+:128] = {wdr_op1[2][(2*i+1)*64+:64],wdr_op0[2][(2*i+1)*64+:64]};
end
for (int i=0 ; i<1 ; i++) begin 
    wdr_res[7][i*256+:256] = {wdr_op1[3][2*i*128+:128],wdr_op0[3][2*i*128+:128]};
    wdr_res[6][i*256+:256] = {wdr_op1[3][(2*i+1)*128+:128],wdr_op0[3][(2*i+1)*128+:128]};
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
for (int j=0; j<8; ++j) begin  

    for (int i=0 ; i<8 ; i++) begin 

        read_tl_ul(.log_filehandle(f), .data(rdbk), .clk(clk_i), .clk_cycles(cc), .address(OTBN_DMEM_OFFSET+4*i+512+32*j), .tl_o(tl_o), .tl_i(tl_i_d) );
        assert (rdbk == wdr_res[j][i*32+:32]) else begin $fwrite(f,"Wrong Result! Act: %h | Exp: %h \n", rdbk, wdr_res[j][i*32+:32]); error_count ++; end

    end

end