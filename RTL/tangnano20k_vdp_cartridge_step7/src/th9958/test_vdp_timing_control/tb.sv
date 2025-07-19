// -----------------------------------------------------------------------------
//	Test of vdp_timing_control.v
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

	// ----------------------------------------------------------------
	// テストベンチの信号定義
	// ----------------------------------------------------------------
	reg				reset_n;
	reg				clk;

	wire	[10:0]	h_count;
	wire	[ 9:0]	v_count;
	wire	[12:0]	screen_pos_x;
	wire	[ 9:0]	screen_pos_y;
	wire			screen_active;
	wire			intr_line;
	wire			intr_frame;

	// VRAMインターフェース
	wire	[16:0]	t12_vram_address;
	wire			t12_vram_valid;
	reg		[7:0]	t12_vram_rdata;
	wire	[3:0]	t12_display_color;

	wire	[16:0]	g123m_vram_address;
	wire			g123m_vram_valid;
	reg		[7:0]	g123m_vram_rdata;
	wire	[3:0]	g123m_display_color;

	wire	[16:0]	g4567_vram_address;
	wire			g4567_vram_valid;
	reg		[31:0]	g4567_vram_rdata;
	wire	[7:0]	g4567_display_color;

	wire	[16:0]	sprite_vram_address;
	wire			sprite_vram_valid;
	reg		[31:0]	sprite_vram_rdata;
	reg		[7:0]	sprite_vram_rdata8;
	wire	[3:0]	sprite_display_color;
	wire			sprite_display_color_en;

	// レジスタ信号
	reg				reg_50hz_mode;
	reg				reg_212lines_mode;
	reg				reg_interlace_mode;
	reg		[7:0]	reg_interrupt_line;
	reg		[7:0]	reg_vertical_offset;
	reg		[8:0]	reg_horizontal_offset;
	reg		[4:0]	reg_screen_mode;
	reg				reg_display_on;
	reg		[16:10]	reg_pattern_name_table_base;
	reg		[16:6]	reg_color_table_base;
	reg		[16:11]	reg_pattern_generator_table_base;
	reg		[16:9]	reg_sprite_attribute_table_base;
	reg		[16:11]	reg_sprite_pattern_generator_table_base;
	reg				reg_sprite_magify;
	reg				reg_sprite_16x16;
	reg				reg_sprite_disable;
	reg				reg_color0_opaque;
	reg		[7:0]	reg_backdrop_color;
	reg				reg_left_mask;

	// ----------------------------------------------------------------
	// DUTインスタンス
	// ----------------------------------------------------------------
	vdp_timing_control u_dut (
		.reset_n									( reset_n									),
		.clk										( clk										),
		.h_count									( h_count									),
		.v_count									( v_count									),
		.screen_pos_x								( screen_pos_x								),
		.screen_pos_y								( screen_pos_y								),
		.screen_active								( screen_active								),
		.intr_line									( intr_line									),
		.intr_frame									( intr_frame								),
		.t12_vram_address							( t12_vram_address							),
		.t12_vram_valid								( t12_vram_valid							),
		.t12_vram_rdata								( t12_vram_rdata							),
		.t12_display_color							( t12_display_color							),
		.g123m_vram_address							( g123m_vram_address						),
		.g123m_vram_valid							( g123m_vram_valid							),
		.g123m_vram_rdata							( g123m_vram_rdata							),
		.g123m_display_color						( g123m_display_color						),
		.g4567_vram_address							( g4567_vram_address						),
		.g4567_vram_valid							( g4567_vram_valid							),
		.g4567_vram_rdata							( g4567_vram_rdata							),
		.g4567_display_color						( g4567_display_color						),
		.sprite_vram_address						( sprite_vram_address						),
		.sprite_vram_valid							( sprite_vram_valid							),
		.sprite_vram_rdata							( sprite_vram_rdata							),
		.sprite_vram_rdata8							( sprite_vram_rdata8						),
		.sprite_display_color						( sprite_display_color						),
		.sprite_display_color_en					( sprite_display_color_en					),
		.reg_50hz_mode								( reg_50hz_mode								),
		.reg_212lines_mode							( reg_212lines_mode							),
		.reg_interlace_mode							( reg_interlace_mode						),
		.reg_interrupt_line							( reg_interrupt_line						),
		.reg_vertical_offset						( reg_vertical_offset						),
		.reg_horizontal_offset						( reg_horizontal_offset						),
		.reg_screen_mode							( reg_screen_mode							),
		.reg_display_on								( reg_display_on							),
		.reg_pattern_name_table_base				( reg_pattern_name_table_base				),
		.reg_color_table_base						( reg_color_table_base						),
		.reg_pattern_generator_table_base			( reg_pattern_generator_table_base			),
		.reg_sprite_attribute_table_base			( reg_sprite_attribute_table_base			),
		.reg_sprite_pattern_generator_table_base	( reg_sprite_pattern_generator_table_base	),
		.reg_sprite_magify							( reg_sprite_magify							),
		.reg_sprite_16x16							( reg_sprite_16x16							),
		.reg_sprite_disable							( reg_sprite_disable						),
		.reg_color0_opaque							( reg_color0_opaque							),
		.reg_backdrop_color							( reg_backdrop_color						),
		.reg_left_mask								( reg_left_mask								)
	);

	// ----------------------------------------------------------------
	// クロック生成
	// ----------------------------------------------------------------
	always begin
		clk = 1'b0;
		#(clk_base/2);
		clk = 1'b1;
		#(clk_base/2);
	end

	// ----------------------------------------------------------------
	// VRAMダミーデータ生成
	// ----------------------------------------------------------------
	always @(*) begin
		// テスト用のダミーデータを生成
		t12_vram_rdata = 8'h55;				// パターンデータ
		g123m_vram_rdata = 8'hAA;			// パターンデータ
		g4567_vram_rdata = 32'h56781234;	// グラフィック4-7用データ
		sprite_vram_rdata = 32'hFFFFFFFF;	// スプライトデータ
	end

	// ----------------------------------------------------------------
	// 初期化処理
	// ----------------------------------------------------------------
	initial begin
		// 初期値設定
		reset_n = 1'b0;
		reg_50hz_mode = 1'b0;					// 60Hz mode
		reg_212lines_mode = 1'b0;				// 192 lines mode
		reg_interlace_mode = 1'b0;				// Non-interlace
		reg_interrupt_line = 8'd192;			// 標準的な割り込みライン
		reg_vertical_offset = 8'd0;				// 垂直オフセットなし
		reg_horizontal_offset = 9'd0;			// 水平オフセットなし
		reg_screen_mode = 5'd0;					// Screen mode 0
		reg_display_on = 1'b1;					// Display ON
		reg_pattern_name_table_base = 7'h00;	// パターンネームテーブルベース
		reg_color_table_base = 11'h000;			// カラーテーブルベース
		reg_pattern_generator_table_base = 6'h00; // パターンジェネレータテーブルベース
		reg_sprite_attribute_table_base = 0;
		reg_sprite_pattern_generator_table_base = 0;
		reg_sprite_magify = 0;
		reg_sprite_16x16 = 0;
		reg_sprite_disable = 0;
		reg_color0_opaque = 0;
		reg_backdrop_color = 8'h0F;				// 背景色（白）
		reg_left_mask = 1'b0;

		// リセット解除
		#(clk_base * 10);
		reset_n = 1'b1;
		
		$display("=== VDP Timing Control Test Start ===");
		
		// テスト1: 基本的なタイミング信号の確認
		test_basic_timing();
		
		// テスト2: 50Hz/60Hzモードの切り替え
		test_refresh_rate();
		
		// テスト3: 割り込みライン設定の確認
		test_interrupt_line();
		
		// テスト4: オフセット設定の確認
		test_offset_settings();
		
		// テスト5: 画面モード切り替えの確認
		test_screen_modes();
		
		$display("=== All Tests Completed ===");
		$finish;
	end

	// ----------------------------------------------------------------
	// テスト1: 基本的なタイミング信号の確認
	// ----------------------------------------------------------------
	task test_basic_timing();
		integer h_count_max, v_count_max;
		integer frame_count;
		
		$display("--- Test 1: Basic Timing Signals ---");
		
		frame_count = 0;
		h_count_max = 0;
		v_count_max = 0;
		
		// 2フレーム分の動作を確認
		while (frame_count < 2) begin
			@(posedge clk);
			
			// 最大値を記録
			if (h_count > h_count_max) h_count_max = h_count;
			if (v_count > v_count_max) v_count_max = v_count;
			
			// フレーム割り込みを検出
			if (intr_frame) begin
				frame_count = frame_count + 1;
				$display("Frame %0d: H_MAX=%0d, V_MAX=%0d", frame_count, h_count_max, v_count_max);
			end
		end
		
		$display("Basic timing test completed");
	endtask

	// ----------------------------------------------------------------
	// テスト2: 50Hz/60Hzモードの切り替え
	// ----------------------------------------------------------------
	task test_refresh_rate();
		integer cycle_count_60hz, cycle_count_50hz;
		
		$display("--- Test 2: Refresh Rate Testing ---");
		
		// 60Hzモード測定
		reg_50hz_mode = 1'b0;
		#(clk_base * 100);
		
		cycle_count_60hz = 0;
		@(posedge intr_frame);
		@(posedge clk);
		while (!intr_frame) begin
			@(posedge clk);
			cycle_count_60hz = cycle_count_60hz + 1;
		end
		
		// 50Hzモード測定
		reg_50hz_mode = 1'b1;
		#(clk_base * 100);
		
		cycle_count_50hz = 0;
		@(posedge intr_frame);
		@(posedge clk);
		while (!intr_frame) begin
			@(posedge clk);
			cycle_count_50hz = cycle_count_50hz + 1;
		end
		
		$display("60Hz mode cycles: %0d", cycle_count_60hz);
		$display("50Hz mode cycles: %0d", cycle_count_50hz);
		$display("Refresh rate test completed");
		
		// 60Hzモードに戻す
		reg_50hz_mode = 1'b0;
	endtask

	// ----------------------------------------------------------------
	// テスト3: 割り込みライン設定の確認
	// ----------------------------------------------------------------
	task test_interrupt_line();
		$display("--- Test 3: Interrupt Line Testing ---");
		
		// 割り込みライン設定を変更してテスト
		reg_interrupt_line = 8'd100;
		#(clk_base * 100);
		
		// フレーム開始を待つ
		@(posedge intr_frame);
		
		// 指定ラインで割り込みが発生するかチェック
		@(posedge intr_line);
		if (screen_pos_y == reg_interrupt_line) begin
			$display("Interrupt line test PASSED: Line %0d", v_count);
		end else begin
			$display("Interrupt line test FAILED: Expected %0d, Got %0d", reg_interrupt_line, v_count);
		end
		
		// 割り込みライン設定を元に戻す
		reg_interrupt_line = 8'd192;
	endtask

	// ----------------------------------------------------------------
	// テスト4: オフセット設定の確認
	// ----------------------------------------------------------------
	task test_offset_settings();
		$display("--- Test 4: Offset Settings Testing ---");
		
		// 垂直オフセットテスト
		reg_vertical_offset = 8'd10;
		reg_horizontal_offset = 9'd20;
		
		#(clk_base * 1000);  // 少し待つ
		
		$display("Vertical offset: %0d", reg_vertical_offset);
		$display("Horizontal offset: %0d", reg_horizontal_offset);
		$display("Offset settings test completed");
		
		// オフセット設定を元に戻す
		reg_vertical_offset = 8'd0;
		reg_horizontal_offset = 9'd0;
	endtask

	// ----------------------------------------------------------------
	// テスト5: 画面モード切り替えの確認
	// ----------------------------------------------------------------
	task test_screen_modes();
		integer mode;
		
		$display("--- Test 5: Screen Mode Testing ---");
		
		// 各画面モードをテスト
		for (mode = 0; mode < 8; mode = mode + 1) begin
			case( mode )
			0:	reg_screen_mode = 5'b00001;	//	SCREEN0:WIDTH40
			1:	reg_screen_mode = 5'b01001;	//	SCREEN0:WIDTH80
			2:	reg_screen_mode = 5'b00000;	//	SCREEN1
			3:	reg_screen_mode = 5'b00100;	//	SCREEN2
			4:	reg_screen_mode = 5'b00010;	//	SCREEN3
			5:	reg_screen_mode = 5'b01000;	//	SCREEN4
			6:	reg_screen_mode = 5'b01100;	//	SCREEN5
			7:	reg_screen_mode = 5'b10000;	//	SCREEN6
			8:	reg_screen_mode = 5'b10100;	//	SCREEN7
			9:	reg_screen_mode = 5'b11100;	//	SCREEN8
			endcase
			#(clk_base * 100);
			$display( "Screen mode set [reg_screen_mode = %05b]", reg_screen_mode );
		end
		
		$display("Screen mode test completed");
		
		// 画面モードを0に戻す
		reg_screen_mode = 5'd0;
	endtask

	// ----------------------------------------------------------------
	// モニタリング用の表示（オプション）
	// ----------------------------------------------------------------
//	always @(posedge clk) begin
//		// 重要な状態変化をモニタ
//		if (intr_frame) begin
//			$display("Time: %0t - Frame interrupt detected at V=%0d", $time, screen_pos_y);
//		end
//		
//		if (intr_line) begin
//			$display("Time: %0t - Line interrupt detected at V=%0d", $time, screen_pos_y);
//		end
//	end

endmodule
