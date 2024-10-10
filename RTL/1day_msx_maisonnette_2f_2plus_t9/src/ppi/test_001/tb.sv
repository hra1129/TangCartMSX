// -----------------------------------------------------------------------------
//	Test of ip_ppi.v
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
//		Simple PPI clone for MSX body
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
	wire	[7:0]	primary_slot;
	wire	[3:0]	key_matrix_row;
	wire			motor_off;
	wire			cas_write;
	wire			caps_led_off;
	wire			click_sound;
	reg		[7:0]	key_matrix_column;
	integer			test_no;

	// --------------------------------------------------------------------
	//	DUT
	// --------------------------------------------------------------------
	ip_ppi u_ppi (
		.n_reset				( n_reset				),
		.clk					( clk					),
		.bus_address			( bus_address			),
		.bus_io_cs				( bus_io_cs				),
		.bus_memory_cs			( bus_memory_cs			),
		.bus_read_ready			( bus_read_ready		),
		.bus_read_data			( bus_read_data			),
		.bus_write_data			( bus_write_data		),
		.bus_read				( bus_read				),
		.bus_write				( bus_write				),
		.bus_io					( bus_io				),
		.bus_memory				( bus_memory			),
		.primary_slot			( primary_slot			),
		.key_matrix_row			( key_matrix_row		),
		.motor_off				( motor_off				),
		.cas_write				( cas_write				),
		.caps_led_off			( caps_led_off			),
		.click_sound			( click_sound			),
		.key_matrix_column		( key_matrix_column		)
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
		key_matrix_column = 0;

		@( negedge clk );
		@( negedge clk );

		n_reset			= 1;
		repeat( 10 ) @( posedge clk );

		// --------------------------------------------------------------------
		//	check CS port
		// --------------------------------------------------------------------
		test_no			= 1;
		$display( "Check CS port" );
		assert( bus_io_cs == 1'b1 );
		assert( bus_memory_cs == 1'b0 );
		@( posedge clk );

		// --------------------------------------------------------------------
		//	check write primary slot register (Port.A)
		// --------------------------------------------------------------------
		test_no			= 2;
		$display( "Check write primary slot register(1)" );
		write_io( 'h00A8, 8'h12 );
		assert( primary_slot == 8'h12 );

		write_io( 'hCDA8, 8'hAB );
		assert( primary_slot == 8'hAB );

		write_io( 'h05A8, 8'h55 );
		assert( primary_slot == 8'h55 );

		write_io( 'h43A8, 8'h93 );
		assert( primary_slot == 8'h93 );

		write_io( 'hABA8, 8'h0F );
		assert( primary_slot == 8'h0F );

		// --------------------------------------------------------------------
		//	check write primary slot register (Port.A)
		// --------------------------------------------------------------------
		test_no			= 3;
		$display( "Check write primary slot register(2)" );
		write_io( 'h00A8, 8'hDA );
		write_memory( 'h00A8, 8'h12 );
		assert( primary_slot == 8'hDA );

		write_memory( 'hCDA8, 8'hAB );
		assert( primary_slot == 8'hDA );

		write_memory( 'h05A8, 8'h55 );
		assert( primary_slot == 8'hDA );

		write_memory( 'h43A8, 8'h93 );
		assert( primary_slot == 8'hDA );

		write_memory( 'hABA8, 8'h0F );
		assert( primary_slot == 8'hDA );

		// --------------------------------------------------------------------
		//	check write key matrix register (Port.C)
		// --------------------------------------------------------------------
		test_no			= 4;
		$display( "Check write key matrix register(1)" );
		write_io( 'h00AA, 8'h12 );
		assert( { click_sound, caps_led_off, cas_write, motor_off, key_matrix_row } == 8'h12 );

		write_io( 'hCDAA, 8'hAB );
		assert( { click_sound, caps_led_off, cas_write, motor_off, key_matrix_row } == 8'hAB );

		write_io( 'h05AA, 8'h55 );
		assert( { click_sound, caps_led_off, cas_write, motor_off, key_matrix_row } == 8'h55 );

		write_io( 'h43AA, 8'h93 );
		assert( { click_sound, caps_led_off, cas_write, motor_off, key_matrix_row } == 8'h93 );

		write_io( 'hABAA, 8'h0F );
		assert( { click_sound, caps_led_off, cas_write, motor_off, key_matrix_row } == 8'h0F );

		// --------------------------------------------------------------------
		//	check write key matrix register (Port.C)
		// --------------------------------------------------------------------
		test_no			= 5;
		$display( "Check write key matrix register(2)" );
		write_io( 'h00AA, 8'hAD );
		write_memory( 'h00AA, 8'h12 );
		assert( { click_sound, caps_led_off, cas_write, motor_off, key_matrix_row } == 8'hAD );

		write_memory( 'hCDAA, 8'hAB );
		assert( { click_sound, caps_led_off, cas_write, motor_off, key_matrix_row } == 8'hAD );

		write_memory( 'h05AA, 8'h55 );
		assert( { click_sound, caps_led_off, cas_write, motor_off, key_matrix_row } == 8'hAD );

		write_memory( 'h43AA, 8'h93 );
		assert( { click_sound, caps_led_off, cas_write, motor_off, key_matrix_row } == 8'hAD );

		write_memory( 'hABAA, 8'h0F );
		assert( { click_sound, caps_led_off, cas_write, motor_off, key_matrix_row } == 8'hAD );

		// --------------------------------------------------------------------
		//	check read back
		// --------------------------------------------------------------------
		test_no			= 5;
		$display( "Check read back register" );
		write_io( 'h00A8, 8'h12 );
		write_io( 'h00A9, 8'h34 );
		write_io( 'h00AA, 8'h56 );
		write_io( 'h00AB, 8'h78 );
		key_matrix_column = 8'h9A;

		$display( " io read A8" );
		read_io( 'h00A8, 'h12 );
		$display( " io read A9" );
		read_io( 'h00A9, 'h9A );
		$display( " io read AA" );
		read_io( 'h00AA, 'h56 );
		$display( " io read AB" );
		read_io( 'h00AB, 'hFF );

		$display( " io read A8" );
		read_io( 'h54A8, 'h12 );
		$display( " io read A9" );
		read_io( 'h56A9, 'h9A );
		$display( " io read AA" );
		read_io( 'h76AA, 'h56 );
		$display( " io read AB" );
		read_io( 'h23AB, 'hFF );

		$display( " memory read 00A8" );
		read_memory_timeout( 'h00A8 );
		$display( " memory read 00A9" );
		read_memory_timeout( 'h00A9 );
		$display( " memory read 00AA" );
		read_memory_timeout( 'h00AA );
		$display( " memory read 00AB" );
		read_memory_timeout( 'h00AB );

		$display( " io read A7" );
		read_io_timeout( 'h00A7 );
		$display( " io read AC" );
		read_io_timeout( 'h00AC );
		$display( " io read 01" );
		read_io_timeout( 'h0001 );
		$display( " io read 23" );
		read_io_timeout( 'h0023 );

		$finish;
	end
endmodule
