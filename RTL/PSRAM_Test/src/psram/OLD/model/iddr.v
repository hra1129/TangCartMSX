// -----------------------------------------------------------------------------
//	iddr.v
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
//		IDDR model for TangNano9K
// -----------------------------------------------------------------------------

module IDDR (
	input			CLK,
	input			D,
	output			Q0,
	output			Q1
);
	reg			ff_q0_0;
	reg			ff_q1_0;
	reg			ff_q0_1;
	reg			ff_q1_1;

	always @( posedge CLK ) begin
		ff_q0_0 <= D;
		ff_q0_1 <= ff_q0_0;
		ff_q1_1 <= ff_q1_0;
	end

	always @( negedge CLK ) begin
		ff_q1_0 <= D;
	end

	assign Q0	= ff_q0_1;
	assign Q1	= ff_q1_1;
endmodule
