module hazard(
    input alu_stall_E,  is_jr_D,
    input flush_jump_conflict_E,flush_pred_failed_E, flush_exception_M, flush_pred_failed_M,
    input [4:0] rs_E, rt_E, rt_D,rs_D,
    input       reg_wr_M, reg_wr_W, reg_wr_E,reg_wr_D,
    input [4:0] wr_reg_M, wr_reg_W, wr_reg_E ,
    input mem_to_reg_E,mem_to_reg_M, 
    output stall_F, stall_D, stall_E, stall_M, stall_W,
    output flush_F, flush_D, flush_E, flush_M, flush_W,
    output [1:0] fw_0_E, fw_1_E,
    output [1:0] RAW_JR
);

    assign fw_0_E = (rs_E!=0)&&reg_wr_M&&(wr_reg_M==rs_E)? 2'b01 :  //MEM
                    (rs_E!=0)&&reg_wr_W&&(wr_reg_W==rs_E)? 2'b10 :  //WB
                    2'b00 ;
    assign fw_1_E = reg_wr_M&&(wr_reg_M==rt_E)? 2'b01 : 
                    reg_wr_W&&(wr_reg_W==rt_E)? 2'b10 :
                    2'b00 ;
                    
    wire RAW ;
    assign RAW = ~reg_wr_D&((rt_D == wr_reg_E )|(rs_D == wr_reg_E)) & reg_wr_E & mem_to_reg_E ;
    assign RAW_JR = ((rs_D == wr_reg_E) & reg_wr_E & is_jr_D ) ?  2'b01 :
                    (mem_to_reg_M & (wr_reg_M == rs_E) &is_jr_D ) ? 2'b10 : 2'b00 ;  
    assign stall_F = (~flush_exception_M & alu_stall_E) | RAW ;
    assign stall_D = alu_stall_E | RAW ;
    assign stall_E = alu_stall_E ;
    assign stall_M = 1'b0 ;
    assign stall_W = 1'b0 ;
    assign flush_F = 1'b0 ;
    assign flush_D = flush_exception_M | flush_pred_failed_E | flush_jump_conflict_E ;
    assign flush_E = flush_exception_M | flush_pred_failed_E;
    assign flush_M = flush_exception_M ;
    assign flush_W = 1'b0 ;
endmodule