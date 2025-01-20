//
//	R80 Registers
//	Copyright (c) 2024 Takayuki Hara
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
//-----------------------------------------------------------------------------

module cz80_registers (
	input			reset_n,
	input			clk,
	input			cen,
	input			we_h,
	input			we_l,
	input	[2:0]	address_a,
	input	[2:0]	address_b,
	input	[2:0]	address_c,
	input	[7:0]	wdata_h,
	input	[7:0]	wdata_l,
	output	[7:0]	rdata_ah,
	output	[7:0]	rdata_al,
	output	[7:0]	rdata_bh,
	output	[7:0]	rdata_bl,
	output	[7:0]	rdata_ch,
	output	[7:0]	rdata_cl
);
	reg		[7:0]	reg_b0;
	reg		[7:0]	reg_d0;
	reg		[7:0]	reg_h0;
	reg		[7:0]	reg_ixh;
	reg		[7:0]	reg_b1;
	reg		[7:0]	reg_d1;
	reg		[7:0]	reg_h1;
	reg		[7:0]	reg_iyh;

	reg		[7:0]	reg_c0;
	reg		[7:0]	reg_e0;
	reg		[7:0]	reg_l0;
	reg		[7:0]	reg_ixl;
	reg		[7:0]	reg_c1;
	reg		[7:0]	reg_e1;
	reg		[7:0]	reg_l1;
	reg		[7:0]	reg_iyl;

	always @( posedge clk ) begin
		if( !reset_n ) begin
			reg_b0		<= 8'h00;
			reg_d0		<= 8'h00;
			reg_h0		<= 8'h00;
			reg_ixh		<= 8'h00;
			reg_b1		<= 8'h00;
			reg_d1		<= 8'h00;
			reg_h1		<= 8'h00;
			reg_iyh		<= 8'h00;
		end
		else if( cen ) begin
			if( we_h ) begin
				case( address_a )
				3'd0:		reg_b0		<= wdata_h;
				3'd1:		reg_d0		<= wdata_h;
				3'd2:		reg_h0		<= wdata_h;
				3'd3:		reg_ixh		<= wdata_h;
				3'd4:		reg_b1		<= wdata_h;
				3'd5:		reg_d1		<= wdata_h;
				3'd6:		reg_h1		<= wdata_h;
				default:	reg_iyh		<= wdata_h;
				endcase
			end
		end
	end

	always @( posedge clk ) begin
		if( !reset_n ) begin
			reg_c0		<= 8'h00;
			reg_e0		<= 8'h00;
			reg_l0		<= 8'h00;
			reg_ixl		<= 8'h00;
			reg_c1		<= 8'h00;
			reg_e1		<= 8'h00;
			reg_l1		<= 8'h00;
			reg_iyl		<= 8'h00;
		end
		if( cen ) begin
			if( we_l ) begin
				case( address_a )
				3'd0:		reg_c0		<= wdata_l;
				3'd1:		reg_e0		<= wdata_l;
				3'd2:		reg_l0		<= wdata_l;
				3'd3:		reg_ixl		<= wdata_l;
				3'd4:		reg_c1		<= wdata_l;
				3'd5:		reg_e1		<= wdata_l;
				3'd6:		reg_l1		<= wdata_l;
				default:	reg_iyl		<= wdata_l;
				endcase
			end
		end
	end

	function [7:0] register_sel(
		input	[2:0]	address,
		input	[7:0]	reg_c0,
		input	[7:0]	reg_d0,
		input	[7:0]	reg_l0,
		input	[7:0]	reg_x0,
		input	[7:0]	reg_c1,
		input	[7:0]	reg_d1,
		input	[7:0]	reg_l1,
		input	[7:0]	reg_x1
	);
		case( address )
		3'd0:		register_sel = reg_c0;
		3'd1:		register_sel = reg_d0;
		3'd2:		register_sel = reg_l0;
		3'd3:		register_sel = reg_x0;
		3'd4:		register_sel = reg_c1;
		3'd5:		register_sel = reg_d1;
		3'd6:		register_sel = reg_l1;
		default:	register_sel = reg_x1;
		endcase
	endfunction

	assign rdata_ah = register_sel( address_a, reg_b0, reg_d0, reg_h0, reg_ixh, reg_b1, reg_d1, reg_h1, reg_iyh );
	assign rdata_al = register_sel( address_a, reg_c0, reg_e0, reg_l0, reg_ixl, reg_c1, reg_e1, reg_l1, reg_iyl );
	assign rdata_bh = register_sel( address_b, reg_b0, reg_d0, reg_h0, reg_ixh, reg_b1, reg_d1, reg_h1, reg_iyh );
	assign rdata_bl = register_sel( address_b, reg_c0, reg_e0, reg_l0, reg_ixl, reg_c1, reg_e1, reg_l1, reg_iyl );
	assign rdata_ch = register_sel( address_c, reg_b0, reg_d0, reg_h0, reg_ixh, reg_b1, reg_d1, reg_h1, reg_iyh );
	assign rdata_cl = register_sel( address_c, reg_c0, reg_e0, reg_l0, reg_ixl, reg_c1, reg_e1, reg_l1, reg_iyl );
endmodule
