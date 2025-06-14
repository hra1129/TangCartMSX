//
// ip_gpio.v
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

module ip_gpio(
	input			reset_n,
	input			clk,
	input	[7:0]	bus_address,
	input			bus_ioreq,
	input			bus_write,
	input			bus_valid,
	output			bus_ready,
	input	[7:0]	bus_wdata,
	output	[7:0]	bus_rdata,
	output			bus_rdata_en,
	output			led_wr,
	output	[7:0]	led_red,
	output	[7:0]	led_green,
	output	[7:0]	led_blue
);
	reg				ff_wr;
	reg		[7:0]	ff_red;
	reg		[7:0]	ff_green;
	reg		[7:0]	ff_blue;
	reg		[7:0]	ff_rdata;
	reg				ff_rdata_en;

	// I/O --------------------------------------------------------------------
	// 10h .... Red
	// 11h .... Green
	// 12h .... Blue and Write
	// -------------------------------------------------------------------------
	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_wr		<= 1'b0;
			ff_red		<= 8'h55;
			ff_green	<= 8'h66;
			ff_blue		<= 8'h77;
		end
		else if( bus_ioreq && bus_write && bus_valid ) begin
			case( bus_address )
			8'h10:
				begin
					ff_red		<= bus_wdata;
					ff_wr		<= 1'b0;
				end
			8'h11:
				begin
					ff_green	<= bus_wdata;
					ff_wr		<= 1'b0;
				end
			8'h12:
				begin
					ff_blue		<= bus_wdata;
					ff_wr		<= 1'b1;
				end
			default:
				begin
					//	hold
				end
			endcase
		end
		else begin
			ff_wr		<= 1'b0;
		end
	end

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_rdata	<= 8'd0;
			ff_rdata_en	<= 1'b0;
		end
		else if( bus_ioreq && !bus_write && bus_valid ) begin
			case( bus_address )
			8'h10:
				begin
					ff_rdata	<= ff_red;
					ff_rdata_en	<= 1'b1;
				end
			8'h11:
				begin
					ff_rdata	<= ff_green;
					ff_rdata_en	<= 1'b1;
				end
			8'h12:
				begin
					ff_rdata	<= ff_blue;
					ff_rdata_en	<= 1'b1;
				end
			default:
				begin
					//	hold
				end
			endcase
		end
		else begin
			ff_rdata	<= 8'd0;
			ff_rdata_en	<= 1'b0;
		end
	end

	assign bus_ready	= 1'b1;
	assign bus_rdata	= ff_rdata;
	assign bus_rdata_en	= ff_rdata_en;
	assign led_wr		= ff_wr;
	assign led_red		= ff_red;
	assign led_green	= ff_green;
	assign led_blue		= ff_blue;
endmodule
