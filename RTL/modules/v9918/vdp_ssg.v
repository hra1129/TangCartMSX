//
//	vdp_ssg.v
//	 Synchronous Signal Generator
//
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

module vdp_ssg (
	input				reset,
	input				clk,
	input				enable,

	output		[10:0]	h_cnt,
	output		[10:0]	v_cnt,
	output		[1:0]	dot_state,
	output		[2:0]	eight_dot_state,
	output		[8:0]	pre_dot_counter_x,
	output		[8:0]	pre_dot_counter_y,
	output		[8:0]	pre_dot_counter_yp,
	output				pre_window_y,
	output				pre_window_y_sp,
	output				field,
	output				window_x,
	output				p_video_dh_clk,
	output				p_video_dl_clk,
	output				p_video_vs_n,

	output				hd,
	output				vd,
	output				hsync,
	output				hsync_en,
	output				v_blanking_start
);
	localparam		clocks_per_line				= 1368;
	localparam		offset_x					= 49;
	localparam		offset_y					= 19;
	localparam		led_tv_x_ntsc				= -3;
	localparam		led_tv_y_ntsc				= 1;
	localparam		v_blanking_start_192_ntsc	= 240;
	localparam		v_blanking_start_212_ntsc	= 250;
	localparam		left_border					= 235;

	// flip flop
	reg		[10:0]	ff_h_cnt;
	reg		[ 9:0]	ff_v_cnt_in_field;
	reg				ff_field;
	reg		[10:0]	ff_v_cnt_in_frame;

	reg				ff_hsync_en;
	reg				ff_pre_window_y;
	reg				ff_pre_window_y_sp;
	reg				ff_video_vs_n;
	reg		[ 1:0]	ff_dotstate;
	reg		[ 2:0]	ff_eightdotstate;
	reg		[ 8:0]	ff_pre_x_cnt;
	reg		[ 8:0]	ff_x_cnt;
	reg		[ 8:0]	ff_pre_y_cnt;
	reg		[ 8:0]	ff_monitor_line;
	reg				ff_video_dh_clk;
	reg				ff_video_dl_clk;
	reg		[ 8:0]	ff_right_mask;
	reg				ff_window_x;
	reg				ff_h_blank;
	reg				ff_v_blank;

	// wire
	wire			w_hsync;
	wire			w_v_blanking_start;
	wire			w_v_blanking_end;
	wire	[8:0]	w_v_sync_intr_start_line;

	wire			w_h_cnt_half;
	wire			w_h_cnt_end;
	wire	[9:0]	w_field_end_cnt;
	wire			w_field_end;
	wire			w_h_blank_start;
	wire			w_h_blank_end;

	// --------------------------------------------------------------------
	//	horizontal counter
	// --------------------------------------------------------------------
	assign w_h_cnt_half		=	( ff_h_cnt == (clocks_per_line/2)-1 ) ? 1'b1: 1'b0;
	assign w_h_cnt_end		=	( ff_h_cnt ==  clocks_per_line   -1 ) ? 1'b1: 1'b0;

	always @( posedge clk ) begin
		if( reset ) begin
			ff_h_cnt <= 11'd0;
		end
		else if( !enable ) begin
			//	hold
		end
		else if( w_h_cnt_end ) begin
			ff_h_cnt <= 11'd0;
		end
		else begin
			ff_h_cnt <= ff_h_cnt + 1;
		end
	end

	// --------------------------------------------------------------------
	//	vertical counter
	// --------------------------------------------------------------------
	assign w_field_end_cnt	= 10'd523;
	assign w_field_end		= ( ff_v_cnt_in_field == w_field_end_cnt ) ? 1'b1: 1'b0;

	always @( posedge clk ) begin
		if( reset ) begin
			ff_v_cnt_in_field	<= 10'd0;
		end
		else if( !enable ) begin
			//	hold
		end
		else if( w_h_cnt_half || w_h_cnt_end ) begin
			if( w_field_end ) begin
				ff_v_cnt_in_field <= 10'd0;
			end
			else begin
				ff_v_cnt_in_field <= ff_v_cnt_in_field + 10'd1;
			end
		end
	end

	// --------------------------------------------------------------------
	//	vertical counter in frame
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( reset ) begin
			ff_v_cnt_in_frame	<= 11'd0;
		end
		else if( !enable ) begin
			//	hold
		end
		else if( w_h_cnt_half || w_h_cnt_end ) begin
			if( w_field_end && ff_field ) begin
				ff_v_cnt_in_frame	<= 11'd0;
			end
			else begin
				ff_v_cnt_in_frame	<= ff_v_cnt_in_frame + 1;
			end
		end
	end

	//---------------------------------------------------------------------------
	//	port assignment
	//---------------------------------------------------------------------------
	assign h_cnt				= ff_h_cnt;
	assign v_cnt				= ff_v_cnt_in_frame;
	assign dot_state			= ff_dotstate;
	assign eight_dot_state		= ff_eightdotstate;
	assign field				= ff_field;
	assign window_x				= ff_window_x;
	assign p_video_dh_clk		= ff_video_dh_clk;
	assign p_video_dl_clk		= ff_video_dl_clk;
	assign p_video_vs_n			= ff_video_vs_n;
	assign pre_dot_counter_x	= ff_pre_x_cnt;
	assign pre_dot_counter_y	= ff_pre_y_cnt;
	assign pre_dot_counter_yp	= ff_monitor_line;
	assign pre_window_y			= ff_pre_window_y;
	assign pre_window_y_sp		= ff_pre_window_y_sp;
	assign hd					= ff_h_blank;
	assign vd					= ff_v_blank;
	assign hsync				= ( ff_h_cnt[1:0] == 2'b10 && ff_pre_x_cnt == 9'b111111111 ) ? 1'b1: 1'b0;
	assign hsync_en				= ff_hsync_en;
	assign v_blanking_start		= w_v_blanking_start;

	// --------------------------------------------------------------------
	//	field id
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( reset ) begin
			ff_field <= 1'b0;
		end
		else if( !enable ) begin
			//	hold
		end
		else if( w_h_cnt_half || w_h_cnt_end ) begin
			if( w_field_end ) begin
				ff_field <= ~ff_field;
			end
		end
	end

	// --------------------------------------------------------------------
	// h blanking
	// --------------------------------------------------------------------
	assign w_h_blank_start	=	w_h_cnt_end;
	assign w_h_blank_end	=	( ff_h_cnt == left_border ) ? 1'b1: 1'b0;

	always @( posedge clk ) begin
		if( reset ) begin
			ff_h_blank <= 1'b0;
		end
		else if( !enable ) begin
			//	hold
		end
		else if( w_h_blank_start ) begin
			ff_h_blank <= 1'b1;
		end
		else if( w_h_blank_end ) begin
			ff_h_blank <= 1'b0;
		end
	end

	// --------------------------------------------------------------------
	// v blanking
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( reset ) begin
			ff_v_blank <= 1'b0;
		end
		else if( !enable ) begin
			//	hold
		end
		else if( w_h_blank_end ) begin
			if( w_v_blanking_end ) begin
				ff_v_blank <= 1'b0;
			end
			else if( w_v_blanking_start ) begin
				ff_v_blank <= 1'b1;
			end
		end
	end

	//---------------------------------------------------------------------------
	//	dot state
	//---------------------------------------------------------------------------
	always @( posedge clk ) begin
		if( reset )begin
			ff_dotstate		<= 2'b00;
			ff_video_dh_clk <= 1'b1;
			ff_video_dl_clk <= 1'b1;
		end
		else if( !enable )begin
			// hold
		end
		else if( ff_h_cnt == clocks_per_line-1 )begin
			ff_dotstate		<= 2'b00;
			ff_video_dh_clk <= 1'b1;
			ff_video_dl_clk <= 1'b1;
		end
		else begin
			case( ff_dotstate )
			2'b00:
				begin
					ff_dotstate		<= 2'b01;
					ff_video_dh_clk <= 1'b0;
					ff_video_dl_clk <= 1'b1;
				end
			2'b01:
				begin
					ff_dotstate		<= 2'b11;
					ff_video_dh_clk <= 1'b1;
					ff_video_dl_clk <= 1'b0;
				end
			2'b11:
				begin
					ff_dotstate		<= 2'b10;
					ff_video_dh_clk <= 1'b0;
					ff_video_dl_clk <= 1'b0;
				end
			2'b10:
				begin
					ff_dotstate		<= 2'b00;
					ff_video_dh_clk <= 1'b1;
					ff_video_dl_clk <= 1'b1;
				end
			default:
				begin
					//	hold
				end
			endcase
		end
	end

	//---------------------------------------------------------------------------
	//	8dot state
	//---------------------------------------------------------------------------
	always @( posedge clk ) begin
		if( reset )begin
			ff_eightdotstate <= 3'b000;
		end
		else if( !enable )begin
			// hold
		end
		else if( ff_h_cnt[1:0] == 2'b11 )begin
			if( ff_pre_x_cnt == 0 )begin
				ff_eightdotstate <= 3'b000;
			end
			else begin
				ff_eightdotstate <= ff_eightdotstate + 1;
			end
		end
	end

	//---------------------------------------------------------------------------
	//	generate dotcounter
	//---------------------------------------------------------------------------
	always @( posedge clk ) begin
		if( reset )begin
			ff_pre_x_cnt <= 'd0;
		end
		else if( !enable )begin
			// hold
		end
		else if( ff_h_cnt == { 2'b00, (offset_x + led_tv_x_ntsc    ), 2'b10 } ) begin
			ff_pre_x_cnt <= 9'b111111000;
		end
		else if( ff_h_cnt[1:0] == 2'b10 )begin
			ff_pre_x_cnt <= ff_pre_x_cnt + 1;
		end
	end

	always @( posedge clk ) begin
		if( reset )begin
			ff_x_cnt <= 'd0;
		end
		else if( !enable )begin
			// hold
		end
		else if( ff_h_cnt == { 2'b00, (offset_x + led_tv_x_ntsc), 2'b10 } ) begin
			// hold
		end
		else if( ff_h_cnt[1:0] == 2'b10) begin
			if( ff_pre_x_cnt == 9'b111111111 )begin
				// jp: ff_pre_x_cnt が -1から0にカウントアップする時にff_x_cntを-8にする
				ff_x_cnt <= 9'b111111000;		// -8
			end
			else begin
				ff_x_cnt <= ff_x_cnt + 1;
			end
		end
	end

	//---------------------------------------------------------------------------
	// generate v-sync pulse
	//---------------------------------------------------------------------------
	always @( posedge clk ) begin
		if( reset )begin
			ff_video_vs_n <= 1'b1;
		end
		else if( !enable )begin
			// hold
		end
		else if( ff_v_cnt_in_field == 10'd6 )begin
			// sstate = sstate_b
			ff_video_vs_n <= 1'b0;
		end
		else if( ff_v_cnt_in_field == 10'd12 )begin
			// sstate = sstate_a
			ff_video_vs_n <= 1'b1;
		end
	end

	//---------------------------------------------------------------------------
	//	display window
	//---------------------------------------------------------------------------
	always @( posedge clk ) begin
		// main window
		if( !enable )begin
			// hold
		end
		else if( ff_h_cnt[1:0] == 2'b01 && ff_x_cnt == 9'd0 )begin
			// when dotcounter_x = 0
			ff_right_mask <= 9'd256;
		end
	end

	always @( posedge clk ) begin
		// main window
		if( reset )begin
			ff_window_x <= 1'b0;
		end
		else if( !enable )begin
			// hold
		end
		else if( ff_h_cnt[1:0] == 2'b01 && ff_x_cnt == 9'd0 ) begin
			// when dotcounter_x = 0
			ff_window_x <= 1'b1;
		end
		else if( ff_h_cnt[1:0] == 2'b01 && ff_x_cnt == ff_right_mask ) begin
			// when dotcounter_x = 256
			ff_window_x <= 1'b0;
		end
	end

	//---------------------------------------------------------------------------
	// y
	//---------------------------------------------------------------------------
	assign w_hsync		=	( ff_h_cnt[1:0] == 2'b10 && ff_pre_x_cnt == 9'b111111111 );

	always @( posedge clk ) begin :window_y
		reg		[8:0]	pre_dot_counter_yp_v;
		reg		[8:0]	pre_dot_counter_yp_start;

		if( reset ) begin
			ff_pre_y_cnt		<= 'd0;
			ff_monitor_line		<= 'd0;
			ff_pre_window_y		<= 1'b0;
			ff_pre_window_y_sp	<= 1'b0;
			ff_hsync_en			<= 1'b0;
		end
		else if( !enable )begin
			// hold
		end
		else if( w_hsync )begin
			// jp: prewindow_xが 1になるタイミングと同じタイミングでy座標の計算
			if( w_v_blanking_end )begin
				pre_dot_counter_yp_start = 9'b111100110;					// top border lines = -26
				ff_monitor_line <= pre_dot_counter_yp_start;
				ff_pre_window_y_sp	<= 1'b1;
			end
			else begin
				if( pre_dot_counter_yp_v == 9'd255 )begin
					pre_dot_counter_yp_v = ff_monitor_line;
				end
				else begin
					pre_dot_counter_yp_v = ff_monitor_line + 1;
				end
				if( pre_dot_counter_yp_v == 9'd0 ) begin
					ff_hsync_en			<= 1'b1;
					ff_pre_window_y		<= 1'b1;
				end
				else if( pre_dot_counter_yp_v == 9'd192 ) begin
					ff_pre_window_y		<= 1'b0;
					ff_pre_window_y_sp	<= 1'b0;
				end
				else if( pre_dot_counter_yp_v == 9'd235 ) begin
					ff_hsync_en		<= 1'b0;
				end
				ff_monitor_line		<= pre_dot_counter_yp_v;
			end
		end

		if( !enable )begin
			// hold
		end
		else begin
			ff_pre_y_cnt <= ff_monitor_line;
		end
	end

	//---------------------------------------------------------------------------
	// vsync interrupt request
	//---------------------------------------------------------------------------
	assign	w_v_sync_intr_start_line	= v_blanking_start_192_ntsc;

	assign	w_v_blanking_end			= (ff_v_cnt_in_field == { 2'b00, (offset_y + led_tv_y_ntsc),          ff_field } );
	assign	w_v_blanking_start			= (ff_v_cnt_in_field == { (w_v_sync_intr_start_line + led_tv_y_ntsc), ff_field } );

endmodule
