`include "define.v"
module MUX3_1(data, m_forward, wb_forward, s, out_data);
    input [31:0] data;
    input [31:0] m_forward;
    input [31:0] wb_forward;
    input [1:0] s;
    output reg [31:0] out_data;

    always@(*) begin
        case(s)
            `UNFORWARD : out_data = data;
            `FORWARD_M : out_data = m_forward;
            `FORWARD_WB: out_data = wb_forward;
            default    : out_data = 0;
        endcase
    end

endmodule