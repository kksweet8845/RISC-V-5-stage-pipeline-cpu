module RegisterFile(
    input clk,
    input rst,
    input [4:0] rs2_addr,
    input [4:0] rs1_addr,
    input [4:0] rd_addr,
    input [31:0] pc_out,
    input RegWrite,
    input [31:0] Din,
    output reg [31:0] Rs1Data,
    output reg [31:0] Rs2Data
);

/* The register file component */

reg [31:0] register [31:0];
reg [4:0] tempRegister_addr;
integer i;

// initial begin
//     for(i=0;i<32;i=i+1) begin
//         register[i] = 32'h0;
//     end
// end

// Run the circuit the when Din or rd_addr different
always @(*) begin
    if(rst == 0) begin
        if(RegWrite == 1) begin
            if (rd_addr != 0 ) begin
                register[rd_addr] = Din;
            end else begin
                register[rd_addr] = 32'b0;
            end
        end
    end else begin
        for(i=0;i<32;i=i+1) begin
            register[i] = 32'h0;
        end
    end
end

// Run the circuit when rs1_addr or rs2_addr or pc_out different
always @(negedge clk) begin
    if(rst == 0) begin
        Rs1Data = register[rs1_addr];
        Rs2Data = register[rs2_addr];
    end
end


endmodule