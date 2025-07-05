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

	input		[2:0]	screen_pos_x,

	input				palette_valid,
	input		[3:0]	palette_num,
	input		[2:0]	palette_r,
	input		[2:0]	palette_g,
	input		[2:0]	palette_b,

	input		[3:0]	display_color_t12,
	input		[3:0]	display_color_g123m,
	input		[7:0]	display_color_g4567,
	input		[3:0]	display_color_sprite,
	input				display_color_sprite_en,

	output		[7:0]	vdp_r,
	output		[7:0]	vdp_g,
	output		[7:0]	vdp_b,

	input		[4:0]	reg_screen_mode,
	input				reg_yjk_mode,
	input				reg_yae_mode
);
	wire				w_256colors_mode;
	wire				w_4colors_mode;
	wire				w_g4567_mode;
	reg			[7:0]	ff_display_color;
	reg					ff_display_color_oe;
	wire		[2:0]	w_display_r;
	wire		[2:0]	w_display_g;
	wire		[2:0]	w_display_b;
	wire		[2:0]	w_display_r16;
	wire		[2:0]	w_display_g16;
	wire		[2:0]	w_display_b16;
	reg			[7:0]	ff_vdp_r;
	reg			[7:0]	ff_vdp_g;
	reg			[7:0]	ff_vdp_b;

	// --------------------------------------------------------------------
	//	Mode Select ( screen_pos_x = 0 )
	// --------------------------------------------------------------------
	assign w_256colors_mode		= (reg_screen_mode == 5'b11100);	// Graphic7 (SCREEN8)
	assign w_4colors_mode		= (reg_screen_mode == 5'b10000);	// Graphic5 (SCREEN6)
	assign w_high_resolution	= (reg_screen_mode == 5'b10000) ||	// Graphic5 (SCREEN6)
	                        	  (reg_screen_mode == 5'b10100);	// Graphic6 (SCREEN7)
	assign w_g4567_mode			= (reg_screen_mode == 5'b01100) ||	// Graphic4 (SCREEN5)
	                        	  (reg_screen_mode == 5'b10000) ||	// Graphic5 (SCREEN6)
	                        	  (reg_screen_mode == 5'b10100) ||	// Graphic6 (SCREEN7)
	                        	  (reg_screen_mode == 5'b11100);	// Graphic7 (SCREEN8)

	// --------------------------------------------------------------------
	//	Palette RAM Read Signal ( screen_pos_x = 0 )
	// --------------------------------------------------------------------
	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_display_color <= 8'd0;
			ff_display_color_oe <= 1'b0;
		end
		else if( w_256colors_mode ) begin
			if( display_color_sprite_en ) begin
				ff_display_color <= { 4'd0, display_color_sprite };
			end
			else begin
				ff_display_color <= display_color_g4567;
			end
			ff_display_color_oe <= 1'b0;
		end
		else if( screen_pos_x == 3'd0 || (w_high_resolution && screen_pos_x == 3'd4) ) begin
			if( display_color_sprite_en ) begin
				ff_display_color <= { 4'd0, display_color_sprite };
			end
			else if( w_g4567_mode ) begin
				ff_display_color <= { 4'd0, display_color_g4567[3:0] };
			end
			else begin
				ff_display_color <= { 4'd0, display_color_g123m };
			end
			ff_display_color_oe <= 1'b1;
		end
		else begin
			ff_display_color_oe <= 1'b0;
		end
	end

	// --------------------------------------------------------------------
	//	Palette RAM for 4 or 16 colors mode ( screen_pos_x = 1 )
	// --------------------------------------------------------------------
	vdp_color_palette_ram u_color_palette_ram (
		.clk					( clk					),
		.palette_valid			( palette_valid			),
		.palette_num			( palette_num			),
		.palette_r				( palette_r				),
		.palette_g				( palette_g				),
		.palette_b				( palette_b				),
		.display_color			( ff_display_color[3:0]	),
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
		else if( screen_pos_x == 3'd1 && w_256colors_mode ) begin
			if( display_color_sprite_en ) begin
				case( ff_display_color )
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
	//	RGB Color Conversion ( screen_pos_x = 2 )
	// --------------------------------------------------------------------
	assign w_display_r = w_256colors_mode ? ff_display_color256[4:2]          : w_display_r16;
	assign w_display_g = w_256colors_mode ? ff_display_color256[7:5]          : w_display_g16;
	assign w_display_b = w_256colors_mode ? { 1'b0, ff_display_color256[1:0] }: w_display_b16;

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_vdp_r <= 8'd0;
			ff_vdp_g <= 8'd0;
		end
		else if( screen_pos_x == 3'd2 || (w_high_resolution == 3'd6 ) begin
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

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_vdp_b <= 8'd0;
		end
		else if( screen_pos_x == 3'd2 || (w_high_resolution == 3'd6 ) begin
			if( w_256colors_mode ) begin
				case( w_display_b[1:0] )
				3'd0:		ff_vdp_b <= 8'd0;
				3'd1:		ff_vdp_b <= 8'd85;
				3'd2:		ff_vdp_b <= 8'd170;
				3'd3:		ff_vdp_b <= 8'd255;
				default:	ff_vdp_b <= 8'd0;
				endcase
			end
			else begin
				case( w_display_b )
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
	//	Output assignment ( screen_pos_x = 3 )
	// --------------------------------------------------------------------
	assign vdp_r = ff_vdp_r;
	assign vdp_g = ff_vdp_g;
	assign vdp_b = ff_vdp_b;
endmodule
