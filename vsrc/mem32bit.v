module mem32bit(
    input clk,
    input [31:0] in_data,
    input [13:0] addr,  // 14位字地址，64KB深度
    input [3:0] wen,    // 4位字节写使能
    output reg [31:0] out_data
);

// (* ram_style = "block" *) // 可选，强制综合为块RAM
reg [31:0] mem [0:16383]; // 32位宽 x 16384深度 = 64KB


always @(posedge clk) begin
    // 写入（带字节使能）
    if (wen[0]) mem[addr][7:0]   <= in_data[7:0];
    if (wen[1]) mem[addr][15:8]  <= in_data[15:8];
    if (wen[2]) mem[addr][23:16] <= in_data[23:16];
    if (wen[3]) mem[addr][31:24] <= in_data[31:24];
    // 同步读取
    out_data <= mem[addr];
end

endmodule