// ------------------------------------------------------------------------------------------------
// Wave Table Sound
// Copyright 2021 t.hara
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
// ------------------------------------------------------------------------------------------------

module scc_tone_generator_5ch (
	input			nreset,					//	negative logic
	input			clk,
	input			enable,
	input	[2:0]	active,
	output	[4:0]	wave_address,
	output			wave_update,
	input	[11:0]	reg_frequency_count,
	input			reg_wave_reset,
	input			clear_counter_a,
	input			clear_counter_b,
	input			clear_counter_c,
	input			clear_counter_d,
	input			clear_counter_e,
	input			reg_wave_error_en
);
	wire	[4:0]	w_wave_address_in;
	wire	[4:0]	w_wave_address_out;
	reg		[4:0]	ff_wave_address_a;
	reg		[4:0]	ff_wave_address_b;
	reg		[4:0]	ff_wave_address_c;
	reg		[4:0]	ff_wave_address_d;
	reg		[4:0]	ff_wave_address_e;
	wire	[11:0]	w_frequency_count_in;
	wire	[11:0]	w_frequency_count_out;
	reg		[11:0]	ff_frequency_count_a;
	reg		[11:0]	ff_frequency_count_b;
	reg		[11:0]	ff_frequency_count_c;
	reg		[11:0]	ff_frequency_count_d;
	reg		[11:0]	ff_frequency_count_e;
	reg		[4:0]	ff_error_count_d;
	reg		[4:0]	ff_error_count_e;
	wire	[4:0]	w_error_count;
	wire			w_frequency_counter_end;
	wire	[5:0]	w_next_error_count;

	scc_selector #( 5 ) u_wave_address_selector (
		.active					( active					),
		.result					( w_wave_address_in			),
		.reg_a					( ff_wave_address_a			),
		.reg_b					( ff_wave_address_b			),
		.reg_c					( ff_wave_address_c			),
		.reg_d					( ff_wave_address_d			),
		.reg_e					( ff_wave_address_e			),
		.reg_f					( 5'd0						)
	);

	scc_selector #( 12 ) u_wave_frequency_counter_selector (
		.active					( active					),
		.result					( w_frequency_count_in		),
		.reg_a					( ff_frequency_count_a		),
		.reg_b					( ff_frequency_count_b		),
		.reg_c					( ff_frequency_count_c		),
		.reg_d					( ff_frequency_count_d		),
		.reg_e					( ff_frequency_count_e		),
		.reg_f					( 12'd0						)
	);

	// frequency counter ------------------------------------------------------
	assign w_frequency_counter_end	= ((w_frequency_count_in == reg_frequency_count) && (reg_frequency_count > 12'd8))? 1'b1 : 1'b0;
	assign w_frequency_count_out	= w_frequency_counter_end ? 12'd0 : (w_frequency_count_in + 12'd1);

	// wave memory address ----------------------------------------------------
	assign w_wave_address_out		= w_frequency_counter_end ? (w_wave_address_in + 5'd1) : w_wave_address_in;

	// output assignment ------------------------------------------------------
	assign wave_address				= w_wave_address_in;

	// error timming generator for Ch.D and Ch.E ------------------------------
	assign w_error_count			= (active[0] == 1'b1) ? ff_error_count_d : ff_error_count_e;
	assign w_next_error_count		= (reg_frequency_count[11:5] == 7'd0) ? ({ 1'b0, w_error_count } + { 1'b0, ~reg_frequency_count[4:0] }) :
									  (reg_frequency_count[0] == 1'b0)    ? ({ 1'b0, w_error_count } + { 1'b0, 5'd16 }) : 6'd0;
	assign wave_update				= ((active == 3'd3) || (active == 3'd4)) ? w_frequency_counter_end & (~reg_wave_error_en | ~w_next_error_count[5]) : w_frequency_counter_end;

	always @( negedge nreset or posedge clk ) begin
		if( !nreset ) begin
			ff_wave_address_a		<= 'd0;
			ff_frequency_count_a	<= 'd0;
		end
		else if( !enable ) begin
			//	hold
		end
		else if( clear_counter_a ) begin
			if( reg_wave_reset ) begin
				ff_wave_address_a		<= 'd0;
			end
			ff_frequency_count_a	<= 'd0;
		end
		else if( active == 3'd0 ) begin
			ff_wave_address_a		<= w_wave_address_out;
			ff_frequency_count_a	<= w_frequency_count_out;
		end
	end

	always @( negedge nreset or posedge clk ) begin
		if( !nreset ) begin
			ff_wave_address_b		<= 'd0;
			ff_frequency_count_b	<= 'd0;
		end
		else if( !enable ) begin
			//	hold
		end
		else if( clear_counter_b ) begin
			if( reg_wave_reset ) begin
				ff_wave_address_b		<= 'd0;
			end
			ff_frequency_count_b	<= 'd0;
		end
		else if( active == 3'd1 ) begin
			ff_wave_address_b		<= w_wave_address_out;
			ff_frequency_count_b	<= w_frequency_count_out;
		end
	end

	always @( negedge nreset or posedge clk ) begin
		if( !nreset ) begin
			ff_wave_address_c		<= 'd0;
			ff_frequency_count_c	<= 'd0;
		end
		else if( !enable ) begin
			//	hold
		end
		else if( clear_counter_c ) begin
			if( reg_wave_reset ) begin
				ff_wave_address_c		<= 'd0;
			end
			ff_frequency_count_c	<= 'd0;
		end
		else if( active == 3'd2 ) begin
			ff_wave_address_c		<= w_wave_address_out;
			ff_frequency_count_c	<= w_frequency_count_out;
		end
	end

	always @( negedge nreset or posedge clk ) begin
		if( !nreset ) begin
			ff_wave_address_d		<= 'd0;
			ff_frequency_count_d	<= 'd0;
			ff_error_count_d		<= 'd0;
		end
		else if( !enable ) begin
			//	hold
		end
		else if( clear_counter_d ) begin
			if( reg_wave_reset ) begin
				ff_wave_address_d		<= 'd0;
			end
			ff_frequency_count_d	<= 'd0;
		end
		else if( active == 3'd3 ) begin
			ff_wave_address_d		<= w_wave_address_out;
			ff_frequency_count_d	<= w_frequency_count_out;
			ff_error_count_d		<= w_next_error_count[4:0];
		end
	end

	always @( negedge nreset or posedge clk ) begin
		if( !nreset ) begin
			ff_wave_address_e		<= 'd0;
			ff_frequency_count_e	<= 'd0;
			ff_error_count_e		<= 'd0;
		end
		else if( !enable ) begin
			//	hold
		end
		else if( clear_counter_e ) begin
			if( reg_wave_reset ) begin
				ff_wave_address_e		<= 'd0;
			end
			ff_frequency_count_e	<= 'd0;
		end
		else if( active == 3'd4 ) begin
			ff_wave_address_e		<= w_wave_address_out;
			ff_frequency_count_e	<= w_frequency_count_out;
			ff_error_count_e		<= w_next_error_count[4:0];
		end
	end
endmodule
