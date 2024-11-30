// -----------------------------------------------------------------------------
//	Test of MCODE
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

	reg		[7:0]		ir;
	reg		[1:0]		iset;
	reg		[2:0]		mcycle;
	reg		[7:0]		f;
	reg					nmicycle;
	reg					intcycle;
	reg		[1:0]		xy_state;
	wire	[2:0]		mcycles;
	wire	[2:0]		tstates;
	wire	[1:0]		prefix;
	wire				inc_pc;
	wire				inc_wz;
	wire	[3:0]		incdec_16;
	wire				read_to_reg ;
	wire				read_to_acc ;
	wire	[3:0]		set_busa_to ;
	wire	[3:0]		set_busb_to ;
	wire	[3:0]		alu_op;
	wire				alu_cpi;
	wire				save_alu;
	wire				preservec;
	wire				arith16;
	wire	[2:0]		set_addr_to ;
	wire				iorq;
	wire				jump;
	wire				jumpe;
	wire				jumpxy;
	wire				call;
	wire				rstp;
	wire				ldz;
	wire				ldw;
	wire				ldsphl;
	wire	[2:0]		special_ld;
	wire				exchangedh;
	wire				exchangerp;
	wire				exchangeaf;
	wire				exchangers;
	wire				i_djnz;
	wire				i_cpl;
	wire				i_ccf;
	wire				i_scf;
	wire				i_retn;
	wire				i_bt;
	wire				i_bc;
	wire				i_btr;
	wire				i_rld;
	wire				i_rrd;
	wire				i_inrc;
	wire				setdi;
	wire				setei;
	wire	[1:0]		imode;
	wire				halt;
	wire				noread;
	wire				write;
	wire				xybit_undoc;

	wire	[2:0]		cz_mcycles;
	wire	[2:0]		cz_tstates;
	wire	[1:0]		cz_prefix;
	wire				cz_inc_pc;
	wire				cz_inc_wz;
	wire	[3:0]		cz_incdec_16;
	wire				cz_read_to_reg ;
	wire				cz_read_to_acc ;
	wire	[3:0]		cz_set_busa_to ;
	wire	[3:0]		cz_set_busb_to ;
	wire	[3:0]		cz_alu_op;
	wire				cz_alu_cpi;
	wire				cz_save_alu;
	wire				cz_preservec;
	wire				cz_arith16;
	wire	[2:0]		cz_set_addr_to ;
	wire				cz_iorq;
	wire				cz_jump;
	wire				cz_jumpe;
	wire				cz_jumpxy;
	wire				cz_call;
	wire				cz_rstp;
	wire				cz_ldz;
	wire				cz_ldw;
	wire				cz_ldsphl;
	wire	[2:0]		cz_special_ld;
	wire				cz_exchangedh;
	wire				cz_exchangerp;
	wire				cz_exchangeaf;
	wire				cz_exchangers;
	wire				cz_i_djnz;
	wire				cz_i_cpl;
	wire				cz_i_ccf;
	wire				cz_i_scf;
	wire				cz_i_retn;
	wire				cz_i_bt;
	wire				cz_i_bc;
	wire				cz_i_btr;
	wire				cz_i_rld;
	wire				cz_i_rrd;
	wire				cz_i_inrc;
	wire				cz_setdi;
	wire				cz_setei;
	wire	[1:0]		cz_imode;
	wire				cz_halt;
	wire				cz_noread;
	wire				cz_write;
	wire				cz_xybit_undoc;

	reg				err;
	int				i;

	// --------------------------------------------------------------------
	//	DUT
	// --------------------------------------------------------------------
	t80_mcode t80_mcode (
		.ir					( ir					),
		.iset				( iset					),
		.mcycle				( mcycle				),
		.f					( f						),
		.nmicycle			( nmicycle				),
		.intcycle			( intcycle				),
		.xy_state			( xy_state				),
		.mcycles			( mcycles				),
		.tstates			( tstates				),
		.prefix				( prefix				),
		.inc_pc				( inc_pc				),
		.inc_wz				( inc_wz				),
		.incdec_16			( incdec_16				),
		.read_to_reg		( read_to_reg			),
		.read_to_acc		( read_to_acc			),
		.set_busa_to		( set_busa_to			),
		.set_busb_to		( set_busb_to			),
		.alu_op				( alu_op				),
		.alu_cpi			( alu_cpi				),
		.save_alu			( save_alu				),
		.preservec			( preservec				),
		.arith16			( arith16				),
		.set_addr_to		( set_addr_to			),
		.iorq				( iorq					),
		.jump				( jump					),
		.jumpe				( jumpe					),
		.jumpxy				( jumpxy				),
		.call				( call					),
		.rstp				( rstp					),
		.ldz				( ldz					),
		.ldw				( ldw					),
		.ldsphl				( ldsphl				),
		.special_ld			( special_ld			),
		.exchangedh			( exchangedh			),
		.exchangerp			( exchangerp			),
		.exchangeaf			( exchangeaf			),
		.exchangers			( exchangers			),
		.i_djnz				( i_djnz				),
		.i_cpl				( i_cpl					),
		.i_ccf				( i_ccf					),
		.i_scf				( i_scf					),
		.i_retn				( i_retn				),
		.i_bt				( i_bt					),
		.i_bc				( i_bc					),
		.i_btr				( i_btr					),
		.i_rld				( i_rld					),
		.i_rrd				( i_rrd					),
		.i_inrc				( i_inrc				),
		.setdi				( setdi					),
		.setei				( setei					),
		.imode				( imode					),
		.halt				( halt					),
		.noread				( noread				),
		.write				( write					),
		.xybit_undoc		( xybit_undoc			)
	);

	cz80_mcode u_cz80_mcode (
		.ir					( ir					),
		.iset				( iset					),
		.mcycle				( mcycle				),
		.f					( f						),
		.nmicycle			( nmicycle				),
		.intcycle			( intcycle				),
		.xy_state			( xy_state				),
		.mcycles			( cz_mcycles			),
		.tstates			( cz_tstates			),
		.prefix				( cz_prefix				),
		.inc_pc				( cz_inc_pc				),
		.inc_wz				( cz_inc_wz				),
		.incdec_16			( cz_incdec_16			),
		.read_to_reg		( cz_read_to_reg		),
		.read_to_acc		( cz_read_to_acc		),
		.set_busa_to		( cz_set_busa_to		),
		.set_busb_to		( cz_set_busb_to		),
		.alu_op				( cz_alu_op				),
		.alu_cpi			( cz_alu_cpi			),
		.save_alu			( cz_save_alu			),
		.preservec			( cz_preservec			),
		.arith16			( cz_arith16			),
		.set_addr_to		( cz_set_addr_to		),
		.iorq				( cz_iorq				),
		.jump				( cz_jump				),
		.jumpe				( cz_jumpe				),
		.jumpxy				( cz_jumpxy				),
		.call				( cz_call				),
		.rstp				( cz_rstp				),
		.ldz				( cz_ldz				),
		.ldw				( cz_ldw				),
		.ldsphl				( cz_ldsphl				),
		.special_ld			( cz_special_ld			),
		.exchangedh			( cz_exchangedh			),
		.exchangerp			( cz_exchangerp			),
		.exchangeaf			( cz_exchangeaf			),
		.exchangers			( cz_exchangers			),
		.i_djnz				( cz_i_djnz				),
		.i_cpl				( cz_i_cpl				),
		.i_ccf				( cz_i_ccf				),
		.i_scf				( cz_i_scf				),
		.i_retn				( cz_i_retn				),
		.i_bt				( cz_i_bt				),
		.i_bc				( cz_i_bc				),
		.i_btr				( cz_i_btr				),
		.i_rld				( cz_i_rld				),
		.i_rrd				( cz_i_rrd				),
		.i_inrc				( cz_i_inrc				),
		.setdi				( cz_setdi				),
		.setei				( cz_setei				),
		.imode				( cz_imode				),
		.halt				( cz_halt				),
		.noread				( cz_noread				),
		.write				( cz_write				),
		.xybit_undoc		( cz_xybit_undoc		)
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
		for( i = 0; i < 10000; i = i + 1 ) begin
			@( posedge clk );
		end

		repeat( 100 ) @( posedge clk );

		$finish;
	end
endmodule
