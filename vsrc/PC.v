module PC(clk, en, rst_n, npc, pc);
    input clk;
    input en;
    input rst_n;
    input [31:0] npc;
    output reg [31:0] pc;

    always@(posedge clk) begin
	if(rst_n == 0)
	    pc <= 32'h7ffffff0;
	else if(!en)
	    pc <= pc;
	else 
	    pc <= npc;
    end

endmodule