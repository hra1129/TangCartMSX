// -----------------------------------------------------------------------------
//	Test of ip_lcd.v
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
	localparam		clk_base	= 1_000_000_000/87_750;	//	ps
	reg				n_reset;
	reg				clk;
	wire			lcd_clk;
	wire			lcd_de;
	wire			lcd_hsync;
	wire			lcd_vsync;
	wire	[4:0]	lcd_red;
	wire	[4:0]	lcd_green;
	wire	[4:0]	lcd_blue;

	// --------------------------------------------------------------------
	//	DUT
	// --------------------------------------------------------------------
	ip_lcd u_lcd (
		.n_reset		( n_reset		),
		.clk			( clk			),
		.lcd_clk		( lcd_clk		),
		.lcd_de			( lcd_de		),
		.lcd_hsync		( lcd_hsync		),
		.lcd_vsync		( lcd_vsync		),
		.lcd_red		( lcd_red		),
		.lcd_green		( lcd_green		),
		.lcd_blue		( lcd_blue		)
	);

	// --------------------------------------------------------------------
	//	clock
	// --------------------------------------------------------------------
	always #(clk_base/2) begin
		clk <= ~clk;
	end

	// --------------------------------------------------------------------
	//	Test bench
	// --------------------------------------------------------------------
	initial begin
		n_reset				= 0;
		clk					= 0;

		@( negedge clk );
		@( negedge clk );
		@( posedge clk );

		n_reset			= 1;
		repeat( 10 ) @( posedge clk );

		repeat( 2500000 ) @( posedge clk );

		$finish;
	end
endmodule
