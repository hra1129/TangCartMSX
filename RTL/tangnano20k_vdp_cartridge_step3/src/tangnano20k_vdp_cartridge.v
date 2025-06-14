// -----------------------------------------------------------------------------
//	tangnano20k_vdp_cartridge.v
//	Copyright (C)2025 Takayuki Hara (HRA!)
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

module tangnano20k_vdp_cartridge (
	input			clk,			//	PIN04		(27MHz)
	input			clk14m,			//	PIN80
	input			slot_reset_n,	//	PIN86
	input			slot_iorq_n,	//	PIN71
	input			slot_rd_n,		//	PIN15
	input			slot_wr_n,		//	PIN16
	output			slot_wait,		//	PIN53
	output			slot_intr,		//	PIN52
	output			slot_data_dir,	//	PIN19
	input	[7:0]	slot_a,			//	PIN17, 49, 48, 41, 42, 76, 31, 30
	inout	[7:0]	slot_d,			//	PIN73, 74, 75, 85, 77, 27, 28, 29
	output			busdir,			//	PIN72
	output			oe_n,			//	PIN20
	input			dipsw,			//	PIN18
	output			ws2812_led,		//	PIN79
	input	[1:0]	button,			//	PIN87, 88	KEY2, KEY1
	output			uart_tx			//	PIN69
);
	wire			pll_lock1;
	wire			pll_lock2;
	wire			clk21m;				//	21.47727MHz
	wire			clk42m;				//	42.95454MHz
	wire			clk85m;				//	85.90908MHz
	wire			clk215m;			//	214.7727MHz
	wire			reset_n;
	wire	[15:0]	bus_address;
	wire			bus_ioreq;
	wire			bus_write;
	wire			bus_valid;
	wire			bus_ready;
	wire	[7:0]	bus_wdata;
	wire	[7:0]	bus_rdata;
	wire			bus_rdata_en;
	wire			led_wr;
	wire	[7:0]	led_red;
	wire	[7:0]	led_green;
	wire	[7:0]	led_blue;

	assign slot_wait		= 1'b0;
	assign slot_intr		= 1'b0;
    assign oe_n             = 1'b0;
    assign busdir           = ( { slot_a[7:2], 2'd0 } == 8'h10 && !slot_iorq_n ) ? ~slot_rd_n: 1'b0;

	// --------------------------------------------------------------------
	//	clock
	// --------------------------------------------------------------------
	Gowin_rPLL u_pll (
		.clkout			( clk215m			),		//	output clkout	214.7727MHz
		.lock			( pll_lock1			),
		.clkin			( clk14m			)		//	input clkin		14.31818MHz
	);

	Gowin_rPLL2 u_pll2 (
		.clkout			( clk85m			),		//	output clkout	85.90908MHz
		.lock			( pll_lock2			),
		.clkin			( clk14m			)		//	input clkin		14.31818MHz
	);

	Gowin_CLKDIV u_clkdiv (
		.clkout			( clk42m			),		//	output clkout	42.95454MHz
		.hclkin			( clk215m			),		//	input hclkin	214.7727MHz
		.resetn			( pll_lock1			)		//	input resetn
	);

	// --------------------------------------------------------------------
	//	FullColor Intelligent LED
	// --------------------------------------------------------------------
	msx_slot u_msx_slot (
		.clk42m				( clk42m					),
		.reset_n			( reset_n					),
		.initial_busy		( 1'b0						),
		.p_slot_reset_n		( slot_reset_n				),
		.p_slot_sltsl_n		( 1'b1						),
		.p_slot_mreq_n		( 1'b1						),
		.p_slot_ioreq_n		( slot_iorq_n				),
		.p_slot_wr_n		( slot_wr_n					),
		.p_slot_rd_n		( slot_rd_n					),
		.p_slot_address		( { 8'd0, slot_a }			),
		.p_slot_data		( slot_d					),
		.p_slot_data_dir	( slot_data_dir				),
		.p_slot_int			( slot_int					),
		.p_slot_wait		( slot_wait					),
		.int_n				( 1'b1						),
		.bus_address		( bus_address				),
		.bus_memreq			( 							),
		.bus_ioreq			( bus_ioreq					),
		.bus_write			( bus_write					),
		.bus_valid			( bus_valid					),
		.bus_ready			( bus_ready					),
		.bus_wdata			( bus_wdata					),
		.bus_rdata			( bus_rdata					),
		.bus_rdata_en		( bus_rdata_en				)
	);

	// --------------------------------------------------------------------
	//	GPIO
	// --------------------------------------------------------------------
	ip_gpio u_gpio (
		.reset_n			( reset_n					),
		.clk				( clk42m					),
		.bus_address		( bus_address[7:0]			),
		.bus_ioreq			( bus_ioreq					),
		.bus_write			( bus_write					),
		.bus_valid			( bus_valid					),
		.bus_ready			( bus_ready					),
		.bus_wdata			( bus_wdata					),
		.bus_rdata			( bus_rdata					),
		.bus_rdata_en		( bus_rdata_en				),
		.led_wr				( led_wr					),
		.led_red			( led_red					),
		.led_green			( led_green					),
		.led_blue			( led_blue					)
	);

	// --------------------------------------------------------------------
	//	FullColor Intelligent LED
	// --------------------------------------------------------------------
	ip_ws2812_led u_fullcolor_led (
		.reset_n			( reset_n					),
		.clk				( clk42m					),
		.wr					( led_wr					),
		.sending			( 							),
		.red				( led_red					),
		.green				( led_green					),
		.blue				( led_blue					),
		.ws2812_led			( ws2812_led				)
	);

endmodule
