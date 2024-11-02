//
//	vdp_colordec.v
//
//	Copyright (C) 2024 Takayuki Hara
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
//----------------------------------------------------------------------------

module vdp_colordec (
	input			reset				,
	input			clk					,
	input			enable				,

	input	[1:0]	dot_state			,

	output	[3:0]	ppaletteaddr_out	,
	input	[7:0]	palettedatarb_out	,
	input	[7:0]	palettedatag_out	,

	input			vdp_mode_text1		,
	input			vdp_mode_text1q		,
	input			vdp_mode_text2		,
	input			vdp_mode_multi		,
	input			vdp_mode_multiq		,
	input			vdp_mode_graphic1		,
	input			vdp_mode_graphic2		,
	input			vdp_mode_graphic3		,
	input			vdp_mode_graphic4		,
	input			vdp_mode_graphic5		,
	input			vdp_mode_graphic6		,
	input			vdp_mode_graphic7		,

	input			window				,	// 有効表示領域だけ 1 になる
	input			sp_color_code_en		,	// スプライトの画素位置だけ 1 になる
	input	[3:0]	colorcodet12		,	// text1, 2 の色
	input	[3:0]	colorcodeg123m		,	// graphic1,2,3,mosaic の色
	input	[7:0]	colorcodeg4567		,	// graphic4,5,6,7 の色
	input	[3:0]	colorcodesprite		,	// スプライトの色
	input	[5:0]	p_yjk_r				,
	input	[5:0]	p_yjk_g				,
	input	[5:0]	p_yjk_b				,
	input			p_yjk_en			,

	output	[5:0]	pvideor_vdp			,	// モニタへ出力する色
	output	[5:0]	pvideog_vdp			,
	output	[5:0]	pvideob_vdp			,
	// registers
	input			reg_r1_disp_on		,
	input	[7:0]	reg_r7_frame_col	,
	input			reg_r8_col0_on		,
	input			reg_r25_yjk
);
	// d-flipflop
	reg		[5:0]	ff_video_r;
	reg		[5:0]	ff_video_g;
	reg		[5:0]	ff_video_b;
	reg		[7:0]	ff_grp7_color_code;
	reg		[3:0]	ff_palette_addr;
	reg		[1:0]	ff_palette_addr_g5;
	reg		[5:0]	ff_yjk_r;
	reg		[5:0]	ff_yjk_g;
	reg		[5:0]	ff_yjk_b;
	reg				ff_yjk_en;
	reg				ff_sprite_color_out;
	// wire
	wire			w_even_dotstate;
	wire	[7:0]	w_grp7_sprite_color;
	wire	[3:0]	w_fore_color;
	wire	[3:0]	w_back_color;
	wire	[7:0]	w_grp7_color;
	wire	[3:0]	w_palette_addr;

	assign ppaletteaddr_out		= ( !vdp_mode_graphic5 ) ? ff_palette_addr : { 2'b00, ff_palette_addr_g5 };

	assign pvideor_vdp			= ff_video_r;
	assign pvideog_vdp			= ff_video_g;
	assign pvideob_vdp			= ff_video_b;

	assign w_even_dotstate		= ( dot_state == 2'b00 || dot_state == 2'b11 ) ? 1'b1 : 1'b0;

	// output data latch
	always @( posedge clk ) begin
		if( reset ) begin
			ff_video_r <= 6'd0;
			ff_video_g <= 6'd0;
			ff_video_b <= 6'd0;
		end
		else if( !enable ) begin
			// hold
		end
		else if( w_even_dotstate ) begin
			if( vdp_mode_graphic7 && ff_yjk_en && !ff_sprite_color_out ) begin
				//	yjk mode
				ff_video_r <= ff_yjk_r;
				ff_video_g <= ff_yjk_g;
				ff_video_b <= ff_yjk_b;
			end
			else if( !vdp_mode_graphic7 || reg_r25_yjk ) begin
				//	palette color (not graphic7, sprite on yjk mode, yae color on yjk mode)
				ff_video_r <= { palettedatarb_out[6:4], 3'b000 };
				ff_video_g <= { palettedatag_out [2:0], 3'b000 };
				ff_video_b <= { palettedatarb_out[2:0], 3'b000 };
			end
			else begin
				//	graphic7
				ff_video_r <= { ff_grp7_color_code[4:2], 3'b000 };
				ff_video_g <= { ff_grp7_color_code[7:5], 3'b000 };
				ff_video_b <= { ff_grp7_color_code[1:0], ff_grp7_color_code[1], 3'b000 };
			end
		end
	end

	// for graphic7
	function [7:0] func_grp7_sprite_color(
		input	[3:0]	colorcodesprite
	);
		case( colorcodesprite )           //      G       R       B
		4'b0000:	func_grp7_sprite_color = { 3'b000, 3'b000, 2'b00 };
		4'b0001:	func_grp7_sprite_color = { 3'b000, 3'b000, 2'b01 };
		4'b0010:	func_grp7_sprite_color = { 3'b000, 3'b011, 2'b00 };
		4'b0011:	func_grp7_sprite_color = { 3'b000, 3'b011, 2'b01 };
		4'b0100:	func_grp7_sprite_color = { 3'b011, 3'b000, 2'b00 };
		4'b0101:	func_grp7_sprite_color = { 3'b011, 3'b000, 2'b01 };
		4'b0110:	func_grp7_sprite_color = { 3'b011, 3'b011, 2'b00 };
		4'b0111:	func_grp7_sprite_color = { 3'b011, 3'b011, 2'b01 };
		4'b1000:	func_grp7_sprite_color = { 3'b100, 3'b111, 2'b01 };
		4'b1001:	func_grp7_sprite_color = { 3'b000, 3'b000, 2'b11 };
		4'b1010:	func_grp7_sprite_color = { 3'b000, 3'b111, 2'b00 };
		4'b1011:	func_grp7_sprite_color = { 3'b000, 3'b111, 2'b11 };
		4'b1100:	func_grp7_sprite_color = { 3'b111, 3'b000, 2'b00 };
		4'b1101:	func_grp7_sprite_color = { 3'b111, 3'b000, 2'b11 };
		4'b1110:	func_grp7_sprite_color = { 3'b111, 3'b111, 2'b00 };
		4'b1111:	func_grp7_sprite_color = { 3'b111, 3'b111, 2'b11 };
		default:	func_grp7_sprite_color = 8'd0;
		endcase
	endfunction
	
	assign w_grp7_sprite_color	= func_grp7_sprite_color( colorcodesprite );

	// for others
	assign w_fore_color			=	( vdp_mode_text1 || vdp_mode_text1q || vdp_mode_text2 ) ? colorcodet12 :
									( sp_color_code_en ) ? colorcodesprite :
									( vdp_mode_graphic1 || vdp_mode_graphic2 || vdp_mode_graphic3 || vdp_mode_multi || vdp_mode_multiq ) ? colorcodeg123m :
									colorcodeg4567[3:0];
	assign w_back_color			=	reg_r7_frame_col[3:0];

	always @( posedge clk ) begin
		if( reset ) begin
			ff_palette_addr		<= 4'd0;
		end
		else if( !enable ) begin
			// hold
		end
		else if( w_even_dotstate ) begin
			if( !window || !reg_r1_disp_on || (w_fore_color == 4'd0 && !reg_r8_col0_on) ) begin
				ff_palette_addr		<= w_back_color;
			end
			else begin
				ff_palette_addr		<= w_fore_color;
			end
		end
	end

	always @( posedge clk ) begin
		if( reset ) begin
			ff_palette_addr_g5	<= 2'd0;
		end
		else if( !enable ) begin
			// hold
		end
		else if( w_even_dotstate ) begin
			if( !window || !reg_r1_disp_on ||
					(!dot_state[1] && w_fore_color[1:0] == 2'b00 && !reg_r8_col0_on) ||
					( dot_state[1] && w_fore_color[3:2] == 2'b00 && !reg_r8_col0_on) ) begin
				if( !dot_state[1] ) begin
					ff_palette_addr_g5	<= w_back_color[1:0];
				end
				else begin
					ff_palette_addr_g5	<= w_back_color[3:2];
				end
			end
			else begin
				if( !dot_state[1] ) begin
					ff_palette_addr_g5	<= w_fore_color[1:0];
				end
				else begin
					ff_palette_addr_g5	<= w_fore_color[3:2];
				end
			end
		end
	end

	always @( posedge clk ) begin
		if( reset ) begin
			ff_grp7_color_code	<= 8'd0;
		end
		else if( !enable ) begin
			// hold
		end
		else if( w_even_dotstate ) begin
			if( sp_color_code_en ) begin
				ff_grp7_color_code	<= w_grp7_sprite_color;
			end
			else begin
				ff_grp7_color_code	<= colorcodeg4567;
			end
		end
	end

	always @( posedge clk ) begin
		if( reset ) begin
			ff_sprite_color_out	<= 1'b0;
			ff_yjk_r			<= 6'd0;
			ff_yjk_g			<= 6'd0;
			ff_yjk_b			<= 6'd0;
			ff_yjk_en			<= 1'b0;
		end
		else if( !enable ) begin
			// hold
		end
		else if( w_even_dotstate ) begin
			ff_sprite_color_out	<= sp_color_code_en & window & reg_r1_disp_on;
			if( window && reg_r1_disp_on ) begin
				ff_yjk_r			<= p_yjk_r;
				ff_yjk_g			<= p_yjk_g;
				ff_yjk_b			<= p_yjk_b;
				ff_yjk_en			<= p_yjk_en;
			end
			else if( (!window || !reg_r1_disp_on) && reg_r25_yjk ) begin
				ff_yjk_en			<= 1'b0;
			end
			else begin
				ff_yjk_r			<= { reg_r7_frame_col[4:2], 3'b000 };
				ff_yjk_g			<= { reg_r7_frame_col[7:5], 3'b000 };
				ff_yjk_b			<= { reg_r7_frame_col[1:0], reg_r7_frame_col[1], 3'b000 };
				ff_yjk_en			<= 1'b1;
			end
		end
	end
endmodule
