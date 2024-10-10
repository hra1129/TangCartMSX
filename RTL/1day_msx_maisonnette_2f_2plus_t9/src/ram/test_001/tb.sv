// -----------------------------------------------------------------------------
//	Test of ip_ram.v
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
	reg				bus_memory_read;
	reg				bus_memory_write;
	integer			test_no;
	int				i;

	// --------------------------------------------------------------------
	//	DUT
	// --------------------------------------------------------------------
	ip_ram u_ram (
		.n_reset			( n_reset			),
		.clk				( clk				),
		.bus_address		( bus_address		),
		.bus_read_ready		( bus_read_ready	),
		.bus_read_data		( bus_read_data		),
		.bus_write_data		( bus_write_data	),
		.bus_memory_read	( bus_memory_read	),
		.bus_memory_write	( bus_memory_write	)
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
		@( posedge clk );
		@( posedge clk );
		@( posedge clk );
		@( posedge clk );
		@( posedge clk );
		@( posedge clk );

		bus_address		<= 0;
		bus_write_data	<= 0;
		bus_memory_write<= 1'b0;
		@( posedge clk );
	endtask: write_memory

	task read_memory(
		input	[15:0]	address,
		input	[7:0]	data
	);
		bus_address		<= address;
		bus_memory_read	<= 1'b1;
		@( posedge clk );
		@( posedge clk );

		while( !bus_read_ready ) begin
			@( posedge clk );
		end

		assert( bus_read_data == data );
		@( posedge clk );
		@( posedge clk );

		bus_address		<= 'd0;
		bus_memory_read	<= 1'b0;
		@( posedge clk );
	endtask: read_memory

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

	// --------------------------------------------------------------------
	//	Test bench
	// --------------------------------------------------------------------
	initial begin
		test_no				= 0;
		n_reset				= 0;
		clk					= 0;
		bus_address			= 0;
		bus_write_data		= 0;
		bus_memory_read		= 0;
		bus_memory_write	= 0;

		@( negedge clk );
		@( negedge clk );

		n_reset			= 1;
		repeat( 10 ) @( posedge clk );

		@( posedge clk );

		// --------------------------------------------------------------------
		//	Invalid Write Test
		// --------------------------------------------------------------------
		test_no				= 1;

		for( i = 0; i < 'h8000; i++ ) begin
			write_memory( i, i & 255 );
		end
		repeat( 10 ) @( posedge clk );

		// --------------------------------------------------------------------
		//	Valid Write Test
		// --------------------------------------------------------------------
		test_no				= 2;

		for( i = 'h8000; i < 'hC000; i++ ) begin
			write_memory( i, i & 255 );
		end
		repeat( 10 ) @( posedge clk );

		// --------------------------------------------------------------------
		//	Invalid Write Test
		// --------------------------------------------------------------------
		test_no				= 3;

		for( i = 'hC000; i <= 'hFFFF; i++ ) begin
			write_memory( i, i & 255 );
		end
		repeat( 10 ) @( posedge clk );
		$finish;
	end
endmodule
