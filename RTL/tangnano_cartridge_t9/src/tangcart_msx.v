// -----------------------------------------------------------------------------
//	tangcart_msx.v
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
//		Tangnano9K Cartridge for MSX
// -----------------------------------------------------------------------------
module tangcart_msx (
	input			n_treset,
	input			tclock,
	input			n_tsltsl,
	input			n_tmerq,
	input			n_tiorq,
	input			n_twr,
	input			n_trd,
	input	[15:0]	ta,
	output			tdir,
	inout	[7:0]	td,
	output			tsnd,
	output	[5:0]	n_led,
	input	[1:0]	button,
	input	[6:0]	dip_sw,
	output			twait
);

`default_nettype none

	reg		[6:0]	ff_reset = 7'd0;
	reg		[4:0]	ff_wait = 5'b10000;
	wire			clk;
	reg		[4:0]	ff_1mhz;
	wire			w_1mhz;
	reg		[2:0]	ff_4mhz;
	wire			w_mclk_pcen_n;
	wire			w_n_reset;
	wire			w_is_output;
	wire	[7:0]	w_out_data;
	//	SCC
	wire	[7:0]	w_scc_data;
	wire			w_scc_data_en;
	wire	[10:0]	w_scc_out;
	//	OPLL
	wire	[15:0]	w_opll_out;
	//	SSG
	wire	[7:0]	w_ssg_data;
	wire			w_ssg_data_en;
	wire	[7:0]	w_ssg_out;
	//	sound generator
	reg		[16:0]	ff_sound;

	// --------------------------------------------------------------------
	//	OUTPUT Assignment
	// --------------------------------------------------------------------
	assign w_out_data	= w_scc_data_en ? w_scc_data : w_ssg_data;
	assign w_is_output	= w_scc_data_en | w_ssg_data_en;

	assign td			= w_is_output   ? w_out_data : 8'hZZ;
	assign tdir			= w_is_output;
	assign n_led		= 6'd0;

	// --------------------------------------------------------------------
	//	Reset and wait
	// --------------------------------------------------------------------
	assign w_n_reset	= ff_reset[6];
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

	// --------------------------------------------------------------------
	//	PLL 3.579545MHz --> 21.47727MHz
	// --------------------------------------------------------------------
	Gowin_PLL u_pll (
		.clkout				( clk						),		// output	21.47727MHz (x6)
		.clkin				( tclock					)		// input	 3.579454MHz
	);

	// --------------------------------------------------------------------
	//	w_mclk_pcen_n: 3.579545MHz timing pulse
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !w_n_reset ) begin
			ff_4mhz <= 3'd0;
		end
		else if( ff_4mhz == 3'd5 ) begin
			ff_4mhz <= 3'd0;
		end
		else begin
			ff_4mhz <= ff_4mhz + 3'd1;
		end
	end

	assign w_mclk_pcen_n	= (ff_4mhz == 3'd0) ? 1'b0: 1'b1;

	// --------------------------------------------------------------------
	//	SCC and MSX-MUSIC ROM
	// --------------------------------------------------------------------
	ip_ikascc_wrapper u_ikascc_wrapper (
		.n_reset			( w_n_reset					),
		.clk				( clk						),		//	21.47727MHz
		.mclk_pcen_n		( w_mclk_pcen_n				),
		.n_tsltsl			( n_tsltsl					),
		.n_trd				( n_trd						),
		.n_twr				( n_twr						),
		.ta					( ta						),
		.wdata				( td						),
		.rdata				( w_scc_data				),
		.rdata_en			( w_scc_data_en				),
		.sound_out			( w_scc_out					)
	);

	// --------------------------------------------------------------------
	//	OPLL
	// --------------------------------------------------------------------
	ip_ikaopll_wrapper #(
		.BUILT_IN_MODE		( 1							)		// 0: Cartridge mode, 1: Built in mode
	) u_ikaopll_wrapper (
		.n_reset			( w_n_reset					),
		.clk				( clk						),
		.mclkpcen_n			( w_mclk_pcen_n				),
		.n_ioreq			( n_tiorq					),
		.n_sltsl			( n_tsltsl					),
		.n_wr				( n_twr						),
		.address			( ta						),
		.wdata				( td						),
		.sound_out			( w_opll_out				)
	);

	// --------------------------------------------------------------------
	//	SSG
	// --------------------------------------------------------------------
	ssg_inst u_ssg (
		.n_reset			( w_n_reset					),
		.clk				( clk						),
		.n_ioreq			( n_tiorq					),
		.n_rd				( n_trd						),
		.n_wr				( n_twr						),
		.address			( ta						),
		.wdata				( td						),
		.rdata				( w_ssg_data				),
		.rdata_en			( w_ssg_data_en				),
		.sound_out			( w_ssg_out					)
	);

	// --------------------------------------------------------------------
	//	Sound
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !w_n_reset ) begin
			ff_sound <= 17'd0;
		end
		else begin
			ff_sound <= { w_scc_out[10], w_scc_out, 5'd0 } + { w_opll_out[15], w_opll_out } + { {4{w_ssg_out[7]}}, w_ssg_out, 5'd0 };
		end
	end

	ip_pwm u_pwm (
		.n_reset			( w_n_reset					),
		.clk				( clk						),		//	21.47727MHz
		.enable				( 1'b1						),
		.signal_level		( ff_sound					),
		.pwm_wave			( tsnd						)
	);
endmodule

`default_nettype wire
