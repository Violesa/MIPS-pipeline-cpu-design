module MEM_WB(
    input clk, rst, stall_W,
    input [31:0] pc_M,
    input [31:0] alu_out_M,
    input [4:0] wr_reg_M,
    input       reg_wr_M,
    input [31:0] result_M,
    output reg[31:0] pc_W,
    output reg[31:0] alu_out_W,
    output reg[4:0] wr_reg_W,
    output reg      reg_wr_W,
    output reg[31:0] result_W
);

    always @(posedge clk) begin
        if(rst)begin
            pc_W        <= 0;
            alu_out_W   <= 0;
            reg_wr_W    <= 0;
            wr_reg_W    <= 0;
            result_W    <= 0;
        end
        else if(~stall_W) begin
            pc_W        <= pc_M;
            alu_out_W   <= alu_out_M;
            reg_wr_W    <= reg_wr_M;
            wr_reg_W    <= wr_reg_M;
            result_W    <= result_M;
        end
    end
endmodule