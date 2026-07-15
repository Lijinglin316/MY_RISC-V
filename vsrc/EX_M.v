module EX_M(clk, rst_n, en, in_pc_plus_4, in_imm, in_alu_result, in_dataB, in_funct3, in_rd, in_data_cache_we, in_gpr_we, in_gpr_wdata_con, out_pc_plus_4, out_imm, out_alu_result, out_dataB, out_funct3, out_rd, out_data_cache_we, out_gpr_we, out_gpr_wdata_con);
    input clk;
    input rst_n;
    input en;
    input [31:0] in_pc_plus_4;
    input [31:0] in_imm;
    input [31:0] in_alu_result;
    input [31:0] in_dataB;
    input [2:0] in_funct3;
    input [4:0] in_rd;
    input in_data_cache_we;
    input in_gpr_we;
    input [2:0] in_gpr_wdata_con;
    output reg [31:0] out_pc_plus_4;
    output reg [31:0] out_imm;
    output reg [31:0] out_alu_result;
    output reg [31:0] out_dataB;
    output reg [2:0] out_funct3;
    output reg [4:0] out_rd;
    output reg out_data_cache_we;
    output reg out_gpr_we;
    output reg [2:0] out_gpr_wdata_con;

    always@(posedge clk) begin
	if(rst_n == 0) begin
	    out_pc_plus_4 <= 0;
	    out_imm <= 0;
	    out_alu_result <= 0;
	    out_dataB <= 0;
	    out_funct3 <= 0;
	    out_rd <= 0;
	    out_data_cache_we <= 0;
	    out_gpr_we <= 0;
	    out_gpr_wdata_con <= 0;
	end else if(!en) begin
	    out_pc_plus_4 <= out_pc_plus_4;
	    out_imm <= out_imm;
	    out_alu_result <= out_alu_result;
	    out_dataB <= out_dataB;
	    out_funct3 <= out_funct3;
	    out_rd <= out_rd;
	    out_data_cache_we <= out_data_cache_we;
	    out_gpr_we <= out_gpr_we;
	    out_gpr_wdata_con <= out_gpr_wdata_con;
	end else begin
	    out_pc_plus_4 <= in_pc_plus_4;
	    out_imm <= in_imm;
	    out_alu_result <= in_alu_result;
	    out_dataB <= in_dataB;
	    out_funct3 <= in_funct3;
	    out_rd <= in_rd;
	    out_data_cache_we <= in_data_cache_we;
	    out_gpr_we <= in_gpr_we;
	    out_gpr_wdata_con <= in_gpr_wdata_con;
	end
    end

endmodule
