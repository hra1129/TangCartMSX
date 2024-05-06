// -----------------------------------------------------------------------------
//	ip_uart.v
//	Copyright (C)2024 Takayuki Hara (HRA!)
//	
//	 Permission is hereby granted, free of charge, to any person obtaining a 
//	copy of this software and associated documentation files (the "Software"), 
//	to deal in the Software without restriction, including without limitation 
//	the rights to use, copy, modify, merge, publish, distribute, sublicense, 
//	and/or sell copies of the Software, and to permit persons to whom the 
//	Software is furnished to do so, subject to the following conditions:
//	
//	The above copyright notice and this permission notice shall be included in 
//	all copies or substantial portions of the Software.
//	
//	The Software is provided "as is", without warranty of any kind, express or 
//	implied, including but not limited to the warranties of merchantability, 
//	fitness for a particular purpose and noninfringement. In no event shall the 
//	authors or copyright holders be liable for any claim, damages or other 
//	liability, whether in an action of contract, tort or otherwise, arising 
//	from, out of or in connection with the Software or the use or other dealings 
//	in the Software.
// -----------------------------------------------------------------------------
//	Description:
//		UART (TX ONLY)
// -----------------------------------------------------------------------------

module ip_uart #(
	parameter		clk_freq	= 21477270,
	parameter		uart_freq	= 115200
) (
	input			n_reset,
	input			clk,
	input	[7:0]	send_data,
	input			send_req,
	output			send_busy,

	output			uart_tx
);
	localparam	uart_cycle		= clk_freq / uart_freq;
	localparam	uart_count_max	= uart_cycle - 1;

	localparam	ST_IDLE			= 4'd0;
	localparam	ST_PRE_START	= 4'd1;
	localparam	ST_START		= 4'd2;
	localparam	ST_D0			= 4'd3;
	localparam	ST_D1			= 4'd4;
	localparam	ST_D2			= 4'd5;
	localparam	ST_D3			= 4'd6;
	localparam	ST_D4			= 4'd7;
	localparam	ST_D5			= 4'd8;
	localparam	ST_D6			= 4'd9;
	localparam	ST_D7			= 4'd10;
	localparam	ST_STOP			= 4'd11;

	reg		[ $clog2( uart_cycle ) + 1: 0 ] ff_uart_count;
	reg		[3:0]	ff_state;
	reg		[9:0]	ff_data;
	reg				ff_busy;

	always @( negedge n_reset or posedge clk ) begin
		if( !n_reset ) begin
			ff_uart_count <= 'd0;
		end
		else if( ff_uart_count == 'd0 ) begin
			ff_uart_count <= uart_count_max;
		end
		else begin
			ff_uart_count <= ff_uart_count - 'd1;
		end
	end

	always @( negedge n_reset or posedge clk ) begin
		if( !n_reset ) begin
			ff_state	<= ST_IDLE;
			ff_data		<= 10'b1111111111;
			ff_busy		<= 1'b0;
		end
		else if( ff_state == ST_IDLE ) begin
			if( send_req == 1'b1 ) begin
				ff_state	<= ST_PRE_START;
				ff_data		<= { send_data, 1'b0, 1'b1 };
				ff_busy		<= 1'b1;
			end
		end
		else if( ff_uart_count == 'd0 ) begin
			if( ff_state > ST_STOP ) begin
				ff_state	<= ST_IDLE;
				ff_busy		<= 1'b0;
			end
			else begin
				ff_state	<= ff_state + 4'd1;
			end
			ff_data		<= { 1'b1, ff_data[9:1] };
		end
	end

	assign uart_tx		= ff_data[0];
	assign send_busy	= ff_busy;
endmodule
