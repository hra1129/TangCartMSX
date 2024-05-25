// -----------------------------------------------------------------------------
//	Test of ip_megarom.v
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
//		MegaROM
// -----------------------------------------------------------------------------

module tb ();
	localparam		clk_base	= 1000000000/21477;
	//	Internal I/F
	reg				n_reset;
	reg				clk;
	reg		[2:0]	mode;				//	0: ASC8; 1: ASC16; 2: Normal; 3: Kon4; 4: SCC; 5: SCC-I; 6: Generic8; 7: Generic16
	//	MSX-50BUS
	reg		[15:0]	bus_address;
	wire			bus_io_cs;
	wire			bus_memory_cs;
	wire			bus_read_ready;
	wire	[7:0]	bus_read_data;
	reg		[7:0]	bus_write_data;
	reg				bus_read;
	reg				bus_write;
	reg				bus_io;
	reg				bus_memory;
	//	RAM I/F
	wire			rd;
	wire			wr;
	reg				busy;
	wire	[21:0]	address;
	wire	[7:0]	wdata;
	reg		[7:0]	rdata;
	reg				rdata_en;
	wire			scc_bank_en;
	wire			sccp_bank_en;
	integer			test_no;
	reg		[21:0]	ff_address;
	reg		[7:0]	ff_wdata;
	reg		[7:0]	ff_rdata;
	reg				ff_scc;
	reg				ff_sccp;
	integer			i;

	// --------------------------------------------------------------------
	//	DUT
	// --------------------------------------------------------------------
	ip_megarom u_megarom (
		.n_reset			( n_reset			),
		.clk				( clk				),
		.mode				( mode				),
		.bus_address		( bus_address		),
		.bus_io_cs			( bus_io_cs			),
		.bus_memory_cs		( bus_memory_cs		),
		.bus_read_ready		( bus_read_ready	),
		.bus_read_data		( bus_read_data		),
		.bus_write_data		( bus_write_data	),
		.bus_read			( bus_read			),
		.bus_write			( bus_write			),
		.bus_io				( bus_io			),
		.bus_memory			( bus_memory		),
		.rd					( rd				),
		.wr					( wr				),
		.busy				( busy				),
		.address			( address			),
		.wdata				( wdata				),
		.rdata				( rdata				),
		.rdata_en			( rdata_en			),
		.scc_bank_en		( scc_bank_en		),
		.sccp_bank_en		( sccp_bank_en		)
	);

	// --------------------------------------------------------------------
	//	clock
	// --------------------------------------------------------------------
	always #(clk_base/2) begin
		clk <= ~clk;
	end

	// --------------------------------------------------------------------
	//	Tasks
	// --------------------------------------------------------------------
	task write_memory(
		input	[15:0]	address,
		input	[7:0]	data
	);
		bus_address		<= address;
		bus_write_data	<= data;
		bus_write		<= 1'b1;
		bus_memory		<= 1'b1;
		@( posedge clk );

		bus_address		<= 'd0;
		bus_write_data	<= 'd0;
		bus_write		<= 1'b0;
		bus_memory		<= 1'b0;
		@( posedge clk );
		@( posedge clk );
		@( posedge clk );
	endtask: write_memory

	task write_io(
		input	[15:0]	address,
		input	[7:0]	data
	);
		bus_address		<= address;
		bus_write_data	<= data;
		bus_write		<= 1'b1;
		bus_io			<= 1'b1;
		@( posedge clk );

		bus_address		<= 'd0;
		bus_write_data	<= 'd0;
		bus_write		<= 1'b0;
		bus_io			<= 1'b0;
		@( posedge clk );
		@( posedge clk );
		@( posedge clk );
	endtask: write_io

	task read_memory(
		input	[15:0]	address,
		input	[7:0]	data
	);
		integer count;
	
		bus_address		<= address;
		bus_read		<= 1'b1;
		bus_memory		<= 1'b1;
		@( posedge clk );

		bus_address		<= 'd0;
		bus_read		<= 1'b0;
		bus_memory		<= 1'b0;
		@( posedge clk );

		count = 0;
		while( !bus_read_ready && count < 100 ) begin
			@( posedge clk );
			count = count + 1;
		end

		assert( count < 100 );
		assert( bus_read_data == data );
		@( posedge clk );
		@( posedge clk );
		@( posedge clk );
	endtask: read_memory

	task read_io(
		input	[15:0]	address,
		input	[7:0]	data
	);
		integer count;
	
		bus_address		<= address;
		bus_read		<= 1'b1;
		bus_io			<= 1'b1;
		@( posedge clk );

		bus_address		<= 'd0;
		bus_read		<= 1'b0;
		bus_io			<= 1'b0;
		@( posedge clk );

		count = 0;
		while( !bus_read_ready && count < 100 ) begin
			@( posedge clk );
			count = count + 1;
		end

		assert( count < 100 );
		assert( bus_read_data == data );
		@( posedge clk );
		@( posedge clk );
		@( posedge clk );
	endtask: read_io

	task read_memory_timeout(
		input	[15:0]	address
	);
		int counter;

		bus_address		<= address;
		bus_read		<= 1'b1;
		bus_memory		<= 1'b1;
		@( posedge clk );

		bus_address		<= 'd0;
		bus_read		<= 1'b0;
		bus_memory		<= 1'b0;
		@( posedge clk );

		counter = 0;
		while( !bus_read_ready && counter < 10 ) begin
			@( posedge clk );
			counter = counter + 1;
		end

		assert( bus_read_ready == 1'b0 );
		@( posedge clk );
		@( posedge clk );
		@( posedge clk );
	endtask: read_memory_timeout

	task read_io_timeout(
		input	[15:0]	address
	);
		int counter;

		bus_address		<= address;
		bus_read		<= 1'b1;
		bus_io			<= 1'b1;
		@( posedge clk );

		bus_address		<= 'd0;
		bus_read		<= 1'b0;
		bus_io			<= 1'b0;
		@( posedge clk );

		counter = 0;
		while( !bus_read_ready && counter < 10 ) begin
			@( posedge clk );
			counter = counter + 1;
		end

		assert( bus_read_ready == 1'b0 );
		@( posedge clk );
		@( posedge clk );
		@( posedge clk );
	endtask: read_io_timeout

	task address_latch();
		forever begin
			if( rd ) begin
				ff_address <= address;
				rdata <= ff_rdata;
				rdata_en <= 1'b1;
			end
			else if( wr ) begin
				ff_address <= address;
				ff_wdata <= wdata;
				rdata <= 8'd0;
				rdata_en <= 1'b0;
			end
			else begin
				rdata <= 8'd0;
				rdata_en <= 1'b0;
			end
			@( posedge clk );
		end
	endtask: address_latch

	task check_bank(
		input	[15:0]	start_address,
		input	[15:0]	end_address,
		input	[7:0]	ref_bank,
		string			s_message
	);
		integer i;

		$display( "---- %s", s_message );
		for( i = start_address; i <= end_address; i = i + 1 ) begin
			ff_rdata = (i & 255) ^ 255;
			read_memory( i, ff_rdata );
			assert( ff_address[20:13] == ref_bank );
			assert( ff_address[12: 0] == (i & 8191) );
		end
	endtask: check_bank

	// --------------------------------------------------------------------
	//	Test bench
	// --------------------------------------------------------------------
	initial begin
		test_no			= 900;
		n_reset			= 0;
		clk				= 0;
		bus_address		= 0;
		bus_write_data	= 0;
		bus_read		= 0;
		bus_write		= 0;
		bus_io			= 0;
		bus_memory		= 0;
		mode			= 0;
		busy			= 0;

		@( negedge clk );
		@( negedge clk );

		n_reset			= 1;
		repeat( 10 ) @( posedge clk );

		fork
			address_latch();
		join_none

		// --------------------------------------------------------------------
		//	check CS port
		// --------------------------------------------------------------------
		test_no			= 901;
		$display( "Check CS port" );
		assert( bus_io_cs == 1'b0 );
		assert( bus_memory_cs == 1'b1 );
		@( posedge clk );

		// --------------------------------------------------------------------
		//	check MODE0:ASC8
		// --------------------------------------------------------------------
		test_no			= 0;
		$display( "Check ASC8 mode" );
		ff_address		= 'd0;
		mode			= 0;
		n_reset			= 0;
		@( posedge clk );
		n_reset			= 1;
		@( posedge clk );

		$display( "-- Read bank and check read address" );
		check_bank( 16'h0000, 16'h1FFF, 8'h02, "bank2 mirror" );
		check_bank( 16'h2000, 16'h3FFF, 8'h03, "bank3 mirror" );
		check_bank( 16'h4000, 16'h5FFF, 8'h00, "bank0" );
		check_bank( 16'h6000, 16'h7FFF, 8'h01, "bank1" );
		check_bank( 16'h8000, 16'h9FFF, 8'h02, "bank2" );
		check_bank( 16'hA000, 16'hBFFF, 8'h03, "bank3" );
		check_bank( 16'hC000, 16'hDFFF, 8'h00, "bank0 mirror" );
		check_bank( 16'hE000, 16'hFFFF, 8'h01, "bank1 mirror" );

		$display( "-- Write bank registers" );
		write_memory( 16'h6000, 8'h12 );
		write_memory( 16'h6800, 8'h34 );
		write_memory( 16'h7000, 8'h56 );
		write_memory( 16'h7800, 8'h78 );
		$display( "-- Read bank and check read address" );
		check_bank( 16'h0000, 16'h1FFF, 8'h56, "bank2 mirror" );
		check_bank( 16'h2000, 16'h3FFF, 8'h78, "bank3 mirror" );
		check_bank( 16'h4000, 16'h5FFF, 8'h12, "bank0" );
		check_bank( 16'h6000, 16'h7FFF, 8'h34, "bank1" );
		check_bank( 16'h8000, 16'h9FFF, 8'h56, "bank2" );
		check_bank( 16'hA000, 16'hBFFF, 8'h78, "bank3" );
		check_bank( 16'hC000, 16'hDFFF, 8'h12, "bank0 mirror" );
		check_bank( 16'hE000, 16'hFFFF, 8'h34, "bank1 mirror" );

		$display( "-- Write bank registers" );
		write_memory( 16'h67FF, 8'h9A );
		write_memory( 16'h6FFF, 8'hBC );
		write_memory( 16'h77FF, 8'hDE );
		write_memory( 16'h7FFF, 8'hF0 );
		$display( "-- Read bank and check read address" );
		check_bank( 16'h0000, 16'h1FFF, 8'hDE, "bank2 mirror" );
		check_bank( 16'h2000, 16'h3FFF, 8'hF0, "bank3 mirror" );
		check_bank( 16'h4000, 16'h5FFF, 8'h9A, "bank0" );
		check_bank( 16'h6000, 16'h7FFF, 8'hBC, "bank1" );
		check_bank( 16'h8000, 16'h9FFF, 8'hDE, "bank2" );
		check_bank( 16'hA000, 16'hBFFF, 8'hF0, "bank3" );
		check_bank( 16'hC000, 16'hDFFF, 8'h9A, "bank0 mirror" );
		check_bank( 16'hE000, 16'hFFFF, 8'hBC, "bank1 mirror" );

		// --------------------------------------------------------------------
		//	check MODE1:ASC16
		// --------------------------------------------------------------------
		test_no			= 100;
		$display( "Check ASC16 mode" );
		ff_address		= 'd0;
		mode			= 1;
		n_reset			= 0;
		@( posedge clk );
		n_reset			= 1;
		@( posedge clk );

		$display( "-- Read bank and check read address" );
		check_bank( 16'h0000, 16'h1FFF, { 7'h01, 1'b0 }, "bank1 mirror" );
		check_bank( 16'h2000, 16'h3FFF, { 7'h01, 1'b1 }, "bank1 mirror" );
		check_bank( 16'h4000, 16'h5FFF, { 7'h00, 1'b0 }, "bank0" );
		check_bank( 16'h6000, 16'h7FFF, { 7'h00, 1'b1 }, "bank0" );
		check_bank( 16'h8000, 16'h9FFF, { 7'h01, 1'b0 }, "bank1" );
		check_bank( 16'hA000, 16'hBFFF, { 7'h01, 1'b1 }, "bank1" );
		check_bank( 16'hC000, 16'hDFFF, { 7'h00, 1'b0 }, "bank0 mirror" );
		check_bank( 16'hE000, 16'hFFFF, { 7'h00, 1'b1 }, "bank0 mirror" );

		$display( "-- Write bank registers" );
		write_memory( 16'h6000, 8'h12 );
		write_memory( 16'h7000, 8'h34 );
		$display( "-- Read bank and check read address" );
		check_bank( 16'h0000, 16'h1FFF, { 7'h34, 1'b0 }, "bank1 mirror" );
		check_bank( 16'h2000, 16'h3FFF, { 7'h34, 1'b1 }, "bank1 mirror" );
		check_bank( 16'h4000, 16'h5FFF, { 7'h12, 1'b0 }, "bank0" );
		check_bank( 16'h6000, 16'h7FFF, { 7'h12, 1'b1 }, "bank0" );
		check_bank( 16'h8000, 16'h9FFF, { 7'h34, 1'b0 }, "bank1" );
		check_bank( 16'hA000, 16'hBFFF, { 7'h34, 1'b1 }, "bank1" );
		check_bank( 16'hC000, 16'hDFFF, { 7'h12, 1'b0 }, "bank0 mirror" );
		check_bank( 16'hE000, 16'hFFFF, { 7'h12, 1'b1 }, "bank0 mirror" );

		$display( "-- Write bank registers" );
		write_memory( 16'h67FF, 8'h56 );
		write_memory( 16'h77FF, 8'h78 );
		$display( "-- Read bank and check read address" );
		check_bank( 16'h0000, 16'h1FFF, { 7'h78, 1'b0 }, "bank1 mirror" );
		check_bank( 16'h2000, 16'h3FFF, { 7'h78, 1'b1 }, "bank1 mirror" );
		check_bank( 16'h4000, 16'h5FFF, { 7'h56, 1'b0 }, "bank0" );
		check_bank( 16'h6000, 16'h7FFF, { 7'h56, 1'b1 }, "bank0" );
		check_bank( 16'h8000, 16'h9FFF, { 7'h78, 1'b0 }, "bank1" );
		check_bank( 16'hA000, 16'hBFFF, { 7'h78, 1'b1 }, "bank1" );
		check_bank( 16'hC000, 16'hDFFF, { 7'h56, 1'b0 }, "bank0 mirror" );
		check_bank( 16'hE000, 16'hFFFF, { 7'h56, 1'b1 }, "bank0 mirror" );

		$display( "-- Write invalid registers" );
		write_memory( 16'h6FFF, 8'h44 );
		write_memory( 16'h7FFF, 8'h55 );
		$display( "-- Read bank and check read address" );
		check_bank( 16'h0000, 16'h1FFF, { 7'h78, 1'b0 }, "bank1 mirror" );
		check_bank( 16'h2000, 16'h3FFF, { 7'h78, 1'b1 }, "bank1 mirror" );
		check_bank( 16'h4000, 16'h5FFF, { 7'h56, 1'b0 }, "bank0" );
		check_bank( 16'h6000, 16'h7FFF, { 7'h56, 1'b1 }, "bank0" );
		check_bank( 16'h8000, 16'h9FFF, { 7'h78, 1'b0 }, "bank1" );
		check_bank( 16'hA000, 16'hBFFF, { 7'h78, 1'b1 }, "bank1" );
		check_bank( 16'hC000, 16'hDFFF, { 7'h56, 1'b0 }, "bank0 mirror" );
		check_bank( 16'hE000, 16'hFFFF, { 7'h56, 1'b1 }, "bank0 mirror" );

		// --------------------------------------------------------------------
		//	check MODE2:Normal
		// --------------------------------------------------------------------
		test_no			= 200;
		$display( "Check Normal mode" );
		ff_address		= 'd0;
		mode			= 2;
		n_reset			= 0;
		@( posedge clk );
		n_reset			= 1;
		@( posedge clk );

		$display( "-- Write invalid registers" );
		for( i = 0; i < 65536; i = i + 1 ) begin
			write_memory( i, ( i & 127 ) + 13 );
		end
		$display( "-- Read bank and check read address" );
		check_bank( 16'h0000, 16'h1FFF, 8'h02, "bank2 mirror" );
		check_bank( 16'h2000, 16'h3FFF, 8'h03, "bank3 mirror" );
		check_bank( 16'h4000, 16'h5FFF, 8'h00, "bank0" );
		check_bank( 16'h6000, 16'h7FFF, 8'h01, "bank1" );
		check_bank( 16'h8000, 16'h9FFF, 8'h02, "bank2" );
		check_bank( 16'hA000, 16'hBFFF, 8'h03, "bank3" );
		check_bank( 16'hC000, 16'hDFFF, 8'h00, "bank0 mirror" );
		check_bank( 16'hE000, 16'hFFFF, 8'h01, "bank1 mirror" );

		// --------------------------------------------------------------------
		//	check MODE3:Kon4
		// --------------------------------------------------------------------
		test_no			= 300;
		$display( "Check Kon4 mode" );
		ff_address		= 'd0;
		mode			= 3;
		n_reset			= 0;
		@( posedge clk );
		n_reset			= 1;
		@( posedge clk );

		$display( "-- Read bank and check read address" );
		check_bank( 16'h0000, 16'h1FFF, 8'h02, "bank2 mirror" );
		check_bank( 16'h2000, 16'h3FFF, 8'h03, "bank3 mirror" );
		check_bank( 16'h4000, 16'h5FFF, 8'h00, "bank0 (always 0)" );
		check_bank( 16'h6000, 16'h7FFF, 8'h01, "bank1" );
		check_bank( 16'h8000, 16'h9FFF, 8'h02, "bank2" );
		check_bank( 16'hA000, 16'hBFFF, 8'h03, "bank3" );
		check_bank( 16'hC000, 16'hDFFF, 8'h00, "bank0 mirror" );
		check_bank( 16'hE000, 16'hFFFF, 8'h01, "bank1 mirror" );

		$display( "-- Write bank registers" );
		write_memory( 16'h4000, 8'h12 );	//	invalid
		write_memory( 16'h6000, 8'h34 );
		write_memory( 16'h8000, 8'h56 );
		write_memory( 16'hA000, 8'h78 );
		$display( "-- Read bank and check read address" );
		check_bank( 16'h0000, 16'h1FFF, 8'h56, "bank2 mirror" );
		check_bank( 16'h2000, 16'h3FFF, 8'h78, "bank3 mirror" );
		check_bank( 16'h4000, 16'h5FFF, 8'h00, "bank0 (always 0)" );
		check_bank( 16'h6000, 16'h7FFF, 8'h34, "bank1" );
		check_bank( 16'h8000, 16'h9FFF, 8'h56, "bank2" );
		check_bank( 16'hA000, 16'hBFFF, 8'h78, "bank3" );
		check_bank( 16'hC000, 16'hDFFF, 8'h00, "bank0 mirror" );
		check_bank( 16'hE000, 16'hFFFF, 8'h34, "bank1 mirror" );

		$display( "-- Write bank registers" );
		write_memory( 16'h5FFF, 8'h9A );	//	invalid
		write_memory( 16'h7FFF, 8'hBC );
		write_memory( 16'h9FFF, 8'hDE );
		write_memory( 16'hBFFF, 8'hF0 );
		$display( "-- Read bank and check read address" );
		check_bank( 16'h0000, 16'h1FFF, 8'hDE, "bank2 mirror" );
		check_bank( 16'h2000, 16'h3FFF, 8'hF0, "bank3 mirror" );
		check_bank( 16'h4000, 16'h5FFF, 8'h00, "bank0 (always 0)" );
		check_bank( 16'h6000, 16'h7FFF, 8'hBC, "bank1" );
		check_bank( 16'h8000, 16'h9FFF, 8'hDE, "bank2" );
		check_bank( 16'hA000, 16'hBFFF, 8'hF0, "bank3" );
		check_bank( 16'hC000, 16'hDFFF, 8'h00, "bank0 mirror" );
		check_bank( 16'hE000, 16'hFFFF, 8'hBC, "bank1 mirror" );

		// --------------------------------------------------------------------
		//	check MODE4:SCC
		// --------------------------------------------------------------------
		test_no			= 400;
		$display( "400: Check SCC mode" );
		ff_address		= 'd0;
		mode			= 4;
		n_reset			= 0;
		@( posedge clk );
		n_reset			= 1;
		@( posedge clk );

		test_no			= 401;
		$display( "-- 401: Read bank and check read address" );
		check_bank( 16'h0000, 16'h1FFF, 8'h02, "bank2 mirror" );
		check_bank( 16'h2000, 16'h3FFF, 8'h03, "bank3 mirror" );
		check_bank( 16'h4000, 16'h5FFF, 8'h00, "bank0" );
		check_bank( 16'h6000, 16'h7FFF, 8'h01, "bank1" );
		check_bank( 16'h8000, 16'h9FFF, 8'h02, "bank2" );
		check_bank( 16'hA000, 16'hBFFF, 8'h03, "bank3" );
		check_bank( 16'hC000, 16'hDFFF, 8'h00, "bank0 mirror" );
		check_bank( 16'hE000, 16'hFFFF, 8'h01, "bank1 mirror" );

		test_no			= 402;
		$display( "-- 402: Write bank registers" );
		write_memory( 16'h5000, 8'h12 );
		write_memory( 16'h7000, 8'h34 );
		write_memory( 16'h9000, 8'h56 );
		write_memory( 16'hB000, 8'h78 );
		$display( "-- 402: Read bank and check read address" );
		check_bank( 16'h0000, 16'h1FFF, 8'h56, "bank2 mirror" );
		check_bank( 16'h2000, 16'h3FFF, 8'h78, "bank3 mirror" );
		check_bank( 16'h4000, 16'h5FFF, 8'h12, "bank0" );
		check_bank( 16'h6000, 16'h7FFF, 8'h34, "bank1" );
		check_bank( 16'h8000, 16'h9FFF, 8'h56, "bank2" );
		check_bank( 16'hA000, 16'hBFFF, 8'h78, "bank3" );
		check_bank( 16'hC000, 16'hDFFF, 8'h12, "bank0 mirror" );
		check_bank( 16'hE000, 16'hFFFF, 8'h34, "bank1 mirror" );

		test_no			= 403;
		$display( "-- 403: Write bank registers" );
		write_memory( 16'h57FF, 8'h9A );
		write_memory( 16'h77FF, 8'hBC );
		write_memory( 16'h97FF, 8'hDE );
		write_memory( 16'hB7FF, 8'hF0 );
		$display( "-- 403: Read bank and check read address" );
		check_bank( 16'h0000, 16'h1FFF, 8'hDE, "bank2 mirror" );
		check_bank( 16'h2000, 16'h3FFF, 8'hF0, "bank3 mirror" );
		check_bank( 16'h4000, 16'h5FFF, 8'h9A, "bank0" );
		check_bank( 16'h6000, 16'h7FFF, 8'hBC, "bank1" );
		check_bank( 16'h8000, 16'h9FFF, 8'hDE, "bank2" );
		check_bank( 16'hA000, 16'hBFFF, 8'hF0, "bank3" );
		check_bank( 16'hC000, 16'hDFFF, 8'h9A, "bank0 mirror" );
		check_bank( 16'hE000, 16'hFFFF, 8'hBC, "bank1 mirror" );

		test_no			= 404;
		$display( "-- 404: Write invalid registers" );
		write_memory( 16'h4000, 8'h12 );
		write_memory( 16'h6000, 8'h34 );
		write_memory( 16'h8000, 8'h56 );
		write_memory( 16'hA000, 8'h78 );
		$display( "-- 404: Read bank and check read address" );
		check_bank( 16'h0000, 16'h1FFF, 8'hDE, "bank2 mirror" );
		check_bank( 16'h2000, 16'h3FFF, 8'hF0, "bank3 mirror" );
		check_bank( 16'h4000, 16'h5FFF, 8'h9A, "bank0" );
		check_bank( 16'h6000, 16'h7FFF, 8'hBC, "bank1" );
		check_bank( 16'h8000, 16'h9FFF, 8'hDE, "bank2" );
		check_bank( 16'hA000, 16'hBFFF, 8'hF0, "bank3" );
		check_bank( 16'hC000, 16'hDFFF, 8'h9A, "bank0 mirror" );
		check_bank( 16'hE000, 16'hFFFF, 8'hBC, "bank1 mirror" );

		test_no			= 405;
		$display( "-- 405: Write invalid registers" );
		write_memory( 16'h4FFF, 8'h12 );
		write_memory( 16'h6FFF, 8'h34 );
		write_memory( 16'h8FFF, 8'h56 );
		write_memory( 16'hAFFF, 8'h78 );
		$display( "-- 405: Read bank and check read address" );
		check_bank( 16'h0000, 16'h1FFF, 8'hDE, "bank2 mirror" );
		check_bank( 16'h2000, 16'h3FFF, 8'hF0, "bank3 mirror" );
		check_bank( 16'h4000, 16'h5FFF, 8'h9A, "bank0" );
		check_bank( 16'h6000, 16'h7FFF, 8'hBC, "bank1" );
		check_bank( 16'h8000, 16'h9FFF, 8'hDE, "bank2" );
		check_bank( 16'hA000, 16'hBFFF, 8'hF0, "bank3" );
		check_bank( 16'hC000, 16'hDFFF, 8'h9A, "bank0 mirror" );
		check_bank( 16'hE000, 16'hFFFF, 8'hBC, "bank1 mirror" );

		test_no			= 406;
		$display( "-- 406: Write invalid registers" );
		write_memory( 16'h5800, 8'h12 );
		write_memory( 16'h7800, 8'h34 );
		write_memory( 16'h9800, 8'h56 );
		write_memory( 16'hB800, 8'h78 );
		$display( "-- 406: Read bank and check read address" );
		check_bank( 16'h0000, 16'h1FFF, 8'hDE, "bank2 mirror" );
		check_bank( 16'h2000, 16'h3FFF, 8'hF0, "bank3 mirror" );
		check_bank( 16'h4000, 16'h5FFF, 8'h9A, "bank0" );
		check_bank( 16'h6000, 16'h7FFF, 8'hBC, "bank1" );
		check_bank( 16'h8000, 16'h9FFF, 8'hDE, "bank2" );
		check_bank( 16'hA000, 16'hBFFF, 8'hF0, "bank3" );
		check_bank( 16'hC000, 16'hDFFF, 8'h9A, "bank0 mirror" );
		check_bank( 16'hE000, 16'hFFFF, 8'hBC, "bank1 mirror" );

		test_no			= 407;
		$display( "-- 407: Write invalid registers" );
		write_memory( 16'h5FFF, 8'h12 );
		write_memory( 16'h7FFF, 8'h34 );
		write_memory( 16'h9FFF, 8'h56 );
		write_memory( 16'hBFFF, 8'h78 );
		$display( "-- 407: Read bank and check read address" );
		check_bank( 16'h0000, 16'h1FFF, 8'hDE, "bank2 mirror" );
		check_bank( 16'h2000, 16'h3FFF, 8'hF0, "bank3 mirror" );
		check_bank( 16'h4000, 16'h5FFF, 8'h9A, "bank0" );
		check_bank( 16'h6000, 16'h7FFF, 8'hBC, "bank1" );
		check_bank( 16'h8000, 16'h9FFF, 8'hDE, "bank2" );
		check_bank( 16'hA000, 16'hBFFF, 8'hF0, "bank3" );
		check_bank( 16'hC000, 16'hDFFF, 8'h9A, "bank0 mirror" );
		check_bank( 16'hE000, 16'hFFFF, 8'hBC, "bank1 mirror" );

		test_no			= 408;
		$display( "-- 408: Write bank registers" );
		write_memory( 16'h5000, 8'h3f );
		write_memory( 16'h7000, 8'h3f );
		write_memory( 16'h9000, 8'h3f );
		write_memory( 16'hB000, 8'h3f );
		$display( "-- 408: Read bank and check read address" );
		check_bank( 16'h0000, 16'h1FFF, 8'h3F, "bank2 mirror" );
		check_bank( 16'h2000, 16'h3FFF, 8'h3F, "bank3 mirror" );
		check_bank( 16'h4000, 16'h5FFF, 8'h3F, "bank0" );
		check_bank( 16'h6000, 16'h7FFF, 8'h3F, "bank1" );
		check_bank( 16'hA000, 16'hBFFF, 8'h3F, "bank3" );
		check_bank( 16'hC000, 16'hDFFF, 8'h3F, "bank0 mirror" );
		check_bank( 16'hE000, 16'hFFFF, 8'h3F, "bank1 mirror" );

		test_no			= 409;
		$display( "-- 409: Read/Write SCC bank" );
		ff_address = 16'h0000;
		ff_wdata = 8'h00;
		write_memory( 16'h9800, 8'h12 );
		assert( ff_address == 16'h0000 );
		assert( ff_wdata == 8'h00 );

		// --------------------------------------------------------------------
		//	check MODE5:SCC+
		// --------------------------------------------------------------------
		test_no			= 500;
		$display( "500: Check SCC+ mode" );
		ff_address		= 'd0;
		mode			= 5;
		n_reset			= 0;
		@( posedge clk );
		n_reset			= 1;
		@( posedge clk );

		// --------------------------------------------------------------------
		//	check MODE6:Generic8
		// --------------------------------------------------------------------
		test_no			= 600;
		$display( "600: Check Generic8 mode" );
		ff_address		= 'd0;
		mode			= 6;
		n_reset			= 0;
		@( posedge clk );
		n_reset			= 1;
		@( posedge clk );

		$display( "-- Read bank and check read address" );
		check_bank( 16'h0000, 16'h1FFF, 8'h02, "bank2 mirror" );
		check_bank( 16'h2000, 16'h3FFF, 8'h03, "bank3 mirror" );
		check_bank( 16'h4000, 16'h5FFF, 8'h00, "bank0" );
		check_bank( 16'h6000, 16'h7FFF, 8'h01, "bank1" );
		check_bank( 16'h8000, 16'h9FFF, 8'h02, "bank2" );
		check_bank( 16'hA000, 16'hBFFF, 8'h03, "bank3" );
		check_bank( 16'hC000, 16'hDFFF, 8'h00, "bank0 mirror" );
		check_bank( 16'hE000, 16'hFFFF, 8'h01, "bank1 mirror" );

		$display( "-- Write bank registers" );
		write_memory( 16'h4000, 8'h12 );
		write_memory( 16'h6000, 8'h34 );
		write_memory( 16'h8000, 8'h56 );
		write_memory( 16'hA000, 8'h78 );
		$display( "-- Read bank and check read address" );
		check_bank( 16'h0000, 16'h1FFF, 8'h56, "bank2 mirror" );
		check_bank( 16'h2000, 16'h3FFF, 8'h78, "bank3 mirror" );
		check_bank( 16'h4000, 16'h5FFF, 8'h12, "bank0" );
		check_bank( 16'h6000, 16'h7FFF, 8'h34, "bank1" );
		check_bank( 16'h8000, 16'h9FFF, 8'h56, "bank2" );
		check_bank( 16'hA000, 16'hBFFF, 8'h78, "bank3" );
		check_bank( 16'hC000, 16'hDFFF, 8'h12, "bank0 mirror" );
		check_bank( 16'hE000, 16'hFFFF, 8'h34, "bank1 mirror" );

		$display( "-- Write bank registers" );
		write_memory( 16'h47FF, 8'h9A );
		write_memory( 16'h67FF, 8'hBC );
		write_memory( 16'h87FF, 8'hDE );
		write_memory( 16'hA7FF, 8'hF0 );
		$display( "-- Read bank and check read address" );
		check_bank( 16'h0000, 16'h1FFF, 8'hDE, "bank2 mirror" );
		check_bank( 16'h2000, 16'h3FFF, 8'hF0, "bank3 mirror" );
		check_bank( 16'h4000, 16'h5FFF, 8'h9A, "bank0" );
		check_bank( 16'h6000, 16'h7FFF, 8'hBC, "bank1" );
		check_bank( 16'h8000, 16'h9FFF, 8'hDE, "bank2" );
		check_bank( 16'hA000, 16'hBFFF, 8'hF0, "bank3" );
		check_bank( 16'hC000, 16'hDFFF, 8'h9A, "bank0 mirror" );
		check_bank( 16'hE000, 16'hFFFF, 8'hBC, "bank1 mirror" );

		$display( "-- Write bank registers" );
		write_memory( 16'h5000, 8'hA9 );
		write_memory( 16'h7000, 8'hCB );
		write_memory( 16'h9000, 8'hED );
		write_memory( 16'hB000, 8'h0F );
		$display( "-- Read bank and check read address" );
		check_bank( 16'h0000, 16'h1FFF, 8'hED, "bank2 mirror" );
		check_bank( 16'h2000, 16'h3FFF, 8'h0F, "bank3 mirror" );
		check_bank( 16'h4000, 16'h5FFF, 8'hA9, "bank0" );
		check_bank( 16'h6000, 16'h7FFF, 8'hCB, "bank1" );
		check_bank( 16'h8000, 16'h9FFF, 8'hED, "bank2" );
		check_bank( 16'hA000, 16'hBFFF, 8'h0F, "bank3" );
		check_bank( 16'hC000, 16'hDFFF, 8'hA9, "bank0 mirror" );
		check_bank( 16'hE000, 16'hFFFF, 8'hCB, "bank1 mirror" );

		$display( "-- Write bank registers" );
		write_memory( 16'h57FF, 8'hED );
		write_memory( 16'h77FF, 8'h0F );
		write_memory( 16'h97FF, 8'hA9 );
		write_memory( 16'hB7FF, 8'hCB );
		$display( "-- Read bank and check read address" );
		check_bank( 16'h0000, 16'h1FFF, 8'hA9, "bank2 mirror" );
		check_bank( 16'h2000, 16'h3FFF, 8'hCB, "bank3 mirror" );
		check_bank( 16'h4000, 16'h5FFF, 8'hED, "bank0" );
		check_bank( 16'h6000, 16'h7FFF, 8'h0F, "bank1" );
		check_bank( 16'h8000, 16'h9FFF, 8'hA9, "bank2" );
		check_bank( 16'hA000, 16'hBFFF, 8'hCB, "bank3" );
		check_bank( 16'hC000, 16'hDFFF, 8'hED, "bank0 mirror" );
		check_bank( 16'hE000, 16'hFFFF, 8'h0F, "bank1 mirror" );

		$display( "-- Write invalid registers" );
		write_memory( 16'h4800, 8'h12 );
		write_memory( 16'h6800, 8'h34 );
		write_memory( 16'h8800, 8'h56 );
		write_memory( 16'hA800, 8'h78 );
		$display( "-- Read bank and check read address" );
		check_bank( 16'h0000, 16'h1FFF, 8'hA9, "bank2 mirror" );
		check_bank( 16'h2000, 16'h3FFF, 8'hCB, "bank3 mirror" );
		check_bank( 16'h4000, 16'h5FFF, 8'hED, "bank0" );
		check_bank( 16'h6000, 16'h7FFF, 8'h0F, "bank1" );
		check_bank( 16'h8000, 16'h9FFF, 8'hA9, "bank2" );
		check_bank( 16'hA000, 16'hBFFF, 8'hCB, "bank3" );
		check_bank( 16'hC000, 16'hDFFF, 8'hED, "bank0 mirror" );
		check_bank( 16'hE000, 16'hFFFF, 8'h0F, "bank1 mirror" );

		$display( "-- Write invalid registers" );
		write_memory( 16'h4FFF, 8'h9A );
		write_memory( 16'h6FFF, 8'hBC );
		write_memory( 16'h8FFF, 8'hDE );
		write_memory( 16'hAFFF, 8'hF0 );
		$display( "-- Read bank and check read address" );
		check_bank( 16'h0000, 16'h1FFF, 8'hA9, "bank2 mirror" );
		check_bank( 16'h2000, 16'h3FFF, 8'hCB, "bank3 mirror" );
		check_bank( 16'h4000, 16'h5FFF, 8'hED, "bank0" );
		check_bank( 16'h6000, 16'h7FFF, 8'h0F, "bank1" );
		check_bank( 16'h8000, 16'h9FFF, 8'hA9, "bank2" );
		check_bank( 16'hA000, 16'hBFFF, 8'hCB, "bank3" );
		check_bank( 16'hC000, 16'hDFFF, 8'hED, "bank0 mirror" );
		check_bank( 16'hE000, 16'hFFFF, 8'h0F, "bank1 mirror" );

		$display( "-- Write invalid registers" );
		write_memory( 16'h5800, 8'hA9 );
		write_memory( 16'h7800, 8'hCB );
		write_memory( 16'h9800, 8'hED );
		write_memory( 16'hB800, 8'h0F );
		$display( "-- Read bank and check read address" );
		check_bank( 16'h0000, 16'h1FFF, 8'hA9, "bank2 mirror" );
		check_bank( 16'h2000, 16'h3FFF, 8'hCB, "bank3 mirror" );
		check_bank( 16'h4000, 16'h5FFF, 8'hED, "bank0" );
		check_bank( 16'h6000, 16'h7FFF, 8'h0F, "bank1" );
		check_bank( 16'h8000, 16'h9FFF, 8'hA9, "bank2" );
		check_bank( 16'hA000, 16'hBFFF, 8'hCB, "bank3" );
		check_bank( 16'hC000, 16'hDFFF, 8'hED, "bank0 mirror" );
		check_bank( 16'hE000, 16'hFFFF, 8'h0F, "bank1 mirror" );

		$display( "-- Write invalid registers" );
		write_memory( 16'h5FFF, 8'h11 );
		write_memory( 16'h7FFF, 8'h22 );
		write_memory( 16'h9FFF, 8'h33 );
		write_memory( 16'hBFFF, 8'h44 );
		$display( "-- Read bank and check read address" );
		check_bank( 16'h0000, 16'h1FFF, 8'hA9, "bank2 mirror" );
		check_bank( 16'h2000, 16'h3FFF, 8'hCB, "bank3 mirror" );
		check_bank( 16'h4000, 16'h5FFF, 8'hED, "bank0" );
		check_bank( 16'h6000, 16'h7FFF, 8'h0F, "bank1" );
		check_bank( 16'h8000, 16'h9FFF, 8'hA9, "bank2" );
		check_bank( 16'hA000, 16'hBFFF, 8'hCB, "bank3" );
		check_bank( 16'hC000, 16'hDFFF, 8'hED, "bank0 mirror" );
		check_bank( 16'hE000, 16'hFFFF, 8'h0F, "bank1 mirror" );

		// --------------------------------------------------------------------
		//	check MODE7:Generic16
		// --------------------------------------------------------------------
		test_no			= 700;
		$display( "700: Check Generic16 mode" );
		ff_address		= 'd0;
		mode			= 7;
		n_reset			= 0;
		@( posedge clk );
		n_reset			= 1;
		@( posedge clk );

		test_no			= 701;
		$display( "-- 701: Read bank and check read address" );
		check_bank( 16'h0000, 16'h1FFF, { 7'h01, 1'b0 }, "bank2 mirror" );
		check_bank( 16'h2000, 16'h3FFF, { 7'h01, 1'b1 }, "bank3 mirror" );
		check_bank( 16'h4000, 16'h5FFF, { 7'h00, 1'b0 }, "bank0" );
		check_bank( 16'h6000, 16'h7FFF, { 7'h00, 1'b1 }, "bank1" );
		check_bank( 16'h8000, 16'h9FFF, { 7'h01, 1'b0 }, "bank2" );
		check_bank( 16'hA000, 16'hBFFF, { 7'h01, 1'b1 }, "bank3" );
		check_bank( 16'hC000, 16'hDFFF, { 7'h00, 1'b0 }, "bank0 mirror" );
		check_bank( 16'hE000, 16'hFFFF, { 7'h00, 1'b1 }, "bank1 mirror" );

		test_no			= 702;
		$display( "-- 702: Write bank registers" );
		write_memory( 16'h4000, 8'h12 );
		write_memory( 16'h8000, 8'h34 );
		$display( "-- 702: Read bank and check read address" );
		check_bank( 16'h0000, 16'h1FFF, { 7'h34, 1'b0 }, "bank2 mirror" );
		check_bank( 16'h2000, 16'h3FFF, { 7'h34, 1'b1 }, "bank3 mirror" );
		check_bank( 16'h4000, 16'h5FFF, { 7'h12, 1'b0 }, "bank0" );
		check_bank( 16'h6000, 16'h7FFF, { 7'h12, 1'b1 }, "bank1" );
		check_bank( 16'h8000, 16'h9FFF, { 7'h34, 1'b0 }, "bank2" );
		check_bank( 16'hA000, 16'hBFFF, { 7'h34, 1'b1 }, "bank3" );
		check_bank( 16'hC000, 16'hDFFF, { 7'h12, 1'b0 }, "bank0 mirror" );
		check_bank( 16'hE000, 16'hFFFF, { 7'h12, 1'b1 }, "bank1 mirror" );

		test_no			= 703;
		$display( "-- 703: Write bank registers" );
		write_memory( 16'h47FF, 8'h9A );
		write_memory( 16'h87FF, 8'hDE );
		$display( "-- 703: Read bank and check read address" );
		check_bank( 16'h0000, 16'h1FFF, { 7'h5E, 1'b0 }, "bank2 mirror" );
		check_bank( 16'h2000, 16'h3FFF, { 7'h5E, 1'b1 }, "bank3 mirror" );
		check_bank( 16'h4000, 16'h5FFF, { 7'h1A, 1'b0 }, "bank0" );
		check_bank( 16'h6000, 16'h7FFF, { 7'h1A, 1'b1 }, "bank1" );
		check_bank( 16'h8000, 16'h9FFF, { 7'h5E, 1'b0 }, "bank2" );
		check_bank( 16'hA000, 16'hBFFF, { 7'h5E, 1'b1 }, "bank3" );
		check_bank( 16'hC000, 16'hDFFF, { 7'h1A, 1'b0 }, "bank0 mirror" );
		check_bank( 16'hE000, 16'hFFFF, { 7'h1A, 1'b1 }, "bank1 mirror" );

		test_no			= 704;
		$display( "-- 704: Write bank registers" );
		write_memory( 16'h5000, 8'hA9 );
		write_memory( 16'h9000, 8'hED );
		$display( "-- 704: Read bank and check read address" );
		check_bank( 16'h0000, 16'h1FFF, { 7'h6D, 1'b0 }, "bank2 mirror" );
		check_bank( 16'h2000, 16'h3FFF, { 7'h6D, 1'b1 }, "bank3 mirror" );
		check_bank( 16'h4000, 16'h5FFF, { 7'h29, 1'b0 }, "bank0" );
		check_bank( 16'h6000, 16'h7FFF, { 7'h29, 1'b1 }, "bank1" );
		check_bank( 16'h8000, 16'h9FFF, { 7'h6D, 1'b0 }, "bank2" );
		check_bank( 16'hA000, 16'hBFFF, { 7'h6D, 1'b1 }, "bank3" );
		check_bank( 16'hC000, 16'hDFFF, { 7'h29, 1'b0 }, "bank0 mirror" );
		check_bank( 16'hE000, 16'hFFFF, { 7'h29, 1'b1 }, "bank1 mirror" );

		test_no			= 705;
		$display( "-- 705: Write bank registers" );
		write_memory( 16'h57FF, 8'hED );
		write_memory( 16'h97FF, 8'hA9 );
		$display( "-- 705: Read bank and check read address" );
		check_bank( 16'h0000, 16'h1FFF, { 7'h29, 1'b0 }, "bank2 mirror" );
		check_bank( 16'h2000, 16'h3FFF, { 7'h29, 1'b1 }, "bank3 mirror" );
		check_bank( 16'h4000, 16'h5FFF, { 7'h6D, 1'b0 }, "bank0" );
		check_bank( 16'h6000, 16'h7FFF, { 7'h6D, 1'b1 }, "bank1" );
		check_bank( 16'h8000, 16'h9FFF, { 7'h29, 1'b0 }, "bank2" );
		check_bank( 16'hA000, 16'hBFFF, { 7'h29, 1'b1 }, "bank3" );
		check_bank( 16'hC000, 16'hDFFF, { 7'h6D, 1'b0 }, "bank0 mirror" );
		check_bank( 16'hE000, 16'hFFFF, { 7'h6D, 1'b1 }, "bank1 mirror" );

		test_no			= 706;
		$display( "-- 706: Write invalid registers" );
		write_memory( 16'h4800, 8'h12 );
		write_memory( 16'h6800, 8'h34 );
		write_memory( 16'h8800, 8'h56 );
		write_memory( 16'hA800, 8'h78 );
		$display( "-- 706: Read bank and check read address" );
		check_bank( 16'h0000, 16'h1FFF, { 7'h29, 1'b0 }, "bank2 mirror" );
		check_bank( 16'h2000, 16'h3FFF, { 7'h29, 1'b1 }, "bank3 mirror" );
		check_bank( 16'h4000, 16'h5FFF, { 7'h6D, 1'b0 }, "bank0" );
		check_bank( 16'h6000, 16'h7FFF, { 7'h6D, 1'b1 }, "bank1" );
		check_bank( 16'h8000, 16'h9FFF, { 7'h29, 1'b0 }, "bank2" );
		check_bank( 16'hA000, 16'hBFFF, { 7'h29, 1'b1 }, "bank3" );
		check_bank( 16'hC000, 16'hDFFF, { 7'h6D, 1'b0 }, "bank0 mirror" );
		check_bank( 16'hE000, 16'hFFFF, { 7'h6D, 1'b1 }, "bank1 mirror" );

		test_no			= 707;
		$display( "-- 707: Write invalid registers" );
		write_memory( 16'h4FFF, 8'h9A );
		write_memory( 16'h6FFF, 8'hBC );
		write_memory( 16'h8FFF, 8'hDE );
		write_memory( 16'hAFFF, 8'hF0 );
		$display( "-- 707: Read bank and check read address" );
		check_bank( 16'h0000, 16'h1FFF, { 7'h29, 1'b0 }, "bank2 mirror" );
		check_bank( 16'h2000, 16'h3FFF, { 7'h29, 1'b1 }, "bank3 mirror" );
		check_bank( 16'h4000, 16'h5FFF, { 7'h6D, 1'b0 }, "bank0" );
		check_bank( 16'h6000, 16'h7FFF, { 7'h6D, 1'b1 }, "bank1" );
		check_bank( 16'h8000, 16'h9FFF, { 7'h29, 1'b0 }, "bank2" );
		check_bank( 16'hA000, 16'hBFFF, { 7'h29, 1'b1 }, "bank3" );
		check_bank( 16'hC000, 16'hDFFF, { 7'h6D, 1'b0 }, "bank0 mirror" );
		check_bank( 16'hE000, 16'hFFFF, { 7'h6D, 1'b1 }, "bank1 mirror" );

		test_no			= 708;
		$display( "-- 708: Write invalid registers" );
		write_memory( 16'h5800, 8'hA9 );
		write_memory( 16'h7800, 8'hCB );
		write_memory( 16'h9800, 8'hED );
		write_memory( 16'hB800, 8'h0F );
		$display( "-- 708: Read bank and check read address" );
		check_bank( 16'h0000, 16'h1FFF, { 7'h29, 1'b0 }, "bank2 mirror" );
		check_bank( 16'h2000, 16'h3FFF, { 7'h29, 1'b1 }, "bank3 mirror" );
		check_bank( 16'h4000, 16'h5FFF, { 7'h6D, 1'b0 }, "bank0" );
		check_bank( 16'h6000, 16'h7FFF, { 7'h6D, 1'b1 }, "bank1" );
		check_bank( 16'h8000, 16'h9FFF, { 7'h29, 1'b0 }, "bank2" );
		check_bank( 16'hA000, 16'hBFFF, { 7'h29, 1'b1 }, "bank3" );
		check_bank( 16'hC000, 16'hDFFF, { 7'h6D, 1'b0 }, "bank0 mirror" );
		check_bank( 16'hE000, 16'hFFFF, { 7'h6D, 1'b1 }, "bank1 mirror" );

		test_no			= 709;
		$display( "-- 709: Write invalid registers" );
		write_memory( 16'h5FFF, 8'h11 );
		write_memory( 16'h7FFF, 8'h22 );
		write_memory( 16'h9FFF, 8'h33 );
		write_memory( 16'hBFFF, 8'h44 );
		$display( "-- 709: Read bank and check read address" );
		check_bank( 16'h0000, 16'h1FFF, { 7'h29, 1'b0 }, "bank2 mirror" );
		check_bank( 16'h2000, 16'h3FFF, { 7'h29, 1'b1 }, "bank3 mirror" );
		check_bank( 16'h4000, 16'h5FFF, { 7'h6D, 1'b0 }, "bank0" );
		check_bank( 16'h6000, 16'h7FFF, { 7'h6D, 1'b1 }, "bank1" );
		check_bank( 16'h8000, 16'h9FFF, { 7'h29, 1'b0 }, "bank2" );
		check_bank( 16'hA000, 16'hBFFF, { 7'h29, 1'b1 }, "bank3" );
		check_bank( 16'hC000, 16'hDFFF, { 7'h6D, 1'b0 }, "bank0 mirror" );
		check_bank( 16'hE000, 16'hFFFF, { 7'h6D, 1'b1 }, "bank1 mirror" );

		$finish;
	end
endmodule
