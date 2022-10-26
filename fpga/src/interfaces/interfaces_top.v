module interfaces_top
(
    input                               clk                        ,
    input                               rst_n                      ,

//camera
    inout                               cmos_scl                   ,
    inout                               cmos_sda                   ,
    input                               cmos_vsync                 ,
    input                               cmos_href                  ,
    input                               cmos_pclk                  ,
    output                              cmos_xclk                  ,
    input              [   7:0]         cmos_db                    ,
    output                              cmos_rst_n                 ,
    output                              cmos_pwdn                  ,
	
//ddr3
    output             [14-1:0]         ddr_addr                   ,
    output             [ 3-1:0]         ddr_bank                   ,
    output                              ddr_cs                     ,
    output                              ddr_ras                    ,
    output                              ddr_cas                    ,
    output                              ddr_we                     ,
    output                              ddr_ck                     ,
    output                              ddr_ck_n                   ,
    output                              ddr_cke                    ,
    output                              ddr_odt                    ,
    output                              ddr_reset_n                ,
    output             [ 2-1:0]         ddr_dm                     ,
    inout              [16-1:0]         ddr_dq                     ,
    inout              [ 2-1:0]         ddr_dqs                    ,
    inout              [ 2-1:0]         ddr_dqs_n                  ,

//hdmi
    output                              O_tmds_clk_p               ,
    output                              O_tmds_clk_n               ,
    output             [   2:0]         O_tmds_data_p              ,
    output             [   2:0]         O_tmds_data_n              ,


//-----
//pre
    output                              o_pre_clk                  ,
    output                              o_pre_vs                   ,
    output                              o_pre_de                   ,
    output             [16-1:0]         o_pre_data                 ,
    input              [16-1:0]         i_pre_data                 ,

    input                               i_finish                   ,

//post
    output                              o_post_clk                 ,
    output                              o_post_vs                  ,
    output                              o_post_de                  ,
    output             [16-1:0]         o_post_data                ,
    input              [8-1:0]          i_post_r                   ,
    input              [8-1:0]          i_post_g                   ,
    input              [8-1:0]          i_post_b                   ,

    output reg                          o_post_camvs                
);

//**************************** PLL ****************************

cmos_pll cmos_pll_m0
(
    .clkin                             (clk                       ),
    .clkout                            (cmos_clk                  ) 
);

mem_pll mem_pll_m0
(
    .clkin                             (clk                       ),
    .clkout                            (memory_clk                ),
    .lock                              (DDR_pll_lock              ) 
);

TMDS_rPLL u_tmds_rpll
(   .clkin                             (clk                       ),
    .clkout                            (serial_clk                ),
    .lock                              (TMDS_DDR_pll_lock         ) 
);
assign hdmi4_rst_n = rst_n & TMDS_DDR_pll_lock;

