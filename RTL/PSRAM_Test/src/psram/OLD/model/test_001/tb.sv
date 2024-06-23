// -----------------------------------------------------------------------------
//	Test of iddr.v
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
//		IDDR
// -----------------------------------------------------------------------------

module tb ();
	localparam		clk_base	= 1000000000/21477;
	//	cartridge slot signals
	reg				clk_q;
	reg				clk_h;
	reg				clk;
	reg				d;
	wire			q0;
	wire			q1;

	// --------------------------------------------------------------------
	//	DUT
	// --------------------------------------------------------------------
	IDDR iddr (
		.CLK		( clk		),
		.D			( d			),
		.Q0			( q0		),
		.Q1			( q1		)
	);

	// --------------------------------------------------------------------
	//	clock
	// --------------------------------------------------------------------
	always #(clk_base/2) begin
		clk_q <= ~clk_q;
	end

	always @( posedge clk_q ) begin
		clk_h <= ~clk_h;
	end

	always @( posedge clk_h ) begin
		clk <= ~clk;
	end

	// --------------------------------------------------------------------
	//	Test bench
	// --------------------------------------------------------------------
	initial begin
		clk_q			= 0;
		clk_h			= 0;
		clk				= 0;

		@( posedge clk );
		@( posedge clk );

		@( posedge clk_h );
		@( posedge clk_q );
		d <= 0;
		@( posedge clk_h );
		@( posedge clk_q );
		d <= 1;
		@( posedge clk_h );
		@( posedge clk_q );
		d <= 1;
		@( posedge clk_h );
		@( posedge clk_q );
		d <= 0;
		@( posedge clk_h );
		@( posedge clk_q );
		d <= 1;
		@( posedge clk_h );
		@( posedge clk_q );
		d <= 1;
		@( posedge clk_h );
		@( posedge clk_q );
		d <= 0;
		@( posedge clk_h );
		@( posedge clk_q );
		d <= 0;
		@( posedge clk_h );
		@( posedge clk_q );
		d <= 0;
		@( posedge clk_h );
		@( posedge clk_q );
		d <= 1;
		@( posedge clk_h );
		@( posedge clk_q );
		d <= 1;
		@( posedge clk_h );
		@( posedge clk_q );
		d <= 0;
		@( posedge clk_h );
		@( posedge clk_q );
		d <= 1;
		@( posedge clk_h );
		@( posedge clk_q );
		d <= 1;
		@( posedge clk_h );
		@( posedge clk_q );
		d <= 0;
		@( posedge clk_h );
		@( posedge clk_q );
		d <= 0;
		@( posedge clk_h );
		@( posedge clk_q );
		d <= 1'bX;
		@( posedge clk_h );
		repeat( 10 ) @( posedge clk_q );

		$finish;
	end
endmodule
