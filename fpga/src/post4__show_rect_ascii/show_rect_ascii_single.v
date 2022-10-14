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
//-----i_ascii == else 时，选择 ascii_draw;
//-----i_ascii == ' '  时，不进行任何绘制;
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

    input  wire                         i_vs                       ,
    input  wire                         i_valid                    ,
    input  wire        [16-1:0]         i_data                     ,
    output reg                          o_valid                    ,
    output reg         [16-1:0]         o_data                     ,                      
    output reg         [16-1:0]         o_data_raw                      
);

/*ascii_draw*/
reg                    [3-1:0]          cnt_x8                     ;
reg                    [4-1:0]          cnt_y16                    ;
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)begin
        cnt_x8 <= 'b0;
        cnt_y16 <= 'b0;
    end
    else
        if(cnt_y16 == 16 - 1)
            if(cnt_x8 == 8 - 1) begin
                cnt_x8 <= 'b0;
                cnt_y16 <= 'b0;
            end
            else begin
                cnt_x8 <= cnt_x8 + 1'b1;
                cnt_y16 <= 'b0;
            end
        else
            cnt_y16 <= cnt_y16 + 1'b1;

wire                                    rom_data                   ;
ROM_letter_show u_ROM_letter_show
(
    .dout                              (rom_data                  ),//output [0:0] dout
    .clk                               (sys_clk                   ),//input clk
    .oce                               (1'b1                      ),//input oce
    .ce                                (1'b1                      ),//input ce
    .reset                             (1'b0                      ),//input reset
    .ad                                ({i_ascii, cnt_x8, cnt_y16}) //input [13:0] ad
);

reg                    [L_W-1:0]        ascii_x                    ;
reg                    [L_W-1:0]        ascii_y                    ;
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0) begin
        ascii_x <= 'b0;
        ascii_y <= 'b0;
    end
    else begin
        ascii_x <= i_x + cnt_x8;
        ascii_y <= i_y + cnt_y16;
    end

/*rect_draw*/
reg                    [L_W-1:0]        rect_x                     ;
reg                    [L_W-1:0]        rect_y                     ;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0) begin
        rect_x <= 'b0;
        rect_y <= 'b0;
    end
    else if(rect_y == i_y1 && rect_x >= i_x1 && rect_x < i_x2)
        rect_x <= rect_x + 1'b1;
    else if(rect_x == i_x2 && rect_y >= i_y1 && rect_y < i_y2)
        rect_y <= rect_y + 1'b1;
    else if(rect_y == i_y2 && rect_x > i_x1 && rect_x <= i_x2)
        rect_x <= rect_x - 1'b1;
    else if(rect_x == i_x1 && rect_y > i_y1 && rect_y <= i_y2)
        rect_y <= rect_y - 1'b1;
    else begin
        rect_x <= i_x1;
        rect_y <= i_y1;
    end

/*clear_ram*/
reg                    [L_W-1:0]        clear_x                      ;
reg                    [L_W-1:0]        clear_y                      ;
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)begin
        clear_x <= 'b0;
        clear_y <= 'b0;
    end
    else if(clear_y > i_ye || clear_y < i_ys)
        clear_y <= i_ys;
    else
        if(clear_x == 0)
            if(clear_y == i_ye) begin
                clear_x <= 'b1;
                clear_y <= i_ys;
            end
            else begin
                clear_x <= 'b1;
                clear_y <= clear_y + 1'b1;
            end
        else
            clear_x <= clear_x + 1'b1;

/*4 to 1*/
reg                    [   2:0]         color_1                    ;
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        color_1 <= 'b0;
    else
        color_1 <= i_color;

reg                    [A_W-1:0]         ascii_1                    ;
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        ascii_1 <= 'b0;
    else
        ascii_1 <= i_ascii;

reg                                     ram_cea                    ;
reg                    [  15:0]         ram_ada                    ;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0) begin
        ram_cea <= 'b0;
        ram_ada <= 'b0;
    end
    else if(ascii_1 == 'b0) begin
        ram_cea <= 'b1;
        ram_ada <= {clear_y, clear_x};
    end
    else if(ascii_1 == 'b1) begin
        ram_cea <= 'b1;
        ram_ada <= {rect_y, rect_x};
    end
    else if(ascii_1 == 'd32) begin
        ram_cea <= 'b0;
        ram_ada <= {ascii_y, ascii_x};
    end
    else begin
        ram_cea <= 'b1;
        ram_ada <= {ascii_y, ascii_x};
    end
        
reg                    [   2:0]         color_2                    ;
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        color_2 <= 'b0;
    else if(ascii_1 == 'b0)
        color_2 <= 'b0;
    else if(ascii_1 == 'b1)
        color_2 <= color_1;
    else if(rom_data == 1'b0)
        color_2 <= 'b0;
    else
        color_2 <= color_1;

//-----
wire                   [  15:0]         ram_addout                 ;
wire                   [   2:0]         ram_dataout                ;
RAM_letter_show u_RAM_letter_show
(
    .dout                              (ram_dataout               ),//output [2:0] dout
    .clka                              (sys_clk                   ),//input clka
    .cea                               (ram_cea                   ),//input cea
    .reseta                            (1'b0                      ),//input reseta
    .clkb                              (sys_clk                   ),//input clkb
    .ceb                               (1'b1                      ),//input ceb
    .resetb                            (1'b0                      ),//input resetb
    .oce                               (1'b1                      ),//input oce
    .ada                               (ram_ada                   ),//input [15:0] ada
    .din                               (color_2                   ),//input [2:0] din
    .adb                               (ram_addout                ) //input [15:0] adb
);


//-----
reg                    [P_W-1:0]        cnt_x                      ;
reg                    [P_W-1:0]        cnt_y                      ;
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

assign ram_addout = {cnt_y[9:2], cnt_x[9:2]};

//delay
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

reg                    [   2:0]         ram_dataout_d              ;
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        ram_dataout_d <= 'b0;
    else
        ram_dataout_d <= ram_dataout;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        o_data <= 'b0;
    else if(ram_dataout_d == 3'b001)
        o_data <= 16'b00000_000000_01000;
    else if(ram_dataout_d == 3'b010)
        o_data <= 16'b00000_010000_00000;
    else if(ram_dataout_d == 3'b100)
        o_data <= 16'b01000_000000_00000;
    else if(ram_dataout_d == 3'b011)
        o_data <= 16'b00000_010000_01000;
    else if(ram_dataout_d == 3'b101)
        o_data <= 16'b01000_000000_01000;
    else if(ram_dataout_d == 3'b110)
        o_data <= 16'b01000_010000_00000;
    else if(ram_dataout_d == 3'b111)
        o_data <= 16'b01000_010000_01000;
    else
        o_data <= data_2;


endmodule