//
//	i2c_audio.v
//	i2c DAC for Audio
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

module i2s_audio(
	input			clk,				//	42.95454MHz
	input			reset_n,
	input	[15:0]	sound_in,
	output			i2s_audio_en,
	output			i2s_audio_din,
	output			i2s_audio_lrclk,
	output			i2s_audio_bclk
);
	localparam		c_512khz	= 8'd83;
	reg		[7:0]	ff_divider;
	wire			w_512khz_pulse;
	reg				ff_bclk;
	reg				ff_lrclk;
	reg		[3:0]	ff_bit_count;
	reg		[15:0]	ff_shift_reg;

	assign i2s_audio_en		= 1'b1;

	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_divider <= 8'd0;
		end
		else if( w_512khz_pulse ) begin
			ff_divider <= 8'd0;
		end
		else begin
			ff_divider <= ff_divider + 8'd1;
		end
	end

	assign w_512khz_pulse	= (ff_divider == c_512khz);

	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_bclk <= 1'b0;
		end
		else if( w_512khz_pulse ) begin
			ff_bclk <= ~ff_bclk;
		end
	end

	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_lrclk <= 1'b0;
		end
		else if( w_512khz_pulse && ff_bit_count == 4'd15 ) begin
			ff_lrclk <= ~ff_lrclk;
		end
	end

	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_bit_count <= 4'd0;
		end
		else if( w_512khz_pulse && !ff_bclk ) begin
			ff_bit_count <= ff_bit_count + 4'd1;
		end
	end

	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_shift_reg <= 16'd0;
		end
		else if( w_512khz_pulse && !ff_bclk ) begin
			if( ff_bit_count == 4'd15 ) begin
				ff_shift_reg <= sound_in;
			end
			else begin
				ff_shift_reg <= { ff_shift_reg[14:0], 1'b0 };
			end
		end
	end

	assign i2s_audio_din	= ff_shift_reg[15];
endmodule
