
module DIV_SIGN(clk, rst_n, en, funct3, dataA, dataB, running, result);
    input clk;
    input rst_n;
    input en;
    input [2:0]funct3;
    input [31:0]dataA;
    input [31:0]dataB;
    output running;
    output [31:0]result;

    wire [31:0]quotient;
    wire [31:0]remainder;
    wire [31:0]div_A;
    wire [31:0]div_B;
    reg result_sel; 
    reg reg_result_sel;
    reg sign;
    reg reg_sign;
    reg sign_A;
    reg sign_B;
    wire sign_quotient;
    wire sign_remainder;
    wire [31:0]extend_quotient;
    wire [31:0]extend_remainder;
    
    assign result = reg_result_sel ? extend_quotient : extend_remainder;
    assign sign_remainder = sign_A;
    assign sign_quotient = sign_A ^ sign_B;
    assign extend_quotient = reg_sign ? (sign_quotient ? ((~quotient) + 1) : quotient) : (quotient);
    assign extend_remainder = reg_sign ? (sign_remainder ? ((~remainder) + 1) : remainder) : (remainder);
    
    DIV DIVU0(.dataA(div_A), 
              .dataB(div_B), 
              .clk(clk), 
              .rst_n(rst_n), 
              .en(en), 
              .running(running), 
              .quotient(quotient), 
              .remainder(remainder));
    
    always@(posedge clk) begin
        if(!rst_n) begin
            sign_A <= 0;
            sign_B <= 0;
            reg_sign <= 0;
            reg_result_sel <= 0;
        end else if(running) begin
            sign_A <= sign_A;
            sign_B <= sign_B;
            reg_sign <= reg_sign;
            reg_result_sel <= reg_result_sel; 
        end else begin
            sign_A <= dataA[31];
            sign_B <= dataB[31];
            reg_sign <= sign;
            reg_result_sel <= result_sel;
        end
    end   
     
    assign div_A = sign ? (dataA[31] ? ((~dataA) + 1) : dataA) : (dataA);
    assign div_B = sign ? (dataB[31] ? ((~dataB) + 1) : dataB) : (dataB);
    
    always@(*) begin
        case(funct3)
            3'b100: begin sign = 1; result_sel = 1;end
            3'b101: begin sign = 0; result_sel = 1;end
            3'b110: begin sign = 1; result_sel = 0;end
            3'b111: begin sign = 0; result_sel = 0;end
            default:begin sign = 0;result_sel = 0;end
        endcase
     end
     
endmodule
