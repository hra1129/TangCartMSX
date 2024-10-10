// -----------------------------------------------------------------------------
//	Test of ip_kanjirom.v
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
//		KanjiROM
// -----------------------------------------------------------------------------

module tb ();
	localparam		clk_base	= 1000000000/21477;
	//	Internal I/F
	reg				n_reset;
	reg				clk;
	reg				enable_jis1;
	reg				enable_jis2;
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
	reg				busy;
	wire	[21:0]	address;
	reg		[7:0]	rdata;
	reg				rdata_en;
	integer			test_no;
	reg		[21:0]	ff_address;

	// --------------------------------------------------------------------
	//	DUT
	// --------------------------------------------------------------------
	ip_kanjirom u_kanjirom (
		.n_reset			( n_reset			),
		.clk				( clk				),
		.enable_jis1		( enable_jis1		),
		.enable_jis2		( enable_jis2		),
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
		.busy				( busy				),
		.address			( address			),
		.rdata				( rdata				),
		.rdata_en			( rdata_en			)
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
		bus_address		<= address;
		bus_read		<= 1'b1;
		bus_memory		<= 1'b1;
		@( posedge clk );

		bus_address		<= 'd0;
		bus_read		<= 1'b0;
		bus_memory		<= 1'b0;
		@( posedge clk );

		while( !bus_read_ready ) begin
			@( posedge clk );
		end

		assert( bus_read_data == data );
		@( posedge clk );
		@( posedge clk );
		@( posedge clk );
	endtask: read_memory

	task read_io(
		input	[15:0]	address,
		input	[7:0]	data
	);
		bus_address		<= address;
		bus_read		<= 1'b1;
		bus_io			<= 1'b1;
		@( posedge clk );

		bus_address		<= 'd0;
		bus_read		<= 1'b0;
		bus_io			<= 1'b0;
		@( posedge clk );

		while( !bus_read_ready ) begin
			@( posedge clk );
		end

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
			end
			@( posedge clk );
		end
	endtask: address_latch

	// --------------------------------------------------------------------
	//	Test bench
	// --------------------------------------------------------------------
	initial begin
		test_no			= 0;
		n_reset			= 0;
		clk				= 0;
		bus_address		= 0;
		bus_write_data	= 0;
		bus_read		= 0;
		bus_write		= 0;
		bus_io			= 0;
		bus_memory		= 0;
		enable_jis1		= 0;
		enable_jis2		= 0;

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
		test_no			= 1;
		$display( "Check CS port" );
		assert( bus_io_cs == 1'b1 );
		assert( bus_memory_cs == 1'b0 );
		@( posedge clk );

		// --------------------------------------------------------------------
		//	check JIS1
		// --------------------------------------------------------------------
		test_no			= 2;
		$display( "Check JIS1" );
		ff_address		= 'd0;
		enable_jis1		= 1;
		enable_jis2		= 1;
		write_io( 'h00D8, 8'h12 );
		write_io( 'h00D9, 8'hAB );

		rdata			<= 8'h34;
		read_io( 'h00D9, 8'h34 );
		$display( "  address: 0x%06X", { 5'b11000, 6'h2B, 6'h12, 5'h0 } );
		assert( ff_address == { 5'b11000, 6'h2B, 6'h12, 5'h0 } );

		rdata			<= 8'h56;
		read_io( 'h00D9, 8'h56 );
		$display( "  address: 0x%06X", { 5'b11000, 6'h2B, 6'h12, 5'h1 } );
		assert( ff_address == { 5'b11000, 6'h2B, 6'h12, 5'h1 } );

		rdata			<= 8'h78;
		read_io( 'h00D9, 8'h78 );
		$display( "  address: 0x%06X", { 5'b11000, 6'h2B, 6'h12, 5'h2 } );
		assert( ff_address == { 5'b11000, 6'h2B, 6'h12, 5'h2 } );

		rdata			<= 8'h9A;
		read_io( 'h00D9, 8'h9A );
		$display( "  address: 0x%06X", { 5'b11000, 6'h2B, 6'h12, 5'h3 } );
		assert( ff_address == { 5'b11000, 6'h2B, 6'h12, 5'h3 } );

		rdata			<= 8'hAB;
		read_io( 'h00D9, 8'hAB );
		$display( "  address: 0x%06X", { 5'b11000, 6'h2B, 6'h12, 5'h4 } );
		assert( ff_address == { 5'b11000, 6'h2B, 6'h12, 5'h4 } );

		rdata			<= 8'hCD;
		read_io( 'h00D9, 8'hCD );
		$display( "  address: 0x%06X", { 5'b11000, 6'h2B, 6'h12, 5'h5 } );
		assert( ff_address == { 5'b11000, 6'h2B, 6'h12, 5'h5 } );

		rdata			<= 8'hEF;
		read_io( 'h00D9, 8'hEF );
		$display( "  address: 0x%06X", { 5'b11000, 6'h2B, 6'h12, 5'h6 } );
		assert( ff_address == { 5'b11000, 6'h2B, 6'h12, 5'h6 } );

		rdata			<= 8'h01;
		read_io( 'h00D9, 8'h01 );
		$display( "  address: 0x%06X", { 5'b11000, 6'h2B, 6'h12, 5'h7 } );
		assert( ff_address == { 5'b11000, 6'h2B, 6'h12, 5'h7 } );

		rdata			<= 8'h23;
		read_io( 'h00D9, 8'h23 );
		$display( "  address: 0x%06X", { 5'b11000, 6'h2B, 6'h12, 5'h8 } );
		assert( ff_address == { 5'b11000, 6'h2B, 6'h12, 5'h8 } );

		rdata			<= 8'h45;
		read_io( 'h00D9, 8'h45 );
		$display( "  address: 0x%06X", { 5'b11000, 6'h2B, 6'h12, 5'h9 } );
		assert( ff_address == { 5'b11000, 6'h2B, 6'h12, 5'h9 } );

		rdata			<= 8'h67;
		read_io( 'h00D9, 8'h67 );
		$display( "  address: 0x%06X", { 5'b11000, 6'h2B, 6'h12, 5'hA } );
		assert( ff_address == { 5'b11000, 6'h2B, 6'h12, 5'hA } );

		rdata			<= 8'h89;
		read_io( 'h00D9, 8'h89 );
		$display( "  address: 0x%06X", { 5'b11000, 6'h2B, 6'h12, 5'hB } );
		assert( ff_address == { 5'b11000, 6'h2B, 6'h12, 5'hB } );

		rdata			<= 8'hAB;
		read_io( 'h00D9, 8'hAB );
		$display( "  address: 0x%06X", { 5'b11000, 6'h2B, 6'h12, 5'hC } );
		assert( ff_address == { 5'b11000, 6'h2B, 6'h12, 5'hC } );

		rdata			<= 8'hCD;
		read_io( 'h00D9, 8'hCD );
		$display( "  address: 0x%06X", { 5'b11000, 6'h2B, 6'h12, 5'hD } );
		assert( ff_address == { 5'b11000, 6'h2B, 6'h12, 5'hD } );

		rdata			<= 8'hEF;
		read_io( 'h00D9, 8'hEF );
		$display( "  address: 0x%06X", { 5'b11000, 6'h2B, 6'h12, 5'hE } );
		assert( ff_address == { 5'b11000, 6'h2B, 6'h12, 5'hE } );

		rdata			<= 8'h01;
		read_io( 'h00D9, 8'h01 );
		$display( "  address: 0x%06X", { 5'b11000, 6'h2B, 6'h12, 5'hF } );
		assert( ff_address == { 5'b11000, 6'h2B, 6'h12, 5'hF } );

		// --------------------------------------------------------------------
		//	check JIS2
		// --------------------------------------------------------------------
		test_no			= 3;
		$display( "Check JIS2" );
		ff_address		= 'd0;
		enable_jis1		= 1;
		enable_jis2		= 1;
		write_io( 'h00DA, 8'h12 );
		write_io( 'h00DB, 8'hAB );

		rdata			<= 8'h34;
		read_io( 'h00DB, 8'h34 );
		$display( "  address: 0x%06X", { 5'b11001, 6'h2B, 6'h12, 5'h0 } );
		assert( ff_address == { 5'b11001, 6'h2B, 6'h12, 5'h0 } );

		rdata			<= 8'h56;
		read_io( 'h00DB, 8'h56 );
		$display( "  address: 0x%06X", { 5'b11001, 6'h2B, 6'h12, 5'h1 } );
		assert( ff_address == { 5'b11001, 6'h2B, 6'h12, 5'h1 } );

		rdata			<= 8'h78;
		read_io( 'h00DB, 8'h78 );
		$display( "  address: 0x%06X", { 5'b11001, 6'h2B, 6'h12, 5'h2 } );
		assert( ff_address == { 5'b11001, 6'h2B, 6'h12, 5'h2 } );

		rdata			<= 8'h9A;
		read_io( 'h00DB, 8'h9A );
		$display( "  address: 0x%06X", { 5'b11001, 6'h2B, 6'h12, 5'h3 } );
		assert( ff_address == { 5'b11001, 6'h2B, 6'h12, 5'h3 } );

		rdata			<= 8'hAB;
		read_io( 'h00DB, 8'hAB );
		$display( "  address: 0x%06X", { 5'b11001, 6'h2B, 6'h12, 5'h4 } );
		assert( ff_address == { 5'b11001, 6'h2B, 6'h12, 5'h4 } );

		rdata			<= 8'hCD;
		read_io( 'h00DB, 8'hCD );
		$display( "  address: 0x%06X", { 5'b11001, 6'h2B, 6'h12, 5'h5 } );
		assert( ff_address == { 5'b11001, 6'h2B, 6'h12, 5'h5 } );

		rdata			<= 8'hEF;
		read_io( 'h00DB, 8'hEF );
		$display( "  address: 0x%06X", { 5'b11001, 6'h2B, 6'h12, 5'h6 } );
		assert( ff_address == { 5'b11001, 6'h2B, 6'h12, 5'h6 } );

		rdata			<= 8'h01;
		read_io( 'h00DB, 8'h01 );
		$display( "  address: 0x%06X", { 5'b11001, 6'h2B, 6'h12, 5'h7 } );
		assert( ff_address == { 5'b11001, 6'h2B, 6'h12, 5'h7 } );

		rdata			<= 8'h23;
		read_io( 'h00DB, 8'h23 );
		$display( "  address: 0x%06X", { 5'b11001, 6'h2B, 6'h12, 5'h8 } );
		assert( ff_address == { 5'b11001, 6'h2B, 6'h12, 5'h8 } );

		rdata			<= 8'h45;
		read_io( 'h00DB, 8'h45 );
		$display( "  address: 0x%06X", { 5'b11001, 6'h2B, 6'h12, 5'h9 } );
		assert( ff_address == { 5'b11001, 6'h2B, 6'h12, 5'h9 } );

		rdata			<= 8'h67;
		read_io( 'h00DB, 8'h67 );
		$display( "  address: 0x%06X", { 5'b11001, 6'h2B, 6'h12, 5'hA } );
		assert( ff_address == { 5'b11001, 6'h2B, 6'h12, 5'hA } );

		rdata			<= 8'h89;
		read_io( 'h00DB, 8'h89 );
		$display( "  address: 0x%06X", { 5'b11001, 6'h2B, 6'h12, 5'hB } );
		assert( ff_address == { 5'b11001, 6'h2B, 6'h12, 5'hB } );

		rdata			<= 8'hAB;
		read_io( 'h00DB, 8'hAB );
		$display( "  address: 0x%06X", { 5'b11001, 6'h2B, 6'h12, 5'hC } );
		assert( ff_address == { 5'b11001, 6'h2B, 6'h12, 5'hC } );

		rdata			<= 8'hCD;
		read_io( 'h00DB, 8'hCD );
		$display( "  address: 0x%06X", { 5'b11001, 6'h2B, 6'h12, 5'hD } );
		assert( ff_address == { 5'b11001, 6'h2B, 6'h12, 5'hD } );

		rdata			<= 8'hEF;
		read_io( 'h00DB, 8'hEF );
		$display( "  address: 0x%06X", { 5'b11001, 6'h2B, 6'h12, 5'hE } );
		assert( ff_address == { 5'b11001, 6'h2B, 6'h12, 5'hE } );

		rdata			<= 8'h01;
		read_io( 'h00DB, 8'h01 );
		$display( "  address: 0x%06X", { 5'b11001, 6'h2B, 6'h12, 5'hF } );
		assert( ff_address == { 5'b11001, 6'h2B, 6'h12, 5'hF } );

		$finish;
	end
endmodule
