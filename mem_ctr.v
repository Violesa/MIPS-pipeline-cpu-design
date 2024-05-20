`include "define.v"
module mem_ctr(
    input [31:0] instr_M,
    input [31:0] addr,
    input [31:0] mem_wr_tdata_M,
    input [31:0] mem_rd_tdata_M, 
    
    output [3:0]  dm_byte,            // 1111 0011 1100 0001 0010 0100 1000
    output [31:0] mem_wr_data_M,
    output [31:0] mem_rd_data_M,
    output lw_error, sw_error
);
    wire [5:0] op;
    assign op = instr_M[31:26] ;
    
    //rd
    assign mem_rd_data_M = ( {32{op== `OP_LW}} &(mem_rd_tdata_M) )
                         | ( {32{op== `OP_LH }}  & { {16{mem_rd_tdata_M[15]}} ,mem_rd_tdata_M[15:0] })         
                         | ( {32{op== `OP_LHU }} & {  16'b0 ,mem_rd_tdata_M[15:0] } )
                         | ( {32{op== `OP_LB }}  & { {24{mem_rd_tdata_M[7]}} ,mem_rd_tdata_M[7:0] })   
                         | ( {32{op== `OP_LBU }} & { 24'b0  ,mem_rd_tdata_M[7:0] })  ;
    //wr
    assign mem_wr_data_M = ( {32{op== `OP_SW}} & mem_wr_tdata_M  )
                         | ( {32{op== `OP_SH}} & {16'b0 ,mem_wr_tdata_M[15:0]} )
                         | ( {32{op== `OP_SB}} & {24'b0 ,mem_wr_tdata_M[7:0] } ) ;

    assign dm_byte   = ( {4{op== `OP_SW & addr[1:0]==2'b00 }} & 4'b1111 )
                     | ( {4{op== `OP_SH & (addr[1:0]==2'b10 | addr[1:0]==2'b00) }} & 4'b0011 )
                     | ( {4{op== `OP_SB  }} & 4'b0001 ) ;

    //exc
    assign lw_error  = ((op== `OP_LW) & ~(addr[1:0]==2'b00))
                     | ((op== `OP_LH) & ~((addr[1:0]==2'b00)|(addr[1:0]==2'b10))) ; 
    assign sw_error  = ((op== `OP_SW) & ~(addr[1:0]==2'b00))
                     | ((op== `OP_SH) & ~((addr[1:0]==2'b00)|(addr[1:0]==2'b10))) ; 


endmodule