`include "define.v" 

module alu_decode(
    input [31:0] instr_D,
    output reg [4:0] alu_ctr_D,
    output reg [4:0] branch_ctr_D
);

    wire [4:0] rs, rt;
    wire [5:0] op, func;
    assign op = instr_D[31:26];
    assign func = instr_D[5:0];
    assign rs = instr_D [25:21];
    assign rt = instr_D [20:16];
    always @(*) begin
        case(op)
            `OP_R_TYPE:
                case(func)
                    `FUNC_ADD:    alu_ctr_D = `ALU_ADD ;
                    `FUNC_ADDU:    alu_ctr_D = `ALU_ADDU;
                    `FUNC_SUB:    alu_ctr_D = `ALU_SUB ;
                    `FUNC_SUBU:    alu_ctr_D =  `ALU_SUBU;
                    `FUNC_SLT:    alu_ctr_D = `ALU_SLT ;  
                    `FUNC_SLTU:    alu_ctr_D  = `ALU_SLTU ;

                    `FUNC_AND:    alu_ctr_D = `ALU_AND ;
                    `FUNC_OR:       alu_ctr_D = `ALU_OR ;
                    `FUNC_XOR:     alu_ctr_D = `ALU_XOR ;
                    `FUNC_NOR:     alu_ctr_D = `ALU_NOR ;
             
					`FUNC_DIV:   	alu_ctr_D = `ALU_SIGNED_DIV;
					`FUNC_DIVU:  	alu_ctr_D = `ALU_UNSIGNED_DIV;
					`FUNC_MULT:  	alu_ctr_D = `ALU_SIGNED_MULT;
					`FUNC_MULTU: 	alu_ctr_D = `ALU_UNSIGNED_MULT;

				
					`FUNC_SLL:   	alu_ctr_D = `ALU_SLL;	
					`FUNC_SRL:   	alu_ctr_D = `ALU_SRL;
					`FUNC_SRA:   	alu_ctr_D = `ALU_SRA;
					`FUNC_SLLV:  	alu_ctr_D = `ALU_SLLV;
					`FUNC_SRLV:  	alu_ctr_D = `ALU_SRLV;
					`FUNC_SRAV:  	alu_ctr_D = `ALU_SRAV;

					
					`FUNC_MTHI:  	alu_ctr_D = `ALU_MTHI;
					`FUNC_MTLO:  	alu_ctr_D = `ALU_MTLO;
					default:    	alu_ctr_D = `ALU_DONOTHING;
                endcase
            `OP_ADDI: 	alu_ctr_D  = `ALU_ADD;
			`OP_ADDIU:  alu_ctr_D  = `ALU_ADDU;
			`OP_SLTI: 	alu_ctr_D  = `ALU_SLT;
			`OP_SLTIU:  alu_ctr_D  = `ALU_SLTU;
			`OP_ANDI: 	alu_ctr_D  = `ALU_AND;
			`OP_XORI:   alu_ctr_D  = `ALU_XOR;
			`OP_LUI: 	alu_ctr_D  = `ALU_LUI;
			`OP_ORI:    alu_ctr_D  = `ALU_OR;
			//memory    
            `OP_LW, `OP_SW, `OP_LB, `OP_LBU, `OP_SB, `OP_LH, `OP_LHU, `OP_SH :
                        alu_ctr_D = `ALU_ADDU ;
            default :   alu_ctr_D =  `ALU_DONOTHING ;
        endcase
    end
    
    always @(*) begin
        case(op)
            `OP_BEQ: branch_ctr_D = `ALU_EQ;
            `OP_BNE: branch_ctr_D = `ALU_NEQ;
            `OP_BLEZ:branch_ctr_D = `ALU_LEZ;
            `OP_BGTZ:branch_ctr_D = `ALU_GTZ; 
            `OP_BRANCHS: 
                case(rt)
                    `RT_BLTZ, `RT_BLTZAL:  branch_ctr_D =  `ALU_LTZ ;
                    `RT_BGEZ, `RT_BGEZAL:  branch_ctr_D =  `ALU_GEZ ;
                    default:               branch_ctr_D =  `ALU_DONOTHING ;
                endcase
            default: branch_ctr_D = `ALU_DONOTHING;
        endcase
    end

endmodule


