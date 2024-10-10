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
	wire			rd;					// Set to 1 to read
	wire			wr;					// Set to 1 to write
	wire			busy;
	wire	[22:0]	address;			// Byte address (8MBytes)
	wire	[7:0]	wdata;
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
	reg		[1:0]	ff_keys;
	wire	[7:0]	send_data;
	wire			send_req;
	wire			send_busy;
	wire			w_uart_tx;

	// --------------------------------------------------------------------
	//	DUT
	// --------------------------------------------------------------------
	ip_debugger #(
		.TEST_ROWS			( 15'b000_0000_1111_1111)
	) u_debugger (
		.n_reset			( n_reset				),
		.clk				( clk					),
		.send_data			( send_data				),
		.send_req			( send_req				),
		.send_busy			( send_busy				),
		.keys				( ff_keys				),
		.sdram_rd			( rd					),
		.sdram_wr			( wr					),
		.sdram_busy			( busy					),
		.sdram_address		( address				),
		.sdram_wdata		( wdata					),
		.sdram_rdata		( rdata[7:0]			),
		.sdram_rdata_en		( rdata_en				)
	);

	ip_uart #(
		.clk_freq			( 108000000				),
		.uart_freq			( 115200				)
	) u_uart (
		.n_reset			( n_reset				),
		.clk				( clk					),
		.send_data			( send_data				),
		.send_req			( send_req				),
		.send_busy			( send_busy				),
		.uart_tx			( w_uart_tx				)
	);

	ip_sdram u_sdram_controller (
		.n_reset			( n_reset				),
		.clk				( clk					),
		.clk_sdram			( clk_sdram				),
		.rd_n				( !rd					),
		.wr_n				( !wr					),
		.busy				( busy					),
		.address			( address				),
		.wdata				( wdata					),
		.rdata				( rdata					),
		.rdata_en			( rdata_en				),
		.O_sdram_clk		( O_sdram_clk			),
		.O_sdram_cke		( O_sdram_cke			),
		.O_sdram_cs_n		( O_sdram_cs_n			),
		.O_sdram_cas_n		( O_sdram_cas_n			),
		.O_sdram_ras_n		( O_sdram_ras_n			),
		.O_sdram_wen_n		( O_sdram_wen_n			),
		.IO_sdram_dq		( IO_sdram_dq			),
		.O_sdram_addr		( O_sdram_addr			),
		.O_sdram_ba			( O_sdram_ba			),
		.O_sdram_dqm		( O_sdram_dqm			)
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
	//	Test bench
	// --------------------------------------------------------------------
	initial begin
		n_reset = 0;
		clk = 0;
		clk_sdram = 1;
		ff_keys = 0;

		@( negedge clk );
		@( negedge clk );
		@( posedge clk );

		n_reset			= 1;
		repeat( 10 ) @( posedge clk );

		ff_keys <= 2'b01;
		@( posedge clk );

		ff_keys <= 2'b00;
		@( posedge clk );

		repeat( 2500000 ) @( posedge clk );

		$finish;
	end
endmodule
