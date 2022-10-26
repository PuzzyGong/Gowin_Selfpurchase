`include "../define.v"

module show_picture
#(
    parameter                           P_W = `POSITION_WIDTH       
)
(
    input  wire                         sys_clk                    ,
    input  wire                         sys_rst_n                  ,

    input  wire        [   2:0]         i_pattern                  ,

    input  wire                         i_valid                    ,
    input  wire        [24-1:0]         i_data                     ,

    output reg                          o_valid                    ,
    output reg         [24-1:0]         o_data                      
);

localparam  posi_title_x1    =  10'd928  ;
localparam  posi_title_x2    =  10'd992  ;
localparam  posi_title_y1    =  10'd032  ;
localparam  posi_title_y2    =  10'd544  ;

localparam  posi_pattern_x1  =  10'd768  ;
localparam  posi_pattern_x2  =  10'd896  ;
localparam  posi_pattern_y1  =  10'd576  ;
localparam  posi_pattern_y2  =  10'd704  ;


//----- 同步信号 第 1~5 层
reg                    [24-1:0]         data_1                     ;
reg                    [24-1:0]         data_2                     ;
reg                    [24-1:0]         data_3                     ;
reg                    [24-1:0]         data_4                     ;
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)begin
        data_1 <= 'd0;
        data_2 <= 'd0;
        data_3 <= 'd0;
        data_4 <= 'd0;
    end
    else begin
        data_1 <= i_data;
        data_2 <= data_1;
        data_3 <= data_2;
        data_4 <= data_3;
    end

reg                    [24-1:0]         valid_1                    ;
reg                    [24-1:0]         valid_2                    ;
reg                    [24-1:0]         valid_3                    ;
reg                    [24-1:0]         valid_4                    ;
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)begin
        valid_1 <= 'd0;
        valid_2 <= 'd0;
        valid_3 <= 'd0;
        valid_4 <= 'd0;
        o_valid <= 'd0;
    end
    else begin
        valid_1 <= i_valid;
        valid_2 <= valid_1;
        valid_3 <= valid_2;
        valid_4 <= valid_3;
        o_valid <= valid_4;
    end

//----- 第 0 层
reg                    [P_W-1:0]        cnt_x_0                    ;
reg                    [P_W-1:0]        cnt_y_0                    ;
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)begin
        cnt_x_0 <= 'b0;
        cnt_y_0 <= 'b0;
    end
    else if(i_valid == 1'b1) begin
        if(cnt_x_0 == `OV5640_X - 1) begin
            cnt_x_0 <= 'b0;
            if(cnt_y_0 == `OV5640_Y - 1)
                cnt_y_0 <= 'b0;
            else
                cnt_y_0 <= cnt_y_0 + 1'b1;
        end
        else
            cnt_x_0 <= cnt_x_0 + 1'b1;
    end

//----- 第 1 层
reg                    [   1:0]         none_or_title_or_pattern_1 ;
reg                    [  16:0]         title_add_1                ;
reg                    [  16:0]         pattern_add_1              ;
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0) begin
        none_or_title_or_pattern_1 <= 'd0;
        title_add_1                <= 'd0;
        pattern_add_1              <= 'd0;
    end
    else if(i_valid == 1'b1 &&
            cnt_x_0 >= posi_title_x1 && cnt_x_0 < posi_title_x2 &&
            cnt_y_0 >= posi_title_y1 && cnt_y_0 < posi_title_y2   ) begin

        none_or_title_or_pattern_1 <= 'd1;
        title_add_1                <= title_add_1 + 'b1;
    end
    else if(i_valid == 1'b1 &&
            cnt_x_0 >= posi_pattern_x1 && cnt_x_0 < posi_pattern_x2 &&
            cnt_y_0 >= posi_pattern_y1 && cnt_y_0 < posi_pattern_y2   ) begin

        none_or_title_or_pattern_1 <= 'd2;
        pattern_add_1              <= pattern_add_1 + 'b1;
    end


//----- 第 2 层
reg                    [  16:0]         ad_2                       ;
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        ad_2 <= 'd0;
    else if(none_or_title_or_pattern_1 == 2'd1)
        ad_2 <= title_add_1;
    else if(none_or_title_or_pattern_1 == 2'd2)
        ad_2 <= 16'h8000 + {i_pattern, 14'b0} + pattern_add_1;

//----- 第 3 层
wire                                    dout_3                     ;
ROM_picture u_ROM_picture
(
    .dout                              (dout_3                    ),//output [0:0] dout
    .clk                               (sys_clk                   ),//input clk
    .oce                               (1'b1                      ),//input oce
    .ce                                (1'b1                      ),//input ce
    .reset                             (1'b0                      ),//input reset
    .ad                                (ad_2                      ) //input [16:0] ad
);

//----- 第 4 层
reg                                     dout_4                     ;
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        dout_4 <= 'd0;
    else
        dout_4 <= dout_3;

//----- 第 5 层
reg                    [   1:0]         none_or_title_or_pattern_2;
reg                    [   1:0]         none_or_title_or_pattern_3;
reg                    [   1:0]         none_or_title_or_pattern_4;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0) begin
        none_or_title_or_pattern_2 <= 'd0;
        none_or_title_or_pattern_3 <= 'd0;
        none_or_title_or_pattern_4 <= 'd0;
    end
    else begin
        none_or_title_or_pattern_2 <= none_or_title_or_pattern_1;
        none_or_title_or_pattern_3 <= none_or_title_or_pattern_2;
        none_or_title_or_pattern_4 <= none_or_title_or_pattern_3;
    end

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        o_data <= 'd0;
    else if(dout_4 == 1'b0)
        if(none_or_title_or_pattern_4 == 2'd0)
            o_data <= data_4;
        else if(none_or_title_or_pattern_4 == 2'd1)
            o_data <= `COLOR_B;
        else if(i_pattern == 3'd0)
            o_data <= `COLOR_G;
        else if(i_pattern == 3'd1)
            o_data <= `COLOR_RB;
        else if(i_pattern == 3'd2)
            o_data <= `COLOR_RB;
        else if(i_pattern == 3'd3)
            o_data <= `COLOR_RG;
        else if(i_pattern == 3'd4)
            o_data <= `COLOR_R;
        else if(i_pattern == 3'd5)
            o_data <= `COLOR_G; 
        else
            o_data <= data_4;          
    else
        o_data <= data_4;


endmodule