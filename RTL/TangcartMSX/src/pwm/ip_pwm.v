// -----------------------------------------------------------------------------
//	ip_pwm.v
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

module ip_pwm (
	input			n_reset,
	input			clk,
	input			enable,
	input	[15:0]	signal_level,
	output			pwm_wave
);
	reg		[16:0]	ff_integ;
	wire	[16:0]	w_integ;

	// --------------------------------------------------------------------
	//	Integral unit
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_integ <= 17'd0;
		end
		else if( enable ) begin
			ff_integ <= w_integ[16:0];
		end
		else begin
			//	hold
		end
	end
	assign w_integ	= { 1'b0, ff_integ[15:0] } + { 1'b0, signal_level };

	// --------------------------------------------------------------------
	//	Output assignment
	// --------------------------------------------------------------------
	assign pwm_wave	= ff_integ[16];
endmodule
