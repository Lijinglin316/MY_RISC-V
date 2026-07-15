`include "define.v"
module ALU(a, b, alu_op, result);
    input [31:0] a;
    input [31:0] b;
    input [3:0] alu_op;
    output [31:0] result;

    wire carry;
    wire zero;
    wire overflow;
    wire [31:0] add_or_sub_result;
    wire [31:0] less_result;
    wire [31:0] lessu_result;
    wire [31:0] eq_result;
    wire [31:0] shift_result;
    wire [31:0] and_result;
    wire [31:0] or_result;
    wire [31:0] xor_result;
    wire sub_en;
    wire cin;
    wire [31:0] adder_b;
    wire [31:0] xor_a;
    wire [1:0] shift_op;
    wire xor_in_con;
    wire [2:0] result_con;

    assign cin = sub_en;
    assign xor_a = xor_in_con ? {32{sub_en}} : a;
    assign zero = ~|add_or_sub_result;
    assign overflow = (a[31] == adder_b[31]) && (add_or_sub_result[31] != a[31]);
    assign {less_result[31:1], lessu_result[31:1], eq_result[31:1]} = {93'b0};
    assign less_result[0] =  add_or_sub_result[31] ^ overflow;
    assign lessu_result[0] = cin ^ carry;
    assign eq_result[0] = zero;
	assign xor_result = adder_b;

    mux8_to_1 mux8_to_1_U0 (
	    .result_con(result_con),
	    .add_or_sub_result(add_or_sub_result),
	    .less_result(less_result),
	    .lessu_result(lessu_result),
	    .eq_result(eq_result),
	    .shift_result(shift_result),
	    .and_result(and_result),
	    .or_result(or_result),
	    .xor_result(xor_result),
        .result(result)
    );


    adder_32bits adder_32_bits_U0 (
	.a(a), 
	.b(adder_b), 
	.cin(cin), 
	.s(add_or_sub_result), 
	.cout(carry)
    );
    xor_unit xor_unit_U0 (
	.a(xor_a), 
	.b(b), 
	.xor_result(adder_b)
    );
    and_unit and_unit_U0 (
	.a(a), 
	.b(b), 
	.and_result(and_result)
    );
    or_unit or_unit_U0 (
	.a(a), 
	.b(b), 
	.or_result(or_result)
    );
    shifter shifter_U0 (
	.a(a), 
	.shift_op(shift_op), 
	.shamt(b[4:0]), 
	.shift_result(shift_result)
    );
    alu_op_control alu_op_control_U0 (
	.alu_op(alu_op), 
	.sub_en(sub_en), 
	.xor_in_con(xor_in_con), 
	.shift_con(shift_op), 
	.result_con(result_con)
    );

endmodule


module and_unit(a, b, and_result);
    input [31:0] a;
    input [31:0] b;
    output [31:0] and_result;

    assign and_result = a & b;

endmodule

module or_unit(a, b, or_result);
    input [31:0] a;
    input [31:0] b;
    output [31:0] or_result;

    assign or_result = a | b;

endmodule

module xor_unit(a, b, xor_result);
    input [31:0] a;
    input [31:0] b;
    output [31:0] xor_result;

    assign xor_result = a ^ b;

endmodule

module mux8_to_1(result_con, add_or_sub_result, less_result, lessu_result, eq_result, shift_result, and_result, or_result, xor_result, result);
     input [2:0] result_con;
     input [31:0] add_or_sub_result;
     input [31:0] less_result;
     input [31:0] lessu_result;
     input [31:0] eq_result;
     input [31:0] shift_result;
     input [31:0] and_result;
     input [31:0] or_result;
     input [31:0] xor_result;
     output reg [31:0] result;

     always@(*) begin
	case(result_con)
	     `ALU_ADD_OR_SUB_RESULT : result = add_or_sub_result;
	     `ALU_LESS_RESULT       : result = less_result;
	     `ALU_LESS_UNSIGN_RESULT: result = lessu_result;
	     `ALU_EQ_RESULT         : result = eq_result;
	     `ALU_AND_RESULT        : result = and_result;
	     `ALU_OR_RESULT         : result = or_result;
	     `ALU_XOR_RESULT        : result = xor_result;
	     `ALU_SHIFT_RESULT      : result = shift_result;
		 default                : result = add_or_sub_result;	
	endcase
     end

endmodule



module shifter(a, shift_op, shamt, shift_result);
    input [31:0] a;
    input [1:0] shift_op;
    input [4:0] shamt;
    output reg [31:0] shift_result;

    always@(*) begin
	case(shift_op)
	    `SHIFTER_L: shift_result = a << shamt;
	    `SHIFTER_R: shift_result = a >> shamt;
	    `SHIFTER_AR: shift_result = a[31] ? ((~(-1 >> shamt)) | (a >> shamt)) : (a >> shamt);
	    default : shift_result = 0;
	endcase
    end

