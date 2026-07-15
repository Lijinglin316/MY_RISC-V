module ID_EX(clk, rst_n, en, out_op, in_op, in_pc, in_m_extend, in_l_type, out_l_type, in_pc_plus_4, in_dataA, in_dataB, in_rs1, in_rs2, in_rd, in_imm, in_alu_a_con, in_alu_b_con, in_alu_op, in_div_en, in_data_cache_we, in_gpr_we, in_b_type, in_jal_type, in_gpr_wdata_con, out_pc, out_pc_plus_4, out_dataA, out_dataB, out_m_extend, out_div_en, out_rs1, out_rs2, out_rd, out_imm, out_alu_a_con, out_alu_b_con, out_alu_op, out_data_cache_we, out_gpr_we, out_b_type, out_jal_type, out_gpr_wdata_con, in_funct3, out_funct3);
    input clk;
    input rst_n;
    input en;
    input [31:0] in_pc;
    input [31:0] in_pc_plus_4;
    input [31:0] in_dataA;
    input [31:0] in_dataB;
    input [4:0] in_rs1;
    input [4:0] in_rs2;
    input [4:0] in_rd;
    input [31:0] in_imm;
    input in_alu_a_con;
    input in_alu_b_con;
    input [3:0] in_alu_op;
    input in_data_cache_we;
    input in_gpr_we;
    input in_b_type;
    input [1:0] in_jal_type;
    input [2:0] in_gpr_wdata_con;
	input [2:0] in_funct3;
	input in_l_type;
	input [6:0] in_op;
	input in_m_extend;
	input in_div_en;
	output reg out_m_extend;
	output reg out_div_en;
    output reg [31:0]  out_pc;
    output reg [31:0]  out_pc_plus_4;
    output reg [31:0]  out_dataA;
    output reg [31:0]  out_dataB;
    output reg [4:0] out_rs1;
    output reg [4:0] out_rs2;
    output reg [4:0] out_rd;
    output reg [31:0]  out_imm;
    output reg out_alu_a_con;
    output reg out_alu_b_con;
    output reg [3:0] out_alu_op;
    output reg out_data_cache_we;
    output reg out_gpr_we;
    output reg out_b_type;
    output reg [1:0] out_jal_type;
    output reg [2:0] out_gpr_wdata_con;
	output reg [2:0] out_funct3;
	output reg out_l_type;
	output reg [6:0] out_op;
    
    always@(posedge clk) begin
	if(rst_n == 0) begin
	    out_pc <= 0;
	    out_pc_plus_4 <= 0;
	    out_dataA <= 0;
	    out_dataB <= 0;
	    out_rs1 <= 0;
	    out_rs2 <= 0;
	    out_rd <= 0;
	    out_imm <= 0;
	    out_alu_a_con <= 0;
	    out_alu_b_con <= 0;
	    out_alu_op <= 0;
	    out_data_cache_we <= 0;
	    out_gpr_we <= 0;
	    out_b_type <= 0;
	    out_jal_type <= 0;
	    out_gpr_wdata_con <= 0;
		out_funct3 <= 0;
		out_l_type <= 0;
		out_op <= 0;
		out_m_extend <= 0;
		out_div_en <= 0;
	end else if(!en) begin
	    out_pc <= out_pc;
	    out_pc_plus_4 <= out_pc_plus_4;
	    out_dataA <= out_dataA;
	    out_dataB <= out_dataB;
	    out_rs1 <= out_rs1;
	    out_rs2 <= out_rs2;
	    out_rd <= out_rd;
	    out_imm <= out_imm;
	    out_alu_a_con <= out_alu_a_con;
	    out_alu_b_con <= out_alu_b_con;
	    out_alu_op <= out_alu_op;
	    out_data_cache_we <= out_data_cache_we;
	    out_gpr_we <= out_gpr_we;
	    out_b_type <= out_b_type;
	    out_jal_type <= out_jal_type;
	    out_gpr_wdata_con <= out_gpr_wdata_con;
		out_funct3 <= out_funct3;
		out_l_type <= out_l_type;
		out_op <= out_op;
		out_m_extend <= out_m_extend;
		out_div_en <= out_div_en;
	end else begin
	    out_pc <= in_pc;
	    out_pc_plus_4 <= in_pc_plus_4;
	    out_dataA <= in_dataA;
	    out_dataB <= in_dataB;
	    out_rs1 <= in_rs1;
	    out_rs2 <= in_rs2;
	    out_rd <= in_rd;
	    out_imm <= in_imm;
	    out_alu_a_con <= in_alu_a_con;
	    out_alu_b_con <= in_alu_b_con;
	    out_alu_op <= in_alu_op;
	    out_data_cache_we <= in_data_cache_we;
	    out_gpr_we <= in_gpr_we;
	    out_b_type <= in_b_type;
	    out_jal_type <= in_jal_type;
	    out_gpr_wdata_con <= in_gpr_wdata_con;
		out_funct3 <= in_funct3;
		out_l_type <= in_l_type;
		out_op <= in_op;
		out_m_extend <= in_m_extend;
		out_div_en <= in_div_en;
	end
    end

endmodule
	    








 