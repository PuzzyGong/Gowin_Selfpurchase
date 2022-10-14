module sfr
#(
	parameter				RST_VALUE 	=	8'd0							,
	parameter				SFR_ADDRESS	=	{2'b00, 14'b00_000_000_000_000}
)
(
	input	wire			sys_clk		,
	input	wire			sys_rst_n	,
	input	wire	[15:0]	i_address	,
	input	wire			i_ad_set	,
	input	wire			i_ad_enable	,
	inout	wire	[7:0]	io_ad_data	,
	
	input	wire			i_set		,
	input	wire			i_enable	,
	input	wire	[7:0]	i_data		,
	output	wire	[7:0]	o_data		,
	output	reg		[7:0]	o_contain	,
	output	reg				o_rd_flag	,
	output	reg				o_wt_flag
);

always@(posedge sys_clk or negedge sys_rst_n)
	if(sys_rst_n == 1'b0)
		o_contain <= RST_VALUE;
	else if(i_set == 1'b1)
		o_contain <= i_data;
	else if(i_address == SFR_ADDRESS && i_ad_set == 1'b1)
		o_contain <= io_ad_data;
		
always@(posedge sys_clk or negedge sys_rst_n)
	if(sys_rst_n == 1'b0)
		o_rd_flag <= 1'b0;
	else if(i_address == SFR_ADDRESS && i_ad_enable == 1'b1)
		o_rd_flag <= 1'b1;
	else
		o_rd_flag <= 1'b0;

always@(posedge sys_clk or negedge sys_rst_n)
	if(sys_rst_n == 1'b0)
		o_wt_flag <= 1'b0;
	else if(i_set == 1'b0 && i_address == SFR_ADDRESS && i_ad_set == 1'b1)
		o_wt_flag <= 1'b1;
	else
		o_wt_flag <= 1'b0;
		
assign io_ad_data = (i_address == SFR_ADDRESS && i_ad_enable == 1'b1) ? o_contain : 8'bzzzz_zzzz;
assign o_data = (i_enable == 1'b1) ? o_contain : 8'bzzzz_zzzz;

endmodule