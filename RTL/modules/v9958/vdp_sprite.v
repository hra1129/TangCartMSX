//
//	vdp_sprite.v
//	  Sprite module.
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
//---------------------------------------------------------------------------

module vdp_sprite (
	// vdp clock ... 21.477mhz
	input				clk							,
	input				reset						,
	input				enable						,

	input		[1:0]	dot_state					,
	input		[2:0]	eight_dot_state				,

	input		[8:0]	dotcounterx					,
	input		[8:0]	dotcounteryp				,
	input				bwindow_y					,

	// vdp status registers of sprite
	output reg			pvdps0spcollisionincidence	,
	output				pvdps0spovermapped			,
	output		[4:0]	pvdps0spovermappednum		,
	output reg	[8:0]	pvdps3s4spcollisionx		,
	output reg	[8:0]	pvdps5s6spcollisiony		,
	input				pvdps0resetreq				,
	output				pvdps0resetack				,
	input				pvdps5resetreq				,
	output				pvdps5resetack				,
	// vdp registers
	input				reg_r1_sp_size				,
	input				reg_r1_sp_zoom				,
	input		[9:0]	reg_r11r5_sp_atr_addr		,
	input		[5:0]	reg_r6_sp_gen_addr			,
	input				reg_r8_col0_on				,
	input				reg_r8_sp_off				,
	input		[7:0]	reg_r23_vstart_line			,
	input		[2:0]	reg_r27_h_scroll			,
	input				spmode2						,
	input				vraminterleavemode			,

	output reg			spvramaccessing				,

	input		[7:0]	pramdat						,
	output		[16:0]	pramadr						,

	// jp: スプライトを描画した時に1'b1になる。カラーコード0で
	// jp: 描画する事もできるので、このビットが必要
	output reg			sp_color_code_en			,
	// output color
	output reg	[3:0]	sp_color_code				,
	input				reg_r9_y_dots				
);
	reg				ff_sp_en;
	reg		[8:0]	ff_cur_y;
	reg		[8:0]	ff_prev_cur_y;
	wire			w_split_screen;

	reg				ff_vdps0resetack;
	reg				ff_vdps5resetack;

	// for spinforam
	wire	[2:0]	w_info_address;
	reg				ff_info_ram_we;
	wire	[31:0]	w_info_wdata;
	wire	[31:0]	w_info_rdata;

	reg		[8:0]	ff_info_x;
	reg		[15:0]	ff_info_pattern;
	reg		[3:0]	ff_info_color;
	reg				ff_info_cc;
	reg				ff_info_ic;
	wire	[8:0]	w_info_x;
	wire	[15:0]	w_info_pattern;
	wire	[3:0]	w_info_color;
	wire			w_info_cc;
	wire			w_info_ic;

	localparam	c_state_idle		= 2'd0;
	localparam	c_state_ytest_draw	= 2'd1;
	localparam	c_state_prepare		= 2'd2;
	reg		[1:0]	ff_main_state;

	// jp: スプライトプレーン番号×横方向表示枚数の配列
	reg		[4:0]	ff_render_planes[0:7];

	wire	[16:0]	w_vram_address;
	reg		[16:0]	ff_y_test_address;
	reg		[16:0]	ff_preread_address;

	reg		[9:0]	ff_attribute_base_address;
	reg		[5:0]	ff_pattern_gen_base_address;
	wire	[16:2]	w_attribute_address;
	wire	[16:0]	w_read_color_address;
	wire	[16:0]	w_read_pattern_address;

	// jp: y座標検査中のプレーン番号
	reg		[4:0]	ff_y_test_sp_num;
	reg		[3:0]	ff_y_test_listup_addr;		 // 0 - 8
	reg				ff_y_test_en;
	// jp: 下書きデータ準備中のローカルプレーン番号
	reg		[2:0]	ff_prepare_local_plane_num;
	// jp: 下書きデータ準備中のプレーン番号
	reg		[4:0]	ff_prepare_plane_num;
	// jp: 下書きデータ準備中のスプライトのyライン番号(スプライトのどの部分を描画するか)
	reg		[3:0]	ff_prepare_line_num;
	// jp: 下書きデータ準備中のスプライトのx位置。0の時左8ドット。1の時右8ドット。(16x16モードのみで使用)
	wire			w_prepare_x_pos;
	reg		[7:0]	ff_prepare_pattern_num;
	// jp: 下書データの準備が終了した
	reg				ff_prepare_end;

	// jp: 下書きをしているスプライトのローカルプレーン番号
	reg		[2:0]	ff_predraw_local_plane_num;	 // 0 - 7
	reg				ff_sp_predraw_end;

	// jp: ラインバッファへの描画用
	reg		[8:0]	ff_draw_x;					// -32 - 287 (=256+31)
	reg		[15:0]	ff_draw_pattern;
	reg		[3:0]	ff_draw_color;

	// jp: スプライト描画ラインバッファの制御信号
	wire	[7:0]	w_line_buf_address_even;
	wire	[7:0]	w_line_buf_address_odd;
	wire			w_line_buf_we_even;
	wire			w_line_buf_we_odd;
	wire	[7:0]	w_line_buf_wdata_even;
	wire	[7:0]	w_line_buf_wdata_odd;
	wire	[7:0]	w_line_buf_rdata_even;
	wire	[7:0]	w_line_buf_rdata_odd;

	reg				ff_line_buf_disp_we;
	reg				ff_line_buf_draw_we;
	reg		[7:0]	ff_line_buf_disp_x;
	reg		[7:0]	ff_line_buf_draw_x;
	reg		[7:0]	ff_line_buf_draw_color;
	wire	[7:0]	w_line_buf_disp_data;
	wire	[7:0]	w_line_buf_draw_data;

	reg				ff_window_x;

	reg				ff_sp_overmap;
	reg		[4:0]	ff_sp_overmap_num;

	wire	[7:0]	w_listup_y;
	wire			w_target_sp_en;
	wire			w_sp_off;
	wire			w_sp_overmap;
	wire			w_active;
	reg				ff_window_y;
	wire			w_ram_even_we;
	wire			w_ram_odd_we;

	assign pvdps0resetack			= ff_vdps0resetack;
	assign pvdps5resetack			= ff_vdps5resetack;
	assign pvdps0spovermapped		= ff_sp_overmap;
	assign pvdps0spovermappednum	= ff_sp_overmap_num;

	//---------------------------------------------------------------------------
	// スプライトを表示するか否かを示す信号
	//---------------------------------------------------------------------------
	always @( posedge clk ) begin
		if( reset ) begin
			ff_sp_en <= 1'b0;
		end
		else if( !enable ) begin
			//	hold
		end
		else if( dot_state == 2'b01 && dotcounterx == 0 ) begin
			ff_sp_en <= w_active;
		end
	end

	//---------------------------------------------------------------------------
	// sprite information array
	// 実際に表示するスプライトの情報を集めて記録しておくram
	//---------------------------------------------------------------------------
	vdp_spinforam u_sprite_info_ram (
		.address		( w_info_address			),
		.clk			( clk						),
		.enable			( enable					),
		.we				( ff_info_ram_we			),
		.data			( w_info_wdata				),
		.q				( w_info_rdata				)
	);

	assign w_info_wdata			=	{ 1'b0, ff_info_x, ff_info_pattern, ff_info_color, ff_info_cc, ff_info_ic };
	assign w_info_x				=	w_info_rdata[30:22];
	assign w_info_pattern		=	w_info_rdata[21:6];
	assign w_info_color			=	w_info_rdata[5:2];
	assign w_info_cc			=	w_info_rdata[1];
	assign w_info_ic			=	w_info_rdata[0];

	assign w_info_address		=	( ff_main_state == c_state_prepare ) ? ff_prepare_local_plane_num : ff_predraw_local_plane_num;

	//---------------------------------------------------------------------------
	// sprite line buffer
	//---------------------------------------------------------------------------
	assign w_line_buf_address_even	= ( !dotcounteryp[0] ) ? ff_line_buf_disp_x		: ff_line_buf_draw_x;
	assign w_line_buf_wdata_even	= ( !dotcounteryp[0] ) ? 8'd0					: ff_line_buf_draw_color;
	assign w_line_buf_we_even		= ( !dotcounteryp[0] ) ? ff_line_buf_disp_we	: ff_line_buf_draw_we;
	assign w_line_buf_disp_data		= ( !dotcounteryp[0] ) ? w_line_buf_rdata_even	: w_line_buf_rdata_odd;

	assign w_ram_even_we			= w_line_buf_we_even & enable;

	vdp_ram_256byte u_even_line_buf (
		.clk		( clk							),
		.enable		( enable						),
		.address	( w_line_buf_address_even		),
		.we			( w_ram_even_we					),
		.wdata		( w_line_buf_wdata_even			),
		.rdata		( w_line_buf_rdata_even			)
	);

	assign w_line_buf_address_odd	= ( !dotcounteryp[0] ) ? ff_line_buf_draw_x		: ff_line_buf_disp_x;
	assign w_line_buf_wdata_odd		= ( !dotcounteryp[0] ) ? ff_line_buf_draw_color	: 8'd0;
	assign w_line_buf_we_odd		= ( !dotcounteryp[0] ) ? ff_line_buf_draw_we	: ff_line_buf_disp_we;
	assign w_line_buf_draw_data		= ( !dotcounteryp[0] ) ? w_line_buf_rdata_odd	: w_line_buf_rdata_even;

	assign w_ram_odd_we				= w_line_buf_we_odd & enable;

	vdp_ram_256byte u_odd_line_buf (
		.clk		( clk							),
		.enable		( enable						),
		.address	( w_line_buf_address_odd		),
		.we			( w_ram_odd_we					),
		.wdata		( w_line_buf_wdata_odd			),
		.rdata		( w_line_buf_rdata_odd			)
	);

	//---------------------------------------------------------------------------
	assign w_prepare_x_pos		=	( eight_dot_state == 3'd4 ) ? 1'b1 : 1'b0;

	// jp: vramアクセスアドレスの出力
	assign w_vram_address		= ( ff_main_state == c_state_ytest_draw ) ? ff_y_test_address : ff_preread_address;
	assign pramadr				= ( vraminterleavemode ) ? { w_vram_address[0], w_vram_address[16:1] } : w_vram_address[16:0];

	//---------------------------------------------------------------------------
	// state machine
	//---------------------------------------------------------------------------
	always @( posedge clk ) begin
		if( reset ) begin
			ff_main_state <= c_state_idle;
		end
		else if( !enable ) begin
			//	hold
		end
		else if( dot_state == 2'b10 ) begin
			case( ff_main_state )
			c_state_idle:
				if( dotcounterx == 0 ) begin
					ff_main_state <= c_state_ytest_draw;
				end
			c_state_ytest_draw:
				if( dotcounterx == 256+8 ) begin
					ff_main_state <= c_state_prepare;
				end
			c_state_prepare:
				if( ff_prepare_end ) begin
					ff_main_state <= c_state_idle;
				end
			default:
				ff_main_state <= c_state_idle;
			endcase
		end
	end

	//---------------------------------------------------------------------------
	// 現ラインのライン番号
	//---------------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !enable ) begin
			//	hold
		end
		else if( (dot_state == 2'b01) && (dotcounterx == 0) ) begin
			//	 +1 should be needed. because it will be drawn in the next line.
			ff_cur_y <= dotcounteryp + { 1'b0, reg_r23_vstart_line } + 1;
		end
	end

	always @( posedge clk ) begin
		if( !enable ) begin
			//	hold
		end
		else if( (dot_state == 2'b01) && (dotcounterx == 0) ) begin
			ff_prev_cur_y <= ff_cur_y;
		end
	end

	// detect a split screen
	assign w_split_screen	= (ff_cur_y == (ff_prev_cur_y + 1)) ? 1'b0 : 1'b1;

	//---------------------------------------------------------------------------
	// vram address generator
	//---------------------------------------------------------------------------
	always @( posedge clk ) begin
		// latching address signals
		if( !enable ) begin
			//	hold
		end
		else if( (dot_state == 2'b01) && (dotcounterx == 0) ) begin
			ff_pattern_gen_base_address <= reg_r6_sp_gen_addr;
			if( !spmode2 ) begin
				ff_attribute_base_address <= reg_r11r5_sp_atr_addr[9:0];
			end
			else begin
				ff_attribute_base_address <= { reg_r11r5_sp_atr_addr[9:2], 2'b00 };
			end
		end
	end

	//---------------------------------------------------------------------------
	// vram access mask
	//---------------------------------------------------------------------------
	always @( posedge clk ) begin
		if( reset ) begin
			spvramaccessing <= 1'b0;
		end
		else if( !enable ) begin
			//	hold
		end
		else if( dot_state == 2'b10 ) begin
			case( ff_main_state )
			c_state_idle:
				begin
					if( dotcounterx == 0 ) begin
						spvramaccessing <= (~reg_r8_sp_off) & w_active;
					end
				end
			c_state_ytest_draw:
				begin
					if( dotcounterx == 256+8 ) begin
						spvramaccessing <= (~reg_r8_sp_off) & ff_sp_en;
					end
				end
			c_state_prepare:
				begin
					if( ff_prepare_end == 1'b1 ) begin
						spvramaccessing <= 1'b0;
					end
				end
			default:
				begin
					//	hold
				end
			endcase
		end
	end

	//---------------------------------------------------------------------------
	// [y_test]yテスト用の信号
	//---------------------------------------------------------------------------
	assign w_listup_y		= ff_cur_y[7:0] - pramdat;

	// [y_test]着目スプライトを現ラインに表示するかどうかの信号
	assign w_target_sp_en	= (((w_listup_y[7:3] == 5'd0) && (!reg_r1_sp_size) && (!reg_r1_sp_zoom)) ||
							   ((w_listup_y[7:4] == 4'd0) && ( reg_r1_sp_size) && (!reg_r1_sp_zoom)) ||
							   ((w_listup_y[7:4] == 4'd0) && (!reg_r1_sp_size) && ( reg_r1_sp_zoom)) ||
							   ((w_listup_y[7:5] == 3'd0) && ( reg_r1_sp_size) && ( reg_r1_sp_zoom)) );

	// [y_test]これ以降のスプライトは表示禁止かどうかの信号
	assign w_sp_off			=	( pramdat == { 4'b1101, spmode2, 3'b000 } ) ? 1'b1: 1'b0;

	// [y_test]４つ（８つ）のスプライトが並んでいるかどうかの信号
	assign w_sp_overmap		=	( (ff_y_test_listup_addr[2] & !spmode2) | ff_y_test_listup_addr[3] );

	// [y_test]表示中のラインか否か
	assign w_active			=	bwindow_y;

	//---------------------------------------------------------------------------
	// [ff_window_y]
	//---------------------------------------------------------------------------
	always @( posedge clk ) begin
		if( reset ) begin
			ff_window_y <= 1'b0;
		end
		else if( !enable ) begin
			//	hold
		end
		else if( dotcounteryp == 0 ) begin
			ff_window_y <= 1'b1;
		end
		else if( ( !reg_r9_y_dots && dotcounteryp == 192 ) ||
				 (  reg_r9_y_dots && dotcounteryp == 212 ) ) begin
			ff_window_y <= 1'b0;
		end
	end


	//---------------------------------------------------------------------------
	// [y_test]yテストステートでないことを示す信号
	//---------------------------------------------------------------------------
	always @( posedge clk ) begin
		if( reset ) begin
			ff_y_test_en <= 1'b0;
		end
		else if( !enable ) begin
			//	hold
		end
		else if( dot_state == 2'b01 ) begin
			if( dotcounterx == 0 ) begin
				ff_y_test_en <= ff_sp_en;
			end
			else if( eight_dot_state == 3'd6 ) begin
				if( w_sp_off || (w_sp_overmap && w_target_sp_en) || (ff_y_test_sp_num == 5'b11111) ) begin
					ff_y_test_en <= 1'b0;
				end
			end
		end
	end

	//---------------------------------------------------------------------------
	// [y_test]テスト対象のスプライト番号 (0～31)
	//---------------------------------------------------------------------------
	always @( posedge clk ) begin
		if( reset ) begin
			ff_y_test_sp_num <= 5'd0;
		end
		else if( !enable ) begin
			//	hold
		end
		else if( dot_state == 2'b01 ) begin
			if( dotcounterx == 0 ) begin
				ff_y_test_sp_num <= 5'd0;
			end
			else if( eight_dot_state == 3'd6 ) begin
				if( ff_y_test_en && ff_y_test_sp_num != 5'b11111 ) begin
					ff_y_test_sp_num <= ff_y_test_sp_num + 1;
				end
			end
		end
	end

	//---------------------------------------------------------------------------
	// [y_test]表示するスプライトをリストアップするためのリストアップメモリアドレス 0～8
	//---------------------------------------------------------------------------
	always @( posedge clk ) begin
		if( reset ) begin
			ff_y_test_listup_addr <= 4'd0;
		end
		else if( !enable ) begin
			//	hold
		end
		else if( dot_state == 2'b01 ) begin
			if( dotcounterx == 0 ) begin
				// initialize
				ff_y_test_listup_addr <= 4'd0;
			end
			else if( eight_dot_state == 3'd6 ) begin
				// next sprite [リストアップメモリが満杯になるまでインクリメント]
				if( ff_y_test_en && w_target_sp_en && !w_sp_overmap && !w_sp_off ) begin
					ff_y_test_listup_addr <= ff_y_test_listup_addr + 1;
				end
			end
		end
	end

	//---------------------------------------------------------------------------
	// [y_test]表示するスプライトをリストアップするためのリストアップメモリへの書き込み
	//---------------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !enable ) begin
			//	hold
		end
		else if( dot_state == 2'b01 ) begin
			if( dotcounterx == 0 ) begin
				// initialize
			end
			else if( eight_dot_state == 3'd6 ) begin
				// next sprite
				if( ff_y_test_en && w_target_sp_en && !w_sp_overmap && !w_sp_off ) begin
					ff_render_planes[ ff_y_test_listup_addr ] <= ff_y_test_sp_num;
				end
			end
		end
	end

	//---------------------------------------------------------------------------
	// [y_test]４つ目（８つ目）のスプライトが並んだかどうかの信号
	//---------------------------------------------------------------------------
	always @( posedge clk ) begin
		if( reset ) begin
			ff_sp_overmap		<= 1'b0;
		end
		else if( !enable ) begin
			//	hold
		end
		else if( pvdps0resetreq == ~ff_vdps0resetack ) begin
			// s#0が読み込まれるまでクリアしない
			ff_sp_overmap		<= 1'b0;
		end
		else if( dot_state == 2'b01 ) begin
			if( dotcounterx == 0 ) begin
				// initialize
			end
			else if( eight_dot_state == 3'd6 ) begin
				if( ff_window_y && ff_y_test_en && w_target_sp_en && w_sp_overmap && !w_sp_off ) begin
					ff_sp_overmap <= 1'b1;
				end
			end
		end
	end

	//---------------------------------------------------------------------------
	// [y_test]処理をあきらめたスプライト信号
	//---------------------------------------------------------------------------
	always @( posedge clk ) begin
		if( reset ) begin
			ff_sp_overmap_num	<= 5'b11111;
		end
		else if( !enable ) begin
			//	hold
		end
		else if( pvdps0resetreq == ~ff_vdps0resetack ) begin
			ff_sp_overmap_num	<= 5'b11111;
		end
		else if( dot_state == 2'b01 ) begin
			if( dotcounterx == 0 ) begin
				// initialize
			end
			else if( eight_dot_state == 3'd6 ) begin
				// jp: 調査をあきらめたスプライト番号が格納される。overmapとは限らない。
				// jp: しかし、すでに overmap で値が確定している場合は更新しない。
				if( ff_window_y && ff_y_test_en && w_target_sp_en && w_sp_overmap && !w_sp_off && !ff_sp_overmap ) begin
					ff_sp_overmap_num <= ff_y_test_sp_num;
				end
			end
		end
	end

	//---------------------------------------------------------------------------
	// yテスト用の vram読み出しアドレス
	//---------------------------------------------------------------------------
	always @( posedge clk ) begin
		if( reset ) begin
			ff_y_test_address <= 17'd0;
		end
		else if( !enable ) begin
			//	hold
		end
		else if( dot_state == 2'b11 ) begin
			ff_y_test_address <= { ff_attribute_base_address, ff_y_test_sp_num, 2'b00 };
		end
	end

	//---------------------------------------------------------------------------
	// prepare sprite
	//
	// jp: 画面描画中			: 8ドット描画する間に1プレーン、スプライトのy座標を検査し、
	// jp:						  表示すべきスプライトをリストアップする。
	// jp: 画面非描画中			: リストアップしたスプライトの情報を集め、inforamに格納
	// jp: 次の画面描画中		: inforamに格納された情報を元に、ラインバッファに描画
	// jp: 次の次の画面描画中	: ラインバッファに描画された絵を出力し、画面描画に混ぜる
	//---------------------------------------------------------------------------

	// read timing of sprite attribute table
	assign w_attribute_address		= { ff_attribute_base_address, ff_prepare_plane_num };
	assign w_read_pattern_address	= ( !reg_r1_sp_size ) ?
										{ ff_pattern_gen_base_address, ff_prepare_pattern_num[7:0], ff_prepare_line_num[2:0]                } :		// 8x8 mode
										{ ff_pattern_gen_base_address, ff_prepare_pattern_num[7:2], w_prepare_x_pos, ff_prepare_line_num[3:0] };	// 16x16 mode
	assign w_read_color_address		= ( !spmode2 ) ? 
										{ w_attribute_address, 2'b11 } :
										{ ff_attribute_base_address[9:3], (~ff_attribute_base_address[2]), ff_prepare_plane_num, ff_prepare_line_num };

	always @( posedge clk ) begin
		if( reset ) begin
			ff_preread_address <= 17'd0;
		end
		else if( !enable ) begin
			//	hold
		end
		else if( dot_state == 2'b11 ) begin
			case( eight_dot_state )
			3'd0:								// y read
				ff_preread_address <= { w_attribute_address, 2'b00 };
			3'd1:								// x read
				ff_preread_address <= { w_attribute_address, 2'b01 };
			3'd2:								// pattern num read
				ff_preread_address <= { w_attribute_address, 2'b10 };
			3'd3, 3'd4:						// pattern read
				ff_preread_address <= w_read_pattern_address;
			3'd5:								// color read
				ff_preread_address <= w_read_color_address;
			default:
				begin
					//	hold
				end
			endcase
		end
	end

	always @( posedge clk ) begin
		if( !enable ) begin
			//	hold
		end
		else begin
			case( dot_state )
			2'b11:
				ff_info_ram_we <= 1'b0;
			2'b01:
				begin
					if( ff_main_state == c_state_prepare ) begin
						if( eight_dot_state == 3'b110 ) begin
							ff_info_ram_we <= 1'b1;
						end
					end
					else begin
						ff_info_ram_we <= 1'b0;
					end
				end
			default:
				begin
					//	hold
				end
			endcase
		end
	end

	always @( posedge clk ) begin
		if( reset ) begin
			ff_prepare_local_plane_num	<= 3'd0;
			ff_prepare_end				<= 1'b0;
		end
		else if( !enable ) begin
			//	hold
		end
		else begin
			if( dot_state == 2'b01 ) begin
				if( ff_main_state == c_state_prepare ) begin
					case( eight_dot_state )
					3'b001:								// y read
						begin
							// jp: スプライトの何行目が該当したか覚えておく
							if( !reg_r1_sp_zoom ) begin
								ff_prepare_line_num	<= w_listup_y[3:0];
							end
							else begin
								ff_prepare_line_num	<= w_listup_y[4:1];
							end
						end
					3'b010:								// x read
						ff_info_x <= { 1'b0, pramdat };
					3'b011:								// pattern num read
						ff_prepare_pattern_num <= pramdat;
					3'b100:								// pattern read left
						ff_info_pattern[15:8] <= pramdat;
					3'b101:								// pattern read right
						begin
							if( !reg_r1_sp_size ) begin
								// 8x8 mode
								ff_info_pattern[7:0] <= 8'd0;
							end
							else begin
								// 16x16 mode
								ff_info_pattern[7:0] <= pramdat;
							end
						end
					3'b110:								// color read
						begin
							// color
							ff_info_color <= pramdat[3:0];
							// cc	優先順位ビット (1: 優先順位無し, 0: 優先順位あり)
							if( spmode2 ) begin
								ff_info_cc <= pramdat[6];
							end
							else begin
								ff_info_cc <= 1'b0;
							end
							// ic	衝突検知ビット (1: 検知しない, 0: 検知する)
							ff_info_ic <= pramdat[5] & spmode2;
							// ec	32ドット左シフト (1: する, 0: しない)
							if( pramdat[7] ) begin
								ff_info_x <= ff_info_x - 32;
							end

							// if all of the sprites list-uped are readed,
							// the sprites left should not be drawn.
							if( ff_prepare_local_plane_num >= ff_y_test_listup_addr ) begin
								ff_info_pattern <= 16'd0;
							end
						end
					3'b111:
						begin
							ff_prepare_local_plane_num <= ff_prepare_local_plane_num + 1;
							if( (ff_prepare_local_plane_num == 7) || (ff_prepare_local_plane_num == 3 && !spmode2) ) begin
								ff_prepare_end <= 1'b1;
							end
						end
					default:
						begin
							//	hold
						end
					endcase
				end
				else begin
					ff_prepare_local_plane_num	<= 3'd0;
					ff_prepare_end				<= 1'b0;
				end
			end
		end
	end

	always @( posedge clk ) begin
		if( !enable ) begin
			//	hold
		end
		else if( dot_state == 2'b01 ) begin
			if( ff_main_state == c_state_prepare ) begin
				if( eight_dot_state == 3'd7 ) begin
					ff_prepare_plane_num <= ff_render_planes[ ff_prepare_local_plane_num + 1 ];
				end
			end
			else begin
				ff_prepare_plane_num <= ff_render_planes[0];
			end
		end
	end

	//---------------------------------------------------------------------------
	// drawing to line buffer.
	//
	// dotcounterx[4:0]
	//	 0... 31	draw local plane#0 to line buffer
	//	32... 63	draw local plane#1 to line buffer
	//	   :						 :
	// 224...255	draw local plane#7 to line buffer
	//---------------------------------------------------------------------------
	always @( posedge clk ) begin: u_drawing_to_line_buffer
		reg				ff_cc0_found;
		reg		[2:0]	ff_last_cc0_local_plane_num;
		reg		[8:0]	ff_draw_x_pre;						 // -32 - 287 (=256+31)
		reg				ff_s0_collision_incidence;
		reg		[8:0]	ff_s3s4_collision_x;
		reg		[8:0]	ff_s5s6_collision_y;

		if( reset ) begin
			ff_line_buf_draw_we			<= 1'b0;					// jp: ラインバッファへの書き込みイネーブラ
			ff_sp_predraw_end			<= 1'b0;
			ff_draw_pattern				<= 'd0;
			ff_line_buf_draw_color		<= 'd0;
			ff_line_buf_draw_x			<= 'd0;
			ff_draw_color				<= 'd0;
			ff_vdps0resetack			<= 1'b0;
			ff_vdps5resetack			<= 1'b0;

			ff_s0_collision_incidence	= 1'b0;						// jp: スプライトが衝突したかどうかを示すフラグ
			ff_s3s4_collision_x			= 'd0;
			ff_s5s6_collision_y			= 'd0;
			ff_cc0_found				= 1'b0;
			ff_last_cc0_local_plane_num	= 'd0;
		end
		else if( !enable ) begin
			//	hold
		end
		else if( ff_main_state == c_state_ytest_draw ) begin
			case( dot_state )
			2'b10:
				// jp: 処理単位の始まり
				ff_line_buf_draw_we <= 1'b0;
			2'b00:
				begin
					// jp:
					if( dotcounterx[4:0] == 4'd1 ) begin
						ff_draw_pattern	<= w_info_pattern;
						ff_draw_x_pre	= w_info_x;
					end
					else begin
						if( !reg_r1_sp_zoom || dotcounterx[0] ) begin
							ff_draw_pattern <= { ff_draw_pattern[14:0], 1'b0 };
						end
						ff_draw_x_pre	= ff_draw_x + 1;
					end
					ff_draw_x			<= ff_draw_x_pre;
					ff_line_buf_draw_x	<= ff_draw_x_pre[7:0];
				end
			2'b01:
				ff_draw_color <= w_info_color;
			2'b11:
				begin
					if( !w_info_cc ) begin
						ff_last_cc0_local_plane_num = ff_predraw_local_plane_num;
						ff_cc0_found = 1'b1;
					end
					if( ff_draw_pattern[15] && !ff_draw_x[8] && !ff_sp_predraw_end && (reg_r8_col0_on || (ff_draw_color != 0)) ) begin
						// jp: スプライトのドットを描画
						// jp: ラインバッファの7ビット目は、何らかの色を描画した時に1'b1になる。
						// jp: ラインバッファの6-4ビット目はそこに描画されているドットのローカルプレーン番号
						// jp: (色合成されているときは親となるcc=1'b0のスプライトのローカルプレーン番号)が入る。
						// jp: つまり、ff_last_cc0_local_plane_numがこの番号と等しいときはor合成してよい事になる。
						if( !w_line_buf_draw_data[7] && ff_cc0_found ) begin
							// jp: 何も描かれていない(ビット7が1'b0)とき、このドットに初めての
							// jp: スプライトが描画される。ただし、cc=1'b0のスプライトが同一ライン上にまだ
							// jp: 現れていない時は描画しない
							ff_line_buf_draw_color	<= { 1'b1, ff_last_cc0_local_plane_num, ff_draw_color };
							ff_line_buf_draw_we		<= 1'b1;
						end
						else if( w_line_buf_draw_data[7] && w_info_cc && w_line_buf_draw_data[6:4] == ff_last_cc0_local_plane_num ) begin
							// jp: 既に絵が描かれているが、ccが1'b1でかつこのドットに描かれているスプライトの
							// jp: localplanenumが ff_last_cc0_local_plane_numと等しい時は、ラインバッファから
							// jp: 下地データを読み、書きたい色と論理和を取リ、書き戻す。
							ff_line_buf_draw_color	<= w_line_buf_draw_data | { 4'b0000, ff_draw_color };
							ff_line_buf_draw_we		<= 1'b1;
						end
						else if( w_line_buf_draw_data[7] && !w_info_ic ) begin
							ff_line_buf_draw_color		<= w_line_buf_draw_data;
							// jp: スプライトが衝突。
							// sprite colision occured
							ff_s0_collision_incidence	= 1'b1;
							ff_s3s4_collision_x			= ff_draw_x + 12;
							// note: drawing line is previous line.
							ff_s5s6_collision_y			= ff_cur_y + 7;
						end
					end
					//
					if( dotcounterx == 0 ) begin
						ff_predraw_local_plane_num	<= 'd0;
						ff_sp_predraw_end				<= w_split_screen || reg_r8_sp_off;
						ff_last_cc0_local_plane_num		= 'd0;
						ff_cc0_found					= 1'b0;
					end
					else if( dotcounterx[4:0] == 5'd0 ) begin
						ff_predraw_local_plane_num <= ff_predraw_local_plane_num + 1;
						if( (ff_predraw_local_plane_num == 7) || (ff_predraw_local_plane_num == 3 && !spmode2) ) begin
							ff_sp_predraw_end <= 1'b1;
						end
					end
				end
			default:
				begin
					//	hold
				end
			endcase
		end

		// status register
		if( !enable ) begin
			//	hold
		end
		else if( pvdps0resetreq != ff_vdps0resetack ) begin
			ff_vdps0resetack <= pvdps0resetreq;
			ff_s0_collision_incidence = 1'b0;
		end
		
		if( !enable ) begin
			//	hold
		end
		else if( pvdps5resetreq != ff_vdps5resetack ) begin
			ff_vdps5resetack <= pvdps5resetreq;
			ff_s3s4_collision_x = 9'd0;
			ff_s5s6_collision_y = 9'd0;
		end

		if( !enable ) begin
			//	hold
		end
		else begin
			pvdps0spcollisionincidence	<= ff_s0_collision_incidence;
			pvdps3s4spcollisionx		<= ff_s3s4_collision_x;
			pvdps5s6spcollisiony		<= ff_s5s6_collision_y;
		end
	end

	//---------------------------------------------------------------------------
	// jp: 画面へのレンダリング。vdpエンティティがdot_state=2'b11の時に値を取得できるように、
	// jp: 2'b01のタイミングで出力する。
	//---------------------------------------------------------------------------
	always @( posedge clk ) begin
		if( reset ) begin
			ff_line_buf_disp_x	<= 8'd0;
		end
		else if( !enable ) begin
			//	hold
		end
		else if( dot_state == 2'b10 ) begin
			// jp: dotcounterと実際の表示(カラーコードの出力)は8ドットずれている
			if( dotcounterx == 8 ) begin
				ff_line_buf_disp_x <= { 5'b00000, reg_r27_h_scroll };
			end
			else begin
				ff_line_buf_disp_x <= ff_line_buf_disp_x + 1;
			end
		end
	end

	always @( posedge clk ) begin
		if( reset ) begin
			ff_window_x <= 1'b0;
		end
		else if( !enable ) begin
			//	hold
		end
		else if( dot_state == 2'b10 ) begin
			// jp: dotcounterと実際の表示(カラーコードの出力)は8ドットずれている
			if( dotcounterx == 8 ) begin
				ff_window_x <= 1'b1;
			end
			else if( ff_line_buf_disp_x == 8'hff ) begin
				ff_window_x <= 1'b0;
			end
		end
	end

	always @( posedge clk ) begin
		if( reset ) begin
			ff_line_buf_disp_we <= 1'b0;
		end
		else if( !enable ) begin
			//	hold
		end
		else if( dot_state == 2'b10 ) begin
			ff_line_buf_disp_we <= 1'b0;
		end
		else if( dot_state == 2'b11 && ff_window_x == 1'b1 ) begin
			// clear displayed dot
			ff_line_buf_disp_we <= 1'b1;
		end
	end

	// jp: ウィンドウで表示をカットする
	always @( posedge clk ) begin
		if( reset ) begin
			sp_color_code_en	<= 1'b0;				// jp:	0=透明, 1=スプライトドット
			sp_color_code		<= 4'd0;				// jp:	sp_color_code_en=1 の時のスプライトドット色番号
		end
		else if( !enable ) begin
			//	hold
		end
		else if( dot_state == 2'b01 ) begin
			if( ff_window_x ) begin
				sp_color_code_en	<= w_line_buf_disp_data[7];
				sp_color_code		<= w_line_buf_disp_data[3:0];
			end
			else begin
				sp_color_code_en	<= 1'b0;
				sp_color_code		<= 4'd0;
			end
		end
	end
endmodule
