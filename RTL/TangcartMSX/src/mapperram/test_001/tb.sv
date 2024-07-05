// -----------------------------------------------------------------------------
//	Test of ip_mapperram.v
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
//		Extended slot
// -----------------------------------------------------------------------------

module tb ();
	localparam		clk_base	= 1000000000/21477;
	//	Internal I/F
	reg				n_reset;
	reg				clk;
	//	MSX-50BUS
	reg		[15:0]	bus_address;
	wire			bus_read_ready;
	wire	[7:0]	bus_read_data;
	reg		[7:0]	bus_write_data;
	reg				bus_io_read;
	reg				bus_io_write;
	reg				bus_memory_read;
	reg				bus_memory_write;
	//	RAM I/F
	wire			rd;
	wire			wr;
	reg				busy;
	wire	[21:0]	address;
	wire	[7:0]	wdata;
	reg		[7:0]	rdata;
	reg				rdata_en;
	integer			test_no;
	reg				ff_rd;
	reg				ff_wr;
	reg		[21:0]	ff_address;
	reg		[7:0]	ff_wdata;
	reg		[7:0]	ff_rdata;

	// --------------------------------------------------------------------
	//	DUT
	// --------------------------------------------------------------------
	ip_mapperram u_mapperram (
		.n_reset			( n_reset			),
		.clk				( clk				),
		.bus_address		( bus_address		),
		.bus_read_ready		( bus_read_ready	),
		.bus_read_data		( bus_read_data		),
		.bus_write_data		( bus_write_data	),
		.bus_io_read		( bus_io_read		),
		.bus_io_write		( bus_io_write		),
		.bus_memory_read	( bus_memory_read	),
		.bus_memory_write	( bus_memory_write	),
		.rd					( rd				),
		.wr					( wr				),
		.busy				( busy				),
		.address			( address			),
		.wdata				( wdata				),
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
		bus_memory_write<= 1'b1;
		@( posedge clk );

		bus_address		<= 'd0;
		bus_write_data	<= 'd0;
		bus_memory_write<= 1'b0;
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
		bus_io_write	<= 1'b1;
		@( posedge clk );

		bus_address		<= 'd0;
		bus_write_data	<= 'd0;
		bus_io_write	<= 1'b0;
		@( posedge clk );
		@( posedge clk );
		@( posedge clk );
	endtask: write_io

	task read_memory(
		input	[15:0]	address,
		input	[7:0]	data
	);
		bus_address		<= address;
		bus_memory_read	<= 1'b1;
		@( posedge clk );

		bus_address		<= 'd0;
		bus_memory_read	<= 1'b0;
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
		bus_io_read		<= 1'b1;
		@( posedge clk );

		bus_address		<= 'd0;
		bus_io_read		<= 1'b0;
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
		bus_memory_read	<= 1'b1;
		@( posedge clk );

		bus_address		<= 'd0;
		bus_memory_read	<= 1'b0;
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
		bus_io_read		<= 1'b1;
		@( posedge clk );

		bus_address		<= 'd0;
		bus_io_read		<= 1'b0;
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

	task access_latch();
		forever begin
			if( rd ) begin
				ff_rd <= 1'b1;
				ff_wr <= 1'b0;
				ff_address <= address;
				rdata <= ff_rdata;
				rdata_en <= rd;
			end
			else if( wr ) begin
				ff_rd <= 1'b0;
				ff_wr <= 1'b1;
				ff_address <= address;
				ff_wdata <= wdata;
				rdata_en <= 1'b0;
			end
			else begin
				rdata_en <= 1'b0;
			end
			@( posedge clk );
		end
	endtask: access_latch

	// --------------------------------------------------------------------
	//	Test bench
	// --------------------------------------------------------------------
	initial begin
		test_no			= 0;
		n_reset			= 0;
		clk				= 0;
		bus_address		= 0;
		bus_write_data	= 0;
		bus_io_read		= 0;
		bus_io_write	= 0;
		bus_memory_read	= 0;
		bus_memory_write= 0;
		busy			= 0;
		rdata			= 0;
		rdata_en		= 0;

		@( negedge clk );
		@( negedge clk );

		n_reset			= 1;
		repeat( 10 ) @( posedge clk );

		fork
			access_latch();
		join_none

		// --------------------------------------------------------------------
		//	check segment registers(1)
		//		Confirm that the RAM I/F does not respond when writing to 
		//		the segment register.
		// --------------------------------------------------------------------
		test_no			= 2;
		$display( "Check segment registers(1)" );
		ff_rd			<= 0;
		ff_wr			<= 0;
		ff_address		<= 0;
		ff_wdata		<= 0;
		write_io( 'h00FC, 8'h12 );
		assert( ff_rd == 0 );
		assert( ff_wr == 0 );
		assert( ff_address == 0 );
		assert( ff_wdata == 0 );

		write_io( 'h00FD, 8'h34 );
		assert( ff_rd == 0 );
		assert( ff_wr == 0 );
		assert( ff_address == 0 );
		assert( ff_wdata == 0 );

		write_io( 'h00FE, 8'h89 );
		assert( ff_rd == 0 );
		assert( ff_wr == 0 );
		assert( ff_address == 0 );
		assert( ff_wdata == 0 );

		write_io( 'h00FF, 8'hAB );
		assert( ff_rd == 0 );
		assert( ff_wr == 0 );
		assert( ff_address == 0 );
		assert( ff_wdata == 0 );

		// --------------------------------------------------------------------
		//	check segment registers(2)
		//		Read the segment register to confirm that it does not respond 
		//		to anything.
		// --------------------------------------------------------------------
		test_no			= 3;
		$display( "Check segment registers(2)" );
		ff_rd			<= 0;
		ff_wr			<= 0;
		ff_address		<= 0;
		ff_wdata		<= 0;
		read_io_timeout( 'h00FC );
		assert( ff_rd == 0 );
		assert( ff_wr == 0 );
		assert( ff_address == 0 );
		assert( ff_wdata == 0 );

		read_io_timeout( 'h00FD );
		assert( ff_rd == 0 );
		assert( ff_wr == 0 );
		assert( ff_address == 0 );
		assert( ff_wdata == 0 );

		read_io_timeout( 'h00FE );
		assert( ff_rd == 0 );
		assert( ff_wr == 0 );
		assert( ff_address == 0 );
		assert( ff_wdata == 0 );

		read_io_timeout( 'h00FF );
		assert( ff_rd == 0 );
		assert( ff_wr == 0 );
		assert( ff_address == 0 );
		assert( ff_wdata == 0 );

		// --------------------------------------------------------------------
		//	check RAM write
		//		When writing memory, make sure that the upper address is the 
		//		value of the segment register.
		//		ff_address[13: 0] ... intra-segment address
		//		ff_address[21:14] ... segment#
		// --------------------------------------------------------------------
		test_no			= 4;
		$display( "Check memory write" );
		write_io( 'h00FC, 8'h12 );	// page0 = segment#12
		write_io( 'h00FD, 8'h34 );	// page1 = segment#34
		write_io( 'h00FE, 8'h89 );	// page2 = segment#89
		write_io( 'h00FF, 8'hAB );	// page3 = segment#AB
		ff_rd			<= 0;
		ff_wr			<= 0;
		ff_address		<= 0;
		ff_wdata		<= 0;

		// page0
		write_memory( 'h0000, 'h21 );
		assert( ff_rd == 0 );
		assert( ff_wr == 1 );
		assert( ff_address[21:14] == 8'h12 );
		assert( ff_address[13:0] == 16'h0000 );
		assert( ff_wdata == 8'h21 );

		write_memory( 'h1234, 'hAB );
		assert( ff_rd == 0 );
		assert( ff_wr == 1 );
		assert( ff_address[21:14] == 8'h12 );
		assert( ff_address[13:0] == 16'h1234 );
		assert( ff_wdata == 8'hAB );

		write_memory( 'h2A4D, 'h9E );
		assert( ff_rd == 0 );
		assert( ff_wr == 1 );
		assert( ff_address[21:14] == 8'h12 );
		assert( ff_address[13:0] == 16'h2A4D );
		assert( ff_wdata == 8'h9E );

		write_memory( 'h3FFF, 'hFA );
		assert( ff_rd == 0 );
		assert( ff_wr == 1 );
		assert( ff_address[21:14] == 8'h12 );
		assert( ff_address[13:0] == 16'h3FFF );
		assert( ff_wdata == 8'hFA );

		// page1
		write_memory( 'h4000, 'h21 );
		assert( ff_rd == 0 );
		assert( ff_wr == 1 );
		assert( ff_address[21:14] == 8'h34 );
		assert( ff_address[13:0] == 16'h0000 );
		assert( ff_wdata == 8'h21 );

		write_memory( 'h5234, 'hAB );
		assert( ff_rd == 0 );
		assert( ff_wr == 1 );
		assert( ff_address[21:14] == 8'h34 );
		assert( ff_address[13:0] == 16'h1234 );
		assert( ff_wdata == 8'hAB );

		write_memory( 'h6A4D, 'h9E );
		assert( ff_rd == 0 );
		assert( ff_wr == 1 );
		assert( ff_address[21:14] == 8'h34 );
		assert( ff_address[13:0] == 16'h2A4D );
		assert( ff_wdata == 8'h9E );

		write_memory( 'h7FFF, 'hFA );
		assert( ff_rd == 0 );
		assert( ff_wr == 1 );
		assert( ff_address[21:14] == 8'h34 );
		assert( ff_address[13:0] == 16'h3FFF );
		assert( ff_wdata == 8'hFA );

		// page2
		write_memory( 'h8000, 'h21 );
		assert( ff_rd == 0 );
		assert( ff_wr == 1 );
		assert( ff_address[21:14] == 8'h89 );
		assert( ff_address[13:0] == 16'h0000 );
		assert( ff_wdata == 8'h21 );

		write_memory( 'h9234, 'hAB );
		assert( ff_rd == 0 );
		assert( ff_wr == 1 );
		assert( ff_address[21:14] == 8'h89 );
		assert( ff_address[13:0] == 16'h1234 );
		assert( ff_wdata == 8'hAB );

		write_memory( 'hAA4D, 'h9E );
		assert( ff_rd == 0 );
		assert( ff_wr == 1 );
		assert( ff_address[21:14] == 8'h89 );
		assert( ff_address[13:0] == 16'h2A4D );
		assert( ff_wdata == 8'h9E );

		write_memory( 'hBFFF, 'hFA );
		assert( ff_rd == 0 );
		assert( ff_wr == 1 );
		assert( ff_address[21:14] == 8'h89 );
		assert( ff_address[13:0] == 16'h3FFF );
		assert( ff_wdata == 8'hFA );

		// page3
		write_memory( 'hC000, 'h21 );
		assert( ff_rd == 0 );
		assert( ff_wr == 1 );
		assert( ff_address[21:14] == 8'hAB );
		assert( ff_address[13:0] == 16'h0000 );
		assert( ff_wdata == 8'h21 );

		write_memory( 'hD234, 'hAB );
		assert( ff_rd == 0 );
		assert( ff_wr == 1 );
		assert( ff_address[21:14] == 8'hAB );
		assert( ff_address[13:0] == 16'h1234 );
		assert( ff_wdata == 8'hAB );

		write_memory( 'hEA4D, 'h9E );
		assert( ff_rd == 0 );
		assert( ff_wr == 1 );
		assert( ff_address[21:14] == 8'hAB );
		assert( ff_address[13:0] == 16'h2A4D );
		assert( ff_wdata == 8'h9E );

		write_memory( 'hFFFF, 'hFA );
		assert( ff_rd == 0 );
		assert( ff_wr == 1 );
		assert( ff_address[21:14] == 8'hAB );
		assert( ff_address[13:0] == 16'h3FFF );
		assert( ff_wdata == 8'hFA );

		// --------------------------------------------------------------------
		//	check RAM read
		//		When reading memory, make sure that the upper address is the 
		//		value of the segment register.
		//		ff_address[13: 0] ... intra-segment address
		//		ff_address[21:14] ... segment#
		// --------------------------------------------------------------------
		test_no			= 4;
		$display( "Check memory read" );
		write_io( 'h00FC, 8'hA5 );	// page0 = segment#12
		write_io( 'h00FD, 8'h92 );	// page1 = segment#34
		write_io( 'h00FE, 8'h25 );	// page2 = segment#89
		write_io( 'h00FF, 8'h18 );	// page3 = segment#AB
		ff_rd			<= 0;
		ff_wr			<= 0;
		ff_address		<= 0;
		ff_wdata		<= 0;

		// page0
		ff_rdata = 8'h21;
		read_memory( 'h0000, ff_rdata );
		assert( ff_rd == 1 );
		assert( ff_wr == 0 );
		assert( ff_address[21:14] == 8'hA5 );
		assert( ff_address[13:0] == 16'h0000 );

		ff_rdata = 8'hAB;
		read_memory( 'h1234, ff_rdata );
		assert( ff_rd == 1 );
		assert( ff_wr == 0 );
		assert( ff_address[21:14] == 8'hA5 );
		assert( ff_address[13:0] == 16'h1234 );

		ff_rdata = 8'h9E;
		read_memory( 'h2A4D, ff_rdata );
		assert( ff_rd == 1 );
		assert( ff_wr == 0 );
		assert( ff_address[21:14] == 8'hA5 );
		assert( ff_address[13:0] == 16'h2A4D );

		ff_rdata = 8'hFA;
		read_memory( 'h3FFF, ff_rdata );
		assert( ff_rd == 1 );
		assert( ff_wr == 0 );
		assert( ff_address[21:14] == 8'hA5 );
		assert( ff_address[13:0] == 16'h3FFF );

		// page1
		ff_rdata = 8'h21;
		read_memory( 'h4000, ff_rdata );
		assert( ff_rd == 1 );
		assert( ff_wr == 0 );
		assert( ff_address[21:14] == 8'h92 );
		assert( ff_address[13:0] == 16'h0000 );

		ff_rdata = 8'hAB;
		read_memory( 'h5234, ff_rdata );
		assert( ff_rd == 1 );
		assert( ff_wr == 0 );
		assert( ff_address[21:14] == 8'h92 );
		assert( ff_address[13:0] == 16'h1234 );

		ff_rdata = 8'h9E;
		read_memory( 'h6A4D, ff_rdata );
		assert( ff_rd == 1 );
		assert( ff_wr == 0 );
		assert( ff_address[21:14] == 8'h92 );
		assert( ff_address[13:0] == 16'h2A4D );

		ff_rdata = 8'hFA;
		read_memory( 'h7FFF, ff_rdata );
		assert( ff_rd == 1 );
		assert( ff_wr == 0 );
		assert( ff_address[21:14] == 8'h92 );
		assert( ff_address[13:0] == 16'h3FFF );

		// page2
		ff_rdata = 8'h21;
		read_memory( 'h8000, ff_rdata );
		assert( ff_rd == 1 );
		assert( ff_wr == 0 );
		assert( ff_address[21:14] == 8'h25 );
		assert( ff_address[13:0] == 16'h0000 );

		ff_rdata = 8'hAB;
		read_memory( 'h9234, ff_rdata );
		assert( ff_rd == 1 );
		assert( ff_wr == 0 );
		assert( ff_address[21:14] == 8'h25 );
		assert( ff_address[13:0] == 16'h1234 );

		ff_rdata = 8'h9E;
		read_memory( 'hAA4D, ff_rdata );
		assert( ff_rd == 1 );
		assert( ff_wr == 0 );
		assert( ff_address[21:14] == 8'h25 );
		assert( ff_address[13:0] == 16'h2A4D );

		ff_rdata = 8'hFA;
		read_memory( 'hBFFF, ff_rdata );
		assert( ff_rd == 1 );
		assert( ff_wr == 0 );
		assert( ff_address[21:14] == 8'h25 );
		assert( ff_address[13:0] == 16'h3FFF );

		// page3
		ff_rdata = 8'h21;
		read_memory( 'hC000, ff_rdata );
		assert( ff_rd == 1 );
		assert( ff_wr == 0 );
		assert( ff_address[21:14] == 8'h18 );
		assert( ff_address[13:0] == 16'h0000 );

		ff_rdata = 8'hAB;
		read_memory( 'hD234, ff_rdata );
		assert( ff_rd == 1 );
		assert( ff_wr == 0 );
		assert( ff_address[21:14] == 8'h18 );
		assert( ff_address[13:0] == 16'h1234 );

		ff_rdata = 8'h9E;
		read_memory( 'hEA4D, ff_rdata );
		assert( ff_rd == 1 );
		assert( ff_wr == 0 );
		assert( ff_address[21:14] == 8'h18 );
		assert( ff_address[13:0] == 16'h2A4D );

		ff_rdata = 8'hFA;
		read_memory( 'hFFFF, ff_rdata );
		assert( ff_rd == 1 );
		assert( ff_wr == 0 );
		assert( ff_address[21:14] == 8'h18 );
		assert( ff_address[13:0] == 16'h3FFF );

		$finish;
	end
endmodule
