`include "../define.v"

module div_color
#(
    parameter                           C_W = `COLOR_WIDTH 
)
(
    input  wire                         sys_clk                    ,
    input  wire                         sys_rst_n                  ,

    input  wire        [C_W-1:0]        i_a_R0                     ,
    input  wire        [C_W-1:0]        i_a_G0                     ,
    input  wire        [C_W-1:0]        i_a_B0                     ,
    input  wire        [C_W+2-1:0]      i_a_err                    ,
    input  wire        [C_W+2-1:0]      i_a_Vmin                   ,
    input  wire        [C_W+2-1:0]      i_a_Vmax                   ,

    input  wire        [C_W-1:0]        i_b_R0                     ,
    input  wire        [C_W-1:0]        i_b_G0                     ,
    input  wire        [C_W-1:0]        i_b_B0                     ,
    input  wire        [C_W+2-1:0]      i_b_err                    ,
    input  wire        [C_W+2-1:0]      i_b_Vmin                   ,
    input  wire        [C_W+2-1:0]      i_b_Vmax                   ,

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

wire                                    o_a_valid                  ;
wire                   [C_W-1:0]        o_a_R                      ;
wire                   [C_W-1:0]        o_a_G                      ;
wire                   [C_W-1:0]        o_a_B                      ;
wire                   [C_W-1:0]        o_a_R_raw                  ;
wire                   [C_W-1:0]        o_a_G_raw                  ;
wire                   [C_W-1:0]        o_a_B_raw                  ;
wire                                    o_a_wb                     ;

wire                                    o_b_valid                  ;
wire                   [C_W-1:0]        o_b_R                      ;
wire                   [C_W-1:0]        o_b_G                      ;
wire                   [C_W-1:0]        o_b_B                      ;
wire                   [C_W-1:0]        o_b_R_raw                  ;
wire                   [C_W-1:0]        o_b_G_raw                  ;
wire                   [C_W-1:0]        o_b_B_raw                  ;
wire                                    o_b_wb                     ;

//----- 第 1~4 层
//SKIN
div_color_HSV
#(
    .BLACK_COLOR                       (16'b00000_000010_00000    )
)
u1_div_color_HSV(
    .sys_clk                           (sys_clk                   ),
    .sys_rst_n                         (sys_rst_n                 ),
    .i_R0                              (i_a_R0                    ),
    .i_G0                              (i_a_G0                    ),
    .i_B0                              (i_a_B0                    ),
    .i_err                             (i_a_err                   ),
    .i_Vmin                            (i_a_Vmin                  ),
    .i_Vmax                            (i_a_Vmax                  ),
    .i_valid                           (i_valid                   ),
    .i_R                               (i_R                       ),
    .i_G                               (i_G                       ),
    .i_B                               (i_B                       ),
    .o_valid                           (o_a_valid                 ),
    .o_R                               (o_a_R                     ),
    .o_G                               (o_a_G                     ),
    .o_B                               (o_a_B                     ),
    .o_R_raw                           (o_a_R_raw                 ),
    .o_G_raw                           (o_a_G_raw                 ),
    .o_B_raw                           (o_a_B_raw                 ),
    .o_wb                              (o_a_wb                    ) 
);

//WHITE
div_color_HSV
#(
    .BLACK_COLOR                       (16'b00010_000000_00000    )
)
u2_div_color_HSV(
    .sys_clk                           (sys_clk                   ),
    .sys_rst_n                         (sys_rst_n                 ),
    .i_R0                              (i_b_R0                    ),
    .i_G0                              (i_b_G0                    ),
    .i_B0                              (i_b_B0                    ),
    .i_err                             (i_b_err                   ),
    .i_Vmin                            (i_b_Vmin                  ),
    .i_Vmax                            (i_b_Vmax                  ),
    .i_valid                           (i_valid                   ),
    .i_R                               (i_R                       ),
    .i_G                               (i_G                       ),
    .i_B                               (i_B                       ),
    .o_valid                           (o_b_valid                 ),
    .o_R                               (o_b_R                     ),
    .o_G                               (o_b_G                     ),
    .o_B                               (o_b_B                     ),
    .o_R_raw                           (o_b_R_raw                 ),
    .o_G_raw                           (o_b_G_raw                 ),
    .o_B_raw                           (o_b_B_raw                 ),
    .o_wb                              (o_b_wb                    ) 
);

//----- 第 5 层
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0) begin
        o_valid <= 'd0;
        o_R     <= 'd0;
        o_G     <= 'd0;
        o_B     <= 'd0;
        o_R_raw <= 'd0;
        o_G_raw <= 'd0;
        o_B_raw <= 'd0;
        o_wb    <= 'd0;
    end
    else begin
//-----优先选 a
        o_valid  <= o_a_valid                       ;
        o_R      <= (o_a_wb == 'b0) ? o_a_R : o_b_R ;
        o_G      <= (o_a_wb == 'b0) ? o_a_G : o_b_G ;
        o_B      <= (o_a_wb == 'b0) ? o_a_B : o_b_B ;
        o_R_raw  <= o_a_R_raw                       ;
        o_G_raw  <= o_a_G_raw                       ;
        o_B_raw  <= o_a_B_raw                       ;
        o_wb     <= o_a_wb & o_b_wb                 ;
    end

endmodule