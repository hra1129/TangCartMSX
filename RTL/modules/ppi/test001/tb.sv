// -----------------------------------------------------------------------------
//	Test of ppi_inst.v
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
	wire		[7:0]		bus_rdata;
	wire					bus_rdata_en;
	wire		[3:0]		matrix_y;
	reg			[7:0]		matrix_x;
	wire					cmt_motor_off;
	wire					cmt_write_signal;
	wire					keyboard_caps_led_off;
	wire					click_sound;
	wire					sltsl0;
	wire					sltsl1;
	wire					sltsl2;
	wire					sltsl3;

	// --------------------------------------------------------------------
	//	DUT
	// --------------------------------------------------------------------
	ppi_inst u_ppi (
		.reset						( reset						),
		.clk						( clk						),
		.bus_io_req					( bus_io_req				),
		.bus_ack					( bus_ack					),
		.bus_wrt					( bus_wrt					),
		.bus_address				( bus_address				),
		.bus_wdata					( bus_wdata					),
		.bus_rdata					( bus_rdata					),
		.bus_rdata_en				( bus_rdata_en				),
		.matrix_y					( matrix_y					),
		.matrix_x					( matrix_x					),
		.cmt_motor_off				( cmt_motor_off				),
		.cmt_write_signal			( cmt_write_signal			),
		.keyboard_caps_led_off		( keyboard_caps_led_off		),
		.click_sound				( click_sound				),
		.sltsl0						( sltsl0					),
		.sltsl1						( sltsl1					),
		.sltsl2						( sltsl2					),
		.sltsl3						( sltsl3					)
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
	task check_slot(
		input	[15:0]	p_address,
		input	[3:0]	p_slot
	);
		bus_address	<= p_address;
		@( posedge clk );

		if( p_slot == { sltsl3, sltsl2, sltsl1, sltsl0 } ) begin
			$display( "[OK] slot check( %04X ) : sltsl OK", p_address );
		end
		else begin
			$display( "[NG] slot check( %04X ) : %01X != %01X", p_address, p_slot, { sltsl3, sltsl2, sltsl1, sltsl0 } );
		end
		@( posedge clk );
	endtask : check_slot

	// --------------------------------------------------------------------
	task check_matrix_sel(
		input	[7:0]	p_sel
	);
		if( p_sel == { click_sound, keyboard_caps_led_off, cmt_write_signal, cmt_motor_off, matrix_y } ) begin
			$display( "[OK] matrix select check : OK" );
		end
		else begin
			$display( "[NG] matrix select check : %02X != %02X", p_sel, { click_sound, keyboard_caps_led_off, cmt_write_signal, cmt_motor_off, matrix_y } );
		end
		@( posedge clk );
	endtask : check_matrix_sel

	// --------------------------------------------------------------------
	task check_matrix(
		input	[7:0]	p_matrix_x
	);
		matrix_x <= p_matrix_x;
		@( posedge clk );

		reg_read( 16'h00A9, p_matrix_x );
	endtask : check_matrix

	// --------------------------------------------------------------------
	//	Test bench
	// --------------------------------------------------------------------
	initial begin
		reset				= 1;
		clk					= 0;
		bus_io_req			= 0;
		bus_wrt				= 0;
		bus_address			= 0;
		bus_wdata			= 0;
		matrix_x			= 0;

		@( negedge clk );
		@( negedge clk );
		@( posedge clk );

		reset			= 1'b0;
		@( posedge clk );
		repeat( 10 ) @( posedge clk );

		reg_write( 16'h00AA, 8'h23 );							//	PortC

		$display( "<<TEST001>> Primary slot write Test" );
		reg_write( 16'h00A8, { 2'd0, 2'd1, 2'd2, 2'd3 } );		//	PortA

		$display( "<<TEST002>> Primary slot read Test" );
		check_slot( 16'h0000, 4'b1000 );
		check_slot( 16'h4000, 4'b0100 );
		check_slot( 16'h8000, 4'b0010 );
		check_slot( 16'hC000, 4'b0001 );

		check_slot( 16'h0159, 4'b1000 );
		check_slot( 16'h4A26, 4'b0100 );
		check_slot( 16'h87B3, 4'b0010 );
		check_slot( 16'hC48C, 4'b0001 );

		check_slot( 16'h0591, 4'b1000 );
		check_slot( 16'h426A, 4'b0100 );
		check_slot( 16'h8B37, 4'b0010 );
		check_slot( 16'hC8C4, 4'b0001 );

		$display( "<<TEST003>> Primary slot write Test" );
		reg_write( 16'h00A8, { 2'd2, 2'd3, 2'd0, 2'd1 } );		//	PortA

		$display( "<<TEST004>> Primary slot read Test" );
		check_slot( 16'h0000, 4'b0010 );
		check_slot( 16'h4000, 4'b0001 );
		check_slot( 16'h8000, 4'b1000 );
		check_slot( 16'hC000, 4'b0100 );

		check_slot( 16'h0159, 4'b0010 );
		check_slot( 16'h4A26, 4'b0001 );
		check_slot( 16'h87B3, 4'b1000 );
		check_slot( 16'hC48C, 4'b0100 );

		check_slot( 16'h0591, 4'b0010 );
		check_slot( 16'h426A, 4'b0001 );
		check_slot( 16'h8B37, 4'b1000 );
		check_slot( 16'hC8C4, 4'b0100 );

		$display( "<<TEST005>> PortC write Test" );
		reg_write( 16'h00AA, 8'h12 );		//	PortC
		check_matrix_sel( 8'h12 );
		reg_write( 16'h00AA, 8'h34 );		//	PortC
		check_matrix_sel( 8'h34 );
		reg_write( 16'h00AA, 8'hAB );		//	PortC
		check_matrix_sel( 8'hAB );
		reg_write( 16'h00AA, 8'h9F );		//	PortC
		check_matrix_sel( 8'h9F );

		$display( "<<TEST006>> PortB read Test" );
		check_matrix( 8'h19 );
		check_matrix( 8'hA5 );
		check_matrix( 8'hD2 );
		check_matrix( 8'h8A );
		check_matrix( 8'h46 );
		check_matrix( 8'hFF );
		check_matrix( 8'h00 );

		$finish;
	end
endmodule
