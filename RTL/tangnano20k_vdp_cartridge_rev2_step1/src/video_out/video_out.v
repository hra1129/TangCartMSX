//
//	video_out.v
//	 LCD 800x480 up-scan converter.
//
//	Copyright (C) 2025 Takayuki Hara.
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

module video_out #(
	parameter		hs_positive = 1'b1,		//	If video_hs is positive logic, set to 1; if video_hs is negative logic, set to 0.
	parameter		vs_positive = 1'b1		//	If video_vs is positive logic, set to 1; if video_vs is negative logic, set to 0.
) (
	// vdp clock ... 42.95454MHz
	input			clk,
	input			reset_n,					//	Must be reset and released at the same time as the VDP
	input			enable,
	// video input
	input	[5:0]	vdp_r,
	input	[5:0]	vdp_g,
	input	[5:0]	vdp_b,
	input	[10:0]	vdp_hcounter,
	input	[10:0]	vdp_vcounter,
	// video output
	output			video_clk,
	output			video_de,
	output			video_hs,
	output			video_vs,
	output	[7:0]	video_r,
	output	[7:0]	video_g,
	output	[7:0]	video_b
);
	// LCD 640x480 parameters
	// Horizontal timing by ff_h_cnt value : 1368cyc @ 42.95454MHz
	localparam	[10:0]	clocks_per_line		= 1368;
	localparam	[10:0]	disp_width			= 800;
	localparam	[10:0]	h_pulse_start		= 1368;						//	(4)
	localparam	[10:0]	h_pulse_end			= 284;						//	(1)
	localparam	[10:0]	h_back_porch_end	= 375;						//	(2)
	localparam	[10:0]	h_active_end		= 1175;						//	(3)
	//	                  _________________ 
	//	video_hs   ______| :            :  |
	//	                 : :____________:  :
	//	ff_h_active______:_|            |__:
	//	                (1)(2)          (3)(4)

	// Vertical timing by ff_v_cnt value
	localparam	[9:0]	v_pulse_start		= 14;						//	[4]
	localparam	[9:0]	v_pulse_end			= v_pulse_start + 6;		//	[1]
	localparam	[9:0]	v_back_porch_end	= v_pulse_end + 21;			//	[2]
	localparam	[9:0]	v_active_end		= v_back_porch_end + 480;	//	[3]
	localparam	[9:0]	v_front_porch_end	= 524;						//	[4]
	//	                ____________________
	//	video_vs   ____|    :           :   |
	//	               :    :___________:   :
	//	ff_v_active____:____|           |___:
	//	              [1]  [2]         [3] [4]

	// ff_disp_start_x + disp_width < clocks_per_line/2 = 684
	localparam	[7:0]	reg_left_offset	= 90;										//	0 ..... 112
	localparam	[7:0]	reg_denominator	= 200;										//	144 ... 200
	localparam	[7:0]	reg_normalize	= 8192 / reg_denominator;					//	8192 / reg_denominator : 57 ... 40
	localparam			reg_scanline	= 1'b1;

	reg				ff_v_sync;
	wire	[7:0]	w_data_r_out;
	wire	[7:0]	w_data_g_out;
	wire	[7:0]	w_data_b_out;
	reg		[10:0]	ff_h_cnt;
	reg				ff_h_sync;
	reg				ff_h_active;
	wire			w_h_pulse_start;
	wire			w_h_pulse_end;
	wire			w_h_back_porch_end;
	wire			w_h_active_end;
	wire			w_h_line_end;
	reg		[9:0]	ff_v_cnt;
	reg				ff_v_active;
	wire			w_v_pulse_start;
	wire			w_v_pulse_end;
	wire			w_v_back_porch_end;
	wire			w_v_active_end;
	wire			w_v_front_porch_end;
	wire			w_lcd_de;

	// --------------------------------------------------------------------
	//	Timing signals
	// --------------------------------------------------------------------
	assign w_h_pulse_start		= (ff_h_cnt == h_pulse_start - 1);
	assign w_h_pulse_end		= (ff_h_cnt == h_pulse_end - 1);
	assign w_h_back_porch_end	= (ff_h_cnt == h_back_porch_end - 1);
	assign w_h_active_end		= (ff_h_cnt == h_active_end - 1);
	assign w_h_line_end			= (ff_h_cnt == clocks_per_line - 1);
	assign w_v_pulse_start		= (ff_v_cnt == v_pulse_start - 1);
	assign w_v_pulse_end		= (ff_v_cnt == v_pulse_end - 1);
	assign w_v_back_porch_end	= (ff_v_cnt == v_back_porch_end - 1);
	assign w_v_active_end		= (ff_v_cnt == v_active_end - 1);
	assign w_v_front_porch_end	= (ff_v_cnt == v_front_porch_end - 1);

	// --------------------------------------------------------------------
	//	H Counter
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_h_cnt <= 11'd0;
		end
		else if( w_h_line_end ) begin
			ff_h_cnt <= 11'd0;
		end
		else begin
			ff_h_cnt <= ff_h_cnt + 11'd1;
		end
	end

	// --------------------------------------------------------------------
	//	H Sync
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_h_sync <= ~hs_positive;
		end
		else if( w_h_pulse_start ) begin
			ff_h_sync <= hs_positive;
		end
		else if( w_h_pulse_end ) begin
			ff_h_sync <= ~hs_positive;
		end
		else begin
			//	hold
		end
	end

	// --------------------------------------------------------------------
	//	H Active
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !reset_n ) begin
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
	//	V Counter
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_v_cnt <= 10'd0;
		end
		else if( w_h_line_end ) begin
			if( w_v_front_porch_end ) begin
				ff_v_cnt <= 10'd0;
			end
			else begin
				ff_v_cnt <= ff_v_cnt + 10'd1;
			end
		end
	end

	// --------------------------------------------------------------------
	//	V Active
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !reset_n )begin
			ff_v_active <= 1'b0;
		end
		else if( w_h_line_end ) begin
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
	video_out_hmag u_hmag (
		.clk				( clk				),
		.reset_n			( reset_n			),
		.enable				( enable			),
		.vdp_hcounter		( vdp_hcounter		),
		.vdp_vcounter		( vdp_vcounter[1:0]	),
		.h_cnt				( ff_h_cnt			),
		.vdp_r				( vdp_r				),
		.vdp_g				( vdp_g				),
		.vdp_b				( vdp_b				),
		.video_r			( w_data_r_out		),
		.video_g			( w_data_g_out		),
		.video_b			( w_data_b_out		),
		.reg_left_offset	( reg_left_offset	),
		.reg_denominator	( reg_denominator	),
		.reg_normalize		( reg_normalize		),
		.reg_scanline		( reg_scanline		)
	);

	// generate v-sync signal
	always @( posedge clk ) begin
		if( !reset_n )begin
			ff_v_sync <= vs_positive;
		end
		else if( w_h_line_end ) begin
			if( w_v_pulse_start )begin
				ff_v_sync <= vs_positive;
			end
			else if( w_v_pulse_end )begin
				ff_v_sync <= ~vs_positive;
			end
		end
	end

	assign w_lcd_de		= ff_h_active & ff_v_active;

	assign video_clk	= clk;
	assign video_de		= w_lcd_de;
	assign video_hs		= ff_h_sync;
	assign video_vs		= ff_v_sync;
	assign video_r		= w_lcd_de ? w_data_r_out: 8'd0;
	assign video_g		= w_lcd_de ? w_data_g_out: 8'd0;
	assign video_b		= w_lcd_de ? w_data_b_out: 8'd0;
endmodule
