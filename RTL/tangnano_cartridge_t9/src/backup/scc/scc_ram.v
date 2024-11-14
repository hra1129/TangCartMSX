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

module scc_ram (
	input			clk,
	input			sram_we,
	input	[7:0]	sram_a,
	input	[7:0]	sram_d,
	output	[7:0]	sram_q
);
	reg		[7:0]	ff_sram_q;
	reg		[7:0]	ram_array [159:0];		//	8bit 160word ( 32word * 5ch )

	always @( posedge clk ) begin
		if( sram_we ) begin
			ram_array[ sram_a ] <= sram_d;
		end
		else begin
			ff_sram_q	<= ram_array[ sram_a ];
		end
	end

	assign sram_q	= ff_sram_q;
endmodule
