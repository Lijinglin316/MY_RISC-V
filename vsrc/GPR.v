module GPR(clk, rst_n, rs1, rs2, data1, data2, rd, wdata, wen); 
    input clk;
    input rst_n;
    input [4:0] rs1;
    input [4:0] rs2;
    input [4:0] rd;
    input [31:0] wdata;
    input wen;
    output [31:0] data1;
    output [31:0] data2;

    reg [31:0] x [0:31];
    integer i;
    always@(posedge clk) begin
	if(rst_n == 0) begin
	    for(i = 0; i < 32; i = i + 1)
		x[i] <= 0;
	end
	else if(wen) begin
	    x[rd] <= wdata;
	end
    end

assign data1 = (rs1 == 0) ? 0 : x[rs1];
assign data2 = (rs2 == 0) ? 0 : x[rs2];

endmodule