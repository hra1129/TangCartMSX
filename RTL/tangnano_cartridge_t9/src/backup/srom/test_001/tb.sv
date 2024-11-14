// -----------------------------------------------------------------------------
//	Test of ip_srom.v
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
//		SerialROM
// -----------------------------------------------------------------------------

module tb ();
	localparam		clk_base	= 1000000000/53693;
	integer			test_num;
	reg				n_reset;
	reg				clk;
	wire			srom_cs;
	wire			srom_mosi;
	wire			srom_sclk;
	reg				srom_miso;
	reg				n_cs;
	reg				rd;
	reg				wr;
	wire			busy;
	reg		[7:0]	wdata;
	wire	[7:0]	rdata;
	wire			rdata_en;
	wire			psram1_wr;
	reg				psram1_busy;
	wire	[21:0]	psram1_address;
	wire	[7:0]	psram1_wdata;
	wire			initial_busy;
	reg		[7:0]	data;

	// --------------------------------------------------------------------
	//	DUT
	// --------------------------------------------------------------------
	ip_srom #(
		.END_ADDRESS	( 'h1FF				)
	) u_srom (
		.n_reset		( n_reset			),
		.clk			( clk				),
		.srom_cs		( srom_cs			),
		.srom_mosi		( srom_mosi			),
		.srom_sclk		( srom_sclk			),
		.srom_miso		( srom_miso			),
		.n_cs			( n_cs				),
		.rd				( rd				),
		.wr				( wr				),
		.busy			( busy				),
		.wdata			( wdata				),
		.rdata			( rdata				),
		.rdata_en		( rdata_en			),
		.psram1_wr		( psram1_wr			),
		.psram1_busy	( psram1_busy		),
		.psram1_address	( psram1_address	),
		.psram1_wdata	( psram1_wdata		),
		.initial_busy	( initial_busy		)
	);

	// --------------------------------------------------------------------
	//	clock
	// --------------------------------------------------------------------
	always #(clk_base/2) begin
		clk <= ~clk;
	end

	// --------------------------------------------------------------------
	//	Write task
	// --------------------------------------------------------------------
	task write_data(
		input	[7:0]	wd
	);
		wr		<= 1;
		wdata	<= wd;
		@( posedge clk );
		while( busy ) begin
			@( posedge clk );
		end
		wr		<= 0;
		wdata	<= 0;
		@( posedge clk );
	endtask: write_data

	// --------------------------------------------------------------------
	//	Write task
	// --------------------------------------------------------------------
	task read_data(
		output	[7:0]	data
	);
		rd		<= 1;
		@( posedge clk );
		while( busy ) begin
			@( posedge clk );
		end
		rd		<= 0;
		@( posedge clk );
		while( rdata_en == 1'b0 ) begin
			@( posedge clk );
		end
		data	<= rdata;
		@( posedge clk );
	endtask: read_data

	// --------------------------------------------------------------------
	//	Test bench
	// --------------------------------------------------------------------
	initial begin
		test_num		= 0;
		n_reset			= 0;
		clk				= 0;
		srom_miso		= 1;
		n_cs			= 1;
		rd				= 0;
		wr				= 0;
		wdata			= 0;
		psram1_busy		= 0;

		@( negedge clk );
		@( negedge clk );
		@( posedge clk );

		n_reset			= 1;
		repeat( 50 ) @( posedge clk );

		srom_miso		= 0;
		@( posedge clk );

		// --------------------------------------------------------------------
		//	wait initial state
		// --------------------------------------------------------------------
		test_num = 1;
		while( initial_busy ) begin
			n_cs <= ~n_cs;					//	Confirm that this control has no effect
			@( posedge clk );
		end

		@( posedge clk );

		// --------------------------------------------------------------------
		//	Verify that the CS signal can now be controlled
		// --------------------------------------------------------------------
		test_num = 2;
		repeat( 10 ) begin
			n_cs <= ~n_cs;
			@( posedge clk );
		end

		n_cs <= 1;
		@( posedge clk );

		// --------------------------------------------------------------------
		//	Check write access
		// --------------------------------------------------------------------
		test_num = 3;
		@( posedge clk );

		n_cs <= 0;
		@( posedge clk );

		write_data( 'h12 );
		write_data( 'h23 );
		write_data( 'hAB );
		write_data( 'hCD );

		n_cs <= 1;
		repeat( 20 ) @( posedge clk );

		// --------------------------------------------------------------------
		//	Check read access
		// --------------------------------------------------------------------
		test_num = 4;

		n_cs <= 0;
		@( posedge clk );

		read_data( data );
		read_data( data );
		read_data( data );
		read_data( data );

		n_cs <= 1;
		@( posedge clk );

		repeat( 100 ) @( posedge clk );

		$finish;
	end
endmodule
