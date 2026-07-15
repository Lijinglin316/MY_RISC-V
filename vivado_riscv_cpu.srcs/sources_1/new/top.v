

module top(clk, rst_n, en, uart_tx);
    input clk;
    input rst_n;
    input en;
    output uart_tx;
    
    wire [7:0] print;
    wire print_vaild;
    reg [31:0]tick;
    wire empty;
    wire overflow;
    wire ren;
    wire [7:0]FIFO_dout;

    always @(posedge clk) begin
        if(!rst_n)
            tick <= 0;
        else if(!en)
            tick <= tick;
        else 
            tick <= tick + 1;
     end
     
     cpu cpuU0(.clk(clk),
               .rst_n(rst_n),
               .en(en),
               .tick(tick),
               .printf(print),
               .printf_vaild(print_vaild));
               
       FIFO FIFOU0(.rst_n(rst_n),
                .din(print),
                .clk(clk),
                .dout(FIFO_dout),
                .empty(empty),
                .wen(print_vaild),
                .ren(ren),
                .overflow(overflow));
    
    uart uartU0(.clk(clk),
                .din(FIFO_dout),
                .valid(!empty),
                .uart_tx(uart_tx),
                .done(ren));

endmodule
