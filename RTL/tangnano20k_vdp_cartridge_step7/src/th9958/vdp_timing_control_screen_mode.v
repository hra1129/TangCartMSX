//
//	vdp_timing_control_screen_mode.v
//	Screen mode timing generator for Timing Control
//
//	Copyright (C) 2025 Takayuki Hara
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

module vdp_timing_control_screen_mode (
	input				reset_n,
	input				clk,					//	42.95454MHz

	input		[13:0]	screen_pos_x,
	input		[ 9:0]	screen_pos_y,
	input		[ 8:0]	pixel_pos_x,
	input		[ 7:0]	pixel_pos_y,
	output		[ 1:0]	pixel_phase_x,
	input				screen_v_active,

	output		[17:0]	vram_address,
	output				vram_valid,
	input		[31:0]	vram_rdata,
	output				vram_interleave,

	output		[7:0]	display_color,
	output				display_color_en,
	output				sprite_off,
	input				interleaving_page,
	input				blink,
	input				field,
	output		[9:0]	screen_mode,
	input		[2:0]	horizontal_offset_l,

	input		[4:0]	reg_screen_mode,
	input				reg_display_on,
	input		[17:10]	reg_pattern_name_table_base,
	input		[17:6]	reg_color_table_base,
	input		[17:11]	reg_pattern_generator_table_base,
	input		[7:0]	reg_text_back_color,
	input		[7:0]	reg_backdrop_color,
	input				reg_scroll_planes,
	input				reg_left_mask,
	input				reg_sprite_mode3,
	input				reg_flat_interlace_mode
);
	//	Screen mode
	localparam			c_mode_g1	= 5'b000_00;	//	Graphic1 (SCREEN1)
	localparam			c_mode_g2	= 5'b001_00;	//	Graphic2 (SCREEN2)
	localparam			c_mode_g3	= 5'b010_00;	//	Graphic3 (SCREEN4)
	localparam			c_mode_g4	= 5'b011_00;	//	Graphic4 (SCREEN5)
	localparam			c_mode_g5	= 5'b100_00;	//	Graphic5 (SCREEN6)
	localparam			c_mode_g6	= 5'b101_00;	//	Graphic6 (SCREEN7)
	localparam			c_mode_g7	= 5'b111_00;	//	Graphic7 (SCREEN8/10/11/12)
	localparam			c_mode_t1	= 5'b00x_01;	//	Text1    (SCREEN0:WIDTH40)
	localparam			c_mode_t2	= 5'b010_01;	//	Text2    (SCREEN0:WIDTH80)
	localparam			c_mode_gm	= 5'b00x_10;	//	Mosaic   (SCREEN3)
	wire		[9:0]	w_mode;
	reg			[9:0]	ff_mode;
	localparam			c_g1		= 0;			//	Graphic1 (SCREEN1) w_mode index
	localparam			c_g2		= 1;			//	Graphic2 (SCREEN2) w_mode index
	localparam			c_g3		= 2;			//	Graphic3 (SCREEN4) w_mode index
	localparam			c_g4		= 3;			//	Graphic4 (SCREEN5) w_mode index
	localparam			c_g5		= 4;			//	Graphic5 (SCREEN6) w_mode index
	localparam			c_g6		= 5;			//	Graphic6 (SCREEN7) w_mode index
	localparam			c_g7		= 6;			//	Graphic7 (SCREEN8) w_mode index
	localparam			c_t1		= 7;			//	Text1    (SCREEN0:WIDTH40) w_mode index
	localparam			c_t2		= 8;			//	Text2    (SCREEN0:WIDTH80) w_mode index
	localparam			c_gm		= 9;			//	Mosaic   (SCREEN3) w_mode index
	//	Phase
	reg			[2:0]	ff_phase;					//	0, 1, 2, ... , 5, 0 (6states) or 0, 1, 2, ... , 7, 0 (8states)
	wire		[3:0]	w_sub_phase;
	reg					ff_screen_h_in_active;
	wire				w_screen_in_active;
	wire		[7:0]	w_valid_decode;
	//	Position
	wire		[9:0]	w_scroll_pos_x;
	wire		[9:0]	w_pos_x;
	wire				w_scroll_page;
	wire				w_blink_page;
	reg			[5:0]	ff_pos_x;					//	Text width40 column position
	//	Pattern name table address
	wire		[10:0]	w_pattern_name_t12_pre;
	wire		[17:0]	w_pattern_name_t1;
	wire		[17:0]	w_pattern_name_t2;
	wire		[17:0]	w_pattern_name_g123m;
	wire		[17:0]	w_pattern_name_g45;
	wire		[17:0]	w_pattern_name_g67;
	wire		[17:0]	w_pattern_name_g45_fil;
	wire		[17:0]	w_pattern_name_g67_fil;
	reg			[7:0]	ff_next_vram0;
	reg			[7:0]	ff_next_vram1;
	reg			[7:0]	ff_next_vram2;
	reg			[7:0]	ff_next_vram3;
	reg			[7:0]	ff_next_vram4;
	reg			[7:0]	ff_next_vram5;
	reg			[7:0]	ff_next_vram6;
	reg			[7:0]	ff_next_vram7;
	//	Pattern generator table address
	wire		[17:0]	w_pattern_generator_g1;
	wire		[17:0]	w_pattern_generator_g23;
    wire        [17:0]  w_pattern_generator_t12;
    wire        [17:0]  w_pattern_generator_t2_2;
	//	Color table address
	wire		[17:0]	w_color_g1;
	wire		[17:0]	w_color_g23;
	wire		[17:0]	w_color_gm;
	wire		[17:0]	w_color_t2;
	wire		[1:0]	w_blink_pattern;
	wire		[1:0]	w_blink;
	//	VRAM address
	reg			[17:0]	ff_vram_address;
	reg					ff_vram_valid;
	//	Display color
	reg			[7:0]	ff_display_color;
	reg					ff_display_color_en;
	wire		[7:0]	w_backdrop_color;
	reg			[7:0]	ff_pattern0;
	reg			[7:0]	ff_pattern1;
	reg			[7:0]	ff_pattern2;
	reg			[7:0]	ff_pattern3;
	reg			[7:0]	ff_pattern4;
	reg			[7:0]	ff_pattern5;
	reg			[7:0]	ff_pattern6;
	reg			[7:0]	ff_pattern7;
	//	YJK
	reg			[4:0]	ff_y;
	reg			[5:0]	ff_j;
	reg			[5:0]	ff_k;
	reg					ff_vram_interleave;
	wire				w_left_mask;
	reg			[9:0]	ff_left_mask_pos;

	// --------------------------------------------------------------------
	//	Screen mode decoder
	// --------------------------------------------------------------------
	function [9:0] func_screen_mode_decoder(
		input	[4:0]	reg_screen_mode
	);
		casex( reg_screen_mode )
		c_mode_g1:		func_screen_mode_decoder = 10'b0000000001;
		c_mode_g2:		func_screen_mode_decoder = 10'b0000000010;
		c_mode_g3:		func_screen_mode_decoder = 10'b0000000100;
		c_mode_g4:		func_screen_mode_decoder = 10'b0000001000;
		c_mode_g5:		func_screen_mode_decoder = 10'b0000010000;
		c_mode_g6:		func_screen_mode_decoder = 10'b0000100000;
		c_mode_g7:		func_screen_mode_decoder = 10'b0001000000;
		c_mode_t1:		func_screen_mode_decoder = 10'b0010000000;
		c_mode_t2:		func_screen_mode_decoder = 10'b0100000000;
		c_mode_gm:		func_screen_mode_decoder = 10'b1000000000;
		default:		func_screen_mode_decoder = 10'b0000000000;
		endcase
	endfunction

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_vram_interleave <= 1'b0;
		end
		else begin
			ff_vram_interleave <= reg_sprite_mode3 ? 1'b0 : (ff_mode[c_g6] || ff_mode[c_g7]);
		end
	end

	always @( posedge clk ) begin
		ff_mode				<= w_mode;
		ff_left_mask_pos	<= (w_mode[c_t1] || w_mode[c_t2]) ? 10'd21: 10'd13;
	end

	assign w_mode				= func_screen_mode_decoder( reg_screen_mode );
	assign screen_mode			= ff_mode;
	assign sprite_off			= (ff_mode[c_t1] || ff_mode[c_t2]);
	assign vram_interleave		= ff_vram_interleave;

	// --------------------------------------------------------------------
	//	Screen Position for active area
	// --------------------------------------------------------------------
	assign w_sub_phase			= screen_pos_x[3:0];
	assign w_scroll_pos_x		= screen_pos_x[13:4]              - { 7'd0, horizontal_offset_l };
	assign w_pos_x				= { pixel_pos_x[8], pixel_pos_x } - { 7'd0, horizontal_offset_l };
	assign w_scroll_page		= ( reg_scroll_planes && reg_pattern_name_table_base[15] ) ? w_pos_x[8]: reg_pattern_name_table_base[15];
	assign w_blink_page			= w_scroll_page & interleaving_page;
	assign pixel_phase_x		= w_scroll_pos_x[1:0];

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_phase <= 3'd0;
		end
		else if( w_sub_phase == 4'd15 ) begin
			if( ff_mode[c_t1] || ff_mode[c_t2] ) begin
				if( ff_phase == 3'd5 || w_scroll_pos_x == 10'd7 ) begin
					ff_phase <= 3'd0;
				end
				else begin
					ff_phase <= ff_phase + 3'd1;
				end
			end
			else begin
				if( w_scroll_pos_x == 10'h3FF ) begin
					ff_phase <= 3'd0;
				end
				else begin
					ff_phase <= ff_phase + 3'd1;
				end
			end
		end
	end

	//	SCREEN0 character position
	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_pos_x <= 6'd0;
		end
		else if( w_scroll_pos_x == 10'd7 && w_sub_phase == 4'd15 ) begin
			ff_pos_x <= 6'd0;
		end
		else if( ff_phase == 3'd5 && w_sub_phase == 4'd15 ) begin
			ff_pos_x <= ff_pos_x + 6'd1;
		end
	end

	// --------------------------------------------------------------------
	//	Active period
	// --------------------------------------------------------------------
	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_screen_h_in_active <= 1'b0;
		end
		else if( ff_mode[c_t1] || ff_mode[c_t2] ) begin
			if( screen_pos_x[13:4] == 10'd252 && w_sub_phase == 4'd15 ) begin
				ff_screen_h_in_active <= 1'b0;
			end
			else if( w_scroll_pos_x == 10'd7 && w_sub_phase == 4'd15 ) begin
				ff_screen_h_in_active <= 1'b1;
			end
		end
		else begin
			if( screen_pos_x[13:4] == 10'd260 && w_sub_phase == 4'd15 ) begin
				ff_screen_h_in_active <= 1'b0;
			end
			else if( w_scroll_pos_x == 10'h3FF && w_sub_phase == 4'd15 ) begin
				ff_screen_h_in_active <= 1'b1;
			end
		end
	end

	assign w_screen_in_active	= screen_v_active & ff_screen_h_in_active;

	// --------------------------------------------------------------------
	//	Pattern name table address
	// --------------------------------------------------------------------
	assign w_pattern_name_g123m			= { reg_pattern_name_table_base, pixel_pos_y[7:3], w_pos_x[7:3] };
	assign w_pattern_name_g45			= { reg_pattern_name_table_base[17:16], w_blink_page, (reg_pattern_name_table_base[14:10] & pixel_pos_y[7:3]), pixel_pos_y[2:0], w_pos_x[7:3], 2'd0 };
	assign w_pattern_name_g67			= { reg_pattern_name_table_base[16]   , w_blink_page, (reg_pattern_name_table_base[14:10] & pixel_pos_y[7:3]), pixel_pos_y[2:0], w_pos_x[7:3], 3'd0 };
	assign w_pattern_name_t12_pre		= { 1'b0, screen_pos_y[7:3], 5'd0 } + { 3'd0, screen_pos_y[7:3], 3'd0 } + { 5'd0, ff_pos_x };
	assign w_pattern_name_t1			= { reg_pattern_name_table_base, w_pattern_name_t12_pre[9:0] };
	assign w_pattern_name_t2			= { reg_pattern_name_table_base[17:12], (reg_pattern_name_table_base[11:10] & w_pattern_name_t12_pre[10:9]), w_pattern_name_t12_pre[8:0], 1'b0 };

	assign w_pattern_name_g45_fil		= { reg_pattern_name_table_base[17:16], (reg_pattern_name_table_base[15:10] & pixel_pos_y[7:2]), pixel_pos_y[1:0], field, w_pos_x[7:3], 2'd0 };
	assign w_pattern_name_g67_fil		= { reg_pattern_name_table_base[16]   , (reg_pattern_name_table_base[15:10] & pixel_pos_y[7:2]), pixel_pos_y[1:0], field, w_pos_x[7:3], 3'd0 };

	// --------------------------------------------------------------------
	//	Pattern generator table address
	// --------------------------------------------------------------------
	assign w_pattern_generator_g1		= { reg_pattern_generator_table_base, ff_next_vram0, pixel_pos_y[2:0] };
	assign w_pattern_generator_g23		= { reg_pattern_generator_table_base[17:13], (pixel_pos_y[7:6] & reg_pattern_generator_table_base[12:11]), ff_next_vram0, pixel_pos_y[2:0] };
	assign w_pattern_generator_t12		= { reg_pattern_generator_table_base, ff_next_vram0, pixel_pos_y[2:0] };
	assign w_pattern_generator_t2_2		= { reg_pattern_generator_table_base, ff_next_vram4, pixel_pos_y[2:0] };

	// --------------------------------------------------------------------
	//	Color table address
	// --------------------------------------------------------------------
	assign w_color_g1					= { reg_color_table_base, 1'b0, ff_next_vram0[7:3] };
	assign w_color_g23					= { reg_color_table_base[17:13], (pixel_pos_y[7:6] & reg_color_table_base[12:11]), (ff_next_vram0[7:3] & reg_color_table_base[10:6]), ff_next_vram0[2:0], pixel_pos_y[2:0] };
	assign w_color_gm					= { reg_pattern_generator_table_base, ff_next_vram0, pixel_pos_y[4:2] };
	assign w_color_t2					= { reg_color_table_base[17:9], (reg_color_table_base[8:6] & w_pattern_name_t12_pre[10:8]), w_pattern_name_t12_pre[7:3] };

	// --------------------------------------------------------------------
	//	VRAM read access request
	// --------------------------------------------------------------------
	function [7:0] func_valid_decoder(
		input	[9:0]	mode
	);
		if( mode[c_t1] ) begin
			func_valid_decoder = 8'b00000011;
		end
		else if( mode[c_t2] ) begin
			func_valid_decoder = 8'b00001111;
		end
		else if( mode[c_g1] || mode[c_g2] || mode[c_g3] ||  mode[c_gm] ) begin
			func_valid_decoder = 8'b00001011;			//	※bit2, bit4 は 0 でなければならない, Sprite用
		end
		else if( mode[c_g4] || mode[c_g5] ) begin
			func_valid_decoder = 8'b00000001;			//	※bit2, bit4 は 0 でなければならない, Sprite用
		end
		else if( mode[c_g6] || mode[c_g7] ) begin
			func_valid_decoder = 8'b00000011;			//	※bit2, bit4 は 0 でなければならない, Sprite用
		end
		else begin
			func_valid_decoder = 8'b00000000;
		end
	endfunction

	assign w_valid_decode	= func_valid_decoder( ff_mode );

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_vram_valid <= 1'b0;
		end
		else if( !w_screen_in_active || !reg_display_on ) begin
			ff_vram_valid <= 1'b0;
		end
		else if( w_sub_phase == 4'd0 ) begin
			ff_vram_valid <= w_valid_decode[ ff_phase ];
		end
		else begin
			ff_vram_valid <= 1'b0;
		end
	end

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_vram_address <= 18'd0;
		end
		else begin
			//	SUB_PHASE:0 is VRAM read access timing.
			if( w_sub_phase == 4'd0 ) begin
				case( ff_phase )
				3'd0:
					//	パターンネームテーブルのアドレスを読む
					if( ff_mode[c_g1] || ff_mode[c_g2] || ff_mode[c_g3] || ff_mode[c_gm] ) begin
						ff_vram_address <= w_pattern_name_g123m;		//	PCG#
					end
					else if( ff_mode[c_g4] || ff_mode[c_g5] ) begin
						ff_vram_address <= reg_flat_interlace_mode ? w_pattern_name_g45_fil: w_pattern_name_g45;			//	Bitmap pixels
					end
					else if( ff_mode[c_g6] || ff_mode[c_g7] ) begin
						ff_vram_address <= reg_flat_interlace_mode ? w_pattern_name_g67_fil: w_pattern_name_g67;			//	Bitmap pixels
					end
					else if( ff_mode[c_t1] ) begin
						ff_vram_address <= w_pattern_name_t1;			//	PCG#
					end
					else if( ff_mode[c_t2] ) begin
						ff_vram_address <= w_pattern_name_t2;			//	PCG#
					end
					else begin
						ff_vram_address <= 18'd0;
					end
				3'd1:
					if( ff_mode[c_t1] || ff_mode[c_t2] ) begin
						//	PCGのドットパターンを読む
						ff_vram_address <= w_pattern_generator_t12;
					end
					else if( ff_mode[c_g1] ) begin
						//	PCGのドットパターンを読む
						ff_vram_address <= w_pattern_generator_g1;
					end
					else if( ff_mode[c_g2] || ff_mode[c_g3] ) begin
						//	PCGのドットパターンを読む
						ff_vram_address <= w_pattern_generator_g23;
					end
					else if( ff_mode[c_g6] || ff_mode[c_g7] ) begin
						//	Bitmap Pixels
						if( ff_vram_interleave ) begin
							ff_vram_address <= reg_flat_interlace_mode ? { w_pattern_name_g67_fil[17:3], 3'd1 } : { w_pattern_name_g67[17:3], 3'd1 };
						end
						else begin
							ff_vram_address <= reg_flat_interlace_mode ? { w_pattern_name_g67_fil[17:3], 3'd4 } : { w_pattern_name_g67[17:3], 3'd4 };
						end
					end
					else begin
						ff_vram_address <= 18'd0;
					end
				3'd2:
					if( ff_mode[c_t2] ) begin
						//	PCGのドットパターンを読む(2つ目)
						ff_vram_address <= w_pattern_generator_t2_2;
					end
					else begin
						ff_vram_address <= 18'd0;
					end
				3'd3:
					if( ff_mode[c_t2] ) begin
						//	ブリンク情報を読む
						ff_vram_address <= w_color_t2;
					end
					else if( ff_mode[c_g1] ) begin
						//	色情報を読む
						ff_vram_address <= w_color_g1;
					end
					else if( ff_mode[c_g2] || ff_mode[c_g3] ) begin
						//	色情報を読む
						ff_vram_address <= w_color_g23;
					end
					else if( ff_mode[c_gm] ) begin
						//	色情報を読む
						ff_vram_address <= w_color_gm;
					end
					else begin
						ff_vram_address <= 18'd0;
					end
				default:
					ff_vram_address <= 18'd0;
				endcase
			end
		end
	end

	assign vram_address = ff_vram_address;
	assign vram_valid = ff_vram_valid;

	// --------------------------------------------------------------------
	//	VRAM read data latch
	// --------------------------------------------------------------------
	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_next_vram0 <= 8'd0;
			ff_next_vram1 <= 8'd0;
			ff_next_vram2 <= 8'd0;
			ff_next_vram3 <= 8'd0;
			ff_next_vram4 <= 8'd0;
			ff_next_vram5 <= 8'd0;
			ff_next_vram6 <= 8'd0;
			ff_next_vram7 <= 8'd0;
		end
		else begin
			if( w_sub_phase == 4'd12 ) begin
				case( ff_phase )
				3'd0:
					//	Pattern Name Table
					if( ff_mode[c_g1] || ff_mode[c_g2] || ff_mode[c_g3] || ff_mode[c_gm] || ff_mode[c_t1] ) begin
						//	SCREEN1, 2, 3, 4, 0(W40) では、PCG の番号を保持する
						case( ff_vram_address[1:0] )
						2'd0:	ff_next_vram0 <= vram_rdata[ 7: 0];
						2'd1:	ff_next_vram0 <= vram_rdata[15: 8];
						2'd2:	ff_next_vram0 <= vram_rdata[23:16];
						2'd3:	ff_next_vram0 <= vram_rdata[31:24];
						endcase
					end
					else if( ff_mode[c_t2] ) begin
						//	SCREEN0, 0(W80) では、PCG の番号を 2つ保持する
						case( ff_vram_address[1] )
						1'd0:
							begin
								ff_next_vram0 <= vram_rdata[ 7: 0];
								ff_next_vram4 <= vram_rdata[15: 8];
							end
						1'd1:
							begin
								ff_next_vram0 <= vram_rdata[23:16];
								ff_next_vram4 <= vram_rdata[31:24];
							end
						endcase
					end
					else if( ff_mode[c_g4] || ff_mode[c_g5] ) begin
						//	SCREEN5, 6 では、この1回の読み出しで 8ドット分の画素値を一気に読める
						ff_next_vram0 <= { 4'd0, vram_rdata[ 7: 4] };
						ff_next_vram1 <= { 4'd0, vram_rdata[ 3: 0] };
						ff_next_vram2 <= { 4'd0, vram_rdata[15:12] };
						ff_next_vram3 <= { 4'd0, vram_rdata[11: 8] };
						ff_next_vram4 <= { 4'd0, vram_rdata[23:20] };
						ff_next_vram5 <= { 4'd0, vram_rdata[19:16] };
						ff_next_vram6 <= { 4'd0, vram_rdata[31:28] };
						ff_next_vram7 <= { 4'd0, vram_rdata[27:24] };
					end
					else if( ff_mode[c_g6] || ff_mode[c_g7] ) begin
						//	SCREEN7, 8 では、この1回の読み出しで 前半4ドット分の画素値を一気に読める
						if( ff_vram_interleave ) begin
							ff_next_vram0 <= vram_rdata[ 7: 0];
							ff_next_vram2 <= vram_rdata[15: 8];
							ff_next_vram4 <= vram_rdata[23:16];
							ff_next_vram6 <= vram_rdata[31:24];
						end
						else begin
							ff_next_vram0 <= vram_rdata[ 7: 0];
							ff_next_vram1 <= vram_rdata[15: 8];
							ff_next_vram2 <= vram_rdata[23:16];
							ff_next_vram3 <= vram_rdata[31:24];
						end
					end
				3'd1:
					if( ff_mode[c_g1] || ff_mode[c_g2] || ff_mode[c_g3] || ff_mode[c_t1] || ff_mode[c_t2] ) begin
						//	SCREEN1, 2, 4, 0(W40), 0(W80) では、ドットパターンを保持する。
						case( ff_vram_address[1:0] )
						2'd0:	ff_next_vram1 <= vram_rdata[ 7: 0];
						2'd1:	ff_next_vram1 <= vram_rdata[15: 8];
						2'd2:	ff_next_vram1 <= vram_rdata[23:16];
						2'd3:	ff_next_vram1 <= vram_rdata[31:24];
						endcase
					end
					else if( ff_mode[c_g6] || ff_mode[c_g7] ) begin
						//	SCREEN7, 8 では、この1回の読み出しで 後半4ドット分の画素値を一気に読める
						if( ff_vram_interleave ) begin
							ff_next_vram1 <= vram_rdata[ 7: 0];
							ff_next_vram3 <= vram_rdata[15: 8];
							ff_next_vram5 <= vram_rdata[23:16];
							ff_next_vram7 <= vram_rdata[31:24];
						end
						else begin
							ff_next_vram4 <= vram_rdata[ 7: 0];
							ff_next_vram5 <= vram_rdata[15: 8];
							ff_next_vram6 <= vram_rdata[23:16];
							ff_next_vram7 <= vram_rdata[31:24];
						end
					end
					else begin
						//	none
					end
				3'd2:
					if( ff_mode[c_t2] ) begin
						//	SCREEN0(W80) の、２つ目のドットパターンを保持する。
						case( ff_vram_address[1:0] )
						2'd0:	ff_next_vram5 <= vram_rdata[ 7: 0];
						2'd1:	ff_next_vram5 <= vram_rdata[15: 8];
						2'd2:	ff_next_vram5 <= vram_rdata[23:16];
						2'd3:	ff_next_vram5 <= vram_rdata[31:24];
						endcase
					end
					else begin
						//	none
					end
				3'd3:
					if( ff_mode[c_g1] || ff_mode[c_g2] || ff_mode[c_g3] || ff_mode[c_gm] || ff_mode[c_t2] ) begin
						//	SCREEN1, 2, 4 では、色を保持する。
						case( ff_vram_address[1:0] )
						2'd0:	ff_next_vram2 <= vram_rdata[ 7: 0];
						2'd1:	ff_next_vram2 <= vram_rdata[15: 8];
						2'd2:	ff_next_vram2 <= vram_rdata[23:16];
						2'd3:	ff_next_vram2 <= vram_rdata[31:24];
						endcase
					end
					else if( ff_mode[c_t1] ) begin
						//	SCREEN0(W40) では、色はレジスタから引っ張ってくる。
						ff_next_vram2 <= reg_backdrop_color;
					end
				3'd4:
					if( ff_mode[c_t2] ) begin
						ff_next_vram2 <= w_blink[1] ? reg_text_back_color: reg_backdrop_color;
						ff_next_vram3 <= w_blink[0] ? reg_text_back_color: reg_backdrop_color;
					end
				default: begin
					//	hold
				end
				endcase
			end
		end
	end

	assign w_blink_pattern	= (ff_pos_x[1:0] == 2'd0) ? ff_next_vram2[7:6]:
	                      	  (ff_pos_x[1:0] == 2'd0) ? ff_next_vram2[5:4]:
	                      	  (ff_pos_x[1:0] == 2'd0) ? ff_next_vram2[3:2]: ff_next_vram2[1:0];
	assign w_blink			= blink ? w_blink_pattern: 2'b00;

	// --------------------------------------------------------------------
	//	Display color generate
	// --------------------------------------------------------------------
	assign w_backdrop_color	= ( ff_mode[c_g7] ) ? reg_backdrop_color: { reg_backdrop_color[3:0], reg_backdrop_color[3:0] };

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_pattern0 <= 8'd0;
			ff_pattern1 <= 8'd0;
			ff_pattern2 <= 8'd0;
			ff_pattern3 <= 8'd0;
			ff_pattern4 <= 8'd0;
			ff_pattern5 <= 8'd0;
			ff_pattern6 <= 8'd0;
			ff_pattern7 <= 8'd0;
		end
		else if( w_sub_phase == 4'd11 ) begin
			if( !w_screen_in_active ) begin
				ff_pattern0 <= w_backdrop_color;
				ff_pattern1 <= w_backdrop_color;
				ff_pattern2 <= w_backdrop_color;
				ff_pattern3 <= w_backdrop_color;
				ff_pattern4 <= w_backdrop_color;
				ff_pattern5 <= w_backdrop_color;
				ff_pattern6 <= w_backdrop_color;
				ff_pattern7 <= w_backdrop_color;
			end
			else if( ff_phase == 3'd5 ) begin
				if( ff_mode[c_g1] || ff_mode[c_g2] || ff_mode[c_g3] || ff_mode[c_t1] ) begin
					//	SCREEN 1, 2, 4, 0(W40) bit pattern --> color code
					ff_pattern0 <= ff_next_vram1[7] ? { 4'd0, ff_next_vram2[ 7: 4] }: { 4'd0, ff_next_vram2[ 3: 0] };
					ff_pattern1 <= ff_next_vram1[6] ? { 4'd0, ff_next_vram2[ 7: 4] }: { 4'd0, ff_next_vram2[ 3: 0] };
					ff_pattern2 <= ff_next_vram1[5] ? { 4'd0, ff_next_vram2[ 7: 4] }: { 4'd0, ff_next_vram2[ 3: 0] };
					ff_pattern3 <= ff_next_vram1[4] ? { 4'd0, ff_next_vram2[ 7: 4] }: { 4'd0, ff_next_vram2[ 3: 0] };
					ff_pattern4 <= ff_next_vram1[3] ? { 4'd0, ff_next_vram2[ 7: 4] }: { 4'd0, ff_next_vram2[ 3: 0] };
					ff_pattern5 <= ff_next_vram1[2] ? { 4'd0, ff_next_vram2[ 7: 4] }: { 4'd0, ff_next_vram2[ 3: 0] };
					ff_pattern6 <= ff_next_vram1[1] ? { 4'd0, ff_next_vram2[ 7: 4] }: { 4'd0, ff_next_vram2[ 3: 0] };
					ff_pattern7 <= ff_next_vram1[0] ? { 4'd0, ff_next_vram2[ 7: 4] }: { 4'd0, ff_next_vram2[ 3: 0] };
				end
				else if( ff_mode[c_t2] ) begin
					//	SCREEN 0(W80) bit pattern --> color code
					ff_pattern0 <= { ff_next_vram1[7] ? { ff_next_vram2[ 7: 4] }: { ff_next_vram2[ 3: 0] }, ff_next_vram1[6] ? { ff_next_vram2[ 7: 4] }: { ff_next_vram2[ 3: 0] } };
					ff_pattern1 <= { ff_next_vram1[5] ? { ff_next_vram2[ 7: 4] }: { ff_next_vram2[ 3: 0] }, ff_next_vram1[4] ? { ff_next_vram2[ 7: 4] }: { ff_next_vram2[ 3: 0] } };
					ff_pattern2 <= { ff_next_vram1[3] ? { ff_next_vram2[ 7: 4] }: { ff_next_vram2[ 3: 0] }, ff_next_vram1[2] ? { ff_next_vram2[ 7: 4] }: { ff_next_vram2[ 3: 0] } };
					ff_pattern3 <= { ff_next_vram5[7] ? { ff_next_vram3[ 7: 4] }: { ff_next_vram3[ 3: 0] }, ff_next_vram5[6] ? { ff_next_vram3[ 7: 4] }: { ff_next_vram3[ 3: 0] } };
					ff_pattern4 <= { ff_next_vram5[5] ? { ff_next_vram3[ 7: 4] }: { ff_next_vram3[ 3: 0] }, ff_next_vram5[4] ? { ff_next_vram3[ 7: 4] }: { ff_next_vram3[ 3: 0] } };
					ff_pattern5 <= { ff_next_vram5[3] ? { ff_next_vram3[ 7: 4] }: { ff_next_vram3[ 3: 0] }, ff_next_vram5[2] ? { ff_next_vram3[ 7: 4] }: { ff_next_vram3[ 3: 0] } };
					ff_pattern6 <= w_backdrop_color;
					ff_pattern7 <= w_backdrop_color;
				end
				else if( ff_mode[c_gm] ) begin
					ff_pattern0 <= { 4'd0, ff_next_vram2[ 7: 4] };
					ff_pattern1 <= { 4'd0, ff_next_vram2[ 7: 4] };
					ff_pattern2 <= { 4'd0, ff_next_vram2[ 7: 4] };
					ff_pattern3 <= { 4'd0, ff_next_vram2[ 7: 4] };
					ff_pattern4 <= { 4'd0, ff_next_vram2[ 3: 0] };
					ff_pattern5 <= { 4'd0, ff_next_vram2[ 3: 0] };
					ff_pattern6 <= { 4'd0, ff_next_vram2[ 3: 0] };
					ff_pattern7 <= { 4'd0, ff_next_vram2[ 3: 0] };
				end
				else if( ff_mode[c_g4] || ff_mode[c_g5] || ff_mode[c_g6] || ff_mode[c_g7] ) begin
					ff_pattern0 <= ff_next_vram0;
					ff_pattern1 <= ff_next_vram1;
					ff_pattern2 <= ff_next_vram2;
					ff_pattern3 <= ff_next_vram3;
					ff_pattern4 <= ff_next_vram4;
					ff_pattern5 <= ff_next_vram5;
					ff_pattern6 <= ff_next_vram6;
					ff_pattern7 <= ff_next_vram7;
				end
			end
			else begin
				ff_pattern0 <= ff_pattern1;
				ff_pattern1 <= ff_pattern2;
				ff_pattern2 <= ff_pattern3;
				ff_pattern3 <= ff_pattern4;
				ff_pattern4 <= ff_pattern5;
				ff_pattern5 <= ff_pattern6;
				ff_pattern6 <= ff_pattern7;
				ff_pattern7 <= w_backdrop_color;
			end
		end
	end

	// --------------------------------------------------------------------
	//	Output pixel
	// --------------------------------------------------------------------
	assign w_left_mask		= (!reg_left_mask || (screen_pos_x[13:4] >= ff_left_mask_pos));

	always @( posedge clk ) begin
		if( w_sub_phase == 4'd7 ) begin
			if( ff_mode[c_t2] || ff_mode[c_g6] ) begin
				ff_display_color <= { 4'd0, ff_pattern0[3:0] };
				ff_display_color_en	= reg_display_on & w_left_mask;
			end
			else if( ff_mode[c_g5] ) begin
				ff_display_color <= { 4'd0, ff_pattern0[1:0] };
				ff_display_color_en	= reg_display_on & w_left_mask;
			end
			else begin
				//	hold
			end
		end
		else if( w_sub_phase == 4'd15 ) begin
			if( ff_mode[c_t2] || ff_mode[c_g6] ) begin
				ff_display_color <= { 4'd0, ff_pattern0[7:4] };
			end
			else if( ff_mode[c_g5] ) begin
				ff_display_color <= { 4'd0, ff_pattern0[3:2] };
			end
			else begin
				ff_display_color <= ff_pattern0;
			end
			ff_display_color_en	= reg_display_on & w_left_mask;
		end
		else begin
			//	hold
		end
	end

	//	phase 6 のタイミングが 8dot/state の起点
	assign display_color		= ff_display_color;
	assign display_color_en		= ff_display_color_en;
endmodule
