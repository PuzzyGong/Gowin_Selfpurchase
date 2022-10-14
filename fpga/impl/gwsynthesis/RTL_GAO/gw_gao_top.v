module gw_gao(
    \u_show_corrode/cnt_x0[9] ,
    \u_show_corrode/cnt_x0[8] ,
    \u_show_corrode/cnt_x0[7] ,
    \u_show_corrode/cnt_x0[6] ,
    \u_show_corrode/cnt_x0[5] ,
    \u_show_corrode/cnt_x0[4] ,
    \u_show_corrode/cnt_x0[3] ,
    \u_show_corrode/cnt_x0[2] ,
    \u_show_corrode/cnt_x0[1] ,
    \u_show_corrode/cnt_x0[0] ,
    \u_show_corrode/cnt_x1[9] ,
    \u_show_corrode/cnt_x1[8] ,
    \u_show_corrode/cnt_x1[7] ,
    \u_show_corrode/cnt_x1[6] ,
    \u_show_corrode/cnt_x1[5] ,
    \u_show_corrode/cnt_x1[4] ,
    \u_show_corrode/cnt_x1[3] ,
    \u_show_corrode/cnt_x1[2] ,
    \u_show_corrode/cnt_x1[1] ,
    \u_show_corrode/cnt_x1[0] ,
    \u_show_corrode/cnt_y0[9] ,
    \u_show_corrode/cnt_y0[8] ,
    \u_show_corrode/cnt_y0[7] ,
    \u_show_corrode/cnt_y0[6] ,
    \u_show_corrode/cnt_y0[5] ,
    \u_show_corrode/cnt_y0[4] ,
    \u_show_corrode/cnt_y0[3] ,
    \u_show_corrode/cnt_y0[2] ,
    \u_show_corrode/cnt_y0[1] ,
    \u_show_corrode/cnt_y0[0] ,
    \u_corrode/o_valid ,
    \u_corrode/o_wb ,
    \u_corrode/cnt_x[9] ,
    \u_corrode/cnt_x[8] ,
    \u_corrode/cnt_x[7] ,
    \u_corrode/cnt_x[6] ,
    \u_corrode/cnt_x[5] ,
    \u_corrode/cnt_x[4] ,
    \u_corrode/cnt_x[3] ,
    \u_corrode/cnt_x[2] ,
    \u_corrode/cnt_x[1] ,
    \u_corrode/cnt_x[0] ,
    \u_corrode/cnt_y[9] ,
    \u_corrode/cnt_y[8] ,
    \u_corrode/cnt_y[7] ,
    \u_corrode/cnt_y[6] ,
    \u_corrode/cnt_y[5] ,
    \u_corrode/cnt_y[4] ,
    \u_corrode/cnt_y[3] ,
    \u_corrode/cnt_y[2] ,
    \u_corrode/cnt_y[1] ,
    \u_corrode/cnt_y[0] ,
    pre_clk,
    tms_pad_i,
    tck_pad_i,
    tdi_pad_i,
    tdo_pad_o
);

input \u_show_corrode/cnt_x0[9] ;
input \u_show_corrode/cnt_x0[8] ;
input \u_show_corrode/cnt_x0[7] ;
input \u_show_corrode/cnt_x0[6] ;
input \u_show_corrode/cnt_x0[5] ;
input \u_show_corrode/cnt_x0[4] ;
input \u_show_corrode/cnt_x0[3] ;
input \u_show_corrode/cnt_x0[2] ;
input \u_show_corrode/cnt_x0[1] ;
input \u_show_corrode/cnt_x0[0] ;
input \u_show_corrode/cnt_x1[9] ;
input \u_show_corrode/cnt_x1[8] ;
input \u_show_corrode/cnt_x1[7] ;
input \u_show_corrode/cnt_x1[6] ;
input \u_show_corrode/cnt_x1[5] ;
input \u_show_corrode/cnt_x1[4] ;
input \u_show_corrode/cnt_x1[3] ;
input \u_show_corrode/cnt_x1[2] ;
input \u_show_corrode/cnt_x1[1] ;
input \u_show_corrode/cnt_x1[0] ;
input \u_show_corrode/cnt_y0[9] ;
input \u_show_corrode/cnt_y0[8] ;
input \u_show_corrode/cnt_y0[7] ;
input \u_show_corrode/cnt_y0[6] ;
input \u_show_corrode/cnt_y0[5] ;
input \u_show_corrode/cnt_y0[4] ;
input \u_show_corrode/cnt_y0[3] ;
input \u_show_corrode/cnt_y0[2] ;
input \u_show_corrode/cnt_y0[1] ;
input \u_show_corrode/cnt_y0[0] ;
input \u_corrode/o_valid ;
input \u_corrode/o_wb ;
input \u_corrode/cnt_x[9] ;
input \u_corrode/cnt_x[8] ;
input \u_corrode/cnt_x[7] ;
input \u_corrode/cnt_x[6] ;
input \u_corrode/cnt_x[5] ;
input \u_corrode/cnt_x[4] ;
input \u_corrode/cnt_x[3] ;
input \u_corrode/cnt_x[2] ;
input \u_corrode/cnt_x[1] ;
input \u_corrode/cnt_x[0] ;
input \u_corrode/cnt_y[9] ;
input \u_corrode/cnt_y[8] ;
input \u_corrode/cnt_y[7] ;
input \u_corrode/cnt_y[6] ;
input \u_corrode/cnt_y[5] ;
input \u_corrode/cnt_y[4] ;
input \u_corrode/cnt_y[3] ;
input \u_corrode/cnt_y[2] ;
input \u_corrode/cnt_y[1] ;
input \u_corrode/cnt_y[0] ;
input pre_clk;
input tms_pad_i;
input tck_pad_i;
input tdi_pad_i;
output tdo_pad_o;

