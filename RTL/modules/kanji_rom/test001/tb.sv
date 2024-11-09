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
	reg						req;
	wire					ack;
	reg						wrt;
	reg			[7:0]		address;
	reg			[7:0]		wdata;
	wire		[7:0]		kanji_rom_address;
	wire					kanji_rom_address_en;

	// --------------------------------------------------------------------
	//	DUT
	// --------------------------------------------------------------------
	kanji_rom_inst u_kanji_rom_inst (
		.reset					( reset					),
		.clk					( clk					),
		.req					( req					),
		.ack					( ack					),
		.wrt					( wrt					),
		.address				( address				),
		.wdata					( wdata					),
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
		input	[7:0]	p_reference_data
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

		while( !bus_rdata_en ) begin
			@( posedge clk );
		end

		if( bus_rdata == p_reference_data ) begin
			$display( "[OK] read( %04X ) == %02X", p_address, p_reference_data );
		end
		else begin
			$display( "[NG] read( %04X ) == %02X != %02X", p_address, p_reference_data, bus_rdata );
		end
		@( posedge clk );
	endtask : reg_read

	// --------------------------------------------------------------------
	//	Test bench
	// --------------------------------------------------------------------
	initial begin
		reset			= 1'b1;
		clk				= 1'b0;
		req				= 1'b0;
		wrt				= 1'b0;
		address			= 1'b0;
		wdata			= 1'b0;

		@( negedge clk );
		@( negedge clk );
		@( posedge clk );

		reset			= 1'b0;
		@( posedge clk );
		repeat( 10 ) @( posedge clk );

		$display( "<<TEST001>> JIS1 Register Write Test" );
		reg_write( 16'h00D8, 8'h12 );
		reg_write( 16'h00D9, 8'h23 );

		repeat( 10 ) @( posedge clk );

		$finish;
	end
endmodule
