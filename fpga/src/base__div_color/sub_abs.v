`timescale 1ns / 1ps

//u16_o = abs(u16_i1 - u16_i2);
module sub_abs
#(
    parameter                           WIDTH = 16                  
)
(
    input  wire                         sys_clk                    ,
    input  wire                         sys_rst_n                  ,

    input  wire        [WIDTH-1:0]      i_data1                    ,
    input  wire        [WIDTH-1:0]      i_data2                    ,

    output reg         [WIDTH-1:0]      o_data                      
);

wire                   [WIDTH:0]        tmp_1                      ;
assign tmp_1 = {1'b0, ~i_data1} + {1'b0, i_data2} + 1'b1;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        o_data <= 'b0;
    else if(tmp_1[WIDTH] == 1'b1)
        o_data <= tmp_1[WIDTH-1:0];
    else
        o_data <= ~tmp_1[WIDTH-1:0] + 1'b1;

endmodule
