`include "define.v"
`timescale 10ns / 10ns
module cpu_tb();
    reg clk;
    reg rst_n;
    reg en;
    reg [31:0] tick;
    wire [31:0] printf;
    wire printf_vaild;

    cpu dut(.clk(clk),
            .rst_n(rst_n),
            .en(en),
            .tick(tick),
            .printf(printf),
            .printf_vaild(printf_vaild));
    
    static string test_name [0:41] = {"rv32ui-p-add.hex",      "rv32ui-p-lb.hex",       "rv32ui-p-slt.hex",
                                    "rv32ui-p-addi.hex",     "rv32ui-p-lbu.hex",      "rv32ui-p-slti.hex",
                                    "rv32ui-p-and.hex",      "rv32ui-p-ld_st.hex",    "rv32ui-p-sltiu.hex",
                                    "rv32ui-p-andi.hex",     "rv32ui-p-lh.hex",       "rv32ui-p-lhu.hex", 
                                    "rv32ui-p-auipc.hex",    "rv32ui-p-lui.hex",      "rv32ui-p-sra.hex",
                                    "rv32ui-p-beq.hex",      "rv32ui-p-lw.hex",       "rv32ui-p-srai.hex",
                                    "rv32ui-p-bge.hex",      "rv32ui-p-ma_data.hex",  "rv32ui-p-srl.hex",
                                    "rv32ui-p-bgeu.hex",     "rv32ui-p-or.hex",       "rv32ui-p-srli.hex",
                                    "rv32ui-p-blt.hex",      "rv32ui-p-ori.hex",      "rv32ui-p-st_ld.hex",
                                    "rv32ui-p-bltu.hex",     "rv32ui-p-sb.hex",       "rv32ui-p-sub.hex",
                                    "rv32ui-p-bne.hex",      "rv32ui-p-sh.hex",       "rv32ui-p-sw.hex",
                                    "rv32ui-p-fence_i.hex",  "rv32ui-p-simple.hex",   "rv32ui-p-xor.hex",
                                    "rv32ui-p-jal.hex",      "rv32ui-p-sll.hex",      "rv32ui-p-xori.hex",
                                    "rv32ui-p-jalr.hex",     "rv32ui-p-slli.hex",       "rv32ui-p-sltu.hex"};
    static string pass_msg = "pass:";
    static string fail_msg = "fail:";
    static int pass_count = 0;
    static int fail_count = 0;
    static int timeout = 0;

    static int count = 0;
    static logic [7:0] c = 0;
    static logic [4:0] rs1 = 0;
    static logic [4:0] rs2 = 0;
    static logic [31:0] imm = 0;
    static logic [6:0] op = 0;
    static logic [2:0] funct3 = 0;
    static logic [3:0] alu_op = 0;
    static logic [31:0] pc = 0;
    static logic [31:0] data1 = 0;
    static logic [31:0] data2 = 0;
    static logic [31:0] func_x = 0;
    static logic [31:0] old_x = 0;

    initial begin
        clk = 1;
        forever #1 clk = ~clk;
    end

    static int trace_file;
    static int a;
    static int b;
    static int e;
    static int d;

