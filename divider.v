module divider(
    input clk, rst,  div_ready,
    input flush, div_en,
    input [31:0] div_A, div_B,
    input is_unsign,
    output div_busy,
    output [63:0] div_out
);
    //debug
    // wire [31:0] debug_A,debug_B;
    // wire [31:0] debug_quo,debug_rem;
    // assign debug_A = div_A ;
    // assign debug_B = div_B ;
    // assign debug_quo = debug_A/debug_B;
    // assign debug_rem = debug_A%debug_B;
    //
    wire [31:0] a,b ;
    assign a = div_A ;
    assign b = div_B ;
    reg    a_save , b_save ;
    
    reg [63:0] SR ;
    wire [31:0] SR_rem , SR_quo ;
    assign SR_rem = SR[63:32] ; 
    assign SR_quo = SR[31:0]  ;
    wire [31:0] a_abs ;
    wire [32:0] sub_ient ;
    assign a_abs    = ( ~is_unsign & a[31]) ? ( ~a + 1 ) : a ;
    assign sub_ient = ( ~is_unsign & b[31]) ? {1'b1,b} : ~{1'b0,b}+1 ;  // signed ext
   
    // sign 1' data 32'
    wire prs ;   
    wire [32:0] sub_res  ;
    assign {prs,sub_res} =  {1'b0,SR_rem} + sub_ient ;  // mimic
    wire [32:0] rem_next ;                  
    assign rem_next = prs ? sub_res : {1'b0 , SR_rem } ;    
    //32
    reg [5:0] cnt;
    reg is_start ;
    always @(posedge clk ) begin
        if(flush | rst)begin
            cnt <= 0;
            is_start <= 0;
        end
        else if(div_en)begin
            if(~is_start&~div_ready)begin
                is_start <= 1 ;
                cnt      <= 1 ;
                a_save   <= a[31] ;
                b_save   <= b[31] ;
                SR       <= {31'b0, a_abs , 1'b0} ;
            end
            else begin
                if(cnt[5]==1'b1)begin 
                    cnt <= 0 ;
                    is_start <= 0;
                    // not shift
                    SR <= {  rem_next[31:0],SR[31:1], prs  } ;
                end
                else begin
                    cnt <= cnt +1  ;
                    // { (rem  quo)<< 1 , prs }
                    SR  <= { rem_next[30:0],SR[31:1], prs , 1'b0 } ;
                end
            end 
        end     
    end             
                /*
               { (rem  quo)<< 1 , prs }
               prs =  {rem + sign(divisor)} > 0 ?
           
                */
    assign div_busy = is_start ;

    wire [31:0] rem_res , quo_res ;
    assign rem_res = ( ~is_unsign & a_save) ? (~SR[63:32] + 1) : SR[63:32] ;
    assign quo_res = ( ~is_unsign & ~(b_save==a_save ) ) ? (~SR[31:0] + 1) : SR[31:0] ;
    assign div_out = {rem_res , quo_res} ; 

endmodule