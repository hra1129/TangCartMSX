// -----------------------------------------------------------------------------
//	Test of micom_connect.v
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
	localparam	clk_base	= 1_000_000_000/85_909;	//	ps
	int				test_no;
	int				i;

	reg				reset_n;
	reg				clk;
	reg				spi_cs_n;
	reg				spi_clk;
	reg				spi_mosi;
	wire			spi_miso;
	wire			msx_reset_n;
	reg		[3:0]	matrix_y;
	wire	[7:0]	matrix_x;
	wire	[21:0]	address;
	wire			req;
	wire	[7:0]	wdata;
	reg				sdram_busy;

	reg		[7:0]	read_data;
	reg		[1:0]	ff_clock_divider;

	// --------------------------------------------------------------------
	//	DUT
	// --------------------------------------------------------------------
	micom_connect u_micom_connect (
		.reset_n		( reset_n		),
		.clk			( clk			),
		.spi_cs_n		( spi_cs_n		),
		.spi_clk		( spi_clk		),
		.spi_mosi		( spi_mosi		),
		.spi_miso		( spi_miso		),
		.msx_reset_n	( msx_reset_n	),
		.matrix_y		( matrix_y		),
		.matrix_x		( matrix_x		),
		.address		( address		),
		.req			( req			),
		.wdata			( wdata			),
		.sdram_busy		( sdram_busy	)
	);

	// --------------------------------------------------------------------
	//	clock
	// --------------------------------------------------------------------
	always #(clk_base/2) begin
		clk <= ~clk;				//	85.90908MHz
	end

	// --------------------------------------------------------------------
	//	Tasks
	// --------------------------------------------------------------------
	task send_byte(
		input	[7:0]	wdata,
		output	[7:0]	rdata
	);
		int i;

		for( i = 0; i < 8; i = i + 1 ) begin
			# 20ns
			spi_clk		<= 1'b0;
			# 1ns
			spi_mosi	<= wdata[7-i];
			# 20ns
			spi_clk		<= 1'b1;
			# 1ns
			rdata[7-i]	<= spi_miso;
		end
		# 21ns
		spi_clk		<= 1'b0;
		# 21ns
		spi_clk		<= 1'b0;
	endtask: send_byte

	// --------------------------------------------------------------------
	//	Test bench
	// --------------------------------------------------------------------
	initial begin
		test_no		= -1;
		reset_n		= 0;
		clk			= 1;
		spi_cs_n	= 1;
		spi_clk		= 0;
		spi_mosi	= 0;
		matrix_y	= 0;
		sdram_busy	= 0;

		@( negedge clk );
		@( negedge clk );
		@( posedge clk );

		reset_n		= 1;
		@( posedge clk );

		assert( msx_reset_n == 1'b0 );

		spi_cs_n	= 0;
		@( posedge clk );
		send_byte( 8'h00, read_data );
		assert( read_data == 8'hA5 );
		@( posedge clk );
		spi_cs_n	= 1;
		@( posedge clk );

		// --------------------------------------------------------------------
		//	MSX Reset Signal
		// --------------------------------------------------------------------
		spi_cs_n	= 0;
		@( posedge clk );
		send_byte( 8'h02, read_data );
		assert( read_data == 8'hA5 );
		assert( msx_reset_n == 1'b0 );
		@( posedge clk );
		spi_cs_n	= 1;
		@( posedge clk );

		spi_cs_n	= 0;
		@( posedge clk );
		send_byte( 8'h01, read_data );
		assert( read_data == 8'hA5 );
		assert( msx_reset_n == 1'b1 );
		@( posedge clk );
		spi_cs_n	= 1;
		@( posedge clk );

		spi_cs_n	= 0;
		@( posedge clk );
		send_byte( 8'h02, read_data );
		assert( read_data == 8'hA5 );
		assert( msx_reset_n == 1'b0 );
		@( posedge clk );
		spi_cs_n	= 1;
		@( posedge clk );

		spi_cs_n	= 0;
		@( posedge clk );
		send_byte( 8'h01, read_data );
		assert( read_data == 8'hA5 );
		assert( msx_reset_n == 1'b1 );
		@( posedge clk );
		spi_cs_n	= 1;
		@( posedge clk );

		// --------------------------------------------------------------------
		//	Key Matrix
		// --------------------------------------------------------------------
		spi_cs_n	= 0;
		@( posedge clk );
		send_byte( 8'h03, read_data );
		assert( read_data == 8'hA5 );
		@( posedge clk );
		send_byte( 8'h00, read_data );			//	Y = 00h
		assert( read_data == 8'hA5 );
		@( posedge clk );
		send_byte( 8'h12, read_data );			//	X = 12h
		assert( read_data == 8'hA5 );
		@( posedge clk );
		spi_cs_n	= 1;
		@( posedge clk );

		spi_cs_n	= 0;
		@( posedge clk );
		send_byte( 8'h03, read_data );
		assert( read_data == 8'hA5 );
		@( posedge clk );
		send_byte( 8'h01, read_data );			//	Y = 01h
		assert( read_data == 8'hA5 );
		@( posedge clk );
		send_byte( 8'h23, read_data );			//	X = 23h
		assert( read_data == 8'hA5 );
		@( posedge clk );
		spi_cs_n	= 1;
		@( posedge clk );

		spi_cs_n	= 0;
		@( posedge clk );
		send_byte( 8'h03, read_data );
		assert( read_data == 8'hA5 );
		@( posedge clk );
		send_byte( 8'h02, read_data );			//	Y = 02h
		assert( read_data == 8'hA5 );
		@( posedge clk );
		send_byte( 8'h34, read_data );			//	X = 34h
		assert( read_data == 8'hA5 );
		@( posedge clk );
		spi_cs_n	= 1;
		@( posedge clk );

		spi_cs_n	= 0;
		@( posedge clk );
		send_byte( 8'h03, read_data );
		assert( read_data == 8'hA5 );
		@( posedge clk );
		send_byte( 8'h03, read_data );			//	Y = 03h
		assert( read_data == 8'hA5 );
		@( posedge clk );
		send_byte( 8'h45, read_data );			//	X = 45h
		assert( read_data == 8'hA5 );
		@( posedge clk );
		spi_cs_n	= 1;
		@( posedge clk );

		spi_cs_n	= 0;
		@( posedge clk );
		send_byte( 8'h03, read_data );
		assert( read_data == 8'hA5 );
		@( posedge clk );
		send_byte( 8'h04, read_data );			//	Y = 04h
		assert( read_data == 8'hA5 );
		@( posedge clk );
		send_byte( 8'h56, read_data );			//	X = 56h
		assert( read_data == 8'hA5 );
		@( posedge clk );
		spi_cs_n	= 1;
		@( posedge clk );

		spi_cs_n	= 0;
		@( posedge clk );
		send_byte( 8'h03, read_data );
		assert( read_data == 8'hA5 );
		@( posedge clk );
		send_byte( 8'h05, read_data );			//	Y = 05h
		assert( read_data == 8'hA5 );
		@( posedge clk );
		send_byte( 8'h67, read_data );			//	X = 67h
		assert( read_data == 8'hA5 );
		@( posedge clk );
		spi_cs_n	= 1;
		@( posedge clk );

		spi_cs_n	= 0;
		@( posedge clk );
		send_byte( 8'h03, read_data );
		assert( read_data == 8'hA5 );
		@( posedge clk );
		send_byte( 8'h06, read_data );			//	Y = 06h
		assert( read_data == 8'hA5 );
		@( posedge clk );
		send_byte( 8'h78, read_data );			//	X = 78h
		assert( read_data == 8'hA5 );
		@( posedge clk );
		spi_cs_n	= 1;
		@( posedge clk );

		spi_cs_n	= 0;
		@( posedge clk );
		send_byte( 8'h03, read_data );
		assert( read_data == 8'hA5 );
		@( posedge clk );
		send_byte( 8'h07, read_data );			//	Y = 07h
		assert( read_data == 8'hA5 );
		@( posedge clk );
		send_byte( 8'h89, read_data );			//	X = 89h
		assert( read_data == 8'hA5 );
		@( posedge clk );
		spi_cs_n	= 1;
		@( posedge clk );

		spi_cs_n	= 0;
		@( posedge clk );
		send_byte( 8'h03, read_data );
		assert( read_data == 8'hA5 );
		@( posedge clk );
		send_byte( 8'h08, read_data );			//	Y = 08h
		assert( read_data == 8'hA5 );
		@( posedge clk );
		send_byte( 8'h9A, read_data );			//	X = 9Ah
		assert( read_data == 8'hA5 );
		@( posedge clk );
		spi_cs_n	= 1;
		@( posedge clk );

		spi_cs_n	= 0;
		@( posedge clk );
		send_byte( 8'h03, read_data );
		assert( read_data == 8'hA5 );
		@( posedge clk );
		send_byte( 8'h09, read_data );			//	Y = 09h
		assert( read_data == 8'hA5 );
		@( posedge clk );
		send_byte( 8'hAB, read_data );			//	X = ABh
		assert( read_data == 8'hA5 );
		@( posedge clk );
		spi_cs_n	= 1;
		@( posedge clk );

		spi_cs_n	= 0;
		@( posedge clk );
		send_byte( 8'h03, read_data );
		assert( read_data == 8'hA5 );
		@( posedge clk );
		send_byte( 8'h0A, read_data );			//	Y = 0Ah
		assert( read_data == 8'hA5 );
		@( posedge clk );
		send_byte( 8'hBC, read_data );			//	X = BCh
		assert( read_data == 8'hA5 );
		@( posedge clk );
		spi_cs_n	= 1;
		@( posedge clk );

		spi_cs_n	= 0;
		@( posedge clk );
		send_byte( 8'h03, read_data );
		assert( read_data == 8'hA5 );
		@( posedge clk );
		send_byte( 8'h0B, read_data );			//	Y = 0Bh
		assert( read_data == 8'hA5 );
		@( posedge clk );
		send_byte( 8'hCD, read_data );			//	X = CDh
		assert( read_data == 8'hA5 );
		@( posedge clk );
		spi_cs_n	= 1;
		@( posedge clk );

		spi_cs_n	= 0;
		@( posedge clk );
		send_byte( 8'h03, read_data );
		assert( read_data == 8'hA5 );
		@( posedge clk );
		send_byte( 8'h0C, read_data );			//	Y = 0Ch
		assert( read_data == 8'hA5 );
		@( posedge clk );
		send_byte( 8'hDE, read_data );			//	X = DEh
		assert( read_data == 8'hA5 );
		@( posedge clk );
		spi_cs_n	= 1;
		@( posedge clk );

		spi_cs_n	= 0;
		@( posedge clk );
		send_byte( 8'h03, read_data );
		assert( read_data == 8'hA5 );
		@( posedge clk );
		send_byte( 8'h0D, read_data );			//	Y = 0Dh
		assert( read_data == 8'hA5 );
		@( posedge clk );
		send_byte( 8'hEF, read_data );			//	X = EFh
		assert( read_data == 8'hA5 );
		@( posedge clk );
		spi_cs_n	= 1;
		@( posedge clk );

		spi_cs_n	= 0;
		@( posedge clk );
		send_byte( 8'h03, read_data );
		assert( read_data == 8'hA5 );
		@( posedge clk );
		send_byte( 8'h0E, read_data );			//	Y = 0Eh
		assert( read_data == 8'hA5 );
		@( posedge clk );
		send_byte( 8'hF0, read_data );			//	X = F0h
		assert( read_data == 8'hA5 );
		@( posedge clk );
		spi_cs_n	= 1;
		@( posedge clk );

		spi_cs_n	= 0;
		@( posedge clk );
		send_byte( 8'h03, read_data );
		assert( read_data == 8'hA5 );
		@( posedge clk );
		send_byte( 8'h0F, read_data );			//	Y = 0Fh
		assert( read_data == 8'hA5 );
		@( posedge clk );
		send_byte( 8'h01, read_data );			//	X = 01h
		assert( read_data == 8'hA5 );
		@( posedge clk );
		spi_cs_n	= 1;
		@( posedge clk );

		for( i = 0; i < 16; i = i + 1 ) begin
			matrix_y <= i;
			@( posedge clk );
			assert( matrix_x == ((i + 2) & 15) | (((i + 1) & 15) << 4) );
			@( posedge clk );
		end

		// --------------------------------------------------------------------
		//	Memory I/F
		// --------------------------------------------------------------------
		spi_cs_n	= 0;
		@( posedge clk );
		send_byte( 8'h04, read_data );
		assert( read_data == 8'hA5 );
		@( posedge clk );
		send_byte( 8'h12, read_data );			//	BANK = 12h
		assert( read_data == 8'hA5 );

		for( i = 0; i < 16384; i = i + 1 ) begin
			send_byte( i & 255, read_data );
			assert( read_data == 8'hA5 );
			@( posedge clk );
			$display( "Address: %04X", i );
		end
		spi_cs_n	= 1;
		@( posedge clk );

		// --------------------------------------------------------------------
		//	Get Status
		// --------------------------------------------------------------------
		sdram_busy	= 0;
		@( posedge clk );
		spi_cs_n	= 0;
		@( posedge clk );
		send_byte( 8'h05, read_data );
		assert( read_data == 8'hA5 );
		@( posedge clk );
		send_byte( 8'h00, read_data );			//	N/A
		assert( read_data == 8'h00 );
		@( posedge clk );
		spi_cs_n	= 1;
		@( posedge clk );

		sdram_busy	= 1;
		@( posedge clk );
		spi_cs_n	= 0;
		@( posedge clk );
		send_byte( 8'h05, read_data );
		assert( read_data == 8'hA5 );
		@( posedge clk );
		send_byte( 8'h00, read_data );			//	N/A
		assert( read_data == 8'h01 );
		@( posedge clk );
		spi_cs_n	= 1;
		@( posedge clk );

		repeat( 10 ) @( posedge clk );
		$finish;
	end
endmodule
