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

module scc_channel_volume (
	input			clk,
	input	[7:0]	sram_q,					//	signed
	output	[7:0]	channel,				//	signed
	input	[3:0]	reg_volume
);
	wire	[12:0]	w_channel_mul;
	reg		[7:0]	ff_channel;				//	signed

	assign w_channel_mul	= $signed( sram_q ) * $signed( { 1'b0, reg_volume } );

	always @( posedge clk ) begin
		ff_channel		<= w_channel_mul[11:4];
	end

	assign channel			= ff_channel;
endmodule
