//
// ip_ws2812_led.v
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

module ip_ws2812_led(
	input			reset_n,
	input			clk,
	input			wr,
	output			sending,
	input	[7:0]	red,
	input	[7:0]	green,
	input	[7:0]	blue,
	output			ws2812_led
);
	localparam c_t0h_count	= 14'd	13	;
	localparam c_t0l_count	= 14'd	34	;
	localparam c_t1h_count	= 14'd	34	;
	localparam c_t1l_count	= 14'd	34	;
	localparam c_res_count	= 14'd	12887	;

	reg		[13:0]	ff_count;
	reg		[23:0]	ff_send_data;
	reg				ff_sending;
	reg		[5:0]	ff_state;
	localparam		c_st_idle		= 0;
	localparam		c_st_reset		= 1;
	localparam		c_st_send00_h	= 2;
	localparam		c_st_send00_l	= 3;
	localparam		c_st_send01_h	= 4;
	localparam		c_st_send01_l	= 5;
	localparam		c_st_send02_h	= 6;
	localparam		c_st_send02_l	= 7;
	localparam		c_st_send03_h	= 8;
	localparam		c_st_send03_l	= 9;
	localparam		c_st_send04_h	= 10;
	localparam		c_st_send04_l	= 11;
	localparam		c_st_send05_h	= 12;
	localparam		c_st_send05_l	= 13;
	localparam		c_st_send06_h	= 14;
	localparam		c_st_send06_l	= 15;
	localparam		c_st_send07_h	= 16;
	localparam		c_st_send07_l	= 17;
	localparam		c_st_send08_h	= 18;
	localparam		c_st_send08_l	= 19;
	localparam		c_st_send09_h	= 20;
	localparam		c_st_send09_l	= 21;
	localparam		c_st_send10_h	= 22;
	localparam		c_st_send10_l	= 23;
	localparam		c_st_send11_h	= 24;
	localparam		c_st_send11_l	= 25;
	localparam		c_st_send12_h	= 26;
	localparam		c_st_send12_l	= 27;
	localparam		c_st_send13_h	= 28;
	localparam		c_st_send13_l	= 29;
	localparam		c_st_send14_h	= 30;
	localparam		c_st_send14_l	= 31;
	localparam		c_st_send15_h	= 32;
	localparam		c_st_send15_l	= 33;
	localparam		c_st_send16_h	= 34;
	localparam		c_st_send16_l	= 35;
	localparam		c_st_send17_h	= 36;
	localparam		c_st_send17_l	= 37;
	localparam		c_st_send18_h	= 38;
	localparam		c_st_send18_l	= 39;
	localparam		c_st_send19_h	= 40;
	localparam		c_st_send19_l	= 41;
	localparam		c_st_send20_h	= 42;
	localparam		c_st_send20_l	= 43;
	localparam		c_st_send21_h	= 44;
	localparam		c_st_send21_l	= 45;
	localparam		c_st_send22_h	= 46;
	localparam		c_st_send22_l	= 47;
	localparam		c_st_send23_h	= 48;
	localparam		c_st_send23_l	= 49;
	localparam		c_st_finish		= 50;
	reg				ff_led;

	// --------------------------------------------------------------------
	//	request-acceptance circuit
	// --------------------------------------------------------------------
	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_sending		<= 1'b0;
		end
		else if( (ff_state == c_st_idle) && wr ) begin
			ff_sending		<= 1'b1;
		end
		else if( (ff_state == c_st_finish) && (ff_count == 'd0) ) begin
			ff_sending		<= 1'b0;
		end
	end

	// --------------------------------------------------------------------
	//	state machine
	// --------------------------------------------------------------------
	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_state	<= c_st_idle;
			ff_count	<= 'd0;
			ff_led		<= 1'b0;
		end
		else if( ff_count != 'd0 ) begin
			ff_count <= ff_count - 'd1;
		end
		else begin
			case( ff_state )
			c_st_idle:
				if( wr ) begin
					ff_state	<= c_st_reset;
					ff_count	<= c_res_count;
					ff_led		<= 1'b0;
				end
			c_st_reset, 
			c_st_send00_l, c_st_send01_l, c_st_send02_l, c_st_send03_l, 
			c_st_send04_l, c_st_send05_l, c_st_send06_l, c_st_send07_l, 
			c_st_send08_l, c_st_send09_l, c_st_send10_l, c_st_send11_l, 
			c_st_send12_l, c_st_send13_l, c_st_send14_l, c_st_send15_l, 
			c_st_send16_l, c_st_send17_l, c_st_send18_l, c_st_send19_l, 
			c_st_send20_l, c_st_send21_l, c_st_send22_l:
				if( ff_count == 'd0 ) begin
					if( ff_send_data[23] ) begin
						ff_count <= c_t1h_count;
					end
					else begin
						ff_count <= c_t0h_count;
					end
					ff_state	<= ff_state + 1'd1;
					ff_led		<= 1'b1;
				end
			c_st_send23_l,
			c_st_send00_h, c_st_send01_h, c_st_send02_h, c_st_send03_h, 
			c_st_send04_h, c_st_send05_h, c_st_send06_h, c_st_send07_h, 
			c_st_send08_h, c_st_send09_h, c_st_send10_h, c_st_send11_h, 
			c_st_send12_h, c_st_send13_h, c_st_send14_h, c_st_send15_h, 
			c_st_send16_h, c_st_send17_h, c_st_send18_h, c_st_send19_h, 
			c_st_send20_h, c_st_send21_h, c_st_send22_h, c_st_send23_h:
				begin
					if( ff_send_data[23] ) begin
						ff_count <= c_t1l_count;
					end
					else begin
						ff_count <= c_t0l_count;
					end
					ff_state	<= ff_state + 1'd1;
					ff_led		<= 1'b0;
				end
			c_st_finish:
				begin
					ff_state	<= c_st_idle;
					ff_led		<= 1'b0;
				end
			default:
				begin
					ff_state	<= c_st_idle;
					ff_led		<= 1'b0;
				end
			endcase
		end
	end

	// --------------------------------------------------------------------
	//	shift register
	// --------------------------------------------------------------------
	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_send_data <= 24'd0;
		end
		else if( (ff_state == c_st_idle) && wr ) begin
			ff_send_data <= { green, red, blue };
		end
		else if( ff_count == 'd1 ) begin
			case( ff_state )
			c_st_send00_l, c_st_send01_l, c_st_send02_l, c_st_send03_l, 
			c_st_send04_l, c_st_send05_l, c_st_send06_l, c_st_send07_l, 
			c_st_send08_l, c_st_send09_l, c_st_send10_l, c_st_send11_l, 
			c_st_send12_l, c_st_send13_l, c_st_send14_l, c_st_send15_l, 
			c_st_send16_l, c_st_send17_l, c_st_send18_l, c_st_send19_l, 
			c_st_send20_l, c_st_send21_l, c_st_send22_l, c_st_send23_l:
				ff_send_data <= { ff_send_data[22:0], 1'b0 };
			default:
				begin
					//	hold
				end
			endcase
		end
	end

	assign ws2812_led	= ff_led;
	assign sending		= ff_sending;
endmodule
