// -----------------------------------------------------------------------------
//	tangmega60k_step3.v
//	Copyright (C)2025 Takayuki Hara (HRA!)
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

module tangmega60k_step3 (
	input			clk50m,				//	clk50m			
	input	[2:0]	button,				//	button[2:0]		KEY.2/1/0	Y12, AB13, AA13
	output	[5:0]	led,				//	led[5:0]		
	output			uart_tx,			//	uart_tx			
	//	DDR3-SDRAM I/F
	output	[13:0]	ddr_addr,			//	DDR3_A[13:0]	
	output	[2:0]	ddr_ba,				//	DDR3_BA[2:0]	
	output			ddr_cs_n,			//	DDR3_CS_N		
	output			ddr_ras_n,			//	DDR3_RAS_N		
	output			ddr_cas_n,			//	DDR3_CAS_N		
	output			ddr_we_n,			//	DDR3_WE_N		
	output			ddr_clk,			//	DDR3_CK_P		
	output			ddr_clk_n,			//	DDR3_CK_N		
	output			ddr_cke,			//	DDR3_CKEN		
	output			ddr_odt,			//	DDR3_ODT0_N		
	output			ddr_reset_n,		//	DDR3_RST_N		
	output	[1:0]	ddr_dqm,			//	DDR3_DQM[1:0]	
	inout	[15:0]	ddr_dq,				//	DDR3_DQ[15:0]	
	inout	[1:0]	ddr_dqs,			//	DDR3_DQS_P[1:0]	
	inout	[1:0]	ddr_dqs_n			//	DDR3_DQS_N[1:0]	
);
	reg				ff_reset_n0 = 1'b0;
	reg				ff_reset_n = 1'b0;
	wire			clk88m;				//	87.5MHz from PLL
	wire			clk350m;			//	350MHz from PLL
	wire			clk44m;				//	43.75MHz
	wire			pll_lock;
	wire			sdram_init_busy;	//	0: Normal, 1: DDR3 SDRAM Initialization phase.
	wire			bus_memreq;			//	cZ80 --> device 0: none, 1: memory request
	wire			bus_ioreq;			//	cZ80 --> device 0: none, 1: io request
	wire	[15:0]	bus_address;		//	cZ80 --> device Peripheral device address
	wire			bus_write;			//	cZ80 --> device Direction 0: Read, 1: Write
	wire			bus_valid;			//	cZ80 --> device 
	wire			bus_ready;			//	cZ80 --> device 0: Busy, 1: Ready
	wire	[7:0]	bus_wdata;			//	cZ80 --> device 
	wire	[7:0]	bus_rdata;			//	device --> cZ80
	wire			bus_rdata_en;		//	device --> cZ80
	wire			bus_rom_ready;		//	rom --> cZ80 0: Busy, 1: Ready
	wire	[7:0]	bus_rom_rdata;		//	rom --> cZ80
	wire			bus_rom_rdata_en;	//	rom --> cZ80
	wire			bus_ram_ready;		//	ram --> cZ80 0: Busy, 1: Ready
	wire	[7:0]	bus_ram_rdata;		//	ram --> cZ80
	wire			bus_ram_rdata_en;	//	ram --> cZ80
	wire			bus_uart_ready;		//	uart --> cZ80 0: Busy, 1: Ready
	wire	[7:0]	bus_uart_rdata;		//	uart --> cZ80
	wire			bus_uart_rdata_en;	//	uart --> cZ80
	wire			bus_test_ready;		//	test controller --> cZ80 0: Busy, 1: Ready
	wire	[7:0]	bus_test_rdata;		//	test controller --> cZ80
	wire			bus_test_rdata_en;	//	test controller --> cZ80
	wire	[26:0]	dram_address;		//	test_module --> DDR3 Controller 64Mword/16bit: [26:24]=BANK, [23:10]=ROW, [9:0]=COLUMN
	wire			dram_write;			//	test_module --> DDR3 Controller Direction 0: Read, 1: Write
	wire			dram_valid;			//	test_module --> DDR3 Controller 
	wire			dram_ready;			//	test_module --> DDR3 Controller 0: Busy, 1: Ready
	wire	[127:0]	dram_wdata;			//	test_module --> DDR3 Controller 
	wire	[15:0]	dram_wdata_mask;	//	test_module --> DDR3 Controller 
	wire	[127:0]	dram_rdata;			//	test_module --> DDR3 Controller 
	wire			dram_rdata_en;	//	test_module --> DDR3 Controller 

	always @( posedge clk49m ) begin
		ff_reset_n0	<= 1'b1;
		ff_reset_n	<= ff_reset_n0;
	end

	assign led		= 6'd0;

	// --------------------------------------------------------------------
	//	CLOCK
	// --------------------------------------------------------------------
	Gowin_PLL your_instance_name(
		.lock					( pll_lock				),		//	output lock
		.clkout0				( clk350m				),		//	output clkout0
		.clkout1				( clk88m				),		//	output clkout1
		.clkin					( clk50m				)		//	input clkin
	);

	// --------------------------------------------------------------------
	//	Z80 core
	// --------------------------------------------------------------------
	cz80_wrap u_cz80 (
		.reset_n				( ff_reset_n			),
		.clk_n					( clk44m				),
		.int_n					( 1'b1					),
		.bus_address			( bus_address			),
		.bus_memreq				( bus_memreq			),
		.bus_ioreq				( bus_ioreq				),
		.bus_valid				( bus_valid				),
		.bus_ready				( bus_ready				),
		.bus_write				( bus_write				),
		.bus_wdata				( bus_wdata				),
		.bus_rdata				( bus_rdata				),
		.bus_rdata_en			( bus_rdata_en			)
	);

	assign bus_ready	= bus_uart_ready    | bus_rom_ready    | bus_ram_ready    | bus_test_ready;
	assign bus_rdata	= bus_uart_rdata    | bus_rom_rdata    | bus_ram_rdata    | bus_test_rdata;
	assign bus_rdata_en	= bus_uart_rdata_en | bus_rom_rdata_en | bus_ram_rdata_en | bus_test_rdata_en;

	// --------------------------------------------------------------------
	//	TEST Module
	// --------------------------------------------------------------------
	test_controller u_test_controller (
		.reset_n				( ff_reset_n			),
		.clk					( clk44m				),
		.sdram_init_busy		( sdram_init_busy		),
		.bus_address			( bus_address[7:0]		),
		.bus_ioreq				( bus_ioreq				),
		.bus_write				( bus_write				),
		.bus_valid				( bus_valid				),
		.bus_ready				( bus_test_ready		),
		.bus_wdata				( bus_wdata				),
		.bus_rdata				( bus_test_rdata		),
		.bus_rdata_en			( bus_test_rdata_en		),
		.dram_address			( dram_address			),
		.dram_write				( dram_write			),
		.dram_valid				( dram_valid			),
		.dram_ready				( dram_ready			),
		.dram_wdata				( dram_wdata			),
		.dram_wdata_mask		( dram_wdata_mask		),
		.dram_rdata				( dram_rdata			),
		.dram_rdata_en			( dram_rdata_en			)
	);

	// --------------------------------------------------------------------
	//	UART
	// --------------------------------------------------------------------
	ip_uart_inst #(
		.clk_freq				( 37125000				),
		.uart_freq				( 115200				)
	) u_uart (
		.reset_n				( ff_reset_n			),
		.clk					( clk44m				),
		.bus_address			( bus_address[7:0]		),
		.bus_ioreq				( bus_ioreq				),
		.bus_write				( bus_write				),
		.bus_valid				( bus_valid				),
		.bus_ready				( bus_uart_ready		),
		.bus_wdata				( bus_wdata				),
		.bus_rdata				( bus_uart_rdata		),
		.bus_rdata_en			( bus_uart_rdata_en		),
		.button					( button				),
		.uart_tx				( uart_tx				)
	);

	// --------------------------------------------------------------------
	//	ROM
	// --------------------------------------------------------------------
	ip_rom u_rom (
		.reset_n				( ff_reset_n			),
		.clk					( clk44m				),
		.bus_address			( bus_address			),
		.bus_memreq				( bus_memreq			),
		.bus_valid				( bus_valid				),
		.bus_ready				( bus_rom_ready			),
		.bus_write				( bus_write				),
		.bus_rdata				( bus_rom_rdata			),
		.bus_rdata_en			( bus_rom_rdata_en		)
	);

	// --------------------------------------------------------------------
	//	RAM
	// --------------------------------------------------------------------
	ip_ram u_ram (
		.reset_n				( ff_reset_n			),
		.clk					( clk44m				),
		.bus_address			( bus_address			),
		.bus_memreq				( bus_memreq			),
		.bus_valid				( bus_valid				),
		.bus_ready				( bus_ram_ready			),
		.bus_write				( bus_write				),
		.bus_wdata				( bus_wdata				),
		.bus_rdata				( bus_ram_rdata			),
		.bus_rdata_en			( bus_ram_rdata_en		)
	);

	// --------------------------------------------------------------------
	//	DDR3-SDRAM Controller
	// --------------------------------------------------------------------
	ip_sdram u_sdram (
		.reset_n				( ff_reset_n			),
		.clk					( clk50m				),
		.memory_clk				( clk350m				),
		.clk_out				( clk44m				),
		.pll_lock				( pll_lock				),
		.sdram_init_busy		( sdram_init_busy		),
		.bus_address			( dram_address			),
		.bus_write				( dram_write			),
		.bus_valid				( dram_valid			),
		.bus_ready				( dram_ready			),
		.bus_wdata				( dram_wdata			),
		.bus_wdata_mask			( dram_wdata_mask		),
		.bus_rdata				( dram_rdata			),
		.bus_rdata_en			( dram_rdata_en			),
		.ddr3_rst_n				( ddr_reset_n			),
		.ddr3_clk				( ddr_clk				),
		.ddr3_clk_n				( ddr_clk_n				),
		.ddr3_cke				( ddr_cke				),
		.ddr3_cs_n				( ddr_cs_n				),
		.ddr3_ras_n				( ddr_ras_n				),
		.ddr3_cas_n				( ddr_cas_n				),
		.ddr3_we_n				( ddr_we_n				),
		.ddr3_dq				( ddr_dq				),
		.ddr3_addr				( ddr_addr				),
		.ddr3_ba				( ddr_ba				),
		.ddr3_dm_tdqs			( ddr_dqm				),
		.ddr3_dqs				( ddr_dqs				),
		.ddr3_dqs_n				( ddr_dqs_n				),
		.ddr3_odt				( ddr_odt				)
	);

endmodule
