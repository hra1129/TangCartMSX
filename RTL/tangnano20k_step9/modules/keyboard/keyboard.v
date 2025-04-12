// -----------------------------------------------------------------------------
//	keyboard.v
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

module ip_keyboard (
	//	internal signals
	input			n_reset,
	input			clk,				//	85.90908MHz
	//	Keymatrix interface (from Physical Keyboard device)
	input			keymatrix_req,
	output			keymatrix_ack,
	input	[3:0]	keymatrix_row,
	input	[7:0]	keymatrix_col,
	//	Keymatrix (to PPI)
	input	[3:0]	ppi_keyboard_row,
	output	[7:0]	ppi_keyboard_col,
	//	LED interface (from PPI, PSG)
	input			caps_led,
	input			kana_led,
	//	LED interface (to Physical LED device)
	output			keyboard_led_req,
	input			keyboard_led_ack,
	output			keyboard_led_caps,
	output			keyboard_led_kana
);
	reg				ff_matrix_req;
	reg				ff_matrix_ack;
	reg		[7:0]	ff_matrix [0:15];
	wire			w_matrix_req;
	wire			w_matrix_ack;
	reg				ff_caps_led;
	reg				ff_kana_led;
	wire			w_caps_led_changed;
	wire			w_kana_led_changed;
	reg				ff_keyboard_led_req;

	// --------------------------------------------------------------------
	//	matrix
	// --------------------------------------------------------------------
	assign w_matrix_req		= keymatrix_req & ~ff_matrix_req;
	assign w_matrix_ack		= ~keymatrix_req & ff_matrix_ack;

	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_matrix_req	<= 1'b0;
		end
		else begin
			ff_matrix_req	<= keymatrix_req;
		end
	end

	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_matrix_ack	<= 1'b0;
		end
		else if( w_matrix_ack ) begin
			ff_matrix_ack	<= 1'b0;
		end
		else if( w_matrix_req ) begin
			ff_matrix_ack	<= 1'b1;
		end
		else begin
			//	hold
		end
	end

	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_matrix[0]	<= 8'hFF;
			ff_matrix[1]	<= 8'hFF;
			ff_matrix[2]	<= 8'hFF;
			ff_matrix[3]	<= 8'hFF;
			ff_matrix[4]	<= 8'hFF;
			ff_matrix[5]	<= 8'hFF;
			ff_matrix[6]	<= 8'hFF;
			ff_matrix[7]	<= 8'hFF;
			ff_matrix[8]	<= 8'hFF;
			ff_matrix[9]	<= 8'hFF;
			ff_matrix[10]	<= 8'hFF;
			ff_matrix[11]	<= 8'hFF;
			ff_matrix[12]	<= 8'hFF;
			ff_matrix[13]	<= 8'hFF;
			ff_matrix[14]	<= 8'hFF;
			ff_matrix[15]	<= 8'hFF;
		end
		else if( w_matrix_req ) begin
			ff_matrix[ keymatrix_row ]	<= keymatrix_col;
		end
		else begin
			//	hold
		end
	end

	// --------------------------------------------------------------------
	//	LED
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_caps_led	<= 1'b1;
			ff_kana_led	<= 1'b1;
		end
		else begin
			ff_caps_led	<= caps_led;
			ff_kana_led	<= kana_led;
		end
	end

	assign w_caps_led_changed	= ff_caps_led ^ caps_led;
	assign w_kana_led_changed	= ff_kana_led ^ kana_led;

	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_keyboard_led_req	<= 1'b0;
		end
		else if( keyboard_led_ack ) begin
			ff_keyboard_led_req	<= 1'b0;
		end
		else if( !ff_keyboard_led_req ) begin
			ff_keyboard_led_req	<= w_caps_led_changed | w_kana_led_changed;
		end
		else begin
			//	hold
		end
	end

	assign keymatrix_ack		= ff_matrix_ack;
	assign ppi_keyboard_col		= ff_matrix[ ppi_keyboard_row ];
	assign keyboard_led_req		= ff_keyboard_led_req;
	assign keyboard_led_caps	= caps_led;
	assign keyboard_led_kana	= kana_led;
endmodule
