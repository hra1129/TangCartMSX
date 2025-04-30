// -----------------------------------------------------------------------------
//	Test of vdp_ssg entity
//	Copyright (C)2024 Takayuki Hara (HRA!)
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
	localparam		clk_base	= 1_000_000_000/87_750;	//	ps
	reg					reset;
	reg					clk;
	reg					enable;

	wire		[10:0]	h_cnt;
	wire		[10:0]	v_cnt;
	wire		[1:0]	dot_state;
	wire		[2:0]	eight_dot_state;
	wire		[8:0]	pre_dot_counter_x;
	wire		[8:0]	pre_dot_counter_y;
	wire		[8:0]	pre_dot_counter_yp;
	wire				pre_window_y;
	wire				pre_window_y_sp;
	wire				field;
	wire				window_x;
	wire				p_video_dh_clk;
	wire				p_video_dl_clk;
	wire				p_video_vs_n;

	wire				hd;
	wire				vd;
	wire				hsync;
	wire				hsync_en;
	wire				v_blanking_start;

	reg					vdp_r9_pal_mode;
	reg					reg_r9_interlace_mode;
	reg					reg_r9_y_dots;
	reg			[7:0]	reg_r18_adj;
	reg			[7:0]	reg_r23_vstart_line;
	reg					reg_r25_msk;
	reg			[2:0]	reg_r27_h_scroll;
	reg					reg_r25_yjk;
	reg					centeryjk_r25_n;
	int					i, j;

	// --------------------------------------------------------------------
	//	DUT
	// --------------------------------------------------------------------
	vdp_ssg u_vdp_ssg (
		.reset					( reset					),
		.clk					( clk					),
		.enable					( enable				),
		.h_cnt					( h_cnt					),
		.v_cnt					( v_cnt					),
		.dot_state				( dot_state				),
		.eight_dot_state		( eight_dot_state		),
		.pre_dot_counter_x		( pre_dot_counter_x		),
		.pre_dot_counter_y		( pre_dot_counter_y		),
		.pre_dot_counter_yp		( pre_dot_counter_yp	),
		.pre_window_y			( pre_window_y			),
		.pre_window_y_sp		( pre_window_y_sp		),
		.field					( field					),
		.window_x				( window_x				),
		.p_video_dh_clk			( p_video_dh_clk		),
		.p_video_dl_clk			( p_video_dl_clk		),
		.p_video_vs_n			( p_video_vs_n			),
		.hd						( hd					),
		.vd						( vd					),
		.hsync					( hsync					),
		.hsync_en				( hsync_en				),
		.v_blanking_start		( v_blanking_start		),
		.vdp_r9_pal_mode		( vdp_r9_pal_mode		),
		.reg_r9_interlace_mode	( reg_r9_interlace_mode	),
		.reg_r9_y_dots			( reg_r9_y_dots			),
		.reg_r18_adj			( reg_r18_adj			),
		.reg_r23_vstart_line	( reg_r23_vstart_line	),
		.reg_r25_msk			( reg_r25_msk			),
		.reg_r27_h_scroll		( reg_r27_h_scroll		),
		.reg_r25_yjk			( reg_r25_yjk			),
		.centeryjk_r25_n		( centeryjk_r25_n		)
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
		reset					= 1;
		clk						= 0;
		enable					= 1;
		vdp_r9_pal_mode			= 0;
		reg_r9_interlace_mode	= 0;
		reg_r9_y_dots			= 0;
		reg_r18_adj				= 0;
		reg_r23_vstart_line		= 0;
		reg_r25_msk				= 0;
		reg_r27_h_scroll		= 0;
		reg_r25_yjk				= 0;
		centeryjk_r25_n			= 0;

		@( negedge clk );
		@( negedge clk );
		@( posedge clk );

		reset					= 0;
		@( posedge clk );

		for( i = 0; i < 10; i++ ) begin
			$display( "[%d]", i );
			repeat( 1368 * 1000 ) begin
				@( posedge clk );
			end
		end

		$finish;
	end
endmodule