/*    initial begin
        trace_file = $fopen("trace.txt", "w");
    end
    static string space;
    always @(posedge clk) begin
        if (dut.rst_n && dut.gpr_we && dut.wb_rd != 5'd0) begin
            if(dut.wb_rd > 9) space = " ";
            else space = "  ";
            $fwrite(trace_file, "0x%08h x%0d%s0x%08h\n", dut.wb_pc_plus_4 - 4, dut.wb_rd, space , dut.gpr_wdata);
        end
    end

    function logic [31:0] gpr_data(input logic [4:0] rd);
        if(op == `LUI) return imm;
        if(op == `AUIPC) return pc + imm;
        if(op == `JAL_OP) return pc + 4;
        if(op == `JALR_OP) return pc + 4;
        if(op == `LOAD) case(funct3)
                            3'b000 : return {{24{dut.MEM_DATA.M_U0.mem[data1 + imm][7]}}, dut.MEM_DATA.M_U0.mem[data1 + imm][7:0]};   
                            3'b001 : return {{16{dut.MEM_DATA.M_U0.mem[data1 + imm][15]}}, dut.MEM_DATA.M_U0.mem[data1 + imm][15:0]};  
                            3'b010 : return dut.MEM_DATA.M_U0.mem[data1 + imm];
                            3'b100 : return {{24{1'b0}}, dut.MEM_DATA.M_U0.mem[data1 + imm][7:0]};   
                            3'b101 : return {{16{1'b0}}, dut.MEM_DATA.M_U0.mem[data1 + imm][15:0]};
                        endcase
        if(op == `IMM_OPERA) case(funct3)
                                3'b000 : return data1 + imm;
                                3'b010 : return (int'(data1) < int'(imm)) ? 1 : 0;
                                3'b011 : return (data1 < imm) ? 1 : 0;
                                3'b100 : return data1 ^ imm;
                                3'b110 : return data1 | imm;
                                3'b111 : return data1 & imm;
                                3'b001 : return data1 << imm[4:0];
                                3'b101 : if(alu_op == `RSHIFT_OP) return data1 >> imm[4:0];
                                         else return data1 >>>imm[4:0];
                            endcase
        if(op == `OPERA) case(funct3)
                            3'b000 : if(alu_op == `ADD_OP) return data1 + data2;
                                     else return data1 - data2;
                            3'b001 : return data1 << data2;
                            3'b010 : return (int'(data1) < int'(data2)) ? 1 : 0;
                            3'b011 : return (data1 < data2) ? 1 : 0;
                            3'b100 : return data1 ^ data2;
                            3'b101 : if(alu_op == `RSHIFT_OP) return data1 >> data2;
                                            else return data1 >>>data2;
                            3'b110 : return data1 | data2;
                            3'b111 : return data1 & data2;
                        endcase

    endfunction

    function void display_gpr_forA();
        $display("gpr_out1 = %32b, gpr_wdata = %32b, s = %b, id_dataA = %32b, gpr_we = %b",
        dut.gpr_out1, dut.gpr_wdata, dut.s_u0, dut.id_dataA, dut.gpr_we);
    endfunction

    function void display_gpr();
        for(int i = 0; i < 3; i++) begin
                $display("|%0d|%0d|%0d|%0d|%0d|%0d|%0d|%0d|", dut.GPR_U0.x[i*8], dut.GPR_U0.x[i*8+1], dut.GPR_U0.x[i*8+2], dut.GPR_U0.x[i*8+3], dut.GPR_U0.x[i*8+4], dut.GPR_U0.x[i*8+5], dut.GPR_U0.x[i*8+6], dut.GPR_U0.x[i*8+7] );
       end
    endfunction

    function void display_dataBforward();
        $display("ex_dataB = %32b, m_forward = %32b, wb_forward = %32b, s = %2b",
        dut.ex_dataB, dut.m_forward_data, dut.gpr_wdata, dut.ex_data_B_con);
    endfunction

    function void display_dataAforward();
        $display("ex_dataA = %32b, m_forward = %32b, wb_forward = %32b, s = %2b, wb_rd%5b, m_rd%5b, ex_rs1%5b",
        dut.ex_dataA, dut.m_forward_data, dut.gpr_wdata, dut.ex_data_A_con, dut.wb_rd, dut.m_rd, dut.ex_rs1);
    endfunction
*/
  /*  function void display_MEM_DATA();
        $display("addr:%32b|indata%32b|out_data_m%32b|outdata%32b|we%b|funct3%3b|",
                    dut.m_alu_result,
                    dut.m_dataB,
                    dut.MEM_DATA.out_data_m,
                    dut.wb_cache_read_data,
                    dut.m_data_cache_we,
                    dut.m_funct3);
    endfunction
*/
    always@(posedge clk) begin
        #1;
  //      if((dut.ex_alu_result == 32'h8000f321)&(dut.ex_data_cache_we))
   //         $display("pc = %b, addr == 32'h8000f321 din = %0h", dut.ex_pc_plus_4 - 4, dut.ex_dataB_aforward);
        count++;
        tick = count;
   /*     
        if(dut.BPUU0.hint) begin//统计分支预测正确率
                b++;
                if(dut.BPUU0.s == 2'b00) e++;
        end
        if(dut.ex_pc == 32'h8000002c) begin
            #60;
            $display("hint: %d\nsuccess of hint: %d", b, e);
            $display("success rate: %d  |  %d", 100*d/a, 100*e/b);
            $stop();
        end
*/
      //  display_pc();
       // $display("in_data %32b, addr %32b, wen %4b, out_data %32b, funct3 %3b",
       //          dut.MEM_DATA.in_data,
       //          dut.MEM_DATA.in_addr, 
       //          dut.MEM_DATA.wen, 
      //           dut.MEM_DATA.out_data_m,
      //          dut.MEM_DATA.funct3);
       // display_dataAforward();
     //  if(dut.ex_pc == 32'h80000ae8) begin
     //   display_alu();
      //  display_MEM_DATA();
    //    display_bht();
    //   end
      //  $display("id_jal%2b, ex_jal%2b, id_i%32b", dut.id_jal_type, dut.ex_jal_type, dut.id_i);
    //    if(dut.ex_pc > 32'h00001140) begin
    //        if(dut.ex_pc < 32'h000011ee) display_pc();
    //    end
        
    //    if(dut.ex_pc == 32'h80000b78) begin
          
      //    $stop();
      //  end
        if(printf_vaild)begin
            c = printf[7:0];
            $write("%s", c);
        end

    end


    function void display_alu();
        $display("alu_dataA = %32b, alu_dataB = %32b, alu_op = %5b, alu_result = %32b",
                dut.alu_dataA,
                dut.alu_dataB,
                dut.ex_alu_op,
                dut.ex_alu_result);
    endfunction

    function void display_pc();
        $display("if_pc = %4h, id_pc = %4h, ex_pc = %4h",
                dut.if_pc,
                dut.id_pc,
                dut.ex_pc);
    endfunction

    function void display_bht();
        for(int i = 0; i < 10; i++) begin
            $display("pc:%32b|addr:%32b|sat_count:%2b|ex_jal%2b|ex_b%b|b_result:%b|miss:%b|pc_we:%b|y:%b|s:%b|success%b|history_brench_addr%32b|ex_brench_addr%32b",
            dut.BPUU0.bht_pc[i],
            dut.BPUU0.bht_addr[i],
            dut.BPUU0.sat_count[i],
            dut.BPUU0.ex_jal_type,
            dut.BPUU0.ex_b_type,
            dut.BPUU0.b_result,
            dut.BPUU0.miss,
            dut.BPUU0.pc_we[i],
            dut.BPUU0.y[i],
            dut.BPUU0.s,
            dut.BPUU0.success,
            dut.BPUU0.history_brench_addr,
            dut.BPUU0.ex_brench_addr);
        end
    endfunction

