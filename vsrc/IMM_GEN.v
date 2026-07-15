`include "define.v"
module IMM_GEN(i, i_type, imm);
    input [31:7] i;
    input [2:0] i_type;
    output reg [31:0] imm;

    always@(*) begin
	case(i_type)
	    `R_TYPE: imm = 32'h0000_0000;
	    `I_TYPE: imm = {{20{i[31]}}, i[31:20]};
	    `S_TYPE: imm = {{20{i[31]}}, i[31:25], i[11:7]};
	    `B_TYPE: imm = {{19{i[31]}}, i[31], i[7], i[30:25], i[11:8], 1'b0};
	    `U_TYPE: imm = {i[31:12], 12'h000};
	    `J_TYPE: imm = {{11{i[31]}}, i[31], i[19:12], i[20], i[30:21], 1'b0};
	    default: imm = 32'h0000_0000;
	endcase
    end

endmodule
