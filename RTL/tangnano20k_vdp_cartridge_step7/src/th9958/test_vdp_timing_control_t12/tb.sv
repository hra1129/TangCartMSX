// -----------------------------------------------------------------------------
//	Test of vdp_timing_control_t12.v
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

	localparam			c_mode_t1	= 5'b000_01;	//	Text1 (SCREEN0:WIDTH40)
	localparam			c_mode_t1q	= 5'b001_01;	//	Text1 (SCREEN0:WIDTH40)
	localparam			c_mode_t2	= 5'b010_01;	//	Text2 (SCREEN0:WIDTH80)

	reg					reset_n;
	reg					clk;						//	42.95454MHz

	reg			[12:0]	screen_pos_x;
	reg			[ 9:0]	screen_pos_y;
	reg					screen_active;

	wire		[16:0]	vram_address;
	wire				vram_valid;
	reg			[7:0]	vram_rdata;

	wire		[3:0]	display_color;

	reg			[4:0]	reg_screen_mode;
	reg			[16:10]	reg_pattern_name_table_base;
	reg			[16:6]	reg_color_table_base;
	reg			[16:11]	reg_pattern_generator_table_base;
	reg			[3:0]	reg_backdrop_color;
	int					i, j, jj;

	// --------------------------------------------------------------------
	//	DUT
	// --------------------------------------------------------------------
	vdp_timing_control_t12 u_timing_control_t12 ( .* );

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
		clk = 0;
		reset_n = 0;
		screen_pos_x = 0;
		screen_pos_y = 0;
		screen_active = 0;
		vram_rdata = 0;
		reg_screen_mode = c_mode_t1;
		reg_pattern_name_table_base = 0;
		reg_pattern_name_table_base = 0;
		reg_color_table_base = 0;
		reg_pattern_generator_table_base = 0;
		reg_backdrop_color = 0;

		@( posedge clk );
		@( posedge clk );
		@( posedge clk );
		reset_n <= 1;
		@( posedge clk );

		$display( "[test001] SCREEN0(W40) Inactive mode" );
		jj = 0;
		reg_screen_mode = c_mode_t1;
		for( j = 0; j < 16; j++ ) begin
			for( i = 0; i < 2736; i++ ) begin
				screen_pos_x <= i - 128;
				screen_pos_y <= -10;
				screen_active <= 1'b0;
				@( posedge clk );
				assert( vram_valid == 1'b0 );
				if( (i % 64) == 63 ) begin
					jj = j;
				end
			end
		end

		$display( "[test002] SCREEN0(E40) Active phase" );
		for( j = 0; j < 16; j++ ) begin
			for( i = 0; i < 2736; i++ ) begin
				screen_pos_x <= i - 128;
				screen_pos_y <= 0;
				screen_active <= 1'b1;
				@( posedge clk );
				if( (i % 64) == 63 ) begin
					jj = j;
				end
			end
		end

		$display( "[test001] SCREEN0(W40) Inactive mode" );
		reg_screen_mode = c_mode_t1q;
		for( j = 0; j < 16; j++ ) begin
			for( i = 0; i < 2736; i++ ) begin
				screen_pos_x <= i - 128;
				screen_pos_y <= -10;
				screen_active <= 1'b0;
				@( posedge clk );
				assert( vram_valid == 1'b0 );
				if( (i % 64) == 63 ) begin
					jj = j;
				end
			end
		end

		$display( "[test002] SCREEN0(W40) Active phase" );
		for( j = 0; j < 16; j++ ) begin
			for( i = 0; i < 2736; i++ ) begin
				screen_pos_x <= i - 128;
				screen_pos_y <= 0;
				screen_active <= 1'b1;
				@( posedge clk );
				if( (i % 64) == 63 ) begin
					jj = j;
				end
			end
		end

		$display( "[test001] SCREEN0(W80) Inactive mode" );
		reg_screen_mode = c_mode_t2;
		for( j = 0; j < 16; j++ ) begin
			for( i = 0; i < 2736; i++ ) begin
				screen_pos_x <= i - 128;
				screen_pos_y <= -10;
				screen_active <= 1'b0;
				@( posedge clk );
				assert( vram_valid == 1'b0 );
				if( (i % 64) == 63 ) begin
					jj = j;
				end
			end
		end

		$display( "[test002] SCREEN0(W80) Active phase" );
		for( j = 0; j < 16; j++ ) begin
			for( i = 0; i < 2736; i++ ) begin
				screen_pos_x <= i - 128;
				screen_pos_y <= 0;
				screen_active <= 1'b1;
				@( posedge clk );
				if( (i % 64) == 63 ) begin
					jj = j;
				end
			end
		end

		$display( "[test---] Finished" );
		repeat( 10 ) @( posedge clk );
		$finish;
	end
endmodule
