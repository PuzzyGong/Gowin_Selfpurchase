`include "../define.v"

module conv_show
#(
    parameter                           C_W = `COLOR_WIDTH         ,

    parameter                           P_W = `POSITION_WIDTH
)
(
    input  wire                         sys_clk                    ,
    input  wire                         sys_rst_n                  ,
    input  wire                         item_rst_n                 ,

    input  wire        [C_W+2-1:0]      i_RGB_err                  ,
    input  wire        [C_W+2-1:0]      i_RGB_Vmin                 ,
    input  wire        [C_W+2-1:0]      i_RGB_Vmax                 ,
    input  wire        [C_W+2-1:0]      i_YELLOW_err               ,
    input  wire        [C_W+2-1:0]      i_YELLOW_Vmin              ,
    input  wire        [C_W+2-1:0]      i_YELLOW_Vmax              ,
    input  wire        [C_W+2-1:0]      i_WB_threshold             ,

    input  wire        [`RECT_NUMMAX * 32 - 1 : 0] i_item          ,
    output reg         [`RECT_NUMMAX * 32 - 1 : 0] o_item          ,
    output reg         [`RECT_NUMMAX * 4 - 1 : 0] o_label          ,

    output reg         [   7:0]         o_num                      ,
    output reg         [   7:0]         o_money                    ,
    input  wire        [   7:0]         i_user                     ,
    output reg         [   7:0]         o_user                     ,
    output reg         [   7:0]         o_payment                  ,
    output reg         [   2:0]         o_pattern                  ,

    input  wire                         i_post_camvs               ,
    input  wire                         i_valid                    ,
    input  wire        [16-1:0]         i_data                     ,
    output reg                          o_valid                    ,
    output reg         [16-1:0]         o_data                     ,
    output reg         [16-1:0]         o_data_raw 
);

//******************** POST 线 ********************

//*************** 同步信号 ***************
//----- 第 1~4 层
reg                                     valid_1                    ;
reg                                     valid_2                    ;
reg                                     valid_3                    ;
reg                                     valid_4                    ;
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)begin
        valid_1 <= 'd0;
        valid_2 <= 'd0;
        valid_3 <= 'd0;
        valid_4 <= 'd0;
    end
    else begin
        valid_1 <= i_valid;
        valid_2 <= valid_1;
        valid_3 <= valid_2;
        valid_4 <= valid_3;
    end

//-----
reg                    [P_W-1:0]        cnt_x_3                    ;
reg                    [P_W-1:0]        cnt_y_3                    ;
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)begin
        cnt_x_3 <= 'b0;
        cnt_y_3 <= 'b0;
    end
    else if(valid_3 == 1'b1)
        if(cnt_x_3 == `OV5640_X - 1) begin
            cnt_x_3 <= 'b0;
            if(cnt_y_3 == `OV5640_Y - 1)
                cnt_y_3 <= 'b0;
            else
                cnt_y_3 <= cnt_y_3 + 1'b1;
        end
        else
            cnt_x_3 <= cnt_x_3 + 1'b1;

//-----
reg                    [P_W-1:0]        cnt_x_4                    ;
reg                    [P_W-1:0]        cnt_y_4                    ;
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)begin
        cnt_x_4 <= 'b0;
        cnt_y_4 <= 'b0;
    end
    else begin
        cnt_x_4 <= cnt_x_3;
        cnt_y_4 <= cnt_y_3;
    end

reg                                     inpic_4                    ;
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0) begin
        inpic_4 <= 'b0;
    end
    else if(valid_3 == 1'b1 && cnt_x_3 >= `PIC_X1 && cnt_x_3 <= `PIC_X2 && cnt_y_3 >= `PIC_Y1 && cnt_y_3 <= `PIC_Y2)
        inpic_4 <= 1'b1;
    else
        inpic_4 <= 1'b0;

//-----
reg                    [P_W-1:0]        cnt_x_5                    ;
reg                    [P_W-1:0]        cnt_y_5                    ;
reg                                     inpic_5                    ;
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)begin
        cnt_x_5 <= 'b0;
        cnt_y_5 <= 'b0;
        inpic_5 <= 'b0;
    end
    else begin
        cnt_x_5 <= cnt_x_4;
        cnt_y_5 <= cnt_y_4;
        inpic_5 <= inpic_4;
    end


