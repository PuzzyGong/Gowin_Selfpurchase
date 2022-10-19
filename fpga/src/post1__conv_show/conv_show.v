`include "../define.v"

module conv_show
#(
    parameter                           C_W = `COLOR_WIDTH         ,

    parameter                           P_W = `POSITION_WIDTH
)
(
    input  wire                         sys_clk_1                  ,
    input  wire                         sys_rst_n_1                ,
    input  wire                         sys_clk_2                  ,
    input  wire                         sys_rst_n_2                ,
    input  wire                         item_rst_n                 ,

    input  wire        [C_W+2-1:0]      i_RGB_err                  ,
    input  wire        [C_W+2-1:0]      i_RGB_Vmin                 ,
    input  wire        [C_W+2-1:0]      i_RGB_Vmax                 ,
    input  wire        [C_W+2-1:0]      i_YELLOW_err               ,
    input  wire        [C_W+2-1:0]      i_YELLOW_Vmin              ,
    input  wire        [C_W+2-1:0]      i_YELLOW_Vmax              ,
    input  wire        [C_W+2-1:0]      i_WB_threshold             ,

    input  wire        [`RECT_NUMMAX * 32 - 1 : 0] item            ,
    output reg         [`RECT_NUMMAX * 32 - 1 : 0] o_item          ,
    output reg         [`RECT_NUMMAX * 4 - 1 : 0] o_label         ,

    input  wire                         i_post_camvs               ,
    input  wire                         i_valid                    ,
    input  wire        [16-1:0]         i_data                     ,
    output reg                          o_valid                    ,
    output reg         [16-1:0]         o_data                     ,
    output reg         [16-1:0]         o_data_raw 
);

