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
	reg				clk;				// 108MHz
	reg				clk_sdram;			// 108MHz with 180dgree delay
	reg				rd;					// Set to 1 to read
	reg				wr;					// Set to 1 to write
	wire			busy;
	reg		[22:0]	address;			// Byte address (8MBytes)
	reg		[7:0]	wdata;
	wire	[15:0]	rdata;
	wire			rdata_en;
	wire			O_sdram_clk;
	wire			O_sdram_cke;
	wire			O_sdram_cs_n;		// chip select
	wire			O_sdram_cas_n;		// columns address select
	wire			O_sdram_ras_n;		// row address select
	wire			O_sdram_wen_n;		// write enable
	wire	[31:0]	IO_sdram_dq;		// 32 bit bidirectional data bus
	wire	[10:0]	O_sdram_addr;		// 11 bit multiplexed address bus
	wire	[1:0]	O_sdram_ba;			// two banks
	wire	[3:0]	O_sdram_dqm;		// data mask

	// --------------------------------------------------------------------
	//	DUT
	// --------------------------------------------------------------------
	ip_sdram u_sdram_controller (
		.n_reset			( n_reset			),
		.clk				( clk				),
		.clk_sdram			( clk_sdram			),
		.rd_n				( !rd				),
		.wr_n				( !wr				),
		.busy				( busy				),
		.address			( address			),
		.wdata				( wdata				),
		.rdata				( rdata				),
		.rdata_en			( rdata_en			),
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

	// --------------------------------------------------------------------
	//	Tasks
	// --------------------------------------------------------------------
	task write_data(
		input	[22:0]	p_address,
		input	[7:0]	p_data
	);
		while( busy ) begin
			@( posedge clk );
		end

		address		<= p_address;
		wdata		<= p_data;
		wr			<= 1'b1;
		@( posedge clk );

		address		<= 0;
		wdata		<= 0;
		wr			<= 1'b0;
		@( posedge clk );
	endtask: write_data

	// --------------------------------------------------------------------
	task read_data(
		input	[22:0]	p_address,
		input	[15:0]	p_data
	);
		int time_out;

		while( busy ) begin
			@( posedge clk );
		end

		address		<= p_address;
		rd			<= 1'b1;
		@( posedge clk );

		rd			<= 1'b0;
		time_out	= 100;
		forever begin
			if( rdata_en ) begin
				assert( p_data == rdata );
				break;
			end
			@( posedge clk );
			time_out <= time_out - 1;
			if( time_out == 0 ) begin
				$error( "Read time out." );
				$finish;
			end
		end
		@( posedge clk );
	endtask: read_data

	// --------------------------------------------------------------------
	//	Test bench
	// --------------------------------------------------------------------
	initial begin
		n_reset = 0;
		clk = 0;
		clk_sdram = 1;
		rd = 0;
		wr = 0;
		address = 0;
		wdata = 0;

		@( negedge clk );
		@( negedge clk );
		@( posedge clk );

		n_reset			= 1;
		repeat( 10 ) @( posedge clk );

		write_data( 'h000000, 'h12 );
		write_data( 'h000001, 'h23 );
		write_data( 'h100002, 'h34 );
		write_data( 'h100003, 'h45 );
		write_data( 'h200000, 'h56 );
		write_data( 'h200001, 'h67 );
		write_data( 'h300002, 'h78 );
		write_data( 'h300003, 'h89 );

		read_data(  'h000000, 'h2312 );
		read_data(  'h000001, 'h2312 );
		read_data(  'h100002, 'h4534 );
		read_data(  'h100003, 'h4534 );
		read_data(  'h200000, 'h6756 );
		read_data(  'h200001, 'h6756 );
		read_data(  'h300002, 'h8978 );
		read_data(  'h300003, 'h8978 );

		forever begin
			if( !busy ) begin
				break;
			end
			@( posedge clk );
		end

		$finish;
	end
endmodule
