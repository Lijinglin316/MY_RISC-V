`include "define.v"
module FORWARDING(m_gpr_we, m_rd, wb_gpr_we, wb_rd, ex_rs1, ex_rs2, ex_data_A_con, ex_data_B_con);
    input m_gpr_we;
    input [4:0] m_rd;
    input wb_gpr_we;
    input [4:0] wb_rd;
    input [4:0] ex_rs1;
    input [4:0] ex_rs2;
    output reg [1:0] ex_data_A_con;
    output reg [1:0] ex_data_B_con;

    wire rs1_forward_m;
    wire rs1_forward_wb;
    wire rs2_forward_m;
    wire rs2_forward_wb;

    assign rs1_forward_m = (m_gpr_we == `WEN) & (ex_rs1 == m_rd) & (ex_rs1 != 0);//转发条件，通过检查gpr写入使能并对比写入地址rd和源地址rs来控制
    assign rs2_forward_m = (m_gpr_we == `WEN) & (ex_rs2 == m_rd) & (ex_rs2 != 0);
    assign rs1_forward_wb = (wb_gpr_we == `WEN) & (ex_rs1 == wb_rd) & (ex_rs1 != 0);
    assign rs2_forward_wb = (wb_gpr_we == `WEN) & (ex_rs2 == wb_rd) & (ex_rs2 != 0);

    always@(*) begin
        if(rs1_forward_m)//dataA的转发控制，只要m阶段转发条件生效，无论wb转发条件是否生效，都转发m的数据，因为如果两者都生效，也应该取最近产生的数据
            ex_data_A_con = `FORWARD_M;
        else if((~rs1_forward_m) & rs1_forward_wb)
            ex_data_A_con = `FORWARD_WB;
        else ex_data_A_con = `UNFORWARD;

        if(rs2_forward_m)//dataB的转发控制，同上
            ex_data_B_con = `FORWARD_M;
        else if((~rs2_forward_m) & rs2_forward_wb)
            ex_data_B_con = `FORWARD_WB;
        else ex_data_B_con = `UNFORWARD;
    end



endmodule