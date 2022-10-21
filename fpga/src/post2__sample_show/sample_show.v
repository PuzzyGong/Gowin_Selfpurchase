`include "../define.v"

module sample_show
#(
    parameter                           C_W = `COLOR_WIDTH         ,

    parameter                           P_W = `POSITION_WIDTH
)
(
    input  wire                         sys_clk                    ,
    input  wire                         sys_rst_n                  ,

    input  wire        [`RECT_NUMMAX * 32 - 1 : 0] i_item          ,
    output reg         [`RECT_NUMMAX * 32 - 1 : 0] o_item          ,

    input  wire                         i_valid                    ,
    input  wire        [16-1:0]         i_data                     ,
    output reg                          o_valid                    ,
    output reg         [16-1:0]         o_data                     ,
    output reg         [16-1:0]         o_data_raw 
);


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

reg                    [`RECT_NUMMAX * 16 - 1 : 0]  item_tmp       ;
reg                    [`RECT_NUMMAX * 16 - 1 : 0]  item_cnt       ;
reg                    [`RECT_NUMMAX - 1 : 0]  in_flag       ;

// always@(posedge sys_clk or negedge sys_rst_n)
//     if(sys_rst_n == 1'b0)
//         o_item <= 'd0;
//     else
//         o_item <= i_item;

reg                          valid_1                ;
reg         [16-1:0]         data_1                 ;

always@(posedge sys_clk or negedge sys_rst_n) 
    if(sys_rst_n == 1'b0) begin
        valid_1 <= 'd0;
        data_1 <=  'd0;
    end
    else begin
        valid_1 <= i_valid;
        data_1 <= i_data;
    end

reg                          valid_2                ;
reg         [16-1:0]         data_2                 ;

always@(posedge sys_clk or negedge sys_rst_n) 
    if(sys_rst_n == 1'b0) begin
        valid_2 <= 'd0;
        data_2 <=  'd0;
    end
    else begin
        valid_2 <=valid_1;
        data_2 <= data_1; 
    end

always@(posedge sys_clk or negedge sys_rst_n) 
    if(sys_rst_n == 1'b0) begin
        o_valid <= 'd0;
        o_data_raw <=  'd0;
    end
    else begin
        o_valid <= valid_2;
        o_data_raw <=  data_2;
    end


genvar k;
generate
for(k = 0; k < `RECT_NUMMAX; k = k + 1) begin

    always@(posedge sys_clk or negedge sys_rst_n) begin
        if(sys_rst_n == 1'b0) begin
            item_tmp [{k, 4'b0} + 8 +: 8] <= 'd0;
            item_tmp [{k, 4'b0}     +: 8] <= 'd0;
            item_cnt [{k, 4'b0} + 8 +: 8] <= 'd0;
            item_cnt [{k, 4'b0}     +: 8] <= 'd0; 
            in_flag[k +: 1] <= 'd0;
            o_item [{k, 5'b0} +: 32] <= 'd0;
        end
            
        else if(i_valid == 1'b1 && cnt_x == `PIC_X1 && cnt_y == `PIC_Y1 ) begin
            o_item [{k, 5'b0} +: 32] <= i_item[{k, 5'b0} +: 32];
            item_tmp [{k, 4'b0} + 8 +: 8] <= i_item[{k, 5'b0}         + 8 +: 8] - i_item[{k, 5'b0} + 8 + 8 + 8 +: 8];
            item_tmp [{k, 4'b0}     +: 8] <= i_item[{k, 5'b0}             +: 8] - i_item[{k, 5'b0}     + 8 + 8 +: 8];
        end
 
        else if(i_valid == 1'b1 &&
                cnt_x >= {o_item[{k, 5'b0} + 8 + 8 + 8 +: 8], 2'b0} &&
                cnt_y >= {o_item[{k, 5'b0}     + 8 + 8 +: 8], 2'b0} &&
                cnt_x <= {o_item[{k, 5'b0}         + 8 +: 8], 2'b0} &&
                cnt_y <= {o_item[{k, 5'b0}             +: 8], 2'b0} ) begin

            

            if ( cnt_x == {o_item[{k, 5'b0}         + 8 +: 8], 2'b0}) begin
                item_cnt [{k, 4'b0}     +: 8] <= 'd0;
                if (item_cnt [{k, 4'b0}     +: 8] + 'd8 >= item_tmp [{k, 4'b0}     +: 8])
                    item_cnt [{k, 4'b0}     +: 8] <= item_cnt [{k, 4'b0}     +: 8] + 'd8 - item_tmp [{k, 4'b0}     +: 8];
                else
                    item_cnt [{k, 4'b0}     +: 8] <= item_cnt [{k, 4'b0}     +: 8] + 'd8; 
            end
            else if (item_cnt [{k, 4'b0} + 8 +: 8] + 'd8 >= item_tmp [{k, 4'b0} + 8 +: 8])
                item_cnt [{k, 4'b0} + 8 +: 8] <= item_cnt [{k, 4'b0} + 8 +: 8] + 'd8 - item_tmp [{k, 4'b0} + 8 +: 8];
            else
                item_cnt [{k, 4'b0} + 8 +: 8] <= item_cnt [{k, 4'b0} + 8 +: 8] + 'd8; 

            if(item_cnt [{k, 4'b0} + 8 +: 8] < 'd8 && item_cnt [{k, 4'b0}     +: 8] < 'd8) 
                in_flag[k +: 1] <= 'd1;
            else
                in_flag[k +: 1] <= 'd0;
        end

        else
            in_flag[k +: 1] <= 'd0;
    end
end
endgenerate

always@(posedge sys_clk or negedge sys_rst_n) 
    if(sys_rst_n == 1'b0) 
        o_data <= 'd0;
    else if(in_flag == 'd0)
        o_data <= data_2;
    else
        o_data <= 'd0;


endmodule