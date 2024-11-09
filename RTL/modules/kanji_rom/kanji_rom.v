//
//	kanji_rom.v
//	 Kanji ROM top entity
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

module kanji_rom(
	input					reset,
	input					clk,
	input					req,
	output					ack,
	input					wrt,
	input		[1:0]		address,			//	D8h, D9h, DAh, DBh
	input		[7:0]		wdata,
	output		[17:0]		kanji_rom_address,
	output					kanji_rom_address_en
);
	reg			[16:0]		ff_jis1_address;
	reg			[16:0]		ff_jis2_address;
	reg						ff_kanji_rom_address_en;
	reg						ff_ack;

	// --------------------------------------------------------------------
	//	JIS1
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( reset ) begin
			ff_jis1_address <= 17'd0;
		end
		else if( req && wrt && ff_ack ) begin
			case( address )
			2'd0:
				begin
					ff_jis1_address[4:0]	<= 5'd0;
					ff_jis1_address[10: 5]	<= wdata[5:0];
				end
			2'd1:
				begin
					ff_jis1_address[4:0]	<= 5'd0;
					ff_jis1_address[16:11]	<= wdata[5:0];
				end
			default:
				begin
					//	hold
				end
			endcase
		end
		else if( !address[1] && ff_kanji_rom_address_en ) begin
			ff_jis1_address <= ff_jis1_address + 17'd1;
		end
		else begin
			//	hold
		end
	end

	// --------------------------------------------------------------------
	//	JIS2
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( reset ) begin
			ff_jis2_address <= 17'd0;
		end
		else if( req && wrt && ff_ack ) begin
			case( address )
			2'd2:
				begin
					ff_jis2_address[4:0]	<= 5'd0;
					ff_jis2_address[10: 5]	<= wdata[5:0];
				end
			2'd3:
				begin
					ff_jis2_address[4:0]	<= 5'd0;
					ff_jis2_address[16:11]	<= wdata[5:0];
				end
			default:
				begin
					//	hold
				end
			endcase
		end
		else if( address[1] && ff_kanji_rom_address_en ) begin
			ff_jis2_address <= ff_jis2_address + 17'd1;
		end
		else begin
			//	hold
		end
	end

	// --------------------------------------------------------------------
	//	Read
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( reset ) begin
			ff_kanji_rom_address_en <= 1'b0;
		end
		else if( req && !wrt && ff_ack && address[0] ) begin
			ff_kanji_rom_address_en <= 1'b1;
		end
		else begin
			ff_kanji_rom_address_en <= 1'b0;
		end
	end

	// --------------------------------------------------------------------
	//	Ack
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( reset ) begin
			ff_ack <= 1'b0;
		end
		else if( ff_ack ) begin
			ff_ack <= 1'b0;
		end
		else if( req ) begin
			ff_ack <= 1'b1;
		end
		else begin
			//	hold
		end
	end

	assign ack						= ff_ack;

	// --------------------------------------------------------------------
	//	Output assignment
	// --------------------------------------------------------------------
	assign kanji_rom_address		= ( address[1] == 1'b0 ) ? { 1'b0, ff_jis1_address } : { 1'b1, ff_jis2_address };
	assign kanji_rom_address_en		= ff_kanji_rom_address_en;
endmodule
