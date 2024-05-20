module IF_ID(
    input clk, rst, 
    input flush_D, stall_D, jump_stall ,
    input [31:0] pc_F, pc_plus_F, pc_jump_F,
    input [31:0] instr_F,
    input       jump_F ,
    input         F_change,
    input        pred_take_F,
    input        branch_F,
    input        is_jr_F ,
    output reg[31:0] pc_D, pc_plus_D, pc_jump_D,
    output reg[31:0] instr_D,
    output reg      pred_take_D,
    output reg      jump_D,
    output reg         is_jr_D,
    output reg       is_in_slot_D,
    output reg branch_D
);

    always@(posedge clk) begin
        if(rst|flush_D) begin
            pc_D          <=0 ;
            pc_plus_D     <=0 ;
            instr_D       <=0 ;
            is_in_slot_D  <=0 ;
            is_jr_D      <= 0;      
            pred_take_D   <=0 ;
            branch_D     <=0 ;     
            pc_jump_D       <= 0;
            jump_D        <= 0;
        end 
        else if(~stall_D)begin
            pc_D          <= pc_F ;
            pc_plus_D     <= pc_plus_F ;
            instr_D       <= instr_F ;
            pc_jump_D     <= pc_jump_F;
            jump_D        <= jump_F;
            is_in_slot_D  <= F_change ;
            pred_take_D   <= pred_take_F;
            is_jr_D      <= is_jr_F ;
            branch_D      <= branch_F ;
        end
    end

endmodule