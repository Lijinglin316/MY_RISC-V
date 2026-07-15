`include "define.v"
module MEM(clk, we, en, funct3, tick, printf, printf_vaild, in_addr, in_data, out_data);
    input clk;
    input we;
	input en;
    input [2:0] funct3;//指令集中的funct3,控制读写模式
    input [31:0] in_addr;
    input [31:0] in_data;
	input [31:0] tick;//
    output  [31:0] out_data; 
	output reg [31:0] printf;//
	output reg printf_vaild;
	
	reg mem_en;
	wire [31:0] out_data_m;
	reg [31:0] out_data_m1;
	reg [3:0] wen;
	reg read_tick;
	reg [2:0] funct30;
	reg [1:0] ren;
	reg [31:0] mem_out_data;
	assign out_data = (mem_en == 0) ? mem_out_data : (read_tick ? tick : out_data_m1);



	always@(posedge clk) begin
		if(in_addr == 32'h00800000)
			 read_tick <= 1;
		else 
			read_tick <= 0;
	end

	always@(posedge clk) begin
		mem_out_data <= out_data;
		ren <= in_addr[1:0];
		mem_en <= en;
		funct30 <= funct3;
	end

    mem32bit M_U0(.clk(clk),
			.in_data(in_data),
			.addr(in_addr[15:2]),
			.wen(wen),
			.out_data(out_data_m));

	always@(*) begin
		if(we)begin
			case(funct3)
				`SW : wen = 4'b1111;
				`SH : wen = (in_addr[1]) ? 4'b1100 : 4'b0011;
				`SB : wen = (in_addr[1]) ? 
                    		(in_addr[0] ? 4'b1000 : 4'b0100) :
                    		(in_addr[0] ? 4'b0010 : 4'b0001);
				default: wen = 0;
			endcase
		end else begin
			wen = 0;
		end
		
			case(funct30)
				`LW : out_data_m1 = out_data_m;
				`LH : out_data_m1 = (ren[1]) ? {{16{out_data_m[31]}}, out_data_m[31:16]} : {{16{out_data_m[15]}}, out_data_m[15:0]};
				`LB : out_data_m1 = (ren[1]) ?
									(ren[0] ? {{24{out_data_m[31]}}, out_data_m[31:24]} : {{24{out_data_m[23]}}, out_data_m[23:16]}):
									(ren[0] ? {{24{out_data_m[15]}}, out_data_m[15:8]} : {{24{out_data_m[7]}}, out_data_m[7:0]});
				`LHU: out_data_m1 = (ren[1]) ? {16'h0000, out_data_m[31:16]} : {16'h0000, out_data_m[15:0]};
				`LBU: out_data_m1 = (ren[1]) ?
									(ren[0] ? {{24'h000000}, out_data_m[31:24]} : {{24'h000000}, out_data_m[23:16]}):
									(ren[0] ? {{24'h000000}, out_data_m[15:8]} : {{24'h000000}, out_data_m[7:0]});
				default : out_data_m1 = out_data_m;
			endcase
		end




	always@(posedge clk) begin
		if(in_addr == 32'h00080000) begin
			printf = in_data;
			printf_vaild = 1;
		end
		else begin
			printf = 0;
			printf_vaild = 0;
		end
	end
		


endmodule