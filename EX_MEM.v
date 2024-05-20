module EX_MEM(
    input clk, rst, 
    input flush_M, stall_M,
    input [31:0] pc_E,
    input [31:0] pc_branch_E,
    input [31:0] rt_data_E,
    input [63:0] alu_out_E,
    input [31:0] instr_E,
    input [4:0]  wr_reg_E,
    input [4:0]  rd_E,
    input      branch_E,
    input       overflow_E,
    input      flush_pred_failed_E,
    input       is_in_slot_E,
    input       pred_take_E,
    input      actual_take_E,
    input       hilo_to_reg_E,
    input     reg_wr_E, 
    input      mem_wr_E,mem_rd_E, mem_to_reg_E, 
    input       alu_src_E,
    input       is_mfc_E,
    input       break_E, syscall_E, eret_E,
    input       cp0_en_E, cp0_to_reg_E,
    input       ri_E,
    output reg[31:0] pc_M,
    output reg[31:0] pc_branch_M,
    output reg[31:0] rt_data_M,
    output reg[31:0] alu_out_M,
    output reg[31:0] instr_M,
    output reg[4:0]  wr_reg_M,
    output reg[4:0]  rd_M,
    output reg     branch_M,
    output reg      overflow_M,
    output reg      flush_pred_failed_M,
    output reg      is_in_slot_M,
    output reg     pred_take_M,
    output reg     actual_take_M,
    output reg      hilo_to_reg_M,
    output reg      reg_wr_M, 
    output reg      mem_wr_M, mem_rd_M, mem_to_reg_M,
    output reg      is_mfc_M,
    output reg      break_M, syscall_M, eret_M,
    output reg      cp0_en_M, cp0_to_reg_M,
    output reg      ri_M
);
    initial begin
        branch_M  <= 0;
    end
    always @(posedge clk) begin
        if( rst|flush_M)begin
            pc_M           <= 0 ;
            pc_branch_M    <= 0 ;
            rt_data_M      <= 0 ;
            alu_out_M      <= 0 ;
            instr_M        <= 0 ;
            wr_reg_M       <= 0 ;
            flush_pred_failed_M <= 0;
            rd_M           <= 0 ;
            branch_M       <= 0 ;
            overflow_M     <= 0 ;
            is_in_slot_M   <= 0 ;
            pred_take_M    <= 0 ;
            actual_take_M  <= 0 ;
            hilo_to_reg_M  <= 0 ;
            reg_wr_M       <= 0 ;
            mem_wr_M       <= 0 ;
            mem_rd_M       <= 0 ;
            mem_to_reg_M   <= 0 ;
            is_mfc_M       <= 0 ;
            break_M        <= 0 ;
            syscall_M      <= 0 ;
            eret_M         <= 0 ;
            cp0_en_M       <= 0 ;
            cp0_to_reg_M   <= 0 ;
            ri_M           <= 0 ;
        end
        else if(~stall_M)begin
            pc_M           <= pc_E ;
            pc_branch_M    <= pc_branch_E ;
            rt_data_M      <= rt_data_E ;
            alu_out_M      <= alu_out_E[31:0] ;
            instr_M        <= instr_E ;
            wr_reg_M       <= wr_reg_E ;
            rd_M           <= rd_E ;
            branch_M       <= branch_E ;
            overflow_M     <= overflow_E ;
            is_in_slot_M   <= is_in_slot_E ;
            pred_take_M    <= pred_take_E ;
            actual_take_M  <= actual_take_E ;
            hilo_to_reg_M  <= hilo_to_reg_E ;
            flush_pred_failed_M<=flush_pred_failed_E ;
            reg_wr_M       <= reg_wr_E ;
            mem_wr_M       <= mem_wr_E ;
            mem_rd_M       <= mem_rd_E ;
            mem_to_reg_M   <= mem_to_reg_E ;
            is_mfc_M       <= is_mfc_E ;
            break_M        <= break_E ;
            syscall_M      <= syscall_E ;
            eret_M         <= eret_E ;
            cp0_en_M       <= cp0_en_E ;
            cp0_to_reg_M   <= cp0_to_reg_E ;
            ri_M           <= ri_E ; 
        end
    end
endmodule