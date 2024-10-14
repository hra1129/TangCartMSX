// -----------------------------------------------------------------------------
//	Test of top entity
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
//		Pulse wave modulation
// -----------------------------------------------------------------------------

module tb ();
	localparam		clk_base	= 1_000_000_000/87_750;	//	ps
	//	MSX Cartridge connector
	reg				clk;			//	PIN04_SYS_CLK:
	reg				n_treset;		//	PIN85_SDIO_D1
//	reg				tclock;			//	PIN80_SDIO_D2: 3.579454MHz from MSX Ç±Ç±Ç≈ó«Ç¢ÇÃÇ©ÅH
	reg				n_ce;			//	PIN55_I2S_LRCK
	reg				n_twr;			//	PIN56_I2S_BCLK
	reg				n_trd;			//	PIN54_I2S_DIN
	reg		[1:0]	ta;				//	PIN73_HSPI_DIN2: ta[0]
									//	PIN74_HSPI_DIN3: ta[1]
	wire			tdir;			//	PIN75_HSPI_DIR
	wire	[7:0]	td;				//	PIN17_SYS_LED2: td[0]
									//	PIN20_SYS_LED5: td[1]
									//	PIN19_SYS_LED4: td[2]
									//	PIN18_SYS_LED3: td[3]
									//	PIN72_HSPI_DIN1: td[4]
									//	PIN71_HSPI_DIN0: td[5]
									//	PIN53_EDIO_CLK: td[6]
									//	PIN52_EDIO_DAT: td[7]
	reg		[1:0]	keys;			//	PIN88_MODE0_KEY1: keys[0]
									//	PIN87_MODE1_KEY2: keys[1]
	wire			twait;			//	PIN76_HSPI_DAT:

//	//	UART
//	wire			uart_tx;		//	PIN69_SYS_TX

	//	LED
	wire			sd_dat2;		//	PIN80_SDIO_D2
	wire			sd_dat3;		//	PIN81_SDIO_D3

	//	VGA wire
	wire			lcd_clk;		//	PIN77
	wire			lcd_de;			//	PIN48
	wire			lcd_hsync;		//	PIN25
	wire			lcd_vsync;		//	PIN26
	wire	[4:0]	lcd_red;		//	PIN38, PIN39, PIN40, PIN41, PIN42
	wire	[5:0]	lcd_green;		//	PIN32, PIN33, PIN34, PIN35, PIN36, PIN37
	wire	[4:0]	lcd_blue;		//	PIN27, PIN28, PIN29, PIN30, PIN31
	wire			lcd_bl;			//	PIN49

	//	SDRAM
	wire			O_sdram_clk;	//	Internal
	wire			O_sdram_cke;	//	Internal
	wire			O_sdram_cs_n;	//	Internal
	wire			O_sdram_cas_n;	//	Internal
	wire			O_sdram_ras_n;	//	Internal
	wire			O_sdram_wen_n;	//	Internal
	wire	[31:0]	IO_sdram_dq;	//	Internal
	wire	[10:0]	O_sdram_addr;	//	Internal
	wire	[1:0]	O_sdram_ba;		//	Internal
	wire	[3:0]	O_sdram_dqm;	//	Internal

	// --------------------------------------------------------------------
	//	DUT
	// --------------------------------------------------------------------
	tang20cart_msx u_dut (
		.clk27m					( clk					),
		.n_treset				( n_treset				),
		.n_ce					( n_ce					),
		.n_twr					( n_twr					),
		.n_trd					( n_trd					),
		.ta						( ta					),
		.tdir					( tdir					),
		.td						( td					),
		.keys					( keys					),
		.twait					( twait					),
		.sd_dat2				( sd_dat2				),
		.sd_dat3				( sd_dat3				),
		.lcd_clk				( lcd_clk				),
		.lcd_de					( lcd_de				),
		.lcd_hsync				( lcd_hsync				),
		.lcd_vsync				( lcd_vsync				),
		.lcd_red				( lcd_red				),
		.lcd_green				( lcd_green				),
		.lcd_blue				( lcd_blue				),
		.lcd_bl					( lcd_bl				),
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

	// --------------------------------------------------------------------
	mt48lc2m32b2 u_sdram (
		.Dq						( IO_sdram_dq			), 
		.Addr					( O_sdram_addr			), 
		.Ba						( O_sdram_ba			), 
		.Clk					( O_sdram_clk			), 
		.Cke					( O_sdram_cke			), 
		.Cs_n					( O_sdram_cs_n			), 
		.Ras_n					( O_sdram_ras_n			), 
		.Cas_n					( O_sdram_cas_n			), 
		.We_n					( O_sdram_wen_n			), 
		.Dqm					( O_sdram_dqm			)
	);

	// --------------------------------------------------------------------
	//	clock
	// --------------------------------------------------------------------
	always #(clk_base/2) begin
		clk <= ~clk;
	end

	// --------------------------------------------------------------------
	//	Test bench
	// --------------------------------------------------------------------
	initial begin
		n_treset			= 0;
		clk					= 0;
		n_ce				= 1;
		n_twr				= 1;
		n_trd				= 1;
		ta					= 2'b00;
		keys				= 2'b00;

		@( negedge clk );
		@( negedge clk );
		@( posedge clk );

		n_treset		= 1;
		repeat( 10000 ) @( posedge clk );

		keys[0]				= 1'b1;
		@( posedge clk );

		keys[0]				= 1'b0;
		@( posedge clk );

		repeat( 1368 * 2500 ) @( posedge clk );

		$finish;
	end
endmodule
