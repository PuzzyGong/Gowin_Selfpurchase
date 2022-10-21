`include "../define.v"


module show_rect_ascii
#(
    parameter                           A_W = `ASCII_WIDTH         ,
    parameter                           P_W = `POSITION_WIDTH      ,
    parameter                           L_W = `LETTER_PIXEL_WIDTH
)
(
    input  wire                         sys_clk                    ,
    input  wire                         sys_rst_n                  ,

    input  wire        [`RECT_NUMMAX * 4  - 1 : 0]   i_label       , 
    input  wire        [`RECT_NUMMAX * 32 - 1 : 0]   i_item        ,
    input  wire        [`RECT_NUMMAX * 32 - 1 : 0]   i_otheritem   ,

    input  wire        [128 - 1 : 0]    i_varies                   ,

    input  wire                         i_valid                    ,
    input  wire        [16-1:0]         i_data                     ,
    output wire                         o_valid                    ,
    output wire        [16-1:0]         o_data                     , 
    output wire        [16-1:0]         o_data_raw 
);

wire                   [16 * ( 8 * 8) - 1 : 0]  wire_label_str     ;
wire                   [16 * ( 8 * 8) - 1 : 0]  wire_varies        ;
wire                   [16 * (32 * 8) - 1 : 0]  wire_const_str     ;
wire                   [A_W-1:0]        wire_ascii                 ;
wire                   [   2:0]         wire_color                 ;
wire                   [L_W-1:0]        wire_ys                    ;
wire                   [L_W-1:0]        wire_ye                    ;
wire                   [L_W-1:0]        wire_x                     ;
wire                   [L_W-1:0]        wire_y                     ;
wire                   [L_W-1:0]        wire_x1                    ;
wire                   [L_W-1:0]        wire_y1                    ;
wire                   [L_W-1:0]        wire_x2                    ;
wire                   [L_W-1:0]        wire_y2                    ;

label_str u_label_str
(
    .o_str                             (wire_label_str            ) 
);

varies u_varies(
    .sys_clk                           (sys_clk                   ),
    .sys_rst_n                         (sys_rst_n                 ),
    .i_varies                          (i_varies                  ),
    .o_str                             (wire_varies               ) 
);

const_str u_const_str
(
    .o_str                             (wire_const_str            ) 
);

show_rect_ascii_ctrl u_show_rect_ascii_ctrl
(
    .sys_clk                           (sys_clk                   ),
    .sys_rst_n                         (sys_rst_n                 ),
    .i_label                           (i_label                   ),
    .i_item                            (i_item                    ),
    .i_otheritem                       (i_otheritem               ),
    .i_label_str                       (wire_label_str            ),
    .i_varies                          (wire_varies               ),
    .i_const_str                       (wire_const_str            ),
    .o_ascii                           (wire_ascii                ),
    .o_color                           (wire_color                ),
    .o_ys                              (wire_ys                   ),
    .o_ye                              (wire_ye                   ),
    .o_x                               (wire_x                    ),
    .o_y                               (wire_y                    ),
    .o_x1                              (wire_x1                   ),
    .o_y1                              (wire_y1                   ),
    .o_x2                              (wire_x2                   ),
    .o_y2                              (wire_y2                   ),
    .i_valid                           (i_valid                   )
);

show_rect_ascii_single u_show_rect_ascii_single
(
    .sys_clk                           (sys_clk                   ),
    .sys_rst_n                         (sys_rst_n                 ),
    .i_ascii                           (wire_ascii                ),
    .i_color                           (wire_color                ),
    .i_ys                              (wire_ys                   ),
    .i_ye                              (wire_ye                   ),
    .i_x                               (wire_x                    ),
    .i_y                               (wire_y                    ),
    .i_x1                              (wire_x1                   ),
    .i_y1                              (wire_y1                   ),
    .i_x2                              (wire_x2                   ),
    .i_y2                              (wire_y2                   ),
    .i_valid                           (i_valid                   ),
    .i_data                            (i_data                    ),
    .o_valid                           (o_valid                   ),
    .o_data                            (o_data                    ),
    .o_data_raw                        (o_data_raw                )
);




endmodule