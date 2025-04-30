// -----------------------------------------------------------------------------
//	tangnano20k_step9.v
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

module tangnano20k_step9 (
	input			clk27m,				//	clk27m		PIN04_SYS_CLK		(27MHz)
	input			clk3_579m,			//	clk3_579m	PIN76				(3.579545MHz)
	input	[1:0]	button,				//	button[0]	PIN88_MODE0_KEY1
										//	button[1]	PIN87_MODE1_KEY2
	output			halt_n,
	//	VGA Output
	output			lcd_clk,			//	PIN77
	output			lcd_de,				//	PIN48
	output			lcd_hsync,			//	PIN25
	output			lcd_vsync,			//	PIN26
	output	[4:0]	lcd_red,			//	PIN38, PIN39, PIN40, PIN41, PIN42
	output	[5:0]	lcd_green,			//	PIN32, PIN33, PIN34, PIN35, PIN36, PIN37
	output	[4:0]	lcd_blue,			//	PIN27, PIN28, PIN29, PIN30, PIN31
	output			lcd_bl,				//	PIN49
	//	SPI
	input			spi_cs_n,			//	PIN79
	input			spi_clk,			//	PIN73
	input			spi_mosi,			//	PIN74
	output			spi_miso,			//	PIN75
	//	PSG
	inout	[5:0]	ssg_ioa,			//	PIN20, PIN19, PIN18, PIN17, PIN16, PIN15
	output	[2:0]	ssg_iob,			//	PIN71, PIN53, PIN52
	//	TF Card I/F
//	output			tf_ck,				//	TF Card I/F PIN83_SDIO_CLK
//	output			tf_cs,				//	TF Card I/F PIN81_SDIO_D3
//	output reg		tf_di,				//	TF Card I/F PIN82_SDIO_CMD
//	input			tf_do,				//	TF Card I/F PIN84_SDIO_D0
	//	I2C AUDIO
	output			i2s_audio_en,		//	PIN51
	output			i2s_audio_din,		//	PIN54
	output			i2s_audio_lrclk,	//	PIN55
	output			i2s_audio_bclk,		//	PIN56
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
	wire			clk;
	wire			clk42m;
	reg		[2:0]	ff_delay = 3'd7;
	reg				ff_reset_n = 1'b0;
	reg				ff_clock_div = 1'b0;
	reg		[3:0]	ff_cpu_clock_div = 4'b0;
	reg		[3:0]	ff_psg_clock_div = 4'b0;
	wire			w_enable;
	wire			w_cpu_enable;
	wire			w_psg_enable;
	wire			w_cpu_enable_timing;
	localparam		enable_timing = 4'd6;

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
	wire			busak_n;
	wire	[15:0]	a;
	wire	[7:0]	d;
	reg		[7:0]	ff_d;

	wire			w_sdram_mreq_n;
	wire			w_sdram_wr_n;
	wire			w_sdram_rd_n;
	wire			w_sdram_init_busy;
	wire			w_sdram_busy;
	wire	[22:0]	w_sdram_address;
	wire	[7:0]	w_sdram_q;
	wire			w_sdram_q_en;
	wire	[7:0]	w_sdram_d;

	wire			w_vram_read_n;
	wire			w_vram_write_n;
	wire	[16:0]	w_vram_address;
	wire	[7:0]	w_vram_wdata;
	wire	[15:0]	w_vram_rdata;
	wire			w_vram_rdata_en;
	reg		[15:0]	ff_vram_rdata;
	reg		[15:0]	ff_vram_rdata1;
	reg		[15:0]	ff_vram_rdata2;

	wire	[7:0]	w_video_r;
	wire	[7:0]	w_video_g;
	wire	[7:0]	w_video_b;

	wire	[1:0]	w_vdp_enable_state;
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

	wire			w_msx_reset_n;
	wire			w_cpu_freeze;

	wire			w_ppi_cs_n;
	wire	[3:0]	w_matrix_y;
	wire	[7:0]	w_matrix_x;
	wire			w_cmt_motor_off;
	wire			w_cmt_write_signal;
	wire			w_keyboard_caps_led_off;
	wire			w_click_sound;
	wire			w_sltsl0;
	wire			w_sltsl1;
	wire			w_sltsl2;
	wire			w_sltsl3;
	wire			w_sltsl00;
	wire			w_sltsl01;
	wire			w_sltsl02;
	wire			w_sltsl03;
	wire			w_sltsl30;
	wire			w_sltsl31;
	wire			w_sltsl32;
	wire			w_sltsl33;
	wire	[7:0]	w_expslt0_q;
	wire			w_expslt0_q_en;
	wire	[7:0]	w_expslt3_q;
	wire			w_expslt3_q_en;
	wire	[22:0]	w_spi_address;
	wire			w_spi_mreq_n;
	wire	[7:0]	w_spi_d;
	wire	[7:0]	w_ppi_q;
	wire			w_ppi_q_en;
	wire			w_psg_cs_n;
	wire	[7:0]	w_psg_q;
	wire			w_psg_q_en;
	wire	[7:0]	w_rtc_q;
	wire			w_rtc_q_en;
	wire			w_keyboard_type;
	wire			w_keyboard_kana_led_off;
	wire	[11:0]	w_ssg_sound_out;
	wire	[15:0]	w_opll_sound_out;
	wire	[15:0]	w_sound_in;

	wire			w_megarom1_rd_n;
	wire	[21:0]	w_megarom1_address;
	wire	[2:0]	w_megarom1_mode;
	wire	[10:0]	w_megarom1_sound;
	wire	[7:0]	w_megarom1_rdata;
	wire			w_megarom1_rdata_en;
	wire			w_megarom1_mem_cs_n;

	wire			w_megarom2_rd_n;
	wire	[21:0]	w_megarom2_address;
	wire	[2:0]	w_megarom2_mode;
	wire	[10:0]	w_megarom2_sound;
	wire	[7:0]	w_megarom2_rdata;
	wire			w_megarom2_rdata_en;
	wire			w_megarom2_mem_cs_n;

	wire			w_kanji_iorq_n;
	wire	[17:0]	w_kanji_address;
	wire			w_kanji_en;

	wire	[7:0]	w_mapper_segment;

	wire	[7:0]	w_sys_q;
	wire			w_sys_q_en;
	wire	[7:0]	w_left_offset;
	wire	[7:0]	w_denominator;
	wire	[7:0]	w_normalize;

	// --------------------------------------------------------------------
	//	clock
	// --------------------------------------------------------------------
	Gowin_PLL u_pll (
		.clkout			( clk			),		//	output clkout	85.90908MHz
		.clkoutd		( clk42m		),		//	output clkoutd	42.95454MHz
		.clkin			( clk3_579m		)		//	input clkin		3.579545MHz
	);

	always @( posedge clk42m ) begin
		if( !ff_reset_n ) begin
			ff_clock_div <= 1'd0;
		end
		else begin
			ff_clock_div <= ~ff_clock_div;
		end
	end
	assign w_enable		= (ff_clock_div == 1'b1);

	always @( posedge clk42m ) begin
		if( !ff_reset_n ) begin
			ff_cpu_clock_div <= 4'd0;
		end
		else begin
			if( ff_cpu_clock_div == 4'd11 ) begin
				ff_cpu_clock_div <= 4'd0;
			end
			else begin
				ff_cpu_clock_div <= ff_cpu_clock_div + 4'd1;
			end
		end
	end
	assign w_cpu_enable			= (ff_cpu_clock_div == enable_timing && !w_sdram_init_busy && !w_cpu_freeze);
	assign w_cpu_enable_timing	= (ff_cpu_clock_div == enable_timing);

	always @( posedge clk42m ) begin
		if( !ff_reset_n ) begin
			ff_psg_clock_div <= 4'd0;
		end
		else begin
			if( ff_psg_clock_div == 4'd11 ) begin
				ff_psg_clock_div <= 4'd0;
			end
			else begin
				ff_psg_clock_div <= ff_psg_clock_div + 4'd1;
			end
		end
	end
	assign w_psg_enable		= (ff_psg_clock_div == enable_timing && !w_sdram_init_busy && !w_cpu_freeze);

	// --------------------------------------------------------------------
	//	reset
	// --------------------------------------------------------------------
	always @( posedge clk42m ) begin
		if( ff_delay != 3'd0 ) begin
			ff_delay <= ff_delay - 3'd1;
		end
		else begin
			//	hold
		end
	end

	always @( posedge clk42m ) begin
		if( ff_delay == 3'd0 ) begin
			ff_reset_n <= 1'b1;
		end
	end

	// --------------------------------------------------------------------
	//	ESP32 Connection module
	// --------------------------------------------------------------------
	micom_connect u_esp32_conn (
		.reset_n				( ff_reset_n				),
		.clk					( clk						),
		.spi_cs_n				( spi_cs_n					),
		.spi_clk				( spi_clk					),
		.spi_mosi				( spi_mosi					),
		.spi_miso				( spi_miso					),
		.msx_reset_n			( w_msx_reset_n				),
		.cpu_freeze				( w_cpu_freeze				),
		.cpu_enable				( w_cpu_enable_timing		),
		.matrix_y				( w_matrix_y				),
		.matrix_x				( w_matrix_x				),
		.address				( w_spi_address				),
		.req_n					( w_spi_mreq_n				),
		.wdata					( w_spi_d					),
		.sdram_busy				( w_sdram_busy				),
		.sdram_init_busy		( w_sdram_init_busy			),
		.keyboard_caps_led_off	( w_keyboard_caps_led_off	),
		.keyboard_kana_led_off	( w_keyboard_kana_led_off	),
		.keyboard_type			( w_keyboard_type			),
		.megarom1_mode			( w_megarom1_mode			),
		.megarom2_mode			( w_megarom2_mode			)
	);

	// --------------------------------------------------------------------
	//	Z80 core
	// --------------------------------------------------------------------
	cz80_inst u_z80 (
		.reset_n				( w_msx_reset_n				),
		.clk_n					( clk42m					),
		.enable					( w_cpu_enable				),
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

	assign wait_n	= 1'b1;
	assign nmi_n	= 1'b1;
	assign busrq_n	= 1'b1;
	assign d		= ( !rd_n ) ? ff_d : 8'hzz;

	always @( posedge clk ) begin
		if( w_sdram_q_en ) begin
			ff_d <= w_sdram_q;
		end
		else if( w_vdp_q_en ) begin
			ff_d <= w_vdp_q;
		end
		else if( w_expslt0_q_en ) begin
			ff_d <= w_expslt0_q;
		end
		else if( w_expslt3_q_en ) begin
			ff_d <= w_expslt3_q;
		end
		else if( w_ppi_q_en ) begin
			ff_d <= w_ppi_q;
		end
//		else if( w_rtc_q_en ) begin
//			ff_d <= w_rtc_q;
//		end
//		else if( w_psg_q_en ) begin
//			ff_d <= w_psg_q;
//		end
		else if( w_sys_q_en ) begin
			ff_d <= w_sys_q;
		end
		else if( rd_n ) begin
			ff_d <= 8'hFF;
		end
		else begin
			//	hold
		end
	end

	// --------------------------------------------------------------------
	//	RTC
	// --------------------------------------------------------------------
//	rtc u_rtc (
//		.clk					( clk42m					),
//		.enable					( w_enable					),
//		.iorq_n					( iorq_n					),
//		.wr_n					( wr_n						),
//		.rd_n					( rd_n						),
//		.address				( a[7:0]					),
//		.wdata					( d							),
//		.rdata					( w_rtc_q					),
//		.rdata_en				( w_rtc_q_en				)
//	);

	// --------------------------------------------------------------------
	//	PPI
	// --------------------------------------------------------------------
	ppi_inst u_ppi (
		.reset_n				( w_msx_reset_n				),
		.clk					( clk						),
		.iorq_n					( w_ppi_cs_n				),
		.wr_n					( wr_n						),
		.rd_n					( rd_n						),
		.address				( a							),
		.wdata					( d							),
		.rdata					( w_ppi_q					),
		.rdata_en				( w_ppi_q_en				),
		.matrix_y				( w_matrix_y				),
		.matrix_x				( w_matrix_x				),
		.cmt_motor_off			( w_cmt_motor_off			),
		.cmt_write_signal		( w_cmt_write_signal		),
		.keyboard_caps_led_off	( w_keyboard_caps_led_off	),
		.click_sound			( w_click_sound				),
		.sltsl0					( w_sltsl0					),
		.sltsl1					( w_sltsl1					),
		.sltsl2					( w_sltsl2					),
		.sltsl3					( w_sltsl3					)
	);

	assign w_ppi_cs_n	= ( { a[7:2], 2'b00 } == 8'hA8 ) ? iorq_n : 1'b1;

	// --------------------------------------------------------------------
	//	Expansion Slot#0-X
	// --------------------------------------------------------------------
	secondary_slot_inst u_exp_slot0 (
		.reset_n				( w_msx_reset_n				),
		.clk					( clk42m					),
		.sltsl					( w_sltsl0					),
		.mreq_n					( mreq_n					),
		.wr_n					( wr_n						),
		.rd_n					( rd_n						),
		.address				( a							),
		.wdata					( d							),
		.rdata					( w_expslt0_q				),
		.rdata_en				( w_expslt0_q_en			),
		.sltsl_ext0				( w_sltsl00					),
		.sltsl_ext1				( w_sltsl01					),
		.sltsl_ext2				( w_sltsl02					),
		.sltsl_ext3				( w_sltsl03					)
	);

	// --------------------------------------------------------------------
	//	Expansion Slot#3-X
	// --------------------------------------------------------------------
	secondary_slot_inst u_exp_slot3 (
		.reset_n				( w_msx_reset_n				),
		.clk					( clk42m					),
		.sltsl					( w_sltsl3					),
		.mreq_n					( mreq_n					),
		.wr_n					( wr_n						),
		.rd_n					( rd_n						),
		.address				( a							),
		.wdata					( d							),
		.rdata					( w_expslt3_q				),
		.rdata_en				( w_expslt3_q_en			),
		.sltsl_ext0				( w_sltsl30					),
		.sltsl_ext1				( w_sltsl31					),
		.sltsl_ext2				( w_sltsl32					),
		.sltsl_ext3				( w_sltsl33					)
	);

	// --------------------------------------------------------------------
	//	SSG
	// --------------------------------------------------------------------
//	ssg u_ssg (
//		.clk					( clk42m					),
//		.reset_n				( w_msx_reset_n				),
//		.enable					( w_psg_enable				),
//		.iorq_n					( w_psg_cs_n				),
//		.wr_n					( wr_n						),
//		.rd_n					( rd_n						),
//		.address				( a[1:0]					),
//		.wdata					( d							),
//		.rdata					( w_psg_q					),
//		.rdata_en				( w_psg_q_en				),
//		.ssg_ioa				( ssg_ioa					),
//		.ssg_iob				( ssg_iob					),
//		.keyboard_type			( w_keyboard_type			),
//		.cmt_read				( 1'b0						),
//		.kana_led				( w_keyboard_kana_led_off	),
//		.sound_out				( w_ssg_sound_out			)
//	);
	assign w_psg_cs_n				= !( !iorq_n && ( { a[7:2], 2'd0 } == 8'hA0 ) );

	// --------------------------------------------------------------------
	//	OPLL
	// --------------------------------------------------------------------
//	ip_opll u_opll (
//		.reset_n				( w_msx_reset_n				),
//		.clk					( clk42m					),
//		.iorq_n					( iorq_n					),
//		.wr_n					( wr_n						),
//		.address				( a							),
//		.wdata					( d							),
//		.sound_out				( w_opll_sound_out			)
//	);

	// --------------------------------------------------------------------
	//	Audio out
	// --------------------------------------------------------------------
//	i2s_audio u_audio (
//		.clk					( clk42m					),
//		.reset_n				( w_msx_reset_n				),
//		.sound_in				( w_sound_in				),
//		.i2s_audio_en			( i2s_audio_en				),
//		.i2s_audio_din			( i2s_audio_din				),
//		.i2s_audio_lrclk		( i2s_audio_lrclk			),
//		.i2s_audio_bclk			( i2s_audio_bclk			)
//	);

	//	signed 16bit mono
//	assign w_sound_in	= 
//		{ w_opll_sound_out } +
//		{ 4'd0, w_click_sound, 12'd0 } + 
//		{ 2'd0, w_ssg_sound_out, 2'd0 } + 
//		{ 2'd0, w_megarom1_sound, 3'd0 } +
//		{ 2'd0, w_megarom2_sound, 3'd0 };

	// --------------------------------------------------------------------
	//	V9958 clone
	// --------------------------------------------------------------------
	vdp_inst u_v9958 (
		.clk					( clk42m				),
		.reset_n				( ff_reset_n			),
		.initial_busy			( w_sdram_init_busy		),
		.iorq_n					( w_vdp_cs_n			),
		.wr_n					( wr_n					),
		.rd_n					( rd_n					),
		.address				( a[1:0]				),
		.rdata					( w_vdp_q				),		//	[ 7: 0];
		.rdata_en				( w_vdp_q_en			),
		.wdata					( d						),		//	[ 7: 0];
		.int_n					( int_n					),		
		.p_dram_oe_n			( w_vram_read_n			),		
		.p_dram_we_n			( w_vram_write_n		),		
		.p_dram_address			( w_vram_address		),		//	[16: 0];
		.p_dram_rdata			( ff_vram_rdata2		),		//	[15: 0];
		.p_dram_wdata			( w_vram_wdata			),		//	[ 7: 0];
		.p_vdp_enable			( w_vdp_enable			),
		.p_vdp_r				( w_vdp_r				),		//	[ 5: 0];
		.p_vdp_g				( w_vdp_g				),		//	[ 5: 0];
		.p_vdp_b				( w_vdp_b				),		//	[ 5: 0];
		.p_vdp_hcounter			( w_vdp_hcounter		),
		.p_vdp_vcounter			( w_vdp_vcounter		),
		.p_video_dh_clk			( w_dh_clk				),
		.p_video_dl_clk			( w_dl_clk				)
    );

	assign w_vdp_cs_n				= !( !iorq_n && ( { a[7:1], 1'd0 } == 8'h98 ) );

	// --------------------------------------------------------------------
	//	VRAM
	// --------------------------------------------------------------------
	ip_ram u_vram (
		.clk					( clk42m				),
		.n_cs					( 1'b0					),
		.n_wr					( w_vram_write_n		),
		.n_rd					( w_vram_read_n			),
		.address				( w_vram_address[13:0]	),
		.wdata					( w_vram_wdata			),
		.rdata					( w_vram_rdata[7:0]		),
		.rdata_en				( w_vram_rdata_en		)
	);

	always @( posedge clk42m ) begin
		if( w_vram_rdata_en ) begin
			ff_vram_rdata	<= { w_vram_rdata[7:0], w_vram_rdata[7:0] };
		end
	end

	always @( posedge clk42m ) begin
		ff_vram_rdata1	<= ff_vram_rdata;
		ff_vram_rdata2	<= ff_vram_rdata1;
	end

	// --------------------------------------------------------------------
	//	Video output
	// --------------------------------------------------------------------
	video_out #(
		.hs_positive			( 1'b0					),		//	If video_hs is positive logic, set to 1.
		.vs_positive			( 1'b0					)		//	If video_vs is positive logic, set to 1.
	) u_video_out (
		.clk					( clk42m				),
		.reset_n				( ff_reset_n			),
		.enable					( w_vdp_enable			),
		.vdp_r					( w_vdp_r				),
		.vdp_g					( w_vdp_g				),
		.vdp_b					( w_vdp_b				),
		.vdp_hcounter			( w_vdp_hcounter		),
		.vdp_vcounter			( w_vdp_vcounter		),
		.video_clk				( lcd_clk				),
		.video_de				( lcd_de				),
		.video_hs				( lcd_hsync				),
		.video_vs				( lcd_vsync				),
		.video_r				( w_video_r				),
		.video_g				( w_video_g				),
		.video_b				( w_video_b				),
		.reg_left_offset		( w_left_offset			),
		.reg_denominator		( w_denominator			),
		.reg_normalize			( w_normalize			),
		.reg_scanline			( w_scanline			)
	);

	assign lcd_red					= w_video_r[7:3];
	assign lcd_green				= { w_video_g[7:3], 1'b0 };
	assign lcd_blue					= w_video_b[7:3];
	assign lcd_bl					= !w_cpu_freeze;

	// --------------------------------------------------------------------
	//	SDRAM
	// --------------------------------------------------------------------
	ip_sdram #(
		.FREQ					( 85_909_080			),		//	Hz
		.c_vram_high_address	( 6'b000_111			)	//	[22:17]
	) u_sdram (
		.reset_n				( ff_reset_n			),
		.clk					( clk					),
		.clk_sdram				( clk					),
		.sdram_init_busy		( w_sdram_init_busy		),
		.sdram_busy				( w_sdram_busy			),
		.cpu_freeze				( w_cpu_freeze			),
		.cpu_enable				( w_cpu_enable_timing	),
		.cpu_mreq_n				( w_sdram_mreq_n		),
		.cpu_address			( w_sdram_address		),
		.cpu_wr_n				( w_sdram_wr_n			),
		.cpu_rd_n				( w_sdram_rd_n			),
		.cpu_rfsh_n				( rfsh_n				),
		.cpu_wdata				( w_sdram_d				),
		.cpu_rdata				( w_sdram_q				),
		.cpu_rdata_en			( w_sdram_q_en			),
		.vdp_access				( w_dl_clk				),
		.vdp_address			( w_vram_address		),
		.vdp_wr_n				( w_vram_write_n		),
		.vdp_rd_n				( w_vram_read_n			),
		.vdp_wdata				( w_vram_wdata			),
		.vdp_rdata				( 						),
		.vdp_rdata_en			( 						),
		.O_sdram_clk			( O_sdram_clk			),
		.O_sdram_cke			( O_sdram_cke			),
		.O_sdram_cs_n			( O_sdram_cs_n			),
		.O_sdram_ras_n			( O_sdram_ras_n			),
		.O_sdram_cas_n			( O_sdram_cas_n			),
		.O_sdram_wen_n			( O_sdram_wen_n			),
		.IO_sdram_dq			( IO_sdram_dq			),
		.O_sdram_addr			( O_sdram_addr			),
		.O_sdram_ba				( O_sdram_ba			),
		.O_sdram_dqm			( O_sdram_dqm			)
	);

	// --------------------------------------------------------------------
	//	KanjiROM
	// --------------------------------------------------------------------
	kanji_rom u_kanji_rom (
		.reset_n				( w_msx_reset_n			),
		.clk					( clk42m				),
		.iorq_n					( w_kanji_iorq_n		),
		.wr_n					( wr_n					),
		.rd_n					( rd_n					),
		.address				( a[1:0]				),
		.wdata					( d						),
		.kanji_rom_address		( w_kanji_address		),
		.kanji_rom_address_en	( w_kanji_en			)
	);

	assign w_kanji_iorq_n	= ( { a[7:2], 2'b00 } == 8'hD8 ) ? iorq_n : 1'b1;

	// --------------------------------------------------------------------
	//	MegaROM Controller
	// --------------------------------------------------------------------
	megarom_wo_scc u_megarom_slot1 (
		.clk					( clk42m				),
		.reset_n				( w_msx_reset_n			),
		.sltsl					( w_sltsl1				),
		.mreq_n					( mreq_n				),
		.wr_n					( wr_n					),
		.rd_n					( rd_n					),
		.address				( a						),
		.wdata					( d						),
		.rdata					( w_megarom1_rdata		),
		.rdata_en				( w_megarom1_rdata_en	),
		.mem_cs_n				( w_megarom1_mem_cs_n	),
		.megarom_rd_n			( w_megarom1_rd_n		),
		.megarom_address		( w_megarom1_address	),
		.mode					( w_megarom1_mode		),
		.sound_out				( w_megarom1_sound		)
	);

	megarom_wo_scc u_megarom_slot2 (
		.clk					( clk42m				),
		.reset_n				( w_msx_reset_n			),
		.sltsl					( w_sltsl2				),
		.mreq_n					( mreq_n				),
		.wr_n					( wr_n					),
		.rd_n					( rd_n					),
		.address				( a						),
		.wdata					( d						),
		.rdata					( w_megarom2_rdata		),
		.rdata_en				( w_megarom2_rdata_en	),
		.mem_cs_n				( w_megarom2_mem_cs_n	),
		.megarom_rd_n			( w_megarom2_rd_n		),
		.megarom_address		( w_megarom2_address	),
		.mode					( w_megarom2_mode		),
		.sound_out				( w_megarom2_sound		)
	);

	// --------------------------------------------------------------------
	//	Memory mapper
	// --------------------------------------------------------------------
	memory_mapper_inst u_memory_mapper (
		.reset_n				( w_msx_reset_n			),
		.clk					( clk42m				),
		.iorq_n					( iorq_n				),
		.wr_n					( wr_n					),
		.address				( a						),
		.wdata					( d						),
		.mapper_segment			( w_mapper_segment		)
	);

	// --------------------------------------------------------------------
	//	SDRAM memory map
	// --------------------------------------------------------------------
	assign w_sdram_address[22:13]	= ( w_cpu_freeze                     ) ? w_spi_address[22:13]                   :		//	SDRAM Updater from SPI
									  ( w_kanji_en                       ) ? {  5'b000_01, w_kanji_address[17:13] } :		//	JIS1/JIS2 KanjiROM
									  ( w_sltsl30                        ) ? {  1'b1, w_mapper_segment, a[13]     } :		//	MapperRAM
									  ( w_sltsl1                         ) ? {  2'b01, w_megarom1_address[20:13]  } :		//	MegaROM 2MB
									  ( w_sltsl2                         ) ? {  3'b001,w_megarom2_address[19:13]  } :		//	MegaROM 1MB
									  ( w_sltsl03                        ) ? {  8'b000_0011_1,    a[14:13]        } :		//	MSX Logo, ExtBASIC
									  ( w_sltsl02                        ) ? {  9'b000_0011_01,   a[13]           } :		//	MSX-MUSIC
									  ( w_sltsl01                        ) ? {  9'b000_0011_00,   a[13]           } :		//	BASIC'N
									  ( w_sltsl31 && (a[15:14] == 2'b00) ) ? {  8'b000_1000_0,    a[13]           } :		//	SUB-ROM
									  ( w_sltsl31                        ) ? {  8'b000_0010_1,    a[15], a[13]    } :		//	KanjiBASIC
									  ( w_sltsl00                        ) ? {  8'b000_0010_0,    a[14:13]        } :		//	MAIN-ROM
									  ( w_sltsl32                        ) ? {  6'b000_000, 1'b0, a[15:13]        } :		//	BANK#00-07: Nextor
									                                           10'b000_0000_000;							//	#3-3 N/A

	assign w_sdram_address[12:0]	= w_cpu_freeze ? w_spi_address[12:0]: 
	                            	  w_kanji_en   ? w_kanji_address[12:0]:
	                            	                 a[12:0];
	assign w_sdram_d				= w_cpu_freeze ? w_spi_d            : d;

	assign w_sdram_mreq_n			= ( w_cpu_freeze ) ? w_spi_mreq_n   : 
									  ( w_kanji_en   ) ? ~w_kanji_en    :		//	JIS1/JIS2 KanjiROM
									                     mreq_n;

	assign w_sdram_wr_n				= ( w_cpu_freeze ) ? w_spi_mreq_n :							//	SDRAM Updater from SPI
									  ( w_sltsl30    ) ? wr_n         :							//	MapperRAM
									                     1'b1;

	assign w_sdram_rd_n				= ( w_kanji_en                                            ) ? ~w_kanji_en :			//	JIS1/JIS2 KanjiROM
									  ( !iorq_n                                               ) ? 1'b1 :				//	
									  ( w_sltsl30                                             ) ? rd_n :				//	MapperRAM
									  ( !w_megarom1_mem_cs_n                                  ) ? w_megarom1_rd_n :		//	MegaROM 1MB
									  ( !w_megarom2_mem_cs_n                                  ) ? w_megarom2_rd_n :		//	MegaROM 512KB
									  ( w_sltsl03  && (a[15:14] == 2'b01 || a[15:14] == 2'b10)) ? rd_n :				//	MSX Logo, ExtBASIC
									  ( w_sltsl02  && (a[15:14] == 2'b01)                     ) ? rd_n :				//	MSX-MUSIC
									  ( w_sltsl01  && (a[15:14] == 2'b01)                     ) ? rd_n :				//	BASIC'N
									  ( w_sltsl31                                             ) ? rd_n :				//	SUB-ROM, KanjiBASIC
									  ( w_sltsl00  && (a[15]    == 1'b0)                      ) ? rd_n :				//	MAIN-ROM
									  ( w_sltsl32  && (a[15:14] == 2'b01 || a[15:14] == 2'b10)) ? rd_n :				//	Nextor
									                                                              1'b1;

	// --------------------------------------------------------------------
	//	System control
	// --------------------------------------------------------------------
	system_control u_system_control (
		.reset_n				( w_msx_reset_n			),
		.clk					( clk42m				),
		.iorq_n					( iorq_n				),
		.wr_n					( wr_n					),
		.rd_n					( rd_n					),
		.address				( a[7:0]				),
		.wdata					( d						),
		.rdata					( w_sys_q				),
		.rdata_en				( w_sys_q_en			),
		.reg_left_offset		( w_left_offset			),
		.reg_denominator		( w_denominator			),
		.reg_normalize			( w_normalize			),
		.reg_scanline			( w_scanline			)
	);
endmodule
