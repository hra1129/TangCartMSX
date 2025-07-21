//
//	vdp_sprite_makeup_pixel.v
//	Makeup pixel pattern for Timing Control Sprite
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

module vdp_sprite_makeup_pixel (
	input				reset_n,
	input				clk,					//	42.95454MHz

	input		[12:0]	screen_pos_x,
	input				screen_active,

	input				sprite_mode2,
	input				reg_display_on,
	input				reg_sprite_magify,
	input				reg_sprite_16x16,
	//	from select_visible_planes
	input		[3:0]	selected_count,
	//	from info_collect
	input		[2:0]	makeup_plane,
	input		[7:0]	plane_x,
	input				plane_x_en,
	input		[7:0]	pattern_left,
	input				pattern_left_en,
	input		[7:0]	pattern_right,
	input				pattern_right_en,
	input		[7:0]	color,
	input				color_en,
	//	to color_palette
	output		[3:0]	display_color,
	output				display_color_en
);
	reg					ff_active;
	reg			[3:0]	ff_planes;
	reg			[3:0]	ff_current_plane;
	reg			[15:0]	ff_pattern0;
	reg			[15:0]	ff_pattern1;
	reg			[15:0]	ff_pattern2;
	reg			[15:0]	ff_pattern3;
	reg			[15:0]	ff_pattern4;
	reg			[15:0]	ff_pattern5;
	reg			[15:0]	ff_pattern6;
	reg			[15:0]	ff_pattern7;
	wire		[7:0]	w_pattern_left;
	wire		[7:0]	w_pattern_right;
	wire		[15:0]	w_pattern;
	reg			[7:0]	ff_color0;
	reg			[7:0]	ff_color1;
	reg			[7:0]	ff_color2;
	reg			[7:0]	ff_color3;
	reg			[7:0]	ff_color4;
	reg			[7:0]	ff_color5;
	reg			[7:0]	ff_color6;
	reg			[7:0]	ff_color7;
	wire		[7:0]	w_color;
	reg			[7:0]	ff_x0;
	reg			[7:0]	ff_x1;
	reg			[7:0]	ff_x2;
	reg			[7:0]	ff_x3;
	reg			[7:0]	ff_x4;
	reg			[7:0]	ff_x5;
	reg			[7:0]	ff_x6;
	reg			[7:0]	ff_x7;
	wire		[7:0]	w_x;
	wire		[2:0]	w_sub_phase;
	wire				w_active;
	reg					ff_pre_pixel_color_en;
	reg			[3:0]	ff_pre_pixel_color;
	reg					ff_pixel_color_en;
	reg			[3:0]	ff_pixel_color;
	wire		[ 9:0]	w_offset_x;
	wire		[ 9:3]	w_overflow;
	wire				w_sprite_en;
	wire		[4:0]	w_ec_shift;
	wire		[3:0]	w_bit_sel;
	reg			[7:0]	ff_color;
	reg					ff_color_en;
	reg			[4:0]	ff_pixel_color_d0;
	reg			[4:0]	ff_pixel_color_d1;
	reg			[4:0]	ff_pixel_color_d2;
	reg			[4:0]	ff_pixel_color_d3;
	reg			[4:0]	ff_pixel_color_d4;
	reg			[4:0]	ff_pixel_color_d5;

	// --------------------------------------------------------------------
	//	Latch information for visible sprite planes
	// --------------------------------------------------------------------
	assign w_pattern_left	= { pattern_left[0] , pattern_left[1] , pattern_left[2] , pattern_left[3] , pattern_left[4] , pattern_left[5] , pattern_left[6] , pattern_left[7]  };
	assign w_pattern_right	= { pattern_right[0], pattern_right[1], pattern_right[2], pattern_right[3], pattern_right[4], pattern_right[5], pattern_right[6], pattern_right[7] };

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_pattern0 <= 16'd0;
			ff_pattern1 <= 16'd0;
			ff_pattern2 <= 16'd0;
			ff_pattern3 <= 16'd0;
			ff_pattern4 <= 16'd0;
			ff_pattern5 <= 16'd0;
			ff_pattern6 <= 16'd0;
			ff_pattern7 <= 16'd0;
		end
		else if( pattern_left_en ) begin
			case( makeup_plane )
			3'd0:		ff_pattern0[ 7: 0]	<= w_pattern_left;
			3'd1:		ff_pattern1[ 7: 0]	<= w_pattern_left;
			3'd2:		ff_pattern2[ 7: 0]	<= w_pattern_left;
			3'd3:		ff_pattern3[ 7: 0]	<= w_pattern_left;
			3'd4:		ff_pattern4[ 7: 0]	<= w_pattern_left;
			3'd5:		ff_pattern5[ 7: 0]	<= w_pattern_left;
			3'd6:		ff_pattern6[ 7: 0]	<= w_pattern_left;
			3'd7:		ff_pattern7[ 7: 0]	<= w_pattern_left;
			default:	ff_pattern0[ 7: 0]	<= w_pattern_left;
			endcase
		end
		else if( pattern_right_en ) begin
			case( makeup_plane )
			3'd0:		ff_pattern0[15: 8]	<= w_pattern_right;
			3'd1:		ff_pattern1[15: 8]	<= w_pattern_right;
			3'd2:		ff_pattern2[15: 8]	<= w_pattern_right;
			3'd3:		ff_pattern3[15: 8]	<= w_pattern_right;
			3'd4:		ff_pattern4[15: 8]	<= w_pattern_right;
			3'd5:		ff_pattern5[15: 8]	<= w_pattern_right;
			3'd6:		ff_pattern6[15: 8]	<= w_pattern_right;
			3'd7:		ff_pattern7[15: 8]	<= w_pattern_right;
			default:	ff_pattern0[15: 8]	<= w_pattern_right;
			endcase
		end
	end

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_color0 <= 8'd0;
			ff_color1 <= 8'd0;
			ff_color2 <= 8'd0;
			ff_color3 <= 8'd0;
			ff_color4 <= 8'd0;
			ff_color5 <= 8'd0;
			ff_color6 <= 8'd0;
			ff_color7 <= 8'd0;
		end
		else if( color_en ) begin
			case( makeup_plane )
			3'd0:		ff_color0	<= color;
			3'd1:		ff_color1	<= color;
			3'd2:		ff_color2	<= color;
			3'd3:		ff_color3	<= color;
			3'd4:		ff_color4	<= color;
			3'd5:		ff_color5	<= color;
			3'd6:		ff_color6	<= color;
			3'd7:		ff_color7	<= color;
			default:	ff_color0	<= color;
			endcase
		end
	end

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_x0 <= 8'd0;
			ff_x1 <= 8'd0;
			ff_x2 <= 8'd0;
			ff_x3 <= 8'd0;
			ff_x4 <= 8'd0;
			ff_x5 <= 8'd0;
			ff_x6 <= 8'd0;
			ff_x7 <= 8'd0;
		end
		else if( plane_x_en ) begin
			case( makeup_plane )
			3'd0:		ff_x0	<= plane_x;
			3'd1:		ff_x1	<= plane_x;
			3'd2:		ff_x2	<= plane_x;
			3'd3:		ff_x3	<= plane_x;
			3'd4:		ff_x4	<= plane_x;
			3'd5:		ff_x5	<= plane_x;
			3'd6:		ff_x6	<= plane_x;
			3'd7:		ff_x7	<= plane_x;
			default:	ff_x0	<= plane_x;
			endcase
		end
	end

	// --------------------------------------------------------------------
	//	Control signals
	// --------------------------------------------------------------------
	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_active			<= 1'b0;
			ff_planes			<= 4'd0;
			ff_current_plane	<= 4'd0;
		end
		else if( screen_pos_x == 13'h1FFF ) begin
			ff_active			<= reg_display_on;
			ff_planes			<= selected_count;
			ff_current_plane	<= 4'd0;
		end
		else if( w_sub_phase == 3'd7 ) begin
			ff_current_plane	<= 4'd0;
		end
		else if( w_active ) begin
			ff_current_plane	<= ff_current_plane + 4'd1;
		end
	end

	assign w_sub_phase	= screen_pos_x[2:0];
	assign w_active		= ( ff_current_plane != ff_planes ) ? ff_active: 1'b0;

	// --------------------------------------------------------------------
	//	[delay 0] Select the current sprite plane
	// --------------------------------------------------------------------
	function [15:0] func_word_selector(
		input	[2:0]	current_plane,
		input	[15:0]	word0,
		input	[15:0]	word1,
		input	[15:0]	word2,
		input	[15:0]	word3,
		input	[15:0]	word4,
		input	[15:0]	word5,
		input	[15:0]	word6,
		input	[15:0]	word7
	);
		case( current_plane )
		3'd0:		func_word_selector = word0;
		3'd1:		func_word_selector = word1;
		3'd2:		func_word_selector = word2;
		3'd3:		func_word_selector = word3;
		3'd4:		func_word_selector = word4;
		3'd5:		func_word_selector = word5;
		3'd6:		func_word_selector = word6;
		3'd7:		func_word_selector = word7;
		default:	func_word_selector = word0;
		endcase
	endfunction

	function [7:0] func_byte_selector(
		input	[2:0]	current_plane,
		input	[7:0]	byte0,
		input	[7:0]	byte1,
		input	[7:0]	byte2,
		input	[7:0]	byte3,
		input	[7:0]	byte4,
		input	[7:0]	byte5,
		input	[7:0]	byte6,
		input	[7:0]	byte7
	);
		case( current_plane )
		3'd0:		func_byte_selector = byte0;
		3'd1:		func_byte_selector = byte1;
		3'd2:		func_byte_selector = byte2;
		3'd3:		func_byte_selector = byte3;
		3'd4:		func_byte_selector = byte4;
		3'd5:		func_byte_selector = byte5;
		3'd6:		func_byte_selector = byte6;
		3'd7:		func_byte_selector = byte7;
		default:	func_byte_selector = byte0;
		endcase
	endfunction

	assign w_pattern	= func_word_selector( 
			ff_current_plane[2:0],
			ff_pattern0,
			ff_pattern1,
			ff_pattern2,
			ff_pattern3,
			ff_pattern4,
			ff_pattern5,
			ff_pattern6,
			ff_pattern7
	);

	assign w_color		= func_byte_selector(
			ff_current_plane[2:0],
			ff_color0,
			ff_color1,
			ff_color2,
			ff_color3,
			ff_color4,
			ff_color5,
			ff_color6,
			ff_color7
	);

	assign w_x			= func_byte_selector(
			ff_current_plane[2:0],
			ff_x0,
			ff_x1,
			ff_x2,
			ff_x3,
			ff_x4,
			ff_x5,
			ff_x6,
			ff_x7
	);

	assign w_offset_x	= screen_pos_x[12:3] - { 2'd0, w_x };
	assign w_overflow	= ( !reg_sprite_16x16 && !reg_sprite_magify ) ?   w_offset_x[9:3]:			// 8x8 normal
	                 	  (  reg_sprite_16x16 &&  reg_sprite_magify ) ? { w_offset_x[9:5], 2'd0 }:	// 16x16 magnify
	                 	                                                { w_offset_x[9:4], 1'd0 };	// 8x8 magnify or 16x16 normal

	assign w_ec_shift	= w_color[7] ? 7'b1111100: 7'b0000000;
	assign w_sprite_en	= ( w_overflow == w_ec_shift );
	assign w_bit_sel	= reg_sprite_magify ? w_offset_x[4:1]: w_offset_x[3:0];

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_color_en		<= 1'b0;
			ff_color		<= 4'd0;
		end
		else begin
			ff_color_en		<= w_sprite_en & w_pattern[ w_bit_sel ] & w_active & screen_active;
			ff_color		<= w_color[3:0];
		end
	end

	// --------------------------------------------------------------------
	//	[delay 1...8] Mix 8 planes
	// --------------------------------------------------------------------
	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_pre_pixel_color_en	<= 1'b0;
			ff_pre_pixel_color		<= 4'd0;
		end
		else if( screen_pos_x == 13'h1FFF ) begin
			ff_pre_pixel_color_en	<= 1'b0;
			ff_pre_pixel_color		<= 4'd0;
		end
		else if( w_sub_phase == 3'd1 ) begin
			ff_pre_pixel_color_en	<= ff_color_en;
			ff_pre_pixel_color		<= ff_color;
		end
		else begin
			if( !ff_pre_pixel_color_en ) begin
				ff_pre_pixel_color_en	<= ff_color_en;
				ff_pre_pixel_color		<= ff_color;
			end
			else begin
				//	The dots of the sprite with the highest priority are already plotted.
			end
		end
	end

	// --------------------------------------------------------------------
	//	[delay 9] latch pixel color
	// --------------------------------------------------------------------
	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_pixel_color_en	<= 1'b0;
			ff_pixel_color		<= 4'd0;
		end
		else if( screen_pos_x == 13'h1FFF ) begin
			ff_pixel_color_en	<= 1'b0;
			ff_pixel_color		<= 4'd0;
		end
		else if( w_sub_phase == 3'd1 ) begin
			ff_pixel_color_en	<= ff_pre_pixel_color_en;
			ff_pixel_color		<= ff_pre_pixel_color;
		end
	end

	always @( posedge clk or negedge reset_n ) begin
        if( !reset_n ) begin
            ff_pixel_color_d0 <= 5'd0;
            ff_pixel_color_d1 <= 5'd0;
            ff_pixel_color_d2 <= 5'd0;
            ff_pixel_color_d3 <= 5'd0;
            ff_pixel_color_d4 <= 5'd0;
            ff_pixel_color_d5 <= 5'd0;
        end
		else if( w_sub_phase == 3'd7 ) begin
			ff_pixel_color_d0 <= { ff_pixel_color_en, ff_pixel_color };
			ff_pixel_color_d1 <= ff_pixel_color_d0;
			ff_pixel_color_d2 <= ff_pixel_color_d1;
			ff_pixel_color_d3 <= ff_pixel_color_d2;
			ff_pixel_color_d4 <= ff_pixel_color_d3;
			ff_pixel_color_d5 <= ff_pixel_color_d4;
		end
	end

	assign display_color_en		= ff_pixel_color_d5[4];
	assign display_color		= ff_pixel_color_d5[3:0];
endmodule
