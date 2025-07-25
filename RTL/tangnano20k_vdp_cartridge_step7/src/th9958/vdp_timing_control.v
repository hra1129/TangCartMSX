//
//	vdp_timing_control.v
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

module vdp_timing_control (
	input				reset_n,
	input				clk,					//	42.95454MHz

	output		[10:0]	h_count,
	output		[ 9:0]	v_count,

	output		[12:0]	screen_pos_x,			//	signed
	output		[ 9:0]	screen_pos_y,			//	signed
	output				screen_active,

	output				intr_line,				//	pulse
	output				intr_frame,				//	pulse

	output		[16:0]	t12_vram_address,
	output				t12_vram_valid,
	input		[7:0]	t12_vram_rdata,
	output		[3:0]	t12_display_color,

	output		[16:0]	g123m_vram_address,
	output				g123m_vram_valid,
	input		[7:0]	g123m_vram_rdata,
	output		[3:0]	g123m_display_color,

	output		[16:0]	g4567_vram_address,
	output				g4567_vram_valid,
	input		[31:0]	g4567_vram_rdata,
	output		[7:0]	g4567_display_color,

	output		[16:0]	sprite_vram_address,
	output				sprite_vram_valid,
	input		[31:0]	sprite_vram_rdata,
	input		[7:0]	sprite_vram_rdata8,
	output		[3:0]	sprite_display_color,
	output				sprite_display_color_en,

	input				clear_sprite_collision,
	output				sprite_collision,
	input				clear_sprite_collision_xy,
	output		[8:0]	sprite_collision_x,
	output		[9:0]	sprite_collision_y,

	input				reg_50hz_mode,
	input				reg_212lines_mode,
	input				reg_interlace_mode,
	input		[7:0]	reg_display_adjust,
	input		[7:0]	reg_interrupt_line,
	input		[7:0]	reg_vertical_offset,
	input		[2:0]	reg_horizontal_offset_l,
	input		[8:3]	reg_horizontal_offset_h,
	input		[4:0]	reg_screen_mode,
	input				reg_display_on,
	input				reg_color0_opaque,
	input		[16:10]	reg_pattern_name_table_base,
	input		[16:6]	reg_color_table_base,
	input		[16:11]	reg_pattern_generator_table_base,
	input		[16:7]	reg_sprite_attribute_table_base,
	input		[16:11]	reg_sprite_pattern_generator_table_base,
	input				reg_sprite_magify,
	input				reg_sprite_16x16,
	input				reg_sprite_disable,
	input		[7:0]	reg_backdrop_color,
	input				reg_left_mask
);
	wire		[12:0]	w_screen_pos_x;			//	signed   (Coordinates not affected by scroll register)
	wire		[ 9:0]	w_screen_pos_y;			//	signed   (Coordinates not affected by scroll register)
	wire		[ 8:0]	w_pixel_pos_x;			//	unsigned (Coordinates affected by scroll register)
	wire		[ 7:0]	w_pixel_pos_y;			//	unsigned (Coordinates affected by scroll register)
	wire				w_screen_active;
	wire		[ 2:0]	w_horizontal_offset_l;
	wire		[ 8:3]	w_horizontal_offset_h;

	// --------------------------------------------------------------------
	//	Output assignment
	// --------------------------------------------------------------------
	assign screen_pos_x		= w_screen_pos_x;
	assign screen_pos_y		= w_screen_pos_y;
	assign screen_active	= w_screen_active;

	// --------------------------------------------------------------------
	//	Synchronous Signal Generator
	// --------------------------------------------------------------------
	vdp_timing_control_ssg u_ssg (
		.reset_n									( reset_n									),
		.clk										( clk										),
		.h_count									( h_count									),
		.v_count									( v_count									),
		.screen_pos_x								( w_screen_pos_x							),
		.screen_pos_y								( w_screen_pos_y							),
		.pixel_pos_x								( w_pixel_pos_x								),
		.pixel_pos_y								( w_pixel_pos_y								),
		.screen_active								( w_screen_active							),
		.intr_line									( intr_line									),
		.intr_frame									( intr_frame								),
		.reg_50hz_mode								( reg_50hz_mode								),
		.reg_212lines_mode							( reg_212lines_mode							),
		.reg_interlace_mode							( reg_interlace_mode						),
		.reg_display_adjust							( reg_display_adjust						),
		.reg_interrupt_line							( reg_interrupt_line						),
		.reg_vertical_offset						( reg_vertical_offset						),
		.reg_horizontal_offset_l					( reg_horizontal_offset_l					),
		.reg_horizontal_offset_h					( reg_horizontal_offset_h					),
		.horizontal_offset_l						( w_horizontal_offset_l						),
		.horizontal_offset_h						( w_horizontal_offset_h						)
	);

	// --------------------------------------------------------------------
	//	Text1 and 2 mode
	// --------------------------------------------------------------------
	vdp_timing_control_t12 u_t12 (
		.reset_n									( reset_n									),
		.clk										( clk										),
		.screen_pos_x								( w_screen_pos_x							),
		.screen_pos_y								( w_screen_pos_y							),
		.pixel_pos_y								( w_pixel_pos_y[2:0]						),
		.screen_active								( screen_active								),
		.vram_address								( t12_vram_address							),
		.vram_valid									( t12_vram_valid							),
		.vram_rdata									( t12_vram_rdata							),
		.display_color								( t12_display_color							),
		.horizontal_offset_l						( w_horizontal_offset_l						),
		.reg_screen_mode							( reg_screen_mode							),
		.reg_display_on								( reg_display_on							),
		.reg_pattern_name_table_base				( reg_pattern_name_table_base				),
		.reg_color_table_base						( reg_color_table_base						),
		.reg_pattern_generator_table_base			( reg_pattern_generator_table_base			),
		.reg_backdrop_color							( reg_backdrop_color						)
	);

	// --------------------------------------------------------------------
	//	Graphic1, 2, 3 and Multi color mode
	// --------------------------------------------------------------------
	vdp_timing_control_g123m u_g123m (
		.reset_n									( reset_n									),
		.clk										( clk										),
		.screen_pos_x								( w_screen_pos_x							),
		.pixel_pos_y								( w_pixel_pos_y								),
		.screen_active								( w_screen_active							),
		.vram_address								( g123m_vram_address						),
		.vram_valid									( g123m_vram_valid							),
		.vram_rdata									( g123m_vram_rdata							),
		.display_color								( g123m_display_color						),
		.reg_screen_mode							( reg_screen_mode							),
		.reg_display_on								( reg_display_on							),
		.reg_pattern_name_table_base				( reg_pattern_name_table_base				),
		.reg_color_table_base						( reg_color_table_base						),
		.reg_pattern_generator_table_base			( reg_pattern_generator_table_base			),
		.reg_backdrop_color							( reg_backdrop_color[3:0]					)
	);

	// --------------------------------------------------------------------
	//	Graphic4, 5, 6 and 7 mode
	// --------------------------------------------------------------------
	vdp_timing_control_g4567 u_g4567 (
		.reset_n									( reset_n									),
		.clk										( clk										),
		.screen_pos_x								( w_screen_pos_x							),
		.pixel_pos_y								( w_pixel_pos_y								),
		.screen_active								( w_screen_active							),
		.vram_address								( g4567_vram_address						),
		.vram_valid									( g4567_vram_valid							),
		.vram_rdata									( g4567_vram_rdata							),
		.display_color								( g4567_display_color						),
		.reg_screen_mode							( reg_screen_mode							),
		.reg_display_on								( reg_display_on							),
		.reg_pattern_name_table_base				( reg_pattern_name_table_base				),
		.reg_backdrop_color							( reg_backdrop_color						)
	);

	// --------------------------------------------------------------------
	//	Sprite
	// --------------------------------------------------------------------
	vdp_timing_control_sprite u_sprite (
		.reset_n									( reset_n									),
		.clk										( clk										),
		.screen_pos_x								( screen_pos_x								),
		.screen_pos_y								( screen_pos_y								),
		.pixel_pos_y								( w_pixel_pos_y								),
		.screen_active								( screen_active								),
		.vram_address								( sprite_vram_address						),
		.vram_valid									( sprite_vram_valid							),
		.vram_rdata									( sprite_vram_rdata							),
		.vram_rdata8								( sprite_vram_rdata8						),
		.display_color								( sprite_display_color						),
		.display_color_en							( sprite_display_color_en					),
		.clear_sprite_collision						( clear_sprite_collision					),
		.sprite_collision							( sprite_collision							),
		.clear_sprite_collision_xy					( clear_sprite_collision_xy					),
		.sprite_collision_x							( sprite_collision_x						),
		.sprite_collision_y							( sprite_collision_y						),
		.reg_screen_mode							( reg_screen_mode							),
		.reg_display_on								( reg_display_on							),
		.reg_color0_opaque							( reg_color0_opaque							),
		.reg_sprite_magify							( reg_sprite_magify							),
		.reg_sprite_16x16							( reg_sprite_16x16							),
		.reg_212lines_mode							( reg_212lines_mode							),
		.reg_sprite_disable							( reg_sprite_disable						),
		.reg_sprite_attribute_table_base			( reg_sprite_attribute_table_base			),
		.reg_sprite_pattern_generator_table_base	( reg_sprite_pattern_generator_table_base	),
		.reg_left_mask								( reg_left_mask								)
	);
endmodule
