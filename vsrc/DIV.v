module DIV(dataA, dataB, clk, rst_n, en, running, quotient, remainder);
    input clk;
    input rst_n;
    input [31:0] dataA;
    input [31:0] dataB;
    input en;
    output running;
    output [31:0] quotient;
    output [31:0] remainder;

    reg running;
    reg [31:0] A;
    reg [31:0] B;
    reg [4:0] count;
    reg [31:0] rmd;
    wire [31:0] sub_out [0:1];
    wire [31:0] mux_out [0:1];
    
    always@(posedge clk)begin
        if(!rst_n)begin
            running <= 0;
            count <= 0;
        end else begin
            if(running) begin
                if(count == 16)begin
                    running <= 0;
                    count <= 0;
                end else begin
                    running <= 1;
                    count <= count + 1;
                end
            end else begin
                if(en) begin
                    running <= 1;
                    count <= 1;
                end else begin  
                    running <= 0;
                    count <= 0;
                end
            end
         end
     end
    
    assign remainder = rmd;
    assign quotient = A;

    always@(posedge clk) begin
        if(!rst_n)
            rmd <= 0;
        else if(!running)
            rmd <= 0;
        else
            rmd <= mux_out[1];
    end

    always@(posedge clk) begin
        if(!rst_n)begin
            A <= 0;
            B <= 0;
        end else if(!running)begin
            A <= dataA;
            B <= dataB;
        end else begin
            A <= {A[29:0], ~sub_out[0][31], ~sub_out[1][31]};
            B <= B;
        end
    end

    adder_32bits adder_32bitsU0(.a({rmd[30:0], A[31]}),
                                .b(~B),
                                .cin(1'b1),
                                .s(sub_out[0]),
                                .cout());

    assign mux_out[0] = sub_out[0][31] ? {rmd[30:0], A[31]} : sub_out[0];

    adder_32bits adder_32bitsU1(.a({mux_out[0][30:0], A[30]}),
                                .b(~B),
                                .cin(1'b1),
                                .s(sub_out[1]),
                                .cout());

    assign mux_out[1] = sub_out[1][31] ? {mux_out[0][30:0], A[30]} : sub_out[1];

endmodule
