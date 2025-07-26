//
//	vdp_timing_control_ssg.v
//	Synchronous Signal Generator for Timing Control
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

module vdp_timing_control_ssg (
	input				reset_n,
	input				clk,					//	42.95454MHz

	output		[10:0]	h_count,
	output		[ 9:0]	v_count,

	output		[12:0]	screen_pos_x,			//	signed   (Coordinates not affected by scroll register)
	output		[ 9:0]	screen_pos_y,			//	signed   (Coordinates not affected by scroll register)
	output		[ 8:0]	pixel_pos_x,			//	unsigned (Coordinates affected by scroll register)
	output		[ 7:0]	pixel_pos_y,			//	unsigned (Coordinates affected by scroll register)
	output				screen_active,

	output				intr_line,				//	pulse
	output				intr_frame,				//	pulse

	input				reg_50hz_mode,
	input				reg_212lines_mode,
	input				reg_interlace_mode,
	input		[7:0]	reg_display_adjust,
	input		[7:0]	reg_interrupt_line,
	input		[7:0]	reg_vertical_offset,
	input		[2:0]	reg_horizontal_offset_l,
	input		[8:3]	reg_horizontal_offset_h,
	output		[2:0]	horizontal_offset_l,
	output		[8:3]	horizontal_offset_h
);
	localparam			c_left_pos			= 12'd320;		//	16の倍数
	localparam			c_top_pos			= 11'd36;
	localparam			c_h_count_max		= 11'd1367;
	localparam			c_v_count_max_60p	= 10'd523;
	localparam			c_v_count_max_60i	= 10'd524;
	localparam			c_v_count_max_50p	= 10'd625;
	localparam			c_v_count_max_50i	= 10'd624;
	localparam			c_intr_line_timing	= 12'd100;
	localparam			c_intr_frame_timing	= 10'd212;
	reg			[10:0]	ff_h_count;
	reg			[11:0]	ff_half_count;
	reg			[ 9:0]	ff_v_count;
	wire				w_h_count_end;
	wire				w_v_count_end;
	wire		[12:0]	w_screen_pos_x;
	wire		[ 9:0]	w_screen_pos_y;
	wire		[ 8:0]	w_pixel_pos_x;
	wire		[ 7:0]	w_pixel_pos_y;
	reg					ff_h_active;
	reg					ff_v_active;
	wire				w_intr_line_timing;
	wire				w_intr_frame_timing;
	reg			[2:0]	ff_horizontal_offset_l;
	reg			[8:3]	ff_horizontal_offset_h;

	// --------------------------------------------------------------------
	//	Latch horizontal scroll register
	// --------------------------------------------------------------------
	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_horizontal_offset_l <= 3'd0;
			ff_horizontal_offset_h <= 6'd0;
		end
		else if( ff_v_count[0] && w_h_count_end ) begin
			ff_horizontal_offset_l <= reg_horizontal_offset_l;
			ff_horizontal_offset_h <= reg_horizontal_offset_h;
		end
	end

	assign horizontal_offset_l	= ff_horizontal_offset_l;
	assign horizontal_offset_h	= ff_horizontal_offset_h;

	// --------------------------------------------------------------------
	//	Horizontal Counter
	// --------------------------------------------------------------------
	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_h_count <= 11'd0;
		end
		else if( w_h_count_end ) begin
			ff_h_count <= 11'd0;
		end
		else begin
			ff_h_count <= ff_h_count + 11'd1;
		end
	end

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_half_count <= 12'd0;
		end
		else if( ff_v_count[0] && w_h_count_end ) begin
			ff_half_count <= 12'd0;
		end
		else begin
			ff_half_count <= ff_half_count + 12'd1;
		end
	end

	assign w_h_count_end	= ( ff_h_count == c_h_count_max );

	// --------------------------------------------------------------------
	//	Vertical Counter
	// --------------------------------------------------------------------
	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_v_count <= 10'd0;
		end
		else if( w_h_count_end ) begin
			if( w_v_count_end ) begin
				ff_v_count <= 10'd0;
			end
			else begin
				ff_v_count <= ff_v_count + 10'd1;
			end
		end
	end

	assign w_v_count_end	= ( !reg_50hz_mode &&  reg_interlace_mode && ff_v_count == c_v_count_max_60i ) ||
							  ( !reg_50hz_mode && !reg_interlace_mode && ff_v_count == c_v_count_max_60p ) ||
							  (  reg_50hz_mode &&  reg_interlace_mode && ff_v_count == c_v_count_max_50i ) ||
							  (                                          ff_v_count == c_v_count_max_50p );

	// --------------------------------------------------------------------
	//	Active area
	// --------------------------------------------------------------------
	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_h_active <= 1'b0;
		end
		else begin
			if( ff_half_count == (c_left_pos - 11'd1) ) begin
				ff_h_active <= 1'b1;
			end
			else if( ff_half_count == (c_left_pos + 11'd2047) ) begin
				ff_h_active <= 1'b0;
			end
		end
	end

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_v_active <= 1'b0;
		end
		else if( w_h_count_end ) begin
			if( ff_v_count == (c_top_pos * 2 - 10'd1) ) begin
				ff_v_active <= 1'b1;
			end
			else if( ff_v_count == (c_top_pos * 2 + 10'd383) && (reg_212lines_mode == 1'b0) ) begin
				ff_v_active <= 1'b0;
			end
			else if( ff_v_count == (c_top_pos * 2 + 10'd423) ) begin
				ff_v_active <= 1'b0;
			end
		end
	end

	assign w_screen_pos_x	= { 1'b0, ff_half_count   } - c_left_pos;
	assign w_screen_pos_y	= { 1'b0, ff_v_count[9:1] } - c_top_pos  + { { 6 {reg_display_adjust[7]} }, reg_display_adjust[7:4] };

	assign w_pixel_pos_x	= w_screen_pos_x[11:3] + { ff_horizontal_offset_h, 3'd0 };
	assign w_pixel_pos_y	= w_screen_pos_y[ 7:0] + reg_vertical_offset;

	// --------------------------------------------------------------------
	//	Interrupt
	// --------------------------------------------------------------------
	assign w_intr_line_timing	= (ff_half_count  == c_intr_line_timing ) ? 1'b1: 1'b0;
	assign w_intr_frame_timing	= (w_screen_pos_y == c_intr_frame_timing) ? 1'b1: 1'b0;

	// --------------------------------------------------------------------
	//	Output assignment
	// --------------------------------------------------------------------
	assign h_count			= ff_h_count;
	assign v_count			= ff_v_count;
	assign screen_pos_x		= w_screen_pos_x;
	assign screen_pos_y		= w_screen_pos_y;
	assign pixel_pos_x		= w_pixel_pos_x;
	assign pixel_pos_y		= w_pixel_pos_y;
	assign intr_line		= (w_screen_pos_y == { 2'd0, reg_interrupt_line } ) ? 1'b1: 1'b0;
	assign intr_frame		= w_intr_frame_timing & w_intr_line_timing;
	assign screen_active	= ff_h_active & ff_v_active;
	assign dot_phase		= ff_half_count[0];
endmodule
