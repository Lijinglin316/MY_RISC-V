module IF_ID(clk, en, rst_n, in_i, out_i, in_pc, out_pc, in_pc_plus_4, out_pc_plus_4);
    input clk;
    input en;
    input rst_n;
    input [31:0] in_i;
    input [31:0] in_pc;
    input [31:0] in_pc_plus_4;
    output reg [31:0] out_i;
    output reg [31:0] out_pc;
    output reg [31:0] out_pc_plus_4;

    always@(posedge clk) begin
	if(rst_n == 0) begin
	    out_i <= 0;
	    out_pc <= 0;
	    out_pc_plus_4 <= 0;
	end
	else if(!en) begin
	    out_i <= out_i;
	    out_pc <= out_pc;
	    out_pc_plus_4 <= out_pc_plus_4;
	end
	else begin
	    out_i <= in_i;
	    out_pc <= in_pc;
	    out_pc_plus_4 <= in_pc_plus_4;
	end
    end

endmodule 
 