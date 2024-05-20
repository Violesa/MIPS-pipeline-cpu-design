`include "define.v"
//  priority : rst
//             ADEL
//             sys
//             bp 
//             ri 
//             ov 
//             tr 
//             ADES
module exception(
    input rst,
    input [5:0] rupt,
    input ri, break, syscall, overflow, eret,
    input lw_error, sw_error, pc_error, 
    input [31:0] cp0_status, cp0_cause, cp0_epc,
    input [31:0] pc_M,
    input [31:0] alu_out_M,

    output [31:0] exception_type,
    output        flush_exception_M,
    output [31:0] pc_exception_M,
    output        pc_trap_M,
    output [31:0] BadVAddr
);
    wire is_rupt ;   //IE               //EXL
    assign is_rupt = cp0_status[0] & ~cp0_status[1] & (//rupt_en & not_kernal
                     ( |(cp0_status[9:8]&cp0_cause[9:8]) ) //soft rupt 
                   | ( |(cp0_status[15:10]& rupt ))        // hard rupt
                   | ( |(cp0_status[30]&cp0_cause[30]))    //time rupt
                   ) ;
        
    assign exception_type = is_rupt               ? `EXC_TYPE_INT  :
                           (lw_error | pc_error)  ? `EXC_TYPE_ADEL :
                            ri                    ? `EXC_TYPE_RI   :
                            syscall               ? `EXC_TYPE_SYS  :
                            break                 ? `EXC_TYPE_BP   :
                            sw_error              ? `EXC_TYPE_ADES :
                            overflow              ? `EXC_TYPE_OV   :
                            eret                  ? `EXC_TYPE_ERET :
                                                    `EXC_TYPE_NOEXC;

    assign flush_exception_M =  ~(exception_type==`EXC_TYPE_NOEXC) ;
    
    assign pc_exception_M = (exception_type == `EXC_TYPE_NOEXC) ? 32'b0 :
                            (exception_type == `EXC_TYPE_ERET)  ? cp0_epc :
                            32'hdead_beef ;

    assign pc_trap_M = ~(exception_type==`EXC_TYPE_NOEXC) ;

    assign BadVAddr = pc_error ? pc_M : alu_out_M ;
                                //ADEL  //ADES
           
endmodule

