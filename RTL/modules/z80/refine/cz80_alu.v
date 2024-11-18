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

module cz80_addsub(
	input			a : std_logic_vector;
	input			b : std_logic_vector;
	input			sub : std_logic;
	input			carry_in : std_logic;
	output			res : out std_logic_vector;
	output			carry : out std_logic
);
	variable b_i		: unsigned(a'length - 1 downto 0);
	variable res_i		: unsigned(a'length + 1 downto 0);

	wire	[]		b_i;
	wire	[]		res_i;

	assign b_i		= sub ? ~b : b;
	assign res_i	= { 1'b0, a, carry_in } + { 1'b0, b_i, 1'b1 };
	assign carry	= res_i(a'length + 1);
	res <= std_logic_vector(res_i(a'length downto 1));
end

//-----------------------------------------------------------------------------
module cz80_alu #(
	parameter			flag_c		= 0,
	parameter			flag_n		= 1,
	parameter			flag_p		= 2,
	parameter			flag_x		= 3,
	parameter			flag_h		= 4,
	parameter			flag_y		= 5,
	parameter			flag_z		= 6,
	parameter			flag_s		= 7
) (
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
	wire	[3:0]	w_busb_l;
	wire	[2:0]	w_busb_m;
	wire			w_busb_h;
	wire			w_carry_l;
	wire			w_carry_m;
	wire			w_carry_h;
	wire	[5:0]	w_addsub_l;
	wire	[4:0]	w_addsub_m;
	wire	[2:0]	w_addsub_h;
	wire	[7:0]	w_q_t;

	// addsub variables (temporary signals)
	signal	usecarry		: std_logic;
	signal	carry7_v		: std_logic;
	signal	overflow_v		: std_logic;
	signal	halfcarry_v		: std_logic;
	signal	carry_v			: std_logic;
	signal	q_v				: std_logic_vector[7:0];
	signal	q_cpi			: std_logic_vector[4:0];

	signal	bitmask			: std_logic_vector[7:0];

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

	assign bitmask		= func_3to8_decoder( ir[5:3] );

	assign usecarry		= ~alu_op[2] & alu_op[0];

	assign w_busb_l		= alu_op[1] ? ~busb[3:0] : busb[3:0];
	assign w_busb_m		= alu_op[1] ? ~busb[6:4] : busb[6:4];
	assign w_busb_h		= alu_op[1] ? ~busb[7]   : busb[7];

	assign w_carry_l	= alu_op[1] ^ ( usecarry & f_in[flag_c] );
	assign w_carry_m	= halfcarry_v;
	assign w_carry_h	= carry7_v;

	assign w_addsub_l	= { 1'b0, busa[3:0], w_carry_l } + { 1'b0, w_busb_l  , 1'b1 }
	assign w_addsub_m	= { 1'b0, busa[6:4], w_carry_m } + { 1'b0, w_busb_m  , 1'b1 }
	assign w_addsub_h	= { 1'b0, busa[7]  , w_carry_h } + { 1'b0, w_busb_h  , 1'b1 }
	assign w_addsub_s	= { 1'b0, busa[3:0], w_carry_m } + { 1'b0, ~busb[3:0], 1'b1 }

	assign q_v[3:0]		= w_addsub_l[4:1];
	assign q_v[6:4]		= w_addsub_m[3:1];
	assign q_v[7]		= w_addsub_h[1];
	assign q_cpi[3:0]	= w_addsub_s[4:1];

	assign halfcarry_v	= w_addsub_l[5];
	assign carry7_v		= w_addsub_m[4];
	assign carry_v		= w_addsub_h[2];
	assign q_cpi[4]		= w_addsub_s[5];

	assign overflow_v 	= carry_v ^ carry7_v;

	process (arith16, alu_op, alu_cpi, f_in, busa, busb, ir, q_v, q_cpi, carry_v, halfcarry_v, overflow_v, bitmask, iset, z16)
		variable daa_q : unsigned[8:0];
	begin
		f_out <= f_in;
		daa_q := 8'dx;
		case( alu_op )
		4'd0, 4'd1, 4'd2, 4'd3, 4'd4, 4'd5, 4'd6, 4'd7:
			f_out[flag_n]	<= 1'b0;
			f_out[flag_c]	<= 1'b0;
			case alu_op[2:0] is
			3'd0, 3'd1:			// add, adc
				begin
					f_out[flag_c]	<= carry_v;
					f_out[flag_h]	<= halfcarry_v;
					f_out[flag_p]	<= overflow_v;
				end
			3'd2, 3'd3, 3'd7:	// sub, sbc, cp
				begin
					f_out[flag_n]	<= 1'b1;
					f_out[flag_c]	<= ~carry_v;
					f_out[flag_h]	<= ~halfcarry_v;
					f_out[flag_p]	<= overflow_v;
				end
			3'd4:	// and
				begin
					f_out[flag_h]	<= 1'b1;
				end
			3'd5:	// xor
				begin
					f_out[flag_h]	<= 1'b0;
				end
			default: // or "110"
				begin
					f_out[flag_h]	<= 1'b0;
				end
			endcase
			if( alu_op[2:0] == 3'b111 ) begin // cp
				if( alu_cpi ) begin //cpi
					f_out[flag_x] <= q_cpi[3];
					f_out[flag_y] <= q_cpi[1];
				end
				else begin
					f_out[flag_x] <= busb[3];
					f_out[flag_y] <= busb(5);
				end
			end
			else begin
				f_out[flag_x] <= w_q_t[3];
				f_out[flag_y] <= w_q_t[5];
			end
			if( w_q_t[7:0] == 8'd0 ) begin
				f_out[flag_z] <= 1'b1;
				if( z16 ) begin
					f_out[flag_z] <= f_in[flag_z];	// 16 bit adc,sbc
				end
			end
			else begin
				f_out[flag_z] <= 1'b0;
			end
			f_out[flag_s] <= w_q_t[7];
			case alu_op[2:0] is
			3'd0, 3'd1, 3'd2, 3'd3, 3'd7:	// add, adc, sub, sbc, cp
				begin
					//	hold
				end
			default:
				f_out[flag_p] <= ~[ w_q_t[0] ^ w_q_t[1] ^ w_q_t[2] ^ w_q_t[3] ^ w_q_t[4] ^ w_q_t[5] ^ w_q_t[6] ^ w_q_t[7] ];
			endcase
			if arith16 = 1'b1 begin
				f_out[flag_s] <= f_in[flag_s];
				f_out[flag_z] <= f_in[flag_z];
				f_out[flag_p] <= f_in[flag_p];
			end
		4'b1100:
			// daa
			f_out[flag_h] <= f_in[flag_h];
			f_out[flag_c] <= f_in[flag_c];
			daa_q[7:0] := unsigned(busa);
			daa_q(8) := 1'b0;
			if f_in[flag_n] = 1'b0 begin
				// after addition
				// alow > 9 or h = 1
				if daa_q[3:0] > 9 or f_in[flag_h] = 1'b1 begin
					if (daa_q[3:0] > 9) begin
						f_out[flag_h] <= 1'b1;
					else
						f_out[flag_h] <= 1'b0;
					end
					daa_q := daa_q + 6;
				end
				// new ahigh > 9 or c = 1
				if daa_q[8:4] > 9 or f_in[flag_c] = 1'b1 begin
					daa_q := daa_q + 96; // 0x60
				end
			end
			else begin
				// after subtraction
				if daa_q[3:0] > 9 or f_in[flag_h] = 1'b1 begin
					if daa_q[3:0] > 5 begin
						f_out[flag_h] <= 1'b0;
					end
					daa_q[7:0] := daa_q[7:0] - 6;
				end
				if unsigned(busa) > 153 or f_in[flag_c] = 1'b1 begin
					daa_q := daa_q - 352; // 0x160
				end
			end
			f_out[flag_x] <= daa_q[3];
			f_out[flag_y] <= daa_q(5);
			f_out[flag_c] <= f_in[flag_c] or daa_q(8);
			if daa_q[7:0] = 8'd0 begin
				f_out[flag_z] <= 1'b1;
			else
				f_out[flag_z] <= 1'b0;
			end
			f_out[flag_s] <= daa_q[7];
			f_out[flag_p] <= not (daa_q[0] xor daa_q[1] xor daa_q[2] xor daa_q[3] xor
				daa_q[4] xor daa_q(5) xor daa_q(6) xor daa_q[7]);
		4'd13, 4'd14:
			// rld, rrd
			f_out[flag_h] <= 1'b0;
			f_out[flag_n] <= 1'b0;
			f_out[flag_x] <= w_q_t[3];
			f_out[flag_y] <= w_q_t(5);
			if w_q_t[7:0] = 8'd0 begin
				f_out[flag_z] <= 1'b1;
			else
				f_out[flag_z] <= 1'b0;
			end
			f_out[flag_s] <= w_q_t[7];
			f_out[flag_p] <= not (w_q_t[0] xor w_q_t[1] xor w_q_t[2] xor w_q_t[3] xor
				w_q_t[4] xor w_q_t(5) xor w_q_t(6) xor w_q_t[7]);
		4'd9:
			// bit
			f_out[flag_s] <= w_q_t[7];
			if w_q_t[7:0] = 8'd0 begin
				f_out[flag_z] <= 1'b1;
				f_out[flag_p] <= 1'b1;
			else
				f_out[flag_z] <= 1'b0;
				f_out[flag_p] <= 1'b0;
			end
			f_out[flag_h] <= 1'b1;
			f_out[flag_n] <= 1'b0;
			f_out[flag_x] <= 1'b0;
			f_out[flag_y] <= 1'b0;
			if ir[2:0] != "110" begin
				f_out[flag_x] <= busb[3];
				f_out[flag_y] <= busb(5);
			end
		4'd10:
		4'd11:
		4'd8:
			// rot
			case( ir[5:3] )
			3'd0: // rlc
				f_out[flag_c] <= busa[7];
			3'd2: // rl
				f_out[flag_c] <= busa[7];
			3'd1: // rrc
				f_out[flag_c] <= busa[0];
			3'd3: // rr
				f_out[flag_c] <= busa[0];
			3'd4: // sla
				f_out[flag_c] <= busa[7];
			3'd6: // sll (undocumented) / swap
				f_out[flag_c] <= busa[7];
			3'd5: // sra
				f_out[flag_c] <= busa[0];
			default: // srl
				f_out[flag_c] <= busa[0];
			endcase
			f_out[flag_h] <= 1'b0;
			f_out[flag_n] <= 1'b0;
			f_out[flag_x] <= w_q_t[3];
			f_out[flag_y] <= w_q_t[5];
			f_out[flag_s] <= w_q_t[7];
			if( w_q_t[7:0] == 8'd0 ) begin
				f_out[flag_z] <= 1'b1;
			end
			else begin
				f_out[flag_z] <= 1'b0;
			end
			f_out[flag_p] <= ~(w_q_t[0] ^ w_q_t[1] ^ w_q_t[2] ^ w_q_t[3] ^ w_q_t[4] ^ w_q_t[5] ^ w_q_t[6] ^ w_q_t[7]);
			if( iset == 2'b00 ) begin
				f_out[flag_p] <= f_in[flag_p];
				f_out[flag_s] <= f_in[flag_s];
				f_out[flag_z] <= f_in[flag_z];
			end
		default:
			begin
				//	hold
			end
		endcase
	end






















	function [7:0] func_q_t(
		input	[3:0]	alu_op
	);
		case( alu_op )
		4'd0, 4'd1, 4'd2, 4'd3:
					func_q_t	= q_v;							//	add, adc, sub, sbc
		4'd4:		func_q_t	= busa & busb;					//	and
		4'd5:		func_q_t	= busa ^ busb;					//	xor
		4'd6:		func_q_t	= busa | busb;					//	or
		4'd7:		func_q_t	= q_v;							//	cp
		4'd8:
			case( ir[5:3] )										//	rotate
			3'd0:	func_q_t	= { busa[6:0], busa[7] };		//	rlc
			3'd2:	func_q_t	= { busa[6:0], f_in[flag_c] };	//	rl
			3'd1:	func_q_t	= { busa[0], busa[7:1] };		//	rrc
			3'd3:	func_q_t	= { f_in[flag_c], busa[7:1] };	//	rr
			3'd4:	func_q_t	= { busa[6:0], 1'b0 };			//	sla
			3'd6:	func_q_t	= { busa[6:0], 1'b1 };			//	sll (undocumented)
			3'd5:	func_q_t	= { busa[7], busa[7:1] };		//	sra
			default:func_q_t	= { 1'b0, busa[7:1] };			//	srl
			endcase
		4'd9:		func_q_t	= busb & bitmask;				//	bit
		4'd10:		func_q_t	= busb | bitmask;				//	set
		4'd11:		func_q_t	= busb & ~bitmask;				//	res
		4'd12:		func_q_t	= daa_q[7:0];					//	daa
		4'd13:		func_q_t	= { busa[7:4], busb[7:4] };		//	rld
		4'd14:		func_q_t	= { busa[7:4], busb[3:0] };		//	rrd
		default:	func_q_t	= 8'dx;
		endcase
	endfunction

	assign w_q_t	= func_q_t( alu_op );
	assign q		= func_3to8_decoder( alu_op );
endmodule