wire \u_show_corrode/cnt_x0[9] ;
wire \u_show_corrode/cnt_x0[8] ;
wire \u_show_corrode/cnt_x0[7] ;
wire \u_show_corrode/cnt_x0[6] ;
wire \u_show_corrode/cnt_x0[5] ;
wire \u_show_corrode/cnt_x0[4] ;
wire \u_show_corrode/cnt_x0[3] ;
wire \u_show_corrode/cnt_x0[2] ;
wire \u_show_corrode/cnt_x0[1] ;
wire \u_show_corrode/cnt_x0[0] ;
wire \u_show_corrode/cnt_x1[9] ;
wire \u_show_corrode/cnt_x1[8] ;
wire \u_show_corrode/cnt_x1[7] ;
wire \u_show_corrode/cnt_x1[6] ;
wire \u_show_corrode/cnt_x1[5] ;
wire \u_show_corrode/cnt_x1[4] ;
wire \u_show_corrode/cnt_x1[3] ;
wire \u_show_corrode/cnt_x1[2] ;
wire \u_show_corrode/cnt_x1[1] ;
wire \u_show_corrode/cnt_x1[0] ;
wire \u_show_corrode/cnt_y0[9] ;
wire \u_show_corrode/cnt_y0[8] ;
wire \u_show_corrode/cnt_y0[7] ;
wire \u_show_corrode/cnt_y0[6] ;
wire \u_show_corrode/cnt_y0[5] ;
wire \u_show_corrode/cnt_y0[4] ;
wire \u_show_corrode/cnt_y0[3] ;
wire \u_show_corrode/cnt_y0[2] ;
wire \u_show_corrode/cnt_y0[1] ;
wire \u_show_corrode/cnt_y0[0] ;
wire \u_corrode/o_valid ;
wire \u_corrode/o_wb ;
wire \u_corrode/cnt_x[9] ;
wire \u_corrode/cnt_x[8] ;
wire \u_corrode/cnt_x[7] ;
wire \u_corrode/cnt_x[6] ;
wire \u_corrode/cnt_x[5] ;
wire \u_corrode/cnt_x[4] ;
wire \u_corrode/cnt_x[3] ;
wire \u_corrode/cnt_x[2] ;
wire \u_corrode/cnt_x[1] ;
wire \u_corrode/cnt_x[0] ;
wire \u_corrode/cnt_y[9] ;
wire \u_corrode/cnt_y[8] ;
wire \u_corrode/cnt_y[7] ;
wire \u_corrode/cnt_y[6] ;
wire \u_corrode/cnt_y[5] ;
wire \u_corrode/cnt_y[4] ;
wire \u_corrode/cnt_y[3] ;
wire \u_corrode/cnt_y[2] ;
wire \u_corrode/cnt_y[1] ;
wire \u_corrode/cnt_y[0] ;
wire pre_clk;
wire tms_pad_i;
wire tck_pad_i;
wire tdi_pad_i;
wire tdo_pad_o;
wire tms_i_c;
wire tck_i_c;
wire tdi_i_c;
wire tdo_o_c;
wire [9:0] control0;
wire gao_jtag_tck;
wire gao_jtag_reset;
wire run_test_idle_er1;
wire run_test_idle_er2;
wire shift_dr_capture_dr;
wire update_dr;
wire pause_dr;
wire enable_er1;
wire enable_er2;
wire gao_jtag_tdi;
wire tdo_er1;

