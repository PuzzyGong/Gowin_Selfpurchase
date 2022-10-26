//Copyright (C)2014-2022 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//GOWIN Version: V1.9.8.07
//Part Number: GW2A-LV18PG256C8/I7
//Device: GW2A-18C
//Created Time: Tue Oct 25 20:51:08 2022

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

    ROM_picture your_instance_name(
        .dout(dout_o), //output [0:0] dout
        .clk(clk_i), //input clk
        .oce(oce_i), //input oce
        .ce(ce_i), //input ce
        .reset(reset_i), //input reset
        .ad(ad_i) //input [16:0] ad
    );

//--------Copy end-------------------
