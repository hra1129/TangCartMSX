// -----------------------------------------------------------------------------
//	Test of t80.v
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
	//	tasks
	// --------------------------------------------------------------------
	always @( posedge clk_n ) begin
		if( !reset_n ) begin
			ff_d <= 8'd0;
		end
		else begin
			case( a[3:0] )
			4'd0:		ff_d <= 8'hdd;	//	ld  ix, 3423h
			4'd1:		ff_d <= 8'h21;
			4'd2:		ff_d <= 8'h23;
			4'd3:		ff_d <= 8'h34;
			4'd4:		ff_d <= 8'h21;	//	ld  hl, 5645h
			4'd5:		ff_d <= 8'h45;
			4'd6:		ff_d <= 8'h56;
			4'd7:		ff_d <= 8'h00;
			4'd8:		ff_d <= 8'h00;
			4'd9:		ff_d <= 8'h00;
			4'd10:		ff_d <= 8'h00;
			4'd11:		ff_d <= 8'h00;
			4'd12:		ff_d <= 8'h00;
			4'd13:		ff_d <= 8'h00;
			4'd14:		ff_d <= 8'h00;
			4'd15:		ff_d <= 8'h00;
			default:	ff_d <= 8'h00;
			endcase
		end
	end

	// --------------------------------------------------------------------
	//	test bench
	// --------------------------------------------------------------------
	initial begin
		reset_n		= 0;
		clk_n		= 1;
		wait_n		= 1;
		int_n		= 1;
		nmi_n		= 1;
		busrq_n		= 1;
		ff_clock_speed	= 5'd24;

		@( negedge clk_n );
		@( negedge clk_n );
		@( posedge clk_n );

		reset_n		= 1;
		@( posedge clk_n );

		// --------------------------------------------------------------------
		//	3.579545mhz‘Š“– 
		// --------------------------------------------------------------------
		ff_clock_speed	= 5'd24;
		repeat( 1000 ) @( posedge clk_n );

		// --------------------------------------------------------------------
		//	7.15909mhz‘Š“– 
		// --------------------------------------------------------------------
		ff_clock_speed	= 5'd12;
		repeat( 1000 ) @( posedge clk_n );

		// --------------------------------------------------------------------
		//	14.31818mhz‘Š“– 
		// --------------------------------------------------------------------
		ff_clock_speed	= 5'd6;
		repeat( 1000 ) @( posedge clk_n );

		// --------------------------------------------------------------------
		//	21.47727mhz‘Š“– 
		// --------------------------------------------------------------------
		ff_clock_speed	= 5'd4;
		repeat( 1000 ) @( posedge clk_n );

		$finish;
	end
endmodule
