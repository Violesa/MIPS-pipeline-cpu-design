`include "define.v"
// 　  Register 0: Index，作为MMU的索引用。将来讨论MMU和TLB时会详解之。
// 　　Register 2, EntryLo0，访问TLB Entry偶数页中的地址低32Bit用。同上，在MMU和TLB的相关章节中详解。
// 　　Register 3, EntryLo1，访问TLB Entry奇数页中的地址低32Bit用。
// 　　Register 4, Context，用以加速TLB Miss异常的处理。
// 　　Register 5, PageMask，用以在MMU中分配可变大小的内存页。
//* 　　Register 8, BadVAddr，在系统捕获到TLB Miss或Address Error这两种Exception时，发生错误的虚拟地址会储存在该寄存器中。对于引发Exception的Bug的定位来说，这个寄存器非常重要。
//* 　　Register 9, Count，这个寄存器是R4000以后的MIPS系统引入的。它是一个计数器，计数频率是系统主频的1/2。BCM1125/1250，RMI XLR系列以及Octeon的Cavium处理器均支持该寄存器。对于操作系统来说，可以通过读取该寄存器的值来获取tick的时基。在系统性能测试中，利用该寄存器也可以实现打点计数。
// 　　Register 10，EntryHi，这个寄存器同EntryLo0/1一样，用于MMU中。以后会详述。
//* 　　Register 11，Compare，配合Count使用。当Compare和Count的值相等的时候，会触发一个硬件中断(Hardware Interrupt)，并且总是使用Cause寄存器的IP7位。
//* 　　Register 12，Status，用于处理器状态的控制。
//* 　　Register 13，Cause，这个寄存器体现了处理器异常发生的原因。
//* 　　Register 14，EPC，这个寄存器存放异常发生时，系统正在执行的指令的地址。
// 　　Register 15，PRID，这个寄存器是只读的，标识处理器的版本信息。向其中写入无意义。
// 　　Register 18/19，WatchLo/WatchHi，这对寄存器用于设置硬件数据断点(Hardware Data Breakpoint)。该断点一旦设定，当CPU存取这个地址时，系统就会发生一个异常。这个功能广泛应用于调试定位内存写坏的错误。
// 　　Register 28/29，TagLo和TagHi，用于高速缓存(Cache)管理。

// Exception 0：Interrupt，外部中断。它是唯一一个异步发生的异常。之所以说中断是异步发生的，是因为相对于其他异常来说，从时序上看，中断的发生是不可预料的，无法确定中断的发生是在流水线的哪一个阶段。MIPS的五级流水线设计如下：
// IF, RD, ALU, MEM, WB。MIPS处理器的中断控制部分有这样的设计：在中断发生时，如果该指令已经完成了MEM阶段的操作，则保证该指令执行完毕。反之，则丢弃流水线对这条指令的工作。除NMI外，所有的内部或外部硬件中断(Hardware Interrupt)均共用这一个异常向量(Exception Vector)。前面提到的CP0中的Counter/Compare这一对计数寄存器，当Counter计数值和Compare门限值相等时，即触发一个硬件中断。

// Exception 1：TLB Modified，内存修改异常。如果一块内存在TLB映射时，其属性设定为Read Only，那么，在试图修改这块内存内容时，处理器就会进入这个异常。显然，这个异常是在Memory阶段发生的。但是，按“精确异常”的原则，在异常发生时，ALU阶段的操作均无效，也就是说，向内存地址中的写入操作，实际上是不会被真正执行的。这一判断原则，也适用于后面的内存读写相关的异常，包括TLB Miss/Address Error/Watch等。
// Exception 2/3：TLB Miss Load/Write，如果试图访问没有在MMU的TLB中映射的内存地址，会触发这个异常。在支持虚拟内存的操作系统中，这会触发内存的页面倒换，系统的Exception Handler会将所需要的内存页从虚拟内存中调入物理内存，并更新相应的TLB表项。
// Exception 4/5：Address Error Load/Write，如果试图访问一个非对齐的地址，例如lw/sw指令的地址非4字节对齐，或lh/sh的地址非2字节对齐，就会触发这个异常。一般地，操作系统在Exception Handler中对这个异常的处理，是分开两次读取/写入这个地址。虽然一般的操作系统内核都处理了这个异常，最后能够完成期待的操作，但是由于会引起用户态到内核态的切换，以及异常的退出，当这样非对齐操作较多时会严重影响程序的运行效率。因此，编译器在定义局部和全局变量时，都会自动考虑到对齐的情况，而程序员在设计数据结构时，则需要对对齐做特别的斟酌。
// Exception 6/7：Instruction/Data Bus Error，一般地原因是Cache尚未初始化的时候访问了Cached的内存空间所致。因此，要注意在系统上电后，Cache初始化之前，只访问Uncached的地址空间，也就是0xA0000000-0xBFFFFFFF这一段。默认地，上电初始化的入口点0xBFC00000就位于这一段。(某些MIPS实现中可以通过外部硬线连接修改入口点地址，但为了不引发无法预料的问题，不要将入口点地址修改为Uncached段以外的地址)
//* Exception 8：Syscall，系统调用的正规入口，也就是在用户模式下进入内核态的正规方式。我们可以类比x86下Linux的系统调用0x80来理解它。它是由一条专用指令syscall触发的。
//* Exception 9：Break Point，绝对断点指令。和syscall指令类似，它也是由专用指令break触发的。它指示了系统的一些异常情况，编程人员可以在某些不应当出现的异常分支里面加入这个指令，便于及早发现问题和调试。我们可以用高级语言中的assert机制来类比理解它。最常见的Break异常的子类型为0x07，它是编译器在编译除法运算时自动加入的。如果除数为0则执行一条break 0x07指令。这样，当出现被0除的情况时，系统就会抛出一个异常，并执行Coredump，以便于程序员定位除0错误的根因。
//* Exception 10：RI，执行了没有定义的指令，系统就会发生这个异常。
// Exception 11，Co-Processor Unaviliable，试图访问的协处理器不存在。比如，在没有实现CP2的处理器上执行对CP2的操作，就会触发这个异常。
//* Exception 12，Overflow，算术溢出。会引起这个异常的指令，仅限于加减法中的带符号运算，如add/addi这样的指令。因此，一般地，编译器总是将加减法运算编译为addiu这样的无符号指令。由于MIPS处理异常需要一定的开销，这样可以避免浪费。
//* Exception 13，Trap，条件断点指令。它由trap系列指令引发。与Break指令不同的是，只有满足断点指令中的条件，才会触发这个异常。我们可以类比x86下的int 3断点异常来理解它。
// Exception 14，VCEI，（不明白！谁知道是干嘛使的？）
// Exceotion 15，Float Point Exception，浮点协处理器1的异常。它由CP1自行定义，与CP1的具体实现相关。其实就是专门为CP1保留的异常入口。
// Exception 16，协处理器2的异常，和前一个异常一样，是和CP2的具体实现相关的。
// Exception 23，Watch异常。前面讲到Watch寄存器可以监控一段内存，当访问/修改这段内存时，就会触发这个异常。在异常处理例程中，通过异常栈可以反推出是什么地方对这段内存进行了读/写操作。这个异常是用来定位内存意外写坏问题的一柄利器。
module cp0(
    input clk, rst, 
    input cp0_en, cp0_we,
    input [4:0] cp0_wr_addr,
    input [4:0] cp0_rd_addr,
    input [31:0] cp0_data_in,
    input [31:0] exception_type,
    input [31:0] pc_M,
    input is_in_slot_M,
    input [31:0] BadVAddr,
    output [31:0] cp0_data_out,
    output reg [31:0] cp0_status, cp0_cause, cp0_epc
); 
    reg [31:0] cp0_BadVAddr ,cp0_count ,cp0_compare ;
    assign cp0_data_out = (  {32{rst}} & 32'b0   )
                        | (  {32{~rst & cp0_rd_addr == `CP0_REG_COUNT }} & cp0_count )
                        | (  {32{~rst & cp0_rd_addr == `CP0_REG_COMPARE }} & cp0_compare )
                        | (  {32{~rst & cp0_rd_addr == `CP0_REG_STATUS }} & cp0_status )
                        | (  {32{~rst & cp0_rd_addr == `CP0_REG_CAUSE }} & cp0_cause )
                        | (  {32{~rst & cp0_rd_addr == `CP0_REG_EPC }} & cp0_epc )
                        | (  {32{~rst & cp0_rd_addr == `CP0_REG_BADVADDR }} & cp0_BadVAddr ) ;

    always @(posedge clk) begin
        if(rst)begin
            cp0_BadVAddr <= 32'b0 ;
            cp0_count    <= 32'b0 ;   
            cp0_compare  <= 32'b0 ;
            cp0_cause    <= 32'b0 ;
            cp0_status   <= 32'b0 ;
            cp0_epc      <= 32'b0 ;
        end
        else begin
            //counter
            cp0_count <= cp0_count+1;
            //timer rupt
            if( ~(cp0_compare==32'b0) & (cp0_compare==cp0_count)  )begin
                cp0_cause[30]  <= 1 ;    //TI
            end

            if(cp0_we)begin
                case (cp0_wr_addr)
                    `CP0_REG_COUNT: begin
                        cp0_count <= cp0_data_in ;
                    end
                    `CP0_REG_COMPARE:begin
                        cp0_compare <= cp0_data_in ;
                        cp0_cause[30] <= 1'b0 ;
                    end
                    `CP0_REG_STATUS:begin
                        cp0_status[0] <= cp0_data_in[0] ; // IE : rupt_en
                        cp0_status[15:8] <= cp0_data_in[15:8] ; // IM : rupt_defended  
                    end 
                    `CP0_REG_CAUSE:begin
                        cp0_cause[9:8] <= cp0_data_in[9:8] ; // IP : syscall break
                                                             // soft rupt
                    end     
                    `CP0_REG_EPC:begin
                        cp0_epc <= cp0_data_in ;
                    end
                    default: begin
                        cp0_BadVAddr <= 32'hdead_beef ;
                        cp0_count    <= 32'hdead_beef ;   
                        cp0_compare  <= 32'hdead_beef ;
                        cp0_cause    <= 32'hdead_beef ;
                        cp0_status   <= 32'hdead_beef ;
                        cp0_epc      <= 32'hdead_beef ;
                    end 
                endcase
            end

            // BD : 分支延迟。EPC寄存器的作用是存储异常处理完之后应该回到的地址。
            // 正常情况下，这指向发生异常的那条指令。但是，如果发生异常的指令是在一条分支指令的延迟槽里，EPC必须指向那条分支指令。
            // 重新执行分支指令没有什么害处，假设你从异常返回到了分支延迟指令，分支指令将没法跳转，从而这个异常将破坏程序的执行。
            // cause(BD)只是当发生异常的指令在分支延迟槽时被置位，并且，EPC指向分支指令。
            // 如果分析发生异常的指令，只要看看cause(BD)，如果cause(BD)=1，那么该指令的位置是EPC+4。
           
           
            // ExcCode ：这5位指示发生了哪种类型异常
            if(cp0_en)begin
                case(exception_type)
                    `EXC_TYPE_INT:begin
                        if(is_in_slot_M== 1'b1)begin    //branch
                            cp0_epc       <= pc_M - 4 ;
                            cp0_cause[31] <=  1'b1 ;    //BD
                        end
                        else begin
                            cp0_epc       <= pc_M  ;
                            cp0_cause[31] <=  1'b0 ;
                        end
                        cp0_status[1]     <=  1'b1 ;   //kernal
                        cp0_cause[6:2]    <=  `EXC_CODE_INT ; //ExcCode
                    end    
                    `EXC_TYPE_ADEL :begin
                        if(is_in_slot_M== 1'b1)begin    //branch
                            cp0_epc       <= pc_M - 4 ;
                            cp0_cause[31] <=  1'b1 ;    //BD
                        end
                        else begin
                            cp0_epc       <= pc_M  ;
                            cp0_cause[31] <=  1'b0 ;
                        end
                        cp0_status[1]     <=  1'b1 ;   //kernal
                        cp0_cause[6:2]    <=  `EXC_CODE_ADEL ;//ExcCode
                    end            
                    `EXC_TYPE_ADES :begin
                        if(is_in_slot_M== 1'b1)begin    //branch
                            cp0_epc       <= pc_M - 4 ;
                            cp0_cause[31] <=  1'b1 ;    //BD
                        end
                        else begin
                            cp0_epc       <= pc_M  ;
                            cp0_cause[31] <=  1'b0 ;
                        end
                        cp0_status[1]     <=  1'b1 ;   //kernal
                        cp0_cause[6:2]    <=  `EXC_CODE_ADES ;//ExcCode
                    end           
                    `EXC_TYPE_SYS:begin
                        if(is_in_slot_M== 1'b1)begin    //branch
                            cp0_epc       <= pc_M - 4 ;
                            cp0_cause[31] <=  1'b1 ;    //BD
                        end
                        else begin
                            cp0_epc       <= pc_M  ;
                            cp0_cause[31] <=  1'b0 ;
                        end
                        cp0_status[1]     <=  1'b1 ;   //kernal
                        cp0_cause[6:2]    <=  `EXC_CODE_SYS ;//ExcCode
                    end             
                    `EXC_TYPE_BP :begin
                        if(is_in_slot_M== 1'b1)begin    //branch
                            cp0_epc       <= pc_M - 4 ;
                            cp0_cause[31] <=  1'b1 ;    //BD
                        end
                        else begin
                            cp0_epc       <= pc_M  ;
                            cp0_cause[31] <=  1'b0 ;
                        end
                        cp0_status[1]     <=  1'b1 ;   //kernal
                        cp0_cause[6:2]    <=  `EXC_CODE_BP ; //ExcCode
                    end            
                    `EXC_TYPE_RI :begin
                        if(is_in_slot_M== 1'b1)begin    //branch
                            cp0_epc       <= pc_M - 4 ;
                            cp0_cause[31] <=  1'b1 ;    //BD
                        end
                        else begin
                            cp0_epc       <= pc_M  ;
                            cp0_cause[31] <=  1'b0 ;
                        end
                        cp0_status[1]     <=  1'b1 ;   //kernal
                        cp0_cause[6:2]    <=  `EXC_CODE_RI ;//ExcCode
                    end           
                    `EXC_TYPE_OV: begin
                        if(is_in_slot_M== 1'b1)begin    //branch
                            cp0_epc       <= pc_M - 4 ;
                            cp0_cause[31] <=  1'b1 ;    //BD
                        end
                        else begin
                            cp0_epc       <= pc_M  ;
                            cp0_cause[31] <=  1'b0 ;
                        end
                        cp0_status[1]     <=  1'b1 ;   //kernal
                        cp0_cause[6:2]    <=  `EXC_CODE_OV ;//ExcCode
                    end           
                    `EXC_TYPE_ERET:begin
                        cp0_status[0]     <=  1'b0 ;
                    end          
                    `EXC_TYPE_NOEXC:begin
                    end          
                endcase
            end
        end 
    end


endmodule