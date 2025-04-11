// ------------------------------------------------------------------------------------------------
// Wave Table Sound
// Copyright 2021 t.hara
// 
//  Permission is hereby granted, free of charge, to any person obtaining a copy 
// of this software and associated documentation files (the "Software"), to deal 
// in the Software without restriction, including without limitation the rights 
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies 
// of the Software, and to permit persons to whom the Software is furnished to do
// so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all 
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A 
// PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT 
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION 
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH 
// THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
// ------------------------------------------------------------------------------------------------

module scc_core #(
	parameter		add_offset = 1			//	0: +0 (for OCM), 1: +128 (for cartridge)
) (
	input			nreset,
	input			clk,
	input			enable,
	input			wrreq,
	input			rdreq,
	input			wr_active,
	input			rd_active,
	input	[14:0]	a,
	input	[7:0]	d,
	output	[7:0]	q,
	output			q_en,
	output			mem_ncs,
	output	[7:0]	mem_a,
	output	[10:0]	left_out
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

	scc_channel_mixer #(
		.add_offset				( add_offset				)
	) u_scc_channel_mixer (
		.nreset					( nreset					),
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
		.left_out				( left_out					),
		.reg_scci_enable		( reg_scci_enable			),
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
		.nreset					( nreset					),
		.clk					( clk						),
		.enable					( enable					),
		.wrreq					( wrreq						),
		.rdreq					( rdreq						),
		.wr_active				( wr_active					),
		.rd_active				( rd_active					),
		.address				( a							),
		.wrdata					( d							),
		.rddata					( q							),
		.rddata_en				( q_en						),
		.active					( active					),
		.ext_memory_nactive		( mem_ncs					),
		.ext_memory_address		( mem_a						),
		.sram_id				( sram_id					),
		.sram_a					( sram_a					),
		.sram_d					( sram_d					),
		.sram_oe				( sram_oe					),
		.sram_we				( sram_we					),
		.sram_q					( sram_q					),
		.sram_q_en				( sram_q_en					),
		.reg_scci_enable		( reg_scci_enable			),
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
