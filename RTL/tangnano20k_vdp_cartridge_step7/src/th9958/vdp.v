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
	input				clk,					//	85.90908MHz

	input				initial_busy,
	input		[1:0]	bus_address,
	input				bus_ioreq,
	input				bus_write,
	input				bus_valid,
	output				bus_ready,
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
	output				display_hs,
	output				display_vs,
	output				display_en,
	output		[7:0]	display_r,
	output		[7:0]	display_g,
	output		[7:0]	display_b
);
	wire		[11:0]	w_h_count;
	wire		[ 9:0]	w_v_count;
	wire		[13:0]	w_screen_pos_x;
	wire		[ 9:0]	w_screen_pos_y;
	wire				w_intr_line;
	wire				w_intr_frame;

	wire		[7:0]	w_upscan_r;
	wire		[7:0]	w_upscan_g;
	wire		[7:0]	w_upscan_b;

	wire		[7:0]	w_vdp_r;
	wire		[7:0]	w_vdp_g;
	wire		[7:0]	w_vdp_b;

	wire				w_palette_valid;
	wire		[3:0]	w_palette_num;
	wire		[2:0]	w_palette_r;
	wire		[2:0]	w_palette_g;
	wire		[2:0]	w_palette_b;

	wire		[16:0]	w_cpu_vram_address;
	wire				w_cpu_vram_valid;
	wire				w_cpu_vram_write;
	wire		[7:0]	w_cpu_vram_wdata;
	wire		[7:0]	w_cpu_vram_rdata;
	wire				w_cpu_vram_rdata_en;

	wire		[16:0]	w_screen_mode_vram_address;
	wire				w_screen_mode_vram_valid;
	wire		[31:0]	w_screen_mode_vram_rdata;
	wire		[7:0]	w_screen_mode_display_color;

	wire		[16:0]	w_sprite_vram_address;
	wire				w_sprite_vram_valid;
	wire		[31:0]	w_sprite_vram_rdata;
	wire		[7:0]	w_sprite_vram_rdata8;
	wire		[3:0]	w_sprite_display_color;
	wire				w_sprite_display_color_en;

	wire		[16:0]	w_command_vram_address;
	wire				w_command_vram_valid;
	wire				w_command_vram_ready;
	wire				w_command_vram_write;
	wire		[7:0]	w_command_vram_wdata;
	wire		[31:0]	w_command_vram_rdata;
	wire				w_command_vram_rdata_en;

	wire				w_clear_sprite_collision;
	wire				w_sprite_collision;
	wire				w_clear_sprite_collision_xy;
	wire		[8:0]	w_sprite_collision_x;
	wire		[9:0]	w_sprite_collision_y;

	wire		[4:0]	reg_screen_mode;
	wire				reg_sprite_magify;
	wire				reg_sprite_16x16;
	wire				reg_display_on;
	wire		[16:10]	reg_pattern_name_table_base;
	wire		[16:6]	reg_color_table_base;
	wire		[16:11]	reg_pattern_generator_table_base;
	wire		[16:7]	reg_sprite_attribute_table_base;
	wire		[16:11]	reg_sprite_pattern_generator_table_base;
	wire		[7:0]	reg_backdrop_color;
	wire				reg_sprite_disable;
	wire				reg_color0_opaque;
	wire				reg_50hz_mode;
	wire				reg_interleaving_mode;
	wire				reg_interlace_mode;
	wire				reg_212lines_mode;
	wire		[7:0]	reg_text_back_color;
	wire		[7:0]	reg_blink_period;
	wire		[7:0]	reg_display_adjust;
	wire		[7:0]	reg_interrupt_line;
	wire		[7:0]	reg_vertical_offset;
	wire				reg_scroll_planes;
	wire				reg_left_mask;
	wire				reg_yjk_mode;
	wire				reg_yae_mode;
	wire				reg_command_enable;
	wire		[2:0]	reg_horizontal_offset_l;
	wire		[8:3]	reg_horizontal_offset_h;

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
		.vram_address								( w_cpu_vram_address						),
		.vram_write									( w_cpu_vram_write							),
		.vram_valid									( w_cpu_vram_valid							),
		.vram_ready									( w_cpu_vram_ready							),
		.vram_wdata									( w_cpu_vram_wdata							),
		.vram_rdata									( w_cpu_vram_rdata							),
		.vram_rdata_en								( w_cpu_vram_rdata_en						),
		.int_n										( int_n										),
		.intr_line									( w_intr_line								),
		.intr_frame									( w_intr_frame								),
		.palette_valid								( w_palette_valid							),
		.palette_num								( w_palette_num								),
		.palette_r									( w_palette_r								),
		.palette_g									( w_palette_g								),
		.palette_b									( w_palette_b								),
		.clear_sprite_collision						( w_clear_sprite_collision					),
		.sprite_collision							( w_sprite_collision						),
		.clear_sprite_collision_xy					( w_clear_sprite_collision_xy				),
		.sprite_collision_x							( w_sprite_collision_x						),
		.sprite_collision_y							( w_sprite_collision_y						),
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
		.reg_display_adjust							( reg_display_adjust						),
		.reg_interrupt_line							( reg_interrupt_line						),
		.reg_vertical_offset						( reg_vertical_offset						),
		.reg_scroll_planes							( reg_scroll_planes							),
		.reg_left_mask								( reg_left_mask								),
		.reg_yjk_mode								( reg_yjk_mode								),
		.reg_yae_mode								( reg_yae_mode								),
		.reg_command_enable							( reg_command_enable						),
		.reg_horizontal_offset_l					( reg_horizontal_offset_l					),
		.reg_horizontal_offset_h					( reg_horizontal_offset_h					)
	);

	// --------------------------------------------------------------------
	//	Timing control
	// --------------------------------------------------------------------
	vdp_timing_control u_timing_control (
		.reset_n									( reset_n									),
		.clk										( clk										),
		.h_count									( w_h_count									),
		.v_count									( w_v_count									),
		.screen_pos_x								( w_screen_pos_x							),
		.screen_pos_y								( w_screen_pos_y							),
		.intr_line									( w_intr_line								),
		.intr_frame									( w_intr_frame								),
		.screen_mode_vram_address					( w_screen_mode_vram_address				),
		.screen_mode_vram_valid						( w_screen_mode_vram_valid					),
		.screen_mode_vram_rdata						( w_screen_mode_vram_rdata					),
		.screen_mode_display_color					( w_screen_mode_display_color				),
		.sprite_vram_address						( w_sprite_vram_address						),
		.sprite_vram_valid							( w_sprite_vram_valid						),
		.sprite_vram_rdata							( w_sprite_vram_rdata						),
		.sprite_vram_rdata8							( w_sprite_vram_rdata8						),
		.sprite_display_color						( w_sprite_display_color					),
		.sprite_display_color_en					( w_sprite_display_color_en					),
		.clear_sprite_collision						( w_clear_sprite_collision					),
		.sprite_collision							( w_sprite_collision						),
		.clear_sprite_collision_xy					( w_clear_sprite_collision_xy				),
		.sprite_collision_x							( w_sprite_collision_x						),
		.sprite_collision_y							( w_sprite_collision_y						),
		.reg_50hz_mode								( reg_50hz_mode								),
		.reg_212lines_mode							( reg_212lines_mode							),
		.reg_interlace_mode							( reg_interlace_mode						),
		.reg_display_adjust							( reg_display_adjust						),
		.reg_interrupt_line							( reg_interrupt_line						),
		.reg_vertical_offset						( reg_vertical_offset						),
		.reg_horizontal_offset_l					( reg_horizontal_offset_l					),
		.reg_horizontal_offset_h					( reg_horizontal_offset_h					),
		.reg_screen_mode							( reg_screen_mode							),
		.reg_display_on								( reg_display_on							),
		.reg_color0_opaque							( reg_color0_opaque							),
		.reg_pattern_name_table_base				( reg_pattern_name_table_base				),
		.reg_color_table_base						( reg_color_table_base						),
		.reg_pattern_generator_table_base			( reg_pattern_generator_table_base			),
		.reg_sprite_attribute_table_base			( reg_sprite_attribute_table_base			),
		.reg_sprite_pattern_generator_table_base	( reg_sprite_pattern_generator_table_base	),
		.reg_sprite_magify							( reg_sprite_magify							),
		.reg_sprite_16x16							( reg_sprite_16x16							),
		.reg_sprite_disable							( reg_sprite_disable						),
		.reg_backdrop_color							( reg_backdrop_color						),
		.reg_left_mask								( reg_left_mask								)
	);

	// --------------------------------------------------------------------
	//	VDP Command Processor
	// --------------------------------------------------------------------
	assign w_command_vram_address	= 17'd0;
	assign w_command_vram_valid		= 1'b0;
	assign w_command_vram_write		= 1'b0;
	assign w_command_vram_wdata		= 8'd0;

	// --------------------------------------------------------------------
	//	VRAM interface
	// --------------------------------------------------------------------
	vdp_vram_interface u_vram_interface (
		.reset_n									( reset_n									),
		.clk										( clk										),
		.initial_busy								( initial_busy								),
		.h_count									( w_h_count[3:0]							),
		.screen_mode_vram_address					( w_screen_mode_vram_address				),
		.screen_mode_vram_valid						( w_screen_mode_vram_valid					),
		.screen_mode_vram_rdata						( w_screen_mode_vram_rdata					),
		.sprite_vram_address						( w_sprite_vram_address						),
		.sprite_vram_valid							( w_sprite_vram_valid						),
		.sprite_vram_rdata							( w_sprite_vram_rdata						),
		.sprite_vram_rdata8							( w_sprite_vram_rdata8						),
		.command_vram_address						( w_command_vram_address					),
		.command_vram_valid							( w_command_vram_valid						),
		.command_vram_ready							( w_command_vram_ready						),
		.command_vram_write							( w_command_vram_write						),
		.command_vram_wdata							( w_command_vram_wdata						),
		.command_vram_rdata							( w_command_vram_rdata						),
		.command_vram_rdata_en						( w_command_vram_rdata_en					),
		.cpu_vram_address							( w_cpu_vram_address						),
		.cpu_vram_valid								( w_cpu_vram_valid							),
		.cpu_vram_ready								( w_cpu_vram_ready							),
		.cpu_vram_write								( w_cpu_vram_write							),
		.cpu_vram_wdata								( w_cpu_vram_wdata							),
		.cpu_vram_rdata								( w_cpu_vram_rdata							),
		.cpu_vram_rdata_en							( w_cpu_vram_rdata_en						),
		.vram_address								( vram_address								),
		.vram_valid									( vram_valid								),
		.vram_write									( vram_write								),
		.vram_wdata									( vram_wdata								),
		.vram_rdata									( vram_rdata								),
		.vram_rdata_en								( vram_rdata_en								)
	);

	// --------------------------------------------------------------------
	//	Color palette
	// --------------------------------------------------------------------
	vdp_color_palette u_color_palette (
		.reset_n									( reset_n									),
		.clk										( clk										),
		.screen_pos_x								( w_screen_pos_x[2:0]						),
		.palette_valid								( w_palette_valid							),
		.palette_num								( w_palette_num								),
		.palette_r									( w_palette_r								),
		.palette_g									( w_palette_g								),
		.palette_b									( w_palette_b								),
		.display_color_screen_mode					( w_screen_mode_display_color				),
		.display_color_sprite						( w_sprite_display_color					),
		.display_color_sprite_en					( w_sprite_display_color_en					),
		.vdp_r										( w_vdp_r									),
		.vdp_g										( w_vdp_g									),
		.vdp_b										( w_vdp_b									),
		.reg_screen_mode							( reg_screen_mode							),
		.reg_yjk_mode								( reg_yjk_mode								),
		.reg_yae_mode								( reg_yae_mode								),
		.reg_color0_opaque							( reg_color0_opaque							)
	);

	// --------------------------------------------------------------------
	//	Upscan
	// --------------------------------------------------------------------
	vdp_upscan u_upscan (
		.clk										( clk										),
		.screen_pos_x								( w_screen_pos_x							),
		.screen_pos_y								( w_screen_pos_y							),
		.h_count									( w_h_count									),
		.v_count									( w_v_count									),
		.reg_display_adjust							( reg_display_adjust[3:0]					),
		.vdp_r										( w_vdp_r									),
		.vdp_g										( w_vdp_g									),
		.vdp_b										( w_vdp_b									),
		.upscan_r									( w_upscan_r								),
		.upscan_g									( w_upscan_g								),
		.upscan_b									( w_upscan_b								)
	);

	// --------------------------------------------------------------------
	//	Video out
	// --------------------------------------------------------------------
	vdp_video_out u_video_out (
		.clk										( clk										),
		.reset_n									( reset_n									),
		.h_count									( w_h_count									),
		.v_count									( w_v_count									),
		.has_scanline								( 1'b1										),
		.vdp_r										( w_upscan_r								),
		.vdp_g										( w_upscan_g								),
		.vdp_b										( w_upscan_b								),
		.display_hs									( display_hs								),
		.display_vs									( display_vs								),
		.display_en									( display_en								),
		.display_r									( display_r									),
		.display_g									( display_g									),
		.display_b									( display_b									),
		.reg_denominator							( 8'd200									),
		.reg_normalize								( 8'd41										)
	);
endmodule
