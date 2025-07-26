//
//	vdp_upscan.v
//	 212line to 424line upscan converter
//
//	Copyright (C) 2025 Takayuki Hara.
//	All rights reserved.
//									   https://github.com/hra1129
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
// -----------------------------------------------------------------------------

module vdp_upscan (
	input				clk,						//	42.95454MHz
	input		[12:0]	screen_pos_x,				//	signed
	input		[ 9:0]	screen_pos_y,				//	signed
	input		[10:0]	h_count,
	input		[ 9:0]	v_count,
	// register
	input		[ 3:0]	reg_display_adjust,
	// input pixel
	input		[7:0]	vdp_r,
	input		[7:0]	vdp_g,
	input		[7:0]	vdp_b,
	// output pixel
	output		[7:0]	upscan_r,
	output		[7:0]	upscan_g,
	output		[7:0]	upscan_b
);
	wire		[9:0]	w_write_pos;
	wire		[9:0]	w_read_pos;
	wire		[9:0]	w_even_address;
	wire				w_even_re;
	wire				w_even_we;
	wire		[23:0]	w_even_d;
	wire		[23:0]	w_even_q;
	wire		[9:0]	w_odd_address;
	wire				w_odd_re;
	wire				w_odd_we;
	wire		[23:0]	w_odd_d;
	wire		[23:0]	w_odd_q;

	// --------------------------------------------------------------------
	//	Line buffer
	// --------------------------------------------------------------------
	assign w_write_pos		= screen_pos_x[11:2] + 10'd24 - { 5'd0, ~reg_display_adjust[3], reg_display_adjust[2:0], 1'b0 };
	assign w_read_pos		= h_count[9:0];

	vdp_upscan_line_buffer u_even_line_buffer (
		.clk			( clk				),
		.address		( w_even_address	),
		.re				( w_even_re			),
		.we				( w_even_we			),
		.d				( w_even_d			),
		.q				( w_even_q			)
	);

	assign w_even_address	= v_count[1] ? w_read_pos : w_write_pos;
	assign w_even_re		= ( (v_count[1] == 1'b1) && (h_count[10] == 1'b0) );
	assign w_even_we		= ( (v_count[1] == 1'b0) && (screen_pos_x[12] == 1'b0) );
	assign w_even_d			= { vdp_r, vdp_g, vdp_b };

	vdp_upscan_line_buffer u_odd_line_buffer (
		.clk			( clk				),
		.address		( w_odd_address		),
		.re				( w_odd_re			),
		.we				( w_odd_we			),
		.d				( w_odd_d			),
		.q				( w_odd_q			)
	);

	assign w_odd_address	= v_count[1] ? w_write_pos : w_read_pos;
	assign w_odd_re			= ( (v_count[1] == 1'b0) && (h_count[10] == 1'b0) );
	assign w_odd_we			= ( (v_count[1] == 1'b1) && (screen_pos_x[12] == 1'b0) );
	assign w_odd_d			= { vdp_r, vdp_g, vdp_b };

	assign upscan_r			= v_count[1] ? w_even_q[23:16] : w_odd_q[23:16];
	assign upscan_g			= v_count[1] ? w_even_q[15: 8] : w_odd_q[15: 8];
	assign upscan_b			= v_count[1] ? w_even_q[ 7: 0] : w_odd_q[ 7: 0];
endmodule
