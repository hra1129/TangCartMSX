//
// ip_sdram_dummy.vhd
//	 16384 bytes of block memory
//	 Revision 1.00
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

module ip_sdram (
	input				n_reset			,
	input				clk				,
	input				clk_sdram		,
	input				rd_n			,
	input				wr_n			,
	input				exec			,
	output				busy			,
	input	[16:0]		address			,
	input	[7:0]		wdata			,
	output	[15:0]		rdata			,
	output				rdata_en		,
	output				O_sdram_clk		,
	output				O_sdram_cke		,
	output				O_sdram_cs_n	,
	output				O_sdram_ras_n	,
	output				O_sdram_cas_n	,
	output				O_sdram_wen_n	,
	inout	[31:0]		IO_sdram_dq		,
	output	[10:0]		O_sdram_addr	,
	output	[1:0]		O_sdram_ba		,
	output	[3:0]		O_sdram_dqm		
);
	reg		[7:0]	ff_ram [0:16383];
	reg		[7:0]	ff_rdata;
	reg		[7:0]	ff_rdata_d1;
	reg		[7:0]	ff_rdata_d2;
	reg		[7:0]	ff_rdata_d3;

	always @( posedge clk ) begin
		ff_rdata_d1 <= ff_rdata;
		ff_rdata_d2 <= ff_rdata_d1;
		ff_rdata_d3 <= ff_rdata_d2;
	end

	always @( posedge clk ) begin
		if( exec ) begin
			if(      rd_n == 1'b0 ) begin
				ff_rdata <= ff_ram[ address[13:0] ];
			end
			else if( wr_n == 1'b0 ) begin
				ff_ram[ address[13:0] ] <= wdata;
			end
		end
	end

	assign O_sdram_clk		= 1'b0;
	assign O_sdram_cke		= 1'b0;
	assign O_sdram_cs_n		= 1'b0;
	assign O_sdram_ras_n	= 1'b0;
	assign O_sdram_cas_n	= 1'b0;
	assign O_sdram_wen_n	= 1'b0;
	assign IO_sdram_dq		= 32'hZ;
	assign O_sdram_addr		= 11'd0;
	assign O_sdram_ba		= 2'b00;
	assign O_sdram_dqm		= 4'b0000;

	assign busy				= 1'b0;
	assign rdata			= { ff_rdata_d1, ff_rdata_d1 };
	assign rdata_en			= 1'b0;
endmodule
