`include "define.v"
module jump_ctr(
    input [31:0] instr_F,
    input [31:0] pc_plus_F,
    input [31:0] mux_JR_out_D,
    input [4:0]  wr_reg_E, wr_reg_M,
    input reg_wr_E, reg_wr_M,
    input   is_jr_D,
    output jump_F, jump_conflict_D,
    output [31:0] pc_jump_F , 
    output       jump_stall, is_jr
);
    wire [4:0] rs ;
    assign rs = instr_F[25:21] ;
    wire is_jr ;
    assign is_jr = (instr_F[31:26] == `OP_R_TYPE ) & ((instr_F[5:0]==`FUNC_JR) | (instr_F[5:0]==`FUNC_JALR)) ;
    wire is_j ;
    assign is_j = (instr_F[31:26] == `OP_J)|(instr_F[31:26]==`OP_JAL) ;
    assign jump_F = is_jr | is_j ;
    assign jump_conflict_D=1'b0 ;
    wire [31:0] pc_jump_F ;
    wire [31:0] pc_jump_imm_F;
    assign pc_jump_imm_F = { pc_plus_F[31:28],instr_F[25:0],2'b00 } ;
    assign pc_jump_F = is_j ? pc_jump_imm_F : mux_JR_out_D ;
    assign jump_stall = is_jr & ~is_jr_D ;
endmodule