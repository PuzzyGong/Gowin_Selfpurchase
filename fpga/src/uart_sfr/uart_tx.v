module	uart_tx
#(
	parameter	BAUD		=	'd115200		,
	parameter	CLK_FREQ	=	'd27_000_000
)
(
	input	wire			sys_clk		,
	input	wire			sys_rst_n	,
	input	wire	[7:0]	pi_data		,
	input	wire	       	pi_flag		,

	output	reg				tx	 		
);

localparam		CLK_CNT_MAX	=	CLK_FREQ	 / BAUD - 1;

reg				work_state	;
reg		[15:0]	clk_cnt		;
reg		[3:0]	bit_cnt		;
reg		[7:0]	tx_data		;

always@(posedge sys_clk or negedge sys_rst_n)
	if(sys_rst_n == 1'b0)
		work_state <= 1'b0;
	else if(work_state == 1'b0 && pi_flag == 1'b1 )
		work_state <= 1'b1;
	else if(work_state == 1'b1 && bit_cnt == 4'd8 && clk_cnt == CLK_CNT_MAX)
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
		tx_data <= 8'd0;
	else if(pi_flag == 1'b1)
		tx_data <= pi_data;

always@(posedge sys_clk or negedge sys_rst_n)
	if(sys_rst_n == 1'b0)
		tx <= 1'b1;
	else if(work_state == 1'b0)
		tx <= 1'b1;
	else
		begin
			case(bit_cnt)
				4'b0000:	tx <= 1'b0	;
				4'b0001:	tx <= tx_data[0]	;
				4'b0010:	tx <= tx_data[1]	;
				4'b0011:	tx <= tx_data[2]	;
				4'b0100:	tx <= tx_data[3]	;
				4'b0101:	tx <= tx_data[4]	;
				4'b0110:	tx <= tx_data[5]	;
				4'b0111:	tx <= tx_data[6]	;
				4'b1000:	tx <= tx_data[7]	;
				default:	tx <= tx_data[7]	;
			endcase
		end

endmodule