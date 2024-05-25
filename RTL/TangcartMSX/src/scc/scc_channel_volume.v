// ------------------------------------------------------------------------------------------------
// Wave Table Sound
// Copyright 2021 t.hara
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
// ------------------------------------------------------------------------------------------------

module scc_channel_volume (
	input			clk,
	input			enable,
	input	[7:0]	sram_q,					//	signed
	output	[7:0]	channel,				//	signed
	input	[3:0]	reg_volume
);
	wire	[12:0]	w_channel_mul;
	reg		[7:0]	ff_channel;				//	signed

	assign w_channel_mul	= $signed( sram_q ) * $signed( { 1'b0, reg_volume } );

	always @( posedge clk ) begin
		if( enable ) begin
			ff_channel		<= w_channel_mul[11:4];
		end
	end

	assign channel			= ff_channel;
endmodule
