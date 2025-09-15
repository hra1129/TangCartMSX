//
//	vdp_color_palette.v
//	Color Palette for VDP
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

module vdp_color_palette (
	input				reset_n,
	input				clk,					//	42.95454MHz

	input		[5:0]	screen_pos_x,
	input		[1:0]	pixel_phase_x,

	input				palette_valid,
	input		[7:0]	palette_num,
	input		[4:0]	palette_r,
	input		[4:0]	palette_g,
	input		[4:0]	palette_b,

	input		[7:0]	display_color_screen_mode,
	input				display_color_screen_mode_en,
	input		[3:0]	display_color_sprite,
	input				display_color_sprite_en,

	output		[7:0]	vdp_r,
	output		[7:0]	vdp_g,
	output		[7:0]	vdp_b,

	input		[4:0]	reg_screen_mode,
	input				reg_yjk_mode,
	input				reg_yae_mode,
	input				reg_color0_opaque,
	input		[7:0]	reg_backdrop_color,
	input				reg_ext_palette_mode
);
	wire				w_256colors_mode;
	wire				w_4colors_mode;
	wire				w_t12_mode;
	wire				w_g4567_mode;
	wire				w_g5_mode;
	wire				w_g6_mode;
	reg			[7:0]	ff_display_color256;
	reg			[7:0]	ff_display_color;
	reg					ff_display_color_oe;
	wire		[2:0]	w_display_r;
	wire		[2:0]	w_display_g;
	wire		[4:0]	w_display_r16;
	wire		[4:0]	w_display_g16;
	wire		[4:0]	w_display_b16;
	reg					ff_rgb_load;
	reg			[7:0]	ff_vdp_r;
	reg			[7:0]	ff_vdp_g;
	reg			[7:0]	ff_vdp_b;
	wire				w_palette_valid;
	wire		[7:0]	w_palette_num;
	wire		[4:0]	w_palette_r;
	wire		[4:0]	w_palette_g;
	wire		[4:0]	w_palette_b;
	reg			[4:0]	ff_palette_num;
	reg			[4:0]	ff_palette_r;
	reg			[4:0]	ff_palette_g;
	reg			[4:0]	ff_palette_b;
	wire				w_high_resolution;
	reg			[8:0]	ff_display_color_delay0;	//	{ palette_flag(1bit), pixel_byte(8bit) }
	reg			[8:0]	ff_display_color_delay1;	//	{ palette_flag(1bit), pixel_byte(8bit) }
	reg			[8:0]	ff_display_color_delay2;	//	{ palette_flag(1bit), pixel_byte(8bit) }
	reg			[8:0]	ff_display_color_delay3;	//	{ palette_flag(1bit), pixel_byte(8bit) }
	reg			[8:0]	ff_display_color_delay4;	//	{ palette_flag(1bit), pixel_byte(8bit) }
	reg			[4:0]	ff_y;
	reg			[5:0]	ff_j;
	reg			[5:0]	ff_k;
	reg					ff_yjk_en;
	wire		[6:0]	w_r_yjk;
	wire		[6:0]	w_g_yjk;
	wire		[8:0]	w_b_yjk_pre;
	wire		[6:0]	w_b_yjk;
	wire		[7:0]	w_b_y;
	wire		[7:0]	w_b_jk;
	wire		[4:0]	w_r;
	wire		[4:0]	w_g;
	wire		[4:0]	w_b;
	reg			[4:0]	ff_yjk_r;
	reg			[4:0]	ff_yjk_g;
	reg			[4:0]	ff_yjk_b;
	reg					ff_yjk_rgb_en;
    wire        [8:0]   w_display_color;

	// --------------------------------------------------------------------
	//	Palette initializer
	// --------------------------------------------------------------------
	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_palette_num	= 5'd0;
			ff_palette_r	= 5'd0;
			ff_palette_g	= 5'd0;
			ff_palette_b	= 5'd0;
		end
		else if( ff_palette_num[4] == 1'b0 ) begin
			case( ff_palette_num[3:0] )
			4'd0:	begin ff_palette_r = { 3'd0, 2'd0 }; ff_palette_b = { 3'd0, 2'd0 }; ff_palette_g = { 3'd0, 2'd0 }; end	//	color#1
			4'd1:	begin ff_palette_r = { 3'd1, 2'd0 }; ff_palette_b = { 3'd1, 2'd0 }; ff_palette_g = { 3'd6, 2'd0 }; end	//	color#2
			4'd2:	begin ff_palette_r = { 3'd3, 2'd0 }; ff_palette_b = { 3'd3, 2'd0 }; ff_palette_g = { 3'd7, 2'd0 }; end	//	color#3
			4'd3:	begin ff_palette_r = { 3'd1, 2'd0 }; ff_palette_b = { 3'd7, 2'd0 }; ff_palette_g = { 3'd1, 2'd0 }; end	//	color#4
			4'd4:	begin ff_palette_r = { 3'd2, 2'd0 }; ff_palette_b = { 3'd7, 2'd0 }; ff_palette_g = { 3'd3, 2'd0 }; end	//	color#5
			4'd5:	begin ff_palette_r = { 3'd5, 2'd0 }; ff_palette_b = { 3'd1, 2'd0 }; ff_palette_g = { 3'd1, 2'd0 }; end	//	color#6
			4'd6:	begin ff_palette_r = { 3'd2, 2'd0 }; ff_palette_b = { 3'd7, 2'd0 }; ff_palette_g = { 3'd6, 2'd0 }; end	//	color#7
			4'd7:	begin ff_palette_r = { 3'd7, 2'd0 }; ff_palette_b = { 3'd1, 2'd0 }; ff_palette_g = { 3'd1, 2'd0 }; end	//	color#8
			4'd8:	begin ff_palette_r = { 3'd7, 2'd0 }; ff_palette_b = { 3'd3, 2'd0 }; ff_palette_g = { 3'd3, 2'd0 }; end	//	color#9
			4'd9:	begin ff_palette_r = { 3'd6, 2'd0 }; ff_palette_b = { 3'd1, 2'd0 }; ff_palette_g = { 3'd6, 2'd0 }; end	//	color#10
			4'd10:	begin ff_palette_r = { 3'd6, 2'd0 }; ff_palette_b = { 3'd3, 2'd0 }; ff_palette_g = { 3'd6, 2'd0 }; end	//	color#11
			4'd11:	begin ff_palette_r = { 3'd1, 2'd0 }; ff_palette_b = { 3'd1, 2'd0 }; ff_palette_g = { 3'd4, 2'd0 }; end	//	color#12
			4'd12:	begin ff_palette_r = { 3'd6, 2'd0 }; ff_palette_b = { 3'd5, 2'd0 }; ff_palette_g = { 3'd2, 2'd0 }; end	//	color#13
			4'd13:	begin ff_palette_r = { 3'd5, 2'd0 }; ff_palette_b = { 3'd5, 2'd0 }; ff_palette_g = { 3'd5, 2'd0 }; end	//	color#14
			4'd14:	begin ff_palette_r = { 3'd7, 2'd0 }; ff_palette_b = { 3'd7, 2'd0 }; ff_palette_g = { 3'd7, 2'd0 }; end	//	color#15
			4'd15:	begin ff_palette_r = { 3'd0, 2'd0 }; ff_palette_b = { 3'd0, 2'd0 }; ff_palette_g = { 3'd0, 2'd0 }; end	//	initialize
			endcase
			ff_palette_num <= ff_palette_num + 5'd1;
		end
	end

	assign w_palette_valid	= ff_palette_num[4] ? palette_valid : 1'b1;
	assign w_palette_num	= ff_palette_num[4] ? palette_num : { 2'd0, ff_palette_num[3:0] };
	assign w_palette_r		= ff_palette_num[4] ? palette_r : ff_palette_r;
	assign w_palette_g		= ff_palette_num[4] ? palette_g : ff_palette_g;
	assign w_palette_b		= ff_palette_num[4] ? palette_b : ff_palette_b;

	// --------------------------------------------------------------------
	//	Pixel delay (screen_pos_x = 0)
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( screen_pos_x[2:0] == 3'd0 ) begin
			if( !reg_yjk_mode ) begin
				//	SCREEN0...8 の場合
				if( display_color_screen_mode_en ) begin
					//	映像期間
					ff_display_color_delay0 <= { 1'b1, display_color_screen_mode };
				end
				else begin
					//	周辺色期間
					ff_display_color_delay0 <= { 1'b1, reg_backdrop_color };
				end
			end
			else if( !reg_yae_mode ) begin
				//	SCREEN12 の場合
				if( display_color_screen_mode_en ) begin
					//	映像期間
					ff_display_color_delay0 <= { 1'b0, display_color_screen_mode };
				end
				else begin
					//	周辺色期間
					ff_display_color_delay0 <= { 1'b1, reg_backdrop_color[3:0], 1'b0, display_color_screen_mode[2:0] };
				end
			end
			else begin
				//	SCREEN10/11 の場合
				if( display_color_screen_mode_en ) begin
					//	映像期間
					ff_display_color_delay0 <= { display_color_screen_mode[3], display_color_screen_mode[7:4], 1'b0, display_color_screen_mode[2:0] };
				end
				else begin
					//	周辺色期間
					ff_display_color_delay0 <= { 1'b1, reg_backdrop_color[3:0], 1'b0, display_color_screen_mode[2:0] };
				end
			end
		end
	end

	always @( posedge clk ) begin
		//	画素単位でシフトする
		if( screen_pos_x[3:0] == 4'd0 ) begin
			ff_display_color_delay1 <= ff_display_color_delay0;
			ff_display_color_delay2 <= ff_display_color_delay1;
			ff_display_color_delay3 <= ff_display_color_delay2;
			ff_display_color_delay4 <= ff_display_color_delay3;
		end
		else begin
			//	hold
		end
	end

	// --------------------------------------------------------------------
	//	Latch YJK color (screen_pos_x = 0)
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		//	phase 6 が起点なので、5 dot 遅延の 11。 11 の下位2bit は 3。4画素周期でラッチ更新。
		if( pixel_phase_x == 2'd3 && screen_pos_x[3:0] == 4'b0000 ) begin
			ff_j	<= { ff_display_color_delay1[2:0], ff_display_color_delay2[2:0] };
			ff_k	<= { ff_display_color_delay3[2:0], ff_display_color_delay4[2:0] };
		end
		else begin
			//	hold
		end
	end

	always @( posedge clk ) begin
		if( screen_pos_x[3:0] == 4'd0 ) begin
			ff_y		<= ff_display_color_delay4[7:3];
			ff_yjk_en	<= ff_display_color_delay4[8];
		end
		else begin
			//	hold
		end
	end

	// --------------------------------------------------------------------
	//	Convert YJK to RGB (screen_pos_x = 1 ※4画素遅延後の 1)
	// --------------------------------------------------------------------
	assign w_r_yjk		= { 2'd0, ff_y } + { ff_j[5], ff_j };						//	r (-32...62)
	assign w_g_yjk		= { 2'd0, ff_y } + { ff_k[5], ff_k };						//	b (-32...62)
	assign w_b_y		= { 1'b0, ff_y, 2'd0 } + { 3'd0, ff_y };					//	y * 5						(   0...155 )
	assign w_b_jk		= { ff_j[5], ff_j, 1'b0 } + { ff_k[5], ff_k[5], ff_k };		//	j * 2 + k					( -96... 93 )
	assign w_b_yjk_pre	= { 1'b0, w_b_y } - { w_b_jk[7], w_b_jk } + 9'd2;			//	(y * 5 - (j * 2 + k) + 2)	( -91...253 )
	assign w_b_yjk		= w_b_yjk_pre[ 8: 2 ];										//	(y * 5 - (j * 2 + k) + 2)/4	( -22... 63 )
	assign w_r			= w_r_yjk[6] ? 5'd0:
	          			  w_r_yjk[5] ? 5'd31: w_r_yjk[4:0];
	assign w_g			= w_g_yjk[6] ? 5'd0:
	          			  w_g_yjk[5] ? 5'd31: w_g_yjk[4:0];
	assign w_b			= w_b_yjk[6] ? 5'd0:
	          			  w_b_yjk[5] ? 5'd31: w_b_yjk[4:0];

	always @( posedge clk ) begin
		if( screen_pos_x[3:0] == 4'd1 ) begin
			ff_yjk_r		<= w_r;
			ff_yjk_g		<= w_g;
			ff_yjk_b		<= w_b;
			ff_yjk_rgb_en	<= ff_yjk_en;
		end
	end

	// --------------------------------------------------------------------
	//	Mode Select ( screen_pos_x = 0 )
	// --------------------------------------------------------------------
	assign w_256colors_mode		= (reg_screen_mode == 5'b11100);	// Graphic7 (SCREEN8)
	assign w_4colors_mode		= (reg_screen_mode == 5'b10000);	// Graphic5 (SCREEN6)
	assign w_g4567_mode			= (reg_screen_mode == 5'b01100) ||	// Graphic4 (SCREEN5)
	                        	  (reg_screen_mode == 5'b10000) ||	// Graphic5 (SCREEN6)
	                        	  (reg_screen_mode == 5'b10100) ||	// Graphic6 (SCREEN7)
	                        	  (reg_screen_mode == 5'b11100);	// Graphic7 (SCREEN8)
	assign w_t12_mode			= (reg_screen_mode == 5'b00001) ||	// Text1 (SCREEN0:W40)
	                        	  (reg_screen_mode == 5'b00101) ||	// Text1 (SCREEN0:W40)
	                        	  (reg_screen_mode == 5'b01001);	// Text2 (SCREEN0:W80)
	assign w_g5_mode			= (reg_screen_mode == 5'b10000);	// Graphic5 (SCREEN6)
	assign w_g6_mode			= (reg_screen_mode == 5'b10100);	// Graphic6 (SCREEN7)
	assign w_high_resolution	= w_g5_mode | w_g6_mode | (reg_screen_mode == 5'b01001);		// Text2 or Graphic5 or 6 (SCREEN0(W80) or SCREEN6 or 7)

	// --------------------------------------------------------------------
	//	Palette RAM Read Signal ( screen_pos_x = 0 )
	// --------------------------------------------------------------------
	assign w_display_color		= reg_yjk_mode ? ff_display_color_delay3: ff_display_color_delay0;

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_display_color <= 8'd0;
			ff_display_color_oe <= 1'b0;
		end
		else if( screen_pos_x[3:0] == 4'd0 ) begin
			if( w_256colors_mode ) begin
				//	SCREEN8...12 (Simply delay)
				if( w_display_color[8] ) begin
					//	映像期間の場合、YJKか RGBかに関わらず、そのまま。
					ff_display_color	<= w_display_color[7:0];
					ff_display_color_oe	<= 1'b0;
				end
				else if( reg_yjk_mode ) begin
					//	YJKモード(SCREEN10/11/12)の場合は、周辺色は palette になる
					ff_display_color	<= { 4'd0, reg_backdrop_color[3:0] };
					ff_display_color_oe	<= 1'b1;
				end
				else begin
					//	RGBモード(SCREEN8)の場合は、周辺色はそのモードの色
					ff_display_color	<= reg_backdrop_color;
					ff_display_color_oe	<= 1'b0;
				end
			end
			else if( w_t12_mode ) begin
				//	SCREEN0
				ff_display_color <= { 4'd0, w_display_color[3:0] };
				ff_display_color_oe <= 1'b1;
			end
			else if( display_color_sprite_en && (display_color_sprite != 4'd0 || reg_color0_opaque) ) begin
				//	Sprite
				if( w_g5_mode ) begin
					ff_display_color <= { 6'd0, display_color_sprite[3:2] };
				end
				else begin
					ff_display_color <= { 4'd0, display_color_sprite };
				end
				ff_display_color_oe <= 1'b1;
			end
			else if( (w_display_color[3:0] != 4'd0 || reg_color0_opaque) ) begin
				//	Background
				ff_display_color <= { 4'd0, w_display_color[3:0] };
				ff_display_color_oe <= 1'b1;
			end
			else begin
				//	Background (Transparent)
				if( w_g5_mode ) begin
					ff_display_color <= { 6'd0, reg_backdrop_color[3:2] };
				end
				else begin
					ff_display_color <= { 4'd0, reg_backdrop_color[3:0] };
				end
				ff_display_color_oe <= 1'b1;
			end
		end
		else if( w_high_resolution && screen_pos_x[3:0] == 4'd8 ) begin
			if( w_t12_mode ) begin
				//	SCREEN0(W80) Background
				ff_display_color <= { 4'd0, w_display_color[3:0] };
			end
			else if( display_color_sprite_en && (display_color_sprite != 4'd0 || reg_color0_opaque) ) begin
				//	Sprite
				if( w_g5_mode ) begin
					//	SCREEN6 Sprite
					ff_display_color <= { 6'd0, display_color_sprite[1:0] };
				end
				else begin
					//	SCREEN7 Sprite
					ff_display_color <= { 4'd0, display_color_sprite };
				end
			end
			else if( (w_display_color[3:0] != 4'd0 || reg_color0_opaque) ) begin
				//	Background
				if( w_g5_mode ) begin
					//	SCREEN6 Background
					ff_display_color <= { 4'd0, w_display_color[1:0] };
				end
				else begin
					//	SCREEN7 Background
					ff_display_color <= { 4'd0, w_display_color[3:0] };
				end
			end
			else begin
				//	Background (Transparent)
				if( w_g5_mode ) begin
					//	SCREEN6
					ff_display_color <= { 4'd0, reg_backdrop_color[1:0] };
				end
				else begin
					//	SCREEN7
					ff_display_color <= { 4'd0, reg_backdrop_color[3:0] };
				end
			end
			ff_display_color_oe <= 1'b1;
		end
		else begin
			ff_display_color_oe <= 1'b0;
		end
	end

	// --------------------------------------------------------------------
	//	Palette RAM for 4 or 16 colors mode ( screen_pos_x = 2 )
	// --------------------------------------------------------------------
	vdp_color_palette_ram u_color_palette_ram (
		.clk					( clk					),
		.palette_valid			( w_palette_valid		),
		.palette_num			( w_palette_num			),
		.palette_r				( w_palette_r			),
		.palette_g				( w_palette_g			),
		.palette_b				( w_palette_b			),
		.display_color			( ff_display_color		),
		.display_color_oe		( ff_display_color_oe	),
		.display_r				( w_display_r16			),
		.display_g				( w_display_g16			),
		.display_b				( w_display_b16			)
	);

	// --------------------------------------------------------------------
	//	RGB table for 256 colors mode ( screen_pos_x = 1 )
	// --------------------------------------------------------------------
	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_display_color256 <= 8'd0;
		end
		else if( screen_pos_x[3:0] == 4'd1 && w_256colors_mode && !reg_yjk_mode ) begin
			if( display_color_sprite_en ) begin
				case( ff_display_color[3:0] )
				4'd0:		ff_display_color256 <= { 3'd0, 3'd0, 2'd0 };
				4'd1:		ff_display_color256 <= { 3'd0, 3'd0, 2'd1 };
				4'd2:		ff_display_color256 <= { 3'd0, 3'd3, 2'd0 };
				4'd3:		ff_display_color256 <= { 3'd0, 3'd3, 2'd1 };
				4'd4:		ff_display_color256 <= { 3'd3, 3'd0, 2'd0 };
				4'd5:		ff_display_color256 <= { 3'd3, 3'd0, 2'd1 };
				4'd6:		ff_display_color256 <= { 3'd3, 3'd3, 2'd0 };
				4'd7:		ff_display_color256 <= { 3'd3, 3'd3, 2'd1 };
				4'd8:		ff_display_color256 <= { 3'd4, 3'd7, 2'd1 };
				4'd9:		ff_display_color256 <= { 3'd0, 3'd0, 2'd3 };
				4'd10:		ff_display_color256 <= { 3'd0, 3'd7, 2'd0 };
				4'd11:		ff_display_color256 <= { 3'd0, 3'd7, 2'd3 };
				4'd12:		ff_display_color256 <= { 3'd7, 3'd0, 2'd0 };
				4'd13:		ff_display_color256 <= { 3'd7, 3'd0, 2'd3 };
				4'd14:		ff_display_color256 <= { 3'd7, 3'd7, 2'd0 };
				4'd15:		ff_display_color256 <= { 3'd7, 3'd7, 2'd3 };
				default:	ff_display_color256 <= { 3'd0, 3'd0, 2'd0 };
				endcase
			end
			else begin
				ff_display_color256 <= ff_display_color;
			end
		end
	end

	// --------------------------------------------------------------------
	//	RGB Color Conversion ( screen_pos_x = 4 )
	// --------------------------------------------------------------------
	assign w_display_r = w_256colors_mode ? ff_display_color256[4:2]          : w_display_r16;
	assign w_display_g = w_256colors_mode ? ff_display_color256[7:5]          : w_display_g16;

	always @( posedge clk ) begin
		ff_rgb_load	<= (screen_pos_x[3:0] == 4'd3) || (w_high_resolution && screen_pos_x[3:0] == 4'd11);
	end

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_vdp_r <= 8'd0;
			ff_vdp_g <= 8'd0;
		end
		else if( ff_rgb_load ) begin
			if( reg_yjk_mode && (!reg_yae_mode || !ff_yjk_rgb_en) ) begin
				ff_vdp_r <= { ff_yjk_r, ff_yjk_r[4:2] };
				ff_vdp_g <= { ff_yjk_g, ff_yjk_g[4:2] };
			end
			else begin
				case( w_display_r )
				3'd0:		ff_vdp_r <= 8'd0;
				3'd1:		ff_vdp_r <= 8'd37;
				3'd2:		ff_vdp_r <= 8'd73;
				3'd3:		ff_vdp_r <= 8'd110;
				3'd4:		ff_vdp_r <= 8'd146;
				3'd5:		ff_vdp_r <= 8'd183;
				3'd6:		ff_vdp_r <= 8'd219;
				3'd7:		ff_vdp_r <= 8'd255;
				default:	ff_vdp_r <= 8'd0;
				endcase

				case( w_display_g )
				3'd0:		ff_vdp_g <= 8'd0;
				3'd1:		ff_vdp_g <= 8'd37;
				3'd2:		ff_vdp_g <= 8'd73;
				3'd3:		ff_vdp_g <= 8'd110;
				3'd4:		ff_vdp_g <= 8'd146;
				3'd5:		ff_vdp_g <= 8'd183;
				3'd6:		ff_vdp_g <= 8'd219;
				3'd7:		ff_vdp_g <= 8'd255;
				default:	ff_vdp_g <= 8'd0;
				endcase
			end
		end
	end

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_vdp_b <= 8'd0;
		end
		else if( ff_rgb_load ) begin
			if( reg_yjk_mode && (!reg_yae_mode || !ff_yjk_rgb_en) ) begin
				ff_vdp_b <= { ff_yjk_b, ff_yjk_b[4:2] };
			end
			else if( w_256colors_mode ) begin
				case( ff_display_color256[1:0] )
				2'd0:		ff_vdp_b <= 8'd0;
				2'd1:		ff_vdp_b <= 8'd85;
				2'd2:		ff_vdp_b <= 8'd170;
				2'd3:		ff_vdp_b <= 8'd255;
				default:	ff_vdp_b <= 8'd0;
				endcase
			end
			else begin
				case( w_display_b16 )
				3'd0:		ff_vdp_b <= 8'd0;
				3'd1:		ff_vdp_b <= 8'd37;
				3'd2:		ff_vdp_b <= 8'd73;
				3'd3:		ff_vdp_b <= 8'd110;
				3'd4:		ff_vdp_b <= 8'd146;
				3'd5:		ff_vdp_b <= 8'd183;
				3'd6:		ff_vdp_b <= 8'd219;
				3'd7:		ff_vdp_b <= 8'd255;
				default:	ff_vdp_b <= 8'd0;
				endcase
			end
		end
	end

	// --------------------------------------------------------------------
	//	Output assignment ( screen_pos_x = 5 )
	// --------------------------------------------------------------------
	assign vdp_r = ff_vdp_r;
	assign vdp_g = ff_vdp_g;
	assign vdp_b = ff_vdp_b;
endmodule
