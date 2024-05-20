module dm(
    input clk,
    input [3:0] dm_byte,
    input dm_en,
    input [31:0] dm_addr,
    input [31:0] dm_in,
    output[31:0] dm_out
);
    parameter  width = 10 ;
    parameter  cnt = 1<<(width+2) -1 ;
    reg [7:0] ram [0: cnt ] ;   
    integer i ;
    initial begin
        for(i=0; i<cnt ; i = i+1  ) ram[i]<=0;
    end
    //rd
    assign dm_out = dm_en ?  { ram[dm_addr[11:0]+3],ram[dm_addr[11:0]+2],ram[dm_addr[11:0]+1],ram[dm_addr[11:0]+0] } : 32'b0;

    //wr
    always@(posedge clk )begin
        if(dm_en)begin
            if(dm_byte[3]==1'b1) ram[dm_addr[11:0]+3] <= dm_in[31:24];
            if(dm_byte[2]==1'b1) ram[dm_addr[11:0]+2] <= dm_in[23:16];
            if(dm_byte[1]==1'b1) ram[dm_addr[11:0]+1] <= dm_in[15:8];
            if(dm_byte[0]==1'b1) ram[dm_addr[11:0]+0] <= dm_in[7:0];
        end
    end

    wire [7:0] a,b,c,d;
    assign a = ram[0];
endmodule