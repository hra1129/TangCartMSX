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
//	input			tclock,			//	PIN80_SDIO_D2: 3.579454MHz from MSX Ç±Ç±Ç≈ó«Ç¢ÇÃÇ©ÅH
	input			n_ce,			//	PIN55_I2S_LRCK
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
	output			twait,			//	PIN76_HSPI_DAT:

//	//	UART
//	output			uart_tx,		//	PIN69_SYS_TX

	//	LED
	output			sd_dat2,		//	PIN80_SDIO_D2
	output			sd_dat3,		//	PIN81_SDIO_D3

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

`default_nettype none
//	localparam		c_vdpid			= 5'b00001;		// V9938
	localparam		c_vdpid			= 5'b00010;		// V9958
	localparam		c_offset_y		= 7'd19;

	reg		[25:0]	ff_count = 26'd0;
	reg		[1:0]	ff_led = 2'd0;
	wire	[15:0]	taddress;
	reg		[6:0]	ff_reset = 7'd0;
	reg		[4:0]	ff_wait = 5'b10000;
	wire			clk;
	wire			clk_sdram;
	reg				ff_21mhz = 1'b0;
	wire			w_n_reset;
	wire	[7:0]	w_o_data;
	wire	[15:0]	w_bus_address;
	wire	[7:0]	w_bus_write_data;
	wire			w_bus_io_read;
	wire			w_bus_io_write;
	wire			w_bus_memory_read;
	wire			w_bus_memory_write;
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
	wire			w_wr;
	wire	[1:0]	w_ta;
	wire	[5:0]	w_lcd_red;
	wire	[5:0]	w_lcd_green;
	wire	[5:0]	w_lcd_blue;

	assign w_req		= 1'b0;
	assign w_wr			= 1'b0;

	// --------------------------------------------------------------------
	//	OUTPUT Assignment
	// --------------------------------------------------------------------
	assign w_n_reset	= ff_reset[6];

	assign sd_dat2		= ~ff_led[0];
	assign sd_dat3		= ~ff_led[1];

//	assign w_is_output	= 1'd0;			// *************************
//	assign w_o_data		= 8'd0;			// *************************

//	assign td			= w_is_output   ? w_o_data : 8'hZZ;
	assign td			= { 4'd0, ff_led, ff_led };
	assign tdir			= w_is_output;
	assign twait		= ff_wait[4];	// | w_srom_busy;

	always @( posedge clk ) begin
		ff_reset[5:0]	<= { ff_reset[4:0], 1'b1 };	//n_treset };
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

	// --------------------------------------------------------------------
	//	PLL 3.579545MHz --> 42.95454MHz
	// --------------------------------------------------------------------
	Gowin_PLL u_pll (
		.clkout				( clk						),		// output		108MHz
		.clkoutp			( clk_sdram					),		// output		108MHz with 180degree phase shifted.
		.clkin				( clk27m					)		// input		27MHz
	);

	always @( posedge clk ) begin
		if( !w_n_reset ) begin
			ff_count <= 'd0;
		end
		else if( ff_count == 'd53999999 ) begin
			ff_count <= 'd0;
		end
		else begin
			ff_count <= ff_count + 'd1;
		end
	end

	always @( posedge clk ) begin
		if( !w_n_reset ) begin
			ff_led <= 'd0;
		end
		else if( ff_count == 'd53999999 ) begin
			ff_led <= ff_led + 'd1;
		end
	end

	// --------------------------------------------------------------------
	//	SDRAM
	// --------------------------------------------------------------------
	ip_sdram u_sdram (
		.n_reset			( w_n_reset					),
		.clk				( clk						),
		.clk_sdram			( clk_sdram					),
		.rd_n				( w_sdram_read_n			),
		.wr_n				( w_sdram_write_n			),
		.busy				( w_sdram_busy				),
		.address			( w_sdram_address			),
		.wdata				( w_sdram_wdata				),
		.rdata				( w_sdram_rdata				),
		.rdata_en			( w_sdram_rdata_en			),
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

	// --------------------------------------------------------------------
	//	V9958 clone
	// --------------------------------------------------------------------
	VDP u_v9958 (
		.CLK				( clk						),	// IN	STD_LOGIC;
		.RESET				( !w_n_reset				),	// IN	STD_LOGIC;
		.REQ				( w_req						),	// IN	STD_LOGIC;
		.ACK				( w_ack						),	// OUT	STD_LOGIC;
		.WRT				( w_wr						),	// IN	STD_LOGIC;
		.ADR				( w_ta						),	// IN	STD_LOGIC_VECTOR(  1 DOWNTO 0 );
		.DBI				( 							),	// OUT	STD_LOGIC_VECTOR(  7 DOWNTO 0 );
		.DBO				( 8'd0						),	// IN	STD_LOGIC_VECTOR(  7 DOWNTO 0 );
		.INT_N				( 							),	// OUT	STD_LOGIC;
		.PRAMOE_N			( w_sdram_read_n			),	// OUT	STD_LOGIC;
		.PRAMWE_N			( w_sdram_write_n			),	// OUT	STD_LOGIC;
		.PRAMADR			( w_sdram_address			),	// OUT	STD_LOGIC_VECTOR( 16 DOWNTO 0 );
		.PRAMDBI			( w_sdram_rdata				),	// IN	STD_LOGIC_VECTOR( 15 DOWNTO 0 );
		.PRAMDBO			( w_sdram_wdata				),	// OUT	STD_LOGIC_VECTOR(  7 DOWNTO 0 );
		.VDPSPEEDMODE		( 1'b0						),	// IN	STD_LOGIC;
		.RATIOMODE			( 3'b000					),	// IN	STD_LOGIC_VECTOR(  2 DOWNTO 0 );
		.CENTERYJK_R25_N	( 1'b1						),	// IN	STD_LOGIC;
		.PVIDEOR			( w_lcd_red					),	// OUT	STD_LOGIC_VECTOR(  5 DOWNTO 0 );
		.PVIDEOG			( w_lcd_green				),	// OUT	STD_LOGIC_VECTOR(  5 DOWNTO 0 );
		.PVIDEOB			( w_lcd_blue				),	// OUT	STD_LOGIC_VECTOR(  5 DOWNTO 0 );
		.PVIDEOHS_N			( lcd_hsync					),	// OUT	STD_LOGIC;
		.PVIDEOVS_N			( lcd_vsync					),	// OUT	STD_LOGIC;
		.PVIDEOCS_N			( 							),	// OUT	STD_LOGIC;
		.PVIDEODHCLK		( 							),	// OUT	STD_LOGIC;
		.PVIDEODLCLK		( 							),	// OUT	STD_LOGIC;
		.BLANK_O			( 							),	// OUT	STD_LOGIC;
		.DISPRESO			( 1'b1						),	// IN	STD_LOGIC;
		.NTSC_PAL_TYPE		( 1'b1						),	// IN	STD_LOGIC;
		.FORCED_V_MODE		( 1'b0						),	// IN	STD_LOGIC;
		.LEGACY_VGA			( 1'b0						),	// IN	STD_LOGIC;
		.VDP_ID				( c_vdpid					),	// IN	STD_LOGIC_VECTOR(  4 DOWNTO 0 );
		.OFFSET_Y			( c_offset_y				)	// IN	STD_LOGIC_VECTOR(  6 DOWNTO 0 )
    );

	assign lcd_red		= w_lcd_red[5:1];
	assign lcd_green	= w_lcd_green;
	assign lcd_blue		= w_lcd_blue[5:1];
	assign lcd_bl		= 1'b1;
endmodule

`default_nettype wire
