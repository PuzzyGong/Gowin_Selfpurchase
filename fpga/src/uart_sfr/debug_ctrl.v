module debug_ctrl
#(
	parameter	BAUD		=	'd115200		,
	parameter	CLK_FREQ	=	'd27_000_000
)
(
	input	wire			sys_clk		,
	input	wire			sys_rst_n	,
	inout	wire	[7:0]	data_io		,
	output	reg		[15:0]	d_address	,
	output	reg				d_set		,
	output	reg				d_enable	,
	
	input	wire	[7:0]	pi_data		,
	input	wire			pi_flag		,
	output	reg		[7:0]	po_data		,
	output	reg				po_flag
);
localparam		CLK_CNT_MAX	=	CLK_FREQ	/	BAUD	-	1	;

//read one location
localparam	DD			=	8'hdd	;

//write one location
localparam	EE			=	8'hee	;

//read many locations
localparam	DA			=	8'hda	;
localparam	MAX_DA_LEN	=	10'd64	;
reg		[9:0]	DA_len		;

//write many locations
localparam	EA			=	8'hea	;
reg		[7:0]	max_EA_len	;
reg		[7:0]	EA_len		;


reg		[19:0]	clk_cnt		;
reg		[23:0]	state		;

localparam	FREE		=	24'h000_001;
localparam	DD_1		=	24'h000_002;
localparam	DD_2		=	24'h000_004;
localparam	DD_3		=	24'h000_008;
localparam	EE_1		=	24'h000_010;
localparam	EE_2		=	24'h000_020;
localparam	EE_3		=	24'h000_040;
localparam	EE_4		=	24'h000_080;
localparam	DA_1		=	24'h000_100;
localparam	DA_2		=	24'h000_200;
localparam	DA_3		=	24'h000_400;
localparam	EA_1		=	24'h000_800;
localparam	EA_2		=	24'h001_000;
localparam	EA_3		=	24'h002_000;
localparam	EA_4		=	24'h004_000;
localparam	EA_5		=	24'h008_000;

