// -----------------------------------------------------------------------------
//	tangprimer20k_vdp_cartridge_test.v
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

module tangprimer20k_vdp_cartridge_test (
	input			clk14m,				//	clk14m			T7 (14.318180MHz)
	input			clk27m,				//	clk27m			H11
	input	[4:0]	dipsw,				//	dipsw[4:0]		T5, T4, T3, T2, D7
	//	MSX SLOT
	input			p_slot_reset_n,		//	p_slot_reset_n	T10
	input			p_slot_sltsl_n,		//	p_slot_sltsl_n	H13
	input			p_slot_mreq_n,		//	p_slot_mreq_n	H12
	input			p_slot_ioreq_n,		//	p_slot_ioreq_n	J12
	input			p_slot_wr_n,		//	p_slot_wr_n		F14
	input			p_slot_rd_n,		//	p_slot_rd_n		F16
	input			p_slot_m1_n,		//	p_slot_m1_n		G15
	input			p_slot_rfsh_n,		//	p_slot_rfsh_n	G14
	input	[15:0]	p_slot_address,		//	p_slot_address	P9,  T9,  K16, J15, H16, H14, G16, H15
										//					T8,  P8,  N16, N14, L16, L14, K15, K14
	inout	[7:0]	p_slot_data,		//	p_slot_data		P11, T11, R11, T12, R12, P13, R13, T14
	output			p_slot_data_dir,	//	p_slot_data_dir	L8
	output			p_slot_busdir,		//	p_slot_busdir	T6
	output			p_slot_oe_n,		//	p_slot_oe_n		M6
	output			p_slot_int,			//	p_slot_int		J16
	output			p_slot_wait,		//	p_slot_wait		J14
	//	VideoOut
	output			p_video_hs,			//	p_video_hs		A15
	output			p_video_vs,			//	p_video_vs		D14
	output	[4:0]	p_video_r,			//	p_video_r		N6,  N7,  N9,  N8,  L9
	output	[4:0]	p_video_g,			//	p_video_g		D10, R7,  P7,  B10, A11
	output	[4:0]	p_video_b,			//	p_video_b		B14, A14, B13, C12, B12
	//	UART_TX
	output			uart_tx
	//	DDR3-SDRAM I/F
//	output	[13:0]	ddr_addr,			//	DDR3_A[13:0]	C8, A3, B7, K3, F9, A5, D8, B1, E6, C4, F8, D6, A4, F7
//	output	[2:0]	ddr_ba,				//	DDR3_BA[2:0]	H5, D3, H4
//	output			ddr_cs_n,			//	DDR3_CS_N		P5
//	output			ddr_ras_n,			//	DDR3_RAS_N		J3
//	output			ddr_cas_n,			//	DDR3_CAS_N		K3
//	output			ddr_we_n,			//	DDR3_WE_N		L3
//	output			ddr_clk,			//	DDR3_CK_P		J1
//	output			ddr_clk_n,			//	DDR3_CK_N		J3
//	output			ddr_cke,			//	DDR3_CKEN		J2
//	output			ddr_odt,			//	DDR3_ODT0_N		R3
//	output			ddr_reset_n,		//	DDR3_RST_N		B9
//	output	[1:0]	ddr_dqm,			//	DDR3_DQM[1:0]	K5, G1
//	inout	[15:0]	ddr_dq,				//	DDR3_DQ[15:0]	M2, R1, H3, P4, L1, N2, K4, M3, B3, E1, C1, E2, F3, F4, F5, G5
//	inout	[1:0]	ddr_dqs,			//	DDR3_DQS_P[1:0]	J5, G2
//	inout	[1:0]	ddr_dqs_n			//	DDR3_DQS_N[1:0]	K6, G3
);
	wire			clk86m;				//	85.90908MHz from PLL
	wire			clk42m;				//	42.95454MHz from PLL
	wire			pll_lock;
	wire			reset_n;
	wire			sdram_init_busy;	//	0: Normal, 1: DDR3 SDRAM Initialization phase.
	wire			bus_memreq;			//	MSX Slot --> device 0: none, 1: memory request
	wire			bus_ioreq;			//	MSX Slot --> device 0: none, 1: io request
	wire	[15:0]	bus_address;		//	MSX Slot --> device Peripheral device address
	wire			bus_write;			//	MSX Slot --> device Direction 0: Read, 1: Write
	wire			bus_valid;			//	MSX Slot --> device 
	wire			bus_ready;			//	MSX Slot --> device 0: Busy, 1: Ready
	wire	[7:0]	bus_wdata;			//	MSX Slot --> device 
	wire	[7:0]	bus_rdata;			//	device --> MSX Slot
	wire			bus_rdata_en;		//	device --> MSX Slot
	wire			w_slot_int_n;		//	VDP --> MSX Slot
	wire			w_slot_data_dir;
	wire	[7:0]	w_latch_data;

	assign p_slot_oe_n		= 1'b0;
	assign p_video_r[4:3]	= 2'd0;
	assign p_video_g[4:3]	= 2'd0;
	assign p_video_b[4:3]	= 2'd0;

	ip_vga u_vga (
		.n_reset		( p_slot_reset_n	),
		.clk42m			( clk42m			),
		.video_r		( p_video_r[2:0]	),
		.video_g		( p_video_g[2:0]	),
		.video_b		( p_video_b[2:0]	),
		.video_hs		( p_video_hs		),
		.video_vs		( p_video_vs		),
		.latch_data		( w_latch_data		)
	);

	ip_uart #(
		.clk_freq		( 14318180			),
		.uart_freq		( 115200			)
	) u_uart (
		.n_reset		( p_slot_reset_n	),
		.clk			( clk14m			),
		.send_data		( 8'h41				),
		.send_req		( 1'b1				),
		.send_busy		( 					),
		.uart_tx		( uart_tx			)
	);

	// --------------------------------------------------------------------
	//	CLOCK
	// --------------------------------------------------------------------
	Gowin_rPLL u_pll (
		.clkout					( clk86m				),		//	output	85.90908MHz
		.lock					( pll_lock				),		//	output	lock
		.clkin					( clk14m				)		//	input	14.318180MHz
	);

	Gowin_CLKDIV u_clkdiv (
		.clkout					( clk42m				),		//	output	42.95454MHz
		.hclkin					( clk86m				),		//	input	85.90908MHz
		.resetn					( p_slot_reset_n		)		//	input	resetn
	);

	// --------------------------------------------------------------------
	//	MSX slot connector
	// --------------------------------------------------------------------
	msx_slot u_msx_slot (
		.clk42m					( clk42m				),
		.reset_n				( reset_n				),
		.initial_busy			( sdram_init_busy		),
		.p_slot_reset_n			( p_slot_reset_n		),
		.p_slot_sltsl_n			( p_slot_sltsl_n		),
		.p_slot_mreq_n			( p_slot_mreq_n			),
		.p_slot_ioreq_n			( p_slot_ioreq_n		),
		.p_slot_wr_n			( p_slot_wr_n			),
		.p_slot_rd_n			( p_slot_rd_n			),
		.p_slot_address			( p_slot_address		),
		.p_slot_data			( p_slot_data			),
		.p_slot_data_dir		( w_slot_data_dir		),
		.p_slot_int				( p_slot_int			),
		.p_slot_wait			( p_slot_wait			),
		.int_n					( w_slot_int_n			),
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

	assign p_slot_data_dir	= w_slot_data_dir;

	// --------------------------------------------------------------------
	//	p_slot_busdir
	//		0 ... Write from CPU
	//		1 ... Read by CPU
	// --------------------------------------------------------------------
	assign p_slot_busdir	= 
			(!p_slot_ioreq_n && !p_slot_rd_n && { p_slot_address[7:2], 2'd0 } == 8'h88 ) ? 1'b1: 
			(!p_slot_ioreq_n && !p_slot_rd_n && { p_slot_address[7:1], 1'd0 } == 8'h10 ) ? 1'b1: 
			1'b0;

	// --------------------------------------------------------------------
	//	GPIO for test
	// --------------------------------------------------------------------
	test_controller u_test_controller (
		.clk42m					( clk42m				),
		.reset_n				( reset_n				),
		.initial_busy			( sdram_init_busy		),
		.bus_address			( bus_address			),
		.bus_ioreq				( bus_ioreq				),
		.bus_write				( bus_write				),
		.bus_valid				( bus_valid				),
		.bus_ready				( bus_ready				),
		.bus_wdata				( bus_wdata				),
		.bus_rdata				( bus_rdata				),
		.bus_rdata_en			( bus_rdata_en			),
		.dipsw					( dipsw					),
		.latch_data				( w_latch_data			)
	);

	assign w_slot_int_n		= 1'b1;
	assign sdram_init_busy	= 1'b0;

//	assign ddr_addr			= 14'd0;
//	assign ddr_ba			= 3'd0;
//	assign ddr_cs_n			= 1'b1;
//	assign ddr_ras_n		= 1'b1;
//	assign ddr_cas_n		= 1'b1;
//	assign ddr_we_n			= 1'b1;
//	assign ddr_clk			= 1'b0;
//	assign ddr_clk_n		= 1'b1;
//	assign ddr_cke			= 1'b0;
//	assign ddr_odt			= 1'b0;
//	assign ddr_reset_n		= 1'b0;
//	assign ddr_dqm			= 2'b0;
endmodule
