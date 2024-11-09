// -----------------------------------------------------------------------------
//	ip_msx50bus_cart.v
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

module ip_msx50bus_cart (
	//	cartridge slot signals
	input			n_reset,
	input			clk,
	input	[15:0]	adr,
	input	[7:0]	i_data,
	output	[7:0]	o_data,
	output			is_output,
	input			n_sltsl,
	input			n_rd,
	input			n_wr,
	input			n_ioreq,
	input			n_mereq,
	//	internal signals
	output	[15:0]	bus_address,
	output			bus_io_req,
	output			bus_memory_req,
	input			bus_ack,
	output			bus_wrt,
	output	[7:0]	bus_wdata,
	input	[7:0]	bus_rdata,
	input			bus_rdata_en
);
	//	Flip-flops for asynchronous switching
	reg				ff_n_sltsl;
	reg				ff_n_ioreq;
	reg				ff_n_rd;
	reg				ff_n_wr;
	//	Make up pulse
	wire			w_io_req_pulse;
	wire			w_memory_req_pulse;
	wire			w_wrt_pulse;
	//	Latch
	reg		[15:0]	ff_address;
	reg		[7:0]	ff_rdata;
	reg		[7:0]	ff_wdata;
	reg				ff_io_req;
	reg				ff_memory_req;
	reg				ff_is_output;

	// --------------------------------------------------------------------
	//	Asynchronous switching and low-pass
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_n_sltsl	<= 1'b1;
			ff_n_rd		<= 1'b1;
			ff_n_wr		<= 1'b1;
			ff_n_ioreq	<= 1'b1;
		end
		else begin
			ff_n_sltsl	<= n_sltsl;
			ff_n_rd		<= n_rd;
			ff_n_wr		<= n_wr;
			ff_n_ioreq	<= n_ioreq;
		end
	end

	assign w_io_req			= ~ff_n_ioreq & (~ff_n_wr | ~ff_n_rd);
	assign w_memory_req		= ~ff_n_sltsl & (~ff_n_wr | ~ff_n_rd);
	assign w_wrt			= ~ff_n_wr;

	// --------------------------------------------------------------------
	//	Make up pulse
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_io_req		<= 1'b0;
			ff_memory_req	<= 1'b0;
			ff_wrt			<= 1'b0;
		end
		else begin
			ff_io_req		<= w_io_req;
			ff_memory_req	<= w_memory_req;
			ff_wrt			<= w_wrt;
		end
	end

	assign w_io_req_pulse		= ~ff_io_req     & w_io_req;
	assign w_memory_req_pulse	= ~ff_memory_req & w_memory_req;
	assign w_wrt_pulse			= ~ff_wrt        & w_wrt;

	// --------------------------------------------------------------------
	//	Latch
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_bus_address		<= 'd0;
		end
		else if( w_io_req_pulse || w_memory_req_pulse ) begin
			ff_bus_address		<= adr;
		end
		else begin
			//	hold
		end
	end

	always @( posedge clk ) begin
		if( w_wrt_pulse ) begin
			ff_wdata	<= i_data;
		end
		else begin
			//	hold
		end
	end

	always @( posedge clk ) begin
		if( bus_ack ) begin
			ff_io_req	<= 1'b0;
		end
		else if( w_io_req_pulse ) begin
			ff_io_req	<= 1'b1;
		end
		else begin
			//	hold
		end
	end

	always @( posedge clk ) begin
		if( bus_ack ) begin
			ff_memory_req	<= 1'b0;
		end
		else if( w_memory_req_pulse ) begin
			ff_memory_req	<= 1'b1;
		end
		else begin
			//	hold
		end
	end

	always @( posedge clk ) begin
		if( bus_ack ) begin
			ff_wrt	<= 1'b0;
		end
		else if( w_wrt_pulse ) begin
			ff_wrt	<= 1'b1;
		end
		else begin
			//	hold
		end
	end

	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_rdata		<= 8'd0;
			ff_is_output	<= 1'b0;
		end
		else if( ff_n_rd == 1'b1 ) begin
			ff_rdata		<= 8'd0;
			ff_is_output	<= 1'b0;
		end
		else if( bus_rdata_en ) begin
			ff_rdata		<= bus_rdata;
			ff_is_output	<= 1'b1;
		end
		else begin
			//	hold
		end
	end

	// --------------------------------------------------------------------
	//	Internal BUS signals
	// --------------------------------------------------------------------
	assign bus_address		= ff_address;
	assign bus_io_req		= ff_io_req;
	assign bus_memory_req	= ff_memory_req;
	assign bus_wrt			= ff_wrt;
	assign bus_wdata		= ff_wdata;

	// --------------------------------------------------------------------
	//	MSX BUS response
	// --------------------------------------------------------------------
	assign o_data			= ff_rdata;
	assign is_output		= ff_is_output;
endmodule
