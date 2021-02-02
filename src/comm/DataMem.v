module DataMem(
    input clk,
    input MemRead,
    input MemWrite,
    input [31:0] alu_out_addr,
    input [31:0] rs2_data,
    output reg [31:0] data_addr, // represent the data address in DM
    output reg [31:0] data_in, // represent the data will be wrote into DM
    output reg data_read,
    output reg data_write
);

always @( negedge clk ) begin

    if ( MemRead == 1'b1) begin
        data_read <= 1'b1;
        data_addr <= alu_out_addr;
        data_in <= rs2_data;
    end else begin
        data_read <= 1'b0;
    end

    if (MemWrite == 1'b1) begin
        data_write <= 1'b1;
        data_addr <= alu_out_addr;
        data_in <= rs2_data;
    end else begin
        data_write <= 1'b0;
    end
end

endmodule