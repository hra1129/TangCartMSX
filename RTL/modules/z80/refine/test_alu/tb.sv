// -----------------------------------------------------------------------------
//	Test of ALU
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

module tb ();
	localparam		clk_base	= 1_000_000_000/85_909;	//	ps
	reg				clk;

	reg				arith16		;
	reg				z16			;
	reg				alu_cpi		;
	reg		[3:0]	alu_op		;
	reg		[5:0]	ir			;
	reg		[1:0]	iset		;
	reg		[7:0]	busa		;
	reg		[7:0]	busb		;
	reg		[7:0]	f_in		;
	wire	[7:0]	q_ref		;
	wire	[7:0]	f_out_ref	;
	wire	[7:0]	q			;
	wire	[7:0]	f_out		;

	// --------------------------------------------------------------------
	//	DUT
	// --------------------------------------------------------------------
	T80_ALU u_t80_alu (
		.Arith16		( arith16		),
		.Z16			( z16			),
		.ALU_cpi		( alu_cpi		),
		.ALU_Op			( alu_op		),
		.IR				( ir			),
		.ISet			( iset			),
		.BusA			( busa			),
		.BusB			( busb			),
		.F_In			( f_in			),
		.Q				( q_ref			),
		.F_Out			( f_out_ref		)
	);

	cz80_alu u_cz80_alu (
		.arith16		( arith16		),
		.z16			( z16			),
		.alu_cpi		( alu_cpi		),
		.alu_op			( alu_op		),
		.ir				( ir			),
		.iset			( iset			),
		.busa			( busa			),
		.busb			( busb			),
		.f_in			( f_in			),
		.q				( q				),
		.f_out			( f_out			)
	);

	// --------------------------------------------------------------------
	//	clock
	// --------------------------------------------------------------------
	always #(clk_base/2) begin
		clk <= ~clk;
	end

	// --------------------------------------------------------------------
	//	Test bench
	// --------------------------------------------------------------------
	initial begin
		clk			= 0;
		@( posedge clk );


		$finish;
	end
endmodule
