// -----------------------------------------------------------------------------
//	Test of ip_uart.v
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
//		The role of protocol conversion by replacing the asynchronous MSXBUS 
//		signal with an internal clock.
// -----------------------------------------------------------------------------

module tb ();
	localparam		clk_base	= 1000000000/21477;
	reg				n_reset;
	reg				clk;
	reg		[7:0]	send_data;
	reg				send_req;
	wire			send_busy;
	wire			uart_tx;
	integer			test_no;

	// --------------------------------------------------------------------
	//	DUT
	// --------------------------------------------------------------------
	ip_uart u_uart (
		.n_reset		( n_reset		),
		.clk			( clk			),
		.send_data		( send_data		),
		.send_req		( send_req		),
		.send_busy		( send_busy		),
		.uart_tx		( uart_tx		)
	);

	// --------------------------------------------------------------------
	//	clock
	// --------------------------------------------------------------------
	always #(clk_base/2) begin
		clk <= ~clk;
	end

	// --------------------------------------------------------------------
	//	send one
	// --------------------------------------------------------------------
	task send_one(
		input	[7:0]	data
	);
		while( send_busy == 1'b1 ) begin
			@( posedge clk );
		end

		send_data <= data;
		send_req <= 1'b1;
		@( posedge clk );

		send_req <= 1'b0;
		@( posedge clk );
	endtask: send_one

	// --------------------------------------------------------------------
	//	Test bench
	// --------------------------------------------------------------------
	initial begin
		test_no			= 0;
		n_reset			= 0;
		clk				= 0;
		send_data		= 0;
		send_req		= 0;

		@( negedge clk );
		@( negedge clk );

		n_reset			= 1;
		repeat( 10 ) @( posedge clk );

		send_one( 'h12 );
		send_one( 'h34 );
		send_one( 'h56 );
		send_one( 'h78 );
		send_one( 'h9A );
		send_one( 'hBC );
		send_one( 'hDE );
		send_one( 'hF0 );

		repeat( 10 ) @( posedge clk );
		$finish;
	end
endmodule
