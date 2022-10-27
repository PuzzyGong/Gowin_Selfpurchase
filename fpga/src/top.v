`include "define.v"

module top(
    input                               sys_clk                    ,
    input                               sys_rst_n                  ,

    inout                               cmos_scl                   ,//cmos i2c clock
    inout                               cmos_sda                   ,//cmos i2c data
    input                               cmos_vsync                 ,//cmos vsync
    input                               cmos_href                  ,//cmos hsync refrence,data valid
    input                               cmos_pclk                  ,//cmos pxiel clock
    output                              cmos_xclk                  ,//cmos externl clock 
    input              [   7:0]         cmos_db                    ,//cmos data
    output                              cmos_rst_n                 ,//cmos reset 
    output                              cmos_pwdn                  ,//cmos power down

    output             [14-1:0]         ddr_addr                   ,//ROW_WIDTH=14
    output             [ 3-1:0]         ddr_bank                   ,//BANK_WIDTH=3
    output                              ddr_cs                     ,
    output                              ddr_ras                    ,
    output                              ddr_cas                    ,
    output                              ddr_we                     ,
    output                              ddr_ck                     ,
    output                              ddr_ck_n                   ,
    output                              ddr_cke                    ,
    output                              ddr_odt                    ,
    output                              ddr_reset_n                ,
    output             [ 2-1:0]         ddr_dm                     ,//DM_WIDTH=2
    inout              [16-1:0]         ddr_dq                     ,//DQ_WIDTH=16
    inout              [ 2-1:0]         ddr_dqs                    ,//DQS_WIDTH=2
    inout              [ 2-1:0]         ddr_dqs_n                  ,//DQS_WIDTH=2

    output                              O_tmds_clk_p               ,
    output                              O_tmds_clk_n               ,
    output             [   2:0]         O_tmds_data_p              ,//{r,g,b}
    output             [   2:0]         O_tmds_data_n              ,

    output             [   3:0]         state_led                  ,

    input                               rx                         ,
    output                              tx                          
);
assign state_led[3] = 1'b0;
assign state_led[2] = 1'b0;
assign state_led[1] = 1'b0;
assign state_led[0] = 1'b0;

//**************************** interfaces ****************************

wire                                    pre_clk                    ;
wire                                    i_pre_vs                   ;
wire                                    i_pre_de                   ;
wire                   [16-1:0]         i_pre_data                 ;
wire                   [16-1:0]         o_pre_data                 ;
wire                                    o_finish                   ;

wire                                    post_clk                   ;
wire                                    i_post_vs                  ;
wire                                    i_post_de                  ;
wire                   [16-1:0]         i_post_data                ;
wire                   [8-1:0]          o_post_r                   ;
wire                   [8-1:0]          o_post_g                   ;
wire                   [8-1:0]          o_post_b                   ;
wire                                    i_post_camvs               ;

interfaces_top u_interfaces_top(
    .clk                               (sys_clk                   ),
    .rst_n                             (sys_rst_n                 ),
    .cmos_scl                          (cmos_scl                  ),
    .cmos_sda                          (cmos_sda                  ),
    .cmos_vsync                        (cmos_vsync                ),
    .cmos_href                         (cmos_href                 ),
    .cmos_pclk                         (cmos_pclk                 ),
    .cmos_xclk                         (cmos_xclk                 ),
    .cmos_db                           (cmos_db                   ),
    .cmos_rst_n                        (cmos_rst_n                ),
    .cmos_pwdn                         (cmos_pwdn                 ),
    .ddr_addr                          (ddr_addr                  ),
    .ddr_bank                          (ddr_bank                  ),
    .ddr_cs                            (ddr_cs                    ),
    .ddr_ras                           (ddr_ras                   ),
    .ddr_cas                           (ddr_cas                   ),
    .ddr_we                            (ddr_we                    ),
    .ddr_ck                            (ddr_ck                    ),
    .ddr_ck_n                          (ddr_ck_n                  ),
    .ddr_cke                           (ddr_cke                   ),
    .ddr_odt                           (ddr_odt                   ),
    .ddr_reset_n                       (ddr_reset_n               ),
    .ddr_dm                            (ddr_dm                    ),
    .ddr_dq                            (ddr_dq                    ),
    .ddr_dqs                           (ddr_dqs                   ),
    .ddr_dqs_n                         (ddr_dqs_n                 ),
    .O_tmds_clk_p                      (O_tmds_clk_p              ),
    .O_tmds_clk_n                      (O_tmds_clk_n              ),
    .O_tmds_data_p                     (O_tmds_data_p             ),
    .O_tmds_data_n                     (O_tmds_data_n             ),

    .o_pre_clk                         (pre_clk                   ),
    .o_pre_vs                          (i_pre_vs                  ),
    .o_pre_de                          (i_pre_de                  ),
    .o_pre_data                        (i_pre_data                ),
    .i_pre_data                        (o_pre_data                ),
    .i_finish                          (o_finish                  ),

    .o_post_clk                        (post_clk                  ),
    .o_post_vs                         (i_post_vs                 ),
    .o_post_de                         (i_post_de                 ),
    .o_post_data                       (i_post_data               ),
    .i_post_r                          (o_post_r                  ),
    .i_post_g                          (o_post_g                  ),
    .i_post_b                          (o_post_b                  ),
    .o_post_camvs                      (i_post_camvs              ) 
);


//**************************** clk_test **************************** 

wire                   [  31:0]         cnt_1s                     ;

wire                   [   7:0]         fps1                       ;
wire                   [   7:0]         fps2                       ;
wire                   [   7:0]         fps3                       ;

top_test u_top_test(
    .pre_clk                           (pre_clk                   ),
    .post_clk                          (post_clk                  ),
    .sys_rst_n                         (sys_rst_n                 ),
    .i_pre_vs                          (i_pre_vs                  ),
    .i_post_vs                         (i_post_vs                 ),
    .fps1                              (fps1                      ),
    .fps2                              (fps2                      ),
    .fps3                              (fps3                      ),
    .cnt_1s                            (cnt_1s                    )
);


//**************************** uart_sfr ****************************

wire                   [ 255:0]         contains                   ;

`define SFR
`ifdef SFR
uart_sfr u_uart_sfr(
    .sys_clk                           (sys_clk                   ),
    .sys_rst_n                         (sys_rst_n                 ),
    .rx                                (rx                        ),
    .tx                                (tx                        ),
    .o_contains                        (contains                  ) 
);
`else
assign contains = {`RST_VALUE_001F,
                   `RST_VALUE_001E,
                   `RST_VALUE_001D,
                   `RST_VALUE_001C,
                   `RST_VALUE_001B,
                   `RST_VALUE_001A,
                   `RST_VALUE_0019,
                   `RST_VALUE_0018,
                   `RST_VALUE_0017,
                   `RST_VALUE_0016,
                   `RST_VALUE_0015,
                   `RST_VALUE_0014,
                   `RST_VALUE_0013,
                   `RST_VALUE_0012,
                   `RST_VALUE_0011,
                   `RST_VALUE_0010,
                   `RST_VALUE_000F,
                   `RST_VALUE_000E,
                   `RST_VALUE_000D,
                   `RST_VALUE_000C,
                   `RST_VALUE_000B,
                   `RST_VALUE_000A,
                   `RST_VALUE_0009,
                   `RST_VALUE_0008,
                   `RST_VALUE_0007,
                   `RST_VALUE_0006,
                   `RST_VALUE_0005,
                   `RST_VALUE_0004,
                   `RST_VALUE_0003,
                   `RST_VALUE_0002,
                   `RST_VALUE_0001,
                   `RST_VALUE_0000 };
