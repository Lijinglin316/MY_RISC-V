`include "define.v"
module MUX2_1(data, wdata, s, out_data);
    input [31:0] data;
    input [31:0] wdata;
    input s;
    output reg [31:0] out_data;

    always@(*) begin
        case(s)
            `EN  : out_data = wdata;
            `UNEN: out_data = data;
        endcase
    end

endmodule