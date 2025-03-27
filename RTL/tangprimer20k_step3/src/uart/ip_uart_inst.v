// -----------------------------------------------------------------------------
//	ip_uart_inst.v
//	Copyright (C)2025 Takayuki Hara (HRA!)
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
	input	[7:0]	bus_address,
	input			bus_ioreq,
	input			bus_write,			//	Direction 0: Read, 1: Write
	input			bus_valid,			//	Valid     0: Idle, 1: Accecss
	output			bus_ready,			//	Ready     0: Busy, 1: Ready
	input	[7:0]	bus_wdata,
	output	[7:0]	bus_rdata,
	output			bus_rdata_en,
	input	[4:0]	button,
	output			uart_tx
);
	localparam		c_io_port = 8'h10;
	reg		[7:0]	ff_d;
	reg		[7:0]	ff_q;
	reg				ff_q_en;
	reg				ff_wr_n;
	reg				ff_req;
	wire			w_busy;
	wire			w_dec;

	assign w_dec		= ( bus_address == c_io_port && bus_ioreq );
	assign bus_ready	= ~(w_busy | ff_req) & w_dec;
	assign bus_rdata	= ff_q_en ? ff_rdata : 8'd0;
	assign bus_rdata_en	= ff_q_en;

	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_d	<= 8'd0;
			ff_q	<= 8'd0;
			ff_q_en	<= 1'b0;
			ff_req	<= 1'b0;
		end
		else begin
			if( ff_req ) begin
				if( !w_busy ) begin
					ff_req	<= 1'b0;
					ff_q_en	<= 1'b1;
				end
				else begin
					ff_q_en	<= 1'b0;
				end
			end
			else if( w_dec && bus_write && bus_valid && !w_busy ) begin
				ff_d	<= bus_wdata;
				ff_req	<= 1'b1;
				ff_q_en	<= 1'b0;
			end
			else if( w_dec && bus_read && bus_valid && !w_busy ) begin
				ff_q	<= bus_wdata;
				ff_req	<= 1'b1;
				ff_q_en	<= 1'b0;
			end
			else begin
				ff_q_en	<= 1'b0;
			end
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
