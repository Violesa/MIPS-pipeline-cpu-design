`include "define.v"
module branch_pre(
    input clk, rst,
    input flush_F, stall_F,
    input [31:0] instr_F, imm_F,
    input [31:0] pc_F, pc_M,
    input branch_M,
    input actual_take_M,
    output branch_F,
    output pred_take_F
);
    wire [5:0] op,func;
    wire [4:0] rs, rt ;
    assign op = instr_F[31:26];
    assign func = instr_F[5:0];
    assign rs = instr_F[25:21];
    assign rt = instr_F[20:16];

    wire   branch_F ;
    assign branch_F =((op==`OP_BRANCHS)& (rt[3:1]==3'b000)) //BLTZ BLTZAL BGEZAL BGEZ
                     | (op[5:2]==4'b0001) ;              //beq, bgtz, blez, bne


    reg [3:0] BHT [0:(1<<`BHT_WIDTH)-1] ; 
    reg [1:0] PHT [0:(1<<`PHT_WIDTH)-1] ;

    wire [`BHT_WIDTH-1:0] hash_pc ;
    assign hash_pc = pc_F[11:2] ;           //hash
    wire [`BHT_WIDTH-1:0] BHT_index ;
    assign BHT_index =  hash_pc ;               
    wire [`PHT_WIDTH-1:0] PHT_index ;
    assign PHT_index =  BHT[BHT_index] ;
    
    assign pred_take_F = branch_F & PHT[PHT_index][1] ;  // taken 11/10
    
    wire [`BHT_WIDTH-1:0] BHT_index_up ;
    assign BHT_index_up = hash_pc ^ { 6'b0, PHT_index_up }  ;                   //hash
    wire [`PHT_WIDTH-1:0] PHT_index_up ;
    assign PHT_index_up =  BHT[BHT_index_up] ;
    
    integer  i;

    // BHT maintain
    always @(posedge clk) begin
        if(rst) begin    
            for(i=0;i< (1<<`BHT_WIDTH) ; i++) BHT[i] = 0 ;
        end
        else if(branch_M) begin
            BHT[BHT_index_up] = {BHT[BHT_index_up]<<1 , actual_take_M };
        end
    end

    // PHT maintain
    always @(posedge clk) begin
        if(rst) begin
            for(i=0;i< (1<<`PHT_WIDTH) ; i++) PHT[i] = `WEAKLY_TAKEN ;  //positive
        end
        else begin
            case( PHT[PHT_index_up] )
                `STRONGLY_NOT_TAKEN  :   PHT[PHT_index_up] <= actual_take_M & branch_M ? `WEAKLY_NOT_TAKEN : `STRONGLY_NOT_TAKEN;
                `WEAKLY_NOT_TAKEN    :   PHT[PHT_index_up] <= actual_take_M & branch_M ? `WEAKLY_TAKEN : `STRONGLY_NOT_TAKEN;
                `WEAKLY_TAKEN        :   PHT[PHT_index_up] <= actual_take_M & branch_M ? `STRONGLY_TAKEN : `WEAKLY_NOT_TAKEN;
                `STRONGLY_TAKEN      :   PHT[PHT_index_up] <= actual_take_M & branch_M ? `STRONGLY_TAKEN : `WEAKLY_TAKEN;
            endcase
        end 
    end

endmodule