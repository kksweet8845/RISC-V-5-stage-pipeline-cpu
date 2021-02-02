module HazardCtrl(
    input clk,
    input rst,
    input [1:0] branchCtrl,
    input EX_MemRead,
    input ID_MemWrite,
    input [4:0] EX_rd_addr,
    input [4:0] ID_rs1_addr,
    input [4:0] ID_rs2_addr,
    input [6:0] nop_signals,
    output reg PCWrite,
    output reg IM_flush,
    output reg IF_ID_reg_RegWrite,
    output reg ID_EX_reg_flush
);

reg stalling;

// initial begin
//     // PCWrite = 1'b1;
//     stalling = 1'b0;
//     IM_flush = 1'b0;
//     IF_ID_reg_RegWrite = 1'b1;
//     ID_EX_reg_flush = 1'b0;
// end

always @(*) begin
    if(rst) begin
        stalling = 1'b0;
        IM_flush = 1'b0;
        IF_ID_reg_RegWrite = 1'b1;
        ID_EX_reg_flush = 1'b0;
    end else begin
        // load-use-data : one stall, IF/ID == 1
        if( ((EX_MemRead)
        & (!ID_MemWrite)
        & (( ID_rs1_addr == EX_rd_addr ) | ( ID_rs2_addr == EX_rd_addr))) ) begin
            IF_ID_reg_RegWrite = 1'b0;
            ID_EX_reg_flush = 1'b1;
            PCWrite = 1'b0;
        end else begin
            ID_EX_reg_flush = 1'b0;
            IF_ID_reg_RegWrite = 1'b1;
            PCWrite = 1'b1;
        end
        // jump : flush IF/ID & ID/EXE register
        //  branch : flush flush IF/ID & ID/EXE register
        if( ((branchCtrl == 2'b01) | (branchCtrl == 2'b10))
        & (nop_signals != 7'b0) ) begin
            // IM_flush = 1'b1;
            ID_EX_reg_flush = 1'b1;
        end
    end
end



// always @(posedge clk) begin
//     if (stalling) begin
//         stalling = 1'b0;
//         PCWrite = 1'b1;
//         IF_ID_reg_RegWrite = 1'b1;
//         //ID_EX_reg_flush = 1'b0;
//     end
// end

endmodule