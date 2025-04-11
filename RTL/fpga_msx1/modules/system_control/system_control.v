//
//	system_control.v
//	 System Controller
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

module system_control(
	input					reset_n,
	input					clk,
	input					iorq_n,
	input					wr_n,
	input					rd_n,
	input		[7:0]		address,
	input		[7:0]		wdata,
	output		[7:0]		rdata,
	output					rdata_en,
	//	Video Out Control
	output		[7:0]		reg_left_offset,
	output		[7:0]		reg_denominator,
	output		[7:0]		reg_normalize,
	output					reg_scanline
);
	localparam	[7:0]		c_maker_id		= 8'h01;
	reg						ff_active;
	reg			[7:0]		ff_rdata;
	reg						ff_rdata_en;
	reg			[7:0]		ff_reg_address;
	//	Video out registers
	reg			[7:0]		ff_left_offset;
	reg			[7:0]		ff_denominator;
	reg			[7:0]		ff_normalize;
	reg						ff_scanline;

	// --------------------------------------------------------------------
	//	Active Switch
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_active <= 1'b0;
		end
		else if( !iorq_n && !wr_n && (address == 8'h40) ) begin
			if( wdata == c_maker_id ) begin
				ff_active <= 1'b1;
			end
			else begin
				ff_active <= 1'b0;
			end
		end
	end

	// --------------------------------------------------------------------
	//	Read Registers
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_rdata		<= 8'd0;
			ff_rdata_en		<= 1'b0;
		end
		else if( !iorq_n && !rd_n && ff_active && (address[7:4] == 4'd4) ) begin
			ff_rdata_en		<= 1'b1;
			case( address[3:0] )
			4'h0:		ff_rdata	<= ~c_maker_id;
			4'h1:		ff_rdata	<= ff_reg_address;
			4'h2:
				case( ff_reg_address )
				8'd0:		ff_rdata	<= ff_left_offset;
				8'd1:		ff_rdata	<= ff_denominator;
				8'd2:		ff_rdata	<= ff_normalize;
				8'd3:		ff_rdata	<= { 7'd0, ff_scanline };
				default:	ff_rdata	<= 8'h00;
				endcase
			default:	ff_rdata	<= 8'h00;
			endcase
		end
		else begin
			ff_rdata_en		<= 1'b0;
		end
	end

	// --------------------------------------------------------------------
	//	Reg address
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_reg_address	<= 8'd0;
		end
		else if( !iorq_n && !wr_n && ff_active && (address == 8'h41) ) begin
			ff_reg_address	<= wdata;
		end
		else begin
			//	hold
		end
	end

	// --------------------------------------------------------------------
	//	Video out registers
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_left_offset	<= 8'd20;
			ff_denominator	<= 8'd175;
			ff_normalize	<= 8'd187;
			ff_scanline		<= 1'b0;
		end
		else if( !iorq_n && !wr_n && ff_active && (address == 8'h42) ) begin
			case( ff_reg_address )
			8'd0:		ff_left_offset	<= wdata;
			8'd1:		ff_denominator	<= wdata;
			8'd2:		ff_normalize	<= wdata;
			8'd3:		ff_scanline		<= wdata[0];
			default:
				begin
					//	hold
				end
			endcase
		end
		else begin
			//	hold
		end
	end

	// --------------------------------------------------------------------
	//	Output assignment
	// --------------------------------------------------------------------
	assign rdata					= ff_rdata;
	assign rdata_en					= ff_rdata_en;

	assign reg_left_offset			= ff_left_offset;
	assign reg_denominator			= ff_denominator;
	assign reg_normalize			= ff_normalize;
	assign reg_scanline				= ff_scanline;
endmodule
