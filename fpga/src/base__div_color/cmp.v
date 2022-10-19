`timescale 1ns / 1ps

//u1_o = (u16_i1 + u16_i2) > u16_i3;
module cmp
#(
    parameter                           WIDTH = 16                  
)
(
    input  wire                         sys_clk                    ,
    input  wire                         sys_rst_n                  ,

    input  wire        [WIDTH-1:0]      i_data1                    ,
    input  wire        [WIDTH-1:0]      i_data2                    ,
    input  wire        [WIDTH-1:0]      i_data3                    ,
    input  wire        [WIDTH-1:0]      i_data4                    ,

    output reg                          o_data                      
);

wire                   [WIDTH:0]        tmp_1                      ;
assign tmp_1 = {1'b0, i_data1} + {1'b0, i_data2} + {1'b0, i_data3};

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        o_data <= 'b0;
    else if(tmp_1 > {1'b0, i_data4})
        o_data <= 1'b1;
    else
        o_data <= 1'b0;

endmodule