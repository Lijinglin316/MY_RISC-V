`define MEM       MEM1      //设置存储器MEM，或MEM1
`define ADD_OP            4'b0001
`define SUB_OP            4'b0010
`define COMPARE_OP        4'b0011
`define UNSIGN_COMPARE_OP 4'b1011
`define EQ_OP             4'b0100
`define LSHIFT_OP         4'b0101
`define RSHIFT_OP         4'b0110
`define A_RSHIFT_OP       4'b0111
`define AND_OP            4'b1000
`define OR_OP             4'b1001
`define XOR_OP            4'b1010

`define MUL     3'b000
`define MULH    3'b001
`define MULHSU  3'b010
`define MULHU   3'b011
`define DIV     3'b100
`define DIVU    3'b101
`define REM     3'b110
`define REMU    3'b111

`define OPERA         7'b0110011
`define IMM_OPERA     7'b0010011
`define STORE         7'b0100011
`define LOAD          7'b0000011
`define BRANCH        7'b1100011
`define JALR_OP       7'b1100111
`define JAL_OP        7'b1101111
`define AUIPC         7'b0010111
`define LUI           7'b0110111

`define R_TYPE 3'b001
`define I_TYPE 3'b010
`define S_TYPE 3'b011
`define B_TYPE 3'b100
`define U_TYPE 3'b101
`define J_TYPE 3'b110

`define NO_J_TYPE 2'b00
`define JAL       2'b01
`define JALR	  2'b10

`define NO_B_TYPE 1'b0


`define PC_PLUS_4_GPR_WDATA   3'b001
`define ALU_RESULT_GPR_WDATA  3'b010
`define CACHE_RDATA_GPR_WDATA 3'b011
`define IMM_GPR_WDATA         3'b000
`define DIV_RESULT_GPR_WDATA  3'b100
`define MUT_RESULT_GPR_WDATA  3'b101

`define PC_A     1'b0
`define DATA_A_A 1'b1

`define DATA_B_B 1'b1
`define IMM_B    1'b0

`define WEN   1'b1
`define UNWEN 1'b0
`define EN    1'b1
`define UNEN  1'b0

`define SHIFTER_L  2'b00
`define SHIFTER_R  2'b01
`define SHIFTER_AR 2'b10

`define A_TO_XOR 1'b0
`define SUBEN_TO_XOR 1'b1

`define ALU_ADD_OR_SUB_RESULT  3'b000
`define ALU_LESS_RESULT        3'b001
`define ALU_LESS_UNSIGN_RESULT 3'b010
`define ALU_EQ_RESULT          3'b011
`define ALU_AND_RESULT         3'b100
`define ALU_OR_RESULT          3'b101
`define ALU_XOR_RESULT         3'b110
`define ALU_SHIFT_RESULT       3'b111

`define LW  3'b010
`define LH  3'b001
`define LB  3'b000
`define LHU 3'b101
`define LBU 3'b100
`define SB  3'b000
`define SH  3'b001
`define SW  3'b010

`define UNFORWARD  2'b00
`define FORWARD_M  2'b01
`define FORWARD_WB 2'b10

`define JUMP 1'b1
`define NO_JUMP 1'b0