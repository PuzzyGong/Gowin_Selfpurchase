`include "../define.v"

//一个vs保持2 ^ 19 + 2 ^ 18个时钟周期

//HDMI 读上部分(2 ^ 19), RAM 写下部分(2 ^ 18) 
//需要写  256 *      256 个周期 (clear_ram )               [19] = 0; [18] = 0; [17] = 0; [16] = 0;
//需要写 (16 * 04) * 256 个周期 (ascii_draw) (i_varies   ) [19] = 0; [18] = 0; [17] = 0; [16] = 1; [15:12]选择; [9:8] 选择
//需要写 (16 * 16) * 256 个周期 (ascii_draw) (i_const_str) [19] = 0; [18] = 0; [17] = 1; [16] = 0; [15:12]选择; [11:8]选择

//HDMI 读下部分(2 ^ 18), RAM 写上部分(2 ^ 19) 
//需要写  256 *      256 个周期 (clear_ram )               [19] = 1; [18] = 0; [17] = 0; [16] = 0;
//需要写  16 *      2048 个周期 (rect_draw ) (i_head_reg ) [19] = 1; [18] = 0; [17] = 0; [16] = 1; [15:12]选择
//需要写  16 *      2048 个周期 (rect_draw ) (i_hair_reg ) [19] = 1; [18] = 0; [17] = 1; [16] = 0; [15:12]选择
//需要写 (16 * 04) * 256 个周期 (ascii_draw) (i_posi_reg ) [19] = 1; [18] = 0; [17] = 1; [16] = 1; [15:12]选择; [9:8] 选择


module show_rect_ascii_ctrl
#(
    parameter                           A_W = `ASCII_WIDTH         ,
    parameter                           P_W = `POSITION_WIDTH      ,
    parameter                           L_W = `LETTER_PIXEL_WIDTH  ,
    parameter                           R_W = `RECT_POSSIBILITY_WIDTH  
)
(
    input  wire                         sys_clk                    ,
    input  wire                         sys_rst_n                  ,

    input  wire                         i_start                    ,
//只能写在上半部分 
    input  wire        [`RECT_NUMMAX * 32 - 1 : 0]   i_head_wire   ,//L_W+L_W+L_W+L_W <= 32
    input  wire        [`RECT_NUMMAX * 32 - 1 : 0]   i_hair_wire   ,//L_W+L_W+L_W+L_W <= 32
    input  wire        [`RECT_NUMMAX *  8 - 1 : 0]   i_posi_wire   ,//R_W+R_W+R_W+R_W <= 8

//只能写在下半部分 
    input  wire        [16 * ( 8 * 8) - 1 : 0]       i_varies      ,
    input  wire        [16 * (32 * 8) - 1 : 0]       i_const_str   ,

    output reg         [A_W-1:0]        o_ascii                    ,
    output reg         [   2:0]         o_color                    ,
    output reg         [L_W-1:0]        o_ys                       ,
    output reg         [L_W-1:0]        o_ye                       ,
    output reg         [L_W-1:0]        o_x                        ,
    output reg         [L_W-1:0]        o_y                        ,
    output reg         [L_W-1:0]        o_x1                       ,
    output reg         [L_W-1:0]        o_y1                       ,
    output reg         [L_W-1:0]        o_x2                       ,
    output reg         [L_W-1:0]        o_y2                       ,

    input  wire                         i_vs                       ,
    input  wire                         i_valid               
);

