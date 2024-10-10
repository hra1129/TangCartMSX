// -----------------------------------------------------------------------------
//	Test of ip_extslot.v
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
	wire			bus_io_cs;
	wire			bus_memory_cs;
	wire			bus_read_ready;
	wire	[7:0]	bus_read_data;
	reg		[7:0]	bus_write_data;
	reg				bus_read;
	reg				bus_write;
	reg				bus_io;
	reg				bus_memory;
	//	wire
	wire			extslot_memory0;
	wire			extslot_memory1;
	wire			extslot_memory2;
	wire			extslot_memory3;
	integer			test_no;

	// --------------------------------------------------------------------
	//	DUT
	// --------------------------------------------------------------------
	ip_extslot u_extslot (
		.n_reset			( n_reset				),
		.clk				( clk					),
		.bus_address		( bus_address			),
		.bus_io_cs			( bus_io_cs				),
		.bus_memory_cs		( bus_memory_cs			),
		.bus_read_ready		( bus_read_ready		),
		.bus_read_data		( bus_read_data			),
		.bus_write_data		( bus_write_data		),
		.bus_read			( bus_read				),
		.bus_write			( bus_write				),
		.bus_io				( bus_io				),
		.bus_memory			( bus_memory			),
		.extslot_memory0	( extslot_memory0		),
		.extslot_memory1	( extslot_memory1		),
		.extslot_memory2	( extslot_memory2		),
		.extslot_memory3	( extslot_memory3		)
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

		@( negedge clk );
		@( negedge clk );

		n_reset			= 1;
		repeat( 10 ) @( posedge clk );

		// --------------------------------------------------------------------
		//	check CS port
		// --------------------------------------------------------------------
		test_no			= 1;
		$display( "Check CS port" );
		assert( bus_io_cs == 1'b0 );
		assert( bus_memory_cs == 1'b1 );
		@( posedge clk );

		// --------------------------------------------------------------------
		//	check write access1
		// --------------------------------------------------------------------
		test_no			= 2;
		$display( "Check write accecss (1)" );
		write_memory( 'hFFFF, 'b11_10_01_00 );

		bus_memory		<= 1'b1;
		bus_address		<= 'h0000;
		@( posedge clk );
		assert( extslot_memory0 == 1'b1 );
		assert( extslot_memory1 == 1'b0 );
		assert( extslot_memory2 == 1'b0 );
		assert( extslot_memory3 == 1'b0 );
		@( posedge clk );

		bus_address		<= 'h4000;
		@( posedge clk );
		assert( extslot_memory0 == 1'b0 );
		assert( extslot_memory1 == 1'b1 );
		assert( extslot_memory2 == 1'b0 );
		assert( extslot_memory3 == 1'b0 );
		@( posedge clk );

		bus_address		<= 'h8000;
		@( posedge clk );
		assert( extslot_memory0 == 1'b0 );
		assert( extslot_memory1 == 1'b0 );
		assert( extslot_memory2 == 1'b1 );
		assert( extslot_memory3 == 1'b0 );
		@( posedge clk );

		bus_address		<= 'hC000;
		@( posedge clk );
		assert( extslot_memory0 == 1'b0 );
		assert( extslot_memory1 == 1'b0 );
		assert( extslot_memory2 == 1'b0 );
		assert( extslot_memory3 == 1'b1 );
		@( posedge clk );
		bus_memory		<= 1'b0;

		write_memory( 'hFFFF, 'b00_01_10_11 );

		bus_memory		<= 1'b1;
		bus_address		<= 'h0000;
		@( posedge clk );
		assert( extslot_memory0 == 1'b0 );
		assert( extslot_memory1 == 1'b0 );
		assert( extslot_memory2 == 1'b0 );
		assert( extslot_memory3 == 1'b1 );
		@( posedge clk );

		bus_address		<= 'h4000;
		@( posedge clk );
		assert( extslot_memory0 == 1'b0 );
		assert( extslot_memory1 == 1'b0 );
		assert( extslot_memory2 == 1'b1 );
		assert( extslot_memory3 == 1'b0 );
		@( posedge clk );

		bus_address		<= 'h8000;
		@( posedge clk );
		assert( extslot_memory0 == 1'b0 );
		assert( extslot_memory1 == 1'b1 );
		assert( extslot_memory2 == 1'b0 );
		assert( extslot_memory3 == 1'b0 );
		@( posedge clk );

		bus_address		<= 'hC000;
		@( posedge clk );
		assert( extslot_memory0 == 1'b1 );
		assert( extslot_memory1 == 1'b0 );
		assert( extslot_memory2 == 1'b0 );
		assert( extslot_memory3 == 1'b0 );
		@( posedge clk );
		bus_memory		<= 1'b0;

		// --------------------------------------------------------------------
		//	check write access2
		// --------------------------------------------------------------------
		test_no			= 3;
		$display( "Check write accecss (2)" );
		write_memory( 'hFFFF, 'b11_10_01_00 );
		write_memory( 'h1234, 'b00_11_00_11 );
		write_memory( 'h4567, 'b01_01_11_11 );
		write_memory( 'h89AB, 'b10_10_10_10 );

		bus_memory		<= 1'b1;
		bus_address		<= 'h0000;
		@( posedge clk );
		assert( extslot_memory0 == 1'b1 );
		assert( extslot_memory1 == 1'b0 );
		assert( extslot_memory2 == 1'b0 );
		assert( extslot_memory3 == 1'b0 );
		@( posedge clk );

		bus_address		<= 'h4000;
		@( posedge clk );
		assert( extslot_memory0 == 1'b0 );
		assert( extslot_memory1 == 1'b1 );
		assert( extslot_memory2 == 1'b0 );
		assert( extslot_memory3 == 1'b0 );
		@( posedge clk );

		bus_address		<= 'h8000;
		@( posedge clk );
		assert( extslot_memory0 == 1'b0 );
		assert( extslot_memory1 == 1'b0 );
		assert( extslot_memory2 == 1'b1 );
		assert( extslot_memory3 == 1'b0 );
		@( posedge clk );

		bus_address		<= 'hC000;
		@( posedge clk );
		assert( extslot_memory0 == 1'b0 );
		assert( extslot_memory1 == 1'b0 );
		assert( extslot_memory2 == 1'b0 );
		assert( extslot_memory3 == 1'b1 );
		@( posedge clk );
		bus_memory		<= 1'b0;

		write_memory( 'hFFFF, 'b00_01_10_11 );
		write_memory( 'h4321, 'b00_11_00_11 );
		write_memory( 'h8765, 'b01_01_11_11 );
		write_memory( 'hCBA9, 'b10_10_10_10 );

		bus_memory		<= 1'b1;
		bus_address		<= 'h0000;
		@( posedge clk );
		assert( extslot_memory0 == 1'b0 );
		assert( extslot_memory1 == 1'b0 );
		assert( extslot_memory2 == 1'b0 );
		assert( extslot_memory3 == 1'b1 );
		@( posedge clk );

		bus_address		<= 'h4000;
		@( posedge clk );
		assert( extslot_memory0 == 1'b0 );
		assert( extslot_memory1 == 1'b0 );
		assert( extslot_memory2 == 1'b1 );
		assert( extslot_memory3 == 1'b0 );
		@( posedge clk );

		bus_address		<= 'h8000;
		@( posedge clk );
		assert( extslot_memory0 == 1'b0 );
		assert( extslot_memory1 == 1'b1 );
		assert( extslot_memory2 == 1'b0 );
		assert( extslot_memory3 == 1'b0 );
		@( posedge clk );

		bus_address		<= 'hC000;
		@( posedge clk );
		assert( extslot_memory0 == 1'b1 );
		assert( extslot_memory1 == 1'b0 );
		assert( extslot_memory2 == 1'b0 );
		assert( extslot_memory3 == 1'b0 );
		@( posedge clk );
		bus_memory		<= 1'b0;

		// --------------------------------------------------------------------
		//	check write access3
		// --------------------------------------------------------------------
		test_no			= 4;
		$display( "Check write accecss (3)" );
		write_memory( 'hFFFF, 'b11_10_01_00 );
		write_io( 'h1234, 'b00_11_00_11 );
		write_io( 'hFFFF, 'b01_01_11_11 );
		write_io( 'h89AB, 'b10_10_10_10 );

		bus_memory		<= 1'b1;
		bus_address		<= 'h0000;
		@( posedge clk );
		assert( extslot_memory0 == 1'b1 );
		assert( extslot_memory1 == 1'b0 );
		assert( extslot_memory2 == 1'b0 );
		assert( extslot_memory3 == 1'b0 );
		@( posedge clk );

		bus_address		<= 'h4000;
		@( posedge clk );
		assert( extslot_memory0 == 1'b0 );
		assert( extslot_memory1 == 1'b1 );
		assert( extslot_memory2 == 1'b0 );
		assert( extslot_memory3 == 1'b0 );
		@( posedge clk );

		bus_address		<= 'h8000;
		@( posedge clk );
		assert( extslot_memory0 == 1'b0 );
		assert( extslot_memory1 == 1'b0 );
		assert( extslot_memory2 == 1'b1 );
		assert( extslot_memory3 == 1'b0 );
		@( posedge clk );

		bus_address		<= 'hC000;
		@( posedge clk );
		assert( extslot_memory0 == 1'b0 );
		assert( extslot_memory1 == 1'b0 );
		assert( extslot_memory2 == 1'b0 );
		assert( extslot_memory3 == 1'b1 );
		@( posedge clk );
		bus_memory		<= 1'b0;

		write_memory( 'hFFFF, 'b00_01_10_11 );
		write_io( 'hFFFF, 'b00_11_00_11 );
		write_io( 'h8765, 'b01_01_11_11 );
		write_io( 'hCBA9, 'b10_10_10_10 );

		bus_memory		<= 1'b1;
		bus_address		<= 'h0000;
		@( posedge clk );
		assert( extslot_memory0 == 1'b0 );
		assert( extslot_memory1 == 1'b0 );
		assert( extslot_memory2 == 1'b0 );
		assert( extslot_memory3 == 1'b1 );
		@( posedge clk );

		bus_address		<= 'h4000;
		@( posedge clk );
		assert( extslot_memory0 == 1'b0 );
		assert( extslot_memory1 == 1'b0 );
		assert( extslot_memory2 == 1'b1 );
		assert( extslot_memory3 == 1'b0 );
		@( posedge clk );

		bus_address		<= 'h8000;
		@( posedge clk );
		assert( extslot_memory0 == 1'b0 );
		assert( extslot_memory1 == 1'b1 );
		assert( extslot_memory2 == 1'b0 );
		assert( extslot_memory3 == 1'b0 );
		@( posedge clk );

		bus_address		<= 'hC000;
		@( posedge clk );
		assert( extslot_memory0 == 1'b1 );
		assert( extslot_memory1 == 1'b0 );
		assert( extslot_memory2 == 1'b0 );
		assert( extslot_memory3 == 1'b0 );
		@( posedge clk );

		bus_address		<= 'hFFFF;
		@( posedge clk );
		assert( extslot_memory0 == 1'b0 );
		assert( extslot_memory1 == 1'b0 );
		assert( extslot_memory2 == 1'b0 );
		assert( extslot_memory3 == 1'b0 );
		@( posedge clk );

		bus_memory		<= 1'b0;

		// --------------------------------------------------------------------
		//	check read access
		// --------------------------------------------------------------------
		test_no			= 5;
		$display( "Check read accecss" );
		write_memory( 'hFFFF, 'b11_10_01_00 );
		read_memory(  'hFFFF, 'b00_01_10_11 );

		write_memory( 'hFFFF, 'b00_01_10_11 );
		read_memory(  'hFFFF, 'b11_10_01_00 );

		write_memory( 'hFFFF, 'b11_11_11_11 );
		read_memory(  'hFFFF, 'b00_00_00_00 );

		write_memory( 'hFFFF, 'b01_01_01_01 );
		read_memory(  'hFFFF, 'b10_10_10_10 );

		read_memory_timeout( 'h1234 );
		read_memory_timeout( 'h3456 );
		read_memory_timeout( 'hAA55 );
		read_memory_timeout( 'h55AA );
		read_memory_timeout( 'h0123 );
		read_memory_timeout( 'h89AB );
		read_memory_timeout( 'hC012 );
		read_memory_timeout( 'hFCC1 );

		read_io_timeout( 'h1234 );
		read_io_timeout( 'h3456 );
		read_io_timeout( 'hAA55 );
		read_io_timeout( 'h55AA );
		read_io_timeout( 'h0123 );
		read_io_timeout( 'h89AB );
		read_io_timeout( 'hC012 );
		read_io_timeout( 'hFCC1 );
		$finish;
	end
endmodule
