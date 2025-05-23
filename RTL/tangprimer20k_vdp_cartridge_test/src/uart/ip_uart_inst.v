// -----------------------------------------------------------------------------
//	ip_uart_inst.v
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

module ip_uart_inst #(
	parameter		clk_freq	= 27000000,
	parameter		uart_freq	= 115200
) (
	input			reset_n,
	input			clk,
	input			enable,
	input			iorq_n,
	input			wr_n,
	input			rd_n,
	input	[7:0]	a,
	input	[7:0]	d,
	output	[7:0]	q,
	output			q_en,
	input	[1:0]	button,
	output	[5:0]	led,
	output			uart_tx
);
	reg		[7:0]	ff_d;
	reg				ff_wr_n;
	reg				ff_req;
	reg				ff_hold;
	wire			w_busy;
	wire			w_dec;
	reg		[5:0]	ff_led;

	assign w_dec	= !iorq_n && ( { a[7:1], 1'b0 } == 8'h10 );
	assign q		= (w_dec && !rd_n) ? ( ( !a[0] ) ? { button, 5'd0, w_busy }: { 2'd0, ff_led } ) : 8'd0;
	assign q_en		= (w_dec && !rd_n);
	assign led		= ff_led;

	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_wr_n <= 1'b1;
		end
		else if( enable ) begin
			ff_wr_n <= wr_n;
		end
		else begin
			//	hold
		end
	end

	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_d <= 8'd0;
		end
		else if( enable ) begin
			if( w_dec && !a[0] && !ff_wr_n ) begin
				ff_d <= d;
			end
			else begin
				//	hold
			end
		end
		else begin
			//	hold
		end
	end

	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_hold <= 1'b0;
		end
		else if( enable && w_dec && !ff_wr_n ) begin
			ff_hold <= 1'b1;
		end
		else if( ff_wr_n ) begin
			ff_hold <= 1'b0;
		end
		else begin
			//	hold
		end
	end

	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_req <= 1'b0;
		end
		else if( enable && w_dec && !a[0] && !ff_wr_n && !ff_hold ) begin
			ff_req <= 1'b1;
		end
		else if( !w_busy ) begin
			ff_req <= 1'b0;
		end
		else begin
			//	hold
		end
	end

	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_led <= 6'b0;
		end
		else if( enable && w_dec && a[0] && !ff_wr_n && !ff_hold ) begin
			ff_led <= d[5:0];
		end
		else begin
			//	hold
		end
	end

	ip_uart #(
		.clk_freq		( clk_freq		),
		.uart_freq		( uart_freq		)
	) u_uart (
		.n_reset		( reset_n		),
		.clk			( clk			),
		.send_data		( ff_d			),
		.send_req		( ff_req		),
		.send_busy		( w_busy		),
		.uart_tx		( uart_tx		)
	);
endmodule
