`include "define.v"
module MUX6_1(in_pc_plus_4, in_imm, in_div_result, in_mut_result, in_alu_result, in_cache_rdata, gpr_wdata_con, gpr_wdata);
    input [31:0] in_div_result;
    input [31:0] in_mut_result;
    input [31:0] in_pc_plus_4;
    input [31:0] in_imm;
    input [31:0] in_alu_result;
    input [31:0] in_cache_rdata;
    input [2:0] gpr_wdata_con;
    output reg [31:0] gpr_wdata;

    always@(*) begin
        case(gpr_wdata_con) 
            `PC_PLUS_4_GPR_WDATA   :gpr_wdata = in_pc_plus_4;
            `ALU_RESULT_GPR_WDATA  :gpr_wdata = in_alu_result;
            `CACHE_RDATA_GPR_WDATA :gpr_wdata = in_cache_rdata;
            `IMM_GPR_WDATA         :gpr_wdata = in_imm;
            `DIV_RESULT_GPR_WDATA  :gpr_wdata = in_div_result;
            `MUT_RESULT_GPR_WDATA  :gpr_wdata = in_mut_result;
        endcase
    end


endmodule