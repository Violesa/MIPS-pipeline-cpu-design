//IM
`define IM_EN  1'b1
`define IM_DIS 1'b0  

`define OP_R_TYPE      6'b000000
//逻辑
`define OP_NOP			6'b000000
`define FUNC_AND 		6'b100100
`define FUNC_OR 		6'b100101
`define FUNC_XOR 		6'b100110
`define FUNC_NOR		6'b100111
`define OP_ANDI		    6'b001100
`define OP_ORI			6'b001101
`define OP_XORI		    6'b001110
`define OP_LUI			6'b001111
//位移
`define FUNC_SLL		6'b000000
`define FUNC_SLLV		6'b000100
`define FUNC_SRL 		6'b000010
`define FUNC_SRLV 		6'b000110
`define FUNC_SRA 		6'b000011
`define FUNC_SRAV 		6'b000111
//move inst
`define FUNC_MFHI  		6'b010000
`define FUNC_MTHI  		6'b010001
`define FUNC_MFLO  		6'b010010
`define FUNC_MTLO  		6'b010011
//算术运算0010
`define FUNC_SLT     6'b101010
`define FUNC_SLTU    6'b101011
`define OP_SLTI    6'b001010
`define OP_SLTIU   6'b001011   
`define FUNC_ADD     6'b100000
`define FUNC_ADDU    6'b100001
`define FUNC_SUB     6'b100010
`define FUNC_SUBU    6'b100011
`define OP_ADDI    6'b001000
`define OP_ADDIU   6'b001001

`define FUNC_MULT    6'b011000
`define FUNC_MULTU   6'b011001

`define FUNC_DIV  6'b011010
`define FUNC_DIVU  6'b011011

`define EXE_EQUAL 6'b111111   //??
//jump
`define OP_J  6'b000010
`define OP_JAL  6'b000011
`define FUNC_JALR  6'b001001
`define FUNC_JR  6'b001000
//branch
`define OP_BEQ  6'b000100
`define OP_BGTZ  6'b000111
`define OP_BNE  6'b000101
`define OP_BLEZ  6'b000110
`define OP_BRANCHS 6'b000001   
`define RT_BLTZ  5'b00000
`define RT_BLTZAL  5'b10000   
`define RT_BGEZAL  5'b10001    
`define RT_BGEZ  5'b00001
//load/store
`define OP_LB  6'b100000
`define OP_LBU  6'b100100
`define OP_LH  6'b100001
`define OP_LHU  6'b100101
`define EXE_LL  6'b110000         //??
`define OP_LW  6'b100011
`define EXE_LWL  6'b100010
`define EXE_LWR  6'b100110
`define OP_SB  6'b101000
`define EXE_SC  6'b111000
`define OP_SH  6'b101001
`define OP_SW  6'b101011
`define EXE_SWL  6'b101010
`define EXE_SWR  6'b101110

//trap
`define FUNC_SYSCALL 6'b001100
`define FUNC_BREAK 6'b001101

`define EXE_TEQ 6'b110100
`define EXE_TEQI 5'b01100
`define EXE_TGE 6'b110000
`define EXE_TGEI 5'b01000
`define EXE_TGEIU 5'b01001
`define EXE_TGEU 6'b110001
`define EXE_TLT 6'b110010
`define EXE_TLTI 5'b01010
`define EXE_TLTIU 5'b01011
`define EXE_TLTU 6'b110011
`define EXE_TNE 6'b110110
`define EXE_TNEI 5'b01110
   
//Exception Return
// `define EXE_ERET 32'b01000010000000000000000000011000
`define INSTR_ERET 32'b01000010000000000000000000011000   
`define OP_ERET_MFTC 6'b010000    //MF MT C0

`define EXE_SYNC 6'b001111
`define EXE_PREF 6'b110011

`define RS_MTC0 5'b00100
`define RS_MFC0 5'b00000

//Exception code
`define EXC_CODE_INT        5'h00     
`define EXC_CODE_ADEL       5'h04     
`define EXC_CODE_ADES       5'h05     
`define EXC_CODE_SYS        5'h08     
`define EXC_CODE_BP         5'h09     
`define EXC_CODE_RI         5'h0a     
`define EXC_CODE_OV         5'h0c     

//Exception type
`define EXC_TYPE_INT        32'h0000_0001  
`define EXC_TYPE_ADEL       32'h0000_0004  
`define EXC_TYPE_ADES       32'h0000_0005  
`define EXC_TYPE_SYS        32'h0000_0008  
`define EXC_TYPE_BP         32'h0000_0009  
`define EXC_TYPE_RI         32'h0000_000a  
`define EXC_TYPE_OV         32'h0000_000c  
`define EXC_TYPE_ERET       32'h0000_000e  
`define EXC_TYPE_NOEXC      32'h0000_0000

//CP0
`define CP0_REG_BADVADDR    5'b01000       
`define CP0_REG_COUNT    5'b01001       
`define CP0_REG_COMPARE    5'b01011     
`define CP0_REG_STATUS    5'b01100      
`define CP0_REG_CAUSE    5'b01101       
`define CP0_REG_EPC    5'b01110         
`define CP0_REG_PRID    5'b01111        
`define CP0_REG_CONFIG    5'b10000      

//alu defines
`define ALU_AND             5'b0_0000     //
`define ALU_OR              5'b0_0001     //
`define ALU_ADD             5'b0_0010     // 
`define ALU_SUB             5'b0_0011     //
`define ALU_SLT             5'b0_0100       //
`define ALU_SLLV            5'b0_0101    //
`define ALU_SRLV            5'b0_0110    // 
`define ALU_SRAV            5'b0_0111    //
`define ALU_SLTU            5'b0_1000       //
`define ALU_NOR             5'b0_1001     // 
`define ALU_XOR             5'b0_1010     //
`define ALU_UNSIGNED_MULT   5'b0_1011     //
`define ALU_UNSIGNED_DIV    5'b0_1100     //
`define ALU_SIGNED_MULT     5'b0_1101     //
`define ALU_SIGNED_DIV      5'b0_1110     //
`define ALU_LUI             5'b0_1111       //
`define ALU_ADDU            5'b1_0000     //
`define ALU_SUBU            5'b1_0001     //
`define ALU_LEZ             5'b1_0010       //
`define ALU_GTZ             5'b1_0011       //
`define ALU_GEZ             5'b1_0100       //
`define ALU_LTZ             5'b1_0101    //
`define ALU_SLL             5'b1_0110     //
`define ALU_SRL             5'b1_0111     //
`define ALU_SRA             5'b1_1000     //
`define ALU_EQ              5'b1_1001       //
`define ALU_NEQ             5'b1_1010       //
`define ALU_MTHI            5'b1_1011
`define ALU_MTLO            5'b1_1100
`define ALU_EQUAL           5'b1_1101
                            // 5'b1_1110
`define ALU_DONOTHING       5'b1_1111


//branch_pre
`define BHT_WIDTH 10
`define PHT_WIDTH 4
`define STRONGLY_NOT_TAKEN 2'b00
`define WEAKLY_NOT_TAKEN   2'b01
`define WEAKLY_TAKEN       2'b10
`define STRONGLY_TAKEN     2'b11