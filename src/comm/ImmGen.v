module ImmGen(
    input [6:0] opcode,
    input [6:0] funct7,
    input [4:0] rs2_addr,
    input [4:0] rs1_addr,
    input [2:0] funct3,
    input [4:0] rd_addr,
    input ImmType,
    output reg [31:0] Imm_src
);

always @(*) begin

    if(ImmType == 1) begin
        if (opcode == 7'b0000011 || opcode == 7'b0010011) begin // lw or i-type
            if (funct3 == 3'b001 || funct3 == 3'b101) begin
                Imm_src = { 27'b0, rs2_addr };
            end else begin
                Imm_src = { {20{funct7[6]}}, funct7, rs2_addr };
            end
        end else if (opcode == 7'b0100011) begin // sw
            Imm_src = {  {20{funct7[6]}}, funct7, rd_addr};
        end else if (opcode == 7'b1100011) begin // Branch
            Imm_src = { 19'b0, funct7[6], rd_addr[0], funct7[5:0], rd_addr[4:1], 1'b0 };
        end else if (opcode == 7'b0010111 || opcode == 7'b0110111) begin
            Imm_src = { funct7, rs2_addr, rs1_addr, funct3, 12'b0};
        end else if (opcode == 7'b1101111) begin // jal
            Imm_src = { 11'b0, funct7[6], rs1_addr, funct3, rs2_addr[0], funct7[5:0], rs2_addr[4:1], 1'b0};
        end else if (opcode == 7'b1100111) begin  // jalr
            Imm_src = {  {20{funct7[6]}}, funct7, rs2_addr };
        end
    end

end

endmodule