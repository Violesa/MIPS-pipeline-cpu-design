module pc(
    input clk, rst,
    input stall_F,
    input branch_F, branch_E,
    input pre_right,
    input actual_take_E,
    input pred_take_F,
    input pc_trap_M,
    input jump_F, jump_stall,
    input jump_conflict_D, jump_conflict_E,
    input [31:0] pc_exception_M,
    input [31:0] pc_plus_E,    // 1 0
    input [31:0] pc_branch_E, //  0 1
    input [31:0] pc_jump_F, pc_jump_E, //D conflict ,E not
    input [31:0] pc_branch_F,
    input [31:0] pc_plus_F,
    output reg [31:0] pc_F 
);
   
    wire [31:0] pc_next;
    reg  [2:0]  mux;
    // 000 error 

    // 001 expected but not
    // 010 not expected but jump

    // 011 jump conflict
    // 100 jump not conflict
    // 101 branch
    // 110 ++

    // 111 ?
    assign pc_next = mux[2] ? (mux[1]?( mux[0]? 32'hdeadbeef: pc_plus_F ) :
                                      ( mux[0]? pc_branch_F : pc_jump_F ) ) :
                              (mux[1]?( mux[0]? pc_jump_E   : pc_branch_E) :
                                      ( mux[0]? pc_plus_E   : pc_exception_M ) ) ;

    always@(posedge clk or posedge rst) begin
            if(rst)           pc_F <= 32'h0000_3000 ;
            else if(~stall_F & ~jump_stall) pc_F <= pc_next ;
            else              pc_F <= pc_F ;
        
    end

    always @(*) begin
        if(pc_trap_M)
            mux <= 3'b000 ; 
        else if(branch_E & ~pre_right & ~actual_take_E )
            mux <= 3'b001 ;
        else if(branch_E & ~pre_right & actual_take_E )
            mux <= 3'b010 ;
        else if(jump_conflict_D)
            mux <= 3'b011;
        else if(jump_F & ~jump_conflict_D)
            mux <= 3'b100;
        else if(branch_F & ~branch_E & pred_take_F || branch_F & branch_E & pre_right & pred_take_F) 
            mux <= 3'b101;
        else 
            mux <= 3'b110;       
    end
endmodule 
