//
// ip_debugger.v
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

module ip_debugger (
	input			reset_n,
	input			clk,
	input			pulse0,
	input			pulse1,
	input			pulse2,
	input			pulse3,
	input			pulse4,
	input			pulse5,
	input			pulse6,
	input			pulse7,
	output			wr,
	input			sending,
	output	[7:0]	red,
	output	[7:0]	green,
	output	[7:0]	blue
);
	reg		[25:0]	ff_counter;
	reg				ff_on;
	reg				ff_wr;
	reg		[7:0]	ff_red;
	reg		[7:0]	ff_green;
	reg		[7:0]	ff_blue;

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_counter <= 26'd0;
		end
		else if( pulse0 || pulse1 || pulse2 || pulse3 || pulse4 || pulse5 || pulse6 || pulse7 ) begin
			ff_counter <= 26'h3FFFFFF;
		end
		else if( ff_counter != 26'd0 ) begin
			ff_counter <= ff_counter - 26'd1;
		end
	end

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_wr	<= 1'b0;
		end
		else if( ff_on == 1'b1 && ff_counter == 26'd0 ) begin
			ff_wr	<= 1'b1;
		end
		else if( pulse0 | pulse1 | pulse2 | pulse3 | pulse4 | pulse5 | pulse6 | pulse7 ) begin
			ff_wr	<= 1'b1;
		end
		else if( !sending ) begin
			ff_wr	<= 1'b0;
		end
	end

	assign wr		= ff_wr & !sending;
	assign red		= ff_red;
	assign green	= ff_green;
	assign blue		= ff_blue;

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_on		<= 1'b0;
			ff_red		<= 8'd0;
			ff_green	<= 8'd0;
			ff_blue		<= 8'd0;
		end
		else if( pulse0 ) begin
			ff_on		<= 1'b1;
			ff_red		<= 8'd32;
			ff_green	<= 8'd0;
			ff_blue		<= 8'd0;
		end
		else if( pulse1 ) begin
			ff_on		<= 1'b1;
			ff_red		<= 8'd0;
			ff_green	<= 8'd32;
			ff_blue		<= 8'd0;
		end
		else if( pulse2 ) begin
			ff_on		<= 1'b1;
			ff_red		<= 8'd0;
			ff_green	<= 8'd0;
			ff_blue		<= 8'd32;
		end
		else if( pulse3 ) begin
			ff_on		<= 1'b1;
			ff_red		<= 8'd32;
			ff_green	<= 8'd32;
			ff_blue		<= 8'd0;
		end
		else if( pulse4 ) begin
			ff_on		<= 1'b1;
			ff_red		<= 8'd0;
			ff_green	<= 8'd32;
			ff_blue		<= 8'd32;
		end
		else if( pulse5 ) begin
			ff_on		<= 1'b1;
			ff_red		<= 8'd32;
			ff_green	<= 8'd0;
			ff_blue		<= 8'd32;
		end
		else if( pulse6 ) begin
			ff_on		<= 1'b1;
			ff_red		<= 8'd32;
			ff_green	<= 8'd16;
			ff_blue		<= 8'd16;
		end
		else if( pulse7 ) begin
			ff_on		<= 1'b1;
			ff_red		<= 8'd32;
			ff_green	<= 8'd32;
			ff_blue		<= 8'd32;
		end
		else if( ff_on == 1'b1 && ff_counter == 26'd0 ) begin
			ff_on		<= 1'b0;
			ff_red		<= 8'd0;
			ff_green	<= 8'd0;
			ff_blue		<= 8'd0;
		end
		else begin
			//	hold
		end
	end
endmodule
