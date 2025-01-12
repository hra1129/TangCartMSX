//
//	megarom.v
//	Multi MegaROM Controller
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

module megarom (
	input			clk,
	input			reset_n,
	input			sltsl,
	input			mreq_n,
	input			wr_n,
	input			rd_n,
	input	[15:0]	address,
	input	[7:0]	wdata,
	//	ROM interface
	output			megarom_rd_n,
	output	[21:0]	megarom_address,
	//	Mode select
	input	[2:0]	mode				//	0: ASC16, 1: ASC8, 2: KonamiSCC, 3: KonamiSCC+, 4: Linear, 5: KonamiVRC, 6: ---, 7: ---
);
	reg		[7:0]	ff_rdata;
	reg				ff_rdata_en;
	reg				ff_rd_n;
	wire			w_wr;
	wire			w_rd;

	reg		[7:0]	ff_bank0;
	reg		[7:0]	ff_bank1;
	reg		[7:0]	ff_bank2;
	reg		[7:0]	ff_bank3;
	wire	[7:0]	w_address16;
	wire	[7:0]	w_address8;

	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_rd_n		<= 1'b1;
		end
		else begin
			ff_rd_n		<= rd_n;
		end
	end

	assign w_wr		= (!mreq_n &&             !wr_n && sltsl);
	assign w_rd		= (!mreq_n &&  ff_rd_n && !rd_n && sltsl);

	// --------------------------------------------------------------------
	//	Bank register
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_bank0 <= 8'd0;
		end
		else if( w_wr ) begin
			if( mode[2:1] == 2'b00 && address[15:11] == 5'b0110_0 ) begin	//	ASC8, ASC16: 6000-67FFh
				ff_bank0 <= wdata;
			end
			else begin
				//	hold
			end
		end
		else begin
			//	hold
		end
	end

	always @( posedge clk ) begin
		if( !reset_n ) begin
			if( mode[2:1] == 2'b00 ) begin
				ff_bank1 <= 8'd0;
			end
			else begin
				ff_bank1 <= 8'd1;
			end
		end
		else if( w_wr ) begin
			if( mode[2:1] == 2'b00 && address[15:11] == 5'b0110_1 ) begin	//	ASC8: 6800-6FFFh
				ff_bank1 <= wdata;
			end
			else begin
				//	hold
			end
		end
		else begin
			//	hold
		end
	end

	always @( posedge clk ) begin
		if( !reset_n ) begin
			if( mode[2:1] == 2'b00 ) begin
				ff_bank2 <= 8'd0;
			end
			else begin
				ff_bank2 <= 8'd2;
			end
		end
		else if( w_wr ) begin
			if( mode[2:1] == 2'b00 && address[15:11] == 5'b0111_0 ) begin	//	ASC8, ASC16: 7000-77FFh
				ff_bank2 <= wdata;
			end
			else begin
				//	hold
			end
		end
		else begin
			//	hold
		end
	end

	always @( posedge clk ) begin
		if( !reset_n ) begin
			if( mode[2:1] == 2'b00 ) begin
				ff_bank3 <= 8'd0;
			end
			else begin
				ff_bank3 <= 8'd3;
			end
		end
		else if( w_wr ) begin
			if( mode[2:1] == 2'b00 && address[15:11] == 5'b0111_1 ) begin	//	ASC8: 7800-7FFFh
				ff_bank3 <= wdata;
			end
			else begin
				//	hold
			end
		end
		else begin
			//	hold
		end
	end

	// --------------------------------------------------------------------
	//	Address select
	// --------------------------------------------------------------------
	assign w_address16				= (address[14]    == 1'b1 ) ? ff_bank0:				//	4000h-7FFFh MSB 2bit = 01-01
	                  				                              ff_bank2;				//	8000h-BFFFh MSB 2bit = 10-10
	assign w_address8				= (address[14:13] == 2'b10) ? ff_bank0:				//	4000h-5FFFh MSB 3bit = 010-010
	                 				  (address[14:13] == 2'b11) ? ff_bank1:				//	6000h-7FFFh MSB 3bit = 011-011
	                 				  (address[14:13] == 2'b00) ? ff_bank2: 			//	8000h-9FFFh MSB 3bit = 100-100
	                 				                              ff_bank3;				//	A000h-BFFFh MSB 3bit = 101-101

	assign megarom_rd_n				= ff_rd_n;
	assign megarom_address[21:13]	= (mode == 3'd0) ? { w_address16, address[13] }: { 1'b0, w_address8 };
	assign megarom_address[12:0]	= address[12:0];
endmodule
