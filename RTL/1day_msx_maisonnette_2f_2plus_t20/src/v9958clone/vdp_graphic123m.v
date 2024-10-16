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
	input				vdp_mode_graphic3,
	// registers
	input	[6:0]		reg_r2_pt_nam_addr,
	input	[5:0]		reg_r4_pt_gen_addr,
	input	[10:0]		reg_r10r3_col_addr,
	input	[8:3]		reg_r26_h_scroll,
	input	[2:0]		reg_r27_h_scroll,
	//
	input	[7:0]		p_ram_dat,
	output	[16:0]		p_ram_adr,
	output	[3:0]		p_color_code
);
	reg		[16:0]		ff_req_addr;
	reg		[3:0]		ff_col_code;
	reg		[7:0]		ff_pat_num;
	reg		[7:0]		ff_pre_pat_gen;
	reg		[7:0]		ff_pre_pat_col;
	reg		[7:0]		ff_pat_gen;
	reg		[7:0]		ff_pat_col;
	wire	[16:0]		w_req_pat_name_tbl_addr;
	wire	[16:0]		w_req_pat_gen_tbl_addr;
	wire	[16:0]		w_req_pat_col_tbl_addr;
	wire	[16:0]		w_req_addr;
	wire				w_col_hl_sel;
	wire	[3:0]		w_col_code;
	wire	[3:0]		w_eight_dot_state_dec;
	wire	[7:3]		w_dot_counter_x;

	assign w_dot_counter_x			= reg_r26_h_scroll[7:3] + dot_counter_x[7:3];

	// address decode
	assign w_req_pat_name_tbl_addr	= { reg_r2_pt_nam_addr, dot_counter_y[7:3], w_dot_counter_x };

	assign w_req_pat_gen_tbl_addr	= ( vdp_mode_graphic1 == 1'b1 ) ? { reg_r4_pt_gen_addr, ff_pat_num, dot_counter_y[2:0] } :
									  ( { reg_r4_pt_gen_addr[5:2], dot_counter_y[7:6], ff_pat_num, dot_counter_y[2:0] } & { 4'b1111, reg_r4_pt_gen_addr[1:0], 11'b11111111111 } );

	assign w_req_pat_col_tbl_addr	= ( vdp_mode_multi == 1'b1 || vdp_mode_multiq == 1'b1 ) ? { reg_r4_pt_gen_addr, ff_pat_num, dot_counter_y[4:2] } :
									  ( vdp_mode_graphic1 == 1'b1 )                       ? { reg_r10r3_col_addr, 1'b0, ff_pat_num[7:3] } :
									  ( { reg_r10r3_col_addr[10:7], dot_counter_y[7:6], ff_pat_num, dot_counter_y[2:0] } & { 4'b1111, reg_r10r3_col_addr[6:0], 6'b111111 } );

	// dram read request
	function [3:0] func_4dec(
		input	[2:0]	eight_dot_state
	);
		case( eight_dot_state )
			3'd0:		func_4dec = 4'b0001;
			3'd1:		func_4dec = 4'b0010;
			3'd2:		func_4dec = 4'b0100;
			3'd3:		func_4dec = 4'b1000;
			default:	func_4dec = 4'b0000;
		endcase
	endfunction
	assign w_eight_dot_state_dec	= func_4dec( eight_dot_state );

	assign w_req_addr				= ( eight_dot_state == 3'd0 ) ? w_req_pat_name_tbl_addr:
									  ( eight_dot_state == 3'd1 ) ? w_req_pat_gen_tbl_addr:
									  ( eight_dot_state == 3'd2 ) ? w_req_pat_col_tbl_addr: ff_req_addr;

	// generate pixel color number
	assign w_col_hl_sel		=	( vdp_mode_multi || vdp_mode_multiq ) ? ~eight_dot_state[2]: ff_pat_gen[7];
	assign w_col_code		=	( w_col_hl_sel ) ? ff_pat_col[7:4] : ff_pat_col[3:0];

	// out assignment
	assign p_ram_adr		= ff_req_addr;
	assign p_color_code		= ff_col_code;

	// ff
	always @( posedge clk ) begin
		if( reset )begin
			ff_pat_col <= 8'd0;
		end
		else if( !enable )begin
			//	hold
		end
		else if( dot_state == 2'b00 && w_eight_dot_state_dec[0] == 1'b1 )begin
			ff_pat_col <= ff_pre_pat_col;
		end
	end

	always @( posedge clk ) begin
		if( reset )begin
			ff_pat_gen <= 8'd0;
		end
		else if( !enable )begin
			//	hold
		end
		else if( dot_state == 2'b00 && w_eight_dot_state_dec[0] == 1'b1 )begin
			ff_pat_gen <= ff_pre_pat_gen;
		end
		else if( dot_state == 2'b01 )begin
			ff_pat_gen <= { ff_pat_gen[6:0], 1'b0 };
		end
	end

	always @( posedge clk ) begin
		if( reset )begin
			ff_pat_num <= 8'd0;
		end
		else if( !enable )begin
			//	hold
		end
		else if( dot_state == 2'b01 && w_eight_dot_state_dec[1] == 1'b1 )begin
			ff_pat_num <= p_ram_dat;
		end
	end

	always @( posedge clk ) begin
		if( reset )begin
			ff_pre_pat_gen <= 8'd0;
		end
		else if( !enable )begin
			//	hold
		end
		else if( dot_state == 2'b01 && w_eight_dot_state_dec[2] == 1'b1 )begin
			ff_pre_pat_gen <= p_ram_dat;
		end
	end

	always @( posedge clk ) begin
		if( reset )begin
			ff_pre_pat_col <= 8'd0;
		end
		else if( !enable )begin
			//	hold
		end
		else if( dot_state == 2'b01 && w_eight_dot_state_dec[3] == 1'b1 )begin
			ff_pre_pat_col <= p_ram_dat;
		end
	end

	always @( posedge clk ) begin
		if( reset )begin
			ff_col_code <= 4'd0;
		end
		else if( !enable )begin
			//	hold
		end
		else if( dot_state == 2'b01 )begin
			ff_col_code <= w_col_code;
		end
	end

	always @( posedge clk ) begin
		if( reset )begin
			ff_req_addr <= 17'd0;
		end
		else if( !enable )begin
			//	hold
		end
		else if( dot_state == 2'b11 )begin
			ff_req_addr <= w_req_addr;
		end
	end
endmodule
