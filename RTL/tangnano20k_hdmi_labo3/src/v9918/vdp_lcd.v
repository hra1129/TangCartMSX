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
	// vdp clock ... 42.95454MHz
	input			clk,
	input			reset,
	input			enable,
	// lcd output
	output			lcd_clk,
	output			lcd_de,
	// video input
	input	[5:0]	videorin,
	input	[5:0]	videogin,
	input	[5:0]	videobin,
	input			videovsin_n,
	input	[10:0]	hcounterin,
	input	[10:0]	vcounterin,
	// video output
	output	[7:0]	videorout,
	output	[7:0]	videogout,
	output	[7:0]	videobout,
	output			videohsout_n,
	output			videovsout_n
);
	// LCD 800x480 parameters
	// Horizontal timing by ff_h_cnt value : 1368cyc
	localparam		clocks_per_line		= 1368;
	localparam		disp_width			= 576;
	localparam		h_pulse_start		= clocks_per_line - 21;
	localparam		h_pulse_end			= clocks_per_line - 1;
	localparam		h_back_porch_end	= 45;
	localparam		h_active_end		= h_back_porch_end + 800;
	localparam		h_front_porch_end	= h_active_end + 502;
	localparam		h_vdp_active_start	= h_back_porch_end + 112;
	localparam		h_vdp_active_end	= h_vdp_active_start + disp_width;
	// Vertical timing by ff_v_cnt value
	localparam		v_pulse_start		= 14;
	localparam		v_pulse_end			= v_pulse_start + 6;			//	min 0 ... max 19
	localparam		v_back_porch_end	= v_pulse_end + 21;
	localparam		v_active_end		= v_back_porch_end + 480;
	localparam		v_front_porch_end	= 524;

	// ff_disp_start_x + disp_width < clocks_per_line/2 = 684
	localparam		disp_start_y	= 3;
	localparam		prb_height		= 25;
	localparam		right_x			= 684 - disp_width - 2;				// 106
	localparam		pal_right_x		= 87;								// 87
	localparam		center_x		= right_x - 32 - 2;					// 72
	localparam		base_left_x		= center_x - 32 - 2 - 3;			// 35

	reg				ff_v_sync;

	// double buffer signal
	wire	[9:0]	w_x_position_w;
	wire			w_is_odd;
	wire			w_we_buf;
	wire	[4:0]	w_data_r_out;
	wire	[4:0]	w_data_g_out;
	wire	[4:0]	w_data_b_out;

	reg		[10:0]	ff_h_cnt;
	reg				ff_h_sync;
	reg				ff_h_active;
	reg				ff_h_vdp_active;
	wire			w_h_pulse_start;
	wire			w_h_pulse_end;
	wire			w_h_back_porch_end;
	wire			w_h_active_end;
	wire			w_h_front_porch_end;
	wire			w_h_line_end;
	wire			w_h_vdp_active_start;
	wire			w_h_vdp_active_end;
	reg		[9:0]	ff_v_cnt;
	reg				ff_v_active;
	wire			w_v_pulse_start;
	wire			w_v_pulse_end;
	wire			w_v_back_porch_end;
	wire			w_v_active_end;
	wire			w_v_front_porch_end;
	wire			w_lcd_de;
	wire			w_vdp_de;
	wire	[9:0]	w_x_position_r;

	// --------------------------------------------------------------------
	//	Timing signals
	// --------------------------------------------------------------------
	assign w_h_pulse_start		= (ff_h_cnt == h_pulse_start);
	assign w_h_pulse_end		= (ff_h_cnt == h_pulse_end);
	assign w_h_back_porch_end	= (ff_h_cnt == h_back_porch_end);
	assign w_h_active_end		= (ff_h_cnt == h_active_end);
	assign w_h_front_porch_end	= (ff_h_cnt == h_front_porch_end);
	assign w_h_line_end			= (ff_h_cnt == clocks_per_line - 1);
	assign w_v_pulse_start		= (ff_v_cnt == v_pulse_start - 1);
	assign w_v_pulse_end		= (ff_v_cnt == v_pulse_end - 1);
	assign w_v_back_porch_end	= (ff_v_cnt == v_back_porch_end - 1);
	assign w_v_active_end		= (ff_v_cnt == v_active_end - 1);
	assign w_v_front_porch_end	= (ff_v_cnt == v_front_porch_end - 1);
	assign w_h_vdp_active_start	= (ff_h_cnt == h_vdp_active_start);
	assign w_h_vdp_active_end	= (ff_h_cnt == h_vdp_active_end);

	// --------------------------------------------------------------------
	//	LCD clock
	// --------------------------------------------------------------------
	assign lcd_clk	= clk;

	// --------------------------------------------------------------------
	//	H Counter
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( reset ) begin
			ff_h_cnt <= 11'd0;
		end
		else if( w_h_line_end ) begin
			ff_h_cnt <= 11'd0;
		end
		else begin
			ff_h_cnt <= ff_h_cnt + 11'd1;
		end
	end
	assign w_x_position_r		= ff_h_cnt - (h_vdp_active_start + 1);

	// --------------------------------------------------------------------
	//	H Sync
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( reset ) begin
			ff_h_sync <= 1'b0;
		end
		else if( w_h_pulse_start ) begin
			ff_h_sync <= 1'b1;
		end
		else if( w_h_pulse_end ) begin
			ff_h_sync <= 1'b0;
		end
		else begin
			//	hold
		end
	end

	// --------------------------------------------------------------------
	//	H Active
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( reset ) begin
			ff_h_active <= 1'b0;
		end
		else if( w_h_active_end ) begin
			ff_h_active <= 1'b0;
		end
		else if( w_h_back_porch_end ) begin
			ff_h_active <= 1'b1;
		end
		else begin
			//	hold
		end
	end

	// --------------------------------------------------------------------
	//	H VDP Active
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( reset ) begin
			ff_h_vdp_active <= 1'b0;
		end
		else if( w_h_vdp_active_start ) begin
			ff_h_vdp_active <= 1'b1;
		end
		else if( w_h_vdp_active_end ) begin
			ff_h_vdp_active <= 1'b0;
		end
		else begin
			//	hold
		end
	end

	// --------------------------------------------------------------------
	//	V Counter
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( reset ) begin
			ff_v_cnt <= 10'd0;
		end
		else if( w_h_front_porch_end ) begin
			if( w_v_front_porch_end ) begin
				ff_v_cnt <= 10'd0;
			end
			else begin
				ff_v_cnt <= ff_v_cnt + 10'd1;
			end
		end
	end
	assign w_x_position_r		= ff_h_cnt - (h_vdp_active_start + 1);

	// --------------------------------------------------------------------
	//	V Active
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( reset )begin
			ff_v_active <= 1'b0;
		end
		else if( w_h_front_porch_end ) begin
			if( w_v_back_porch_end )begin
				ff_v_active <= 1'b1;
			end
			else if( w_v_active_end )begin
				ff_v_active <= 1'b0;
			end
		end
	end

	// --------------------------------------------------------------------
	//	Color
	// --------------------------------------------------------------------
	assign w_lcd_de		= ff_h_active && ff_v_active;
	assign w_vdp_de		= ff_h_vdp_active && ff_v_active;
	assign videorout	= w_vdp_de ? { w_data_r_out, 3'b0 }: 8'd0;
	assign videogout	= w_vdp_de ? { w_data_g_out, 3'b0 }: 8'd0;
	assign videobout	= w_vdp_de ? { w_data_b_out, 3'b0 }: 8'd0;
	assign lcd_de		= w_lcd_de;

	vdp_double_buffer dbuf (
		.clk			( clk				),
		.reset			( reset				),
		.enable			( enable			),
		.x_position_w	( w_x_position_w	),
		.x_position_r	( w_x_position_r	),
		.is_odd			( w_is_odd			),
		.we				( w_we_buf			),
		.wdata_r		( videorin[5:1]		),
		.wdata_g		( videogin[5:1]		),
		.wdata_b		( videobin[5:1]		),
		.rdata_r		( w_data_r_out		),
		.rdata_g		( w_data_g_out		),
		.rdata_b		( w_data_b_out		)
	);

	assign w_x_position_w	= hcounterin[10:1] - (clocks_per_line/2 - disp_width - 10);
	assign w_is_odd			= vcounterin[1];
	assign w_we_buf			= 1'b1;

	// generate v-sync signal
	// the videovsin_n signal is not used
	always @( posedge clk ) begin
		if( reset )begin
			ff_v_sync <= 1'b1;
		end
		else if( w_h_front_porch_end ) begin
			if( w_v_pulse_start )begin
				ff_v_sync <= 1'b1;
			end
			else if( w_v_pulse_end )begin
				ff_v_sync <= 1'b0;
			end
		end
	end

	assign videohsout_n		= ff_h_sync;
	assign videovsout_n		= ff_v_sync;
endmodule
