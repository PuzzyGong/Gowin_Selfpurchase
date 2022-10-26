`include "../define.v"

//所有 i参数 需要在同一个时钟周期置入，包括：
/*
i_ascii
i_color
i_x
i_y
i_x1
i_y1
i_x2
i_y2
*/
//如果不绘制任何图形，需要
/*
i_ascii = 'b1;
i_x1    = 'b0;
i_y1    = 'b0;
i_x2    = 'b0;
i_y2    = 'b0;
*/

module show_rect_ascii_single
#(
    parameter                           A_W = `ASCII_WIDTH         ,
    parameter                           P_W = `POSITION_WIDTH      ,
    parameter                           L_W = `LETTER_PIXEL_WIDTH   
)
(
    input  wire                         sys_clk                    ,
    input  wire                         sys_rst_n                  ,

//-----i_ascii == 0    时，选择 clear_ram ;
//-----i_ascii == 1    时，选择 rect_draw ;
//-----i_ascii == ' '  时，不进行任何绘制;
//-----i_ascii == else 时，选择 ascii_draw;
    input  wire        [A_W-1:0]        i_ascii                    ,
    input  wire        [   2:0]         i_color                    ,

//-----clear_ram
    input  wire        [L_W-1:0]        i_ys                       ,
    input  wire        [L_W-1:0]        i_ye                       ,
//-----

//-----ascii_draw
    input  wire        [L_W-1:0]        i_x                        ,
    input  wire        [L_W-1:0]        i_y                        ,
//-----

//-----rect_draw
    input  wire        [L_W-1:0]        i_x1                       ,
    input  wire        [L_W-1:0]        i_y1                       ,
    input  wire        [L_W-1:0]        i_x2                       ,
    input  wire        [L_W-1:0]        i_y2                       ,
//-----

    input  wire                         i_valid                    ,
    input  wire        [16-1:0]         i_data                     ,
    output reg                          o_valid                    ,
    output reg         [16-1:0]         o_data                     ,
    output reg         [16-1:0]         o_data_raw                  
);

//*************** RAM_PRE ***************

//----- 第 1 层
/*ascii_draw*/
reg                    [3-1:0]          cnt_x8_0                   ;
reg                    [4-1:0]          cnt_y16_0                  ;
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)begin
        cnt_x8_0 <= 'b0;
        cnt_y16_0 <= 'b0;
    end
    else
        if(cnt_y16_0 == 16 - 1)
            if(cnt_x8_0 == 8 - 1) begin
                cnt_x8_0 <= 'b0;
                cnt_y16_0 <= 'b0;
            end
            else begin
                cnt_x8_0 <= cnt_x8_0 + 1'b1;
                cnt_y16_0 <= 'b0;
            end
        else
            cnt_y16_0 <= cnt_y16_0 + 1'b1;

wire                                    rom_dout_1                 ;
ROM_letter_show u_ROM_letter_show
(
    .dout                              (rom_dout_1                ),//output [0:0] dout
    .clk                               (sys_clk                   ),//input clk
    .oce                               (1'b1                      ),//input oce
    .ce                                (1'b1                      ),//input ce
    .reset                             (1'b0                      ),//input reset
    .ad                                ({i_ascii, cnt_x8_0, cnt_y16_0}) //input [13:0] ad
);

reg                    [L_W-1:0]        ascii_x_1                  ;
reg                    [L_W-1:0]        ascii_y_1                  ;
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0) begin
        ascii_x_1 <= 'b0;
        ascii_y_1 <= 'b0;
    end
    else begin
        ascii_x_1 <= i_x + cnt_x8_0;
        ascii_y_1 <= i_y + cnt_y16_0;
    end

/*rect_draw*/
reg                    [L_W-1:0]        rect_x_1                   ;
reg                    [L_W-1:0]        rect_y_1                   ;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0) begin
        rect_x_1 <= 'b0;
        rect_y_1 <= 'b0;
    end
    else if(rect_y_1 == i_y1 && rect_x_1 >= i_x1 && rect_x_1 < i_x2)
        rect_x_1 <= rect_x_1 + 1'b1;
    else if(rect_x_1 == i_x2 && rect_y_1 >= i_y1 && rect_y_1 < i_y2)
        rect_y_1 <= rect_y_1 + 1'b1;
    else if(rect_y_1 == i_y2 && rect_x_1 > i_x1 && rect_x_1 <= i_x2)
        rect_x_1 <= rect_x_1 - 1'b1;
    else if(rect_x_1 == i_x1 && rect_y_1 > i_y1 && rect_y_1 <= i_y2)
        rect_y_1 <= rect_y_1 - 1'b1;
    else begin
        rect_x_1 <= i_x1;
        rect_y_1 <= i_y1;
    end

/*clear_ram*/
reg                    [L_W-1:0]        clear_x_1                  ;
reg                    [L_W-1:0]        clear_y_1                  ;
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)begin
        clear_x_1 <= 'b0;
        clear_y_1 <= 'b0;
    end
    else if(clear_y_1 > i_ye || clear_y_1 < i_ys)
        clear_y_1 <= i_ys;
    else
        if(clear_x_1 == 0)
            if(clear_y_1 == i_ye) begin
                clear_x_1 <= 'b1;
                clear_y_1 <= i_ys;
            end
            else begin
                clear_x_1 <= 'b1;
                clear_y_1 <= clear_y_1 + 1'b1;
            end
        else
            clear_x_1 <= clear_x_1 + 1'b1;

