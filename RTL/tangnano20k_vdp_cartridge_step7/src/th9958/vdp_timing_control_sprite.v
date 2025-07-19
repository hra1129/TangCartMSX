//
//	vdp_timing_control_sprite.v
//	Sprite for Timing Control
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

module vdp_timing_control_sprite (
	input				reset_n,
	input				clk,					//	42.95454MHz

	input		[12:0]	screen_pos_x,
	input		[ 9:0]	screen_pos_y,
	input				screen_active,

	output		[16:0]	vram_address,
	output				vram_valid,
	input		[31:0]	vram_rdata,

	output		[3:0]	display_color,

	input		[4:0]	reg_screen_mode,
	input				reg_sprite_magify,
	input				reg_sprite_16x16,
	input				reg_sprite_disable,
	input				reg_color0_opaque,
	input	[16:9]		reg_sprite_attribute_table_base,
	input	[16:11]		reg_sprite_pattern_generator_table_base,
	input				reg_left_mask
);

	// --------------------------------------------------------------------
	//	Select visible planes
	// --------------------------------------------------------------------
	vdp_sprite_select_visible_planes u_select_visible_planes (
		.reset_n									( reset_n									),
		.clk										( clk										),
		.screen_pos_x								( screen_pos_x								),
		.pixel_pos_y								( pixel_pos_y								),
		.screen_active								( screen_active								),
		.vram_address								( vram_address								),
		.vram_valid									( vram_valid								),
		.vram_rdata									( vram_rdata								),
		.selected_en								( selected_en								),
		.selected_plane_num							( selected_plane_num						),
		.selected_y									( selected_y								),
		.selected_x									( selected_x								),
		.selected_pattern							( selected_pattern							),
		.selected_color								( selected_color							),
		.selected_count								( selected_count							),
		.start_info_collect							( start_info_collect						),
		.sprite_mode2								( sprite_mode2								),
		.reg_sprite_magify							( reg_sprite_magify							),
		.reg_sprite_16x16							( reg_sprite_16x16							),
		.reg_sprite_attribute_table_base			( reg_sprite_attribute_table_base			)
	);

	// --------------------------------------------------------------------
	//	Information collect
	// --------------------------------------------------------------------
	vdp_sprite_info_collect u_info_collect (
		.reset_n									( reset_n									),
		.clk										( clk										),
		.start_info_collect							( start_info_collect						),
		.screen_pos_x								( screen_pos_x								),
		.pixel_pos_y								( pixel_pos_y								),
		.screen_active								( screen_active								),
		.vram_address								( vram_address								),
		.vram_valid									( vram_valid								),
		.vram_rdata									( vram_rdata								),
		.current_plane								( current_plane								),
		.selected_plane_num							( selected_plane_num						),
		.selected_y									( selected_y								),
		.selected_x									( selected_x								),
		.selected_pattern							( selected_pattern							),
		.selected_color								( selected_color							),
		.selected_count								( selected_count							),
		.selected_x_en								( selected_x_en								),
		.pattern_left								( pattern_left								),
		.pattern_left_en							( pattern_left_en							),
		.pattern_right								( pattern_right								),
		.pattern_right_en							( pattern_right_en							),
		.color										( color										),
		.color_en									( color_en									),
		.sprite_mode2								( sprite_mode2								),
		.reg_sprite_magify							( reg_sprite_magify							),
		.reg_sprite_16x16							( reg_sprite_16x16							),
		.reg_sprite_attribute_table_base			( reg_sprite_attribute_table_base			),
		.reg_sprite_pattern_generator_table_base	( reg_sprite_pattern_generator_table_base	)
	);

	// --------------------------------------------------------------------
	//	Makeup pixels
	// --------------------------------------------------------------------
	vdp_sprite_makeup_pixel u_makeup_pixel (
		.reset_n									( reset_n									),
		.clk										( clk										),
		.screen_pos_x								( screen_pos_x								),
		.screen_active								( screen_active								),
		.sprite_mode2								( sprite_mode2								),
		.reg_sprite_magify							( reg_sprite_magify							),
		.reg_sprite_16x16							( reg_sprite_16x16							),
		.selected_count								( selected_count							),
		.makeup_plane								( makeup_plane								),
		.selected_x									( selected_x								),
		.selected_x_en								( selected_x_en								),
		.pattern_left								( pattern_left								),
		.pattern_left_en							( pattern_left_en							),
		.pattern_right								( pattern_right								),
		.pattern_right_en							( pattern_right_en							),
		.color										( color										),
		.color_en								    ( color_en								    ),
		.display_color								( display_color								),
		.display_color_en							( display_color_en							)
	);

endmodule
