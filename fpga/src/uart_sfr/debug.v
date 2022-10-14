module debug
(
	input	wire			sys_clk		,
	input	wire			sys_rst_n	,
	inout	wire	[7:0]	data_io     ,
	output	wire	[15:0]	d_address	,
	output	wire			d_set		,
	output	wire			d_enable	,
	
	input	wire			rx			,
	output	wire			tx
);

wire	[7:0]	pi_data		;
wire			pi_flag		;
wire	[7:0]	po_data		;
wire			po_flag     ;

debug_ctrl debug_ctrl_inst
(
	.sys_clk	(sys_clk	),
	.sys_rst_n	(sys_rst_n	),
	.data_io	(data_io    ),
	.d_address	(d_address	),
	.d_set		(d_set		),
	.d_enable	(d_enable	),

	.pi_data	(po_data	),
	.pi_flag	(po_flag	),
	.po_data	(pi_data	),
	.po_flag	(pi_flag    )
);

uart_tx uart_tx_inst
(
	.sys_clk	(sys_clk	),
	.sys_rst_n	(sys_rst_n	),
	.pi_data	(pi_data	),
	.pi_flag	(pi_flag	),
                 
	.tx			(tx			)
);
 
uart_rx uart_rx_inst
(
	.sys_clk	(sys_clk	),
	.sys_rst_n	(sys_rst_n	),
	.rx			(rx			),
                 
	.po_data	(po_data	),
	.po_flag	(po_flag    )
);

endmodule