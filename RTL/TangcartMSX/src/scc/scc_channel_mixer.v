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

module scc_channel_mixer (
	input			nreset,
	input			clk,
	input			enable,

	input	[2:0]	sram_id,				//	A...E
	input	[4:0]	sram_a,
	input	[7:0]	sram_d,
	input			sram_oe,
	input			sram_we,
	output	[7:0]	sram_q,
	output			sram_q_en,

	output	[2:0]	active,

	output	[10:0]	left_out,

	input			reg_scci_enable,
	input	[11:0]	reg_frequency_count0,
	input	[3:0]	reg_volume0,
	input			reg_enable0,
	input			reg_wave_reset,
	input			clear_counter_a0,
	input			clear_counter_b0,
	input			clear_counter_c0,
	input			clear_counter_d0,
	input			clear_counter_e0
);

	reg		[2:0]	ff_active;
	wire	[7:0]	w_sram_a0;
	wire	[7:0]	w_sram_q0;
	wire	[7:0]	w_channel0;
	wire	[7:0]	w_left_channel0;
	reg		[10:0]	ff_left_integ;
	reg		[10:0]	ff_left_out;

	reg				ff_active_delay;
	reg				ff_sram_q_en;

	wire	[4:0]	w_wave_address0;
	wire			w_sram_we0;
	wire			w_address_reset0;
	wire			w_wave_update0;
	reg				ff_wave_update0;
	reg		[7:0]	ff_wave_a0;
	reg		[7:0]	ff_wave_b0;
	reg		[7:0]	ff_wave_c0;
	reg		[7:0]	ff_wave_d0;
	reg		[7:0]	ff_wave_e0;
	wire	[7:0]	w_wave_q0;

	// ------------------------------------------------------------------------
	//	CPU SRAM ACCESS INTERFACE
	// ------------------------------------------------------------------------
	always @( negedge nreset or posedge clk ) begin
		if( !nreset ) begin
			ff_sram_q_en <= 1'b0;
		end
		else if( !enable ) begin
			//	hold
		end
		else if( sram_oe || sram_we ) begin
			ff_sram_q_en <= sram_oe;
		end
		else begin
			ff_sram_q_en <= 1'b0;
		end
	end

	assign sram_q_en	= ff_sram_q_en;
	assign sram_q		= w_sram_q0;

	// ------------------------------------------------------------------------
	always @( negedge nreset or posedge clk ) begin
		if( !nreset ) begin
			ff_active		<= 3'd0;
			ff_active_delay	<= 1'b0;
		end
		else if( !enable ) begin
			//	hold
		end
		else begin
			if( ff_active == 3'd5 ) begin
				ff_active		<= 3'd0;
				ff_active_delay	<= 1'b0;
			end
			else if( (sram_oe | sram_we) == 1'b1 ) begin
				ff_active_delay	<= 1'b1;
			end
			else if( ff_active_delay && ff_active == 3'd4 ) begin
				ff_active		<= 3'd0;
				ff_active_delay	<= 1'b0;
			end
			else begin
				ff_active		<= ff_active + 3'd1;
			end
		end
	end

	assign active			= ff_active;

	scc_tone_generator_5ch u_tone_generator_5ch (
		.nreset						( nreset						),
		.clk						( clk							),
		.enable						( enable						),
		.active						( ff_active						),
		.wave_address				( w_wave_address0				),
		.wave_update				( w_wave_update0				),
		.reg_frequency_count		( reg_frequency_count0			),
		.reg_wave_reset				( reg_wave_reset				),
		.clear_counter_a			( clear_counter_a0				),
		.clear_counter_b			( clear_counter_b0				),
		.clear_counter_c			( clear_counter_c0				),
		.clear_counter_d			( clear_counter_d0				),
		.clear_counter_e			( clear_counter_e0				),
		.reg_wave_error_en			( ~reg_scci_enable				)
	);

	assign w_sram_a0	= ( sram_oe || sram_we ) ? { sram_id, sram_a } : 
		(( ff_active[2] && (reg_scci_enable == 1'b0)) ? { 3'b011, w_wave_address0 } : { ff_active, w_wave_address0 });
	assign w_sram_we0	= ( sram_oe || sram_we ) ? (sram_we & enable) : 1'b0;

	always @( posedge clk ) begin
		if( !enable ) begin
			//	hold
		end
		else begin
			ff_wave_update0 <= w_wave_update0;
		end
	end

	always @( negedge nreset or posedge clk ) begin
		if( !nreset ) begin
			ff_wave_a0	<= 8'd0;
			ff_wave_b0	<= 8'd0;
			ff_wave_c0	<= 8'd0;
			ff_wave_d0	<= 8'd0;
			ff_wave_e0	<= 8'd0;
		end
		else if( !enable ) begin
			//	hold
		end
		else if( ff_wave_update0 ) begin
			case( ff_active )
			3'd1:	ff_wave_a0	<= w_sram_q0;
			3'd2:	ff_wave_b0	<= w_sram_q0;
			3'd3:	ff_wave_c0	<= w_sram_q0;
			3'd4:	ff_wave_d0	<= w_sram_q0;
			3'd5:	ff_wave_e0	<= w_sram_q0;
			endcase
		end
		else begin
			//	hold
		end
	end

	scc_ram u_ram00 (
		.clk			( clk				),
		.sram_we		( w_sram_we0		),		//	delay 0 clock
		.sram_a			( w_sram_a0			),		//	delay 0 clock
		.sram_d			( sram_d			),		//	delay 0 clock
		.sram_q			( w_sram_q0			)		//	delay 1 clock
	);

	assign w_wave_q0	= (ff_active == 3'd1) ? ff_wave_a0 :
						  (ff_active == 3'd2) ? ff_wave_b0 :
						  (ff_active == 3'd3) ? ff_wave_c0 :
						  (ff_active == 3'd4) ? ff_wave_d0 :
						  (ff_active == 3'd5) ? ff_wave_e0 : 8'd0;

	scc_channel_volume u_channel_volume0 (
		.clk			( clk				),
		.enable			( enable			),
		.sram_q			( w_wave_q0			),		//	delay 1 clock
		.channel		( w_channel0		),		//	delay 2 clock
		.reg_volume		( reg_volume0		)		//	delay 1 clock
	);

	//	delay 2 clock
	assign w_left_channel0		= reg_enable0 ? w_channel0 : 8'd0;

	always @( negedge nreset or posedge clk ) begin
		if( !nreset ) begin
			ff_left_integ		<= 11'd0;
		end
		else if( !enable ) begin
			//	hold
		end
		else if( (sram_oe | sram_we) == 1'b1 ) begin
			//	hold
		end
		else if( ff_active == 3'd1 ) begin
			ff_left_integ		<= 11'd0;
		end
		else begin
			ff_left_integ		<= ff_left_integ  + { 3'd0, ~w_left_channel0[7], w_left_channel0[6:0]  };
		end
	end

	//	delay 5 clock
	always @( negedge nreset or posedge clk ) begin
		if( !nreset ) begin
			ff_left_out			<= 11'd0;
		end
		else if( !enable ) begin
			//	hold
		end
		else if( ff_active == 3'd1 ) begin
			ff_left_out			<= ff_left_integ;
		end
		else begin
			//	hold
		end
	end

	assign left_out		= ff_left_out;
endmodule
