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
	function string cmd_sel(
		input	[1:0]	sel
	);
		case( sel )
		2'b01:		cmd_sel = "BIT";
		2'b10:		cmd_sel = "RES";
		2'b11:		cmd_sel = "SET";
		default:	cmd_sel = "*";
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
	task send_byte_a(
		input	[7:0]	data,
		input	[15:0]	address
	);
		ff_d <= data;
		@( negedge rd_n );
		@( posedge rd_n );
		assert( m1_n == 1'b1 );
		assert( a == address );
		if( a != address ) begin
			$display( "-- address %04X is not match %04X(ref)", a, address );
		end
	endtask: send_byte_a

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
	task run_ld_xy_nn(
		input	[7:0]	prefix,
		input	[15:0]	data
	);
		$display( "CODE %02X, 21, %04X: LD  %s, %02Xh", prefix, data, regxy_sel( prefix[5] ), data );

		//	2bytes の命令コードを送る 
		send_byte( prefix );
		send_byte( 8'h21 );
		send_byte( data[7:0] );
		send_byte( data[15:8] );
	endtask: run_ld_xy_nn

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
	task result_check(
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
		logic	[7:0]	rdata;

		//	確認用に全レジスタを push してレジスタ値を出力させる 
		send_byte( 8'hC5 );
		receive_byte( rdata );
		assert( rdata === ref_b );
		if( rdata !== ref_b ) begin
			$display( "  B bloken to 0x%02X", rdata );
		end

		receive_byte( rdata );
		assert( rdata === ref_c );
		if( rdata !== ref_c ) begin
			$display( "  C bloken to 0x%02X", rdata );
		end

		send_byte( 8'hD5 );
		receive_byte( rdata );
		assert( rdata === ref_d );
		if( rdata !== ref_d ) begin
			$display( "  D bloken to 0x%02X", rdata );
		end

		receive_byte( rdata );
		assert( rdata === ref_e );
		if( rdata !== ref_e ) begin
			$display( "  E bloken to 0x%02X", rdata );
		end

		send_byte( 8'hE5 );
		receive_byte( rdata );
		assert( rdata === ref_h );
		if( rdata !== ref_h ) begin
			$display( "  H bloken to 0x%02X", rdata );
		end

		receive_byte( rdata );
		assert( rdata === ref_l );
		if( rdata !== ref_l ) begin
			$display( "  L bloken to 0x%02X", rdata );
		end

		send_byte( 8'hF5 );
		receive_byte( rdata );
		assert( rdata === ref_a );
		if( rdata !== ref_a ) begin
			$display( "  A bloken to 0x%02X", rdata );
		end

		receive_byte( rdata );
		assert( rdata === ref_f );
		if( rdata !== ref_f ) begin
			$display( "  F bloken to 0x%02X", rdata );
		end

		send_byte( 8'hDD );
		send_byte( 8'hE5 );
		receive_byte( rdata );
		assert( rdata === ref_ixh );
		if( rdata !== ref_ixh ) begin
			$display( "  IXh bloken to 0x%02X", rdata );
		end

		receive_byte( rdata );
		assert( rdata === ref_ixl );
		if( rdata !== ref_ixl ) begin
			$display( "  IXl bloken to 0x%02X", rdata );
		end

		send_byte( 8'hFD );
		send_byte( 8'hE5 );
		receive_byte( rdata );
		assert( rdata === ref_iyh );
		if( rdata !== ref_iyh ) begin
			$display( "  IYh bloken to 0x%02X", rdata );
		end

		receive_byte( rdata );
		assert( rdata === ref_iyl );
		if( rdata !== ref_iyl ) begin
			$display( "  IYl bloken to 0x%02X", rdata );
		end
	endtask: result_check

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

		sopecode	= { opecode[7:6], bit_no, opecode[2:0] };
		$display( "CODE CB, %02X    : %s %1d, %s", sopecode, cmd_sel( opecode[7:6] ), bit_no, reg8_sel( opecode[2:0] ) );
		send_byte( 8'hCB );
		send_byte( sopecode );
		result_check( ref_b, ref_c, ref_d, ref_e, ref_h, ref_l, ref_a, ref_f, ref_ixh, ref_ixl, ref_iyh, ref_iyl );
	endtask: test_bit_b_r

	// --------------------------------------------------------------------
	task test_bit_b_hl(
		input	[7:0]	opecode,
		input	[2:0]	bit_no,
		input	[7:0]	data,
		input	[15:0]	address,
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

		sopecode	= { opecode[7:6], bit_no, opecode[2:0] };
		$display( "CODE CB, %02X    : BIT %1d, %s", sopecode, bit_no, reg8_sel( opecode[2:0] ) );
		send_byte( 8'hCB );
		send_byte( sopecode );
		send_byte_a( data, address );
		result_check( ref_b, ref_c, ref_d, ref_e, ref_h, ref_l, ref_a, ref_f, ref_ixh, ref_ixl, ref_iyh, ref_iyl );
	endtask: test_bit_b_hl

	// --------------------------------------------------------------------
	task test_res_b_hl(
		input	[7:0]	opecode,
		input	[2:0]	bit_no,
		input	[7:0]	data,
		input	[7:0]	ref_data,
		input	[15:0]	address,
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
		logic	[15:0]	raddress;
		logic	[7:0]	rdata;

		sopecode	= { opecode[7:6], bit_no, opecode[2:0] };
		$display( "CODE CB, %02X    : %s %1d, %s", sopecode, cmd_sel( opecode[7:6] ), bit_no, reg8_sel( opecode[2:0] ) );
		send_byte( 8'hCB );
		send_byte( sopecode );
		send_byte_a( data, address );
		receive_byte_a( rdata, raddress );
		assert( raddress == address );
		if( raddress != address ) begin
			$display( "-- Address %04X is not match %04X(ref).", raddress, address );
		end
		assert( rdata == ref_data );
		if( rdata != ref_data ) begin
			$display( "-- Data %02X is not match %02X(ref).", rdata, ref_data );
		end
		result_check( ref_b, ref_c, ref_d, ref_e, ref_h, ref_l, ref_a, ref_f, ref_ixh, ref_ixl, ref_iyh, ref_iyl );
	endtask: test_res_b_hl

	// --------------------------------------------------------------------
	task test_bit_b_xy(
		input	[7:0]	prefix,
		input	[7:0]	opecode,
		input	[2:0]	bit_no,
		input	[7:0]	d,
		input	[7:0]	data,
		input	[15:0]	address,
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
		logic	[15:0]	raddress;

		sopecode	= { opecode[7:6], bit_no, opecode[2:0] };
		$display( "CODE %02X, CB, %02X, %03X: BIT %1d, (%s + %02Xh)", prefix, sopecode, d, bit_no, regxy_sel( prefix[5] ), d );
		send_byte( prefix );
		send_byte( 8'hCB );
		send_byte( d );
		send_byte( sopecode );
		send_byte_a( data, address );
		result_check( ref_b, ref_c, ref_d, ref_e, ref_h, ref_l, ref_a, ref_f, ref_ixh, ref_ixl, ref_iyh, ref_iyl );
	endtask: test_bit_b_xy

	// --------------------------------------------------------------------
	task test_res_b_xy(
		input	[7:0]	prefix,
		input	[7:0]	opecode,
		input	[2:0]	bit_no,
		input	[7:0]	d,
		input	[7:0]	data,
		input	[7:0]	ref_data,
		input	[15:0]	address,
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
		logic	[15:0]	raddress;

		sopecode	= { opecode[7:6], bit_no, opecode[2:0] };
		$display( "CODE %02X, CB, %02X, %03X: %s %1d, (%s + %02Xh)", prefix, sopecode, d, cmd_sel( opecode[7:6] ), bit_no, regxy_sel( prefix[5] ), d );
		send_byte( prefix );
		send_byte( 8'hCB );
		send_byte( d );
		send_byte( sopecode );
		send_byte_a( data, address );
		receive_byte_a( rdata, raddress );
		assert( raddress == address );
		if( raddress != address ) begin
			$display( "-- Address %04X is not match %04X(ref).", raddress, address );
		end
		assert( rdata == ref_data );
		if( rdata != ref_data ) begin
			$display( "-- Data %02X is not match %02X(ref).", rdata, ref_data );
		end
		result_check( ref_b, ref_c, ref_d, ref_e, ref_h, ref_l, ref_a, ref_f, ref_ixh, ref_ixl, ref_iyh, ref_iyl );
	endtask: test_res_b_xy


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
		run_ld_xy_nn( 8'hDD, 16'h1357 );		//	LD IX, 1357h
		run_ld_xy_nn( 8'hFD, 16'h7531 );		//	LD IY, 7531h
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
		test_bit_b_r( 8'h40, 3'd0, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h30, 8'h13, 8'h57, 8'h75, 8'h31 );	//	bit 0, b
		test_bit_b_r( 8'h40, 3'd1, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h74, 8'h13, 8'h57, 8'h75, 8'h31 );	//	bit 1, b
		test_bit_b_r( 8'h40, 3'd2, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h30, 8'h13, 8'h57, 8'h75, 8'h31 );	//	bit 2, b
		test_bit_b_r( 8'h40, 3'd3, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h74, 8'h13, 8'h57, 8'h75, 8'h31 );	//	bit 3, b
		test_bit_b_r( 8'h40, 3'd4, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h74, 8'h13, 8'h57, 8'h75, 8'h31 );	//	bit 4, b
		test_bit_b_r( 8'h40, 3'd5, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h30, 8'h13, 8'h57, 8'h75, 8'h31 );	//	bit 5, b
		test_bit_b_r( 8'h40, 3'd6, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h74, 8'h13, 8'h57, 8'h75, 8'h31 );	//	bit 6, b
		test_bit_b_r( 8'h40, 3'd7, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'hB0, 8'h13, 8'h57, 8'h75, 8'h31 );	//	bit 7, b
		//            code   n     ref B  ref C  ref D  ref E  ref H  ref L  ref A  ref F  rf ixh rf ixl rf iyh rf iyl
		test_bit_b_r( 8'h41, 3'd0, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h10, 8'h13, 8'h57, 8'h75, 8'h31 );	//	bit 0, c
		test_bit_b_r( 8'h41, 3'd1, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h10, 8'h13, 8'h57, 8'h75, 8'h31 );	//	bit 1, c
		test_bit_b_r( 8'h41, 3'd2, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h54, 8'h13, 8'h57, 8'h75, 8'h31 );	//	bit 2, c
		test_bit_b_r( 8'h41, 3'd3, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h54, 8'h13, 8'h57, 8'h75, 8'h31 );	//	bit 3, c
		test_bit_b_r( 8'h41, 3'd4, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h54, 8'h13, 8'h57, 8'h75, 8'h31 );	//	bit 4, c
		test_bit_b_r( 8'h41, 3'd5, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h54, 8'h13, 8'h57, 8'h75, 8'h31 );	//	bit 5, c
		test_bit_b_r( 8'h41, 3'd6, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h10, 8'h13, 8'h57, 8'h75, 8'h31 );	//	bit 6, c
		test_bit_b_r( 8'h41, 3'd7, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	bit 7, c
		//            code   n     ref B  ref C  ref D  ref E  ref H  ref L  ref A  ref F  rf ixh rf ixl rf iyh rf iyl
		test_bit_b_r( 8'h42, 3'd0, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h5C, 8'h13, 8'h57, 8'h75, 8'h31 );	//	bit 0, d
		test_bit_b_r( 8'h42, 3'd1, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h18, 8'h13, 8'h57, 8'h75, 8'h31 );	//	bit 1, d
		test_bit_b_r( 8'h42, 3'd2, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h5C, 8'h13, 8'h57, 8'h75, 8'h31 );	//	bit 2, d
		test_bit_b_r( 8'h42, 3'd3, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h18, 8'h13, 8'h57, 8'h75, 8'h31 );	//	bit 3, d
		test_bit_b_r( 8'h42, 3'd4, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h18, 8'h13, 8'h57, 8'h75, 8'h31 );	//	bit 4, d
		test_bit_b_r( 8'h42, 3'd5, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h5C, 8'h13, 8'h57, 8'h75, 8'h31 );	//	bit 5, d
		test_bit_b_r( 8'h42, 3'd6, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h18, 8'h13, 8'h57, 8'h75, 8'h31 );	//	bit 6, d
		test_bit_b_r( 8'h42, 3'd7, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h5C, 8'h13, 8'h57, 8'h75, 8'h31 );	//	bit 7, d
		//            code   n     ref B  ref C  ref D  ref E  ref H  ref L  ref A  ref F  rf ixh rf ixl rf iyh rf iyl
		test_bit_b_r( 8'h43, 3'd0, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h7C, 8'h13, 8'h57, 8'h75, 8'h31 );	//	bit 0, e
		test_bit_b_r( 8'h43, 3'd1, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h7C, 8'h13, 8'h57, 8'h75, 8'h31 );	//	bit 1, e
		test_bit_b_r( 8'h43, 3'd2, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h38, 8'h13, 8'h57, 8'h75, 8'h31 );	//	bit 2, e
		test_bit_b_r( 8'h43, 3'd3, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h38, 8'h13, 8'h57, 8'h75, 8'h31 );	//	bit 3, e
		test_bit_b_r( 8'h43, 3'd4, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h38, 8'h13, 8'h57, 8'h75, 8'h31 );	//	bit 4, e
		test_bit_b_r( 8'h43, 3'd5, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h38, 8'h13, 8'h57, 8'h75, 8'h31 );	//	bit 5, e
		test_bit_b_r( 8'h43, 3'd6, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h7C, 8'h13, 8'h57, 8'h75, 8'h31 );	//	bit 6, e
		test_bit_b_r( 8'h43, 3'd7, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h7C, 8'h13, 8'h57, 8'h75, 8'h31 );	//	bit 7, e
		//            code   n     ref B  ref C  ref D  ref E  ref H  ref L  ref A  ref F  rf ixh rf ixl rf iyh rf iyl
		test_bit_b_r( 8'h44, 3'd0, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h38, 8'h13, 8'h57, 8'h75, 8'h31 );	//	bit 0, h
		test_bit_b_r( 8'h44, 3'd1, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h7C, 8'h13, 8'h57, 8'h75, 8'h31 );	//	bit 1, h
		test_bit_b_r( 8'h44, 3'd2, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h7C, 8'h13, 8'h57, 8'h75, 8'h31 );	//	bit 2, h
		test_bit_b_r( 8'h44, 3'd3, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h38, 8'h13, 8'h57, 8'h75, 8'h31 );	//	bit 3, h
		test_bit_b_r( 8'h44, 3'd4, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h7C, 8'h13, 8'h57, 8'h75, 8'h31 );	//	bit 4, h
		test_bit_b_r( 8'h44, 3'd5, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h38, 8'h13, 8'h57, 8'h75, 8'h31 );	//	bit 5, h
		test_bit_b_r( 8'h44, 3'd6, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h38, 8'h13, 8'h57, 8'h75, 8'h31 );	//	bit 6, h
		test_bit_b_r( 8'h44, 3'd7, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h7C, 8'h13, 8'h57, 8'h75, 8'h31 );	//	bit 7, h
		//            code   n     ref B  ref C  ref D  ref E  ref H  ref L  ref A  ref F  rf ixh rf ixl rf iyh rf iyl
		test_bit_b_r( 8'h45, 3'd0, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h74, 8'h13, 8'h57, 8'h75, 8'h31 );	//	bit 0, l
		test_bit_b_r( 8'h45, 3'd1, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h74, 8'h13, 8'h57, 8'h75, 8'h31 );	//	bit 1, l
		test_bit_b_r( 8'h45, 3'd2, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h30, 8'h13, 8'h57, 8'h75, 8'h31 );	//	bit 2, l
		test_bit_b_r( 8'h45, 3'd3, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h74, 8'h13, 8'h57, 8'h75, 8'h31 );	//	bit 3, l
		test_bit_b_r( 8'h45, 3'd4, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h74, 8'h13, 8'h57, 8'h75, 8'h31 );	//	bit 4, l
		test_bit_b_r( 8'h45, 3'd5, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h30, 8'h13, 8'h57, 8'h75, 8'h31 );	//	bit 5, l
		test_bit_b_r( 8'h45, 3'd6, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h74, 8'h13, 8'h57, 8'h75, 8'h31 );	//	bit 6, l
		test_bit_b_r( 8'h45, 3'd7, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h74, 8'h13, 8'h57, 8'h75, 8'h31 );	//	bit 7, l
		//             code   n     data   ref addr  ref B  ref C  ref D  ref E  ref H  ref L  ref A  ref F  rf ixh rf ixl rf iyh rf iyl
		test_bit_b_hl( 8'h46, 3'd0, 8'h96, 16'h6924, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h54, 8'h13, 8'h57, 8'h75, 8'h31 );	//	bit 0, (hl)
		test_bit_b_hl( 8'h46, 3'd1, 8'h96, 16'h6924, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h10, 8'h13, 8'h57, 8'h75, 8'h31 );	//	bit 1, (hl)
		test_bit_b_hl( 8'h46, 3'd2, 8'h96, 16'h6924, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h10, 8'h13, 8'h57, 8'h75, 8'h31 );	//	bit 2, (hl)
		test_bit_b_hl( 8'h46, 3'd3, 8'h96, 16'h6924, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h54, 8'h13, 8'h57, 8'h75, 8'h31 );	//	bit 3, (hl)
		test_bit_b_hl( 8'h46, 3'd4, 8'h96, 16'h6924, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h10, 8'h13, 8'h57, 8'h75, 8'h31 );	//	bit 4, (hl)
		test_bit_b_hl( 8'h46, 3'd5, 8'h96, 16'h6924, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h54, 8'h13, 8'h57, 8'h75, 8'h31 );	//	bit 5, (hl)
		test_bit_b_hl( 8'h46, 3'd6, 8'h96, 16'h6924, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h54, 8'h13, 8'h57, 8'h75, 8'h31 );	//	bit 6, (hl)
		test_bit_b_hl( 8'h46, 3'd7, 8'h96, 16'h6924, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	bit 7, (hl)
		//            code   n     ref B  ref C  ref D  ref E  ref H  ref L  ref A  ref F  rf ixh rf ixl rf iyh rf iyl
		test_bit_b_r( 8'h47, 3'd0, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h54, 8'h13, 8'h57, 8'h75, 8'h31 );	//	bit 0, a
		test_bit_b_r( 8'h47, 3'd1, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h10, 8'h13, 8'h57, 8'h75, 8'h31 );	//	bit 1, a
		test_bit_b_r( 8'h47, 3'd2, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h10, 8'h13, 8'h57, 8'h75, 8'h31 );	//	bit 2, a
		test_bit_b_r( 8'h47, 3'd3, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h54, 8'h13, 8'h57, 8'h75, 8'h31 );	//	bit 3, a
		test_bit_b_r( 8'h47, 3'd4, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h10, 8'h13, 8'h57, 8'h75, 8'h31 );	//	bit 4, a
		test_bit_b_r( 8'h47, 3'd5, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h54, 8'h13, 8'h57, 8'h75, 8'h31 );	//	bit 5, a
		test_bit_b_r( 8'h47, 3'd6, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h54, 8'h13, 8'h57, 8'h75, 8'h31 );	//	bit 6, a
		test_bit_b_r( 8'h47, 3'd7, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	bit 7, a
		//             prefix code   n     d      data   ref addr  ref B  ref C  ref D  ref E  ref H  ref L  ref A  ref F  rf ixh rf ixl rf iyh rf iyl
		test_bit_b_xy( 8'hDD, 8'h46, 3'd0, 8'h00, 8'h96, 16'h1357, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h54, 8'h13, 8'h57, 8'h75, 8'h31 );	//	bit 0, (ix + 00h)
		test_bit_b_xy( 8'hDD, 8'h46, 3'd1, 8'h7F, 8'h96, 16'h13D6, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h10, 8'h13, 8'h57, 8'h75, 8'h31 );	//	bit 1, (ix + 7Fh)
		test_bit_b_xy( 8'hDD, 8'h46, 3'd2, 8'h80, 8'h96, 16'h12D7, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h10, 8'h13, 8'h57, 8'h75, 8'h31 );	//	bit 2, (ix + 80h)
		test_bit_b_xy( 8'hDD, 8'h46, 3'd3, 8'hC0, 8'h96, 16'h1317, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h54, 8'h13, 8'h57, 8'h75, 8'h31 );	//	bit 3, (ix + C0h)
		test_bit_b_xy( 8'hDD, 8'h46, 3'd4, 8'h40, 8'h96, 16'h1397, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h10, 8'h13, 8'h57, 8'h75, 8'h31 );	//	bit 4, (ix + 40h)
		test_bit_b_xy( 8'hDD, 8'h46, 3'd5, 8'h57, 8'h96, 16'h13AE, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h54, 8'h13, 8'h57, 8'h75, 8'h31 );	//	bit 5, (ix + 57h)
		test_bit_b_xy( 8'hDD, 8'h46, 3'd6, 8'hAB, 8'h96, 16'h1302, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h54, 8'h13, 8'h57, 8'h75, 8'h31 );	//	bit 6, (ix + ABh)
		test_bit_b_xy( 8'hDD, 8'h46, 3'd7, 8'h12, 8'h96, 16'h1369, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	bit 7, (ix + 12h)
		//             prefix code   n     d      data   ref addr  ref B  ref C  ref D  ref E  ref H  ref L  ref A  ref F  rf ixh rf ixl rf iyh rf iyl
		test_bit_b_xy( 8'hFD, 8'h46, 3'd0, 8'h00, 8'h96, 16'h7531, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h54, 8'h13, 8'h57, 8'h75, 8'h31 );	//	bit 0, (iy + 00h)
		test_bit_b_xy( 8'hFD, 8'h46, 3'd1, 8'h7F, 8'h96, 16'h75B0, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h10, 8'h13, 8'h57, 8'h75, 8'h31 );	//	bit 1, (iy + 7Fh)
		test_bit_b_xy( 8'hFD, 8'h46, 3'd2, 8'h80, 8'h96, 16'h74B1, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h10, 8'h13, 8'h57, 8'h75, 8'h31 );	//	bit 2, (iy + 80h)
		test_bit_b_xy( 8'hFD, 8'h46, 3'd3, 8'hC0, 8'h96, 16'h74F1, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h54, 8'h13, 8'h57, 8'h75, 8'h31 );	//	bit 3, (iy + C0h)
		test_bit_b_xy( 8'hFD, 8'h46, 3'd4, 8'h40, 8'h96, 16'h7571, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h10, 8'h13, 8'h57, 8'h75, 8'h31 );	//	bit 4, (iy + 40h)
		test_bit_b_xy( 8'hFD, 8'h46, 3'd5, 8'h57, 8'h96, 16'h7588, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h54, 8'h13, 8'h57, 8'h75, 8'h31 );	//	bit 5, (iy + 57h)
		test_bit_b_xy( 8'hFD, 8'h46, 3'd6, 8'hAB, 8'h96, 16'h74DC, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h54, 8'h13, 8'h57, 8'h75, 8'h31 );	//	bit 6, (iy + ABh)
		test_bit_b_xy( 8'hFD, 8'h46, 3'd7, 8'h12, 8'h96, 16'h7543, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	bit 7, (iy + 12h)

		// --------------------------------------------------------------------
		//            code   n     ref B  ref C  ref D  ref E  ref H  ref L  ref A  ref F  rf ixh rf ixl rf iyh rf iyl
		test_bit_b_r( 8'h80, 3'd0, 8'hA4, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	res 0, b
		test_bit_b_r( 8'h80, 3'd1, 8'hA4, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	res 1, b
		test_bit_b_r( 8'h80, 3'd2, 8'hA0, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	res 2, b
		test_bit_b_r( 8'h80, 3'd3, 8'hA0, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	res 3, b
		test_bit_b_r( 8'h80, 3'd4, 8'hA0, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	res 4, b
		test_bit_b_r( 8'h80, 3'd5, 8'h80, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	res 5, b
		test_bit_b_r( 8'h80, 3'd6, 8'h80, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	res 6, b
		test_bit_b_r( 8'h80, 3'd7, 8'h00, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	res 7, b
		run_ld_r_n( 8'h06, 8'hA5 );		//	LD B, A5h
		//            code   n     ref B  ref C  ref D  ref E  ref H  ref L  ref A  ref F  rf ixh rf ixl rf iyh rf iyl
		test_bit_b_r( 8'h81, 3'd0, 8'hA5, 8'hC2, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	res 0, c
		test_bit_b_r( 8'h81, 3'd1, 8'hA5, 8'hC0, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	res 1, c
		test_bit_b_r( 8'h81, 3'd2, 8'hA5, 8'hC0, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	res 2, c
		test_bit_b_r( 8'h81, 3'd3, 8'hA5, 8'hC0, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	res 3, c
		test_bit_b_r( 8'h81, 3'd4, 8'hA5, 8'hC0, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	res 4, c
		test_bit_b_r( 8'h81, 3'd5, 8'hA5, 8'hC0, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	res 5, c
		test_bit_b_r( 8'h81, 3'd6, 8'hA5, 8'h80, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	res 6, c
		test_bit_b_r( 8'h81, 3'd7, 8'hA5, 8'h00, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	res 7, c
		run_ld_r_n( 8'h0E, 8'hC3 );		//	LD C, C3h
		//            code   n     ref B  ref C  ref D  ref E  ref H  ref L  ref A  ref F  rf ixh rf ixl rf iyh rf iyl
		test_bit_b_r( 8'h82, 3'd0, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	res 0, d
		test_bit_b_r( 8'h82, 3'd1, 8'hA5, 8'hC3, 8'h58, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	res 1, d
		test_bit_b_r( 8'h82, 3'd2, 8'hA5, 8'hC3, 8'h58, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	res 2, d
		test_bit_b_r( 8'h82, 3'd3, 8'hA5, 8'hC3, 8'h50, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	res 3, d
		test_bit_b_r( 8'h82, 3'd4, 8'hA5, 8'hC3, 8'h40, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	res 4, d
		test_bit_b_r( 8'h82, 3'd5, 8'hA5, 8'hC3, 8'h40, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	res 5, d
		test_bit_b_r( 8'h82, 3'd6, 8'hA5, 8'hC3, 8'h00, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	res 6, d
		test_bit_b_r( 8'h82, 3'd7, 8'hA5, 8'hC3, 8'h00, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	res 7, d
		run_ld_r_n( 8'h16, 8'h5A );		//	LD D, 5Ah
		//            code   n     ref B  ref C  ref D  ref E  ref H  ref L  ref A  ref F  rf ixh rf ixl rf iyh rf iyl
		test_bit_b_r( 8'h83, 3'd0, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	res 0, e
		test_bit_b_r( 8'h83, 3'd1, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	res 1, e
		test_bit_b_r( 8'h83, 3'd2, 8'hA5, 8'hC3, 8'h5A, 8'h38, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	res 2, e
		test_bit_b_r( 8'h83, 3'd3, 8'hA5, 8'hC3, 8'h5A, 8'h30, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	res 3, e
		test_bit_b_r( 8'h83, 3'd4, 8'hA5, 8'hC3, 8'h5A, 8'h20, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	res 4, e
		test_bit_b_r( 8'h83, 3'd5, 8'hA5, 8'hC3, 8'h5A, 8'h00, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	res 5, e
		test_bit_b_r( 8'h83, 3'd6, 8'hA5, 8'hC3, 8'h5A, 8'h00, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	res 6, e
		test_bit_b_r( 8'h83, 3'd7, 8'hA5, 8'hC3, 8'h5A, 8'h00, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	res 7, e
		run_ld_r_n( 8'h1E, 8'h3C );		//	LD E, 3Ch
		//            code   n     ref B  ref C  ref D  ref E  ref H  ref L  ref A  ref F  rf ixh rf ixl rf iyh rf iyl
		test_bit_b_r( 8'h84, 3'd0, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h68, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	res 0, h
		test_bit_b_r( 8'h84, 3'd1, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h68, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	res 1, h
		test_bit_b_r( 8'h84, 3'd2, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h68, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	res 2, h
		test_bit_b_r( 8'h84, 3'd3, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h60, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	res 3, h
		test_bit_b_r( 8'h84, 3'd4, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h60, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	res 4, h
		test_bit_b_r( 8'h84, 3'd5, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h40, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	res 5, h
		test_bit_b_r( 8'h84, 3'd6, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h00, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	res 6, h
		test_bit_b_r( 8'h84, 3'd7, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h00, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	res 7, h
		run_ld_r_n( 8'h26, 8'h69 );		//	LD H, 69h
		//            code   n     ref B  ref C  ref D  ref E  ref H  ref L  ref A  ref F  rf ixh rf ixl rf iyh rf iyl
		test_bit_b_r( 8'h85, 3'd0, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	res 0, l
		test_bit_b_r( 8'h85, 3'd1, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	res 1, l
		test_bit_b_r( 8'h85, 3'd2, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h20, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	res 2, l
		test_bit_b_r( 8'h85, 3'd3, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h20, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	res 3, l
		test_bit_b_r( 8'h85, 3'd4, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h20, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	res 4, l
		test_bit_b_r( 8'h85, 3'd5, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h00, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	res 5, l
		test_bit_b_r( 8'h85, 3'd6, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h00, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	res 6, l
		test_bit_b_r( 8'h85, 3'd7, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h00, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	res 7, l
		run_ld_r_n( 8'h2E, 8'h24 );		//	LD L, 24h
		//             code   n     data   ref d  ref addr  ref B  ref C  ref D  ref E  ref H  ref L  ref A  ref F  rf ixh rf ixl rf iyh rf iyl
		test_res_b_hl( 8'h86, 3'd0, 8'h96, 8'h96, 16'h6924, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	res 0, (hl)
		test_res_b_hl( 8'h86, 3'd1, 8'h96, 8'h94, 16'h6924, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	res 1, (hl)
		test_res_b_hl( 8'h86, 3'd2, 8'h96, 8'h92, 16'h6924, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	res 2, (hl)
		test_res_b_hl( 8'h86, 3'd3, 8'h96, 8'h96, 16'h6924, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	res 3, (hl)
		test_res_b_hl( 8'h86, 3'd4, 8'h96, 8'h86, 16'h6924, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	res 4, (hl)
		test_res_b_hl( 8'h86, 3'd5, 8'h96, 8'h96, 16'h6924, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	res 5, (hl)
		test_res_b_hl( 8'h86, 3'd6, 8'h96, 8'h96, 16'h6924, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	res 6, (hl)
		test_res_b_hl( 8'h86, 3'd7, 8'h96, 8'h16, 16'h6924, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	res 7, (hl)
		//            code   n     ref B  ref C  ref D  ref E  ref H  ref L  ref A  ref F  rf ixh rf ixl rf iyh rf iyl
		test_bit_b_r( 8'h87, 3'd0, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	res 0, a
		test_bit_b_r( 8'h87, 3'd1, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h94, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	res 1, a
		test_bit_b_r( 8'h87, 3'd2, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h90, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	res 2, a
		test_bit_b_r( 8'h87, 3'd3, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h90, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	res 3, a
		test_bit_b_r( 8'h87, 3'd4, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h80, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	res 4, a
		test_bit_b_r( 8'h87, 3'd5, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h80, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	res 5, a
		test_bit_b_r( 8'h87, 3'd6, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h80, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	res 6, a
		test_bit_b_r( 8'h87, 3'd7, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h00, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	res 7, a
		run_ld_r_n( 8'h3E, 8'h96 );		//	LD A, 96h
		//             prefix code   n     d      data   ref d  ref addr  ref B  ref C  ref D  ref E  ref H  ref L  ref A  ref F  rf ixh rf ixl rf iyh rf iyl
		test_res_b_xy( 8'hDD, 8'h86, 3'd0, 8'h00, 8'h96, 8'h96, 16'h1357, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	res 0, (ix + 00h)
		test_res_b_xy( 8'hDD, 8'h86, 3'd1, 8'h7F, 8'h96, 8'h94, 16'h13D6, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	res 1, (ix + 7Fh)
		test_res_b_xy( 8'hDD, 8'h86, 3'd2, 8'h80, 8'h96, 8'h92, 16'h12D7, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	res 2, (ix + 80h)
		test_res_b_xy( 8'hDD, 8'h86, 3'd3, 8'hC0, 8'h96, 8'h96, 16'h1317, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	res 3, (ix + C0h)
		test_res_b_xy( 8'hDD, 8'h86, 3'd4, 8'h40, 8'h96, 8'h86, 16'h1397, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	res 4, (ix + 40h)
		test_res_b_xy( 8'hDD, 8'h86, 3'd5, 8'h57, 8'h96, 8'h96, 16'h13AE, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	res 5, (ix + 57h)
		test_res_b_xy( 8'hDD, 8'h86, 3'd6, 8'hAB, 8'h96, 8'h96, 16'h1302, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	res 6, (ix + ABh)
		test_res_b_xy( 8'hDD, 8'h86, 3'd7, 8'h12, 8'h96, 8'h16, 16'h1369, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	res 7, (ix + 12h)
		//             prefix code   n     d      data   ref d  ref addr  ref B  ref C  ref D  ref E  ref H  ref L  ref A  ref F  rf ixh rf ixl rf iyh rf iyl
		test_res_b_xy( 8'hFD, 8'h86, 3'd0, 8'h00, 8'h96, 8'h96, 16'h7531, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	res 0, (iy + 00h)
		test_res_b_xy( 8'hFD, 8'h86, 3'd1, 8'h7F, 8'h96, 8'h94, 16'h75B0, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	res 1, (iy + 7Fh)
		test_res_b_xy( 8'hFD, 8'h86, 3'd2, 8'h80, 8'h96, 8'h92, 16'h74B1, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	res 2, (iy + 80h)
		test_res_b_xy( 8'hFD, 8'h86, 3'd3, 8'hC0, 8'h96, 8'h96, 16'h74F1, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	res 3, (iy + C0h)
		test_res_b_xy( 8'hFD, 8'h86, 3'd4, 8'h40, 8'h96, 8'h86, 16'h7571, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	res 4, (iy + 40h)
		test_res_b_xy( 8'hFD, 8'h86, 3'd5, 8'h57, 8'h96, 8'h96, 16'h7588, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	res 5, (iy + 57h)
		test_res_b_xy( 8'hFD, 8'h86, 3'd6, 8'hAB, 8'h96, 8'h96, 16'h74DC, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	res 6, (iy + ABh)
		test_res_b_xy( 8'hFD, 8'h86, 3'd7, 8'h12, 8'h96, 8'h16, 16'h7543, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	res 7, (iy + 12h)

		// --------------------------------------------------------------------
		//            code   n     ref B  ref C  ref D  ref E  ref H  ref L  ref A  ref F  rf ixh rf ixl rf iyh rf iyl
		test_bit_b_r( 8'hC0, 3'd0, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	set 0, b
		test_bit_b_r( 8'hC0, 3'd1, 8'hA7, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	set 1, b
		test_bit_b_r( 8'hC0, 3'd2, 8'hA7, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	set 2, b
		test_bit_b_r( 8'hC0, 3'd3, 8'hAF, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	set 3, b
		test_bit_b_r( 8'hC0, 3'd4, 8'hBF, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	set 4, b
		test_bit_b_r( 8'hC0, 3'd5, 8'hBF, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	set 5, b
		test_bit_b_r( 8'hC0, 3'd6, 8'hFF, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	set 6, b
		test_bit_b_r( 8'hC0, 3'd7, 8'hFF, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	set 7, b
		run_ld_r_n( 8'h06, 8'hA5 );		//	LD B, A5h
		//            code   n     ref B  ref C  ref D  ref E  ref H  ref L  ref A  ref F  rf ixh rf ixl rf iyh rf iyl
		test_bit_b_r( 8'hC1, 3'd0, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	set 0, c
		test_bit_b_r( 8'hC1, 3'd1, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	set 1, c
		test_bit_b_r( 8'hC1, 3'd2, 8'hA5, 8'hC7, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	set 2, c
		test_bit_b_r( 8'hC1, 3'd3, 8'hA5, 8'hCF, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	set 3, c
		test_bit_b_r( 8'hC1, 3'd4, 8'hA5, 8'hDF, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	set 4, c
		test_bit_b_r( 8'hC1, 3'd5, 8'hA5, 8'hFF, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	set 5, c
		test_bit_b_r( 8'hC1, 3'd6, 8'hA5, 8'hFF, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	set 6, c
		test_bit_b_r( 8'hC1, 3'd7, 8'hA5, 8'hFF, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	set 7, c
		run_ld_r_n( 8'h0E, 8'hC3 );		//	LD C, C3h
		//            code   n     ref B  ref C  ref D  ref E  ref H  ref L  ref A  ref F  rf ixh rf ixl rf iyh rf iyl
		test_bit_b_r( 8'hC2, 3'd0, 8'hA5, 8'hC3, 8'h5B, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	set 0, d
		test_bit_b_r( 8'hC2, 3'd1, 8'hA5, 8'hC3, 8'h5B, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	set 1, d
		test_bit_b_r( 8'hC2, 3'd2, 8'hA5, 8'hC3, 8'h5F, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	set 2, d
		test_bit_b_r( 8'hC2, 3'd3, 8'hA5, 8'hC3, 8'h5F, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	set 3, d
		test_bit_b_r( 8'hC2, 3'd4, 8'hA5, 8'hC3, 8'h5F, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	set 4, d
		test_bit_b_r( 8'hC2, 3'd5, 8'hA5, 8'hC3, 8'h7F, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	set 5, d
		test_bit_b_r( 8'hC2, 3'd6, 8'hA5, 8'hC3, 8'h7F, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	set 6, d
		test_bit_b_r( 8'hC2, 3'd7, 8'hA5, 8'hC3, 8'hFF, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	set 7, d
		run_ld_r_n( 8'h16, 8'h5A );		//	LD D, 5Ah
		//            code   n     ref B  ref C  ref D  ref E  ref H  ref L  ref A  ref F  rf ixh rf ixl rf iyh rf iyl
		test_bit_b_r( 8'hC3, 3'd0, 8'hA5, 8'hC3, 8'h5A, 8'h3D, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	set 0, e
		test_bit_b_r( 8'hC3, 3'd1, 8'hA5, 8'hC3, 8'h5A, 8'h3F, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	set 1, e
		test_bit_b_r( 8'hC3, 3'd2, 8'hA5, 8'hC3, 8'h5A, 8'h3F, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	set 2, e
		test_bit_b_r( 8'hC3, 3'd3, 8'hA5, 8'hC3, 8'h5A, 8'h3F, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	set 3, e
		test_bit_b_r( 8'hC3, 3'd4, 8'hA5, 8'hC3, 8'h5A, 8'h3F, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	set 4, e
		test_bit_b_r( 8'hC3, 3'd5, 8'hA5, 8'hC3, 8'h5A, 8'h3F, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	set 5, e
		test_bit_b_r( 8'hC3, 3'd6, 8'hA5, 8'hC3, 8'h5A, 8'h7F, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	set 6, e
		test_bit_b_r( 8'hC3, 3'd7, 8'hA5, 8'hC3, 8'h5A, 8'hFF, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	set 7, e
		run_ld_r_n( 8'h1E, 8'h3C );		//	LD E, 3Ch
		//            code   n     ref B  ref C  ref D  ref E  ref H  ref L  ref A  ref F  rf ixh rf ixl rf iyh rf iyl
		test_bit_b_r( 8'hC4, 3'd0, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	set 0, h
		test_bit_b_r( 8'hC4, 3'd1, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h6B, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	set 1, h
		test_bit_b_r( 8'hC4, 3'd2, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h6F, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	set 2, h
		test_bit_b_r( 8'hC4, 3'd3, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h6F, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	set 3, h
		test_bit_b_r( 8'hC4, 3'd4, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h7F, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	set 4, h
		test_bit_b_r( 8'hC4, 3'd5, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h7F, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	set 5, h
		test_bit_b_r( 8'hC4, 3'd6, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h7F, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	set 6, h
		test_bit_b_r( 8'hC4, 3'd7, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'hFF, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	set 7, h
		run_ld_r_n( 8'h26, 8'h69 );		//	LD H, 69h
		//            code   n     ref B  ref C  ref D  ref E  ref H  ref L  ref A  ref F  rf ixh rf ixl rf iyh rf iyl
		test_bit_b_r( 8'hC5, 3'd0, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h25, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	set 0, l
		test_bit_b_r( 8'hC5, 3'd1, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h27, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	set 1, l
		test_bit_b_r( 8'hC5, 3'd2, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h27, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	set 2, l
		test_bit_b_r( 8'hC5, 3'd3, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h2F, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	set 3, l
		test_bit_b_r( 8'hC5, 3'd4, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h3F, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	set 4, l
		test_bit_b_r( 8'hC5, 3'd5, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h3F, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	set 5, l
		test_bit_b_r( 8'hC5, 3'd6, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h7F, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	set 6, l
		test_bit_b_r( 8'hC5, 3'd7, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'hFF, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	set 7, l
		run_ld_r_n( 8'h2E, 8'h24 );		//	LD L, 24h
		//             code   n     data   ref d  ref addr  ref B  ref C  ref D  ref E  ref H  ref L  ref A  ref F  rf ixh rf ixl rf iyh rf iyl
		test_res_b_hl( 8'hC6, 3'd0, 8'h96, 8'h97, 16'h6924, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	set 0, (hl)
		test_res_b_hl( 8'hC6, 3'd1, 8'h96, 8'h96, 16'h6924, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	set 1, (hl)
		test_res_b_hl( 8'hC6, 3'd2, 8'h96, 8'h96, 16'h6924, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	set 2, (hl)
		test_res_b_hl( 8'hC6, 3'd3, 8'h96, 8'h9E, 16'h6924, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	set 3, (hl)
		test_res_b_hl( 8'hC6, 3'd4, 8'h96, 8'h96, 16'h6924, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	set 4, (hl)
		test_res_b_hl( 8'hC6, 3'd5, 8'h96, 8'hB6, 16'h6924, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	set 5, (hl)
		test_res_b_hl( 8'hC6, 3'd6, 8'h96, 8'hD6, 16'h6924, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	set 6, (hl)
		test_res_b_hl( 8'hC6, 3'd7, 8'h96, 8'h96, 16'h6924, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	set 7, (hl)
		//            code   n     ref B  ref C  ref D  ref E  ref H  ref L  ref A  ref F  rf ixh rf ixl rf iyh rf iyl
		test_bit_b_r( 8'hC7, 3'd0, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h97, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	set 0, a
		test_bit_b_r( 8'hC7, 3'd1, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h97, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	set 1, a
		test_bit_b_r( 8'hC7, 3'd2, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h97, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	set 2, a
		test_bit_b_r( 8'hC7, 3'd3, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h9F, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	set 3, a
		test_bit_b_r( 8'hC7, 3'd4, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h9F, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	set 4, a
		test_bit_b_r( 8'hC7, 3'd5, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'hBF, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	set 5, a
		test_bit_b_r( 8'hC7, 3'd6, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'hFF, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	set 6, a
		test_bit_b_r( 8'hC7, 3'd7, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'hFF, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	set 7, a
		run_ld_r_n( 8'h3E, 8'h96 );		//	LD A, 96h
		//             prefix code   n     d      data   ref d  ref addr  ref B  ref C  ref D  ref E  ref H  ref L  ref A  ref F  rf ixh rf ixl rf iyh rf iyl
		test_res_b_xy( 8'hDD, 8'hC6, 3'd0, 8'h00, 8'h96, 8'h97, 16'h1357, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	set 0, (ix + 00h)
		test_res_b_xy( 8'hDD, 8'hC6, 3'd1, 8'h7F, 8'h96, 8'h96, 16'h13D6, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	set 1, (ix + 7Fh)
		test_res_b_xy( 8'hDD, 8'hC6, 3'd2, 8'h80, 8'h96, 8'h96, 16'h12D7, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	set 2, (ix + 80h)
		test_res_b_xy( 8'hDD, 8'hC6, 3'd3, 8'hC0, 8'h96, 8'h9E, 16'h1317, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	set 3, (ix + C0h)
		test_res_b_xy( 8'hDD, 8'hC6, 3'd4, 8'h40, 8'h96, 8'h96, 16'h1397, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	set 4, (ix + 40h)
		test_res_b_xy( 8'hDD, 8'hC6, 3'd5, 8'h57, 8'h96, 8'hB6, 16'h13AE, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	set 5, (ix + 57h)
		test_res_b_xy( 8'hDD, 8'hC6, 3'd6, 8'hAB, 8'h96, 8'hD6, 16'h1302, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	set 6, (ix + ABh)
		test_res_b_xy( 8'hDD, 8'hC6, 3'd7, 8'h12, 8'h96, 8'h96, 16'h1369, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	set 7, (ix + 12h)
		//             prefix code   n     d      data   ref d  ref addr  ref B  ref C  ref D  ref E  ref H  ref L  ref A  ref F  rf ixh rf ixl rf iyh rf iyl
		test_res_b_xy( 8'hFD, 8'hC6, 3'd0, 8'h00, 8'h96, 8'h97, 16'h7531, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	set 0, (iy + 00h)
		test_res_b_xy( 8'hFD, 8'hC6, 3'd1, 8'h7F, 8'h96, 8'h96, 16'h75B0, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	set 1, (iy + 7Fh)
		test_res_b_xy( 8'hFD, 8'hC6, 3'd2, 8'h80, 8'h96, 8'h96, 16'h74B1, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	set 2, (iy + 80h)
		test_res_b_xy( 8'hFD, 8'hC6, 3'd3, 8'hC0, 8'h96, 8'h9E, 16'h74F1, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	set 3, (iy + C0h)
		test_res_b_xy( 8'hFD, 8'hC6, 3'd4, 8'h40, 8'h96, 8'h96, 16'h7571, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	set 4, (iy + 40h)
		test_res_b_xy( 8'hFD, 8'hC6, 3'd5, 8'h57, 8'h96, 8'hB6, 16'h7588, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	set 5, (iy + 57h)
		test_res_b_xy( 8'hFD, 8'hC6, 3'd6, 8'hAB, 8'h96, 8'hD6, 16'h74DC, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	set 6, (iy + ABh)
		test_res_b_xy( 8'hFD, 8'hC6, 3'd7, 8'h12, 8'h96, 8'h96, 16'h7543, 8'hA5, 8'hC3, 8'h5A, 8'h3C, 8'h69, 8'h24, 8'h96, 8'h90, 8'h13, 8'h57, 8'h75, 8'h31 );	//	set 7, (iy + 12h)

		$finish;
	end
endmodule
