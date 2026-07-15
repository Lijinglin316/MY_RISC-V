module adder_32bits(
    input [31:0] a,
    input [31:0] b,
    input cin,
    output [31:0] s,
    output cout);

    wire [8:0] c;

    adder_4bits a0 (a[3:0],  b[3:0],  c[0],s[3:0],  c[1]);
    adder_4bits a1 (a[7:4],  b[7:4],  c[1],s[7:4],  c[2]);
    adder_4bits a2 (a[11:8], b[11:8], c[2],s[11:8], c[3]);
    adder_4bits a3 (a[15:12],b[15:12],c[3],s[15:12],c[4]);
    adder_4bits a4 (a[19:16],b[19:16],c[4],s[19:16],c[5]);
    adder_4bits a5 (a[23:20],b[23:20],c[5],s[23:20],c[6]);
    adder_4bits a6 (a[27:24],b[27:24],c[6],s[27:24],c[7]);
    adder_4bits a7 (a[31:28],b[31:28],c[7],s[31:28],c[8]);

    assign c[0] = cin;
    assign cout = c[8];

endmodule


module adder_4bits(
    input [3:0] a,
    input [3:0] b,
    input cin,
    output [3:0] s,
    output cout);

    wire [3:0] p;
    wire [3:0] g;
    wire [4:0] c;

	assign c[0] = cin;
	assign cout = c[4];

	genvar i;
        generate
	for(i = 0; i<4; i = i + 1)
	begin
		assign p[i] = a[i] ^ b[i];
		assign g[i] = a[i] & b[i];
	end
	endgenerate
	assign c[1] = g[0]|(p[0]&c[0]);
	assign c[2] = g[1]|(p[1]&g[0])|(p[1]&p[0]&c[0]);
	assign c[3] = g[2]|(p[2]&g[1])|(p[2]&p[1]&g[0])|(p[2]&p[1]&p[0]&c[0]);
	assign c[4] = g[3]|(p[3]&g[2])|(p[3]&p[2]&g[1])|(p[3]&p[2]&p[1]&g[0])|(p[3]&p[2]&p[1]&p[0]&c[0]);

	genvar j;
        generate
	for(j = 0; j<4; j = j + 1)
	begin
		assign s[j] = c[j] ^ p[j];
	end
	endgenerate
endmodule

