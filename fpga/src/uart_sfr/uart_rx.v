module	uart_rx
#(
	parameter	BAUD		=	'd115200		,
	parameter	CLK_FREQ	=	'd27_000_000
)
(
	input	wire			sys_clk		,
	input	wire			sys_rst_n	,
	input	wire			rx			,
	
	output	reg		[7:0]	po_data		,
	output	reg				po_flag
);

localparam		CLK_CNT_MAX	=	CLK_FREQ / BAUD - 1;

reg				rx_reg1		;
reg				rx_reg2		;
reg				rx_reg3		;
reg				work_state	;
reg		[15:0]	clk_cnt		;
reg		[3:0]	bit_cnt		;
reg		[7:0]	rx_data		;

always@(posedge sys_clk or negedge sys_rst_n)
	if(sys_rst_n == 1'b0)
		rx_reg1 <= 1'b1;
	else
		rx_reg1 <= rx;
		
always@(posedge sys_clk or negedge sys_rst_n)
	if(sys_rst_n == 1'b0)
		rx_reg2 <= 1'b1;
	else
		rx_reg2 <= rx_reg1;		

always@(posedge sys_clk or negedge sys_rst_n)
	if(sys_rst_n == 1'b0)
		rx_reg3 <= 1'b1;
	else
		rx_reg3 <= rx_reg2;
		
always@(posedge sys_clk or negedge sys_rst_n)
	if(sys_rst_n == 1'b0)
		work_state <= 1'b0;
	else if(work_state == 1'b0 && rx_reg3 == 1'b0)
		work_state <= 1'b1;
	else if(work_state == 1'b1 && clk_cnt == CLK_CNT_MAX / 2 && bit_cnt == 4'd0 && rx_reg3 == 1'b1)
		work_state <= 1'b0;
	else if(work_state == 1'b1 && clk_cnt == CLK_CNT_MAX && bit_cnt == 4'd8)
		work_state <= 1'b0;
		
always@(posedge sys_clk or negedge sys_rst_n)
	if(sys_rst_n == 1'b0)
		clk_cnt <= 16'd0;
	else if(work_state == 1'b0)
		clk_cnt <= 16'd0;
	else if(clk_cnt == CLK_CNT_MAX)
		clk_cnt <= 16'd0;
	else
		clk_cnt	<= clk_cnt + 1'b1;
		
always@(posedge sys_clk or negedge sys_rst_n)
	if(sys_rst_n == 1'b0)
		bit_cnt <= 4'd0;
	else if(work_state == 1'b0)
		bit_cnt <= 4'd0;
	else if(clk_cnt == CLK_CNT_MAX)
		bit_cnt	<= bit_cnt + 1'b1;
		
always@(posedge sys_clk or negedge sys_rst_n)
	if(sys_rst_n == 1'b0)
		rx_data <= 8'd0;
	else if(work_state == 1'b0)
		rx_data <= 8'd0;
	else if(clk_cnt == CLK_CNT_MAX / 2 && bit_cnt >= 4'd1 && bit_cnt <= 4'd8)
		rx_data	<= {rx_reg3, rx_data[7:1]};
		
always@(posedge sys_clk or negedge sys_rst_n)
	if(sys_rst_n == 1'b0)
		po_flag <= 1'b0;
    else if(work_state == 1'b1 && clk_cnt == CLK_CNT_MAX && bit_cnt == 4'd8)
		po_flag <= 1'b1;
	else
		po_flag <= 1'b0;
		
always@(posedge sys_clk or negedge sys_rst_n)
	if(sys_rst_n == 1'b0)
		po_data <= 8'd0;
    else if(work_state == 1'b1 && clk_cnt == CLK_CNT_MAX && bit_cnt == 4'd8)
		po_data <= rx_data;
		
		
endmodule