// Please include verilog file if you write module in other file

`include "comm/ALU.v"
`include "comm/ALUCtrl.v"
`include "comm/BranchCtrl.v"
`include "comm/DataMem.v"
`include "comm/Decoder.v"
`include "comm/Distributor.v"
`include "comm/ForwardCtrl.v"
`include "comm/HazardCtrl.v"
`include "comm/ImmGen.v"
`include "comm/ProgramCounter.v"
`include "comm/PipeReg.v"
`include "comm/RegisterFile.v"

module CPU(
    input         clk,
    input         rst,
    output reg        instr_read,
    output reg [31:0] instr_addr,
    input  [31:0] instr_out,
    output        data_read,
    output        data_write,
    output [31:0] data_addr,
    output [31:0] data_in,
    input  [31:0] data_out
);

parameter [4:0] add_op = 5'b0,
                sub_op = 5'b00001,
                sl_op  = 5'b00010,
                sr_op  = 5'b00011,
                sru_op = 5'b00100,
                xor_op = 5'b00101,
                or_op  = 5'b00110,
                and_op = 5'b00111,
                slt_op = 5'b01000,
                sltu_op= 5'b01001,
                beq_op = 5'b01010,
                bne_op = 5'b01011,
                blt_op = 5'b01100,
                bgt_op = 5'b01101,
                bltu_op= 5'b01110,
                bgtu_op= 5'b01111,
                no_op  = 5'b10000;

wire [6:0] opcode;

wire PCWrite,
     IM_flush,
     IF_ID_reg_RegWrite,
     ID_EX_reg_flush;

// ID Ctrl signals
wire ID_RegWrite, ID_RegWrite_af_mux,
     ID_ImmType,
     ID_PCToRegSrc, ID_PCToRegSrc_af_mux,
     ID_RDSrc, ID_RDSrc_af_mux,
     ID_MemRead, ID_MemRead_af_mux,
     ID_MemWrite, ID_MemWrite_af_mux,
     ID_MemToReg, ID_MemToReg_af_mux,
     ID_ALUSrc, ID_ALUSrc_af_mux;
wire [2:0] ID_ALUOp;

// EX Ctrl signals
wire EX_RegWrite,
     EX_ImmType,
     EX_PCToRegSrc,
     EX_RDSrc,
     EX_MemRead,
     EX_MemWrite,
     EX_MemToReg,
     EX_ALUSrc;
wire [2:0] EX_ALUOp;
wire [4:0] EX_ALUCtrl;

// MEM Ctrl signals
wire MEM_MemToReg,
     MEM_RegWrite,
     MEM_RDSrc,
     MEM_MemRead,
     MEM_MemWrite;

// WB Ctrl signals
wire WB_MemToReg,
     WB_RegWrite;

// IF reg wire
// input
wire [31:0] IF_instr_out_in;

// ID reg wire
// input
wire [31:0] ID_pc,
            ID_Rs1Data,
            ID_Rs2Data,
            ID_Imm_src,
            ID_instr_in_out;
wire [2:0] ID_funct3;
wire [6:0] ID_funct7;
wire [4:0] ID_rd_addr,
           ID_rs1_addr,
           ID_rs2_addr;

// EX reg wire
wire [31:0] EX_rs1_data,
            EX_rs2_data,
            EX_Imm_src,
            EX_pc,
            EX_pc_imm,
            EX_pc_const,
            EX_pc_to_reg,
            EX_forward_rs1_data,
            EX_forward_rs2_data,
            EX_rs2_data_imm,
            EX_alu_out;
wire EX_zero_flag;
wire [2:0] EX_funct3;
wire [6:0] EX_funct7,
           EX_opcode;
wire [4:0] EX_rd_addr,
           EX_rs1_addr,
           EX_rs2_addr;

// Mem reg wire
wire [31:0] MEM_pc_to_reg,
            MEM_alu_out,
            MEM_forward_rs2_data,
            MEM_Din,
            MEM_rd_data,
            MEM_Dout;
wire [4:0] MEM_rd_addr,
           MEM_rs2_addr;

// WB reg wire
wire [31:0] WB_rd_data,
            WB_Dout,
            WB_Dout_or_rd_data;
wire [4:0] WB_rd_addr;

// Forward unit
wire [1:0] ForwardRs1Src,
           ForwardRs2Src;
wire ForwardRDSrc;


wire [1:0] branchCtrl;
wire [31:0] pc_normal_out,
            pc_in;
wire [31:0] pc_out;

