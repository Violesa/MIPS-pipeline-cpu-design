`include "define.v"
module hilo(
    input clk, rst,
    input we,
    input [31:0] instr_M,
    input [63:0] hilo_in,
    output [31:0] hilo_out,
    output [63:0] hilo_alu 
);
    reg [63:0] hilo ;
    always@(posedge clk)begin
        if(rst) hilo<= 0;
        else if(we) hilo <= hilo_in ;
    end
    assign hilo_alu = hilo ;
    assign hilo_out = ( {32{ (instr_M[31:26]==`OP_R_TYPE)&(instr_M[5:0]==`FUNC_MFHI) }} & hilo[63:32]  )
                    | ( {32{ (instr_M[31:26]==`OP_R_TYPE)&(instr_M[5:0]==`FUNC_MFLO) }} & hilo[31:0]  ) ;
endmodule