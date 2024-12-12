// -----------------------------------------------------------------------------
//	Test of micom_connect.v
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
	reg						spi_cs_n;
	reg						spi_clk;
	reg						spi_mosi;
	wire					spi_miso;
	wire					msx_reset_n;
	reg			[7:0]		read_data;
	reg			[1:0]		ff_clock_divider;

	// --------------------------------------------------------------------
	//	DUT
	// --------------------------------------------------------------------
	micom_connect u_micom_connect (
		.reset_n		( reset_n		),
		.clk			( clk			),
		.spi_cs_n		( spi_cs_n		),
		.spi_clk		( spi_clk		),
		.spi_mosi		( spi_mosi		),
		.spi_miso		( spi_miso		),
		.msx_reset_n	( msx_reset_n	)
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
	task send_byte(
		input	[7:0]	wdata,
		output	[7:0]	rdata
	);
		for( i = 0; i < 8; i = i + 1 ) begin
			# 20ns
			spi_clk		<= 1'b0;
			# 1ns
			spi_mosi	<= wdata[7-i];
			# 20ns
			spi_clk		<= 1'b1;
			# 1ns
			rdata[7-i]	<= spi_miso;
		end
		# 21ns
		spi_clk		<= 1'b0;
		# 21ns
		spi_clk		<= 1'b0;
	endtask: send_byte

	// --------------------------------------------------------------------
	//	Test bench
	// --------------------------------------------------------------------
	initial begin
		test_no		= -1;
		reset_n		= 0;
		clk			= 1;
		spi_cs_n	= 1;
		spi_clk		= 0;
		spi_mosi	= 0;

		@( negedge clk );
		@( negedge clk );
		@( posedge clk );

		reset_n		= 1;
		@( posedge clk );

		spi_cs_n	= 0;
		@( posedge clk );
		send_byte( 8'h00, read_data );
		assert( read_data == 8'hA5 );
		@( posedge clk );
		spi_cs_n	= 1;
		@( posedge clk );

		spi_cs_n	= 0;
		@( posedge clk );
		send_byte( 8'h02, read_data );
		assert( read_data == 8'hA5 );
		@( posedge clk );
		spi_cs_n	= 1;
		@( posedge clk );

		spi_cs_n	= 0;
		@( posedge clk );
		send_byte( 8'h01, read_data );
		assert( read_data == 8'hA5 );
		@( posedge clk );
		spi_cs_n	= 1;
		@( posedge clk );

		spi_cs_n	= 0;
		@( posedge clk );
		send_byte( 8'h02, read_data );
		assert( read_data == 8'hA5 );
		@( posedge clk );
		spi_cs_n	= 1;
		@( posedge clk );

		$finish;
	end
endmodule
