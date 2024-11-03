//
//	vdp.v
//	 FPGA9958 top entity
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

module vdp(
	input					reset,
	input					initial_busy,
	input					clk,				//	21.47727MHz or over
	input					enable,				//	21.47727MHz pulse
	input					req,
	output					ack,
	input					wrt,
	input		[1:0]		adr,
	output		[7:0]		dbi,
	input		[7:0]		dbo,

	output					int_n,

	output					pramoe_n,
	output					pramwe_n,
	output		[16:0]		pramadr,
	input		[15:0]		pramdbi,
	output reg	[7:0]		pramdbo,

	input					vdp_speed_mode,
	input		[2:0]		ratio_mode,
	input					centeryjk_r25_n,

	// video output
	output					pvideo_clk,
	output					pvideo_data_en,

	output		[5:0]		pvideor,
	output		[5:0]		pvideog,
	output		[5:0]		pvideob,

	output					pvideohs_n,
	output					pvideovs_n,

	output					p_video_dh_clk,
	output					p_video_dl_clk,

	// display resolution (0=15kHz, 1=31kHz)
	input					dispreso,

	input					ntsc_pal_type,
	input					forced_v_mode,
	input					legacy_vga,

	input		[4:0]		vdp_id
);
	localparam		clocks_per_line		= 1368;
	localparam		offset_x			= 7'b0110001;
	localparam		led_tv_x_ntsc		= -3;
	localparam		led_tv_y_ntsc		= 1;
	localparam		led_tv_x_pal		= -2;
	localparam		led_tv_y_pal		= 3;

	wire	[10:0]	w_h_count;
	wire	[10:0]	w_v_count;

	// dot state register
	wire	[1:0]	w_dot_state;
	wire	[2:0]	w_eight_dot_state;

	// display w_field signal
	wire			w_field;
	wire			w_hd;
	wire			w_vd;
	reg				ff_active_line;
	wire			w_v_blanking_start;

	// for vsync interrupt
	wire			w_vsync_int_n;
	wire			w_clr_vsync_int;
	wire			req_vsync_int_n;

	// for hsync interrupt
	wire			w_hsync_int_n;
	wire			w_clr_hsync_int;
	wire			req_hsync_int_n;

	// display area flags
	wire			w_window;
	wire			w_window_x;
	reg				ff_prewindow_x;
	wire			w_prewindow_y;
	wire			w_prewindow_y_sp;
	wire			w_prewindow;
	// for frame zone
	reg				ff_bwindow_x;
	reg				ff_bwindow_y;
	reg				ff_bwindow;

	// dot counter - 8 ( reading addr )
	wire	[8:0]	w_pre_dot_counter_x;
	wire	[8:0]	w_pre_dot_counter_y;
	// y counters independent of vertical scroll register
	wire	[8:0]	w_pre_dot_counter_yp;

	// vdp register access
	reg		[16:0]	ff_vram_access_address;
	wire			w_disp_mode_vga;
	reg				ff_vram_reading_req;
	reg				ff_vram_reading_ack;
	wire	[3:1]	w_vdpr0dispnum;
	wire	[7:0]	w_vram_access_data;
	wire	[16:0]	w_vram_access_address_tmp;
	wire			w_vram_addr_set_req;
	reg				ff_vram_addr_set_ack;
	wire			w_vram_write_req;
	reg				ff_vram_write_ack;
	reg		[7:0]	ff_vram_read_data;
	wire			w_vram_rd_req;
	reg				ff_vram_rd_ack;
	wire			w_r9_pal_mode;

	wire			reg_r0_hsync_int_en;
	wire			reg_r1_sp_size;
	wire			reg_r1_sp_zoom;
	wire			reg_r1_bl_clks;
	wire			reg_r1_vsync_int_en;
	wire			reg_r1_disp_on;
	wire	[6:0]	reg_r2_pattern_name;
	wire	[5:0]	reg_r4_pattern_generator;
	wire	[10:0]	reg_r10r3_color;
	wire	[9:0]	reg_r11r5_sp_atr_addr;
	wire	[5:0]	reg_r6_sp_gen_addr;
	wire	[7:0]	reg_r7_frame_col;
	wire			reg_r8_sp_off;
	wire			reg_r8_col0_on;
	wire			reg_r9_pal_mode;
	wire			reg_r9_interlace_mode;
	wire			reg_r9_y_dots;
	wire	[7:0]	reg_r12_blink_mode;
	wire	[7:0]	reg_r13_blink_period;
	wire	[7:0]	reg_r18_adj;
	wire	[7:0]	reg_r19_hsync_int_line;
	wire	[7:0]	reg_r23_vstart_line;
	wire			reg_r25_cmd;
	wire			reg_r25_yae;
	wire			reg_r25_yjk;
	wire			reg_r25_msk;
	wire			reg_r25_sp2;
	wire	[8:3]	reg_r26_h_scroll;
	wire	[2:0]	reg_r27_h_scroll;

	wire			w_text_mode;						// text mode 1, 2 or 1q
	wire			w_vdp_mode_text1;					// text mode 1		(screen0 width 40)
	wire			w_vdp_mode_text1q;					// text mode 1		(??)
	wire			w_vdp_mode_text2;					// text mode 2		(screen0 width 80)
	wire			w_vdp_mode_multi;					// multicolor mode	(screen3)
	wire			w_vdp_mode_multiq;					// multicolor mode	(??)
	wire			w_vdp_mode_graphic1;				// graphic mode 1	(screen1)
	wire			w_vdp_mode_graphic2;				// graphic mode 2	(screen2)
	wire			w_vdp_mode_graphic3;				// graphic mode 2	(screen4)
	wire			w_vdp_mode_graphic4;				// graphic mode 4	(screen5)
	wire			w_vdp_mode_graphic5;				// graphic mode 5	(screen6)
	wire			w_vdp_mode_graphic6;				// graphic mode 6	(screen7)
	wire			w_vdp_mode_graphic7;				// graphic mode 7	(screen8,10,11,12)
	wire			w_vdp_mode_is_highres;				// true when mode graphic5, 6
	wire			w_vdp_mode_is_vram_interleave;		// true when mode graphic6, 7

	// for text 1 and 2
	wire	[16:0]	w_vram_address_text12;
	wire	[3:0]	w_color_code_text12;
	wire			w_tx_vram_read_en;

	// for graphic 1,2,3 and multi color
	wire	[16:0]	w_vram_address_graphic123m;
	wire	[3:0]	w_color_code_graphic123m;

	// for graphic 4,5,6,7
	wire	[16:0]	w_vram_address_graphic4567;
	wire	[7:0]	w_color_code_graphic4567;

	// for YJK color
	wire	[5:0]	w_yjk_r;
	wire	[5:0]	w_yjk_g;
	wire	[5:0]	w_yjk_b;
	wire			w_yjk_en;

	// sprite
	wire			w_sp_mode2;
	wire			w_sp_vram_accessing;
	wire	[16:0]	w_sprite_vram_address;
	wire			w_sp_color_code_en;
	wire	[3:0]	w_sp_color_code;
	wire			w_s0_sp_collision_incidence;
	wire			w_s0_sp_overmapped;
	wire	[4:0]	w_s0_sp_overmapped_num;
	wire	[8:0]	w_s3s4_sp_collision_x;
	wire	[8:0]	w_s5s6_sp_collision_y;
	wire			w_s0_reset_req;
	wire			w_s0_reset_ack;
	wire			w_s5_reset_req;
	wire			w_s5_reset_ack;

	// palette registers
	wire	[3:0]	w_palette_address;
	wire	[7:0]	w_palette_data_rb;
	wire	[7:0]	w_palette_data_g;

	// vdp command signals - can be read & set by cpu
	wire			w_vdpcmd_clr;					// r44, s#7
	// vdp command signals - can be read by cpu
	wire			w_vdpcmd_ce;					// s#2 (bit 0)
	wire			w_vdpcmd_bd;					// s#2 (bit 4)
	wire			w_vdpcmd_tr;					// s#2 (bit 7)
	wire	[10:0]	w_vdpcmd_sx_tmp;				// s#8, s#9

	wire	[3:0]	w_vdpcmd_reg_num;
	wire	[7:0]	w_vdpcmd_reg_data;
	wire			w_vdpcmd_reg_write_ack;
	wire			w_vdpcmd_tr_clr_ack;
	reg				ff_vdpcmd_vram_write_ack;
	reg				ff_vdpcmd_vram_read_ack;
	reg				ff_vdpcmd_vram_reading_req;
	reg				ff_vdpcmd_vram_reading_ack;
	reg		[7:0]	ff_vdpcmd_vram_rdata;
	wire			w_vdpcmd_reg_wr_req;
	wire			w_vdpcmd_tr_clr_req;
	wire			w_vdpcmd_vram_write_req;
	wire			w_vdpcmd_vram_read_req;
	wire	[16:0]	w_vdpcmd_vram_access_address;
	wire	[7:0]	w_vdpcmd_vram_wdata;

	reg				ff_vdp_command_drive;
	wire			w_vdp_command_active;
	wire	[7:4]	w_current_vdp_command;

	// video output signals
	wire	[5:0]	w_video_r;
	wire	[5:0]	w_video_g;
	wire	[5:0]	w_video_b;

	wire	[5:0]	w_video_r_vdp;
	wire	[5:0]	w_video_g_vdp;
	wire	[5:0]	w_video_b_vdp;
	wire			w_video_vsync_n;

	wire	[5:0]	w_video_r_lcd;
	wire	[5:0]	w_video_g_lcd;
	wire	[5:0]	w_video_b_lcd;
	wire			w_video_hs_n_lcd;
	wire			w_video_vs_n_lcd;

	reg		[16:0]	ff_vram_address;
	wire	[7:0]	w_vram_data;
	wire			w_vram_rdata_sel;
	wire	[7:0]	w_vram_data_pair;

	wire			w_hsync;
	wire			w_hsync_en;

	reg				ff_req;
	reg				ff_wrt;
	wire			w_ack;

	reg				ff_pramoe_n;
	reg				ff_pramwe_n;

	localparam	[2:0]	vram_access_idle	= 3'd0;
	localparam	[2:0]	vram_access_draw	= 3'd1;
	localparam	[2:0]	vram_access_cpuw	= 3'd2;
	localparam	[2:0]	vram_access_cpur	= 3'd3;
	localparam	[2:0]	vram_access_sprt	= 3'd4;
	localparam	[2:0]	vram_access_vdpw	= 3'd5;
	localparam	[2:0]	vram_access_vdpr	= 3'd6;
	localparam	[2:0]	vram_access_vdps	= 3'd7;

	// --------------------------------------------------------------------
	assign pramadr			= ff_vram_address;
	assign w_vram_rdata_sel	= ff_vram_address[16];
	assign w_vram_data		= ( !w_vram_rdata_sel ) ? pramdbi[ 7:0] : pramdbi[15:8];
	assign w_vram_data_pair	= (  w_vram_rdata_sel ) ? pramdbi[ 7:0] : pramdbi[15:8];
	assign pramoe_n			= ff_pramoe_n;
	assign pramwe_n			= ff_pramwe_n;

	//--------------------------------------------------------------
	// request signal
	//--------------------------------------------------------------
	always @( posedge clk ) begin
		if( reset ) begin
			ff_req <= 1'b0;
			ff_wrt <= 1'b0;
		end
		else if( enable ) begin
			if( w_ack ) begin
				ff_req <= 1'b0;
			end
			else begin
				ff_req <= req;
				ff_wrt <= wrt;
			end
		end
		else begin
			// hold
		end
	end

	//--------------------------------------------------------------
	// display components
	//--------------------------------------------------------------
	assign w_disp_mode_vga	= dispreso;			// display resolution (0=15khz, 1=31khz)

	assign w_r9_pal_mode	= ( ntsc_pal_type ) ? reg_r9_pal_mode : forced_v_mode;

	assign w_video_r		= ( !ff_bwindow ) ? 6'd0 : w_video_r_vdp;
	assign w_video_g		= ( !ff_bwindow ) ? 6'd0 : w_video_g_vdp;
	assign w_video_b		= ( !ff_bwindow ) ? 6'd0 : w_video_b_vdp;

	// change display mode by external input port.
	assign pvideor			= w_video_r_lcd;
	assign pvideog			= w_video_g_lcd;
	assign pvideob			= w_video_b_lcd;

	// h sync signal
	assign pvideohs_n		= w_video_hs_n_lcd;
	// v sync signal
	assign pvideovs_n		= w_video_vs_n_lcd;

	//---------------------------------------------------------------------------
	// interrupt
	//---------------------------------------------------------------------------

	// vsync interrupt
	assign w_vsync_int_n	= ( reg_r1_vsync_int_en             ) ? req_vsync_int_n : 1'b1;
	// hsync interrupt
	assign w_hsync_int_n	= ( reg_r0_hsync_int_en && w_hsync_en ) ? req_hsync_int_n : 1'b1;

	assign int_n			= w_vsync_int_n & w_hsync_int_n;

	always @( posedge clk ) begin
		if( reset ) begin
			ff_active_line <= 1'b0;
		end
		else if( !enable ) begin
			// hold
		end
		else if( w_pre_dot_counter_x == 255 ) begin
			ff_active_line <= 1'b1;
		end
		else begin
			ff_active_line <= 1'b0;
		end
	end

	// generate ff_bwindow
	always @( posedge clk ) begin
		if( reset ) begin
			ff_bwindow_x <= 1'b0;
		end
		else if( !enable ) begin
			// hold
		end
		else if( w_h_count == 200 ) begin
			ff_bwindow_x <= 1'b1;
		end
		else if( w_h_count == clocks_per_line-1-1 ) begin
			ff_bwindow_x <= 1'b0;
		end
	end

	always @( posedge clk ) begin
		if( reset ) begin
			ff_bwindow_y <= 1'b0;
		end
		else if( !enable ) begin
			// hold
		end
		else if( !reg_r9_interlace_mode ) begin
			// non-interlace
			// 3+3+16 = 19
			if( (w_v_count == 20*2) ||
					((w_v_count == 524+20*2) && !w_r9_pal_mode) ||
					((w_v_count == 626+20*2) &&  w_r9_pal_mode) ) begin
				ff_bwindow_y <= 1'b1;
			end
			else if(((w_v_count == 524) && !w_r9_pal_mode) ||
					((w_v_count == 626) &&  w_r9_pal_mode) ||
					 (w_v_count == 0) ) begin
				ff_bwindow_y <= 1'b0;
			end
		end
		else begin
			// interlace
			if( (w_v_count == 20*2) ||
					// +1 should be needed.
					// because odd field's start is delayed half line.
					// so the start position of display time should be
					// delayed more half line.
					((w_v_count == 525+20*2 + 1) && !w_r9_pal_mode) ||
					((w_v_count == 625+20*2 + 1) &&  w_r9_pal_mode) ) begin
				ff_bwindow_y <= 1'b1;
			end
			else if( ((w_v_count == 525) && !w_r9_pal_mode) ||
					 ((w_v_count == 625) &&  w_r9_pal_mode) ||
					  (w_v_count == 0) ) begin
				ff_bwindow_y <= 1'b0;
			end
		end
	end

	always @( posedge clk ) begin
		if( reset ) begin
			ff_bwindow <= 1'b0;
		end
		else if( !enable ) begin
			// hold
		end
		else begin
			ff_bwindow <= ff_bwindow_x & ff_bwindow_y;
		end
	end

	// generate w_prewindow, w_window
	assign w_window		=	w_window_x     & w_prewindow_y;
	assign w_prewindow	=	ff_prewindow_x & w_prewindow_y;

	always @( posedge clk ) begin
		if( reset ) begin
			ff_prewindow_x <= 1'b0;
		end
		else if( !enable ) begin
			// hold
		end
		else if((w_h_count == {2'b00, (offset_x + led_tv_x_ntsc - {(reg_r25_msk & ~centeryjk_r25_n), 2'b00} + 4), 2'b10} && ( reg_r25_yjk &&  centeryjk_r25_n) && !w_r9_pal_mode) ||
				(w_h_count == {2'b00, (offset_x + led_tv_x_ntsc - {(reg_r25_msk & ~centeryjk_r25_n), 2'b00}    ), 2'b10} && (!reg_r25_yjk || !centeryjk_r25_n) && !w_r9_pal_mode) ||
				(w_h_count == {2'b00, (offset_x + led_tv_x_pal  - {(reg_r25_msk & ~centeryjk_r25_n), 2'b00} + 4), 2'b10} && ( reg_r25_yjk &&  centeryjk_r25_n) &&  w_r9_pal_mode) ||
				(w_h_count == {2'b00, (offset_x + led_tv_x_pal  - {(reg_r25_msk & ~centeryjk_r25_n), 2'b00}    ), 2'b10} && (!reg_r25_yjk || !centeryjk_r25_n) &&  w_r9_pal_mode) ) begin
			// hold
		end
		else if( w_h_count[1:0] == 2'b10) begin
			if( w_pre_dot_counter_x == 9'b111111111 ) begin
				// jp: w_pre_dot_counter_x が -1から0にカウントアップする時にw_windowを1にする
				ff_prewindow_x <= 1'b1;
			end
			else if( w_pre_dot_counter_x == 9'b011111111 ) begin
				ff_prewindow_x <= 1'b0;
			end
		end
	end

	// --------------------------------------------------------------------
	// main process
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( reset ) begin
			ff_vram_read_data		<= 8'd0;
			ff_vram_reading_ack		<= 1'b0;
		end
		else if( !enable ) begin
			// hold
		end
		else if( w_dot_state == 2'b01 ) begin
			if( ff_vram_reading_req != ff_vram_reading_ack ) begin
				ff_vram_read_data		<= w_vram_data;
				ff_vram_reading_ack		<= ~ff_vram_reading_ack;
			end
		end
	end

	always @( posedge clk ) begin
		if( reset ) begin
			ff_vdpcmd_vram_rdata		<= 8'd0;
			ff_vdpcmd_vram_read_ack		<= 1'b0;
			ff_vdpcmd_vram_reading_ack	<= 1'b0;
		end
		else if( !enable ) begin
			// hold
		end
		else if( w_dot_state == 2'b01 ) begin
			if( ff_vdpcmd_vram_reading_req != ff_vdpcmd_vram_reading_ack ) begin
				ff_vdpcmd_vram_rdata		<= w_vram_data;
				ff_vdpcmd_vram_read_ack		<= ~ff_vdpcmd_vram_read_ack;
				ff_vdpcmd_vram_reading_ack	<= ~ff_vdpcmd_vram_reading_ack;
			end
		end
	end

	assign w_text_mode		= w_vdp_mode_text1 | w_vdp_mode_text1q | w_vdp_mode_text2;

	always @( posedge clk ) begin: vram_access
		reg		[16:0]	ff_vram_access_address_pre;
		reg		[2:0]	ff_vram_access_state;

		if( reset ) begin
			ff_vram_address	<= 17'b11111111111111111;
			pramdbo			<= 8'd0;
			ff_pramoe_n		<= 1'b1;
			ff_pramwe_n		<= 1'b1;

			ff_vram_reading_req <= 1'b0;

			ff_vram_rd_ack <= 1'b0;
			ff_vram_write_ack <= 1'b0;
			ff_vram_addr_set_ack <= 1'b0;
			ff_vram_access_address <= 17'd0;

			ff_vdpcmd_vram_write_ack <= 1'b0;
			ff_vdpcmd_vram_reading_req <= 1'b0;
			ff_vdp_command_drive <= 1'b0;
		end
		else if( !enable ) begin
			// hold
		end
		else begin
			//
			// vram access arbiter.
			//
			// vramアクセスタイミングを、w_eight_dot_state によって制御している
			if( w_dot_state == 2'b10 ) begin
				if( w_prewindow && reg_r1_disp_on &&
					((w_eight_dot_state == 3'd0) || (w_eight_dot_state == 3'd1) || (w_eight_dot_state == 3'd2) ||
					 (w_eight_dot_state == 3'd3) || (w_eight_dot_state == 3'd4)) ) begin
					//	w_eight_dot_state が 0～4 で、表示中の場合
					ff_vram_access_state = vram_access_draw;
				end
				else if( w_prewindow && reg_r1_disp_on && w_tx_vram_read_en ) begin
					//	w_eight_dot_state が 5～7 で、表示中で、テキストモードの場合
					ff_vram_access_state = vram_access_draw;
				end
				else if( ff_prewindow_x && w_prewindow_y_sp && w_sp_vram_accessing && (w_eight_dot_state == 3'd5) && !w_text_mode ) begin
					// for sprite y-testing
					ff_vram_access_state = vram_access_sprt;
				end
				else if( !ff_prewindow_x && w_prewindow_y_sp && w_sp_vram_accessing && !w_text_mode && (
							(w_eight_dot_state == 3'd0) || (w_eight_dot_state == 3'd1) || (w_eight_dot_state == 3'd2) ||
							(w_eight_dot_state == 3'd3) || (w_eight_dot_state == 3'd4) || (w_eight_dot_state == 3'd5)) ) begin
					// for sprite prepareing
					ff_vram_access_state = vram_access_sprt;
				end
				else if( w_vram_write_req != ff_vram_write_ack ) begin
					// vram write request by cpu
					ff_vram_access_state = vram_access_cpuw;
				end
				else if( w_vram_rd_req != ff_vram_rd_ack ) begin
					// vram read request by cpu
					ff_vram_access_state = vram_access_cpur;
				end
				else begin
					// vdp command
					if( w_vdp_command_active ) begin
						if( w_vdpcmd_vram_write_req != ff_vdpcmd_vram_write_ack ) begin
							ff_vram_access_state = vram_access_vdpw;
						end
						else if( w_vdpcmd_vram_read_req != ff_vdpcmd_vram_read_ack ) begin
							ff_vram_access_state = vram_access_vdpr;
						end
						else begin
							ff_vram_access_state = vram_access_vdps;
						end
					end
					else begin
						ff_vram_access_state = vram_access_vdps;
					end
				end
			end
			else begin
				ff_vram_access_state = vram_access_draw;
			end

			if( ff_vram_access_state == vram_access_vdpw ||
				ff_vram_access_state == vram_access_vdpr ||
				ff_vram_access_state == vram_access_vdps ) begin
				ff_vdp_command_drive <= 1'b1;
			end
			else begin
				ff_vdp_command_drive <= 1'b0;
			end

			//
			// vram access address switch
			//
			if( ff_vram_access_state == vram_access_cpuw ) begin
				// vram write by cpu
				// jp: graphic6,7ではvram上のアドレスと ram上のアドレスの関係が
				// jp: 他の画面モードと異るので注意
				if( w_vdp_mode_graphic6 || w_vdp_mode_graphic7 ) begin
					ff_vram_address <= { ff_vram_access_address[0], ff_vram_access_address[16:1] };
				end
				else begin
					ff_vram_address <= ff_vram_access_address;
				end
				if( w_vdp_mode_text1 || w_vdp_mode_text1q || w_vdp_mode_multi || w_vdp_mode_multiq || w_vdp_mode_graphic1 || w_vdp_mode_graphic2 ) begin
					ff_vram_access_address[13:0]	<= ff_vram_access_address[13:0] + 14'd1;
				end
				else begin
					ff_vram_access_address		<= ff_vram_access_address + 1;
				end
				pramdbo			<= w_vram_access_data;
				ff_pramoe_n		<= 1'b1;
				ff_pramwe_n		<= 1'b0;
				ff_vram_write_ack	<= ~ff_vram_write_ack;
			end
			else if( ff_vram_access_state == vram_access_cpur ) begin
				// vram read by cpu
				if( w_vram_addr_set_req != ff_vram_addr_set_ack ) begin
					ff_vram_access_address_pre = w_vram_access_address_tmp;
					// clear vram address set request signal
					ff_vram_addr_set_ack <= ~ff_vram_addr_set_ack;
				end
				else begin
					ff_vram_access_address_pre = ff_vram_access_address;
				end

				// jp: graphic6,7ではvram上のアドレスと ram上のアドレスの関係が
				// jp: 他の画面モードと異るので注意
				if( w_vdp_mode_graphic6 || w_vdp_mode_graphic7 ) begin
					ff_vram_address <= { ff_vram_access_address_pre[0], ff_vram_access_address_pre[16:1] };
				end
				else begin
					ff_vram_address <= ff_vram_access_address_pre;
				end
				if( w_vdp_mode_text1 || w_vdp_mode_text1q || w_vdp_mode_multi || w_vdp_mode_multiq || w_vdp_mode_graphic1 || w_vdp_mode_graphic2 ) begin
					ff_vram_access_address[13:0] <= ff_vram_access_address_pre[13:0] + 1;
				end
				else begin
					ff_vram_access_address <= ff_vram_access_address_pre + 1;
				end
				pramdbo				<= 8'd0;
				ff_pramoe_n			<= 1'b0;
				ff_pramwe_n			<= 1'b1;
				ff_vram_rd_ack		<= ~ff_vram_rd_ack;
				ff_vram_reading_req	<= ~ff_vram_reading_ack;
			end
			else if( ff_vram_access_state == vram_access_vdpw ) begin
				// vram write by vdp command
				// vdp command write vram.
				// jp: Graphic6, 7 (Screen 7, 8) ではアドレスと ram上の位置が他の画面モードと
				// jp: 異るので注意
				if( w_vdp_mode_graphic6 || w_vdp_mode_graphic7 ) begin
					ff_vram_address <= { w_vdpcmd_vram_access_address[0], w_vdpcmd_vram_access_address[16:1] };
				end
				else begin
					ff_vram_address <= w_vdpcmd_vram_access_address;
				end
				pramdbo		<= w_vdpcmd_vram_wdata;
				ff_pramoe_n	<= 1'b1;
				ff_pramwe_n	<= 1'b0;
				ff_vdpcmd_vram_write_ack	<= ~ff_vdpcmd_vram_write_ack;
			end
			else if( ff_vram_access_state == vram_access_vdpr ) begin
				// vram read by vdp command
				// jp: Graphic6, 7 (Screen 7, 8) ではアドレスと ram上の位置が他の画面モードと
				// jp: 異るので注意
				if( w_vdp_mode_graphic6 || w_vdp_mode_graphic7 ) begin
					ff_vram_address <= { w_vdpcmd_vram_access_address[0], w_vdpcmd_vram_access_address[16:1] };
				end
				else begin
					ff_vram_address <= w_vdpcmd_vram_access_address;
				end
				pramdbo		<= 8'd0;
				ff_pramoe_n	<= 1'b0;
				ff_pramwe_n	<= 1'b1;
				ff_vdpcmd_vram_reading_req	<= ~ff_vdpcmd_vram_reading_ack;
			end
			else if( ff_vram_access_state == vram_access_sprt ) begin
				// vram read by sprite module
				ff_vram_address		<= w_sprite_vram_address;
				ff_pramoe_n			<= 1'b0;
				ff_pramwe_n			<= 1'b1;
				pramdbo				<= 8'd0;
			end
			else begin
				// vram_access_draw
				// vram read for screen image building
				if( w_dot_state == 2'b10 ) begin
					pramdbo		<= 8'd0;
					ff_pramoe_n	<= 1'b0;
					ff_pramwe_n	<= 1'b1;
					if( w_text_mode ) begin
						ff_vram_address <= w_vram_address_text12;
					end
					else if( w_vdp_mode_graphic1 || w_vdp_mode_graphic2 || w_vdp_mode_graphic3 || w_vdp_mode_multi || w_vdp_mode_multiq ) begin
						ff_vram_address <= w_vram_address_graphic123m;
					end
					else if( w_vdp_mode_graphic4 || w_vdp_mode_graphic5 || w_vdp_mode_graphic6 || w_vdp_mode_graphic7 ) begin
						ff_vram_address <= w_vram_address_graphic4567;
					end
				end
				else begin
					pramdbo		<= 8'd0;
					ff_pramoe_n	<= 1'b1;
					ff_pramwe_n	<= 1'b1;
				end

				if( (w_dot_state == 2'b11) && (w_vram_addr_set_req != ff_vram_addr_set_ack) ) begin
					ff_vram_access_address	<= w_vram_access_address_tmp;
					ff_vram_addr_set_ack	<= ~ff_vram_addr_set_ack;
				end
			end
		end
	end

	// --------------------------------------------------------------------
	//	Interrupt
	// --------------------------------------------------------------------
	vdp_interrupt u_interrupt(
		.reset							( reset							),
		.clk							( clk							),
		.enable							( enable						),

		.h_cnt							( w_h_count						),
		.y_cnt							( w_pre_dot_counter_y[7:0]		),
		.active_line					( ff_active_line				),
		.v_blanking_start				( w_v_blanking_start			),
		.clr_vsync_int					( w_clr_vsync_int				),
		.clr_hsync_int					( w_clr_hsync_int				),
		.req_vsync_int_n				( req_vsync_int_n				),
		.req_hsync_int_n				( req_hsync_int_n				),
		.reg_r19_hsync_int_line			( reg_r19_hsync_int_line		)
	);

	//---------------------------------------------------------------------------
	// synchronous signal generator
	//---------------------------------------------------------------------------
	vdp_ssg u_ssg(
		.reset							( reset							),
		.clk							( clk							),
		.enable							( enable						),

		.h_cnt							( w_h_count						),
		.v_cnt							( w_v_count						),
		.dot_state						( w_dot_state					),
		.eight_dot_state				( w_eight_dot_state				),
		.pre_dot_counter_x				( w_pre_dot_counter_x			),
		.pre_dot_counter_y				( w_pre_dot_counter_y			),
		.pre_dot_counter_yp				( w_pre_dot_counter_yp			),
		.pre_window_y					( w_prewindow_y					),
		.pre_window_y_sp				( w_prewindow_y_sp				),
		.field							( w_field						),
		.window_x						( w_window_x					),
		.p_video_dh_clk					( p_video_dh_clk				),
		.p_video_dl_clk					( p_video_dl_clk				),
		.p_video_vs_n					( w_video_vsync_n				),

		.hd								( w_hd							),
		.vd								( w_vd							),
		.hsync							( w_hsync						),
		.hsync_en						( w_hsync_en					),
		.v_blanking_start				( w_v_blanking_start			),

		.vdp_r9_pal_mode				( w_r9_pal_mode					),
		.reg_r9_interlace_mode			( reg_r9_interlace_mode			),
		.reg_r9_y_dots					( reg_r9_y_dots					),
		.reg_r18_adj					( reg_r18_adj					),
		.reg_r23_vstart_line			( reg_r23_vstart_line			),
		.reg_r25_msk					( reg_r25_msk					),
		.reg_r27_h_scroll				( reg_r27_h_scroll				),
		.reg_r25_yjk					( reg_r25_yjk					),
		.centeryjk_r25_n				( centeryjk_r25_n				)
	);

	//---------------------------------------------------------------------
	// color decoding
	//-----------------------------------------------------------------------
	vdp_colordec u_vdp_colordec(
		.reset							( reset							),
		.clk							( clk							),
		.enable							( enable						),

		.dot_state						( w_dot_state					),

		.ppaletteaddr_out				( w_palette_address				),
		.palettedatarb_out				( w_palette_data_rb				),
		.palettedatag_out				( w_palette_data_g				),

		.vdp_mode_text1					( w_vdp_mode_text1				),
		.vdp_mode_text1q				( w_vdp_mode_text1q				),
		.vdp_mode_text2					( w_vdp_mode_text2				),
		.vdp_mode_multi					( w_vdp_mode_multi				),
		.vdp_mode_multiq				( w_vdp_mode_multiq				),
		.vdp_mode_graphic1				( w_vdp_mode_graphic1			),
		.vdp_mode_graphic2				( w_vdp_mode_graphic2			),
		.vdp_mode_graphic3				( w_vdp_mode_graphic3			),
		.vdp_mode_graphic4				( w_vdp_mode_graphic4			),
		.vdp_mode_graphic5				( w_vdp_mode_graphic5			),
		.vdp_mode_graphic6				( w_vdp_mode_graphic6			),
		.vdp_mode_graphic7				( w_vdp_mode_graphic7			),

		.window							( w_window						),
		.sp_color_code_en				( w_sp_color_code_en			),
		.colorcodet12					( w_color_code_text12			),
		.colorcodeg123m					( w_color_code_graphic123m		),
		.colorcodeg4567					( w_color_code_graphic4567		),
		.colorcodesprite				( w_sp_color_code				),
		.p_yjk_r						( w_yjk_r						),
		.p_yjk_g						( w_yjk_g						),
		.p_yjk_b						( w_yjk_b						),
		.p_yjk_en						( w_yjk_en						),

		.pvideor_vdp					( w_video_r_vdp					),
		.pvideog_vdp					( w_video_g_vdp					),
		.pvideob_vdp					( w_video_b_vdp					),

		.reg_r1_disp_on					( reg_r1_disp_on				),
		.reg_r7_frame_col				( reg_r7_frame_col				),
		.reg_r8_col0_on					( reg_r8_col0_on				),
		.reg_r25_yjk					( reg_r25_yjk					)
	);

	//---------------------------------------------------------------------------
	// Screen mode controller
	//---------------------------------------------------------------------------
	vdp_text12 u_vdp_text12(
		.clk							( clk							),
		.reset							( reset							),
		.enable							( enable						),
		.dot_state						( w_dot_state					),
		.dotcounterx					( w_pre_dot_counter_x			),
		.dotcountery					( w_pre_dot_counter_y			),
		.dotcounteryp					( w_pre_dot_counter_yp			),
		.vdp_mode_text1					( w_vdp_mode_text1				),
		.vdp_mode_text1q				( w_vdp_mode_text1q				),
		.vdp_mode_text2					( w_vdp_mode_text2				),
		.reg_r1_bl_clks					( reg_r1_bl_clks				),
		.reg_r7_frame_col				( reg_r7_frame_col				),
		.reg_r12_blink_mode				( reg_r12_blink_mode			),
		.reg_r13_blink_period			( reg_r13_blink_period			),
		.reg_r2_pattern_name			( reg_r2_pattern_name			),
		.reg_r4_pattern_generator		( reg_r4_pattern_generator		),
		.reg_r10r3_color				( reg_r10r3_color				),
		.pramdat						( w_vram_data					),
		.pramadr						( w_vram_address_text12			),
		.txvramreaden					( w_tx_vram_read_en				),
		.pcolorcode						( w_color_code_text12			)
	);

	vdp_graphic123m u_vdp_graphic123m(
		.clk							( clk							),
		.reset							( reset							),
		.enable							( enable						),
		.dot_state						( w_dot_state					),
		.eight_dot_state				( w_eight_dot_state				),
		.dot_counter_x					( w_pre_dot_counter_x			),
		.dot_counter_y					( w_pre_dot_counter_y			),
		.vdp_mode_multi					( w_vdp_mode_multi				),
		.vdp_mode_multiq				( w_vdp_mode_multiq				),
		.vdp_mode_graphic1				( w_vdp_mode_graphic1			),
		.vdp_mode_graphic2				( w_vdp_mode_graphic2			),
		.vdp_mode_graphic3				( w_vdp_mode_graphic3			),
		.reg_r2_pattern_name			( reg_r2_pattern_name			),
		.reg_r4_pattern_generator		( reg_r4_pattern_generator		),
		.reg_r10r3_color				( reg_r10r3_color				),
		.reg_r26_h_scroll				( reg_r26_h_scroll				),
		.reg_r27_h_scroll				( reg_r27_h_scroll				),
		.p_ram_dat						( w_vram_data					),
		.p_ram_adr						( w_vram_address_graphic123m	),
		.p_color_code					( w_color_code_graphic123m		)
	);

	vdp_graphic4567 u_vdp_graphic4567(
		.clk							( clk							),
		.reset							( reset							),
		.enable							( enable						),
		.dot_state						( w_dot_state					),
		.eight_dot_state				( w_eight_dot_state				),
		.dotcounterx					( w_pre_dot_counter_x			),
		.dotcountery					( w_pre_dot_counter_y			),
		.vdp_mode_graphic4				( w_vdp_mode_graphic4			),
		.vdp_mode_graphic5				( w_vdp_mode_graphic5			),
		.vdp_mode_graphic6				( w_vdp_mode_graphic6			),
		.vdp_mode_graphic7				( w_vdp_mode_graphic7			),
		.reg_r1_bl_clks					( reg_r1_bl_clks				),
		.reg_r2_pattern_name			( reg_r2_pattern_name			),
		.reg_r13_blink_period			( reg_r13_blink_period			),
		.reg_r26_h_scroll				( reg_r26_h_scroll				),
		.reg_r27_h_scroll				( reg_r27_h_scroll				),
		.reg_r25_yae					( reg_r25_yae					),
		.reg_r25_yjk					( reg_r25_yjk					),
		.reg_r25_sp2					( reg_r25_sp2					),
		.pramdat						( w_vram_data					),
		.pramdatpair					( w_vram_data_pair				),
		.pramadr						( w_vram_address_graphic4567	),
		.pcolorcode						( w_color_code_graphic4567		),
		.p_yjk_r						( w_yjk_r						),
		.p_yjk_g						( w_yjk_g						),
		.p_yjk_b						( w_yjk_b						),
		.p_yjk_en						( w_yjk_en						)
	);

	//---------------------------------------------------------------------------
	// sprite module
	//---------------------------------------------------------------------------
	vdp_sprite u_sprite(
		.clk							( clk							),
		.reset							( reset							),
		.enable							( enable						),
		.dot_state						( w_dot_state					),
		.eight_dot_state				( w_eight_dot_state				),
		.dotcounterx					( w_pre_dot_counter_x			),
		.dotcounteryp					( w_pre_dot_counter_yp			),
		.bwindow_y						( ff_bwindow_y					),
		.pvdps0spcollisionincidence		( w_s0_sp_collision_incidence	),
		.pvdps0spovermapped				( w_s0_sp_overmapped			),
		.pvdps0spovermappednum			( w_s0_sp_overmapped_num		),
		.pvdps3s4spcollisionx			( w_s3s4_sp_collision_x			),
		.pvdps5s6spcollisiony			( w_s5s6_sp_collision_y			),
		.pvdps0resetreq					( w_s0_reset_req				),
		.pvdps0resetack					( w_s0_reset_ack				),
		.pvdps5resetreq					( w_s5_reset_req				),
		.pvdps5resetack					( w_s5_reset_ack				),
		.reg_r1_sp_size					( reg_r1_sp_size				),
		.reg_r1_sp_zoom					( reg_r1_sp_zoom				),
		.reg_r11r5_sp_atr_addr			( reg_r11r5_sp_atr_addr			),
		.reg_r6_sp_gen_addr				( reg_r6_sp_gen_addr			),
		.reg_r8_col0_on					( reg_r8_col0_on				),
		.reg_r8_sp_off					( reg_r8_sp_off					),
		.reg_r23_vstart_line			( reg_r23_vstart_line			),
		.reg_r27_h_scroll				( reg_r27_h_scroll				),
		.spmode2						( w_sp_mode2					),
		.vraminterleavemode				( w_vdp_mode_is_vram_interleave	),
		.spvramaccessing				( w_sp_vram_accessing			),
		.pramdat						( w_vram_data					),
		.pramadr						( w_sprite_vram_address			),
		.sp_color_code_en				( w_sp_color_code_en			),
		.sp_color_code					( w_sp_color_code				),
		.reg_r9_y_dots					( reg_r9_y_dots					)
	);

	//---------------------------------------------------------------------------
	// vdp register access
	//---------------------------------------------------------------------------
	assign ack	= w_ack;

	vdp_register u_vdp_register(
		.reset							( reset							),
		.clk							( clk							),
		.enable							( enable						),

		.req							( ff_req						),
		.ack							( w_ack							),
		.wrt							( ff_wrt						),
		.adr							( adr							),
		.dbi							( dbi							),
		.dbo							( dbo							),

		.dot_state						( w_dot_state					),

		.vdp_cmd_tr_clr_ack				( w_vdpcmd_tr_clr_ack			),
		.vdp_cmd_reg_wr_ack				( w_vdpcmd_reg_write_ack		),
		.hsync							( w_hsync						),

		.vdp_s0_sp_collision_incidence	( w_s0_sp_collision_incidence	),
		.vdp_s0_sp_overmapped			( w_s0_sp_overmapped			),
		.vdp_s0_sp_overmapped_num		( w_s0_sp_overmapped_num		),
		.sp_vdp_s0_reset_req			( w_s0_reset_req				),
		.sp_vdp_s0_reset_ack			( w_s0_reset_ack				),
		.sp_vdp_s5_reset_req			( w_s5_reset_req				),
		.sp_vdp_s5_reset_ack			( w_s5_reset_ack				),

		.vdp_cmd_tr						( w_vdpcmd_tr					),
		.vd								( w_vd							),
		.hd								( w_hd							),
		.vdp_cmd_bd						( w_vdpcmd_bd					),
		.field							( w_field						),
		.vdp_cmd_ce						( w_vdpcmd_ce					),
		.vdp_s3_s4_sp_collision_x		( w_s3s4_sp_collision_x			),
		.vdp_s5_s6_sp_collision_y		( w_s5s6_sp_collision_y			),
		.vdp_cmd_clr					( w_vdpcmd_clr					),
		.vdp_cmd_sx_tmp					( w_vdpcmd_sx_tmp				),

		.vdp_vram_access_data			( w_vram_access_data			),
		.vdp_vram_access_addr_tmp		( w_vram_access_address_tmp		),
		.vdp_vram_addr_set_req			( w_vram_addr_set_req			),
		.vdp_vram_addr_set_ack			( ff_vram_addr_set_ack			),
		.vdp_vram_wr_req				( w_vram_write_req				),
		.vdp_vram_wr_ack				( ff_vram_write_ack				),
		.vdp_vram_rd_data				( ff_vram_read_data				),
		.vdp_vram_rd_req				( w_vram_rd_req					),
		.vdp_vram_rd_ack				( ff_vram_rd_ack				),

		.vdp_cmd_reg_num				( w_vdpcmd_reg_num				),
		.vdp_cmd_reg_data				( w_vdpcmd_reg_data				),
		.vdp_cmd_reg_wr_req				( w_vdpcmd_reg_wr_req			),
		.vdp_cmd_tr_clr_req				( w_vdpcmd_tr_clr_req			),

		.palette_addr_out				( w_palette_address				),
		.palette_data_rb_out			( w_palette_data_rb				),
		.palette_data_g_out				( w_palette_data_g				),

		.clr_vsync_int					( w_clr_vsync_int				),
		.clr_hsync_int					( w_clr_hsync_int				),
		.req_vsync_int_n				( req_vsync_int_n				),
		.req_hsync_int_n				( req_hsync_int_n				),

		.reg_r0_hsync_int_en			( reg_r0_hsync_int_en			),
		.reg_r1_sp_size					( reg_r1_sp_size				),
		.reg_r1_sp_zoom					( reg_r1_sp_zoom				),
		.reg_r1_bl_clks					( reg_r1_bl_clks				),
		.reg_r1_vsync_int_en			( reg_r1_vsync_int_en			),
		.reg_r1_disp_on					( reg_r1_disp_on				),
		.reg_r2_pattern_name			( reg_r2_pattern_name			),
		.reg_r4_pattern_generator		( reg_r4_pattern_generator		),
		.reg_r10r3_color				( reg_r10r3_color				),
		.reg_r11r5_sp_atr_addr			( reg_r11r5_sp_atr_addr			),
		.reg_r6_sp_gen_addr				( reg_r6_sp_gen_addr			),
		.reg_r7_frame_col				( reg_r7_frame_col				),
		.reg_r8_sp_off					( reg_r8_sp_off					),
		.reg_r8_col0_on					( reg_r8_col0_on				),
		.reg_r9_pal_mode				( reg_r9_pal_mode				),
		.reg_r9_interlace_mode			( reg_r9_interlace_mode			),
		.reg_r9_y_dots					( reg_r9_y_dots					),
		.reg_r12_blink_mode				( reg_r12_blink_mode			),
		.reg_r13_blink_period			( reg_r13_blink_period			),
		.reg_r18_adj					( reg_r18_adj					),
		.reg_r19_hsync_int_line			( reg_r19_hsync_int_line		),
		.reg_r23_vstart_line			( reg_r23_vstart_line			),
		.reg_r25_cmd					( reg_r25_cmd					),
		.reg_r25_yae					( reg_r25_yae					),
		.reg_r25_yjk					( reg_r25_yjk					),
		.reg_r25_msk					( reg_r25_msk					),
		.reg_r25_sp2					( reg_r25_sp2					),
		.reg_r26_h_scroll				( reg_r26_h_scroll				),
		.reg_r27_h_scroll				( reg_r27_h_scroll				),

		.vdp_mode_text1					( w_vdp_mode_text1				),
		.vdp_mode_text1q				( w_vdp_mode_text1q				),
		.vdp_mode_text2					( w_vdp_mode_text2				),
		.vdp_mode_multi					( w_vdp_mode_multi				),
		.vdp_mode_multiq				( w_vdp_mode_multiq				),
		.vdp_mode_graphic1				( w_vdp_mode_graphic1			),
		.vdp_mode_graphic2				( w_vdp_mode_graphic2			),
		.vdp_mode_graphic3				( w_vdp_mode_graphic3			),
		.vdp_mode_graphic4				( w_vdp_mode_graphic4			),
		.vdp_mode_graphic5				( w_vdp_mode_graphic5			),
		.vdp_mode_graphic6				( w_vdp_mode_graphic6			),
		.vdp_mode_graphic7				( w_vdp_mode_graphic7			),
		.vdp_mode_is_high_res			( w_vdp_mode_is_highres			),
		.sp_mode_2						( w_sp_mode2					),
		.vdp_mode_is_vram_interleave	( w_vdp_mode_is_vram_interleave	),

		.forced_v_mode					( forced_v_mode					),
		.vdp_id							( vdp_id						)
	);

	//---------------------------------------------------------------------------
	// vdp command
	//---------------------------------------------------------------------------
	vdp_command u_vdp_command (
		.reset							( reset							),
		.clk							( clk							),
		.enable							( enable						),
		.vdp_mode_graphic4				( w_vdp_mode_graphic4			),
		.vdp_mode_graphic5				( w_vdp_mode_graphic5			),
		.vdp_mode_graphic6				( w_vdp_mode_graphic6			),
		.vdp_mode_graphic7				( w_vdp_mode_graphic7			),
		.vdp_mode_is_highres			( w_vdp_mode_is_highres			),
		.vramwrack						( ff_vdpcmd_vram_write_ack		),
		.vramrdack						( ff_vdpcmd_vram_read_ack		),
		.vramrddata						( ff_vdpcmd_vram_rdata			),
		.regwrreq						( w_vdpcmd_reg_wr_req			),
		.trclrreq						( w_vdpcmd_tr_clr_req			),
		.regnum							( w_vdpcmd_reg_num				),
		.regdata						( w_vdpcmd_reg_data				),
		.pregwrack						( w_vdpcmd_reg_write_ack		),
		.ptrclrack						( w_vdpcmd_tr_clr_ack			),
		.pvramwrreq						( w_vdpcmd_vram_write_req		),
		.pvramrdreq						( w_vdpcmd_vram_read_req		),
		.pvramaccessaddr				( w_vdpcmd_vram_access_address	) ,
		.pvramwrdata					( w_vdpcmd_vram_wdata			),
		.pclr							( w_vdpcmd_clr					),
		.pce							( w_vdpcmd_ce					),
		.pbd							( w_vdpcmd_bd					),
		.ptr							( w_vdpcmd_tr					),
		.psxtmp							( w_vdpcmd_sx_tmp				),
		.cur_vdp_command				( w_current_vdp_command			),
		.reg_r25_cmd					( reg_r25_cmd					)
	);

	//---------------------------------------------------------------------------
	// VDP wait controller
	//---------------------------------------------------------------------------
	vdp_wait_control u_vdp_wait_control(
		.reset							( reset							),
		.clk							( clk							),
		.enable							( enable						),

		.vdp_command					( w_current_vdp_command			),

		.vdpr9palmode					( w_r9_pal_mode					),
		.reg_r1_disp_on					( reg_r1_disp_on				),
		.reg_r8_sp_off					( reg_r8_sp_off					),
		.reg_r9_y_dots					( reg_r9_y_dots					),

		.vdp_speed_mode					( vdp_speed_mode				),
		.drive							( ff_vdp_command_drive			),

		.active							( w_vdp_command_active			)
	);

	// --------------------------------------------------------------------
	//	LCD Controller
	// --------------------------------------------------------------------
	vdp_lcd u_vdp_lcd(
		.clk							( clk							),
		.reset							( reset							),
		.enable							( enable						),
		.lcd_clk						( pvideo_clk					),
		.lcd_de							( pvideo_data_en				),
		.videorin						( w_video_r						),
		.videogin						( w_video_g						),
		.videobin						( w_video_b						),
		.videovsin_n					( w_video_vsync_n				),
		.hcounterin						( w_h_count						),
		.vcounterin						( w_v_count						),
		.pal_mode						( w_r9_pal_mode					),
		.interlace_mode					( reg_r9_interlace_mode			),
		.legacy_vga						( legacy_vga					),
		.videorout						( w_video_r_lcd					),
		.videogout						( w_video_g_lcd					),
		.videobout						( w_video_b_lcd					),
		.videohsout_n					( w_video_hs_n_lcd				),
		.videovsout_n					( w_video_vs_n_lcd				),
		.ratio_mode						( ratio_mode					)
	);

endmodule
