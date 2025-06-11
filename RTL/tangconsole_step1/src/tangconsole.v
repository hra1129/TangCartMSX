// -----------------------------------------------------------------------------
//	tangconsole_step1.v
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

module tangconsole_step1 (
	input			clk,			//	clk			V22 (50MHz)
	output	[1:0]	led				//	led[0]		G11 DONE
									//	led[1]		U12 READY
);
	localparam c_frequency = 25'd2_000_000;
	reg		[24:0]	ff_count = 25'd0;
	reg		[1:0]	ff_led = 2'b00;

	always @( posedge clk ) begin
		if( ff_count == c_frequency ) begin
			ff_count <= 25'd0;
		end
		else begin
			ff_count <= ff_count + 'd1;
		end
	end

	always @( posedge clk ) begin
		if( ff_count == c_frequency ) begin
			ff_led <= ff_led + 2'b01;
		end
	end

	assign led = ff_led;
endmodule
