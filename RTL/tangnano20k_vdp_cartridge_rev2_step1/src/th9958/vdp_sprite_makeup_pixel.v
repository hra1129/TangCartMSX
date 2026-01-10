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

	input		[13:0]	screen_pos_x,
	input		[7:0]	pixel_pos_y,
	input				screen_v_active,

	input				sprite_mode2,
	input				reg_display_on,
	input				reg_color0_opaque,
	input				reg_sprite_magify,
	input				reg_sprite_16x16,
	input				reg_sprite_mode3,
	//	from select_visible_planes
	input		[4:0]	selected_count,
	//	from info_collect
	input		[3:0]	makeup_plane,
	input		[9:0]	plane_x,
	input		[7:0]	color,
	input		[7:0]	info_mgx,
	input				color_plane_x_en,
	input		[31:0]	pattern,
	input				pattern_left_en,
	input				pattern_right_en,
	//	to/from divider
	output		[7:0]	x,
	output		[7:0]	mgx,
	input		[6:0]	sample_x,
	//	to color_palette
	output		[7:0]	display_color,
	output		[1:0]	display_color_transparent,
	output				display_color_en,
	//	to cpu_interface
	input				clear_sprite_collision,
	output				sprite_collision,
	input				clear_sprite_collision_xy,
	output		[8:0]	sprite_collision_x,
	output		[9:0]	sprite_collision_y
);
	reg					ff_active;
	reg			[4:0]	ff_visible_planes;
	reg			[4:0]	ff_current_plane;
	reg			[63:0]	ff_pattern0;
	reg			[63:0]	ff_pattern1;
	reg			[63:0]	ff_pattern2;
	reg			[63:0]	ff_pattern3;
	reg			[63:0]	ff_pattern4;
	reg			[63:0]	ff_pattern5;
	reg			[63:0]	ff_pattern6;
	reg			[63:0]	ff_pattern7;
	reg			[63:0]	ff_pattern8;
	reg			[63:0]	ff_pattern9;
	reg			[63:0]	ff_pattern10;
	reg			[63:0]	ff_pattern11;
	reg			[63:0]	ff_pattern12;
	reg			[63:0]	ff_pattern13;
	reg			[63:0]	ff_pattern14;
	reg			[63:0]	ff_pattern15;
	wire		[7:0]	w_read_pattern12;
	wire		[63:0]	w_pattern;
	wire		[3:0]	w_sample_x;
	reg			[7:0]	ff_color0;
	reg			[7:0]	ff_color1;
	reg			[7:0]	ff_color2;
	reg			[7:0]	ff_color3;
	reg			[7:0]	ff_color4;
	reg			[7:0]	ff_color5;
	reg			[7:0]	ff_color6;
	reg			[7:0]	ff_color7;
	reg			[7:0]	ff_color8;
	reg			[7:0]	ff_color9;
	reg			[7:0]	ff_color10;
	reg			[7:0]	ff_color11;
	reg			[7:0]	ff_color12;
	reg			[7:0]	ff_color13;
	reg			[7:0]	ff_color14;
	reg			[7:0]	ff_color15;
	wire		[7:0]	w_color;
	reg			[9:0]	ff_x0;
	reg			[9:0]	ff_x1;
	reg			[9:0]	ff_x2;
	reg			[9:0]	ff_x3;
	reg			[9:0]	ff_x4;
	reg			[9:0]	ff_x5;
	reg			[9:0]	ff_x6;
	reg			[9:0]	ff_x7;
	reg			[9:0]	ff_x8;
	reg			[9:0]	ff_x9;
	reg			[9:0]	ff_x10;
	reg			[9:0]	ff_x11;
	reg			[9:0]	ff_x12;
	reg			[9:0]	ff_x13;
	reg			[9:0]	ff_x14;
	reg			[9:0]	ff_x15;
	reg			[7:0]	ff_mgx0;
	reg			[7:0]	ff_mgx1;
	reg			[7:0]	ff_mgx2;
	reg			[7:0]	ff_mgx3;
	reg			[7:0]	ff_mgx4;
	reg			[7:0]	ff_mgx5;
	reg			[7:0]	ff_mgx6;
	reg			[7:0]	ff_mgx7;
	reg			[7:0]	ff_mgx8;
	reg			[7:0]	ff_mgx9;
	reg			[7:0]	ff_mgx10;
	reg			[7:0]	ff_mgx11;
	reg			[7:0]	ff_mgx12;
	reg			[7:0]	ff_mgx13;
	reg			[7:0]	ff_mgx14;
	reg			[7:0]	ff_mgx15;
	wire		[9:0]	w_x;
	wire		[3:0]	w_sub_phase;
	wire				w_active;
	reg					ff_pre_pixel_color_en;
	reg			[1:0]	ff_pre_pixel_color_transparent;
	reg			[7:0]	ff_pre_pixel_color;
	reg					ff_pre_pixel_color_fix;
	reg					ff_pre_pixel_cc0_found;
	reg					ff_pixel_color_en;
	reg			[1:0]	ff_pixel_color_transparent;
	reg			[7:0]	ff_pixel_color;
	wire		[ 9:0]	w_offset_x;
	wire		[ 9:3]	w_overflow12;
	wire				w_sprite_en12;
	wire				w_sprite_en3;
	wire				w_sprite_en;
	wire		[4:0]	w_ec_shift;
	wire		[3:0]	w_bit_sel12;
	reg			[3:0]	ff_color;
	reg			[3:0]	ff_palette_set;
	reg			[1:0]	ff_transparent;
	reg					ff_color_cc;
	reg					ff_color_ic;
	reg					ff_color_en;
	reg			[10:0]	ff_pixel_color_d0;
	reg			[10:0]	ff_pixel_color_d1;
	reg			[10:0]	ff_pixel_color_d2;
	reg			[10:0]	ff_pixel_color_d3;
	reg			[10:0]	ff_pixel_color_d4;
	reg			[10:0]	ff_pixel_color_d5;
	reg					ff_sprite_collision;
	reg			[8:0]	ff_sprite_collision_x;
	reg			[9:0]	ff_sprite_collision_y;
	reg					ff_sprite_en1;
	reg					ff_sprite_en2;
	reg					ff_sprite_en3;
	reg			[7:0]	ff_color_1;
	reg			[7:0]	ff_color_2;
	reg			[7:0]	ff_color_3;
	reg			[3:0]	ff_bit_sel12_1;
	reg			[3:0]	ff_bit_sel12_2;
	reg			[3:0]	ff_bit_sel12_3;
	reg					ff_active1;
	reg					ff_active2;
	reg					ff_active3;
	reg			[4:0]	ff_current_plane1;
	reg			[4:0]	ff_current_plane2;
	reg			[4:0]	ff_current_plane3;
	wire		[7:0]	w_mgx;
	wire		[3:0]	w_pattern_m3;

	// --------------------------------------------------------------------
	//	Latch information for visible sprite planes
	// --------------------------------------------------------------------
	assign w_read_pattern12	= { pattern[0] , pattern[1] , pattern[2] , pattern[3] , pattern[4] , pattern[5] , pattern[6] , pattern[7]  };

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_pattern0 <= 64'd0;
			ff_pattern1 <= 64'd0;
			ff_pattern2 <= 64'd0;
			ff_pattern3 <= 64'd0;
			ff_pattern4 <= 64'd0;
			ff_pattern5 <= 64'd0;
			ff_pattern6 <= 64'd0;
			ff_pattern7 <= 64'd0;
			ff_pattern8 <= 64'd0;
			ff_pattern9 <= 64'd0;
			ff_pattern10 <= 64'd0;
			ff_pattern11 <= 64'd0;
			ff_pattern12 <= 64'd0;
			ff_pattern13 <= 64'd0;
			ff_pattern14 <= 64'd0;
			ff_pattern15 <= 64'd0;
		end
		else if( reg_sprite_mode3 ) begin
			if( pattern_left_en ) begin
				case( makeup_plane )
				4'd0:		ff_pattern0[ 31: 0]	<= pattern;
				4'd1:		ff_pattern1[ 31: 0]	<= pattern;
				4'd2:		ff_pattern2[ 31: 0]	<= pattern;
				4'd3:		ff_pattern3[ 31: 0]	<= pattern;
				4'd4:		ff_pattern4[ 31: 0]	<= pattern;
				4'd5:		ff_pattern5[ 31: 0]	<= pattern;
				4'd6:		ff_pattern6[ 31: 0]	<= pattern;
				4'd7:		ff_pattern7[ 31: 0]	<= pattern;
				4'd8:		ff_pattern8[ 31: 0]	<= pattern;
				4'd9:		ff_pattern9[ 31: 0]	<= pattern;
				4'd10:		ff_pattern10[31: 0]	<= pattern;
				4'd11:		ff_pattern11[31: 0]	<= pattern;
				4'd12:		ff_pattern12[31: 0]	<= pattern;
				4'd13:		ff_pattern13[31: 0]	<= pattern;
				4'd14:		ff_pattern14[31: 0]	<= pattern;
				4'd15:		ff_pattern15[31: 0]	<= pattern;
				default:	ff_pattern0[ 31: 0]	<= pattern;
				endcase
			end
			else if( pattern_right_en ) begin
				case( makeup_plane )
				4'd0:		ff_pattern0[ 63:32]	<= pattern;
				4'd1:		ff_pattern1[ 63:32]	<= pattern;
				4'd2:		ff_pattern2[ 63:32]	<= pattern;
				4'd3:		ff_pattern3[ 63:32]	<= pattern;
				4'd4:		ff_pattern4[ 63:32]	<= pattern;
				4'd5:		ff_pattern5[ 63:32]	<= pattern;
				4'd6:		ff_pattern6[ 63:32]	<= pattern;
				4'd7:		ff_pattern7[ 63:32]	<= pattern;
				4'd8:		ff_pattern8[ 63:32]	<= pattern;
				4'd9:		ff_pattern9[ 63:32]	<= pattern;
				4'd10:		ff_pattern10[63:32]	<= pattern;
				4'd11:		ff_pattern11[63:32]	<= pattern;
				4'd12:		ff_pattern12[63:32]	<= pattern;
				4'd13:		ff_pattern13[63:32]	<= pattern;
				4'd14:		ff_pattern14[63:32]	<= pattern;
				4'd15:		ff_pattern15[63:32]	<= pattern;
				default:	ff_pattern0[ 63:32]	<= pattern;
				endcase
			end
		end
		else begin
			if( pattern_left_en ) begin
				case( makeup_plane )
				4'd0:		ff_pattern0[ 7: 0]	<= w_read_pattern12;
				4'd1:		ff_pattern1[ 7: 0]	<= w_read_pattern12;
				4'd2:		ff_pattern2[ 7: 0]	<= w_read_pattern12;
				4'd3:		ff_pattern3[ 7: 0]	<= w_read_pattern12;
				4'd4:		ff_pattern4[ 7: 0]	<= w_read_pattern12;
				4'd5:		ff_pattern5[ 7: 0]	<= w_read_pattern12;
				4'd6:		ff_pattern6[ 7: 0]	<= w_read_pattern12;
				4'd7:		ff_pattern7[ 7: 0]	<= w_read_pattern12;
				4'd8:		ff_pattern8[ 7: 0]	<= w_read_pattern12;
				4'd9:		ff_pattern9[ 7: 0]	<= w_read_pattern12;
				4'd10:		ff_pattern10[ 7: 0]	<= w_read_pattern12;
				4'd11:		ff_pattern11[ 7: 0]	<= w_read_pattern12;
				4'd12:		ff_pattern12[ 7: 0]	<= w_read_pattern12;
				4'd13:		ff_pattern13[ 7: 0]	<= w_read_pattern12;
				4'd14:		ff_pattern14[ 7: 0]	<= w_read_pattern12;
				4'd15:		ff_pattern15[ 7: 0]	<= w_read_pattern12;
				default:	ff_pattern0[ 7: 0]	<= w_read_pattern12;
				endcase
			end
			else if( pattern_right_en ) begin
				case( makeup_plane )
				4'd0:		ff_pattern0[15: 8]	<= w_read_pattern12;
				4'd1:		ff_pattern1[15: 8]	<= w_read_pattern12;
				4'd2:		ff_pattern2[15: 8]	<= w_read_pattern12;
				4'd3:		ff_pattern3[15: 8]	<= w_read_pattern12;
				4'd4:		ff_pattern4[15: 8]	<= w_read_pattern12;
				4'd5:		ff_pattern5[15: 8]	<= w_read_pattern12;
				4'd6:		ff_pattern6[15: 8]	<= w_read_pattern12;
				4'd7:		ff_pattern7[15: 8]	<= w_read_pattern12;
				4'd8:		ff_pattern8[15: 8]	<= w_read_pattern12;
				4'd9:		ff_pattern9[15: 8]	<= w_read_pattern12;
				4'd10:		ff_pattern10[15: 8]	<= w_read_pattern12;
				4'd11:		ff_pattern11[15: 8]	<= w_read_pattern12;
				4'd12:		ff_pattern12[15: 8]	<= w_read_pattern12;
				4'd13:		ff_pattern13[15: 8]	<= w_read_pattern12;
				4'd14:		ff_pattern14[15: 8]	<= w_read_pattern12;
				4'd15:		ff_pattern15[15: 8]	<= w_read_pattern12;
				default:	ff_pattern0[15: 8]	<= w_read_pattern12;
				endcase
			end
		end
	end

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_color0  <= 8'd0;
			ff_color1  <= 8'd0;
			ff_color2  <= 8'd0;
			ff_color3  <= 8'd0;
			ff_color4  <= 8'd0;
			ff_color5  <= 8'd0;
			ff_color6  <= 8'd0;
			ff_color7  <= 8'd0;
			ff_color8  <= 8'd0;
			ff_color9  <= 8'd0;
			ff_color10 <= 8'd0;
			ff_color11 <= 8'd0;
			ff_color12 <= 8'd0;
			ff_color13 <= 8'd0;
			ff_color14 <= 8'd0;
			ff_color15 <= 8'd0;
		end
		else if( color_plane_x_en ) begin
			case( makeup_plane )
			4'd0:		ff_color0	<= color;
			4'd1:		ff_color1	<= color;
			4'd2:		ff_color2	<= color;
			4'd3:		ff_color3	<= color;
			4'd4:		ff_color4	<= color;
			4'd5:		ff_color5	<= color;
			4'd6:		ff_color6	<= color;
			4'd7:		ff_color7	<= color;
			4'd8:		ff_color8	<= color;
			4'd9:		ff_color9	<= color;
			4'd10:		ff_color10	<= color;
			4'd11:		ff_color11	<= color;
			4'd12:		ff_color12	<= color;
			4'd13:		ff_color13	<= color;
			4'd14:		ff_color14	<= color;
			4'd15:		ff_color15	<= color;
			default:	ff_color0	<= color;
			endcase
		end
	end

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_x0 <= 10'd0;
			ff_x1 <= 10'd0;
			ff_x2 <= 10'd0;
			ff_x3 <= 10'd0;
			ff_x4 <= 10'd0;
			ff_x5 <= 10'd0;
			ff_x6 <= 10'd0;
			ff_x7 <= 10'd0;
			ff_x8 <= 10'd0;
			ff_x9 <= 10'd0;
			ff_x10 <= 10'd0;
			ff_x11 <= 10'd0;
			ff_x12 <= 10'd0;
			ff_x13 <= 10'd0;
			ff_x14 <= 10'd0;
			ff_x15 <= 10'd0;
		end
		else if( color_plane_x_en ) begin
			case( makeup_plane )
			4'd0:		ff_x0	<= plane_x;
			4'd1:		ff_x1	<= plane_x;
			4'd2:		ff_x2	<= plane_x;
			4'd3:		ff_x3	<= plane_x;
			4'd4:		ff_x4	<= plane_x;
			4'd5:		ff_x5	<= plane_x;
			4'd6:		ff_x6	<= plane_x;
			4'd7:		ff_x7	<= plane_x;
			4'd8:		ff_x8	<= plane_x;
			4'd9:		ff_x9	<= plane_x;
			4'd10:		ff_x10	<= plane_x;
			4'd11:		ff_x11	<= plane_x;
			4'd12:		ff_x12	<= plane_x;
			4'd13:		ff_x13	<= plane_x;
			4'd14:		ff_x14	<= plane_x;
			4'd15:		ff_x15	<= plane_x;
			default:	ff_x0	<= plane_x;
			endcase
		end
	end

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_mgx0		<= 8'd0;
			ff_mgx1		<= 8'd0;
			ff_mgx2		<= 8'd0;
			ff_mgx3		<= 8'd0;
			ff_mgx4		<= 8'd0;
			ff_mgx5		<= 8'd0;
			ff_mgx6		<= 8'd0;
			ff_mgx7		<= 8'd0;
			ff_mgx8		<= 8'd0;
			ff_mgx9		<= 8'd0;
			ff_mgx10	<= 8'd0;
			ff_mgx11	<= 8'd0;
			ff_mgx12	<= 8'd0;
			ff_mgx13	<= 8'd0;
			ff_mgx14	<= 8'd0;
			ff_mgx15	<= 8'd0;
		end
		else if( color_plane_x_en ) begin
			case( makeup_plane )
			4'd0:		ff_mgx0		<= info_mgx;
			4'd1:		ff_mgx1		<= info_mgx;
			4'd2:		ff_mgx2		<= info_mgx;
			4'd3:		ff_mgx3		<= info_mgx;
			4'd4:		ff_mgx4		<= info_mgx;
			4'd5:		ff_mgx5		<= info_mgx;
			4'd6:		ff_mgx6		<= info_mgx;
			4'd7:		ff_mgx7		<= info_mgx;
			4'd8:		ff_mgx8		<= info_mgx;
			4'd9:		ff_mgx9		<= info_mgx;
			4'd10:		ff_mgx10	<= info_mgx;
			4'd11:		ff_mgx11	<= info_mgx;
			4'd12:		ff_mgx12	<= info_mgx;
			4'd13:		ff_mgx13	<= info_mgx;
			4'd14:		ff_mgx14	<= info_mgx;
			4'd15:		ff_mgx15	<= info_mgx;
			default:	ff_mgx0		<= info_mgx;
			endcase
		end
	end

	// --------------------------------------------------------------------
	//	Control signals
	// --------------------------------------------------------------------
	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_active			<= 1'b0;
			ff_visible_planes	<= 5'd0;
			ff_current_plane	<= 5'd0;
		end
		else if( screen_pos_x == 14'h3FFF ) begin
			ff_active			<= reg_display_on;
			ff_visible_planes	<= selected_count;
			ff_current_plane	<= 5'd0;
		end
		else if( screen_pos_x == 14'h0FFF ) begin
			ff_active			<= 1'b0;
		end
		else if( w_sub_phase == 4'd15 ) begin
			ff_current_plane	<= 5'd0;
		end
		else if( w_active ) begin
			ff_current_plane	<= ff_current_plane + 4'd1;
		end
	end

	assign w_sub_phase	= screen_pos_x[3:0];
	assign w_active		= ( ff_current_plane != ff_visible_planes ) ? ff_active: 1'b0;

	// --------------------------------------------------------------------
	//	[delay 0] Select the current sprite plane
	// --------------------------------------------------------------------
	function [63:0] func_word_selector(
		input	[3:0]	current_plane,
		input	[63:0]	word0,
		input	[63:0]	word1,
		input	[63:0]	word2,
		input	[63:0]	word3,
		input	[63:0]	word4,
		input	[63:0]	word5,
		input	[63:0]	word6,
		input	[63:0]	word7,
		input	[63:0]	word8,
		input	[63:0]	word9,
		input	[63:0]	word10,
		input	[63:0]	word11,
		input	[63:0]	word12,
		input	[63:0]	word13,
		input	[63:0]	word14,
		input	[63:0]	word15
	);
		case( current_plane )
		4'd0:		func_word_selector = word0;
		4'd1:		func_word_selector = word1;
		4'd2:		func_word_selector = word2;
		4'd3:		func_word_selector = word3;
		4'd4:		func_word_selector = word4;
		4'd5:		func_word_selector = word5;
		4'd6:		func_word_selector = word6;
		4'd7:		func_word_selector = word7;
		4'd8:		func_word_selector = word8;
		4'd9:		func_word_selector = word9;
		4'd10:		func_word_selector = word10;
		4'd11:		func_word_selector = word11;
		4'd12:		func_word_selector = word12;
		4'd13:		func_word_selector = word13;
		4'd14:		func_word_selector = word14;
		4'd15:		func_word_selector = word15;
		default:	func_word_selector = word0;
		endcase
	endfunction

	function [7:0] func_byte_selector(
		input	[3:0]	current_plane,
		input	[7:0]	byte0,
		input	[7:0]	byte1,
		input	[7:0]	byte2,
		input	[7:0]	byte3,
		input	[7:0]	byte4,
		input	[7:0]	byte5,
		input	[7:0]	byte6,
		input	[7:0]	byte7,
		input	[7:0]	byte8,
		input	[7:0]	byte9,
		input	[7:0]	byte10,
		input	[7:0]	byte11,
		input	[7:0]	byte12,
		input	[7:0]	byte13,
		input	[7:0]	byte14,
		input	[7:0]	byte15
	);
		case( current_plane )
		4'd0:		func_byte_selector = byte0;
		4'd1:		func_byte_selector = byte1;
		4'd2:		func_byte_selector = byte2;
		4'd3:		func_byte_selector = byte3;
		4'd4:		func_byte_selector = byte4;
		4'd5:		func_byte_selector = byte5;
		4'd6:		func_byte_selector = byte6;
		4'd7:		func_byte_selector = byte7;
		4'd8:		func_byte_selector = byte8;
		4'd9:		func_byte_selector = byte9;
		4'd10:		func_byte_selector = byte10;
		4'd11:		func_byte_selector = byte11;
		4'd12:		func_byte_selector = byte12;
		4'd13:		func_byte_selector = byte13;
		4'd14:		func_byte_selector = byte14;
		4'd15:		func_byte_selector = byte15;
		default:	func_byte_selector = byte0;
		endcase
	endfunction

	function [9:0] func_10bit_selector(
		input	[3:0]	current_plane,
		input	[9:0]	num0,
		input	[9:0]	num1,
		input	[9:0]	num2,
		input	[9:0]	num3,
		input	[9:0]	num4,
		input	[9:0]	num5,
		input	[9:0]	num6,
		input	[9:0]	num7,
		input	[9:0]	num8,
		input	[9:0]	num9,
		input	[9:0]	num10,
		input	[9:0]	num11,
		input	[9:0]	num12,
		input	[9:0]	num13,
		input	[9:0]	num14,
		input	[9:0]	num15
	);
		case( current_plane )
		4'd0:		func_10bit_selector = num0;
		4'd1:		func_10bit_selector = num1;
		4'd2:		func_10bit_selector = num2;
		4'd3:		func_10bit_selector = num3;
		4'd4:		func_10bit_selector = num4;
		4'd5:		func_10bit_selector = num5;
		4'd6:		func_10bit_selector = num6;
		4'd7:		func_10bit_selector = num7;
		4'd8:		func_10bit_selector = num8;
		4'd9:		func_10bit_selector = num9;
		4'd10:		func_10bit_selector = num10;
		4'd11:		func_10bit_selector = num11;
		4'd12:		func_10bit_selector = num12;
		4'd13:		func_10bit_selector = num13;
		4'd14:		func_10bit_selector = num14;
		4'd15:		func_10bit_selector = num15;
		default:	func_10bit_selector = num0;
		endcase
	endfunction

	function [1:0] func_2bit_selector(
		input	[3:0]	current_plane,
		input	[1:0]	num0,
		input	[1:0]	num1,
		input	[1:0]	num2,
		input	[1:0]	num3,
		input	[1:0]	num4,
		input	[1:0]	num5,
		input	[1:0]	num6,
		input	[1:0]	num7,
		input	[1:0]	num8,
		input	[1:0]	num9,
		input	[1:0]	num10,
		input	[1:0]	num11,
		input	[1:0]	num12,
		input	[1:0]	num13,
		input	[1:0]	num14,
		input	[1:0]	num15
	);
		case( current_plane )
		4'd0:		func_2bit_selector = num0;
		4'd1:		func_2bit_selector = num1;
		4'd2:		func_2bit_selector = num2;
		4'd3:		func_2bit_selector = num3;
		4'd4:		func_2bit_selector = num4;
		4'd5:		func_2bit_selector = num5;
		4'd6:		func_2bit_selector = num6;
		4'd7:		func_2bit_selector = num7;
		4'd8:		func_2bit_selector = num8;
		4'd9:		func_2bit_selector = num9;
		4'd10:		func_2bit_selector = num10;
		4'd11:		func_2bit_selector = num11;
		4'd12:		func_2bit_selector = num12;
		4'd13:		func_2bit_selector = num13;
		4'd14:		func_2bit_selector = num14;
		4'd15:		func_2bit_selector = num15;
		default:	func_2bit_selector = num0;
		endcase
	endfunction

	// --------------------------------------------------------------------
	//	w_sub_phase: 0
	// --------------------------------------------------------------------
	assign w_color		= func_byte_selector(
			ff_current_plane,
			ff_color0,
			ff_color1,
			ff_color2,
			ff_color3,
			ff_color4,
			ff_color5,
			ff_color6,
			ff_color7,
			ff_color8,
			ff_color9,
			ff_color10,
			ff_color11,
			ff_color12,
			ff_color13,
			ff_color14,
			ff_color15
	);

	assign w_x			= func_10bit_selector(
			ff_current_plane,
			ff_x0,
			ff_x1,
			ff_x2,
			ff_x3,
			ff_x4,
			ff_x5,
			ff_x6,
			ff_x7,
			ff_x8,
			ff_x9,
			ff_x10,
			ff_x11,
			ff_x12,
			ff_x13,
			ff_x14,
			ff_x15
	);

	assign w_mgx		= func_byte_selector(
			ff_current_plane,
			ff_mgx0,
			ff_mgx1,
			ff_mgx2,
			ff_mgx3,
			ff_mgx4,
			ff_mgx5,
			ff_mgx6,
			ff_mgx7,
			ff_mgx8,
			ff_mgx9,
			ff_mgx10,
			ff_mgx11,
			ff_mgx12,
			ff_mgx13,
			ff_mgx14,
			ff_mgx15
	);

	// --------------------------------------------------------------------
	//	w_sub_phase: 0
	// --------------------------------------------------------------------
	assign w_offset_x		= screen_pos_x[13:4] - w_x;
	assign x				= ff_active ? w_offset_x[7:0] : 8'd0;
	assign mgx				= ff_active ? w_mgx : 8'd0;
	assign w_overflow12		= ( !reg_sprite_16x16 && !reg_sprite_magify ) ?   w_offset_x[9:3]:			// 8x8 normal
	                 		  (  reg_sprite_16x16 &&  reg_sprite_magify ) ? { w_offset_x[9:5], 2'd0 }:	// 16x16 magnify
	                 		                                                { w_offset_x[9:4], 1'd0 };	// 8x8 magnify or 16x16 normal
	assign w_ec_shift		= { 5 { w_color[7] } };
	assign w_sprite_en12	= ( w_overflow12 == { w_ec_shift, 2'd0 } );
	assign w_sprite_en3		= ( w_offset_x[9:8] == 2'd0 && w_offset_x[7:0] < w_mgx ) ? w_active: 1'b0;
	assign w_sprite_en		= reg_sprite_mode3 ? w_sprite_en3: w_sprite_en12;
	assign w_bit_sel12		= reg_sprite_magify ? w_offset_x[4:1]: w_offset_x[3:0];

	// --------------------------------------------------------------------
	//	w_sub_phase: 3
	// --------------------------------------------------------------------
	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_active1			<= 1'b0;
			ff_active2			<= 1'b0;
			ff_active3			<= 1'b0;
		end
		else begin
			ff_active1			<= w_active;
			ff_active2			<= ff_active1;
			ff_active3			<= ff_active2;
		end
	end

	always @( posedge clk ) begin
		ff_sprite_en1		<= w_sprite_en;
		ff_sprite_en2		<= ff_sprite_en1;
		ff_sprite_en3		<= ff_sprite_en2;

		ff_bit_sel12_1		<= w_bit_sel12;
		ff_bit_sel12_2		<= ff_bit_sel12_1;
		ff_bit_sel12_3		<= ff_bit_sel12_2;

		ff_color_1			<= w_color;
		ff_color_2			<= ff_color_1;
		ff_color_3			<= ff_color_2;

		ff_current_plane1	<= ff_current_plane;
		ff_current_plane2	<= ff_current_plane1;
		ff_current_plane3	<= ff_current_plane2;
	end

	assign w_pattern	= func_word_selector( 
			ff_current_plane3,
			ff_pattern0,
			ff_pattern1,
			ff_pattern2,
			ff_pattern3,
			ff_pattern4,
			ff_pattern5,
			ff_pattern6,
			ff_pattern7,
			ff_pattern8,
			ff_pattern9,
			ff_pattern10,
			ff_pattern11,
			ff_pattern12,
			ff_pattern13,
			ff_pattern14,
			ff_pattern15
	);

	function [3:0] func_nibble_sel(
		input	[3:0]	sample_x,
		input	[63:0]	pattern
	);
		case( sample_x )
		4'd0:		func_nibble_sel = pattern[ 7: 4];
		4'd1:		func_nibble_sel = pattern[ 3: 0];
		4'd2:		func_nibble_sel = pattern[15:12];
		4'd3:		func_nibble_sel = pattern[11: 8];
		4'd4:		func_nibble_sel = pattern[23:20];
		4'd5:		func_nibble_sel = pattern[19:16];
		4'd6:		func_nibble_sel = pattern[31:28];
		4'd7:		func_nibble_sel = pattern[27:24];
		4'd8:		func_nibble_sel = pattern[39:36];
		4'd9:		func_nibble_sel = pattern[35:32];
		4'd10:		func_nibble_sel = pattern[47:44];
		4'd11:		func_nibble_sel = pattern[43:40];
		4'd12:		func_nibble_sel = pattern[55:52];
		4'd13:		func_nibble_sel = pattern[51:48];
		4'd14:		func_nibble_sel = pattern[63:60];
		default:	func_nibble_sel = pattern[59:56];
		endcase
	endfunction

	assign w_sample_x		= ff_color_3[4] ? ~sample_x[3:0]: sample_x[3:0];
	assign w_pattern_m3		= func_nibble_sel( w_sample_x, w_pattern );

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_color_en			<= 1'b0;
			ff_color			<= 4'd0;
			ff_color_cc			<= 1'b0;
			ff_color_ic			<= 1'b0;
			ff_palette_set		<= 4'd0;
			ff_transparent		<= 2'd0;
		end
		else if( reg_sprite_mode3 ) begin
			//	Sprite mode3
			if( w_pattern_m3 != 4'd0 ) begin
				ff_color_en			<= ff_sprite_en3 & ff_active3 & screen_v_active;
				ff_color			<= w_pattern_m3;
				ff_palette_set		<= ff_color_3[3:0];
				ff_transparent		<= ff_color_3[7:6];
			end
			else begin
				ff_color_en			<= 1'b0;
				ff_color			<= 4'd0;
				ff_palette_set		<= 4'd0;
				ff_transparent		<= 2'd0;
			end
			ff_color_cc			<= 1'b0;
			ff_color_ic			<= 1'b0;
		end
		else begin
			//	Sprite mode1 or mode2
			ff_color_en			<= ff_sprite_en3 & ff_active3 & screen_v_active & w_pattern[ ff_bit_sel12_3 ];
			ff_color			<= ff_color_3[3:0];
			ff_color_cc			<= ff_color_3[6];
			ff_color_ic			<= ff_color_3[5];
			ff_palette_set		<= 4'd0;
			ff_transparent		<= 2'd0;
		end
	end

	// --------------------------------------------------------------------
	//	[delay 3...15,0,1,2] Mix 16 planes
	// --------------------------------------------------------------------
	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_pre_pixel_color_en			<= 1'b0;
			ff_pre_pixel_color_transparent	<= 2'd0;
			ff_pre_pixel_color				<= 8'd0;
			ff_pre_pixel_color_fix			<= 1'b0;
			ff_pre_pixel_cc0_found			<= 1'b0;
		end
		else if( w_sub_phase == 4'd3 ) begin
			//	最初のスプライトプレーン。w_sub_phase = 3 → 1番目。4 → 2番目。 ... 2 → 16番目。
			if( reg_sprite_mode3 ) begin
				//	Sprite mode3 の場合
				if( ff_color_en ) begin
					//	最初のスプライトは表示（ドットがある）位置だった
					ff_pre_pixel_color_en			<= 1'b1;
					ff_pre_pixel_color				<= { ff_palette_set, ff_color };
					ff_pre_pixel_color_transparent	<= ff_transparent;
					ff_pre_pixel_color_fix			<= 1'b1;
					
				end
				else begin
					//	最初のスプライトは非表示（ドットがない）位置だった
					ff_pre_pixel_color_en			<= 1'b0;
					ff_pre_pixel_color				<= 8'd0;
					ff_pre_pixel_color_transparent	<= 2'd0;
					ff_pre_pixel_color_fix			<= 1'b0;
				end
			end
			//	Sprite mode1, mode2 の場合
			else if( !ff_color_cc ) begin
				//	着目プレーンが CC=0 の場合、ドットの有無にかかわらず CC=0 プレーンが出現したフラグを立てる
				ff_pre_pixel_cc0_found	<= 1'b1;
				ff_pre_pixel_color_fix	<= 1'b0;
				if( ff_color_en && (ff_color != 4'd0 || reg_color0_opaque) ) begin
					//	着目プレーンが CC=0 で、かつドットが存在する場合に描画
					ff_pre_pixel_color_en	<= 1'b1;
					ff_pre_pixel_color		<= { 4'd0, ff_color };
				end
				else begin
					ff_pre_pixel_color_en	<= 1'b0;
					ff_pre_pixel_color		<= 8'd0;
				end
			end
			else begin
				//	着目プレーンが CC=1 の場合、描画しない
				ff_pre_pixel_cc0_found	<= 1'b0;
				ff_pre_pixel_color_fix	<= 1'b0;
				ff_pre_pixel_color_en	<= 1'b0;
				ff_pre_pixel_color		<= 4'd0;
			end
		end
		else begin
			//	２番目以降スプライトプレーン。w_sub_phase = 3 → 1番目。4 → 2番目。 ... 2 → 16番目。
			if( ff_pre_pixel_color_fix ) begin
				//	hold
			end
			else if( reg_sprite_mode3 ) begin
				//	Sprite mode3 の場合
				if( ff_color_en ) begin
					//	最初のスプライトは表示（ドットがある）位置だった
					ff_pre_pixel_color_en			<= 1'b1;
					ff_pre_pixel_color				<= { ff_palette_set, ff_color };
					ff_pre_pixel_color_transparent	<= ff_transparent;
					ff_pre_pixel_color_fix			<= 1'b1;
					
				end
				else begin
					//	最初のスプライトは非表示（ドットがない）位置だった
					ff_pre_pixel_color_en			<= 1'b0;
					ff_pre_pixel_color				<= 8'd0;
					ff_pre_pixel_color_transparent	<= 2'd0;
					ff_pre_pixel_color_fix			<= 1'b0;
				end
			end
			else if( !ff_pre_pixel_cc0_found ) begin
				//	このドットに対して、CC=0 のプレーンが一度も現れていない場合
				if( !ff_color_cc ) begin
					//	着目プレーンが CC=0 の場合、ドットの有無にかかわらず CC=0 プレーンが出現したフラグを立てる
					ff_pre_pixel_cc0_found	<= 1'b1;
					if( ff_color_en && (ff_color != 4'd0 || reg_color0_opaque) ) begin
						//	着目プレーンが CC=0 で、かつドットが存在する場合に描画
						ff_pre_pixel_color_en	<= 1'b1;
						ff_pre_pixel_color		<= ff_color;
					end
				end
				else begin
					//	着目プレーンが CC=1 の場合、描画しない
				end
			end
			else if( ff_color_en && (ff_color != 4'd0 || reg_color0_opaque) ) begin
				if( ff_pre_pixel_color_en ) begin
					//	既にスプライトを描画済み
					if( ff_color_cc ) begin
						//	着目スプライトは CC=1 の場合は、OR合成。
						ff_pre_pixel_color		<= ff_pre_pixel_color | ff_color;
					end
					else begin
						//	既に描画済みで、着目スプライトは CC=0 の場合は、隠れて見えない。描画せず。
						ff_pre_pixel_color_fix	<= 1'b1;
					end
				end
				else begin
					//	初めての描画
					ff_pre_pixel_color_en	<= 1'b1;
					ff_pre_pixel_color		<= ff_color;
				end
			end
			else begin
				if( ff_pre_pixel_color_en && !ff_color_cc ) begin
					//	既に描画済みで、着目スプライトは CC=0 の場合は、隠れて見えない。描画せず。
					ff_pre_pixel_color_fix	<= 1'b1;
				end
			end
		end
	end

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_sprite_collision		<= 1'b0;
			ff_sprite_collision_x	<= 9'd0;
			ff_sprite_collision_y	<= 10'd0;
		end
		else if( clear_sprite_collision ) begin
			ff_sprite_collision		<= 1'b0;
		end
		else if( clear_sprite_collision_xy ) begin
			ff_sprite_collision_x	<= 9'd0;
			ff_sprite_collision_y	<= 10'd0;
		end
		else if( w_sub_phase == 4'd1 ) begin
			//	hold
		end
		else begin
			if( !ff_pre_pixel_color_en || !ff_color_en || ff_color_ic || ff_color_cc ) begin
				//	hold
			end
			else if( !ff_sprite_collision ) begin
				//	The dots of the sprite with the highest priority are already plotted.
				if( ff_pre_pixel_color[3:0] != 4'd0 || (!reg_sprite_mode3 && reg_color0_opaque) ) begin
					ff_sprite_collision		<= 1'b1;
					ff_sprite_collision_x	<= screen_pos_x[11:4] + 9'd12;
					ff_sprite_collision_y	<= { 2'd0, pixel_pos_y } + 10'd8;
				end
			end
		end
	end

	// --------------------------------------------------------------------
	//	[delay 9] latch pixel color
	// --------------------------------------------------------------------
	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_pixel_color_en			<= 1'b0;
			ff_pixel_color_transparent	<= 2'd0;
			ff_pixel_color				<= 8'd0;
		end
		else if( screen_pos_x == 14'h3FFF ) begin
			ff_pixel_color_en			<= 1'b0;
			ff_pixel_color_transparent	<= 2'd0;
			ff_pixel_color				<= 8'd0;
		end
		else if( w_sub_phase == 4'd3 ) begin
			ff_pixel_color_en			<= ff_pre_pixel_color_en;
			ff_pixel_color_transparent	<= ff_pre_pixel_color_transparent;
			ff_pixel_color				<= ff_pre_pixel_color;
		end
	end

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_pixel_color_d0 <= 11'd0;
			ff_pixel_color_d1 <= 11'd0;
			ff_pixel_color_d2 <= 11'd0;
			ff_pixel_color_d3 <= 11'd0;
			ff_pixel_color_d4 <= 11'd0;
			ff_pixel_color_d5 <= 11'd0;
		end
		else if( w_sub_phase == 4'd15 ) begin
			ff_pixel_color_d0 <= { ff_pixel_color_en, ff_pixel_color_transparent, ff_pixel_color };
			ff_pixel_color_d1 <= ff_pixel_color_d0;
			ff_pixel_color_d2 <= ff_pixel_color_d1;
			ff_pixel_color_d3 <= ff_pixel_color_d2;
			ff_pixel_color_d4 <= ff_pixel_color_d3;
			ff_pixel_color_d5 <= ff_pixel_color_d4;
		end
	end

	assign display_color_en				= ff_pixel_color_d5[10];
	assign display_color_transparent	= ff_pixel_color_d5[9:8];
	assign display_color				= ff_pixel_color_d5[7:0];
	assign sprite_collision				= ff_sprite_collision;
	assign sprite_collision_x			= ff_sprite_collision_x;
	assign sprite_collision_y			= ff_sprite_collision_y;
endmodule
