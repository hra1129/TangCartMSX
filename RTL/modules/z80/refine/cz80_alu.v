//
//	Z80 compatible microprocessor core
//	Copyright (c) 2002 Daniel Wallner (jesus@opencores.org)
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
//	This module is based on T80(Version : 0250_T80) by Daniel Wallner and 
//	modified by Takayuki Hara.
//
//	The following modifications have been made.
//	-- Convert VHDL code to Verilog code.
//	-- Some minor bug fixes.
//-----------------------------------------------------------------------------

module cz80_alu (
	input				arith16		,
	input				z16			,
	input				alu_cpi		,
	input	[3:0]		alu_op		,
	input	[5:0]		ir			,
	input	[1:0]		iset		,
	input	[7:0]		busa		,
	input	[7:0]		busb		,
	input	[7:0]		f_in		,
	output	[7:0]		q			,
	output	[7:0]		f_out		
);
	localparam		flag_c = 0;
	localparam		flag_n = 1;
	localparam		flag_p = 2;
	localparam		flag_x = 3;
	localparam		flag_h = 4;
	localparam		flag_y = 5;
	localparam		flag_z = 6;
	localparam		flag_s = 7;

	wire	[3:0]	w_busb_l;
	wire	[2:0]	w_busb_m;
	wire			w_busb_h;
	wire			w_carry_l;
	wire			w_carry_m;
	wire			w_carry_h;
	wire	[5:0]	w_addsub_l;
	wire	[4:0]	w_addsub_m;
	wire	[2:0]	w_addsub_h;
	wire	[5:0]	w_addsub_s;
	wire	[7:0]	w_q_t;
	wire	[8:0]	w_daa_ql;
	wire	[7:0]	w_daa_sub;
	wire	[8:0]	w_daa_q;

	// addsub variables (temporary signals)
	wire			w_usecarry;
	wire			w_carry7;
	wire			w_overflow;
	wire			w_halfcarry;
	wire			w_carry;
	wire	[7:0]	w_q;
	wire	[4:0]	w_q_cpi;
	wire	[7:0]	w_bitmask;

	function [7:0] func_3to8_decoder(
		input	[2:0]	sel
	);
		case( sel )
		3'd0:		func_3to8_decoder = 8'b00000001;
		3'd1:		func_3to8_decoder = 8'b00000010;
		3'd2:		func_3to8_decoder = 8'b00000100;
		3'd3:		func_3to8_decoder = 8'b00001000;
		3'd4:		func_3to8_decoder = 8'b00010000;
		3'd5:		func_3to8_decoder = 8'b00100000;
		3'd6:		func_3to8_decoder = 8'b01000000;
		default:	func_3to8_decoder = 8'b10000000;
		endcase
	endfunction

	assign w_bitmask	= func_3to8_decoder( ir[5:3] );

	assign w_usecarry	= ~alu_op[2] & alu_op[0];

	assign w_busb_l		= alu_op[1] ? ~busb[3:0] : busb[3:0];
	assign w_busb_m		= alu_op[1] ? ~busb[6:4] : busb[6:4];
	assign w_busb_h		= alu_op[1] ? ~busb[7]   : busb[7];

	assign w_carry_l	= alu_op[1] ^ ( w_usecarry & f_in[flag_c] );
	assign w_carry_m	= w_halfcarry;
	assign w_carry_h	= w_carry7;

	assign w_addsub_l	= { 1'b0, busa[3:0], w_carry_l } + { 1'b0, w_busb_l  , 1'b1 };
	assign w_addsub_m	= { 1'b0, busa[6:4], w_carry_m } + { 1'b0, w_busb_m  , 1'b1 };
	assign w_addsub_h	= { 1'b0, busa[7]  , w_carry_h } + { 1'b0, w_busb_h  , 1'b1 };
	assign w_addsub_s	= { 1'b0, busa[3:0], w_carry_m } + { 1'b0, ~busb[3:0], 1'b1 };

	assign w_q[3:0]		= w_addsub_l[4:1];
	assign w_q[6:4]		= w_addsub_m[3:1];
	assign w_q[7]		= w_addsub_h[1];
	assign w_q_cpi[3:0]	= w_addsub_s[4:1];

	assign w_halfcarry	= w_addsub_l[5];
	assign w_carry7		= w_addsub_m[4];
	assign w_carry		= w_addsub_h[2];
	assign w_q_cpi[4]	= w_addsub_s[5];

	assign w_overflow 	= w_carry ^ w_carry7;

	assign w_daa_sub	= busa - 8'h06;
	assign w_daa_ql		= (!f_in[flag_n]) ? 
			( ( (busa[3:0] > 4'd9) || f_in[flag_h] ) ? ({ 1'b0, busa } + 9'h06) : { 1'b0, busa } ) :	// after addition
			( ( (busa[3:0] > 4'd9) || f_in[flag_h] ) ?  { 1'b0, w_daa_sub     } : { 1'b0, busa } );		// after subtraction

	assign w_daa_q		= (!f_in[flag_n]) ?
			( ( (w_daa_ql[8:4] > 4'h9  ) || f_in[flag_c]) ? (w_daa_ql + 9'h060) : w_daa_ql ) :			// after addition
			( ( (busa          > 9'h99 ) || f_in[flag_c]) ? (w_daa_ql - 9'h160) : w_daa_ql );			// after subtraction

	// --------------------------------------------------------------------
	//	Carry flag
	// --------------------------------------------------------------------
	function func_flag_c(
		input	[3:0]	alu_op,
		input			busa0,
		input			busa7,
		input			w_daa_q8,
		input			f_in_c,
		input			ir3,
		input			w_carry
	);
		case( alu_op )
		4'd0, 4'd1:
			func_flag_c = w_carry;
		4'd2, 4'd3, 4'd7:
			func_flag_c = ~w_carry;
		4'd4, 4'd5, 4'd6:
			func_flag_c = 1'b0;
		4'd8:
			func_flag_c = ir3 ? busa0 : busa7;
		4'd12:
			func_flag_c = f_in_c | w_daa_q8;
		default:
			func_flag_c = f_in_c;
		endcase
	endfunction

	assign f_out[flag_c] = func_flag_c( alu_op, busa[0], busa[7], w_daa_q[8], f_in[flag_c], ir[3], w_carry );

	// --------------------------------------------------------------------
	//	Negative flag
	// --------------------------------------------------------------------
	assign f_out[flag_n] =
			( alu_op == 4'd2 || alu_op == 4'd3 || alu_op == 4'd7 ) ? 1'b1 :
			( alu_op == 4'd10 || alu_op == 4'd11 || alu_op == 4'd12 || alu_op == 4'd15 ) ? f_in[flag_n] : 1'b0;

	// --------------------------------------------------------------------
	//	Half carry flag
	// --------------------------------------------------------------------
	function func_flag_h(
		input	[3:0]	alu_op,
		input			w_halfcarry,
		input	[3:0]	busa,
		input			f_in_h,
		input			f_in_n
	);
		case( alu_op )
		4'd0, 4'd1:
			func_flag_h	= w_halfcarry;
		4'd2, 4'd3, 4'd7:
			func_flag_h	= ~w_halfcarry;
		4'd4, 4'd9:
			func_flag_h	= 1'b1;
		4'd5, 4'd6, 4'd8, 4'd13, 4'd14:
			func_flag_h	= 1'b0;
		4'd12:
			func_flag_h	= ( !f_in_n     ) ? ( busa > 4'h9 ) :
						  ( busa > 4'h5 ) ? 1'b0 : f_in_h;
		default:
			func_flag_h = f_in_h;
		endcase
	endfunction

	assign f_out[flag_h] = func_flag_h( alu_op, w_halfcarry, busa[3:0], f_in[flag_h], f_in[flag_n] );

	// --------------------------------------------------------------------
	//	Parity/Overflow flag
	// --------------------------------------------------------------------
	function func_flag_p(
		input	[3:0]	alu_op,
		input	[2:0]	iset,
		input			arith16,
		input			f_in_p,
		input			w_overflow,
		input	[7:0]	w_q_t,
		input	[7:0]	w_daa_q
	);
		case( alu_op )
		4'd0, 4'd1, 4'd2, 4'd3, 4'd7:
			func_flag_p	= ( arith16       ) ? f_in_p : w_overflow;
		4'd4, 4'd5, 4'd6:
			func_flag_p = ( arith16       ) ? f_in_p : ~( w_q_t[0] ^ w_q_t[1] ^ w_q_t[2] ^ w_q_t[3] ^ w_q_t[4] ^ w_q_t[5] ^ w_q_t[6] ^ w_q_t[7] );
		4'd8:
			func_flag_p = ( iset == 2'b00 ) ? f_in_p : ~( w_q_t[0] ^ w_q_t[1] ^ w_q_t[2] ^ w_q_t[3] ^ w_q_t[4] ^ w_q_t[5] ^ w_q_t[6] ^ w_q_t[7] );
		4'd9:
			func_flag_p = ( w_q_t[7:0] == 8'd0 );
		4'd12:
			func_flag_p = ~( w_daa_q[0] ^ w_daa_q[1] ^ w_daa_q[2] ^ w_daa_q[3] ^ w_daa_q[4] ^ w_daa_q[5] ^ w_daa_q[6] ^ w_daa_q[7] );
		4'd13, 4'd14:
			func_flag_p = ~( w_q_t[0] ^ w_q_t[1] ^ w_q_t[2] ^ w_q_t[3] ^ w_q_t[4] ^ w_q_t[5] ^ w_q_t[6] ^ w_q_t[7] );
		default:
			func_flag_p = f_in_p;
		endcase
	endfunction

	assign f_out[flag_p] = func_flag_p( alu_op, iset, arith16, f_in[flag_p], w_overflow, w_q_t[7:0], w_daa_q[7:0] );

	// --------------------------------------------------------------------
	//	X flag, Y flag
	// --------------------------------------------------------------------
	function func_flag_xy(
		input	[3:0]	alu_op,
		input			f_in_xy,
		input	[2:0]	ir,
		input			alu_cpi,
		input			w_q_cpi,
		input			busb,
		input			w_q_t,
		input			w_daa_q
	);
		case( alu_op )
		4'd0, 4'd1, 4'd2, 4'd3, 4'd4, 4'd5, 4'd6, 4'd8, 4'd13, 4'd14:
			func_flag_xy	= w_q_t;
		4'd7:
			func_flag_xy	= ( alu_cpi ) ? w_q_cpi : busb;
		4'd12:
			func_flag_xy	= w_daa_q;
		4'd9:
			func_flag_xy	= ( ir == 3'd6 ) ? 1'b0 : busb;
		default:
			func_flag_xy	= f_in_xy;
		endcase
	endfunction

	assign f_out[flag_x] = func_flag_xy( alu_op, f_in[flag_x], ir[2:0], alu_cpi, w_q_cpi[3], busb[3], w_q_t[3], w_daa_q[3] );
	assign f_out[flag_y] = func_flag_xy( alu_op, f_in[flag_y], ir[2:0], alu_cpi, w_q_cpi[1], busb[5], w_q_t[5], w_daa_q[5] );

	// --------------------------------------------------------------------
	//	Zero flag
	// --------------------------------------------------------------------
	function func_flag_z(
		input	[3:0]	alu_op,
		input			f_in_z,
		input	[7:0]	w_q_t,
		input	[7:0]	w_daa_q,
		input			arith16,
		input			z16,
		input	[1:0]	iset
	);
		case( alu_op )
		4'd0, 4'd1, 4'd2, 4'd3, 4'd4, 4'd5, 4'd6, 4'd7:
			func_flag_z = ( arith16       ) ? f_in_z :
						  ( w_q_t == 8'd0 ) ? ( ( z16 ) ? f_in_z : 1'b1 ) : 1'b0;
		4'd12:
			func_flag_z = ( w_daa_q == 8'd0 );
		4'd9, 4'd13, 4'd14:
			func_flag_z = ( w_q_t == 8'd0 );
		4'd8:
			func_flag_z = ( iset == 2'b00 ) ? f_in_z : ( w_q_t == 8'd0 );
		default:
			func_flag_z = f_in_z;
		endcase
	endfunction

	assign f_out[flag_z] = func_flag_z( alu_op, f_in[flag_z], w_q_t[7:0], w_daa_q[7:0], arith16, z16, iset );

	// --------------------------------------------------------------------
	//	Sign flag
	// --------------------------------------------------------------------
	function func_flag_s(
		input	[3:0]	alu_op,
		input	[2:0]	iset,
		input			arith16,
		input			w_q_t7,
		input			w_daa_q7,
		input			f_in_s
	);
		case( alu_op )
		4'd0, 4'd1, 4'd2, 4'd3, 4'd4, 4'd5, 4'd6, 4'd7:
			func_flag_s = arith16 ? f_in_s : w_q_t7;
		4'd8:
			func_flag_s = ( iset == 2'b00 ) ? f_in_s : w_q_t7;
		4'd9, 4'd13, 4'd14:
			func_flag_s = w_q_t7;
		4'd12:
			func_flag_s = w_daa_q7;
		default:
			func_flag_s = f_in_s;
		endcase
	endfunction

	assign f_out[flag_s] = func_flag_s( alu_op, iset, arith16, w_q_t[7], w_daa_q[7], f_in[flag_s] );

	// --------------------------------------------------------------------
	//	演算結果 q
	// --------------------------------------------------------------------
	function [7:0] func_q_t(
		input	[3:0]	alu_op,
		input	[7:0]	busa,
		input	[7:0]	busb,
		input			f_in_c,
		input	[7:0]	w_bitmask,
		input	[7:0]	w_q,
		input	[7:0]	w_daa_q
	);
		case( alu_op )
		4'd0, 4'd1, 4'd2, 4'd3, 4'd7:
					func_q_t	= w_q;							//	add, adc, sub, sbc, cp
		4'd4:		func_q_t	= busa & busb;					//	and
		4'd5:		func_q_t	= busa ^ busb;					//	xor
		4'd6:		func_q_t	= busa | busb;					//	or
		4'd8:
			case( ir[5:3] )										//	rotate
			3'd0:	func_q_t	= { busa[6:0], busa[7] };		//	rlc
			3'd2:	func_q_t	= { busa[6:0], f_in_c };		//	rl
			3'd1:	func_q_t	= { busa[0], busa[7:1] };		//	rrc
			3'd3:	func_q_t	= { f_in_c, busa[7:1] };		//	rr
			3'd4:	func_q_t	= { busa[6:0], 1'b0 };			//	sla
			3'd6:	func_q_t	= { busa[6:0], 1'b1 };			//	sll (undocumented)
			3'd5:	func_q_t	= { busa[7], busa[7:1] };		//	sra
			default:func_q_t	= { 1'b0, busa[7:1] };			//	srl
			endcase
		4'd9:		func_q_t	= busb & w_bitmask;				//	bit
		4'd10:		func_q_t	= busb | w_bitmask;				//	set
		4'd11:		func_q_t	= busb & ~w_bitmask;			//	res
		4'd12:		func_q_t	= w_daa_q[7:0];					//	daa
		4'd13:		func_q_t	= { busa[7:4], busb[7:4] };		//	rld
		4'd14:		func_q_t	= { busa[7:4], busb[3:0] };		//	rrd
		default:	func_q_t	= 8'd0;
		endcase
	endfunction

	assign w_q_t	= func_q_t( alu_op, busa, busb, f_in[flag_c], w_bitmask, w_q, w_daa_q[7:0] );
	assign q		= w_q_t;
endmodule
