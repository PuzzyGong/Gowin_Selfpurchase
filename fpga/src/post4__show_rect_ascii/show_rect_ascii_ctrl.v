`include "../define.v"

//一个vs保持2 ^ 19 + 2 ^ 18个时钟周期

//HDMI 读上部分(2 ^ 19), RAM 写下部分(2 ^ 18) 
//需要写  256 *      256 个周期 (clear_ram )               [19] = 0; [18] = 0; [17] = 0; [16] = 0;
//需要写 (16 * 04) * 256 个周期 (ascii_draw) (i_varies   ) [19] = 0; [18] = 0; [17] = 0; [16] = 1; [15:12]选择; [9:8] 选择
//需要写 (16 * 16) * 256 个周期 (ascii_draw) (i_const_str) [19] = 0; [18] = 0; [17] = 1; [16] = 0; [15:12]选择; [11:8]选择

//HDMI 读下部分(2 ^ 18), RAM 写上部分(2 ^ 19) 
//需要写  256 *      256 个周期 (clear_ram )               [19] = 1; [18] = 0; [17] = 0; [16] = 0;
//需要写 (16 * 08) * 256 个周期 (ascii_draw) (label_real ) [19] = 1; [18] = 0; [17] = 0; [16] = 1; [15:12]选择; [10:8] 选择
//需要写  16 *      2048 个周期 (rect_draw ) (i_item     ) [19] = 1; [18] = 0; [17] = 1; [16] = 0; [15:12]选择
//需要写  16 *      2048 个周期 (rect_draw ) (i_otheritem) [19] = 1; [18] = 0; [17] = 1; [16] = 1; [15:12]选择


module show_rect_ascii_ctrl
#(
    parameter                           A_W = `ASCII_WIDTH         ,
    parameter                           P_W = `POSITION_WIDTH      ,
    parameter                           L_W = `LETTER_PIXEL_WIDTH
)
(
    input  wire                         sys_clk                    ,
    input  wire                         sys_rst_n                  ,

//只能写在上半部分 
    input  wire        [`RECT_NUMMAX * 4  - 1 : 0]   i_label       , 
    input  wire        [`RECT_NUMMAX * 32 - 1 : 0]   i_item        ,
    input  wire        [`RECT_NUMMAX * 32 - 1 : 0]   i_otheritem   ,

//只能写在下半部分 
    input  wire        [16 * ( 8 * 8) - 1 : 0]       i_label_str   ,
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

    input  wire                         i_valid               
);

//----- cnt
reg                    [P_W-1:0]        cnt_x                      ;
reg                    [P_W-1:0]        cnt_y                      ;
reg                    [P_W+P_W-1:0]    cnt                        ;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)begin
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

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt <= 'b0;
    else
        cnt <= {cnt_y, cnt_x};

//----- process
reg                    [64-1:0]         label_real                 ;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0) begin
        o_ascii <= 'b1;
        o_color <= 'b0;
        o_ys    <= 'b0;
        o_ye    <= 'b0;
        o_x     <= 'b0;
        o_y     <= 'b0;
        o_x1    <= 'b0;
        o_y1    <= 'b0;
        o_x2    <= 'b0;
        o_y2    <= 'b0;
        label_real <= 'b0;
    end
    // else if(cnt[19:16] == 4'b0000) begin
    //     o_ascii <= 'b0;
    //     o_color <= 'b0;
    //     o_ys    <= 'd128;
    //     o_ye    <= 'd191;
    // end
    // else if(cnt[19:16] == 4'b0001 && cnt[7:0] == 'b0) begin
    //     o_ascii <= i_varies    [{~cnt[15:12] , 6'b0} + {~cnt[ 9:8], 3'b0} +: 8  ];
    //     o_color <= i_varies    [{~cnt[15:12] , 6'b0} + L_W + L_W +  4 * 8 +: 3  ];
    //     o_x     <= i_varies    [{~cnt[15:12] , 6'b0} +       L_W +  4 * 8 +: L_W] + {cnt[ 9:8], 3'b0};
    //     o_y     <= i_varies    [{~cnt[15:12] , 6'b0} +              4 * 8 +: L_W];
    // end
    // else if(cnt[19:16] == 4'b0010 && cnt[7:0] == 'b0) begin
    //     o_ascii <= i_const_str [{~cnt[15:12] , 8'b0} + {~cnt[11:8] ,3'b0} +: 8  ];
    //     o_color <= i_const_str [{~cnt[15:12] , 8'b0} + L_W + L_W + 16 * 8 +: 3  ];
    //     o_x     <= i_const_str [{~cnt[15:12] , 8'b0} +       L_W + 16 * 8 +: L_W] + {cnt[11:8], 3'b0};
    //     o_y     <= i_const_str [{~cnt[15:12] , 8'b0} +             16 * 8 +: L_W];
    // end

    else if(cnt[19:16] == 4'b1000) begin
        o_ascii <= 'b0;
        o_ys    <= 'd0;
        o_ye    <= 'd127;
    end
    // else if(cnt[19:16] == 4'b1001 && cnt[7:0] == 'b0) begin
    //     case(~i_label[{~cnt[15:12], 2'b0} +: 4])
    //         4'h0:  label_real <= i_label_str[{4'h0,6'b0} +: 64];
    //         4'h1:  label_real <= i_label_str[{4'h1,6'b0} +: 64];
    //         4'h2:  label_real <= i_label_str[{4'h2,6'b0} +: 64];
    //         4'h3:  label_real <= i_label_str[{4'h3,6'b0} +: 64];
    //         4'h4:  label_real <= i_label_str[{4'h4,6'b0} +: 64];
    //         4'h5:  label_real <= i_label_str[{4'h5,6'b0} +: 64];
    //         4'h6:  label_real <= i_label_str[{4'h6,6'b0} +: 64];
    //         4'h7:  label_real <= i_label_str[{4'h7,6'b0} +: 64];
    //         4'h8:  label_real <= i_label_str[{4'h8,6'b0} +: 64];
    //         4'h9:  label_real <= i_label_str[{4'h9,6'b0} +: 64];
    //         4'hA:  label_real <= i_label_str[{4'hA,6'b0} +: 64];
    //         4'hB:  label_real <= i_label_str[{4'hB,6'b0} +: 64];
    //         4'hC:  label_real <= i_label_str[{4'hC,6'b0} +: 64];
    //         4'hD:  label_real <= i_label_str[{4'hD,6'b0} +: 64];
    //         4'hE:  label_real <= i_label_str[{4'hE,6'b0} +: 64];
    //         4'hF:  label_real <= i_label_str[{4'hF,6'b0} +: 64];
    //     endcase
    // end
    // else if(cnt[19:16] == 4'b1001 && cnt[7:0] == 'b1) begin
    //     if(cnt[10] == 1'b0) begin
    //         o_ascii <= label_real [{~cnt[10:8], 3'b0} +: 8  ];
    //         o_color <= 3'b010;
    //         o_x     <= i_item [{~cnt[15:12] , 5'b0} + L_W + L_W + L_W +: L_W] + {cnt[10:8], 3'b0};
    //         o_y     <= i_item [{~cnt[15:12] , 5'b0}                   +: L_W] - 'd2;
    //     end
    //     if(cnt[10] == 1'b1) begin
    //         o_ascii <= label_real [{~cnt[10:8], 3'b0} +: 8  ];
    //         o_color <= 3'b010;
    //         o_y     <= i_item [{~cnt[15:12] , 5'b0}                   +: L_W] - 'd15;
    //         if(cnt[9:8] == 2'b00)
    //             o_x <= i_item [{~cnt[15:12] , 5'b0} + L_W + L_W + L_W +: L_W] + 'd0;
    //         else if(cnt[9:8] == 2'b01)
    //             o_x <= i_item [{~cnt[15:12] , 5'b0} + L_W + L_W + L_W +: L_W] + 'd6;
    //         else if(cnt[9:8] == 2'b10)
    //             o_x <= i_item [{~cnt[15:12] , 5'b0} + L_W + L_W + L_W +: L_W] + 'd14;
    //         else if(cnt[9:8] == 2'b11)
    //             o_x <= i_item [{~cnt[15:12] , 5'b0} + L_W + L_W + L_W +: L_W] + 'd18;
    //     end
    // end
    else if(cnt[19:16] == 4'b1010 && cnt[7:0] == 'b0) begin
        o_x1    <= i_item [{~cnt[15:12] , 5'b0} + L_W + L_W + L_W +: L_W];
        o_y1    <= i_item [{~cnt[15:12] , 5'b0} +       L_W + L_W +: L_W];
        o_x2    <= i_item [{~cnt[15:12] , 5'b0} +             L_W +: L_W];
        o_y2    <= i_item [{~cnt[15:12] , 5'b0}                   +: L_W];
        o_ascii <= 'd1;
        o_color <= 3'b011;
    end
    // else if(cnt[19:16] == 4'b1011 && cnt[7:0] == 'b0) begin
    //     o_x1    <= i_otheritem [{~cnt[15:12] , 5'b0} + L_W + L_W + L_W +: L_W];
    //     o_y1    <= i_otheritem [{~cnt[15:12] , 5'b0} +       L_W + L_W +: L_W];
    //     o_x2    <= i_otheritem [{~cnt[15:12] , 5'b0} +             L_W +: L_W];
    //     o_y2    <= i_otheritem [{~cnt[15:12] , 5'b0}                   +: L_W];
    //     o_ascii <= 'd1;
    //     o_color <= 3'b010;
    // end


endmodule