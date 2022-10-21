`include "../define.v"

module show_corrode
#(
    parameter                           P_W = `POSITION_WIDTH      ,
    parameter                           C_L = `CORROSION_DX         
)
(
    input  wire                         sys_clk_1                  ,
    input  wire                         sys_rst_n_1                ,
    input  wire                         sys_clk_2                  ,
    input  wire                         sys_rst_n_2                ,

//----- pre
    input  wire                         i_pre_valid                ,
    input  wire                         i_pre_wb                   ,

//----- post
    input  wire                         i_valid                    ,
    input  wire        [16-1:0]         i_data                     ,
    output reg                          o_valid                    ,
    output reg         [16-1:0]         o_data                     ,
    output reg         [16-1:0]         o_data_raw                  
);

//*************** pre ***************

reg                    [  12:0]         ada                        ;//C_W + C_W <= 13
always@(posedge sys_clk_1 or negedge sys_rst_n_1)
    if(sys_rst_n_1 == 1'b0)
        ada <= 'b0;
    else if(i_pre_valid == 1'b1)
        ada <= ada + 1'b1;
        

//*************** RAM ***************

reg                    [  12:0]         adb                        ;
wire                                    dout_o                     ;
RAM_show_corrode u_RAM_show_corrode(
    .dout                              (dout_o                    ),//output [0:0] dout
    .clka                              (sys_clk_1                 ),//input clka
    .cea                               (i_pre_valid               ),//input cea
    .reseta                            (1'b0                      ),//input reseta
    .clkb                              (sys_clk_2                 ),//input clkb
    .ceb                               (1'b1                      ),//input ceb
    .resetb                            (1'b0                      ),//input resetb
    .oce                               (1'b1                      ),//input oce
    .ada                               (ada                       ),//input [12:0] ada
    .din                               (i_pre_wb                  ),//input [0:0] din
    .adb                               (adb                       ) //input [12:0] adb
);


//*************** post ***************
//----- 第 0 层
reg                    [P_W-1:0]        cnt_x_0                    ;
reg                    [P_W-1:0]        cnt_y_0                    ;
always@(posedge sys_clk_2 or negedge sys_rst_n_2)
    if(sys_rst_n_2 == 1'b0)begin
        cnt_x_0 <= 'b0;
        cnt_y_0 <= 'b0;
    end
    else if(i_valid == 1'b1)
        if(cnt_x_0 == `OV5640_X - 1) begin
            cnt_x_0 <= 'b0;
            if(cnt_y_0 == `OV5640_Y - 1)
                cnt_y_0 <= 'b0;
            else
                cnt_y_0 <= cnt_y_0 + 1'b1;
        end
        else
            cnt_x_0 <= cnt_x_0 + 1'b1;

reg                    [P_W-1:0]        cnt_x0_0                   ;
reg                    [P_W-1:0]        cnt_x1_0                   ;
reg                    [P_W-1:0]        cnt_y0_0                   ;
always@(posedge sys_clk_2 or negedge sys_rst_n_2)
    if(sys_rst_n_2 == 1'b0) begin
        cnt_x0_0 <= 'b0;
        cnt_x1_0 <= 'b0;
        cnt_y0_0 <= 'b0;
        adb    <= 'b0;
    end
    else if(i_valid == 1'b1 && cnt_x_0 >= `PIC_X1 && cnt_x_0 <= `PIC_X2 && cnt_y_0 >= `PIC_Y1 && cnt_y_0 <= `PIC_Y2) begin
        if(cnt_x0_0 == `CORROSION_SIZE - 1) begin
            cnt_x0_0 <= 'b0;
            if(cnt_x1_0 == C_L - 1) begin
                cnt_x1_0 <= 'b0;
                if(cnt_y0_0 == `CORROSION_SIZE - 1) begin
                    cnt_y0_0 <= 'b0;
                    adb <= adb + 'b1;
                end
                else begin
                    cnt_y0_0 <= cnt_y0_0 + 1'b1;
                    adb <= adb - `CORROSION_DX + 1;
                end
            end
            else begin
                cnt_x1_0 <= cnt_x1_0 + 1'b1;
                adb <= adb + 'b1;
            end
        end
        else
            cnt_x0_0 <= cnt_x0_0 + 1'b1;
    end

//----- 第 1 层
// dout_o 是此层 
reg                                     valid_1                    ;
reg                    [16-1:0]         data_1                     ;
reg                                     inpic_1                    ;
always@(posedge sys_clk_2 or negedge sys_rst_n_2)
    if(sys_rst_n_2 == 1'b0) begin
        valid_1 <= 'b0;
        data_1  <= 'b0;
        inpic_1 <= 'b0;
    end
    else begin
        valid_1 <= i_valid;
        data_1  <= i_data ;
        if(i_valid == 1'b1 && cnt_x_0 >= `PIC_X1 && cnt_x_0 <= `PIC_X2 && cnt_y_0 >= `PIC_Y1 && cnt_y_0 <= `PIC_Y2)
            inpic_1 <= 1'b1;
        else
            inpic_1 <= 1'b0;
    end

//----- 第 2 层
always@(posedge sys_clk_2 or negedge sys_rst_n_2)
    if(sys_rst_n_2 == 1'b0) begin
        o_valid    <= 'b0;
        o_data     <= 'b0;
        o_data_raw <= 'b0;
    end
    else begin
        o_valid    <= valid_1;
        if(inpic_1 == 1'b1 && dout_o == 1'b0)
            o_data <= `CORRODE_COLOR;
        else
            o_data <= data_1;
        o_data_raw <= data_1;
    end
    

endmodule