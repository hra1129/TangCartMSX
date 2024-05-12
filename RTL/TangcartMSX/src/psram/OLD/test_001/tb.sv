// -----------------------------------------------------------------------------
//	Test of ip_psram.v
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
//		PSRAM Controller for TangNano9K
// -----------------------------------------------------------------------------

module tb ();
	localparam		CLK_BASE	= 1000000000/81000;
	reg				n_reset;
	reg				base_clk;
	reg				clk;
	reg				n_clk;
	reg				rd;				// Set to 1 to read
	reg				wr;				// Set to 1 to write
	wire			busy;			// Busy signal
	reg		[21:0]	address;		// Byte address
	reg		[7:0]	wdata;
	wire	[7:0]	rdata;
	wire			rdata_en;
	wire			O_psram_ck;
	wire			w_IO_psram_rwds;
	wire	[7:0]	w_IO_psram_dq;
	reg				IO_psram_rwds;
	reg		[7:0]	IO_psram_dq;
	reg				dir_psram_rwds;
	reg				dir_psram_dq;
	wire			O_psram_cs_n;
	integer			test_no;
	reg		[7:0]	data;

	// --------------------------------------------------------------------
	//	DUT
	// --------------------------------------------------------------------
	ip_psram u_psram (
		.n_reset			( n_reset			),
		.clk				( clk				),
		.n_clk				( n_clk				),
		.rd					( rd				),
		.wr					( wr				),
		.busy				( busy				),
		.address			( address			),
		.wdata				( wdata				),
		.rdata				( rdata				),
		.rdata_en			( rdata_en			),
		.O_psram_ck			( O_psram_ck		),
		.IO_psram_rwds		( w_IO_psram_rwds	),
		.IO_psram_dq		( w_IO_psram_dq		),
		.O_psram_cs_n		( O_psram_cs_n		)
	);

	assign w_IO_psram_rwds	= dir_psram_rwds ? IO_psram_rwds : 1'bZ;
	assign w_IO_psram_dq	= dir_psram_dq   ? IO_psram_dq   : 8'hZZ;

	// --------------------------------------------------------------------
	//	clock
	// --------------------------------------------------------------------
	always #(CLK_BASE/4) begin
		base_clk <= ~base_clk;
	end

	always @( posedge base_clk ) begin
		clk		<= ~clk;
		n_clk	<= ~n_clk;
	end

	// --------------------------------------------------------------------
	//	Write access
	// --------------------------------------------------------------------
	task write_data(
		input	[21:0]	adr,
		input	[7:0]	dat
	);
		//	wait ready
		while( busy ) begin
			@( posedge clk );
		end

		//	set address
		address	<= adr;
		wdata	<= dat;
		wr		<= 1'b1;
		@( posedge clk );

		address	<= 0;
		wdata	<= 0;
		wr		<= 1'b0;
		@( posedge clk );
	endtask: write_data

	// --------------------------------------------------------------------
	//	Write access
	// --------------------------------------------------------------------
	task read_data(
		input	[21:0]	adr,
		input	[7:0]	dat
	);
		logic	[7:0]	out_data;

		//	wait ready
		while( busy ) begin
			@( posedge clk );
		end

		//	set address
		address	<= adr;
		wdata	<= dat;
		rd		<= 1'b1;
		@( posedge clk );

		address	<= 0;
		wdata	<= 0;
		rd		<= 1'b0;
		@( posedge clk );

		while( O_psram_cs_n == 1'b1 ) begin
			@( posedge base_clk );
		end

		dir_psram_rwds <= 1;
		IO_psram_rwds <= 1'b1;
		@( posedge base_clk );
		@( posedge base_clk );
		@( posedge base_clk );
		@( posedge base_clk );
		@( posedge base_clk );
		@( posedge base_clk );

		IO_psram_rwds <= 1'b0;
		@( posedge base_clk );
		@( posedge base_clk );
		@( posedge base_clk );
		@( posedge base_clk );
		@( posedge base_clk );
		@( posedge base_clk );
		@( posedge base_clk );
		@( posedge base_clk );
		@( posedge base_clk );
		@( posedge base_clk );
		@( posedge base_clk );

		dir_psram_dq <= 1'b1;
		IO_psram_dq <= dat;
		@( posedge base_clk );

		IO_psram_rwds <= 1'b1;
		@( posedge base_clk );

		dir_psram_rwds <= 1'b0;
		IO_psram_rwds <= 1'b0;
		dir_psram_dq <= 1'b0;
		@( posedge base_clk );

		//	wait ready
		while( rdata_en == 1'b0 ) begin
			@( posedge clk );
		end

		out_data	<= rdata;
		@( posedge clk );

		assert( out_data == dat );
	endtask: read_data

	// --------------------------------------------------------------------
	//	Test bench
	// --------------------------------------------------------------------
	initial begin
		test_no			= 0;
		n_reset			= 0;
		base_clk		= 0;
		clk				= 0;
		n_clk			= 1;
		rd				= 0;
		wr				= 0;
		address			= 0;
		wdata			= 0;
		IO_psram_rwds	= 1'b0;
		IO_psram_dq		= 8'h00;
		dir_psram_rwds	= 1'b0;
		dir_psram_dq	= 1'b0;

		@( negedge clk );
		@( negedge clk );
		@( posedge clk );

		n_reset			= 1;
		@( posedge clk );

		// wait initial process -------------------------------------------
		$display( "Wait initial process ...." );
		@( negedge busy );
		repeat( 10 ) @( posedge clk );

		// write access ---------------------------------------------------
		$display( "Write test" );
		test_no			= 1;
		write_data( 'h123456, 'h12 );
		write_data( 'h112233, 'h23 );
		write_data( 'h00EFBE, 'h45 );
		write_data( 'h11BEEF, 'h67 );
		repeat( 10 ) @( posedge clk );

		// read access ---------------------------------------------------
		$display( "Read test" );
		test_no			= 2;
		read_data( 'h123456, 'h12 );
		read_data( 'h112233, 'h23 );
		read_data( 'h00EFBE, 'h45 );
		read_data( 'h11BEEF, 'h67 );
		repeat( 100 ) @( posedge clk );
		$finish;
	end
endmodule
