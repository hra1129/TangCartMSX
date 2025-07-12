//
//	vdp_timing_control_g4567.v
//	Graphic 4, 5, 6 and 7 mode timing generator for Timing Control
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

module vdp_timing_control_g4567 (
	input				reset_n,
	input				clk,					//	42.95454MHz

	input		[12:0]	screen_pos_x,
	input		[ 7:0]	pixel_pos_y,
	input				screen_active,

	output		[16:0]	vram_address,
	output				vram_valid,
	input		[31:0]	vram_rdata,

	output		[7:0]	display_color,

	input		[4:0]	reg_screen_mode,
	input				reg_display_on,
	input		[16:10]	reg_pattern_name_table_base,
	input		[7:0]	reg_backdrop_color
);
	//	Screen mode
	localparam			c_mode_g4	= 5'b011_00;	//	Graphic4 (SCREEN5)
	localparam			c_mode_g5	= 5'b100_00;	//	Graphic5 (SCREEN6)
	localparam			c_mode_g6	= 5'b101_00;	//	Graphic6 (SCREEN7)
	localparam			c_mode_g7	= 5'b111_00;	//	Graphic7 (SCREEN8/10/11/12)
	wire		[3:0]	w_mode;
	localparam			c_g4		= 0;			//	Graphic4 (SCREEN5) w_mode index
	localparam			c_g5		= 1;			//	Graphic5 (SCREEN6) w_mode index
	localparam			c_g6		= 2;			//	Graphic6 (SCREEN7) w_mode index
	localparam			c_g7		= 3;			//	Graphic7 (SCREEN8) w_mode index
	//	Phase
	wire		[2:0]	w_phase;
	wire		[2:0]	w_sub_phase;
	//	Position
	wire		[7:0]	w_pos_x;
	//	Pattern name table address
	wire		[16:0]	w_pattern_name_g45;
	wire		[16:0]	w_pattern_name_g67;
	reg			[31:0]	ff_next_pattern0;
	reg			[31:0]	ff_next_pattern1;
	reg			[7:0]	ff_pattern [0:7];
	//	VRAM address
	reg			[16:0]	ff_vram_address;
	reg					ff_vram_valid;
	//	Display color
	reg			[7:0]	ff_display_color;

	// --------------------------------------------------------------------
	//	Screen mode decoder
	// --------------------------------------------------------------------
	function [3:0] func_screen_mode_decoder(
		input	[4:0]	reg_screen_mode
	);
		case( reg_screen_mode )
		c_mode_g4:		func_screen_mode_decoder = 4'b0001;
		c_mode_g5:		func_screen_mode_decoder = 4'b0010;
		c_mode_g6:		func_screen_mode_decoder = 4'b0100;
		c_mode_g7:		func_screen_mode_decoder = 4'b1000;
		default:		func_screen_mode_decoder = 4'b0000;
		endcase
	endfunction

	assign w_mode		= func_screen_mode_decoder( reg_screen_mode );

	// --------------------------------------------------------------------
	//	Screen Position for active area
	// --------------------------------------------------------------------
	assign w_pos_x		= screen_pos_x[10:3];

	// --------------------------------------------------------------------
	//	Phase
	// --------------------------------------------------------------------
	assign w_phase		= screen_pos_x[5:3];
	assign w_sub_phase	= screen_pos_x[2:0];

	// --------------------------------------------------------------------
	//	Pattern name table address
	// --------------------------------------------------------------------
	assign w_pattern_name_g45			= {          reg_pattern_name_table_base[16:15], (reg_pattern_name_table_base[14:10] & pixel_pos_y[7:3]), pixel_pos_y[2:0], w_pos_x[7:3], 2'd0 };
	assign w_pattern_name_g67			= { w_pos_x[0], reg_pattern_name_table_base[15], (reg_pattern_name_table_base[14:10] & pixel_pos_y[7:3]), pixel_pos_y[2:0], w_pos_x[7:3], 3'd0 };

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
						if( w_mode[2] || w_mode[3] ) begin
							ff_vram_address <= w_pattern_name_g45;
						end
						else begin
							ff_vram_address <= w_pattern_name_g67;
						end
						ff_vram_valid <= screen_active & (w_mode != 4'b0000) & reg_display_on;
					end
				3'd1:
					begin
						ff_vram_address <= w_pattern_name_g67;
						ff_vram_valid <= screen_active & (w_mode[2] | w_mode[3]) & reg_display_on;
					end
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
			ff_next_pattern0 <= 32'd0;
			ff_next_pattern1 <= 32'd0;
		end
		else begin
			if( w_sub_phase == 3'd0 ) begin
				case( w_phase )
				3'd1:
					begin
						ff_next_pattern0 <= reg_display_on ? vram_rdata : 8'd0;
					end
				3'd2:
					begin
						ff_next_pattern1 <= reg_display_on ? vram_rdata : 8'd0;
					end
				3'd3:
					begin
						if( w_mode[0] || w_mode[1] ) begin
							ff_next_pattern0 <= { 4'd0, ff_next_pattern0[15:12], 4'd0, ff_next_pattern0[11: 8], 
							                      4'd0, ff_next_pattern0[ 7: 4], 4'd0, ff_next_pattern0[ 3: 0] };
							ff_next_pattern1 <= { 4'd0, ff_next_pattern0[31:28], 4'd0, ff_next_pattern0[27:24], 
							                      4'd0, ff_next_pattern0[23:20], 4'd0, ff_next_pattern0[19:16] };
						end
						else begin
							ff_next_pattern0 <= { ff_next_pattern1[15: 8], ff_next_pattern0[15: 8], ff_next_pattern1[ 7: 0], ff_next_pattern0[ 7: 0] };
							ff_next_pattern1 <= { ff_next_pattern1[31:24], ff_next_pattern0[31:24], ff_next_pattern1[23:16], ff_next_pattern0[23:16] };
						end
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
			ff_pattern[0] <= 8'd0;
			ff_pattern[1] <= 8'd0;
			ff_pattern[2] <= 8'd0;
			ff_pattern[3] <= 8'd0;
			ff_pattern[4] <= 8'd0;
			ff_pattern[5] <= 8'd0;
			ff_pattern[6] <= 8'd0;
			ff_pattern[7] <= 8'd0;
		end
		else if( w_sub_phase == 3'd5 ) begin
			if( w_phase == 3'd7 ) begin
				if( !screen_active ) begin
					ff_pattern[0] <= reg_backdrop_color;
					ff_pattern[1] <= reg_backdrop_color;
					ff_pattern[2] <= reg_backdrop_color;
					ff_pattern[3] <= reg_backdrop_color;
					ff_pattern[4] <= reg_backdrop_color;
					ff_pattern[5] <= reg_backdrop_color;
					ff_pattern[6] <= reg_backdrop_color;
					ff_pattern[7] <= reg_backdrop_color;
				end
				else begin
					ff_pattern[0] <= ff_next_pattern0[ 7: 0];
					ff_pattern[1] <= ff_next_pattern0[15: 8];
					ff_pattern[2] <= ff_next_pattern0[23:16];
					ff_pattern[3] <= ff_next_pattern0[31:24];
					ff_pattern[4] <= ff_next_pattern1[ 7: 0];
					ff_pattern[5] <= ff_next_pattern1[15: 8];
					ff_pattern[6] <= ff_next_pattern1[23:16];
					ff_pattern[7] <= ff_next_pattern1[31:24];
				end
			end
			else begin
				ff_pattern[0] <= ff_pattern[1];
				ff_pattern[1] <= ff_pattern[2];
				ff_pattern[2] <= ff_pattern[3];
				ff_pattern[3] <= ff_pattern[4];
				ff_pattern[4] <= ff_pattern[5];
				ff_pattern[5] <= ff_pattern[6];
				ff_pattern[6] <= ff_pattern[7];
				ff_pattern[7] <= reg_backdrop_color;
			end
		end
	end

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_display_color <= 4'd0;
		end
		else if( w_sub_phase == 3'd7 ) begin
			ff_display_color <= ff_pattern[0];
		end
	end

	assign display_color = ff_display_color;
endmodule
