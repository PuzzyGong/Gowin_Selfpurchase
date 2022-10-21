`include "../define.v"

module div_rect
#(
    parameter                           C0_W  = `CORROSION_WIDTH   ,
    parameter                           C_W = C0_W+C0_W+C0_W+C0_W  ,

    parameter                           R_W  = `RECT_NUMMAX_WIDTH  ,
    parameter                           RR_W = `RECT_NUMMAX        ,

    parameter                           V_L  = `CORROSION_DX        
)
(
    input  wire                         sys_clk                    ,
    input  wire                         sys_rst_n                  ,
    input  wire                         item_rst_n                 ,

    input  wire        [   7:0]         i_smax                     ,

    input  wire                         i_valid                    ,
    input  wire                         i_wb                       ,

    output reg                          o_finish                   ,
    output reg         [`RECT_NUMMAX * 32 - 1 : 0] o_item
);
reg                    [`RECT_NUMMAX * 32 - 1 : 0] item_cor        ;//C_W <= 32

//----- stack
reg                    [R_W-1:0]        stack_index  [0:RR_W-1]    ;
reg                                     stack_pop                  ;
reg                                     stack_push                 ;
reg                    [R_W-1:0]        stack_data                 ;
integer i;
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0) begin
        for(i = 0; i < RR_W; i = i + 1)
            stack_index[i] <= i + 1;
    end
    else if(stack_pop == 1'b1) begin
        for(i = 0; i < RR_W - 1; i = i + 1)
            stack_index[i] <= stack_index[i+1];
    end
    else if(stack_push == 1'b1) begin
        for(i = 0; i < RR_W - 1; i = i + 1)
            stack_index[i+1] <= stack_index[i];
        stack_index[0] <= stack_data;
    end

//----- cnt
reg                    [   3:0]         cnt_clk                    ;
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_clk <= 'b0;
    else if(i_valid == 1'b1)
        cnt_clk <= 'b1;
    else if(cnt_clk != 'b0)
        cnt_clk <= cnt_clk + 'b1;

reg                    [C0_W-1:0]       cnt_x                      ;
reg                    [C0_W-1:0]       cnt_y                      ;
reg                    [   7:0]         cnt_finish                 ;
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)begin
        cnt_x <= 'b0;
        cnt_y <= 'b0;
        cnt_finish <= 'b0;
        o_finish <= 'b0; 
    end
    else if(cnt_clk == 'd5)
        if(cnt_x == `CORROSION_DX - 1) begin
            cnt_x <= 'b0;
            if(cnt_y == `CORROSION_DY - 1) begin
                cnt_y <= 'b0;
                cnt_finish <= 1'b1;
            end
            else
                cnt_y <= cnt_y + 1'b1;
        end
        else
            cnt_x <= cnt_x + 1'b1;

    else if(cnt_finish == 'b0) begin
        cnt_finish <= cnt_finish;
        o_finish <= 'b0;
    end
    else if(cnt_finish == `RECT_NUMMAX) begin
        cnt_finish <= 'b0;
        o_finish <= 'b1;
    end
    else begin
        cnt_finish <= cnt_finish + 'b1;
        o_finish <= 'b0;
    end

//----- process
reg                    [   5:0]         state                      ;
localparam                              BLACK = 6'b000_001         ;
localparam                              WHITE = 6'b000_010         ;
localparam                              NONE  = 6'b000_100         ;
localparam                              UP    = 6'b001_000         ;
localparam                              LEFT  = 6'b010_000         ;
localparam                              BOTH  = 6'b100_000         ;

reg                    [R_W-1:0]        last_horizen   [V_L-1:0]   ;
reg                    [R_W-1:0]        left                       ;
reg                    [R_W-1:0]        up                         ;

