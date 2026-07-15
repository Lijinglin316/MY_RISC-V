module FIFO(rst_n,din, clk, dout, empty, wen, ren, overflow);
    input [7:0]din;
    input rst_n;
    output [7:0]dout;
    input clk;
    output empty;
    input wen;
    input ren;
    output overflow;
    
    reg [9:0]w_p;
    reg [9:0]r_p;
    
    assign empty = (w_p == r_p);
    assign overflow = (w_p == (w_p - 1));
    
    always @(posedge clk)begin
        if(!rst_n)
            w_p <= 0;
        else if(wen)
            w_p <= w_p + 1;
        else
            w_p <= w_p;
    end
    
    always @(posedge clk)begin
        if(!rst_n)
            r_p <= 0;
        else if(ren)
            r_p <= r_p + 1;
        else
            r_p <= r_p;
    end
   
    blk_mem_gen_0 FIFOromU0 (
         .clka(clk),    // input wire clka
         .wea(wen),      // input wire [0 : 0] wea
         .addra(w_p),  // input wire [9 : 0] addra
         .dina(din),    // input wire [7 : 0] dina
         .clkb(clk),    // input wire clkb
         .addrb(r_p),  // input wire [9 : 0] addrb
         .doutb(dout)  // output wire [7 : 0] doutb
        );
         
      

endmodule 