/*else*/
reg                    [   2:0]         color_1                    ;
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        color_1 <= 'b0;
    else
        color_1 <= i_color;

reg                    [A_W-1:0]        ascii_1                    ;
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        ascii_1 <= 'b0;
    else
        ascii_1 <= i_ascii;

//----- 第 2 层
reg                                     cea_2                      ;
reg                    [  15:0]         ada_2                      ;
reg                    [   2:0]         din_2                      ;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0) begin
        cea_2 <= 'b0;
        ada_2 <= 'b0;
        din_2 <= 'b0;
    end
    else if(ascii_1 == 'b0) begin
        cea_2 <= 'b1;
        ada_2 <= {clear_y_1, clear_x_1};
        din_2 <= 'b0;
    end
    else if(ascii_1 == 'b1) begin
        cea_2 <= 'b1;
        ada_2 <= {rect_y_1, rect_x_1};
        din_2 <= 'b1;
    end
    else if(ascii_1 == 'd32) begin
        cea_2 <= 'b0;
        ada_2 <= {ascii_y_1, ascii_x_1};
        din_2 <= 'b0;
    end
    else if(rom_dout_1 == 1'b0) begin
        cea_2 <= 'b1;
        ada_2 <= {ascii_y_1, ascii_x_1};
        din_2 <= 'b0;
    end
    else begin
        cea_2 <= 'b1;
        ada_2 <= {ascii_y_1, ascii_x_1};
        din_2 <= 'b1;
    end


//*************** RAM ***************

wire                   [  15:0]         adb_0                      ;
wire                                    dout_1                     ;
RAM_letter_show u_RAM_letter_show
(
    .dout                              (dout_1                    ),//output [0:0] dout
    .clka                              (sys_clk                   ),//input clka
    .cea                               (cea_2                     ),//input cea
    .reseta                            (1'b0                      ),//input reseta
    .clkb                              (sys_clk                   ),//input clkb
    .ceb                               (1'b1                      ),//input ceb
    .resetb                            (1'b0                      ),//input resetb
    .oce                               (1'b1                      ),//input oce
    .ada                               (ada_2                     ),//input [15:0] ada
    .din                               (din_2                     ),//input [2:0] din
    .adb                               (adb_0                     ) //input [15:0] adb
);


//*************** RAM_POST ***************

//----- 第 0 层
reg                    [P_W-1:0]        cnt_x_0                    ;
reg                    [P_W-1:0]        cnt_y_0                    ;
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)begin
        cnt_x_0 <= 'b0;
        cnt_y_0 <= 'b0;
    end
    else if(i_valid == 1'b1)
        if(cnt_x_0 == `OV5640_X - 1)
            if(cnt_y_0 == `OV5640_Y - 1) begin
                cnt_x_0 <= 'b0;
                cnt_y_0 <= 'b0;
            end
            else begin
                cnt_x_0 <= 'b0;
                cnt_y_0 <= cnt_y_0 + 1'b1;
            end
        else
            cnt_x_0 <= cnt_x_0 + 1'b1;

assign adb_0 = {cnt_y_0[9:2], cnt_x_0[9:2]};

//----- 信号同步 第 1~3 层
reg                                     valid_1                    ;
reg                                     valid_2                    ;
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0) begin
        o_valid <= 'b0;
        valid_1 <= 'b0;
        valid_2 <= 'b0;
    end
    else begin
        valid_1 <= i_valid;
        valid_2 <= valid_1;
        o_valid <= valid_2;
    end

reg                    [  15:0]         data_1                     ;
reg                    [  15:0]         data_2                     ;
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0) begin
        data_1 <= 'b0;
        data_2 <= 'b0;
        o_data_raw <= 'b0;
    end
    else begin
        data_1 <= i_data;
        data_2 <= data_1;
        o_data_raw <= data_2;
    end

//----- 第 2 层
reg                                     dout_2                     ;
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        dout_2 <= 'b0;
    else
        dout_2 <= dout_1;

//----- 第 3 层
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        o_data <= 'b0;
    else if(dout_2 == 1'b1)
        o_data <= `ASCII_RECT_COLOR_GB;
    else
        o_data <= data_2;


endmodule