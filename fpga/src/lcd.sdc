//Copyright (C)2014-2022 GOWIN Semiconductor Corporation.
//All rights reserved.
//File Title: Timing Constraints file
//GOWIN Version: 1.9.8.07 
//Created Time: 2022-10-02 20:16:40
create_clock -name sys_clk -period 37.037 -waveform {0 18.518} [get_ports {sys_clk}]
create_clock -name memory_clk -period 2.5 -waveform {0 1.25} [get_nets {u_interfaces_top/memory_clk}]
create_clock -name cmos_vsync -period 1000 -waveform {0 500} [get_ports {cmos_vsync}] -add
create_clock -name cmos_pclk -period 10 -waveform {0 5} [get_ports {cmos_pclk}] -add
report_timing -hold -from_clock [get_clocks {sys_clk*}] -to_clock [get_clocks {sys_clk*}] -max_paths 25 -max_common_paths 1
report_timing -setup -from_clock [get_clocks {sys_clk*}] -to_clock [get_clocks {sys_clk*}] -max_paths 25 -max_common_paths 1
