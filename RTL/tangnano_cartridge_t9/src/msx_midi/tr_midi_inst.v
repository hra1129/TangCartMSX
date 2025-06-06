//
//	msx_midi_inst.v
//	 MSX-MIDI instanece wrapper entity
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

module msx_midi_inst #(
	parameter				BUILT_IN_MODE = 0		// 0: Cartridge mode, 1: Built in mode
) (
	input					n_reset,
	input					clk,
	input					n_ioreq,
	input					n_wr,
	input					n_rd,
	input		[15:0]		address,
	input		[7:0]		wdata,
	output		[7:0]		rdata,
	output					rdata_en,

	output					midi_out,
	input					midi_in,
	output					midi_intr_n
);
	localparam				c_port_cartridge_number	= 8'hE0;		//	uPACK
	localparam				c_port_built_in_number	= 8'hE8;		//	A1GT
	wire					w_decode;
	wire					w_ack;
	reg			[7:0]		ff_rdata;
	reg						ff_ioreq;
	reg						ff_ioreq_hold;
	wire		[7:0]		w_rdata;
	reg						ff_rdata_en;
	wire		[5:0]		w_joystick_port1;
	wire		[5:0]		w_joystick_port2;

	// --------------------------------------------------------------------
	//	wrapper
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_ioreq_hold <= 1'b0;
		end
		else begin
			ff_ioreq_hold <= !n_ioreq;
		end
	end

	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_ioreq <= 1'b0;
		end
		else if( !ff_ioreq_hold && ~n_ioreq ) begin
			ff_ioreq <= 1'b1;
		end
		else if( n_ioreq || w_ack ) begin
			ff_ioreq <= 1'b0;
		end
		else begin
			//	hold
		end
	end

	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_rdata_en <= 1'd0;
		end
		else begin
			ff_rdata_en <= ff_ioreq & ~n_rd;
		end
	end

	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_rdata <= 8'd0;
		end
		else if( ff_rdata_en ) begin
			ff_rdata <= w_rdata;
		end
	end

	assign rdata			= ff_rdata;

	// --------------------------------------------------------------------
	//	address decoder
	// --------------------------------------------------------------------
	generate
		if( BUILT_IN_MODE == 0 ) begin
			assign rdata_en			= (!n_rd && ff_ioreq_hold && ( { address[7:2], 2'b00 } == c_port_cartridge_number ));
			assign w_decode			= ( { address[7:3], 3'b000 } == c_port_cartridge_number ) ? ff_ioreq : 1'b0;
		end
		else begin
			assign rdata_en			= (!n_rd && ff_ioreq_hold && ( { address[7:2], 2'b00 } == c_port_built_in_number ));
			assign w_decode			= ( { address[7:3], 3'b000 } == c_port_built_in_number  ) ? ff_ioreq : 1'b0;
		end
	endgenerate

	// --------------------------------------------------------------------
	//	SSG body
	// --------------------------------------------------------------------
	tr_midi #(
		.c_base_clk		( 22'd2147727	)	//	21.47727[MHz]
	) u_tr_midi (
		.clk21m			( clk			),
		.reset			( ~n_reset		),
		.req			( w_decode		),
		.ack			( w_ack			),
		.wrt			( ~n_wr			),
		.adr			( address[2:0]	),
		.dbi			( w_rdata		),
		.dbo			( wdata			),
		.pMidiTxD		( midi_out		),
		.pMidiRxD		( midi_in		),
		.pMidiIntr		( midi_intr_n	)
	);
endmodule
