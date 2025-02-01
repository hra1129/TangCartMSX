// -----------------------------------------------------------------------------
//	tangnano20k_hdmi_labo.v
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

module tangnano20k_hdmi_labo (
	input			clk27m,				//	clk27m		PIN04_SYS_CLK		(27MHz)
	input	[1:0]	button,				//	button[0]	PIN88_MODE0_KEY1
										//	button[1]	PIN87_MODE1_KEY2
	//	HDMI
	output			tmds_clk_p,			//	(PIN33/34)
	output			tmds_clk_n,			//	dummy
	output	[2:0]	tmds_d_p,			//	(PIN39/40), (PIN37/38), (PIN35/36)
	output	[2:0]	tmds_d_n,			//	dummy
	//	SDRAM
	output			O_sdram_clk,		//	Internal
	output			O_sdram_cke,		//	Internal
	output			O_sdram_cs_n,		//	Internal
	output			O_sdram_cas_n,		//	Internal
	output			O_sdram_ras_n,		//	Internal
	output			O_sdram_wen_n,		//	Internal
	inout	[31:0]	IO_sdram_dq,		//	Internal
	output	[10:0]	O_sdram_addr,		//	Internal
	output	[1:0]	O_sdram_ba,			//	Internal
	output	[3:0]	O_sdram_dqm			//	Internal
);
	wire			pll_lock;
	wire			clk_pixel;
	wire			clk_serial;
	reg				ff_cpu_enable;
	reg				ff_reset0_n = 1'b0;
	reg				ff_reset1_n = 1'b0;
	reg				ff_reset_n = 1'b0;
	wire			w_hdmi_reset_n;
	wire			w_enable;

	wire			wait_n;
	wire			int_n;
	wire			nmi_n;
	wire			busrq_n;
	wire			m1_n;
	wire			mreq_n;
	wire			iorq_n;
	wire			rd_n;
	wire			wr_n;
	wire			rfsh_n;
	wire			halt_n;
	wire			busak_n;
	wire	[15:0]	a;
	wire	[7:0]	d;
	reg		[7:0]	ff_d;

	wire	[7:0]	w_gpio_q;
	wire			w_gpio_q_en;
	wire	[7:0]	w_gpo;

	wire			w_rom_cs_n;
	wire	[7:0]	w_rom_rdata;
	wire			w_rom_rdata_en;

	wire			w_ram_cs_n;
	wire	[7:0]	w_ram_rdata;
	wire			w_ram_rdata_en;

	wire			w_vram_mreq_n;
	wire	[22:0]	w_vram_address;
	wire			w_vram_wr_n;
	wire			w_vram_rd_n;
	wire			w_vram_rfsh_n;
	wire	[ 7:0]	w_vram_wdata;
	wire	[31:0]	w_vram_rdata;
	wire			w_vram_rdata_en;

	wire			w_sdram_mreq_n;
	wire			w_sdram_wr_n;
	wire			w_sdram_rd_n;
	wire			w_sdram_rfsh_n;
	wire			w_sdram_init_busy;
	wire			w_sdram_busy;

	wire			w_hs;
	wire			w_vs;
	wire			w_de;
	wire	[7:0]	w_r;
	wire	[7:0]	w_g;
	wire	[7:0]	w_b;

	// --------------------------------------------------------------------
	//	clock
	// --------------------------------------------------------------------
	assign w_hdmi_reset_n	= ff_reset_n;

	Gowin_rPLL u_pll (
		.clkout			( clk_serial		),		//	output clkout	371.25MHz
		.lock			( pll_lock			),
		.clkin			( clk27m			)		//	input clkin		27MHz
	);

	Gowin_CLKDIV u_clkdiv (
		.clkout			( clk_pixel			),		//	output clkout	74.25MHz
		.hclkin			( clk_serial		),		//	input hclkin	371.25MHz
		.resetn			( 1'b1				)		//	input resetn
	);

	// --------------------------------------------------------------------
	//	reset
	// --------------------------------------------------------------------
	always @( posedge clk_pixel ) begin
		ff_reset_n	<= ff_reset1_n;
		ff_reset1_n	<= ff_reset0_n;
		ff_reset0_n	<= 1'b1;
	end

	// --------------------------------------------------------------------
	//	Z80 core
	// --------------------------------------------------------------------
	always @( posedge clk_pixel ) begin
		if( !ff_reset_n ) begin
			ff_cpu_enable <= 1'b0;
		end
		else if( w_sdram_init_busy ) begin
			//	Wait finish for SDRAM initialization
			ff_cpu_enable <= 1'b0;
		end
		else begin
			ff_cpu_enable <= ~ff_cpu_enable;
		end
	end

	assign w_enable	= ~w_sdram_init_busy && ff_cpu_enable;

	cz80_inst u_z80 (
		.reset_n				( ff_reset_n				),
		.clk_n					( clk_pixel					),
		.enable					( w_enable					),
		.wait_n					( wait_n					),
		.int_n					( int_n						),
		.nmi_n					( nmi_n						),
		.busrq_n				( busrq_n					),
		.m1_n					( m1_n						),
		.mreq_n					( mreq_n					),
		.iorq_n					( iorq_n					),
		.rd_n					( rd_n						),
		.wr_n					( wr_n						),
		.rfsh_n					( rfsh_n					),
		.halt_n					( halt_n					),
		.busak_n				( busak_n					),
		.a						( a							),
		.d						( d							)
	);

	assign int_n	= 1'b1;
	assign wait_n	= 1'b1;
	assign nmi_n	= 1'b1;
	assign busrq_n	= 1'b1;
	assign d		= ( !rd_n ) ? ff_d : 8'hzz;

	always @( posedge clk_pixel ) begin
		if( w_rom_rdata_en ) begin
			ff_d <= w_rom_rdata;
		end
		else if( w_ram_rdata_en ) begin
			ff_d <= w_ram_rdata;
		end
		else if( w_gpio_q_en ) begin
			ff_d <= w_gpio_q;
		end
		else if( rd_n ) begin
			ff_d <= 8'hFF;
		end
		else begin
			//	hold
		end
	end

	// --------------------------------------------------------------------
	//	GPIO ( I/O 10h )
	// --------------------------------------------------------------------
	ip_gpio #(
		.io_address				( 8'h10					)
	) u_gpio (
		.reset_n				( ff_reset_n			),
		.clk					( clk_pixel				),
		.iorq_n					( iorq_n				),
		.address				( a[7:0]				),
		.rd_n					( rd_n					),
		.wr_n					( wr_n					),
		.d						( d						),
		.q						( w_gpio_q				),
		.q_en					( w_gpio_q_en			),
		.gpo					( w_gpo					),
		.gpi					( { 6'd0, button }		)
	);

	// --------------------------------------------------------------------
	//	CPU ROM ( 0000h-3FFFh )
	// --------------------------------------------------------------------
	ip_rom u_rom (
		.clk					( clk_pixel				),
		.n_cs					( w_rom_cs_n			),
		.n_rd					( rd_n					),
		.address				( a[9:0]				),
		.rdata					( w_rom_rdata			),
		.rdata_en				( w_rom_rdata_en		)
	);

	assign w_rom_cs_n	= ( a[15:14] == 2'b00 ) ? mreq_n: 1'b1;

	// --------------------------------------------------------------------
	//	CPU RAM ( C000h-FFFFh )
	// --------------------------------------------------------------------
	ip_ram u_ram (
		.clk					( clk_pixel				),
		.n_cs					( w_ram_cs_n			),
		.n_wr					( wr_n					),
		.n_rd					( rd_n					),
		.address				( a[9:0]				),
		.wdata					( d						),
		.rdata					( w_ram_rdata			),
		.rdata_en				( w_ram_rdata_en		)
	);

	assign w_ram_cs_n	= ( a[15:14] == 2'b11 ) ? mreq_n: 1'b1;

	// --------------------------------------------------------------------
	//	Video Core
	// --------------------------------------------------------------------
	ip_video u_video (
		.reset_n				( w_hdmi_reset_n		),
		.clk					( clk_pixel				),
		.iorq_n					( iorq_n				),
		.address				( a[7:0]				),
		.wr_n					( wr_n					),
		.wdata					( d						),
		.vram_mreq_n			( w_vram_mreq_n			),
		.vram_address			( w_vram_address		),
		.vram_wr_n				( w_vram_wr_n			),
		.vram_rd_n				( w_vram_rd_n			),
		.vram_rfsh_n			( w_vram_rfsh_n			),
		.vram_wdata				( w_vram_wdata			),
		.vram_rdata				( w_vram_rdata			),
		.vram_rdata_en			( w_vram_rdata_en		),
		.video_de				( w_de					),
		.video_hs				( w_hs					),
		.video_vs				( w_vs					),
		.video_r				( w_r					),
		.video_g				( w_g					),
		.video_b				( w_b					)
	);

	assign w_sdram_mreq_n	= w_vram_mreq_n | w_sdram_init_busy;

	// --------------------------------------------------------------------
	//	HDMI
	// --------------------------------------------------------------------
	DVI_TX_Top u_dvi (
		.I_rst_n				( w_hdmi_reset_n		),		//input I_rst_n
		.I_serial_clk			( clk_serial			),		//input I_serial_clk
		.I_rgb_clk				( clk_pixel				),		//input I_rgb_clk
		.I_rgb_vs				( w_vs					),		//input I_rgb_vs
		.I_rgb_hs				( w_hs					),		//input I_rgb_hs
		.I_rgb_de				( w_de					),		//input I_rgb_de
		.I_rgb_r				( w_r					),		//input [7:0] I_rgb_r
		.I_rgb_g				( w_g					),		//input [7:0] I_rgb_g
		.I_rgb_b				( w_b					),		//input [7:0] I_rgb_b
		.O_tmds_clk_p			( tmds_clk_p			),		//output O_tmds_clk_p
		.O_tmds_clk_n			( tmds_clk_n			),		//output O_tmds_clk_n
		.O_tmds_data_p			( tmds_d_p				),		//output [2:0] O_tmds_data_p
		.O_tmds_data_n			( tmds_d_n				)		//output [2:0] O_tmds_data_n
	);

	// --------------------------------------------------------------------
	//	SDRAM
	// --------------------------------------------------------------------
	ip_sdram u_sdram (
		.reset_n				( ff_reset_n			),
		.clk					( clk_pixel				),
		.clk_sdram				( clk_pixel				),
		.sdram_init_busy		( w_sdram_init_busy		),
		.sdram_busy				( w_sdram_busy			),
		.mreq_n					( w_sdram_mreq_n		),
		.address				( w_vram_address		),
		.wr_n					( w_vram_wr_n			),
		.rd_n					( w_vram_rd_n			),
		.rfsh_n					( w_vram_rfsh_n			),
		.wdata					( w_vram_wdata			),
		.rdata					( w_vram_rdata			),
		.rdata_en				( w_vram_rdata_en		),
		.O_sdram_clk			( O_sdram_clk			),
		.O_sdram_cke			( O_sdram_cke			),
		.O_sdram_cs_n			( O_sdram_cs_n			),
		.O_sdram_cas_n			( O_sdram_cas_n			),
		.O_sdram_ras_n			( O_sdram_ras_n			),
		.O_sdram_wen_n			( O_sdram_wen_n			),
		.IO_sdram_dq			( IO_sdram_dq			),
		.O_sdram_addr			( O_sdram_addr			),
		.O_sdram_ba				( O_sdram_ba			),
		.O_sdram_dqm			( O_sdram_dqm			)
	);
endmodule
