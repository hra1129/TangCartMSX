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
	input					clk,				//	85.90908MHz
	input					enable,
	input					iorq_n,
	input					wr_n,
	input					rd_n,
	input		[1:0]		address,
	output		[7:0]		rdata,
	output					rdata_en,
	input		[7:0]		wdata,

	output					int_n,

	output					p_dram_oe_n,
	output					p_dram_we_n,
	output		[16:0]		p_dram_address,
	input		[15:0]		p_dram_rdata,
	output		[7:0]		p_dram_wdata,

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
	input					legacy_vga,

	input		[4:0]		vdp_id
);
	localparam		clocks_per_line		= 1368;
	localparam		offset_x			= 7'd49;
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
	wire	[3:1]	w_vdpr0dispnum;
	wire	[7:0]	w_vram_wdata_cpu;
	wire	[7:0]	w_vram_rdata_cpu;
	wire	[16:0]	w_vram_address_cpu;

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
	wire			w_vram_interleave_mode;		// true when mode graphic6, 7

	// for palette
	reg		[4:0]	ff_palette_initial_state;
	reg		[4:0]	ff_palette_r;
	reg		[4:0]	ff_palette_g;
	reg		[4:0]	ff_palette_b;
	reg		[7:0]	ff_palette_address;
	reg				ff_palette_we;
	wire	[7:0]	w_palette_wr_address;
	wire	[7:0]	w_palette_rd_address;
	wire	[7:0]	w_palette_address;
	wire			w_palette_we;
	wire	[4:0]	w_palette_wdata_r;
	wire	[4:0]	w_palette_wdata_g;
	wire	[4:0]	w_palette_wdata_b;
	wire	[4:0]	w_palette_rdata_r;
	wire	[4:0]	w_palette_rdata_g;
	wire	[4:0]	w_palette_rdata_b;
	wire	[2:0]	w_initial_palette_r;
	wire	[2:0]	w_initial_palette_g;
	wire	[2:0]	w_initial_palette_b;

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
	wire	[16:0]	w_vram_address_sprite;
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
	wire	[4:0]	w_palette_data_r;
	wire	[4:0]	w_palette_data_g;
	wire	[4:0]	w_palette_data_b;

	// vdp command signals - can be read & set by cpu
	wire	[7:0]	w_vdpcmd_clr;					// r44, s#7
	// vdp command signals - can be read by cpu
	wire			w_vdpcmd_ce;					// s#2 (bit 0)
	wire			w_vdpcmd_bd;					// s#2 (bit 4)
	wire			w_vdpcmd_tr;					// s#2 (bit 7)
	wire	[10:0]	w_vdpcmd_sx_tmp;				// s#8, s#9

	wire	[3:0]	w_vdpcmd_reg_num;
	wire	[7:0]	w_vdpcmd_reg_data;
	wire			w_vdpcmd_reg_write_ack;
	wire			w_vdpcmd_reg_write_req;
	wire			w_vdpcmd_tr_clr_ack;
	wire			w_vdpcmd_tr_clr_req;
	wire	[7:0]	w_vdpcmd_vram_wdata;

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

	wire			w_hsync;
	wire			w_hsync_en;

	wire			w_vdp_command_active;
	wire			w_vram_addr_set_req;
	wire			w_vram_addr_set_ack;
	wire			w_vram_write_req;
	wire			w_vram_write_ack;
	wire			w_vram_rd_req;
	wire			w_vram_rd_ack;
	wire			w_vdpcmd_vram_read_req;
	wire			w_vdpcmd_vram_write_req;
	wire			w_vdpcmd_vram_write_ack;
	wire			w_vdpcmd_vram_read_ack;
	wire	[16:0]	w_vdpcmd_vram_address;
	wire	[7:0]	w_vdpcmd_vram_rdata;
	wire	[7:0]	w_vram_data;
	wire	[7:0]	w_vram_data_pair;
	wire			w_vdp_command_drive;

	wire			w_wr_n;
	wire			w_rd_n;

	//--------------------------------------------------------------
	// request signal
	//--------------------------------------------------------------
	assign w_wr_n			= wr_n | iorq_n;
	assign w_rd_n			= rd_n | iorq_n;

	//--------------------------------------------------------------
	// display components
	//--------------------------------------------------------------
	assign w_disp_mode_vga	= dispreso;			// display resolution (0=15khz, 1=31khz)

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

	// --------------------------------------------------------------------
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
					((w_v_count == 524+20*2) && !reg_r9_pal_mode) ||
					((w_v_count == 626+20*2) &&  reg_r9_pal_mode) ) begin
				ff_bwindow_y <= 1'b1;
			end
			else if(((w_v_count == 524) && !reg_r9_pal_mode) ||
					((w_v_count == 626) &&  reg_r9_pal_mode) ||
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
					((w_v_count == 525+20*2 + 1) && !reg_r9_pal_mode) ||
					((w_v_count == 625+20*2 + 1) &&  reg_r9_pal_mode) ) begin
				ff_bwindow_y <= 1'b1;
			end
			else if( ((w_v_count == 525) && !reg_r9_pal_mode) ||
					 ((w_v_count == 625) &&  reg_r9_pal_mode) ||
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
		else if((w_h_count == {2'b00, (offset_x + led_tv_x_ntsc - {(reg_r25_msk & ~centeryjk_r25_n), 2'b00} + 4), 2'b10} && ( reg_r25_yjk &&  centeryjk_r25_n) && !reg_r9_pal_mode) ||
				(w_h_count == {2'b00, (offset_x + led_tv_x_ntsc - {(reg_r25_msk & ~centeryjk_r25_n), 2'b00}    ), 2'b10} && (!reg_r25_yjk || !centeryjk_r25_n) && !reg_r9_pal_mode) ||
				(w_h_count == {2'b00, (offset_x + led_tv_x_pal  - {(reg_r25_msk & ~centeryjk_r25_n), 2'b00} + 4), 2'b10} && ( reg_r25_yjk &&  centeryjk_r25_n) &&  reg_r9_pal_mode) ||
				(w_h_count == {2'b00, (offset_x + led_tv_x_pal  - {(reg_r25_msk & ~centeryjk_r25_n), 2'b00}    ), 2'b10} && (!reg_r25_yjk || !centeryjk_r25_n) &&  reg_r9_pal_mode) ) begin
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

	//---------------------------------------------------------------------------
	// palette initializer
	//---------------------------------------------------------------------------
	always @( posedge clk ) begin
		if( reset ) begin
			ff_palette_initial_state <= 5'd0;
		end
		else if( !ff_palette_initial_state[4] ) begin
			ff_palette_initial_state <= ff_palette_initial_state + 5'd1;
		end
		else begin
			//	hold
		end
	end

	assign w_initial_palette_r	=
		( ff_palette_initial_state[3:0] == 4'd0  ) ? 3'd0 :
		( ff_palette_initial_state[3:0] == 4'd1  ) ? 3'd0 :
		( ff_palette_initial_state[3:0] == 4'd2  ) ? 3'd1 :
		( ff_palette_initial_state[3:0] == 4'd3  ) ? 3'd3 :
		( ff_palette_initial_state[3:0] == 4'd4  ) ? 3'd1 :
		( ff_palette_initial_state[3:0] == 4'd5  ) ? 3'd2 :
		( ff_palette_initial_state[3:0] == 4'd6  ) ? 3'd5 :
		( ff_palette_initial_state[3:0] == 4'd7  ) ? 3'd2 :
		( ff_palette_initial_state[3:0] == 4'd8  ) ? 3'd7 :
		( ff_palette_initial_state[3:0] == 4'd9  ) ? 3'd7 :
		( ff_palette_initial_state[3:0] == 4'd10 ) ? 3'd6 :
		( ff_palette_initial_state[3:0] == 4'd11 ) ? 3'd6 :
		( ff_palette_initial_state[3:0] == 4'd12 ) ? 3'd1 :
		( ff_palette_initial_state[3:0] == 4'd13 ) ? 3'd6 :
		( ff_palette_initial_state[3:0] == 4'd14 ) ? 3'd5 : 3'd7;

	assign w_initial_palette_g	=
		( ff_palette_initial_state[3:0] == 4'd0  ) ? 3'd0 :
		( ff_palette_initial_state[3:0] == 4'd1  ) ? 3'd0 :
		( ff_palette_initial_state[3:0] == 4'd2  ) ? 3'd6 :
		( ff_palette_initial_state[3:0] == 4'd3  ) ? 3'd7 :
		( ff_palette_initial_state[3:0] == 4'd4  ) ? 3'd1 :
		( ff_palette_initial_state[3:0] == 4'd5  ) ? 3'd3 :
		( ff_palette_initial_state[3:0] == 4'd6  ) ? 3'd1 :
		( ff_palette_initial_state[3:0] == 4'd7  ) ? 3'd6 :
		( ff_palette_initial_state[3:0] == 4'd8  ) ? 3'd1 :
		( ff_palette_initial_state[3:0] == 4'd9  ) ? 3'd3 :
		( ff_palette_initial_state[3:0] == 4'd10 ) ? 3'd6 :
		( ff_palette_initial_state[3:0] == 4'd11 ) ? 3'd6 :
		( ff_palette_initial_state[3:0] == 4'd12 ) ? 3'd4 :
		( ff_palette_initial_state[3:0] == 4'd13 ) ? 3'd2 :
		( ff_palette_initial_state[3:0] == 4'd14 ) ? 3'd5 : 3'd7;

	assign w_initial_palette_b	=
		( ff_palette_initial_state[3:0] == 4'd0  ) ? 3'd0 :
		( ff_palette_initial_state[3:0] == 4'd1  ) ? 3'd0 :
		( ff_palette_initial_state[3:0] == 4'd2  ) ? 3'd1 :
		( ff_palette_initial_state[3:0] == 4'd3  ) ? 3'd3 :
		( ff_palette_initial_state[3:0] == 4'd4  ) ? 3'd7 :
		( ff_palette_initial_state[3:0] == 4'd5  ) ? 3'd7 :
		( ff_palette_initial_state[3:0] == 4'd6  ) ? 3'd1 :
		( ff_palette_initial_state[3:0] == 4'd7  ) ? 3'd7 :
		( ff_palette_initial_state[3:0] == 4'd8  ) ? 3'd1 :
		( ff_palette_initial_state[3:0] == 4'd9  ) ? 3'd3 :
		( ff_palette_initial_state[3:0] == 4'd10 ) ? 3'd1 :
		( ff_palette_initial_state[3:0] == 4'd11 ) ? 3'd4 :
		( ff_palette_initial_state[3:0] == 4'd12 ) ? 3'd1 :
		( ff_palette_initial_state[3:0] == 4'd13 ) ? 3'd5 :
		( ff_palette_initial_state[3:0] == 4'd14 ) ? 3'd5 : 3'd7;

	// --------------------------------------------------------------------
	// color bus
	// --------------------------------------------------------------------
	vdp_color_bus u_vdp_color_bus (
		.reset							( reset							),
		.clk							( clk							),
		.enable							( enable						),
		.dot_state						( w_dot_state					),
		.eight_dot_state				( w_eight_dot_state				),
		.p_dram_oe_n					( p_dram_oe_n					),
		.p_dram_we_n					( p_dram_we_n					),
		.p_dram_address					( p_dram_address				),
		.p_dram_wdata					( p_dram_wdata					),
		.p_dram_rdata					( p_dram_rdata					),
		.p_vdp_mode_text1				( w_vdp_mode_text1				),
		.p_vdp_mode_text1q				( w_vdp_mode_text1q				),
		.p_vdp_mode_text2				( w_vdp_mode_text2				),
		.p_vdp_mode_multi				( w_vdp_mode_multi				),
		.p_vdp_mode_multiq				( w_vdp_mode_multiq				),
		.p_vdp_mode_graphic1			( w_vdp_mode_graphic1			),
		.p_vdp_mode_graphic2			( w_vdp_mode_graphic2			),
		.p_vdp_mode_graphic3			( w_vdp_mode_graphic3			),
		.p_vdp_mode_graphic4			( w_vdp_mode_graphic4			),
		.p_vdp_mode_graphic5			( w_vdp_mode_graphic5			),
		.p_vdp_mode_graphic6			( w_vdp_mode_graphic6			),
		.p_vdp_mode_graphic7			( w_vdp_mode_graphic7			),
		.p_vram_address_cpu				( w_vram_address_cpu			),
		.p_vram_address_sprite			( w_vram_address_sprite			),
		.p_vram_address_text12			( w_vram_address_text12			),
		.p_vram_address_graphic123m		( w_vram_address_graphic123m	),
		.p_vram_address_graphic4567		( w_vram_address_graphic4567	),
		.p_vram_wdata_cpu				( w_vram_wdata_cpu				),
		.p_vram_rdata_cpu				( w_vram_rdata_cpu				),
		.p_vram_data					( w_vram_data					),
		.p_vram_data_pair				( w_vram_data_pair				),
		.p_prewindow					( w_prewindow					),
		.p_prewindow_x					( ff_prewindow_x				),
		.p_vdp_command_active			( w_vdp_command_active			),
		.p_vdp_command_drive			( w_vdp_command_drive			),
		.p_vram_addr_set_req			( w_vram_addr_set_req			),
		.p_vram_addr_set_ack			( w_vram_addr_set_ack			),
		.p_vram_write_req				( w_vram_write_req				),
		.p_vram_write_ack				( w_vram_write_ack				),
		.p_vram_rd_req					( w_vram_rd_req					),
		.p_vram_rd_ack					( w_vram_rd_ack					),
		.p_vdpcmd_vram_write_ack		( w_vdpcmd_vram_write_ack		),
		.p_vdpcmd_vram_read_ack			( w_vdpcmd_vram_read_ack		),
		.p_vdpcmd_vram_read_req			( w_vdpcmd_vram_read_req		),
		.p_vdpcmd_vram_write_req		( w_vdpcmd_vram_write_req		),
		.p_vdpcmd_vram_address			( w_vdpcmd_vram_address			),
		.p_vdpcmd_vram_wdata			( w_vdpcmd_vram_wdata			),
		.p_vdpcmd_vram_rdata			( w_vdpcmd_vram_rdata			),
		.p_tx_vram_read_en				( w_tx_vram_read_en				),
		.p_prewindow_y_sp				( w_prewindow_y_sp				),
		.p_sp_vram_accessing			( w_sp_vram_accessing			),
		.reg_r1_disp_on					( reg_r1_disp_on				)
	);

	// --------------------------------------------------------------------
	//	Interrupt
	// --------------------------------------------------------------------
	vdp_interrupt u_vdp_interrupt(
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
	vdp_ssg u_vdp_ssg(
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

		.vdp_r9_pal_mode				( reg_r9_pal_mode				),
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
	vdp_color_decoder u_vdp_color_decoder(
		.reset							( reset							),
		.clk							( clk							),
		.enable							( enable						),

		.dot_state						( w_dot_state					),

		.palette_address				( w_palette_rd_address			),
		.palette_rdata_r				( w_palette_rdata_r				),
		.palette_rdata_g				( w_palette_rdata_g				),
		.palette_rdata_b				( w_palette_rdata_b				),

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
		.dot_counter_x					( w_pre_dot_counter_x			),
		.dotcountery					( w_pre_dot_counter_y			),
		.dot_counter_yp					( w_pre_dot_counter_yp			),
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
		.p_vram_rdata					( w_vram_data					),
		.p_vram_address					( w_vram_address_text12			),
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
		.dot_counter_x					( w_pre_dot_counter_x			),
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
		.p_vram_rdata					( w_vram_data					),
		.pramdatpair					( w_vram_data_pair				),
		.p_vram_address					( w_vram_address_graphic4567	),
		.pcolorcode						( w_color_code_graphic4567		),
		.p_yjk_r						( w_yjk_r						),
		.p_yjk_g						( w_yjk_g						),
		.p_yjk_b						( w_yjk_b						),
		.p_yjk_en						( w_yjk_en						)
	);

	//---------------------------------------------------------------------------
	// sprite module
	//---------------------------------------------------------------------------
	vdp_sprite u_vdp_sprite(
		.clk							( clk							),
		.reset							( reset							),
		.enable							( enable						),
		.dot_state						( w_dot_state					),
		.eight_dot_state				( w_eight_dot_state				),
		.dot_counter_x					( w_pre_dot_counter_x			),
		.dot_counter_yp					( w_pre_dot_counter_yp			),
		.bwindow_y						( ff_bwindow_y					),
		.p_s0_sp_collision_incidence	( w_s0_sp_collision_incidence	),
		.p_s0_sp_overmapped				( w_s0_sp_overmapped			),
		.p_s0_sp_overmapped_num			( w_s0_sp_overmapped_num		),
		.p_s3s4_sp_collision_x			( w_s3s4_sp_collision_x			),
		.p_s5s6_sp_collision_y			( w_s5s6_sp_collision_y			),
		.p_s0_reset_req					( w_s0_reset_req				),
		.p_s0_reset_ack					( w_s0_reset_ack				),
		.p_s5_reset_req					( w_s5_reset_req				),
		.p_s5_reset_ack					( w_s5_reset_ack				),
		.reg_r1_sp_size					( reg_r1_sp_size				),
		.reg_r1_sp_zoom					( reg_r1_sp_zoom				),
		.reg_r11r5_sp_atr_addr			( reg_r11r5_sp_atr_addr			),
		.reg_r6_sp_gen_addr				( reg_r6_sp_gen_addr			),
		.reg_r8_col0_on					( reg_r8_col0_on				),
		.reg_r8_sp_off					( reg_r8_sp_off					),
		.reg_r23_vstart_line			( reg_r23_vstart_line			),
		.reg_r27_h_scroll				( reg_r27_h_scroll				),
		.p_sp_mode2						( w_sp_mode2					),
		.vram_interleave_mode			( w_vram_interleave_mode		),
		.sp_vram_accessing				( w_sp_vram_accessing			),
		.p_vram_rdata					( w_vram_data					),
		.p_vram_address					( w_vram_address_sprite			),
		.sp_color_code_en				( w_sp_color_code_en			),
		.sp_color_code					( w_sp_color_code				),
		.reg_r9_y_dots					( reg_r9_y_dots					)
	);

	//---------------------------------------------------------------------------
	// color palette
	//---------------------------------------------------------------------------
	always @( posedge clk ) begin
		if( reset ) begin
			ff_palette_r		<= 5'd0;
			ff_palette_g		<= 5'd0;
			ff_palette_b		<= 5'd0;
			ff_palette_address	<= 8'd0;
			ff_palette_we		<= 1'b0;
		end
		else begin
			ff_palette_r		<= !ff_palette_initial_state[4] ? { w_initial_palette_r, w_initial_palette_r[2:1] }: w_palette_wdata_r;
			ff_palette_g		<= !ff_palette_initial_state[4] ? { w_initial_palette_g, w_initial_palette_g[2:1] }: w_palette_wdata_g;
			ff_palette_b		<= !ff_palette_initial_state[4] ? { w_initial_palette_b, w_initial_palette_b[2:1] }: w_palette_wdata_b;
			ff_palette_address	<= !ff_palette_initial_state[4] ? { 4'd0, ff_palette_initial_state[3:0] } : w_palette_wr_address;
			ff_palette_we		<= (enable & w_palette_we) | ~ff_palette_initial_state[4];
		end
	end

	assign w_palette_address	= ff_palette_we ? ff_palette_address : w_palette_rd_address;

	vdp_ram_palette u_vdp_palette_ram (
		.clk		( clk										),
		.enable		( 1'b1										),
		.address	( w_palette_address							),
		.we			( ff_palette_we								),
		.d_r		( ff_palette_r								),
		.d_g		( ff_palette_g								),
		.d_b		( ff_palette_b								),
		.q_r		( w_palette_rdata_r							),
		.q_g		( w_palette_rdata_g							),
		.q_b		( w_palette_rdata_b							)
	);

	//---------------------------------------------------------------------------
	// vdp register access
	//---------------------------------------------------------------------------
	vdp_register u_vdp_register(
		.reset							( reset							),
		.clk							( clk							),
		.enable							( enable						),

		.wr_req							( ~w_wr_n						),
		.rd_req							( ~w_rd_n						),
		.address						( address						),
		.rdata							( rdata							),
		.rdata_en						( rdata_en						),
		.wdata							( wdata							),

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

		.vdp_vram_wdata_cpu				( w_vram_wdata_cpu				),
		.vdp_vram_address_cpu			( w_vram_address_cpu			),
		.vdp_vram_addr_set_req			( w_vram_addr_set_req			),
		.vdp_vram_addr_set_ack			( w_vram_addr_set_ack			),
		.vdp_vram_wr_req				( w_vram_write_req				),
		.vdp_vram_wr_ack				( w_vram_write_ack				),
		.vdp_vram_rd_data				( w_vram_rdata_cpu				),
		.vdp_vram_rd_req				( w_vram_rd_req					),
		.vdp_vram_rd_ack				( w_vram_rd_ack					),

		.vdp_cmd_reg_num				( w_vdpcmd_reg_num				),
		.vdp_cmd_reg_data				( w_vdpcmd_reg_data				),
		.vdp_cmd_reg_wr_req				( w_vdpcmd_reg_write_req		),
		.vdp_cmd_tr_clr_req				( w_vdpcmd_tr_clr_req			),

		.palette_address				( w_palette_wr_address			),
		.palette_we						( w_palette_we					),
		.palette_wdata_r				( w_palette_wdata_r				),
		.palette_wdata_g				( w_palette_wdata_g				),
		.palette_wdata_b				( w_palette_wdata_b				),

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
		.vdp_mode_is_vram_interleave	( w_vram_interleave_mode		),

		.forced_v_mode					( 1'b0							),
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
		.vramwrack						( w_vdpcmd_vram_write_ack		),
		.vramrdack						( w_vdpcmd_vram_read_ack		),
		.vramrddata						( w_vdpcmd_vram_rdata			),
		.regwrreq						( w_vdpcmd_reg_write_req		),
		.trclrreq						( w_vdpcmd_tr_clr_req			),
		.regnum							( w_vdpcmd_reg_num				),
		.regdata						( w_vdpcmd_reg_data				),
		.pregwrack						( w_vdpcmd_reg_write_ack		),
		.ptrclrack						( w_vdpcmd_tr_clr_ack			),
		.pvramwrreq						( w_vdpcmd_vram_write_req		),
		.pvramrdreq						( w_vdpcmd_vram_read_req		),
		.pvramaccessaddr				( w_vdpcmd_vram_address			) ,
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

		.vdpr9palmode					( reg_r9_pal_mode				),
		.reg_r1_disp_on					( reg_r1_disp_on				),
		.reg_r8_sp_off					( reg_r8_sp_off					),
		.reg_r9_y_dots					( reg_r9_y_dots					),

		.vdp_speed_mode					( vdp_speed_mode				),
		.drive							( w_vdp_command_drive			),

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
		.pal_mode						( reg_r9_pal_mode				),
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
