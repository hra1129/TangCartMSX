// -----------------------------------------------------------------------------
//	tangprimer20k_step3.v
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

module tangprimer20k_step3 (
	input			clk27m,				//	clk27m			H11
	input	[4:0]	button,				//	button[4:0]		C7,  D7,  T2,  T3,  T10
	output	[5:0]	led,				//	led[5:0]		L16, L14, N14, N16, A13, C13
	output			uart_tx,			//	uart_tx			M11
	//	DDR3-SDRAM I/F
	output	[13:0]	ddr_addr,			//	DDR3_A[13:0]	C8, A3, B7, K3, F9, A5, D8, B1, E6, C4, F8, D6, A4, F7
	output	[2:0]	ddr_ba,				//	DDR3_BA[2:0]	H5, D3, H4
	output			ddr_cs_n,			//	DDR3_CS_N		P5
	output			ddr_ras_n,			//	DDR3_RAS_N		J3
	output			ddr_cas_n,			//	DDR3_CAS_N		K3
	output			ddr_we_n,			//	DDR3_WE_N		L3
	output			ddr_clk,			//	DDR3_CK_P		J1
	output			ddr_clk_n,			//	DDR3_CK_N		J3
	output			ddr_cke,			//	DDR3_CKEN		J2
	output			ddr_odt,			//	DDR3_ODT0_N		R3
	output			ddr_reset_n,		//	DDR3_RST_N		B9
	output	[1:0]	ddr_dqm,			//	DDR3_DQM[1:0]	K5, G1
	inout	[15:0]	ddr_dq,				//	DDR3_DQ[15:0]	M2, R1, H3, P4, L1, N2, K4, M3, B3, E1, C1, E2, F3, F4, F5, G5
	inout	[1:0]	ddr_dqs,			//	DDR3_DQS_P[1:0]	J5, G2
	inout	[1:0]	ddr_dqs_n			//	DDR3_DQS_N[1:0]	K6, G3
);
	reg				ff_reset_n0 = 1'b0;
	reg				ff_reset_n = 1'b0;
	wire			clk49m;				//	49.5MHz from PLL
	wire			clk297m;			//	297MHz from PLL
	wire			clk;				//	74.25MHz from DDR3 Controller
	wire			clk37m;				//	37.125MHz
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
	Gowin_rPLL u_pll (
		.clkout					( clk297m				),		//	output clkout
		.lock					( pll_lock				),		//	output lock
		.clkoutd				( clk49m				),		//	output clkoutd
		.clkin					( clk27m				)		//	input clkin
	);

	Gowin_CLKDIV2 your_instance_name(
		.clkout					( clk37m				),		//	output clkout
		.hclkin					( clk					),		//	input hclkin
		.resetn					( ff_reset_n			)		//	input resetn
	);

	// --------------------------------------------------------------------
	//	Z80 core
	// --------------------------------------------------------------------
	cz80_wrap u_cz80 (
		.reset_n				( ff_reset_n			),
		.clk_n					( clk37m				),
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
		.clk					( clk37m				),
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
		.clk					( clk37m				),
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
		.clk					( clk37m				),
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
		.clk					( clk37m				),
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
		.clk					( clk49m				),
		.memory_clk				( clk297m				),
		.clk_out				( clk					),
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
