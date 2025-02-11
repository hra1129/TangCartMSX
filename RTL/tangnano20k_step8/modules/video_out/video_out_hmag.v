//
//	video_out_hmag.v
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

module video_out_hmag (
	input			clk,						//	42.95454MHz
	input			reset_n,
	input			enable,
	input	[10:0]	vdp_hcounter,
	input	[1:0]	vdp_vcounter,
	input	[10:0]	h_cnt,
	// write side
	input	[5:0]	vdp_r,
	input	[5:0]	vdp_g,
	input	[5:0]	vdp_b,
	// read side
	output	[7:0]	video_r,
	output	[7:0]	video_g,
	output	[7:0]	video_b,
	// parameters
	input	[7:0]	reg_left_offset,			//	0 ..... 112
	input	[7:0]	reg_denominator,			//	144 ... 200
	input	[7:0]	reg_normalize				//	8192 / reg_denominator : 228 ... 160
);
	localparam		clocks_per_line		= 1368;
	localparam		disp_width			= 10'd576;
	localparam		h_back_porch_end	= 45;
	localparam		h_active_end		= h_back_porch_end + 800;
	localparam		h_front_porch_end	= h_active_end + 502;
	localparam		h_vdp_active_start	= h_back_porch_end + 112;
	localparam		c_active_end		= disp_width - 1;
	localparam		c_numerator			= disp_width / 4;
	wire	[9:0]	w_x_position_w;
	reg		[9:0]	ff_x_position_r;
	reg				ff_active;
	reg		[7:0]	ff_numerator;
	wire	[8:0]	w_next_numerator;
	wire	[8:0]	w_sub_numerator;
	wire			w_active_start;
	wire			w_active_end;
	wire			w_is_odd;
	wire			w_we_buf;
	wire	[5:0]	w_pixel_r;
	wire	[5:0]	w_pixel_g;
	wire	[5:0]	w_pixel_b;
	wire			w_hold;
	wire	[15:0]	w_normalized_numerator;
	reg		[5:0]	ff_coeff;
	wire	[5:0]	w_sigmoid;
	reg		[5:0]	ff_sigmoid2;
	reg		[5:0]	ff_sigmoid3;
	reg		[5:0]	ff_sigmoid4;
	reg				ff_hold0;
	reg				ff_hold1;
	reg				ff_hold2;
	reg				ff_hold3;
	reg				ff_hold4;
	reg		[5:0]	ff_tap0_r;
	reg		[5:0]	ff_tap0_g;
	reg		[5:0]	ff_tap0_b;
	reg		[5:0]	ff_tap1_r;
	reg		[5:0]	ff_tap1_g;
	reg		[5:0]	ff_tap1_b;

	// --------------------------------------------------------------------
	//	Buffer address
	// --------------------------------------------------------------------
	assign w_x_position_w	= vdp_hcounter[10:1] - (clocks_per_line/2 - disp_width - 10);

	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_x_position_r <= 10'd0;
		end
		else if( h_cnt == (clocks_per_line - 1) ) begin
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

	assign w_hold				= w_sub_numerator[8];
	assign w_next_numerator		= { 1'b0, ff_numerator } + c_numerator;
	assign w_sub_numerator		= w_next_numerator - { 1'b0, reg_denominator };

	always @( posedge clk ) begin
		ff_hold0 <= w_hold;
		ff_hold1 <= ff_hold0;
		ff_hold2 <= ff_hold1;
		ff_hold3 <= ff_hold2;
		ff_hold4 <= ff_hold3;
	end

	// --------------------------------------------------------------------
	//	Filter coefficient
	// --------------------------------------------------------------------
	assign w_normalized_numerator	= ff_numerator * reg_normalize;		//	8bit * 8bit = 16bit

	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_coeff <= 6'd0;
		end
		else begin
			ff_coeff <= w_normalized_numerator[14:9];					//	0 ... 63
		end
	end

	video_out_sigmoid u_sigmoid (
		.clk			( clk				),
		.coeff			( ff_coeff			),
		.sigmoid		( w_sigmoid			)
	);

	always @( posedge clk ) begin
		ff_sigmoid2	<= w_sigmoid;
		ff_sigmoid3	<= ff_sigmoid2;
		ff_sigmoid4	<= ff_sigmoid3;
	end

	// --------------------------------------------------------------------
	//	Active period
	// --------------------------------------------------------------------
	assign w_active_start	= (h_cnt           == { 1'b0, reg_left_offset, 2'd0 } );
	assign w_active_end		= (ff_x_position_r == c_active_end);

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
	//	Delay line memory
	// --------------------------------------------------------------------
	video_double_buffer u_double_buffer (
		.clk			( clk				),
		.reset_n		( reset_n			),
		.enable			( enable			),
		.x_position_w	( w_x_position_w	),
		.x_position_r	( ff_x_position_r	),
		.is_odd			( w_is_odd			),
		.we				( w_we_buf			),
		.wdata_r		( vdp_r				),
		.wdata_g		( vdp_g				),
		.wdata_b		( vdp_b				),
		.rdata_r		( w_pixel_r			),
		.rdata_g		( w_pixel_g			),
		.rdata_b		( w_pixel_b			)
	);

	assign w_is_odd			= vdp_vcounter[1];
	assign w_we_buf			= (w_x_position_w < disp_width);

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

	video_out_bilinear u_bilinear_r (
		.clk			( clk					),
		.coeff			( ff_sigmoid4			),
		.tap0			( ff_tap0_r				),
		.tap1			( ff_tap1_r				),
		.pixel_out		( video_r				)
	);

	video_out_bilinear u_bilinear_g (
		.clk			( clk					),
		.coeff			( ff_sigmoid4			),
		.tap0			( ff_tap0_g				),
		.tap1			( ff_tap1_g				),
		.pixel_out		( video_g				)
	);

	video_out_bilinear u_bilinear_b (
		.clk			( clk					),
		.coeff			( ff_sigmoid4			),
		.tap0			( ff_tap0_b				),
		.tap1			( ff_tap1_b				),
		.pixel_out		( video_b				)
	);
endmodule
