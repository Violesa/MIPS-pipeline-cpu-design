module ID_EX(
    input clk, rst,
    input stall_E, flush_E,
    input [31:0] pc_D,
    input [31:0] pc_plus_D,
    input [31:0] pc_branch_D,
    input [31:0] imm_D,
    input [31:0] instr_D,
    input [31:0] reg_out_0_D, reg_out_1_D,
    input [4:0]  rs_D, rt_D, rd_D, sa_D,
    input pred_take_D,
    input branch_D,
    input jump_D, jump_conflict_D,
    input is_in_slot_D,
    input [4:0] alu_ctr_D,
    input [4:0] branch_ctr_D,
    input     reg_wr_D, 
    input     mem_wr_D,mem_rd_D, mem_to_reg_D, 
    input [1:0] reg_dst_D,
    input      hilo_wr_D, hilo_to_reg_D,
    input       alu_src_D,
    input       is_mfc_D,  
    input       break_D,  syscall_D, eret_D,
    input       cp0_en_D, cp0_to_reg_D,
    input       ri_D,

    output reg[31:0] pc_E,
    output reg[31:0] pc_plus_E,
    output reg[31:0] pc_branch_E,
    output reg[31:0] imm_E,
    output reg[31:0] instr_E,
    output reg[31:0] reg_out_0_E, reg_out_1_E,
    output reg[4:0]  rs_E, rt_E, rd_E, sa_E,
    output reg pred_take_E,
    output reg branch_E,
    output reg jump_E, jump_conflict_E,
    output reg is_in_slot_E,
    output reg[4:0] alu_ctr_E,
    output reg[4:0] branch_ctr_E,
    output reg    reg_wr_E, 
    output reg   mem_wr_E,mem_rd_E, mem_to_reg_E, 
    output reg[1:0] reg_dst_E,
    output reg     hilo_wr_E, hilo_to_reg_E,
    output reg      alu_src_E,
    output reg      is_mfc_E,
    output reg      break_E, syscall_E, eret_E,
    output reg      cp0_en_E, cp0_to_reg_E,
    output reg     ri_E
);
    always @(posedge clk ) begin
        if(rst | flush_E)begin
            pc_E             <= 0 ;
            pc_plus_E        <= 0 ;
            pc_branch_E      <= 0 ;
            imm_E            <= 0 ;
            instr_E          <= 0 ;
            reg_out_0_E      <= 0 ;
            reg_out_1_E      <= 0 ;
            rs_E             <= 0 ;
            rt_E             <= 0 ;
            rd_E             <= 0 ;
            sa_E             <= 0 ;
            branch_E         <= 0 ;
            jump_E           <= 0 ;
            jump_conflict_E  <= 0 ;
            is_in_slot_E     <= 0 ;
            alu_ctr_E        <= 0 ;
            branch_ctr_E     <= 0 ;
            reg_wr_E         <= 0 ;
            mem_wr_E         <= 0 ;
            mem_rd_E         <= 0 ;
            mem_to_reg_E     <= 0 ;
            reg_dst_E        <= 0 ;
            hilo_wr_E        <= 0 ;
            hilo_to_reg_E    <= 0 ;
            alu_src_E        <= 0 ;
            is_mfc_E         <= 0 ;
            break_E          <= 0 ;
            syscall_E        <= 0 ;
            eret_E           <= 0 ;
            cp0_en_E         <= 0 ;
            cp0_to_reg_E     <= 0 ;
            ri_E             <= 0 ;
            pred_take_E <= 0;
        end
        else if(~stall_E)begin
            pc_E             <= pc_D ;
            pc_plus_E        <= pc_plus_D ;
            pc_branch_E      <= pc_branch_D ;
            imm_E            <= imm_D ;
            instr_E          <= instr_D ;
            reg_out_0_E      <= reg_out_0_D ;
            reg_out_1_E      <= reg_out_1_D ;
            rs_E             <= rs_D ;
            rt_E             <= rt_D ;
            rd_E             <= rd_D ;
            sa_E             <= sa_D ;
            branch_E         <= branch_D ;
            jump_E           <= jump_D ;
            jump_conflict_E  <= jump_conflict_D ;
            is_in_slot_E     <= is_in_slot_D ;
            alu_ctr_E        <= alu_ctr_D ;
            branch_ctr_E     <= branch_ctr_D ;
            reg_wr_E         <= reg_wr_D ;
            mem_wr_E         <= mem_wr_D ;
            mem_rd_E         <= mem_rd_D ;
            mem_to_reg_E     <= mem_to_reg_D ;
            reg_dst_E        <= reg_dst_D ;
            hilo_wr_E        <= hilo_wr_D ;
            hilo_to_reg_E    <= hilo_to_reg_D ;
            alu_src_E        <= alu_src_D ;
            is_mfc_E         <= is_mfc_D ;
            break_E          <= break_D ;
            syscall_E        <= syscall_D ;
            eret_E           <= eret_D ;
            cp0_en_E         <= cp0_en_D ;
            cp0_to_reg_E     <= cp0_to_reg_D ;
            ri_E             <= ri_D  ;
            pred_take_E <= pred_take_D;
        end
    end


endmodule