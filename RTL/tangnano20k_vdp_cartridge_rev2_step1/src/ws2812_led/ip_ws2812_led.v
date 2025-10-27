//
// ip_ws2812_led.v
//
//	Copyright (C) 2025 Takayuki Hara
//
//	�{�\�t�g�E�F�A����і{�\�t�g�E�F�A�Ɋ�Â��č쐬���ꂽ�h�����́A�ȉ��̏�����
//	�������ꍇ�Ɍ���A�ĔЕz����юg�p��������܂��B
//
//	1.�\�[�X�R�[�h�`���ōĔЕz����ꍇ�A��L�̒��쌠�\���A�{�����ꗗ�A����щ��L
//	  �Ɛӏ��������̂܂܂̌`�ŕێ����邱�ƁB
//	2.�o�C�i���`���ōĔЕz����ꍇ�A�Еz���ɕt���̃h�L�������g���̎����ɁA��L��
//	  ���쌠�\���A�{�����ꗗ�A����щ��L�Ɛӏ������܂߂邱�ƁB
//	3.���ʂɂ�鎖�O�̋��Ȃ��ɁA�{�\�t�g�E�F�A��̔��A����я��ƓI�Ȑ��i�⊈��
//	  �Ɏg�p���Ȃ����ƁB
//
//	�{�\�t�g�E�F�A�́A���쌠�҂ɂ���āu����̂܂܁v�񋟂���Ă��܂��B���쌠�҂́A
//	����ړI�ւ̓K�����̕ۏ؁A���i���̕ۏ؁A�܂�����Ɍ��肳��Ȃ��A�����Ȃ閾��
//	�I�������͈ÖقȕۏؐӔC�������܂���B���쌠�҂́A���R�̂�������킸�A���Q
//	�����̌�����������킸�A���ӔC�̍������_��ł��邩���i�ӔC�ł��邩�i�ߎ�
//	���̑��́j�s�@�s�ׂł��邩���킸�A���ɂ��̂悤�ȑ��Q����������\����m��
//	����Ă����Ƃ��Ă��A�{�\�t�g�E�F�A�̎g�p�ɂ���Ĕ��������i��֕i�܂��͑�p�T
//	�[�r�X�̒��B�A�g�p�̑r���A�f�[�^�̑r���A���v�̑r���A�Ɩ��̒��f���܂߁A�܂���
//	��Ɍ��肳��Ȃ��j���ڑ��Q�A�Ԑڑ��Q�A�����I�ȑ��Q�A���ʑ��Q�A�����I���Q�A��
//	���͌��ʑ��Q�ɂ��āA��ؐӔC�𕉂�Ȃ����̂Ƃ��܂��B
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
	localparam c_t0h_count	= 15'd26;
	localparam c_t0l_count	= 15'd68;
	localparam c_t1h_count	= 15'd68;
	localparam c_t1l_count	= 15'd68;
	localparam c_res_count	= 15'd25773;

	reg		[14:0]	ff_count;
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
		else if( (ff_state == c_st_finish) && (ff_count == 15'd0) ) begin
			ff_sending		<= 1'b0;
		end
	end

	// --------------------------------------------------------------------
	//	state machine
	// --------------------------------------------------------------------
	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_state	<= c_st_idle;
			ff_count	<= 15'd0;
			ff_led		<= 1'b0;
		end
		else if( ff_count != 15'd0 ) begin
			ff_count <= ff_count - 15'd1;
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
