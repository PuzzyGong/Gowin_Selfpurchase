`include "../define.v"

module intercept
#(
    parameter                           P_W = `POSITION_WIDTH      ,
    parameter                           C_W = `COLOR_WIDTH
)
(
    input  wire                         sys_clk                    ,
    input  wire                         sys_rst_n                  ,

    input  wire                         i_valid                    ,
    input  wire        [C_W-1:0]        i_R                        ,
    input  wire        [C_W-1:0]        i_G                        ,
    input  wire        [C_W-1:0]        i_B                        ,
    
    output reg                          o_valid                    ,
    output reg         [C_W-1:0]        o_R                        ,
    output reg         [C_W-1:0]        o_G                        ,
    output reg         [C_W-1:0]        o_B                         
);

//----- 第 0 层
reg                    [P_W-1:0]        cnt_x                      ;
reg                    [P_W-1:0]        cnt_y                      ;
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)begin
        cnt_x <= 'b0;
        cnt_y <= 'b0;
    end
    else if(i_valid == 1'b1) begin
        if(cnt_x == `OV5640_X - 1) begin
            cnt_x <= 'b0;
            if(cnt_y == `OV5640_Y - 1)
                cnt_y <= 'b0;
            else
                cnt_y <= cnt_y + 1'b1;
        end
        else
            cnt_x <= cnt_x + 1'b1;
    end

//----- 第 1 层 
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        o_valid <= 1'b0;
    else
        o_valid <= i_valid;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0) begin
        o_R <= 'b0;
        o_G <= 'b0;
        o_B <= 'b0;
    end
    else if(i_valid == 1'b1 && cnt_x >= `PIC_X1 && cnt_x <= `PIC_X2 && cnt_y >= `PIC_Y1 && cnt_y <= `PIC_Y2_FOR_INTERCEPT) begin
        o_R <= i_R;
        o_G <= i_G;
        o_B <= i_B;
    end
    else begin
        o_R <= `BACKROUND_R;
        o_G <= `BACKROUND_G;
        o_B <= `BACKROUND_B;
    end


endmodule