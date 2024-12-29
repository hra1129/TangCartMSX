// -----------------------------------------------------------------------------
//	Test of cz80.v
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
	reg				reset_n		;
	reg				clk_n		;
	reg				enable		;
	reg				wait_n		;
	reg				int_n		;
	reg				nmi_n		;
	reg				busrq_n		;
	wire			m1_n		;
	wire			mreq_n		;
	wire			iorq_n		;
	wire			rd_n		;
	wire			wr_n		;
	wire			rfsh_n		;
	wire			halt_n		;
	wire			busak_n		;
	wire	[15:0]	a			;
	wire	[7:0]	d			;
	reg		[7:0]	ff_d		;
	reg		[7:0]	ff_ram [0:15];

	reg		[4:0]	ff_clock;
	reg		[4:0]	ff_clock_speed;

	// --------------------------------------------------------------------
	//	dut
	// --------------------------------------------------------------------
	cz80_inst u_z80 (
		.reset_n	( reset_n		),
		.clk_n		( clk_n			),
		.enable		( enable		),
		.wait_n		( wait_n		),
		.int_n		( int_n			),
		.nmi_n		( nmi_n			),
		.busrq_n	( busrq_n		),
		.m1_n		( m1_n			),
		.mreq_n		( mreq_n		),
		.iorq_n		( iorq_n		),
		.rd_n		( rd_n			),
		.wr_n		( wr_n			),
		.rfsh_n		( rfsh_n		),
		.halt_n		( halt_n		),
		.busak_n	( busak_n		),
		.a			( a				),
		.d			( d				)
	);

	//				         write  read
	assign d		= rd_n ? 8'dz : ff_d;

	// --------------------------------------------------------------------
	//	clock
	// --------------------------------------------------------------------
	always #(clk_base/2) begin
		clk_n <= ~clk_n;
	end

	// --------------------------------------------------------------------
	//	clock divider
	// --------------------------------------------------------------------
	always @( posedge clk_n ) begin
		if( !reset_n ) begin
			ff_clock <= 5'd1;
		end
		else if( ff_clock == 5'd0 ) begin
			ff_clock <= ff_clock_speed;
		end
		else begin
			ff_clock <= ff_clock - 5'd1;
		end
	end

	assign enable = (ff_clock == 5'd0 );

	// --------------------------------------------------------------------
	//	functions
	// --------------------------------------------------------------------
	function string reg8_sel(
		input	[2:0]	sel
	);
		case( sel )
		3'd0:		reg8_sel = "B";
		3'd1:		reg8_sel = "C";
		3'd2:		reg8_sel = "D";
		3'd3:		reg8_sel = "E";
		3'd4:		reg8_sel = "H";
		3'd5:		reg8_sel = "L";
		3'd6:		reg8_sel = "(HL)";
		3'd7:		reg8_sel = "A";
		default:	reg8_sel = "*";
		endcase
	endfunction

	// --------------------------------------------------------------------
	function string reg16_sel(
		input	[1:0]	sel
	);
		case( sel )
		2'd0:		reg16_sel = "BC";
		2'd1:		reg16_sel = "DE";
		2'd2:		reg16_sel = "HL";
		2'd3:		reg16_sel = "SP";
		default:	reg16_sel = "*";
		endcase
	endfunction

	// --------------------------------------------------------------------
	function string reg16_sel2(
		input	[1:0]	sel
	);
		case( sel )
		2'd0:		reg16_sel2 = "BC";
		2'd1:		reg16_sel2 = "DE";
		2'd2:		reg16_sel2 = "HL";
		2'd3:		reg16_sel2 = "AF";
		default:	reg16_sel2 = "*";
		endcase
	endfunction

	// --------------------------------------------------------------------
	function string regxy_sel(
		input			sel
	);
		case( sel )
		1'd0:		regxy_sel = "IX";
		1'd1:		regxy_sel = "IY";
		default:	regxy_sel = "*";
		endcase
	endfunction

	// --------------------------------------------------------------------
	//	tasks
	// --------------------------------------------------------------------
	task send_byte(
		input	[7:0]	data
	);
		ff_d <= data;
		@( negedge rd_n );
		@( posedge rd_n );
		if( m1_n == 1'b0 ) begin
			@( posedge m1_n );
		end
	endtask: send_byte

	// --------------------------------------------------------------------
	task receive_byte(
		output	[7:0]	data
	);
		@( negedge wr_n );
		data	<= d;
		@( posedge wr_n );
	endtask: receive_byte

	// --------------------------------------------------------------------
	task receive_byte_a(
		output	[7:0]	data,
		output	[15:0]	address
	);
		@( negedge wr_n );
		data	<= d;
		address	<= a;
		@( posedge wr_n );
	endtask: receive_byte_a

	// --------------------------------------------------------------------
	task run_ld_r_n(
		input	[7:0]	opecode,
		input	[7:0]	data
	);
		$display( "CODE %02X, %02X    : LD  %s, %02Xh", opecode, data, reg8_sel( opecode[5:3] ), data );

		//	2bytes の命令コードを送る 
		send_byte( opecode );
		send_byte( data );
	endtask: run_ld_r_n

	// --------------------------------------------------------------------
	task run_ld_rr_nn(
		input	[7:0]	opecode,
		input	[15:0]	data
	);
		$display( "CODE %02X, %04X  : LD  %s, %02Xh", opecode, data, reg16_sel( opecode[5:4] ), data );

		//	2bytes の命令コードを送る 
		send_byte( opecode );
		send_byte( data[7:0] );
		send_byte( data[15:8] );
	endtask: run_ld_rr_nn

	// --------------------------------------------------------------------
	task run_pop(
		input	[7:0]	opecode,
		input	[15:0]	data
	);
		$display( "CODE %02X        : POP %s <== %04X", opecode, reg16_sel2( opecode[5:4] ), data );

		//	2bytes の命令コードを送る 
		send_byte( opecode );
		send_byte( data[7:0] );
		send_byte( data[15:8] );
	endtask: run_pop

	// --------------------------------------------------------------------
	task test_bit_b_r(
		input	[7:0]	opecode,
		input	[2:0]	bit_no,
		input	[7:0]	ref_b,
		input	[7:0]	ref_c,
		input	[7:0]	ref_d,
		input	[7:0]	ref_e,
		input	[7:0]	ref_h,
		input	[7:0]	ref_l,
		input	[7:0]	ref_a,
		input	[7:0]	ref_f,
		input	[7:0]	ref_ixh,
		input	[7:0]	ref_ixl,
		input	[7:0]	ref_iyh,
		input	[7:0]	ref_iyl
	);
		logic	[7:0]	sopecode;
		logic	[7:0]	rdata;

		sopecode	= { opecode[7:6], bit_no, opecode[2:0] };
		$display( "CODE CB, %02X    : BIT %1d, %s", sopecode, bit_no, reg8_sel( opecode[2:0] ) );
		send_byte( 8'hCB );
		send_byte( sopecode );

		//	確認用に全レジスタを push してレジスタ値を出力させる 
		send_byte( 8'hC5 );
		receive_byte( rdata );
		assert( rdata === ref_b );
		receive_byte( rdata );
		assert( rdata === ref_c );

		send_byte( 8'hD5 );
		receive_byte( rdata );
		assert( rdata === ref_d );
		receive_byte( rdata );
		assert( rdata === ref_e );

		send_byte( 8'hE5 );
		receive_byte( rdata );
		assert( rdata === ref_h );
		receive_byte( rdata );
		assert( rdata === ref_l );

		send_byte( 8'hF5 );
		receive_byte( rdata );
		assert( rdata === ref_a );
		receive_byte( rdata );
		assert( rdata === ref_f );
		if( rdata !== ref_f ) begin
			$display( "  FLAG is 0x%02X", rdata );
		end

		send_byte( 8'hDD );
		send_byte( 8'hE5 );
		receive_byte( rdata );
		assert( rdata === ref_ixh );
		receive_byte( rdata );
		assert( rdata === ref_ixl );

		send_byte( 8'hFD );
		send_byte( 8'hE5 );
		receive_byte( rdata );
		assert( rdata === ref_iyh );
		receive_byte( rdata );
		assert( rdata === ref_iyl );
	endtask: test_bit_b_r

	// --------------------------------------------------------------------
	//	test bench
	// --------------------------------------------------------------------
	initial begin
		reset_n			= 0;
		clk_n			= 1;
		wait_n			= 1;
		int_n			= 1;
		nmi_n			= 1;
		busrq_n			= 1;
		ff_d			= 8'h00;
		ff_clock_speed	= 5'd3;

		@( negedge clk_n );
		@( negedge clk_n );
		@( posedge clk_n );

		reset_n			= 1;
		@( posedge clk_n );

		// --------------------------------------------------------------------
		//	Fレジスタ 
		//	[Sf][Zf][Yf][Hf][Xf][Pf][Nf][Cf]
		// --------------------------------------------------------------------

		// --------------------------------------------------------------------
		//	レジスタを初期化する 
		// --------------------------------------------------------------------
		//             code  data
		run_ld_rr_nn( 8'h01, 16'hA5C3 );		//	LD BC, A5C3h
		run_ld_rr_nn( 8'h11, 16'h5A3C );		//	LD DE, 5A3Ch
		run_ld_rr_nn( 8'h21, 16'h6924 );		//	LD HL, 6924h
		run_pop(      8'hF1, 16'h9600 );		//	POP AF ← 9600h

		// --------------------------------------------------------------------
		//	bit n, r
		//	R = r & (1 << n) の R は捨てられ、F にのみ結果が反映される
		//
		//	Fレジスタ 
		//	[Sf][Zf][Yf][Hf][Xf][Pf][Nf][Cf]
		//		Sf: Set if n = 7 and tested bit is set.
		//		Zf: Set if the tested bit is reset.
		//		Yf: Set if n = 5 and tested bit is set.
		//		Hf: Always set.
		//		Xf: Set if n = 3 and tested bit is set.
		//		Pf: Set just like Zf.
		//		Nf: Always reset.
		//		Cf: Unchanged.
		// --------------------------------------------------------------------
		//            code   n     ref B  ref C  ref D  ref E  ref H  ref L  ref A  ref F  rf ixh rf ixl rf iyh rf iyl
		test_bit_b_r( 8'h40, 3'd0, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h30, 8'h00, 8'h00, 8'h00, 8'h00 );	//	set 0, b
		test_bit_b_r( 8'h40, 3'd1, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h74, 8'h00, 8'h00, 8'h00, 8'h00 );	//	set 1, b
		test_bit_b_r( 8'h40, 3'd2, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h30, 8'h00, 8'h00, 8'h00, 8'h00 );	//	set 2, b
		test_bit_b_r( 8'h40, 3'd3, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h74, 8'h00, 8'h00, 8'h00, 8'h00 );	//	set 3, b
		test_bit_b_r( 8'h40, 3'd4, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h74, 8'h00, 8'h00, 8'h00, 8'h00 );	//	set 4, b
		test_bit_b_r( 8'h40, 3'd5, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h30, 8'h00, 8'h00, 8'h00, 8'h00 );	//	set 5, b
		test_bit_b_r( 8'h40, 3'd6, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h74, 8'h00, 8'h00, 8'h00, 8'h00 );	//	set 6, b
		test_bit_b_r( 8'h40, 3'd7, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'hB0, 8'h00, 8'h00, 8'h00, 8'h00 );	//	set 7, b
		//            code   n     ref B  ref C  ref D  ref E  ref H  ref L  ref A  ref F  rf ixh rf ixl rf iyh rf iyl
		test_bit_b_r( 8'h41, 3'd0, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h10, 8'h00, 8'h00, 8'h00, 8'h00 );	//	set 0, c
		test_bit_b_r( 8'h41, 3'd1, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h10, 8'h00, 8'h00, 8'h00, 8'h00 );	//	set 1, c
		test_bit_b_r( 8'h41, 3'd2, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h54, 8'h00, 8'h00, 8'h00, 8'h00 );	//	set 2, c
		test_bit_b_r( 8'h41, 3'd3, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h54, 8'h00, 8'h00, 8'h00, 8'h00 );	//	set 3, c
		test_bit_b_r( 8'h41, 3'd4, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h54, 8'h00, 8'h00, 8'h00, 8'h00 );	//	set 4, c
		test_bit_b_r( 8'h41, 3'd5, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h54, 8'h00, 8'h00, 8'h00, 8'h00 );	//	set 5, c
		test_bit_b_r( 8'h41, 3'd6, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h10, 8'h00, 8'h00, 8'h00, 8'h00 );	//	set 6, c
		test_bit_b_r( 8'h41, 3'd7, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h00, 8'h00, 8'h00, 8'h00 );	//	set 7, c
		//            code   n     ref B  ref C  ref D  ref E  ref H  ref L  ref A  ref F  rf ixh rf ixl rf iyh rf iyl
		test_bit_b_r( 8'h42, 3'd0, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h5C, 8'h00, 8'h00, 8'h00, 8'h00 );	//	set 0, d
		test_bit_b_r( 8'h42, 3'd1, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h18, 8'h00, 8'h00, 8'h00, 8'h00 );	//	set 1, d
		test_bit_b_r( 8'h42, 3'd2, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h5C, 8'h00, 8'h00, 8'h00, 8'h00 );	//	set 2, d
		test_bit_b_r( 8'h42, 3'd3, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h18, 8'h00, 8'h00, 8'h00, 8'h00 );	//	set 3, d
		test_bit_b_r( 8'h42, 3'd4, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h18, 8'h00, 8'h00, 8'h00, 8'h00 );	//	set 4, d
		test_bit_b_r( 8'h42, 3'd5, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h5C, 8'h00, 8'h00, 8'h00, 8'h00 );	//	set 5, d
		test_bit_b_r( 8'h42, 3'd6, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h18, 8'h00, 8'h00, 8'h00, 8'h00 );	//	set 6, d
		test_bit_b_r( 8'h42, 3'd7, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h5C, 8'h00, 8'h00, 8'h00, 8'h00 );	//	set 7, d
		//            code   n     ref B  ref C  ref D  ref E  ref H  ref L  ref A  ref F  rf ixh rf ixl rf iyh rf iyl
		test_bit_b_r( 8'h43, 3'd0, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h7C, 8'h00, 8'h00, 8'h00, 8'h00 );	//	set 0, e
		test_bit_b_r( 8'h43, 3'd1, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h7C, 8'h00, 8'h00, 8'h00, 8'h00 );	//	set 1, e
		test_bit_b_r( 8'h43, 3'd2, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h38, 8'h00, 8'h00, 8'h00, 8'h00 );	//	set 2, e
		test_bit_b_r( 8'h43, 3'd3, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h38, 8'h00, 8'h00, 8'h00, 8'h00 );	//	set 3, e
		test_bit_b_r( 8'h43, 3'd4, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h38, 8'h00, 8'h00, 8'h00, 8'h00 );	//	set 4, e
		test_bit_b_r( 8'h43, 3'd5, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h38, 8'h00, 8'h00, 8'h00, 8'h00 );	//	set 5, e
		test_bit_b_r( 8'h43, 3'd6, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h7C, 8'h00, 8'h00, 8'h00, 8'h00 );	//	set 6, e
		test_bit_b_r( 8'h43, 3'd7, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h7C, 8'h00, 8'h00, 8'h00, 8'h00 );	//	set 7, e
		//            code   n     ref B  ref C  ref D  ref E  ref H  ref L  ref A  ref F  rf ixh rf ixl rf iyh rf iyl
		test_bit_b_r( 8'h44, 3'd0, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h38, 8'h00, 8'h00, 8'h00, 8'h00 );	//	set 0, h
		test_bit_b_r( 8'h44, 3'd1, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h7C, 8'h00, 8'h00, 8'h00, 8'h00 );	//	set 1, h
		test_bit_b_r( 8'h44, 3'd2, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h7C, 8'h00, 8'h00, 8'h00, 8'h00 );	//	set 2, h
		test_bit_b_r( 8'h44, 3'd3, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h38, 8'h00, 8'h00, 8'h00, 8'h00 );	//	set 3, h
		test_bit_b_r( 8'h44, 3'd4, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h7C, 8'h00, 8'h00, 8'h00, 8'h00 );	//	set 4, h
		test_bit_b_r( 8'h44, 3'd5, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h38, 8'h00, 8'h00, 8'h00, 8'h00 );	//	set 5, h
		test_bit_b_r( 8'h44, 3'd6, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h38, 8'h00, 8'h00, 8'h00, 8'h00 );	//	set 6, h
		test_bit_b_r( 8'h44, 3'd7, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h7C, 8'h00, 8'h00, 8'h00, 8'h00 );	//	set 7, h
		//            code   n     ref B  ref C  ref D  ref E  ref H  ref L  ref A  ref F  rf ixh rf ixl rf iyh rf iyl
		test_bit_b_r( 8'h45, 3'd0, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h74, 8'h00, 8'h00, 8'h00, 8'h00 );	//	set 0, l
		test_bit_b_r( 8'h45, 3'd1, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h74, 8'h00, 8'h00, 8'h00, 8'h00 );	//	set 1, l
		test_bit_b_r( 8'h45, 3'd2, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h30, 8'h00, 8'h00, 8'h00, 8'h00 );	//	set 2, l
		test_bit_b_r( 8'h45, 3'd3, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h74, 8'h00, 8'h00, 8'h00, 8'h00 );	//	set 3, l
		test_bit_b_r( 8'h45, 3'd4, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h74, 8'h00, 8'h00, 8'h00, 8'h00 );	//	set 4, l
		test_bit_b_r( 8'h45, 3'd5, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h30, 8'h00, 8'h00, 8'h00, 8'h00 );	//	set 5, l
		test_bit_b_r( 8'h45, 3'd6, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h74, 8'h00, 8'h00, 8'h00, 8'h00 );	//	set 6, l
		test_bit_b_r( 8'h45, 3'd7, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h74, 8'h00, 8'h00, 8'h00, 8'h00 );	//	set 7, l
		//            code   n     ref B  ref C  ref D  ref E  ref H  ref L  ref A  ref F  rf ixh rf ixl rf iyh rf iyl
		test_bit_b_r( 8'h47, 3'd0, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h54, 8'h00, 8'h00, 8'h00, 8'h00 );	//	set 0, a
		test_bit_b_r( 8'h47, 3'd1, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h10, 8'h00, 8'h00, 8'h00, 8'h00 );	//	set 1, a
		test_bit_b_r( 8'h47, 3'd2, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h10, 8'h00, 8'h00, 8'h00, 8'h00 );	//	set 2, a
		test_bit_b_r( 8'h47, 3'd3, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h54, 8'h00, 8'h00, 8'h00, 8'h00 );	//	set 3, a
		test_bit_b_r( 8'h47, 3'd4, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h10, 8'h00, 8'h00, 8'h00, 8'h00 );	//	set 4, a
		test_bit_b_r( 8'h47, 3'd5, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h54, 8'h00, 8'h00, 8'h00, 8'h00 );	//	set 5, a
		test_bit_b_r( 8'h47, 3'd6, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h54, 8'h00, 8'h00, 8'h00, 8'h00 );	//	set 6, a
		test_bit_b_r( 8'h47, 3'd7, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h00, 8'h00, 8'h00, 8'h00 );	//	set 7, a

		$finish;
	end
endmodule
