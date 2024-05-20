`include "define.v"
`include "divider.v"
`include "multiplier_reg.v"
module alu(
    input clk, rst, flush_E,
    input [31:0] A, B,
    input [4:0] alu_ctr_E,
    input [4:0] sa,             // shift 
    input [63:0] hilo,
    output reg alu_stall_E,
    output [63:0] alu_out_E,
    output overflow_E
);
    wire mthilo = (alu_ctr_E == `ALU_MTHI)|(alu_ctr_E == `ALU_MTLO);
    assign alu_out_E = ( {64{div_en}}  & div_out  )
                     | ( {64{mult_en}} & mult_out )
                     | ( {64{~div_en & ~mult_en &~mthilo }} & {32'b0 , alu_not_md} )
                     | ( {64{alu_ctr_E == `ALU_MTHI}} & {A , hilo[31:0]})
                     | ( {64{alu_ctr_E == `ALU_MTLO}} & {hilo[63:32] ,B} ) ;
    // mult div
    wire is_unsign;
    assign is_unsign=(alu_ctr_E==`ALU_UNSIGNED_DIV)|(alu_ctr_E==`ALU_UNSIGNED_MULT);

    wire [63:0] div_out ;
    wire div_busy ;
    wire div_en ;
    assign div_en= (alu_ctr_E==`ALU_SIGNED_DIV)|(alu_ctr_E==`ALU_UNSIGNED_DIV) ;
    reg div_ready ;
    initial div_ready <= 0;
    always @(negedge div_busy) begin
        div_ready <= 1;
    end
    always @(posedge clk) begin
        if(div_ready==1)
            div_ready <= 0;
    end
    divider u_divider(
        .clk       ( clk       ),
        .rst       ( rst       ),
        .div_ready (div_ready),
        .flush     ( flush_E     ),
        .div_en    ( div_en    ),
        .div_A     ( A     ),
        .div_B     ( B     ),
        .is_unsign ( is_unsign ),
        .div_busy  ( div_busy  ),
        .div_out   ( div_out   )
    );


    wire [63:0] mult_out ;
    wire mult_busy ;
    wire mult_en ;
    assign mult_en= (((alu_ctr_E==`ALU_SIGNED_MULT)|(alu_ctr_E==`ALU_UNSIGNED_MULT))) ;
    reg mult_ready ;
    initial mult_ready <= 0;
    always @(negedge mult_busy) begin
        mult_ready <= 1;
    end
    always @(posedge clk) begin
        if(mult_ready==1)
            mult_ready <= 0;
    end
    multiplier_reg u_multiplier_reg(
        .clk       ( clk       ),
        .rst       ( rst       ),
        .mult_ready(mult_ready),
        .flush     ( flush_E     ),
        .mult_en   ( mult_en   ),
        .mult_A    ( A    ),
        .mult_B    ( B    ),
        .is_unsign ( is_unsign ),
        .mult_busy ( mult_busy ),
        .mult_out  ( mult_out  )
    );

    initial alu_stall_E <= 0 ;
    always @(posedge mult_en or posedge div_en ) begin
        alu_stall_E <= 1 ;    
    end
    always @(negedge mult_busy or negedge div_busy) begin
        alu_stall_E <= 0 ;
    end
    //
    reg [31:0] alu_not_md ;
    reg carry ;
    assign overflow_E = (alu_ctr_E == `ALU_ADD | alu_ctr_E == `ALU_SUB) & (carry ^ alu_not_md[31]);
    always @(*) begin
        carry = 0 ;            
        case (alu_ctr_E)
            //algori
            `ALU_ADD:  {carry , alu_not_md } <= {A[31],A} + {B[31],B} ;     //signed ext
            `ALU_SUB:  {carry , alu_not_md } <= {A[31],A} + (~{B[31],B} + 1 ) ;
            `ALU_ADDU:          alu_not_md   <= A + B  ;         
            `ALU_SUBU:          alu_not_md   <= A + (~B + 1 ) ;
             
             //logic
            `ALU_AND:           alu_not_md   <= A & B  ;     
            `ALU_OR:            alu_not_md   <= A | B  ;     
            `ALU_XOR:           alu_not_md   <= A ^ B  ;     
            `ALU_NOR:           alu_not_md   <= ~(A | B)  ;     
             //shift
            `ALU_SLL:           alu_not_md   <= B << sa  ;     
            `ALU_SRL:           alu_not_md   <= B >> sa  ;     
            `ALU_SRA:           alu_not_md   <= $signed(B) >>> sa  ;  
            `ALU_SLLV:          alu_not_md   <= B << A[4:0] ;        
            `ALU_SRLV:          alu_not_md   <= B >> A[4:0] ;     
            `ALU_SRAV:          alu_not_md   <= $signed(B) >>> A[4:0] ;     
            //comp
            `ALU_SLT:           alu_not_md   <= $signed(A) < $signed(B) ;     
            `ALU_SLTU:          alu_not_md   <= A < B  ;
            //LD
            `ALU_LUI:           alu_not_md   <= {B[15:0],16'b0}  ;  
            `ALU_DONOTHING:      alu_not_md   <= A  ;            
            default:            alu_not_md   <= 32'hdead_beef  ;     
        endcase
    end




endmodule