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
	localparam	clk_base	= 1_000_000_000/85_909;	//	ps
	int				test_no;

	reg				clk;
	reg		[1:0]	button;
	wire			lcd_clk;		//	PIN77
	wire			lcd_de;			//	PIN48
	wire			lcd_hsync;		//	PIN25
	wire			lcd_vsync;		//	PIN26
	wire	[4:0]	lcd_red;		//	PIN38, PIN39, PIN40, PIN41, PIN42
	wire	[5:0]	lcd_green;		//	PIN32, PIN33, PIN34, PIN35, PIN36, PIN37
	wire	[4:0]	lcd_blue;		//	PIN27, PIN28, PIN29, PIN30, PIN31
	wire			lcd_bl;			//	PIN49
	reg				spi_cs_n;		//	PIN79
	reg				spi_clk;		//	PIN73
	reg				spi_mosi;		//	PIN74
	wire			spi_miso;		//	PIN75
	wire			uart_tx;		//	uart_tx		PIN69_SYS_TX
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
	tangnano20k_step4 u_dut (
		.clk27m				( 					),
		.clk3_579m			( clk				),
		.button				( button			),
		.lcd_clk			( lcd_clk			),
		.lcd_de				( lcd_de			),
		.lcd_hsync			( lcd_hsync			),
		.lcd_vsync			( lcd_vsync			),
		.lcd_red			( lcd_red			),
		.lcd_green			( lcd_green			),
		.lcd_blue			( lcd_blue			),
		.lcd_bl				( lcd_bl			),
		.spi_cs_n			( spi_cs_n			),
		.spi_clk			( spi_clk			),
		.spi_mosi			( spi_mosi			),
		.spi_miso			( spi_miso			),
		.uart_tx			( uart_tx			),
		.O_sdram_clk		( O_sdram_clk		),
		.O_sdram_cke		( O_sdram_cke		),
		.O_sdram_cs_n		( O_sdram_cs_n		),
		.O_sdram_cas_n		( O_sdram_cas_n		),
		.O_sdram_ras_n		( O_sdram_ras_n		),
		.O_sdram_wen_n		( O_sdram_wen_n		),
		.IO_sdram_dq		( IO_sdram_dq		),
		.O_sdram_addr		( O_sdram_addr		),
		.O_sdram_ba			( O_sdram_ba		),
		.O_sdram_dqm		( O_sdram_dqm		)
	);

	// --------------------------------------------------------------------
//	mt48lc2m32b2 u_sdram (
//		.Dq					( IO_sdram_dq		), 
//		.Addr				( O_sdram_addr		), 
//		.Ba					( O_sdram_ba		), 
//		.Clk				( O_sdram_clk		), 
//		.Cke				( O_sdram_cke		), 
//		.Cs_n				( O_sdram_cs_n		), 
//		.Ras_n				( O_sdram_ras_n		), 
//		.Cas_n				( O_sdram_cas_n		), 
//		.We_n				( O_sdram_wen_n		), 
//		.Dqm				( O_sdram_dqm		)
//	);

	// --------------------------------------------------------------------
	//	clock
	// --------------------------------------------------------------------
	always #(clk_base/2) begin
		clk <= ~clk;				//	86.4MHz
	end

	// --------------------------------------------------------------------
	//	Test bench
	// --------------------------------------------------------------------
	initial begin
		clk				= 1;
		button			= 0;
		spi_cs_n		= 1;
		spi_clk			= 1;
		spi_mosi		= 1;
		repeat( 1000 ) @( posedge clk );

		button[0]		= 1;
		repeat( 50 ) @( posedge clk );
		forever begin
			@( posedge clk );
		end
		$finish;
	end
endmodule