//-----
reg                    [`RECT_NUMMAX * 32 - 1 : 0]   i_head_reg    ;//P_W+P_W+P_W+P_W <= 64
reg                    [`RECT_NUMMAX * 32 - 1 : 0]   i_hair_reg    ;//P_W+P_W+P_W+P_W <= 64
reg                    [`RECT_NUMMAX * 8 - 1 : 0]    i_posi_reg    ;//R_W+R_W+R_W+R_W <= 8

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)begin
        i_head_reg <= 'b0;
        i_hair_reg <= 'b0;
        i_posi_reg <= 'b0;
    end
    else if (i_start == 1'b1) begin
        i_head_reg <= i_head_wire;
        i_hair_reg <= i_hair_wire;
        i_posi_reg <= i_posi_wire;
    end


//-----
reg                    [P_W-1:0]        cnt_x                      ;
reg                    [P_W-1:0]        cnt_y                      ;
wire                   [P_W+P_W-1:0]    cnt                        ;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)begin
        cnt_x <= 'b0;
        cnt_y <= 'b0;
    end
    else if(i_vs == 1'b0)begin
        cnt_x <= 'b0;
        cnt_y <= 'b0;
    end
    else if(i_valid == 1'b1)
        if(cnt_x == `OV5640_X - 1)
            if(cnt_y == `OV5640_Y - 1) begin
                cnt_x <= 'b0;
                cnt_y <= 'b0;
            end
            else begin
                cnt_x <= 'b0;
                cnt_y <= cnt_y + 1'b1;
            end
        else
            cnt_x <= cnt_x + 1'b1;                                

assign cnt = {cnt_y, cnt_x};


//-----
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0) begin
        o_ascii <= 'b1;
        o_color <= 'b0;
        o_ys<= 'b0;
        o_ye<= 'b0;
        o_x <= 'b0;
        o_y <= 'b0;
        o_x1<= 'b0;
        o_y1<= 'b0;
        o_x2<= 'b0;
        o_y2<= 'b0;
    end
    else if(cnt[19:16] == 4'b0000) begin
        o_ascii <= 'b0;
        o_ys    <= 'd128;
        o_ye    <= 'd191;
    end
    else if(cnt[19:16] == 4'b0001 && cnt[7:0] == 'b0) begin
        o_ascii <= i_varies   [{~cnt[15:12] , 6'b0} + {~cnt[9:8] ,3'b0} +: 8  ];
        o_color <= i_varies   [{~cnt[15:12] , 6'b0} + L_W + L_W + 4 * 8 +: 3  ];
        o_x     <= i_varies   [{~cnt[15:12] , 6'b0} +       L_W + 4 * 8 +: L_W] + {cnt[9:8], 3'b0};
        o_y     <= i_varies   [{~cnt[15:12] , 6'b0} +             4 * 8 +: L_W];
    end
    else if(cnt[19:16] == 4'b0010 && cnt[7:0] == 'b0) begin
        o_ascii <= i_const_str[{~cnt[15:12] , 8'b0} + {~cnt[11:8] ,3'b0} +: 8  ];
        o_color <= i_const_str[{~cnt[15:12] , 8'b0} + L_W + L_W + 16 * 8 +: 3  ];
        o_x     <= i_const_str[{~cnt[15:12] , 8'b0} +       L_W + 16 * 8 +: L_W] + {cnt[11:8], 3'b0};
        o_y     <= i_const_str[{~cnt[15:12] , 8'b0} +             16 * 8 +: L_W];
    end

    else if(cnt[19:16] == 4'b1000) begin
        o_ascii <= 'b0;
        o_ys    <= 'd0;
        o_ye    <= 'd127;
    end
    else if(cnt[19:16] == 4'b1001 && cnt[7:0] == 'b0) begin
        o_x1    <= i_head_reg [{~cnt[15:12] , 5'b0} + L_W + L_W + L_W +: L_W];
        o_y1    <= i_head_reg [{~cnt[15:12] , 5'b0} +       L_W + L_W +: L_W];
        o_x2    <= i_head_reg [{~cnt[15:12] , 5'b0} +             L_W +: L_W];
        o_y2    <= i_head_reg [{~cnt[15:12] , 5'b0}                   +: L_W];
        o_ascii <= 'd1;
        o_color <= 3'b100;
    end
    else if(cnt[19:16] == 4'b1010 && cnt[7:0] == 'b0) begin
        o_x1    <= i_hair_reg [{~cnt[15:12] , 5'b0} + L_W + L_W + L_W +: L_W];
        o_y1    <= i_hair_reg [{~cnt[15:12] , 5'b0} +       L_W + L_W +: L_W];
        o_x2    <= i_hair_reg [{~cnt[15:12] , 5'b0} +             L_W +: L_W];
        o_y2    <= i_hair_reg [{~cnt[15:12] , 5'b0}                   +: L_W];
        o_ascii <= 'd1;
        o_color <= 3'b010;
    end



endmodule