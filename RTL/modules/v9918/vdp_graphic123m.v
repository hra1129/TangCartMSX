//
//	vdp_graphic123M.vhd
//	  Imprementation of Graphic Mode 1,2,3 and Multicolor Mode.
//
//	Copyright (C) 2024 Takayuki Hara
//	All rights reserved.
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
// Document
//   GRAPHICモード1,2,3および MULTICOLORモードのメイン処理回路です。
//

module vdp_graphic123m (
	input				clk,
	input				reset,
	input				enable,
	// control signals
	input	[1:0]		dot_state,
	input	[2:0]		eight_dot_state,
	input	[8:0]		dot_counter_x,
	input	[8:0]		dot_counter_y,

	input				vdp_mode_multi,
	input				vdp_mode_multiq,
	input				vdp_mode_graphic1,
	input				vdp_mode_graphic2,
	// registers
	input	[3:0]		reg_r2_pattern_name,
	input	[2:0]		reg_r4_pattern_generator,
	input	[7:0]		reg_r3_color,
	//
	input	[7:0]		p_ram_dat,
	output	[13:0]		p_ram_adr,
	output	[3:0]		p_color_code
);
	reg		[7:0]		ff_ram_dat;
	reg		[13:0]		ff_vram_address;
	reg		[3:0]		ff_color_code;
	reg		[7:0]		ff_pre_pattern_num;
	reg		[7:0]		ff_pre_pattern_generator;
	reg		[7:0]		ff_pre_color;
	reg		[7:0]		ff_pattern_generator;
	reg		[7:0]		ff_color;
	wire	[13:0]		w_pattern_name_address;
	wire	[13:0]		w_pattern_generator_address;
	wire	[13:0]		w_color_address;
	wire				w_foreground_dot;
	wire	[7:3]		w_dot_counter_x;

	assign w_dot_counter_x				= dot_counter_x[7:3];

	// address decode
	assign w_pattern_name_address		= { reg_r2_pattern_name, dot_counter_y[7:3], w_dot_counter_x };

	assign w_pattern_generator_address	= ( vdp_mode_graphic1 == 1'b1 ) ? { reg_r4_pattern_generator, ff_pre_pattern_num, dot_counter_y[2:0] } :
										  ( { reg_r4_pattern_generator[2], dot_counter_y[7:6], ff_pre_pattern_num, dot_counter_y[2:0] } & { 1'b1, reg_r4_pattern_generator[1:0], 11'b11111111111 } );

	assign w_color_address				= ( vdp_mode_multi == 1'b1 || vdp_mode_multiq == 1'b1 ) ? { reg_r4_pattern_generator, ff_pre_pattern_num, dot_counter_y[4:2] } :
										  ( vdp_mode_graphic1 == 1'b1 )                         ? { reg_r3_color, 1'b0, ff_pre_pattern_num[7:3] } :
										  ( { reg_r3_color[7], dot_counter_y[7:6], ff_pre_pattern_num, dot_counter_y[2:0] } & { 1'b1, reg_r3_color[6:0], 6'b111111 } );

	// generate pixel color number
	assign w_foreground_dot				= ( vdp_mode_multi || vdp_mode_multiq ) ? ~eight_dot_state[2]: ff_pattern_generator[7];

	// out assignment
	assign p_ram_adr					= ff_vram_address;
	assign p_color_code					= ff_color_code;

	// --------------------------------------------------------------------
	//	VRAM latch
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !enable ) begin
			//	hold
		end
		else if( dot_state == 2'b01 ) begin
			ff_ram_dat <= p_ram_dat;
		end
	end

	// --------------------------------------------------------------------
	//	[memo]
	//	dot_state:   00 -> 01 -> 11 -> 10 -> 00 (gray code)
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( reset )begin
			ff_vram_address <= 14'd0;
		end
		else if( !enable )begin
			//	hold
		end
		else if( dot_state == 2'b11 )begin
			case( eight_dot_state )
			3'd0:		ff_vram_address <= w_pattern_name_address;
			3'd1:		ff_vram_address <= w_pattern_generator_address;
			3'd2:		ff_vram_address <= w_color_address;
			default:
				begin
					//	hold
				end
			endcase
		end
	end

	always @( posedge clk ) begin
		if( reset )begin
			ff_color_code <= 4'd0;
		end
		else if( !enable )begin
			//	hold
		end
		else if( dot_state == 2'b01 )begin
			if( w_foreground_dot ) begin
				ff_color_code <= ff_color[7:4];
			end
			else begin
				ff_color_code <= ff_color[3:0];
			end
		end
	end

	// --------------------------------------------------------------------
	//	eight dot state = 1: read pattern name table
	//		パターンジェネレーターテーブルと、カラーテーブルのどこから
	//		読み出すのか決める値。これをパターンネームテーブルから読み出す。
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( reset )begin
			ff_pre_pattern_num <= 8'd0;
		end
		else if( !enable )begin
			//	hold
		end
		else if( dot_state == 2'b10 && eight_dot_state == 3'd1 )begin
			ff_pre_pattern_num <= ff_ram_dat;
		end
	end

	// --------------------------------------------------------------------
	//	eight dot state = 2: read pattern generator table
	//		ff_pre_pattern_num に基づいたパターンジェネレータテーブル
	//		からの読み出し結果を ff_pre_pattern_generator に保存。
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( reset )begin
			ff_pre_pattern_generator <= 8'd0;
		end
		else if( !enable )begin
			//	hold
		end
		else if( dot_state == 2'b10 && eight_dot_state == 3'd2 )begin
			ff_pre_pattern_generator <= ff_ram_dat;
		end
	end

	// --------------------------------------------------------------------
	//	eight dot state = 3: read color table
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( reset )begin
			ff_pre_color <= 8'd0;
		end
		else if( !enable )begin
			//	hold
		end
		else if( dot_state == 2'b10 && eight_dot_state == 3'd3 )begin
			ff_pre_color <= ff_ram_dat;
		end
	end

	// --------------------------------------------------------------------
	//	eight dot state = 0: shift pattern generator table
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( reset )begin
			ff_color <= 8'd0;
		end
		else if( !enable )begin
			//	hold
		end
		else if( dot_state == 2'b00 && eight_dot_state == 3'd0 )begin
			ff_color <= ff_pre_color;
		end
	end

	always @( posedge clk ) begin
		if( reset )begin
			ff_pattern_generator <= 8'd0;
		end
		else if( !enable )begin
			//	hold
		end
		else if( dot_state == 2'b00 && eight_dot_state == 3'd0 )begin
			ff_pattern_generator <= ff_pre_pattern_generator;
		end
		else if( dot_state == 2'b00 )begin
			ff_pattern_generator <= { ff_pattern_generator[6:0], 1'b0 };
		end
	end
endmodule
