module MEM1 (clk, we, en, funct3, tick, printf, printf_vaild, in_addr, in_data, out_data);
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

    wire [31:0] dataout;
    reg read_tick;
    reg [31:0] mem_out_data;
    reg mem_en;

    assign out_data = (mem_en == 0) ? mem_out_data : (read_tick ? tick : dataout);

    always@(posedge clk) begin
		mem_out_data <= out_data;
		mem_en <= en;
	end

    always@(posedge clk) begin
		if((in_addr == 32'h00080000)&(we)) begin
			printf = in_data;
			printf_vaild = 1;
		end
		else begin
			printf = 0;
			printf_vaild = 0;
		end
	end

    always@(posedge clk) begin
		if(in_addr == 32'h00800000)
			 read_tick <= 1;
		else 
			read_tick <= 0;
	end

    mem8bit M_U0(.clk(clk),
                        .din(in_data),
                        .funct3(funct3),
                        .addr(in_addr[15:0]),
                        .dataout(dataout),
                        .we(we));

    endmodule


