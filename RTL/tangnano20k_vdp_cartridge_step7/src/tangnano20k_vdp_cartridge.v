// -----------------------------------------------------------------------------
//	tangnano20k_vdp_cartridge.v
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

module tangnano20k_vdp_cartridge (
	input			clk,			//	PIN04		(27MHz)
	input			clk14m,			//	PIN80
	input			slot_reset_n,	//	PIN86
	input			slot_iorq_n,	//	PIN71
	input			slot_rd_n,		//	PIN15
	input			slot_wr_n,		//	PIN16
	output			slot_wait,		//	PIN53
	output			slot_intr,		//	PIN52
	output			slot_data_dir,	//	PIN19
	input	[7:0]	slot_a,			//	PIN17, 49, 48, 41, 42, 76, 31, 30
	inout	[7:0]	slot_d,			//	PIN73, 74, 75, 85, 77, 27, 28, 29
	output			busdir,			//	PIN72
	output			oe_n,			//	PIN20
	input			dipsw,			//	PIN18
	output			ws2812_led,		//	PIN79
	input	[1:0]	button,			//	PIN87, 88	KEY2, KEY1

	//	HDMI
	output			tmds_clk_p,		//	(PIN33/34)
	output			tmds_clk_n,		//	dummy
	output	[2:0]	tmds_d_p,		//	(PIN39/40), (PIN37/38), (PIN35/36)
	output	[2:0]	tmds_d_n,		//	dummy

	output			O_sdram_clk,
	output			O_sdram_cke,
	output			O_sdram_cs_n,	// chip select
	output			O_sdram_ras_n,	// row address select
	output			O_sdram_cas_n,	// columns address select
	output			O_sdram_wen_n,	// write enable
	inout	[31:0]	IO_sdram_dq,	// 32 bit bidirectional data bus
	output	[10:0]	O_sdram_addr,	// 11 bit multiplexed address bus
	output	[ 1:0]	O_sdram_ba,		// two banks
	output	[ 3:0]	O_sdram_dqm		// data mask
);
	wire			pll_lock;
	wire			clk21m;				//	21.47727MHz
	wire			clk42m;				//	42.95454MHz
	wire			clk85m;				//	85.90908MHz
	wire			clk85m_n;			//	85.90908MHz (negative)
	wire			clk215m;			//	214.7727MHz
	wire			reset_n;
	wire	[15:0]	w_bus_address;
	wire			w_bus_ioreq;
	wire			w_bus_write;
	wire			w_bus_valid;
	wire			w_bus_ready;
	wire	[7:0]	w_bus_wdata;
	wire	[7:0]	w_bus_rdata;
	wire			w_bus_rdata_en;

	wire	[7:0]	w_bus_gpio_rdata;
	wire			w_bus_gpio_rdata_en;
	wire	[7:0]	w_bus_vdp_rdata;
	wire			w_bus_vdp_rdata_en;

	wire			w_led_wr;
	wire	[7:0]	w_led_red;
	wire	[7:0]	w_led_green;
	wire	[7:0]	w_led_blue;

	wire	[13:0]	w_dram_address;
	wire			w_dram_write;
	wire			w_dram_valid;
	wire			w_dram_refresh;
	wire	[7:0]	w_dram_wdata;
	wire	[15:0]	w_dram_rdata;
	wire			w_dram_rdata_en;
	wire			w_dram_init_busy;

	wire			w_vdp_cs_n;
	wire	[7:0]	w_vdp_q;
	wire			w_vdp_q_en;
	wire			w_vdp_enable;
	wire	[5:0]	w_vdp_r;
	wire	[5:0]	w_vdp_g;
	wire	[5:0]	w_vdp_b;
	wire	[10:0]	w_vdp_hcounter;
	wire	[10:0]	w_vdp_vcounter;
	wire			w_dh_clk;
	wire			w_dl_clk;

	wire			w_video_clk;
	wire			w_video_de;
	wire			w_video_hs;
	wire			w_video_vs;
	wire	[7:0]	w_video_r;
	wire	[7:0]	w_video_g;
	wire	[7:0]	w_video_b;

	assign slot_wait		= w_dram_init_busy;
	assign slot_intr		= 1'b0;
    assign oe_n             = 1'b0;
    assign busdir           = ( { slot_a[7:2], 2'd0 } == 8'h10 && !slot_iorq_n ) ? ~slot_rd_n: 1'b0;

	// --------------------------------------------------------------------
	//	clock
	// --------------------------------------------------------------------
	Gowin_rPLL u_pll (
		.clkout			( clk215m			),		//	output clkout	214.7727MHz
		.lock			( pll_lock			),
		.clkin			( clk14m			)		//	input clkin		14.31818MHz
	);

	Gowin_rPLL2 u_pll2 (
		.clkout			( clk85m			),		//	output clkout	85.90908MHz
		.clkoutp		( clk85m_n			),		//	output clkoutp	85.90908MHz (negative)
		.clkin			( clk14m			)		//	input clkin		14.31818MHz
	);

	Gowin_CLKDIV u_clkdiv (
		.clkout			( clk42m			),		//	output clkout	42.95454MHz
		.hclkin			( clk215m			),		//	input hclkin	214.7727MHz
		.resetn			( pll_lock			)		//	input resetn
	);

	// --------------------------------------------------------------------
	//	FullColor Intelligent LED
	// --------------------------------------------------------------------
	msx_slot u_msx_slot (
		.clk42m				( clk42m					),
		.reset_n			( reset_n					),
		.initial_busy		( 1'b0						),
		.p_slot_reset_n		( slot_reset_n				),
		.p_slot_sltsl_n		( 1'b1						),
		.p_slot_mreq_n		( 1'b1						),
		.p_slot_ioreq_n		( slot_iorq_n				),
		.p_slot_wr_n		( slot_wr_n					),
		.p_slot_rd_n		( slot_rd_n					),
		.p_slot_address		( { 8'd0, slot_a }			),
		.p_slot_data		( slot_d					),
		.p_slot_data_dir	( slot_data_dir				),
		.p_slot_int			( slot_int					),
		.int_n				( 1'b1						),
		.bus_address		( w_bus_address				),
		.bus_memreq			( 							),
		.bus_ioreq			( w_bus_ioreq				),
		.bus_write			( w_bus_write				),
		.bus_valid			( w_bus_valid				),
		.bus_ready			( w_bus_ready				),
		.bus_wdata			( w_bus_wdata				),
		.bus_rdata			( w_bus_rdata				),
		.bus_rdata_en		( w_bus_rdata_en			)
	);

	assign w_bus_rdata		= ( w_bus_gpio_rdata_en		) ? w_bus_gpio_rdata:
	                  		  ( w_bus_vdp_rdata_en		) ? w_bus_gpio_rdata: 8'hFF;
	assign w_bus_rdata_en	= w_bus_gpio_rdata_en;	// | w_bus_vdp_rdata_en;

	// --------------------------------------------------------------------
	//	GPIO
	// --------------------------------------------------------------------
	ip_gpio u_gpio (
		.reset_n			( reset_n					),
		.clk				( clk42m					),
		.bus_address		( w_bus_address[7:0]		),
		.bus_ioreq			( w_bus_ioreq				),
		.bus_write			( w_bus_write				),
		.bus_valid			( w_bus_valid				),
		.bus_ready			( w_bus_ready				),
		.bus_wdata			( w_bus_wdata				),
		.bus_rdata			( w_bus_gpio_rdata			),
		.bus_rdata_en		( w_bus_gpio_rdata_en		),
		.led_wr				( w_led_wr					),
		.led_red			( w_led_red					),
		.led_green			( w_led_green				),
		.led_blue			( w_led_blue				)
	);

	// --------------------------------------------------------------------
	//	FullColor Intelligent LED
	// --------------------------------------------------------------------
	ip_ws2812_led u_fullcolor_led (
		.reset_n			( reset_n					),
		.clk				( clk42m					),
		.wr					( w_led_wr					),
		.sending			( 							),
		.red				( w_led_red					),
		.green				( w_led_green				),
		.blue				( w_led_blue				),
		.ws2812_led			( ws2812_led				)
	);

	// --------------------------------------------------------------------
	//	V9958 clone
	// --------------------------------------------------------------------
	vdp_inst u_v9958 (
		.clk				( clk42m				),
		.reset_n			( reset_n				),
		.initial_busy		( w_dram_init_busy		),
		.bus_address		( w_bus_address			),
		.bus_ioreq			( w_bus_ioreq			),
		.bus_write			( w_bus_write			),
		.bus_valid			( w_bus_valid			),
		.bus_wdata			( w_bus_wdata			),
		.bus_rdata			( w_bus_vdp_rdata		),
		.bus_rdata_en		( w_bus_vdp_rdata_en	),
		.int_n				( 						),
		.p_dram_address		( w_dram_address		),
		.p_dram_write		( w_dram_write			),
		.p_dram_valid		( w_dram_valid			),
		.p_dram_wdata		( w_dram_wdata			),
		.p_dram_rdata		( w_dram_rdata			),
		.p_dram_rdata_en	( w_dram_rdata_en		),
		.p_vdp_enable		( w_vdp_enable			),
		.p_vdp_r			( w_vdp_r				),
		.p_vdp_g			( w_vdp_g				),
		.p_vdp_b			( w_vdp_b				),
		.p_vdp_hcounter		( w_vdp_hcounter		),
		.p_vdp_vcounter		( w_vdp_vcounter		)
    );

	// --------------------------------------------------------------------
	//	Video output
	// --------------------------------------------------------------------
	video_out #(
		.hs_positive		( 1'b0					),		//	If video_hs is positive logic, set to 1.
		.vs_positive		( 1'b0					)		//	If video_vs is positive logic, set to 1.
	) u_video_out (
		.clk				( clk42m				),
		.reset_n			( reset_n   			),
		.enable				( w_vdp_enable			),
		.vdp_r				( w_vdp_r				),
		.vdp_g				( w_vdp_g				),
		.vdp_b				( w_vdp_b				),
		.vdp_hcounter		( w_vdp_hcounter		),
		.vdp_vcounter		( w_vdp_vcounter		),
		.video_clk			( w_video_clk			),
		.video_de			( w_video_de			),
		.video_hs			( w_video_hs			),
		.video_vs			( w_video_vs			),
		.video_r			( w_video_r				),
		.video_g			( w_video_g				),
		.video_b			( w_video_b				)
	);

	// --------------------------------------------------------------------
	//	HDMI
	// --------------------------------------------------------------------
	DVI_TX_Top u_dvi (
		.I_rst_n			( reset_n   			),		//input I_rst_n
		.I_serial_clk		( clk215m				),		//input I_serial_clk
		.I_rgb_clk			( w_video_clk			),		//input I_rgb_clk
		.I_rgb_vs			( w_video_vs			),		//input I_rgb_vs
		.I_rgb_hs			( w_video_hs			),		//input I_rgb_hs
		.I_rgb_de			( w_video_de			),		//input I_rgb_de
		.I_rgb_r			( w_video_r				),		//input [7:0] I_rgb_r
		.I_rgb_g			( w_video_g				),		//input [7:0] I_rgb_g
		.I_rgb_b			( w_video_b				),		//input [7:0] I_rgb_b
		.O_tmds_clk_p		( tmds_clk_p			),		//output O_tmds_clk_p
		.O_tmds_clk_n		( tmds_clk_n			),		//output O_tmds_clk_n
		.O_tmds_data_p		( tmds_d_p				),		//output [2:0] O_tmds_data_p
		.O_tmds_data_n		( tmds_d_n				)		//output [2:0] O_tmds_data_n
	);

	// --------------------------------------------------------------------
	//	VRAM
	// --------------------------------------------------------------------
	ip_sdram #(
		.FREQ				( 85_909_080			)		//	Hz
	) u_vram (
		.reset_n			( reset_n				),
		.clk				( clk85m				),		//	85.90908MHz
		.clk_sdram			( clk85m				),
		.sdram_init_busy	( w_dram_init_busy		),
		.bus_address		( w_dram_address		),
		.bus_valid			( w_dram_valid			),
		.bus_write			( w_dram_write			),
		.bus_refresh		( w_dram_refresh		),
		.bus_wdata			( w_dram_wdata			),
		.bus_rdata			( w_dram_rdata			),
		.bus_rdata_en		( w_dram_rdata_en		),
		.O_sdram_clk		( O_sdram_clk			),
		.O_sdram_cke		( O_sdram_cke			),
		.O_sdram_cs_n		( O_sdram_cs_n			),		// chip select
		.O_sdram_ras_n		( O_sdram_ras_n			),		// row address select
		.O_sdram_cas_n		( O_sdram_cas_n			),		// columns address select
		.O_sdram_wen_n		( O_sdram_wen_n			),		// write enable
		.IO_sdram_dq		( IO_sdram_dq			),		// 32 bit bidirectional data bus
		.O_sdram_addr		( O_sdram_addr			),		// 11 bit multiplexed address bus
		.O_sdram_ba			( O_sdram_ba			),		// two banks
		.O_sdram_dqm		( O_sdram_dqm			)		// data mask
	);

	assign w_dram_refresh	= 1'b0;
endmodule
