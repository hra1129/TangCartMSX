// -----------------------------------------------------------------------------
//	Test of video_out_hmag.v
//	Copyright (C)2025 Takayuki Hara (HRA!)
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
			vdp_r	<= i;
			vdp_g	<= j;
			vdp_b	<= k;
			i++;
			j++;
			k++;
			repeat( 4 ) @( posedge clk );	//	4 dot clock : 342 * 4 = 1368
		end
		$finish;
	end
endmodule
