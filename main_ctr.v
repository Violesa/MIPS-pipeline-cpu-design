`include "define.v"
module main_ctr(
    input [31:0] instr_D,
    output     reg_wr_D, 
    output     mem_wr_D,mem_rd_D, mem_to_reg_D, 
    output [1:0] reg_dst_D,
    output      is_unsign_D, 
    output      hilo_wr_D, hilo_to_reg_D,
    output       alu_src_D,
    output       is_mfc_D,
    output       break_D, syscall_D, eret_D,
    output       cp0_we_D, cp0_to_reg_D,
    output       ri_D ,
    output [5:0] op , func //debug
);
    //wire 
    wire [4:0] rs, rt;
    wire [5:0] op, func;
    wire is_unsign_D;
    wire hilo_wr_D, hilo_to_reg_D ;
    wire cp0_we_D, cp0_to_reg_D ;
    wire break_D, syscall_D, eret_D;
    wire is_mfc_D;
    assign op = instr_D[31:26];
    assign func = instr_D[5:0];
    assign rs = instr_D [25:21];
    assign rt = instr_D [20:16];
    assign is_unsign_D = (op[5:2] == 4'b0011) ; //andi xori lui ori 
    assign hilo_wr_D = ((op == `OP_R_TYPE) & (func[5:2] == 4'b0110))  //div divu mult multu
                     | (func == `FUNC_MTHI)
                     | (func == `FUNC_MTLO) ;
    assign hilo_to_reg_D = (op == `OP_R_TYPE) & (  (func == `FUNC_MFHI)
                                                 | (func == `FUNC_MFLO) ) ;
    assign cp0_we_D     = (op == `OP_ERET_MFTC) & (rs == `RS_MTC0) ;
    assign cp0_to_reg_D = (op == `OP_ERET_MFTC) & (rs == `RS_MFC0) ;
    assign break_D   = (op == `OP_R_TYPE) & (func == `FUNC_BREAK) ;
    assign syscall_D = (op == `OP_R_TYPE) & (func == `FUNC_SYSCALL) ;
    assign eret_D    = (instr_D == `INSTR_ERET) ;
    assign is_mfc_D = (op == `OP_ERET_MFTC) & (rs == `RS_MFC0) ;
    //reg
    reg ri_D ;                  //exception
    reg reg_wr_D ;
    reg [1:0] reg_dst_D ;
    reg alu_src_D ;
    reg mem_to_reg_D ,mem_rd_D ,mem_wr_D;

    always@(*) begin

        ri_D = 1'b0 ;

        case(op)
            `OP_R_TYPE:
                case(func)
                    `FUNC_JR ,
                    `FUNC_MULT, `FUNC_MULTU, `FUNC_DIV, `FUNC_DIVU, `FUNC_MTHI, `FUNC_MTLO,
                    `FUNC_BREAK, `FUNC_SYSCALL :begin
                        reg_wr_D     = 1'b0 ;
                        reg_dst_D    = 2'b00;
                        alu_src_D    = 1'b0 ;
                        mem_to_reg_D = 1'b0 ;
                        mem_rd_D     = 1'b0 ;
                        mem_wr_D     = 1'b0 ;
                    end
                    `FUNC_ADD, `FUNC_ADDU, `FUNC_SUB, `FUNC_SUBU,
                    `FUNC_SLT, `FUNC_SLTU, 
                    `FUNC_AND, `FUNC_OR, `FUNC_NOR, `FUNC_XOR,
                    `FUNC_SLL, `FUNC_SLLV, `FUNC_SRA, `FUNC_SRAV, `FUNC_SRL, `FUNC_SRLV,
                    `FUNC_MFHI, `FUNC_MFLO :begin
                        reg_wr_D     = 1'b1 ;
                        reg_dst_D    = 2'b00;
                        alu_src_D    = 1'b0 ;
                        mem_to_reg_D = 1'b0 ;
                        mem_rd_D     = 1'b0 ;
                        mem_wr_D     = 1'b0 ;                    
                    end
                    `FUNC_JALR :begin
                        reg_wr_D     = 1'b1 ;
                        reg_dst_D    = 2'b10;   //ra
                        alu_src_D    = 1'b0 ;
                        mem_to_reg_D = 1'b0 ;
                        mem_rd_D     = 1'b0 ;
                        mem_wr_D     = 1'b0 ;
                    end
                    default:begin
                        ri_D = 1'b1 ;
                        reg_wr_D     = 1'b0 ;
                        reg_dst_D    = 2'b00;
                        alu_src_D    = 1'b0 ;
                        mem_to_reg_D = 1'b0 ;
                        mem_rd_D     = 1'b0 ;
                        mem_wr_D     = 1'b0 ;
                    end
                endcase
            //I_TYPE
            `OP_ADDI, `OP_ADDIU, `OP_SLTI, `OP_SLTIU, `OP_ANDI, `OP_LUI, `OP_XORI, `OP_ORI:begin
                reg_wr_D     = 1'b1 ;
                reg_dst_D    = 2'b01;
                alu_src_D    = 1'b1 ;
                mem_to_reg_D = 1'b0 ;
                mem_rd_D     = 1'b0 ;
                mem_wr_D     = 1'b0 ;
            end
            //B
            `OP_BEQ, `OP_BNE, `OP_BLEZ, `OP_BGTZ :begin
                reg_wr_D     = 1'b0 ;
                reg_dst_D    = 2'b00;
                alu_src_D    = 1'b0 ;
                mem_to_reg_D = 1'b0 ;
                mem_rd_D     = 1'b0 ;
                mem_wr_D     = 1'b0 ;
            end
            //branch
            `OP_BRANCHS:
                case(rt)
                    `RT_BGEZAL, `RT_BLTZAL: begin
                        reg_wr_D     = 1'b1 ;
                        reg_dst_D    = 2'b10; //ra
                        alu_src_D    = 1'b0 ;
                        mem_to_reg_D = 1'b0 ;
                        mem_rd_D     = 1'b0 ;
                        mem_wr_D     = 1'b0 ;
                    end
                    `RT_BGEZ, `RT_BLTZ: begin
                        reg_wr_D     = 1'b0 ;
                        reg_dst_D    = 2'b00;
                        alu_src_D    = 1'b0 ;
                        mem_to_reg_D = 1'b0 ;
                        mem_rd_D     = 1'b0 ;
                        mem_wr_D     = 1'b0 ;
                    end
                    default: begin
                        ri_D = 1'b1 ;
                        reg_wr_D     = 1'b0 ;
                        reg_dst_D    = 2'b00;
                        alu_src_D    = 1'b0 ;
                        mem_to_reg_D = 1'b0 ;
                        mem_rd_D     = 1'b0 ;
                        mem_wr_D     = 1'b0 ;
                    end
                endcase
            //LD ST
            `OP_LW, `OP_LB, `OP_LBU, `OP_LH, `OP_LHU: begin
                reg_wr_D     = 1'b1 ;
                reg_dst_D    = 2'b01;
                alu_src_D    = 1'b1 ;
                mem_to_reg_D = 1'b1 ;
                mem_rd_D     = 1'b1 ;
                mem_wr_D     = 1'b0 ;
            end
            `OP_SW, `OP_SB, `OP_SH: begin
                reg_wr_D     = 1'b0 ;
                reg_dst_D    = 2'b00;
                alu_src_D    = 1'b1 ;
                mem_to_reg_D = 1'b0 ;
                mem_rd_D     = 1'b0 ;
                mem_wr_D     = 1'b1 ; 
            end
            //J
            `OP_J: begin
                reg_wr_D     = 1'b0 ;
                reg_dst_D    = 2'b00;
                alu_src_D    = 1'b0 ;
                mem_to_reg_D = 1'b0 ;
                mem_rd_D     = 1'b0 ;
                mem_wr_D     = 1'b0 ;
            end
            `OP_JAL: begin
                reg_wr_D     = 1'b1 ;
                reg_dst_D    = 2'b10;        //ra
                alu_src_D    = 1'b0 ; 
                mem_to_reg_D = 1'b0 ;
                mem_rd_D     = 1'b0 ;
                mem_wr_D     = 1'b0 ; 
            end
            //sudo
            `OP_ERET_MFTC:
                case(rs)
                    `RS_MFC0:begin   
                        reg_wr_D     = 1'b1 ;
                        reg_dst_D    = 2'b01;
                        alu_src_D    = 1'b0 ;
                        mem_to_reg_D = 1'b0 ;
                        mem_rd_D     = 1'b0 ;
                        mem_wr_D     = 1'b0 ;
                    end
                    `RS_MTC0:begin    //CP0[rd] <- GPR[rt]
                        reg_wr_D     = 1'b0 ;
                        reg_dst_D    = 2'b00;
                        alu_src_D    = 1'b0 ;
                        mem_to_reg_D = 1'b0 ;
                        mem_rd_D     = 1'b0 ;
                        mem_wr_D     = 1'b0 ;
                    end
                    default:begin     //eret : PC <- CP0[epc]
                        ri_D = ~(instr_D == `INSTR_ERET) ;
                        reg_wr_D     = 1'b0 ;
                        reg_dst_D    = 2'b00;
                        alu_src_D    = 1'b0 ;
                        mem_to_reg_D = 1'b0 ;
                        mem_rd_D     = 1'b0 ;
                        mem_wr_D     = 1'b0 ;
                    end
                endcase
            default : begin
                ri_D = 1'b1 ;
                reg_wr_D     = 1'b0 ;
                reg_dst_D    = 2'b00;
                alu_src_D    = 1'b0 ;
                mem_to_reg_D = 1'b0 ;
                mem_rd_D     = 1'b0 ;
                mem_wr_D     = 1'b0 ;
            end    
        endcase
    end

endmodule