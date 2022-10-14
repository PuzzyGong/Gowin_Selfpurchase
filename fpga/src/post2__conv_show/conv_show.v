`include "../define.v"

module conv
#(
    parameter                           C_W = `COLOR_WIDTH         ,

)
(
    input  wire                         sys_clk                    ,
    input  wire                         sys_rst_n                  ,

    input  wire        [C_W+2-1:0]      i_err                      ,

    input  wire        [`RECT_NUMMAX * 32 - 1 : 0] item            ,

    input  wire                         i_post_camvs               ,
    input  wire                         i_valid                    ,
    input  wire        [16-1:0]         i_data                     ,
    output wire                         o_valid                    ,
    output wire        [16-1:0]         o_data                     ,
    output wire        [16-1:0]         o_data_raw 
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

//-----




