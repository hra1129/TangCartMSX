//
//	ppi_inst.v
//	 PPI i82C55 instanece wrapper entity
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

module ppi_inst (
	input					reset,
	input					clk,
	input					bus_io_req,
	output					bus_ack,
	input					bus_wrt,
	input		[15:0]		bus_address,
	input		[7:0]		bus_wdata,
	output		[7:0]		bus_rdata,
	output					bus_rdata_en,

	//	keyboard I/F
	output		[3:0]		matrix_y,
	input		[7:0]		matrix_x,
	//	Misc I/F
	output					cmt_motor_off,
	output					cmt_write_signal,
	output					keyboard_caps_led_off,
	output					click_sound,
	//	Primary slot signals
	output					sltsl0,
	output					sltsl1,
	output					sltsl2,
	output					sltsl3
);
	localparam				c_port_number = 8'hA8;
	wire					w_decode;
	wire		[7:0]		w_primary_slot;
	wire		[1:0]		w_current_page;
	wire		[1:0]		w_current_slot;

	// --------------------------------------------------------------------
	//	address decoder
	// --------------------------------------------------------------------
	assign w_decode			= ( { bus_address[7:2], 2'b00 } == c_port_number ) ? bus_io_req : 1'b0;

	assign w_current_page	= bus_address[15:14];

	assign w_current_slot	= (w_current_page == 2'd0) ? w_primary_slot[1:0] :
							  (w_current_page == 2'd1) ? w_primary_slot[3:2] :
							  (w_current_page == 2'd2) ? w_primary_slot[5:4] : w_primary_slot[7:6];

	assign sltsl0			= (w_current_slot == 2'd0) ? 1'b1 : 1'b0;
	assign sltsl1			= (w_current_slot == 2'd1) ? 1'b1 : 1'b0;
	assign sltsl2			= (w_current_slot == 2'd2) ? 1'b1 : 1'b0;
	assign sltsl3			= (w_current_slot == 2'd3) ? 1'b1 : 1'b0;

	// --------------------------------------------------------------------
	//	PPI body
	// --------------------------------------------------------------------
	ppi u_ppi (
		.reset					( reset					),
		.clk					( clk					),
		.req					( w_decode				),
		.ack					( bus_ack				),
		.wrt					( bus_wrt				),
		.address				( bus_address[1:0]		),
		.wdata					( bus_wdata				),
		.rdata					( bus_rdata				),
		.rdata_en				( bus_rdata_en			),
		.primary_slot			( w_primary_slot		),
		.matrix_y				( matrix_y				),
		.matrix_x				( matrix_x				),
		.cmt_motor_off			( cmt_motor_off			),
		.cmt_write_signal		( cmt_write_signal		),
		.keyboard_caps_led_off	( keyboard_caps_led_off	),
		.click_sound			( click_sound			)
	);
endmodule
