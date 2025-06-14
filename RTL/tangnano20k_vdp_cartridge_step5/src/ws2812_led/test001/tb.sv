// -----------------------------------------------------------------------------
//	Test of ip_ws2812_led
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
//		Pulse wave modulation
// -----------------------------------------------------------------------------

module tb ();
	localparam	clk_base	= 1_000_000_000/42_954_540;	//	ns
	int				test_no;

	reg				reset_n;
	reg				clk;
	reg				wr;
	wire			sending;
	reg		[7:0]	red;
	reg		[7:0]	green;
	reg		[7:0]	blue;
	wire			ws2812_led;

	// --------------------------------------------------------------------
	//	clock
	// --------------------------------------------------------------------
	always #(clk_base/2) begin
		clk <= ~clk;				//	14.31818MHz
	end

	// --------------------------------------------------------------------
	//	DUT
	// --------------------------------------------------------------------
	ip_ws2812_led u_dut (
		.reset_n		( reset_n		),
		.clk			( clk			),
		.wr				( wr			),
		.sending		( sending		),
		.red			( red			),
		.green			( green			),
		.blue			( blue			),
		.ws2812_led		( ws2812_led	)
	);

	// --------------------------------------------------------------------
	//	task
	// --------------------------------------------------------------------
	task set_color(
		input	[7:0]	r,
		input	[7:0]	g,
		input	[7:0]	b
	);
		while( sending ) begin
			@( posedge clk );
		end

		red		= r;
		green	= g;
		blue	= b;
		wr		= 1'b1;
		@( posedge clk );

		red		= 0;
		green	= 0;
		blue	= 0;
		wr		= 1'b0;
		repeat( 4 ) @( posedge clk );
	endtask: set_color

	// --------------------------------------------------------------------
	//	Test bench
	// --------------------------------------------------------------------
	initial begin
		reset_n = 0;
		clk = 0;
		wr = 0;
		red = 0;
		green = 0;
		blue = 0;

		@( negedge clk );
		@( negedge clk );
		reset_n = 1;

		clk				= 1;
		repeat( 50 ) @( posedge clk );

		set_color( 10, 20, 30 );
		repeat( 50 ) @( posedge clk );

		set_color( 20, 30, 40 );
		repeat( 50 ) @( posedge clk );

		set_color( 255, 255, 255 );
		repeat( 50 ) @( posedge clk );

		set_color( 0, 0, 0 );
		repeat( 50 ) @( posedge clk );

		while( sending ) begin
			@( posedge clk );
		end
		repeat( 50 ) @( posedge clk );

		$finish;
	end
endmodule
