// -----------------------------------------------------------------------------
//	Test of t80.v
//	Copyright (C)2025 Takayuki Hara (HRA!)
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
	reg				clk_n		;		//	85.90908MHz
	reg				int_n		;
	wire	[15:0]	bus_address	;
	wire			bus_memreq	;
	wire			bus_ioreq	;
	wire			bus_valid	;
	reg				bus_ready	;
	wire			bus_write	;
	wire	[7:0]	bus_wdata	;
	reg		[7:0]	bus_rdata	;
	reg				bus_rdata_en;
	reg		[7:0]	ff_d;
	reg		[7:0]	ff_ram [0:15];

	// --------------------------------------------------------------------
	//	dut
	// --------------------------------------------------------------------
	cz80_wrap u_z80 (
		.reset_n		( reset_n		),
		.clk_n			( clk_n			),
		.int_n			( int_n			),
		.bus_address	( bus_address	),
		.bus_memreq		( bus_memreq	),
		.bus_ioreq		( bus_ioreq		),
		.bus_valid		( bus_valid		),
		.bus_ready		( bus_ready		),
		.bus_write		( bus_write		),
		.bus_wdata		( bus_wdata		),
		.bus_rdata		( bus_rdata		),
		.bus_rdata_en	( bus_rdata_en	)
	);

	// --------------------------------------------------------------------
	//	clock
	// --------------------------------------------------------------------
	always #(clk_base/2) begin
		clk_n <= ~clk_n;
	end

	// --------------------------------------------------------------------
	//	tasks
	// --------------------------------------------------------------------
	always @( posedge clk_n ) begin
		if( !reset_n ) begin
			ff_d <= 8'd0;
		end
		else begin
			case( bus_address[4:0] )
			4'd0:		ff_d <= 8'hdd;	//	ld  ix, 0010h
			4'd1:		ff_d <= 8'h21;
			4'd2:		ff_d <= 8'h10;
			4'd3:		ff_d <= 8'h00;
			4'd4:		ff_d <= 8'h3e;	//	ld  a, 12h
			4'd5:		ff_d <= 8'h12;
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
			default:	ff_d <= ff_ram[ bus_address[3:0] ];
			endcase
		end
	end

	assign bus_rdata	= ff_d;

	always @( posedge clk_n ) begin
		if( bus_memreq && bus_write && bus_address[4] == 1'b1 ) begin
			ff_ram[ bus_address[3:0] ] <= bus_wdata;
		end
	end

	always @( posedge clk_n ) begin
		bus_rdata_en	<= (bus_memreq | bus_ioreq) & ~bus_write & bus_valid;
	end

	// --------------------------------------------------------------------
	//	test bench
	// --------------------------------------------------------------------
	initial begin
		reset_n			= 0;
		clk_n			= 1;
		int_n			= 1;
		bus_ready		= 1'b1;

		@( negedge clk_n );
		@( negedge clk_n );
		@( posedge clk_n );

		reset_n		= 1;
		@( posedge clk_n );

		repeat( 1000 ) @( posedge clk_n );
		repeat( 1000 ) @( posedge clk_n );
		repeat( 1000 ) @( posedge clk_n );
		repeat( 1000 ) @( posedge clk_n );
		$finish;
	end
endmodule
