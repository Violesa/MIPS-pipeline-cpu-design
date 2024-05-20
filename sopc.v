`include "define.v"
`include "cpu.v"
`include "im.v"
`include "dm.v"
module sopc(
    input clk, 
    input rst
);
    
    wire        im_en;
    wire [31:0] im_addr;
    
    wire [31:0] dm_addr;
    wire [31:0] dm_in;
    wire        dm_en;
    wire [3:0]  dm_byte;
    cpu u_cpu(
        .clk(clk),
        .rst(rst),
        .im_out(im_out),
        .dm_out(dm_out),
        .rupt(),

        .im_en(im_en),
        .im_addr(im_addr),
        .dm_addr(dm_addr),
        .dm_en(dm_en),
        .dm_in(dm_in),
        .dm_byte(dm_byte) 
    );

    wire [31:0] im_out ;
    im mips_im(
        .im_en(im_en),        
        .im_addr(im_addr),

        .im_out(im_out)
    );

    wire [31:0] dm_out;
    dm u_dm(
        .clk(~clk),
        .dm_en(dm_en),
        .dm_byte(dm_byte),
        .dm_in(dm_in),
        .dm_addr(dm_addr),

        .dm_out(dm_out)
    );

endmodule