`include "define.v"
module cpu(clk, rst_n, en, tick, printf , printf_vaild);
    input clk;
    input rst_n;
    input en;
    input [31:0] tick;
    output [7:0] printf;
    output printf_vaild;

    wire [31:0] if_pc;
    wire [31:0] if_npc;
    wire [31:0] if_pc_plus_4;
   // wire [31:0] if_i;
    wire [31:0] id_i;
    wire [31:0] id_pc;
    wire [31:0] id_pc_plus_4;
    wire [2:0] i_type;
    wire id_alu_a_con;
    wire id_alu_b_con;
    wire [3:0] id_alu_op;
    wire id_data_cache_we;
    wire id_gpr_we;
    wire id_b_type;
    wire [1:0] id_jal_type;
    wire [2:0] id_gpr_wdata_con;
    wire [31:0] imm;
    wire [4:0] id_rs1;
    wire [4:0] id_rs2;
    wire [4:0] id_rd;
    wire [31:0] gpr_wdata;//+++++++++++
    wire gpr_we;
    wire [31:0] gpr_out1;
    wire [31:0] gpr_out2;
    wire [31:0] id_dataA;
    wire [31:0] id_dataB;
    wire id_m_extend;
    wire id_div_en;

    wire [31:0]  ex_pc;
    wire [31:0]  ex_pc_plus_4;
    wire [31:0]  ex_dataA;
    wire [31:0]  ex_dataB;
    wire [4:0] ex_rs1;
    wire [4:0] ex_rs2;
    wire [4:0] ex_rd;
    wire [31:0]  ex_imm;
    wire ex_alu_a_con;
    wire ex_alu_b_con;
    wire [3:0] ex_alu_op;
    wire ex_data_cache_we;
    wire ex_gpr_we;
    wire ex_b_type;
    wire [1:0] ex_jal_type;
    wire [2:0] ex_gpr_wdata_con;
    wire [2:0] ex_funct3;
    wire [6:0] ex_op;

    wire [31:0]  ex_dataA_aforward;
    wire [31:0]  ex_dataB_aforward;

    wire [1:0] ex_data_A_con;
    wire [1:0] ex_data_B_con;

    wire [31:0] ex_alu_result;//++++++++++++
    wire ex_m_extend;
    wire ex_div_en;

    wire [31:0] m_forward_data;

    wire [31:0] m_pc_plus_4;
    wire [31:0] m_imm;
    wire [31:0] m_alu_result;
    wire [31:0] m_dataB;
    wire [2:0] m_funct3;
    wire [4:0] m_rd;
    wire m_data_cache_we;
    wire m_gpr_we;
    wire [2:0] m_gpr_wdata_con;
    wire [31:0] m_div_result;
    wire [31:0] m_mut_result;

    wire [31:0] wb_pc_plus_4;
    wire [31:0] wb_imm;
    wire [31:0] wb_alu_result;
    wire [31:0] wb_cache_read_data;
    wire [2:0] wb_gpr_wdata_con;
    wire [4:0] wb_rd;
    wire [31:0] wb_div_result;
    wire [31:0] wb_mut_result;
    
    wire [31:0] alu_dataA;
    wire [31:0] alu_dataB;

    wire s_u0;
    wire s_u1;

    wire [31:0] ex_brench_addr;
    wire if_pre;
    wire [31:0] if_brench_addr;
  
    wire history_pre;
    wire [31:0] pre_npc;
    wire [31:0] adder_out;
    wire rush;
    wire id_l_type;
    wire ex_l_type;
    wire load_use;
    wire [1:0] s;
    wire div_running; 
    wire G_en;

    assign G_en = en & (!div_running);

    assign s_u0 = gpr_we & (id_rs1 == wb_rd) & (id_rs1 != 0);
    assign s_u1 = gpr_we & (id_rs2 == wb_rd) & (id_rs2 != 0);
    assign alu_dataA = ex_alu_a_con ? ex_dataA_aforward : ex_pc;
    assign alu_dataB = ex_alu_b_con ? ex_dataB_aforward : ex_imm;
    assign id_rs1 = id_i[19:15];
    assign id_rs2 = id_i[24:20];
    assign id_rd  = id_i[11:7]; 
    assign if_npc = (s == 2'b00) ? pre_npc : (s == 2'b10 ? ex_brench_addr : ex_pc_plus_4);
    assign ex_brench_addr = (ex_jal_type == `JALR) ? ex_alu_result : adder_out;
    assign load_use = (ex_m_extend) | (ex_l_type & ((ex_rd == id_rs1) | (ex_rd == id_rs2)));

    

     BPU BPUU0(.clk(clk),
              .rst_n(rst_n),
              .ex_b_type(ex_b_type),
              .ex_jal_type(ex_jal_type),
              .ex_funct3(ex_funct3),
              .ex_brench_addr(ex_brench_addr),
              .ex_alu_result(ex_alu_result),
              .if_pc(if_pc),
              .ex_pc(ex_pc),
              .pre(if_pre),
              .brench_addr(if_brench_addr),
              .s(s));

    MUX2_1 MUX2_1U2(.wdata(if_brench_addr),
                    .data(if_pc_plus_4),
                    .s(if_pre),
                    .out_data(pre_npc));

    PC PC_U0(.clk(clk),
             .rst_n(rst_n),
             .en(G_en & (!load_use)),
             .npc(if_npc),
             .pc(if_pc));
            
    adder_32bits adder_32bits_U0(.a(if_pc),
                                 .b(4),
                                 .cin(1'b0),
                                 .s(if_pc_plus_4),
                                 .cout());
                            
    adder_32bits adder_32bits_U1(.a(ex_pc),
                                 .b(ex_imm),
                                 .cin(1'b0),
                                 .s(adder_out),
                                 .cout());

MEM_cpu MEM_INS(.clk(clk), //用于fpga验证
                .en(G_en & (!load_use)), 
                .rst_n(1'b1), 
                .we(1'b0), 
                .tick(0), 
                .funct3(`LW), 
                .addr(if_npc), 
                .din(0), 
                .dout(id_i), 
                .print(), 
                .print_vaild());

/*    `MEM MEM_INS(.clk(clk),//用于仿真测试
                .we(1'b0),
                .en(G_en & (!(load_use))),
                .funct3(`LW),
                .in_addr(if_pc),
                .in_data(0),
                .out_data(id_i),
                .tick(0),
                .printf(),
                .printf_vaild());
*/
    IF_ID IF_ID_U0(.clk(clk),
                   .en(G_en & (!load_use)),
                   .rst_n(rst_n),
                   .in_i(0),
                   .in_pc(if_pc),
                   .in_pc_plus_4(if_pc_plus_4),
                   .out_i(),
                   .out_pc(id_pc),
                   .out_pc_plus_4(id_pc_plus_4));

    CONTROL CONTROL_U0( .op(id_i[6:0]),
                        .funct3(id_i[14:12]),
                        .funct7(id_i[31:25]),
                        .i_type(i_type),
                        .alu_a_con(id_alu_a_con),
                        .alu_b_con(id_alu_b_con),
                        .alu_op(id_alu_op),
                        .data_cache_we(id_data_cache_we),
                        .gpr_we(id_gpr_we),
                        .b_type(id_b_type),
                        .jal_type(id_jal_type),
                        .gpr_wdata_con(id_gpr_wdata_con),
                        .l_type(id_l_type),
                        .div_en(id_div_en),
                        .m_extend(id_m_extend));

    IMM_GEN IMM_GEN_U0( .i(id_i[31:7]),
                        .i_type(i_type),
                        .imm(imm));

    GPR GPR_U0(.clk(clk),
                .rst_n(rst_n),
                .rs1(id_rs1),
                .rs2(id_rs2),
                .rd(wb_rd),
                .wdata(gpr_wdata),
                .wen(gpr_we),
                .data1(gpr_out1),
                .data2(gpr_out2));
            
    MUX2_1 MUX2_1_U0(.data(gpr_out1),
                     .wdata(gpr_wdata),
                     .s(s_u0),
                     .out_data(id_dataA));

    MUX2_1 MUX2_1_U1(.data(gpr_out2),
                     .wdata(gpr_wdata),
                     .s(s_u1),
                     .out_data(id_dataB));

    dff1bits dff1bitsU0(.clk(clk),
            .in(s==0),
            .out(rush));

    ID_EX ID_EX_U0(.clk(clk),
                    .rst_n(rst_n & rush & (s == 0) & (!load_use)), //& rush & (s == 0) & (!load_use)
                    .en(G_en),
                    .in_pc(id_pc),
                    .in_pc_plus_4(id_pc_plus_4),
                    .in_dataA(id_dataA),
                    .in_dataB(id_dataB),
                    .in_rs1(id_rs1),
                    .in_rs2(id_rs2),
                    .in_rd(id_rd),
                    .in_imm(imm),
                    .in_m_extend(id_m_extend),
                    .in_div_en(id_div_en),
                    .in_alu_a_con(id_alu_a_con),
                    .in_alu_b_con(id_alu_b_con),
                    .in_alu_op(id_alu_op),
                    .in_data_cache_we(id_data_cache_we),
                    .in_gpr_we(id_gpr_we),
                    .in_b_type(id_b_type),
                    .in_jal_type(id_jal_type),
                    .in_gpr_wdata_con(id_gpr_wdata_con),
                    .in_funct3(id_i[14:12]),
                    .in_l_type(id_l_type),
                    .in_op(id_i[6:0]),
                    .out_pc(ex_pc),
                    .out_pc_plus_4(ex_pc_plus_4),
                    .out_dataA(ex_dataA),
                    .out_dataB(ex_dataB),
                    .out_rs1(ex_rs1),
                    .out_rs2(ex_rs2),
                    .out_rd(ex_rd),
                    .out_imm(ex_imm),
                    .out_alu_a_con(ex_alu_a_con),
                    .out_alu_b_con(ex_alu_b_con),
                    .out_alu_op(ex_alu_op),
                    .out_data_cache_we(ex_data_cache_we),
                    .out_gpr_we(ex_gpr_we),
                    .out_b_type(ex_b_type),
                    .out_jal_type(ex_jal_type),
                    .out_gpr_wdata_con(ex_gpr_wdata_con),
                    .out_funct3(ex_funct3),
                    .out_l_type(ex_l_type),
                    .out_op(ex_op),
                    .out_m_extend(ex_m_extend),
                    .out_div_en(ex_div_en));
                    
    BW_MUT BW_MUTU0(.clk(clk),
                    .rst_n(rst_n),
                    .en(G_en),
                    .funct3(ex_funct3),
                    .dataA(ex_dataA_aforward),
                    .dataB(ex_dataB_aforward),
                    .dout(m_mut_result));

    DIV_SIGN DIV_SIGN(.clk(clk), 
                      .rst_n(rst_n), 
                      .en(ex_div_en), 
                      .funct3(ex_funct3), 
                      .dataA(ex_dataA_aforward),
                      .dataB(ex_dataB_aforward), 
                      .running(div_running), 
                      .result(m_div_result));


    MUX3_1 MUX3_1_U0(.data(ex_dataA),
                     .m_forward(m_forward_data),
                     .wb_forward(gpr_wdata),
                     .s(ex_data_A_con),
                     .out_data(ex_dataA_aforward));

    MUX3_1 MUX3_1_U1(.data(ex_dataB),
                     .m_forward(m_forward_data),
                     .wb_forward(gpr_wdata),
                     .s(ex_data_B_con),
                     .out_data(ex_dataB_aforward));    

   ALU ALU_U0(.a(alu_dataA),
               .b(alu_dataB),
               .alu_op(ex_alu_op),
               .result(ex_alu_result));

    EX_M EX_M_u0(.clk(clk),
                 .rst_n(rst_n),
                 .en(G_en),
                 .in_pc_plus_4(ex_pc_plus_4),
                 .in_imm(ex_imm),
                 .in_alu_result(ex_alu_result),
                 .in_dataB(ex_dataB_aforward),//ex_dataB
                 .in_funct3(ex_funct3),
                 .in_rd(ex_rd),
                 .in_data_cache_we(ex_data_cache_we),
                 .in_gpr_we(ex_gpr_we),
                 .in_gpr_wdata_con(ex_gpr_wdata_con),
                 .out_pc_plus_4(m_pc_plus_4),
                 .out_imm(m_imm),
                 .out_alu_result(m_alu_result),
                 .out_dataB(m_dataB),
                 .out_funct3(m_funct3),
                 .out_rd(m_rd),
                 .out_data_cache_we(m_data_cache_we),
                 .out_gpr_we(m_gpr_we),
                 .out_gpr_wdata_con(m_gpr_wdata_con));

    MUX6_1 MUX6_1_U0(.in_pc_plus_4(m_pc_plus_4),
                     .in_imm(m_imm),
                     .in_alu_result(m_alu_result),
                     .in_cache_rdata(0),
                     .in_div_result(),
                     .in_mut_result(),
                     .gpr_wdata_con(m_gpr_wdata_con),
                     .gpr_wdata(m_forward_data));

MEM_cpu MEM_DATA(.clk(clk), //用于fpga验证
                .en(G_en), 
                .rst_n(rst_n), 
                .we(ex_data_cache_we), 
                .tick(tick), 
                .funct3(ex_funct3), 
                .addr(ex_alu_result), 
                .din(ex_dataB_aforward), 
                .dout(wb_cache_read_data), 
                .print(printf), 
                .print_vaild(printf_vaild));
/*
   `MEM MEM_DATA(.clk(clk),//用于仿真测试
                 .en(G_en),
                 .we(m_data_cache_we),
                 .funct3(m_funct3),
                 .in_addr(m_alu_result),
                 .in_data(m_dataB),
                 .out_data(wb_cache_read_data),
                 .tick(tick),
                 .printf(printf),
                 .printf_vaild(printf_vaild));
*/
    M_WB M_WB_U0(.clk(clk),
                 .rst_n(rst_n),
                 .en(G_en),
                 .in_pc_plus_4(m_pc_plus_4),
                 .in_imm(m_imm),
                 .in_alu_result(m_alu_result),
                 .in_div_result(m_div_result),
                 .in_mut_result(m_mut_result),
                 .in_cache_read_data(0),
                 .in_gpr_wdata_con(m_gpr_wdata_con),
                 .in_rd(m_rd),
                 .in_gpr_we(m_gpr_we),
                 .out_pc_plus_4(wb_pc_plus_4),
                 .out_div_result(wb_div_result),
                 .out_mut_result(wb_mut_result),
                 .out_imm(wb_imm),
                 .out_alu_result(wb_alu_result),
                 .out_cache_read_data(),
                 .out_gpr_wdata_con(wb_gpr_wdata_con),
                 .out_rd(wb_rd),
                 .out_gpr_we(gpr_we));

    MUX6_1 MUX6_1_U1(.in_pc_plus_4(wb_pc_plus_4),
                     .in_imm(wb_imm),
                     .in_div_result(wb_div_result),
                     .in_mut_result(wb_mut_result),
                     .in_alu_result(wb_alu_result),
                     .in_cache_rdata(wb_cache_read_data),
                     .gpr_wdata_con(wb_gpr_wdata_con),
                     .gpr_wdata(gpr_wdata));

    FORWARDING FORWARDING_U0(.m_gpr_we(m_gpr_we),
                             .m_rd(m_rd),
                             .wb_gpr_we(gpr_we),
                             .wb_rd(wb_rd),
                             .ex_rs1(ex_rs1),
                             .ex_rs2(ex_rs2),
                             .ex_data_A_con(ex_data_A_con),
                             .ex_data_B_con(ex_data_B_con));
                             

endmodule
    

module dff1bits(in, clk, out);
input in;
input clk;
output reg out;

always@(posedge clk) 
  out <= in;
endmodule