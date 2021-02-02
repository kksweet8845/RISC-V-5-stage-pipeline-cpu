module Distributor(
    input [31:0] instr_out,
    output reg [6:0] opcode,
    output reg  [4:0] rs1_addr,
    output reg [4:0] rs2_addr,
    output reg [4:0] rd_addr,
    output reg [6:0] funct7,
    output reg [2:0] funct3
);


always @(instr_out) begin

    funct7 = instr_out[31:25];
    rs2_addr = instr_out[24:20];
    rs1_addr = instr_out[19:15];
    funct3 = instr_out[14:12];
    rd_addr = instr_out[11:7];
    opcode = instr_out[6:0];
end

endmodule