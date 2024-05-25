// ------------------------------------------------------------------------------------------------
// Wave Table Sound
// Copyright 2021 t.hara
// 
//  Permission is hereby granted, free of charge, to any person obtaining a copy 
// of this software and associated documentation files (the "Software"), to deal 
// in the Software without restriction, including without limitation the rights 
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies 
// of the Software, and to permit persons to whom the Software is furnished to do
// so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all 
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A 
// PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT 
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION 
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH 
// THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
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
