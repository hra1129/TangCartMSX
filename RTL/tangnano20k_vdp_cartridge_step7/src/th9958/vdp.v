//
//	vdp.v
//	VDP Top Entity
//
//	Copyright (C) 2025 Takayuki Hara
//
//	本ソフトウェアおよび本ソフトウェアに基づいて作成された派生物は、以下の条件を
//	満たす場合に限り、再頒布および使用が許可されます。
//
//	1.ソースコード形式で再頒布する場合、上記の著作権表示、本条件一覧、および下記
//	  免責条項をそのままの形で保持すること。
//	2.バイナリ形式で再頒布する場合、頒布物に付属のドキュメント等の資料に、上記の
//	  著作権表示、本条件一覧、および下記免責条項を含めること。
//	3.書面による事前の許可なしに、本ソフトウェアを販売、および商業的な製品や活動
//	  に使用しないこと。
//
//	本ソフトウェアは、著作権者によって「現状のまま」提供されています。著作権者は、
//	特定目的への適合性の保証、商品性の保証、またそれに限定されない、いかなる明示
//	的もしくは暗黙な保証責任も負いません。著作権者は、事由のいかんを問わず、損害
//	発生の原因いかんを問わず、かつ責任の根拠が契約であるか厳格責任であるか（過失
//	その他の）不法行為であるかを問わず、仮にそのような損害が発生する可能性を知ら
//	されていたとしても、本ソフトウェアの使用によって発生した（代替品または代用サ
//	ービスの調達、使用の喪失、データの喪失、利益の喪失、業務の中断も含め、またそ
//	れに限定されない）直接損害、間接損害、偶発的な損害、特別損害、懲罰的損害、ま
//	たは結果損害について、一切責任を負わないものとします。
//
//	Note that above Japanese version license is the formal document.
//	The following translation is only for reference.
//
//	Redistribution and use of this software or any derivative works,
//	are permitted provided that the following conditions are met:
//
//	1. Redistributions of source code must retain the above copyright
//	   notice, this list of conditions and the following disclaimer.
//	2. Redistributions in binary form must reproduce the above
//	   copyright notice, this list of conditions and the following
//	   disclaimer in the documentation and/or other materials
//	   provided with the distribution.
//	3. Redistributions may not be sold, nor may they be used in a
//	   commercial product or activity without specific prior written
//	   permission.
//
//	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
//	"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
//	LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
//	FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
//	COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
//	INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
//	BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//	LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
//	CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
//	LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
//	ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//	POSSIBILITY OF SUCH DAMAGE.
//
//-----------------------------------------------------------------------------

module vdp (
	input				reset_n,
	input				clk,					//	42.95454MHz

	input				initial_busy,
	input		[15:0]	bus_address,
	input				bus_ioreq,
	input				bus_write,
	input				bus_valid,
	input		[7:0]	bus_wdata,
	output		[7:0]	bus_rdata,
	output				bus_rdata_en,

	output				int_n,

	output		[16:0]	vram_address,
	output				vram_write,
	output				vram_valid,
	output		[7:0]	vram_wdata,
	input		[31:0]	vram_rdata,
	input				vram_rdata_en,

	// video output
	output		[10:0]	vdp_h_counter,
	output		[10:0]	vdp_v_counter,
	output				vdp_v_counter_end,
	output		[7:0]	vdp_r,
	output		[7:0]	vdp_g,
	output		[7:0]	vdp_b
);
	wire	[16:0]		vram_address;
	wire				vram_write;
	wire				vram_valid;
	wire				vram_ready;
	wire	[7:0]		vram_wdata;
	wire	[7:0]		vram_rdata;
	wire				vram_rdata_en;

	wire	[4:0]		reg_screen_mode;
	wire				reg_sprite_magify;
	wire				reg_sprite_16x16;
	wire				reg_display_on;
	wire	[16:10]		reg_pattern_name_table_base;
	wire	[16:6]		reg_color_table_base;
	wire	[16:11]		reg_pattern_generator_table_base;
	wire	[16:9]		reg_sprite_attribute_table_base;
	wire	[16:11]		reg_sprite_pattern_generator_table_base;
	wire	[7:0]		reg_backdrop_color;
	wire				reg_sprite_disable;
	wire				reg_color0_opaque;
	wire				reg_50hz_mode;
	wire				reg_interleaving_mode;
	wire				reg_interlace_mode;
	wire				reg_212lines_mode;
	wire	[7:0]		reg_text_back_color;
	wire	[7:0]		reg_blink_period;
	wire	[3:0]		reg_color_palette_address;
	wire	[7:0]		reg_display_adjust;
	wire	[7:0]		reg_interrupt_line;
	wire	[7:0]		reg_vertical_offset;
	wire				reg_scroll_planes;
	wire				reg_left_mask;
	wire				reg_yjk_mode;
	wire				reg_yae_mode;
	wire				reg_command_enable;
	wire	[8:0]		reg_horizontal_offset;

	// --------------------------------------------------------------------
	//	CPU Interface
	// --------------------------------------------------------------------
	vdp_cpu_interface u_cpu_interface (
		.reset_n									( reset_n									),
		.clk										( clk										),
		.bus_address								( bus_address								),
		.bus_ioreq									( bus_ioreq									),
		.bus_write									( bus_write									),
		.bus_valid									( bus_valid									),
		.bus_ready									( bus_ready									),
		.bus_wdata									( bus_wdata									),
		.bus_rdata									( bus_rdata									),
		.bus_rdata_en								( bus_rdata_en								),
		.vram_address								( vram_address								),
		.vram_write									( vram_write								),
		.vram_valid									( vram_valid								),
		.vram_ready									( vram_ready								),
		.vram_wdata									( vram_wdata								),
		.vram_rdata									( vram_rdata								),
		.vram_rdata_en								( vram_rdata_en								),
		.reg_screen_mode							( reg_screen_mode							),
		.reg_sprite_magify							( reg_sprite_magify							),
		.reg_sprite_16x16							( reg_sprite_16x16							),
		.reg_display_on								( reg_display_on							),
		.reg_pattern_name_table_base				( reg_pattern_name_table_base				),
		.reg_color_table_base						( reg_color_table_base						),
		.reg_pattern_generator_table_base			( reg_pattern_generator_table_base			),
		.reg_sprite_attribute_table_base			( reg_sprite_attribute_table_base			),
		.reg_sprite_pattern_generator_table_base	( reg_sprite_pattern_generator_table_base	),
		.reg_backdrop_color							( reg_backdrop_color						),
		.reg_sprite_disable							( reg_sprite_disable						),
		.reg_color0_opaque							( reg_color0_opaque							),
		.reg_50hz_mode								( reg_50hz_mode								),
		.reg_interleaving_mode						( reg_interleaving_mode						),
		.reg_interlace_mode							( reg_interlace_mode						),
		.reg_212lines_mode							( reg_212lines_mode							),
		.reg_text_back_color						( reg_text_back_color						),
		.reg_blink_period							( reg_blink_period							),
		.reg_color_palette_address					( reg_color_palette_address					),
		.reg_display_adjust							( reg_display_adjust						),
		.reg_interrupt_line							( reg_interrupt_line						),
		.reg_vertical_offset						( reg_vertical_offset						),
		.reg_scroll_planes							( reg_scroll_planes							),
		.reg_left_mask								( reg_left_mask								),
		.reg_yjk_mode								( reg_yjk_mode								),
		.reg_yae_mode								( reg_yae_mode								),
		.reg_command_enable							( reg_command_enable						),
		.reg_horizontal_offset						( reg_horizontal_offset						)
	);

endmodule