//*************** 颜色信号 ***************
//----- 第 1~4 层
//RED -> GREEN; GREEN -> BLUE; BLUE -> RED; YELLOW -> GRAY; BLACK -> WHITE; WHITE -> BLACK; 
wire                                    RED____valid               ;
wire                   [C_W-1:0]        RED____R                   ;
wire                   [C_W-1:0]        RED____G                   ;
wire                   [C_W-1:0]        RED____B                   ;
wire                   [C_W-1:0]        RED____R_raw               ;
wire                   [C_W-1:0]        RED____G_raw               ;
wire                   [C_W-1:0]        RED____B_raw               ;
wire                                    RED____wb                  ;
wire                   [  15:0]         RED____RGB                 ;
wire                                    BLUE___valid               ;
wire                   [C_W-1:0]        BLUE___R                   ;
wire                   [C_W-1:0]        BLUE___G                   ;
wire                   [C_W-1:0]        BLUE___B                   ;
wire                   [C_W-1:0]        BLUE___R_raw               ;
wire                   [C_W-1:0]        BLUE___G_raw               ;
wire                   [C_W-1:0]        BLUE___B_raw               ;
wire                                    BLUE___wb                  ;
wire                   [  15:0]         BLUE___RGB                 ;
wire                                    GREEN__valid               ;
wire                   [C_W-1:0]        GREEN__R                   ;
wire                   [C_W-1:0]        GREEN__G                   ;
wire                   [C_W-1:0]        GREEN__B                   ;
wire                   [C_W-1:0]        GREEN__R_raw               ;
wire                   [C_W-1:0]        GREEN__G_raw               ;
wire                   [C_W-1:0]        GREEN__B_raw               ;
wire                                    GREEN__wb                  ;
wire                   [  15:0]         GREEN__RGB                 ;
wire                                    YELLOW_valid               ;
wire                   [C_W-1:0]        YELLOW_R                   ;
wire                   [C_W-1:0]        YELLOW_G                   ;
wire                   [C_W-1:0]        YELLOW_B                   ;
wire                   [C_W-1:0]        YELLOW_R_raw               ;
wire                   [C_W-1:0]        YELLOW_G_raw               ;
wire                   [C_W-1:0]        YELLOW_B_raw               ;
wire                                    YELLOW_wb                  ;
wire                   [  15:0]         YELLOW_RGB                 ;

