`include "../define.v"

module corrode
#(
    parameter                           P_W = `POSITION_WIDTH      ,
    parameter                           C_L = `CORROSION_DX        ,
    parameter                           C_W = `CORROSION_WIDTH + `CORROSION_WIDTH 
)
(
    input  wire                         sys_clk                    ,
    input  wire                         sys_rst_n                  ,

    input  wire        [C_W-1:0]        i_err                      ,

    input  wire                         i_valid                    ,
    input  wire                         i_wb                       ,

    output reg                          o_valid                    ,
    output reg                          o_wb                        
);

//----- 第 0 层
reg                    [P_W-1:0]        cnt_x                    ;
reg                    [P_W-1:0]        cnt_y                    ;
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)begin
        cnt_x <= 'b0;
        cnt_y <= 'b0;
    end
    else if(i_valid == 1'b1)
        if(cnt_x == `OV5640_X - 1) begin
            cnt_x <= 'b0;
            if(cnt_y == `OV5640_Y - 1)
                cnt_y <= 'b0;
            else
                cnt_y <= cnt_y + 1'b1;
        end
        else
            cnt_x <= cnt_x + 1'b1;

reg                    [P_W-1:0]        cnt_x0                   ;
reg                    [P_W-1:0]        cnt_x1                   ;
reg                    [P_W-1:0]        cnt_y0                   ;
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)begin
        cnt_x0 <= 'b0;
        cnt_x1 <= 'b0;
        cnt_y0 <= 'b0;
    end
    else if(i_valid == 1'b1 && cnt_x >= `PIC_X1 && cnt_x <= `PIC_X2 && cnt_y >= `PIC_Y1 && cnt_y <= `PIC_Y2)
        if(cnt_x0 == `CORROSION_SIZE - 1) begin
            cnt_x0 <= 'b0;
            if(cnt_x1 == C_L - 1) begin
                cnt_x1 <= 'b0;
                if(cnt_y0 == `CORROSION_SIZE - 1) begin
                    cnt_y0 <= 'b0;
                end
                else begin
                    cnt_y0 <= cnt_y0 + 1'b1;
                end
            end
            else begin
                cnt_x1 <= cnt_x1 + 1'b1;
            end
        end
        else
            cnt_x0 <= cnt_x0 + 1'b1;

//----- 第 1 层
reg                    [C_W-1:0]        tmp_reg[0:C_L-1]                           ;

integer i;
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0) begin
        o_valid <= 'b0;
        o_wb    <= 'b0;
        for(i = 0; i < C_L; i = i + 1)
            tmp_reg[i] <= 'b0;
    end
    else if(i_valid == 1'b1 && cnt_x >= `PIC_X1 && cnt_x <= `PIC_X2 && cnt_y >= `PIC_Y1 && cnt_y <= `PIC_Y2) begin
        if(cnt_x0 == `CORROSION_SIZE - 1 && cnt_y0 == `CORROSION_SIZE - 1) begin
            o_valid <= 'b1;
            if(tmp_reg[cnt_x1] > i_err)
                o_wb <= 'b0;
            else
                o_wb <= 'b1;
            tmp_reg[cnt_x1] <= 'b0;
        end
        else begin
            o_valid <= 'b0;
            o_wb    <= 'b0;  
            if(i_wb == 1'b0)
                tmp_reg[cnt_x1] <= tmp_reg[cnt_x1] + 1'b1;
        end
    end
    else begin
        o_valid <= 'b0;
        o_wb    <= 'b0;
    end
    
endmodule