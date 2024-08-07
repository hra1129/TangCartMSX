// ------------------------------------------------------------------------------------------------
// SCC Sound Core
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

module ip_scc (
	input			n_reset,
	input			clk,
	input			enable,
	//	MSX-50BUS
	input	[15:0]	bus_address,
	output			bus_read_ready,
	output	[7:0]	bus_read_data,
	input	[7:0]	bus_write_data,
	input			bus_read,
	input			bus_write,
	input			bus_memory,
	//	SCC
	input			scc_bank_en,
	input			sccp_bank_en,
	input			sccp_en,
	output	[10:0]	sound_out		//	digital sound output (11 bits)
);
	wire	[2:0]	active;

	wire	[2:0]	sram_id;				//	A...E
	wire	[4:0]	sram_a;
	wire	[7:0]	sram_d;
	wire			sram_oe;
	wire			sram_we;
	wire	[7:0]	sram_q;
	wire			sram_q_en;

	wire			reg_scci_enable;
	wire	[11:0]	reg_frequency_count0;
	wire	[3:0]	reg_volume0;
	wire			reg_enable0;
	wire			reg_wave_reset;
	wire			clear_counter_a0;
	wire			clear_counter_b0;
	wire			clear_counter_c0;
	wire			clear_counter_d0;
	wire			clear_counter_e0;

	scc_channel_mixer u_scc_channel_mixer (
		.nreset					( n_reset					),
		.clk					( clk						),
		.enable					( enable					),
		.sram_id				( sram_id					),
		.sram_a					( sram_a					),
		.sram_d					( sram_d					),
		.sram_oe				( sram_oe					),
		.sram_we				( sram_we					),
		.sram_q					( sram_q					),
		.sram_q_en				( sram_q_en					),
		.active					( active					),
		.left_out				( sound_out					),
		.reg_scci_enable		( sccp_en					),
		.reg_frequency_count0	( reg_frequency_count0		),
		.reg_volume0			( reg_volume0				),
		.reg_enable0			( reg_enable0				),
		.reg_wave_reset			( reg_wave_reset			),
		.clear_counter_a0		( clear_counter_a0			),
		.clear_counter_b0		( clear_counter_b0			),
		.clear_counter_c0		( clear_counter_c0			),
		.clear_counter_d0		( clear_counter_d0			),
		.clear_counter_e0		( clear_counter_e0			)
	);

	scc_register u_scc_register (
		.nreset					( n_reset					),
		.clk					( clk						),
		.enable					( enable					),
		.wr						( bus_write					),
		.rd						( bus_read					),
		.memory					( bus_memory				),
		.ready					( bus_read_ready			),
		.address				( bus_address[12:0]			),
		.wrdata					( bus_write_data			),
		.rddata					( bus_read_data				),
		.scc_en					( scc_bank_en				),
		.scci_en				( sccp_bank_en				),
		.active					( active					),
		.sram_id				( sram_id					),
		.sram_a					( sram_a					),
		.sram_d					( sram_d					),
		.sram_oe				( sram_oe					),
		.sram_we				( sram_we					),
		.sram_q					( sram_q					),
		.sram_q_en				( sram_q_en					),
		.reg_scci_enable		( sccp_en					),
		.reg_frequency_count0	( reg_frequency_count0		),
		.reg_volume0			( reg_volume0				),
		.reg_enable0			( reg_enable0				),
		.reg_wave_reset			( reg_wave_reset			),
		.clear_counter_a0		( clear_counter_a0			),
		.clear_counter_b0		( clear_counter_b0			),
		.clear_counter_c0		( clear_counter_c0			),
		.clear_counter_d0		( clear_counter_d0			),
		.clear_counter_e0		( clear_counter_e0			)
	);
endmodule
