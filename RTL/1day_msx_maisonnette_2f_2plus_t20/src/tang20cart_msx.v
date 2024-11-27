// -----------------------------------------------------------------------------
//	tang20cart_msx.v
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
//		Tangnano20K Cartridge for MSX
// -----------------------------------------------------------------------------
module tang20cart_msx (
	//	MSX Cartridge connector
	input			clk27m,			//	PIN04_SYS_CLK: 27MHz
	input			n_treset,		//	PIN85_SDIO_D1
	input			tclock,			//	PIN76_HSPI_DAT: 3.579454MHz
	input			vdp_cs,			//	PIN55_I2S_LRCK
	input			n_twr,			//	PIN56_I2S_BCLK
	input			n_trd,			//	PIN54_I2S_DIN
	input	[1:0]	ta,				//	PIN73_HSPI_DIN2: ta[0]
									//	PIN74_HSPI_DIN3: ta[1]
	output			tdir,			//	PIN75_HSPI_DIR
	inout	[7:0]	td,				//	PIN17_SYS_LED2: td[0]
									//	PIN20_SYS_LED5: td[1]
									//	PIN19_SYS_LED4: td[2]
									//	PIN18_SYS_LED3: td[3]
									//	PIN72_HSPI_DIN1: td[4]
									//	PIN71_HSPI_DIN0: td[5]
									//	PIN53_EDIO_CLK: td[6]
									//	PIN52_EDIO_DAT: td[7]
	input	[1:0]	keys,			//	PIN88_MODE0_KEY1: keys[0]
									//	PIN87_MODE1_KEY2: keys[1]
	output			twait,			//	PIN80_SDIO_D2:
	output			tint,			//	PIN16
	output			led,			//	PIN79
	//	VGA Output
	output			lcd_clk,		//	PIN77
	output			lcd_de,			//	PIN48
	output			lcd_hsync,		//	PIN25
	output			lcd_vsync,		//	PIN26
	output	[4:0]	lcd_red,		//	PIN38, PIN39, PIN40, PIN41, PIN42
	output	[5:0]	lcd_green,		//	PIN32, PIN33, PIN34, PIN35, PIN36, PIN37
	output	[4:0]	lcd_blue,		//	PIN27, PIN28, PIN29, PIN30, PIN31
	output			lcd_bl,			//	PIN49

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

	reg		[25:0]	ff_count = 26'd0;
	reg				ff_led;
	wire	[15:0]	taddress;
	reg		[6:0]	ff_reset = 7'd0;
	reg		[4:0]	ff_wait = 5'b10000;
	wire			clk;
	wire			clk_sdram;
	wire			clk_half;
	reg				ff_21mhz = 1'b0;
	wire			w_n_reset;
	wire	[15:0]	w_bus_address;
	wire	[7:0]	w_bus_write_data;
	wire	[7:0]	w_bus_read_data;
	wire			w_bus_io_req;
	wire			w_bus_write;
	wire			w_is_output;
	//	SDRAM
	wire			w_sdram_read_n;
	wire			w_sdram_write_n;
	wire			w_sdram_busy;
	wire	[22:0]	w_sdram_address;
	wire	[7:0]	w_sdram_wdata;
	wire	[15:0]	w_sdram_rdata;
	wire			w_sdram_rdata_en;

	wire	[7:0]	w_read_cycle;
	wire	[7:0]	w_send_data;
	wire			w_send_req;
	wire			w_send_busy;

	wire			w_req;
	wire			w_ack;
	wire			w_wrt;

	wire	[5:0]	w_lcd_red;
	wire	[5:0]	w_lcd_green;
	wire	[5:0]	w_lcd_blue;
	wire	[1:0]	w_vdp_enable_state;

	wire			w_dh_clk;
	wire			w_dl_clk;

	wire			n_reset;
	wire	[15:0]	w_adr;
	wire	[7:0]	w_i_data;
	wire	[7:0]	w_o_data;
	wire			is_wire;
	wire			n_sltsl;
	wire			n_rd;
	wire			n_wr;
	wire			n_ioreq;
	wire			n_mereq;
	wire			w_int_n;
	reg		[3:0]	ff_count2;

	// --------------------------------------------------------------------
	//	OUTPUT Assignment
	// --------------------------------------------------------------------
	assign w_n_reset	= ff_reset[6];

	assign td			= w_is_output   ? w_o_data : 8'hZZ;
	assign tdir			= w_is_output;
	assign twait		= ff_wait[4];

	always @( posedge clk ) begin
		ff_reset[5:0]	<= { ff_reset[4:0], n_treset };
		ff_reset[6]		<= ( ff_reset[5:1] != 5'd0 ) ? 1'b1 : 1'b0;
	end

	always @( posedge clk ) begin
		if( ff_wait[3:0] == 4'b1111 ) begin
			ff_wait[4] <= 1'b0;
		end
		else begin
			ff_wait[3:0] <= ff_wait[3:0] + 4'd1;
			ff_wait[4] <= 1'b1;
		end
	end

	always @( posedge clk ) begin
		if( !w_n_reset ) begin
			ff_count	<= 26'h0;
		end
		else if( vdp_cs ) begin
			ff_count	<= 26'h3FFFFFF;
		end
		else if( ff_count != 26'd0 ) begin
			ff_count	<= ff_count - 26'd1;
		end
		else begin
			//	hold
		end
	end

	always @( posedge clk ) begin
		if( !w_n_reset ) begin
			ff_led	<= 1'b1;
		end
		else if( vdp_cs ) begin
			ff_led	<= 1'b0;
		end
		else if( ff_count == 26'd0 ) begin
			ff_led	<= 1'b1;
		end
		else begin
			//	hold
		end
	end

	always @( posedge clk ) begin
		if( !w_n_reset ) begin
			ff_count2 <= 4'd0;
		end
		else if( ff_count == 26'd0 ) begin
			ff_count2 <= ff_count2 + 4'd1;
		end
		else begin
			//	hold
		end
	end

	assign led		= ff_led;

	assign w_adr	= { 14'd0, ta };
	assign w_i_data	= td;
//	assign tint		= ~w_int_n;
	assign tint		= (ff_count2 == 4'hF);

	// --------------------------------------------------------------------
	//	PLL 3.579545MHz --> 42.95454MHz
	// --------------------------------------------------------------------
	Gowin_PLL u_pll (
		.clkout				( clk						),		//	output		85.90908MHz
		.clkin				( tclock					)		//	input		3.579545MHz
	);

//	Gowin_PLL u_pll (
//		.clkout				( clk						),		//	output		86.4MHz
//		.clkin				( clk27m					)		//	input		27.0MHz
//	);

	// --------------------------------------------------------------------
	//	DEBUGGER
	// --------------------------------------------------------------------
//	ip_debugger u_debugger (
//		.n_reset			( w_n_reset					),
//		.clk				( clk						),
//		.keys				( keys						),
//		.enable_state		( w_vdp_enable_state		),
//		.dh_clk				( w_dh_clk					),
//		.dl_clk				( w_dl_clk					),
//		.req				( w_req						),
//		.ack				( w_ack						),
//		.wr					( w_wr						),
//		.address			( w_a						),
//		.wdata				( w_wdata					),
//		.rdata				( w_rdata					),
//		.sdram_busy			( w_sdram_busy				)
//	);

	// --------------------------------------------------------------------
	//	MSX50BUS for cartridge side
	// --------------------------------------------------------------------
	ip_msxbus u_msxbus (
		.n_reset			( w_n_reset					),
		.clk				( clk						),
		.adr				( w_adr						),
		.i_data				( w_i_data					),
		.o_data				( w_o_data					),
		.is_output			( w_is_output				),
		.n_sltsl			( 1'b1						),
		.n_rd				( n_trd						),
		.n_wr				( n_twr						),
		.n_ioreq			( ~vdp_cs					),
		.bus_address		( w_bus_address				),
		.bus_read_data		( w_bus_read_data			),
		.bus_read_data_en	( w_ack						),
		.bus_write_data		( w_bus_write_data			),
		.bus_io_req			( w_req						),
		.bus_memory_req		( 							),
		.bus_ack			( w_ack						),
		.bus_write			( w_wrt						)
	);

	// --------------------------------------------------------------------
	//	V9958 clone
	// --------------------------------------------------------------------
	vdp_inst u_v9958 (
		.clk				( clk						),
		.enable_state		( w_vdp_enable_state		),
		.reset_n			( w_n_reset					),
		.initial_busy		( w_sdram_busy				),
		.req				( w_req						),
		.ack				( w_ack						),
		.wrt				( w_wrt						),
		.address			( w_bus_address[1:0]		),		//	[ 1: 0];
		.rdata				( w_bus_read_data			),		//	[ 7: 0];
		.wdata				( w_bus_write_data			),		//	[ 7: 0];
		.int_n				( w_int_n					),		
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

	// --------------------------------------------------------------------
	//	SDRAM
	// --------------------------------------------------------------------
	ip_sdram u_sdram (
		.n_reset			( w_n_reset					),
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

	assign w_sdram_address[22:17]	= 6'b000000;
	assign lcd_red					= w_lcd_red[5:1];
	assign lcd_green				= w_lcd_green;
	assign lcd_blue					= w_lcd_blue[5:1];
	assign lcd_bl					= 1'b1;
endmodule

`default_nettype wire
