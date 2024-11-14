// -----------------------------------------------------------------------------
//	Test of ssg_inst.v
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
	localparam	clk_base	= 1_000_000_000/85_909;	//	ps
	int						test_no;
	int						i;
	reg						reset;
	reg						clk;
	wire					enable;			//	21.47727MHz pulse
	reg						bus_io_req;
	wire					bus_ack;
	reg						bus_wrt;
	reg			[15:0]		bus_address;
	reg			[7:0]		bus_wdata;
	wire		[7:0]		bus_rdata;
	wire					bus_rdata_en;
	wire		[5:0]		joystick_port1;
	wire		[5:0]		joystick_port2;
	wire					strobe_port1;
	wire					strobe_port2;
	reg						keyboard_type;
	reg						cmt_read;
	wire					kana_led;
	wire		[7:0]		sound_out;

	reg			[1:0]		ff_clock_divider;
	int						counter;

	// --------------------------------------------------------------------
	//	DUT
	// --------------------------------------------------------------------
	ssg_inst u_ssg_inst (
	.reset				( reset				),
	.clk				( clk				),
	.enable				( enable			),
	.bus_io_req			( bus_io_req		),
	.bus_ack			( bus_ack			),
	.bus_wrt			( bus_wrt			),
	.bus_address		( bus_address		),
	.bus_wdata			( bus_wdata			),
	.bus_rdata			( bus_rdata			),
	.bus_rdata_en		( bus_rdata_en		),
	.joystick_port1		( joystick_port1	),
	.joystick_port2		( joystick_port2	),
	.strobe_port1		( strobe_port1		),
	.strobe_port2		( strobe_port2		),
	.keyboard_type		( keyboard_type		),
	.cmt_read			( cmt_read			),
	.kana_led			( kana_led			),
	.sound_out			( sound_out			)
	);

	// --------------------------------------------------------------------
	//	clock
	// --------------------------------------------------------------------
	always #(clk_base/2) begin
		clk <= ~clk;				//	85.90908MHz
	end

	// --------------------------------------------------------------------
	//	clock divider
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( reset ) begin
			ff_clock_divider <= 2'd0;
		end
		else begin
			ff_clock_divider <= ff_clock_divider + 2'd1;
		end
	end

	assign enable = (ff_clock_divider == 2'd3 );

	// --------------------------------------------------------------------
	//	Tasks
	// --------------------------------------------------------------------
	task write_reg(
		input	[15:0]	_bus_address,
		input	[7:0]	_bus_wdata
	);
		bus_io_req		<= 1'b1;
		bus_address		<= _bus_address;
		bus_wdata		<= _bus_wdata;
		bus_wrt			<= 1'b1;
		counter			<= 0;						//	timeout counter
		@( posedge clk );

		while( !bus_ack && counter < 5 ) begin
			counter <= counter + 1;
			@( posedge clk );
		end

		bus_io_req		<= 1'b0;
		bus_address		<= 0;
		bus_wdata		<= 0;
		bus_wrt			<= 1'b0;
		@( posedge clk );
	endtask: write_reg

	// --------------------------------------------------------------------
	task write_ssg_reg(
		input	[3:0]	_ssg_register_num,
		input	[7:0]	_ssg_wdata
	);
		$display( "Write SSG Register#%d <= 0x%02X;", _ssg_register_num, _ssg_wdata );
		write_reg( 16'h00A0, { 4'd0, _ssg_register_num } );
		write_reg( 16'h00A1, _ssg_wdata );
	endtask: write_ssg_reg

	// --------------------------------------------------------------------
	//	Test bench
	// --------------------------------------------------------------------
	initial begin
		test_no		= -1;
		reset		= 1;
		clk			= 1;

		bus_io_req		= 0;
		bus_wrt			= 0;
		bus_address		= 0;
		bus_wdata		= 0;
		keyboard_type	= 0;
		cmt_read		= 0;

		@( negedge clk );
		@( negedge clk );
		@( posedge clk );

		reset		= 0;
		@( posedge clk );

		write_ssg_reg( 0, 2 );
		write_ssg_reg( 1, 0 );
		write_ssg_reg( 2, 2 );
		write_ssg_reg( 3, 0 );
		write_ssg_reg( 4, 2 );
		write_ssg_reg( 5, 0 );
		repeat( 12'hFFF * 4 ) @( posedge clk );

		// --------------------------------------------------------------------
		//	Envelope test
		// --------------------------------------------------------------------
		test_no = 1;
		for( i = 0; i < 16; i = i + 1 ) begin
			$display( "Envelope %d (Port A)", i );
			write_ssg_reg( 0, 2 );
			write_ssg_reg( 1, 0 );
			write_ssg_reg( 7, 8'b10111110 );
			write_ssg_reg( 8, 16 );
			write_ssg_reg( 11, 10 );
			write_ssg_reg( 12, 0 );
			write_ssg_reg( 13, i );
			repeat( 50000 ) @( posedge clk );
		end
		write_ssg_reg( 8, 0 );

		test_no = 2;
		for( i = 0; i < 16; i = i + 1 ) begin
			$display( "Envelope %d (Port B)", i );
			write_ssg_reg( 2, 2 );
			write_ssg_reg( 3, 0 );
			write_ssg_reg( 7, 8'b10111101 );
			write_ssg_reg( 9, 16 );
			write_ssg_reg( 11, 10 );
			write_ssg_reg( 12, 0 );
			write_ssg_reg( 13, i );
			repeat( 50000 ) @( posedge clk );
		end
		write_ssg_reg( 9, 0 );

		test_no = 3;
		for( i = 0; i < 16; i = i + 1 ) begin
			$display( "Envelope %d (Port C)", i );
			write_ssg_reg( 4, 2 );
			write_ssg_reg( 5, 0 );
			write_ssg_reg( 7, 8'b10111011 );
			write_ssg_reg( 10, 16 );
			write_ssg_reg( 11, 10 );
			write_ssg_reg( 12, 0 );
			write_ssg_reg( 13, i );
			repeat( 50000 ) @( posedge clk );
		end
		write_ssg_reg( 10, 0 );

		// --------------------------------------------------------------------
		//	Volume test
		// --------------------------------------------------------------------
		test_no = 4;
		for( i = 0; i < 16; i = i + 1 ) begin
			$display( "Volume %d (Port A)", i );
			write_ssg_reg( 0, 2 );
			write_ssg_reg( 1, 0 );
			write_ssg_reg( 7, 8'b10111110 );
			write_ssg_reg( 8, i );
			write_ssg_reg( 11, 10 );
			write_ssg_reg( 12, 0 );
			repeat( 50000 ) @( posedge clk );
		end
		write_ssg_reg( 8, 0 );

		test_no = 5;
		for( i = 0; i < 16; i = i + 1 ) begin
			$display( "Volume %d (Port B)", i );
			write_ssg_reg( 2, 2 );
			write_ssg_reg( 3, 0 );
			write_ssg_reg( 7, 8'b10111101 );
			write_ssg_reg( 9, i );
			write_ssg_reg( 11, 10 );
			write_ssg_reg( 12, 0 );
			repeat( 50000 ) @( posedge clk );
		end
		write_ssg_reg( 9, 0 );

		test_no = 6;
		for( i = 0; i < 16; i = i + 1 ) begin
			$display( "Volume %d (Port C)", i );
			write_ssg_reg( 4, 2 );
			write_ssg_reg( 5, 0 );
			write_ssg_reg( 7, 8'b10111011 );
			write_ssg_reg( 10, i );
			write_ssg_reg( 11, 10 );
			write_ssg_reg( 12, 0 );
			repeat( 50000 ) @( posedge clk );
		end
		write_ssg_reg( 10, 0 );

		// --------------------------------------------------------------------
		//	Envelope frequency test
		// --------------------------------------------------------------------
		test_no = 7;
		for( i = 0; i < 16; i = i + 1 ) begin
			$display( "Envelope frequency %d (Port A)", (i * 256) + 127 );
			write_ssg_reg( 0, 2 );
			write_ssg_reg( 1, 0 );
			write_ssg_reg( 7, 8'b10111110 );
			write_ssg_reg( 8, 16 );
			write_ssg_reg( 11, 127 );
			write_ssg_reg( 12, i );
			write_ssg_reg( 13, 0 );
			repeat( 500000 ) @( posedge clk );
		end
		write_ssg_reg( 8, 0 );

		// --------------------------------------------------------------------
		//	Volume frequency test
		// --------------------------------------------------------------------
		test_no = 8;
		for( i = 0; i < 16; i = i + 1 ) begin
			$display( "Volume frequency %d (Port A)", (i * 256) + 127 );
			write_ssg_reg( 0, 127 );
			write_ssg_reg( 1, i );
			write_ssg_reg( 7, 8'b10111110 );
			write_ssg_reg( 8, 15 );
			repeat( 500000 ) @( posedge clk );
		end
		write_ssg_reg( 8, 0 );

		// --------------------------------------------------------------------
		//	Noise frequency test
		// --------------------------------------------------------------------
		test_no = 9;
		for( i = 0; i < 32; i = i + 1 ) begin
			$display( "Noise frequency %d (Port A)", i );
			write_ssg_reg( 0, 2 );
			write_ssg_reg( 1, 0 );
			write_ssg_reg( 6, i );
			write_ssg_reg( 7, 8'b10110111 );
			write_ssg_reg( 8, 15 );
			repeat( 500000 ) @( posedge clk );
		end
		write_ssg_reg( 8, 0 );

		// --------------------------------------------------------------------
		//	Noise and tone frequency test
		// --------------------------------------------------------------------
		test_no = 10;
		for( i = 0; i < 32; i = i + 1 ) begin
			$display( "Noise frequency %d (Port A)", i );
			write_ssg_reg( 0, 128 );
			write_ssg_reg( 1, i / 2 );
			write_ssg_reg( 6, i );
			write_ssg_reg( 7, 8'b10110110 );
			write_ssg_reg( 8, 15 );
			repeat( 500000 ) @( posedge clk );
		end
		write_ssg_reg( 8, 0 );
		$finish;
	end
endmodule
