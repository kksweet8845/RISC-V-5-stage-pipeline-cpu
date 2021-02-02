module IF_ID_reg(
    input clk,
    input rst,
    input IF_ID_reg_RegWrite,
    input [31:0] pc_out_in,
    input [31:0] instr_out_in,
    output reg [31:0] pc_in_out,
    output reg [31:0] instr_in_out
);

always @(posedge clk) begin
    if(rst == 0) begin
        if(IF_ID_reg_RegWrite) begin
            pc_in_out <= pc_out_in;
            instr_in_out <= instr_out_in;
        end
    end
end

endmodule

module ID_EX_reg(
    input clk,
    input rst,
    // Mem/WB field input
    input MemToReg,
    input RegWrite,
    output reg MemToReg_out,
    output reg RegWrite_out,
    // Ex/Mem field input
    input RDSrc,
    input MemRead,
    input MemWrite,
    output reg RDSrc_out,
    output reg MemRead_out,
    output reg MemWrite_out,
    // ID/Ex field input
    input PCToRegSrc,
    input ALUSrc,
    input [2:0] ALUOp,
    output reg PCToRegSrc_out,
    output reg ALUSrc_out,
    output reg [2:0] ALUOp_out,
    // information field
    input [6:0] opcode,
    input [31:0] ID_pc,
    input [31:0] Rs1Data,
    input [31:0] Rs2Data,
    input [31:0] Imm_src,
    input [2:0] funct3,
    input [6:0] funct7,
    input [4:0] rd_addr,
    input [4:0] rs1_addr,
    input [4:0] rs2_addr,
    output reg [6:0] opcode_out,
    output reg [31:0] ID_pc_out,
    output reg [31:0] Rs1Data_out,
    output reg [31:0] Rs2Data_out,
    output reg [31:0] Imm_src_out,
    output reg [2:0] funct3_out,
    output reg [6:0] funct7_out,
    output reg [4:0] rd_addr_out,
    output reg [4:0] rs1_addr_out,
    output reg [4:0] rs2_addr_out
);

always @(posedge clk) begin
    if(rst == 0) begin
        // Mem/WB field
        MemToReg_out <= MemToReg;
        RegWrite_out <= RegWrite;
        // Ex/Mem field
        RDSrc_out <= RDSrc;
        MemRead_out <= MemRead;
        MemWrite_out <= MemWrite;
        // ID/Ex field
        PCToRegSrc_out <= PCToRegSrc;
        ALUSrc_out <= ALUSrc;
        ALUOp_out <= ALUOp;
        // information field
        ID_pc_out <= ID_pc;
        Rs1Data_out <= Rs1Data;
        Rs2Data_out <= Rs2Data;
        Imm_src_out <= Imm_src;
        funct3_out <= funct3;
        funct7_out <= funct7;
        rd_addr_out <= rd_addr;
        rs1_addr_out <= rs1_addr;
        rs2_addr_out <= rs2_addr;
        opcode_out <= opcode;
    end
end

endmodule

module EX_MEM_reg(
    input clk,
    input rst,
    // MEM/WB field
    input MemToReg,
    input RegWrite,
    output reg MemToReg_out,
    output reg RegWrite_out,
    // EX/MEM field
    input RDSrc,
    input MemRead,
    input MemWrite,
    output reg RDSrc_out,
    output reg MemRead_out,
    output reg MemWrite_out,
    // information field
    input [31:0] pc_to_reg,
    input [31:0] alu_out_in,
    input [31:0] rs2_data,
    input [4:0] rd_addr,
    input [4:0] rs2_addr,
    output reg [4:0] rs2_addr_out,
    output reg [31:0] pc_to_reg_out,
    output reg [31:0] alu_in_out,
    output reg [31:0] rs2_data_out,
    output reg [4:0] rd_addr_out
);

always @(posedge clk) begin
    if(rst == 0) begin
        // Mem/WB field
        MemToReg_out <= MemToReg;
        RegWrite_out <= RegWrite;
        // EX/MEM field
        RDSrc_out <= RDSrc;
        MemRead_out <= MemRead;
        MemWrite_out <= MemWrite;
        // information field
        pc_to_reg_out <= pc_to_reg;
        alu_in_out <= alu_out_in;
        rs2_data_out <= rs2_data;
        rs2_addr_out <= rs2_addr;
        rd_addr_out <= rd_addr;
    end
end

endmodule


module MEM_WB_reg(
    input clk,
    input rst,
    // WB field
    input MemToReg,
    input RegWrite,
    output reg MemToReg_out,
    output reg RegWrite_out,
    // information field
    input [31:0] MEM_rd_data,
    input [31:0] DM_out_in,
    input [4:0] MEM_rd_addr,
    output reg [31:0] MEM_rd_data_out,
    output reg [31:0] DM_in_out,
    output reg [4:0] MEM_rd_addr_out
);

always @(posedge clk) begin
    if(rst == 0) begin
        // WB field
        MemToReg_out <= MemToReg;
        RegWrite_out <= RegWrite;
        // information field
        MEM_rd_data_out <= MEM_rd_data;
        DM_in_out <= DM_out_in;
        MEM_rd_addr_out <= MEM_rd_addr;
    end
end

endmodule