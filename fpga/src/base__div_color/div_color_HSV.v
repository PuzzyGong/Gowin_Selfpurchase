`include "../define.v"

module div_color_HSV
#(
    parameter                           BLACK_COLOR = 16'd0        ,
    
    parameter                           C_W = `COLOR_WIDTH         ,

    //N_W -> NUMBER_WIDTH, 运算数据的位宽
    parameter                           N_W = 16
)
(
    input  wire                         sys_clk                    ,
    input  wire                         sys_rst_n                  ,

    input  wire        [C_W-1:0]        i_R0                       ,
    input  wire        [C_W-1:0]        i_G0                       ,
    input  wire        [C_W-1:0]        i_B0                       ,
    input  wire        [C_W+2-1:0]      i_err                      ,
    input  wire        [C_W+2-1:0]      i_Vmin                     ,
    input  wire        [C_W+2-1:0]      i_Vmax                     ,

    input  wire                         i_valid                    ,
    input  wire        [C_W-1:0]        i_R                        ,
    input  wire        [C_W-1:0]        i_G                        ,
    input  wire        [C_W-1:0]        i_B                        ,
    

    output reg                          o_valid                    ,
    output reg         [C_W-1:0]        o_R                        ,
    output reg         [C_W-1:0]        o_G                        ,
    output reg         [C_W-1:0]        o_B                        ,
    output reg         [C_W-1:0]        o_R_raw                    ,
    output reg         [C_W-1:0]        o_G_raw                    ,
    output reg         [C_W-1:0]        o_B_raw                    ,
    output reg                          o_wb                       
);

//******************** 数据处理 第 1~3 层 ********************

wire                   [N_W-1:0]        tmp_1_1                    ;
reg                    [N_W-1:0]        tmp_1_2                    ;
wire                   [N_W-1:0]        tmp_1_3                    ;
reg                    [N_W-1:0]        tmp_1_4                    ;
wire                   [N_W-1:0]        tmp_1_5                    ;
reg                    [N_W-1:0]        tmp_1_6                    ;
wire                   [N_W-1:0]        tmp_1_7                    ;
wire                   [N_W-1:0]        tmp_2_1                    ;
wire                   [N_W-1:0]        tmp_2_2                    ;
wire                   [N_W-1:0]        tmp_2_3                    ;
reg                    [N_W-1:0]        tmp_2_4                    ;
wire                                    tmp_3_1                    ;

