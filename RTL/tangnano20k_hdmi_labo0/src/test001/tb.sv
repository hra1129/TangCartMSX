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
	localparam	clk_base	= 1_000_000_000/371_250;	//	ps
	int				test_no;

	reg				clk;				//	clk27m		PIN04_SYS_CLK		(27MHz)
	reg		[1:0]	button;				//	button[0]	PIN88_MODE0_KEY1
										//	button[1]	PIN87_MODE1_KEY2
	//	HDMI
	wire			tmds_clk_n;			//	PIN33
	wire			tmds_clk_p;			//	PIN34
	wire	[2:0]	tmds_d_n;			//	PIN39, PIN37, PIN25
	wire	[2:0]	tmds_d_p;			//	PIN40, PIN38, PIN36
	//	SDRAM
	wire			O_sdram_clk;		//	Internal
	wire			O_sdram_cke;		//	Internal
	wire			O_sdram_cs_n;		//	Internal
	wire			O_sdram_cas_n;		//	Internal
	wire			O_sdram_ras_n;		//	Internal
	wire			O_sdram_wen_n;		//	Internal
	wire	[31:0]	IO_sdram_dq;		//	Internal
	wire	[10:0]	O_sdram_addr;		//	Internal
	wire	[1:0]	O_sdram_ba;			//	Internal
	wire	[3:0]	O_sdram_dqm;		//	Internal

	// --------------------------------------------------------------------
	//	DUT
	// --------------------------------------------------------------------
	tangnano20k_hdmi_labo u_dut (
		.clk27m				( clk				),
		.button				( button			),
		.tmds_clk_n			( tmds_clk_n		),
		.tmds_clk_p			( tmds_clk_p		),
		.tmds_d_n			( tmds_d_n			),
		.tmds_d_p			( tmds_d_p			),
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
	mt48lc2m32b2 u_sdram (
		.Dq					( IO_sdram_dq		), 
		.Addr				( O_sdram_addr		), 
		.Ba					( O_sdram_ba		), 
		.Clk				( O_sdram_clk		), 
		.Cke				( O_sdram_cke		), 
		.Cs_n				( O_sdram_cs_n		), 
		.Ras_n				( O_sdram_ras_n		), 
		.Cas_n				( O_sdram_cas_n		), 
		.We_n				( O_sdram_wen_n		), 
		.Dqm				( O_sdram_dqm		)
	);

	// --------------------------------------------------------------------
	//	clock
	// --------------------------------------------------------------------
	always #(clk_base/2) begin
		clk <= ~clk;				//	371.25MHz
	end

	// --------------------------------------------------------------------
	//	Test bench
	// --------------------------------------------------------------------
	initial begin
		clk				= 1;
		button			= 0;
		repeat( 100 ) @( posedge clk );
		#300us
		button			= 1;
		repeat( 100000 ) @( posedge clk );
		button			= 0;
		repeat( 100000 ) @( posedge clk );
		button			= 1;
		repeat( 100000 ) @( posedge clk );
		button			= 0;
		repeat( 100000 ) @( posedge clk );
		$finish;
	end
endmodule
