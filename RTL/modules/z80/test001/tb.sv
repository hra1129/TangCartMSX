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
	reg				RESET_n		;
	reg				CLK_n		;
	reg				ENABLE		;
	reg				WAIT_n		;
	reg				INT_n		;
	reg				NMI_n		;
	reg				BUSRQ_n		;
	wire			M1_n		;
	wire			MREQ_n		;
	wire			IORQ_n		;
	wire			RD_n		;
	wire			WR_n		;
	wire			RFSH_n		;
	wire			HALT_n		;
	wire			BUSAK_n		;
	wire	[15:0]	A			;
	wire	[7:0]	D			;
	wire	[15:0]	p_PC		;
	reg		[7:0]	ff_d		;
	reg		[7:0]	ff_ram [0:15];

	reg		[4:0]	ff_clock;
	reg		[4:0]	ff_clock_speed;

	// --------------------------------------------------------------------
	//	DUT
	// --------------------------------------------------------------------
	T80_inst #(
		.Mode		( 0				),		// 0 => Z80, 1 => Fast Z80, 2 => 8080, 3 => GB
		.R800_MULU	( 0				),		// 0 => no MULU, 1=> R800 MULU
		.IOWait		( 1				)		// 0 => Single I/O cycle, 1 => Std I/O cycle
	) u_z80 (
		.RESET_n	( RESET_n		),
		.CLK_n		( CLK_n			),
		.ENABLE		( ENABLE		),
		.WAIT_n		( WAIT_n		),
		.INT_n		( INT_n			),
		.NMI_n		( NMI_n			),
		.BUSRQ_n	( BUSRQ_n		),
		.M1_n		( M1_n			),
		.MREQ_n		( MREQ_n		),
		.IORQ_n		( IORQ_n		),
		.RD_n		( RD_n			),
		.WR_n		( WR_n			),
		.RFSH_n		( RFSH_n		),
		.HALT_n		( HALT_n		),
		.BUSAK_n	( BUSAK_n		),
		.A			( A				),
		.D			( D				),
		.p_PC		( p_PC			)
	);

	//				         write  read
	assign D		= RD_n ? 8'dz : ff_d;

	// --------------------------------------------------------------------
	//	clock
	// --------------------------------------------------------------------
	always #(clk_base/2) begin
		CLK_n <= ~CLK_n;
	end

	// --------------------------------------------------------------------
	//	clock divider
	// --------------------------------------------------------------------
	always @( posedge CLK_n ) begin
		if( !RESET_n ) begin
			ff_clock <= 5'd1;
		end
		else if( ff_clock == 5'd0 ) begin
			ff_clock <= ff_clock_speed;
		end
		else begin
			ff_clock <= ff_clock - 5'd1;
		end
	end

	assign ENABLE = (ff_clock == 5'd0 );

	// --------------------------------------------------------------------
	//	Tasks
	// --------------------------------------------------------------------
	always @( posedge CLK_n ) begin
		if( !RESET_n ) begin
			ff_d <= 8'd0;
		end
		else begin
			case( A[4:0] )
			4'd0:		ff_d <= 8'hdd;	//	ld  ix, 0010h
			4'd1:		ff_d <= 8'h21;
			4'd2:		ff_d <= 8'h10;
			4'd3:		ff_d <= 8'h00;
			4'd4:		ff_d <= 8'h3e;	//	ld  a, 11h
			4'd5:		ff_d <= 8'h11;
			4'd6:		ff_d <= 8'h32;	//	ld  (0010h), a
			4'd7:		ff_d <= 8'h10;
			4'd8:		ff_d <= 8'h00;
			4'd9:		ff_d <= 8'hdd;	//	bit 0, (ix + 0)
			4'd10:		ff_d <= 8'hcb;
			4'd11:		ff_d <= 8'h00;
			4'd12:		ff_d <= 8'h46;
			4'd13:		ff_d <= 8'hc3;	//	jp  0000h
			4'd14:		ff_d <= 8'h00;
			4'd15:		ff_d <= 8'h00;
			default:	ff_d <= ff_ram[ A[3:0] ];
			endcase
		end
	end

	always @( posedge CLK_n ) begin
		if( !MREQ_n && !WR_n && A[4] == 1'b1 ) begin
			ff_ram[ A[3:0] ] <= D;
		end
	end

	// --------------------------------------------------------------------
	//	Test bench
	// --------------------------------------------------------------------
	initial begin
		RESET_n		= 0;
		CLK_n		= 1;
		WAIT_n		= 1;
		INT_n		= 1;
		NMI_n		= 1;
		BUSRQ_n		= 1;
		ff_clock_speed	= 5'd24;

		@( negedge CLK_n );
		@( negedge CLK_n );
		@( posedge CLK_n );

		RESET_n		= 1;
		@( posedge CLK_n );

		// --------------------------------------------------------------------
		//	3.579545MHz‘Š“– 
		// --------------------------------------------------------------------
		ff_clock_speed	= 5'd24;
		repeat( 1000 ) @( posedge CLK_n );

		// --------------------------------------------------------------------
		//	7.15909MHz‘Š“– 
		// --------------------------------------------------------------------
		ff_clock_speed	= 5'd12;
		repeat( 1000 ) @( posedge CLK_n );

		// --------------------------------------------------------------------
		//	14.31818MHz‘Š“– 
		// --------------------------------------------------------------------
		ff_clock_speed	= 5'd6;
		repeat( 1000 ) @( posedge CLK_n );

		// --------------------------------------------------------------------
		//	21.47727MHz‘Š“– 
		// --------------------------------------------------------------------
		ff_clock_speed	= 5'd4;
		repeat( 1000 ) @( posedge CLK_n );

		$finish;
	end
endmodule