`endif


//**************************** pre ****************************

wire                   [   5:0]         R_0                        ;
wire                   [   5:0]         G_0                        ;
wire                   [   5:0]         B_0                        ;

wire                                    de_1                       ;
wire                   [   5:0]         R_1                        ;
wire                   [   5:0]         G_1                        ;
wire                   [   5:0]         B_1                        ;

wire                                    de_2                       ;
wire                                    wb_2                       ;
wire                   [   5:0]         R_2                        ;
wire                   [   5:0]         G_2                        ;
wire                   [   5:0]         B_2                        ;
wire                   [   5:0]         R_2_process                ;
wire                   [   5:0]         G_2_process                ;
wire                   [   5:0]         B_2_process                ;
wire                   [   5:0]         R_2_raw                    ;
wire                   [   5:0]         G_2_raw                    ;
wire                   [   5:0]         B_2_raw                    ;

wire                                    de_3                       ;
wire                                    wb_3                       ;

//-----
assign R_0 = {i_pre_data[15:11], 1'b0};
assign G_0 =  i_pre_data[10:05]       ;
assign B_0 = {i_pre_data[04:00], 1'b0};

//-----
assign de_1 = i_pre_de;
assign R_1  = R_0;
assign G_1  = G_0;
assign B_1  = B_0;

//-----Delay = 4 + 1
div_color u_div_color(
    .sys_clk                           (pre_clk                   ),
    .sys_rst_n                         (sys_rst_n  &  ~i_pre_vs   ),
    .i_a_R0                            (contains[{'h00,3'b0} +: 6]),
    .i_a_G0                            (contains[{'h01,3'b0} +: 6]),
    .i_a_B0                            (contains[{'h02,3'b0} +: 6]),
    .i_a_err                           (contains[{'h03,3'b0} +: 8]),
    .i_a_Vmin                          (contains[{'h04,3'b0} +: 8]),
    .i_a_Vmax                          (contains[{'h05,3'b0} +: 8]),
    .i_b_R0                            (contains[{'h06,3'b0} +: 6]),
    .i_b_G0                            (contains[{'h07,3'b0} +: 6]),
    .i_b_B0                            (contains[{'h08,3'b0} +: 6]),
    .i_b_err                           (contains[{'h09,3'b0} +: 8]),
    .i_b_Vmin                          (contains[{'h0A,3'b0} +: 8]),
    .i_b_Vmax                          (contains[{'h0B,3'b0} +: 8]),
    .i_valid                           (de_1                      ),
    .i_R                               (R_1                       ),
    .i_G                               (G_1                       ),
    .i_B                               (B_1                       ),
    .o_valid                           (de_2                      ),
    .o_R                               (R_2_process               ),
    .o_G                               (G_2_process               ),
    .o_B                               (B_2_process               ),
    .o_R_raw                           (R_2_raw                   ),
    .o_G_raw                           (G_2_raw                   ),
    .o_B_raw                           (B_2_raw                   ),
    .o_wb                              (wb_2                      ) 
);

assign R_2 = (contains[{'h0C,3'b0} +: 1] == 'b0) ? R_2_raw : R_2_process;
assign G_2 = (contains[{'h0C,3'b0} +: 1] == 'b0) ? G_2_raw : G_2_process;
assign B_2 = (contains[{'h0C,3'b0} +: 1] == 'b0) ? B_2_raw : B_2_process;

//-----Delay = 1
wire                   [   5:0]         R_tmp                      ;
wire                   [   5:0]         G_tmp                      ;
wire                   [   5:0]         B_tmp                      ;
intercept u_intercept(
    .sys_clk                           (pre_clk                   ),
    .sys_rst_n                         (sys_rst_n  &  ~i_pre_vs   ),
    .i_valid                           (de_2                      ),
    .i_R                               (R_2                       ),
    .i_G                               (G_2                       ),
    .i_B                               (B_2                       ),
    .o_valid                           (                          ),
    .o_R                               (R_tmp                     ),
    .o_G                               (G_tmp                     ),
    .o_B                               (B_tmp                     ) 
);
assign o_pre_data = {R_tmp[5:1], G_tmp[5:0], B_tmp[5:1]};

//-----
corrode u_corrode(
    .sys_clk                           (pre_clk                   ),
    .sys_rst_n                         (sys_rst_n  &  ~i_pre_vs   ),
    .i_err                             (contains[{'h0D,3'b0} +: 8]),
    .i_valid                           (de_2                      ),
    .i_wb                              (wb_2                      ),
    .o_valid                           (de_3                      ),
    .o_wb                              (wb_3                      ) 
);

//-----
wire                   [`RECT_NUMMAX * 32 - 1 : 0]  item_1         ;
wire                   [`RECT_NUMMAX * 32 - 1 : 0]  item_2         ;
wire                   [`RECT_NUMMAX *  4 - 1 : 0]  label          ;

