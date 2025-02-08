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

module scc_selector #(
	parameter		bits = 12
) (
	input	[2:0]		active,
	output	[bits-1:0]	result,
	input	[bits-1:0]	reg_a,
	input	[bits-1:0]	reg_b,
	input	[bits-1:0]	reg_c,
	input	[bits-1:0]	reg_d,
	input	[bits-1:0]	reg_e,
	input	[bits-1:0]	reg_f
);
	function [bits-1:0] func_selector(
		input	[2:0]		active,
		input	[bits-1:0]	reg_a,
		input	[bits-1:0]	reg_b,
		input	[bits-1:0]	reg_c,
		input	[bits-1:0]	reg_d,
		input	[bits-1:0]	reg_e,
		input	[bits-1:0]	reg_f
	);
		case( active )
		3'd0:		func_selector = reg_a;
		3'd1:		func_selector = reg_b;
		3'd2:		func_selector = reg_c;
		3'd3:		func_selector = reg_d;
		3'd4:		func_selector = reg_e;
		3'd5:		func_selector = reg_f;
		default:	func_selector = 'd0;
		endcase
	endfunction

	assign result = func_selector( active, reg_a, reg_b, reg_c, reg_d, reg_e, reg_f );
endmodule
