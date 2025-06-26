//
//	vdp_timing_control_g123m.v
//	Graphic 1, 2, 3 and Mosaic mode timing generator for Timing Control
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

module vdp_timing_control_g123m (
	input				reset_n,
	input				clk,					//	42.95454MHz

	input		[10:0]	screen_pos_x,
	input		[ 9:0]	screen_pos_y,
	input				screen_active,
	input				dot_phase,

	input		[4:0]	reg_screen_mode,
	input		[16:10]	reg_pattern_name_table_base,
	input		[16:6]	reg_color_table_base,
	input		[16:11]	reg_pattern_generator_table_base,

	output		[16:0]	vram_read_address,
	output				vram_read_valid,
	input		[7:0]	vram_read_data
);
	//	Screen mode
	localparam			c_mode_g1	= 5'b000_00;	//	Graphic1 (SCREEN1)
	localparam			c_mode_g2	= 5'b001_00;	//	Graphic2 (SCREEN2)
	localparam			c_mode_g3	= 5'b010_00;	//	Graphic3 (SCREEN4)
	localparam			c_mode_gm	= 5'b000_10;	//	Mosaic   (SCREEN3)
	localparam			c_mode_gmq	= 5'b001_10;	//	Mosaic   (SCREEN3)
	wire		[3:0]	w_mode;
	localparam			c_g1		= 0;			//	Graphic1 (SCREEN1) w_mode index
	localparam			c_g2		= 1;			//	Graphic2 (SCREEN2) w_mode index
	localparam			c_g3		= 2;			//	Graphic3 (SCREEN4) w_mode index
	localparam			c_gm		= 3;			//	Mosaic   (SCREEN3) w_mode index
	//	Phase
	wire		[2:0]	w_phase;
	wire		[1:0]	w_sub_phase;
	//	Position
	wire		[7:0]	w_pos_x;
	wire		[7:0]	w_pos_y;
	//	Pattern name table address
	wire		[16:0]	w_pattern_name;
	reg			[7:0]	ff_pattern_num;
	//	Pattern generator table address
	wire		[16:0]	w_pattern_generator_g1;
	wire		[16:0]	w_pattern_generator_g23;
	wire		[16:0]	w_pattern_generator;
	//	VRAM address
	reg			[16:0]	ff_vram_read_address;
	reg					ff_vram_read_valid;

	// --------------------------------------------------------------------
	//	Screen mode decoder
	// --------------------------------------------------------------------
	function [3:0] func_screen_mode_decoder(
		input	[4:0]	reg_screen_mode
	);
		case( reg_screen_mode )
		c_mode_g1:				func_screen_mode_decoder = 4'b0001;
		c_mode_g2:				func_screen_mode_decoder = 4'b0010;
		c_mode_g3:				func_screen_mode_decoder = 4'b0100;
		c_mode_gm, c_mode_gmq:	func_screen_mode_decoder = 4'b1000;
		default:				func_screen_mode_decoder = 4'b0000;
		endcase
	endfunction

	assign w_mode		= func_screen_mode_decoder( reg_screen_mode );

	// --------------------------------------------------------------------
	//	Screen Position for active area
	// --------------------------------------------------------------------
	assign w_pos_x		= screen_pos_x[9:3];
	assign w_pos_y		= screen_pos_y[7:0];

	// --------------------------------------------------------------------
	//	Phase
	// --------------------------------------------------------------------
	assign w_phase		= screen_pos_x[5:3];
	assign w_sub_phase	= screen_pos_x[2:0];

	// --------------------------------------------------------------------
	//	Pattern name table address
	// --------------------------------------------------------------------
	assign w_pattern_name				= { reg_pattern_name_table_base, w_pos_y[7:3], w_pos_x[7:5] };

	// --------------------------------------------------------------------
	//	Pattern generator table address
	// --------------------------------------------------------------------
	assign w_pattern_generator_g1		= { reg_pattern_generator_table_base, ff_pattern_num, w_pos_y[2:0] };
	assign w_pattern_generator_g23		= { reg_pattern_generator_table_base[16:13], (w_pos_y[7:6] & reg_pattern_generator_table_base[12:11]), ff_pattern_num, w_pos_y[2:0] };
	assign w_pattern_generator			= w_mode[ c_g1 ] ? w_pattern_generator_g1: w_pattern_generator_g23;

	// --------------------------------------------------------------------
	//	Color table address
	// --------------------------------------------------------------------
	assign w_color_g1					= { reg_color_table_base, 1'b0, ff_pattern_num[7:3] };
	assign w_color_g23					= { reg_color_table_base[16:13], (w_pos_y[7:6] & reg_color_table_base[12:11]), (ff_pattern_num[7:3] & reg_color_table_base[10:6]), ff_pattern_num[2:0], w_pos_y[2:0] };
	assign w_color_m					= { reg_pattern_generator_table_base, ff_pattern_num, w_pos_y[4:2] };
	assign w_color						= w_mode[ c_g1 ] ? w_color_g1:
										  w_mode[ c_m  ] ? w_color_m : w_color_g23;

	
endmodule
