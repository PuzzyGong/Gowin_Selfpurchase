`include "../define.v"

module conv
#(
    parameter                           P_W = `POSITION_WIDTH
)
(
    input  wire                         sys_clk                    ,
    input  wire                         sys_rst_n                  ,
    input  wire                         item_rst_n                 ,

    input  wire        [P_W-1:0]        cnt_x_5                    ,
    input  wire        [P_W-1:0]        cnt_y_5                    ,
    input  wire                         inpic_5                    ,
    input  wire                         RED____wb                  ,
    input  wire                         GREEN__wb                  ,
    input  wire                         BLUE___wb                  ,
    input  wire                         YELLOW_wb                  ,
    input  wire                         BLACK__wb                  ,
    input  wire                         WHITE__wb                  ,

    input  wire        [32-1:0]         i_item                     ,
    output reg         [32-1:0]         o_item                     ,
    output reg         [64-1:0]         o_label                     
);
reg                    [5-1:0]         RED____cnt                 ;
reg                    [5-1:0]         GREEN__cnt                 ;
reg                    [5-1:0]         BLUE___cnt                 ;
reg                    [5-1:0]         YELLOW_cnt                 ;
reg                    [5-1:0]         BLACK__cnt                 ;
reg                    [5-1:0]         WHITE__cnt                 ;


always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0) begin
        RED____cnt <= 'd0;
        GREEN__cnt <= 'd0;
        BLUE___cnt <= 'd0;
        YELLOW_cnt <= 'd0;
        BLACK__cnt <= 'd0;
        WHITE__cnt <= 'd0;
    end
    else if( inpic_5 == 1'b1 && cnt_x_5 >= i_item[3 * 8 +: 8] && cnt_y_5 >= i_item[2 * 8 +: 8] &&
                                cnt_x_5 <= i_item[1 * 8 +: 8] && cnt_y_5 <= i_item[0 * 8 +: 8] ) begin
        if(RED____wb == 1'b0)
            RED____cnt <= RED____cnt + 'b1;
        else if(GREEN__wb == 1'b0)
            GREEN__cnt <= GREEN__cnt + 'b1;
        else if(BLUE___wb == 1'b0)
            BLUE___cnt <= BLUE___cnt + 'b1;
        else if(YELLOW_wb == 1'b0)
            YELLOW_cnt <= YELLOW_cnt + 'b1;
        else if(BLACK__wb == 1'b0)
            BLACK__cnt <= BLACK__cnt + 'b1;
        else
            WHITE__cnt <= WHITE__cnt + 'b1;
    end

always@(posedge sys_clk or negedge item_rst_n)
    if(item_rst_n == 1'b0) begin
        o_item  <= 'd0;
        o_label <= "abababab";
    end
    else if( inpic_5 == 1'b1 && cnt_x_5 == `PIC_X2 && cnt_y_5 == `PIC_Y2) begin
        o_item  <= i_item;
        if     (YELLOW_cnt > 'b01000)
            o_label <= "Pie +2.2";

        else if(BLUE___cnt > 'b01000)
            o_label <= "Pesi+2.0";
        
        else if(RED____cnt > 'b01000 &&
                BLACK__cnt > 'b01000)
            o_label <= "Tang+4.0";

        else if(RED____cnt > 'b01000 &&
                i_item[3 * 8 +: 8] - i_item[1 * 8 +: 8] >
                i_item[2 * 8 +: 8] - i_item[0 * 8 +: 8])
            o_label <= "Choc+5.0";

        else if(RED____cnt > 'b01000 &&
                i_item[3 * 8 +: 8] - i_item[1 * 8 +: 8] <
                i_item[2 * 8 +: 8] - i_item[0 * 8 +: 8] + 8)
            o_label <= "Cret+5.0";

        else if(RED____cnt > 'b01000 &&
                i_item[3 * 8 +: 8] - i_item[1 * 8 +: 8] <
                i_item[2 * 8 +: 8] - i_item[0 * 8 +: 8] + 6)
            o_label <= "Cre5+5.0";

        else if(RED____cnt > 'b01000 &&
                i_item[3 * 8 +: 8] - i_item[1 * 8 +: 8] <
                i_item[2 * 8 +: 8] - i_item[0 * 8 +: 8] + 4)
            o_label <= "Cre7+5.0";

        else
            o_label <= "cdcdcdcd";
    end

endmodule