// -----------------------------------------------------------------------------
//	Test of ip_opll_wrapper.v
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
	localparam		clk_base	= 64'd1_000_000_000_000 / 64'd21_477_270;	//	pico sec.
	reg				n_reset;
	reg				clk;
	wire			mclkpcen_n;
	reg				n_ioreq;
	reg				n_sltsl;
	reg				n_wr;
	reg		[15:0]	address;
	reg		[7:0]	wdata;
	wire	[15:0]	sound_out;
	reg		[2:0]	ff_4mhz;

	// --------------------------------------------------------------------
	//	DUT
	// --------------------------------------------------------------------
	ip_ikaopll_wrapper #(
		.BUILT_IN_MODE	( 1				)	// 0: Cartridge mode, 1: Built in mode
	) u_ikaopll_wrapper (
		.n_reset		( n_reset		),
		.clk			( clk			),
		.mclkpcen_n		( mclkpcen_n	),
		.n_ioreq		( n_ioreq		),
		.n_sltsl		( n_sltsl		),
		.n_wr			( n_wr			),
		.address		( address		),
		.wdata			( wdata			),
		.sound_out		( sound_out		)
	);

	// --------------------------------------------------------------------
	//	clock
	// --------------------------------------------------------------------
	always #(clk_base/2) begin
		clk <= ~clk;
	end

	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_4mhz <= 3'd0;
		end
		else if( ff_4mhz == 3'd5 ) begin
			ff_4mhz <= 3'd0;
		end
		else begin
			ff_4mhz <= ff_4mhz + 3'd1;
		end
	end

	assign mclkpcen_n	= (ff_4mhz == 3'd0) ? 1'b0: 1'b1;

	// --------------------------------------------------------------------
	//	Write register (Primary slot)
	// --------------------------------------------------------------------
	task write_register(
		input	[15:0]	_address,
		input	[7:0]	_data
	);
		n_sltsl = 1'b1;
		wdata = 8'dz;
		@( posedge clk );
		#170ns	address = _address;
		#124ns	n_sltsl = 1'b0;
		#55ns	wdata = _data;
		@( negedge clk );
		#140ns	n_wr = 1'b0;
		//	Half clock = 139.6826ns
		#258ns	n_wr = 1'b1;
		#35ns	n_sltsl = 1'b1;
		#30ns	wdata = 8'dz;
	endtask: write_register

	// --------------------------------------------------------------------
	//	Write register (Extended slot)
	// --------------------------------------------------------------------
	task write_register_ext(
		input	[15:0]	_address,
		input	[7:0]	_data
	);
		
	endtask: write_register_ext

	// --------------------------------------------------------------------
	//	Write register (Extended slot)
	// --------------------------------------------------------------------
	task opll_register(
		input	[7:0]	_address,
		input	[7:0]	_data
	);
		write_register( 16'h7FF4, _address );		//	register number
		repeat( 6 * (12 + 1) ) @( posedge clk );
		write_register( 16'h7FF5, _data );			//	register value
		repeat( 6 * (84 + 1) ) @( posedge clk );
	endtask: opll_register

	// --------------------------------------------------------------------
	//	Test bench
	// --------------------------------------------------------------------
	initial begin
		n_reset			= 0;
		clk				= 0;
		n_ioreq			= 1;
		n_sltsl			= 1;
		n_wr			= 1;
		address			= 0;
		wdata			= 0;

		repeat( 150 ) @( posedge clk );

		n_reset			= 1;
		repeat( 150 ) @( posedge clk );

		write_register( 16'h7FF6, 8'd01 );
		repeat( 60 ) @( posedge clk );

		//リズムパラメータセットアップ
		opll_register( 8'h16, 8'h20 );
		opll_register( 8'h17, 8'h50 );
		opll_register( 8'h18, 8'hC0 );
		opll_register( 8'h26, 8'h05 );
		opll_register( 8'h27, 8'h05 );
		opll_register( 8'h28, 8'h01 );

		//リズム再生
		opll_register( 8'h0E, 8'h30 );

		//FMセットアップ
		opll_register( 8'h10, 8'hAC );
		opll_register( 8'h30, 8'hE0 );
		opll_register( 8'h20, 8'h17 );

		repeat( 1000000 ) @( posedge clk );

		//FMストップ
		opll_register( 8'h20, 8'h07 );

		repeat( 300 ) @( posedge clk );
		$finish;
	end
endmodule
