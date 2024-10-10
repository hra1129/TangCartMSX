// -----------------------------------------------------------------------------
//	Test of ip_gpio.v
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
	wire	[7:0]	gpo;
	reg		[7:0]	gpi;
	integer			test_no;

	// --------------------------------------------------------------------
	//	DUT
	// --------------------------------------------------------------------
	ip_gpio u_gpio (
		.n_reset			( n_reset			),
		.clk				( clk				),
		.bus_address		( bus_address		),
		.bus_read_ready		( bus_read_ready	),
		.bus_read_data		( bus_read_data		),
		.bus_write_data		( bus_write_data	),
		.bus_io_read		( bus_io_read		),
		.bus_io_write		( bus_io_write		),
		.gpo				( gpo				),
		.gpi				( gpi				)
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
		gpi				= 8'h83;

		@( negedge clk );
		@( negedge clk );

		n_reset			= 1;
		repeat( 10 ) @( posedge clk );

		// --------------------------------------------------------------------
		//	check write access1
		// --------------------------------------------------------------------
		test_no			= 2;
		$display( "Check write accecss (1)" );
		write_io( 'h0001, 8'h12 );
		assert( gpo == 8'h12 );

		write_io( 'hCD01, 8'hAB );
		assert( gpo == 8'hAB );

		write_io( 'h0501, 8'h55 );
		assert( gpo == 8'h55 );

		write_io( 'h4301, 8'h93 );
		assert( gpo == 8'h93 );

		write_io( 'hAB01, 8'h0F );
		assert( gpo == 8'h0F );

		// --------------------------------------------------------------------
		//	check write access3
		// --------------------------------------------------------------------
		test_no			= 4;
		$display( "Check write accecss (3)" );
		write_io( 'h0001, 8'hDA );
		write_io( 'h0005, 8'h12 );
		assert( gpo == 8'hDA );

		write_io( 'hCDAB, 8'hAB );
		assert( gpo == 8'hDA );

		write_io( 'h0542, 8'h55 );
		assert( gpo == 8'hDA );

		write_io( 'h438F, 8'h93 );
		assert( gpo == 8'hDA );

		write_io( 'hAB26, 8'h0F );
		assert( gpo == 8'hDA );

		// --------------------------------------------------------------------
		//	check read access1
		// --------------------------------------------------------------------
		test_no			= 5;
		$display( "Check read accecss (1)" );
		gpi <= 8'h12;
		read_io( 'h0001, 8'h12 );

		gpi <= 8'hAB;
		read_io( 'hCD01, 8'hAB );

		gpi <= 8'h55;
		read_io( 'h0501, 8'h55 );

		gpi <= 8'h93;
		read_io( 'h4301, 8'h93 );

		gpi <= 8'h0F;
		read_io( 'hAB01, 8'h0F );

		// --------------------------------------------------------------------
		//	check read access2
		// --------------------------------------------------------------------
		test_no			= 7;
		$display( "Check read accecss (3)" );
		gpi <= 8'h12;
		read_io_timeout( 'h0002 );

		gpi <= 8'hAB;
		read_io_timeout( 'hCD10 );

		gpi <= 8'h55;
		read_io_timeout( 'h0555 );

		gpi <= 8'h93;
		read_io_timeout( 'h4332 );

		gpi <= 8'h0F;
		read_io_timeout( 'hABAC );

		$finish;
	end
endmodule