div_rect u_div_rect(
    .sys_clk                           (pre_clk                   ),
    .sys_rst_n                         (sys_rst_n  &  ~i_pre_vs   ),
    .item_rst_n                        (sys_rst_n                 ),
    .i_smax                            (contains[{'h0F,3'b0} +: 8]),
    .i_valid                           (de_3                      ),
    .i_wb                              (wb_3                      ),
    .o_finish                          (o_finish                  ),
    .o_item                            (item_1                    ) 
);


//**************************** post ****************************

wire                                    en_1                       ;
wire                   [  15:0]         data_1                     ;
wire                   [  15:0]         data_1_process             ;
wire                   [  15:0]         data_1_raw                 ;

wire                                    en_2                       ;
wire                   [  15:0]         data_2                     ;
wire                   [  15:0]         data_2_process             ;
wire                   [  15:0]         data_2_raw                 ;

wire                                    en_3                       ;
wire                   [  15:0]         data_3                     ;
wire                   [  15:0]         data_3_process             ;
wire                   [  15:0]         data_3_raw                 ;

wire                                    en_4                       ;
wire                   [  15:0]         data_4                     ;
wire                                    en_5                       ;
wire                   [  23:0]         data_5                     ;
wire                                    en_6                       ;
wire                   [  23:0]         data_6                     ;
wire                                    en_7                       ;
wire                   [  23:0]         data_7                     ;
wire                                    en_8                       ;
wire                   [  23:0]         data_8                     ;

