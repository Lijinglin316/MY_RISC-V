`include "define.v"
module BPU(clk, rst_n, ex_jal_type, ex_b_type, ex_funct3, ex_brench_addr, ex_alu_result, if_pc, ex_pc, pre, brench_addr, s);
    input clk;
    input rst_n;
    input ex_b_type;
    input [1:0] ex_jal_type;
    input [2:0] ex_funct3;
    input [31:0] ex_brench_addr;
    input [31:0] ex_alu_result;
    input [31:0] if_pc;
    input [31:0] ex_pc;
    output pre;
    output [31:0] brench_addr;
    output [1:0] s;

    wire sat_counter_c;
    wire [19:0] sat_counter_en;
    wire [19:0] pointer;
    wire ex_j_type;
    wire miss;
    wire [1:0] sat_count [19:0];
    wire hint;
    reg [19:0] set01;
    reg [19:0] set10;
    wire history_pre;
    wire [19:0] x;
    wire [19:0] y;
    reg b_result;
    wire [31:0] bht_pc [19:0];
    wire [31:0] bht_addr [19:0];
    wire success;
    wire [19:0] brench_pre;

    assign hint = (ex_j_type | ex_b_type)&(| y);
    assign ex_j_type = (ex_jal_type > 2'b00) ? 1'b1 : 1'b0;
    assign miss = (ex_j_type | ex_b_type) & (y == 0);

    wire [19:0] pc_we;
    wire [19:0] addr_we;
    wire [31:0] history_brench_addr;

    assign sat_counter_en = y;
    assign sat_counter_c = success;
    assign success = history_pre == b_result;
    assign pc_we = miss ? pointer : 0;
    assign addr_we = miss ? pointer : 0;
    assign s = (miss ? (b_result ? 2'b10 : 2'b00) : (hint ? (((ex_jal_type == `JALR)&(history_brench_addr != ex_brench_addr)) ? 2'b10 : (success ? 2'b00 : (b_result ? 2'b10 : 2'b01 ))) : 2'b00));


    always@(*) begin
        if(miss) begin
            if(b_result) begin 
                set10 = pointer;
                set01 = 0;
            end else begin
                set10 = 0;
                set01 = pointer;
            end
        end else begin
            set01 = 0;
            set10 = 0;
        end
    end
            

    mux10_1_32bits mux10_1_32bitsU1(.a0(bht_addr[0]),
                                    .a1(bht_addr[1]),
                                    .a2(bht_addr[2]),
                                    .a3(bht_addr[3]),
                                    .a4(bht_addr[4]),
                                    .a5(bht_addr[5]),
                                    .a6(bht_addr[6]),
                                    .a7(bht_addr[7]),
                                    .a8(bht_addr[8]),
                                    .a9(bht_addr[9]),
                                    .a10(bht_addr[10]),
                                    .a11(bht_addr[11]),
                                    .a12(bht_addr[12]),
                                    .a13(bht_addr[13]),
                                    .a14(bht_addr[14]),
                                    .a15(bht_addr[15]),
                                    .a16(bht_addr[16]),
                                    .a17(bht_addr[17]),
                                    .a18(bht_addr[18]),
                                    .a19(bht_addr[19]),
                                    .s(y),
                                    .en(1'b1),
                                    .pre(history_brench_addr));


    mux10_1_32bits mux10_1_32bitsU0(.a0(bht_addr[0]),
                                    .a1(bht_addr[1]),
                                    .a2(bht_addr[2]),
                                    .a3(bht_addr[3]),
                                    .a4(bht_addr[4]),
                                    .a5(bht_addr[5]),
                                    .a6(bht_addr[6]),
                                    .a7(bht_addr[7]),
                                    .a8(bht_addr[8]),
                                    .a9(bht_addr[9]),
                                    .a10(bht_addr[10]),
                                    .a11(bht_addr[11]),
                                    .a12(bht_addr[12]),
                                    .a13(bht_addr[13]),
                                    .a14(bht_addr[14]),
                                    .a15(bht_addr[15]),
                                    .a16(bht_addr[16]),
                                    .a17(bht_addr[17]),
                                    .a18(bht_addr[18]),
                                    .a19(bht_addr[19]),
                                    .s(x),
                                    .en(1'b1),
                                    .pre(brench_addr));

    onehot_counter onehot_counterU0(.en(miss),
                              .clk(clk),
                              .rst_n(rst_n),
                              .count(pointer));

    mux10_1 mux10_1U0(.a(brench_pre),
                      .s(x),
                      .en(1'b1),
                      .pre(pre));

    mux10_1 mux10_1U1(.a(brench_pre),
                      .s(y),
                      .en(1'b1),
                      .pre(history_pre));


    genvar i;
    generate
        for(i = 0; i < 20; i = i + 1) begin
            assign x[i] = ((if_pc == bht_pc[i])) ? 1'b1 : 1'b0;
            assign y[i] = ((ex_pc == bht_pc[i])) ? 1'b1 : 1'b0;
            assign brench_pre[i] = (sat_count[i] > 2'b01) ? `JUMP : `NO_JUMP; 
        end
    endgenerate

    generate
        for(i = 0; i < 20; i = i + 1) begin : gen_pc_m
            pc_m pc_mU(.clk(clk),
                        .rst_n(rst_n),
                        .we(pc_we[i]),
                        .pc(ex_pc),
                        .out_pc(bht_pc[i])
                        );
        end
    endgenerate

    generate
        for(i = 0; i < 20; i = i + 1) begin : gen_addr_m
            pc_m addr_mU(.clk(clk),
                        .rst_n(rst_n),
                        .we(addr_we[i]),
                        .pc(ex_brench_addr),
                        .out_pc(bht_addr[i])
                        );
        end
    endgenerate

    generate
        for(i = 0; i < 20; i = i + 1) begin : gen_sat_counter
            sat_counter sat_counterU(.clk(clk),
                                    .en(sat_counter_en[i]),
                                    .c(sat_counter_c),
                                    .set01(set01[i]),
                                    .set10(set10[i]),
                                    .count(sat_count[i])
                                   );
        end
    endgenerate 


    always@(*) begin
        if(ex_b_type) begin
            case(ex_funct3)
                3'b000: if(ex_alu_result == 1) b_result = `JUMP;
                        else b_result = `NO_JUMP;
                3'b001: if(ex_alu_result == 0) b_result = `JUMP;
                        else b_result = `NO_JUMP;
                3'b100: if(ex_alu_result == 1) b_result = `JUMP;
                        else b_result = `NO_JUMP;
                3'b101: if(ex_alu_result == 0) b_result = `JUMP;
                        else b_result = `NO_JUMP;
                3'b110: if(ex_alu_result == 1) b_result = `JUMP;
                        else b_result = `NO_JUMP;
                3'b111: if(ex_alu_result == 0) b_result = `JUMP;
                        else b_result = `NO_JUMP;
                default: b_result = 0;
            endcase
        end else if(ex_j_type)begin
            b_result = `JUMP;
        end else b_result = `NO_JUMP;
    end
endmodule

module sat_counter(clk, en, c, set01, set10, count);
    input clk;
    input en;
    input c;
    input set01;
    input set10;
    output reg [1:0] count;

    always@(posedge clk) begin
        if(set01) count = 2'b01;
        else if(set10) count = 2'b10;
        else if(en & c) begin
                case(count)
                    2'b00: count = 2'b00;
                    2'b01: count = 2'b00;
                    2'b10: count = 2'b11;
                    2'b11: count = 2'b11;
                endcase
        end else if(en & (!c)) begin
                case(count)
                    2'b00: count = 2'b01;
                    2'b01: count = 2'b10;
                    2'b10: count = 2'b01;
                    2'b11: count = 2'b10;
                endcase
        end else count = count;
    end

endmodule


module onehot_counter(clk, en, rst_n, count); 
    input clk;
    input en;
    input rst_n;
    output reg [19:0] count;

    always@(posedge clk) begin
        if(rst_n == 0)
            count = 20'b1;
        else if(!en) 
            count = count;
        else if(count == 20'b1000_0000_0000_0000_0000)
            count = 20'b1;
        else count = {count[18:0], 1'b0};
    end
endmodule

module pc_m(clk, rst_n, we, pc, out_pc);
    input rst_n;
    input clk;
    input we;
    input [31:0] pc;
    output [31:0] out_pc; 

    reg [31:0] mem;

    assign out_pc = mem;

    always@(posedge clk) begin
        if(rst_n == 0)
            mem = -1;
        else if(!we)
            mem = mem;
        else mem = pc;
    end
endmodule

module mux10_1(a, s, en, pre);
    input [19:0] a;
    input [19:0] s;
    input en;
    output reg pre;

    always@(*) begin
        if(!en) pre = 1'b0;
        else 
            case(s)
                20'b0000_0000_0000_0000_0001: pre =a[0];
                20'b0000_0000_0000_0000_0010: pre =a[1];
                20'b0000_0000_0000_0000_0100: pre =a[2];
                20'b0000_0000_0000_0000_1000: pre =a[3];
                20'b0000_0000_0000_0001_0000: pre =a[4];
                20'b0000_0000_0000_0010_0000: pre =a[5];
                20'b0000_0000_0000_0100_0000: pre =a[6];
                20'b0000_0000_0000_1000_0000: pre =a[7];
                20'b0000_0000_0001_0000_0000: pre =a[8];
                20'b0000_0000_0010_0000_0000: pre =a[9];
                20'b0000_0000_0100_0000_0000: pre =a[10];
                20'b0000_0000_1000_0000_0000: pre =a[11];
                20'b0000_0001_0000_0000_0000: pre =a[12];
                20'b0000_0010_0000_0000_0000: pre =a[13];
                20'b0000_0100_0000_0000_0000: pre =a[14];
                20'b0000_1000_0000_0000_0000: pre =a[15];
                20'b0001_0000_0000_0000_0000: pre =a[16];
                20'b0010_0000_0000_0000_0000: pre =a[17];
                20'b0100_0000_0000_0000_0000: pre =a[18];
                20'b1000_0000_0000_0000_0000: pre =a[19];
                default         : pre =1'b0; 
    endcase
    end
endmodule

module mux10_1_32bits(a0,a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19, s, en, pre);
    input [31:0]a0;
    input [31:0]a1;
    input [31:0]a2;
    input [31:0]a3;
    input [31:0]a4;
    input [31:0]a5;
    input [31:0]a6;
    input [31:0]a7;
    input [31:0]a8;
    input [31:0]a9;
    input [31:0]a10;
    input [31:0]a11;
    input [31:0]a12;
    input [31:0]a13;
    input [31:0]a14;
    input [31:0]a15;
    input [31:0]a16;
    input [31:0]a17;
    input [31:0]a18;
    input [31:0]a19;
    input [19:0] s;
    input en;
    output reg [31:0] pre;

    always@(*) begin
        if(!en) pre = 0;
        else 
            case(s)
                20'b0000_0000_0000_0000_0001: pre =a0;
                20'b0000_0000_0000_0000_0010: pre =a1;
                20'b0000_0000_0000_0000_0100: pre =a2;
                20'b0000_0000_0000_0000_1000: pre =a3;
                20'b0000_0000_0000_0001_0000: pre =a4;
                20'b0000_0000_0000_0010_0000: pre =a5;
                20'b0000_0000_0000_0100_0000: pre =a6;
                20'b0000_0000_0000_1000_0000: pre =a7;
                20'b0000_0000_0001_0000_0000: pre =a8;
                20'b0000_0000_0010_0000_0000: pre =a9;
                20'b0000_0000_0100_0000_0000: pre =a10;
                20'b0000_0000_1000_0000_0000: pre =a11;
                20'b0000_0001_0000_0000_0000: pre =a12;
                20'b0000_0010_0000_0000_0000: pre =a13;
                20'b0000_0100_0000_0000_0000: pre =a14;
                20'b0000_1000_0000_0000_0000: pre =a15;
                20'b0001_0000_0000_0000_0000: pre =a16;
                20'b0010_0000_0000_0000_0000: pre =a17;
                20'b0100_0000_0000_0000_0000: pre =a18;
                20'b1000_0000_0000_0000_0000: pre =a19;
                default         : pre =0; 
    endcase
    end
endmodule
