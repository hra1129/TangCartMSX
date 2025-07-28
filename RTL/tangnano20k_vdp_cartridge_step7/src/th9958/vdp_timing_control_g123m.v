//
//	vdp_timing_control_g123m.v
//	Graphic 1, 2, 3 and Mosaic mode timing generator for Timing Control
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

module vdp_timing_control_g123m (
	input				reset_n,
	input				clk,					//	42.95454MHz

	input		[12:0]	screen_pos_x,
	input		[ 8:0]	pixel_pos_x,
	input		[ 7:0]	pixel_pos_y,
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
	input		[3:0]	reg_backdrop_color
);
	//	Screen mode
	localparam			c_mode_g1	= 5'b000_00;	//	Graphic1 (SCREEN1)
	localparam			c_mode_g2	= 5'b001_00;	//	Graphic2 (SCREEN2)
	localparam			c_mode_g3	= 5'b010_00;	//	Graphic3 (SCREEN4)
	localparam			c_mode_gm	= 5'b000_10;	//	Mosaic   (SCREEN3)
	localparam			c_mode_gmq	= 5'b001_10;	//	Mosaic   (SCREEN3)
	wire		[3:0]	w_mode;
	localparam			c_g1		= 0;			//	Graphic1 (SCREEN1) w_mode index
	localparam			c_g2		= 1;			//	Graphic2 (SCREEN2) w_mode index
	localparam			c_g3		= 2;			//	Graphic3 (SCREEN4) w_mode index
	localparam			c_gm		= 3;			//	Mosaic   (SCREEN3) w_mode index
	//	Phase
	wire		[2:0]	w_phase;
	wire		[2:0]	w_sub_phase;
	reg					ff_h_active;
	//	Position
	wire		[9:0]	w_pos_x;
	//	Pattern name table address
	wire		[16:0]	w_pattern_name;
	reg			[7:0]	ff_pattern_num;
	//	Pattern generator table address
	wire		[16:0]	w_pattern_generator_g1;
	wire		[16:0]	w_pattern_generator_g23;
	wire		[16:0]	w_pattern_generator;
	reg			[7:0]	ff_next_pattern;
	reg			[7:0]	ff_pattern;
	//	Color table address
	wire		[16:0]	w_color_g1;
	wire		[16:0]	w_color_g23;
	wire		[16:0]	w_color_gm;
	wire		[16:0]	w_color;
	reg			[7:0]	ff_next_color;
	reg			[7:0]	ff_color;
	//	VRAM address
	reg			[16:0]	ff_vram_address;
	reg					ff_vram_valid;
	//	Display color
	reg			[3:0]	ff_display_color;

	// --------------------------------------------------------------------
	//	Screen mode decoder
	// --------------------------------------------------------------------
	function [3:0] func_screen_mode_decoder(
		input	[4:0]	reg_screen_mode
	);
		case( reg_screen_mode )
		c_mode_g1:				func_screen_mode_decoder = 4'b0001;
		c_mode_g2:				func_screen_mode_decoder = 4'b0010;
		c_mode_g3:				func_screen_mode_decoder = 4'b0100;
		c_mode_gm, c_mode_gmq:	func_screen_mode_decoder = 4'b1000;
		default:				func_screen_mode_decoder = 4'b0000;
		endcase
	endfunction

	assign w_mode		= func_screen_mode_decoder( reg_screen_mode );

	// --------------------------------------------------------------------
	//	Screen Position for active area
	// --------------------------------------------------------------------
	assign w_pos_x		= screen_pos_x[12:3] - { 7'd0, horizontal_offset_l };

	// --------------------------------------------------------------------
	//	Phase
	// --------------------------------------------------------------------
	assign w_phase		= w_pos_x[2:0];
	assign w_sub_phase	= screen_pos_x[2:0];

	// --------------------------------------------------------------------
	//	Pattern name table address
	// --------------------------------------------------------------------
	assign w_pattern_name				= { reg_pattern_name_table_base, pixel_pos_y[7:3], pixel_pos_x[7:3] };

	// --------------------------------------------------------------------
	//	Pattern generator table address
	// --------------------------------------------------------------------
	assign w_pattern_generator_g1		= { reg_pattern_generator_table_base, ff_pattern_num, pixel_pos_y[2:0] };
	assign w_pattern_generator_g23		= { reg_pattern_generator_table_base[16:13], (pixel_pos_y[7:6] & reg_pattern_generator_table_base[12:11]), ff_pattern_num, pixel_pos_y[2:0] };
	assign w_pattern_generator			= w_mode[ c_g1 ] ? w_pattern_generator_g1: w_pattern_generator_g23;

	// --------------------------------------------------------------------
	//	Color table address
	// --------------------------------------------------------------------
	assign w_color_g1					= { reg_color_table_base, 1'b0, ff_pattern_num[7:3] };
	assign w_color_g23					= { reg_color_table_base[16:13], (pixel_pos_y[7:6] & reg_color_table_base[12:11]), (ff_pattern_num[7:3] & reg_color_table_base[10:6]), ff_pattern_num[2:0], pixel_pos_y[2:0] };
	assign w_color_gm					= { reg_pattern_generator_table_base, ff_pattern_num, pixel_pos_y[4:2] };
	assign w_color						= w_mode[ c_g1 ] ? w_color_g1:
										  w_mode[ c_gm ] ? w_color_gm : w_color_g23;

	// --------------------------------------------------------------------
	//	Active period
	// --------------------------------------------------------------------
	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_h_active <= 1'b0;
		end
		else if( screen_pos_x[12:3] == 10'd262 && w_sub_phase == 3'd6 ) begin
			ff_h_active <= 1'b0;
		end
		else if( w_pos_x == 10'h3FF && w_sub_phase == 3'd7 ) begin
			ff_h_active <= 1'b1;
		end
	end

	assign w_screen_active	= screen_v_active & ff_h_active;

	// --------------------------------------------------------------------
	//	VRAM read access request
	// --------------------------------------------------------------------
	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_vram_address <= 17'd0;
			ff_vram_valid <= 1'b0;
		end
		else begin
			if( w_sub_phase == 3'd0 ) begin
				case( w_phase )
				3'd0:
					begin
						ff_vram_address <= w_pattern_name;
						ff_vram_valid <= w_screen_active & (w_mode != 4'b0000) & reg_display_on;
					end
				3'd2:
					begin
						ff_vram_address <= w_pattern_generator;
						ff_vram_valid <= w_screen_active & (w_mode != 4'b0000) & reg_display_on;
					end
				3'd3:
					begin
						ff_vram_address <= w_color;
						ff_vram_valid <= w_screen_active & (w_mode != 4'b0000) & reg_display_on;
					end
				default:
					begin
						//	hold
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
			ff_pattern_num <= 8'd0;
			ff_next_pattern <= 8'd0;
			ff_next_color <= 8'd0;
		end
		else begin
			if( w_sub_phase == 3'd0 ) begin
				case( w_phase )
				3'd1:
					begin
						ff_pattern_num <= reg_display_on ? vram_rdata : 8'd0;
					end
				3'd3:
					begin
						ff_next_pattern <= reg_display_on ? vram_rdata : 8'd0;
					end
				3'd4:
					begin
						ff_next_color <= reg_display_on ? vram_rdata : 8'd0;
					end
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
			ff_pattern <= 8'd0;
		end
		else if( w_sub_phase == 3'd5 ) begin
			if( w_phase == 3'd7 ) begin
				if( !w_screen_active ) begin
					ff_pattern <= 8'd0;
				end
				else if( w_mode[ c_gm ] ) begin
					//	Fixed pattern 11110000 for mosaic mode
					ff_pattern <= 8'hF0;
				end
				else begin
					ff_pattern <= ff_next_pattern;
				end
			end
			else begin
				ff_pattern <= { ff_pattern[6:0], 1'b0 };
			end
		end
	end

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_color <= 8'd0;
		end
		else if( w_sub_phase == 3'd5 ) begin
			if( !w_screen_active ) begin
				ff_color <= { reg_backdrop_color, reg_backdrop_color };
			end
			else if( w_phase == 3'd7 ) begin
				ff_color <= ff_next_color;
			end
		end
	end

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_display_color <= 4'd0;
		end
		else if( w_sub_phase == 3'd7 ) begin
			if( ff_pattern[7] ) begin
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
