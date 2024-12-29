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
	task test_ld_r_n(
		input	[7:0]	opecode,
		input	[7:0]	data,
		input	[7:0]	ref_b,
		input	[7:0]	ref_c,
		input	[7:0]	ref_d,
		input	[7:0]	ref_e,
		input	[7:0]	ref_h,
		input	[7:0]	ref_l,
		input	[7:0]	ref_a,
		input	[7:0]	ref_f
	);
		logic	[7:0]	rdata;

		$display( "CODE %02X, %02X    : LD  %s, %02Xh", opecode, data, reg8_sel( opecode[5:3] ), data );

		//	2bytes の命令コードを送る 
		send_byte( opecode );
		send_byte( data );

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
	endtask: test_ld_r_n

	// --------------------------------------------------------------------
	task test_ld_r_r(
		input	[7:0]	opecode,
		input	[7:0]	ref_b,
		input	[7:0]	ref_c,
		input	[7:0]	ref_d,
		input	[7:0]	ref_e,
		input	[7:0]	ref_h,
		input	[7:0]	ref_l,
		input	[7:0]	ref_a,
		input	[7:0]	ref_f
	);
		logic	[7:0]	rdata;

		$display( "CODE %02X            : LD  %s, %s", opecode, reg8_sel( opecode[5:3] ), reg8_sel( opecode[2:0] ) );

		//	1byte の命令コードを送る 
		send_byte( opecode );

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
	endtask: test_ld_r_r

	// --------------------------------------------------------------------
	task test_ld_rr_nn(
		input	[7:0]	opecode,
		input	[15:0]	data,
		input	[7:0]	ref_b,
		input	[7:0]	ref_c,
		input	[7:0]	ref_d,
		input	[7:0]	ref_e,
		input	[7:0]	ref_h,
		input	[7:0]	ref_l,
		input	[7:0]	ref_a,
		input	[7:0]	ref_f
	);
		logic	[7:0]	rdata;

		$display( "CODE %02X, %02X, %02X    : LD  %s, %04Xh", opecode, data[7:0], data[15:8], reg16_sel( opecode[5:4] ), data );

		//	3bytes の命令コードを送る 
		send_byte( opecode );
		send_byte( data[7:0] );
		send_byte( data[15:8] );

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
	endtask: test_ld_rr_nn

	// --------------------------------------------------------------------
	task test_ld_xy_nn(
		input	[7:0]	prefix,
		input	[7:0]	opecode,
		input	[15:0]	data,
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

		$display( "CODE %02X, %02X, %02X, %02X: LD  %s, %04Xh", prefix, opecode, data[7:0], data[15:8], regxy_sel( prefix[5] ), data );

		//	4bytes の命令コードを送る 
		send_byte( prefix );
		send_byte( opecode );
		send_byte( data[7:0] );
		send_byte( data[15:8] );

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
	endtask: test_ld_xy_nn

	// --------------------------------------------------------------------
	task test_ld_hl_n(
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
		logic	[15:0]	raddress;
		logic	[7:0]	rdata;

		$display( "CODE 36, %02X        : LD  (HL), %02Xh", data, data );

		//	2bytes の命令コードを送る 
		send_byte( 8'h36 );
		send_byte( data );
		receive_byte_a( rdata, raddress );
		assert( rdata === data );
		assert( raddress === address );

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
	endtask: test_ld_hl_n

	// --------------------------------------------------------------------
	task test_ld_xy_n(
		input	[7:0]	prefix,
		input	[7:0]	d,
		input	[15:0]	address,
		input	[7:0]	n,
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
		logic	[15:0]	raddress;
		logic	[7:0]	rdata;

		$display( "CODE %02X, 36, %02X, %02X: LD  (%s + %02Xh), %02Xh", prefix, d, n, regxy_sel( prefix[5] ), d, n );

		//	2bytes の命令コードを送る 
		send_byte( prefix );
		send_byte( 8'h36 );
		send_byte( d );
		send_byte( n );
		receive_byte_a( rdata, raddress );
		assert( rdata === n );
		assert( raddress === address );

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
	endtask: test_ld_xy_n

	// --------------------------------------------------------------------
	task test_ld_hl_r(
		input	[7:0]	opecode,
		input	[15:0]	address,
		input	[7:0]	data,
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
		logic	[15:0]	raddress;
		logic	[7:0]	rdata;

		$display( "CODE %02X            : LD  (HL), %s", opecode, reg8_sel( opecode[2:0] ) );

		//	1byte の命令コードを送る 
		send_byte( opecode );
		receive_byte_a( rdata, raddress );
		assert( rdata === data );
		assert( raddress === address );

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
	endtask: test_ld_hl_r

	// --------------------------------------------------------------------
	task test_ld_xy_r(
		input	[7:0]	prefix,
		input	[7:0]	opecode,
		input	[7:0]	d,
		input	[15:0]	address,
		input	[7:0]	n,
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
		logic	[15:0]	raddress;
		logic	[7:0]	rdata;

		$display( "CODE %02X, %02X, %02X    : LD  (%s + %02Xh), %s", prefix, opecode, d, regxy_sel( prefix[5] ), d, reg8_sel( opecode[2:0] ) );

		//	3bytes の命令コードを送る 
		send_byte( prefix );
		send_byte( opecode );
		send_byte( d );
		receive_byte_a( rdata, raddress );
		assert( rdata === n );
		assert( raddress === address );

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
	endtask: test_ld_xy_r

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
		//	LD		r, n
		// --------------------------------------------------------------------
		//            code   data  ref B  ref C  ref D  ref E  ref H  ref L  ref A  ref F
		test_ld_r_n( 8'h06, 8'h12, 8'h12, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF );	//	LD B, 12h
		test_ld_r_n( 8'h0E, 8'h23, 8'h12, 8'h23, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF );	//	LD C, 23h
		test_ld_r_n( 8'h16, 8'h34, 8'h12, 8'h23, 8'h34, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF );	//	LD D, 34h
		test_ld_r_n( 8'h1E, 8'h45, 8'h12, 8'h23, 8'h34, 8'h45, 8'h00, 8'h00, 8'hFF, 8'hFF );	//	LD E, 45h
		test_ld_r_n( 8'h26, 8'h56, 8'h12, 8'h23, 8'h34, 8'h45, 8'h56, 8'h00, 8'hFF, 8'hFF );	//	LD H, 56h
		test_ld_r_n( 8'h2E, 8'h67, 8'h12, 8'h23, 8'h34, 8'h45, 8'h56, 8'h67, 8'hFF, 8'hFF );	//	LD L, 67h
		test_ld_r_n( 8'h3E, 8'h78, 8'h12, 8'h23, 8'h34, 8'h45, 8'h56, 8'h67, 8'h78, 8'hFF );	//	LD A, 78h

		// --------------------------------------------------------------------
		//	LD		B, r'
		// --------------------------------------------------------------------
		//            code  ref B  ref C  ref D  ref E  ref H  ref L  ref A  ref F
		test_ld_r_r( 8'h40, 8'h12, 8'h23, 8'h34, 8'h45, 8'h56, 8'h67, 8'h78, 8'hFF );			//	LD B, B
		test_ld_r_r( 8'h41, 8'h23, 8'h23, 8'h34, 8'h45, 8'h56, 8'h67, 8'h78, 8'hFF );			//	LD B, C
		test_ld_r_r( 8'h42, 8'h34, 8'h23, 8'h34, 8'h45, 8'h56, 8'h67, 8'h78, 8'hFF );			//	LD B, D
		test_ld_r_r( 8'h43, 8'h45, 8'h23, 8'h34, 8'h45, 8'h56, 8'h67, 8'h78, 8'hFF );			//	LD B, E
		test_ld_r_r( 8'h44, 8'h56, 8'h23, 8'h34, 8'h45, 8'h56, 8'h67, 8'h78, 8'hFF );			//	LD B, H
		test_ld_r_r( 8'h45, 8'h67, 8'h23, 8'h34, 8'h45, 8'h56, 8'h67, 8'h78, 8'hFF );			//	LD B, L
		test_ld_r_r( 8'h47, 8'h78, 8'h23, 8'h34, 8'h45, 8'h56, 8'h67, 8'h78, 8'hFF );			//	LD B, A

		// --------------------------------------------------------------------
		//	LD		B, n
		// --------------------------------------------------------------------
		//            code   data  ref B  ref C  ref D  ref E  ref H  ref L  ref A  ref F
		test_ld_r_n( 8'h06, 8'h12, 8'h12, 8'h23, 8'h34, 8'h45, 8'h56, 8'h67, 8'h78, 8'hFF );	//	LD B, 12h

		// --------------------------------------------------------------------
		//	LD		C, r'
		// --------------------------------------------------------------------
		//            code  ref B  ref C  ref D  ref E  ref H  ref L  ref A  ref F
		test_ld_r_r( 8'h48, 8'h12, 8'h12, 8'h34, 8'h45, 8'h56, 8'h67, 8'h78, 8'hFF );			//	LD C, B
		test_ld_r_r( 8'h49, 8'h12, 8'h12, 8'h34, 8'h45, 8'h56, 8'h67, 8'h78, 8'hFF );			//	LD C, C
		test_ld_r_r( 8'h4A, 8'h12, 8'h34, 8'h34, 8'h45, 8'h56, 8'h67, 8'h78, 8'hFF );			//	LD C, D
		test_ld_r_r( 8'h4B, 8'h12, 8'h45, 8'h34, 8'h45, 8'h56, 8'h67, 8'h78, 8'hFF );			//	LD C, E
		test_ld_r_r( 8'h4C, 8'h12, 8'h56, 8'h34, 8'h45, 8'h56, 8'h67, 8'h78, 8'hFF );			//	LD C, H
		test_ld_r_r( 8'h4D, 8'h12, 8'h67, 8'h34, 8'h45, 8'h56, 8'h67, 8'h78, 8'hFF );			//	LD C, L
		test_ld_r_r( 8'h4F, 8'h12, 8'h78, 8'h34, 8'h45, 8'h56, 8'h67, 8'h78, 8'hFF );			//	LD C, A

		// --------------------------------------------------------------------
		//	LD		C, n
		// --------------------------------------------------------------------
		//            code   data  ref B  ref C  ref D  ref E  ref H  ref L  ref A  ref F
		test_ld_r_n( 8'h0E, 8'h23, 8'h12, 8'h23, 8'h34, 8'h45, 8'h56, 8'h67, 8'h78, 8'hFF );	//	LD C, 23h

		// --------------------------------------------------------------------
		//	LD		D, r'
		// --------------------------------------------------------------------
		//            code  ref B  ref C  ref D  ref E  ref H  ref L  ref A  ref F
		test_ld_r_r( 8'h50, 8'h12, 8'h23, 8'h12, 8'h45, 8'h56, 8'h67, 8'h78, 8'hFF );			//	LD D, B
		test_ld_r_r( 8'h51, 8'h12, 8'h23, 8'h23, 8'h45, 8'h56, 8'h67, 8'h78, 8'hFF );			//	LD D, C
		test_ld_r_r( 8'h52, 8'h12, 8'h23, 8'h23, 8'h45, 8'h56, 8'h67, 8'h78, 8'hFF );			//	LD D, D
		test_ld_r_r( 8'h53, 8'h12, 8'h23, 8'h45, 8'h45, 8'h56, 8'h67, 8'h78, 8'hFF );			//	LD D, E
		test_ld_r_r( 8'h54, 8'h12, 8'h23, 8'h56, 8'h45, 8'h56, 8'h67, 8'h78, 8'hFF );			//	LD D, H
		test_ld_r_r( 8'h55, 8'h12, 8'h23, 8'h67, 8'h45, 8'h56, 8'h67, 8'h78, 8'hFF );			//	LD D, L
		test_ld_r_r( 8'h57, 8'h12, 8'h23, 8'h78, 8'h45, 8'h56, 8'h67, 8'h78, 8'hFF );			//	LD D, A

		// --------------------------------------------------------------------
		//	LD		D, n
		// --------------------------------------------------------------------
		//            code   data  ref B  ref C  ref D  ref E  ref H  ref L  ref A  ref F
		test_ld_r_n( 8'h16, 8'h34, 8'h12, 8'h23, 8'h34, 8'h45, 8'h56, 8'h67, 8'h78, 8'hFF );	//	LD D, 34h

		// --------------------------------------------------------------------
		//	LD		E, r'
		// --------------------------------------------------------------------
		//            code  ref B  ref C  ref D  ref E  ref H  ref L  ref A  ref F
		test_ld_r_r( 8'h58, 8'h12, 8'h23, 8'h34, 8'h12, 8'h56, 8'h67, 8'h78, 8'hFF );			//	LD E, B
		test_ld_r_r( 8'h59, 8'h12, 8'h23, 8'h34, 8'h23, 8'h56, 8'h67, 8'h78, 8'hFF );			//	LD E, C
		test_ld_r_r( 8'h5A, 8'h12, 8'h23, 8'h34, 8'h34, 8'h56, 8'h67, 8'h78, 8'hFF );			//	LD E, D
		test_ld_r_r( 8'h5B, 8'h12, 8'h23, 8'h34, 8'h34, 8'h56, 8'h67, 8'h78, 8'hFF );			//	LD E, E
		test_ld_r_r( 8'h5C, 8'h12, 8'h23, 8'h34, 8'h56, 8'h56, 8'h67, 8'h78, 8'hFF );			//	LD E, H
		test_ld_r_r( 8'h5D, 8'h12, 8'h23, 8'h34, 8'h67, 8'h56, 8'h67, 8'h78, 8'hFF );			//	LD E, L
		test_ld_r_r( 8'h5F, 8'h12, 8'h23, 8'h34, 8'h78, 8'h56, 8'h67, 8'h78, 8'hFF );			//	LD E, A

		// --------------------------------------------------------------------
		//	LD		E, n
		// --------------------------------------------------------------------
		//            code   data  ref B  ref C  ref D  ref E  ref H  ref L  ref A  ref F
		test_ld_r_n( 8'h1E, 8'h45, 8'h12, 8'h23, 8'h34, 8'h45, 8'h56, 8'h67, 8'h78, 8'hFF );	//	LD E, 45h

		// --------------------------------------------------------------------
		//	LD		H, r'
		// --------------------------------------------------------------------
		//            code  ref B  ref C  ref D  ref E  ref H  ref L  ref A  ref F
		test_ld_r_r( 8'h60, 8'h12, 8'h23, 8'h34, 8'h45, 8'h12, 8'h67, 8'h78, 8'hFF );			//	LD H, B
		test_ld_r_r( 8'h61, 8'h12, 8'h23, 8'h34, 8'h45, 8'h23, 8'h67, 8'h78, 8'hFF );			//	LD H, C
		test_ld_r_r( 8'h62, 8'h12, 8'h23, 8'h34, 8'h45, 8'h34, 8'h67, 8'h78, 8'hFF );			//	LD H, D
		test_ld_r_r( 8'h63, 8'h12, 8'h23, 8'h34, 8'h45, 8'h45, 8'h67, 8'h78, 8'hFF );			//	LD H, E
		test_ld_r_r( 8'h64, 8'h12, 8'h23, 8'h34, 8'h45, 8'h45, 8'h67, 8'h78, 8'hFF );			//	LD H, H
		test_ld_r_r( 8'h65, 8'h12, 8'h23, 8'h34, 8'h45, 8'h67, 8'h67, 8'h78, 8'hFF );			//	LD H, L
		test_ld_r_r( 8'h67, 8'h12, 8'h23, 8'h34, 8'h45, 8'h78, 8'h67, 8'h78, 8'hFF );			//	LD H, A

		// --------------------------------------------------------------------
		//	LD		H, n
		// --------------------------------------------------------------------
		//            code   data  ref B  ref C  ref D  ref E  ref H  ref L  ref A  ref F
		test_ld_r_n( 8'h26, 8'h56, 8'h12, 8'h23, 8'h34, 8'h45, 8'h56, 8'h67, 8'h78, 8'hFF );	//	LD H, 56h

		// --------------------------------------------------------------------
		//	LD		L, r'
		// --------------------------------------------------------------------
		//            code  ref B  ref C  ref D  ref E  ref H  ref L  ref A  ref F
		test_ld_r_r( 8'h68, 8'h12, 8'h23, 8'h34, 8'h45, 8'h56, 8'h12, 8'h78, 8'hFF );			//	LD L, B
		test_ld_r_r( 8'h69, 8'h12, 8'h23, 8'h34, 8'h45, 8'h56, 8'h23, 8'h78, 8'hFF );			//	LD L, C
		test_ld_r_r( 8'h6A, 8'h12, 8'h23, 8'h34, 8'h45, 8'h56, 8'h34, 8'h78, 8'hFF );			//	LD L, D
		test_ld_r_r( 8'h6B, 8'h12, 8'h23, 8'h34, 8'h45, 8'h56, 8'h45, 8'h78, 8'hFF );			//	LD L, E
		test_ld_r_r( 8'h6C, 8'h12, 8'h23, 8'h34, 8'h45, 8'h56, 8'h56, 8'h78, 8'hFF );			//	LD L, H
		test_ld_r_r( 8'h6D, 8'h12, 8'h23, 8'h34, 8'h45, 8'h56, 8'h56, 8'h78, 8'hFF );			//	LD L, L
		test_ld_r_r( 8'h6F, 8'h12, 8'h23, 8'h34, 8'h45, 8'h56, 8'h78, 8'h78, 8'hFF );			//	LD L, A

		// --------------------------------------------------------------------
		//	LD		L, n
		// --------------------------------------------------------------------
		//            code   data  ref B  ref C  ref D  ref E  ref H  ref L  ref A  ref F
		test_ld_r_n( 8'h2E, 8'h67, 8'h12, 8'h23, 8'h34, 8'h45, 8'h56, 8'h67, 8'h78, 8'hFF );	//	LD L, 67h

		// --------------------------------------------------------------------
		//	LD		A, r'
		// --------------------------------------------------------------------
		//            code  ref B  ref C  ref D  ref E  ref H  ref L  ref A  ref F
		test_ld_r_r( 8'h78, 8'h12, 8'h23, 8'h34, 8'h45, 8'h56, 8'h67, 8'h12, 8'hFF );			//	LD A, B
		test_ld_r_r( 8'h79, 8'h12, 8'h23, 8'h34, 8'h45, 8'h56, 8'h67, 8'h23, 8'hFF );			//	LD A, C
		test_ld_r_r( 8'h7A, 8'h12, 8'h23, 8'h34, 8'h45, 8'h56, 8'h67, 8'h34, 8'hFF );			//	LD A, D
		test_ld_r_r( 8'h7B, 8'h12, 8'h23, 8'h34, 8'h45, 8'h56, 8'h67, 8'h45, 8'hFF );			//	LD A, E
		test_ld_r_r( 8'h7C, 8'h12, 8'h23, 8'h34, 8'h45, 8'h56, 8'h67, 8'h56, 8'hFF );			//	LD A, H
		test_ld_r_r( 8'h7D, 8'h12, 8'h23, 8'h34, 8'h45, 8'h56, 8'h67, 8'h67, 8'hFF );			//	LD A, L
		test_ld_r_r( 8'h7F, 8'h12, 8'h23, 8'h34, 8'h45, 8'h56, 8'h67, 8'h67, 8'hFF );			//	LD A, A

		// --------------------------------------------------------------------
		//	LD		A, n
		// --------------------------------------------------------------------
		//            code   data  ref B  ref C  ref D  ref E  ref H  ref L  ref A  ref F
		test_ld_r_n( 8'h3E, 8'h78, 8'h12, 8'h23, 8'h34, 8'h45, 8'h56, 8'h67, 8'h78, 8'hFF );	//	LD A, 78h

		// --------------------------------------------------------------------
		//	LD		rr, nn
		// --------------------------------------------------------------------
		//              code            ref B  ref C  ref D  ref E  ref H  ref L  ref A  ref F
		test_ld_rr_nn( 8'h01, 16'h899A, 8'h89, 8'h9A, 8'h34, 8'h45, 8'h56, 8'h67, 8'h78, 8'hFF );	//	LD BC, 988Ah
		test_ld_rr_nn( 8'h11, 16'hABBC, 8'h89, 8'h9A, 8'hAB, 8'hBC, 8'h56, 8'h67, 8'h78, 8'hFF );	//	LD DE, ABBCh
		test_ld_rr_nn( 8'h21, 16'hCDDE, 8'h89, 8'h9A, 8'hAB, 8'hBC, 8'hCD, 8'hDE, 8'h78, 8'hFF );	//	LD HL, CDDEh

		// --------------------------------------------------------------------
		//	LD		xy, nn
		// --------------------------------------------------------------------
		//              code                   ref B  ref C  ref D  ref E  ref H  ref L  ref A  ref F rf IXH rf IXL rf IYH rf IYL
		test_ld_xy_nn( 8'hDD, 8'h21, 16'hEFF0, 8'h89, 8'h9A, 8'hAB, 8'hBC, 8'hCD, 8'hDE, 8'h78, 8'hFF, 8'hEF, 8'hF0, 8'h00, 8'h00 );	//	LD IX, EFF0h
		test_ld_xy_nn( 8'hFD, 8'h21, 16'h0112, 8'h89, 8'h9A, 8'hAB, 8'hBC, 8'hCD, 8'hDE, 8'h78, 8'hFF, 8'hEF, 8'hF0, 8'h01, 8'h12 );	//	LD IY, 0112h

		// --------------------------------------------------------------------
		//	LD		(hl), n
		// --------------------------------------------------------------------
		//             data   ref addr  ref B  ref C  ref D  ref E  ref H  ref L  ref A  ref F rf IXH rf IXL rf IYH rf IYL
		test_ld_rr_nn( 8'h21, 16'h1234, 8'h89, 8'h9A, 8'hAB, 8'hBC, 8'h12, 8'h34, 8'h78, 8'hFF );								//	LD HL, 1234h
		test_ld_hl_n(  8'hAB, 16'h1234, 8'h89, 8'h9A, 8'hAB, 8'hBC, 8'h12, 8'h34, 8'h78, 8'hFF, 8'hEF, 8'hF0, 8'h01, 8'h12 );	//	LD (HL), ABh
		test_ld_rr_nn( 8'h21, 16'hFEDC, 8'h89, 8'h9A, 8'hAB, 8'hBC, 8'hFE, 8'hDC, 8'h78, 8'hFF );								//	LD HL, FEDCh
		test_ld_hl_n(  8'h53, 16'hFEDC, 8'h89, 8'h9A, 8'hAB, 8'hBC, 8'hFE, 8'hDC, 8'h78, 8'hFF, 8'hEF, 8'hF0, 8'h01, 8'h12 );	//	LD (HL), 53h

		// --------------------------------------------------------------------
		//	LD		(IX + d), n
		// --------------------------------------------------------------------
		//             prefix data  ref addr       n  ref B  ref C  ref D  ref E  ref H  ref L  ref A  ref F rf IXH rf IXL rf IYH rf IYL
		test_ld_xy_nn( 8'hDD, 8'h21, 16'h7654,        8'h89, 8'h9A, 8'hAB, 8'hBC, 8'hFE, 8'hDC, 8'h78, 8'hFF, 8'h76, 8'h54, 8'h01, 8'h12 );		//	LD IX, 7654h
		test_ld_xy_nn( 8'hFD, 8'h21, 16'h3456,        8'h89, 8'h9A, 8'hAB, 8'hBC, 8'hFE, 8'hDC, 8'h78, 8'hFF, 8'h76, 8'h54, 8'h34, 8'h56 );		//	LD IY, 3456h
		test_ld_xy_n(  8'hDD, 8'h00, 16'h7654, 8'h53, 8'h89, 8'h9A, 8'hAB, 8'hBC, 8'hFE, 8'hDC, 8'h78, 8'hFF, 8'h76, 8'h54, 8'h34, 8'h56 );		//	LD (IX+00h), 53h
		test_ld_xy_n(  8'hDD, 8'h09, 16'h765D, 8'hA2, 8'h89, 8'h9A, 8'hAB, 8'hBC, 8'hFE, 8'hDC, 8'h78, 8'hFF, 8'h76, 8'h54, 8'h34, 8'h56 );		//	LD (IX+09h), A2h
		test_ld_xy_n(  8'hDD, 8'h7F, 16'h76D3, 8'hBE, 8'h89, 8'h9A, 8'hAB, 8'hBC, 8'hFE, 8'hDC, 8'h78, 8'hFF, 8'h76, 8'h54, 8'h34, 8'h56 );		//	LD (IX+7Fh), BEh
		test_ld_xy_n(  8'hDD, 8'h80, 16'h75D4, 8'h93, 8'h89, 8'h9A, 8'hAB, 8'hBC, 8'hFE, 8'hDC, 8'h78, 8'hFF, 8'h76, 8'h54, 8'h34, 8'h56 );		//	LD (IX-80h), 93h
		test_ld_xy_n(  8'hFD, 8'h00, 16'h3456, 8'h53, 8'h89, 8'h9A, 8'hAB, 8'hBC, 8'hFE, 8'hDC, 8'h78, 8'hFF, 8'h76, 8'h54, 8'h34, 8'h56 );		//	LD (IY+00h), 53h
		test_ld_xy_n(  8'hFD, 8'h09, 16'h345F, 8'hA2, 8'h89, 8'h9A, 8'hAB, 8'hBC, 8'hFE, 8'hDC, 8'h78, 8'hFF, 8'h76, 8'h54, 8'h34, 8'h56 );		//	LD (IY+09h), A2h
		test_ld_xy_n(  8'hFD, 8'h7F, 16'h34D5, 8'hBE, 8'h89, 8'h9A, 8'hAB, 8'hBC, 8'hFE, 8'hDC, 8'h78, 8'hFF, 8'h76, 8'h54, 8'h34, 8'h56 );		//	LD (IY+7Fh), BEh
		test_ld_xy_n(  8'hFD, 8'h80, 16'h33D6, 8'h93, 8'h89, 8'h9A, 8'hAB, 8'hBC, 8'hFE, 8'hDC, 8'h78, 8'hFF, 8'h76, 8'h54, 8'h34, 8'h56 );		//	LD (IY-80h), 93h

		test_ld_rr_nn(        8'h21, 16'hCDDE,        8'h89, 8'h9A, 8'hAB, 8'hBC, 8'hCD, 8'hDE, 8'h78, 8'hFF );								//	LD HL, FEDCh
		test_ld_xy_nn( 8'hDD, 8'h21, 16'hEFF0,        8'h89, 8'h9A, 8'hAB, 8'hBC, 8'hCD, 8'hDE, 8'h78, 8'hFF, 8'hEF, 8'hF0, 8'h34, 8'h56 );	//	LD IX, EFF0h
		test_ld_xy_nn( 8'hFD, 8'h21, 16'h0112,        8'h89, 8'h9A, 8'hAB, 8'hBC, 8'hCD, 8'hDE, 8'h78, 8'hFF, 8'hEF, 8'hF0, 8'h01, 8'h12 );	//	LD IY, 0112h

		// --------------------------------------------------------------------
		//	LD		(hl), r
		// --------------------------------------------------------------------
		//            code   address   r      ref B  ref C  ref D  ref E  ref H  ref L  ref A  ref F rf IXH rf IXL rf IYH rf IYL
		test_ld_hl_r( 8'h70, 16'hCDDE, 8'h89, 8'h89, 8'h9A, 8'hAB, 8'hBC, 8'hCD, 8'hDE, 8'h78, 8'hFF, 8'hEF, 8'hF0, 8'h01, 8'h12 );		//	LD (HL), B
		test_ld_hl_r( 8'h71, 16'hCDDE, 8'h9A, 8'h89, 8'h9A, 8'hAB, 8'hBC, 8'hCD, 8'hDE, 8'h78, 8'hFF, 8'hEF, 8'hF0, 8'h01, 8'h12 );		//	LD (HL), C
		test_ld_hl_r( 8'h72, 16'hCDDE, 8'hAB, 8'h89, 8'h9A, 8'hAB, 8'hBC, 8'hCD, 8'hDE, 8'h78, 8'hFF, 8'hEF, 8'hF0, 8'h01, 8'h12 );		//	LD (HL), D
		test_ld_hl_r( 8'h73, 16'hCDDE, 8'hBC, 8'h89, 8'h9A, 8'hAB, 8'hBC, 8'hCD, 8'hDE, 8'h78, 8'hFF, 8'hEF, 8'hF0, 8'h01, 8'h12 );		//	LD (HL), E
		test_ld_hl_r( 8'h74, 16'hCDDE, 8'hCD, 8'h89, 8'h9A, 8'hAB, 8'hBC, 8'hCD, 8'hDE, 8'h78, 8'hFF, 8'hEF, 8'hF0, 8'h01, 8'h12 );		//	LD (HL), H
		test_ld_hl_r( 8'h75, 16'hCDDE, 8'hDE, 8'h89, 8'h9A, 8'hAB, 8'hBC, 8'hCD, 8'hDE, 8'h78, 8'hFF, 8'hEF, 8'hF0, 8'h01, 8'h12 );		//	LD (HL), L
		test_ld_hl_r( 8'h77, 16'hCDDE, 8'h78, 8'h89, 8'h9A, 8'hAB, 8'hBC, 8'hCD, 8'hDE, 8'h78, 8'hFF, 8'hEF, 8'hF0, 8'h01, 8'h12 );		//	LD (HL), A

		// --------------------------------------------------------------------
		//	LD		(ix + d), r
		// --------------------------------------------------------------------
		//            prefix code   d      address   r      ref B  ref C  ref D  ref E  ref H  ref L  ref A  ref F rf IXH rf IXL rf IYH rf IYL
		test_ld_xy_r( 8'hDD, 8'h70, 8'h00, 16'hEFF0, 8'h89, 8'h89, 8'h9A, 8'hAB, 8'hBC, 8'hCD, 8'hDE, 8'h78, 8'hFF, 8'hEF, 8'hF0, 8'h01, 8'h12 );		//	LD (IX+00h), B
		test_ld_xy_r( 8'hDD, 8'h71, 8'h7F, 16'hF06F, 8'h9A, 8'h89, 8'h9A, 8'hAB, 8'hBC, 8'hCD, 8'hDE, 8'h78, 8'hFF, 8'hEF, 8'hF0, 8'h01, 8'h12 );		//	LD (IX+7Fh), C
		test_ld_xy_r( 8'hDD, 8'h72, 8'h80, 16'hEF70, 8'hAB, 8'h89, 8'h9A, 8'hAB, 8'hBC, 8'hCD, 8'hDE, 8'h78, 8'hFF, 8'hEF, 8'hF0, 8'h01, 8'h12 );		//	LD (IX+80h), D
		test_ld_xy_r( 8'hDD, 8'h73, 8'h40, 16'hF030, 8'hBC, 8'h89, 8'h9A, 8'hAB, 8'hBC, 8'hCD, 8'hDE, 8'h78, 8'hFF, 8'hEF, 8'hF0, 8'h01, 8'h12 );		//	LD (IX+40h), E
		test_ld_xy_r( 8'hDD, 8'h74, 8'h15, 16'hF005, 8'hCD, 8'h89, 8'h9A, 8'hAB, 8'hBC, 8'hCD, 8'hDE, 8'h78, 8'hFF, 8'hEF, 8'hF0, 8'h01, 8'h12 );		//	LD (IX+15h), H
		test_ld_xy_r( 8'hDD, 8'h75, 8'h57, 16'hF047, 8'hDE, 8'h89, 8'h9A, 8'hAB, 8'hBC, 8'hCD, 8'hDE, 8'h78, 8'hFF, 8'hEF, 8'hF0, 8'h01, 8'h12 );		//	LD (IX+57h), L
		test_ld_xy_r( 8'hDD, 8'h77, 8'hC0, 16'hEFB0, 8'h78, 8'h89, 8'h9A, 8'hAB, 8'hBC, 8'hCD, 8'hDE, 8'h78, 8'hFF, 8'hEF, 8'hF0, 8'h01, 8'h12 );		//	LD (IX+C0h), A

		// --------------------------------------------------------------------
		//	LD		(iy + d), r
		// --------------------------------------------------------------------
		//            prefix code   d      address   r      ref B  ref C  ref D  ref E  ref H  ref L  ref A  ref F rf IXH rf IXL rf IYH rf IYL
		test_ld_xy_r( 8'hFD, 8'h70, 8'h00, 16'h0112, 8'h89, 8'h89, 8'h9A, 8'hAB, 8'hBC, 8'hCD, 8'hDE, 8'h78, 8'hFF, 8'hEF, 8'hF0, 8'h01, 8'h12 );		//	LD (IY+00h), B
		test_ld_xy_r( 8'hFD, 8'h71, 8'h7F, 16'h0191, 8'h9A, 8'h89, 8'h9A, 8'hAB, 8'hBC, 8'hCD, 8'hDE, 8'h78, 8'hFF, 8'hEF, 8'hF0, 8'h01, 8'h12 );		//	LD (IY+7Fh), C
		test_ld_xy_r( 8'hFD, 8'h72, 8'h80, 16'h0092, 8'hAB, 8'h89, 8'h9A, 8'hAB, 8'hBC, 8'hCD, 8'hDE, 8'h78, 8'hFF, 8'hEF, 8'hF0, 8'h01, 8'h12 );		//	LD (IY+80h), D
		test_ld_xy_r( 8'hFD, 8'h73, 8'h40, 16'h0152, 8'hBC, 8'h89, 8'h9A, 8'hAB, 8'hBC, 8'hCD, 8'hDE, 8'h78, 8'hFF, 8'hEF, 8'hF0, 8'h01, 8'h12 );		//	LD (IY+40h), E
		test_ld_xy_r( 8'hFD, 8'h74, 8'h15, 16'h0127, 8'hCD, 8'h89, 8'h9A, 8'hAB, 8'hBC, 8'hCD, 8'hDE, 8'h78, 8'hFF, 8'hEF, 8'hF0, 8'h01, 8'h12 );		//	LD (IY+15h), H
		test_ld_xy_r( 8'hFD, 8'h75, 8'h57, 16'h0169, 8'hDE, 8'h89, 8'h9A, 8'hAB, 8'hBC, 8'hCD, 8'hDE, 8'h78, 8'hFF, 8'hEF, 8'hF0, 8'h01, 8'h12 );		//	LD (IY+57h), L
		test_ld_xy_r( 8'hFD, 8'h77, 8'hC0, 16'h00D2, 8'h78, 8'h89, 8'h9A, 8'hAB, 8'hBC, 8'hCD, 8'hDE, 8'h78, 8'hFF, 8'hEF, 8'hF0, 8'h01, 8'h12 );		//	LD (IY+C0h), A

		// ================================================================================================================================
		//	フラグを書き替えないことを確認するために、もう一度同じことを確認する 
		// ================================================================================================================================

		// --------------------------------------------------------------------
		//	POP		AF を使って Fレジスタを 00h にする 
		// --------------------------------------------------------------------
		send_byte( 8'hF1 );
		send_byte( 8'h00 );
		send_byte( 8'h00 );

		// --------------------------------------------------------------------
		//	LD		r, n
		// --------------------------------------------------------------------
		//            code   data  ref B  ref C  ref D  ref E  ref H  ref L  ref A  ref F
		test_ld_r_n( 8'h06, 8'h12, 8'h12, 8'h9A, 8'hAB, 8'hBC, 8'hCD, 8'hDE, 8'h00, 8'h00 );	//	LD B, 12h
		test_ld_r_n( 8'h0E, 8'h23, 8'h12, 8'h23, 8'hAB, 8'hBC, 8'hCD, 8'hDE, 8'h00, 8'h00 );	//	LD C, 23h
		test_ld_r_n( 8'h16, 8'h34, 8'h12, 8'h23, 8'h34, 8'hBC, 8'hCD, 8'hDE, 8'h00, 8'h00 );	//	LD D, 34h
		test_ld_r_n( 8'h1E, 8'h45, 8'h12, 8'h23, 8'h34, 8'h45, 8'hCD, 8'hDE, 8'h00, 8'h00 );	//	LD E, 45h
		test_ld_r_n( 8'h26, 8'h56, 8'h12, 8'h23, 8'h34, 8'h45, 8'h56, 8'hDE, 8'h00, 8'h00 );	//	LD H, 56h
		test_ld_r_n( 8'h2E, 8'h67, 8'h12, 8'h23, 8'h34, 8'h45, 8'h56, 8'h67, 8'h00, 8'h00 );	//	LD L, 67h
		test_ld_r_n( 8'h3E, 8'h78, 8'h12, 8'h23, 8'h34, 8'h45, 8'h56, 8'h67, 8'h78, 8'h00 );	//	LD A, 78h

		// --------------------------------------------------------------------
		//	LD		B, r'
		// --------------------------------------------------------------------
		//            code  ref B  ref C  ref D  ref E  ref H  ref L  ref A  ref F
		test_ld_r_r( 8'h40, 8'h12, 8'h23, 8'h34, 8'h45, 8'h56, 8'h67, 8'h78, 8'h00 );			//	LD B, B
		test_ld_r_r( 8'h41, 8'h23, 8'h23, 8'h34, 8'h45, 8'h56, 8'h67, 8'h78, 8'h00 );			//	LD B, C
		test_ld_r_r( 8'h42, 8'h34, 8'h23, 8'h34, 8'h45, 8'h56, 8'h67, 8'h78, 8'h00 );			//	LD B, D
		test_ld_r_r( 8'h43, 8'h45, 8'h23, 8'h34, 8'h45, 8'h56, 8'h67, 8'h78, 8'h00 );			//	LD B, E
		test_ld_r_r( 8'h44, 8'h56, 8'h23, 8'h34, 8'h45, 8'h56, 8'h67, 8'h78, 8'h00 );			//	LD B, H
		test_ld_r_r( 8'h45, 8'h67, 8'h23, 8'h34, 8'h45, 8'h56, 8'h67, 8'h78, 8'h00 );			//	LD B, L
		test_ld_r_r( 8'h47, 8'h78, 8'h23, 8'h34, 8'h45, 8'h56, 8'h67, 8'h78, 8'h00 );			//	LD B, A

		// --------------------------------------------------------------------
		//	LD		B, n
		// --------------------------------------------------------------------
		//            code   data  ref B  ref C  ref D  ref E  ref H  ref L  ref A  ref F
		test_ld_r_n( 8'h06, 8'h12, 8'h12, 8'h23, 8'h34, 8'h45, 8'h56, 8'h67, 8'h78, 8'h00 );	//	LD B, 12h

		// --------------------------------------------------------------------
		//	LD		C, r'
		// --------------------------------------------------------------------
		//            code  ref B  ref C  ref D  ref E  ref H  ref L  ref A  ref F
		test_ld_r_r( 8'h48, 8'h12, 8'h12, 8'h34, 8'h45, 8'h56, 8'h67, 8'h78, 8'h00 );			//	LD C, B
		test_ld_r_r( 8'h49, 8'h12, 8'h12, 8'h34, 8'h45, 8'h56, 8'h67, 8'h78, 8'h00 );			//	LD C, C
		test_ld_r_r( 8'h4A, 8'h12, 8'h34, 8'h34, 8'h45, 8'h56, 8'h67, 8'h78, 8'h00 );			//	LD C, D
		test_ld_r_r( 8'h4B, 8'h12, 8'h45, 8'h34, 8'h45, 8'h56, 8'h67, 8'h78, 8'h00 );			//	LD C, E
		test_ld_r_r( 8'h4C, 8'h12, 8'h56, 8'h34, 8'h45, 8'h56, 8'h67, 8'h78, 8'h00 );			//	LD C, H
		test_ld_r_r( 8'h4D, 8'h12, 8'h67, 8'h34, 8'h45, 8'h56, 8'h67, 8'h78, 8'h00 );			//	LD C, L
		test_ld_r_r( 8'h4F, 8'h12, 8'h78, 8'h34, 8'h45, 8'h56, 8'h67, 8'h78, 8'h00 );			//	LD C, A

		// --------------------------------------------------------------------
		//	LD		C, n
		// --------------------------------------------------------------------
		//            code   data  ref B  ref C  ref D  ref E  ref H  ref L  ref A  ref F
		test_ld_r_n( 8'h0E, 8'h23, 8'h12, 8'h23, 8'h34, 8'h45, 8'h56, 8'h67, 8'h78, 8'h00 );	//	LD C, 23h

		// --------------------------------------------------------------------
		//	LD		D, r'
		// --------------------------------------------------------------------
		//            code  ref B  ref C  ref D  ref E  ref H  ref L  ref A  ref F
		test_ld_r_r( 8'h50, 8'h12, 8'h23, 8'h12, 8'h45, 8'h56, 8'h67, 8'h78, 8'h00 );			//	LD D, B
		test_ld_r_r( 8'h51, 8'h12, 8'h23, 8'h23, 8'h45, 8'h56, 8'h67, 8'h78, 8'h00 );			//	LD D, C
		test_ld_r_r( 8'h52, 8'h12, 8'h23, 8'h23, 8'h45, 8'h56, 8'h67, 8'h78, 8'h00 );			//	LD D, D
		test_ld_r_r( 8'h53, 8'h12, 8'h23, 8'h45, 8'h45, 8'h56, 8'h67, 8'h78, 8'h00 );			//	LD D, E
		test_ld_r_r( 8'h54, 8'h12, 8'h23, 8'h56, 8'h45, 8'h56, 8'h67, 8'h78, 8'h00 );			//	LD D, H
		test_ld_r_r( 8'h55, 8'h12, 8'h23, 8'h67, 8'h45, 8'h56, 8'h67, 8'h78, 8'h00 );			//	LD D, L
		test_ld_r_r( 8'h57, 8'h12, 8'h23, 8'h78, 8'h45, 8'h56, 8'h67, 8'h78, 8'h00 );			//	LD D, A

		// --------------------------------------------------------------------
		//	LD		D, n
		// --------------------------------------------------------------------
		//            code   data  ref B  ref C  ref D  ref E  ref H  ref L  ref A  ref F
		test_ld_r_n( 8'h16, 8'h34, 8'h12, 8'h23, 8'h34, 8'h45, 8'h56, 8'h67, 8'h78, 8'h00 );	//	LD D, 34h

		// --------------------------------------------------------------------
		//	LD		E, r'
		// --------------------------------------------------------------------
		//            code  ref B  ref C  ref D  ref E  ref H  ref L  ref A  ref F
		test_ld_r_r( 8'h58, 8'h12, 8'h23, 8'h34, 8'h12, 8'h56, 8'h67, 8'h78, 8'h00 );			//	LD E, B
		test_ld_r_r( 8'h59, 8'h12, 8'h23, 8'h34, 8'h23, 8'h56, 8'h67, 8'h78, 8'h00 );			//	LD E, C
		test_ld_r_r( 8'h5A, 8'h12, 8'h23, 8'h34, 8'h34, 8'h56, 8'h67, 8'h78, 8'h00 );			//	LD E, D
		test_ld_r_r( 8'h5B, 8'h12, 8'h23, 8'h34, 8'h34, 8'h56, 8'h67, 8'h78, 8'h00 );			//	LD E, E
		test_ld_r_r( 8'h5C, 8'h12, 8'h23, 8'h34, 8'h56, 8'h56, 8'h67, 8'h78, 8'h00 );			//	LD E, H
		test_ld_r_r( 8'h5D, 8'h12, 8'h23, 8'h34, 8'h67, 8'h56, 8'h67, 8'h78, 8'h00 );			//	LD E, L
		test_ld_r_r( 8'h5F, 8'h12, 8'h23, 8'h34, 8'h78, 8'h56, 8'h67, 8'h78, 8'h00 );			//	LD E, A

		// --------------------------------------------------------------------
		//	LD		E, n
		// --------------------------------------------------------------------
		//            code   data  ref B  ref C  ref D  ref E  ref H  ref L  ref A  ref F
		test_ld_r_n( 8'h1E, 8'h45, 8'h12, 8'h23, 8'h34, 8'h45, 8'h56, 8'h67, 8'h78, 8'h00 );	//	LD E, 45h

		// --------------------------------------------------------------------
		//	LD		H, r'
		// --------------------------------------------------------------------
		//            code  ref B  ref C  ref D  ref E  ref H  ref L  ref A  ref F
		test_ld_r_r( 8'h60, 8'h12, 8'h23, 8'h34, 8'h45, 8'h12, 8'h67, 8'h78, 8'h00 );			//	LD H, B
		test_ld_r_r( 8'h61, 8'h12, 8'h23, 8'h34, 8'h45, 8'h23, 8'h67, 8'h78, 8'h00 );			//	LD H, C
		test_ld_r_r( 8'h62, 8'h12, 8'h23, 8'h34, 8'h45, 8'h34, 8'h67, 8'h78, 8'h00 );			//	LD H, D
		test_ld_r_r( 8'h63, 8'h12, 8'h23, 8'h34, 8'h45, 8'h45, 8'h67, 8'h78, 8'h00 );			//	LD H, E
		test_ld_r_r( 8'h64, 8'h12, 8'h23, 8'h34, 8'h45, 8'h45, 8'h67, 8'h78, 8'h00 );			//	LD H, H
		test_ld_r_r( 8'h65, 8'h12, 8'h23, 8'h34, 8'h45, 8'h67, 8'h67, 8'h78, 8'h00 );			//	LD H, L
		test_ld_r_r( 8'h67, 8'h12, 8'h23, 8'h34, 8'h45, 8'h78, 8'h67, 8'h78, 8'h00 );			//	LD H, A

		// --------------------------------------------------------------------
		//	LD		H, n
		// --------------------------------------------------------------------
		//            code   data  ref B  ref C  ref D  ref E  ref H  ref L  ref A  ref F
		test_ld_r_n( 8'h26, 8'h56, 8'h12, 8'h23, 8'h34, 8'h45, 8'h56, 8'h67, 8'h78, 8'h00 );	//	LD H, 56h

		// --------------------------------------------------------------------
		//	LD		L, r'
		// --------------------------------------------------------------------
		//            code  ref B  ref C  ref D  ref E  ref H  ref L  ref A  ref F
		test_ld_r_r( 8'h68, 8'h12, 8'h23, 8'h34, 8'h45, 8'h56, 8'h12, 8'h78, 8'h00 );			//	LD L, B
		test_ld_r_r( 8'h69, 8'h12, 8'h23, 8'h34, 8'h45, 8'h56, 8'h23, 8'h78, 8'h00 );			//	LD L, C
		test_ld_r_r( 8'h6A, 8'h12, 8'h23, 8'h34, 8'h45, 8'h56, 8'h34, 8'h78, 8'h00 );			//	LD L, D
		test_ld_r_r( 8'h6B, 8'h12, 8'h23, 8'h34, 8'h45, 8'h56, 8'h45, 8'h78, 8'h00 );			//	LD L, E
		test_ld_r_r( 8'h6C, 8'h12, 8'h23, 8'h34, 8'h45, 8'h56, 8'h56, 8'h78, 8'h00 );			//	LD L, H
		test_ld_r_r( 8'h6D, 8'h12, 8'h23, 8'h34, 8'h45, 8'h56, 8'h56, 8'h78, 8'h00 );			//	LD L, L
		test_ld_r_r( 8'h6F, 8'h12, 8'h23, 8'h34, 8'h45, 8'h56, 8'h78, 8'h78, 8'h00 );			//	LD L, A

		// --------------------------------------------------------------------
		//	LD		L, n
		// --------------------------------------------------------------------
		//            code   data  ref B  ref C  ref D  ref E  ref H  ref L  ref A  ref F
		test_ld_r_n( 8'h2E, 8'h67, 8'h12, 8'h23, 8'h34, 8'h45, 8'h56, 8'h67, 8'h78, 8'h00 );	//	LD L, 67h

		// --------------------------------------------------------------------
		//	LD		A, r'
		// --------------------------------------------------------------------
		//            code  ref B  ref C  ref D  ref E  ref H  ref L  ref A  ref F
		test_ld_r_r( 8'h78, 8'h12, 8'h23, 8'h34, 8'h45, 8'h56, 8'h67, 8'h12, 8'h00 );			//	LD A, B
		test_ld_r_r( 8'h79, 8'h12, 8'h23, 8'h34, 8'h45, 8'h56, 8'h67, 8'h23, 8'h00 );			//	LD A, C
		test_ld_r_r( 8'h7A, 8'h12, 8'h23, 8'h34, 8'h45, 8'h56, 8'h67, 8'h34, 8'h00 );			//	LD A, D
		test_ld_r_r( 8'h7B, 8'h12, 8'h23, 8'h34, 8'h45, 8'h56, 8'h67, 8'h45, 8'h00 );			//	LD A, E
		test_ld_r_r( 8'h7C, 8'h12, 8'h23, 8'h34, 8'h45, 8'h56, 8'h67, 8'h56, 8'h00 );			//	LD A, H
		test_ld_r_r( 8'h7D, 8'h12, 8'h23, 8'h34, 8'h45, 8'h56, 8'h67, 8'h67, 8'h00 );			//	LD A, L
		test_ld_r_r( 8'h7F, 8'h12, 8'h23, 8'h34, 8'h45, 8'h56, 8'h67, 8'h67, 8'h00 );			//	LD A, A

		// --------------------------------------------------------------------
		//	LD		A, n
		// --------------------------------------------------------------------
		//            code   data  ref B  ref C  ref D  ref E  ref H  ref L  ref A  ref F
		test_ld_r_n( 8'h3E, 8'h78, 8'h12, 8'h23, 8'h34, 8'h45, 8'h56, 8'h67, 8'h78, 8'h00 );	//	LD A, 78h

		// --------------------------------------------------------------------
		//	LD		rr, nn
		// --------------------------------------------------------------------
		//              code            ref B  ref C  ref D  ref E  ref H  ref L  ref A  ref F
		test_ld_rr_nn( 8'h01, 16'h899A, 8'h89, 8'h9A, 8'h34, 8'h45, 8'h56, 8'h67, 8'h78, 8'h00 );	//	LD BC, 988Ah
		test_ld_rr_nn( 8'h11, 16'hABBC, 8'h89, 8'h9A, 8'hAB, 8'hBC, 8'h56, 8'h67, 8'h78, 8'h00 );	//	LD DE, ABBCh
		test_ld_rr_nn( 8'h21, 16'hCDDE, 8'h89, 8'h9A, 8'hAB, 8'hBC, 8'hCD, 8'hDE, 8'h78, 8'h00 );	//	LD HL, CDDEh

		// --------------------------------------------------------------------
		//	LD		xy, nn
		// --------------------------------------------------------------------
		//              code                   ref B  ref C  ref D  ref E  ref H  ref L  ref A  ref F rf IXH rf IXL rf IYH rf IYL
		test_ld_xy_nn( 8'hDD, 8'h21, 16'hEFF0, 8'h89, 8'h9A, 8'hAB, 8'hBC, 8'hCD, 8'hDE, 8'h78, 8'h00, 8'hEF, 8'hF0, 8'h01, 8'h12 );	//	LD IX, EFF0h
		test_ld_xy_nn( 8'hFD, 8'h21, 16'h0112, 8'h89, 8'h9A, 8'hAB, 8'hBC, 8'hCD, 8'hDE, 8'h78, 8'h00, 8'hEF, 8'hF0, 8'h01, 8'h12 );	//	LD IY, 0112h

		// --------------------------------------------------------------------
		//	LD		(hl), n
		// --------------------------------------------------------------------
		test_ld_rr_nn( 8'h21, 16'h1234, 8'h89, 8'h9A, 8'hAB, 8'hBC, 8'h12, 8'h34, 8'h78, 8'h00 );								//	LD HL, 1234h
		test_ld_hl_n(  8'hAB, 16'h1234, 8'h89, 8'h9A, 8'hAB, 8'hBC, 8'h12, 8'h34, 8'h78, 8'h00, 8'hEF, 8'hF0, 8'h01, 8'h12 );	//	LD (HL), ABh
		test_ld_rr_nn( 8'h21, 16'hFEDC, 8'h89, 8'h9A, 8'hAB, 8'hBC, 8'hFE, 8'hDC, 8'h78, 8'h00 );								//	LD HL, FEDCh
		test_ld_hl_n(  8'h53, 16'hFEDC, 8'h89, 8'h9A, 8'hAB, 8'hBC, 8'hFE, 8'hDC, 8'h78, 8'h00, 8'hEF, 8'hF0, 8'h01, 8'h12 );	//	LD (HL), 53h

		// --------------------------------------------------------------------
		//	LD		(IX + d), n
		// --------------------------------------------------------------------
		//             prefix data  ref addr       n  ref B  ref C  ref D  ref E  ref H  ref L  ref A  ref F rf IXH rf IXL rf IYH rf IYL
		test_ld_xy_nn( 8'hDD, 8'h21, 16'h7654,        8'h89, 8'h9A, 8'hAB, 8'hBC, 8'hFE, 8'hDC, 8'h78, 8'h00, 8'h76, 8'h54, 8'h01, 8'h12 );		//	LD IX, 7654h
		test_ld_xy_nn( 8'hFD, 8'h21, 16'h3456,        8'h89, 8'h9A, 8'hAB, 8'hBC, 8'hFE, 8'hDC, 8'h78, 8'h00, 8'h76, 8'h54, 8'h34, 8'h56 );		//	LD IY, 3456h
		test_ld_xy_n(  8'hDD, 8'h00, 16'h7654, 8'h53, 8'h89, 8'h9A, 8'hAB, 8'hBC, 8'hFE, 8'hDC, 8'h78, 8'h00, 8'h76, 8'h54, 8'h34, 8'h56 );		//	LD (IX+00h), 53h
		test_ld_xy_n(  8'hDD, 8'h09, 16'h765D, 8'hA2, 8'h89, 8'h9A, 8'hAB, 8'hBC, 8'hFE, 8'hDC, 8'h78, 8'h00, 8'h76, 8'h54, 8'h34, 8'h56 );		//	LD (IX+09h), A2h
		test_ld_xy_n(  8'hDD, 8'h7F, 16'h76D3, 8'hBE, 8'h89, 8'h9A, 8'hAB, 8'hBC, 8'hFE, 8'hDC, 8'h78, 8'h00, 8'h76, 8'h54, 8'h34, 8'h56 );		//	LD (IX+7Fh), BEh
		test_ld_xy_n(  8'hDD, 8'h80, 16'h75D4, 8'h93, 8'h89, 8'h9A, 8'hAB, 8'hBC, 8'hFE, 8'hDC, 8'h78, 8'h00, 8'h76, 8'h54, 8'h34, 8'h56 );		//	LD (IX-80h), 93h
		test_ld_xy_n(  8'hFD, 8'h00, 16'h3456, 8'h53, 8'h89, 8'h9A, 8'hAB, 8'hBC, 8'hFE, 8'hDC, 8'h78, 8'h00, 8'h76, 8'h54, 8'h34, 8'h56 );		//	LD (IY+00h), 53h
		test_ld_xy_n(  8'hFD, 8'h09, 16'h345F, 8'hA2, 8'h89, 8'h9A, 8'hAB, 8'hBC, 8'hFE, 8'hDC, 8'h78, 8'h00, 8'h76, 8'h54, 8'h34, 8'h56 );		//	LD (IY+09h), A2h
		test_ld_xy_n(  8'hFD, 8'h7F, 16'h34D5, 8'hBE, 8'h89, 8'h9A, 8'hAB, 8'hBC, 8'hFE, 8'hDC, 8'h78, 8'h00, 8'h76, 8'h54, 8'h34, 8'h56 );		//	LD (IY+7Fh), BEh
		test_ld_xy_n(  8'hFD, 8'h80, 16'h33D6, 8'h93, 8'h89, 8'h9A, 8'hAB, 8'hBC, 8'hFE, 8'hDC, 8'h78, 8'h00, 8'h76, 8'h54, 8'h34, 8'h56 );		//	LD (IY-80h), 93h

		test_ld_rr_nn(        8'h21, 16'hCDDE,        8'h89, 8'h9A, 8'hAB, 8'hBC, 8'hCD, 8'hDE, 8'h78, 8'h00 );								//	LD HL, FEDCh
		test_ld_xy_nn( 8'hDD, 8'h21, 16'hEFF0,        8'h89, 8'h9A, 8'hAB, 8'hBC, 8'hCD, 8'hDE, 8'h78, 8'h00, 8'hEF, 8'hF0, 8'h34, 8'h56 );	//	LD IX, EFF0h
		test_ld_xy_nn( 8'hFD, 8'h21, 16'h0112,        8'h89, 8'h9A, 8'hAB, 8'hBC, 8'hCD, 8'hDE, 8'h78, 8'h00, 8'hEF, 8'hF0, 8'h01, 8'h12 );	//	LD IY, 0112h

		$finish;
	end
endmodule
