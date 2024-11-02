// -----------------------------------------------------------------------------
//	Test of ip_sdram.v
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
	localparam		clk_base	= 1_000_000_000/108_000;	//	ps
	reg				n_reset;
	reg				clk;				//	85.90908MHz
	reg				clk_sdram;			//	85.90908MHz
	wire			sdram_busy;
	reg				dh_clk;				//	10.738635MHz: VideoDHClk
	reg				dl_clk;				//	 5.369318MHz: VideoDLClk
	reg		[22:0]	address;
	reg				is_write;			//	0:Read, 1:Write
	reg		[ 7:0]	wdata;
	wire	[15:0]	rdata;
	wire			O_sdram_clk;
	wire			O_sdram_cke;
	wire			O_sdram_cs_n;		// chip select
	wire			O_sdram_cas_n;		// columns address select
	wire			O_sdram_ras_n;		// row address select
	wire			O_sdram_wen_n;		// write enable
	wire	[31:0]	IO_sdram_dq;		// 32 bit bidirectional data bus
	wire	[10:0]	O_sdram_addr;		// 11 bit multiplexed address bus
	wire	[ 1:0]	O_sdram_ba;			// two banks
	wire	[ 3:0]	O_sdram_dqm;		// data mask
	reg		[ 1:0]	ff_video_clk;

	// --------------------------------------------------------------------
	//	DUT
	// --------------------------------------------------------------------
	ip_sdram u_sdram_controller (
		.n_reset			( n_reset			),
		.clk				( clk				),
		.clk_sdram			( clk				),
		.enable_state		( ff_video_clk		),
		.sdram_busy			( sdram_busy		),
		.dh_clk				( dh_clk			),
		.dl_clk				( dl_clk			),
		.address			( address			),
		.is_write			( is_write			),
		.wdata				( wdata				),
		.rdata				( rdata				),
		.O_sdram_clk		( O_sdram_clk		),
		.O_sdram_cke		( O_sdram_cke		),
		.O_sdram_cs_n		( O_sdram_cs_n		),
		.O_sdram_cas_n		( O_sdram_cas_n		),
		.O_sdram_ras_n		( O_sdram_ras_n		),
		.O_sdram_wen_n		( O_sdram_wen_n		),
		.IO_sdram_dq		( IO_sdram_dq		),
		.O_sdram_addr		( O_sdram_addr		),
		.O_sdram_ba			( O_sdram_ba		),
		.O_sdram_dqm		( O_sdram_dqm		)
	);

	// --------------------------------------------------------------------
	mt48lc2m32b2 u_sdram (
		.Dq					( IO_sdram_dq		), 
		.Addr				( O_sdram_addr		), 
		.Ba					( O_sdram_ba		), 
		.Clk				( O_sdram_clk		), 
		.Cke				( O_sdram_cke		), 
		.Cs_n				( O_sdram_cs_n		), 
		.Ras_n				( O_sdram_ras_n		), 
		.Cas_n				( O_sdram_cas_n		), 
		.We_n				( O_sdram_wen_n		), 
		.Dqm				( O_sdram_dqm		)
	);

	// --------------------------------------------------------------------
	//	clock
	// --------------------------------------------------------------------
	always #(clk_base/2) begin
		clk <= ~clk;
		clk_sdram <= ~clk_sdram;
	end

	always @( posedge clk ) begin
		ff_video_clk <= ff_video_clk + 2'd1;
	end

	always @( posedge clk ) begin
		if( sdram_busy ) begin
			//	hold
		end
		else if( ff_video_clk == 2'b11 ) begin
			dh_clk <= ~dh_clk;
		end
	end

	always @( posedge clk ) begin
		if( sdram_busy ) begin
			//	hold
		end
		else if( (ff_video_clk == 2'b11) && !dh_clk ) begin
			dl_clk <= ~dl_clk;
		end
	end

	// --------------------------------------------------------------------
	//	Tasks
	// --------------------------------------------------------------------
	task write_data(
		input	[22:0]	p_address,
		input	[7:0]	p_data
	);
		address		<= p_address;
		wdata		<= p_data;
		is_write	<= 1'b1;
		forever begin
			if( dl_clk && dh_clk && (ff_video_clk == 2'b00) ) begin
				break;
			end
			@( posedge clk );
		end
		repeat( 4 ) @( posedge clk );

		address		<= 0;
		wdata		<= 0;
		is_write	<= 1'b0;
		repeat( 12 ) @( posedge clk );
	endtask: write_data

	// --------------------------------------------------------------------
	task read_data(
		input	[22:0]	p_address,
		input	[15:0]	p_data
	);
		int time_out;

		address		<= p_address;
		is_write	<= 1'b0;
		forever begin
			if( dl_clk && dh_clk && (ff_video_clk == 2'b00) ) begin
				break;
			end
			@( posedge clk );
		end
		repeat( 16 ) @( posedge clk );
	endtask: read_data

	// --------------------------------------------------------------------
	//	Test bench
	// --------------------------------------------------------------------
	initial begin
		n_reset = 0;
		clk = 0;
		clk_sdram = 1;
		is_write = 0;
		address = 0;
		wdata = 0;
		ff_video_clk = 0;

		dh_clk = 0;
		dl_clk = 1;

		@( negedge clk );
		@( negedge clk );
		@( posedge clk );

		n_reset			= 1;
		@( posedge clk );

		while( sdram_busy ) begin
			@( posedge clk );
		end

		repeat( 16 ) @( posedge clk );
		repeat( 7 ) @( posedge clk );

		write_data( 'h000000, 'h12 );
		write_data( 'h000001, 'h23 );
		write_data( 'h000002, 'h34 );
		write_data( 'h000003, 'h45 );
		write_data( 'h000004, 'h56 );
		write_data( 'h000005, 'h67 );
		write_data( 'h000006, 'h78 );
		write_data( 'h000007, 'h89 );

		read_data(  'h000000, 'h2312 );
		read_data(  'h000001, 'h2312 );
		read_data(  'h000002, 'h4534 );
		read_data(  'h000003, 'h4534 );
		read_data(  'h000000, 'h6756 );
		read_data(  'h000001, 'h6756 );
		read_data(  'h000002, 'h8978 );
		read_data(  'h000003, 'h8978 );

		repeat( 12 ) @( posedge clk );
		$finish;
	end
endmodule
