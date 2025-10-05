// -----------------------------------------------------------------------------
//	Test of sprite_divide_table.v
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
	localparam			clk_base		= 1_000_000_000/85_909_080;	//	ns

	reg					reset_n;
	reg					clk;
	reg			[7:0]	x;
	reg			[7:0]	reg_mgx;
	reg			[1:0]	bit_shift;
	wire		[6:0]	sample_x;				//	3clk delay

	// --------------------------------------------------------------------
	//	Loop variables
	// --------------------------------------------------------------------
	integer				i, j, k;

	// --------------------------------------------------------------------
	//	DUT
	// --------------------------------------------------------------------
	vdp_sprite_divide_table u_dut (
		.reset_n		( reset_n		),
		.clk			( clk			),
		.x				( x				),
		.reg_mgx		( reg_mgx		),
		.bit_shift		( bit_shift		),
		.sample_x		( sample_x		)
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
		reset_n		= 0;
		clk			= 0;
		x			= 0;
		reg_mgx		= 0;
		bit_shift	= 0;

		// Reset sequence
		@( posedge clk );
		@( posedge clk );
		@( posedge clk );
		reset_n <= 1;
		@( posedge clk );

		$display( "[test001] MGX=16, BIT_SHIFT=0" );
		bit_shift	= 0;
		for( i = 0; i < 20; i++ ) begin
			x		<= i;
			reg_mgx	<= 16;
			@( posedge clk );
		end
		repeat( 10 ) @( posedge clk );

		$display( "[test002] MGX=16, BIT_SHIFT=1" );
		bit_shift	= 1;
		for( i = 0; i < 20; i++ ) begin
			x		<= i;
			reg_mgx	<= 16;
			@( posedge clk );
		end
		repeat( 10 ) @( posedge clk );

		$display( "[test003] MGX=16, BIT_SHIFT=2" );
		bit_shift	= 2;
		for( i = 0; i < 20; i++ ) begin
			x		<= i;
			reg_mgx	<= 16;
			@( posedge clk );
		end
		repeat( 10 ) @( posedge clk );

		$display( "[test004] MGX=16, BIT_SHIFT=3" );
		bit_shift	= 3;
		for( i = 0; i < 20; i++ ) begin
			x		<= i;
			reg_mgx	<= 16;
			@( posedge clk );
		end
		repeat( 10 ) @( posedge clk );

		$display( "[test005] MGX=19, BIT_SHIFT=0" );
		bit_shift	= 0;
		for( i = 0; i < 25; i++ ) begin
			x		<= i;
			reg_mgx	<= 19;
			@( posedge clk );
		end
		repeat( 10 ) @( posedge clk );

		$display( "[test006] MGX=19, BIT_SHIFT=1" );
		bit_shift	= 1;
		for( i = 0; i < 25; i++ ) begin
			x		<= i;
			reg_mgx	<= 19;
			@( posedge clk );
		end
		repeat( 10 ) @( posedge clk );

		$display( "[test007] MGX=19, BIT_SHIFT=2" );
		bit_shift	= 2;
		for( i = 0; i < 25; i++ ) begin
			x		<= i;
			reg_mgx	<= 19;
			@( posedge clk );
		end
		repeat( 10 ) @( posedge clk );

		$display( "[test008] MGX=19, BIT_SHIFT=3" );
		bit_shift	= 3;
		for( i = 0; i < 25; i++ ) begin
			x		<= i;
			reg_mgx	<= 19;
			@( posedge clk );
		end
		repeat( 10 ) @( posedge clk );

		$display( "[test009] MGX=128, BIT_SHIFT=0" );
		bit_shift	= 0;
		for( i = 0; i < 135; i++ ) begin
			x		<= i;
			reg_mgx	<= 128;
			@( posedge clk );
		end
		repeat( 10 ) @( posedge clk );

		$display( "[test010] MGX=128, BIT_SHIFT=1" );
		bit_shift	= 1;
		for( i = 0; i < 135; i++ ) begin
			x		<= i;
			reg_mgx	<= 128;
			@( posedge clk );
		end
		repeat( 10 ) @( posedge clk );

		$display( "[test011] MGX=128, BIT_SHIFT=2" );
		bit_shift	= 2;
		for( i = 0; i < 135; i++ ) begin
			x		<= i;
			reg_mgx	<= 128;
			@( posedge clk );
		end
		repeat( 10 ) @( posedge clk );

		$display( "[test012] MGX=128, BIT_SHIFT=3" );
		bit_shift	= 3;
		for( i = 0; i < 135; i++ ) begin
			x		<= i;
			reg_mgx	<= 128;
			@( posedge clk );
		end
		repeat( 10 ) @( posedge clk );

		$display( "[test013] MGX=0, BIT_SHIFT=0" );
		bit_shift	= 0;
		for( i = 0; i < 260; i++ ) begin
			x		<= i;
			reg_mgx	<= 0;
			@( posedge clk );
		end
		repeat( 10 ) @( posedge clk );

		$display( "[test014] MGX=0, BIT_SHIFT=1" );
		bit_shift	= 1;
		for( i = 0; i < 260; i++ ) begin
			x		<= i;
			reg_mgx	<= 0;
			@( posedge clk );
		end
		repeat( 10 ) @( posedge clk );

		$display( "[test015] MGX=0, BIT_SHIFT=2" );
		bit_shift	= 2;
		for( i = 0; i < 260; i++ ) begin
			x		<= i;
			reg_mgx	<= 0;
			@( posedge clk );
		end
		repeat( 10 ) @( posedge clk );

		$display( "[test016] MGX=0, BIT_SHIFT=3" );
		bit_shift	= 3;
		for( i = 0; i < 260; i++ ) begin
			x		<= i;
			reg_mgx	<= 0;
			@( posedge clk );
		end
		repeat( 10 ) @( posedge clk );

		$display( "[test017] BIT_SHIFT=3, MGX=64...256" );
		bit_shift	= 3;
		for( i = 64; i < 256; i++ ) begin
			for( j = 0; j < 256; j+=3 ) begin
				x		<= j;
				reg_mgx	<= i & 255;
				@( posedge clk );
			end
			repeat( 10 ) @( posedge clk );
		end
		repeat( 10 ) @( posedge clk );

		$display( "[test---] Finished" );
		repeat( 10 ) @( posedge clk );
		$finish;
	end
endmodule
