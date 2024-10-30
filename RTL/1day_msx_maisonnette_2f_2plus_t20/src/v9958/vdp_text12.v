//
//	vdp_text12.v
//	  Imprementation of Text Mode 1,2.
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

module vdp_text12 (
	input			clk							,
	input			reset						,
	input			enable						,

	input	[1:0]	dotstate					,
	input	[8:0]	dotcounterx					,
	input	[8:0]	dotcountery					,
	input	[8:0]	dotcounteryp				,

	input			vdpmodetext1				,
	input			vdpmodetext1q				,
	input			vdpmodetext2				,

	// registers
	input			reg_r1_bl_clks				,
	input	[7:0]	reg_r7_frame_col			,
	input	[7:0]	reg_r12_blink_mode			,
	input	[7:0]	reg_r13_blink_period		,

	input	[6:0]	reg_r2_pt_nam_addr			,
	input	[5:0]	reg_r4_pt_gen_addr			,
	input	[10:0]	reg_r10r3_col_addr			,
	//
	input	[7:0]	pramdat						,
	output	[16:0]	pramadr						,
	output			txvramreaden				,

	output	[3:0]	pcolorcode					
);
	reg				ff_tx_vram_read_en;
	reg				ff_tx_vram_read_en2;
	reg		[4:0]	ff_dot_counter24;
	reg				ff_tx_window_x;
	reg				ff_tx_prewindow_x;
	reg		[16:0]	ff_ramadr;

	wire	[16:0]	w_logical_vram_addr_nam;
	wire	[16:0]	w_logical_vram_addr_gen;
	wire	[16:0]	w_logical_vram_addr_col;

	wire	[11:0]	w_tx_char_counter;
	reg		[6:0]	ff_tx_char_counter_x;
	reg		[11:0]	ff_tx_char_counter_start_of_line;

	reg		[7:0]	ff_pattern_num;
	reg		[7:0]	ff_prepattern;
	reg		[7:0]	ff_preblink;
	reg		[7:0]	ff_pattern;
	reg		[7:0]	ff_blink;
	reg				ff_is_foreground;
	wire	[7:0]	w_tx_color;

	reg		[3:0]	ff_blink_clk_cnt;
	reg				ff_blink_state;
	reg		[3:0]	ff_blink_period_cnt;
	wire	[3:0]	w_blink_cnt_max;
	wire			w_blink_sync;

	// jp: ramは dotstateが 2'b10, 2'b00 の時にアドレスを出して 2'b01 でアクセスする。
	// jp: eightdotstateで見ると、
	// jp:	0-1		read ff_pattern num.
	// jp:	1-2		read ff_pattern
	// jp: となる。

	// --------------------------------------------------------------------
	//  color select
	// --------------------------------------------------------------------
	assign w_tx_char_counter		=	ff_tx_char_counter_start_of_line + ff_tx_char_counter_x;

	assign w_logical_vram_addr_nam	=	( vdpmodetext1 || vdpmodetext1q ) ? { reg_r2_pt_nam_addr, w_tx_char_counter[9:0] }:
										{ reg_r2_pt_nam_addr[6:2], w_tx_char_counter };

	assign w_logical_vram_addr_gen	=	{ reg_r4_pt_gen_addr, ff_pattern_num, dotcountery[2:0] };

	assign w_logical_vram_addr_col	=	{ reg_r10r3_col_addr[10:3], w_tx_char_counter[11:3] };

	assign txvramreaden				=	( vdpmodetext1 || vdpmodetext1q ) ? ff_tx_vram_read_en :
										( vdpmodetext2                  ) ? (ff_tx_vram_read_en | ff_tx_vram_read_en2) : 1'b0;

	assign w_tx_color				=	( vdpmodetext2 && ff_blink_state && ff_blink[7] ) ? reg_r12_blink_mode : reg_r7_frame_col;
	assign pcolorcode				=	( ff_tx_window_x &&  ff_is_foreground ) ? w_tx_color[7:4] :
										( ff_tx_window_x && !ff_is_foreground ) ? w_tx_color[3:0] :
										reg_r7_frame_col[3:0];

	// --------------------------------------------------------------------
	// timing generator
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( reset ) begin
			ff_dot_counter24 <= 5'd0;
		end
		else if( !enable ) begin
			// hold
		end
		else if( dotstate == 2'b10 ) begin
			if( dotcounterx == 12 ) begin
				// jp: dotcounterは 2'b10 のタイミングでは既にカウントアップしているので注意
				ff_dot_counter24 <= 5'd0;
			end
			else begin
				// the ff_dot_counter24[2:0] counts up 0 to 5,
				// and the ff_dot_counter24[4:3] counts up 0 to 3.
				if( ff_dot_counter24[2:0] == 3'b101 ) begin
					ff_dot_counter24[4:3] <= ff_dot_counter24[4:3] + 1;
					ff_dot_counter24[2:0] <= 3'b000;
				end
				else begin
					ff_dot_counter24[2:0] <= ff_dot_counter24[2:0] + 1;
				end
			end
		end
	end

	always @( posedge clk ) begin
		if( reset ) begin
			ff_tx_prewindow_x <= 1'b0;
		end
		else if( !enable ) begin
			// hold
		end
		else if( dotstate == 2'b10 ) begin
			if( dotcounterx == 12 ) begin
				ff_tx_prewindow_x <= 1'b1;
			end
			else if( dotcounterx == 240+12 ) begin
				ff_tx_prewindow_x <= 1'b0;
			end
		end
	end

	always @( posedge clk ) begin
		if( reset ) begin
			ff_tx_window_x <= 1'b0;
		end
		else if( !enable ) begin
			// hold
		end
		else if( dotstate == 2'b01 ) begin
			if( dotcounterx == 16 ) begin
				ff_tx_window_x <= 1'b1;
			end
			else if( dotcounterx == 240+16 ) begin
				ff_tx_window_x <= 1'b0;
			end
		end
	end

	// --------------------------------------------------------------------
	//
	// --------------------------------------------------------------------
	assign pramadr	= ff_ramadr;

	always @( posedge clk ) begin
		if( reset ) begin
			ff_pattern_num						<= 8'd0;
			ff_ramadr							<= 17'd0;
			ff_tx_vram_read_en					<= 1'b0;
			ff_tx_vram_read_en2					<= 1'b0;
			ff_tx_char_counter_x				<= 7'd0;
			ff_preblink							<= 8'd0;
			ff_tx_char_counter_start_of_line	<= 12'd0;
		end
		else if( !enable ) begin
			// hold
		end
		else begin
			case( dotstate )
			2'b11:
				begin
					if( ff_tx_prewindow_x ) begin
						// vram read address output.
						case( ff_dot_counter24[2:0] )
						3'b000:
							begin
								if( ff_dot_counter24[4:3] == 2'b00 ) begin
									// read color table(text2 ff_blink)
									// it is used only one time per 8 characters.
									ff_ramadr <= w_logical_vram_addr_col;
									ff_tx_vram_read_en2 <= 1'b1;
								end
							end
						3'b001:
							begin
								// read ff_pattern name table
								ff_ramadr <= w_logical_vram_addr_nam;
								ff_tx_vram_read_en <= 1'b1;
								ff_tx_char_counter_x <= ff_tx_char_counter_x + 1;
							end
						3'b010:
							begin
								// read ff_pattern generator table
								ff_ramadr <= w_logical_vram_addr_gen;
								ff_tx_vram_read_en <= 1'b1;
							end
						3'b100:
							begin
								// read ff_pattern name table
								// it is used if vdpmode is test2.
								ff_ramadr <= w_logical_vram_addr_nam;
								ff_tx_vram_read_en2 <= 1'b1;
								if( vdpmodetext2 ) begin
									ff_tx_char_counter_x <= ff_tx_char_counter_x + 1;
								end
							end
						3'b101:
							begin
								// read ff_pattern generator table
								// it is used if vdpmode is test2.
								ff_ramadr <= w_logical_vram_addr_gen;
								ff_tx_vram_read_en2 <= 1'b1;
							end
						default:
							begin
								//	hold
							end
						endcase
					end
				end
			2'b10:
				begin
					ff_tx_vram_read_en <= 1'b0;
					ff_tx_vram_read_en2 <= 1'b0;
				end
			2'b00:
				begin
					if( dotcounterx == 11) begin
						ff_tx_char_counter_x <= 7'd0;
						if( dotcounteryp == 0 )	begin
							ff_tx_char_counter_start_of_line <= 12'd0;
						end
					end
					else if( (dotcounterx == 240+11) && (dotcounteryp[2:0] == 3'b111) ) begin
						ff_tx_char_counter_start_of_line <= ff_tx_char_counter_start_of_line + ff_tx_char_counter_x;
					end
				end
			2'b01:
				begin
					case( ff_dot_counter24[2:0] )
					3'b001:
						begin
							// read color table(text2 ff_blink)
							// it is used only one time per 8 characters.
							if( ff_dot_counter24[4:3] == 2'b00 ) begin
								ff_preblink <= pramdat;
							end
						end
					3'b010:
						// read ff_pattern name table
						ff_pattern_num <= pramdat;
					3'b011:
						// read ff_pattern generator table
						ff_prepattern <= pramdat;
					3'b101:
						// read ff_pattern name table
						// it is used if vdpmode is test2.
						ff_pattern_num <= pramdat;
					3'b000:
						begin
							// read ff_pattern generator table
							// it is used if vdpmode is test2.
							if( vdpmodetext2 ) begin
								ff_prepattern <= pramdat;
							end
						end
					default:
						begin
							//	hold
						end
					endcase
				end
			default:
				begin
					//	hold
				end
			endcase
		end
	end

	// --------------------------------------------------------------------
	//
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		// color code decision
		// jp: 2'b01 と 2'b10 のタイミングでかラーコードを出力してあげれば、
		// jp: vdpエンティティの方でパレットをデコードして色を出力してくれる。
		// jp: 2'b01 と 2'b10 で同じ色を出力すれば横256ドットになり、違う色を
		// jp: 出力すれば横512ドット表示となる。
		if( reset ) begin
			ff_pattern			<= 8'd0;
			ff_is_foreground	<= 1'b0;
			ff_blink			<= 8'b0;
		end
		else if( !enable ) begin
			// hold
		end
		else begin
			case( dotstate )
			2'b00:
				begin
					if( ff_dot_counter24[2:0] == 3'b100 ) begin
						// load next 8 dot data
						// jp: キャラクタの描画は ff_dot_counter24が、
						// jp:	 "0:4"から"1:3"の6ドット
						// jp:	 "1:4"から"2:3"の6ドット
						// jp:	 "2:4"から"3:3"の6ドット
						// jp:	 "3:4"から"0:3"の6ドット
						// jp: で行われるので 3'b100 のタイミングでロードする
						ff_pattern <= ff_prepattern;
					end
					else if( (ff_dot_counter24[2:0] == 3'b001) && (vdpmodetext2 == 1'b1) ) begin
						// jp: text2では 3'b001 のタイミングでもロードする。
						ff_pattern <= ff_prepattern;
					end

					if( (ff_dot_counter24[2:0] == 3'b100) || (ff_dot_counter24[2:0] == 3'b001) ) begin
						// evaluate ff_blink signal
						if( ff_dot_counter24 == 5'b00100 ) begin
							ff_blink <= ff_preblink;
						end
						else begin
							ff_blink <= { ff_blink[6:0], 1'b0 };
						end
					end
				end
			2'b01:
				begin
					// パターンに応じてカラーコードを決定
					ff_is_foreground <= ff_pattern[7];
					// パターンをシフト
					ff_pattern <= { ff_pattern[6:0], 1'b0 };
				end
			2'b11:
				begin
					//	hold
				end
			2'b10:
				begin
					if( vdpmodetext2 ) begin
						ff_is_foreground <= ff_pattern[7];
						// パターンをシフト
						ff_pattern <= { ff_pattern[6:0], 1'b0 };
					end
				end
			default:
				begin
					//	hold
				end
			endcase
		end
	end

	// --------------------------------------------------------------------
	// ff_blink timing generation fixed by caro and t.hara
	// --------------------------------------------------------------------
	assign w_blink_cnt_max	=	( !ff_blink_state ) ? reg_r13_blink_period[3:0]: reg_r13_blink_period[7:4];
	assign w_blink_sync		=	( (dotcounterx == 0) && (dotcounteryp == 0) && (dotstate == 2'b00) && (!reg_r1_bl_clks) ) ? 1'b1:
								( (dotcounterx == 0) &&                        (dotstate == 2'b00) &&   reg_r1_bl_clks  ) ? 1'b1: 1'b0;

	always @( posedge clk ) begin
		if( reset ) begin
			ff_blink_state <= 1'b0;
		end
		else if( !enable ) begin
			// hold
		end
		else if( w_blink_sync ) begin
			if( ff_blink_period_cnt >= w_blink_cnt_max ) begin
				if( reg_r13_blink_period[7:4] == 4'b0000 ) begin
					 // when on period is 0, the page selected should be always odd / r#2
					 ff_blink_state <= 1'b0;
				end
				else if( reg_r13_blink_period[3:0] == 4'b0000 ) begin
					 // when off period is 0 and on not, the page select should be always the r#2 even pair
					 ff_blink_state <= 1'b1;
				end
				else begin
					 // neither are 0, so just keep switching when period ends
					 ff_blink_state <= ~ff_blink_state;
				end
			end
		end
	end

	always @( posedge clk ) begin
		if( reset ) begin
			ff_blink_clk_cnt <= 4'd0;
		end
		else if( !enable ) begin
			// hold
		end
		else if( w_blink_sync ) begin
			if(ff_blink_clk_cnt == 4'd9 ) begin
				ff_blink_clk_cnt <= 4'd0;
			end
			else begin
				ff_blink_clk_cnt <= ff_blink_clk_cnt + 1;
			end
		end
	end

	always @( posedge clk ) begin
		if( reset ) begin
			ff_blink_period_cnt <= 4'd0;
		end
		else if( !enable ) begin
			// hold
		end
		else if( w_blink_sync ) begin
			if( ff_blink_period_cnt >= w_blink_cnt_max ) begin
				ff_blink_period_cnt <= 4'd0;
			end
			else if(ff_blink_clk_cnt == 4'd9 ) begin
				ff_blink_period_cnt <= ff_blink_period_cnt + 1;
			end
			else begin
				//	hold
			end
		end
	end
endmodule
