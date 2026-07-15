`include "define.v"
module mem8bit (din, we, funct3, clk, dataout, addr);
    input clk;
    input we;
    input [2:0] funct3;
    input [31:0] din;
    input [15:0] addr;
    output reg [31:0] dataout;

    reg [8:0] mem [1024*64-1:0];
    reg [31:0] dout;
    reg [2:0] funct30;

    always@(posedge clk) begin
        funct30 <= funct3;
    end

    always@(posedge clk) begin
        if(we) begin
            case(funct3)
                `SW :   begin
                            mem[addr]   <= din[7:0];
                            mem[addr+1] <= din[15:8];
                            mem[addr+2] <= din[23:16];
                            mem[addr+3] <= din[31:24];
                        end
                `SH :   begin
                            mem[addr]   <= din[7:0];
                            mem[addr+1] <= din[15:8];
                        end
                `SB :   begin
                            mem[addr]   <= din[7:0];
                        end
            endcase
        end
            dout[7:0]   <= mem[addr];
            dout[15:8]  <= mem[addr+1];
            dout[23:16] <= mem[addr+2];
            dout[31:24] <= mem[addr+3];
    end

    always@(*) begin
        case(funct30)
                `LW : dataout = dout;
				`LH : dataout = {{16{dout[15]}}, dout[15:0]};
				`LB : dataout = {{24{dout[7]}}, dout[7:0]};
				`LHU: dataout = {16'h0000, dout[15:0]};
				`LBU: dataout = {24'h000000, dout[7:0]};
				default : dataout = dout;
        endcase
    end

    endmodule