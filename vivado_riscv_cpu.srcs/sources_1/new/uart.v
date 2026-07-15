module uart(
    clk,
    din,
    valid,
    uart_tx,
    done
    
    );
    output done;
    input clk;
    input valid;
    input [7:0]din;
    output reg uart_tx;
    parameter BAUD = 9600;
    parameter M_CNT = (50000000/BAUD) - 1;
    parameter M_NUM = 12;//BAUD - 1;
    
    reg [15:0]count;
    reg [15:0]NUM;
    reg [7:0]data;
    wire clk_div;
    
    assign done = (count == M_CNT) & (NUM == 9);
    
    always @(posedge clk) begin    //clk分频
        if(!valid) 
            count <= 0;
        else if(count == M_CNT)
            count <= 0;
        else count <= count + 1;
    end
    
    always @(posedge clk) begin  
        if(!valid)
            NUM <= 0;
        else if(count == M_CNT) begin
            if(NUM == M_NUM)
                NUM <= 0;
            else NUM <= NUM + 1;
        end else NUM <= NUM;
    end
    
    always  @(posedge clk) begin   //数据寄存
        if(!valid)
            data <= 0;
        else if((NUM == 0) && (count == M_CNT))
            data <= din;
        else data <= data;
    end
    
   always @(posedge clk) begin
        if(count == M_CNT)
            case(NUM)
                0: uart_tx <= 0;
                1: uart_tx <= data[0];
                2: uart_tx <= data[1];
                3: uart_tx <= data[2];
                4: uart_tx <= data[3];
                5: uart_tx <= data[4];
                6: uart_tx <= data[5];
                7: uart_tx <= data[6];
                8: uart_tx <= data[7];
                9: uart_tx <= 1;
                default : uart_tx <= 1;
            endcase
        else uart_tx <= uart_tx;
    end
    
endmodule