// initial begin
//     instr_read = 1'b0;
//     instr_addr = 32'b0;
// end


// always @(posedge clk) begin
//     if(rst == 1) begin
//         instr_read = 1'b0;
//     end
// end

// always @(*) begin
//     instr_addr = pc_out;
// end

assign instr_addr = pc_out;


// ProgramCounter
ProgramCounter i_ProgramCounter(
    // input
    .rst            (rst                ),
    .pc_in          (pc_in              ),
    .PCWrite        (PCWrite            ),
    // output
    .pc_out         (pc_out             )
);

// normal_adder
adder normal_adder(
    // input
    .src            (pc_out             ),
    .imm            ({29'b0, 3'b100}    ),
    // output
    .result         (pc_normal_out      )
);

// mux for instr_out or flush it
mux_binary instr_out_mux(
    // input
    .zero_path              (instr_out          ),
    .one_path               ({32'b0}            ),
    .sel                    (IM_flush           ),
    // output
    .result                 (IF_instr_out_in    )
);

// Hazard Ctrl
HazardCtrl i_HazardCtrl(
    // input
    .clk                    (clk                ),
    .rst                    (rst                ),
    .branchCtrl             (branchCtrl         ),
    .EX_MemRead             (EX_MemRead         ),
    .ID_MemWrite            (ID_MemWrite        ),
    .EX_rd_addr             (EX_rd_addr         ),
    .ID_rs1_addr            (ID_rs1_addr        ),
    .ID_rs2_addr            (ID_rs2_addr        ),
    .nop_signals            ({EX_PCToRegSrc,
                              EX_ALUSrc,
                              EX_RegWrite,
                              EX_RDSrc,
                              EX_MemRead,
                              EX_MemWrite,
                              EX_MemToReg}      ),
    // output
    .PCWrite                (PCWrite            ),
    .IM_flush               (IM_flush           ),
    .IF_ID_reg_RegWrite     (IF_ID_reg_RegWrite ),
    .ID_EX_reg_flush        (ID_EX_reg_flush    )
);

// IF/ID reg
IF_ID_reg   i_IF_ID_reg(
    // input
    .clk                    (clk                ),
    .rst                    (rst                ),
    .IF_ID_reg_RegWrite     (IF_ID_reg_RegWrite ),
    .pc_out_in              (pc_out             ),
    .instr_out_in           (IF_instr_out_in    ),
    // output
    .pc_in_out              (ID_pc              ),
    .instr_in_out           (ID_instr_in_out    )
);

// Distributor
Distributor i_Distributor(
    // input
    .instr_out              (ID_instr_in_out    ),
    // output
    .opcode                 (opcode             ),
    .rs1_addr               (ID_rs1_addr        ),
    .rs2_addr               (ID_rs2_addr        ),
    .rd_addr                (ID_rd_addr         ),
    .funct7                 (ID_funct7          ),
    .funct3                 (ID_funct3          )
);

// RegisterFile
RegisterFile i_RegisterFile(
    // input
    .clk                    (clk                ),
    .rst                    (rst                ),
    .rs1_addr               (ID_rs1_addr        ),
    .rs2_addr               (ID_rs2_addr        ),
    .rd_addr                (WB_rd_addr         ),
    .pc_out                 (ID_pc              ),
    .RegWrite               (WB_RegWrite        ),
    .Din                    (WB_Dout_or_rd_data ),
    // output
    .Rs1Data                (ID_Rs1Data         ),
    .Rs2Data                (ID_Rs2Data         )
);


// Decoder
Decoder i_Decoder(
    // input
    .opcode                 (opcode             ),
    // output
    .RegWrite               (ID_RegWrite        ),
    .ImmType                (ID_ImmType         ),
    .PCToRegSrc             (ID_PCToRegSrc      ),
    .RDSrc                  (ID_RDSrc           ),
    .MemRead                (ID_MemRead         ),
    .MemWrite               (ID_MemWrite        ),
    .MemToReg               (ID_MemToReg        ),
    .ALUSrc                 (ID_ALUSrc          ),
    .ALUOp                  (ID_ALUOp           )
);

mux_binary_1 ID_RegWrite_mux(
    .zero_path              (ID_RegWrite        ),
    .one_path               (1'b0               ),
    .sel                    (ID_EX_reg_flush    ),
    .result                 (ID_RegWrite_af_mux )
);
mux_binary_1 ID_PCToRegSrc_mux(
    .zero_path              (ID_PCToRegSrc          ),
    .one_path               (1'b0                   ),
    .sel                    (ID_EX_reg_flush        ),
    .result                 (ID_PCToRegSrc_af_mux   )
);
mux_binary_1 ID_ALUSrc_mux(
    .zero_path              (ID_ALUSrc          ),
    .one_path               (1'b0               ),
    .sel                    (ID_EX_reg_flush    ),
    .result                 (ID_ALUSrc_af_mux   )
);
mux_binary_1 ID_RDSrc_mux(
    .zero_path              (ID_RDSrc           ),
    .one_path               (1'b0               ),
    .sel                    (ID_EX_reg_flush    ),
    .result                 (ID_RDSrc_af_mux    )
);
mux_binary_1 ID_MemRead_mux(
    .zero_path              (ID_MemRead         ),
    .one_path               (1'b0               ),
    .sel                    (ID_EX_reg_flush    ),
    .result                 (ID_MemRead_af_mux  )
);
mux_binary_1 ID_MemWrite_mux(
    .zero_path              (ID_MemWrite        ),
    .one_path               (1'b0               ),
    .sel                    (ID_EX_reg_flush    ),
    .result                 (ID_MemWrite_af_mux )
);
mux_binary_1 ID_MemToReg_mux(
    .zero_path              (ID_MemToReg        ),
    .one_path               (1'b0               ),
    .sel                    (ID_EX_reg_flush    ),
    .result                 (ID_MemToReg_af_mux )
);

// ImmGen
ImmGen  i_ImmGen(
    // input
    .opcode                 (opcode             ),
    .funct7                 (ID_funct7          ),
    .rs2_addr               (ID_rs2_addr        ),
    .rs1_addr               (ID_rs1_addr        ),
    .funct3                 (ID_funct3          ),
    .rd_addr                (ID_rd_addr         ),
    .ImmType                (ID_ImmType         ),
    // output
    .Imm_src                (ID_Imm_src         )
);

// ID_EX_reg
ID_EX_reg i_ID_EX_reg(
    // input
    .clk                    (clk                ),
    .rst                    (rst                ),
    // Mem/WB field input
    .MemToReg               (ID_MemToReg_af_mux        ),
    .RegWrite               (ID_RegWrite_af_mux        ),
    // Mem/WB field output
    .MemToReg_out           (EX_MemToReg        ),
    .RegWrite_out           (EX_RegWrite        ),
    // Ex/Mem field input
    .RDSrc                  (ID_RDSrc_af_mux           ),
    .MemRead                (ID_MemRead_af_mux         ),
    .MemWrite               (ID_MemWrite_af_mux        ),
    // Ex/Mem field output
    .RDSrc_out              (EX_RDSrc           ),
    .MemRead_out            (EX_MemRead         ),
    .MemWrite_out           (EX_MemWrite        ),
    // ID/EX field input
    .PCToRegSrc             (ID_PCToRegSrc_af_mux      ),
    .ALUSrc                 (ID_ALUSrc_af_mux          ),
    .ALUOp                  (ID_ALUOp           ),
    // ID/EX field output
    .PCToRegSrc_out         (EX_PCToRegSrc      ),
    .ALUSrc_out             (EX_ALUSrc          ),
    .ALUOp_out              (EX_ALUOp           ),
    // information field input
    .opcode                 (opcode             ),
    .ID_pc                  (ID_pc              ),
    .Rs1Data                (ID_Rs1Data         ),
    .Rs2Data                (ID_Rs2Data         ),
    .Imm_src                (ID_Imm_src         ),
    .funct3                 (ID_funct3          ),
    .funct7                 (ID_funct7          ),
    .rd_addr                (ID_rd_addr         ),
    .rs1_addr               (ID_rs1_addr        ),
    .rs2_addr               (ID_rs2_addr        ),
    // information field output
    .opcode_out             (EX_opcode          ),
    .ID_pc_out              (EX_pc              ),
    .Rs1Data_out            (EX_rs1_data        ),
    .Rs2Data_out            (EX_rs2_data        ),
    .Imm_src_out            (EX_Imm_src         ),
    .funct3_out             (EX_funct3          ),
    .funct7_out             (EX_funct7          ),
    .rd_addr_out            (EX_rd_addr         ),
    .rs1_addr_out           (EX_rs1_addr        ),
    .rs2_addr_out           (EX_rs2_addr        )
);

// forward unit
ForwardCtrl i_ForwardCtrl(
    // input
    .EX_rs1_addr            (EX_rs1_addr        ),
    .EX_rs2_addr            (EX_rs2_addr        ),
    .WB_RegWrite            (WB_RegWrite        ),
    .WB_rd_addr             (WB_rd_addr         ),
    .MEM_RegWrite           (MEM_RegWrite       ),
    .MEM_rd_addr            (MEM_rd_addr        ),
    .MEM_rs2_addr           (MEM_rs2_addr       ),
    .MEM_MemWrite           (MEM_MemWrite       ),
    // output
    .ForwardRs1Src          (ForwardRs1Src      ),
    .ForwardRs2Src          (ForwardRs2Src      ),
    .ForwardRDSrc           (ForwardRDSrc       )
);

// pc adder
adder EX_pc_imm_adder(
    // input
    .src                    (EX_pc              ),
    .imm                    (EX_Imm_src         ),
    // output
    .result                 (EX_pc_imm          )
);

adder EX_pc_const_adder(
    // input
    .src                    (EX_pc              ),
    .imm                    ({29'b0, 3'b100} ),
    // output
    .result                 (EX_pc_const        )
);

// pc_imm or pc_const mux

mux_binary pc_imm_or_pc_const_mux(
    // input
    .zero_path              (EX_pc_const        ),
    .one_path               (EX_pc_imm          ),
    .sel                    (EX_PCToRegSrc      ),
    // output
    .result                 (EX_pc_to_reg       )
);

// forward or rs1 mux
mux_triple forward_rs1_mux(
    // input
    .zero_path              (EX_rs1_data        ),
    .one_path               (MEM_rd_data        ),
    .two_path               (WB_Dout_or_rd_data ),
    .sel                    (ForwardRs1Src      ),
    // output
    .result                 (EX_forward_rs1_data)
);

mux_triple forward_rs2_mux(
    // input
    .zero_path              (EX_rs2_data        ),
    .one_path               (MEM_rd_data        ),
    .two_path               (WB_Dout_or_rd_data ),
    .sel                    (ForwardRs2Src      ),
    // output
    .result                 (EX_forward_rs2_data)
);

mux_binary rs2_or_imm_mux(
    // input
    .zero_path              (EX_Imm_src         ),
    .one_path               (EX_forward_rs2_data),
    .sel                    (EX_ALUSrc          ),
    // output
    .result                 (EX_rs2_data_imm    )
);

// ALU Ctrl
ALUCtrl i_ALUCtrl(
    // input
    .MemRead                (EX_MemRead         ),
    .funct3                 (EX_funct3          ),
    .funct7                 (EX_funct7          ),
    .ALUOp                  (EX_ALUOp           ),
    // output
    .ALUCtrl                (EX_ALUCtrl         )
);

// ALU
ALU i_ALU(
    // input
    .rs1_data               (EX_forward_rs1_data),
    .rs2_or_imm_data        (EX_rs2_data_imm    ),
    .rd_addr                (EX_rd_addr         ),
    .ALUCtrl                (EX_ALUCtrl         ),
    // output
    .result                 (EX_alu_out         ),
    .zero_flag              (EX_zero_flag       )
);

// Branch Ctrl
BranchCtrl i_BranchCtrl(
    // input
    .clk                    (clk                ),
    .rst                    (rst                ),
    .funct3                 (EX_funct3          ),
    .opcode                 (EX_opcode          ),
    .alu_out                (EX_alu_out         ),
    .zero_flag              (EX_zero_flag       ),
    .ALUOp                  (EX_ALUOp           ),
    // output
    .branchCtrl             (branchCtrl         )
);


// EX/MEM reg
EX_MEM_reg i_EX_MEM_reg(
    // input
    .clk                    (clk                    ),
    .rst                    (rst                    ),
    // MEM/WB field input
    .MemToReg               (EX_MemToReg            ),
    .RegWrite               (EX_RegWrite            ),
    // MEM/WB field output
    .MemToReg_out           (MEM_MemToReg           ),
    .RegWrite_out           (MEM_RegWrite           ),
    // EM/MEM field input
    .RDSrc                  (EX_RDSrc               ),
    .MemRead                (EX_MemRead             ),
    .MemWrite               (EX_MemWrite            ),
    // EM/MEM field output
    .RDSrc_out              (MEM_RDSrc              ),
    .MemRead_out            (MEM_MemRead            ),
    .MemWrite_out           (MEM_MemWrite           ),
    // information field
    .pc_to_reg              (EX_pc_to_reg           ),
    .alu_out_in             (EX_alu_out             ),
    .rs2_data               (EX_forward_rs2_data    ),
    .rd_addr                (EX_rd_addr             ),
    .rs2_addr               (EX_rs2_addr            ),
    // information field output
    .rs2_addr_out           (MEM_rs2_addr           ),
    .pc_to_reg_out          (MEM_pc_to_reg          ),
    .alu_in_out             (MEM_alu_out            ),
    .rs2_data_out           (MEM_forward_rs2_data   ),
    .rd_addr_out            (MEM_rd_addr            )
);

// MEM_pc_to_reg or MEM_alu_out mux
mux_binary MEM_pc_to_reg_or_alu_out_mux(
    // input
    .zero_path              (MEM_pc_to_reg          ),
    .one_path               (MEM_alu_out            ),
    .sel                    (MEM_RDSrc              ),
    // output
    .result                 (MEM_rd_data            )
);

// MEM_rs2_data or WB_rd_data
mux_binary MEM_rs2_data_or_WB_rd_data_mux(
    // input
    .zero_path              (MEM_forward_rs2_data   ),
    .one_path               (WB_Dout_or_rd_data     ),
    .sel                    (ForwardRDSrc           ),
    // output
    .result                 (MEM_Din                )
);

// Data Memory
DataMem i_DataMem(
    // input
    .clk                    (clk                    ),
    .MemRead                (MEM_MemRead            ),
    .MemWrite               (MEM_MemWrite           ),
    .alu_out_addr           (MEM_alu_out            ),
    .rs2_data               (MEM_Din                ),
    // output
    .data_addr              (data_addr              ),
    .data_in                (data_in                ),
    .data_read              (data_read              ),
    .data_write             (data_write             )
);

// MEM/WB reg
MEM_WB_reg  i_MEM_WB_reg(
    // input
    .clk                    (clk                    ),
    .rst                    (rst                    ),
    // WB field input
    .MemToReg               (MEM_MemToReg           ),
    .RegWrite               (MEM_RegWrite           ),
    // WB field output
    .MemToReg_out           (WB_MemToReg            ),
    .RegWrite_out           (WB_RegWrite            ),
    // information field
    .MEM_rd_data            (MEM_rd_data            ),
    .DM_out_in              (data_out               ),
    .MEM_rd_addr            (MEM_rd_addr            ),
    // output
    .MEM_rd_data_out        (WB_rd_data             ),
    .DM_in_out              (WB_Dout                ),
    .MEM_rd_addr_out        (WB_rd_addr             )
);

// WB_rd_data or WB_Dout
mux_binary WB_rd_data_or_WB_Dout_mux(
    // input
    .zero_path              (WB_rd_data             ),
    .one_path               (WB_Dout                ),
    .sel                    (WB_MemToReg            ),
    // output
    .result                 (WB_Dout_or_rd_data     )
);

mux_triple_neg_clk pc_triple_mux(
    // input
    .clk                    (clk                    ),
    .zero_path              (pc_normal_out          ),
    .one_path               (EX_pc_imm              ),
    .two_path               (EX_alu_out             ),
    .sel                    (branchCtrl             ),
    // output
    .result                 (pc_in                  )
);




endmodule

module mux_binary(
    input [31:0] zero_path,
    input [31:0] one_path,
    input sel,
    output reg [31:0] result
);

always @(sel or zero_path or one_path) begin

    case(sel)
    1'b0: result = zero_path;
    1'b1: result = one_path;
    endcase
end

endmodule

module mux_binary_1(
    input zero_path,
    input one_path,
    input sel,
    output reg result
);

always @(sel or zero_path or one_path) begin

    case(sel)
    1'b0: result = zero_path;
    1'b1: result = one_path;
    endcase
end

endmodule

module mux_triple_neg_clk(
    input clk,
    input [31:0] zero_path,
    input [31:0] one_path,
    input [31:0] two_path,
    input [1:0] sel,
    output reg [31:0] result
);

initial begin
    result = 32'b0;
end

always @(negedge clk ) begin
    case(sel)
    2'b00: result <= zero_path;
    2'b01: result <= one_path;
    2'b10: result <= two_path;
    endcase
end

endmodule

module mux_triple(
    input [31:0] zero_path,
    input [31:0] one_path,
    input [31:0] two_path,
    input [1:0] sel,
    output reg [31:0] result
);

always @(*) begin
    case(sel)
    2'b00: result = zero_path;
    2'b01: result = one_path;
    2'b10: result = two_path;
    endcase
end

endmodule


module adder(
    input [31:0] src,
    input [31:0] imm,
    output reg [31:0] result
);

always @(src or imm) begin
    result = src + imm;
end

endmodule