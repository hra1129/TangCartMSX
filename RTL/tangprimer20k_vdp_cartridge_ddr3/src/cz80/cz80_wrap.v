//
//	Z80 compatible microprocessor core, asynchronous top level
//	Copyright (c) 2002 Daniel Wallner (jesus@opencores.org)
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
//	This module is based on T80(Version : 0250_T80) by Daniel Wallner and 
//	modified by Takayuki Hara.
//
//	The following modifications have been made.
//	-- Convert VHDL code to Verilog code.
//	-- Some minor bug fixes.
//-----------------------------------------------------------------------------

module cz80_wrap (
	input			reset_n		,
	input			clk_n		,		//	85.90908MHz
	input			int_n		,
	output	[15:0]	bus_address	,
	output			bus_memreq	,
	output			bus_ioreq	,
	output			bus_valid	,
	input			bus_ready	,
	output			bus_write	,
	output	[7:0]	bus_wdata	,
	input	[7:0]	bus_rdata	,
	input			bus_rdata_en
);
	reg				ff_enable;
	reg		[15:0]	ff_bus_address;
	reg				ff_bus_memreq;
	reg				ff_bus_ioreq;
	reg				ff_bus_valid;
	reg				ff_bus_write;
	reg		[7:0]	ff_bus_wdata;
	reg		[7:0]	ff_bus_rdata;
	reg				ff_request;
	wire			w_mreq_n;
	wire			w_iorq_n;
	wire			w_rd_n;
	wire			w_wr_n;
	wire	[15:0]	w_a;
	wire	[7:0]	w_d;
	wire			w_enable;

	assign bus_address	= ff_bus_address;
	assign bus_memreq	= ff_bus_memreq;
	assign bus_ioreq	= ff_bus_ioreq;
	assign bus_valid	= ff_bus_valid;
	assign bus_write	= ff_bus_write;
	assign bus_wdata	= ff_bus_wdata;

	always @( posedge clk_n ) begin
		if( !reset_n ) begin
			ff_enable		<= 1'b0;
		end
		else begin
			ff_enable		<= ~ff_enable;
		end
	end

	always @( posedge clk_n ) begin
		if( bus_rdata_en ) begin
			ff_bus_rdata	<= bus_rdata;
		end
	end

	always @( posedge clk_n ) begin
		if( !reset_n ) begin
			ff_request		<= 1'b0;
			ff_bus_address	<= 16'd0;
			ff_bus_memreq	<= 1'b0;
			ff_bus_ioreq	<= 1'b0;
			ff_bus_valid	<= 1'b0;
			ff_bus_write	<= 1'b0;
			ff_bus_wdata	<= 8'd0;
		end
		else if( ff_request ) begin
			if( bus_ready ) begin
				ff_bus_valid	<= 1'b0;
			end
			if( w_mreq_n && w_iorq_n ) begin
				ff_bus_memreq	<= 1'b0;
				ff_bus_ioreq	<= 1'b0;
				ff_bus_valid	<= 1'b0;
				ff_request		<= 1'b0;
			end
		end
		else if( !w_mreq_n || !w_iorq_n ) begin
			if( !w_rd_n ) begin
				ff_request		<= 1'b1;
				ff_bus_address	<= w_a;
				ff_bus_memreq	<= ~w_mreq_n;
				ff_bus_ioreq	<= ~w_iorq_n;
				ff_bus_valid	<= 1'b1;
				ff_bus_write	<= 1'b0;
				ff_bus_wdata	<= 8'b0;
			end
			else if( !w_wr_n ) begin
				ff_request		<= 1'b1;
				ff_bus_address	<= w_a;
				ff_bus_memreq	<= ~w_mreq_n;
				ff_bus_ioreq	<= ~w_iorq_n;
				ff_bus_valid	<= 1'b1;
				ff_bus_write	<= 1'b1;
				ff_bus_wdata	<= w_d;
			end
			else begin
			end
		end
	end

	assign w_enable	= ff_bus_valid ? 1'b0: ff_enable;
	assign w_d		= (w_rd_n == 1'b0) ? ff_bus_rdata : 8'dz;

	cz80_inst u_cz80_inst (
		.reset_n	( reset_n		),
		.clk_n		( clk_n			),
		.enable		( w_enable		),
		.wait_n		( 1'b1			),
		.int_n		( int_n			),
		.nmi_n		( 1'b1			),
		.busrq_n	( 1'b1			),
		.m1_n		( 				),
		.mreq_n		( w_mreq_n		),
		.iorq_n		( w_iorq_n		),
		.rd_n		( w_rd_n		),
		.wr_n		( w_wr_n		),
		.rfsh_n		( 				),
		.halt_n		( 				),
		.busak_n	( 				),
		.a			( w_a			),
		.d			( w_d			)
	);
endmodule
