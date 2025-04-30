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
	localparam	sclk_base	= 1_000_000_000/30_000;	//	ps
	int				test_no;

	reg				clk;
	reg				sclk;
	reg		[1:0]	button;
	wire			halt_n;
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
	wire	[5:0]	ssg_ioa;		//	PIN20, PIN19, PIN18, PIN17, PIN16, PIN15
	wire	[2:0]	ssg_iob;		//	PIN71, PIN53, PIN52

	reg				n_cs;
	reg				n_rd;
	reg		[13:0]	address;
	wire	[7:0]	rdata;
	wire			rdata_en;

	int				i, j;
	int				fd;
	reg		[7:0]	read_data;
	reg		[7:0]	write_data;

	// --------------------------------------------------------------------
	//	DUT
	// --------------------------------------------------------------------
	tangnano20k_step9 u_dut (
		.clk27m				( 					),
		.clk3_579m			( clk				),
		.button				( button			),
		.halt_n				( halt_n			),
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
		.ssg_ioa			( ssg_ioa			),
		.ssg_iob			( ssg_iob			),
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
	//	Dummy ROM image
	// --------------------------------------------------------------------
	ip_hello_world_rom u_rom (
		.clk				( clk				),
		.n_cs				( n_cs				),
		.n_rd				( n_rd				),
		.address			( address			),
		.rdata				( rdata				),
		.rdata_en			( rdata_en			)
	);

	// --------------------------------------------------------------------
	//	clock
	// --------------------------------------------------------------------
	always #(clk_base/2) begin
		clk <= ~clk;				//	85.90908MHz
	end

	always #(sclk_base/2) begin
		sclk <= ~sclk;				//	30MHz
	end

	// --------------------------------------------------------------------
	task get_rom(
		input	[13:0]	a,
		output	[7:0]	d
	);
		address	<= a;
		n_rd	<= 1'b0;
		@( posedge clk );

		n_rd	<= 1'b1;
		while( !rdata_en ) begin
			@( posedge clk );
		end
		d		<= rdata;
		@( posedge clk );
	endtask: get_rom

	// --------------------------------------------------------------------
	task send_byte(
		input	[7:0]	wdata,
		output	[7:0]	rdata
	);
		int i;

		for( i = 0; i < 8; i = i + 1 ) begin
			@( posedge sclk );
			spi_clk		<= 1'b0;
			@( posedge sclk );
			spi_mosi	<= wdata[7-i];
			@( posedge sclk );
			spi_clk		<= 1'b1;
			@( posedge sclk );
			rdata[7-i]	<= spi_miso;
		end
		@( posedge sclk );
		spi_clk		<= 1'b0;
		@( posedge sclk );
		spi_clk		<= 1'b0;
		@( posedge sclk );
	endtask: send_byte

	// --------------------------------------------------------------------
	//	Test bench
	// --------------------------------------------------------------------
	initial begin
		clk				= 1;
		sclk			= 1;
		button			= 0;
		spi_cs_n		= 1;
		spi_clk			= 1;
		spi_mosi		= 1;
		n_cs			= 0;
		n_rd			= 1;
		repeat( 1000 ) @( posedge clk );

		button[0]		= 1;
		repeat( 50 ) @( posedge clk );

		// --------------------------------------------------------------------
		//	Wait connection
		// --------------------------------------------------------------------
		$display( "Wait connection ---------------" );
		forever begin
			spi_cs_n	= 0;
			@( posedge clk );
			send_byte( 8'h00, read_data );
			@( posedge clk );
			spi_cs_n	= 1;
			@( posedge clk );
			if( read_data == 8'hA5 ) begin
				break;
			end
			@( posedge clk );
		end
		$display( "  Connection OK" );
		@( posedge clk );

		// --------------------------------------------------------------------
		//	Initialize key matrix
		// --------------------------------------------------------------------
		$display( "Initialize key matrix ---------" );
		for( i = 0; i < 16; i++ ) begin
			$display( "  Y[%d] = 0x%02X", i, 8'hFF );
			spi_cs_n	= 0;
			@( posedge clk );
			send_byte( 8'h03, read_data );
			@( posedge clk );
			send_byte( i, read_data );				//	Y
			@( posedge clk );
			send_byte( 8'hFF, read_data );			//	X
			@( posedge clk );
			spi_cs_n	= 1;
			@( posedge clk );
			@( posedge clk );
			@( posedge clk );
		end

		// --------------------------------------------------------------------
		//	Wait SDRAM ready
		// --------------------------------------------------------------------
		$display( "Wait SDRAM ready --------------" );
		forever begin
			spi_cs_n	= 0;
			@( posedge clk );
			send_byte( 8'h05, read_data );
			@( posedge clk );
			send_byte( 8'h00, read_data );			//	N/A
			@( posedge clk );
			spi_cs_n	= 1;
			@( posedge clk );
			if( read_data[0] == 1'b0 ) begin
				break;
			end
			@( posedge clk );
		end
		$display( "  SDRAM Ready" );
		@( posedge clk );

		// --------------------------------------------------------------------
		//	Send ROM image for SDRAM BANK0
		// --------------------------------------------------------------------
		$display( "Send MAIN-ROM --------------" );
		fd = $fopen( "hello_world.rom", "rb" );

		spi_cs_n	= 0;
		@( posedge clk );
		send_byte( 8'h04, read_data );
		assert( read_data == 8'hA5 );
		@( posedge clk );
		send_byte( 8'h08, read_data );			//	BANK = 08h
		assert( read_data == 8'hA5 );

		for( i = 0; i < 16384; i++ ) begin
			write_data = $fgetc( fd );
			send_byte( write_data, read_data );
			assert( read_data == 8'hA5 );
			@( posedge clk );
			$display( "MAIN-ROM1 Address: %04X", i );
		end
		spi_cs_n	= 1;
		repeat( 40 ) @( posedge clk );
		$fclose( fd );

		// --------------------------------------------------------------------
		//	Start CPU
		// --------------------------------------------------------------------
		$display( "Start CPU ---------------------" );
		spi_cs_n	= 0;
		@( posedge clk );
		send_byte( 8'h06, read_data );
		assert( read_data == 8'hA5 );
		@( posedge clk );
		spi_cs_n	= 1;
		repeat( 42 ) @( posedge clk );
		spi_cs_n	= 0;
		@( posedge clk );
		send_byte( 8'h02, read_data );
		assert( read_data == 8'hA5 );
		@( posedge clk );
		spi_cs_n	= 1;
		repeat( 40 ) @( posedge clk );

		for( j = 0; halt_n != 1'b0; j++ ) begin
			$display( "[%t] LINE#%2d", $realtime, j );
			repeat( 1368 * 2 ) @( posedge clk );
		end
		$finish;
	end
endmodule
