// -----------------------------------------------------------------------------
//	Test of ip_msxbus.v
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
//		The role of protocol conversion by replacing the asynchronous MSXBUS 
//		signal with an internal clock.
// -----------------------------------------------------------------------------

module tb ();
	localparam		clk_base	= 1000000000/21477;
	//	cartridge slot signals
	reg				n_reset;
	reg				clk;
	reg		[15:0]	adr;
	reg		[7:0]	i_data;
	wire	[7:0]	o_data;
	wire			is_output;
	wire			is_output_d;
	reg				n_sltsl;
	reg				n_rd;
	reg				n_wr;
	reg				n_ioreq;
	reg				n_mereq;
	//	internal signals
	wire	[15:0]	bus_address;
	reg				bus_io_cs;
	reg				bus_memory_cs;
	reg				bus_read_ready;
	reg		[7:0]	bus_read_data;
	wire	[7:0]	bus_write_data;
	wire			bus_read;
	wire			bus_write;
	wire			bus_io;
	wire			bus_memory;
	integer			count;
	logic	[15:0]	last_address;
	logic	[7:0]	last_write_data;
	logic	[7:0]	last_read_data;
	integer			test_no;
	logic			last_io;
	logic			last_memory;
	logic	[7:0]	save_read_data;

	// --------------------------------------------------------------------
	//	DUT
	// --------------------------------------------------------------------
	ip_msxbus u_msxbus (
		.n_reset			( n_reset			),
		.clk				( clk				),
		.adr				( adr				),
		.i_data				( i_data			),
		.o_data				( o_data			),
		.is_output			( is_output			),
		.is_output_d		( is_output_d		),
		.n_sltsl			( n_sltsl			),
		.n_rd				( n_rd				),
		.n_wr				( n_wr				),
		.n_ioreq			( n_ioreq			),
		.n_mereq			( n_mereq			),
		.bus_address		( bus_address		),
		.bus_io_cs			( bus_io_cs			),
		.bus_memory_cs		( bus_memory_cs		),
		.bus_read_ready		( bus_read_ready	),
		.bus_read_data		( bus_read_data		),
		.bus_write_data		( bus_write_data	),
		.bus_read			( bus_read			),
		.bus_write			( bus_write			),
		.bus_io				( bus_io			),
		.bus_memory			( bus_memory		)
	);

	// --------------------------------------------------------------------
	//	clock
	// --------------------------------------------------------------------
	always #(clk_base/2) begin
		clk <= ~clk;
	end

	// --------------------------------------------------------------------
	//	Memory write access
	// --------------------------------------------------------------------
	task memory_write(
		input	[15:0]	address,
		input	[7:0]	data
	);
		count = 0;
		adr = 16'dX;
		i_data = 8'dX;
		#170ns

		adr = address;
		#145ns

		n_mereq = 1'b0;
		#10ns

		n_sltsl = 1'b0;
		#55ns

		i_data = data;
		#209ns

		n_wr = 1'b0;
		#259ns

		n_wr = 1'b1;
		#25ns

		n_mereq = 1'b1;
		#10ns

		n_sltsl = 1'b1;
		#55ns

		@( posedge clk );
	endtask: memory_write

	// --------------------------------------------------------------------
	//	Memory read access
	// --------------------------------------------------------------------
	task memory_read(
		input	[15:0]	address,
		input	[7:0]	data
	);
		count = 0;
		adr = 16'dX;
		i_data = 8'dX;
		save_read_data = data;
		#170ns

		adr = address;
		#145ns

		n_mereq = 1'b0;
		#10ns

		n_sltsl = 1'b0;
		n_rd = 1'b0;
		#702ns

		last_read_data <= o_data;
		n_mereq = 1'b1;
		n_rd = 1'b1;
		#10ns

		n_sltsl = 1'b1;
		#279ns

		@( posedge clk );
	endtask: memory_read

	// --------------------------------------------------------------------
	//	Memory write access
	// --------------------------------------------------------------------
	task io_write(
		input	[15:0]	address,
		input	[7:0]	data
	);
		count = 0;
		adr = 16'dX;
		i_data = 8'dX;
		n_sltsl = 1'b1;
		#170ns

		adr = address;
		#145ns

		n_ioreq = 1'b0;
		#10ns

		n_sltsl = 1'b1;
		#55ns

		i_data = data;
		#209ns

		n_wr = 1'b0;
		#259ns

		n_wr = 1'b1;
		#25ns

		n_ioreq = 1'b1;
		#10ns

		n_sltsl = 1'b1;
		#55ns

		@( posedge clk );
	endtask: io_write

	// --------------------------------------------------------------------
	//	I/O read access
	// --------------------------------------------------------------------
	task io_read(
		input	[15:0]	address,
		input	[7:0]	data
	);
		count = 0;
		adr = 16'dX;
		i_data = 8'dX;
		save_read_data = data;
		n_sltsl = 1'b1;
		#170ns

		adr = address;
		#145ns

		n_ioreq = 1'b0;
		#10ns

		n_rd = 1'b0;
		#702ns

		last_read_data <= o_data;
		n_ioreq = 1'b1;
		n_rd = 1'b1;
		#10ns

		n_sltsl = 1'b1;
		#279ns

		@( posedge clk );
	endtask: io_read

	// --------------------------------------------------------------------
	//	Access check task
	// --------------------------------------------------------------------
	task access_check();
		last_write_data <= 8'd0;
		last_address <= 16'hAAAA;
		forever begin
			@( posedge clk );
			if( bus_io || bus_memory ) begin
				if( bus_write ) begin
					count <= count + 1;
					last_write_data <= bus_write_data;
					last_address <= bus_address;
					last_io <= bus_io;
					last_memory <= bus_memory;
				end
				else if( bus_read ) begin
					count <= count + 1;
					last_address <= bus_address;
					last_io <= bus_io;
					last_memory <= bus_memory;
					@( posedge clk );
					@( posedge clk );
					@( posedge clk );
					@( posedge clk );
					bus_read_data <= save_read_data;
					bus_read_ready <= 1'b1;
					@( posedge clk );
					bus_read_data <= 8'd0;
					bus_read_ready <= 1'b0;
					@( posedge clk );
				end
			end
		end
	endtask: access_check

	// --------------------------------------------------------------------
	//	Test bench
	// --------------------------------------------------------------------
	initial begin
		test_no			= 0;
		n_reset			= 0;
		clk				= 0;
		adr				= 0;
		i_data			= 0;
		n_sltsl			= 1;
		n_rd			= 1;
		n_wr			= 1;
		n_ioreq			= 1;
		n_mereq			= 1;
		bus_read_ready	= 0;
		bus_read_data	= 0;

		@( negedge clk );
		@( negedge clk );

		fork
			access_check();
		join_none

		n_reset			= 1;
		repeat( 10 ) @( posedge clk );

		// --------------------------------------------------------------------
		//	memory write test
		// --------------------------------------------------------------------
		test_no			= 1;
		$display( "Memory Write Test" );
		bus_io_cs		= 0;
		bus_memory_cs	= 1;
		@( posedge clk );
		#19ns
		memory_write( 16'h1234, 8'h12 );
		assert( count == 1 );
		assert( last_write_data == 8'h12 );
		assert( last_address == 16'h1234 );
		assert( last_io == 1'b0 );
		assert( last_memory == 1'b1 );

		@( posedge clk );
		#38ns
		memory_write( 16'h2345, 8'h23 );
		assert( count == 1 );
		assert( last_write_data == 8'h23 );
		assert( last_address == 16'h2345 );
		assert( last_io == 1'b0 );
		assert( last_memory == 1'b1 );

		@( posedge clk );
		#57ns
		memory_write( 16'h3456, 8'h34 );
		assert( count == 1 );
		assert( last_write_data == 8'h34 );
		assert( last_address == 16'h3456 );
		assert( last_io == 1'b0 );
		assert( last_memory == 1'b1 );

		@( posedge clk );
		#76ns
		memory_write( 16'h4567, 8'h45 );
		assert( count == 1 );
		assert( last_write_data == 8'h45 );
		assert( last_address == 16'h4567 );
		assert( last_io == 1'b0 );
		assert( last_memory == 1'b1 );

		@( posedge clk );
		#95ns
		memory_write( 16'h5678, 8'h65 );
		assert( count == 1 );
		assert( last_write_data == 8'h65 );
		assert( last_address == 16'h5678 );
		assert( last_io == 1'b0 );
		assert( last_memory == 1'b1 );

		@( posedge clk );
		#114ns
		memory_write( 16'h6789, 8'hAB );
		assert( count == 1 );
		assert( last_write_data == 8'hAB );
		assert( last_address == 16'h6789 );
		assert( last_io == 1'b0 );
		assert( last_memory == 1'b1 );

		@( posedge clk );
		#133ns
		memory_write( 16'h789A, 8'hCD );
		assert( count == 1 );
		assert( last_write_data == 8'hCD );
		assert( last_address == 16'h789A );
		assert( last_io == 1'b0 );
		assert( last_memory == 1'b1 );

		@( posedge clk );
		#152ns
		memory_write( 16'h89AB, 8'hEF );
		assert( count == 1 );
		assert( last_write_data == 8'hEF );
		assert( last_address == 16'h89AB );
		assert( last_io == 1'b0 );
		assert( last_memory == 1'b1 );

		// --------------------------------------------------------------------
		//	I/O write test
		// --------------------------------------------------------------------
		test_no			= 2;
		$display( "I/O Write Test" );
		bus_io_cs		= 1;
		bus_memory_cs	= 0;
		@( posedge clk );
		#19ns
		io_write( 16'h1234, 8'h12 );
		assert( count == 1 );
		assert( last_write_data == 8'h12 );
		assert( last_address == 16'h1234 );
		assert( last_io == 1'b1 );
		assert( last_memory == 1'b0 );

		@( posedge clk );
		#38ns
		io_write( 16'h2345, 8'h23 );
		assert( count == 1 );
		assert( last_write_data == 8'h23 );
		assert( last_address == 16'h2345 );
		assert( last_io == 1'b1 );
		assert( last_memory == 1'b0 );

		@( posedge clk );
		#57ns
		io_write( 16'h3456, 8'h34 );
		assert( count == 1 );
		assert( last_write_data == 8'h34 );
		assert( last_address == 16'h3456 );
		assert( last_io == 1'b1 );
		assert( last_memory == 1'b0 );

		@( posedge clk );
		#76ns
		io_write( 16'h4567, 8'h45 );
		assert( count == 1 );
		assert( last_write_data == 8'h45 );
		assert( last_address == 16'h4567 );
		assert( last_io == 1'b1 );
		assert( last_memory == 1'b0 );

		@( posedge clk );
		#95ns
		io_write( 16'h5678, 8'h65 );
		assert( count == 1 );
		assert( last_write_data == 8'h65 );
		assert( last_address == 16'h5678 );
		assert( last_io == 1'b1 );
		assert( last_memory == 1'b0 );

		@( posedge clk );
		#114ns
		io_write( 16'h6789, 8'hAB );
		assert( count == 1 );
		assert( last_write_data == 8'hAB );
		assert( last_address == 16'h6789 );
		assert( last_io == 1'b1 );
		assert( last_memory == 1'b0 );

		@( posedge clk );
		#133ns
		io_write( 16'h789A, 8'hCD );
		assert( count == 1 );
		assert( last_write_data == 8'hCD );
		assert( last_address == 16'h789A );
		assert( last_io == 1'b1 );
		assert( last_memory == 1'b0 );

		@( posedge clk );
		#152ns
		io_write( 16'h89AB, 8'hEF );
		assert( count == 1 );
		assert( last_write_data == 8'hEF );
		assert( last_address == 16'h89AB );
		assert( last_io == 1'b1 );
		assert( last_memory == 1'b0 );

		// --------------------------------------------------------------------
		//	memory read test
		// --------------------------------------------------------------------
		test_no			= 3;
		$display( "Memory Read Test" );
		bus_io_cs		= 0;
		bus_memory_cs	= 1;
		@( posedge clk );
		#19ns
		memory_read( 16'h1234, 8'h12 );
		assert( count == 1 );
		assert( last_read_data == 8'h12 );
		assert( last_address == 16'h1234 );
		assert( last_io == 1'b0 );
		assert( last_memory == 1'b1 );

		@( posedge clk );
		#38ns
		memory_read( 16'h2345, 8'h23 );
		assert( count == 1 );
		assert( last_read_data == 8'h23 );
		assert( last_address == 16'h2345 );
		assert( last_io == 1'b0 );
		assert( last_memory == 1'b1 );

		@( posedge clk );
		#57ns
		memory_read( 16'h3456, 8'h34 );
		assert( count == 1 );
		assert( last_read_data == 8'h34 );
		assert( last_address == 16'h3456 );
		assert( last_io == 1'b0 );
		assert( last_memory == 1'b1 );

		@( posedge clk );
		#76ns
		memory_read( 16'h4567, 8'h45 );
		assert( count == 1 );
		assert( last_read_data == 8'h45 );
		assert( last_address == 16'h4567 );
		assert( last_io == 1'b0 );
		assert( last_memory == 1'b1 );

		@( posedge clk );
		#95ns
		memory_read( 16'h5678, 8'h65 );
		assert( count == 1 );
		assert( last_read_data == 8'h65 );
		assert( last_address == 16'h5678 );
		assert( last_io == 1'b0 );
		assert( last_memory == 1'b1 );

		@( posedge clk );
		#114ns
		memory_read( 16'h6789, 8'hAB );
		assert( count == 1 );
		assert( last_read_data == 8'hAB );
		assert( last_address == 16'h6789 );
		assert( last_io == 1'b0 );
		assert( last_memory == 1'b1 );

		@( posedge clk );
		#133ns
		memory_read( 16'h789A, 8'hCD );
		assert( count == 1 );
		assert( last_read_data == 8'hCD );
		assert( last_address == 16'h789A );
		assert( last_io == 1'b0 );
		assert( last_memory == 1'b1 );

		@( posedge clk );
		#152ns
		memory_read( 16'h89AB, 8'hEF );
		assert( count == 1 );
		assert( last_read_data == 8'hEF );
		assert( last_address == 16'h89AB );
		assert( last_io == 1'b0 );
		assert( last_memory == 1'b1 );

		// --------------------------------------------------------------------
		//	I/O read test
		// --------------------------------------------------------------------
		test_no			= 4;
		$display( "I/O Read Test" );
		bus_io_cs		= 1;
		bus_memory_cs	= 0;
		@( posedge clk );
		#19ns
		io_read( 16'h1234, 8'h12 );
		assert( count == 1 );
		assert( last_read_data == 8'h12 );
		assert( last_address == 16'h1234 );
		assert( last_io == 1'b1 );
		assert( last_memory == 1'b0 );

		@( posedge clk );
		#38ns
		io_read( 16'h2345, 8'h23 );
		assert( count == 1 );
		assert( last_read_data == 8'h23 );
		assert( last_address == 16'h2345 );
		assert( last_io == 1'b1 );
		assert( last_memory == 1'b0 );

		@( posedge clk );
		#57ns
		io_read( 16'h3456, 8'h34 );
		assert( count == 1 );
		assert( last_read_data == 8'h34 );
		assert( last_address == 16'h3456 );
		assert( last_io == 1'b1 );
		assert( last_memory == 1'b0 );

		@( posedge clk );
		#76ns
		io_read( 16'h4567, 8'h45 );
		assert( count == 1 );
		assert( last_read_data == 8'h45 );
		assert( last_address == 16'h4567 );
		assert( last_io == 1'b1 );
		assert( last_memory == 1'b0 );

		@( posedge clk );
		#95ns
		io_read( 16'h5678, 8'h65 );
		assert( count == 1 );
		assert( last_read_data == 8'h65 );
		assert( last_address == 16'h5678 );
		assert( last_io == 1'b1 );
		assert( last_memory == 1'b0 );

		@( posedge clk );
		#114ns
		io_read( 16'h6789, 8'hAB );
		assert( count == 1 );
		assert( last_read_data == 8'hAB );
		assert( last_address == 16'h6789 );
		assert( last_io == 1'b1 );
		assert( last_memory == 1'b0 );

		@( posedge clk );
		#133ns
		io_read( 16'h789A, 8'hCD );
		assert( count == 1 );
		assert( last_read_data == 8'hCD );
		assert( last_address == 16'h789A );
		assert( last_io == 1'b1 );
		assert( last_memory == 1'b0 );

		@( posedge clk );
		#152ns
		io_read( 16'h89AB, 8'hEF );
		assert( count == 1 );
		assert( last_read_data == 8'hEF );
		assert( last_address == 16'h89AB );
		assert( last_io == 1'b1 );
		assert( last_memory == 1'b0 );

		// --------------------------------------------------------------------
		//	memory write reject test
		// --------------------------------------------------------------------
		test_no			= 5;
		$display( "Memory Write Reject Test" );
		bus_io_cs		= 0;
		bus_memory_cs	= 0;
		@( posedge clk );
		#19ns
		memory_write( 16'h1234, 8'h12 );
		assert( count == 0 );

		@( posedge clk );
		#38ns
		memory_write( 16'h2345, 8'h23 );
		assert( count == 0 );

		@( posedge clk );
		#57ns
		memory_write( 16'h3456, 8'h34 );
		assert( count == 0 );

		@( posedge clk );
		#76ns
		memory_write( 16'h4567, 8'h45 );
		assert( count == 0 );

		@( posedge clk );
		#95ns
		memory_write( 16'h5678, 8'h65 );
		assert( count == 0 );

		@( posedge clk );
		#114ns
		memory_write( 16'h6789, 8'hAB );
		assert( count == 0 );

		@( posedge clk );
		#133ns
		memory_write( 16'h789A, 8'hCD );
		assert( count == 0 );

		@( posedge clk );
		#152ns
		memory_write( 16'h89AB, 8'hEF );
		assert( count == 0 );

		// --------------------------------------------------------------------
		//	I/O write test
		// --------------------------------------------------------------------
		test_no			= 6;
		$display( "I/O Write Reject Test" );
		bus_io_cs		= 0;
		bus_memory_cs	= 0;
		@( posedge clk );
		#19ns
		io_write( 16'h1234, 8'h12 );
		assert( count == 0 );

		@( posedge clk );
		#38ns
		io_write( 16'h2345, 8'h23 );
		assert( count == 0 );

		@( posedge clk );
		#57ns
		io_write( 16'h3456, 8'h34 );
		assert( count == 0 );

		@( posedge clk );
		#76ns
		io_write( 16'h4567, 8'h45 );
		assert( count == 0 );

		@( posedge clk );
		#95ns
		io_write( 16'h5678, 8'h65 );
		assert( count == 0 );

		@( posedge clk );
		#114ns
		io_write( 16'h6789, 8'hAB );
		assert( count == 0 );

		@( posedge clk );
		#133ns
		io_write( 16'h789A, 8'hCD );
		assert( count == 0 );

		@( posedge clk );
		#152ns
		io_write( 16'h89AB, 8'hEF );
		assert( count == 0 );

		// --------------------------------------------------------------------
		//	memory read test
		// --------------------------------------------------------------------
		test_no			= 7;
		$display( "Memory Read Reject Test" );
		bus_io_cs		= 0;
		bus_memory_cs	= 0;
		@( posedge clk );
		#19ns
		memory_read( 16'h1234, 8'h12 );
		assert( count == 0 );

		@( posedge clk );
		#38ns
		memory_read( 16'h2345, 8'h23 );
		assert( count == 0 );

		@( posedge clk );
		#57ns
		memory_read( 16'h3456, 8'h34 );
		assert( count == 0 );

		@( posedge clk );
		#76ns
		memory_read( 16'h4567, 8'h45 );
		assert( count == 0 );

		@( posedge clk );
		#95ns
		memory_read( 16'h5678, 8'h65 );
		assert( count == 0 );

		@( posedge clk );
		#114ns
		memory_read( 16'h6789, 8'hAB );
		assert( count == 0 );

		@( posedge clk );
		#133ns
		memory_read( 16'h789A, 8'hCD );
		assert( count == 0 );

		@( posedge clk );
		#152ns
		memory_read( 16'h89AB, 8'hEF );
		assert( count == 0 );

		// --------------------------------------------------------------------
		//	I/O read test
		// --------------------------------------------------------------------
		test_no			= 8;
		$display( "I/O Read Reject Test" );
		bus_io_cs		= 0;
		bus_memory_cs	= 0;
		@( posedge clk );
		#19ns
		io_read( 16'h1234, 8'h12 );
		assert( count == 0 );

		@( posedge clk );
		#38ns
		io_read( 16'h2345, 8'h23 );
		assert( count == 0 );

		@( posedge clk );
		#57ns
		io_read( 16'h3456, 8'h34 );
		assert( count == 0 );

		@( posedge clk );
		#76ns
		io_read( 16'h4567, 8'h45 );
		assert( count == 0 );

		@( posedge clk );
		#95ns
		io_read( 16'h5678, 8'h65 );
		assert( count == 0 );

		@( posedge clk );
		#114ns
		io_read( 16'h6789, 8'hAB );
		assert( count == 0 );

		@( posedge clk );
		#133ns
		io_read( 16'h789A, 8'hCD );
		assert( count == 0 );

		@( posedge clk );
		#152ns
		io_read( 16'h89AB, 8'hEF );
		assert( count == 0 );
		$finish;
	end
endmodule
