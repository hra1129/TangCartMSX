//
//	vdp_double_buffer.vhd
//	  Double Buffered Line Memory.
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
//
//-----------------------------------------------------------------------------

module vdp_double_buffer (
	input			clk,
	input			enable,
	input	[9:0]	x_position_w,
	input	[9:0]	x_position_r,
	input			is_odd,
	input			we,
	input	[4:0]	wdata_r,
	input	[4:0]	wdata_g,
	input	[4:0]	wdata_b,
	output	[4:0]	rdata_r,
	output	[4:0]	rdata_g,
	output	[4:0]	rdata_b
);
	wire			we_e;
	wire			we_o;
	wire	[9:0]	addr_e;
	wire	[9:0]	addr_o;
	wire	[14:0]	out_e;
	wire	[14:0]	out_o;
	wire	[14:0]	w_d;

	assign w_d		= { wdata_r, wdata_g, wdata_b };

	// even line
	vdp_ram_line_buffer u_buf_even (
		.clk		( clk			),
		.enable		( enable		),
		.address	( addr_e		),
		.we			( we_e			),
		.d			( w_d			),
		.q			( out_e			)
	);

	// odd line
	vdp_ram_line_buffer u_buf_odd (
		.clk		( clk			),
		.enable		( enable		),
		.address	( addr_o		),
		.we			( we_o			),
		.d			( w_d			),
		.q			( out_o			)
	);

	assign we_e			= ( !is_odd ) ? we : 1'b0;
	assign we_o			= (  is_odd ) ? we : 1'b0;

	assign addr_e		= ( !is_odd ) ? x_position_w : x_position_r;
	assign addr_o		= (  is_odd ) ? x_position_w : x_position_r;

	assign rdata_r		= (  is_odd ) ? out_e[14:10] : out_o[14:10];
	assign rdata_g		= (  is_odd ) ? out_e[ 9: 5] : out_o[ 9: 5];
	assign rdata_b		= (  is_odd ) ? out_e[ 4: 0] : out_o[ 4: 0];
endmodule