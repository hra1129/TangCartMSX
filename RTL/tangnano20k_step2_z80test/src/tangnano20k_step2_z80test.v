// -----------------------------------------------------------------------------
//	tangnano20k_step2_z80test.v
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

module tangnano20k_step2_z80test (
	input			clk27m,			//	clk27m		PIN04_SYS_CLK		(27MHz)
	input	[1:0]	button,			//	button[0]	PIN88_MODE0_KEY1
									//	button[1]	PIN87_MODE1_KEY2
	output			uart_tx			//	uart_tx		PIN69_SYS_TX
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
	wire	[15:0]	w_a;
	wire	[7:0]	d;
	wire			w_rom_cs_n;
	wire	[7:0]	w_rom_q;
	wire			w_rom_q_en;
	wire			w_ram_cs_n;
	wire	[7:0]	w_ram_q;
	wire			w_ram_q_en;
	wire	[7:0]	w_uart_q;
	wire			w_uart_q_en;
	wire			w_address_swap;

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
		.address_swap	( w_address_swap),
		.uart_tx		( uart_tx		)
	);

	assign w_a	= w_address_swap ? { a[15], ~a[14], a[13:0] }: a;

	// --------------------------------------------------------------------
	//	ROM
	// --------------------------------------------------------------------
	ip_hello_world_rom u_rom (
		.clk			( clk			),
		.n_cs			( w_rom_cs_n	),
		.n_rd			( rd_n			),
		.address		( w_a[13:0]		),
		.rdata			( w_rom_q		),
		.rdata_en		( w_rom_q_en	)
	);

	assign w_rom_cs_n	= ( w_a[15:14] == 2'b00 ) ? mreq_n : 1'b1;

	// --------------------------------------------------------------------
	//	RAM
	// --------------------------------------------------------------------
	ip_ram u_ram (
		.clk			( clk			),
		.n_cs			( w_ram_cs_n	),
		.n_wr			( wr_n			),
		.n_rd			( rd_n			),
		.address		( w_a[13:0]		),
		.wdata			( d				),
		.rdata			( w_ram_q		),
		.rdata_en		( w_ram_q_en	)
	);

	assign w_ram_cs_n	= ( w_a[15:14] == 2'b01 ) ? mreq_n : 1'b1;

endmodule
