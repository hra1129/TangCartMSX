//
//	vdp_video_out.v
//	 LCD 800x480 horizontal magnifier.
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

module vdp_video_out #(
	parameter			active_area_start = 11'd100,
	parameter			active_area_end = 11'd1056
) (
	input				clk,						//	42.95454MHz
	input				reset_n,
	input		[10:0]	h_count,
	input		[ 9:0]	v_count,
	input				has_scanline,
	// input pixel
	input		[7:0]	vdp_r,
	input		[7:0]	vdp_g,
	input		[7:0]	vdp_b,
	// output pixel
	output				display_hs,
	output				display_vs,
	output				display_en,
	output		[7:0]	display_r,
	output		[7:0]	display_g,
	output		[7:0]	display_b,
	// parameters
	input		[7:0]	reg_denominator,			//	800 / 4
	input		[7:0]	reg_normalize				//	8192 / reg_denominator
);
	localparam		clocks_per_line		= 11'd1368;
	localparam		h_en_start			= 11'd374;
	localparam		h_en_end			= h_en_start + 11'd800;
	localparam		hs_start			= clocks_per_line - 1;
	localparam		hs_end				= 11'd283;
	localparam		v_en_start			= 10'd40;
	localparam		v_en_end			= v_en_start + 10'd480;
	localparam		vs_start			= 10'd13;
	localparam		vs_end				= 10'd19;
	localparam		c_numerator			= 576 / 4;
	wire	[10:0]	w_x_position_w;
	reg		[9:0]	ff_x_position_r;
	reg				ff_active;
	reg		[7:0]	ff_numerator;
	wire	[10:0]	w_next_numerator;
	wire	[11:0]	w_sub_numerator;
	wire			w_active_start;
	wire			w_active_end;
	wire			w_h_cnt_end;
	wire			w_is_write_odd;
	wire	[7:0]	w_pixel_r;
	wire	[7:0]	w_pixel_g;
	wire	[7:0]	w_pixel_b;
	wire			w_hold;
	wire	[15:0]	w_normalized_numerator;
	reg		[7:0]	ff_coeff;
	reg		[7:0]	ff_coeff1;
	reg		[7:0]	ff_coeff2;
	reg				ff_hold0;
	reg				ff_hold1;
	reg				ff_hold2;
	reg				ff_hold3;
	reg				ff_hold4;
	reg		[7:0]	ff_tap0_r;
	reg		[7:0]	ff_tap0_g;
	reg		[7:0]	ff_tap0_b;
	reg		[7:0]	ff_tap1_r;
	reg		[7:0]	ff_tap1_g;
	reg		[7:0]	ff_tap1_b;
	wire	[7:0]	w_bilinear_r;
	wire	[7:0]	w_bilinear_g;
	wire	[7:0]	w_bilinear_b;
	wire	[9:0]	w_scanline_gain;
	wire	[7:0]	w_gain;
	reg		[7:0]	ff_bilinear_r;
	reg		[7:0]	ff_bilinear_g;
	reg		[7:0]	ff_bilinear_b;
	reg		[7:0]	ff_gain;
	wire	[15:0]	w_display_r;
	wire	[15:0]	w_display_g;
	wire	[15:0]	w_display_b;
	reg		[7:0]	ff_display_r;
	reg		[7:0]	ff_display_g;
	reg		[7:0]	ff_display_b;
	reg				ff_h_en;
	reg				ff_v_en;
	reg				ff_hs;
	reg				ff_vs;
	wire			w_h_en_start;
	wire			w_h_en_end;
	wire			w_v_en_start;
	wire			w_v_en_end;
	wire			w_hs_start;
	wire			w_hs_end;
	wire			w_vs_start;
	wire			w_vs_end;

	// --------------------------------------------------------------------
	//	Active period
	// --------------------------------------------------------------------
	assign w_active_start	= (h_count == active_area_start    );
	assign w_active_end		= (h_count == active_area_end      );
	assign w_h_cnt_end		= (h_count == (clocks_per_line - 1));

	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_active <= 1'b0;
		end
		else if( w_active_end ) begin
			ff_active <= 1'b0;
		end
		else if( w_active_start ) begin
			ff_active <= 1'b1;
		end
		else begin
			//	hold
		end
	end

	// --------------------------------------------------------------------
	//	Synchronous signals
	// --------------------------------------------------------------------
	assign w_h_en_start		= (h_count == h_en_start);
	assign w_h_en_end		= (h_count == h_en_end  );

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_h_en <= 1'b0;
		end
		else if( w_h_en_end ) begin
			ff_h_en <= 1'b0;
		end
		else if( w_h_en_start ) begin
			ff_h_en <= 1'b1;
		end
	end

	assign w_v_en_start		= (v_count == v_en_start);
	assign w_v_en_end		= (v_count == v_en_end  );

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_v_en <= 1'b0;
		end
		else if( w_h_cnt_end ) begin
			if( w_v_en_end ) begin
				ff_v_en <= 1'b0;
			end
			else if( w_v_en_start ) begin
				ff_v_en <= 1'b1;
			end
		end
	end

	assign w_hs_start		= (h_count == hs_start);
	assign w_hs_end			= (h_count == hs_end  );

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_hs <= 1'b1;
		end
		else if( w_hs_end ) begin
			ff_hs <= 1'b1;
		end
		else if( w_hs_start ) begin
			ff_hs <= 1'b0;
		end
	end

	assign w_vs_start		= (v_count == vs_start);
	assign w_vs_end			= (v_count == vs_end  );

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_vs <= 1'b1;
		end
		else if( w_h_cnt_end ) begin
			if( w_vs_end ) begin
				ff_vs <= 1'b1;
			end
			else if( w_vs_start ) begin
				ff_vs <= 1'b0;
			end
		end
	end

	assign display_hs	= ff_hs;
	assign display_vs	= ff_vs;

	// --------------------------------------------------------------------
	//	Buffer address
	// --------------------------------------------------------------------
	assign w_x_position_w	= h_count;

	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_x_position_r <= 10'd0;
		end
		else if( w_active_start ) begin
			ff_x_position_r <= 10'd0;
		end
		else if( ff_active ) begin
			if( w_hold ) begin
				//	hold
			end
			else begin
				ff_x_position_r <= ff_x_position_r + 10'd1;
			end
		end
		else begin
			//	hold
		end
	end

	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_numerator <= 8'b0;
		end
		else if( w_active_start ) begin
			ff_numerator <= 8'b0;
		end
		else if( ff_active ) begin
			if( w_hold ) begin
				ff_numerator <= w_next_numerator[7:0];
			end
			else begin
				ff_numerator <= w_sub_numerator[7:0];
			end
		end
	end

	assign w_next_numerator		= { 1'b0, ff_numerator } + c_numerator;
	assign w_sub_numerator		= w_next_numerator - { 1'b0, reg_denominator };
	assign w_hold				= w_sub_numerator[8];

	always @( posedge clk ) begin
		ff_hold0 <= w_hold & ff_active;
		ff_hold1 <= ff_hold0;
		ff_hold2 <= ff_hold1;
		ff_hold3 <= ff_hold2;
		ff_hold4 <= ff_hold3;
	end

	// --------------------------------------------------------------------
	//	Delay line memory
	// --------------------------------------------------------------------
	vdp_video_double_buffer u_double_buffer (
		.clk			( clk				),
		.x_position_w	( w_x_position_w	),
		.x_position_r	( ff_x_position_r	),
		.is_write_odd	( w_is_write_odd	),
		.re				( ff_active			),
		.wdata_r		( vdp_r				),
		.wdata_g		( vdp_g				),
		.wdata_b		( vdp_b				),
		.rdata_r		( w_pixel_r			),
		.rdata_g		( w_pixel_g			),
		.rdata_b		( w_pixel_b			)
	);

	assign w_is_write_odd	= v_count[0];

	// --------------------------------------------------------------------
	//	Filter coefficient
	// --------------------------------------------------------------------
	assign w_normalized_numerator	= ff_numerator * reg_normalize;		//	8bit * 10bit = 16bit

	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_coeff <= 8'd0;
		end
		else begin
			ff_coeff <= w_normalized_numerator[14:7];					//	0 ... 63
		end
	end

	always @( posedge clk ) begin
		ff_coeff1	<= ff_coeff;
		ff_coeff2	<= ff_coeff1;
	end

	// --------------------------------------------------------------------
	//	Bilinear interpolation
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( ff_hold4 ) begin
			//	hold
		end
		else begin
			ff_tap0_r	<= w_pixel_r;
			ff_tap0_g	<= w_pixel_g;
			ff_tap0_b	<= w_pixel_b;
			ff_tap1_r	<= ff_tap0_r;
			ff_tap1_g	<= ff_tap0_g;
			ff_tap1_b	<= ff_tap0_b;
		end
	end

	vdp_video_out_bilinear u_bilinear_r (
		.clk			( clk					),
		.coeff			( ff_coeff2				),
		.tap0			( ff_tap0_r				),
		.tap1			( ff_tap1_r				),
		.pixel_out		( w_bilinear_r			)
	);

	vdp_video_out_bilinear u_bilinear_g (
		.clk			( clk					),
		.coeff			( ff_coeff2				),
		.tap0			( ff_tap0_g				),
		.tap1			( ff_tap1_g				),
		.pixel_out		( w_bilinear_g			)
	);

	vdp_video_out_bilinear u_bilinear_b (
		.clk			( clk					),
		.coeff			( ff_coeff2				),
		.tap0			( ff_tap0_b				),
		.tap1			( ff_tap1_b				),
		.pixel_out		( w_bilinear_b			)
	);

	// --------------------------------------------------------------------
	//	Scanline
	// --------------------------------------------------------------------
	assign w_scanline_gain	= { 2'd0, w_bilinear_r } + { 2'd0, w_bilinear_g } + { 2'd0, w_bilinear_b };
	assign w_gain			= (has_scanline == 1'b0 ) ? 8'd128:
							  (~v_count[0]          ) ? 8'd128: { 1'b0, w_scanline_gain[9:3] };

	always @( posedge clk ) begin
		ff_bilinear_r	<= w_bilinear_r;
		ff_bilinear_g	<= w_bilinear_g;
		ff_bilinear_b	<= w_bilinear_b;
		ff_gain		<= w_gain;
	end

	assign w_display_r	= ff_bilinear_r * ff_gain;
	assign w_display_g	= ff_bilinear_g * ff_gain;
	assign w_display_b	= ff_bilinear_b * ff_gain;

	always @( posedge clk ) begin
		ff_display_r	<= w_display_r[14:7];
		ff_display_g	<= w_display_g[14:7];
		ff_display_b	<= w_display_b[14:7];
	end

	assign w_display_en	= ff_h_en & ff_v_en;
	assign display_r	= w_display_en ? ff_display_r : 8'd0;
	assign display_g	= w_display_en ? ff_display_g : 8'd0;
	assign display_b	= w_display_en ? ff_display_b : 8'd0;
	assign display_en	= w_display_en;
endmodule