/*    task testlui();
        #50;
        rst_n = 1;
        $readmemb("luitest.txt", dut.MEM_INS.M_U0.mem);
        #200;
        if(dut.GPR_U0.x[1] == 32'hfffff000) $display("PASS ");
        else $display("FAIL!%32b", dut.GPR_U0.x[1]);
        rst_n = 0;
        #50;
    endtask

    task testauipc();
        rst_n = 0;
        #50;
        rst_n = 1;
        $readmemb("testauipc.txt", dut.MEM_INS.M_U0.mem);
        #200;
        if((dut.GPR_U0.x[1] == 32'h00001010)&(dut.GPR_U0.x[2] == 32'h00001014))
             $display("PASS ");
        else 
            $display("FAIL!%32b|%32b", dut.GPR_U0.x[1], dut.GPR_U0.x[2]);  
       
    endtask
  
    task testadd_b_j();
        rst_n = 0;
        #50;
        rst_n = 1;
        $readmemb("add_b_j.txt", dut.MEM_INS.M_U0.mem);
        #1100;
    

    endtask

    task testload();
        rst_n = 0;
        #50;
        rst_n = 1;
        $readmemb("loadsim.txt", dut.MEM_INS.M_U0.mem);
        #1100;
        $display("m1 = %8h||m2 = %8h||m3 = %8h", dut.MEM_DATA.M_U0.mem[1], dut.MEM_DATA.M_U0.mem[2], dut.MEM_DATA.M_U0.mem[3]);
        endtask

    task rvtest(input int i);
        $readmemh({"rv32hex1/", test_name[i]}, dut.MEM_INS.M_U0.mem);
        $readmemh({"rv32hex1/", test_name[i]}, dut.MEM_DATA.M_U0.mem);
        rst_n = 0;
        en = 1;
        #40;
        rst_n = 1;
        timeout = 0;
        forever begin
            @(posedge clk)
            #1;
            if(++timeout > 10000) begin
                fail_count++;
                fail_msg = {fail_msg, test_name[i], "(timeout), "};
                return;
            end
            if(dut.id_i == 32'h000000073) begin
                #60;
                if(dut.GPR_U0.x[10] == 0)begin
                    pass_count++;
                    pass_msg = {pass_msg, test_name[i], ", " };
                end else begin
                    fail_count++; 
                    fail_msg = {fail_msg, test_name[i], ", "};
                end
                return;
            end
        end
    endtask

task  testall();
      $display("rv32_test begin\n===================================");
        for(int i = 0; i < 42; i++)begin
            $display("%s begining", test_name[i]);
            rvtest(i);
            $display("%s has done", test_name[i]);
        end
        $display("===================================");
        $display("pass_number = %0d\n%s\nfail_namber = %0d\n%s", pass_count, pass_msg, fail_count, fail_msg);
        #40;
        $stop();
endtask 
*/
    initial begin
    //    for (int i = 0; i < 64*1024; i = i + 1) begin
   //         dut.MEM_DATA.M_U0.mem[i] = 8'h0;  // 全部初始化为 0
    //    end
      //testall();
       //$stop();
   
    //   $readmemh("coremark_im_2000.txt", dut.MEM_INS.M_U0.mem);
    //   $readmemh("coremark_im_2000.txt", dut.MEM_DATA.M_U0.mem);
        rst_n = 0;
        en = 1;
        #60;
        rst_n = 1;
        #600;
      //  $fclose(trace_file);
           
    end
   
endmodule
