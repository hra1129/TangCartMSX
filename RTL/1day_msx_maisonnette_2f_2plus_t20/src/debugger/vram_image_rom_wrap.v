// -----------------------------------------------------------------------------
//	vram_image_rom_wrap.v
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
//		Debugger
// -----------------------------------------------------------------------------

module vram_image_rom (
	input			clk,
	input	[13:0]	adr,
	output	[ 7:0]	dbi
);
	reg		[ 7:0]	ff_dbi;

	always @( posedge clk ) begin
		case( adr[13:0] )
`include "vram_image_rom.v"
		default:	ff_dbi <= 8'hxx;
		endcase
	end

	assign dbi = ff_dbi;
endmodule
