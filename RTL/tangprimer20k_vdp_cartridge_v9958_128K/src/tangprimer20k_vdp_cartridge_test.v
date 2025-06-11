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
	wire			clk344m;			//	343.63632MHz from PLL
	wire			clk42m;				//	 42.95454MHz from PLL
	wire			clk50m;				//	 50.11363MHz from PLL
	wire			pll_lock;
	wire			reset_n;
	wire			w_sdram_init_busy;	//	0: Normal, 1: DDR3 SDRAM Initialization phase.
	wire			w_bus_memreq;		//	MSX Slot --> device 0: none, 1: memory request
	wire			w_bus_ioreq;		//	MSX Slot --> device 0: none, 1: io request
	wire	[15:0]	w_bus_address;		//	MSX Slot --> device Peripheral device address
	wire			w_bus_write;		//	MSX Slot --> device Direction 0: Read, 1: Write
	wire			w_bus_valid;		//	MSX Slot --> device 
	wire			w_bus_ready;		//	MSX Slot --> device 0: Busy, 1: Ready
	wire	[7:0]	w_bus_wdata;		//	MSX Slot --> device 
	wire	[7:0]	w_bus_rdata;		//	device --> MSX Slot
	wire			w_bus_rdata_en;		//	device --> MSX Slot
	wire			w_slot_int_n;		//	VDP --> MSX Slot
	wire			w_slot_data_dir;
	wire	[7:0]	w_latch_data;

	wire	[7:0]	w_bus_vdp_rdata;
	wire			w_bus_vdp_rdata_en;

	wire	[26:0]	w_dram_address;		//	test_module --> DDR3 Controller 64Mword/16bit: [26:24]=BANK, [23:10]=ROW, [9:0]=COLUMN
	wire			w_dram_write;		//	test_module --> DDR3 Controller Direction 0: Read, 1: Write
	wire			w_dram_valid;		//	test_module --> DDR3 Controller 
	wire			w_dram_ready;		//	test_module --> DDR3 Controller 0: Busy, 1: Ready
	wire	[127:0]	w_dram_wdata;		//	test_module --> DDR3 Controller 
	wire	[15:0]	w_dram_wdata_mask;	//	test_module --> DDR3 Controller 
	wire	[127:0]	w_dram_rdata;		//	test_module --> DDR3 Controller 
	wire			w_dram_rdata_en;	//	test_module --> DDR3 Controller 

	// video output
	wire			w_vdp_enable;
	wire	[5:0]	w_vdp_r;
	wire	[5:0]	w_vdp_g;
	wire	[5:0]	w_vdp_b;
	wire	[10:0]	w_vdp_hcounter;
	wire	[10:0]	w_vdp_vcounter;
	wire	[7:0]	w_video_r;
	wire	[7:0]	w_video_g;
	wire	[7:0]	w_video_b;

	assign p_slot_oe_n		= 1'b0;

	// --------------------------------------------------------------------
	//	CLOCK
	// --------------------------------------------------------------------
	Gowin_rPLL u_pll (
		.clkout					( clk344m				),		//	output clkout
		.lock					( pll_lock				),		//	output lock
		.clkin					( clk14m				)		//	input clkin
	);

	Gowin_rPLL50 u_pll50 (
		.clkout					( clk50m				),      //  output clkout
		.clkin					( clk27m				)       //  input clkin
	);

	// --------------------------------------------------------------------
	//	MSX slot connector
	// --------------------------------------------------------------------
	msx_slot u_msx_slot (
		.clk42m					( clk42m				),
		.reset_n				( reset_n				),
		.initial_busy			( w_sdram_init_busy		),
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
		.bus_address			( w_bus_address			),
		.bus_memreq				( w_bus_memreq			),
		.bus_ioreq				( w_bus_ioreq			),
		.bus_valid				( w_bus_valid			),
		.bus_ready				( w_bus_ready			),
		.bus_write				( w_bus_write			),
		.bus_wdata				( w_bus_wdata			),
		.bus_rdata				( w_bus_rdata			),
		.bus_rdata_en			( w_bus_rdata_en		)
	);

	assign p_slot_data_dir	= w_slot_data_dir;
	assign w_bus_rdata		= w_bus_vdp_rdata;
	assign w_bus_rdata_en	= w_bus_vdp_rdata_en;
	assign w_bus_ready		= 1'b1;

	// --------------------------------------------------------------------
	//	VDP: V9918
	// --------------------------------------------------------------------
	vdp_inst u_v9958 (
		.clk					( clk42m				),
		.reset_n				( reset_n				),
		.initial_busy			( w_sdram_init_busy		),
		.bus_address			( w_bus_address			),
		.bus_ioreq				( w_bus_ioreq			),
		.bus_write				( w_bus_write			),
		.bus_valid				( w_bus_valid			),
		.bus_wdata				( w_bus_wdata			),
		.bus_rdata				( w_bus_vdp_rdata		),
		.bus_rdata_en			( w_bus_vdp_rdata_en	),
		.int_n					( 						),
		.p_dram_address			( w_dram_address[16:0]	),
		.p_dram_write			( w_dram_write			),
		.p_dram_valid			( w_dram_valid			),
		.p_dram_ready			( w_dram_ready			),
		.p_dram_wdata			( w_dram_wdata			),
		.p_dram_rdata			( w_dram_rdata			),
		.p_dram_rdata_en		( w_dram_rdata_en		),
		.p_vdp_enable			( w_vdp_enable			),
		.p_vdp_r				( w_vdp_r				),
		.p_vdp_g				( w_vdp_g				),
		.p_vdp_b				( w_vdp_b				),
		.p_vdp_hcounter			( w_vdp_hcounter		),
		.p_vdp_vcounter			( w_vdp_vcounter		)
	);

	video_out #(
		.hs_positive			( 1'b0					),		//	If video_hs is positive logic, set to 1; if video_hs is negative logic, set to 0.
		.vs_positive			( 1'b0					)		//	If video_vs is positive logic, set to 1; if video_vs is negative logic, set to 0.
	) u_video_out (
		.clk					( clk42m				),
		.reset_n				( reset_n				),
		.enable					( w_vdp_enable			),
		.vdp_r					( w_vdp_r				),
		.vdp_g					( w_vdp_g				),
		.vdp_b					( w_vdp_b				),
		.vdp_hcounter			( w_vdp_hcounter		),
		.vdp_vcounter			( w_vdp_vcounter		),
		.video_clk				( 						),
		.video_de				( 						),
		.video_hs				( p_video_hs			),
		.video_vs				( p_video_vs			),
		.video_r				( w_video_r				),
		.video_g				( w_video_g				),
		.video_b				( w_video_b				)
	);

	assign p_video_r[4:0]	= w_video_r[7:3];
	assign p_video_g[4:0]	= w_video_g[7:3];
	assign p_video_b[4:0]	= w_video_b[7:3];

	// --------------------------------------------------------------------
	//	p_slot_busdir
	//		0 ... Write from CPU
	//		1 ... Read by CPU
	// --------------------------------------------------------------------
	assign p_slot_busdir	= 
			//(!p_slot_ioreq_n && !p_slot_rd_n && { p_slot_address[7:2], 2'd0 } == 8'h98 ) ? 1'b1: 
			1'b0;

	assign w_slot_int_n			= 1'b1;

	// --------------------------------------------------------------------
	//	DDR3-SDRAM Controller
	// --------------------------------------------------------------------
	assign w_dram_address[26:17]	= 10'd0;
	assign w_dram_wdata_mask		= 16'hFFFE;

	ip_sdram u_sdram (
		.reset_n				( reset_n				),
		.clk					( clk50m				),
		.memory_clk				( clk344m				),
		.clk42m					( clk42m				),
		.pll_lock				( pll_lock				),
		.sdram_init_busy		( w_sdram_init_busy		),
		.bus_address			( w_dram_address		),
		.bus_write				( w_dram_write			),
		.bus_valid				( w_dram_valid			),
		.bus_ready				( w_dram_ready			),
		.bus_wdata				( w_dram_wdata			),
		.bus_wdata_mask			( w_dram_wdata_mask		),
		.bus_rdata				( w_dram_rdata			),
		.bus_rdata_en			( w_dram_rdata_en		),
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
