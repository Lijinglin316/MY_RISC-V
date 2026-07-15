module BW_MUT (clk, rst_n, en, funct3, dataA, dataB, dout);
    input clk;
    input rst_n;
    input en;
    input [2:0] funct3;
    input [31:0] dataA;
    input [31:0] dataB;
    output [31:0] dout;

    reg [32:0] dataA_extend;
    reg [32:0] dataB_extend;

    wire [63:0] out;
    wire [66:0] s0 [0:16];
    wire [16:0] single;
    wire [16:0] double;
    wire [16:0] neg;
    reg output_sel;
    wire sel;
    assign dout = sel ? out[63:32] : out[31:0]; 

    always@(*) begin
        dataA_extend[31:0] = dataA[31:0];
        dataB_extend[31:0] = dataB[31:0];
        case(funct3)
            3'b000 : begin
                dataA_extend[32] = dataA[31] ? 1'b1 : 1'b0;
                dataB_extend[32] = dataB[31] ? 1'b1 : 1'b0;
                output_sel = 0;
            end
            3'b001 : begin
                dataA_extend[32] = dataA[31] ? 1'b1 : 1'b0;
                dataB_extend[32] = dataB[31] ? 1'b1 : 1'b0;
                output_sel= 1;
            end
            3'b010 : begin
                dataA_extend[32] = dataA[31] ? 1'b1 : 1'b0;
                dataB_extend[32] = 1'b0;
                output_sel= 1;
            end
            3'b011 : begin
                dataA_extend[32] = 1'b0;
                dataB_extend[32] = 1'b0;
                output_sel= 1;
            end
            default : begin
                dataA_extend[32] = 1'b0;
                dataB_extend[32] = 1'b0;
                output_sel= 1;
            end
        endcase
    end

    genvar i, j;

    generate
        for(i = 0; i < 17; i = i + 1) begin : gen_booth_encoder
            booth_encoder booth_encoderU(.a((i == 16) ? dataB_extend[32] : dataB_extend[2*i+1]),
                                         .b(dataB_extend[2*i]),
                                         .c((i == 0) ? 1'b0 : dataB_extend[2*i-1]),
                                         .single(single[i]),
                                         .double(double[i]),
                                         .neg(neg[i]));

            booth_selector booth_selectorU(.single(single[i]),
                                           .double(double[i]),
                                           .neg(neg[i]),
                                           .din(dataA_extend),
                                           .dout(s0[i][32+i*2:i*2]));

            assign s0[i][65:33+2*i] = s0[i][32+i*2] ? {65-(32+i*2){1'b1}} : {65-(32+i*2){1'b0}};
        end
        for(i = 0; i < 16; i = i + 1) begin : gen_neg_trans
            assign s0[16][2*i] = neg[i];
            assign s0[16][1+2*i] = 1'b0;
        end
    endgenerate

    wire [64:0] s1 [0:11];
 
    assign s1[10][29:0] = s0[16][29:0];

    ha ha010(.a(s0[15][30]), .b(s0[16][30]), .cin(1'b0), .s(s1[10][30]), .cout(s1[10][31]));

    generate
        for(i = 31; i < 64; i = i + 1) begin : ha016
            ha ha016(.a(s0[15][i]), .b(s0[16][i]), .cin((i == 32) ? neg[16] : 1'b0), .s(s1[11][i]), .cout(s1[10][i+1]));
        end

    endgenerate

    generate
        for(i = 0; i < 5; i = i + 1) begin : ha01
            assign s1[2*i][i*6+1:i*6] = s0[i*3][i*6+1:i*6];
            ha ha01i0(.a(s0[3*i][2+6*i]), .b(s0[3*i+1][2+6*i]), .cin(1'b0), .s(s1[2*i][2+6*i]), .cout(s1[2*i][3+6*i]));
            ha ha01i1(.a(s0[3*i][3+6*i]), .b(s0[3*i+1][3+6*i]), .cin(1'b0), .s(s1[1+2*i][3+6*i]), .cout(s1[2*i][4+6*i]));
            for(j = 4+6*i; j < 64; j = j + 1) begin :ha01j
                ha haj(.a(s0[3*i][j]), .b(s0[3*i+1][j]), .cin(s0[3*i+2][j]), .s(s1[1+2*i][j]), .cout(s1[2*i][j+1]));
            end
        end
    endgenerate

    wire [64:0] s2 [0:7];
    assign s2[6][26:0] = s1[10][26:0];
    ha ha12n(.a(s1[9][27]), .b(s1[10][27]), .cin(1'b0), .s(s2[6][27]), .cout(s2[6][28]));
    generate
        for(i = 28; i < 64; i = i + 1)begin : ha120
            ha ha120(.a(s1[9][i]), .b(s1[10][i]), .cin((i < 31) ? 1'b0 : s1[11][i]), .s(s2[7][i]), .cout(s2[6][i+1]));
        end
    endgenerate

    generate
        for(i = 0; i < 3; i = i + 1) begin : ha12
            assign s2[2*i][i*9+2:i*9] = s1[i*3][i*9+2:i*9];
             ha ha12i0(.a(s1[3*i][3+9*i]), .b(s1[3*i+1][3+9*i]), .cin(1'b0), .s(s2[2*i][3+9*i]), .cout(s2[2*i][4+9*i]));
             ha ha12i1(.a(s1[3*i][4+9*i]), .b(s1[3*i+1][4+9*i]), .cin(1'b0), .s(s2[1+2*i][4+9*i]), .cout(s2[2*i][5+9*i]));
             ha ha12i2(.a(s1[3*i][5+9*i]), .b(s1[3*i+1][5+9*i]), .cin(1'b0), .s(s2[1+2*i][5+9*i]), .cout(s2[2*i][6+9*i]));
            for(j = 6+9*i; j < 64; j = j + 1) begin : ha12j
                ha ha12j(.a(s1[3*i][j]), .b(s1[3*i+1][j]), .cin(s1[3*i+2][j]), .s(s2[1+2*i][j]), .cout(s2[2*i][j+1]));
            end
        end
    endgenerate

    wire [64:0] s3 [0:5];
    assign s3[0][3:0] = s2[0][3:0];
    assign s3[2][17:13] = s2[3][17:13];
    assign s3[4][63:0] = s2[6][63:0];
    assign s3[5][63:28] = s2[7][63:28];

    ha ha230(.a(s2[0][4]), .b(s2[1][4]), .cin(1'b0), .s(s3[0][4]), .cout(s3[0][5]));
    ha ha231(.a(s2[3][18]), .b(s2[4][18]), .cin(1'b0), .s(s3[2][18]), .cout(s3[2][19]));

    generate
        for(i = 5; i < 64; i = i + 1) begin : gen_ha230
            ha ha23(.a(s2[0][i]), .b(s2[1][i]), .cin((i < 9) ? 1'b0 : s2[2][i]), .s(s3[1][i]), .cout(s3[0][i+1]));
        end

        for(i = 19; i < 64; i = i + 1) begin : gen_ha231
            ha ha23(.a(s2[3][i]), .b(s2[4][i]), .cin((i < 22) ? 1'b0 : s2[5][i]), .s(s3[3][i]), .cout(s3[2][i+1]));
        end
    endgenerate

    wire [64:0] s4 [0:3];
    assign s4[0][4:0] = s3[0][4:0];
    assign s4[2][18:0] = s3[4][18:0];
    ha ha340(.a(s3[0][5]), .b(s3[1][5]), .cin(1'b0), .s(s4[0][5]), .cout(s4[0][6]));
    ha ha341(.a(s3[3][19]), .b(s3[4][19]), .cin(1'b0), .s(s4[2][19]), .cout(s4[2][20]));

    generate
        for(i = 6; i < 64; i = i + 1) begin : gen_ha34i0
            ha ha23(.a(s3[0][i]), .b(s3[1][i]), .cin((i < 13) ? 1'b0 : s3[2][i]), .s(s4[1][i]), .cout(s4[0][i+1]));
        end

        for(i = 20; i < 64; i = i + 1) begin : gen_ha34i1
            ha ha23(.a(s3[3][i]), .b(s3[4][i]), .cin((i < 28) ? 1'b0 : s3[5][i]), .s(s4[3][i]), .cout(s4[2][i+1]));
        end
    endgenerate

    wire [64:0] s5 [0:2];
    assign s5[2][63:20] = s4[3][63:20];
    ha ha450(.a(s4[0][0]), .b(s4[2][0]), .cin(1'b0), .s(s5[0][0]), .cout(s5[0][1]));

    generate
        for(i = 1; i < 64; i = i + 1) begin : gen_ha45i0
            ha ha45(.a(s4[0][i]), .b(s4[2][i]), .cin((i < 6) ? 1'b0 : s4[1][i]), .s(s5[1][i]), .cout(s5[0][i+1]));
        end
    endgenerate

    wire [64:0] s6 [0:1];
    assign s6[0][0] = s5[0][0];
    assign s6[1][1:0] = 2'b00;
    ha ha560(.a(s5[0][1]), .b(s5[1][1]), .cin(1'b0), .s(s6[0][1]), .cout(s6[0][2]));


    generate
        for(i = 2; i < 64; i = i + 1) begin : gen_ha56i0
            ha ha56(.a(s5[0][i]), .b(s5[1][i]), .cin((i < 20) ? 1'b0 : s5[2][i]), .s(s6[1][i]), .cout(s6[0][i+1]));
        end
    endgenerate

    wire [63:0]s[0:1];

    dff dffU0(.clk(clk), 
              .din(output_sel), 
              .rst_n(rst_n), 
              .en(en), 
              .dout(sel));

    dff_64 dff_64U0(.clk(clk),
                    .rst_n(rst_n),
                    .en(en),
                    .din(s6[0][63:0]),
                    .dout(s[0]));

    dff_64 dff_64U1(.clk(clk),
                    .rst_n(rst_n),
                    .en(en),
                    .din(s6[1][63:0]),
                    .dout(s[1]));

    wire s_cout;

    adder_32bits adder_32bitsU0(.a(s[0][31:0]),
                              .b(s[1][31:0]),
                              .cin(1'b0),
                              .s(out[31:0]),
                              .cout(s_cout));

    adder_32bits adder_32bitsU1(.a(s[0][63:32]),
                              .b(s[1][63:32]),
                              .cin(s_cout),
                              .s(out[63:32]),
                              .cout());            


endmodule

module booth_encoder (a, b, c, single, double, neg);
    input a;
    input b;
    input c;
    output reg single;
    output reg double;
    output reg neg;
    
    always@(*) begin
        case({a, b, c})
            3'b000 : {single, double, neg} = 3'b000;
            3'b001 : {single, double, neg} = 3'b100; 
            3'b010 : {single, double, neg} = 3'b100; 
            3'b011 : {single, double, neg} = 3'b010; 
            3'b100 : {single, double, neg} = 3'b011; 
            3'b101 : {single, double, neg} = 3'b101; 
            3'b110 : {single, double, neg} = 3'b101;
            3'b111 : {single, double, neg} = 3'b001;
        endcase
    end
endmodule

module booth_selector(single, double, neg, din, dout);
    input single;
    input double;
    input neg;
    input [32:0] din;
    output [32:0] dout;

    wire [32:0] s;

    assign s = ({33{single}} & din) | ({33{double}} & (din << 1));
    assign dout = neg ? (~s) : s;

endmodule

module dff(clk, din, rst_n, en, dout);
    input clk;
    input rst_n;
    input en;
    input din;
    output reg dout;

    always@(posedge clk) begin
        if(rst_n == 0)
            dout <= 0;
        else if(!en)
            dout <= dout;
        else 
            dout <= din;
    end
endmodule


module dff_64(clk, din, rst_n, en, dout);
    input clk;
    input rst_n;
    input en;
    input [63:0] din;
    output reg [63:0] dout;

    always@(posedge clk) begin
        if(rst_n == 0)
            dout <= 0;
        else if(!en)
            dout <= dout;
        else 
            dout <= din;
    end
endmodule

module ha(a, b, cin, s, cout);
    input a;
    input b;
    input cin;
    output s;
    output cout;

    assign s = a ^ b ^ cin;
    assign cout = (a & b) | (a & cin) | (b & cin);

endmodule