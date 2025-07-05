// -----------------------------------------------------------------------------
//	Test of vdp_video_out.v
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
	localparam			clk_base		= 1_000_000_000/42_954_540;	//	ns

	// --------------------------------------------------------------------
	//	Signal declarations for DUT ports
	// --------------------------------------------------------------------
	logic				clk;
	logic				reset_n;
	logic		[10:0]	h_count;
	logic		[ 9:0]	v_count;
	logic				has_scanline;
	// input pixel
	logic		[7:0]	vdp_r;
	logic		[7:0]	vdp_g;
	logic		[7:0]	vdp_b;
	// read side
	logic		[7:0]	video_r;
	logic		[7:0]	video_g;
	logic		[7:0]	video_b;
	// parameters
	logic		[7:0]	reg_denominator;
	logic		[7:0]	reg_normalize;
	logic				reg_scanline;

	// --------------------------------------------------------------------
	//	Loop variables
	// --------------------------------------------------------------------
	integer				i, j, jj;

	// --------------------------------------------------------------------
	//	DUT
	// --------------------------------------------------------------------
	vdp_video_out u_video_out (
		.clk				( clk ),
		.reset_n			( reset_n ),
		.h_count			( h_count ),
		.v_count			( v_count ),
		.has_scanline		( has_scanline ),
		.vdp_r				( vdp_r ),
		.vdp_g				( vdp_g ),
		.vdp_b				( vdp_b ),
		.video_r			( video_r ),
		.video_g			( video_g ),
		.video_b			( video_b ),
		.reg_denominator	( reg_denominator ),
		.reg_normalize		( reg_normalize ),
		.reg_scanline		( reg_scanline )
	);

	// --------------------------------------------------------------------
	//	clock
	// --------------------------------------------------------------------
	always #(clk_base/2) begin
		clk <= ~clk;
	end

	// --------------------------------------------------------------------
	//	Test bench
	// --------------------------------------------------------------------
	initial begin
		// Initialize signals
		clk = 0;
		reset_n = 0;
		h_count = 0;
		v_count = 0;
		has_scanline = 0;
		vdp_r = 0;
		vdp_g = 0;
		vdp_b = 0;
		reg_denominator = 8'd144;		// Default value
		reg_normalize = 8'd228;			// Default value (8192/144 ≈ 57)
		reg_scanline = 0;

		// Reset sequence
		@( posedge clk );
		@( posedge clk );
		@( posedge clk );
		reset_n <= 1;
		@( posedge clk );

		$display( "[test001] vdp_video_out basic functionality test" );
		
		// Test basic video input/output
		for( j = 0; j < 16; j++ ) begin
			for( i = 0; i < 1368; i++ ) begin	// One line
				h_count <= i;
				v_count <= j;
				has_scanline <= (j % 2 == 1);	// Scanline every other line
				
				// Set some test colors
				vdp_r <= 8'hFF;
				vdp_g <= 8'h80;
				vdp_b <= 8'h40;
				
				@( posedge clk );
			end
		end

		$display( "[test002] Different denominator values" );
		
		// Test different denominator values
		reg_denominator <= 8'd200;
		reg_normalize <= 8'd160;		// 8192/200 ≈ 41
		
		for( j = 0; j < 8; j++ ) begin
			for( i = 0; i < 1368; i++ ) begin	// One line
				h_count <= i;
				v_count <= j;
				has_scanline <= 0;
				
				// Set different test colors
				vdp_r <= 8'h00;
				vdp_g <= 8'hFF;
				vdp_b <= 8'h80;
				
				@( posedge clk );
			end
		end

		$display( "[test003] Scanline mode test" );
		
		reg_scanline <= 1;
		
		for( j = 0; j < 8; j++ ) begin
			for( i = 0; i < 1368; i++ ) begin	// One line
				h_count <= i;
				v_count <= j;
				has_scanline <= 1;
				
				// Set test colors
				vdp_r <= 8'h80;
				vdp_g <= 8'h40;
				vdp_b <= 8'hFF;
				
				@( posedge clk );
			end
		end

		$display( "[test---] Finished" );
		repeat( 10 ) @( posedge clk );
		$finish;
	end
endmodule
