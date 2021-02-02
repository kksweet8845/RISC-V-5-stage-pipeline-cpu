module ALUCtrl(
    input MemRead,
    input [2:0] funct3,
    input [6:0] funct7,
    input [2:0] ALUOp,
    output reg [4:0] ALUCtrl
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


always@(*) begin

    case( { ALUOp, funct3} )
    6'b000000: begin // add or sub
        if(funct7[5] == 0) begin
            ALUCtrl = add_op; // add operation
        end else begin
            ALUCtrl = sub_op;// sub operation
        end
    end
    6'b000001: begin
        ALUCtrl = sl_op; // shift left
    end
    6'b000101: begin
         if(funct7[5] == 0) begin
            ALUCtrl = sru_op; // shift right unsigned operation
        end else begin
            ALUCtrl = sr_op; // shift right signed operation
        end
    end
    6'b000010: begin
        ALUCtrl = slt_op; // less than
    end
    6'b000011: begin
        ALUCtrl = sltu_op; // less than unsigned
    end
    6'b000100: begin
        ALUCtrl = xor_op; // xor
    end
    6'b000110: begin
        ALUCtrl = or_op; // or
    end
    6'b000111: begin
        ALUCtrl = and_op; // and
    end
    6'b001000: begin
        ALUCtrl = add_op; // add operation
    end
    6'b001010: begin
        if ( MemRead == 1'b1 ) begin // load word
            ALUCtrl = add_op;
        end else begin
            ALUCtrl = slt_op; // set less than
        end
    end
    6'b001011: begin
        ALUCtrl = sltu_op; // set less than unsigned
    end
    6'b001100: begin
        ALUCtrl = xor_op; // xor
    end
    6'b001110: begin
        ALUCtrl = or_op; // or
    end
    6'b001111: begin
        ALUCtrl = and_op; // and
    end
    6'b001001: begin
        ALUCtrl = sl_op; // shift left
    end
    6'b001101: begin
        if(funct7[5] == 0) begin
            ALUCtrl = sru_op; // shift right unisgned
        end else begin
            ALUCtrl = sr_op; // shift right signed
        end
    end
    6'b001000: begin
        ALUCtrl = add_op; // add
    end
    6'b010010: begin
        ALUCtrl = add_op; // sw uses add operation
    end
    6'b011000: begin
        ALUCtrl = beq_op; // branch equal
    end
    6'b011001: begin
        ALUCtrl = bne_op; // branch not equal
    end
    6'b011100: begin
        ALUCtrl = blt_op; // branch less than
    end
    6'b011101: begin
        ALUCtrl = bgt_op; // branch great than
    end
    6'b011110: begin
        ALUCtrl = bltu_op; // branch less than unsigned
    end
    6'b011111: begin
        ALUCtrl = bgtu_op; // branch greater than unsigned
    end
    default: begin
        ALUCtrl = no_op; // No operation
    end
    endcase
end

endmodule