//-----Delay = 5
wire                   [   7:0]         num                        ;
wire                   [   7:0]         money                      ;
wire                   [   7:0]         user                       ;
wire                   [   7:0]         payment                    ;
wire                   [   2:0]         pattern                    ;

conv_show u_conv_show(
    .sys_clk                           (post_clk                  ),
    .sys_rst_n                         (sys_rst_n  &  i_post_vs   ),
    .item_rst_n                        (sys_rst_n                 ),
    .i_RGB_err                         (contains[{'h11,3'b0} +: 8]),
    .i_RGB_Vmin                        (contains[{'h12,3'b0} +: 8]),
    .i_RGB_Vmax                        (contains[{'h13,3'b0} +: 8]),
    .i_YELLOW_err                      (contains[{'h14,3'b0} +: 8]),
    .i_YELLOW_Vmin                     (contains[{'h15,3'b0} +: 8]),
    .i_YELLOW_Vmax                     (contains[{'h16,3'b0} +: 8]),
    .i_WB_threshold                    (contains[{'h17,3'b0} +: 8]),
    .i_item                            (item_1                    ),
    .o_item                            (item_2                    ),
    .o_label                           (label                     ),
    .o_num                             (num                       ),
    .o_money                           (money                     ),
    .i_user                            (contains[{'h10,3'b0} +: 8]),
    .o_user                            (user                      ),
    .o_payment                         (payment                   ),
    .o_pattern                         (pattern                   ),
    .i_post_camvs                      (i_post_camvs              ),
    .i_valid                           (i_post_de                 ),
    .i_data                            (i_post_data               ),
    .o_valid                           (en_1                      ),
    .o_data                            (data_1_process            ),
    .o_data_raw                        (data_1_raw                ) 
);
assign data_1 = (contains[{'h18,3'b0} +: 1] == 'b0) ? data_1_raw : data_1_process;

//-----Delay = 0
`define SAMPLE_SHOW
`ifdef SAMPLE_SHOW
sample_show u_sample_show(
    .sys_clk                           (post_clk                  ),
    .sys_rst_n                         (sys_rst_n  &  i_post_vs   ),
    .i_item                            (item_2                    ),
    .i_valid                           (en_1                      ),
    .i_data                            (data_1                    ),
    .o_valid                           (en_2                      ),
    .o_data                            (data_2_process            ),
    .o_data_raw                        (data_2_raw                ) 
); 
`else
assign en_2 = en_1;
assign data_2_raw = data_1;
assign data_2_process = data_1;
`endif

assign data_2 = (contains[{'h19,3'b0} +: 1] == 'b0) ? data_2_raw : data_2_process;

//-----Delay = 2
show_corrode u_show_corrode(
    .sys_clk_1                         (pre_clk                   ),
    .sys_clk_2                         (post_clk                  ),
    .sys_rst_n_1                       (sys_rst_n  &  ~i_pre_vs   ),
    .sys_rst_n_2                       (sys_rst_n  &  i_post_vs   ),
    .i_pre_valid                       (de_3                      ),
    .i_pre_wb                          (wb_3                      ),
    .i_valid                           (en_2                      ),
    .i_data                            (data_2                    ),
    .o_valid                           (en_3                      ),
    .o_data                            (data_3_process            ),
    .o_data_raw                        (data_3_raw                ) 
);
assign data_3 = (contains[{'h0E,3'b0} +: 1] == 'b0) ? data_3_raw : data_3_process;


//-----Delay = 3
show_rect_ascii u_show_rect_ascii(
    .sys_clk                           (post_clk                  ),
    .sys_rst_n                         (sys_rst_n  &  i_post_vs   ),
    .i_label                           (64'b0                     ),
    .i_item                            (item_2                    ),
    .i_otheritem                       (512'b0                    ),
    .i_varies                          (128'b0                    ),
    .i_valid                           (en_3                      ),
    .i_data                            (data_3                    ),
    .o_valid                           (en_4                      ),
    .o_data                            (data_4                    ),
    .o_data_raw                        (                          )
);

//-----Delay = 5
show_character u_show_character(
    .sys_clk                           (post_clk                  ),
    .sys_rst_n                         (sys_rst_n  &  i_post_vs   ),
    .i_label                           (label                     ),
    .i_item                            (item_2                    ),
    .i_valid                           (en_4                      ),
    .i_data                            ({data_4[15:11], 3'd0, data_4[10:5], 2'd0, data_4[4:0], 3'd0}),
    .o_valid                           (en_5                      ),
    .o_data                            (data_5                    ) 
);

//-----Delay = 5
show_varies u_show_varies(
    .sys_clk                           (post_clk                  ),
    .sys_rst_n                         (sys_rst_n  &  i_post_vs   ),
    .i_valid                           (en_5                      ),
    .i_data                            (data_5                    ),
    .o_valid                           (en_6                      ),
    .o_data                            (data_6                    ) 
);

//-----Delay = 5
show_ascii u_show_ascii(
    .sys_clk                           (post_clk                  ),
    .sys_rst_n                         (sys_rst_n  &  i_post_vs   ),
    .i_varies                          ({fps1, fps2, fps3, num, money, user, payment, 72'd0}),
    .i_valid                           (en_6                      ),
    .i_data                            (data_6                    ),
    .o_valid                           (en_7                      ),
    .o_data                            (data_7                    ) 
);

//-----Delay = 5
show_picture u_show_picture(
    .sys_clk                           (post_clk                  ),
    .sys_rst_n                         (sys_rst_n  &  i_post_vs   ),
    .i_pattern                         (pattern                   ),
    .i_valid                           (en_7                      ),
    .i_data                            (data_7                    ),
    .o_valid                           (en_8                      ),
    .o_data                            (data_8                    ) 
);


assign o_post_r = data_8[2 * 8 +: 8];
assign o_post_g = data_8[1 * 8 +: 8];
assign o_post_b = data_8[0 * 8 +: 8];


endmodule