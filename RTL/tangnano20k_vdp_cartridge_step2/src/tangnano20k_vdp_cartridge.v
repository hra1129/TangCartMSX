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
	reg				ff_reset_n = 1'b0;
	reg				ff_wr;
	reg		[7:0]	ff_red;
	reg		[7:0]	ff_green;
	reg		[7:0]	ff_blue;
	reg		[1:0]	ff_button0 = 2'd0;
	reg		[1:0]	ff_button1 = 2'd0;
	wire			w_sending;

	assign slot_wait		= 1'b0;
	assign slot_intr		= 1'b0;

	always @( posedge clk14m ) begin
		ff_reset_n	<= 1'b1;
	end

	always @( posedge clk14m ) begin
		ff_button0	<= button;
		ff_button1	<= ff_button0;
	end

	// --------------------------------------------------------------------
	//	Button
	// --------------------------------------------------------------------
	always @( posedge clk14m or negedge ff_reset_n ) begin
		if( !ff_reset_n ) begin
			ff_wr		<= 1'b0;
			ff_red		<= 8'd0;
			ff_green	<= 8'd0;
			ff_blue		<= 8'd0;
		end
		else if( ff_button1[0] && !ff_button0[0] ) begin
			ff_wr		<= 1'b1;
			ff_red		<= 8'd100;
			ff_green	<= 8'd20;
			ff_blue		<= 8'd0;
		end
		else if( ff_button1[1] && !ff_button0[1] ) begin
			ff_wr		<= 1'b1;
			ff_red		<= 8'd0;
			ff_green	<= 8'd70;
			ff_blue		<= 8'd100;
		end
		else begin
			ff_wr		<= 1'b0;
			ff_red		<= 8'd0;
			ff_green	<= 8'd0;
			ff_blue		<= 8'd0;
		end
	end

	// --------------------------------------------------------------------
	//	FullColor Intelligent LED
	// --------------------------------------------------------------------
	ip_ws2812_led u_fullcolor_led (
		.reset_n		( ff_reset_n	),
		.clk			( clk14m		),
		.wr				( ff_wr			),
		.sending		( w_sending		),
		.red			( ff_red		),
		.green			( ff_green		),
		.blue			( ff_blue		),
		.ws2812_led		( ws2812_led	)
	);

endmodule
