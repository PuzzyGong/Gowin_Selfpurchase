`include "../define.v"

module show_varies
#(
    parameter                           P_W = `POSITION_WIDTH       
)
(
    input  wire                         sys_clk                    ,
    input  wire                         sys_rst_n                  ,

    input  wire                         i_valid                    ,
    input  wire        [24-1:0]         i_data                     ,

    output reg                          o_valid                    ,
    output reg         [24-1:0]         o_data                      
);

wire                   [16*32-1:0]      posi                       ;
assign posi = {8'h20, 8'h84, 8'h00, 8'h00,
               8'h30, 8'h84, 8'h00, 8'h00,
               8'h40, 8'h84, 8'h00, 8'h00,
               8'h60, 8'h84, 8'h00, 8'h00,
               8'h70, 8'h84, 8'h00, 8'h00,
               8'h90, 8'h84, 8'h00, 8'h00,
               8'hA0, 8'h84, 8'h00, 8'h00,
               8'hFF, 8'hFF, 8'h00, 8'h00,
               8'hFF, 8'hFF, 8'h00, 8'h00,
               8'hFF, 8'hFF, 8'h00, 8'h00,
               8'hFF, 8'hFF, 8'h00, 8'h00,
               8'hFF, 8'hFF, 8'h00, 8'h00,
               8'hFF, 8'hFF, 8'h00, 8'h00,
               8'hFF, 8'hFF, 8'h00, 8'h00,
               8'hFF, 8'hFF, 8'h00, 8'h00,
               8'hFF, 8'hFF, 8'h00, 8'h00 };
           

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
reg                    [   3:0]         index_1                    ;
reg                    [   5:0]         cnt_1                      ;
reg                    [   9:0]         caltmp_1                   ;
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0) begin
        index_1  <= 'd0;
        caltmp_1 <= 'd0;
        cnt_1    <= 'd0;
    end
    else if(i_valid == 1'b1 &&
            cnt_x_0[9:4] == posi[{cnt_x_0[3:0], 5'b0} + 2 + 8 + 8 + 8 +: 6]        -  'b01 &&
            cnt_y_0      - {posi[{cnt_x_0[3:0], 5'b0}         + 8 + 8 +: 8], 2'b0} >= 'd00 &&
            cnt_y_0      - {posi[{cnt_x_0[3:0], 5'b0}         + 8 + 8 +: 8], 2'b0} <  'd128   ) begin

        index_1  <= ~cnt_x_0[3:0];
        caltmp_1 <= cnt_y_0 - {posi[{cnt_x_0[3:0], 5'b0}         + 8 + 8 +: 8], 2'b0};
        cnt_1    <= {2'b01, cnt_x_0[3:0]};
    end
    else if(cnt_1 == 6'b111111) begin
        index_1  <= 'd0;
        cnt_1    <= 'd0;
    end
    else if(cnt_1 != 'd0)
        cnt_1    <= cnt_1 + 'b1;

//----- 第 2 层
reg                    [  14:0]         ad_2                       ;
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        ad_2 <= 'd0;
    else if(cnt_1[5] == 1'b1)
        ad_2 <= {index_1[2:0], caltmp_1[6:0], cnt_1[4:0]};
    else
        ad_2 <= 'd0;

//----- 第 3 层
wire                                    dout_3                     ;
ROM_varies u_ROM_varies
(
    .dout                              (dout_3                    ),//output [0:0] dout
    .clk                               (sys_clk                   ),//input clk
    .oce                               (1'b1                      ),//input oce
    .ce                                (1'b1                      ),//input ce
    .reset                             (1'b0                      ),//input reset
    .ad                                (ad_2                      ) //input [14:0] ad
);

//----- 第 4 层
reg                                     dout_4                     ;
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        dout_4 <= 'd0;
    else
        dout_4 <= dout_3;

//----- 第 5 层
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        o_data <= 'd0;
    else if(dout_4 == 1'b0)
        o_data <= `COLOR_W;
    else
        o_data <= data_4;


endmodule