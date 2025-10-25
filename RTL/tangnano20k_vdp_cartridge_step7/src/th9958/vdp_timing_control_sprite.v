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

	input		[13:0]	screen_pos_x,
	input		[9:0]	screen_pos_y,
	input		[7:0]	pixel_pos_y,
	input				screen_v_active,

	output		[17:0]	vram_address,
	output				vram_valid,
	input		[31:0]	vram_rdata,
	input		[7:0]	vram_rdata8,

	output		[7:0]	display_color,
	output		[1:0]	display_color_transparent,
	output				display_color_en,

	input		[2:0]	horizontal_offset_l,
	input				clear_sprite_collision,
	output				sprite_collision,
	input				clear_sprite_collision_xy,
	output		[8:0]	sprite_collision_x,
	output		[9:0]	sprite_collision_y,
	input				sprite_off,
	output				sprite_overmap,
	output		[4:0]	sprite_overmap_id,

	input		[4:0]	reg_screen_mode,
	input				reg_display_on,
	input				reg_color0_opaque,
	input				reg_sprite_magify,
	input				reg_sprite_16x16,
	input				reg_sprite_disable,
	input   	[17:7]	reg_sprite_attribute_table_base,
	input   	[17:11]	reg_sprite_pattern_generator_table_base,
	input				reg_left_mask,
	input				reg_sprite_nonR23_mode,
	input				reg_sprite_mode3,
	input				reg_sprite16_mode,
	input				reg_sprite_priority_shuffle
);
	localparam			c_mode_g3	= 5'b010_00;	//	Graphic3 (SCREEN4)
	localparam			c_mode_g4	= 5'b011_00;	//	Graphic4 (SCREEN5)
	localparam			c_mode_g5	= 5'b100_00;	//	Graphic5 (SCREEN6)
	localparam			c_mode_g6	= 5'b101_00;	//	Graphic6 (SCREEN7)
	localparam			c_mode_g7	= 5'b111_00;	//	Graphic7 (SCREEN8/10/11/12)
	wire				w_sprite_disable;
	reg					ff_screen_v_active;
	reg					ff_screen_h_active;
	reg					ff_sprite_priority_shuffle;

	assign w_sprite_disable	= reg_sprite_disable | sprite_off;

	// --------------------------------------------------------------------
	//	Wire declarations
	// --------------------------------------------------------------------
	wire				w_selected_en;
	wire		[5:0]	w_selected_plane_num;
	wire		[31:0]	w_selected_attribute;
	wire		[4:0]	w_selected_count;
	wire				w_start_info_collect;
	wire				w_sprite_mode2;
	wire		[9:0]	w_plane_x;
	wire		[7:0]	w_color;
	wire				w_color_plane_x_en;
	wire		[31:0]	w_pattern;
	wire				w_pattern_left_en;
	wire				w_pattern_right_en;
	wire		[3:0]	w_makeup_plane;
	wire		[17:0]	w_vp_vram_address;
	wire				w_vp_vram_valid;
	wire		[17:0]	w_ic_vram_address;
	wire				w_ic_vram_valid;
	wire		[7:0]	w_x;
	wire		[7:0]	w_mgx;
	wire		[7:0]	w_y;
	wire		[7:0]	w_mgy;
	wire		[7:0]	w_info_mgx;
	wire		[1:0]	w_transparent;
	wire		[7:0]	w_divider_x;
	wire		[7:0]	w_divider_mgx;
	wire		[1:0]	w_bit_shift;
	wire		[6:0]	w_sample_x;
	wire		[13:0]	w_screen_pos_x;

	// --------------------------------------------------------------------
	//	Horizontal active
	// --------------------------------------------------------------------
	assign vram_address			= w_vp_vram_address | w_ic_vram_address;
	assign vram_valid			= w_vp_vram_valid   | w_ic_vram_valid;
	assign w_sprite_mode2		= (
			reg_screen_mode == c_mode_g3 ||
			reg_screen_mode == c_mode_g4 ||
			reg_screen_mode == c_mode_g5 ||
			reg_screen_mode == c_mode_g6 ||
			reg_screen_mode == c_mode_g7 );
	assign w_screen_pos_x[13:4]	= screen_pos_x[13:4] - { 7'd0, horizontal_offset_l };
	assign w_screen_pos_x[ 3:0]	= screen_pos_x[ 3:0];

	// --------------------------------------------------------------------
	//	Active period
	// --------------------------------------------------------------------

	//	実際にスプライトを処理する映像期間（表示期間は screen_v_active で、これはもう少し広い）
	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_screen_v_active <= 1'b0;
		end
		else if( screen_pos_x[13:4] == 10'h3DF && screen_pos_x[3:0] == 4'hF ) begin
			if( screen_pos_y[9:0] == 10'h3FF ) begin
				ff_screen_v_active <= 1'b1;
			end
			else if( screen_pos_y[9:0] == 10'd255 ) begin
				ff_screen_v_active <= 1'b0;
			end
		end
	end

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_screen_h_active <= 1'b0;
		end
		else if( w_screen_pos_x[3:0] == 4'hF ) begin
			if( w_screen_pos_x[13:4] == 10'h3FF ) begin
				ff_screen_h_active <= 1'b1;
			end
			else if( w_screen_pos_x[13:4] == 10'd255 ) begin
				ff_screen_h_active <= 1'b0;
			end
		end
	end

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_sprite_priority_shuffle <= 1'b0;
		end
		else if( screen_pos_x[13:0] == 14'h3FFF ) begin
			ff_sprite_priority_shuffle <= reg_sprite_priority_shuffle;
		end
	end

	// --------------------------------------------------------------------
	//	Select visible planes
	// --------------------------------------------------------------------
	vdp_sprite_select_visible_planes u_select_visible_planes (
		.reset_n									( reset_n									),
		.clk										( clk										),
		.screen_pos_x								( w_screen_pos_x							),
		.screen_pos_y								( screen_pos_y[8:0]							),
		.pixel_pos_y								( pixel_pos_y								),
		.screen_v_active							( ff_screen_v_active						),
		.screen_h_active							( ff_screen_h_active						),
		.vram_address								( w_vp_vram_address							),
		.vram_valid									( w_vp_vram_valid							),
		.vram_rdata									( vram_rdata								),
		.selected_en								( w_selected_en								),
		.selected_plane_num							( w_selected_plane_num						),
		.selected_attribute							( w_selected_attribute						),
		.selected_count								( w_selected_count							),
		.start_info_collect							( w_start_info_collect						),
		.sprite_overmap								( sprite_overmap							),
		.sprite_overmap_id							( sprite_overmap_id							),
		.clear_sprite_collision						( clear_sprite_collision					),
		.sprite_mode2								( w_sprite_mode2							),
		.reg_display_on								( reg_display_on							),
		.reg_sprite_disable							( w_sprite_disable							),
		.reg_sprite_magify							( reg_sprite_magify							),
		.reg_sprite_16x16							( reg_sprite_16x16							),
		.reg_sprite_attribute_table_base			( reg_sprite_attribute_table_base			),
		.reg_sprite_nonR23_mode						( reg_sprite_nonR23_mode					),
		.reg_sprite_mode3							( reg_sprite_mode3							),
		.reg_sprite16_mode							( reg_sprite16_mode							),
		.reg_sprite_priority_shuffle				( ff_sprite_priority_shuffle				)
	);

	// --------------------------------------------------------------------
	//	Information collect
	// --------------------------------------------------------------------
	vdp_sprite_info_collect u_info_collect (
		.reset_n									( reset_n									),
		.clk										( clk										),
		.start_info_collect							( w_start_info_collect						),
		.screen_pos_x								( w_screen_pos_x							),
		.screen_v_active							( ff_screen_v_active						),
		.screen_h_active							( ff_screen_h_active						),
		.vram_address								( w_ic_vram_address							),
		.vram_valid									( w_ic_vram_valid							),
		.vram_rdata8								( vram_rdata8								),
		.vram_rdata									( vram_rdata								),
		.selected_en								( w_selected_en								),
		.selected_plane_num							( w_selected_plane_num						),
		.selected_attribute							( w_selected_attribute						),
		.selected_count								( w_selected_count							),
		.y											( w_y										),
		.mgy										( w_mgy										),
		.bit_shift									( w_bit_shift								),
		.sample_y									( w_sample_x								),
		.makeup_plane								( w_makeup_plane							),
		.plane_x									( w_plane_x									),
		.color										( w_color									),
		.mgx										( w_info_mgx								),
		.color_plane_x_en							( w_color_plane_x_en						),
		.pattern									( w_pattern									),
		.pattern_left_en							( w_pattern_left_en							),
		.pattern_right_en							( w_pattern_right_en						),
		.sprite_mode2								( w_sprite_mode2							),
		.reg_display_on								( reg_display_on							),
		.reg_sprite_magify							( reg_sprite_magify							),
		.reg_sprite_16x16							( reg_sprite_16x16							),
		.reg_sprite_pattern_generator_table_base	( reg_sprite_pattern_generator_table_base	),
		.reg_sprite_attribute_table_base			( reg_sprite_attribute_table_base			),
		.reg_sprite_mode3							( reg_sprite_mode3							)
	);

	// --------------------------------------------------------------------
	//	Makeup pixels
	// --------------------------------------------------------------------
	vdp_sprite_makeup_pixel u_makeup_pixel (
		.reset_n									( reset_n									),
		.clk										( clk										),
		.screen_pos_x								( screen_pos_x								),
		.pixel_pos_y								( pixel_pos_y								),
		.screen_v_active							( screen_v_active							),
		.sprite_mode2								( w_sprite_mode2							),
		.clear_sprite_collision						( clear_sprite_collision					),
		.sprite_collision							( sprite_collision							),
		.clear_sprite_collision_xy					( clear_sprite_collision_xy					),
		.sprite_collision_x							( sprite_collision_x						),
		.sprite_collision_y							( sprite_collision_y						),
		.reg_display_on								( reg_display_on							),
		.reg_color0_opaque							( reg_color0_opaque							),
		.reg_sprite_magify							( reg_sprite_magify							),
		.reg_sprite_16x16							( reg_sprite_16x16							),
		.reg_sprite_mode3							( reg_sprite_mode3							),
		.selected_count								( w_selected_count							),
		.makeup_plane								( w_makeup_plane							),
		.plane_x									( w_plane_x									),
		.color										( w_color									),
		.info_mgx									( w_info_mgx								),
		.color_plane_x_en						    ( w_color_plane_x_en						),
		.pattern									( w_pattern									),
		.pattern_left_en							( w_pattern_left_en							),
		.pattern_right_en							( w_pattern_right_en						),
		.x											( w_x										),
		.mgx										( w_mgx										),
		.sample_x									( w_sample_x								),
		.display_color								( display_color								),
		.display_color_transparent					( display_color_transparent					),
		.display_color_en							( display_color_en							)
	);

	// --------------------------------------------------------------------
	//	Divider
	// --------------------------------------------------------------------
	assign w_divider_x		= w_x | w_y;
	assign w_divider_mgx	= w_mgx | w_mgy;
	vdp_sprite_divide_table u_divide_table (
		.reset_n									( reset_n									),
		.clk										( clk										),
		.x											( w_divider_x								),
		.reg_mgx									( w_divider_mgx								),
		.bit_shift									( w_bit_shift								),
		.sample_x									( w_sample_x								)
	);

endmodule
