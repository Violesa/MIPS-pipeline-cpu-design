`include "define.v"
module branch_check(
    input [4:0] branch_ctr_E, 
    input  pred_take_E,
    input [31:0] rs_data_E, rt_data_E,
    output reg actual_take_E,
    output     pre_right
);
    always @(*) begin
        case (branch_ctr_E)
        `ALU_EQ:    actual_take_E = (rs_data_E==rt_data_E) ;
        `ALU_NEQ:   actual_take_E = ~(rs_data_E==rt_data_E);
        `ALU_LEZ:   actual_take_E = rs_data_E[31] | (rs_data_E == 32'b0) ;
        `ALU_GTZ:   actual_take_E = ~rs_data_E[31] & ~(rs_data_E== 32'b0) ;
        `ALU_GEZ:   actual_take_E = ~rs_data_E[31] ;
        `ALU_LTZ:   actual_take_E = rs_data_E[31] ;
        default:    actual_take_E = 1'b0 ;
        endcase
    end

    assign pre_right = actual_take_E == pred_take_E ;
endmodule