IBUF tms_ibuf (
    .I(tms_pad_i),
    .O(tms_i_c)
);

IBUF tck_ibuf (
    .I(tck_pad_i),
    .O(tck_i_c)
);

IBUF tdi_ibuf (
    .I(tdi_pad_i),
    .O(tdi_i_c)
);

OBUF tdo_obuf (
    .I(tdo_o_c),
    .O(tdo_pad_o)
);

GW_JTAG  u_gw_jtag(
    .tms_pad_i(tms_i_c),
    .tck_pad_i(tck_i_c),
    .tdi_pad_i(tdi_i_c),
    .tdo_pad_o(tdo_o_c),
    .tck_o(gao_jtag_tck),
    .test_logic_reset_o(gao_jtag_reset),
    .run_test_idle_er1_o(run_test_idle_er1),
    .run_test_idle_er2_o(run_test_idle_er2),
    .shift_dr_capture_dr_o(shift_dr_capture_dr),
    .update_dr_o(update_dr),
    .pause_dr_o(pause_dr),
    .enable_er1_o(enable_er1),
    .enable_er2_o(enable_er2),
    .tdi_o(gao_jtag_tdi),
    .tdo_er1_i(tdo_er1),
    .tdo_er2_i(1'b0)
);

gw_con_top  u_icon_top(
    .tck_i(gao_jtag_tck),
    .tdi_i(gao_jtag_tdi),
    .tdo_o(tdo_er1),
    .rst_i(gao_jtag_reset),
    .control0(control0[9:0]),
    .enable_i(enable_er1),
    .shift_dr_capture_dr_i(shift_dr_capture_dr),
    .update_dr_i(update_dr)
);

ao_top_0  u_la0_top(
    .control(control0[9:0]),
    .trig0_i(\u_corrode/o_valid ),
    .data_i({\u_show_corrode/cnt_x0[9] ,\u_show_corrode/cnt_x0[8] ,\u_show_corrode/cnt_x0[7] ,\u_show_corrode/cnt_x0[6] ,\u_show_corrode/cnt_x0[5] ,\u_show_corrode/cnt_x0[4] ,\u_show_corrode/cnt_x0[3] ,\u_show_corrode/cnt_x0[2] ,\u_show_corrode/cnt_x0[1] ,\u_show_corrode/cnt_x0[0] ,\u_show_corrode/cnt_x1[9] ,\u_show_corrode/cnt_x1[8] ,\u_show_corrode/cnt_x1[7] ,\u_show_corrode/cnt_x1[6] ,\u_show_corrode/cnt_x1[5] ,\u_show_corrode/cnt_x1[4] ,\u_show_corrode/cnt_x1[3] ,\u_show_corrode/cnt_x1[2] ,\u_show_corrode/cnt_x1[1] ,\u_show_corrode/cnt_x1[0] ,\u_show_corrode/cnt_y0[9] ,\u_show_corrode/cnt_y0[8] ,\u_show_corrode/cnt_y0[7] ,\u_show_corrode/cnt_y0[6] ,\u_show_corrode/cnt_y0[5] ,\u_show_corrode/cnt_y0[4] ,\u_show_corrode/cnt_y0[3] ,\u_show_corrode/cnt_y0[2] ,\u_show_corrode/cnt_y0[1] ,\u_show_corrode/cnt_y0[0] ,\u_corrode/o_valid ,\u_corrode/o_wb ,\u_corrode/cnt_x[9] ,\u_corrode/cnt_x[8] ,\u_corrode/cnt_x[7] ,\u_corrode/cnt_x[6] ,\u_corrode/cnt_x[5] ,\u_corrode/cnt_x[4] ,\u_corrode/cnt_x[3] ,\u_corrode/cnt_x[2] ,\u_corrode/cnt_x[1] ,\u_corrode/cnt_x[0] ,\u_corrode/cnt_y[9] ,\u_corrode/cnt_y[8] ,\u_corrode/cnt_y[7] ,\u_corrode/cnt_y[6] ,\u_corrode/cnt_y[5] ,\u_corrode/cnt_y[4] ,\u_corrode/cnt_y[3] ,\u_corrode/cnt_y[2] ,\u_corrode/cnt_y[1] ,\u_corrode/cnt_y[0] }),
    .clk_i(pre_clk)
);

endmodule
