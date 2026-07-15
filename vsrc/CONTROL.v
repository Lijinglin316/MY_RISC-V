`include "define.v"
module CONTROL(op, funct3, funct7, i_type, l_type, alu_a_con, alu_b_con, alu_op, data_cache_we, gpr_we, gpr_wdata_con, b_type, jal_type, m_extend, div_en);
    input [6:0] op;
    input [2:0] funct3;
    input [6:0] funct7;
    output reg [2:0] i_type;
    output reg alu_a_con;
    output reg alu_b_con;
    output reg [3:0] alu_op;
    output reg data_cache_we;
    output reg gpr_we;
    output reg b_type;
    output reg [1:0] jal_type;
    output reg [2:0] gpr_wdata_con;
	output reg l_type;
	output reg m_extend;
	output reg div_en;

    always@(*) begin
	case(op)
	    7'b0110011: begin
			if(funct7 == 7'b0000001) begin//m扩展
				i_type = `R_TYPE;
				alu_a_con = `DATA_A_A;
				alu_b_con = `DATA_B_B;
				data_cache_we = `UNWEN;
				gpr_we = `WEN;
				b_type = `NO_B_TYPE;
				jal_type = `NO_J_TYPE;
				l_type = `UNEN;
				alu_op = `ADD_OP;
				m_extend = `EN;
				if(funct3 > 3'b011) begin
					div_en = `EN;
					gpr_wdata_con = `DIV_RESULT_GPR_WDATA;
				end else begin
					div_en = `UNEN;
					gpr_wdata_con = `MUT_RESULT_GPR_WDATA;
				end
			end else begin
				i_type = `R_TYPE;
				alu_a_con = `DATA_A_A;
				alu_b_con = `DATA_B_B;
				data_cache_we = `UNWEN;
				gpr_we = `WEN;
				b_type = `NO_B_TYPE;
				jal_type = `NO_J_TYPE;
				l_type = `UNEN;
				m_extend = `UNEN;
				div_en = `UNEN;
				gpr_wdata_con = `ALU_RESULT_GPR_WDATA;
				case(funct3)
				    3'b000: begin
					if(funct7 == 7'b0000000) alu_op = `ADD_OP;
					else if(funct7 == 7'b0100000) alu_op = `SUB_OP;
					else alu_op = 0;
				    end
				    3'b001: alu_op = `LSHIFT_OP;
				    3'b010: alu_op = `COMPARE_OP;
				    3'b011: alu_op = `UNSIGN_COMPARE_OP;
				    3'b100: alu_op = `XOR_OP;
				    3'b101: begin
					if(funct7 == 7'b0000000) alu_op = `RSHIFT_OP;
					else if(funct7 == 7'b0100000) alu_op = `A_RSHIFT_OP;
					else alu_op = 0;
				    end
				    3'b110: alu_op = `OR_OP;
				    3'b111: alu_op = `AND_OP;
				endcase
			end
	    end
	    7'b0010011: begin
		i_type = `I_TYPE;
		alu_a_con = `DATA_A_A;
		alu_b_con = `IMM_B;
		data_cache_we = `UNWEN;
		gpr_we = `WEN;
		b_type = `NO_B_TYPE;
		jal_type = `NO_J_TYPE;
		l_type = `UNEN;
		m_extend = `UNEN;
		div_en = `UNEN;
		gpr_wdata_con = `ALU_RESULT_GPR_WDATA;
		case(funct3) 
		    3'b000: alu_op = `ADD_OP;
		    3'b010: alu_op = `COMPARE_OP;
		    3'b011: alu_op = `UNSIGN_COMPARE_OP;
		    3'b100: alu_op = `XOR_OP;
		    3'b110: alu_op = `OR_OP;
		    3'b111: alu_op = `AND_OP;
		    3'b001: alu_op = `LSHIFT_OP;
		    3'b101: begin
			if(funct7 == 7'b0000000) alu_op = `RSHIFT_OP;
			else if(funct7 == 7'b0100000) alu_op = `A_RSHIFT_OP;
			else alu_op = 0;
		    end
			
		endcase
	    end
	    7'b0100011: begin
		i_type = `S_TYPE;
		alu_a_con = `DATA_A_A;
		alu_b_con = `IMM_B;
		data_cache_we = `WEN;
		gpr_we = `UNWEN;
		b_type = `NO_B_TYPE;
		jal_type = `NO_J_TYPE;
		l_type = `UNEN;
		gpr_wdata_con = `ALU_RESULT_GPR_WDATA;
		alu_op = `ADD_OP;
		m_extend = `UNEN;
		div_en = `UNEN;
	    end
	    7'b0000011: begin
		i_type = `I_TYPE;
		alu_a_con = `DATA_A_A;
		alu_b_con = `IMM_B;
		data_cache_we = `UNWEN;
		gpr_we = `WEN;
		b_type = `NO_B_TYPE;
		jal_type = `NO_J_TYPE;
		l_type = `EN;
		gpr_wdata_con = `CACHE_RDATA_GPR_WDATA;
		alu_op = `ADD_OP;
		m_extend = `UNEN;
		div_en = `UNEN;
	    end
	    7'b1100011: begin
		i_type = `B_TYPE;
		alu_a_con = `DATA_A_A;
		alu_b_con = `DATA_B_B;
		data_cache_we = `UNWEN;
		gpr_we = `UNWEN;
		b_type = `EN;
		jal_type = `NO_J_TYPE;
		l_type = `UNEN;
		m_extend = `UNEN;
		div_en = `UNEN;
		gpr_wdata_con = `ALU_RESULT_GPR_WDATA;
		case(funct3) 
		    3'b000: alu_op = `EQ_OP;
		    3'b001: alu_op = `EQ_OP;
		    3'b100: alu_op = `COMPARE_OP;
		    3'b101: alu_op = `COMPARE_OP;
		    3'b110: alu_op = `UNSIGN_COMPARE_OP;
		    3'b111: alu_op = `UNSIGN_COMPARE_OP;
			default: alu_op = `ADD_OP;
		endcase
	    end
	    7'b1100111: begin
		i_type = `I_TYPE;
		alu_a_con = `DATA_A_A;
		alu_b_con = `IMM_B;
		data_cache_we = `UNWEN;
		gpr_we = `WEN;
		b_type = `NO_B_TYPE;
		jal_type = `JALR;
		l_type = `UNEN;
		gpr_wdata_con = `PC_PLUS_4_GPR_WDATA;
		alu_op = `ADD_OP;
		m_extend = `UNEN;
		div_en = `UNEN;
	    end
	    7'b1101111: begin
		i_type = `J_TYPE;
	    alu_a_con = `DATA_A_A;
		alu_b_con = `DATA_B_B;
		data_cache_we = `UNWEN;
		gpr_we = `WEN;
		b_type = `NO_B_TYPE;
		jal_type = `JAL;
		l_type = `UNEN;
		gpr_wdata_con = `PC_PLUS_4_GPR_WDATA;
		alu_op = `ADD_OP;
		m_extend = `UNEN;
		div_en = `UNEN;
	    end
	    7'b0010111: begin
		i_type = `U_TYPE;
		alu_a_con = `PC_A;
		alu_b_con = `IMM_B;
		data_cache_we = `UNWEN;
		gpr_we = `WEN;
		b_type = `NO_B_TYPE;
		jal_type = `NO_J_TYPE;
		l_type = `UNEN;
		gpr_wdata_con = `ALU_RESULT_GPR_WDATA;
		alu_op = `ADD_OP;
		m_extend = `UNEN;
		div_en = `UNEN;
	    end
	    7'b0110111: begin
		i_type = `U_TYPE;
		alu_a_con = `DATA_A_A;
		alu_b_con = `DATA_B_B;
		data_cache_we = `UNWEN;
		gpr_we = `WEN;
		b_type = `NO_B_TYPE;
		jal_type = `NO_J_TYPE;
		l_type = `UNEN;
		gpr_wdata_con = `IMM_GPR_WDATA;
		alu_op = `ADD_OP;
		m_extend = `UNEN;
		div_en = `UNEN;
	    end
	    default: begin
		i_type = 0;
		alu_a_con = 0;
		alu_b_con = 0;
		data_cache_we = 0;
		gpr_we = 0;
		b_type = 0;
		jal_type = 0;
		l_type = 0;
		gpr_wdata_con = 0;
		alu_op = 0;
		m_extend = `UNEN;
		div_en = `UNEN;
	    end
	endcase
    end

endmodule









 