//----- 第 1 层
wire                   [N_W-1:0]        i_RGB                      ;
assign i_RGB = {{(N_W-C_W){1'b0}}, i_R} + {{(N_W-C_W){1'b0}}, i_G} + {{(N_W-C_W){1'b0}}, i_B};

mul u1_mul(
    .sys_clk                           (sys_clk                   ),
    .sys_rst_n                         (sys_rst_n                 ),
    .i_data1                           (i_RGB                     ),
    .i_data2                           ({{(N_W-C_W){1'b0}}, i_R0} ),
    .o_data                            (tmp_1_1                   ),
    .o_err                             (                          ) 
);
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        tmp_1_2 <= 'b0;
    else
        tmp_1_2 <= {{(N_W-C_W-C_W){1'b0}}, i_R, {C_W{1'b0}}};

mul u2_mul(
    .sys_clk                           (sys_clk                   ),
    .sys_rst_n                         (sys_rst_n                 ),
    .i_data1                           (i_RGB                     ),
    .i_data2                           ({{(N_W-C_W){1'b0}}, i_G0} ),
    .o_data                            (tmp_1_3                   ),
    .o_err                             (                          ) 
);
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        tmp_1_4 <= 'b0;
    else
        tmp_1_4 <= {{(N_W-C_W-C_W){1'b0}}, i_G, {C_W{1'b0}}};

mul u3_mul(
    .sys_clk                           (sys_clk                   ),
    .sys_rst_n                         (sys_rst_n                 ),
    .i_data1                           (i_RGB                     ),
    .i_data2                           ({{(N_W-C_W){1'b0}}, i_B0} ),
    .o_data                            (tmp_1_5                   ),
    .o_err                             (                          ) 
);
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        tmp_1_6 <= 'b0;
    else
        tmp_1_6 <= {{(N_W-C_W-C_W){1'b0}}, i_B, {C_W{1'b0}}};

mul u4_mul(
    .sys_clk                           (sys_clk                   ),
    .sys_rst_n                         (sys_rst_n                 ),
    .i_data1                           (i_RGB                     ),
    .i_data2                           ({{(N_W-C_W-2){1'b0}}, i_err}),
    .o_data                            (tmp_1_7                   ),
    .o_err                             (                          ) 
);

//----- 第 2 层
sub_abs u1_sub_abs(
    .sys_clk                           (sys_clk                   ),
    .sys_rst_n                         (sys_rst_n                 ),
    .i_data1                           (tmp_1_1                   ),
    .i_data2                           (tmp_1_2                   ),
    .o_data                            (tmp_2_1                   ) 
);

sub_abs u2_sub_abs(
    .sys_clk                           (sys_clk                   ),
    .sys_rst_n                         (sys_rst_n                 ),
    .i_data1                           (tmp_1_3                   ),
    .i_data2                           (tmp_1_4                   ),
    .o_data                            (tmp_2_2                   ) 
);

sub_abs u3_sub_abs(
    .sys_clk                           (sys_clk                   ),
    .sys_rst_n                         (sys_rst_n                 ),
    .i_data1                           (tmp_1_5                   ),
    .i_data2                           (tmp_1_6                   ),
    .o_data                            (tmp_2_3                   ) 
);

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        tmp_2_4 <= 'b0;
    else
        tmp_2_4 <= tmp_1_7;

//----- 第 3 层 
cmp u1_cmp(
    .sys_clk                           (sys_clk                   ),
    .sys_rst_n                         (sys_rst_n                 ),
    .i_data1                           (tmp_2_1                   ),
    .i_data2                           (tmp_2_2                   ),
    .i_data3                           (tmp_2_3                   ),
    .i_data4                           (tmp_2_4                   ),
    .o_data                            (tmp_3_1                   ) 
);

//******************** 信号同步 第 1~4 层 ********************
reg                                     valid_1                    ;
reg                                     valid_2                    ;
reg                                     valid_3                    ;
reg                    [C_W-1:0]        o_R1                       ;
reg                    [C_W-1:0]        o_G1                       ;
reg                    [C_W-1:0]        o_B1                       ;
reg                    [C_W-1:0]        o_R2                       ;
reg                    [C_W-1:0]        o_G2                       ;
reg                    [C_W-1:0]        o_B2                       ;
reg                    [C_W-1:0]        o_R3                       ;
reg                    [C_W-1:0]        o_G3                       ;
reg                    [C_W-1:0]        o_B3                       ;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
    begin
        valid_1 <= 'b0;
        valid_2 <= 'b0;
        valid_3 <= 'b0;
        o_valid <= 'b0;

        o_R1 <= 'b0;
        o_G1 <= 'b0;
        o_B1 <= 'b0;
        o_R2 <= 'b0;
        o_G2 <= 'b0;
        o_B2 <= 'b0;
        o_R3 <= 'b0;
        o_G3 <= 'b0;
        o_B3 <= 'b0;
        o_R_raw  <= 'b0;
        o_G_raw  <= 'b0;
        o_B_raw  <= 'b0;
    end
    else
    begin
        valid_1 <= i_valid;
        valid_2 <= valid_1;
        valid_3 <= valid_2;
        o_valid <= valid_3;

        o_R1 <= i_R;
        o_G1 <= i_G;
        o_B1 <= i_B;
        o_R2 <= o_R1;
        o_G2 <= o_G1;
        o_B2 <= o_B1;
        o_R3 <= o_R2;
        o_G3 <= o_G2;
        o_B3 <= o_B2;
        o_R_raw  <= o_R3;
        o_G_raw  <= o_G3;
        o_B_raw  <= o_B3; 
    end 


//******************** 数据处理 第 4 层 ********************
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0) begin
        o_wb <= 'b0;
        o_R  <= 'b0;
        o_G  <= 'b0;
        o_B  <= 'b0;
    end
    else if(tmp_3_1 == 1'b1 ||
            {{2'b0, o_R3} + {2'b0, o_G3} + {2'b0, o_B3}} > i_Vmax || 
            {{2'b0, o_R3} + {2'b0, o_G3} + {2'b0, o_B3}} < i_Vmin   ) begin
        o_wb <= 1'b1;
        o_R  <= o_R3;
        o_G  <= o_G3;
        o_B  <= o_B3;
    end
    else begin
        o_wb <= 1'b0; 
        o_R  <= {BLACK_COLOR[15:11], 1'b0};
        o_G  <=  BLACK_COLOR[10:05]       ;
        o_B  <= {BLACK_COLOR[04:00], 1'b0};
    end


endmodule