`timescale 1ns / 1ps

//u16_o = u16_i1 * u16_i2; note: (u16_i1 * u16_i2) > 2 ^ 16则同步报错
module mul
#(
    parameter                           WIDTH = 16                  
)
(
    input  wire                         sys_clk                    ,
    input  wire                         sys_rst_n                  ,

    input  wire        [WIDTH-1:0]      i_data1                    ,
    input  wire        [WIDTH-1:0]      i_data2                    ,

    output reg         [WIDTH-1:0]      o_data                     ,
    output wire                         o_err                       
);
assign o_err = 1'b0;

wire                   [WIDTH-1:0]      tmp_1                      ;

mul_8 u_mul_8(
    .dout                              (tmp_1  [16-1:0]           ),
    .a                                 (i_data1[8-1:0]            ),
    .b                                 (i_data2[8-1:0]            ) 
);

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        o_data <= 'b0;
    else
        o_data <= tmp_1[WIDTH-1:0];


endmodule