`define		FREE_GETSIGNAL	(pi_flag == 1'b1 && state == FREE)
`define 	DD_1_GETSIGNAL	(pi_flag == 1'b1 && state == DD_1)
`define 	DD_2_GETSIGNAL	(pi_flag == 1'b1 && state == DD_2)
`define 	DD_3_GETSIGNAL	(pi_flag == 1'b1 && state == DD_3)
`define 	EE_1_GETSIGNAL	(pi_flag == 1'b1 && state == EE_1)
`define 	EE_2_GETSIGNAL	(pi_flag == 1'b1 && state == EE_2)
`define 	EE_3_GETSIGNAL	(pi_flag == 1'b1 && state == EE_3)
`define 	EE_4_GETSIGNAL	(pi_flag == 1'b1 && state == EE_4)
`define 	DA_1_GETSIGNAL	(pi_flag == 1'b1 && state == DA_1)
`define 	DA_2_GETSIGNAL	(pi_flag == 1'b1 && state == DA_2)
`define 	DA_3_GETSIGNAL	(pi_flag == 1'b1 && state == DA_3)
`define 	EA_1_GETSIGNAL	(pi_flag == 1'b1 && state == EA_1)
`define 	EA_2_GETSIGNAL	(pi_flag == 1'b1 && state == EA_2)
`define 	EA_3_GETSIGNAL	(pi_flag == 1'b1 && state == EA_3)
`define 	EA_4_GETSIGNAL	(pi_flag == 1'b1 && state == EA_4)
`define 	EA_5_GETSIGNAL	(pi_flag == 1'b1 && state == EA_5)

always@(posedge sys_clk or negedge sys_rst_n)
	if(sys_rst_n == 1'b0)
		state <= FREE;
	else if(`FREE_GETSIGNAL && pi_data == DD)
		state <= DD_1;
	else if(`FREE_GETSIGNAL && pi_data == EE)
		state <= EE_1;
	else if(`FREE_GETSIGNAL && pi_data == DA)
		state <= DA_1;
	else if(`FREE_GETSIGNAL && pi_data == EA)
		state <= EA_1;
		
	else if(`DD_1_GETSIGNAL)
		state <= DD_2;
	else if(`DD_2_GETSIGNAL)
		state <= DD_3;	
	else if(state == DD_3 && clk_cnt == 20'd3)
		state <= FREE;
		
	else if(`EE_1_GETSIGNAL)
		state <= EE_2;
	else if(`EE_2_GETSIGNAL)
		state <= EE_3;
	else if(`EE_3_GETSIGNAL)
		state <= EE_4;		
	else if(state == EE_4 && clk_cnt == 20'd3)
		state <= FREE;
	
	else if(`DA_1_GETSIGNAL)
		state <= DA_2;
	else if(`DA_2_GETSIGNAL)
		state <= DA_3;
	else if(state == DA_3 && DA_len == MAX_DA_LEN)
		state <= FREE;

	else if(`EA_1_GETSIGNAL)
		state <= EA_2;
	else if(`EA_2_GETSIGNAL)
		state <= EA_3;
	else if(`EA_3_GETSIGNAL)
		state <= EA_4;
	else if(`EA_4_GETSIGNAL)
		state <= EA_5;			
	else if(state == EA_5 && EA_len == max_EA_len)
		state <= FREE;
		
always@(posedge sys_clk or negedge sys_rst_n)
	if(sys_rst_n == 1'b0)
		clk_cnt <= 20'd0;
	else if(pi_flag == 1'b1)
		clk_cnt <= 20'd1;
	else if(clk_cnt == {CLK_CNT_MAX, 4'b0000})
		clk_cnt <= 20'd0;
	else
		clk_cnt <= clk_cnt + 20'b1;
		
always@(posedge sys_clk or negedge sys_rst_n)
	if(sys_rst_n == 1'b0)
		DA_len <= 10'd0;
	else if(state != DA_3)
		DA_len <= 10'd0;
	else if(state == DA_3 && po_flag == 1'b1)
		DA_len <= DA_len + 1'b1;

always@(posedge sys_clk or negedge sys_rst_n)
	if(sys_rst_n == 1'b0)
		EA_len <= 8'd0;
	else if(`EA_5_GETSIGNAL || `EA_4_GETSIGNAL)
		EA_len <= EA_len + 1'b1;
	else if(state == FREE)
		EA_len <= 8'd0;

always@(posedge sys_clk or negedge sys_rst_n)
	if(sys_rst_n == 1'b0)
		max_EA_len <= 8'd0;
	else if(`EA_3_GETSIGNAL)
		max_EA_len <= pi_data;

always@(posedge sys_clk or negedge sys_rst_n)
	if(sys_rst_n == 1'b0)
		d_address <= 16'd0;
	else if(`DD_1_GETSIGNAL || `EE_1_GETSIGNAL || `DA_1_GETSIGNAL || `EA_1_GETSIGNAL)
		d_address <= {pi_data, d_address[7:0]};
	else if(`DD_2_GETSIGNAL || `EE_2_GETSIGNAL || `DA_2_GETSIGNAL || `EA_2_GETSIGNAL)
		d_address <= {d_address[15:8], pi_data};
	else if(state == DA_3 && po_flag == 1'b1)
		d_address <= d_address + 1'b1;
	else if(`EA_5_GETSIGNAL)
		d_address <= d_address + 1'b1;

always@(posedge sys_clk or negedge sys_rst_n)
	if(sys_rst_n == 1'b0)
		d_set <= 1'd0;
	else if(`EE_3_GETSIGNAL || `EA_4_GETSIGNAL || `EA_5_GETSIGNAL)
		d_set <= 1'd1;
	else
		d_set <= 1'b0;
		
always@(posedge sys_clk or negedge sys_rst_n)
	if(sys_rst_n == 1'b0)
		d_enable <= 1'd0;
	else if(state == DD_3 && clk_cnt == 20'd1)
		d_enable <= 1'd1;
	else if(state == DA_3 && clk_cnt == 20'd1)
		d_enable <= 1'd1;
	else
		d_enable <= 1'b0;
		
always@(posedge sys_clk or negedge sys_rst_n)
	if(sys_rst_n == 1'b0)
		po_data <= 8'd0;
	else if(state == DD_3 && clk_cnt == 20'd2)
		po_data <= data_io;
	else if(state == DA_3 && clk_cnt == 20'd2)
		po_data <= data_io;	

always@(posedge sys_clk or negedge sys_rst_n)
	if(sys_rst_n == 1'b0)
		po_flag <= 1'd0;
	else if(state == DD_3 && clk_cnt == 20'd2)
		po_flag <= 1'b1;
	else if(state == DA_3 && clk_cnt == 20'd2)
		po_flag <= 1'b1;	
	else
		po_flag <= 1'b0;
		
assign data_io = (d_set) ? pi_data : 8'bzzzz_zzzz;

endmodule