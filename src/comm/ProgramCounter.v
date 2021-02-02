module ProgramCounter(
    input rst,
    input [31:0] pc_in,
    input PCWrite,
    output reg [31:0] pc_out
);

// initial begin
//     pc_out = 32'b0;
// end

always @(*) begin
    // $display("%h",pc_in);
    if(rst) begin
        pc_out = 32'd0;
    end else begin
        if (PCWrite) begin
            pc_out = pc_in;
        end else begin
            pc_out = pc_in - 32'h00000004;
        end
    end
end

endmodule