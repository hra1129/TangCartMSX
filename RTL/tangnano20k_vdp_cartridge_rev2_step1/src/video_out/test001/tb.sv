// -----------------------------------------------------------------------------
//	Test of video_out_hmag.v
//	Copyright (C)2025 Takayuki Hara (HRA!)
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
// --------------------------------------------------------------------

module tb ();
	localparam		clk_base	= 1_000_000_000/42_954_540;	//	ps
	// vdp clock ... 42.95454MHz
	reg				clk;
	reg				reset_n;					//	Must be reset and released at the same time as the VDP
	reg				enable;
	// video input
	reg		[5:0]	vdp_r;
	reg		[5:0]	vdp_g;
	reg		[5:0]	vdp_b;
	reg		[10:0]	vdp_hcounter;
	reg		[10:0]	vdp_vcounter;
	// video output
	wire			video_clk;
	wire			video_de;
	wire			video_hs;
	wire			video_vs;
	wire	[7:0]	video_r;
	wire	[7:0]	video_g;
	wire	[7:0]	video_b;
	int				i,j,k;

	// --------------------------------------------------------------------
	//	DUT
	// --------------------------------------------------------------------
	video_out #(
		.hs_positive	( 1'b0			),
		.vs_positive	( 1'b0			)
	) u_dut (
		.clk			( clk			),
		.reset_n		( reset_n		),
		.enable			( enable		),
		.vdp_r			( vdp_r			),
		.vdp_g			( vdp_g			),
		.vdp_b			( vdp_b			),
		.vdp_hcounter	( vdp_hcounter	),
		.vdp_vcounter	( vdp_vcounter	),
		.video_clk		( video_clk		),
		.video_de		( video_de		),
		.video_hs		( video_hs		),
		.video_vs		( video_vs		),
		.video_r		( video_r		),
		.video_g		( video_g		),
		.video_b		( video_b		)
	);

	// --------------------------------------------------------------------
	//	clock
	// --------------------------------------------------------------------
	always #(clk_base/2) begin
		clk <= ~clk;
	end

	always @( posedge clk ) begin
		if( !reset_n ) begin
			vdp_hcounter <= 0;
		end
		else if( vdp_hcounter == 1367 ) begin
			vdp_hcounter <= 0;
		end
		else begin
			vdp_hcounter <= vdp_hcounter + 1;
		end
	end

	always @( posedge clk ) begin
		if( !reset_n ) begin
			vdp_vcounter <= 0;
		end
		else if( vdp_hcounter == 1367 ) begin
			if( vdp_vcounter == 523 ) begin
				vdp_vcounter <= 0;
			end
			else begin
				vdp_vcounter <= vdp_vcounter + 1;
			end
		end
	end

	always @( posedge clk ) begin
		if( !reset_n ) begin
			enable <= 0;
		end
		else begin
			enable <= ~enable;
		end
	end

	// --------------------------------------------------------------------
	//	Test bench
	// --------------------------------------------------------------------
	initial begin
		clk				= 0;			//	42.95454MHz
		reset_n			= 0;
		vdp_r			= 0;
		vdp_g			= 0;
		vdp_b			= 0;
		
		@( negedge clk );
		@( negedge clk );
		@( posedge clk );

		reset_n			= 1;
		@( posedge clk );

		i = 0;
		j = 100;
		k = 200;
		repeat( 342 * 600 ) begin
			vdp_r	<= 0;//i;
			vdp_g	<= 0;//j;
			vdp_b	<= 0;//k;
			i++;
			j++;
			k++;
			repeat( 4 ) @( posedge clk );	//	4 dot clock : 342 * 4 = 1368
		end
		$finish;
	end
endmodule
