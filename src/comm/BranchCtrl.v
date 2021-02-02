module BranchCtrl(
    input clk,
    input rst,
    input [2:0] funct3,
    input [6:0] opcode,
    input [31:0] alu_out,
    input zero_flag,
    input [2:0] ALUOp,
    output reg [1:0] branchCtrl
);


always @(negedge clk or funct3 or opcode or alu_out or zero_flag or ALUOp) begin
    if(rst == 0) begin
        if( {ALUOp, funct3} == 6'b001000 && opcode == 7'b1100111) begin
            branchCtrl = 2'b10;
        end else if(zero_flag == 1'b1 || opcode == 7'b1101111) begin
            branchCtrl = 2'b01;
        end else begin
            branchCtrl = 2'b0;
        end
    end
end

endmodule