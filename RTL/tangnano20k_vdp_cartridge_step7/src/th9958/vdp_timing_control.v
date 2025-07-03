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

	output		[3:0]	display_color_t12,
	output		[3:0]	display_color_g123m,
	output		[7:0]	display_color_g4567,
	output		[3:0]	display_color_sprite,
	output				display_color_sprite_en,

	input				reg_50hz_mode,
	input				reg_interlace_mode,
	input		[7:0]	reg_interrupt_line,
	input		[7:0]	reg_vertical_offset,
	input		[4:0]	reg_screen_mode,
	input		[16:10]	reg_pattern_name_table_base,
	input		[16:6]	reg_color_table_base,
	input		[16:11]	reg_pattern_generator_table_base,
	input		[3:0]	reg_backdrop_color
);
	wire		[12:0]	w_screen_pos_x;			//	signed   (Coordinates not affected by scroll register)
	wire		[ 9:0]	w_screen_pos_y;			//	signed   (Coordinates not affected by scroll register)
	wire		[ 8:0]	w_pixel_pos_x;			//	unsigned (Coordinates affected by scroll register)
	wire		[ 7:0]	w_pixel_pos_y;			//	unsigned (Coordinates affected by scroll register)
	wire				w_screen_active;

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
		.reset_n							( reset_n							),
		.clk								( clk								),
		.h_count							( h_count							),
		.v_count							( v_count							),
		.screen_pos_x						( w_screen_pos_x					),
		.screen_pos_y						( w_screen_pos_y					),
		.pixel_pos_x						( w_pixel_pos_x						),
		.pixel_pos_y						( w_pixel_pos_y						),
		.screen_active						( w_screen_active					),
		.intr_line							( intr_line							),
		.intr_frame							( intr_frame						),
		.reg_50hz_mode						( reg_50hz_mode						),
		.reg_interlace_mode					( reg_interlace_mode				),
		.reg_interrupt_line					( reg_interrupt_line				),
		.reg_vertical_offset				( reg_vertical_offset				),
		.reg_horizontal_offset				( reg_horizontal_offset				)
	);

	// --------------------------------------------------------------------
	//	Text1 and 2 mode
	// --------------------------------------------------------------------
	vdp_timing_control_t12 u_t12 (
		.reset_n							( reset_n							),
		.clk								( clk								),
		.screen_pos_x						( w_screen_pos_x					),
		.screen_pos_y						( w_screen_pos_y					),
		.pixel_pos_y						( w_pixel_pos_y[2:0]				),
		.screen_active						( screen_active						),
		.vram_address						( vram_address						),
		.vram_valid							( vram_valid						),
		.vram_rdata							( vram_rdata						),
		.display_color						( display_color						),
		.reg_screen_mode					( reg_screen_mode					),
		.reg_pattern_name_table_base		( reg_pattern_name_table_base		),
		.reg_color_table_base				( reg_color_table_base				),
		.reg_pattern_generator_table_base	( reg_pattern_generator_table_base	),
		.reg_backdrop_color					( reg_backdrop_color				)
	);

	// --------------------------------------------------------------------
	//	Graphic1, 2, 3 and Multi color mode
	// --------------------------------------------------------------------
	vdp_timing_control_g123m u_g123m (
		.reset_n							( reset_n							),
		.clk								( clk								),
		.screen_pos_x						( w_screen_pos_x					),
		.pixel_pos_y						( w_pixel_pos_y						),
		.screen_active						( w_screen_active					),
		.vram_address						( vram_address						),
		.vram_valid							( vram_valid						),
		.vram_rdata							( vram_rdata						),
		.display_color						( display_color_g123m				),
		.reg_screen_mode					( reg_screen_mode					),
		.reg_pattern_name_table_base		( reg_pattern_name_table_base		),
		.reg_color_table_base				( reg_color_table_base				),
		.reg_pattern_generator_table_base	( reg_pattern_generator_table_base	),
		.reg_backdrop_color					( reg_backdrop_color				)
	);

	// --------------------------------------------------------------------
	//	Graphic4, 5, 6 and 7 mode
	// --------------------------------------------------------------------
	vdp_timing_control_g4567 u_g4567 (
		.reset_n							( reset_n							),
		.clk								( clk								),
		.screen_pos_x						( w_screen_pos_x					),
		.screen_pos_y						( w_screen_pos_y					),
		.screen_active						( w_screen_active					),
		.vram_address						( vram_address						),
		.vram_valid							( vram_valid						),
		.vram_rdata							( vram_rdata						),
		.display_color						( display_color_g4567				),
		.reg_screen_mode					( reg_screen_mode					),
		.reg_pattern_name_table_base		( reg_pattern_name_table_base		)
	);

	// --------------------------------------------------------------------
	//	Sprite
	// --------------------------------------------------------------------

endmodule
