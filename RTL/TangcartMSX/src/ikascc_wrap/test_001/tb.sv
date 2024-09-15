// -----------------------------------------------------------------------------
//	Test of ip_scc_wrapper.v
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
//		The role of protocol conversion by replacing the asynchronous MSXBUS 
//		signal with an internal clock.
// -----------------------------------------------------------------------------

module tb ();
	localparam		clk_base	= 64'd1_000_000_000_000 / 64'd3_579_545;	//	pico sec.
	reg				n_reset;
	reg				cpu_clk;
	reg				clk;
	reg				mclk_pcen_n;
	reg				n_tsltsl;
	reg				n_trd;
	reg				n_twr;
	reg		[15:0]	ta;
	reg		[7:0]	wdata;
	wire	[7:0]	rdata;
	wire			rdata_en;
	wire	[10:0]	sound_out;
	wire	[4:0]	n_led;

	// --------------------------------------------------------------------
	//	DUT
	// --------------------------------------------------------------------
	ip_ikascc_wrapper u_ikascc_wrapper (
		.n_reset		( n_reset		),
		.clk			( clk			),
		.mclk_pcen_n	( mclk_pcen_n	),
		.n_tsltsl		( n_tsltsl		),
		.n_trd			( n_trd			),
		.n_twr			( n_twr			),
		.ta				( ta			),
		.wdata			( wdata			),
		.rdata			( rdata			),
		.rdata_en		( rdata_en		),
		.sound_out		( sound_out		),
		.n_led			( n_led			)
	);

	// --------------------------------------------------------------------
	//	clock
	// --------------------------------------------------------------------
	always #(clk_base/2) begin
		cpu_clk <= ~cpu_clk;
	end

	always @( posedge cpu_clk or negedge cpu_clk ) begin
		#40ps
		clk <= ~clk;
	end

	// --------------------------------------------------------------------
	//	Write register (Primary slot)
	// --------------------------------------------------------------------
	task write_register(
		input	[15:0]	address,
		input	[7:0]	data
	);
		
	endtask: write_register

	// --------------------------------------------------------------------
	//	Read register (Primary slot)
	// --------------------------------------------------------------------
	task read_register(
		input	[15:0]	address,
		output	[7:0]	data
	);
		
	endtask: read_register

	// --------------------------------------------------------------------
	//	Write register (Extended slot)
	// --------------------------------------------------------------------
	task write_register_ext(
		input	[15:0]	address,
		input	[7:0]	data
	);
		
	endtask: write_register_ext

	// --------------------------------------------------------------------
	//	Read register (Extended slot)
	// --------------------------------------------------------------------
	task read_register_ext(
		input	[15:0]	address,
		output	[7:0]	data
	);
		
	endtask: read_register_ext

	// --------------------------------------------------------------------
	//	Test bench
	// --------------------------------------------------------------------
	initial begin
		n_reset			= 0;
		cpu_clk			= 0;
		clk				= 0;

		@( negedge cpu_clk );
		@( negedge cpu_clk );

		n_reset			= 1;
		repeat( 10 ) @( posedge cpu_clk );


		repeat( 10 ) @( posedge cpu_clk );
		$finish;
	end
endmodule
