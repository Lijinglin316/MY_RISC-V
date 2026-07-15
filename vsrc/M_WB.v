module M_WB(clk, rst_n, en, in_div_result, in_mut_result, in_pc_plus_4, in_imm, in_alu_result, in_cache_read_data, in_gpr_wdata_con, in_rd, in_gpr_we, out_div_result, out_mut_result, out_pc_plus_4, out_imm, out_alu_result, out_cache_read_data, out_gpr_wdata_con, out_rd, out_gpr_we);
    input clk;
    input rst_n;
    input en;
	input [31:0] in_div_result;
	input [31:0] in_mut_result;
    input [31:0] in_pc_plus_4;
    input [31:0] in_imm;
    input [31:0] in_alu_result;
    input [31:0] in_cache_read_data;
    input [2:0] in_gpr_wdata_con;
    input [4:0] in_rd;
    input in_gpr_we;
	output reg [31:0] out_div_result;
	output reg [31:0] out_mut_result;
    output reg [31:0] out_pc_plus_4;
    output reg [31:0] out_imm;
    output reg [31:0] out_alu_result;
    output reg [31:0] out_cache_read_data;
    output reg [2:0] out_gpr_wdata_con;
    output reg [4:0] out_rd;
    output reg out_gpr_we;

    always@(posedge clk) begin
	if(rst_n == 0) begin
	     out_pc_plus_4 <= 0;
	     out_imm <= 0;
	     out_alu_result <= 0;
	     out_cache_read_data <= 0;
	     out_gpr_wdata_con <= 0;
	     out_rd <= 0;
	     out_gpr_we <= 0;
		 out_div_result <= 0;
		 out_mut_result <= 0;
	end else if(!en) begin
	     out_pc_plus_4 <= out_pc_plus_4;
	     out_imm <= out_imm;
	     out_alu_result <= out_alu_result;
	     out_cache_read_data <= out_cache_read_data;
	     out_gpr_wdata_con <= out_gpr_wdata_con;
	     out_rd <= out_rd;
	     out_gpr_we <= out_gpr_we;
		 out_div_result <= out_div_result;
		 out_mut_result <= out_mut_result;
	end else begin
	     out_pc_plus_4 <= in_pc_plus_4;
	     out_imm <= in_imm;
	     out_alu_result <= in_alu_result;
	     out_cache_read_data <= in_cache_read_data;
	     out_gpr_wdata_con <= in_gpr_wdata_con;
	     out_rd <= in_rd;
	     out_gpr_we <= in_gpr_we;
		 out_div_result <= in_div_result;
		 out_mut_result <= in_mut_result;
	end
    end

endmodule
