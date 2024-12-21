//
//	ppi.v
//	 PPI i82C55 top entity
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

module ppi(
	input					reset_n,
	input					clk,
	input					iorq_n,
	input					wr_n,
	input					rd_n,
	input		[1:0]		address,
	input		[7:0]		wdata,
	output		[7:0]		rdata,
	output					rdata_en,
	//	Primary slot
	output		[7:0]		primary_slot,
	//	keyboard I/F
	output		[3:0]		matrix_y,
	input		[7:0]		matrix_x,
	//	Misc I/F
	output					cmt_motor_off,
	output					cmt_write_signal,
	output					keyboard_caps_led_off,
	output					click_sound
);
	reg			[7:0]		ff_port_a;
	reg			[7:0]		ff_port_c;
	reg			[7:0]		ff_rdata;
	reg						ff_rdata_en;

	// --------------------------------------------------------------------
	//	PortA: Primary Slot Register
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_port_a <= 8'd0;
		end
		else if( !iorq_n && !wr_n && (address == 2'b00) ) begin
			ff_port_a <= wdata;
		end
		else begin
			//	hold
		end
	end

	// --------------------------------------------------------------------
	//	PortC: Keyboard and cassette interface Register
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_port_c <= 8'b01110000;
		end
		else if( !iorq_n && !wr_n && (address == 2'b10) ) begin
			ff_port_c <= wdata;
		end
		else begin
			//	hold
		end
	end

	// --------------------------------------------------------------------
	//	Read
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_rdata <= 8'd0;
		end
		else if( !iorq_n && !rd_n ) begin
			case( address )
			2'd0:		ff_rdata <= ff_port_a;
			2'd1:		ff_rdata <= matrix_x;
			2'd2:		ff_rdata <= ff_port_c;
			2'd3:		ff_rdata <= 8'd0;
			default:	ff_rdata <= 8'd0;
			endcase
		end
		else begin
			ff_rdata <= 8'd0;
		end
	end

	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_rdata_en <= 1'b0;
		end
		else if( !iorq_n && !rd_n ) begin
			ff_rdata_en <= 1'b1;
		end
		else begin
			ff_rdata_en <= 1'b0;
		end
	end

	// --------------------------------------------------------------------
	//	Output assignment
	// --------------------------------------------------------------------
	assign rdata					= ff_rdata;
	assign rdata_en					= ff_rdata_en;

	assign primary_slot				= ff_port_a;
	assign matrix_y					= ff_port_c[3:0];
	assign cmt_motor_off			= ff_port_c[4];
	assign cmt_write_signal			= ff_port_c[5];
	assign keyboard_caps_led_off	= ff_port_c[6];
	assign click_sound				= ff_port_c[7];
endmodule