CLKDIV u_clkdiv
(
    .RESETN                            (hdmi4_rst_n               ),
    .HCLKIN                            (serial_clk                ),
    .CLKOUT                            (video_clk                 ),
    .CALIB                             (1'b1                      ) 
);
defparam u_clkdiv.DIV_MODE      =   "5";
defparam u_clkdiv.GSREN         =   "false";


//**************************** CAMERA ****************************

//-----CAMERA_INIT
assign cmos_xclk = cmos_clk;
assign cmos_pwdn = 1'b0;
assign cmos_rst_n = 1'b1;

wire                   [   9:0]         lut_index                  ;
wire                   [  31:0]         lut_data                   ;
i2c_config i2c_config_m0(
    .rst                               (~rst_n                    ),
    .clk                               (clk                       ),
    .clk_div_cnt                       (16'd270                   ),
    .i2c_addr_2byte                    (1'b1                      ),
    .lut_index                         (lut_index                 ),
    .lut_dev_addr                      (lut_data[31:24]           ),
    .lut_reg_addr                      (lut_data[23:8]            ),
    .lut_reg_data                      (lut_data[7:0]             ),
    .error                             (                          ),
    .done                              (                          ),
    .i2c_scl                           (cmos_scl                  ),
    .i2c_sda                           (cmos_sda                  ) 
);
lut_ov5640_rgb565_1024_768 lut_ov5640_rgb565_1024_768_m0(
    .lut_index                         (lut_index                 ),
    .lut_data                          (lut_data                  ) 
);

//-----CAMERA_READ
wire                   [  15:0]         cmos_16bit_data            ;
cmos_8_16bit cmos_8_16bit_m0(
    .rst                               (~rst_n                    ),
    .pclk                              (cmos_pclk                 ),
    .pdata_i                           (cmos_db                   ),
    .de_i                              (cmos_href                 ),
    .pdata_o                           (cmos_16bit_data           ),
    .hblank                            (o_pre_de                  ),
    .de_o                              (o_pre_clk                 ) 
);

assign o_pre_data = {cmos_16bit_data[4:0],cmos_16bit_data[10:5],cmos_16bit_data[15:11]};
assign o_pre_vs = cmos_vsync;

//-----delay clocks -- from CAMERA to VFB
localparam                              PRE_DELAY = 6              ;
                          
reg                    [PRE_DELAY-1:0]  pre_vs_dn                  ;
reg                    [PRE_DELAY-1:0]  pre_de_dn                  ;

always@(posedge o_pre_clk or negedge rst_n)
begin
    if(!rst_n)
        begin
            pre_vs_dn  <= {PRE_DELAY{1'b1}};
            pre_de_dn  <= {PRE_DELAY{1'b0}};
        end
    else
        begin
            pre_vs_dn  <= {pre_vs_dn[PRE_DELAY-2:0], o_pre_vs};
            pre_de_dn  <= {pre_de_dn[PRE_DELAY-2:0], o_pre_de};
        end
end


//**************************** SYN_GEN ****************************

wire                                    post_hs                    ;
wire                                    post_vs                    ;
wire                                    post_de                    ;
vga_timing vga_timing_m0
(
    .clk                               (video_clk                 ),
    .rst                               (~rst_n                    ),


    .hs                                (post_hs                   ),
    .vs                                (post_vs                   ),
    .de                                (post_de                   ) 
);

//-----delay clocks -- from SYN_GEN to POST&HDMI
localparam                              IN_DELAY = 5               ;
localparam                              OUT_DELAY = 30             ;
localparam                              TOTAL_DELAY = IN_DELAY + OUT_DELAY;
                          
reg                    [TOTAL_DELAY-1:0]post_hs_dn                 ;
reg                    [TOTAL_DELAY-1:0]post_vs_dn                 ;
reg                    [TOTAL_DELAY-1:0]post_de_dn                 ;

always@(posedge video_clk or negedge rst_n)
begin
    if(!rst_n)
        begin
            post_hs_dn  <= {TOTAL_DELAY{1'b1}};
            post_vs_dn  <= {TOTAL_DELAY{1'b1}};
            post_de_dn  <= {TOTAL_DELAY{1'b0}};
        end
    else
        begin
            post_hs_dn  <= {post_hs_dn[TOTAL_DELAY-2:0],post_hs};
            post_vs_dn  <= {post_vs_dn[TOTAL_DELAY-2:0],post_vs};
            post_de_dn  <= {post_de_dn[TOTAL_DELAY-2:0],post_de};
        end
end

assign o_post_clk                = video_clk;
assign o_post_vs                 = post_vs_dn[IN_DELAY-1];
assign o_post_de                 = post_de_dn[IN_DELAY-1];


//**************************** DDR3 ****************************

//According to IP parameters to choose
`define        WR_VIDEO_WIDTH_16
`define    DEF_WR_VIDEO_WIDTH 16

`define        RD_VIDEO_WIDTH_16
`define    DEF_RD_VIDEO_WIDTH 16

`define    USE_THREE_FRAME_BUFFER

`define    DEF_ADDR_WIDTH 28
`define    DEF_SRAM_DATA_WIDTH 128

    parameter                           ADDR_WIDTH          = `DEF_ADDR_WIDTH;//存储单元是byte，总容量=2^27*16bit = 2Gbit,增加1位rank地址，{rank[0],bank[2:0],row[13:0],cloumn[9:0]}
    parameter                           DATA_WIDTH          = `DEF_SRAM_DATA_WIDTH;//与生成DDR3IP有关，此ddr3 2Gbit, x16， 时钟比例1:4 ，则固定128bit
    parameter                           WR_VIDEO_WIDTH      = `DEF_WR_VIDEO_WIDTH;
    parameter                           RD_VIDEO_WIDTH      = `DEF_RD_VIDEO_WIDTH;

//-----               
wire                                        off0_syn_de                ;
wire                   [RD_VIDEO_WIDTH-1:0] off0_syn_data              ;

wire                                        dma_clk                    ;
wire                                        cmd_ready                  ;
wire                   [   2:0]             cmd                        ;
wire                                        cmd_en                     ;
wire                   [   5:0]             app_burst_number           ;
wire                   [ADDR_WIDTH-1:0]     addr                       ;
wire                                        wr_data_rdy                ;
wire                                        wr_data_en                 ;//
wire                                        wr_data_end                ;//
wire                   [DATA_WIDTH-1:0]     wr_data                    ;
wire                   [DATA_WIDTH/8-1:0]   wr_data_mask               ;
wire                                        rd_data_valid              ;
wire                                        rd_data_end                ;//unused 
wire                   [DATA_WIDTH-1:0]     rd_data                    ;
wire                                        init_calib_complete        ;

Video_Frame_Buffer_Top Video_Frame_Buffer_Top_inst
(
    .I_rst_n                           (init_calib_complete       ),//rst_n            ),
    .I_dma_clk                         (dma_clk                   ),//sram_clk         ),
`ifdef USE_THREE_FRAME_BUFFER
    .I_wr_halt                         (1'd0                      ),//1:halt,  0:no halt
    .I_rd_halt                         (1'd0                      ),//1:halt,  0:no halt
`endif
    // video data input             
    .I_vin0_clk                        (o_pre_clk                 ),
    .I_vin0_vs_n                       (~pre_vs_dn[PRE_DELAY-1]   ),//只接收负极性
    .I_vin0_de                         (pre_de_dn[PRE_DELAY-1]    ),
    .I_vin0_data                       (i_pre_data                ),
    .O_vin0_fifo_full                  (                          ),
    // video data output            
    .I_vout0_clk                       (video_clk                 ),
    .I_vout0_vs_n                      (post_vs                   ),//只接收负极性
    .I_vout0_de                        (post_de                   ),
    .O_vout0_den                       (off0_syn_de               ),
    .O_vout0_data                      (off0_syn_data             ),
    .O_vout0_fifo_empty                (                          ),
    // ddr write request
    .I_cmd_ready                       (cmd_ready                 ),
    .O_cmd                             (cmd                       ),//0:write;  1:read
    .O_cmd_en                          (cmd_en                    ),
    .O_app_burst_number                (app_burst_number          ),
    .O_addr                            (addr                      ),//[ADDR_WIDTH-1:0]
    .I_wr_data_rdy                     (wr_data_rdy               ),
    .O_wr_data_en                      (wr_data_en                ),//
    .O_wr_data_end                     (wr_data_end               ),//
    .O_wr_data                         (wr_data                   ),//[DATA_WIDTH-1:0]
    .O_wr_data_mask                    (wr_data_mask              ),
    .I_rd_data_valid                   (rd_data_valid             ),
    .I_rd_data_end                     (rd_data_end               ),//unused 
    .I_rd_data                         (rd_data                   ),//[DATA_WIDTH-1:0]
    .I_init_calib_complete             (init_calib_complete       ) 
);

DDR3MI DDR3_Memory_Interface_Top_inst
(
    .clk                               (video_clk                 ),
    .memory_clk                        (memory_clk                ),
    .pll_lock                          (DDR_pll_lock              ),
    .rst_n                             (rst_n                     ),//rst_n
    .app_burst_number                  (app_burst_number          ),
    .cmd_ready                         (cmd_ready                 ),
    .cmd                               (cmd                       ),
    .cmd_en                            (cmd_en                    ),
    .addr                              (addr                      ),
    .wr_data_rdy                       (wr_data_rdy               ),
    .wr_data                           (wr_data                   ),
    .wr_data_en                        (wr_data_en                ),
    .wr_data_end                       (wr_data_end               ),
    .wr_data_mask                      (wr_data_mask              ),
    .rd_data                           (rd_data                   ),
    .rd_data_valid                     (rd_data_valid             ),
    .rd_data_end                       (rd_data_end               ),
    .sr_req                            (1'b0                      ),
    .ref_req                           (1'b0                      ),
    .sr_ack                            (                          ),
    .ref_ack                           (                          ),
    .init_calib_complete               (init_calib_complete       ),
    .clk_out                           (dma_clk                   ),
    .burst                             (1'b1                      ),
    // mem interface
    .ddr_rst                           (                          ),
    .O_ddr_addr                        (ddr_addr                  ),
    .O_ddr_ba                          (ddr_bank                  ),
    .O_ddr_cs_n                        (ddr_cs                    ),
    .O_ddr_ras_n                       (ddr_ras                   ),
    .O_ddr_cas_n                       (ddr_cas                   ),
    .O_ddr_we_n                        (ddr_we                    ),
    .O_ddr_clk                         (ddr_ck                    ),
    .O_ddr_clk_n                       (ddr_ck_n                  ),
    .O_ddr_cke                         (ddr_cke                   ),
    .O_ddr_odt                         (ddr_odt                   ),
    .O_ddr_reset_n                     (ddr_reset_n               ),
    .O_ddr_dqm                         (ddr_dm                    ),
    .IO_ddr_dq                         (ddr_dq                    ),
    .IO_ddr_dqs                        (ddr_dqs                   ),
    .IO_ddr_dqs_n                      (ddr_dqs_n                 ) 
);

assign  o_post_data = off0_syn_de ? off0_syn_data[15:0] : 16'h0000;


//**************************** HDMI ****************************

DVI_TX_Top DVI_TX_Top_inst
(
    .I_rst_n                           (hdmi4_rst_n               ),
    .I_serial_clk                      (serial_clk                ),
    .I_rgb_clk                         (video_clk                 ),
    .I_rgb_vs                          (post_vs_dn[TOTAL_DELAY-1] ),
    .I_rgb_hs                          (post_hs_dn[TOTAL_DELAY-1] ),
    .I_rgb_de                          (post_de_dn[TOTAL_DELAY-1] ),
    .I_rgb_r                           (i_post_r                  ),
    .I_rgb_g                           (i_post_g                  ),
    .I_rgb_b                           (i_post_b                  ),

    .O_tmds_clk_p                      (O_tmds_clk_p              ),
    .O_tmds_clk_n                      (O_tmds_clk_n              ),
    .O_tmds_data_p                     (O_tmds_data_p             ),
    .O_tmds_data_n                     (O_tmds_data_n             ) 
);


//**************************** i_finish && o_post_camvs ****************************

//----- i_finish 在最大为 50Hz 的时钟域，o_post_camvs 在 65Hz 的时钟域，可以直接用 clk_65Hz 捕获 i_finish 信号

reg                    [   3:0]         state                      ;
localparam                              WAIT_FOR__o_post_vs__TURN_LOW       = 4'b0001;
localparam                              WAIT_FOR__o_post_vs__TURN_HIGH      = 4'b0010;
localparam                              WAIT_FOR__o_post_vs__TURN_LOW_AGAIN = 4'b0100;
localparam                              WAIT_FOR__i_finish__TURN_HIGH       = 4'b1000;


always@(posedge o_post_clk or negedge rst_n)
    if(rst_n == 'b0) begin
        state <= WAIT_FOR__i_finish__TURN_HIGH;
        o_post_camvs <= 'b0;
    end
    else if(state == WAIT_FOR__i_finish__TURN_HIGH && i_finish == 1'b1) begin
        state <= WAIT_FOR__o_post_vs__TURN_LOW;
        o_post_camvs <= 'b0;
    end
    else if(state == WAIT_FOR__o_post_vs__TURN_LOW && o_post_vs == 1'b0) begin
        state <= WAIT_FOR__o_post_vs__TURN_HIGH;
        o_post_camvs <= 'b1;
    end    
    else if(state == WAIT_FOR__o_post_vs__TURN_HIGH && o_post_vs == 1'b1) begin
        state <= WAIT_FOR__o_post_vs__TURN_LOW_AGAIN;
        o_post_camvs <= 'b1;
    end        
    else if(state == WAIT_FOR__o_post_vs__TURN_LOW_AGAIN && o_post_vs == 1'b0) begin
        state <= WAIT_FOR__i_finish__TURN_HIGH;
        o_post_camvs <= 'b0;
    end


endmodule