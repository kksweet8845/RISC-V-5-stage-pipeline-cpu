module ALU(
    input [31:0] rs1_data,
    input [31:0] rs2_or_imm_data,
    input [4:0] rd_addr,
    input [4:0] ALUCtrl,
    output reg [31:0] result,
    output reg zero_flag
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

always @(rs1_data or rs2_or_imm_data or ALUCtrl or rd_addr) begin
    case(ALUCtrl)
    add_op  :     begin zero_flag = 0; result = rs1_data + rs2_or_imm_data; end
    sub_op  :     begin zero_flag = 0; result = rs1_data - rs2_or_imm_data; end
    sl_op   :     begin zero_flag = 0; result = rs1_data << rs2_or_imm_data[4:0]; end
    sr_op   :     begin zero_flag = 0; result = $signed(rs1_data) >>> rs2_or_imm_data[4:0]; end
    sru_op  :     begin zero_flag = 0; result = rs1_data >> rs2_or_imm_data[4:0]; end
    xor_op  :     begin zero_flag = 0; result = rs1_data ^ rs2_or_imm_data; end
    or_op   :     begin zero_flag = 0; result = rs1_data | rs2_or_imm_data; end
    and_op  :     begin zero_flag = 0; result = rs1_data & rs2_or_imm_data; end
    slt_op  :     begin zero_flag = 0; result = $signed(rs1_data) < $signed(rs2_or_imm_data) ? 1 : 0; end
    sltu_op :     begin zero_flag = 0; result = rs1_data < rs2_or_imm_data ? 1:0; end
    beq_op  :     zero_flag = rs1_data == rs2_or_imm_data ? 1 : 0;
    bne_op  :     zero_flag = rs1_data != rs2_or_imm_data ? 1 : 0;
    blt_op  :     zero_flag = $signed(rs1_data) < $signed(rs2_or_imm_data) ? 1 : 0;
    bgt_op  :     zero_flag = $signed(rs1_data) >= $signed(rs2_or_imm_data) ? 1 : 0;
    bltu_op :     zero_flag = rs1_data < rs2_or_imm_data ? 1 : 0;
    bgtu_op :     zero_flag = rs1_data >= rs2_or_imm_data ? 1 : 0;
    no_op   :     begin zero_flag = 0; result = rs2_or_imm_data; end
    default :     zero_flag = 0;
    endcase
end

endmodule