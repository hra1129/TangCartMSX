// -----------------------------------------------------------------------------
//	Test of dcsg_wrapper.v
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
	reg						en_clk_psg_i;
	reg						n_ioreq;
	reg						n_wr;
	reg		[15:0]			address;
	reg		[7:0]			wdata;
	wire	[13:0]			sound_out;

	int						counter;
	reg		[1:0]			ff_clock_divider;

	// --------------------------------------------------------------------
	//	DUT
	// --------------------------------------------------------------------
	ip_dcsg_wrapper u_dcsg (
		.n_reset			( n_reset			),
		.clk				( clk				),
		.en_clk_psg_i		( en_clk_psg_i		),
		.n_ioreq			( n_ioreq			),
		.n_wr				( n_wr				),
		.address			( address			),
		.wdata				( wdata				),
		.sound_out			( sound_out			)
	);

	// --------------------------------------------------------------------
	//	clock
	// --------------------------------------------------------------------
	always #(clk_base/2) begin
		clk <= ~clk;				//	21.47727MHz
	end

	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_clock_divider <= 2'b00;
		end
		else begin
			ff_clock_divider <= ff_clock_divider + 2'b01;
		end
	end

	assign en_clk_psg_i = (ff_clock_divider == 2'b11 );

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
		repeat( 256 ) @( posedge clk );
	endtask: write_reg

	// --------------------------------------------------------------------
	//	Test bench
	// --------------------------------------------------------------------
	initial begin
		test_no			= -1;
		n_reset			= 0;
		clk				= 1;

		n_ioreq			= 1;
		n_wr			= 1;
		address			= 0;
		wdata			= 0;

		@( negedge clk );
		@( negedge clk );
		@( posedge clk );

		n_reset			= 1;
		@( posedge clk );

		write_reg( 16'h003F, 8'h8F );
		write_reg( 16'h003F, 8'h00 );
		write_reg( 16'h003F, 8'h9F );

		repeat( 100000 ) @( posedge clk );

		$finish;
	end
endmodule
