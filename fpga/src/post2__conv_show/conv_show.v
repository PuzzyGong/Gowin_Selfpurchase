`include "../define.v"

module conv
#(
    parameter                           C_W = `COLOR_WIDTH         ,

    parameter                           P_W = `POSITION_WIDTH
)
(
    input  wire                         sys_clk                    ,
    input  wire                         sys_rst_n                  ,

    input  wire        [C_W+2-1:0]      i_RGB_err                  ,
    input  wire        [C_W+2-1:0]      i_RGB_Vmin                 ,
    input  wire        [C_W+2-1:0]      i_RGB_Vmax                 ,
    input  wire        [C_W+2-1:0]      i_YELLOW_err               ,
    input  wire        [C_W+2-1:0]      i_YELLOW_Vmin              ,
    input  wire        [C_W+2-1:0]      i_YELLOW_Vmax              ,
    input  wire        [C_W+2-1:0]      i_WB_threshold             ,

    input  wire        [`RECT_NUMMAX * 32 - 1 : 0] item            ,

    input  wire                         i_post_camvs               ,
    input  wire                         i_valid                    ,
    input  wire        [16-1:0]         i_data                     ,
    output reg                          o_valid                    ,
    output reg         [16-1:0]         o_data                     ,
    output reg         [16-1:0]         o_data_raw 
);

//-----
reg                    [P_W-1:0]        cnt_x                      ;
reg                    [P_W-1:0]        cnt_y                      ;
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)begin
        cnt_x <= 'b0;
        cnt_y <= 'b0;
    end
    else if(i_valid == 1'b1)
        if(cnt_x == `OV5640_X - 1) begin
            cnt_x <= 'b0;
            if(cnt_y == `OV5640_Y - 1) 
                cnt_y <= 'b0;
            else
                cnt_y <= cnt_y + 1'b1;
        end
        else
            cnt_x <= cnt_x + 1'b1;

//-----



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
wire                                    BLACK__valid               ;
wire                   [C_W-1:0]        BLACK__R                   ;
wire                   [C_W-1:0]        BLACK__G                   ;
wire                   [C_W-1:0]        BLACK__B                   ;
wire                   [C_W-1:0]        BLACK__R_raw               ;
wire                   [C_W-1:0]        BLACK__G_raw               ;
wire                   [C_W-1:0]        BLACK__B_raw               ;
wire                                    BLACK__wb                  ;
wire                   [  15:0]         BLACK__RGB                 ;
wire                                    WHITE__valid               ;
wire                   [C_W-1:0]        WHITE__R                   ;
wire                   [C_W-1:0]        WHITE__G                   ;
wire                   [C_W-1:0]        WHITE__B                   ;
wire                   [C_W-1:0]        WHITE__R_raw               ;
wire                   [C_W-1:0]        WHITE__G_raw               ;
wire                   [C_W-1:0]        WHITE__B_raw               ;
wire                                    WHITE__wb                  ;
wire                   [  15:0]         WHITE__RGB                 ;

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
    .sys_clk                           (sys_clk                   ),
    .sys_rst_n                         (sys_rst_n                 ),
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

//-----
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0) begin
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


endmodule