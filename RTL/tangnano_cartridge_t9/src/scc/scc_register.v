// ------------------------------------------------------------------------------------------------
// Wave Table Sound
// Copyright 2021-2024 t.hara
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

module scc_register (
	input				nreset,					//	negative logic
	input				clk,
	input				enable,					//	21.47727MHz
	input				wr,
	input				rd,
	input				memory,
	output				ready,
	input		[12:0]	address,
	input		[7:0]	wrdata,
	output		[7:0]	rddata,
	input				scc_en,
	input				scci_en,

	input		[2:0]	active,

	output reg	[2:0]	sram_id,				//	A...E
	output reg	[4:0]	sram_a,
	output reg	[7:0]	sram_d,
	output reg			sram_oe,
	output reg			sram_we,
	input		[7:0]	sram_q,
	input				sram_q_en,

	input				reg_scci_enable,
	output		[11:0]	reg_frequency_count0,
	output		[3:0]	reg_volume0,
	output				reg_enable0,
	output				reg_wave_reset,
	output				clear_counter_a0,
	output				clear_counter_b0,
	output				clear_counter_c0,
	output				clear_counter_d0,
	output				clear_counter_e0
);
	reg				reg_ram_mode0;
	reg				reg_ram_mode1;
	reg				reg_ram_mode2;
	reg				reg_ram_mode3;

	reg		[11:0]	ff_reg_frequency_count_a0;
	reg		[3:0]	ff_reg_volume_a0;
	reg				ff_reg_enable_a0;
	reg				ff_clear_counter_a0;

	reg		[11:0]	ff_reg_frequency_count_b0;
	reg		[3:0]	ff_reg_volume_b0;
	reg				ff_reg_enable_b0;
	reg				ff_clear_counter_b0;

	reg		[11:0]	ff_reg_frequency_count_c0;
	reg		[3:0]	ff_reg_volume_c0;
	reg				ff_reg_enable_c0;
	reg				ff_clear_counter_c0;

	reg		[11:0]	ff_reg_frequency_count_d0;
	reg		[3:0]	ff_reg_volume_d0;
	reg				ff_reg_enable_d0;
	reg				ff_clear_counter_d0;

	reg		[11:0]	ff_reg_frequency_count_e0;
	reg		[3:0]	ff_reg_volume_e0;
	reg				ff_reg_enable_e0;
	reg				ff_clear_counter_e0;

	reg		[7:0]	ff_rddata;
	reg				ff_ready;
	reg				ff_wave_reset;

	// Wave memory ------------------------------------------------------------
	always @( posedge clk ) begin
		if( !nreset ) begin
			sram_id	<= 3'd0;
			sram_a	<= 5'd0;
			sram_d	<= 8'd0;
			sram_oe	<= 1'b0;
			sram_we	<= 1'b0;
		end
		else if( memory && scc_en && (address[12:7] == 6'b1_1000_0) ) begin
			//	9800-987Fh : {100} 1 1000 0XXX XXXX
			sram_id		<= { 1'b0, address[6:5] };	//	Channel A, B, C or D
			sram_a		<= address[4:0];
			sram_oe		<= rd;
			sram_we		<= wr;
			sram_d		<= wrdata;
		end
		else if( memory && scc_en && (address[12:5] == 8'b1_1000_101) ) begin
			//	98A0-98BFh : {100} 1 1000 101X XXXX ReadOnly
			if( reg_scci_enable ) begin
				sram_id		<= 3'd4;					//	Channel E
			end
			else begin
				sram_id		<= 3'd3;					//	Channel D
			end
			sram_a		<= address[4:0];
			sram_oe		<= rd;
			sram_we		<= 1'b0;
			sram_d		<= wrdata;
		end
		else if( memory && scci_en && (address[10:8] == 3'b000) && ((address[7:5] == 3'b100) || !address[7]) ) begin
			//	B800-B87Fh : {101} 1 1000 0XXX XXXX
			//	B880-B89Fh : {101} 1 1000 100X XXXX
			sram_id		<= address[7:5];
			sram_a		<= address[4:0];
			sram_oe		<= rd;
			sram_we		<= wr;
			sram_d		<= wrdata;
		end
		else if( enable ) begin
			sram_oe		<= 1'b0;
			sram_we		<= 1'b0;
		end
	end

	// Frequency reset --------------------------------------------------------
	assign w_clear_counter_a0 = (scc_en  && (address[7:1] == 7'b1000_000)) ? 1'b1 :
	                            (scci_en && (address[7:1] == 7'b1010_000)) ? 1'b1 : 1'b0;
	assign w_clear_counter_b0 = (scc_en  && (address[7:1] == 7'b1000_001)) ? 1'b1 :
	                            (scci_en && (address[7:1] == 7'b1010_001)) ? 1'b1 : 1'b0;
	assign w_clear_counter_c0 = (scc_en  && (address[7:1] == 7'b1000_010)) ? 1'b1 :
	                            (scci_en && (address[7:1] == 7'b1010_010)) ? 1'b1 : 1'b0;
	assign w_clear_counter_d0 = (scc_en  && (address[7:1] == 7'b1000_011)) ? 1'b1 :
	                            (scci_en && (address[7:1] == 7'b1010_011)) ? 1'b1 : 1'b0;
	assign w_clear_counter_e0 = (scc_en  && (address[7:1] == 7'b1000_100)) ? 1'b1 :
	                            (scci_en && (address[7:1] == 7'b1010_100)) ? 1'b1 : 1'b0;

	always @( posedge clk ) begin
		if( !nreset ) begin
			ff_clear_counter_a0 <= 1'b0;
			ff_clear_counter_b0 <= 1'b0;
			ff_clear_counter_c0 <= 1'b0;
			ff_clear_counter_d0 <= 1'b0;
			ff_clear_counter_e0 <= 1'b0;
		end
		else if( memory && wr && enable ) begin
			ff_clear_counter_a0 <= w_clear_counter_a0;
			ff_clear_counter_b0 <= w_clear_counter_b0;
			ff_clear_counter_c0 <= w_clear_counter_c0;
			ff_clear_counter_d0 <= w_clear_counter_d0;
			ff_clear_counter_e0 <= w_clear_counter_e0;
		end
		else begin
			ff_clear_counter_a0 <= ff_clear_counter_a0 | w_clear_counter_a0;
			ff_clear_counter_b0 <= ff_clear_counter_b0 | w_clear_counter_b0;
			ff_clear_counter_c0 <= ff_clear_counter_c0 | w_clear_counter_c0;
			ff_clear_counter_d0 <= ff_clear_counter_d0 | w_clear_counter_d0;
			ff_clear_counter_e0 <= ff_clear_counter_e0 | w_clear_counter_e0;
		end
	end

	assign clear_counter_a0 = ff_clear_counter_a0;
	assign clear_counter_b0 = ff_clear_counter_b0;
	assign clear_counter_c0 = ff_clear_counter_c0;
	assign clear_counter_d0 = ff_clear_counter_d0;
	assign clear_counter_e0 = ff_clear_counter_e0;

	// Control registers ------------------------------------------------------
	always @( posedge clk ) begin
		if( !nreset ) begin
			ff_reg_volume_a0			<= 'd0;
			ff_reg_enable_a0			<= 'd0;
			ff_reg_frequency_count_a0	<= 'd0;

			ff_reg_volume_b0			<= 'd0;
			ff_reg_enable_b0			<= 'd0;
			ff_reg_frequency_count_b0	<= 'd0;

			ff_reg_volume_c0			<= 'd0;
			ff_reg_enable_c0			<= 'd0;
			ff_reg_frequency_count_c0	<= 'd0;

			ff_reg_volume_d0			<= 'd0;
			ff_reg_enable_d0			<= 'd0;
			ff_reg_frequency_count_d0	<= 'd0;

			ff_reg_volume_e0			<= 'd0;
			ff_reg_enable_e0			<= 'd0;
			ff_reg_frequency_count_e0	<= 'd0;

			ff_wave_reset				<= 1'b0;
		end
		else if( wr ) begin
			if( memory && scc_en && (address[7:4] == 4'h8) ) begin
				case( address[3:0] )
				4'h0:		ff_reg_frequency_count_a0[ 7:0]	<= wrdata;
				4'h1:		ff_reg_frequency_count_a0[11:8]	<= wrdata[3:0];
				4'h2:		ff_reg_frequency_count_b0[ 7:0]	<= wrdata;
				4'h3:		ff_reg_frequency_count_b0[11:8]	<= wrdata[3:0];
				4'h4:		ff_reg_frequency_count_c0[ 7:0]	<= wrdata;
				4'h5:		ff_reg_frequency_count_c0[11:8]	<= wrdata[3:0];
				4'h6:		ff_reg_frequency_count_d0[ 7:0]	<= wrdata;
				4'h7:		ff_reg_frequency_count_d0[11:8]	<= wrdata[3:0];
				4'h8:		ff_reg_frequency_count_e0[ 7:0]	<= wrdata;
				4'h9:		ff_reg_frequency_count_e0[11:8]	<= wrdata[3:0];
				4'hA:		ff_reg_volume_a0				<= wrdata[3:0];
				4'hB:		ff_reg_volume_b0				<= wrdata[3:0];
				4'hC:		ff_reg_volume_c0				<= wrdata[3:0];
				4'hD:		ff_reg_volume_d0				<= wrdata[3:0];
				4'hE:		ff_reg_volume_e0				<= wrdata[3:0];
				4'hF:
					begin
						ff_reg_enable_a0	<= wrdata[0];
						ff_reg_enable_b0	<= wrdata[1];
						ff_reg_enable_c0	<= wrdata[2];
						ff_reg_enable_d0	<= wrdata[3];
						ff_reg_enable_e0	<= wrdata[4];
					end
				endcase
			end
			else if( memory && scc_en && (address[7:5] == 3'b111) ) begin
				ff_wave_reset	<= wrdata[5];
			end
			else if( memory && scci_en && (address[7:4] == 4'hA) ) begin
				case( address[3:0] )
				4'h0:		ff_reg_frequency_count_a0[ 7:0]	<= wrdata;
				4'h1:		ff_reg_frequency_count_a0[11:8]	<= wrdata[3:0];
				4'h2:		ff_reg_frequency_count_b0[ 7:0]	<= wrdata;
				4'h3:		ff_reg_frequency_count_b0[11:8]	<= wrdata[3:0];
				4'h4:		ff_reg_frequency_count_c0[ 7:0]	<= wrdata;
				4'h5:		ff_reg_frequency_count_c0[11:8]	<= wrdata[3:0];
				4'h6:		ff_reg_frequency_count_d0[ 7:0]	<= wrdata;
				4'h7:		ff_reg_frequency_count_d0[11:8]	<= wrdata[3:0];
				4'h8:		ff_reg_frequency_count_e0[ 7:0]	<= wrdata;
				4'h9:		ff_reg_frequency_count_e0[11:8]	<= wrdata[3:0];
				4'hA:		ff_reg_volume_a0				<= wrdata[3:0];
				4'hB:		ff_reg_volume_b0				<= wrdata[3:0];
				4'hC:		ff_reg_volume_c0				<= wrdata[3:0];
				4'hD:		ff_reg_volume_d0				<= wrdata[3:0];
				4'hE:		ff_reg_volume_e0				<= wrdata[3:0];
				4'hF:
					begin
						ff_reg_enable_a0	<= wrdata[0];
						ff_reg_enable_b0	<= wrdata[1];
						ff_reg_enable_c0	<= wrdata[2];
						ff_reg_enable_d0	<= wrdata[3];
						ff_reg_enable_e0	<= wrdata[4];
					end
				endcase
			end
			else if( memory && scc_en && (address[7:5] == 3'b110) ) begin
				ff_wave_reset	<= wrdata[5];
			end
		end
		else begin
			//	hold
		end
	end

	// Read registers ---------------------------------------------------------
	always @( posedge clk ) begin
		if( sram_q_en ) begin
			ff_rddata <= sram_q;
		end
		else begin
			//	hold
		end
	end

	always @( posedge clk ) begin
		if( !nreset ) begin
			ff_ready <= 1'b0;
		end
		else begin
			ff_ready <= sram_q_en;
		end
	end

	assign rddata	= ff_ready ? ff_rddata : 8'd0;
	assign ready	= ff_ready;

	// Tone Parameters --------------------------------------------------------
	scc_selector #( 12 ) u_wave_frequency_count_selector0 (
		.active					( active					),
		.result					( reg_frequency_count0		),
		.reg_a					( ff_reg_frequency_count_a0	),
		.reg_b					( ff_reg_frequency_count_b0	),
		.reg_c					( ff_reg_frequency_count_c0	),
		.reg_d					( ff_reg_frequency_count_d0	),
		.reg_e					( ff_reg_frequency_count_e0	),
		.reg_f					( 12'd0						)
	);

	scc_selector #( 4 ) u_volume_selector0 (
		.active		( active				),
		.result		( reg_volume0			),		//	delay 1 clock
		.reg_a		( 4'd0					),
		.reg_b		( ff_reg_volume_a0		),
		.reg_c		( ff_reg_volume_b0		),
		.reg_d		( ff_reg_volume_c0		),
		.reg_e		( ff_reg_volume_d0		),
		.reg_f		( ff_reg_volume_e0		)
	);

	scc_selector #( 1 ) u_enable_selector0 (
		.active		( active				),
		.result		( reg_enable0			),		//	delay 2 clock
		.reg_a		( ff_reg_enable_e0		),
		.reg_b		( 1'd0					),
		.reg_c		( ff_reg_enable_a0		),
		.reg_d		( ff_reg_enable_b0		),
		.reg_e		( ff_reg_enable_c0		),
		.reg_f		( ff_reg_enable_d0		)
	);
	
	assign reg_wave_reset		= ff_wave_reset;
endmodule
