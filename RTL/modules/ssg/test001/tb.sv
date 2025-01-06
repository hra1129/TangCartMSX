// -----------------------------------------------------------------------------
//	Test of ssg.v
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
	reg						reset_n;
	reg						clk;
	wire					enable;			//	21.47727MHz pulse
	reg						iorq_n;
	reg						wr_n;
	reg						rd_n;
	reg			[15:0]		address;
	reg			[7:0]		wdata;
	wire		[7:0]		rdata;
	wire					rdata_en;
	wire		[5:0]		w_ssg_ioa;
	reg			[5:0]		ssg_ioa;
	wire		[2:0]		ssg_iob;
	reg						keyboard_type;
	reg						cmt_read;
	wire					kana_led;
	wire		[11:0]		sound_out;

	reg			[1:0]		ff_clock_divider;
	int						counter;
	reg			[7:0]		ff_rdata;

	// --------------------------------------------------------------------
	//	DUT
	// --------------------------------------------------------------------
	ssg u_ssg (
	.reset_n			( reset_n			),
	.clk				( clk				),
	.enable				( enable			),
	.iorq_n				( iorq_n			),
	.wr_n				( wr_n				),
	.rd_n				( rd_n				),
	.address			( address[1:0]		),
	.wdata				( wdata				),
	.rdata				( rdata				),
	.rdata_en			( rdata_en			),
	.ssg_ioa			( w_ssg_ioa			),
	.ssg_iob			( ssg_iob			),
	.keyboard_type		( keyboard_type		),
	.cmt_read			( cmt_read			),
	.kana_led			( kana_led			),
	.sound_out			( sound_out			)
	);
	
	assign w_ssg_ioa	= ssg_ioa;

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
		if( !reset_n ) begin
			ff_clock_divider <= 2'd0;
		end
		else begin
			ff_clock_divider <= ff_clock_divider + 2'd1;
		end
	end

	assign enable = (ff_clock_divider == 2'd3 );

	// --------------------------------------------------------------------
	//	rdata
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_rdata <= 8'h00;
		end
		else if( rdata_en ) begin
			ff_rdata <= rdata;
		end
	end

	// --------------------------------------------------------------------
	//	Tasks
	// --------------------------------------------------------------------
	task write_reg(
		input	[15:0]	_address,
		input	[7:0]	_wdata
	);
		$display( "write_reg( 0x%04X, 0x%02X )", _address, _wdata );
		address		<= _address;
		wdata		<= _wdata;
		iorq_n		<= 1'b0;
		wr_n		<= 1'b0;
		@( posedge clk );
		@( posedge clk );

		iorq_n		<= 1'b1;
		wr_n		<= 1'b1;
		address		<= 0;
		wdata		<= 0;
		@( posedge clk );
		@( posedge clk );
		@( posedge clk );
		@( posedge clk );
		@( posedge clk );
		@( posedge clk );
	endtask: write_reg

	// --------------------------------------------------------------------
	task read_reg(
		input	[15:0]	_address,
		input	[7:0]	_rdata
	);
		int time_out;

		$display( "read_reg( 0x%04X, 0x%02X )", _address, _rdata );
		address		<= _address;
		iorq_n		<= 1'b0;
		@( posedge clk );
		rd_n		<= 1'b0;
		repeat( 16 ) @( negedge clk );

		iorq_n		<= 1'b1;
		rd_n		<= 1'b1;
		@( posedge clk );

		assert( ff_rdata == _rdata );
		if( ff_rdata != _rdata ) begin
			$display( "-- p_data = %08X (ref: %08X)", rdata, _rdata );
		end

		@( posedge clk );
		@( posedge clk );
		@( posedge clk );
		@( posedge clk );
	endtask: read_reg

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
		test_no			= -1;
		reset_n			= 0;
		clk				= 1;

		iorq_n			= 1;
		wr_n			= 1;
		rd_n			= 1;
		address			= 0;
		wdata			= 0;
		keyboard_type	= 0;
		cmt_read		= 0;

		@( negedge clk );
		@( negedge clk );
		@( posedge clk );

		reset_n		= 1;
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

		// --------------------------------------------------------------------
		//	Read port test
		// --------------------------------------------------------------------
		test_no = 11;
		write_ssg_reg( 15, 8'b00000000 );
		write_reg( 0, 14 );
		ssg_ioa = 6'b101010;
		read_reg( 2, ssg_ioa );
		ssg_ioa = 6'b010101;
		read_reg( 2, ssg_ioa );
		ssg_ioa = 6'b110011;
		read_reg( 2, ssg_ioa );
		ssg_ioa = 6'b111000;
		read_reg( 2, ssg_ioa );
		$finish;
	end
endmodule
