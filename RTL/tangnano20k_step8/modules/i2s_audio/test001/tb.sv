// -----------------------------------------------------------------------------
//	Test of i2s_audio.v
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
	localparam	clk_base	= 1_000_000_000/42.95454;	//	ps
	int						test_no;
	int						i;
	reg						clk;				//	42.95454MHz
	reg						reset_n;
	reg		[15:0]			sound_in;
	wire					i2s_audio_en;
	wire					i2s_audio_din;
	wire					i2s_audio_lrclk;
	wire					i2s_audio_bclk;

	// --------------------------------------------------------------------
	//	DUT
	// --------------------------------------------------------------------
	i2s_audio u_i2s_audio (
	.clk				( clk				),
	.reset_n			( reset_n			),
	.sound_in			( sound_in			),
	.i2s_audio_en		( i2s_audio_en		),
	.i2s_audio_din		( i2s_audio_din		),
	.i2s_audio_lrclk	( i2s_audio_lrclk	),
	.i2s_audio_bclk		( i2s_audio_bclk	)
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
		test_no			= -1;
		reset_n			= 0;
		clk				= 1;
		sound_in		= 0;

		@( negedge clk );
		@( negedge clk );
		@( posedge clk );

		reset_n		= 1;
		@( posedge clk );

		sound_in	<= 16'b1000000000000000;
		repeat( 1000 ) @( posedge clk );

		sound_in	<= 16'b1111111100000000;
		repeat( 1000 ) @( posedge clk );

		sound_in	<= 16'b0101010101010101;
		repeat( 1000 ) @( posedge clk );

		sound_in	<= 16'b1110111011101110;
		repeat( 1000 ) @( posedge clk );

		sound_in	<= 16'b1100110000110011;
		repeat( 1000 ) @( posedge clk );

		repeat( 100000 ) @( posedge clk );
		$finish;
	end
endmodule
