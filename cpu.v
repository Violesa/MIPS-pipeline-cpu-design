`include "define.v"
`include "main_ctr.v"
`include "alu_decoder.v"
`include "hazard.v"
`include "pc.v"
`include "IF_ID.v"
`include "GPR.v"
`include "branch_pre.v"
`include "jump_ctr.v"
`include "ID_EX.v"
`include "mux.v"
`include "alu.v"
`include "branch_check.v"
`include "EX_MEM.v"
`include "mem_ctr.v"
`include "hilo.v"
`include "cp0.v"
`include "exception.v"
`include "MEM_WB.v"
module cpu(
    input clk,
    input rst,
    
    input [31:0] im_out,
    output        im_en,
    output [31:0] im_addr,
    
    input [31:0] dm_out,
    output [31:0] dm_addr,
    output [31:0] dm_in,
    output        dm_en,
    output [3:0] dm_byte,

    input [5:0] rupt 
);

    
    assign im_addr = pc_F ;
    assign im_en   = ~stall_F&(pc_F[1:0]==2'b00) & ~flush_pred_failed_E ;

    wire [4:0] rs_D, rt_D, rd_D, sa_D;
    assign rs_D = instr_D[25:21];
    assign rt_D = instr_D[20:16];
    assign rd_D = instr_D[15:11];
    assign sa_D = instr_D[10:6];

    wire     reg_wr_D, mem_wr_D,mem_rd_D, mem_to_reg_D;
    wire  [1:0] reg_dst_D;
    wire       is_unsign_D; 
    wire      hilo_wr_D, hilo_to_reg_D;
    wire         alu_src_D;
    wire         is_mfc_D;
    wire         break_D, syscall_D, eret_D;
    wire         cp0_we_D, cp0_to_reg_D;
    wire         ri_D;
    main_ctr u_main_ctr(
        .instr_D        ( instr_D        ),

        .reg_wr_D      ( reg_wr_D      ),
        .mem_wr_D      ( mem_wr_D      ),
        .mem_rd_D      ( mem_rd_D      ),
        .mem_to_reg_D  ( mem_to_reg_D  ),
        .reg_dst_D     ( reg_dst_D     ),
        .is_unsign_D   ( is_unsign_D   ),
        .hilo_wr_D     ( hilo_wr_D     ),
        .hilo_to_reg_D ( hilo_to_reg_D ),
        .alu_src_D     ( alu_src_D     ),
        .is_mfc_D      ( is_mfc_D      ),
        .break_D       ( break_D       ),
        .syscall_D     ( syscall_D     ),
        .eret_D        ( eret_D        ),
        .cp0_we_D      ( cp0_we_D      ),
        .cp0_to_reg_D  ( cp0_to_reg_D  ),
        .ri_D          ( ri_D          )
    );

    

    wire [4:0] alu_ctr_D ;
    wire [4:0] branch_ctr_D ;
    alu_decode u_alu_decode(
        .instr_D   ( instr_D    ),

        .alu_ctr_D ( alu_ctr_D ),
        .branch_ctr_D  ( branch_ctr_D  )
    );

    wire stall_F, stall_D, stall_E, stall_M, stall_W;
    wire flush_F, flush_D, flush_E, flush_M, flush_W;
    wire [1:0] fw_0_E, fw_1_E;
    wire [1:0] RAW_JR;
    hazard u_hazard(
        .alu_stall_E           ( alu_stall_E           ),
        .flush_jump_conflict_E ( flush_jump_conflict_E ),
        .is_jr_D               (is_jr_D),
        .flush_pred_failed_E   ( flush_pred_failed_E   ),
        .flush_pred_failed_M   (flush_pred_failed_M) ,
        .flush_exception_M     ( flush_exception_M     ),
        .rs_E                  ( rs_E                  ),
        .rt_E                  ( rt_E                  ),
        .rt_D                   (rt_D),
        .rs_D                      (rs_D),
        .reg_wr_M              ( reg_wr_M              ),
        .reg_wr_W              ( reg_wr_W              ),
        .reg_wr_E             (reg_wr_E),
        .reg_wr_D               (reg_wr_D),
        .wr_reg_E              (wr_reg_E),
        .wr_reg_M              ( wr_reg_M              ),
        .wr_reg_W              ( wr_reg_W              ),
        .mem_to_reg_E              ( mem_to_reg_E              ),
        .mem_to_reg_M         (mem_to_reg_M),
        .stall_F               ( stall_F               ),
        .stall_D               ( stall_D               ),
        .stall_E               ( stall_E               ),
        .stall_M               ( stall_M               ),
        .stall_W               ( stall_W               ),
        .flush_F               ( flush_F               ),
        .flush_D               ( flush_D               ),
        .flush_E               ( flush_E               ),
        .flush_M               ( flush_M               ),
        .flush_W               ( flush_W               ),
        .fw_0_E                ( fw_0_E                ),
        .fw_1_E                ( fw_1_E                ),
        .RAW_JR              (RAW_JR)
    );  
    
    wire branch_F ;
    wire pred_take_F;
    branch_pre u_branch_pre(
        .clk           ( clk           ),
        .rst           ( rst           ),
        .flush_F       ( flush_F       ),
        .stall_F       ( stall_F       ),
        .instr_F       ( instr_F       ),
        .imm_F         ( imm_F         ),
        .pc_F          ( pc_F          ),
        .pc_M          ( pc_M          ),
        .branch_M      ( branch_M      ),
        .actual_take_M ( actual_take_M ),

        .branch_F      ( branch_F      ),
        .pred_take_F   ( pred_take_F   )
    );

    wire jump_F, jump_conflict_D;
    wire [31:0] pc_jump_F ;
    wire jump_stall;
    wire is_jr_F ;
    jump_ctr u_jump_ctr(
        .instr_F         ( instr_F         ),
        .pc_plus_F       ( pc_plus_F       ),
        .mux_JR_out_D     ( mux_JR_out_D     ),
        .wr_reg_E        ( wr_reg_E        ),
        .wr_reg_M        ( wr_reg_M        ),
        .reg_wr_E        ( reg_wr_E        ),
        .reg_wr_M        ( reg_wr_M        ),
        .is_jr_D         (is_jr_D),

        .jump_F          ( jump_F          ),
        .jump_conflict_D ( jump_conflict_D ),
        .pc_jump_F       ( pc_jump_F       ),
        .jump_stall        (jump_stall),
        .is_jr           (is_jr_F)
    );

    // IF
    wire [31:0] instr_F ;
    assign instr_F = im_out ;
    wire   F_change;
    assign F_change = branch_D | jump_D ;
    
    wire [31:0] imm_F;
    assign imm_F = { {16{instr_F[15]}} , instr_F[15:0]   };
    
    wire [31:0] pc_F, pc_plus_F;
    assign pc_plus_F = pc_F + 4 ;
    
    wire [31:0] pc_branch_F ;
    assign pc_branch_F = {imm_F[29:0],2'b00} + pc_plus_F ;
    pc u_pc(
        .clk             ( clk             ),
        .rst             ( rst             ),
        .stall_F         ( stall_F         ),
        .branch_F        ( branch_F        ),
        .branch_E        ( branch_E        ),
        .pre_right       ( pre_right       ),
        .actual_take_E   ( actual_take_E   ),
        .pred_take_F     ( pred_take_F     ),
        .pc_trap_M       ( pc_trap_M       ),
        .jump_F          ( jump_F          ),
        .jump_stall      (jump_stall),
        .jump_conflict_D ( jump_conflict_D ),
        .jump_conflict_E ( jump_conflict_E ),
        .pc_exception_M  ( pc_exception_M  ),
        .pc_plus_E       ( pc_plus_E       ),
        .pc_branch_E     ( pc_branch_E     ),
        .pc_jump_F       ( pc_jump_F       ),
        .pc_jump_E       ( pc_jump_E       ),
        .pc_branch_F     ( pc_branch_F     ),
        .pc_plus_F       ( pc_plus_F       ),

        .pc_F            ( pc_F            )
    );
    //
    wire [31:0] pc_D, pc_plus_D;
    wire [31:0] instr_D;
    wire        is_in_slot_D;
    wire        pred_take_D;
    wire [31:0] pc_jump_D;
    wire        is_jr_D;
    IF_ID u_IF_ID(
        .clk       ( clk       ),
        .rst       ( rst       ),
        .flush_D   ( flush_D   ),
        .stall_D   ( stall_D   ),
        .jump_stall(jump_stall),
        .pc_F      ( pc_F      ),
        .pred_take_F(pred_take_F),
        .pc_plus_F ( pc_plus_F ),
        .instr_F   ( im_out    ),
        .F_change  ( F_change  ),
        .pc_jump_F (pc_jump_F),
        .jump_F     (jump_F),
        .is_jr_F   (is_jr_F),
        .branch_F  (branch_F),

        .jump_D    (jump_D),
        .pc_jump_D  (pc_jump_D),
        .pc_D      ( pc_D      ),
        .pc_plus_D ( pc_plus_D ),
        .instr_D   ( instr_D   ),
        .pred_take_D   (pred_take_D),
        .is_jr_D      (is_jr_D),
        .is_in_slot_D  ( is_in_slot_D  ),
        .branch_D    (branch_D)
    );
    //ID    
    wire [31:0] imm_D;
    assign imm_D = is_unsign_D ? {16'b0,instr_D[15:0]} :
                                 { {16{instr_D[15]}}, instr_D[15:0]} ;
    wire [31:0] pc_branch_D;
    assign pc_branch_D = {imm_D[29:0],2'b00} + pc_plus_D ;
    
    wire [31:0] reg_out_0_D, reg_out_1_D ;
    GPR u_GPR(
        .clk         ( clk         ),
        .stall_W     ( stall_W     ),
        .we          ( reg_wr_M & ~flush_exception_M    ),
        .A1          ( rs_D         ),
        .A2          ( rt_D         ),
        .A3          ( wr_reg_M     ),                 
        .reg_wr_data ( result_M    ),                       //

        .reg_out_0   ( reg_out_0_D   ),
        .reg_out_1   ( reg_out_1_D   )
    );
    wire [31:0] mux_JR_out_D;
    mux4 mux_JR_D(
        reg_out_0_D,
        alu_out_E[31:0],
        result_M,
        32'hdead_beef,
        RAW_JR,
        mux_JR_out_D
    ); 
    //
    wire [31:0] pc_E;
    wire  [31:0] pc_plus_E;
    wire  [31:0] pc_branch_E;
    wire  [31:0] imm_E;
    wire  [31:0] instr_E;
    wire  [31:0] reg_out_0_E, reg_out_1_E;
    wire  [4:0]  rs_E, rt_E, rd_E, sa_E;
    wire  pred_take_E;
    wire  branch_E;
    wire  jump_E, jump_conflict_E;
    wire  is_in_slot_E;
    wire  [4:0] alu_ctr_E;
    wire  [4:0] branch_ctr_E;
    wire      reg_wr_E;
    wire      mem_wr_E,mem_rd_E, mem_to_reg_E;
    wire  [1:0] reg_dst_E;
    wire       hilo_wr_E, hilo_to_reg_E;
    wire        alu_src_E;
    wire        is_mfc_E;
    wire        break_E, syscall_E, eret_E;
    wire        cp0_en_E, cp0_to_reg_E;
    wire        ri_E;
    ID_EX u_ID_EX(
        .clk             ( clk             ),
        .rst             ( rst             ),
        .stall_E         ( stall_E         ),
        .flush_E         ( flush_E         ),
        .pc_D            ( pc_D            ),
        .pc_plus_D       ( pc_plus_D       ),
        .pc_branch_D     ( pc_branch_D     ),
        .imm_D           ( imm_D           ),
        .instr_D         ( instr_D         ),
        .reg_out_0_D     ( reg_out_0_D     ),
        .reg_out_1_D     ( reg_out_1_D     ),
        .rs_D            ( rs_D            ),
        .rt_D            ( rt_D            ),
        .rd_D            ( rd_D            ),
        .sa_D            ( sa_D            ),
        .pred_take_D     ( pred_take_D     ),
        .branch_D        ( branch_D        ),
        .jump_D          ( jump_D          ),
        .jump_conflict_D ( jump_conflict_D ),
        .is_in_slot_D    ( is_in_slot_D    ),
        .alu_ctr_D       ( alu_ctr_D       ),
        .branch_ctr_D    ( branch_ctr_D    ),
        .reg_wr_D        ( reg_wr_D        ),
        .mem_wr_D        ( mem_wr_D        ),
        .mem_rd_D        ( mem_rd_D        ),
        .mem_to_reg_D    ( mem_to_reg_D    ),
        .reg_dst_D       ( reg_dst_D       ),
        .hilo_wr_D       ( hilo_wr_D       ),
        .hilo_to_reg_D   ( hilo_to_reg_D   ),
        .alu_src_D       ( alu_src_D       ),
        .is_mfc_D        ( is_mfc_D        ),
        .break_D         ( break_D         ),
        .syscall_D       ( syscall_D       ),
        .eret_D          ( eret_D          ),
        .cp0_en_D        ( cp0_en_D        ),
        .cp0_to_reg_D    ( cp0_to_reg_D    ),
        .ri_D            ( ri_D            ),

        .pc_E            ( pc_E            ),
        .pc_plus_E       ( pc_plus_E       ),
        .pc_branch_E     ( pc_branch_E     ),
        .imm_E           ( imm_E           ),
        .instr_E         ( instr_E         ),
        .reg_out_0_E     ( reg_out_0_E     ),
        .reg_out_1_E     ( reg_out_1_E     ),
        .rs_E            ( rs_E            ),
        .rt_E            ( rt_E            ),
        .rd_E            ( rd_E            ),
        .sa_E            ( sa_E            ),
        .pred_take_E     ( pred_take_E     ),
        .branch_E        ( branch_E        ),
        .jump_E          ( jump_E          ),
        .jump_conflict_E ( jump_conflict_E ),
        .is_in_slot_E    ( is_in_slot_E    ),
        .alu_ctr_E       ( alu_ctr_E       ),
        .branch_ctr_E    ( branch_ctr_E    ),
        .reg_wr_E        ( reg_wr_E        ),
        .mem_wr_E        ( mem_wr_E        ),
        .mem_rd_E        ( mem_rd_E        ),
        .mem_to_reg_E    ( mem_to_reg_E    ),
        .reg_dst_E       ( reg_dst_E       ),
        .hilo_wr_E       ( hilo_wr_E       ),
        .hilo_to_reg_E   ( hilo_to_reg_E   ),
        .alu_src_E       ( alu_src_E       ),
        .is_mfc_E        ( is_mfc_E        ),
        .break_E         ( break_E         ),
        .syscall_E       ( syscall_E       ),
        .eret_E          ( eret_E          ),
        .cp0_en_E        ( cp0_en_E        ),
        .cp0_to_reg_E    ( cp0_to_reg_E    ),
        .ri_E            ( ri_E            )
    );

    
    //EX
    wire [31:0] src_0_E;
    mux4 mux_fw_0_E(
        reg_out_0_E,
        result_M,
        result_W,
        pc_plus_E,
        {2{jump_E|branch_E}}| fw_0_E,

        src_0_E
    );

    wire [31:0] src_1_E;
    mux4 mux_fw_1_E(
        reg_out_1_E,
        result_M,
        result_W,
        imm_E,
        {2{alu_src_E}}| fw_1_E,

        src_1_E
    );

    wire [4:0] wr_reg_E;
    mux4 #(5) mux_reg_wr_E(
        rd_E,
        rt_E,
        5'b11111,
        5'b0,
        reg_dst_E,
        wr_reg_E
    );  

    wire flush_jump_conflict_E ;
    assign flush_jump_conflict_E = jump_conflict_E ;
    wire [31:0] pc_jump_E ;
    assign pc_jump_E = rs_data_E ;

    wire [31:0] rs_data_E ;
    mux4 mux_rs_data_E(
        reg_out_0_E,
        result_M,
        result_W,
        32'b0,
        fw_0_E,
        rs_data_E
    );

    wire [31:0] rt_data_E ;
    mux4 mux_rt_data_E(
        reg_out_1_E,
        result_M,
        result_W,
        32'b0,
        fw_1_E,
        rt_data_E
    );

    wire alu_stall_E;
    wire [63:0] alu_out_E;
    wire overflow_E;
    alu u_alu(
        .clk         ( clk         ),
        .rst         ( rst         ),
        .flush_E     ( flush_E     ),
        .A           ( src_0_E          ),
        .B           ( src_1_E           ),
        .alu_ctr_E   ( alu_ctr_E   ),
        .sa          ( sa_E         ),
        .hilo        ( hilo_alu      ),             //

        .alu_stall_E ( alu_stall_E ),
        .alu_out_E   ( alu_out_E   ),
        .overflow_E  ( overflow_E  )
    );
    
   wire pre_right ;
    wire flush_pred_failed_E = ~pre_right ;
    wire actual_take_E;
    branch_check u_branch_check(
        .branch_ctr_E ( branch_ctr_E ),
        .pred_take_E  (pred_take_E),
        .rs_data_E    ( rs_data_E    ),
        .rt_data_E    ( rt_data_E    ),
        .actual_take_E  ( actual_take_E  ),
        .pre_right    (pre_right)
    );
    //
    wire [31:0] pc_M;
    wire [31:0] pc_branch_M;
    wire [31:0] rt_data_M;
    wire [31:0] alu_out_M;
    wire [31:0] instr_M;
    wire [4:0]  wr_reg_M;
    wire [4:0]  rd_M;
    wire      branch_M;
    wire       overflow_M;
    wire       is_in_slot_M;
    wire      actual_take_M;
    wire       hilo_to_reg_M;
    wire       flush_pred_failed_M;
    wire       reg_wr_M;
    wire       mem_wr_M, mem_rd_M, mem_to_reg_M;
    wire       is_mfc_M;
    wire       break_M, syscall_M, eret_M;
    wire       cp0_en_M, cp0_to_reg_M;
    wire       ri_M;
    EX_MEM u_EX_MEM(
        .clk           ( clk           ),
        .rst           ( rst           ),
        .flush_M       ( flush_M       ),
        .stall_M       ( stall_M       ),
        .pc_E          ( pc_E          ),
        .pc_branch_E   ( pc_branch_E   ),
        .rt_data_E     ( rt_data_E     ),
        .alu_out_E     ( alu_out_E     ),
        .instr_E       ( instr_E       ),
        .wr_reg_E      ( wr_reg_E      ),
        .rd_E          ( rd_E          ),
        .branch_E      ( branch_E      ),
        .flush_pred_failed_E (flush_pred_failed_E),
        .overflow_E    ( overflow_E    ),
        .is_in_slot_E  ( is_in_slot_E  ),
        .pred_take_E   (pred_take_E    ),
        .actual_take_E ( actual_take_E ),
        .hilo_to_reg_E ( hilo_to_reg_E ),
        .reg_wr_E      ( reg_wr_E      ),
        .mem_wr_E      ( mem_wr_E      ),
        .mem_rd_E      ( mem_rd_E      ),
        .mem_to_reg_E  ( mem_to_reg_E  ),
        .is_mfc_E      ( is_mfc_E      ),
        .break_E       ( break_E       ),
        .syscall_E     ( syscall_E     ),
        .eret_E        ( eret_E        ),
        .cp0_en_E      ( cp0_en_E      ),
        .cp0_to_reg_E  ( cp0_to_reg_E  ),
        .ri_E          ( ri_E          ),

        .pc_M          ( pc_M          ),
        .pc_branch_M   ( pc_branch_M   ),
        .rt_data_M     ( rt_data_M     ),
        .alu_out_M     ( alu_out_M     ),
        .instr_M       ( instr_M       ),
        .wr_reg_M      ( wr_reg_M      ),
        .rd_M          ( rd_M          ),
        .branch_M      ( branch_M      ),
        .overflow_M    ( overflow_M    ),
        .is_in_slot_M  ( is_in_slot_M  ),
        .pred_take_M   (pred_take_M    ),   
        .actual_take_M ( actual_take_M ),
        .hilo_to_reg_M ( hilo_to_reg_M ),
        .reg_wr_M      ( reg_wr_M      ),
        .mem_wr_M      ( mem_wr_M      ),
        .mem_rd_M      ( mem_rd_M      ),
        .mem_to_reg_M  ( mem_to_reg_M  ),
        .flush_pred_failed_M(flush_pred_failed_M),
        .is_mfc_M      ( is_mfc_M      ),
        .break_M       ( break_M       ),
        .syscall_M     ( syscall_M     ),
        .eret_M        ( eret_M        ),
        .cp0_en_M      ( cp0_en_M      ),
        .cp0_to_reg_M  ( cp0_to_reg_M  ),
        .ri_M          ( ri_M          )
    );

    //MEM
    assign dm_addr = alu_out_M ;
    assign dm_en = mem_rd_M | mem_wr_M ;
    wire [31:0] mem_rd_data_M;
    wire lw_error_M, sw_error_M;
    mem_ctr u_mem_ctr(
        .instr_M        ( instr_M        ),
        .addr           ( alu_out_M           ),
        .mem_wr_tdata_M ( rt_data_M ),
        .mem_rd_tdata_M ( dm_out        ),

        .dm_byte        ( dm_byte        ),
        .mem_wr_data_M  ( dm_in  ),
        .mem_rd_data_M  ( mem_rd_data_M  ),
        .lw_error       ( lw_error_M       ),
        .sw_error       ( sw_error_M       )
    );

    wire [63:0] hilo_alu ;
    wire [31:0] hilo_out_M ;
    hilo u_hilo(
        .clk     ( clk     ),
        .rst     ( rst     ),
        .we      ( hilo_wr_E & ~flush_exception_M      ),
        .instr_M ( instr_M ),
        .hilo_in ( alu_out_E ),

        .hilo_alu (hilo_alu),
        .hilo_out  ( hilo_out_M  )
    );

    wire pc_error_M;
    assign pc_error_M = ~(pc_M[1:0]==2'b00) ;
    wire [31:0] exception_type_M;
    wire flush_exception_M;
    wire [31:0] pc_exception_M;
    wire pc_trap_M;
    wire [31:0] BadVAddr;
    exception u_exception(
        .rst               ( rst               ),
        .rupt              ( rupt              ),
        .ri                ( ri_M               ),
        .break             ( break_M             ),
        .syscall           ( syscall_M           ),
        .overflow          ( overflow_M          ),
        .eret              ( eret_M              ),
        .lw_error          ( lw_error_M          ),
        .sw_error          ( sw_error_M          ),
        .pc_error          ( pc_error_M          ),
        .cp0_status        ( cp0_status_W        ),
        .cp0_cause         ( cp0_cause_W         ),
        .cp0_epc           ( cp0_epc_W           ),
        .pc_M              ( pc_M              ),
        .alu_out_M         ( alu_out_M         ),

        .exception_type    ( exception_type_M    ),
        .flush_exception_M ( flush_exception_M ),
        .pc_exception_M    ( pc_exception_M    ),
        .pc_trap_M         ( pc_trap_M         ),
        .BadVAddr          ( BadVAddr        )
    );

    wire [31:0] cp0_data_out_W;
    wire [31:0] cp0_status_W, cp0_cause_W, cp0_epc_W;
    cp0 u_cp0(
        .clk            ( clk            ),
        .rst            ( rst            ),
        .cp0_en         ( flush_exception_M     ),
        .cp0_we         (  cp0_we        ),
        .cp0_wr_addr    ( rd_M    ),
        .cp0_rd_addr    ( rd_M    ),
        .cp0_data_in    ( rt_data_M    ),       //
        .exception_type ( exception_type_M ),
        .pc_M           ( pc_M           ),
        .is_in_slot_M   ( is_in_slot_M   ),
        .BadVAddr      ( BadVAddr     ),

        .cp0_data_out   ( cp0_data_out_W   ),
        .cp0_status     ( cp0_status_W     ),
        .cp0_cause      ( cp0_cause_W     ),
        .cp0_epc        ( cp0_epc_W        )
    );

    wire [31:0] result_M;
    mux4 mux_mem_to_reg(
        alu_out_M,
        mem_rd_data_M,
        hilo_out_M,
        cp0_data_out_W,
        {hilo_to_reg_M,mem_to_reg_M} | {2{is_mfc_M}},

        result_M
    );
    //
    wire [31:0] pc_W;
    wire [31:0] alu_out_W;
    wire [4:0] wr_reg_W;
    wire       reg_wr_W;
    wire [31:0] mem_rd_data_W;
    wire [31:0] result_W;
    MEM_WB u_MEM_WB(
        .clk           ( clk           ),
        .rst           ( rst           ),
        .stall_W       ( stall_W       ),
        .pc_M          ( pc_M          ),
        .alu_out_M     ( alu_out_M     ),
        .wr_reg_M      ( wr_reg_M      ),
        .reg_wr_M      ( reg_wr_M      ),
        .result_M      ( result_M      ),

        .pc_W          ( pc_W          ),
        .alu_out_W     ( alu_out_W     ),
        .wr_reg_W      ( wr_reg_W      ),
        .reg_wr_W      ( reg_wr_W      ),
        .result_W      ( result_W      )
    );

    //WB





endmodule