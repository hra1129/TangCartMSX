// -----------------------------------------------------------------------------
//	tangnano20k_step3.v
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

module tangnano20k_step3 (
	input			clk27m,			//	clk27m		PIN04_SYS_CLK		(27MHz)
	input	[1:0]	button,			//	button[0]	PIN88_MODE0_KEY1
									//	button[1]	PIN87_MODE1_KEY2
	//	VGA Output
	output			lcd_clk,		//	PIN77
	output			lcd_de,			//	PIN48
	output			lcd_hsync,		//	PIN25
	output			lcd_vsync,		//	PIN26
	output	[4:0]	lcd_red,		//	PIN38, PIN39, PIN40, PIN41, PIN42
	output	[5:0]	lcd_green,		//	PIN32, PIN33, PIN34, PIN35, PIN36, PIN37
	output	[4:0]	lcd_blue,		//	PIN27, PIN28, PIN29, PIN30, PIN31
	output			lcd_bl,			//	PIN49
	//	UART
	output			uart_tx,		//	uart_tx		PIN69_SYS_TX
	//	SDRAM
	output			O_sdram_clk,	//	Internal
	output			O_sdram_cke,	//	Internal
	output			O_sdram_cs_n,	//	Internal
	output			O_sdram_cas_n,	//	Internal
	output			O_sdram_ras_n,	//	Internal
	output			O_sdram_wen_n,	//	Internal
	inout	[31:0]	IO_sdram_dq,	//	Internal
	output	[10:0]	O_sdram_addr,	//	Internal
	output	[1:0]	O_sdram_ba,		//	Internal
	output	[3:0]	O_sdram_dqm		//	Internal
);
	wire			clk;
	reg				ff_delay = 3'd7;
	reg				ff_reset_n = 1'b0;
	reg		[1:0]	ff_clock_div = 2'd0;
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
	wire			w_rom_cs_n;
	wire	[7:0]	w_rom_q;
	wire			w_rom_q_en;
	wire			w_ram_cs_n;
	wire	[7:0]	w_ram_q;
	wire			w_ram_q_en;
	wire	[7:0]	w_uart_q;
	wire			w_uart_q_en;

	wire			w_sdram_read_n;
	wire			w_sdram_write_n;
	wire			w_sdram_busy;
	wire	[22:0]	w_sdram_address;
	wire	[7:0]	w_sdram_wdata;
	wire	[15:0]	w_sdram_rdata;
	wire			w_sdram_rdata_en;

	wire	[5:0]	w_lcd_red;
	wire	[5:0]	w_lcd_green;
	wire	[5:0]	w_lcd_blue;

	wire	[1:0]	w_vdp_enable_state;
	wire			w_vdp_cs_n;
	wire	[7:0]	w_vdp_q;
	wire			w_vdp_q_en;
	wire			w_dh_clk;
	wire			w_dl_clk;

	// --------------------------------------------------------------------
	//	clock
	// --------------------------------------------------------------------
	Gowin_PLL u_pll (
		.clkout			( clk			),		//output clkout		86.4MHz
		.clkin			( clk27m		)		//input clkin		27MHz
	);

	always @( posedge clk ) begin
		if( !ff_reset_n ) begin
			ff_clock_div <= 3'd0;
		end
		else begin
			ff_clock_div <= ff_clock_div + 2'd1;
		end
	end
	assign w_enable		= (ff_clock_div == 2'd3);

	// --------------------------------------------------------------------
	//	reset
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( ff_delay != 3'd0 ) begin
			ff_delay <= ff_delay - 3'd1;
		end
		else begin
			//	hold
		end
	end

	always @( posedge clk ) begin
		if( ff_delay == 3'd0 ) begin
			ff_reset_n <= 1'b1;
		end
	end

	// --------------------------------------------------------------------
	//	Z80 core
	// --------------------------------------------------------------------
	cz80_inst u_z80 (
		.reset_n		( ff_reset_n	),
		.clk_n			( clk			),
		.enable			( w_enable		),
		.wait_n			( wait_n		),
		.int_n			( int_n			),
		.nmi_n			( nmi_n			),
		.busrq_n		( busrq_n		),
		.m1_n			( m1_n			),
		.mreq_n			( mreq_n		),
		.iorq_n			( iorq_n		),
		.rd_n			( rd_n			),
		.wr_n			( wr_n			),
		.rfsh_n			( rfsh_n		),
		.halt_n			( halt_n		),
		.busak_n		( busak_n		),
		.a				( a				),
		.d				( d				)
	);

	assign wait_n	= 1'b1;
	assign int_n	= 1'b1;
	assign nmi_n	= 1'b1;
	assign busrq_n	= 1'b1;
	assign d		= ( w_uart_q_en ) ? w_uart_q:
					  ( w_rom_q_en  ) ? w_rom_q :
					  ( w_ram_q_en  ) ? w_ram_q : 8'hzz;

	// --------------------------------------------------------------------
	//	UART
	// --------------------------------------------------------------------
	ip_uart_inst #(
		.clk_freq		( 86400000		),
		.uart_freq		( 115200		)
	) u_uart (
		.reset_n		( ff_reset_n	),
		.clk			( clk			),
		.enable			( w_enable		),
		.iorq_n			( iorq_n		),
		.wr_n			( wr_n			),
		.rd_n			( rd_n			),
		.a				( a[7:0]		),
		.d				( d				),
		.q				( w_uart_q		),
		.q_en			( w_uart_q_en	),
		.button			( button		),
		.uart_tx		( uart_tx		)
	);

	// --------------------------------------------------------------------
	//	ROM
	// --------------------------------------------------------------------
	ip_hello_world_rom u_rom (
		.clk				( clk						),
		.n_cs				( w_rom_cs_n				),
		.n_rd				( rd_n						),
		.address			( a[13:0]					),
		.rdata				( w_rom_q					),
		.rdata_en			( w_rom_q_en				)
	);

	assign w_rom_cs_n	= ( a[15:14] == 2'b00 ) ? mreq_n : 1'b1;

	// --------------------------------------------------------------------
	//	RAM
	// --------------------------------------------------------------------
	ip_ram u_ram (
		.clk				( clk						),
		.n_cs				( w_ram_cs_n				),
		.n_wr				( wr_n						),
		.n_rd				( rd_n						),
		.address			( a[13:0]					),
		.wdata				( d							),
		.rdata				( w_ram_q					),
		.rdata_en			( w_ram_q_en				)
	);

	assign w_ram_cs_n	= ( a[15:14] == 2'b01 ) ? mreq_n : 1'b1;

	// --------------------------------------------------------------------
	//	V9958 clone
	// --------------------------------------------------------------------
	vdp_inst u_v9958 (
		.clk				( clk						),
		.enable_state		( w_vdp_enable_state		),
		.reset_n			( ff_reset_n				),
		.initial_busy		( w_sdram_busy				),
		.iorq_n				( w_vdp_cs_n				),
		.wr_n				( wr_n						),
		.rd_n				( rd_n						),
		.address			( a[1:0]					),		//	[ 1: 0];
		.rdata				( w_vdp_q					),		//	[ 7: 0];
		.rdata_en			( w_vdp_q_en				),
		.wdata				( d							),		//	[ 7: 0];
		.int_n				( 							),		
		.p_dram_oe_n		( w_sdram_read_n			),		
		.p_dram_we_n		( w_sdram_write_n			),		
		.p_dram_address		( w_sdram_address[16:0]		),		//	[16: 0];
		.p_dram_rdata		( w_sdram_rdata				),		//	[15: 0];
		.p_dram_wdata		( w_sdram_wdata				),		//	[ 7: 0];
		.pvideo_clk			( lcd_clk					),		
		.pvideo_data_en		( lcd_de					),		
		.pvideor			( w_lcd_red					),		//	[ 5: 0];
		.pvideog			( w_lcd_green				),		//	[ 5: 0];
		.pvideob			( w_lcd_blue				),		//	[ 5: 0];
		.pvideohs_n			( lcd_hsync					),
		.pvideovs_n			( lcd_vsync					),
		.p_video_dh_clk		( w_dh_clk					),
		.p_video_dl_clk		( w_dl_clk					)
    );

	assign w_vdp_cs_n				= !( !iorq_n && ( { a[7:2], 2'd0 } == 8'h98 ) );
	assign w_sdram_address[22:17]	= 6'b000000;
	assign lcd_red					= w_lcd_red[5:1];
	assign lcd_green				= w_lcd_green;
	assign lcd_blue					= w_lcd_blue[5:1];
	assign lcd_bl					= 1'b1;

	// --------------------------------------------------------------------
	//	SDRAM
	// --------------------------------------------------------------------
	ip_sdram u_sdram (
		.n_reset			( ff_reset_n				),
		.clk				( clk						),
		.clk_sdram			( clk						),
		.enable_state		( w_vdp_enable_state		),
		.sdram_busy			( w_sdram_busy				),
		.dh_clk				( w_dh_clk					),
		.dl_clk				( w_dl_clk					),
		.address			( w_sdram_address			),
		.is_write			( !w_sdram_write_n			),
		.wdata				( w_sdram_wdata				),
		.rdata				( w_sdram_rdata				),
		.O_sdram_clk		( O_sdram_clk				),
		.O_sdram_cke		( O_sdram_cke				),
		.O_sdram_cs_n		( O_sdram_cs_n				),
		.O_sdram_cas_n		( O_sdram_cas_n				),
		.O_sdram_ras_n		( O_sdram_ras_n				),
		.O_sdram_wen_n		( O_sdram_wen_n				),
		.IO_sdram_dq		( IO_sdram_dq				),
		.O_sdram_addr		( O_sdram_addr				),
		.O_sdram_ba			( O_sdram_ba				),
		.O_sdram_dqm		( O_sdram_dqm				)
	);
endmodule
