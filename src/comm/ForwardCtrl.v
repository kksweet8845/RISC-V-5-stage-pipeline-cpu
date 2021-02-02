module ForwardCtrl(
    // EX rs & rt
    input [4:0] EX_rs1_addr,
    input [4:0] EX_rs2_addr,
    // MEM forwarding
    input WB_RegWrite,
    input [4:0] WB_rd_addr,
    // EX forwarding & lwsw pairs
    input MEM_RegWrite,
    input [4:0] MEM_rd_addr,
    input [4:0] MEM_rs2_addr,
    input MEM_MemWrite,
    // output
    // forward rs1
    output reg [1:0] ForwardRs1Src,
    // forward rs2
    output reg [1:0] ForwardRs2Src,
    // forward MEM data input
    output reg ForwardRDSrc
);

always @(*) begin

    // EX & MEM rs1 forward
    if ( MEM_RegWrite
    & (MEM_rd_addr != 5'b0)
    & ( EX_rs1_addr == MEM_rd_addr ) ) begin // forward rs1
        ForwardRs1Src = 2'b01;
    end else if ( WB_RegWrite
    & (WB_rd_addr != 5'b0)
    & (! (MEM_RegWrite
            & MEM_rd_addr != 5'b0
            & MEM_rd_addr == WB_rd_addr))
    & ( EX_rs1_addr == WB_rd_addr ) ) begin
        ForwardRs1Src = 2'b10;
    end else begin
        ForwardRs1Src = 2'b0;
    end

    // EX & MEM rs2 forward
    if ( MEM_RegWrite
    & (MEM_rd_addr != 5'b0)
    & ( EX_rs2_addr == MEM_rd_addr ) )begin
        ForwardRs2Src = 2'b01;
    end else if( WB_RegWrite
    & (WB_rd_addr != 5'b0)
    & (!(MEM_RegWrite
            & MEM_rd_addr != 5'b0
            & MEM_rd_addr == WB_rd_addr))
    & (EX_rs2_addr == WB_rd_addr )) begin
        ForwardRs2Src = 2'b10;
    end else begin
        ForwardRs2Src = 2'b0;
    end

    // WB & MEM forward
    if ( WB_RegWrite
    & MEM_MemWrite
    & ( MEM_rs2_addr == WB_rd_addr )) begin
        ForwardRDSrc = 1'b1;
    end else begin
        ForwardRDSrc = 1'b0;
    end
end


endmodule