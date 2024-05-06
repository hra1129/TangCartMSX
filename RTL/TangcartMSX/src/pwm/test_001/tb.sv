// -----------------------------------------------------------------------------
//	Test of ip_pwm.v
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
	localparam		clk_base	= 1000000000/21477;
	//	cartridge slot signals
	reg				n_reset;
	reg				clk;
	reg				enable;
	reg		[15:0]	signal_level;
	wire			pwm_wave;
	reg		[2:0]	ff_enable;
	integer			i;

	// --------------------------------------------------------------------
	//	DUT
	// --------------------------------------------------------------------
	ip_pwm u_pwm (
		.n_reset			( n_reset			),
		.clk				( clk				),
		.enable				( enable			),
		.signal_level		( signal_level		),
		.pwm_wave			( pwm_wave			)
	);

	// --------------------------------------------------------------------
	//	clock
	// --------------------------------------------------------------------
	always #(clk_base/2) begin
		clk <= ~clk;
	end

	always @( negedge n_reset or posedge clk ) begin
		if( !n_reset ) begin
			ff_enable <= 0;
		end
		else begin
			ff_enable <= ff_enable + 3'd1;
		end
	end

	always @( negedge n_reset or posedge clk ) begin
		if( !n_reset ) begin
			enable <= 1'b0;
		end
		else if( ff_enable == 3'd0 ) begin
			enable <= 1'b1;
		end
		else begin
			enable <= 1'b0;
		end
	end

	// --------------------------------------------------------------------
	//	Test bench
	// --------------------------------------------------------------------
	initial begin
		n_reset			= 0;
		clk				= 0;
		signal_level	= 0;

		@( negedge clk );
		@( negedge clk );
		@( posedge clk );

		n_reset			= 1;
		repeat( 10 ) @( posedge clk );

		for( i = 0; i < 65536; i = i + 16 ) begin
			signal_level <= i;
			@( posedge enable );
		end

		for( i = 65535; i >= 0; i = i - 16 ) begin
			signal_level <= i;
			@( posedge enable );
		end

		signal_level <= 0;
		repeat( 10 ) @( posedge enable );

		$finish;
	end
endmodule
