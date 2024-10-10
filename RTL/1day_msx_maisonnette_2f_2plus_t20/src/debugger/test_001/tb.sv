// -----------------------------------------------------------------------------
//	Test of debugger.v
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
//		Pulse wave modulation
// -----------------------------------------------------------------------------

module tb ();
	localparam		clk_base	= 1000000000/54000000;
	reg				n_reset;
	reg				clk;
	wire	[7:0]	send_data;
	wire			send_req;
	wire			send_busy;
	reg		[1:0]	keys;
	reg		[15:0]	address;

	// --------------------------------------------------------------------
	//	DUT
	// --------------------------------------------------------------------
	ip_debugger u_debuffer (
		.n_reset			( n_reset			),
		.clk				( clk				),
		.send_data			( send_data			),
		.send_req			( send_req			),
		.send_busy			( send_busy			),
		.keys				( keys				),
		.address			( address			)
	);

	// --------------------------------------------------------------------
	//	clock
	// --------------------------------------------------------------------
	always #(clk_base/2) begin
		clk <= ~clk;
	end

	reg		[15:0]	ff_count;

	always @( posedge clk ) begin
		if( ff_count == 16'd0 ) begin
			if( send_req ) begin
				ff_count <= 16'd70;
			end
		end
		else begin
			ff_count <= ff_count - 16'd1;
		end
	end

	assign send_busy = (ff_count == 16'd0) ? 1'b0 : 1'b1;

	// --------------------------------------------------------------------
	//	Test bench
	// --------------------------------------------------------------------
	initial begin
		ff_count = 0;
		n_reset = 0;
		clk = 0;
		address = 0;
		keys = 2'b00;

		@( negedge clk );
		@( negedge clk );
		@( posedge clk );

		n_reset			= 1;
		repeat( 10 ) @( posedge clk );

		keys = 2'b11;
		repeat( 1000 ) @( posedge clk );

		keys = 2'b00;
		repeat( 1000 ) @( posedge clk );

		keys = 2'b11;
		repeat( 2000 ) @( posedge clk );

		keys = 2'b00;
		repeat( 3000 ) @( posedge clk );

		keys = 2'b11;
		repeat( 4000 ) @( posedge clk );

		keys = 2'b00;
		repeat( 5000 ) @( posedge clk );

		keys = 2'b11;
		repeat( 6000 ) @( posedge clk );

		keys = 2'b00;
		repeat( 1000 ) @( posedge clk );

		keys = 2'b11;
		repeat( 2000 ) @( posedge clk );

		keys = 2'b00;
		repeat( 3000 ) @( posedge clk );

		keys = 2'b11;
		repeat( 4000 ) @( posedge clk );

		keys = 2'b00;
		repeat( 5000 ) @( posedge clk );

		keys = 2'b11;
		repeat( 6000 ) @( posedge clk );

		keys = 2'b00;
		repeat( 1000 ) @( posedge clk );

		keys = 2'b11;
		repeat( 1000 ) @( posedge clk );

		keys = 2'b00;
		repeat( 1000 ) @( posedge clk );

		keys = 2'b11;
		repeat( 1000 ) @( posedge clk );

		keys = 2'b00;
		repeat( 1000 ) @( posedge clk );

		keys = 2'b11;
		repeat( 1000 ) @( posedge clk );

		keys = 2'b00;
		repeat( 1000 ) @( posedge clk );

		$finish;
	end
endmodule
