module top_test
(
    input  wire                         pre_clk                    ,
    input  wire                         post_clk                   ,
    input  wire                         sys_rst_n                  ,
    
    input  wire                         i_pre_vs                   ,
    input  wire                         i_post_vs                  ,
    output reg         [   7:0]         fps1                       ,
    output reg         [   7:0]         fps2                       , 
    output reg         [   7:0]         fps3                       , 
    output reg         [  31:0]         cnt_1s                       
);

//-----cnt for 1s
always@(posedge post_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_1s <= 'b0;
    else if(cnt_1s == 32'd65_000_000)
        cnt_1s <= 'b0;
    else
        cnt_1s <= cnt_1s + 1'b1;

//-----cnt for 100us
reg                    [  31:0]         cnt_100us                  ;
wire                                    clk_test                   ;
always@(posedge post_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_100us <= 'b0;
    else if(cnt_100us == 32'd65_00)
        cnt_100us <= 'b0;
    else
        cnt_100us <= cnt_100us + 1'b1;
assign clk_test = (cnt_100us < 32'd32_50) ? 1'b1 : 1'b0;

//-----fps_calcu
reg                                     pre_vs_inflag              ;
reg                    [   7:0]         pre_vs_cnt                 ;
always@(posedge post_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0) begin
        pre_vs_inflag <= 'b0;
        pre_vs_cnt <= 'b0;
        fps1 <= 'b0;
    end
    else if(cnt_1s == 'b0) begin
        pre_vs_cnt <= 'b0;
        fps1 <= pre_vs_cnt;
    end
    else if(pre_vs_inflag == 1'b1 && i_pre_vs == 1'b0) begin
        pre_vs_inflag <= 'b0;
        pre_vs_cnt <= pre_vs_cnt + 'b1;
    end
    else if(pre_vs_inflag == 1'b0 && i_pre_vs == 1'b1) begin
        pre_vs_inflag <= 'b1;
    end

reg                                     post_vs_inflag             ;
reg                    [   7:0]         post_vs_cnt                ;
always@(posedge post_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0) begin
        post_vs_inflag <= 'b0;
        post_vs_cnt <= 'b0;
        fps2 <= 'b0;
    end
    else if(cnt_1s == 'b0) begin
        post_vs_cnt <= 'b0;
        fps2 <= post_vs_cnt;
    end
    else if(post_vs_inflag == 1'b1 && i_post_vs == 1'b0) begin
        post_vs_inflag <= 'b0;
        post_vs_cnt <= post_vs_cnt + 'b1;
    end
    else if(post_vs_inflag == 1'b0 && i_post_vs == 1'b1) begin
        post_vs_inflag <= 'b1;
    end

reg                    [   7:0]         fps3_cnt_cnt               ;
reg                    [   7:0]         fps3_cnt                   ;
always@(posedge post_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0) begin
        fps3_cnt_cnt <= 'd0; 
        fps3_cnt     <= 'd0;
        fps3         <= 'd0;
    end
    else if(cnt_1s == 'b0) begin
        fps3_cnt     <= 'd0;
        fps3         <= fps3_cnt;
    end
    else if(post_vs_inflag == 1'b1 && i_post_vs == 1'b0) begin
        if(fps3_cnt_cnt == 8'd7) begin
            fps3_cnt_cnt <= 'd0;
            fps3_cnt     <= fps3_cnt + 'b1;
        end
        else
            fps3_cnt_cnt <= fps3_cnt_cnt + 'b1;
    end

endmodule