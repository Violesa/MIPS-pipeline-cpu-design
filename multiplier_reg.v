module multiplier_reg(
    input clk, rst, 
    input flush, mult_en,
    input [31:0] mult_A, mult_B,
    input is_unsign,
    input mult_ready,
    output mult_busy,
    output [63:0] mult_out
    //    output [63:0] debug
);
    //assign debug = Si[13];
    reg [31:0] A, B;
    wire [31:0] neg_A;
    initial begin
        A <= 0 ;
        B <= 0 ;
    end
    always @(posedge clk) begin
        if(mult_en)begin
            A <= mult_A ;
            B <= mult_B ;
        end

    end

    assign neg_A= ~A + 1 ;

    
    //compress 32*32 to 16*32
    // 000     0
    // 001     1
    // 010     1
    // 011     2
    // 100     -2
    // 101     -1
    // 110     -1
    // 111     0  
    wire [2:0] booth[0:15]; 
    wire [63:0] Pi  [0:15]; 
    assign booth[0] = {B[1],B[0],1'b0};
    genvar  i;
    generate
        for(i=1;i<16;i=i+1)begin
            assign booth[i] = { B[(i<<1)+1],B[i<<1],B[(i<<1)-1]};
        end
    endgenerate
    generate
        for(i=0;i<16;i=i+1)begin
            assign Pi[i] = { {64{booth[i]==3'b000}} & 64'b0  } 
                         | { {64{booth[i]==3'b001}} & {  {(32-(i<<1)){A[31]}} , A , {(i<<1){1'b0}} } }
                         | { {64{booth[i]==3'b010}} & {  {(32-(i<<1)){A[31]}} , A , {(i<<1){1'b0}} } }
                         | { {64{booth[i]==3'b011}} & {  {(32-(i<<1)-1){A[31]}} , A , {((i<<1)+1){1'b0}} } }
                         | { {64{booth[i]==3'b100}} & {  {(32-(i<<1)-1){neg_A[31]}} , neg_A , {((i<<1)+1){1'b0}} } }
                         | { {64{booth[i]==3'b101}} & {  {(32-(i<<1)){neg_A[31]}} , neg_A , {(i<<1){1'b0}} } }
                         | { {64{booth[i]==3'b110}} & {  {(32-(i<<1)){neg_A[31]}} , neg_A , {(i<<1){1'b0}} } }
                         | { {64{booth[i]==3'b111}} & 64'b0  }  ;
                
        end
    endgenerate

    wire clk_0,clk_1,clk_2,clk_3,clk_4,clk_5 ;
    assign clk_0 = cnt == 3'b001;
    assign clk_1 = cnt == 3'b010;
    assign clk_2 = cnt == 3'b011;
    assign clk_3 = cnt == 3'b100;
    assign clk_4 = cnt == 3'b101;
    assign clk_5 = cnt == 3'b110;
    reg [2:0] cnt ;
    always @(posedge clk ) begin
        if(rst | flush)begin 
            cnt <= 0;
        end 
        else begin
                if((cnt==0)&mult_en&~mult_ready)begin
                    cnt      <=1;
                end
                else if(cnt== 3'b110)begin
                    cnt <= 0;
                end
                else if(cnt!=0)begin
                    cnt <= cnt + 1;
                end
            end
    end

    wire [64:0] Ci[0:13];
    wire [63:0] Si[0:13];
    generate
        for(i=0;i<14;i=i+1) assign Ci[i][0] = 1'b0 ;
    endgenerate
    generate
        for(i=0;i<64;i=i+1)begin
            //clk 0
            adder adder_0(
                .a( Pi[0][i] ), .b(Pi[1][i]), .cin(Pi[2][i]), .clk(clk), .en(clk_0),
                .cout(Ci[0][i+1]), .s(Si[0][i])
            );
            adder adder_1(
                .a( Pi[4][i] ), .b(Pi[5][i]), .cin(Pi[6][i]), .clk(clk), .en(clk_0),
                .cout(Ci[1][i+1]), .s(Si[1][i])
            );
            adder adder_2(
                .a( Pi[8][i] ), .b(Pi[9][i]), .cin(Pi[10][i]), .clk(clk), .en(clk_0),
                .cout(Ci[2][i+1]), .s(Si[2][i])
            );
            adder adder_3(
                .a( Pi[12][i] ), .b(Pi[13][i]), .cin(Pi[14][i]), .clk(clk), .en(clk_0),
                .cout(Ci[3][i+1]), .s(Si[3][i])
            );
            //clk 1
            adder adder_4(
                .a( Pi[3][i] ), .b(Si[0][i]), .cin(Ci[0][i]),  .clk(clk), .en(clk_1),
                .cout(Ci[4][i+1]), .s(Si[4][i])
            );
            adder adder_5(
                .a( Pi[7][i] ), .b(Si[1][i]), .cin(Ci[1][i]),  .clk(clk),.en(clk_1),
                .cout(Ci[5][i+1]), .s(Si[5][i])
            );
            adder adder_6(
                .a( Pi[11][i] ), .b(Si[2][i]), .cin(Ci[2][i]),  .clk(clk),.en(clk_1),
                .cout(Ci[6][i+1]), .s(Si[6][i])
            );
            adder adder_7(
                .a( Pi[15][i] ), .b(Si[3][i]), .cin(Ci[3][i]),  .clk(clk),.en(clk_1),
                .cout(Ci[7][i+1]), .s(Si[7][i])
            );
            //clk2
            adder adder_8(
                .a( Ci[4][i] ), .b(Si[5][i]), .cin(Ci[5][i]),  .clk(clk),.en(clk_2),
                .cout(Ci[8][i+1]), .s(Si[8][i])
            );
            adder adder_9(
                .a( Ci[6][i] ), .b(Si[7][i]), .cin(Ci[7][i]),  .clk(clk),.en(clk_2),
                .cout(Ci[9][i+1]), .s(Si[9][i])
            );
            //clk 3
            adder adder_10(
                .a( Si[4][i] ), .b(Si[8][i]), .cin(Ci[8][i]),  .clk(clk),.en(clk_3),
                .cout(Ci[10][i+1]), .s(Si[10][i])
            );
            adder adder_11(
                .a( Si[6][i] ), .b(Si[9][i]), .cin(Ci[9][i]),  .clk(clk),.en(clk_3),
                .cout(Ci[11][i+1]), .s(Si[11][i])
            );
            //clk 4
            adder adder_12(
                .a( Ci[10][i] ), .b(Si[11][i]), .cin(Ci[11][i]),  .clk(clk),.en(clk_4),
                .cout(Ci[12][i+1]), .s(Si[12][i])
            );
            // 5
            adder adder_13(
                .a( Si[10][i] ), .b(Si[12][i]), .cin(Ci[12][i]), .clk(clk) ,.en(clk_5),
                .cout(Ci[13][i+1]), .s(Si[13][i])
            );
            //6
        end
    endgenerate
    assign mult_out = Si[13] + Ci[13][63:0] ;
    assign mult_busy = ~(cnt==0) ;
endmodule

module adder(
    input a, b, cin,  clk , en ,
    output reg cout, s
);
    // assign  cout = ( ~cin&(a&b)) | ( cin&(a|b) ) ;
    // assign  s    = a^b^cin ;
    always @(posedge clk ) begin
        if(en)begin
            cout <= ( ~cin&(a&b)) | ( cin&(a|b) ) ;
            s <= a^b^cin ; 
        end
    end
endmodule