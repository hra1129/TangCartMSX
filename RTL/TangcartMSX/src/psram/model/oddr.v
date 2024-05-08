// -----------------------------------------------------------------------------
//	oddr.v
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
//		ODDR model for TangNano9K
// -----------------------------------------------------------------------------

module ODDR #(
	parameter		TX_POL = 1
) (
	input			CLK,
	input			D0,
	input			D1,
	input			TX,
	output			Q0,
	output			Q1
);
	reg			ff_q0_0;
	reg			ff_q1_0;
	reg			ff_q0_1;
	reg			ff_q1_1;
	reg			ff_q0_2;
	reg			ff_q1_2;
	reg			ff_tx_0;
	reg			ff_tx_1;
	reg			ff_tx_2;
	reg			ff_tx_3;

	always @( posedge CLK ) begin
		ff_q0_0 <= D0;
		ff_q1_0 <= D1;
		ff_q0_1 <= ff_q0_0;
		ff_q1_1 <= ff_q1_0;
		ff_q1_2 <= ff_q1_1;
		ff_tx_0 <= TX;
		ff_tx_1 <= ff_tx_0;
		ff_tx_3 <= ff_tx_2;
	end

	always @( negedge CLK ) begin
		ff_q0_2 <= ff_q0_1;
		ff_tx_2 <= ff_tx_1;
	end

	assign Q0	= CLK    ? ff_q0_2 : ff_q1_2;
	assign Q1	= TX_POL ? ff_tx_3 : ff_tx_2;
endmodule
