//
//	vdp.v
//	 FPGA9918 top entity
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
	input					address,
	output		[7:0]		rdata,
	output					rdata_en,
	input		[7:0]		wdata,

	output					int_n,

	output					p_dram_oe_n,
	output					p_dram_we_n,
	output		[13:0]		p_dram_address,
	input		[7:0]		p_dram_rdata,
	output		[7:0]		p_dram_wdata,
	// video output
	output					pvideo_clk,
	output					pvideo_data_en,

	output		[5:0]		pvideor,
	output		[5:0]		pvideog,
	output		[5:0]		pvideob,

	output					pvideohs_n,
	output					pvideovs_n,

	output					p_video_dh_clk,
	output					p_video_dl_clk
);
	localparam		clocks_per_line		= 1368;
	localparam		offset_x			= 7'd49;
	localparam		led_tv_x_ntsc		= -3;
	localparam		led_tv_y_ntsc		= 1;

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
	wire	[3:1]	w_vdpr0dispnum;
	wire	[7:0]	w_vram_wdata_cpu;
	wire	[7:0]	w_vram_rdata_cpu;
	wire	[13:0]	w_vram_address_cpu;

	wire			reg_r0_hsync_int_en;
	wire			reg_r1_sp_size;
	wire			reg_r1_sp_zoom;
	wire			reg_r1_bl_clks;
	wire			reg_r1_vsync_int_en;
	wire			reg_r1_disp_on;
	wire	[3:0]	reg_r2_pattern_name;
	wire	[2:0]	reg_r4_pattern_generator;
	wire	[7:0]	reg_r3_color;
	wire	[6:0]	reg_r5_sp_atr_addr;
	wire	[2:0]	reg_r6_sp_gen_addr;
	wire	[7:0]	reg_r7_frame_col;

	wire			w_vdp_mode_text1;					// text mode 1		(screen0 width 40)
	wire			w_vdp_mode_text1q;					// text mode 1		(??)
	wire			w_vdp_mode_multi;					// multicolor mode	(screen3)
	wire			w_vdp_mode_multiq;					// multicolor mode	(??)
	wire			w_vdp_mode_graphic1;				// graphic mode 1	(screen1)
	wire			w_vdp_mode_graphic2;				// graphic mode 2	(screen2)

	// for text 1 and 2
	wire	[13:0]	w_vram_address_text12;
	wire	[3:0]	w_color_code_text12;
	wire			w_tx_vram_read_en;

	// for graphic 1,2,3 and multi color
	wire	[13:0]	w_vram_address_graphic123m;
	wire	[3:0]	w_color_code_graphic123m;

	// sprite
	wire			w_sp_vram_accessing;
	wire	[13:0]	w_vram_address_sprite;
	wire			w_sp_color_code_en;
	wire	[3:0]	w_sp_color_code;
	wire			w_s0_sp_collision_incidence;
	wire			w_s0_sp_overmapped;
	wire	[4:0]	w_s0_sp_overmapped_num;
	wire			w_s0_reset_req;
	wire			w_s0_reset_ack;

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

	wire			w_vram_addr_set_req;
	wire			w_vram_addr_set_ack;
	wire			w_vram_write_req;
	wire			w_vram_write_ack;
	wire			w_vram_rd_req;
	wire			w_vram_rd_ack;
	wire	[7:0]	w_vram_data;
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
	assign w_vsync_int_n	= ( reg_r1_vsync_int_en ) ? req_vsync_int_n : 1'b1;
	assign int_n			= w_vsync_int_n;

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
		else begin
			// non-interlace
			// 3+3+16 = 19
			if( (w_v_count == 20*2) || (w_v_count == 524+20*2) ) begin
				ff_bwindow_y <= 1'b1;
			end
			else if( (w_v_count == 524) || (w_v_count == 0) ) begin
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
		else if( w_h_count == {2'b00, (offset_x + led_tv_x_ntsc    ), 2'b10} ) begin
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
		.p_vdp_mode_multi				( w_vdp_mode_multi				),
		.p_vdp_mode_multiq				( w_vdp_mode_multiq				),
		.p_vdp_mode_graphic1			( w_vdp_mode_graphic1			),
		.p_vdp_mode_graphic2			( w_vdp_mode_graphic2			),
		.p_vram_address_cpu				( w_vram_address_cpu			),
		.p_vram_address_sprite			( w_vram_address_sprite			),
		.p_vram_address_text12			( w_vram_address_text12			),
		.p_vram_address_graphic123m		( w_vram_address_graphic123m	),
		.p_vram_wdata_cpu				( w_vram_wdata_cpu				),
		.p_vram_rdata_cpu				( w_vram_rdata_cpu				),
		.p_vram_data					( w_vram_data					),
		.p_prewindow					( w_prewindow					),
		.p_prewindow_x					( ff_prewindow_x				),
		.p_vram_addr_set_req			( w_vram_addr_set_req			),
		.p_vram_addr_set_ack			( w_vram_addr_set_ack			),
		.p_vram_write_req				( w_vram_write_req				),
		.p_vram_write_ack				( w_vram_write_ack				),
		.p_vram_rd_req					( w_vram_rd_req					),
		.p_vram_rd_ack					( w_vram_rd_ack					),
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
		.req_vsync_int_n				( req_vsync_int_n				)
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
		.v_blanking_start				( w_v_blanking_start			)
	);

	//---------------------------------------------------------------------
	// color decoding
	//-----------------------------------------------------------------------
	vdp_color_decoder u_vdp_color_decoder(
		.reset							( reset							),
		.clk							( clk							),
		.enable							( enable						),

		.dot_state						( w_dot_state					),

		.vdp_mode_text1					( w_vdp_mode_text1				),
		.vdp_mode_text1q				( w_vdp_mode_text1q				),
		.vdp_mode_multi					( w_vdp_mode_multi				),
		.vdp_mode_multiq				( w_vdp_mode_multiq				),
		.vdp_mode_graphic1				( w_vdp_mode_graphic1			),
		.vdp_mode_graphic2				( w_vdp_mode_graphic2			),

		.window							( w_window						),
		.sp_color_code_en				( w_sp_color_code_en			),
		.colorcodet12					( w_color_code_text12			),
		.colorcodeg123m					( w_color_code_graphic123m		),
		.colorcodesprite				( w_sp_color_code				),

		.pvideor_vdp					( w_video_r_vdp					),
		.pvideog_vdp					( w_video_g_vdp					),
		.pvideob_vdp					( w_video_b_vdp					),

		.reg_r1_disp_on					( reg_r1_disp_on				),
		.reg_r7_frame_col				( reg_r7_frame_col				)
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
		.reg_r1_bl_clks					( reg_r1_bl_clks				),
		.reg_r7_frame_col				( reg_r7_frame_col				),
		.reg_r2_pattern_name			( reg_r2_pattern_name			),
		.reg_r4_pattern_generator		( reg_r4_pattern_generator		),
		.reg_r3_color					( reg_r3_color					),
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
		.reg_r2_pattern_name			( reg_r2_pattern_name			),
		.reg_r4_pattern_generator		( reg_r4_pattern_generator		),
		.reg_r3_color					( reg_r3_color					),
		.p_ram_dat						( w_vram_data					),
		.p_ram_adr						( w_vram_address_graphic123m	),
		.p_color_code					( w_color_code_graphic123m		)
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
		.p_s0_reset_req					( w_s0_reset_req				),
		.p_s0_reset_ack					( w_s0_reset_ack				),
		.reg_r1_sp_size					( reg_r1_sp_size				),
		.reg_r1_sp_zoom					( reg_r1_sp_zoom				),
		.reg_r5_sp_atr_addr				( reg_r5_sp_atr_addr			),
		.reg_r6_sp_gen_addr				( reg_r6_sp_gen_addr			),
		.sp_vram_accessing				( w_sp_vram_accessing			),
		.p_vram_rdata					( w_vram_data					),
		.p_vram_address					( w_vram_address_sprite			),
		.sp_color_code_en				( w_sp_color_code_en			),
		.sp_color_code					( w_sp_color_code				)
	);

	//---------------------------------------------------------------------------
	// vdp register access
	//---------------------------------------------------------------------------
	vdp_register u_vdp_register(
		.reset							( reset							),
		.clk							( clk							),
		.enable							( enable						),

		.wr_n							( w_wr_n						),
		.rd_n							( w_rd_n						),
		.address						( address						),
		.rdata							( rdata							),
		.rdata_en						( rdata_en						),
		.wdata							( wdata							),

		.dot_state						( w_dot_state					),

		.hsync							( w_hsync						),

		.vdp_s0_sp_collision_incidence	( w_s0_sp_collision_incidence	),
		.vdp_s0_sp_overmapped			( w_s0_sp_overmapped			),
		.vdp_s0_sp_overmapped_num		( w_s0_sp_overmapped_num		),
		.sp_vdp_s0_reset_req			( w_s0_reset_req				),
		.sp_vdp_s0_reset_ack			( w_s0_reset_ack				),

		.vd								( w_vd							),
		.hd								( w_hd							),
		.field							( w_field						),

		.vdp_vram_wdata_cpu				( w_vram_wdata_cpu				),
		.vdp_vram_address_cpu			( w_vram_address_cpu			),
		.vdp_vram_addr_set_req			( w_vram_addr_set_req			),
		.vdp_vram_addr_set_ack			( w_vram_addr_set_ack			),
		.vdp_vram_wr_req				( w_vram_write_req				),
		.vdp_vram_wr_ack				( w_vram_write_ack				),
		.vdp_vram_rd_data				( w_vram_rdata_cpu				),
		.vdp_vram_rd_req				( w_vram_rd_req					),
		.vdp_vram_rd_ack				( w_vram_rd_ack					),

		.clr_vsync_int					( w_clr_vsync_int				),
		.req_vsync_int_n				( req_vsync_int_n				),

		.reg_r0_hsync_int_en			( reg_r0_hsync_int_en			),
		.reg_r1_sp_size					( reg_r1_sp_size				),
		.reg_r1_sp_zoom					( reg_r1_sp_zoom				),
		.reg_r1_bl_clks					( reg_r1_bl_clks				),
		.reg_r1_vsync_int_en			( reg_r1_vsync_int_en			),
		.reg_r1_disp_on					( reg_r1_disp_on				),
		.reg_r2_pattern_name			( reg_r2_pattern_name			),
		.reg_r4_pattern_generator		( reg_r4_pattern_generator		),
		.reg_r3_color					( reg_r3_color					),
		.reg_r5_sp_atr_addr				( reg_r5_sp_atr_addr			),
		.reg_r6_sp_gen_addr				( reg_r6_sp_gen_addr			),
		.reg_r7_frame_col				( reg_r7_frame_col				),

		.vdp_mode_text1					( w_vdp_mode_text1				),
		.vdp_mode_text1q				( w_vdp_mode_text1q				),
		.vdp_mode_multi					( w_vdp_mode_multi				),
		.vdp_mode_multiq				( w_vdp_mode_multiq				),
		.vdp_mode_graphic1				( w_vdp_mode_graphic1			),
		.vdp_mode_graphic2				( w_vdp_mode_graphic2			)
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
		.videorout						( w_video_r_lcd					),
		.videogout						( w_video_g_lcd					),
		.videobout						( w_video_b_lcd					),
		.videohsout_n					( w_video_hs_n_lcd				),
		.videovsout_n					( w_video_vs_n_lcd				)
	);
endmodule
