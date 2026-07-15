`include "define.v"
module MEM_cpu(clk, en, rst_n, we, tick, funct3, addr, din, dout, print, print_vaild);
    input clk;
    input en;
    input rst_n;
    input we;
    input [31:0]tick;
    input [2:0]funct3;
    input [31:0]addr;
    input [31:0]din;
    output [31:0]dout;
    output reg [7:0]print;
    output reg print_vaild;
    
    reg [1:0]read_tick;
    reg [3:0]wen;
    wire [31:0]mem_out;
    reg [31:0]extend_mem_out;
    reg [2:0]extend_op[1:0];
    reg [1:0]ren[1:0];
    reg [31:0]mem_in;
    assign dout = read_tick[1] ? tick : extend_mem_out; 
    
    always@(*) begin
		if(we & (addr != 32'h00080000))begin
			case(funct3)
				`SW : begin wen = 4'b1111;
				        mem_in = din;
				        end
				`SH : begin wen = (addr[1]) ? 4'b1100 : 4'b0011;
				      mem_in = (addr[1]) ? din<<16 : din;
				      end
				`SB : begin wen = (addr[1]) ? 
                    		(addr[0] ? 4'b1000 : 4'b0100) :
                    		(addr[0] ? 4'b0010 : 4'b0001);
                      mem_in = (addr[1]) ? 
                            (addr[0] ? din<<24 : din <<16):
                            (addr[0] ? din<<8 : din);                                
                      end
				default: begin wen = 0;
                         mem_in = din;
                         end
			endcase
		end else begin
			wen = 0;
			mem_in = din;
		end
		case(extend_op[1])
				`LW : extend_mem_out = mem_out;
				`LH : extend_mem_out = (ren[1][1]) ? {{16{mem_out[31]}}, mem_out[31:16]} : {{16{mem_out[15]}}, mem_out[15:0]};
				`LB : extend_mem_out = (ren[1][1]) ?
									(ren[1][0] ? {{24{mem_out[31]}}, mem_out[31:24]} : {{24{mem_out[23]}}, mem_out[23:16]}):
									(ren[1][0] ? {{24{mem_out[15]}}, mem_out[15:8]} : {{24{mem_out[7]}}, mem_out[7:0]});
				`LHU: extend_mem_out = (ren[1][1]) ? {16'h0000, mem_out[31:16]} : {16'h0000, mem_out[15:0]};
				`LBU: extend_mem_out = (ren[1][1]) ?
									(ren[1][0] ? {{24'h000000}, mem_out[31:24]} : {{24'h000000}, mem_out[23:16]}):
									(ren[1][0] ? {{24'h000000}, mem_out[15:8]} : {{24'h000000}, mem_out[7:0]});
				default : extend_mem_out = mem_out;
			endcase
    end
    
    always @(posedge clk) begin
        if(!rst_n) begin
            extend_op[0] <= 0;
            extend_op[1] <= 0;
            ren[0] <= 0;
            ren[1] <= 0;
        end else if(!en)begin
            extend_op[0] <= extend_op[0];
            extend_op[1] <= extend_op[1];
            ren[0] <= ren[0];
            ren[1] <= ren[1];
        end else begin
            extend_op[0] <= funct3;
            extend_op[1] <= extend_op[0];
            ren[0] <= addr[1:0];
            ren[1] <= ren[0];
        end
    end
    
    always@(posedge clk) begin
		if((addr == 32'h00080000)&(we)) begin
			print = din[7:0];
			print_vaild = 1;
		end
		else begin
			print = 0;
			print_vaild = 0;
		end
	end
    
    always@(posedge clk) begin
        if(!rst_n)begin
            read_tick <= 0;
        end else if(!en) begin
            read_tick <= read_tick;
        end else if(addr == 32'h00800000) begin
            read_tick[0] <= 1;
            read_tick[1] <= read_tick[0];
        end else begin
            read_tick[0] <= 0;
            read_tick[1] <= read_tick[0];
        end
    end
    
    
     ip_mem ip_memU0(
  .clka(clk),    // input wire clka
  .ena(en),      // input wire ena
  .wea(wen),      // input wire [3 : 0] wea
  .addra(we ? addr[16:2] : 0),  // input wire [13 : 0] addra
  .dina(mem_in),    // input wire [31 : 0] dina
  .douta(),  // output wire [31 : 0] douta
  .clkb(clk),    // input wire clkb
  .enb(en),      // input wire enb
  .web(0),      // input wire [3 : 0] web
  .addrb(we ? 0 : addr[16:2]),  // input wire [13 : 0] addrb
  .dinb(0),    // input wire [31 : 0] dinb
  .doutb(mem_out)  // output wire [31 : 0] doutb
);
     
     
    /*    ip_mem ip_memU0 (
        .clka(clk),            // input wire clka
        .ena(en),              // input wire ena
        .wea(wen),              // input wire [3 : 0] wea
        .addra(addr[16:2]),          // input wire [14 : 0] addra
        .dina(mem_in),            // input wire [31 : 0] dina
        .clkb(clk),            // input wire clkb
        .rstb(!rst_n),            // input wire rstb
        .enb(en),              // input wire enb
        .addrb(addr[16:2]),          // input wire [14 : 0] addrb
        .doutb(mem_out),          // output wire [31 : 0] doutb
        .rsta_busy(),  // output wire rsta_busy
        .rstb_busy()  // output wire rstb_busy
            );
        
      */  
endmodule
