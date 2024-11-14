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
	localparam	clk_base	= 1_000_000_000/21_477;	//	ps
	int						test_no;
	reg						n_reset;
	reg						clk;
	reg						n_ioreq;
	reg						n_wr;
	reg						n_rd;
	reg			[15:0]		address;
	reg			[7:0]		wdata;
	wire		[7:0]		rdata;
	wire					rdata_en;

	wire		[7:0]		sound_out;

	int						counter;

	// --------------------------------------------------------------------
	//	DUT
	// --------------------------------------------------------------------
	ssg_inst u_ssg_inst (
	.n_reset			( n_reset			),
	.clk				( clk				),
	.n_ioreq			( n_ioreq			),
	.n_wr				( n_wr				),
	.n_rd				( n_rd				),
	.address			( address			),
	.wdata				( wdata				),
	.rdata				( rdata				),
	.rdata_en			( rdata_en			),
	.sound_out			( sound_out			)
	);

	// --------------------------------------------------------------------
	//	clock
	// --------------------------------------------------------------------
	always #(clk_base/2) begin
		clk <= ~clk;				//	85.90908MHz
	end

	// --------------------------------------------------------------------
	//	Tasks
	// --------------------------------------------------------------------
	task write_reg(
		input	[15:0]	_bus_address,
		input	[7:0]	_bus_wdata
	);
		n_ioreq			<= 1'b0;
		n_wr			<= 1'b0;
		address			<= _bus_address;
		wdata			<= _bus_wdata;
		counter			<= 0;						//	timeout counter
		repeat( 12 ) @( posedge clk );

		n_ioreq			<= 1'b1;
		address			<= 0;
		wdata			<= 0;
		n_wr			<= 1'b1;
		repeat( 12 ) @( posedge clk );
	endtask: write_reg

	// --------------------------------------------------------------------
	task write_ssg_reg(
		input	[3:0]	_ssg_register_num,
		input	[7:0]	_ssg_wdata
	);
		$display( "Write SSG Register#%d <= 0x%02X;", _ssg_register_num, _ssg_wdata );
		write_reg( 16'h0010, { 4'd0, _ssg_register_num } );
		write_reg( 16'h0011, _ssg_wdata );
	endtask: write_ssg_reg

	// --------------------------------------------------------------------
	//	Test bench
	// --------------------------------------------------------------------
	initial begin
		test_no			= -1;
		n_reset			= 0;
		clk				= 1;

		n_ioreq			= 1;
		n_wr			= 1;
		n_rd			= 1;
		address			= 0;
		wdata			= 0;

		@( negedge clk );
		@( negedge clk );
		@( posedge clk );

		n_reset			= 1;
		@( posedge clk );

		// --------------------------------------------------------------------
		//	Envelope test
		// --------------------------------------------------------------------
		for( test_no = 0; test_no < 16; test_no = test_no + 1 ) begin
			$display( "Envelope %d", test_no );
			write_ssg_reg( 0, 0 );
			write_ssg_reg( 1, 0 );
			write_ssg_reg( 7, 8'b10111110 );
			write_ssg_reg( 8, 16 );
			write_ssg_reg( 11, 10 );
			write_ssg_reg( 12, 0 );
			write_ssg_reg( 13, test_no );
			repeat( 50000 ) @( posedge clk );
		end
		$finish;
	end
endmodule
