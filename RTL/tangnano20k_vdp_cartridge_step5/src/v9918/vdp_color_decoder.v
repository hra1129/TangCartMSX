//
//	vdp_color_decoder.v
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

module vdp_color_decoder (
	input			reset				,
	input			clk					,
	input			enable				,

	input	[1:0]	dot_state			,

	input			vdp_mode_text1		,
	input			vdp_mode_text1q		,
	input			vdp_mode_multi		,
	input			vdp_mode_multiq		,
	input			vdp_mode_graphic1	,
	input			vdp_mode_graphic2	,

	input			window				,	// 有効表示領域だけ 1 になる
	input			sp_color_code_en	,	// スプライトの画素位置だけ 1 になる
	input	[3:0]	colorcodet12		,	// text1, 2 の色
	input	[3:0]	colorcodeg123m		,	// graphic1,2,3,mosaic の色
	input	[3:0]	colorcodesprite		,	// スプライトの色

	output	[5:0]	pvideor_vdp			,	// モニタへ出力する色
	output	[5:0]	pvideog_vdp			,
	output	[5:0]	pvideob_vdp			,
	// registers
	input			reg_r1_disp_on		,
	input	[7:0]	reg_r7_frame_col	
);
	// d-flipflop
	reg		[4:0]	ff_video_r;
	reg		[4:0]	ff_video_g;
	reg		[4:0]	ff_video_b;
	reg		[3:0]	ff_palette_address;
	reg				ff_sprite_color_out;
	// wire
	wire			w_even_dotstate;
	wire	[3:0]	w_fore_color;
	wire	[3:0]	w_back_color;

	assign pvideor_vdp			= { ff_video_r, 1'b1 };
	assign pvideog_vdp			= { ff_video_g, 1'b1 };
	assign pvideob_vdp			= { ff_video_b, 1'b1 };

	assign w_even_dotstate		= ( dot_state == 2'b00 || dot_state == 2'b11 ) ? 1'b1 : 1'b0;

	// output data latch
	always @( posedge clk ) begin
		if( reset ) begin
			ff_video_r <= 5'd0;
			ff_video_g <= 5'd0;
			ff_video_b <= 5'd0;
		end
		else if( !enable ) begin
			// hold
		end
		else if( w_even_dotstate ) begin
			case( ff_palette_address )
			4'd0:		begin ff_video_r <= 5'd0 ; ff_video_g <= 5'd0 ; ff_video_b <= 5'd0 ; end
			4'd1:		begin ff_video_r <= 5'd0 ; ff_video_g <= 5'd0 ; ff_video_b <= 5'd0 ; end
			4'd2:		begin ff_video_r <= 5'd4 ; ff_video_g <= 5'd26; ff_video_b <= 5'd4 ; end
			4'd3:		begin ff_video_r <= 5'd13; ff_video_g <= 5'd31; ff_video_b <= 5'd13; end
			4'd4:		begin ff_video_r <= 5'd4 ; ff_video_g <= 5'd4 ; ff_video_b <= 5'd31; end
			4'd5:		begin ff_video_r <= 5'd8 ; ff_video_g <= 5'd13; ff_video_b <= 5'd31; end
			4'd6:		begin ff_video_r <= 5'd22; ff_video_g <= 5'd4 ; ff_video_b <= 5'd4 ; end
			4'd7:		begin ff_video_r <= 5'd8 ; ff_video_g <= 5'd26; ff_video_b <= 5'd31; end
			4'd8:		begin ff_video_r <= 5'd31; ff_video_g <= 5'd4 ; ff_video_b <= 5'd4 ; end
			4'd9:		begin ff_video_r <= 5'd31; ff_video_g <= 5'd13; ff_video_b <= 5'd13; end
			4'd10:		begin ff_video_r <= 5'd26; ff_video_g <= 5'd26; ff_video_b <= 5'd4 ; end
			4'd11:		begin ff_video_r <= 5'd26; ff_video_g <= 5'd26; ff_video_b <= 5'd17; end
			4'd12:		begin ff_video_r <= 5'd4 ; ff_video_g <= 5'd17; ff_video_b <= 5'd4 ; end
			4'd13:		begin ff_video_r <= 5'd26; ff_video_g <= 5'd8 ; ff_video_b <= 5'd22; end
			4'd14:		begin ff_video_r <= 5'd22; ff_video_g <= 5'd22; ff_video_b <= 5'd22; end
			4'd15:		begin ff_video_r <= 5'd31; ff_video_g <= 5'd31; ff_video_b <= 5'd31; end
			default:	begin ff_video_r <= 5'd0 ; ff_video_g <= 5'd0 ; ff_video_b <= 5'd0 ; end
			endcase
		end
	end

	// for others
	assign w_fore_color			=	( vdp_mode_text1 || vdp_mode_text1q ) ? colorcodet12    :
									( sp_color_code_en                  ) ? colorcodesprite : colorcodeg123m;
	assign w_back_color			=	reg_r7_frame_col[3:0];

	always @( posedge clk ) begin
		if( reset ) begin
			ff_palette_address		<= 4'd0;
		end
		else if( !enable ) begin
			// hold
		end
		else if( w_even_dotstate ) begin
			//	16 color palettes
			if( !window || !reg_r1_disp_on || (w_fore_color == 4'd0) ) begin
				ff_palette_address		<= w_back_color;
			end
			else begin
				ff_palette_address		<= w_fore_color;
			end
		end
	end
endmodule
