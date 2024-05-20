module GPR(
    input clk,
    input stall_W,
    input we,
    input [4:0] A1, A2, A3,
    input [31:0] reg_wr_data,
    output [31:0] reg_out_0, reg_out_1
);

    integer i;
    reg [31:0] regs [0:31] ;
    
    initial begin
        for(i=0;i<32;i++)begin
            regs[i]=0;
        end
    end

    always @(posedge clk) begin
        if(we& ~stall_W )begin
            if(A3!=0) regs[A3] = reg_wr_data ;
        end    
    end

    assign reg_out_0 = regs[A1] ;
    assign reg_out_1 = regs[A2] ;
endmodule