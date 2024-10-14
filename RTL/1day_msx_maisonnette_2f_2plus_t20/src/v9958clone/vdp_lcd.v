//
//	vdp_lcd.v
//	 LCD 800x480 up-scan converter.
//
//	Copyright (C) 2024 Takayuki Hara.
//	All rights reserved.
//									   https://github.com/hra1129
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
// -----------------------------------------------------------------------------

module vdp_lcd(
	// vdp clock ... 21.477mhz
	input			clk,
	input			reset,
	input			enable,
	// video input
	input	[5:0]	videorin,
	input	[5:0]	videogin,
	input	[5:0]	videobin,
	input			videovsin_n,
	input	[10:0]	hcounterin,
	input	[10:0]	vcounterin,
	// mode
	input			pal_mode,			// added by caro
	input			interlace_mode,
	input			legacy_vga,
	// video output
	output	[5:0]	videorout,
	output	[5:0]	videogout,
	output	[5:0]	videobout,
	output			videohsout_n,
	output			videovsout_n,
	// hdmi support
	output			blank_o,
	// switched i/o signals
	input	[2:0]	ratiomode
);
	// ff_disp_start_x + disp_width < clocks_per_line/2 = 684
	localparam		clocks_per_line	= 1368;
	localparam		disp_width		= 576;
	localparam		disp_start_y	= 3;
	localparam		prb_height		= 25;
	localparam		right_x			= 684 - disp_width - 2;				// 106
	localparam		pal_right_x		= 87;								// 87
	localparam		center_x		= right_x - 32 - 2;					// 72
	localparam		base_left_x		= center_x - 32 - 2 - 3;			// 35
	localparam		center_y		= 12;								// based on hdmi av output

	reg				ff_hsync_n;
	reg				ff_vsync_n;

	// video output enable
	reg				ff_video_out_x;

	// double buffer signal
	wire	[9:0]	w_x_position_w;
	reg		[9:0]	ff_x_position_r;
	wire			w_evenodd;
	wire			w_we_buf;
	wire	[5:0]	w_data_r_out;
	wire	[5:0]	w_data_g_out;
	wire	[5:0]	w_data_b_out;
	reg		[10:0]	ff_disp_start_x;

	assign videorout	= ( ff_video_out_x == 1'b1 ) ? w_data_r_out: 6'd0;
	assign videogout	= ( ff_video_out_x == 1'b1 ) ? w_data_g_out: 6'd0;
	assign videobout	= ( ff_video_out_x == 1'b1 ) ? w_data_b_out: 6'd0;

	vdp_doublebuf dbuf (
		.clk			( clk				),
		.enable			( enable			),
		.xpositionw		( w_x_position_w	),
		.xpositionr		( ff_x_position_r	),
		.evenodd		( w_evenodd			),
		.we				( w_we_buf			),
		.datarin		( videorin			),
		.datagin		( videogin			),
		.databin		( videobin			),
		.datarout		( w_data_r_out		),
		.datagout		( w_data_g_out		),
		.databout		( w_data_b_out		)
	);

	assign w_x_position_w	= hcounterin[10:1] - (clocks_per_line/2 - disp_width - 10);
	assign w_evenodd		= vcounterin[1];
	assign w_we_buf			= 1'b1;

	// pixel ratio 1:1 for led display
	always @( posedge clk ) begin
		if( reset )begin
			ff_disp_start_x <= 684 - disp_width - 2;
		end
		else if( enable == 1'b0 )begin
			// hold
		end
		else if( (ratiomode == 3'b000 || interlace_mode == 1'b1 || pal_mode == 1'b1) && legacy_vga == 1'b1 )begin
			// legacy output
			ff_disp_start_x <= right_x;			// 106
		end
		else if( pal_mode == 1'b1 )begin
			// 50hz
			ff_disp_start_x <= pal_right_x;		// 87
		end
		else if( ratiomode == 3'b000 || interlace_mode == 1'b1 )begin
			// 60hz
			ff_disp_start_x <= center_x;			// 72
		end
		else if( (vcounterin < 38 + disp_start_y + prb_height) ||
			   (vcounterin > 526 - prb_height && vcounterin < 526 ) ||
			   (vcounterin > 524 + 38 + disp_start_y && vcounterin < 524 + 38 + disp_start_y + prb_height) ||
			   (vcounterin > 524 + 526 - prb_height) )begin
			// pixel ratio 1:1 (vga mode, 60hz, not interlaced)
//			if( w_evenodd == 1'b0 )begin											// plot from top-right
			if( w_evenodd == 1'b1 )begin											// plot from top-left
				ff_disp_start_x <= base_left_x + ~ratiomode;						// 35 to 41
			end
			else begin
				ff_disp_start_x <= right_x;	// 106
			end
		end
		else begin
			ff_disp_start_x <= center_x;			// 72
		end
	end

	// generate h-sync signal
	always @( posedge clk ) begin
		if( reset )begin
			ff_hsync_n <= 1'b1;
		end
		else if( enable == 1'b0 )begin
			// hold
		end
		else if( (hcounterin == 0) || (hcounterin == (clocks_per_line/2)) )begin
			ff_hsync_n <= 1'b0;
		end
		else if( (hcounterin == 40) || (hcounterin == (clocks_per_line/2) + 40) )begin
			ff_hsync_n <= 1'b1;
		end
	end

	// generate v-sync signal
	// the videovsin_n signal is not used
	always @( posedge clk ) begin
		if( reset )begin
			ff_vsync_n <= 1'b1;
		end
		else if( enable == 1'b0 )begin
			// hold
		end
		else if( pal_mode == 1'b0 )begin
			if( interlace_mode == 1'b0 )begin
				if( (vcounterin == 3*2 + center_y) || (vcounterin == 524 + 3*2 + center_y) )begin
					ff_vsync_n <= 1'b0;
				end
				else if( (vcounterin == 6*2 + center_y) || (vcounterin == 524 + 6*2 + center_y) )begin
					ff_vsync_n <= 1'b1;
				end
			end
			else begin
				if( (vcounterin == 3*2 + center_y) || (vcounterin == 525 + 3*2 + center_y) )begin
					ff_vsync_n <= 1'b0;
				end
				else if( (vcounterin == 6*2 + center_y) || (vcounterin == 525 + 6*2 + center_y) )begin
					ff_vsync_n <= 1'b1;
				end
			end
		end
		else begin
			if( interlace_mode == 1'b0 )begin
				if( (vcounterin == 3*2 + center_y + 6) || (vcounterin == 626 + 3*2 + center_y + 6) )begin
					ff_vsync_n <= 1'b0;
				end
				else if( (vcounterin == 6*2 + center_y + 6) || (vcounterin == 626 + 6*2 + center_y + 6) )begin
					ff_vsync_n <= 1'b1;
				end
			end
			else begin
				if( (vcounterin == 3*2 + center_y + 6) || (vcounterin == 625 + 3*2 + center_y + 6) )begin
					ff_vsync_n <= 1'b0;
				end
				else if( (vcounterin == 6*2 + center_y + 6) || (vcounterin == 625 + 6*2 + center_y + 6) )begin
					ff_vsync_n <= 1'b1;
				end
			end
		end
	end

	// generate data read timing
	always @( posedge clk ) begin
		if( reset )begin
			ff_x_position_r <= 10'd0;
		end
		else if( enable == 1'b0 )begin
			// hold
		end
		else if( (hcounterin == ff_disp_start_x) ||
				(hcounterin == ff_disp_start_x + (clocks_per_line/2)) )begin
			ff_x_position_r <= 10'd0;
		end
		else begin
			ff_x_position_r <= ff_x_position_r + 1;
		end
	end

	// generate video output timing
	always @( posedge clk ) begin
		if( reset )begin
			ff_video_out_x <= 1'b0;
		end
		else if( enable == 1'b0 )begin
			// hold
		end
		else if( (hcounterin == ff_disp_start_x) ||
				((hcounterin == ff_disp_start_x + (clocks_per_line/2)) && interlace_mode == 1'b0) )begin
			ff_video_out_x <= 1'b1;
		end
		else if( (hcounterin == ff_disp_start_x + disp_width) ||
				(hcounterin == ff_disp_start_x + disp_width + (clocks_per_line/2)) )begin
			ff_video_out_x <= 1'b0;
		end
	end

	assign videohsout_n		= ff_hsync_n;
	assign videovsout_n		= ff_vsync_n;
	assign blank_o			= ( ff_video_out_x == 1'b0 || ff_vsync_n == 1'b0 )? 1'b1: 1'b0;
endmodule
