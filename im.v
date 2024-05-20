`include "define.v"
module im(
    input       im_en,
    input [31:0] im_addr,
    output[31:0] im_out
);
    parameter  im_width = 10 ;
    reg [31:0] rom [ 0 : (1<<im_width)-1 ] ;

    assign im_out = im_en ? rom[ im_addr[ im_width-1 +2 : 2 ] ] : 32'b0 ;

    initial $readmemh("code_3.txt",rom);
    
endmodule