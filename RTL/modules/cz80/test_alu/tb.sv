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

	int				i_arith16	;
	int				i_z16		;
	int				i_alu_cpi	;
	int				i_alu_op	;
	int				i_ir		;
	int				i_iset		;
	int				i_busa		;
	int				i_busb		;
	int				i_f_in		;

	reg				err;
	int				i;

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

		// --------------------------------------------------------------------
		//	random test
		// --------------------------------------------------------------------
		for( i_arith16	= 0; i_arith16	< 2;	i_arith16	= i_arith16	+1 ) begin
			for( i_z16		= 0; i_z16		< 2;	i_z16		= i_z16		+1 ) begin
				for( i_alu_cpi	= 0; i_alu_cpi	< 2;	i_alu_cpi	= i_alu_cpi	+1 ) begin
					for( i_alu_op	= 0; i_alu_op	< 16;	i_alu_op	= i_alu_op	+1 ) begin
						for( i_ir		= 0; i_ir		< 64;	i_ir		= i_ir		+1 ) begin
							for( i_iset		= 0; i_iset		< 4;	i_iset		= i_iset	+1 ) begin
								for( i_busa		= 0; i_busa		< 256;	i_busa		= i_busa	+1 ) begin
									for( i_busb		= 0; i_busb		< 256;	i_busb		= i_busb	+1 ) begin
										for( i_f_in		= 0; i_f_in		< 256;	i_f_in		= i_f_in	+1 ) begin
											arith16		= i_arith16		;
											z16			= i_z16			;
											alu_cpi		= i_alu_cpi		;
											alu_op		= i_alu_op		;
											ir			= i_ir			;
											iset		= i_iset		;
											busa		= i_busa		;
											busb		= i_busb		;
											f_in		= i_f_in		;
											@( posedge clk );

											assert( q_ref == q );
											assert( f_out_ref == f_out );
											err			= (q_ref != q) || (f_out_ref != f_out);
											@( posedge clk );
										end
									end
								end
							end
						end
					end
				end
			end
		end
		repeat( 100 ) @( posedge clk );

		$finish;
	end
endmodule
