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
reg                    [16-1:0]         o_post_data                ;
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
    .i_post_data                       (o_post_data               ),
    .o_post_camvs                      (i_post_camvs              ) 
);


//**************************** clk_test **************************** 

wire                   [  31:0]         cnt_1s                     ;

wire                   [   7:0]         fps1                       ;
wire                   [   7:0]         fps2                       ;

top_test u_top_test(
    .pre_clk                           (pre_clk                   ),
    .post_clk                          (post_clk                  ),
    .sys_rst_n                         (sys_rst_n                 ),
    .i_pre_vs                          (i_pre_vs                  ),
    .i_post_vs                         (i_post_vs                 ),
    .fps1                              (fps1                      ),
    .fps2                              (fps2                      ),
    .cnt_1s                            (cnt_1s                    )
);


//**************************** uart_sfr ****************************

wire                   [ 255:0]         contains               ;
uart_sfr u_uart_sfr(
    .sys_clk                           (sys_clk                   ),
    .sys_rst_n                         (sys_rst_n                 ),
    .rx                                (rx                        ),
    .tx                                (tx                        ),
    .o_contains                        (contains              ) 
);


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
wire        [`RECT_NUMMAX * 32 - 1 : 0] item                       ;
wire        [`RECT_NUMMAX * 32 - 1 : 0] item_                      ;
div_rect u_div_rect(
    .sys_clk                           (pre_clk                   ),
    .sys_rst_n                         (sys_rst_n  &  ~i_pre_vs   ),
    .item_rst_n                        (sys_rst_n                 ),
    .i_smax                            (contains[{'h0F,3'b0} +: 8]),
    .i_valid                           (de_3                      ),
    .i_wb                              (wb_3                      ),
    .o_finish                          (o_finish                  ),
    .o_item                            (item                      ) 
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

wire                   [  15:0]         data_3_process             ;
wire                   [  15:0]         data_3_raw                 ;

//-----Delay = 2
show_corrode u_show_corrode(
    .sys_clk_1                         (pre_clk                   ),
    .sys_clk_2                         (post_clk                  ),
    .sys_rst_n_1                       (sys_rst_n  &  ~i_pre_vs   ),
    .sys_rst_n_2                       (sys_rst_n  &  i_post_vs   ),
    .i_valid_1                         (de_3                      ),
    .i_wb_1                            (wb_3                      ),
    .i_valid                           (i_post_de                 ),
    .i_data                            (i_post_data               ),
    .o_valid                           (en_1                      ),
    .o_data                            (data_1_process            ),
    .o_data_raw                        (data_1_raw                ) 
);
assign data_1 = (contains[{'h0E,3'b0} +: 1] == 'b0) ? data_1_raw : data_1_process;

//-----Delay = 4 + 1
conv u_conv(
    .sys_clk_1                         (pre_clk                   ),
    .sys_clk_2                         (post_clk                  ),
    .sys_rst_n_1                       (sys_rst_n  &  ~i_pre_vs   ),
    .sys_rst_n_2                       (sys_rst_n  &  i_post_vs   ),
    .item_rst_n                        (sys_rst_n                 ),
    .i_RGB_err                         (contains[{'h11,3'b0} +: 8]),
    .i_RGB_Vmin                        (contains[{'h12,3'b0} +: 8]),
    .i_RGB_Vmax                        (contains[{'h13,3'b0} +: 8]),
    .i_YELLOW_err                      (contains[{'h14,3'b0} +: 8]),
    .i_YELLOW_Vmin                     (contains[{'h15,3'b0} +: 8]),
    .i_YELLOW_Vmax                     (contains[{'h16,3'b0} +: 8]),
    .i_WB_threshold                    (contains[{'h17,3'b0} +: 8]),
    .item                              (item                      ),
    .o_item                            (item_                     ),
    .i_post_camvs                      (1'b1                      ),
    .i_valid                           (en_1                      ),
    .i_data                            (data_1                    ),
    .o_valid                           (en_2                      ),
    .o_data                            (data_2_process            ),
    .o_data_raw                        (data_2_raw                ) 
);
assign data_2 = (contains[{'h18,3'b0} +: 1] == 'b0) ? data_2_raw : data_2_process;

//-----Delay = 3 + 1
show_rect_ascii u_show_rect_ascii(
    .sys_clk                           (post_clk                  ),
    .sys_rst_n                         (sys_rst_n                 ),
    .i_start                           (o_finish                  ),
    .i_head_wire                       (item                      ),
    .i_hair_wire                       (item_                     ),
    //.i_hair_wire                       ({448'd0,   fps1,8'd025,8'd150,8'd050,  8'd150,8'd050,8'd200,8'd100}),
    .i_posi_wire                       (128'd0                    ),
    .i_varies                          ({80'd0,    8'd213,8'd123,8'd222,       8'd000,fps2,fps1}),
    .i_vs                              (i_post_vs                 ),
    .i_valid                           (en_2                      ),
    .i_data                            (data_2                    ),
    .o_valid                           (                          ),
    .o_data                            (data_3_process            ),
    .o_data_raw                        (data_3_raw                )
);

always@(posedge post_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        o_post_data <= 'b0;
    else if(contains[{'h10,3'b0} +: 3] == 3'b000)
        o_post_data <=  data_1_raw;
    else if(contains[{'h10,3'b0} +: 3] == 3'b001)
        o_post_data <=  data_1_process;
    else if(contains[{'h10,3'b0} +: 3] == 3'b010)
        o_post_data <=  data_2_raw;
    else if(contains[{'h10,3'b0} +: 3] == 3'b011)
        o_post_data <=  data_2_process;
    else if(contains[{'h10,3'b0} +: 3] == 3'b100)
        o_post_data <=  data_3_raw;
    else if(contains[{'h10,3'b0} +: 3] == 3'b101)
        o_post_data <=  data_3_process;
    else
        o_post_data <=  i_post_data;


endmodule