integer j;
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0) begin
        item_cor   <= 'b0;
        stack_pop  <= 'b0;
        stack_push <= 'b0;
        stack_data <= 'b0;
        state      <= BLACK;
        for(j = 0; j < V_L; j = j + 1)
            last_horizen[j] <= 'b0;
        left <= 'b0;
        up   <= 'b0;
    end
    else if(i_valid == 1'b1) begin
        if(i_wb == 1'b1)
            state <= WHITE;
        else
            state <= BLACK;
        up <= last_horizen[V_L-1];
        if(cnt_x == 0)
            left <= 'b0;
        else
            left <= last_horizen[0];
    end
    else if(cnt_clk == 'd1 && state == WHITE) begin
        if     (up == 'b0 && left == 'b0)
            state      <= NONE;
        else if(up != 'b0 && left == 'b0)
            state      <= UP;
        else if(up == 'b0 && left != 'b0)
            state      <= LEFT;
        else if(up != 'b0 && left != 'b0 && up == left)
            state      <= UP;
        else if(up != 'b0 && left != 'b0 && up != left)
            state      <= BOTH;
    end

    else if(state == UP) begin
        if(cnt_clk == 'd2) begin
            if(cnt_x < item_cor[{up,   5'b0} + 8 + 8 + 8 +: C0_W])
                       item_cor[{up,   5'b0} + 8 + 8 + 8 +: C0_W] <= cnt_x;
            if(cnt_y < item_cor[{up,   5'b0}     + 8 + 8 +: C0_W])
                       item_cor[{up,   5'b0}     + 8 + 8 +: C0_W] <= cnt_y;
            if(cnt_x > item_cor[{up,   5'b0}         + 8 +: C0_W])
                       item_cor[{up,   5'b0}         + 8 +: C0_W] <= cnt_x;
            if(cnt_y > item_cor[{up,   5'b0}             +: C0_W])
                       item_cor[{up,   5'b0}             +: C0_W] <= cnt_y;
            for(j = 1; j < V_L; j = j + 1)
                last_horizen[j] <= last_horizen[j - 1];
            last_horizen[0] <= up;
        end
    end

    else if(state == LEFT) begin
        if(cnt_clk == 'd2) begin
            if(cnt_x < item_cor[{left, 5'b0} + 8 + 8 + 8 +: C0_W])
                       item_cor[{left, 5'b0} + 8 + 8 + 8 +: C0_W] <= cnt_x;
            if(cnt_y < item_cor[{left, 5'b0}     + 8 + 8 +: C0_W])
                       item_cor[{left, 5'b0}     + 8 + 8 +: C0_W] <= cnt_y;
            if(cnt_x > item_cor[{left, 5'b0}         + 8 +: C0_W])
                       item_cor[{left, 5'b0}         + 8 +: C0_W] <= cnt_x;
            if(cnt_y > item_cor[{left, 5'b0}             +: C0_W])
                       item_cor[{left, 5'b0}             +: C0_W] <= cnt_y;
            for(j = 1; j < V_L; j = j + 1)
                last_horizen[j] <= last_horizen[j - 1];
            last_horizen[0] <= left;
        end
    end

    else if(state == NONE) begin
        if(cnt_clk == 'd2) begin
            stack_pop <= 'b1;
            item_cor[{stack_index[0], 5'b0} + 8 + 8 + 8 +: C0_W] <= cnt_x;
            item_cor[{stack_index[0], 5'b0}     + 8 + 8 +: C0_W] <= cnt_y;
            item_cor[{stack_index[0], 5'b0}         + 8 +: C0_W] <= cnt_x;
            item_cor[{stack_index[0], 5'b0}             +: C0_W] <= cnt_y;
            for(j = 1; j < V_L; j = j + 1)
                last_horizen[j] <= last_horizen[j - 1];
            last_horizen[0] <= stack_index[0];
        end
        else if(cnt_clk == 'd3) begin
            stack_pop <= 'b0;
        end
    end

    else if(state == BOTH) begin
        if(cnt_clk == 'd2) begin
            stack_push <= 'b1;
            stack_data <= left;
            if(item_cor[{up,   5'b0} + 8 + 8 + 8 +: C0_W] >  item_cor[{left, 5'b0} + 8 + 8 + 8 +: C0_W])
               item_cor[{up,   5'b0} + 8 + 8 + 8 +: C0_W] <= item_cor[{left, 5'b0} + 8 + 8 + 8 +: C0_W];
            if(item_cor[{up,   5'b0}     + 8 + 8 +: C0_W] >  item_cor[{left, 5'b0}     + 8 + 8 +: C0_W])
               item_cor[{up,   5'b0}     + 8 + 8 +: C0_W] <= item_cor[{left, 5'b0}     + 8 + 8 +: C0_W];
            if(item_cor[{up,   5'b0}         + 8 +: C0_W] <  item_cor[{left, 5'b0}         + 8 +: C0_W])
               item_cor[{up,   5'b0}         + 8 +: C0_W] <= item_cor[{left, 5'b0}         + 8 +: C0_W];
            if(item_cor[{up,   5'b0}             +: C0_W] <  item_cor[{left, 5'b0}             +: C0_W])
               item_cor[{up,   5'b0}             +: C0_W] <= item_cor[{left, 5'b0}             +: C0_W];
            for(j = 1; j < V_L; j = j + 1)
                last_horizen[j] <= last_horizen[j - 1];
            last_horizen[0] <= up;
        end
        else if(cnt_clk == 'd3) begin
            stack_push <= 'b0;
            item_cor[{left,           5'b0} + 8 + 8 + 8 +: C0_W] <= 'b0;
            item_cor[{left,           5'b0}     + 8 + 8 +: C0_W] <= 'b0;
            item_cor[{left,           5'b0}         + 8 +: C0_W] <= 'b0;
            item_cor[{left,           5'b0}             +: C0_W] <= 'b0;
            for(j = 0; j < V_L; j = j + 1)
                if(last_horizen[j] == left)
                    last_horizen[j] <= up;
        end
    end

    else if(state == BLACK) begin
        if(cnt_clk == 'd2) begin
            for(j = 1; j < V_L; j = j + 1)
                last_horizen[j] <= last_horizen[j - 1];
            last_horizen[0] <= 'b0;
        end
    end


//-----
//CORROSION x1坐标 转 LETTER_WRITE x1坐标
//out = in * CORROSION_SIZE / LETTER_PIXEL_SIZE + PIC_X1 / LETTER_PIXEL_SIZE;
//CORROSION y1坐标 转 LETTER_WRITE y1坐标
//out = in * CORROSION_SIZE / LETTER_PIXEL_SIZE;
//CORROSION x2坐标 转 LETTER_WRITE x2坐标
//out = (in + 1) * CORROSION_SIZE / LETTER_PIXEL_SIZE + PIC_X1 / LETTER_PIXEL_SIZE;
//CORROSION y2坐标 转 LETTER_WRITE y2坐标
//out = (in + 1) * CORROSION_SIZE / LETTER_PIXEL_SIZE;

// out = in * (4) + 28;
// out = in * (4) + 00;
// out = in * (4) + 32;
// out = in * (4) + 04;

always@(posedge sys_clk or negedge item_rst_n)
    if(item_rst_n == 1'b0) begin
        o_item <= 'b0;
    end 
    else if(cnt_finish != 0 && cnt_finish != `RECT_NUMMAX) begin
        if( item_cor[{cnt_finish, 5'b0}         + 8 +: 8]  -  item_cor[{cnt_finish, 5'b0} + 8 + 8 + 8 +: 8] < i_smax ||
            item_cor[{cnt_finish, 5'b0}             +: 8]  -  item_cor[{cnt_finish, 5'b0}     + 8 + 8 +: 8] < i_smax)
            o_item  [{cnt_finish, 5'b0} +: 32] <= 'b0;
        else begin
            o_item  [{cnt_finish, 5'b0} + 8 + 8 + 8 +: 8] <= {item_cor[{cnt_finish, 5'b0} + 8 + 8 + 8 +: 6], 2'b0} + 'd28;
            o_item  [{cnt_finish, 5'b0}     + 8 + 8 +: 8] <= {item_cor[{cnt_finish, 5'b0}     + 8 + 8 +: 6], 2'b0} + 'd00;
            o_item  [{cnt_finish, 5'b0}         + 8 +: 8] <= {item_cor[{cnt_finish, 5'b0}         + 8 +: 6], 2'b0} + 'd32;
            o_item  [{cnt_finish, 5'b0}             +: 8] <= {item_cor[{cnt_finish, 5'b0}             +: 6], 2'b0} + 'd04;
        end
    end


endmodule