endmodule

module alu_op_control(alu_op, sub_en, xor_in_con, shift_con, result_con);
    input [3:0] alu_op;
    output reg sub_en;
    output reg xor_in_con;
    output reg [1:0] shift_con;
    output reg [2:0] result_con;

    
    always@(*) begin
	case(alu_op)
	    `ADD_OP: begin
		sub_en =  `UNEN;
		shift_con = `SHIFTER_L;
		xor_in_con = `SUBEN_TO_XOR;
		result_con = `ALU_ADD_OR_SUB_RESULT;
	    end
	    `SUB_OP: begin
		sub_en =  `EN;
		shift_con = `SHIFTER_L;
		xor_in_con = `SUBEN_TO_XOR;
		result_con = `ALU_ADD_OR_SUB_RESULT;
	    end
	    `COMPARE_OP: begin
		sub_en =  `EN;
		shift_con = `SHIFTER_L;
		xor_in_con = `SUBEN_TO_XOR;
		result_con = `ALU_LESS_RESULT;
	    end
	    `UNSIGN_COMPARE_OP: begin
		sub_en =  `EN;
		shift_con = `SHIFTER_L;
		xor_in_con = `SUBEN_TO_XOR;
		result_con = `ALU_LESS_UNSIGN_RESULT;
	    end 
	    `EQ_OP: begin
		sub_en =  `EN;
		shift_con = `SHIFTER_L;
		xor_in_con = `SUBEN_TO_XOR;
		result_con = `ALU_EQ_RESULT;
	    end
	    `LSHIFT_OP: begin
		sub_en =  `EN;
		shift_con = `SHIFTER_L;
		xor_in_con = `SUBEN_TO_XOR;
		result_con = `ALU_SHIFT_RESULT;
	    end
	    `RSHIFT_OP: begin
		sub_en =  `EN;
		shift_con = `SHIFTER_R;
		xor_in_con = `SUBEN_TO_XOR;
		result_con = `ALU_SHIFT_RESULT;
	    end
	    `A_RSHIFT_OP: begin
		sub_en =  `EN;
		shift_con = `SHIFTER_AR;
		xor_in_con = `SUBEN_TO_XOR;
		result_con = `ALU_SHIFT_RESULT;
	    end
	    `AND_OP: begin
		sub_en =  `EN;
		shift_con = `SHIFTER_L;
		xor_in_con = `SUBEN_TO_XOR;
		result_con = `ALU_AND_RESULT;
	    end
	    `OR_OP: begin
		sub_en =  `EN;
		shift_con = `SHIFTER_L;
		xor_in_con = `SUBEN_TO_XOR;
		result_con = `ALU_OR_RESULT;
	    end
	    `XOR_OP: begin
		sub_en =  `EN;
		shift_con = `SHIFTER_L;
		xor_in_con = `A_TO_XOR;
		result_con = `ALU_XOR_RESULT;
	    end
		default: begin
		sub_en =  `UNEN;
		shift_con = `SHIFTER_L;
		xor_in_con = `SUBEN_TO_XOR;
		result_con = `ALU_LESS_RESULT;
		end
	endcase
    end

endmodule








 