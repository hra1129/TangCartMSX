// -----------------------------------------------------------------------------
//	tangprimer20k_vdp.v
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

module tangprimer20k_vdp (
	input			clk21m,				//	clk21m			
	input			clk27m,				//	clk27m			H11
	input	[4:0]	dipsw,				//	dipsw[4:0]		
	output			uart_tx,			//	uart_tx			M11
	//	MSX SLOT
	input			p_slot_reset_n,		//	p_slot_reset_n	
	input			p_slot_sltsl_n,		//	p_slot_sltsl_n	
	input			p_slot_cs1_n,		//	p_slot_cs1_n	
	input			p_slot_cs2_n,		//	p_slot_cs2_n	
	input			p_slot_cs12_n,		//	p_slot_cs12_n	
	input			p_slot_mreq_n,		//	p_slot_mreq_n	
	input			p_slot_ioreq_n,		//	p_slot_ioreq_n	
	input			p_slot_wr_n,		//	p_slot_wr_n		
	input			p_slot_rd_n,		//	p_slot_rd_n		
	input			p_slot_m1_n,		//	p_slot_m1_n		
	input	[15:0]	p_slot_address,		//	p_slot_address	
	inout	[7:0]	p_slot_data,		//	p_slot_data		
	output			p_slot_data_dir,	//	p_slot_data_dir	
	output			p_slot_int,			//	p_slot_int		
	output			p_slot_wait,		//	p_slot_wait		
	//	VideoOut
	output			p_video_hs,			//	p_video_hs		
	output			p_video_vs,			//	p_video_vs		
	output	[4:0]	p_video_r,			//	p_video_r		
	output	[4:0]	p_video_g,			//	p_video_g		
	output	[4:0]	p_video_b,			//	p_video_b		
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
	wire			clk50m;				//	50MHz from PLL
	wire			clk344m;			//	343.63632MHz from PLL
	wire			clk42m;				//	42.95454MHz from DDR3 Controller
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
	wire			bus_vdp_ready;		//	vdp --> MSX Slot 0: Busy, 1: Ready
	wire	[7:0]	bus_vdp_rdata;		//	vdp --> MSX Slot
	wire			bus_vdp_rdata_en;	//	vdp --> MSX Slot
	wire			bus_ram_ready;		//	ram --> vdp 0: Busy, 1: Ready
	wire	[7:0]	bus_ram_rdata;		//	ram --> vdp
	wire			bus_ram_rdata_en;	//	ram --> vdp
	wire			w_slot_int_n;		//	VDP --> MSX Slot
	wire	[13:0]	w_vram_address;		//	VDP --> SRAM
	wire			w_vram_write;		//	VDP --> SRAM Direction 0: Read, 1: Write
	wire			w_vram_valid;		//	VDP --> SRAM 
	wire			w_vram_ready;		//	VDP --> SRAM 0: Busy, 1: Ready
	wire	[7:0]	w_vram_wdata;		//	VDP --> SRAM 
	wire	[7:0]	w_vram_rdata;		//	VDP --> SRAM 
	wire			w_vram_rdata_en;	//	VDP --> SRAM 
	wire			w_vdp_enable;		//	VDP --> Video Out
	wire	[5:0]	w_vdp_r;			//	VDP --> Video Out
	wire	[5:0]	w_vdp_g;			//	VDP --> Video Out
	wire	[5:0]	w_vdp_b;			//	VDP --> Video Out
	wire	[10:0]	w_vdp_hcounter;		//	VDP --> Video Out
	wire	[10:0]	w_vdp_vcounter;		//	VDP --> Video Out
//	wire	[26:0]	dram_address;		//	VDP --> DDR3 Controller 64Mword/16bit: [26:24]=BANK, [23:10]=ROW, [9:0]=COLUMN
//	wire			dram_write;			//	VDP --> DDR3 Controller Direction 0: Read, 1: Write
//	wire			dram_valid;			//	VDP --> DDR3 Controller 
//	wire			dram_ready;			//	VDP --> DDR3 Controller 0: Busy, 1: Ready
//	wire	[127:0]	dram_wdata;			//	VDP --> DDR3 Controller 
//	wire	[15:0]	dram_wdata_mask;	//	VDP --> DDR3 Controller 
//	wire	[127:0]	dram_rdata;			//	VDP --> DDR3 Controller 
//	wire			dram_rdata_en;		//	VDP --> DDR3 Controller 
	wire	[7:0]	w_video_r;			//	Video Out --> VGA Connector
	wire	[7:0]	w_video_g;			//	Video Out --> VGA Connector
	wire	[7:0]	w_video_b;			//	Video Out --> VGA Connector

	// --------------------------------------------------------------------
	//	CLOCK
	// --------------------------------------------------------------------
	Gowin_rPLL u_pll (
		.clkout					( clk344m				),		//	output	343.63632MHz
		.lock					( pll_lock				),		//	output	
		.clkoutd				( clk50m				),		//	output	50MHz
		.clkin					( clk21m				)		//	input	21.47727MHz
	);

	// --------------------------------------------------------------------
	//	MSX slot connector
	// --------------------------------------------------------------------
	msx_slot u_msx_slot (
		.clk42m					( clk42m				),
		.reset_n				( reset_n				),
		.initial_busy			( initial_busy			),
		.p_slot_reset_n			( p_slot_reset_n		),
		.p_slot_sltsl_n			( p_slot_sltsl_n		),
		.p_slot_mreq_n			( p_slot_mreq_n			),
		.p_slot_ioreq_n			( p_slot_ioreq_n		),
		.p_slot_wr_n			( p_slot_wr_n			),
		.p_slot_rd_n			( p_slot_rd_n			),
		.p_slot_address			( p_slot_address		),
		.p_slot_data			( p_slot_data			),
		.p_slot_data_dir		( p_slot_data_dir		),
		.p_slot_int				( p_slot_int			),
		.p_slot_wait			( p_slot_wait			)
		.int_n					( w_slot_int_n			),
		.bus_address			( bus_address			),
		.bus_memreq				( bus_memreq			),
		.bus_ioreq				( bus_ioreq				),
		.bus_valid				( bus_valid				),
		.bus_ready				( bus_ready				),
		.bus_write				( bus_write				),
		.bus_wdata				( bus_wdata				),
		.bus_rdata				( bus_rdata				),
		.bus_rdata_en			( bus_rdata_en			),
	);

	// --------------------------------------------------------------------
	//	V9918
	// --------------------------------------------------------------------
	vdp_inst u_v9918 (
		.clk					( clk					),
		.reset_n				( reset_n				),
		.initial_busy			( 1'b0					),
		.bus_address			( bus_address[0]		),
		.bus_ioreq				( bus_ioreq				),
		.bus_write				( bus_write				),
		.bus_valid				( bus_valid				),
		.bus_wdata				( bus_wdata				),
		.bus_rdata				( bus_rdata				),
		.bus_rdata_en			( bus_rdata_en			),
		.int_n					( w_slot_int_n			),
		.p_dram_address			( w_vdram_address		),
		.p_dram_write			( w_vdram_write			),
		.p_dram_valid			( w_vdram_valid			),
		.p_dram_ready			( w_vdram_ready			),
		.p_dram_wdata			( w_vdram_wdata			),
		.p_dram_rdata			( w_vdram_rdata			),
		.p_dram_rdata_en		( w_vdram_rdata_en		),
		.p_vdp_enable			( w_vdp_enable			),
		.p_vdp_r				( w_vdp_r				),
		.p_vdp_g				( w_vdp_g				),
		.p_vdp_b				( w_vdp_b				),
		.p_vdp_hcounter			( w_vdp_hcounter		),
		.p_vdp_vcounter			( w_vdp_vcounter		)
	);

	assign w_vdp_ioreq	= ((dipsw[0] == 1'b0) && { bus_address[7:1], 1'b0 } == 8'h88 && bus_ioreq) ? 1'b1:
	                  	  ((dipsw[0] == 1'b1) && { bus_address[7:1], 1'b0 } == 8'h98 && bus_ioreq) ? 1'b1: 1'b0;

	// --------------------------------------------------------------------
	//	VRAM
	// --------------------------------------------------------------------
	ip_ram u_vram (
		.reset_n				( reset_n				),
		.clk					( clk42m				),
		.bus_address			( w_vram_address		),
		.bus_valid				( w_vram_valid			),
		.bus_ready				( w_vram_ready			),
		.bus_write				( w_vram_write			),
		.bus_wdata				( w_vram_wdata			),
		.bus_rdata				( w_vram_rdata			),
		.bus_rdata_en			( w_vram_rdata_en		)
	);

	// --------------------------------------------------------------------
	//	VIDEO OUT
	// --------------------------------------------------------------------
	video_out #(
		.hs_positive			( 1'b0					),
		.vs_positive			( 1'b0					)
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

	assign w_video_r	= w_video_r[7:3];
	assign w_video_g	= w_video_g[7:3];
	assign w_video_b	= w_video_b[7:3];

	// --------------------------------------------------------------------
	//	DDR3-SDRAM Controller
	// --------------------------------------------------------------------
	assign sdram_init_busy	= 1'b0;

//	ip_sdram u_sdram (
//		.reset_n				( reset_n				),
//		.clk					( clk50m				),
//		.memory_clk				( clk344m				),
//		.clk_out				( clk42m				),
//		.pll_lock				( pll_lock				),
//		.sdram_init_busy		( sdram_init_busy		),
//		.bus_address			( dram_address			),
//		.bus_write				( dram_write			),
//		.bus_valid				( dram_valid			),
//		.bus_ready				( dram_ready			),
//		.bus_wdata				( dram_wdata			),
//		.bus_wdata_mask			( dram_wdata_mask		),
//		.bus_rdata				( dram_rdata			),
//		.bus_rdata_en			( dram_rdata_en			),
//		.ddr3_rst_n				( ddr_reset_n			),
//		.ddr3_clk				( ddr_clk				),
//		.ddr3_clk_n				( ddr_clk_n				),
//		.ddr3_cke				( ddr_cke				),
//		.ddr3_cs_n				( ddr_cs_n				),
//		.ddr3_ras_n				( ddr_ras_n				),
//		.ddr3_cas_n				( ddr_cas_n				),
//		.ddr3_we_n				( ddr_we_n				),
//		.ddr3_dq				( ddr_dq				),
//		.ddr3_addr				( ddr_addr				),
//		.ddr3_ba				( ddr_ba				),
//		.ddr3_dm_tdqs			( ddr_dqm				),
//		.ddr3_dqs				( ddr_dqs				),
//		.ddr3_dqs_n				( ddr_dqs_n				),
//		.ddr3_odt				( ddr_odt				)
//	);

endmodule