//*************** 同步信号 ***************
//----- 第 1~4 层
reg                                     valid_1                    ;
reg                                     valid_2                    ;
reg                                     valid_3                    ;
reg                                     valid_4                    ;
always@(posedge sys_clk_2 or negedge sys_rst_n_2)
    if(sys_rst_n_2 == 1'b0)begin
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

//----- 第 4 层
reg                    [P_W-1:0]        cnt_x_4                    ;
reg                    [P_W-1:0]        cnt_y_4                    ;
always@(posedge sys_clk_2 or negedge sys_rst_n_2)
    if(sys_rst_n_2 == 1'b0)begin
        cnt_x_4 <= 'b0;
        cnt_y_4 <= 'b0;
    end
    else if(valid_3 == 1'b1)
        if(cnt_x_4 == `OV5640_X - 1) begin
            cnt_x_4 <= 'b0;
            if(cnt_y_4 == `OV5640_Y - 1)
                cnt_y_4 <= 'b0;
            else
                cnt_y_4 <= cnt_y_4 + 1'b1;
        end
        else
            cnt_x_4 <= cnt_x_4 + 1'b1;

//----- 第 5 层
reg                    [P_W-1:0]        cnt_x_5                    ;
reg                    [P_W-1:0]        cnt_y_5                    ;
always@(posedge sys_clk_2 or negedge sys_rst_n_2)
    if(sys_rst_n_2 == 1'b0)begin
        cnt_x_5 <= 'b0;
        cnt_y_5 <= 'b0;
    end
    else begin
        cnt_x_5 <= cnt_x_4;
        cnt_y_5 <= cnt_y_4;
    end

reg                                     inpic_5                    ;
always@(posedge sys_clk_2 or negedge sys_rst_n_2)
    if(sys_rst_n_2 == 1'b0) begin
        inpic_5 <= 'b0;
    end
    else if(i_post_camvs == 1'b1 && valid_4 == 1'b1 && cnt_x_4 >= `PIC_X1 && cnt_x_4 <= `PIC_X2 && cnt_y_4 >= `PIC_Y1 && cnt_y_4 <= `PIC_Y2)
        inpic_5 <= 1'b1;
    else
        inpic_5 <= 1'b0;


//*************** 颜色信号 ***************
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

//-----
wire                   [   5:0]         i_R                        ;
wire                   [   5:0]         i_G                        ;
wire                   [   5:0]         i_B                        ;
assign i_R = {i_data[15:11], 1'b0};
assign i_G =  i_data[10:05]       ;
assign i_B = {i_data[04:00], 1'b0};

//-----
//RED
div_color_HSV
#(
    .BLACK_COLOR                       (16'b00000_100000_00000    )
)
u1_div_color_HSV(
    .sys_clk                           (sys_clk_2                 ),
    .sys_rst_n                         (sys_rst_n_2               ),
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
    .sys_clk                           (sys_clk_2                 ),
    .sys_rst_n                         (sys_rst_n_2               ),
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
    .sys_clk                           (sys_clk_2                 ),
    .sys_rst_n                         (sys_rst_n_2               ),
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
    .sys_clk                           (sys_clk_2                 ),
    .sys_rst_n                         (sys_rst_n_2               ),
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
//-----
always@(posedge sys_clk_2 or negedge sys_rst_n_2)
    if(sys_rst_n_2 == 1'b0) begin
        o_valid    <= 'd0;
        o_data     <= 'd0;
        o_data_raw <= 'd0;
    end
    else begin
        o_valid    <= RED____valid;
        if(RED____wb == 1'b0)
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


//*************** 计数 ***************
reg         [`RECT_NUMMAX - 1 : 0] RED____flag               ;
reg         [`RECT_NUMMAX - 1 : 0] GREEN__flag               ;
reg         [`RECT_NUMMAX - 1 : 0] BLUE___flag               ;
reg         [`RECT_NUMMAX - 1 : 0] YELLOW_flag               ;
reg         [`RECT_NUMMAX - 1 : 0] BLACK__flag               ;
reg         [`RECT_NUMMAX - 1 : 0] WHITE__flag               ;
reg         [`RECT_NUMMAX - 1 : 0] FAT____flag               ;
reg         [`RECT_NUMMAX - 1 : 0] SKIN___flag               ;
reg         [`RECT_NUMMAX - 1 : 0] NORMAL_flag               ;

reg         [`RECT_NUMMAX * 64 - 1 : 0] item_tmp               ;
//reg         [`RECT_NUMMAX * 8   - 1 : 0] flag_tmp               ;

genvar k;
generate

// for(k = 2; k < `RECT_NUMMAX; k = k + 1) begin
//     always@(posedge sys_clk_2 or negedge item_rst_n) begin
//         if(item_rst_n == 1'b0) begin
//             o_item   [{k, 5'b0} +: 32]  <= 'd0;
//             item_tmp [{k, 6'b0} +: 64] <= 'd0;
//             o_label  [{k, 6'b0}             +:64] <= "        ";
//         end
//     end
// end
// for(k = 1; k < 2; k = k + 1) begin
for(k = 0; k < `RECT_NUMMAX; k = k + 1) begin

    always@(posedge sys_clk_2 or negedge item_rst_n) begin
        if(item_rst_n == 1'b0) begin
            o_item   [{k, 5'b0} +: 32]  <= 'd0;
            item_tmp [{k, 6'b0} +: 64] <= 'd0;
            o_label[{k, 2'b0} +:4] <= 'd0;

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
        else if(inpic_5 == 1'b1 && cnt_x_5 == `PIC_X2 - 1 && cnt_y_5 == `PIC_Y2) begin
            if(item_tmp[{k, 6'b0} +  8 +  8 +  8 +  8 +  8 +:  8] > 8'b01000000)
                RED____flag[k +: 1] <= 'd1;
            if(item_tmp[{k, 6'b0}      +  8 +  8 +  8 +  8 +:  8] > 8'b01000000)
                GREEN__flag[k +: 1] <= 'd1;  
            if(item_tmp[{k, 6'b0}           +  8 +  8 +  8 +:  8] > 8'b01000000)
                BLUE___flag[k +: 1] <= 'd1;
            if(item_tmp[{k, 6'b0}                +  8 +  8 +:  8] > 8'b01000000)
                YELLOW_flag[k +: 1] <= 'd1;  
            if(item_tmp[{k, 6'b0}                     +  8 +:  8] > 8'b01000000)
                WHITE__flag[k +: 1] <= 'd1;  
            if(item_tmp[{k, 6'b0}                          +:  8] > 8'b01000000)
                BLACK__flag[k +: 1] <= 'd1;  
            if(     item[{k, 5'b0}         + 8 +: 8] - item[{k, 5'b0} + 8 + 8 + 8 +: 8] >=
                    item[{k, 5'b0}             +: 8] - item[{k, 5'b0}     + 8 + 8 +: 8] - 2)
                FAT____flag[k +: 1] <= 'd1;  
            else if(item[{k, 5'b0}         + 8 +: 8] - item[{k, 5'b0} + 8 + 8 + 8 +: 8] <=
                    item[{k, 5'b0}             +: 8] - item[{k, 5'b0}     + 8 + 8 +: 8] - 24)
                SKIN___flag[k +: 1] <= 'd1; 
            else
                NORMAL_flag[k +: 1] <= 'd1; 

        end
        else if(inpic_5 == 1'b1 && cnt_x_5 == `PIC_X2 && cnt_y_5 == `PIC_Y2) begin
            o_item   [{k, 5'b0} +: 32]  <=  item   [{k, 5'b0} +: 32] ;

            if     (YELLOW_flag[k +: 1] == 1'b1) 
                o_label[{k, 2'b0} +:4] <= 'd1;
                
            else if(BLUE___flag[k +: 1] == 1'b1) 
                o_label[{k, 2'b0} +:4] <= 'd2;

            else if(GREEN__flag[k +: 1] == 1'b1) 
                o_label[{k, 2'b0} +:4] <= 'd3;
 
            else if(RED____flag[k +: 1] == 1'b1 && GREEN__flag[k +: 1] == 1'b1) 
                o_label[{k, 2'b0} +:4] <= 'd4;

            else if(RED____flag[k +: 1] == 1'b1 && BLUE___flag[k +: 1] == 1'b1) 
                o_label[{k, 2'b0} +:4] <= 'd5;

            else if(RED____flag[k +: 1] == 1'b1 && BLACK__flag[k +: 1] == 1'b1)  
                o_label[{k, 2'b0} +:4] <= 'd6;
            
            else if(FAT____flag[k +: 1] == 1'b1) 
                o_label[{k, 2'b0} +:4] <= 'd7;

            else if(SKIN___flag[k +: 1] == 1'b1) 
                o_label[{k, 2'b0} +:4] <= 'd8;

            else if(NORMAL_flag[k +: 1] == 1'b1) 
                o_label[{k, 2'b0} +:4] <= 'd9;

            else
                o_label[{k, 2'b0} +:4] <= 'd0;
            
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
    end
end
endgenerate

endmodule