wire                   [   5:0]         i_R                        ;
wire                   [   5:0]         i_G                        ;
wire                   [   5:0]         i_B                        ;
assign i_R = {i_data[15:11], 1'b0};
assign i_G =  i_data[10:05]       ;
assign i_B = {i_data[04:00], 1'b0};

//RED
div_color_HSV
#(
    .BLACK_COLOR                       (16'b00000_100000_00000    )
)
u1_div_color_HSV(
    .sys_clk                           (sys_clk                 ),
    .sys_rst_n                         (sys_rst_n               ),
    .i_R0                              (6'b111111                 ),
    .i_G0                              (6'b000000                 ),
    .i_B0                              (6'b000000                 ),
    .i_err                             (i_RGB_err                 ),
    .i_Vmin                            (i_RGB_Vmin                ),
    .i_Vmax                            (i_RGB_Vmax                ),
    .i_valid                           (i_valid                   ),
    .i_R                               (i_R                       ),
    .i_G                               (i_G                       ),
    .i_B                               (i_B                       ),
    .o_valid                           (RED____valid              ),
    .o_R                               (RED____R                  ),
    .o_G                               (RED____G                  ),
    .o_B                               (RED____B                  ),
    .o_R_raw                           (RED____R_raw              ),
    .o_G_raw                           (RED____G_raw              ),
    .o_B_raw                           (RED____B_raw              ),
    .o_wb                              (RED____wb                 ) 
);
assign RED____RGB = {RED____R[5:1], RED____G[5:0], RED____B[5:1]};

//GREEN
div_color_HSV
#(
    .BLACK_COLOR                       (16'b00000_000000_10000    )
)
u2_div_color_HSV(
    .sys_clk                           (sys_clk                   ),
    .sys_rst_n                         (sys_rst_n                 ),
    .i_R0                              (6'b000000                 ),
    .i_G0                              (6'b111111                 ),
    .i_B0                              (6'b000000                 ),
    .i_err                             (i_RGB_err                 ),
    .i_Vmin                            (i_RGB_Vmin                ),
    .i_Vmax                            (i_RGB_Vmax                ),
    .i_valid                           (i_valid                   ),
    .i_R                               (i_R                       ),
    .i_G                               (i_G                       ),
    .i_B                               (i_B                       ),
    .o_valid                           (GREEN__valid              ),
    .o_R                               (GREEN__R                  ),
    .o_G                               (GREEN__G                  ),
    .o_B                               (GREEN__B                  ),
    .o_R_raw                           (GREEN__R_raw              ),
    .o_G_raw                           (GREEN__G_raw              ),
    .o_B_raw                           (GREEN__B_raw              ),
    .o_wb                              (GREEN__wb                 ) 
);
assign GREEN__RGB = {GREEN__R[5:1], GREEN__G[5:0], GREEN__B[5:1]};

//BLUE
div_color_HSV
#(
    .BLACK_COLOR                       (16'b10000_000000_00000    )
)
u3_div_color_HSV(
    .sys_clk                           (sys_clk                   ),
    .sys_rst_n                         (sys_rst_n                 ),
    .i_R0                              (6'b000000                 ),
    .i_G0                              (6'b000000                 ),
    .i_B0                              (6'b111111                 ),
    .i_err                             (i_RGB_err                 ),
    .i_Vmin                            (i_RGB_Vmin                ),
    .i_Vmax                            (i_RGB_Vmax                ),
    .i_valid                           (i_valid                   ),
    .i_R                               (i_R                       ),
    .i_G                               (i_G                       ),
    .i_B                               (i_B                       ),
    .o_valid                           (BLUE___valid              ),
    .o_R                               (BLUE___R                  ),
    .o_G                               (BLUE___G                  ),
    .o_B                               (BLUE___B                  ),
    .o_R_raw                           (BLUE___R_raw              ),
    .o_G_raw                           (BLUE___G_raw              ),
    .o_B_raw                           (BLUE___B_raw              ),
    .o_wb                              (BLUE___wb                 ) 
);
assign BLUE___RGB = {BLUE___R[5:1], BLUE___G[5:0], BLUE___B[5:1]};

//YELLOW
div_color_HSV
#(
    .BLACK_COLOR                       (16'b10000_100000_10000    )
)
u4_div_color_HSV(
    .sys_clk                           (sys_clk                   ),
    .sys_rst_n                         (sys_rst_n                 ),
    .i_R0                              (6'b100000                 ),
    .i_G0                              (6'b100000                 ),
    .i_B0                              (6'b000000                 ),
    .i_err                             (i_YELLOW_err              ),
    .i_Vmin                            (i_YELLOW_Vmin             ),
    .i_Vmax                            (i_YELLOW_Vmax             ),
    .i_valid                           (i_valid                   ),
    .i_R                               (i_R                       ),
    .i_G                               (i_G                       ),
    .i_B                               (i_B                       ),
    .o_valid                           (YELLOW_valid              ),
    .o_R                               (YELLOW_R                  ),
    .o_G                               (YELLOW_G                  ),
    .o_B                               (YELLOW_B                  ),
    .o_R_raw                           (YELLOW_R_raw              ),
    .o_G_raw                           (YELLOW_G_raw              ),
    .o_B_raw                           (YELLOW_B_raw              ),
    .o_wb                              (YELLOW_wb                 ) 
);
assign YELLOW_RGB = {YELLOW_R[5:1], YELLOW_G[5:0], YELLOW_B[5:1]};

wire BLACK__wb;
assign BLACK__wb = ({{2'b0, RED____R_raw} + {2'b0, RED____G_raw} + {2'b0, RED____B_raw}} > i_WB_threshold) ? 1'b0 : 1'b1;

//*************** 总 ***************
//----- 第 5 层
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0) begin
        o_valid    <= 'd0;
        o_data     <= 'd0;
        o_data_raw <= 'd0;
    end
    else begin
        o_valid    <= RED____valid;

        if(inpic_4 == 1'b0)
            o_data <= {RED____R_raw[5:1], RED____G_raw[5:0], RED____B_raw[5:1]};
        else if(RED____wb == 1'b0)
            o_data <= RED____RGB;
        else if(GREEN__wb == 1'b0)
            o_data <= GREEN__RGB;
        else if(BLUE___wb == 1'b0)
            o_data <= BLUE___RGB;
        else if(YELLOW_wb == 1'b0)
            o_data <= YELLOW_RGB;
        else if({{2'b0, RED____R_raw} + {2'b0, RED____G_raw} + {2'b0, RED____B_raw}} > i_WB_threshold)
            o_data <= 16'd0;
        else
            o_data <= 16'hFFFF;

        o_data_raw <= {RED____R_raw[5:1], RED____G_raw[5:0], RED____B_raw[5:1]};
    end


//******************** ITEM 线 ********************

reg                    [`RECT_NUMMAX * 32 - 1 : 0]  item           ;
reg                    [`RECT_NUMMAX * 64 - 1 : 0]  item_tmp       ;

reg                    [`RECT_NUMMAX - 1 : 0]       RED____flag    ;
reg                    [`RECT_NUMMAX - 1 : 0]       GREEN__flag    ;
reg                    [`RECT_NUMMAX - 1 : 0]       BLUE___flag    ;
reg                    [`RECT_NUMMAX - 1 : 0]       YELLOW_flag    ;
reg                    [`RECT_NUMMAX - 1 : 0]       BLACK__flag    ;
reg                    [`RECT_NUMMAX - 1 : 0]       WHITE__flag    ;
reg                    [`RECT_NUMMAX - 1 : 0]       FAT____flag    ;
reg                    [`RECT_NUMMAX - 1 : 0]       SKIN___flag    ;
reg                    [`RECT_NUMMAX - 1 : 0]       NORMAL_flag    ;

genvar k;
generate
//******************************************************
//`define _item_8
`ifdef _item_8
for(k = 8; k < `RECT_NUMMAX; k = k + 1) begin
    always@(posedge sys_clk or negedge item_rst_n) begin
        if(item_rst_n == 1'b0) begin
            o_item   [{k, 5'b0} +: 32] <= 'd0;
            item     [{k, 5'b0} +: 32] <= 'd0;
            item_tmp [{k, 6'b0} +: 64] <= 'd0;
            o_label  [{k, 2'b0} +:  4] <= 'd0;

            RED____flag[k +: 1] <= 'd0;
            GREEN__flag[k +: 1] <= 'd0;
            BLUE___flag[k +: 1] <= 'd0;
            YELLOW_flag[k +: 1] <= 'd0;
            BLACK__flag[k +: 1] <= 'd0;
            WHITE__flag[k +: 1] <= 'd0;
            FAT____flag[k +: 1] <= 'd0;
            SKIN___flag[k +: 1] <= 'd0;
            NORMAL_flag[k +: 1] <= 'd0;
        end
    end
end
endgenerate
generate
for(k = 0; k < 8; k = k + 1) begin
`else
for(k = 0; k < `RECT_NUMMAX; k = k + 1) begin
`endif
//******************************************************
    always@(posedge sys_clk or negedge item_rst_n) begin
        if(item_rst_n == 1'b0) begin
            o_item   [{k, 5'b0} +: 32] <= 'd0;
            item     [{k, 5'b0} +: 32] <= 'd0;
            item_tmp [{k, 6'b0} +: 64] <= 'd0;
            o_label  [{k, 2'b0} +:  4] <= 'd0;

            RED____flag[k +: 1] <= 'd0;
            GREEN__flag[k +: 1] <= 'd0;
            BLUE___flag[k +: 1] <= 'd0;
            YELLOW_flag[k +: 1] <= 'd0;
            BLACK__flag[k +: 1] <= 'd0;
            WHITE__flag[k +: 1] <= 'd0;
            FAT____flag[k +: 1] <= 'd0;
            SKIN___flag[k +: 1] <= 'd0;
            NORMAL_flag[k +: 1] <= 'd0;
        end
        else if(inpic_5 == 1'b1 && cnt_x_5 == `PIC_X1 && cnt_y_5 == `PIC_Y1) begin
            item     [{k, 5'b0} +: 32] <= i_item[{k, 5'b0} +: 32];
            item_tmp [{k, 6'b0} +: 64] <= 'd0;

            RED____flag[k +: 1] <= 'd0;
            GREEN__flag[k +: 1] <= 'd0;
            BLUE___flag[k +: 1] <= 'd0;
            YELLOW_flag[k +: 1] <= 'd0;
            BLACK__flag[k +: 1] <= 'd0;
            WHITE__flag[k +: 1] <= 'd0;
            FAT____flag[k +: 1] <= 'd0;
            SKIN___flag[k +: 1] <= 'd0;
            NORMAL_flag[k +: 1] <= 'd0;
        end

        else if(inpic_5 == 1'b1 &&
                cnt_x_5[P_W-1:2] >= item[{k, 5'b0} + 8 + 8 + 8 +: 8] &&
                cnt_y_5[P_W-1:2] >= item[{k, 5'b0}     + 8 + 8 +: 8] &&
                cnt_x_5[P_W-1:2] <= item[{k, 5'b0}         + 8 +: 8] &&
                cnt_y_5[P_W-1:2] <= item[{k, 5'b0}             +: 8] &&
                cnt_x_5[2:0]     == 3'b0                             &&
                cnt_y_5[2:0]     == 3'b0                             &&
                cnt_x_5[2:0]     == 3'b0                             &&
                cnt_y_5[2:0]     == 3'b0                             ) begin

            if(o_data == RED____RGB && 
                item_tmp[{k, 6'b0} +  8 +  8 +  8 +  8 +  8 +:  8] != 8'hFF)
                item_tmp[{k, 6'b0} +  8 +  8 +  8 +  8 +  8 +:  8] <= 
                item_tmp[{k, 6'b0} +  8 +  8 +  8 +  8 +  8 +:  8] + 1'b1;
            else if(o_data == GREEN__RGB &&
                item_tmp[{k, 6'b0}      +  8 +  8 +  8 +  8 +:  8] != 8'hFF)
                item_tmp[{k, 6'b0}      +  8 +  8 +  8 +  8 +:  8] <= 
                item_tmp[{k, 6'b0}      +  8 +  8 +  8 +  8 +:  8] + 1'b1;
            else if(o_data == BLUE___RGB &&
                item_tmp[{k, 6'b0}           +  8 +  8 +  8 +:  8] != 8'hFF)
                item_tmp[{k, 6'b0}           +  8 +  8 +  8 +:  8] <= 
                item_tmp[{k, 6'b0}           +  8 +  8 +  8 +:  8] + 1'b1;
            else if(o_data == YELLOW_RGB &&
                item_tmp[{k, 6'b0}                +  8 +  8 +:  8] != 8'hFF)
                item_tmp[{k, 6'b0}                +  8 +  8 +:  8] <= 
                item_tmp[{k, 6'b0}                +  8 +  8 +:  8] + 1'b1;
            else if(o_data ==  16'd0 &&
                item_tmp[{k, 6'b0}                     +  8 +:  8] != 8'hFF)
                item_tmp[{k, 6'b0}                     +  8 +:  8] <= 
                item_tmp[{k, 6'b0}                     +  8 +:  8] + 1'b1;
            else if(o_data ==  16'hFFFF &&
                item_tmp[{k, 6'b0}                          +:  8] != 8'hFF)
                item_tmp[{k, 6'b0}                          +:  8] <= 
                item_tmp[{k, 6'b0}                          +:  8] + 1'b1;
        end

        else if(inpic_5 == 1'b1 && cnt_x_5 == `PIC_X2 - 1 && cnt_y_5 == `PIC_Y2) begin
            if(item_tmp[{k, 6'b0} +  8 +  8 +  8 +  8 +  8 +:  8] > 8'b00100000) //2个字面积
                RED____flag[k +: 1] <= 'd1;
            if(item_tmp[{k, 6'b0}      +  8 +  8 +  8 +  8 +:  8] > 8'b00100000) //2个字面积
                GREEN__flag[k +: 1] <= 'd1;  
            if(item_tmp[{k, 6'b0}           +  8 +  8 +  8 +:  8] > 8'b00100000) //2个字面积
                BLUE___flag[k +: 1] <= 'd1;
            if(item_tmp[{k, 6'b0}                +  8 +  8 +:  8] > 8'b00100000) //2个字面积
                YELLOW_flag[k +: 1] <= 'd1;  
            if(item_tmp[{k, 6'b0}                     +  8 +:  8] > 8'b00100000) //2个字面积
                WHITE__flag[k +: 1] <= 'd1;  
            if(item_tmp[{k, 6'b0}                          +:  8] > 8'b00001000) //0.5个字面积
                BLACK__flag[k +: 1] <= 'd1;  
            if(     item[{k, 5'b0}         + 8 +: 8] - item[{k, 5'b0} + 8 + 8 + 8 +: 8] >=
                    item[{k, 5'b0}             +: 8] - item[{k, 5'b0}     + 8 + 8 +: 8] )  
                FAT____flag[k +: 1] <= 'd1;  
            else if(item[{k, 5'b0}         + 8 +: 8] - item[{k, 5'b0} + 8 + 8 + 8 +: 8] <=
                    item[{k, 5'b0}             +: 8] - item[{k, 5'b0}     + 8 + 8 +: 8] - 24) //3个字长
                SKIN___flag[k +: 1] <= 'd1; 
            else
                NORMAL_flag[k +: 1] <= 'd1; 

        end

        else if(inpic_5 == 1'b1 && cnt_x_5 == `PIC_X2 && cnt_y_5 == `PIC_Y2) begin
            o_item   [{k, 5'b0} +: 32]  <=  item   [{k, 5'b0} +: 32] ;

            if     (RED____flag[k +: 1] == 1'b1 && SKIN___flag[k +: 1] == 1'b1) 
                o_label[{k, 2'b0} +:4] <= 'd6;

            else if(GREEN__flag[k +: 1] == 1'b1) 
                o_label[{k, 2'b0} +:4] <= 'd1;
                
            else if(BLUE___flag[k +: 1] == 1'b1) 
                o_label[{k, 2'b0} +:4] <= 'd2;

            else if(YELLOW_flag[k +: 1] == 1'b1) 
                o_label[{k, 2'b0} +:4] <= 'd3;
 
            // else if(RED____flag[k +: 1] == 1'b1 && GREEN__flag[k +: 1] == 1'b1) 
            //     o_label[{k, 2'b0} +:4] <= 'd4;

            // else if(RED____flag[k +: 1] == 1'b1 && BLUE___flag[k +: 1] == 1'b1) 
            //     o_label[{k, 2'b0} +:4] <= 'd5;

            else if(RED____flag[k +: 1] == 1'b1 && BLACK__flag[k +: 1] == 1'b1)  
                o_label[{k, 2'b0} +:4] <= 'd4;
            
            else if(RED____flag[k +: 1] == 1'b1 && FAT____flag[k +: 1] == 1'b1) 
                o_label[{k, 2'b0} +:4] <= 'd5;

            else if(RED____flag[k +: 1] == 1'b1 && NORMAL_flag[k +: 1] == 1'b1) 
                o_label[{k, 2'b0} +:4] <= 'd7;

            else
                o_label[{k, 2'b0} +:4] <= 'd0;
            
        end
    end
end
endgenerate

//*********************************************************************
localparam                              FREE = 3'd0                ;
localparam                              GET  = 3'd1                ;
localparam                              PUT  = 3'd2                ;
localparam                              PAY  = 3'd3                ;
localparam                              WARN = 3'd4                ;

reg                    [   7:0]         num_decrease_cnt           ;
reg                    [   7:0]         num_calculating            ;
reg                    [   7:0]         money_calculating          ;
reg                    [   7:0]         num_last                   ;
reg                    [   7:0]         money_last                 ;
reg                    [   4:0]         finish_cnt                 ;
reg                    [  31:0]         cnt_ns                     ;

always@(posedge sys_clk or negedge item_rst_n)
    if(item_rst_n == 1'b0)
        finish_cnt <= 'd0;
    else if(inpic_5 == 1'b1 && cnt_x_5 == `PIC_X2 && cnt_y_5 == `PIC_Y2)
        finish_cnt <= 'd1;
    else if(finish_cnt == 'd0 || finish_cnt == 'd16)
        finish_cnt <= 'd0;
    else
        finish_cnt <= finish_cnt + 1'b1;

always@(posedge sys_clk or negedge item_rst_n)
    if(item_rst_n == 1'b0)
        cnt_ns <= 'b0;
    else if(o_pattern == PAY || o_pattern == WARN)
        cnt_ns <= cnt_ns + 1'b1;
    else
        cnt_ns <= 'b0;

always@(posedge sys_clk or negedge item_rst_n)
    if(item_rst_n == 1'b0) begin
        num_decrease_cnt  <= 'd0;
        num_calculating   <= 'd0;
        money_calculating <= 'd0;
        num_last          <= 'd0;
        money_last        <= 'd0;
        o_num             <= 'd0;
        o_money           <= 'd0;
        o_payment         <= 'd0;
        o_pattern         <= 'd0;
        o_user            <= 'd0;
    end
    else if(finish_cnt != 'd0 && finish_cnt != 'd16) begin
        if(o_label[{finish_cnt, 2'b0} +: 4] != 'd0) begin
            num_calculating   <= num_calculating   + 1'b1;
            case(o_label[{finish_cnt, 2'b0} +: 4])
                4'd1: money_calculating <= money_calculating + 'd2;
                4'd2: money_calculating <= money_calculating + 'd2;
                4'd3: money_calculating <= money_calculating + 'd2;
                4'd4: money_calculating <= money_calculating + 'd4;
                4'd5: money_calculating <= money_calculating + 'd3;
                4'd6: money_calculating <= money_calculating + 'd6;
                4'd7: money_calculating <= money_calculating + 'd2;
                default: money_calculating <= money_calculating;
            endcase
        end
    end
    else if(finish_cnt == 'd16) begin
            num_calculating   <= 'd0;
            money_calculating <= 'd0;

        if     (num_decrease_cnt > 'd50) begin
            num_decrease_cnt  <= 'd0;
            o_num             <= num_calculating  ;
            o_money           <= money_calculating;
            o_payment         <= 'd0;
            o_pattern         <= WARN;
        end

        else if(o_pattern == FREE && num_calculating > o_num) begin
            num_decrease_cnt  <= num_decrease_cnt + 'b1;
            o_payment         <= 'd0;
        end
        else if(o_pattern == FREE && num_calculating < o_num) begin
            num_decrease_cnt  <= num_decrease_cnt + 'b1;
            o_payment         <= 'd0;
        end
        else if(o_pattern == FREE && i_user == 8'hFF) begin
            o_pattern         <= PUT;
        end
        else if(o_pattern == FREE && i_user != 8'h00) begin
            num_last          <= o_num  ;
            money_last        <= o_money;
            o_pattern         <= GET    ;
            o_user            <= i_user ;
        end
        else if(o_pattern == FREE) begin
            if(num_decrease_cnt > 'd0) 
                num_decrease_cnt  <= num_decrease_cnt - 'b1;
            o_num             <= num_calculating  ;
            o_money           <= money_calculating;
            o_payment         <= 'd0;
        end
            
        else if(o_pattern == GET && i_user == 8'h00) begin
            o_num             <= num_last  ;
            o_money           <= money_last;
            o_payment         <= money_last - money_calculating;
            o_pattern         <= PAY;
        end

        else if(o_pattern == PUT && i_user == 8'h00) begin
            o_num             <= num_calculating  ;
            o_pattern         <= FREE;
        end

        else if(o_pattern == PAY && cnt_ns > 32'd130_000_000) begin
            o_num             <= num_calculating  ;
            o_pattern         <= FREE;
            o_user            <= i_user ;
        end

        else if(o_pattern == WARN && cnt_ns > 32'd130_000_000) begin
            o_num             <= num_calculating  ;
            o_pattern         <= FREE;
        end
    end


endmodule


