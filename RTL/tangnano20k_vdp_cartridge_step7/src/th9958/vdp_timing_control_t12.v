//
//	vdp_timing_control_t12.v
//	Text 1 and 2 mode timing generator for Timing Control
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

module vdp_timing_control_t12 (
	input				reset_n,
	input				clk,					//	42.95454MHz

	input		[12:0]	screen_pos_x,
	input		[ 9:0]	screen_pos_y,
	input		[ 2:0]	pixel_pos_y,
	input				screen_v_active,

	output		[16:0]	vram_address,
	output				vram_valid,
	input		[7:0]	vram_rdata,

	output		[3:0]	display_color,

	input		[2:0]	horizontal_offset_l,
	input		[4:0]	reg_screen_mode,
	input				reg_display_on,
	input		[16:10]	reg_pattern_name_table_base,
	input		[16:6]	reg_color_table_base,
	input		[16:11]	reg_pattern_generator_table_base,
	input		[7:0]	reg_backdrop_color
);
	//	Screen mode
	localparam			c_mode_t1	= 5'b000_01;	//	Text1 (SCREEN0:WIDTH40)
	localparam			c_mode_t1q	= 5'b001_01;	//	Text1 (SCREEN0:WIDTH40)
	localparam			c_mode_t2	= 5'b010_01;	//	Text2 (SCREEN0:WIDTH80)
	wire		[1:0]	w_mode;
	localparam			c_t1		= 0;			//	Text1 (SCREEN0:WIDTH40) w_mode index
	localparam			c_t2		= 1;			//	Text2 (SCREEN0:WIDTH80) w_mode index
	//	Phase
	reg			[2:0]	ff_phase;					//	0, 1, 2, ... , 5, 0 ... 6states
	wire		[2:0]	w_sub_phase;
	//	Position
	reg			[5:0]	ff_pos_x;
	reg			[7:0]	ff_pos_y;
	reg					ff_h_active;
	//	Pattern name table address
	wire		[10:0]	w_pre_pattern_name;
	wire		[16:0]	w_pattern_name;
	reg			[7:0]	ff_pattern_num0;
	reg			[7:0]	ff_pattern_num1;
	wire		[7:0]	w_pattern_num;
	//	Pattern generator table address
	wire		[16:0]	w_pattern_generator;
	reg			[5:0]	ff_next_pattern0;
	reg			[5:0]	ff_next_pattern1;
	reg			[5:0]	ff_pattern0;
	reg			[5:0]	ff_pattern1;
	//	Color table address
	wire		[16:0]	w_color;
	reg			[7:0]	ff_next_color0;
	reg			[7:0]	ff_next_color1;
	reg			[7:0]	ff_color;
	//	VRAM address
	reg			[16:0]	ff_vram_address;
	reg					ff_vram_valid;
	//	Display color
	reg			[3:0]	ff_display_color;
	wire		[9:0]	w_screen_pos_x;
	wire				w_line_start;
	reg					ff_screen_h_active;
	wire				w_screen_active;
	wire				w_t12_valid;
	wire				w_t2_valid;

	// --------------------------------------------------------------------
	//	★メモ
	//	垂直スクロールは、パターンジェネレータのアドレスにしか効かない。
	//	水平スクロールは、R#27 は効くが、R#26 は効かない。
	// --------------------------------------------------------------------

	// --------------------------------------------------------------------
	//	Screen mode decoder
	// --------------------------------------------------------------------
	function [1:0] func_screen_mode_decoder(
		input	[4:0]	reg_screen_mode
	);
		case( reg_screen_mode )
		c_mode_t1, c_mode_t1q:	func_screen_mode_decoder = 2'b01;
		c_mode_t2:				func_screen_mode_decoder = 2'b10;
		default:				func_screen_mode_decoder = 2'b00;
		endcase
	endfunction

	assign w_mode		= func_screen_mode_decoder( reg_screen_mode );

	// --------------------------------------------------------------------
	//	Screen Position for active area
	// --------------------------------------------------------------------
	assign w_screen_pos_x	= screen_pos_x[12:3] - { 7'd0, horizontal_offset_l };
	assign w_line_start		= (w_sub_phase == 3'd7 && w_screen_pos_x == 10'd7);

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_pos_x <= 6'd0;
		end
		else if( w_line_start ) begin
			ff_pos_x <= 6'd0;
		end
		else if( w_sub_phase == 3'd7 && ff_phase == 3'd5 ) begin
			ff_pos_x <= ff_pos_x + 6'd1;
		end
	end

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_pos_y <= 8'd0;
		end
		else if( w_line_start ) begin
			if( screen_pos_y == 10'h0 ) begin
				ff_pos_y <= 8'h0;
			end
			else begin
				ff_pos_y <= ff_pos_y + 8'd1;
			end
		end
	end

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_h_active <= 1'b0;
		end
		else if( w_line_start ) begin
			ff_h_active <= 1'b1;
		end
		else if( ff_pos_x == 6'd40 && ff_phase == 3'd5 ) begin
			ff_h_active <= 1'b0;
		end
	end

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_screen_h_active <= 1'b0;
		end
		else if( screen_pos_x[12:3] == 10'd251 && screen_pos_x[2:0] == 3'd7 ) begin
			ff_screen_h_active <= 1'b0;
		end
		else if( screen_pos_x[12:3] == 10'h3FF && screen_pos_x[2:0] == 3'd7 ) begin
			ff_screen_h_active <= 1'b1;
		end
	end

	assign w_screen_active	= screen_v_active & ff_screen_h_active;

	// --------------------------------------------------------------------
	//	Phase
	// --------------------------------------------------------------------
	assign w_sub_phase	= screen_pos_x[2:0];

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_phase <= 3'd0;
		end
		else if( w_line_start ) begin
			ff_phase <= 3'd0;
		end
		else if( w_sub_phase == 3'd7 ) begin
			if( ff_phase == 3'd5 ) begin
				ff_phase <= 3'd0;
			end
			else begin
				ff_phase <= ff_phase + 3'd1;
			end
		end
	end

	// --------------------------------------------------------------------
	//	Pattern name table address
	// --------------------------------------------------------------------
	                         			// (ff_pos_y >> 3) * 40 + ff_pos_x = (ff_pos_y >> 3) * (32 + 8) + ff_pos_x
	assign w_pre_pattern_name			= { 1'b0, ff_pos_y[7:3], 5'd0 } + { 3'd0, ff_pos_y[7:3], 3'd0 } + { 5'd0, ff_pos_x };
	assign w_pattern_name				= { reg_pattern_name_table_base, 8'd0 } + (w_mode[ c_t1 ] ? { 6'd0, w_pre_pattern_name }: { 5'd0, w_pre_pattern_name, 1'b0 });

	// --------------------------------------------------------------------
	//	Pattern generator table address
	// --------------------------------------------------------------------
	assign w_pattern_num				= ff_pattern_num0;	//ff_phase[0] ? ff_pattern_num1: ff_pattern_num0;
	assign w_pattern_generator			= { reg_pattern_generator_table_base, w_pattern_num, pixel_pos_y[2:0] };

	// --------------------------------------------------------------------
	//	Color table address
	// --------------------------------------------------------------------
	assign w_color						= { reg_color_table_base[16:9], 9'd0 } + (w_mode[ c_t1 ] ? { 6'd0, w_pre_pattern_name }: { 5'd0, w_pre_pattern_name, 1'b0 });

	// --------------------------------------------------------------------
	//	VRAM read access request
	// --------------------------------------------------------------------
	assign w_t12_valid		= w_screen_active & reg_display_on & (w_mode != 2'b00);
	assign w_t2_valid		= w_screen_active & reg_display_on & w_mode[ c_t2 ];

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_vram_address <= 17'd0;
			ff_vram_valid <= 1'b0;
		end
		else begin
			if( w_sub_phase == 3'd0 ) begin
				case( ff_phase )
				3'd0:
					if( w_screen_active && ff_h_active ) begin
						ff_vram_address <= w_t12_valid ? w_pattern_name: 17'd0;
						ff_vram_valid <= w_t12_valid;
					end
//				3'd1:
//					begin
//						ff_vram_address <= w_t2_valid ? { w_pattern_name[16:1], 1'b1 }: 17'd0;
//						ff_vram_valid <= w_t2_valid;
//					end
				3'd2:
					if( w_screen_active && ff_h_active ) begin
						ff_vram_address <= w_t12_valid ? w_pattern_generator: 17'd0;
						ff_vram_valid <= w_t12_valid;
					end
//				3'd3:
//					begin
//						ff_vram_address <= w_t2_valid ? w_pattern_generator: 17'd0;
//						ff_vram_valid <= w_t2_valid;
//					end
//				3'd4:
//					begin
//						ff_vram_address <= w_t2_valid ? w_color: 17'd0;
//						ff_vram_valid <= w_t2_valid;
//					end
//				3'd5:
//					begin
//						ff_vram_address <= w_t2_valid ? w_color: 17'd0;
//						ff_vram_valid <= w_t2_valid;
//					end
				default:
					begin
						ff_vram_address <= 17'd0;
						ff_vram_valid <= 1'b0;
					end
				endcase
			end
			else begin
				ff_vram_address <= 17'd0;
				ff_vram_valid <= 1'b0;
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
			ff_pattern_num0 <= 8'd0;
			ff_pattern_num1 <= 8'd0;
			ff_next_pattern0 <= 6'd0;
			ff_next_pattern1 <= 6'd0;
			ff_next_color0 <= 8'd0;
			ff_next_color1 <= 8'd0;
		end
		else begin
			if( w_sub_phase == 3'd0 ) begin
				case( ff_phase )
				3'd1:
					if( w_screen_active && ff_h_active ) begin
						ff_pattern_num0 <= vram_rdata;
					end
//				3'd2:
//					begin
//						ff_pattern_num1 <= vram_rdata;
//					end
				3'd3:
					if( w_screen_active && ff_h_active ) begin
						ff_next_pattern0 <= vram_rdata[7:2];
					end
//				3'd4:
//					begin
//						ff_next_pattern1 <= vram_rdata[7:2];
//					end
//				3'd5:
//					begin
//						ff_next_color0 <= vram_rdata;
//					end
//				3'd0:
//					begin
//						ff_next_color1 <= vram_rdata;
//					end
				default:
					begin
						//	hold
					end
				endcase
			end
		end
	end

	// --------------------------------------------------------------------
	//	Display color generate
	// --------------------------------------------------------------------
	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_pattern0 <= 6'd0;
			ff_pattern1 <= 6'd0;
		end
		else if( w_sub_phase == 3'd7 ) begin
			if( !(w_screen_active && ff_h_active) ) begin
				ff_pattern0 <= 6'd0;
				ff_pattern1 <= 6'd0;
			end
			else if( ff_phase == 3'd5 ) begin
				ff_pattern0 <= ff_next_pattern0;
				ff_pattern1 <= ff_next_pattern1;
			end
			else if( ff_phase == 3'd2 && w_mode[ c_t2 ] ) begin
				ff_pattern0 <= ff_pattern1;
			end
			else begin
				ff_pattern0 <= { ff_pattern0[4:0], 1'b0 };
			end
		end
		else if( w_sub_phase == 3'd3 && w_mode[ c_t2 ] ) begin
			ff_pattern0 <= { ff_pattern0[4:0], 1'b0 };
		end
	end

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_color <= 8'd0;
		end
		else if( w_sub_phase == 3'd7 ) begin
			if( ff_phase == 3'd5 ) begin
				if( !w_screen_active ) begin
					ff_color <= reg_backdrop_color;
				end
				else if( w_mode[ c_t1 ] ) begin
					ff_color <= reg_backdrop_color;
				end
				else begin
					ff_color <= ff_next_color0;
				end
			end
			else if( ff_phase == 3'd2 && w_mode[ c_t2 ] ) begin
				if( !w_screen_active ) begin
					ff_color <= reg_backdrop_color;
				end
				else begin
					ff_color <= ff_next_color1;
				end
			end
		end
	end

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_display_color <= 4'd0;
		end
		else if( w_sub_phase == 3'd7 || (w_sub_phase == 3'd3 && w_mode[ c_t2 ]) ) begin
			if( ff_pattern0[5] ) begin
				//	Foreground
				ff_display_color <= ff_color[7:4];
			end
			else begin
				//	Background
				ff_display_color <= ff_color[3:0];
			end
		end
	end

	assign display_color = ff_display_color;
endmodule
