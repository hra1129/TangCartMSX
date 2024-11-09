// -----------------------------------------------------------------------------
//	Test of kanji_rom_inst.v
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
	localparam		clk_base	= 1_000_000_000/85_909;	//	ps
	reg						reset;
	reg						clk;
	reg						bus_io_req;
	wire					bus_ack;
	reg						bus_wrt;
	reg			[15:0]		bus_address;
	reg			[7:0]		bus_wdata;
	wire		[17:0]		kanji_rom_address;
	wire					kanji_rom_address_en;
	int						i;

	// --------------------------------------------------------------------
	//	DUT
	// --------------------------------------------------------------------
	kanji_rom_inst u_kanji_rom_inst (
		.reset					( reset					),
		.clk					( clk					),
		.bus_io_req				( bus_io_req			),
		.bus_ack				( bus_ack				),
		.bus_wrt				( bus_wrt				),
		.bus_address			( bus_address			),
		.bus_wdata				( bus_wdata				),
		.kanji_rom_address		( kanji_rom_address		),
		.kanji_rom_address_en	( kanji_rom_address_en	)
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
	task reg_write(
		input	[15:0]	p_address,
		input	[7:0]	p_data
	);
		int count;

		count		<= 0;
		bus_io_req	<= 1'b1;
		bus_wrt		<= 1'b1;
		bus_address	<= p_address;
		bus_wdata	<= p_data;
		@( posedge clk );

		while( !bus_ack && count < 5 ) begin
			count	<= count + 1;
			@( posedge clk );
		end

		bus_io_req	<= 1'b0;
		bus_wrt		<= 1'b0;
		@( posedge clk );
	endtask : reg_write

	// --------------------------------------------------------------------
	task reg_read(
		input	[15:0]	p_address,
		input	[17:0]	p_kanji_rom_address
	);
		int count;

		count		<= 0;
		bus_io_req	<= 1'b1;
		bus_wrt		<= 1'b0;
		bus_address	<= p_address;
		bus_wdata	<= 8'd0;
		@( posedge clk );

		while( !bus_ack && count < 5 ) begin
			count	<= count + 1;
			@( posedge clk );
		end

		bus_io_req	<= 1'b0;

		while( !kanji_rom_address_en ) begin
			@( posedge clk );
		end

		if( kanji_rom_address == p_kanji_rom_address ) begin
			$display( "[OK] read( %02X ) == %05X", p_address, p_kanji_rom_address );
		end
		else begin
			$display( "[NG] read( %02X ) == %05X != %05X", p_address, p_kanji_rom_address, kanji_rom_address );
		end
		@( posedge clk );
	endtask : reg_read

	// --------------------------------------------------------------------
	//	Test bench
	// --------------------------------------------------------------------
	initial begin
		reset			= 1'b1;
		clk				= 1'b0;
		bus_io_req		= 1'b0;
		bus_wrt			= 1'b0;
		bus_address		= 1'b0;
		bus_wdata		= 1'b0;

		@( negedge clk );
		@( negedge clk );
		@( posedge clk );

		reset			= 1'b0;
		@( posedge clk );
		repeat( 10 ) @( posedge clk );

		$display( "<<TEST001>> JIS1 Register Write Test" );
		reg_write( 16'h00D8, 8'h12 );
		reg_write( 16'h00D9, 8'h23 );

		$display( "<<TEST002>> JIS2 Register Write Test" );
		reg_write( 16'h00DA, 8'h34 );
		reg_write( 16'h00DB, 8'h56 );

		$display( "<<TEST003>> JIS1 Register Read Test" );
		reg_read( 16'h00D9, { 1'b0, 6'h23, 6'h12, 5'h00 } );
		reg_read( 16'h00D9, { 1'b0, 6'h23, 6'h12, 5'h01 } );
		reg_read( 16'h00D9, { 1'b0, 6'h23, 6'h12, 5'h02 } );
		reg_read( 16'h00D9, { 1'b0, 6'h23, 6'h12, 5'h03 } );
		reg_read( 16'h00D9, { 1'b0, 6'h23, 6'h12, 5'h04 } );

		$display( "<<TEST004>> JIS2 Register Read Test" );
		reg_read( 16'h00DB, { 1'b1, 6'h16, 6'h34, 5'h00 } );
		reg_read( 16'h00DB, { 1'b1, 6'h16, 6'h34, 5'h01 } );
		reg_read( 16'h00DB, { 1'b1, 6'h16, 6'h34, 5'h02 } );
		reg_read( 16'h00DB, { 1'b1, 6'h16, 6'h34, 5'h03 } );
		reg_read( 16'h00DB, { 1'b1, 6'h16, 6'h34, 5'h04 } );

		$display( "<<TEST005>> JIS1 Register Read Test" );
		reg_read( 16'h00D9, { 1'b0, 6'h23, 6'h12, 5'h05 } );
		reg_read( 16'h00D9, { 1'b0, 6'h23, 6'h12, 5'h06 } );
		reg_read( 16'h00D9, { 1'b0, 6'h23, 6'h12, 5'h07 } );
		reg_read( 16'h00D9, { 1'b0, 6'h23, 6'h12, 5'h08 } );

		$display( "<<TEST006>> JIS2 Register Read Test" );
		reg_read( 16'h00DB, { 1'b1, 6'h16, 6'h34, 5'h05 } );
		reg_read( 16'h00DB, { 1'b1, 6'h16, 6'h34, 5'h06 } );
		reg_read( 16'h00DB, { 1'b1, 6'h16, 6'h34, 5'h07 } );
		reg_read( 16'h00DB, { 1'b1, 6'h16, 6'h34, 5'h08 } );

		$display( "<<TEST007>> JIS1/JIS2 Register Read Test" );
		for( i = 9; i < 128; i++ ) begin
			reg_read( 16'h00D9, { 1'b0, 6'h23, 6'h12, 5'h00 } + i );
			reg_read( 16'h00DB, { 1'b1, 6'h16, 6'h34, 5'h00 } + i );
		end

		repeat( 10 ) @( posedge clk );

		$finish;
	end
endmodule
