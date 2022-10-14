//Copyright (C)2014-2022 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: IP file
//GOWIN Version: V1.9.8.07
//Part Number: GW2A-LV18PG256C8/I7
//Device: GW2A-18C
//Created Time: Sun Oct 09 19:04:25 2022

module mul_8 (dout, a, b);

output [15:0] dout;
input [7:0] a;
input [7:0] b;

wire [1:0] dout_w;
wire [8:0] soa_w;
wire [8:0] sob_w;
wire gw_gnd;

assign gw_gnd = 1'b0;

MULT9X9 mult9x9_inst (
    .DOUT({dout_w[1:0],dout[15:0]}),
    .SOA(soa_w),
    .SOB(sob_w),
    .A({gw_gnd,a[7:0]}),
    .B({gw_gnd,b[7:0]}),
    .ASIGN(gw_gnd),
    .BSIGN(gw_gnd),
    .SIA({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd}),
    .SIB({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd}),
    .CE(gw_gnd),
    .CLK(gw_gnd),
    .RESET(gw_gnd),
    .ASEL(gw_gnd),
    .BSEL(gw_gnd)
);

defparam mult9x9_inst.AREG = 1'b0;
defparam mult9x9_inst.BREG = 1'b0;
defparam mult9x9_inst.OUT_REG = 1'b0;
defparam mult9x9_inst.PIPE_REG = 1'b0;
defparam mult9x9_inst.ASIGN_REG = 1'b0;
defparam mult9x9_inst.BSIGN_REG = 1'b0;
defparam mult9x9_inst.SOA_REG = 1'b0;
defparam mult9x9_inst.MULT_RESET_MODE = "SYNC";

endmodule //mul_8
