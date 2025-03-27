//	
//	CZ80 compatible microprocessor core
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
//	This module is based on T80(Version: 0250_T80) by Daniel Wallner and 
//	modified by Takayuki Hara.
//
//	The following modifications have been made.
//	-- Convert VHDL code to Verilog code.
//	-- Some minor bug fixes.
//-----------------------------------------------------------------------------

module cz80_mcode (
	input	[7:0]		ir			,
	input	[1:0]		iset		,
	input	[2:0]		mcycle		,
	input	[7:0]		f			,
	input				nmicycle	,
	input				intcycle	,
	input	[1:0]		xy_state	,
	output	[2:0]		mcycles		,
	output	[2:0]		tstates		,
	output	[1:0]		prefix		,	// none,cb,ed,dd/fd
	output				inc_pc		,
	output				inc_wz		,
	output	[3:0]		incdec_16	,	// bc,de,hl,sp	 0 is inc
	output				read_to_reg ,
	output				read_to_acc ,
	output	[3:0]		set_busa_to ,	// b,c,d,e,h,l,di/db,a,sp(l),sp(m),0,f
	output	[3:0]		set_busb_to ,	// b,c,d,e,h,l,di,a,sp(l),sp(m),1,f,pc(l),pc(m),0
	output	[3:0]		alu_op		,	// add, adc, sub, sbc, and, xor, or, cp, rot, bit, set, res, daa, rld, rrd, none
	output				alu_cpi		,	//for undoc xy-flags
	output				save_alu	,
	output				preservec	,
	output				arith16		,
	output	[2:0]		set_addr_to ,	// anone,axy,aioa,asp,abc,ade,azi
	output				iorq		,
	output				jump		,
	output				jumpe		,
	output				jumpxy		,
	output				call		,
	output				rstp		,
	output				ldz			,
	output				ldw			,
	output				ldsphl		,
	output	[2:0]		special_ld	,	// a,i;a,r;i,a;r,a;none
	output				exchangedh	,
	output				exchangerp	,
	output				exchangeaf	,
	output				exchangers	,
	output				i_djnz		,
	output				i_cpl		,
	output				i_ccf		,
	output				i_scf		,
	output				i_retn		,
	output				i_bt		,
	output				i_bc		,
	output				i_btr		,
	output				i_rld		,
	output				i_rrd		,
	output				i_inrc		,
	output				setdi		,
	output				setei		,
	output	[1:0]		imode		,
	output				halt		,
	output				noread		,
	output				write		,
	output				xybit_undoc	
);
	localparam			flag_c	= 0;
	localparam			flag_n	= 1;
	localparam			flag_p	= 2;
	localparam			flag_x	= 3;
	localparam			flag_h	= 4;
	localparam			flag_y	= 5;
	localparam			flag_z	= 6;
	localparam			flag_s	= 7;

	localparam	[2:0]	anone	= 3'd7;
	localparam	[2:0]	abc		= 3'd0;
	localparam	[2:0]	ade		= 3'd1;
	localparam	[2:0]	axy		= 3'd2;
	localparam	[2:0]	aioa	= 3'd4;
	localparam	[2:0]	asp		= 3'd5;
	localparam	[2:0]	azi		= 3'd6;

	wire	[7:0]	irb;
	wire	[2:0]	ddd;
	wire	[2:0]	sss;
	wire	[1:0]	dpair;

	// ------------------------------------------------------------------------
	//	is_cc_true = f[6] のような記述だと、シミュレーション時にメモリモデルが
	//	不定を返した結果が伝搬し、この関数の出力も不定になってしまうため、
	//	それを避けるために、不定だった場合は、F[n] の値は 0 として扱うように
	//	記述している。
	//
	function is_cc_true(
		input	[7:0]	f,
		input	[2:0]	cc
	);
		case( cc )
		 3'd0: 
		 	if( f[6] == 1'b1 ) begin	//	NZ	F[6]が 0 or X のときに 1 を返す 
		 		is_cc_true = 1'b0;
		 	end
		 	else begin
		 		is_cc_true = 1'b1;
		 	end
		 3'd1:
		 	if( f[6] == 1'b1 ) begin	//	Z	F[6]が 0 or X のときに 0 を返す 
		 		is_cc_true = 1'b1;
		 	end
		 	else begin
		 		is_cc_true = 1'b0;
		 	end
		 3'd2:
		 	if( f[0] == 1'b1 ) begin	//	NC	F[0]が 0 or X のときに 1 を返す 
		 		is_cc_true = 1'b0;
		 	end
		 	else begin
		 		is_cc_true = 1'b1;
		 	end
		 3'd3:
		 	if( f[0] == 1'b1 ) begin	//	C	F[0]が 0 or X のときに 0 を返す 
		 		is_cc_true = 1'b1;
		 	end
		 	else begin
		 		is_cc_true = 1'b0;
		 	end
		 3'd4:
		 	if( f[2] == 1'b1 ) begin	//	PO	F[2]が 0 or X のときに 1 を返す 
		 		is_cc_true = 1'b0;
		 	end
		 	else begin
		 		is_cc_true = 1'b1;
		 	end
		 3'd5:
		 	if( f[2] == 1'b1 ) begin	//	PE	F[2]が 0 or X のときに 0 を返す 
		 		is_cc_true = 1'b1;
		 	end
		 	else begin
		 		is_cc_true = 1'b0;
		 	end
		 3'd6:
		 	if( f[7] == 1'b1 ) begin	//	P	F[7]が 0 or X のときに 1 を返す 
		 		is_cc_true = 1'b0;
		 	end
		 	else begin
		 		is_cc_true = 1'b1;
		 	end
		 3'd7:
		 	if( f[7] == 1'b1 ) begin	//	M	F[7]が 0 or X のときに 0 を返す 
		 		is_cc_true = 1'b1;
		 	end
		 	else begin
		 		is_cc_true = 1'b0;
		 	end
		endcase
	endfunction

	assign ddd		= ir[5:3];
	assign sss		= ir[2:0];
	assign dpair	= ir[5:4];
	assign irb		= ir;

	// --------------------------------------------------------------------
	//	Prefix instruction
	// --------------------------------------------------------------------
	function [1:0] func_prefix(
		input	[1:0]	iset,
		input	[7:0]	irb
	);
		if( iset == 2'b00 ) begin
			case( irb )
			8'hCB:
				func_prefix = 2'b01;
			8'hED:
				func_prefix = 2'b10;
			8'hDD, 8'hFD:
				func_prefix = 2'b11;
			default:
				func_prefix = 2'b00;
			endcase
		end
		else begin
			func_prefix = 2'b00;
		end
	endfunction

	assign prefix	= func_prefix( iset, irb );

	// --------------------------------------------------------------------
	//	mcycles
	// --------------------------------------------------------------------
	function [2:0] func_mcycles(
		input	[1:0]	iset,
		input	[7:0]	irb,
		input	[1:0]	xy_state,
		input	[3:0]	mcycle,
		input	[7:0]	f,
		input	[5:3]	ir
	);
		case( iset )
		2'b00:
			// --------------------------------------------------------------------
			//  unprefixed instructions
			// --------------------------------------------------------------------
			case( irb )
			8'h06, 8'h0E, 8'h16, 8'h1E, 8'h26, 8'h2E, 8'h3E,
			8'h46, 8'h4E, 8'h56, 8'h5E, 8'h66, 8'h6E, 8'h7E,
			8'h70, 8'h71, 8'h72, 8'h73, 8'h74, 8'h75, 8'h77,
			8'h0A, 8'h1A, 8'h02, 8'h12,
			8'h86, 8'h8E, 8'h96, 8'h9E, 8'hA6, 8'hAE, 8'hB6, 8'hBE,
			8'hC6, 8'hCE, 8'hD6, 8'hDE, 8'hE6, 8'hEE, 8'hF6, 8'hFE:
				func_mcycles = 3'd2;
			8'h36, 8'h01, 8'h11, 8'h21, 8'h31, 8'hC5, 8'hD5, 
			8'hE5, 8'hF5, 8'hC1, 8'hD1, 8'hE1, 8'hF1, 8'h34, 8'h35,
			8'h09, 8'h19, 8'h29, 8'h39, 8'hC3, 8'h18, 8'h10,
			8'hC2, 8'hCA, 8'hD2, 8'hDA, 8'hE2, 8'hEA, 8'hF2, 8'hFA,
			8'hC9, 8'hDB, 8'hD3,
			8'hC7, 8'hCF, 8'hD7, 8'hDF, 8'hE7, 8'hEF, 8'hF7, 8'hFF:
				func_mcycles = 3'd3;
			8'h32, 8'h3A:
				func_mcycles = 3'd4;
			8'h2A, 8'h22, 8'hE3, 8'hCD:
				func_mcycles = 3'd5;
			8'h00:
				if( nmicycle == 1'b1 ) begin
					// nmi
					func_mcycles = 3'd3;
				end
				else if( intcycle == 1'b1 ) begin
					// int (im 2)
					func_mcycles = 3'd5;
				end
				else begin
					// nop
					func_mcycles = 3'd1;
				end
			8'h38:														// jr c,e
				if( mcycle == 3'd2 ) begin
					func_mcycles = ( !f[flag_c] ) ? 3'd2: 3'd3;
				end
				else begin
					func_mcycles = 3'd3;
				end
			8'h30:														// jr nc,e
				if( mcycle == 3'd2 ) begin
					func_mcycles = ( f[flag_c] ) ? 3'd2: 3'd3;
				end
				else begin
					func_mcycles = 3'd3;
				end
			8'h28:														// jr z,e
				if( mcycle == 3'd2 ) begin
					func_mcycles = ( !f[flag_z] ) ? 3'd2: 3'd3;
				end
				else begin
					func_mcycles = 3'd3;
				end
			8'h20:														// jr nz,e
				if( mcycle == 3'd2 ) begin
					func_mcycles = ( f[flag_z] ) ? 3'd2: 3'd3;
				end
				else begin
					func_mcycles = 3'd3;
				end
			8'hC4, 8'hCC, 8'hD4, 8'hDC, 8'hE4, 8'hEC, 8'hF4, 8'hFC:		// call cc,nn
				if( mcycle == 3'd3 ) begin
					func_mcycles = ( is_cc_true( f, ir[5:3] ) ) ? 3'd5: 3'd3;
				end
				else begin
					func_mcycles = 3'd5;
				end
			8'hC0, 8'hC8, 8'hD0, 8'hD8, 8'hE0, 8'hE8, 8'hF0, 8'hF8:	// ret cc
				if( mcycle == 3'd1 ) begin
					func_mcycles = ( is_cc_true( f, ir[5:3] ) ) ? 3'd3: 3'd1;
				end
				else begin
					func_mcycles = 3'd3;
				end
			default:
				func_mcycles = 3'd1;
			endcase

		// --------------------------------------------------------------------
		//  cb prefixed instructions
		// --------------------------------------------------------------------
		2'b01:
			case( irb )
			8'h00, 8'h01, 8'h02, 8'h03, 8'h04, 8'h05, 8'h07,
			8'h10, 8'h11, 8'h12, 8'h13, 8'h14, 8'h15, 8'h17,
			8'h08, 8'h09, 8'h0A, 8'h0B, 8'h0C, 8'h0D, 8'h0F,
			8'h18, 8'h19, 8'h1A, 8'h1B, 8'h1C, 8'h1D, 8'h1F,
			8'h20, 8'h21, 8'h22, 8'h23, 8'h24, 8'h25, 8'h27,
			8'h28, 8'h29, 8'h2A, 8'h2B, 8'h2C, 8'h2D, 8'h2F,
			8'h30, 8'h31, 8'h32, 8'h33, 8'h34, 8'h35, 8'h37,
			8'h38, 8'h39, 8'h3A, 8'h3B, 8'h3C, 8'h3D, 8'h3F,			// rlc r, rl r, rrc r, rr r, sla r, sra r, srl r, sll r (undocumented)
			8'hC0, 8'hC1, 8'hC2, 8'hC3, 8'hC4, 8'hC5, 8'hC7,
			8'hC8, 8'hC9, 8'hCA, 8'hCB, 8'hCC, 8'hCD, 8'hCF,
			8'hD0, 8'hD1, 8'hD2, 8'hD3, 8'hD4, 8'hD5, 8'hD7,
			8'hD8, 8'hD9, 8'hDA, 8'hDB, 8'hDC, 8'hDD, 8'hDF,
			8'hE0, 8'hE1, 8'hE2, 8'hE3, 8'hE4, 8'hE5, 8'hE7,
			8'hE8, 8'hE9, 8'hEA, 8'hEB, 8'hEC, 8'hED, 8'hEF,
			8'hF0, 8'hF1, 8'hF2, 8'hF3, 8'hF4, 8'hF5, 8'hF7,
			8'hF8, 8'hF9, 8'hFA, 8'hFB, 8'hFC, 8'hFD, 8'hFF:			// set b,r
				func_mcycles = ( xy_state != 2'b00 ) ? 3'd3: 3'd1;			// r/s (ix+d),reg, undocumented
			8'h06, 8'h16, 8'h26, 8'h36, 
			8'h86, 8'h96, 8'hA6, 8'hB6,
			8'hC6, 8'hD6, 8'hE6, 8'hF6, 
			8'h0E, 8'h1E, 8'h2E, 8'h3E,
			8'h8E, 8'h9E, 8'hAE, 8'hBE,
			8'hCE, 8'hDE, 8'hEE, 8'hFE:
				func_mcycles = 3'd3;
			8'h40, 8'h41, 8'h42, 8'h43, 8'h44, 8'h45, 8'h47,
			8'h48, 8'h49, 8'h4A, 8'h4B, 8'h4C, 8'h4D, 8'h4F,
			8'h50, 8'h51, 8'h52, 8'h53, 8'h54, 8'h55, 8'h57,
			8'h58, 8'h59, 8'h5A, 8'h5B, 8'h5C, 8'h5D, 8'h5F,
			8'h60, 8'h61, 8'h62, 8'h63, 8'h64, 8'h65, 8'h67,
			8'h68, 8'h69, 8'h6A, 8'h6B, 8'h6C, 8'h6D, 8'h6F,
			8'h70, 8'h71, 8'h72, 8'h73, 8'h74, 8'h75, 8'h77,
			8'h78, 8'h79, 8'h7A, 8'h7B, 8'h7C, 8'h7D, 8'h7F:			// bit b,r
				func_mcycles = ( xy_state != 2'b00 ) ? 3'd2: 3'd1;			// bit b,(ix+d), undocumented
			8'h46, 8'h4E, 8'h56, 8'h5E, 8'h66, 8'h6E, 8'h76, 8'h7E:		// bit b,(hl)
				func_mcycles = 3'd2;
			8'h80, 8'h81, 8'h82, 8'h83, 8'h84, 8'h85, 8'h87, 
			8'h88, 8'h89, 8'h8A, 8'h8B, 8'h8C, 8'h8D, 8'h8F, 
			8'h90, 8'h91, 8'h92, 8'h93, 8'h94, 8'h95, 8'h97, 
			8'h98, 8'h99, 8'h9A, 8'h9B, 8'h9C, 8'h9D, 8'h9F, 
			8'hA0, 8'hA1, 8'hA2, 8'hA3, 8'hA4, 8'hA5, 8'hA7, 
			8'hA8, 8'hA9, 8'hAA, 8'hAB, 8'hAC, 8'hAD, 8'hAF, 
			8'hB0, 8'hB1, 8'hB2, 8'hB3, 8'hB4, 8'hB5, 8'hB7, 
			8'hB8, 8'hB9, 8'hBA, 8'hBB, 8'hBC, 8'hBD, 8'hBF:			// res b,r
				func_mcycles = (xy_state == 2'b00) ? 3'd1: 3'd3;			// res b,(ix+d),reg, undocumented
			default:
				func_mcycles = 3'd1;
			endcase

		// --------------------------------------------------------------------
		//	ED prefixed instructions
		// --------------------------------------------------------------------
		default:
			case( irb )
			8'h4B, 8'h5B, 8'h6B, 8'h7B, 8'h43, 8'h53, 8'h63, 8'h73:
				func_mcycles = 3'd5;
			8'hA0, 8'hA8, 8'hB0, 8'hB8, 8'hA1, 8'hA9, 8'hB1, 8'hB9, 8'h6F, 8'h67,
			8'hA2, 8'hAA, 8'hB2, 8'hBA, 8'hA3, 8'hAB, 8'hB3, 8'hBB:
				func_mcycles = 3'd4;
			8'h4A, 8'h5A, 8'h6A, 8'h7A, 8'h42, 8'h52, 8'h62, 8'h72,
			8'h45, 8'h4D, 8'h55, 8'h5D, 8'h65, 8'h6D, 8'h75, 8'h7D:
				func_mcycles = 3'd3;
			8'h40, 8'h48, 8'h50, 8'h58, 8'h60, 8'h68, 8'h70, 8'h78,
			8'h41, 8'h49, 8'h51, 8'h59, 8'h61, 8'h69, 8'h71, 8'h79:
				func_mcycles = 3'd2;
			default:
				func_mcycles = 3'd1;
			endcase
		endcase
	endfunction

	assign mcycles	= func_mcycles( iset, irb, xy_state, mcycle, f, ir[5:3] );

	// --------------------------------------------------------------------
	//	tstates
	// --------------------------------------------------------------------
	function [2:0] func_tstates(
		input	[2:0]	mcycle,
		input	[1:0]	iset,
		input	[7:0]	irb,
		input	[7:0]	f,
		input	[5:3]	ir,
		input	[1:0]	xy_state
	);
		if( mcycle == 3'd7 ) begin
			func_tstates = 3'd5;
		end
		else begin
			case( iset )
			2'b00:
				// --------------------------------------------------------------------
				//  unprefixed instructions
				// --------------------------------------------------------------------
				case( irb )
				 8'hF9:											// ld sp,hl
					func_tstates = 3'd6;
				 8'hC5, 8'hD5, 8'hE5, 8'hF5:					// push qq
					if( mcycle == 3'd1 ) begin
						func_tstates = 3'd5;
					end
					else begin
						func_tstates = 3'd3;
					end
				 8'hE3:											// ex (sp),hl
					if( mcycle == 3'd1 || mcycle == 3'd3 ) begin
						func_tstates = 3'd4;
					end
					else if( mcycle == 3'd5 ) begin
						func_tstates = 3'd5;
					end
					else begin
						func_tstates = 3'd3;
					end
				8'h34,														// inc (hl)
				8'h35:														// dec (hl)
					if( mcycle == 3'd1 || mcycle == 3'd2 ) begin
						func_tstates = 3'd4;
					end
					else begin
						func_tstates = 3'd3;
					end
				 8'h00:
					if( nmicycle || intcycle ) begin
						if( mcycle == 3'd1 ) begin
							func_tstates = 3'd5;
						end
						else if( mcycle == 3'd2 || mcycle == 3'd3 ) begin
							func_tstates = 3'd4;
						end
						else begin
							func_tstates = 3'd3;
						end
					end
					else begin
						if( mcycle == 3'd1 ) begin
							func_tstates = 3'd4;
						end
						else begin
							func_tstates = 3'd3;
						end
					end
				 8'h09, 8'h19, 8'h29, 8'h39:			// add hl,ss
					if( mcycle == 3'd1 ) begin
						func_tstates = 3'd4;
					end
					else if( mcycle == 3'd2 ) begin
						func_tstates = 3'd4;
					end
					else begin
						func_tstates = 3'd3;
					end
				8'h18, 8'h20, 8'h28, 8'h30, 8'h38:		// jr e, jr nz,e, jr z,e, jr c,e, jr nc,e
					if( mcycle == 3'd1 ) begin
						func_tstates = 3'd4;
					end
					else if( mcycle == 3'd3 ) begin
						func_tstates = 3'd5;
					end
					else begin
						func_tstates = 3'd3;
					end
				8'h10:									// djnz,e
					if( mcycle == 3'd1 || mcycle == 3'd3 ) begin
						func_tstates = 3'd5;
					end
					else begin
						func_tstates = 3'd3;
					end
				8'hCD:									// call nn
					if( mcycle == 3'd1 || mcycle == 3'd3 ) begin
						func_tstates = 3'd4;
					end
					else begin
						func_tstates = 3'd3;
					end
				 8'hC4, 8'hCC, 8'hD4, 8'hDC, 8'hE4, 8'hEC, 8'hF4, 8'hFC:		// call cc,nn
					if( mcycle == 3'd1 ) begin
						func_tstates = 3'd4;
					end
					else if( mcycle == 3'd3 ) begin
						if( is_cc_true( f, ir[5:3] ) ) begin
							func_tstates = 3'd4;
						end
						else begin
							func_tstates = 3'd3;
						end
					end
					else begin
						func_tstates = 3'd3;
					end
				8'h03, 8'h13, 8'h23, 8'h33, 8'h0B, 8'h1B, 8'h2B, 8'h3B:
					func_tstates = 3'd6;
				8'hC9,
				8'hC0, 8'hC8, 8'hD0, 8'hD8, 8'hE0, 8'hE8, 8'hF0, 8'hF8,
				8'hC7, 8'hCF, 8'hD7, 8'hDF, 8'hE7, 8'hEF, 8'hF7, 8'hFF:
					func_tstates = ( mcycle == 3'd1 ) ? 3'd5: 3'd3;
				default:
					func_tstates = ( mcycle == 3'd1 ) ? 3'd4: 3'd3;
				endcase

			2'b01:
				// --------------------------------------------------------------------
				//  CB prefixed instructions
				// --------------------------------------------------------------------
				case( irb )
				8'h00, 8'h01, 8'h02, 8'h03, 8'h04, 8'h05, 8'h07, 
				8'h10, 8'h11, 8'h12, 8'h13, 8'h14, 8'h15, 8'h17, 
				8'h08, 8'h09, 8'h0A, 8'h0B, 8'h0C, 8'h0D, 8'h0F, 
				8'h18, 8'h19, 8'h1A, 8'h1B, 8'h1C, 8'h1D, 8'h1F, 
				8'h20, 8'h21, 8'h22, 8'h23, 8'h24, 8'h25, 8'h27, 
				8'h28, 8'h29, 8'h2A, 8'h2B, 8'h2C, 8'h2D, 8'h2F, 
				8'h30, 8'h31, 8'h32, 8'h33, 8'h34, 8'h35, 8'h37, 
				8'h38, 8'h39, 8'h3A, 8'h3B, 8'h3C, 8'h3D, 8'h3F,
				8'h40, 8'h41, 8'h42, 8'h43, 8'h44, 8'h45, 8'h47, 
				8'h48, 8'h49, 8'h4A, 8'h4B, 8'h4C, 8'h4D, 8'h4F, 
				8'h50, 8'h51, 8'h52, 8'h53, 8'h54, 8'h55, 8'h57, 
				8'h58, 8'h59, 8'h5A, 8'h5B, 8'h5C, 8'h5D, 8'h5F, 
				8'h60, 8'h61, 8'h62, 8'h63, 8'h64, 8'h65, 8'h67, 
				8'h68, 8'h69, 8'h6A, 8'h6B, 8'h6C, 8'h6D, 8'h6F, 
				8'h70, 8'h71, 8'h72, 8'h73, 8'h74, 8'h75, 8'h77, 
				8'h78, 8'h79, 8'h7A, 8'h7B, 8'h7C, 8'h7D, 8'h7F,
				8'hC0, 8'hC1, 8'hC2, 8'hC3, 8'hC4, 8'hC5, 8'hC7,
				8'hC8, 8'hC9, 8'hCA, 8'hCB, 8'hCC, 8'hCD, 8'hCF,
				8'hD0, 8'hD1, 8'hD2, 8'hD3, 8'hD4, 8'hD5, 8'hD7,
				8'hD8, 8'hD9, 8'hDA, 8'hDB, 8'hDC, 8'hDD, 8'hDF,
				8'hE0, 8'hE1, 8'hE2, 8'hE3, 8'hE4, 8'hE5, 8'hE7,
				8'hE8, 8'hE9, 8'hEA, 8'hEB, 8'hEC, 8'hED, 8'hEF,
				8'hF0, 8'hF1, 8'hF2, 8'hF3, 8'hF4, 8'hF5, 8'hF7,
				8'hF8, 8'hF9, 8'hFA, 8'hFB, 8'hFC, 8'hFD, 8'hFF,
				8'h80, 8'h81, 8'h82, 8'h83, 8'h84, 8'h85, 8'h87,
				8'h88, 8'h89, 8'h8A, 8'h8B, 8'h8C, 8'h8D, 8'h8F,
				8'h90, 8'h91, 8'h92, 8'h93, 8'h94, 8'h95, 8'h97,
				8'h98, 8'h99, 8'h9A, 8'h9B, 8'h9C, 8'h9D, 8'h9F,
				8'hA0, 8'hA1, 8'hA2, 8'hA3, 8'hA4, 8'hA5, 8'hA7,
				8'hA8, 8'hA9, 8'hAA, 8'hAB, 8'hAC, 8'hAD, 8'hAF,
				8'hB0, 8'hB1, 8'hB2, 8'hB3, 8'hB4, 8'hB5, 8'hB7,
				8'hB8, 8'hB9, 8'hBA, 8'hBB, 8'hBC, 8'hBD, 8'hBF:
					if( xy_state == 2'b00 ) begin
						if( mcycle == 3'd1 ) begin
							func_tstates = 3'd4;
						end
						else begin
							func_tstates = 3'd3;
						end
					end
					else begin
						if( mcycle == 3'd1 || mcycle == 3'd2 ) begin
							func_tstates = 3'd4;
						end
						else begin
							func_tstates = 3'd3;
						end
					end
				8'h06, 8'h16, 8'h0E, 8'h1E, 8'h2E, 8'h3E, 8'h26, 8'h36,
				8'h46, 8'h4E, 8'h56, 8'h5E, 8'h66, 8'h6E, 8'h76, 8'h7E,
				8'h86, 8'h8E, 8'h96, 8'h9E, 8'hA6, 8'hAE, 8'hB6, 8'hBE,
				8'hC6, 8'hCE, 8'hD6, 8'hDE, 8'hE6, 8'hEE, 8'hF6, 8'hFE:
					func_tstates = ( mcycle == 3'd1 || mcycle == 3'd2 ) ? 3'd4: 3'd3;
				default:
					func_tstates = ( mcycle == 3'd1 ) ? 3'd4: 3'd3;
				endcase
			default:
				// --------------------------------------------------------------------
				//	ED prefixed instructions
				// --------------------------------------------------------------------
				case( irb )
				8'h57,								// ld a,i
				8'h5F,								// ld a,r
				8'h47,								// ld i,a
				8'h4F:								// ld r,a
					func_tstates = 3'd5;
				8'hA0, 8'hA8, 8'hB0, 8'hB8,			// ldi, ldd, ldir, lddr
				8'hA1, 8'hA9, 8'hB1, 8'hB9:			// cpi, cpd, cpir, cpdr
					if( mcycle == 3'd1 ) begin
						func_tstates = 3'd4;
					end
					else if( mcycle == 3'd3 || mcycle == 3'd4 ) begin
						func_tstates = 3'd5;
					end
					else begin
						func_tstates = 3'd3;
					end
				8'h4A, 8'h5A, 8'h6A, 8'h7A,
				8'h42, 8'h52, 8'h62, 8'h72:
					if( mcycle == 3'd1 || mcycle == 3'd2 ) begin
						func_tstates = 3'd4;
					end
					else begin
						func_tstates = 3'd3;
					end
				8'h6F, 8'h67:
					if( mcycle == 3'd1 || mcycle == 3'd3 ) begin
						func_tstates = 3'd4;
					end
					else begin
						func_tstates = 3'd3;
					end

				8'hA2, 8'hAA, 8'hB2, 8'hBA:
					if( mcycle == 3'd1 || mcycle == 3'd3 ) begin
						func_tstates = 3'd4;
					end
					else if( mcycle == 3'd4 ) begin
						func_tstates = 3'd5;
					end
					else begin
						func_tstates = 3'd3;
					end
				8'hA3, 8'hAB, 8'hB3, 8'hBB:
					if( mcycle == 3'd1 || mcycle == 3'd4 ) begin
						func_tstates = 3'd5;
					end
					else begin
						func_tstates = 3'd3;
					end
				default:
					if( mcycle == 3'd1 ) begin
						func_tstates = 3'd4;
					end
					else begin
						func_tstates = 3'd3;
					end
				endcase
			endcase
		end
	endfunction

	assign tstates = func_tstates( mcycle, iset, irb, f, ir[5:3], xy_state );

	// --------------------------------------------------------------------
	//	Increment PC
	// --------------------------------------------------------------------
	function func_inc_pc(
		input	[1:0]	iset,
		input	[2:0]	mcycle,
		input	[7:0]	irb,
		input			nmicycle,
		input			intcycle
	);
		if( mcycle == 3'd6 ) begin
			func_inc_pc = 1'b1;
		end
		else if( mcycle == 3'd7 ) begin
			func_inc_pc = ( irb == 8'h36 || iset == 2'b01 );
		end
		else begin
			case( iset )
			// --------------------------------------------------------------------
			//  unprefixed instructions
			// --------------------------------------------------------------------
			 2'b00:
				case( irb )
				8'h06, 8'h0E, 8'h16, 8'h1E, 8'h26, 8'h2E, 8'h3E,
				8'h36, 8'hC6, 8'hCE, 8'hD6, 8'hDE, 8'hE6, 8'hEE,
				8'hF6, 8'hFE, 8'h18, 8'h38, 8'h30, 8'h28, 8'h20,
				8'h10, 8'hDB, 8'hD3:
					func_inc_pc = ( mcycle == 3'd2 );
				8'h3A, 8'h32, 8'h01, 8'h11, 8'h21, 8'h31, 8'h2A,
				8'h22, 8'hC3, 8'hC2, 8'hCA, 8'hD2, 8'hDA, 8'hE2,
				8'hEA, 8'hF2, 8'hFA, 8'hCD, 8'hC4, 8'hCC, 8'hD4,
				8'hDC, 8'hE4, 8'hEC, 8'hF4, 8'hFC:
				 	func_inc_pc = ( mcycle == 3'd2 || mcycle == 3'd3 );
				8'h00:
					func_inc_pc = ( !nmicycle && intcycle && mcycle == 3'd4 );
				default:
					func_inc_pc = 1'b0;
				endcase
			// --------------------------------------------------------------------
			//  CB prefixed instructions
			// --------------------------------------------------------------------
			 2'b01:
				func_inc_pc = 1'b0;
			// --------------------------------------------------------------------
			//	ED prefixed instructions
			// --------------------------------------------------------------------
			default:
				case( irb )
				8'h4B, 8'h5B, 8'h6B, 8'h7B,
				8'h43, 8'h53, 8'h63, 8'h73:
			 		func_inc_pc = ( mcycle == 3'd2 || mcycle == 3'd3 );
				default:
					func_inc_pc = 1'b0;
				endcase
			endcase
		end
	endfunction

	assign inc_pc = func_inc_pc( iset, mcycle, irb, nmicycle, intcycle );

	// --------------------------------------------------------------------
	//	Increment WZ
	// --------------------------------------------------------------------
	function func_inc_wz(
		input	[1:0]	iset,
		input	[2:0]	mcycle,
		input	[7:0]	irb
	);
		case( iset )
		 2'b00:
			// --------------------------------------------------------------------
			//  unprefixed instructions
			// --------------------------------------------------------------------
			case( irb )
			8'h2A, 8'h22:
				func_inc_wz = ( mcycle == 3'd4 );
			default:
				func_inc_wz = 1'b0;
			endcase
		2'b01:
			func_inc_wz = 1'b0;
		default:
			// --------------------------------------------------------------------
			//	ED prefixed instructions
			// --------------------------------------------------------------------
			case( irb )
			8'h4B, 8'h5B, 8'h6B, 8'h7B, 8'h43, 8'h53, 8'h63, 8'h73:
				func_inc_wz = ( mcycle == 3'd4 );
			default:
				func_inc_wz = 1'b0;
			endcase
		endcase
	endfunction

	assign inc_wz	= func_inc_wz( iset, mcycle, irb );

	// --------------------------------------------------------------------
	//	increment/decrement for 16bits
	// --------------------------------------------------------------------
	function [3:0] func_incdec_16(
		input	[1:0]	iset,
		input	[2:0]	mcycle,
		input	[7:0]	irb,
		input			nmicycle,
		input			intcycle,
		input	[1:0]	dpair,
		input	[7:0]	f,
		input	[5:3]	ir
	);
		case( iset )
		// --------------------------------------------------------------------
		//  unprefixed instructions
		// --------------------------------------------------------------------
		 2'b00:
			case( irb )
			8'hC5, 8'hD5, 8'hE5, 8'hF5, 
			8'hC7, 8'hCF, 8'hD7, 8'hDF, 8'hE7, 8'hEF, 8'hF7, 8'hFF:
				if( mcycle == 3'd1 || mcycle == 3'd2 ) begin
					func_incdec_16 = 4'hF;
				end
				else begin
					func_incdec_16 = 4'h0;
				end
			8'hC1, 8'hD1, 8'hE1, 8'hF1, 8'hC9,
			8'hC0, 8'hC8, 8'hD0, 8'hD8, 8'hE0, 8'hE8, 8'hF0, 8'hF8:
				if( mcycle == 3'd2 || mcycle == 3'd3 ) begin
					func_incdec_16 = 4'h7;
				end
				else begin
					func_incdec_16 = 4'h0;
				end
			8'hE3:
				if( mcycle == 3'd3 ) begin
					func_incdec_16 = 4'h7;
				end
				else if( mcycle == 3'd5 ) begin
					func_incdec_16 = 4'hF;
				end
				else begin
					func_incdec_16 = 4'h0;
				end
			8'h00:
				if( nmicycle || intcycle ) begin
					func_incdec_16 = ( mcycle == 3'd1 || mcycle == 3'd2 ) ? 4'hF: 4'h0;
				end
				else begin
					func_incdec_16 = 4'h0;
				end
			8'h03, 8'h13, 8'h23, 8'h33:
				func_incdec_16 = { 2'b01, dpair };
			8'h0B, 8'h1B, 8'h2B, 8'h3B:
				func_incdec_16 = { 2'b11, dpair };
			 8'hCD:
				func_incdec_16 = ( mcycle == 3'd3 || mcycle == 3'd4 ) ? 4'hF: 4'h0;
			 8'hC4, 8'hCC, 8'hD4, 8'hDC, 8'hE4, 8'hEC, 8'hF4, 8'hFC:
				func_incdec_16 = ( mcycle == 3'd3 && is_cc_true( f, ir[5:3] ) ) ? 4'hF:
							(( mcycle == 3'd4 ) ? 4'hF: 4'h0);
			default:
				func_incdec_16 = 4'h0;
			endcase
		// --------------------------------------------------------------------
		//  cb prefixed instructions
		// --------------------------------------------------------------------
		2'b01:
			func_incdec_16 = 4'h0;

		// --------------------------------------------------------------------
		//	ED prefixed instructions
		// --------------------------------------------------------------------
		default:
			case( irb )
			8'hA0, 8'hA8, 8'hB0, 8'hB8:
				if( mcycle == 3'd1 ) begin
					func_incdec_16 = 4'hC;
				end
				else if( mcycle == 3'd2 ) begin
					if( ir[3] == 1'b0 ) begin
						func_incdec_16 = 4'h6;
					end
					else begin
						func_incdec_16 = 4'hE;
					end
				end
				else if( mcycle == 3'd3 ) begin
					if( ir[3] == 1'b0 ) begin
						func_incdec_16 = 4'h5; // de
					end
					else begin
						func_incdec_16 = 4'hD;
					end
				end
				else begin
					func_incdec_16 = 4'h0;
				end
			8'hA1, 8'hA9, 8'hB1, 8'hB9:
				if( mcycle == 3'd1 ) begin
					func_incdec_16 = 4'hC; // bc
				end
				else if( mcycle == 3'd2 ) begin
					if( !ir[3] ) begin
						func_incdec_16 = 4'h6;
					end
					else begin
						func_incdec_16 = 4'hE;
					end
				end
				else begin
					func_incdec_16 = 4'h0;
				end
			8'h45, 8'h4D, 8'h55, 8'h5D, 8'h65, 8'h6D, 8'h75, 8'h7D:
				if( mcycle == 3'd2 || mcycle == 3'd3 ) begin
					func_incdec_16 = 4'h7;
				end
				else begin
					func_incdec_16 = 4'h0;
				end
			8'hA2, 8'hAA, 8'hB2, 8'hBA, 8'hA3, 8'hAB, 8'hB3, 8'hBB:
				if( mcycle == 3'd3 ) begin
					if( !ir[3] ) begin
						func_incdec_16 = 4'h6;
					end
					else begin
						func_incdec_16 = 4'hE;
					end
				end
				else begin
					func_incdec_16 = 4'h0;
				end
			default:
				func_incdec_16 = 4'h0;
			endcase
		endcase
	endfunction

	assign incdec_16	= func_incdec_16( iset, mcycle, irb, nmicycle, intcycle, dpair, f, ir[5:3] );

	// --------------------------------------------------------------------
	//	I/O request
	// --------------------------------------------------------------------
	function func_iorq(
		input	[2:0]	mcycle,
		input	[1:0]	iset,
		input	[7:0]	irb
	);
		case( iset )
		// --------------------------------------------------------------------
		//  unprefixed instructions
		// --------------------------------------------------------------------
		 2'b00:
			func_iorq = ( (irb == 8'hD3 || irb == 8'hDB) && mcycle == 3'd3 );
		// --------------------------------------------------------------------
		//  CD prefixed instructions
		// --------------------------------------------------------------------
		2'b01:
			func_iorq = 1'b0;
		// --------------------------------------------------------------------
		//	ED prefixed instructions
		// --------------------------------------------------------------------
		default:
			case( irb )
			8'h40, 8'h48, 8'h50, 8'h58, 8'h60, 8'h68, 8'h70, 8'h78,
			8'h41, 8'h49, 8'h51, 8'h59, 8'h61, 8'h69, 8'h71, 8'h79,
			8'hA2, 8'hAA, 8'hB2, 8'hBA:
				func_iorq = ( mcycle == 3'd2 );
			8'hA3, 8'hAB, 8'hB3, 8'hBB:
				func_iorq = ( mcycle == 3'd3 );
			default:
				func_iorq = 1'b0;
			endcase
		endcase
	endfunction

	assign iorq	= func_iorq( mcycle, iset, irb );

	// --------------------------------------------------------------------
	//	read to accumulator flag
	// --------------------------------------------------------------------
	function func_read_to_acc(
		input	[1:0]	iset,
		input	[2:0]	mcycle,
		input	[7:0]	irb
	);
		case( iset )
		// --------------------------------------------------------------------
		//  unprefixed instructions
		// --------------------------------------------------------------------
		 2'b00:
			case( irb )
			8'h0A, 8'h1A:
				func_read_to_acc = ( mcycle == 3'd2 );
			8'h3A:
				func_read_to_acc = ( mcycle == 3'd4 );
			8'hDB:
				func_read_to_acc = ( mcycle == 3'd3 );
			default:
				func_read_to_acc = 1'b0;
			endcase
		// --------------------------------------------------------------------
		//  CB prefixed instructions
		// --------------------------------------------------------------------
		2'b01:
			func_read_to_acc = 1'b0;
		// --------------------------------------------------------------------
		//	ED prefixed instructions
		// --------------------------------------------------------------------
		default:
			case( irb )
			8'h44, 8'h4C, 8'h54, 8'h5C, 8'h64, 8'h6C, 8'h74, 8'h7C:
				func_read_to_acc = 1'b1;
			default:
				func_read_to_acc = 1'b0;
			endcase
		endcase
	endfunction

	assign read_to_acc = func_read_to_acc( iset, mcycle, irb );

	// --------------------------------------------------------------------
	//	read to register flag
	// --------------------------------------------------------------------
	function func_read_to_reg(
		input	[1:0]	iset,
		input	[2:0]	mcycle,
		input	[7:0]	irb,
		input	[5:3]	ir,
		input	[1:0]	xy_state
	);
		case( iset )
		// --------------------------------------------------------------------
		//  unprefixed instructions
		// --------------------------------------------------------------------
		 2'b00:
			case( irb )
			8'h04, 8'h0C, 8'h14, 8'h1C, 8'h24, 8'h2C, 8'h3C,
			8'h05, 8'h0D, 8'h15, 8'h1D, 8'h25, 8'h2D, 8'h3D,
			8'h07, 8'h17, 8'h27, 8'h0F, 8'h1F,
			8'h40, 8'h41, 8'h42, 8'h43, 8'h44, 8'h45, 8'h47,
			8'h48, 8'h49, 8'h4A, 8'h4B, 8'h4C, 8'h4D, 8'h4F,
			8'h50, 8'h51, 8'h52, 8'h53, 8'h54, 8'h55, 8'h57,
			8'h58, 8'h59, 8'h5A, 8'h5B, 8'h5C, 8'h5D, 8'h5F,
			8'h60, 8'h61, 8'h62, 8'h63, 8'h64, 8'h65, 8'h67,
			8'h68, 8'h69, 8'h6A, 8'h6B, 8'h6C, 8'h6D, 8'h6F,
			8'h78, 8'h79, 8'h7A, 8'h7B, 8'h7C, 8'h7D, 8'h7F,
			8'h80, 8'h81, 8'h82, 8'h83, 8'h84, 8'h85, 8'h87,
			8'h88, 8'h89, 8'h8A, 8'h8B, 8'h8C, 8'h8D, 8'h8F,
			8'h90, 8'h91, 8'h92, 8'h93, 8'h94, 8'h95, 8'h97,
			8'h98, 8'h99, 8'h9A, 8'h9B, 8'h9C, 8'h9D, 8'h9F,
			8'hA0, 8'hA1, 8'hA2, 8'hA3, 8'hA4, 8'hA5, 8'hA7,
			8'hA8, 8'hA9, 8'hAA, 8'hAB, 8'hAC, 8'hAD, 8'hAF,
			8'hB0, 8'hB1, 8'hB2, 8'hB3, 8'hB4, 8'hB5, 8'hB7,
			8'hB8, 8'hB9, 8'hBA, 8'hBB, 8'hBC, 8'hBD, 8'hBF:
				func_read_to_reg = 1'b1;
			8'h06, 8'h0E, 8'h16, 8'h1E, 8'h26, 8'h2E, 8'h3E, 
			8'h46, 8'h4E, 8'h56, 8'h5E, 8'h66, 8'h6E, 8'h7E, 
			8'h86, 8'h8E, 8'h96, 8'h9E, 8'hA6, 8'hAE, 8'hB6, 8'hBE, 
			8'hC6, 8'hCE, 8'hD6, 8'hDE, 8'hE6, 8'hEE, 8'hF6, 8'hFE, 
			8'h34, 8'h35: 
				func_read_to_reg = ( mcycle == 3'd2 );
			8'h70, 8'h71, 8'h72, 8'h73, 8'h74, 8'h75, 8'h77, 
			8'h36, 8'h0A, 8'h1A, 8'h3A, 8'h02, 8'h12, 8'h32, 
			8'h22, 8'hF9, 8'hC5, 8'hD5, 8'hE5, 8'hF5, 8'h00, 
			8'h03, 8'h13, 8'h23, 8'h33, 8'h0B, 8'h1B, 8'h2B, 8'h3B, 
			8'hC3, 8'h18, 8'h38, 8'h30, 8'h28, 8'h20, 8'hE9, 8'hCD, 
			8'hC4, 8'hCC, 8'hD4, 8'hDC, 8'hE4, 8'hEC, 8'hF4, 8'hFC, 
			8'hC2, 8'hCA, 8'hD2, 8'hDA, 8'hE2, 8'hEA, 8'hF2, 8'hFA, 
			8'hC0, 8'hC8, 8'hD0, 8'hD8, 8'hE0, 8'hE8, 8'hF0, 8'hF8, 
			8'hC7, 8'hCF, 8'hD7, 8'hDF, 8'hE7, 8'hEF, 8'hF7, 8'hFF, 
			8'hC9, 8'hDB, 8'hD3:
				func_read_to_reg = 1'b0;
			8'h01, 8'h11, 8'h21, 8'h31:
				func_read_to_reg = ( mcycle == 3'd2 || mcycle == 3'd3 );
			8'h2A:
				func_read_to_reg = ( mcycle == 3'd4 || mcycle == 3'd5 );
			8'hC1, 8'hD1, 8'hE1, 8'hF1, 8'h09, 8'h19, 8'h29, 8'h39:
				func_read_to_reg = ( mcycle == 3'd2 || mcycle == 3'd3 );
			8'hE3:
				func_read_to_reg = ( mcycle == 3'd2 || mcycle == 3'd4 );
			8'h10:
				func_read_to_reg = ( mcycle == 3'd1 );
			default:
				func_read_to_reg = 1'b0;
			endcase
		// --------------------------------------------------------------------
		//  cb prefixed instructions
		// --------------------------------------------------------------------
		2'b01:
			case( irb )
			8'h06, 8'h16, 8'h0E, 8'h1E, 8'h2E, 8'h3E, 8'h26, 8'h36:
				func_read_to_reg = ( mcycle == 3'd2 );
			8'h40, 8'h41, 8'h42, 8'h43, 8'h44, 8'h45, 8'h47, 
			8'h48, 8'h49, 8'h4A, 8'h4B, 8'h4C, 8'h4D, 8'h4F, 
			8'h50, 8'h51, 8'h52, 8'h53, 8'h54, 8'h55, 8'h57, 
			8'h58, 8'h59, 8'h5A, 8'h5B, 8'h5C, 8'h5D, 8'h5F, 
			8'h60, 8'h61, 8'h62, 8'h63, 8'h64, 8'h65, 8'h67, 
			8'h68, 8'h69, 8'h6A, 8'h6B, 8'h6C, 8'h6D, 8'h6F, 
			8'h70, 8'h71, 8'h72, 8'h73, 8'h74, 8'h75, 8'h77, 
			8'h78, 8'h79, 8'h7A, 8'h7B, 8'h7C, 8'h7D, 8'h7F, 
			8'h46, 8'h4E, 8'h56, 8'h5E, 8'h66, 8'h6E, 8'h76, 8'h7E: 
				func_read_to_reg = 1'b0;
			8'hC6, 8'hCE, 8'hD6, 8'hDE, 8'hE6, 8'hEE, 8'hF6, 8'hFE,
			8'h86, 8'h8E, 8'h96, 8'h9E, 8'hA6, 8'hAE, 8'hB6, 8'hBE:
				func_read_to_reg = ( mcycle == 3'd2 );
			default:
				if( xy_state == 2'b00 ) begin
					func_read_to_reg = ( mcycle == 3'd1 );
				end
				else begin
					func_read_to_reg = ( mcycle == 3'd2 );
				end
			endcase
		// --------------------------------------------------------------------
		//	ED prefixed instructions
		// --------------------------------------------------------------------
		default:
			case( irb )
			8'h4B, 8'h5B, 8'h6B, 8'h7B:
				func_read_to_reg = ( mcycle == 3'd4 || mcycle == 3'd5 );
			8'h4A, 8'h5A, 8'h6A, 8'h7A, 8'h42, 8'h52, 8'h62, 8'h72:
				func_read_to_reg = ( mcycle == 3'd2 || mcycle == 3'd3 );
			8'h6F, 8'h67:
				func_read_to_reg = ( mcycle == 3'd3 );
			8'h40, 8'h48, 8'h50, 8'h58, 8'h60, 8'h68, 8'h70, 8'h78:
				func_read_to_reg = ( mcycle == 3'd2 && ir[5:3] != 3'd6 );
			8'hA2, 8'hAA, 8'hB2, 8'hBA, 8'hA3, 8'hAB, 8'hB3, 8'hBB:
				func_read_to_reg = ( mcycle == 3'd1 );
			default:
				func_read_to_reg = 1'b0;
			endcase
		endcase
	endfunction

	assign read_to_reg = func_read_to_reg( iset, mcycle, irb, ir[5:3], xy_state );

	// --------------------------------------------------------------------
	//	BUSB
	// --------------------------------------------------------------------
	function [3:0] func_set_busb_to(
		input	[1:0]	iset,
		input	[2:0]	mcycle,
		input	[7:0]	irb,
		input	[7:0]	ir,
		input	[1:0]	dpair
	);
		if( mcycle == 3'd7 ) begin
			func_set_busb_to = { 1'b0, sss };
		end
		else begin
			case( iset )
			// --------------------------------------------------------------------
			//  unprefixed instructions
			// --------------------------------------------------------------------
			 2'b00:
				case( irb )
				8'h40, 8'h41, 8'h42, 8'h43, 8'h44, 8'h45, 8'h47, 
				8'h48, 8'h49, 8'h4A, 8'h4B, 8'h4C, 8'h4D, 8'h4F, 
				8'h50, 8'h51, 8'h52, 8'h53, 8'h54, 8'h55, 8'h57, 
				8'h58, 8'h59, 8'h5A, 8'h5B, 8'h5C, 8'h5D, 8'h5F, 
				8'h60, 8'h61, 8'h62, 8'h63, 8'h64, 8'h65, 8'h67, 
				8'h68, 8'h69, 8'h6A, 8'h6B, 8'h6C, 8'h6D, 8'h6F, 
				8'h78, 8'h79, 8'h7A, 8'h7B, 8'h7C, 8'h7D, 8'h7F, 
				8'h80, 8'h81, 8'h82, 8'h83, 8'h84, 8'h85, 8'h87, 
				8'h88, 8'h89, 8'h8A, 8'h8B, 8'h8C, 8'h8D, 8'h8F, 
				8'h90, 8'h91, 8'h92, 8'h93, 8'h94, 8'h95, 8'h97, 
				8'h98, 8'h99, 8'h9A, 8'h9B, 8'h9C, 8'h9D, 8'h9F, 
				8'hA0, 8'hA1, 8'hA2, 8'hA3, 8'hA4, 8'hA5, 8'hA7, 
				8'hA8, 8'hA9, 8'hAA, 8'hAB, 8'hAC, 8'hAD, 8'hAF, 
				8'hB0, 8'hB1, 8'hB2, 8'hB3, 8'hB4, 8'hB5, 8'hB7, 
				8'hB8, 8'hB9, 8'hBA, 8'hBB, 8'hBC, 8'hBD, 8'hBF:
					func_set_busb_to = { 1'b0, sss };
				8'h70, 8'h71, 8'h72, 8'h73, 8'h74, 8'h75, 8'h77:
					func_set_busb_to = (mcycle == 3'd1) ? { 1'b0, sss }: 4'd0;
				 8'h36,
				 8'h86, 8'h8E, 8'h96, 8'h9E, 8'hA6, 8'hAE, 8'hB6, 8'hBE,
				 8'hC6, 8'hCE, 8'hD6, 8'hDE, 8'hE6, 8'hEE, 8'hF6, 8'hFE:
					func_set_busb_to = (mcycle == 3'd2) ? { 1'b0, sss }: 4'd0;
				 8'h02:
					func_set_busb_to = (mcycle == 3'd1) ? 4'h7: 4'd0;
				 8'h12:
					func_set_busb_to = (mcycle == 3'd1) ? 4'h7: 4'd0;
				 8'h32:
					func_set_busb_to = (mcycle == 3'd3) ? 4'h7: 4'd0;
				 8'h22:
					func_set_busb_to = (mcycle == 3'd3 ) ? 4'h5: ((mcycle == 3'd4) ? 4'h4: 4'h0);
				 8'hC5, 8'hD5, 8'hE5, 8'hF5:
					if( mcycle == 3'd1 ) begin
						if( dpair == 2'b11 ) begin
							func_set_busb_to = 4'h7;
						end
						else begin
							func_set_busb_to = { 1'b0, dpair, 1'b0 };
						end
					end
					else if( mcycle == 3'd2 ) begin
						if( dpair == 2'b11 ) begin
							func_set_busb_to = 4'hB;
						end
						else begin
							func_set_busb_to = { 1'b0, dpair, 1'b1 };
						end
					end
					else begin
						func_set_busb_to = 4'h0;
					end
				 8'hE3:
					if( mcycle == 3'd2 ) begin
						func_set_busb_to = 4'h5;
					end
					else if( mcycle == 3'd4 ) begin
						func_set_busb_to = 4'h4;
					end
					else begin
						func_set_busb_to = 4'h0;
					end
				8'h04, 8'h0C, 8'h14, 8'h1C, 8'h24, 8'h2C, 8'h3C:
					func_set_busb_to = 4'hA;
				8'h34, 8'h35:
					if( mcycle == 3'd2 ) begin
						func_set_busb_to = 4'hA;
					end
					else begin
						func_set_busb_to = 4'h0;
					end
				8'h05, 8'h0D, 8'h15, 8'h1D, 8'h25, 8'h2D, 8'h3D:
					func_set_busb_to = 4'hA;
				8'h27:
					func_set_busb_to = 4'h0;
				8'h00:
					if( nmicycle || intcycle ) begin
						if( mcycle == 3'd1 ) begin
							func_set_busb_to = 4'hD;
						end
						else if( mcycle == 3'd2 ) begin
							func_set_busb_to = 4'hC;
						end
						else begin
							func_set_busb_to = 4'h0;
						end
					end
					else begin
						func_set_busb_to = 4'h0;
					end
				8'h09, 8'h19, 8'h29, 8'h39:
					if( mcycle == 3'd2 ) begin
						if( ir[5:4] == 0 || ir[5:4] == 1 || ir[5:4] == 2 ) begin
							func_set_busb_to = { 1'b0, ir[5:4], 1'b1 };
						end
						else begin
							func_set_busb_to = 4'h8;
						end
					end
					else if( mcycle == 3'd3 ) begin
						if( ir[5:4] == 0 || ir[5:4] == 1 || ir[5:4] == 2 ) begin
							func_set_busb_to = { 1'b0, ir[5:4], 1'b0 };
						end
						else begin
							func_set_busb_to = 4'h9;
						end
					end
					else begin
						func_set_busb_to = 4'h0;
					end
				8'h10:
					if( mcycle == 3'd1 ) begin
						func_set_busb_to = 4'hA;
					end
					else begin
						func_set_busb_to = 4'h0;
					end
				 8'hCD:
					if( mcycle == 3'd3 ) begin
						func_set_busb_to = 4'hD;
					end
					else if( mcycle == 3'd4 ) begin
						func_set_busb_to = 4'hC;
					end
					else begin
						func_set_busb_to = 4'h0;
					end
				 8'hC4, 8'hCC, 8'hD4, 8'hDC, 8'hE4, 8'hEC, 8'hF4, 8'hFC:
					if( mcycle == 3'd3 ) begin
						if( is_cc_true( f, ir[5:3] ) ) begin
							func_set_busb_to = 4'hD;
						end
						else begin
							func_set_busb_to = 4'h0;
						end
					end
					else if( mcycle == 3'd4 ) begin
						func_set_busb_to = 4'hC;
					end
					else begin
						func_set_busb_to = 4'h0;
					end
				 8'hC9:
					func_set_busb_to = 4'h0;
				 8'hC0, 8'hC8, 8'hD0, 8'hD8, 8'hE0, 8'hE8, 8'hF0, 8'hF8:
					func_set_busb_to = 4'h0;
				 8'hC7, 8'hCF, 8'hD7, 8'hDF, 8'hE7, 8'hEF, 8'hF7, 8'hFF:
					if( mcycle == 3'd1 ) begin
						func_set_busb_to = 4'hD;
					end
					else if( mcycle == 3'd2 ) begin
						func_set_busb_to = 4'hC;
					end
					else begin
						func_set_busb_to = 4'h0;
					end
				8'hD3:
					if( mcycle == 3'd2 ) begin
						func_set_busb_to = 4'h7;
					end
					else begin
						func_set_busb_to = 4'h0;
					end
				default:
					func_set_busb_to = 4'h0;
				endcase
			// --------------------------------------------------------------------
			//  CB prefixed instructions
			// --------------------------------------------------------------------
			2'b01:
				func_set_busb_to = { 1'b0, ir[2:0] };
			// --------------------------------------------------------------------
			//	ED prefixed instructions
			// --------------------------------------------------------------------
			default:
				case( irb )
				8'h43, 8'h53, 8'h63, 8'h73:
					if( mcycle == 3'd3 ) begin
						if( ir[5:4] == 2'b11 ) begin
							func_set_busb_to = 4'h8;
						end
						else begin
							func_set_busb_to = { 1'b0, ir[5:4], 1'b1 };
						end
					end
					else if( mcycle == 3'd4 ) begin
						if( ir[5:4] == 2'b11 ) begin
							func_set_busb_to = 4'h9;
						end
						else begin
							func_set_busb_to = { 1'b0, ir[5:4], 1'b0 };
						end
					end
					else begin
						func_set_busb_to = 4'h0;
					end
				8'hA0, 8'hA8, 8'hB0, 8'hB8, 8'hA1, 8'hA9, 8'hB1, 8'hB9:
					if( mcycle == 3'd2 ) begin
						func_set_busb_to = 4'h6;
					end
					else begin
						func_set_busb_to = 4'h0;
					end
				8'h44, 8'h4C, 8'h54, 8'h5C, 8'h64, 8'h6C, 8'h74, 8'h7C:
					func_set_busb_to = 4'h7;
				8'h4A, 8'h5A, 8'h6A, 8'h7A:
					if( mcycle == 3'd2 ) begin
						if( ir[5:4] == 3'd0 || ir[5:4] == 3'd1 || ir[5:4] == 3'd2 ) begin
							func_set_busb_to = { 1'b0, ir[5:4], 1'b1 };
						end
						else begin
							func_set_busb_to = 4'h8;
						end
					end
					else if( mcycle == 3'd3 ) begin
						if( ir[5:4] == 3'd0 || ir[5:4] == 3'd1 || ir[5:4] == 3'd2 ) begin
							func_set_busb_to = { 1'b0, ir[5:4], 1'b0 };
						end
						else begin
							func_set_busb_to = 4'h9;
						end
					end
					else begin
						func_set_busb_to = 4'h0;
					end
				 8'h42, 8'h52, 8'h62, 8'h72:
					if( mcycle == 3'd2 ) begin
						if( ir[5:4] == 3'd0 || ir[5:4] == 3'd1 || ir[5:4] == 3'd2 ) begin
							func_set_busb_to = { 1'b0, ir[5:4], 1'b1 };
						end
						else begin
							func_set_busb_to = 4'h8;
						end
					end
					else if( mcycle == 3'd3 ) begin
						if( ir[5:4] == 3'd0 || ir[5:4] == 3'd1 || ir[5:4] == 3'd2 ) begin
							func_set_busb_to = { 1'b0, ir[5:4], 1'b0 };
						end
						else begin
							func_set_busb_to = 4'h9;
						end
					end
					else begin
						func_set_busb_to = 4'h0;
					end
				 8'h6F:
					if( mcycle == 3'd3 ) begin
						func_set_busb_to = 4'd6;
					end
					else begin
						func_set_busb_to = 4'd0;
					end
				 8'h67:
					if( mcycle == 3'd3 ) begin
						func_set_busb_to = 4'd6;
					end
					else begin
						func_set_busb_to = 4'd0;
					end
				 8'h41, 8'h49, 8'h51, 8'h59, 8'h61, 8'h69, 8'h71, 8'h79:
					if( mcycle == 3'd1 ) begin
						func_set_busb_to	= { ( ir[5:3] == 3'd6 ), ir[5:3] };
					end
					else begin
						func_set_busb_to = 4'd0;
					end
				8'hA2, 8'hAA, 8'hB2, 8'hBA:
					if( mcycle == 3'd1 ) begin
						func_set_busb_to = 4'hA;
					end
					else if( mcycle == 3'd2 ) begin
						func_set_busb_to = 4'h6;
					end
					else begin
						func_set_busb_to = 4'h0;
					end
				8'hA3, 8'hAB, 8'hB3, 8'hBB:
					if( mcycle == 3'd1 ) begin
						func_set_busb_to = 4'hA;
					end
					else if( mcycle == 3'd2 ) begin
						func_set_busb_to = 4'h6;
					end
					else begin
						func_set_busb_to = 4'h0;
					end
				default:
					func_set_busb_to = 4'h0;
				endcase
			endcase
		end
	endfunction

	assign set_busb_to = func_set_busb_to( iset, mcycle, irb, ir, dpair );

	// --------------------------------------------------------------------
	//	BUSA
	// --------------------------------------------------------------------
	function [3:0] func_set_busa_to(
		input	[1:0]	iset,
		input	[2:0]	mcycle,
		input	[7:0]	irb,
		input	[7:0]	ir,
		input	[1:0]	dpair
	);
		case( iset )
		// --------------------------------------------------------------------
		//  unprefixed instructions
		// --------------------------------------------------------------------
		2'b00:
			case( irb )
			8'h40, 8'h41, 8'h42, 8'h43, 8'h44, 8'h45, 8'h47, 
			8'h48, 8'h49, 8'h4A, 8'h4B, 8'h4C, 8'h4D, 8'h4F, 
			8'h50, 8'h51, 8'h52, 8'h53, 8'h54, 8'h55, 8'h57, 
			8'h58, 8'h59, 8'h5A, 8'h5B, 8'h5C, 8'h5D, 8'h5F, 
			8'h60, 8'h61, 8'h62, 8'h63, 8'h64, 8'h65, 8'h67, 
			8'h68, 8'h69, 8'h6A, 8'h6B, 8'h6C, 8'h6D, 8'h6F, 
			8'h78, 8'h79, 8'h7A, 8'h7B, 8'h7C, 8'h7D, 8'h7F, 
			8'h04, 8'h0C, 8'h14, 8'h1C, 8'h24, 8'h2C, 8'h3C,
			8'h05, 8'h0D, 8'h15, 8'h1D, 8'h25, 8'h2D, 8'h3D:
				func_set_busa_to = { 1'b0, ddd };
			8'h06, 8'h0E, 8'h16, 8'h1E, 8'h26, 8'h2E, 8'h3E,
			8'h46, 8'h4E, 8'h56, 8'h5E, 8'h66, 8'h6E, 8'h7E:
				if( mcycle == 3'd2 ) begin
					func_set_busa_to = { 1'b0, ddd };
				end
				else begin
					func_set_busa_to = 4'h0;
				end
			8'h01, 8'h11, 8'h21, 8'h31:
				if( mcycle == 3'd2 ) begin
					if( dpair == 2'b11 ) begin
						func_set_busa_to = 4'h8;
					end
					else begin
						func_set_busa_to = { 1'b0, dpair, 1'b1 };
					end
				end
				else if( mcycle == 3'd3 ) begin
					if( dpair == 2'b11 ) begin
						func_set_busa_to = 4'h9;
					end
					else begin
						func_set_busa_to = { 1'b0, dpair, 1'b0 };
					end
				end
				else begin
					func_set_busa_to = 4'h0;
				end
			8'h2A:
				if( mcycle == 3'd4 ) begin
					func_set_busa_to = 4'd5;	// l
				end
				else if( mcycle == 3'd5 ) begin
					func_set_busa_to = 4'd4;	// h
				end
				else begin
					func_set_busa_to = 4'd0;
				end
			8'hC1, 8'hD1, 8'hE1, 8'hF1:
				if( mcycle == 3'd2 ) begin
					if( dpair == 2'b11 ) begin
						func_set_busa_to = 4'hB;
					end
					else begin
						func_set_busa_to = { 1'b0, dpair, 1'b1 };
					end
				end
				else if( mcycle == 3'd3 ) begin
					if( dpair == 2'b11 ) begin
						func_set_busa_to = 4'h7;
					end
					else begin
						func_set_busa_to = { 1'b0, dpair, 1'b0 };
					end
				end
				else begin
					func_set_busa_to = 4'h0;
				end
			8'hE3:
				if( mcycle == 3'd2 ) begin
					func_set_busa_to = 4'h5;
				end
				else if( mcycle == 3'd4 ) begin
					func_set_busa_to = 4'h4;
				end
				else begin
					func_set_busa_to = 4'h0;
				end
			8'h80, 8'h81, 8'h82, 8'h83, 8'h84, 8'h85, 8'h87, 
			8'h88, 8'h89, 8'h8A, 8'h8B, 8'h8C, 8'h8D, 8'h8F, 
			8'h90, 8'h91, 8'h92, 8'h93, 8'h94, 8'h95, 8'h97, 
			8'h98, 8'h99, 8'h9A, 8'h9B, 8'h9C, 8'h9D, 8'h9F, 
			8'hA0, 8'hA1, 8'hA2, 8'hA3, 8'hA4, 8'hA5, 8'hA7, 
			8'hA8, 8'hA9, 8'hAA, 8'hAB, 8'hAC, 8'hAD, 8'hAF, 
			8'hB0, 8'hB1, 8'hB2, 8'hB3, 8'hB4, 8'hB5, 8'hB7, 
			8'hB8, 8'hB9, 8'hBA, 8'hBB, 8'hBC, 8'hBD, 8'hBF,
			8'h07, 8'h17, 8'h0F, 8'h1F:
				func_set_busa_to = 4'd7;
			8'h86, 8'h8E, 8'h96, 8'h9E, 8'hA6, 8'hAE, 8'hB6, 8'hBE,
			8'hC6, 8'hCE, 8'hD6, 8'hDE, 8'hE6, 8'hEE, 8'hF6, 8'hFE:
				if( mcycle == 3'd2 ) begin
					func_set_busa_to = 4'd7;
				end
				else begin
					func_set_busa_to = 4'd0;
				end
			8'h34:
				if( mcycle == 3'd2 ) begin
					func_set_busa_to = { 1'b0, ddd };
				end
				else begin
					func_set_busa_to = 4'd0;
				end
			8'h35:
				if( mcycle == 3'd2 ) begin
					func_set_busa_to = { 1'b0, ddd };
				end
				else begin
					func_set_busa_to = 4'd0;
				end
			8'h27:
				func_set_busa_to = 4'd7;
			8'h09, 8'h19, 8'h29, 8'h39:
				if( mcycle == 3'd2 ) begin
					func_set_busa_to = 4'd5;
				end
				else if( mcycle == 3'd3 ) begin
					func_set_busa_to = 4'd4;
				end
				else begin
					func_set_busa_to = 4'd0;
				end
			default:
				func_set_busa_to = 4'd0;
			endcase
		// --------------------------------------------------------------------
		//  CB prefixed instructions
		// --------------------------------------------------------------------
		2'b01:
			func_set_busa_to = { 1'b0, ir[2:0] };
		// --------------------------------------------------------------------
		//	ED prefixed instructions
		// --------------------------------------------------------------------
		default:
			case( irb )
			8'h4B, 8'h5B, 8'h6B, 8'h7B:
				if( mcycle == 3'd4 ) begin
					if( ir[5:4] == 2'b11 ) begin
						func_set_busa_to = 4'h8;
					end
					else begin
						func_set_busa_to = { 1'b0, ir[5:4], 1'b1 };
					end
				end
				else if( mcycle == 3'd5 ) begin
					if( ir[5:4] == 2'b11 ) begin
						func_set_busa_to = 4'h9;
					end
					else begin
						func_set_busa_to = { 1'b0, ir[5:4], 1'b0 };
					end
				end
				else begin
					func_set_busa_to = 4'h0;
				end
			8'hA0, 8'hA8, 8'hB0, 8'hB8, 8'hA1, 8'hA9, 8'hB1, 8'hB9:
				if( mcycle == 3'd2 ) begin
					func_set_busa_to = 4'd7;
				end
				else begin
					func_set_busa_to = 4'd0;
				end
			8'h44, 8'h4C, 8'h54, 8'h5C, 8'h64, 8'h6C, 8'h74, 8'h7C:
				func_set_busa_to = 4'hA;
			8'h4A, 8'h5A, 8'h6A, 8'h7A, 8'h42, 8'h52, 8'h62, 8'h72:
				if( mcycle == 3'd2 ) begin
					func_set_busa_to = 4'd5;
				end
				else if( mcycle == 3'd3 ) begin
					func_set_busa_to = 4'd4;
				end
				else begin
					func_set_busa_to = 4'd0;
				end
			8'h6F:
				if( mcycle == 3'd3 ) begin
					func_set_busa_to = 4'd7;
				end
				else begin
					func_set_busa_to = 4'd0;
				end
			8'h67:
				if( mcycle == 3'd3 ) begin
					func_set_busa_to = 4'd7;
				end
				else begin
					func_set_busa_to = 4'd0;
				end
			8'h40, 8'h48, 8'h50, 8'h58, 8'h60, 8'h68, 8'h70, 8'h78:
				if( mcycle == 3'd2 ) begin
					if( ir[5:3] != 3'd6 ) begin
						func_set_busa_to = { 1'b0, ir[5:3] };
					end
					else begin
						func_set_busa_to = 4'd0;
					end
				end
				else begin
					func_set_busa_to = 4'h0;
				end
			default:
				func_set_busa_to = 4'h0;
			endcase
		endcase
	endfunction

	assign set_busa_to = func_set_busa_to( iset, mcycle, irb, ir, dpair );

	// --------------------------------------------------------------------
	//	ALU_OP
	// --------------------------------------------------------------------
	function [3:0] func_alu_op(
		input	[1:0]	iset,
		input	[2:0]	mcycle,
		input	[7:0]	irb,
		input	[5:3]	ir,
		input	[1:0]	xy_state
	);
		case( iset )
		// --------------------------------------------------------------------
		//  unprefixed instructions
		// --------------------------------------------------------------------
		2'b00:
			case( irb )
			8'h04, 8'h0C, 8'h14, 8'h1C, 8'h24, 8'h2C, 8'h3C:
				func_alu_op = 4'h0;
			8'h34:
				if( mcycle == 3'd2 ) begin
					func_alu_op = 4'h0;
				end
				else begin
					func_alu_op = { 1'b0, ir[5:3] };
				end
			8'h05, 8'h0D, 8'h15, 8'h1D, 8'h25, 8'h2D, 8'h3D:
				func_alu_op = 4'h2;
			8'h35:
				if( mcycle == 3'd2 ) begin
					func_alu_op = 4'h2;
				end
				else begin
					func_alu_op = { 1'b0, ir[5:3] };
				end
			8'h27:
				func_alu_op = 4'hC;
			8'h09, 8'h19, 8'h29, 8'h39:
				if( mcycle == 3'd2 ) begin
					func_alu_op = 4'h0;
				end
				else if( mcycle == 3'd3 ) begin
					func_alu_op = 4'h1;
				end
				else begin
					func_alu_op = { 1'b0, ir[5:3] };
				end
			8'h10:
				if( mcycle == 3'd1 ) begin
					func_alu_op = 4'h2;
				end
				else begin
					func_alu_op = { 1'b0, ir[5:3] };
				end
			8'h07, 8'h17, 8'h0F, 8'h1F:
				func_alu_op = 4'h8;
			default:
				func_alu_op = { 1'b0, ir[5:3] };
			endcase

		// --------------------------------------------------------------------
		//  cb prefixed instructions
		// --------------------------------------------------------------------
		2'b01:

			case( irb )
			8'h00, 8'h01, 8'h02, 8'h03, 8'h04, 8'h05, 8'h07, 
			8'h10, 8'h11, 8'h12, 8'h13, 8'h14, 8'h15, 8'h17, 
			8'h08, 8'h09, 8'h0A, 8'h0B, 8'h0C, 8'h0D, 8'h0F, 
			8'h18, 8'h19, 8'h1A, 8'h1B, 8'h1C, 8'h1D, 8'h1F, 
			8'h20, 8'h21, 8'h22, 8'h23, 8'h24, 8'h25, 8'h27, 
			8'h28, 8'h29, 8'h2A, 8'h2B, 8'h2C, 8'h2D, 8'h2F, 
			8'h30, 8'h31, 8'h32, 8'h33, 8'h34, 8'h35, 8'h37, 
			8'h38, 8'h39, 8'h3A, 8'h3B, 8'h3C, 8'h3D, 8'h3F:
				if( xy_state == 2'b00 ) begin
					if( mcycle == 3'd1 ) begin
						func_alu_op = 4'h8;
					end
					else begin
						func_alu_op = { 1'b0, ir[5:3] };
					end
				end
				else if( mcycle == 3'd2 ) begin
					func_alu_op = 4'h8;
				end
				else begin
					func_alu_op = { 1'b0, ir[5:3] };
				end
			8'h06, 8'h16, 8'h0E, 8'h1E, 8'h2E, 8'h3E, 8'h26, 8'h36:
				if( mcycle == 3'd2 ) begin
					func_alu_op = 4'h8;
				end
				else begin
					func_alu_op = { 1'b0, ir[5:3] };
				end
			8'h40, 8'h41, 8'h42, 8'h43, 8'h44, 8'h45, 8'h47, 
			8'h48, 8'h49, 8'h4A, 8'h4B, 8'h4C, 8'h4D, 8'h4F, 
			8'h50, 8'h51, 8'h52, 8'h53, 8'h54, 8'h55, 8'h57, 
			8'h58, 8'h59, 8'h5A, 8'h5B, 8'h5C, 8'h5D, 8'h5F, 
			8'h60, 8'h61, 8'h62, 8'h63, 8'h64, 8'h65, 8'h67, 
			8'h68, 8'h69, 8'h6A, 8'h6B, 8'h6C, 8'h6D, 8'h6F, 
			8'h70, 8'h71, 8'h72, 8'h73, 8'h74, 8'h75, 8'h77, 
			8'h78, 8'h79, 8'h7A, 8'h7B, 8'h7C, 8'h7D, 8'h7F:
				if( xy_state == 2'b00 ) begin
					if( mcycle == 3'd1 ) begin
						func_alu_op = 4'h9;
					end
					else begin
						func_alu_op = { 1'b0, ir[5:3] };
					end
				end
				else if( mcycle == 3'd2 ) begin
					func_alu_op = 4'h9;
				end
				else begin
					func_alu_op = { 1'b0, ir[5:3] };
				end
			8'h46, 8'h4E, 8'h56, 8'h5E, 8'h66, 8'h6E, 8'h76, 8'h7E:
				if( mcycle == 3'd2 ) begin
					func_alu_op = 4'h9;
				end
				else begin
					func_alu_op = { 1'b0, ir[5:3] };
				end
			8'hC0, 8'hC1, 8'hC2, 8'hC3, 8'hC4, 8'hC5, 8'hC7, 
			8'hC8, 8'hC9, 8'hCA, 8'hCB, 8'hCC, 8'hCD, 8'hCF, 
			8'hD0, 8'hD1, 8'hD2, 8'hD3, 8'hD4, 8'hD5, 8'hD7, 
			8'hD8, 8'hD9, 8'hDA, 8'hDB, 8'hDC, 8'hDD, 8'hDF, 
			8'hE0, 8'hE1, 8'hE2, 8'hE3, 8'hE4, 8'hE5, 8'hE7, 
			8'hE8, 8'hE9, 8'hEA, 8'hEB, 8'hEC, 8'hED, 8'hEF, 
			8'hF0, 8'hF1, 8'hF2, 8'hF3, 8'hF4, 8'hF5, 8'hF7, 
			8'hF8, 8'hF9, 8'hFA, 8'hFB, 8'hFC, 8'hFD, 8'hFF:
				if( xy_state == 2'b00 ) begin
					if( mcycle == 3'd1 ) begin
						func_alu_op = 4'hA;
					end
					else begin
						func_alu_op = { 1'b0, ir[5:3] };
					end
				end
				else if( mcycle == 3'd2 ) begin
					func_alu_op = 4'hA;
				end
				else begin
					func_alu_op = { 1'b0, ir[5:3] };
				end
			8'hC6, 8'hCE, 8'hD6, 8'hDE, 8'hE6, 8'hEE, 8'hF6, 8'hFE:
				if( mcycle == 3'd2 ) begin
					func_alu_op = 4'hA;
				end
				else begin
					func_alu_op = { 1'b0, ir[5:3] };
				end
			8'h80, 8'h81, 8'h82, 8'h83, 8'h84, 8'h85, 8'h87, 
			8'h88, 8'h89, 8'h8A, 8'h8B, 8'h8C, 8'h8D, 8'h8F, 
			8'h90, 8'h91, 8'h92, 8'h93, 8'h94, 8'h95, 8'h97, 
			8'h98, 8'h99, 8'h9A, 8'h9B, 8'h9C, 8'h9D, 8'h9F, 
			8'hA0, 8'hA1, 8'hA2, 8'hA3, 8'hA4, 8'hA5, 8'hA7, 
			8'hA8, 8'hA9, 8'hAA, 8'hAB, 8'hAC, 8'hAD, 8'hAF, 
			8'hB0, 8'hB1, 8'hB2, 8'hB3, 8'hB4, 8'hB5, 8'hB7, 
			8'hB8, 8'hB9, 8'hBA, 8'hBB, 8'hBC, 8'hBD, 8'hBF:
				if( xy_state == 2'b00 ) begin
					if( mcycle == 3'd1 ) begin
						func_alu_op = 4'hB;
					end
					else begin
						func_alu_op = { 1'b0, ir[5:3] };
					end
				end
				else if( mcycle == 3'd2 ) begin
					func_alu_op = 4'hB;
				end
				else begin
					func_alu_op = { 1'b0, ir[5:3] };
				end
			8'h86, 8'h8E, 8'h96, 8'h9E, 8'hA6, 8'hAE, 8'hB6, 8'hBE:
				if( mcycle == 3'd2 ) begin
					func_alu_op = 4'hB;
				end
				else begin
					func_alu_op = { 1'b0, ir[5:3] };
				end
			default:
				func_alu_op = { 1'b0, ir[5:3] };
			endcase

		// --------------------------------------------------------------------
		//	ED prefixed instructions
		// --------------------------------------------------------------------
		default:
			case( irb )
			8'hA0, 8'hA8, 8'hB0, 8'hB8:
				if( mcycle == 3'd2 ) begin
					func_alu_op = 4'h0;
				end
				else begin
					func_alu_op = { 1'b0, ir[5:3] };
				end
			8'hA1, 8'hA9, 8'hB1, 8'hB9:
				if( mcycle == 3'd2 ) begin
					func_alu_op = 4'h7;
				end
				else begin
					func_alu_op = { 1'b0, ir[5:3] };
				end
			8'h44, 8'h4C, 8'h54, 8'h5C, 8'h64, 8'h6C, 8'h74, 8'h7C:
				func_alu_op = 4'h2;
			8'h4A, 8'h5A, 8'h6A, 8'h7A:
				if( mcycle == 3'd2 || mcycle == 3'd3 ) begin
					func_alu_op = 4'h1;
				end
				else begin
					func_alu_op = { 1'b0, ir[5:3] };
				end
			8'h42, 8'h52, 8'h62, 8'h72:
				if( mcycle == 3'd2 || mcycle == 3'd3 ) begin
					func_alu_op = 4'h3;
				end
				else begin
					func_alu_op = { 1'b0, ir[5:3] };
				end
			8'h6F:
				if( mcycle == 3'd3 ) begin
					func_alu_op = 4'hD;
				end
				else begin
					func_alu_op = { 1'b0, ir[5:3] };
				end
			8'h67:
				if( mcycle == 3'd3 ) begin
					func_alu_op = 4'hE;
				end
				else begin
					func_alu_op = { 1'b0, ir[5:3] };
				end
			8'hA2, 8'hAA, 8'hB2, 8'hBA:
				if( mcycle == 3'd1 ) begin
					func_alu_op = 4'h2;
				end
				else begin
					func_alu_op = { 1'b0, ir[5:3] };
				end
			8'hA3, 8'hAB, 8'hB3, 8'hBB:
				if( mcycle == 3'd1 ) begin
					func_alu_op = 4'h2;
				end
				else begin
					func_alu_op = { 1'b0, ir[5:3] };
				end
			default:
				func_alu_op = { 1'b0, ir[5:3] };
			endcase
		endcase
	endfunction

	assign alu_op	= func_alu_op( iset, mcycle, irb, ir[5:3], xy_state );
	assign alu_cpi	= ( iset[1] == 1'b1 && mcycle == 3'd2 &&
			(irb == 8'hA1 || irb == 8'hA9 || irb == 8'hB1 || irb == 8'hB9) );

	// --------------------------------------------------------------------
	//	save_alu
	// --------------------------------------------------------------------
	function func_save_alu(
		input	[1:0]	iset,
		input	[2:0]	mcycle,
		input	[7:0]	irb,
		input	[1:0]	xy_state
	);
		case( iset )
		// --------------------------------------------------------------------
		//  unprefixed instructions
		// --------------------------------------------------------------------
		2'b00:
			case( irb )
			8'h80, 8'h81, 8'h82, 8'h83, 8'h84, 8'h85, 8'h87, 
			8'h88, 8'h89, 8'h8A, 8'h8B, 8'h8C, 8'h8D, 8'h8F, 
			8'h90, 8'h91, 8'h92, 8'h93, 8'h94, 8'h95, 8'h97, 
			8'h98, 8'h99, 8'h9A, 8'h9B, 8'h9C, 8'h9D, 8'h9F, 
			8'hA0, 8'hA1, 8'hA2, 8'hA3, 8'hA4, 8'hA5, 8'hA7, 
			8'hA8, 8'hA9, 8'hAA, 8'hAB, 8'hAC, 8'hAD, 8'hAF, 
			8'hB0, 8'hB1, 8'hB2, 8'hB3, 8'hB4, 8'hB5, 8'hB7, 
			8'hB8, 8'hB9, 8'hBA, 8'hBB, 8'hBC, 8'hBD, 8'hBF, 
			8'h04, 8'h0C, 8'h14, 8'h1C, 8'h24, 8'h2C, 8'h3C, 
			8'h05, 8'h0D, 8'h15, 8'h1D, 8'h25, 8'h2D, 8'h3D, 
			8'h27, 8'h07, 8'h17, 8'h0F, 8'h1F:
				func_save_alu = 1'b1;
			8'h86, 8'h8E, 8'h96, 8'h9E, 8'hA6, 8'hAE, 8'hB6, 8'hBE,
			8'hC6, 8'hCE, 8'hD6, 8'hDE, 8'hE6, 8'hEE, 8'hF6, 8'hFE,
			8'h34, 8'h35:
				func_save_alu = ( mcycle == 3'd2 );
			8'h09, 8'h19, 8'h29, 8'h39:
				func_save_alu = ( mcycle == 3'd2 || mcycle == 3'd3 );
			8'h10:
				func_save_alu = ( mcycle == 3'd1 );
			default:
				func_save_alu = 1'b0;
			endcase
		// --------------------------------------------------------------------
		//  cb prefixed instructions
		// --------------------------------------------------------------------
		2'b01:
			case( irb )
			8'h00, 8'h01, 8'h02, 8'h03, 8'h04, 8'h05, 8'h07, 
			8'h08, 8'h09, 8'h0A, 8'h0B, 8'h0C, 8'h0D, 8'h0F, 
			8'h10, 8'h11, 8'h12, 8'h13, 8'h14, 8'h15, 8'h17, 
			8'h18, 8'h19, 8'h1A, 8'h1B, 8'h1C, 8'h1D, 8'h1F, 
			8'h20, 8'h21, 8'h22, 8'h23, 8'h24, 8'h25, 8'h27, 
			8'h28, 8'h29, 8'h2A, 8'h2B, 8'h2C, 8'h2D, 8'h2F, 
			8'h30, 8'h31, 8'h32, 8'h33, 8'h34, 8'h35, 8'h37, 
			8'h38, 8'h39, 8'h3A, 8'h3B, 8'h3C, 8'h3D, 8'h3F, 
			8'h80, 8'h81, 8'h82, 8'h83, 8'h84, 8'h85, 8'h87, 
			8'h88, 8'h89, 8'h8A, 8'h8B, 8'h8C, 8'h8D, 8'h8F, 
			8'h90, 8'h91, 8'h92, 8'h93, 8'h94, 8'h95, 8'h97, 
			8'h98, 8'h99, 8'h9A, 8'h9B, 8'h9C, 8'h9D, 8'h9F, 
			8'hA0, 8'hA1, 8'hA2, 8'hA3, 8'hA4, 8'hA5, 8'hA7, 
			8'hA8, 8'hA9, 8'hAA, 8'hAB, 8'hAC, 8'hAD, 8'hAF, 
			8'hB0, 8'hB1, 8'hB2, 8'hB3, 8'hB4, 8'hB5, 8'hB7, 
			8'hB8, 8'hB9, 8'hBA, 8'hBB, 8'hBC, 8'hBD, 8'hBF, 
			8'hC0, 8'hC1, 8'hC2, 8'hC3, 8'hC4, 8'hC5, 8'hC7, 
			8'hC8, 8'hC9, 8'hCA, 8'hCB, 8'hCC, 8'hCD, 8'hCF, 
			8'hD0, 8'hD1, 8'hD2, 8'hD3, 8'hD4, 8'hD5, 8'hD7, 
			8'hD8, 8'hD9, 8'hDA, 8'hDB, 8'hDC, 8'hDD, 8'hDF, 
			8'hE0, 8'hE1, 8'hE2, 8'hE3, 8'hE4, 8'hE5, 8'hE7, 
			8'hE8, 8'hE9, 8'hEA, 8'hEB, 8'hEC, 8'hED, 8'hEF, 
			8'hF0, 8'hF1, 8'hF2, 8'hF3, 8'hF4, 8'hF5, 8'hF7, 
			8'hF8, 8'hF9, 8'hFA, 8'hFB, 8'hFC, 8'hFD, 8'hFF:
				if( xy_state == 2'b00 ) begin
					func_save_alu = ( mcycle == 3'd1 );
				end
				else begin
					func_save_alu = ( mcycle == 3'd2 );
				end
			8'h06, 8'h16, 8'h0E, 8'h1E, 8'h2E, 8'h3E, 8'h26, 8'h36, 
			8'hC6, 8'hCE, 8'hD6, 8'hDE, 8'hE6, 8'hEE, 8'hF6, 8'hFE, 
			8'h86, 8'h8E, 8'h96, 8'h9E, 8'hA6, 8'hAE, 8'hB6, 8'hBE:
				func_save_alu = ( mcycle == 3'd2 );
			default:
				func_save_alu = 1'b0;
			endcase
		// --------------------------------------------------------------------
		//	ED prefixed instructions
		// --------------------------------------------------------------------
		default:
			case( irb )
			8'hA1, 8'hA9, 8'hB1, 8'hB9:
				func_save_alu = (mcycle == 3'd2);
			8'h44, 8'h4C, 8'h54, 8'h5C, 8'h64, 8'h6C, 8'h74, 8'h7C:
				func_save_alu = 1'b1;
			8'h4A, 8'h5A, 8'h6A, 8'h7A, 8'h42, 8'h52, 8'h62, 8'h72:
				func_save_alu = (mcycle == 3'd2 || mcycle == 3'd3);
			8'h6F, 8'h67:
				func_save_alu = (mcycle == 3'd3);
			8'hA2, 8'hAA, 8'hB2, 8'hBA, 8'hA3, 8'hAB, 8'hB3, 8'hBB:
				func_save_alu = (mcycle == 3'd1);
			default:
				func_save_alu = 1'b0;
			endcase
		endcase
	endfunction

	assign save_alu = func_save_alu( iset, mcycle, irb, xy_state );

	// --------------------------------------------------------------------
	//	preserve C
	// --------------------------------------------------------------------
	function func_preservec(
		input	[1:0]	iset,
		input	[2:0]	mcycle,
		input	[7:0]	irb
	);
		case( iset )
		// --------------------------------------------------------------------
		//  unprefixed instructions
		// --------------------------------------------------------------------
		2'b00:
			case( irb )
			8'h04, 8'h0C, 8'h14, 8'h1C, 8'h24, 8'h2C, 8'h3C,
			8'h05, 8'h0D, 8'h15, 8'h1D, 8'h25, 8'h2D, 8'h3D:
				func_preservec = 1'b1;
			8'h34, 8'h35:
				func_preservec = ( mcycle == 3'd2 );
			default:
				func_preservec = 1'b0;
			endcase
		2'b01:
			func_preservec = 1'b0;
		default:
		// --------------------------------------------------------------------
		//  cb prefixed instructions
		// --------------------------------------------------------------------
			case( irb )
			8'hA1, 8'hA9, 8'hB1, 8'hB9:
				func_preservec = ( mcycle == 3'd2 );
			default:
				func_preservec = 1'b0;
			endcase
		endcase
	endfunction

	assign preservec = func_preservec( iset, mcycle, irb );

	// --------------------------------------------------------------------
	//	Set address
	// --------------------------------------------------------------------
	function [2:0] func_set_addr_to(
		input	[1:0]	iset,
		input	[2:0]	mcycle,
		input	[7:0]	irb,
		input	[7:0]	f,
		input	[5:3]	ir,
		input			nmicycle,
		input			intcycle,
		input	[1:0]	xy_state
	);
		if( mcycle == 3'd6 && (irb == 8'h36 || irb == 8'hCB) ) begin
			func_set_addr_to = anone;
		end
		else if( mcycle == 3'd7 && iset != 2'b01 ) begin
			func_set_addr_to = axy;
		end
		else begin
			case( iset )
			// --------------------------------------------------------------------
			//  unprefixed instructions
			// --------------------------------------------------------------------
			2'b00:
				case( irb )
				8'h46, 8'h4E, 8'h56, 8'h5E, 8'h66, 8'h6E, 8'h7E,
				8'h70, 8'h71, 8'h72, 8'h73, 8'h74, 8'h75, 8'h77,
				8'h86, 8'h8E, 8'h96, 8'h9E, 8'hA6, 8'hAE, 8'hB6, 8'hBE:
					func_set_addr_to = ( mcycle == 3'd1 ) ? axy: anone;
				8'h36:
					func_set_addr_to = ( mcycle == 3'd2 ) ? axy: anone;
				8'h0A, 8'h02:
					func_set_addr_to = ( mcycle == 3'd1 ) ? abc: anone;
				8'h1A, 8'h12:
					func_set_addr_to = ( mcycle == 3'd1 ) ? ade: anone;
				8'h3A, 8'h32:
					func_set_addr_to = ( mcycle == 3'd3 ) ? azi: anone;
				8'h2A, 8'h22:
					func_set_addr_to = ( mcycle == 3'd3 || mcycle == 3'd4 ) ? azi: anone;
				8'hC5, 8'hD5, 8'hE5, 8'hF5, 8'hC1, 8'hD1, 8'hE1, 8'hF1, 8'hC9,
				8'hC7, 8'hCF, 8'hD7, 8'hDF, 8'hE7, 8'hEF, 8'hF7, 8'hFF:
					func_set_addr_to = ( mcycle == 3'd1 || mcycle == 3'd2 ) ? asp: anone;
				8'hE3:
					func_set_addr_to = ( mcycle == 3'd1 || mcycle == 3'd2 || mcycle == 3'd3 || mcycle == 3'd4 ) ? asp: anone;
				8'h34, 8'h35:
					func_set_addr_to = ( mcycle == 3'd1 || mcycle == 3'd2 ) ? axy: anone;
				8'h00:
					func_set_addr_to = ( (nmicycle || intcycle) && (mcycle == 3'd1 || mcycle == 3'd2) ) ? asp: anone;
				8'hCD:
					func_set_addr_to = ( mcycle == 3'd3 || mcycle == 3'd4 ) ? asp: anone;
				8'hC4, 8'hCC, 8'hD4, 8'hDC, 8'hE4, 8'hEC, 8'hF4, 8'hFC:
					if( mcycle == 3'd3 ) begin
						if( is_cc_true( f, ir[5:3]) ) begin
							func_set_addr_to = asp;
						end
						else begin
							func_set_addr_to = anone;
						end
					end
					else if( mcycle == 3'd4 ) begin
						func_set_addr_to = asp;
					end
					else begin
						func_set_addr_to = anone;
					end
				8'hC0, 8'hC8, 8'hD0, 8'hD8, 8'hE0, 8'hE8, 8'hF0, 8'hF8:
					if( mcycle == 3'd1 ) begin
						if( is_cc_true( f, ir[5:3]) ) begin
							func_set_addr_to = asp;
						end
						else begin
							func_set_addr_to = anone;
						end
					end
					else if( mcycle == 3'd2 ) begin
						func_set_addr_to = asp;
					end
					else begin
						func_set_addr_to = anone;
					end
				8'hDB, 8'hD3:
					func_set_addr_to = ( mcycle == 3'd2 ) ? aioa: anone;
				default:
					func_set_addr_to = anone;
				endcase
			// --------------------------------------------------------------------
			//  cb prefixed instructions
			// --------------------------------------------------------------------
			2'b01:
				case( irb )
				8'h00, 8'h01, 8'h02, 8'h03, 8'h04, 8'h05, 8'h07, 
				8'h10, 8'h11, 8'h12, 8'h13, 8'h14, 8'h15, 8'h17, 
				8'h08, 8'h09, 8'h0A, 8'h0B, 8'h0C, 8'h0D, 8'h0F, 
				8'h18, 8'h19, 8'h1A, 8'h1B, 8'h1C, 8'h1D, 8'h1F, 
				8'h20, 8'h21, 8'h22, 8'h23, 8'h24, 8'h25, 8'h27, 
				8'h28, 8'h29, 8'h2A, 8'h2B, 8'h2C, 8'h2D, 8'h2F, 
				8'h30, 8'h31, 8'h32, 8'h33, 8'h34, 8'h35, 8'h37, 
				8'h38, 8'h39, 8'h3A, 8'h3B, 8'h3C, 8'h3D, 8'h3F, 
				8'hC0, 8'hC1, 8'hC2, 8'hC3, 8'hC4, 8'hC5, 8'hC7, 
				8'hC8, 8'hC9, 8'hCA, 8'hCB, 8'hCC, 8'hCD, 8'hCF, 
				8'hD0, 8'hD1, 8'hD2, 8'hD3, 8'hD4, 8'hD5, 8'hD7, 
				8'hD8, 8'hD9, 8'hDA, 8'hDB, 8'hDC, 8'hDD, 8'hDF, 
				8'hE0, 8'hE1, 8'hE2, 8'hE3, 8'hE4, 8'hE5, 8'hE7, 
				8'hE8, 8'hE9, 8'hEA, 8'hEB, 8'hEC, 8'hED, 8'hEF, 
				8'hF0, 8'hF1, 8'hF2, 8'hF3, 8'hF4, 8'hF5, 8'hF7, 
				8'hF8, 8'hF9, 8'hFA, 8'hFB, 8'hFC, 8'hFD, 8'hFF, 
				8'h80, 8'h81, 8'h82, 8'h83, 8'h84, 8'h85, 8'h87, 
				8'h88, 8'h89, 8'h8A, 8'h8B, 8'h8C, 8'h8D, 8'h8F, 
				8'h90, 8'h91, 8'h92, 8'h93, 8'h94, 8'h95, 8'h97, 
				8'h98, 8'h99, 8'h9A, 8'h9B, 8'h9C, 8'h9D, 8'h9F, 
				8'hA0, 8'hA1, 8'hA2, 8'hA3, 8'hA4, 8'hA5, 8'hA7, 
				8'hA8, 8'hA9, 8'hAA, 8'hAB, 8'hAC, 8'hAD, 8'hAF, 
				8'hB0, 8'hB1, 8'hB2, 8'hB3, 8'hB4, 8'hB5, 8'hB7, 
				8'hB8, 8'hB9, 8'hBA, 8'hBB, 8'hBC, 8'hBD, 8'hBF:
					if( xy_state != 2'b00 ) begin
						func_set_addr_to = ( mcycle == 3'd1 || mcycle == 3'd2 || mcycle == 3'd7 ) ? axy: anone;
					end
					else begin
						func_set_addr_to = anone;
					end
				8'h06, 8'h16, 8'h26, 8'h36, 8'h0E, 8'h1E, 8'h2E, 8'h3E:
					func_set_addr_to = ( mcycle == 3'd1 || mcycle == 3'd2 || mcycle == 3'd7 ) ? axy: anone;
				8'h40, 8'h41, 8'h42, 8'h43, 8'h44, 8'h45, 8'h47, 
				8'h48, 8'h49, 8'h4A, 8'h4B, 8'h4C, 8'h4D, 8'h4F, 
				8'h50, 8'h51, 8'h52, 8'h53, 8'h54, 8'h55, 8'h57, 
				8'h58, 8'h59, 8'h5A, 8'h5B, 8'h5C, 8'h5D, 8'h5F, 
				8'h60, 8'h61, 8'h62, 8'h63, 8'h64, 8'h65, 8'h67, 
				8'h68, 8'h69, 8'h6A, 8'h6B, 8'h6C, 8'h6D, 8'h6F, 
				8'h70, 8'h71, 8'h72, 8'h73, 8'h74, 8'h75, 8'h77, 
				8'h78, 8'h79, 8'h7A, 8'h7B, 8'h7C, 8'h7D, 8'h7F:
					if( xy_state != 2'b00 ) begin
						func_set_addr_to = ( mcycle == 3'd1 || mcycle == 3'd7 ) ? axy: anone;
					end
					else begin
						func_set_addr_to = anone;
					end
				8'h46, 8'h4E, 8'h56, 8'h5E, 8'h66, 8'h6E, 8'h76, 8'h7E:
					func_set_addr_to = ( mcycle == 3'd1 || mcycle == 3'd7 ) ? axy: anone;
				8'hC6, 8'hCE, 8'hD6, 8'hDE, 8'hE6, 8'hEE, 8'hF6, 8'hFE,
				8'h86, 8'h8E, 8'h96, 8'h9E, 8'hA6, 8'hAE, 8'hB6, 8'hBE:
					func_set_addr_to = ( mcycle == 3'd1 || mcycle == 3'd2 || mcycle == 3'd7 ) ? axy: anone;
				default:
					func_set_addr_to = anone;
				endcase
			// --------------------------------------------------------------------
			//	ED prefixed instructions
			// --------------------------------------------------------------------
			default:
				case( irb )
				8'h4B, 8'h5B, 8'h6B, 8'h7B, 8'h43, 8'h53, 8'h63, 8'h73:
					func_set_addr_to = ( mcycle == 3'd3 || mcycle == 3'd4 ) ? azi: anone;
				8'hA0, 8'hA8, 8'hB0, 8'hB8:
					func_set_addr_to = ( mcycle == 3'd1 ) ? axy:
									   ( mcycle == 3'd2 ) ? ade: anone;
				8'hA1, 8'hA9, 8'hB1, 8'hB9:
					func_set_addr_to = ( mcycle == 3'd1 ) ? axy: anone;
				8'h6F, 8'h67:
					func_set_addr_to = ( mcycle == 3'd2 || mcycle == 3'd3 ) ? axy: anone;
				8'h45, 8'h4D, 8'h55, 8'h5D, 8'h65, 8'h6D, 8'h75, 8'h7D:
					func_set_addr_to = ( mcycle == 3'd1 || mcycle == 3'd2 ) ? asp: anone;
				8'h40, 8'h48, 8'h50, 8'h58, 8'h60, 8'h68, 8'h70, 8'h78,
				8'h41, 8'h49, 8'h51, 8'h59, 8'h61, 8'h69, 8'h71, 8'h79:
					func_set_addr_to = ( mcycle == 3'd1 ) ? abc: anone;
				8'hA2, 8'hAA, 8'hB2, 8'hBA:
					func_set_addr_to = ( mcycle == 3'd1 ) ? abc:
									   ( mcycle == 3'd2 ) ? axy: anone;
				8'hA3, 8'hAB, 8'hB3, 8'hBB:
					func_set_addr_to = ( mcycle == 3'd1 ) ? axy:
									   ( mcycle == 3'd2 ) ? abc: anone;
				default:
					func_set_addr_to = anone;
				endcase
			endcase
		end
	endfunction

	assign set_addr_to = func_set_addr_to( iset, mcycle, irb, f, ir[5:3], nmicycle, intcycle, xy_state );

	// --------------------------------------------------------------------
	//	no read
	// --------------------------------------------------------------------
	function func_noread(
		input	[1:0]	iset,
		input	[2:0]	mcycle,
		input	[7:0]	irb
	);
		if( mcycle == 3'd7 ) begin
			if( irb != 8'h36 && iset != 2'b01 ) begin
				func_noread = 1'b1;
			end
			else begin
				func_noread = 1'b0;
			end
		end
		else begin
			case( iset )
			// --------------------------------------------------------------------
			//  unprefixed instructions
			// --------------------------------------------------------------------
			2'b00:
				case( irb )
				8'h09, 8'h19, 8'h29, 8'h39:
					func_noread = ( mcycle == 3'd2 || mcycle == 3'd3 );
				8'h18, 8'h38, 8'h30, 8'h28, 8'h20, 8'h10:
					func_noread = ( mcycle == 3'd3 );
				default:
					func_noread = 1'b0;
				endcase
			// --------------------------------------------------------------------
			//  cb prefixed instructions
			// --------------------------------------------------------------------
			2'b01:
				func_noread = 1'b0;
			default:
				case( irb )
				8'hA0, 8'hA8, 8'hB0, 8'hB8, 8'hA2, 8'hAA, 8'hB2, 8'hBA,
				8'hA3, 8'hAB, 8'hB3, 8'hBB:
					func_noread = ( mcycle == 3'd4 );
				8'hA1, 8'hA9, 8'hB1, 8'hB9:
					func_noread = ( mcycle == 3'd3 || mcycle == 3'd4 );
				8'h42, 8'h52, 8'h62, 8'h72, 8'h4A, 8'h5A, 8'h6A, 8'h7A:
					func_noread = ( mcycle == 3'd2 || mcycle == 3'd3 );
				8'h6F:
					func_noread = ( mcycle == 3'd2 );
				default:
					func_noread = 1'b0;
				endcase
			endcase
		end
	endfunction

	assign noread	= func_noread( iset, mcycle, irb );

	// --------------------------------------------------------------------
	//	JUMP
	// --------------------------------------------------------------------
	function func_jump(
		input	[1:0]	iset,
		input	[2:0]	mcycle,
		input	[7:0]	irb,
		input	[7:0]	f,
		input	[5:3]	ir,
		input			nmicycle,
		input			intcycle
	);
		case( iset )
		// --------------------------------------------------------------------
		//  unprefixed instructions
		// --------------------------------------------------------------------
		2'b00:
			case( irb )
			8'h00:
				func_jump = ( !nmicycle && intcycle && mcycle == 3'd5 );
			8'hC3, 8'hC9,
			8'hC0, 8'hC8, 8'hD0, 8'hD8, 8'hE0, 8'hE8, 8'hF0, 8'hF8:
				func_jump = ( mcycle == 3'd3 );
			8'hC2, 8'hCA, 8'hD2, 8'hDA, 8'hE2, 8'hEA, 8'hF2, 8'hFA:
				func_jump = ( mcycle == 3'd3 && is_cc_true( f, ir[5:3] ) );
			default:
				func_jump = 1'b0;
			endcase
		// --------------------------------------------------------------------
		//  cb prefixed instructions
		// --------------------------------------------------------------------
		2'b01:
			func_jump = 1'b0;
		// --------------------------------------------------------------------
		//	ED prefixed instructions
		// --------------------------------------------------------------------
		default:
			case( irb )
			8'h45, 8'h4D, 8'h55, 8'h5D, 8'h65, 8'h6D, 8'h75, 8'h7D:
				func_jump = ( mcycle == 3'd3 );
			default:
				func_jump = 1'b0;
			endcase
		endcase
	endfunction

	assign jump = func_jump( iset, mcycle, irb, f, ir[5:3], nmicycle, intcycle );

	// --------------------------------------------------------------------
	//	JUMPE
	// --------------------------------------------------------------------
	function func_jumpe(
		input	[1:0]	iset,
		input	[2:0]	mcycle,
		input	[7:0]	irb
	);
		case( iset )
		// --------------------------------------------------------------------
		//  unprefixed instructions
		// --------------------------------------------------------------------
		2'b00:
			case( irb )
			8'h18, 8'h38, 8'h30, 8'h28, 8'h20, 8'h10:
				func_jumpe = ( mcycle == 3'd3 );
			default:
				func_jumpe = 1'b0;
			endcase
		// --------------------------------------------------------------------
		//	CB, ED prefixed instructions
		// --------------------------------------------------------------------
		default:
			func_jumpe = 1'b0;
		endcase
	endfunction

	assign jumpe = func_jumpe( iset, mcycle, irb );

	// --------------------------------------------------------------------
	//	call
	// --------------------------------------------------------------------
	function func_call(
		input	[1:0]	iset,
		input	[2:0]	mcycle,
		input	[7:0]	irb
	);
		if( iset == 2'b00 ) begin
			case( irb )
			8'hCD, 8'hC4, 8'hCC, 8'hD4, 8'hDC, 8'hE4, 8'hEC, 8'hF4, 8'hFC:
				func_call = ( mcycle == 3'd5 );
			default:
				func_call = 1'b0;
			endcase
		end
		else begin
			func_call = 1'b0;
		end
	endfunction

	assign call = func_call( iset, mcycle, irb );

	// --------------------------------------------------------------------
	//	write
	// --------------------------------------------------------------------
	function func_write(
		input	[1:0]	iset,
		input	[2:0]	mcycle,
		input	[7:0]	irb,
		input	[1:0]	xy_state
	);
		case( iset )
		// --------------------------------------------------------------------
		//  unprefixed instructions
		// --------------------------------------------------------------------
		2'b00:
			case( irb )
			8'h70, 8'h71, 8'h72, 8'h73, 8'h74, 8'h75, 8'h77,
			8'h02, 8'h12:
				func_write = ( mcycle == 3'd2 );
			8'h36, 8'h34, 8'h35, 8'hD3:
				func_write = ( mcycle == 3'd3 );
			8'h32:
				func_write = ( mcycle == 3'd4 );
			8'h22, 8'hCD, 8'hC4, 8'hCC, 8'hD4, 8'hDC, 8'hE4, 8'hEC, 8'hF4, 8'hFC:
				func_write = ( mcycle == 3'd4 || mcycle == 3'd5 );
			8'hC5, 8'hD5, 8'hE5, 8'hF5, 8'hC7, 8'hCF, 8'hD7, 8'hDF, 8'hE7, 8'hEF, 8'hF7, 8'hFF:
				func_write = ( mcycle == 3'd2 || mcycle == 3'd3 );
			8'hE3:
				func_write = ( mcycle == 3'd3 || mcycle == 3'd5 );
			8'h00:
				if( nmicycle || intcycle ) begin
					func_write = ( mcycle == 3'd2 || mcycle == 3'd3 );
				end
				else begin
					func_write = 1'b0;
				end
			default:
				func_write = 1'b0;
			endcase
		// --------------------------------------------------------------------
		//  cb prefixed instructions
		// --------------------------------------------------------------------
		2'b01:
			case( irb )
			8'h00, 8'h01, 8'h02, 8'h03, 8'h04, 8'h05, 8'h07, 
			8'h10, 8'h11, 8'h12, 8'h13, 8'h14, 8'h15, 8'h17, 
			8'h08, 8'h09, 8'h0A, 8'h0B, 8'h0C, 8'h0D, 8'h0F, 
			8'h18, 8'h19, 8'h1A, 8'h1B, 8'h1C, 8'h1D, 8'h1F, 
			8'h20, 8'h21, 8'h22, 8'h23, 8'h24, 8'h25, 8'h27, 
			8'h28, 8'h29, 8'h2A, 8'h2B, 8'h2C, 8'h2D, 8'h2F, 
			8'h30, 8'h31, 8'h32, 8'h33, 8'h34, 8'h35, 8'h37, 
			8'h38, 8'h39, 8'h3A, 8'h3B, 8'h3C, 8'h3D, 8'h3F, 
			8'hC0, 8'hC1, 8'hC2, 8'hC3, 8'hC4, 8'hC5, 8'hC7, 
			8'hC8, 8'hC9, 8'hCA, 8'hCB, 8'hCC, 8'hCD, 8'hCF, 
			8'hD0, 8'hD1, 8'hD2, 8'hD3, 8'hD4, 8'hD5, 8'hD7, 
			8'hD8, 8'hD9, 8'hDA, 8'hDB, 8'hDC, 8'hDD, 8'hDF, 
			8'hE0, 8'hE1, 8'hE2, 8'hE3, 8'hE4, 8'hE5, 8'hE7, 
			8'hE8, 8'hE9, 8'hEA, 8'hEB, 8'hEC, 8'hED, 8'hEF, 
			8'hF0, 8'hF1, 8'hF2, 8'hF3, 8'hF4, 8'hF5, 8'hF7, 
			8'hF8, 8'hF9, 8'hFA, 8'hFB, 8'hFC, 8'hFD, 8'hFF, 
			8'h80, 8'h81, 8'h82, 8'h83, 8'h84, 8'h85, 8'h87, 
			8'h88, 8'h89, 8'h8A, 8'h8B, 8'h8C, 8'h8D, 8'h8F, 
			8'h90, 8'h91, 8'h92, 8'h93, 8'h94, 8'h95, 8'h97, 
			8'h98, 8'h99, 8'h9A, 8'h9B, 8'h9C, 8'h9D, 8'h9F, 
			8'hA0, 8'hA1, 8'hA2, 8'hA3, 8'hA4, 8'hA5, 8'hA7, 
			8'hA8, 8'hA9, 8'hAA, 8'hAB, 8'hAC, 8'hAD, 8'hAF, 
			8'hB0, 8'hB1, 8'hB2, 8'hB3, 8'hB4, 8'hB5, 8'hB7, 
			8'hB8, 8'hB9, 8'hBA, 8'hBB, 8'hBC, 8'hBD, 8'hBF:
				if( xy_state != 2'b00 ) begin
					func_write = ( mcycle == 3'd3 );
				end
				else begin
					func_write = 1'b0;
				end
			8'h06, 8'h16, 8'h0E, 8'h1E, 8'h2E, 8'h3E, 8'h26, 8'h36,
			8'hC6, 8'hCE, 8'hD6, 8'hDE, 8'hE6, 8'hEE, 8'hF6, 8'hFE,
			8'h86, 8'h8E, 8'h96, 8'h9E, 8'hA6, 8'hAE, 8'hB6, 8'hBE:
				func_write = ( mcycle == 3'd3 );
			default:
				func_write = 1'b0;
			endcase
		// --------------------------------------------------------------------
		//	ED prefixed instructions
		// --------------------------------------------------------------------
		default:
			case( irb )
			8'h43, 8'h53, 8'h63, 8'h73:
				func_write = ( mcycle == 3'd4 || mcycle == 3'd5 );
			8'hA0, 8'hA8, 8'hB0, 8'hB8, 8'hA2, 8'hAA, 8'hB2, 8'hBA,
			8'hA3, 8'hAB, 8'hB3, 8'hBB:
				func_write = ( mcycle == 3'd3 );
			8'h6F, 8'h67:
				func_write = ( mcycle == 3'd4 );
			8'h41, 8'h49, 8'h51, 8'h59, 8'h61, 8'h69, 8'h71, 8'h79:
				func_write = ( mcycle == 3'd2 );
			default:
				func_write = 1'b0;
			endcase
		endcase
	endfunction

	assign write = func_write( iset, mcycle, irb, xy_state );

	// --------------------------------------------------------------------
	//	ldz
	// --------------------------------------------------------------------
	function func_ldz(
		input	[1:0]	iset,
		input	[2:0]	mcycle,
		input	[7:0]	irb,
		input			nmicycle,
		input			intcycle
	);
		case( iset )
		// --------------------------------------------------------------------
		//  unprefixed instructions
		// --------------------------------------------------------------------
		2'b00:
			case( irb )
			8'h3A, 8'h32, 8'h2A, 8'h22, 8'hC3, 8'hC9, 8'hCD,
			8'hC2, 8'hCA, 8'hD2, 8'hDA, 8'hE2, 8'hEA, 8'hF2, 8'hFA,
			8'hC4, 8'hCC, 8'hD4, 8'hDC, 8'hE4, 8'hEC, 8'hF4, 8'hFC,
			8'hC0, 8'hC8, 8'hD0, 8'hD8, 8'hE0, 8'hE8, 8'hF0, 8'hF8:
				func_ldz = ( mcycle == 3'd2 );
			8'h00:
				func_ldz = ( !nmicycle && intcycle && (mcycle == 3'd1 || mcycle == 3'd4) );
			default:
				func_ldz = 1'b0;
			endcase
		// --------------------------------------------------------------------
		//  CD prefixed instructions
		// --------------------------------------------------------------------
		2'b01:
			func_ldz = 1'b0;
		// --------------------------------------------------------------------
		//	ED prefixed instructions
		// --------------------------------------------------------------------
		default:
			case( irb )
			8'h4B, 8'h5B, 8'h6B, 8'h7B, 8'h43, 8'h53, 8'h63, 8'h73,
			8'h45, 8'h4D, 8'h55, 8'h5D, 8'h65, 8'h6D, 8'h75, 8'h7D:
				func_ldz = ( mcycle == 3'd2 );
			default:
				func_ldz = 1'b0;
			endcase
		endcase
	endfunction

	assign ldz	= func_ldz( iset, mcycle, irb, nmicycle, intcycle );

	// --------------------------------------------------------------------
	//	retn
	// --------------------------------------------------------------------
	function func_i_retn(
		input	[1:0]	iset,
		input	[2:0]	mcycle,
		input	[7:0]	irb
	);
		case( iset )
		// --------------------------------------------------------------------
		//  unprefixed/CB prefixed instructions
		// --------------------------------------------------------------------
		2'b00, 2'b01:
			func_i_retn = 1'b0;
		// --------------------------------------------------------------------
		//	ED prefixed instructions
		// --------------------------------------------------------------------
		default:
			case( irb )
			8'h45, 8'h4D, 8'h55, 8'h5D, 8'h65, 8'h6D, 8'h75, 8'h7D:
				func_i_retn = ( mcycle == 3'd3 );
			default:
				func_i_retn = 1'b0;
			endcase
		endcase
	endfunction

	assign i_retn = func_i_retn( iset, mcycle, irb );

	// --------------------------------------------------------------------
	//	ldw
	// --------------------------------------------------------------------
	function func_ldw(
		input	[1:0]	iset,
		input	[2:0]	mcycle,
		input	[7:0]	irb
	);
		case( iset )
		// --------------------------------------------------------------------
		//  unprefixed instructions
		// --------------------------------------------------------------------
		2'b00:
			case( irb )
			8'h2A, 8'h22, 8'hCD, 8'hC4, 8'hCC, 8'hD4, 8'hDC, 8'hE4, 8'hEC, 8'hF4, 8'hFC:
				func_ldw = ( mcycle == 3'd3 );
			default:
				func_ldw = 1'b0;
			endcase
		// --------------------------------------------------------------------
		//  CB prefixed instructions
		// --------------------------------------------------------------------
		2'b01:
			func_ldw = 1'b0;
		// --------------------------------------------------------------------
		//	ED prefixed instructions
		// --------------------------------------------------------------------
		default:
			case( irb )
			8'h4B, 8'h5B, 8'h6B, 8'h7B, 8'h43, 8'h53, 8'h63, 8'h73:
				func_ldw = ( mcycle == 3'd3 );
			default:
				func_ldw = 1'b0;
			endcase
		endcase
	endfunction

	assign ldw	= func_ldw( iset, mcycle, irb );

	// --------------------------------------------------------------------
	//	exchangerp
	// --------------------------------------------------------------------
	function func_exchangerp(
		input	[1:0]	iset,
		input	[2:0]	mcycle,
		input	[7:0]	irb
	);
		case( iset )
		// --------------------------------------------------------------------
		//  unprefixed instructions
		// --------------------------------------------------------------------
		2'b00:
			case( irb )
			8'h40, 8'h41, 8'h42, 8'h43, 8'h44, 8'h45, 8'h47, 
			8'h48, 8'h49, 8'h4A, 8'h4B, 8'h4C, 8'h4D, 8'h4F, 
			8'h50, 8'h51, 8'h52, 8'h53, 8'h54, 8'h55, 8'h57, 
			8'h58, 8'h59, 8'h5A, 8'h5B, 8'h5C, 8'h5D, 8'h5F, 
			8'h60, 8'h61, 8'h62, 8'h63, 8'h64, 8'h65, 8'h67, 
			8'h68, 8'h69, 8'h6A, 8'h6B, 8'h6C, 8'h6D, 8'h6F, 
			8'h78, 8'h79, 8'h7A, 8'h7B, 8'h7C, 8'h7D, 8'h7F:
				begin
					func_exchangerp = 1'b1;
				end
			default:
				func_exchangerp = 1'b0;
			endcase
		// --------------------------------------------------------------------
		//  ED/CB prefixed instructions
		// --------------------------------------------------------------------
		default:
			func_exchangerp = 1'b0;
		endcase
	endfunction

	assign exchangerp	= func_exchangerp( iset, mcycle, irb );

	// --------------------------------------------------------------------
	//	i_btr
	// --------------------------------------------------------------------
	function func_i_btr(
		input	[1:0]	iset,
		input	[2:0]	mcycle,
		input	[7:0]	irb
	);
		case( iset )
		// --------------------------------------------------------------------
		//  cb prefixed instructions
		// --------------------------------------------------------------------
		2'b00, 2'b01:
			func_i_btr = 1'b0;
		// --------------------------------------------------------------------
		//	ED prefixed instructions
		// --------------------------------------------------------------------
		default:
			case( irb )
			8'hA2, 8'hAA, 8'hB2, 8'hBA, 8'hA3, 8'hAB, 8'hB3, 8'hBB:
				func_i_btr = ( mcycle == 3'd3 );
			default:
				func_i_btr = 1'b0;
			endcase
		endcase
	endfunction

	assign i_btr		= func_i_btr( iset, mcycle, irb );

	// --------------------------------------------------------------------
	//	xybit_undoc
	// --------------------------------------------------------------------
	function func_xybit_undoc(
		input	[1:0]	iset,
		input	[2:0]	mcycle,
		input	[7:0]	irb,
		input	[1:0]	xy_state
	);
		case( iset )
		// --------------------------------------------------------------------
		//  cb prefixed instructions
		// --------------------------------------------------------------------
		2'b01:
			case( irb )
			8'h00, 8'h01, 8'h02, 8'h03, 8'h04, 8'h05, 8'h07, 
			8'h10, 8'h11, 8'h12, 8'h13, 8'h14, 8'h15, 8'h17, 
			8'h08, 8'h09, 8'h0A, 8'h0B, 8'h0C, 8'h0D, 8'h0F, 
			8'h18, 8'h19, 8'h1A, 8'h1B, 8'h1C, 8'h1D, 8'h1F, 
			8'h20, 8'h21, 8'h22, 8'h23, 8'h24, 8'h25, 8'h27, 
			8'h28, 8'h29, 8'h2A, 8'h2B, 8'h2C, 8'h2D, 8'h2F, 
			8'h30, 8'h31, 8'h32, 8'h33, 8'h34, 8'h35, 8'h37, 
			8'h38, 8'h39, 8'h3A, 8'h3B, 8'h3C, 8'h3D, 8'h3F, 
			8'h40, 8'h41, 8'h42, 8'h43, 8'h44, 8'h45, 8'h47, 
			8'h48, 8'h49, 8'h4A, 8'h4B, 8'h4C, 8'h4D, 8'h4F, 
			8'h50, 8'h51, 8'h52, 8'h53, 8'h54, 8'h55, 8'h57, 
			8'h58, 8'h59, 8'h5A, 8'h5B, 8'h5C, 8'h5D, 8'h5F, 
			8'h60, 8'h61, 8'h62, 8'h63, 8'h64, 8'h65, 8'h67, 
			8'h68, 8'h69, 8'h6A, 8'h6B, 8'h6C, 8'h6D, 8'h6F, 
			8'h70, 8'h71, 8'h72, 8'h73, 8'h74, 8'h75, 8'h77, 
			8'h78, 8'h79, 8'h7A, 8'h7B, 8'h7C, 8'h7D, 8'h7F, 
			8'hC0, 8'hC1, 8'hC2, 8'hC3, 8'hC4, 8'hC5, 8'hC7, 
			8'hC8, 8'hC9, 8'hCA, 8'hCB, 8'hCC, 8'hCD, 8'hCF, 
			8'hD0, 8'hD1, 8'hD2, 8'hD3, 8'hD4, 8'hD5, 8'hD7, 
			8'hD8, 8'hD9, 8'hDA, 8'hDB, 8'hDC, 8'hDD, 8'hDF, 
			8'hE0, 8'hE1, 8'hE2, 8'hE3, 8'hE4, 8'hE5, 8'hE7, 
			8'hE8, 8'hE9, 8'hEA, 8'hEB, 8'hEC, 8'hED, 8'hEF, 
			8'hF0, 8'hF1, 8'hF2, 8'hF3, 8'hF4, 8'hF5, 8'hF7, 
			8'hF8, 8'hF9, 8'hFA, 8'hFB, 8'hFC, 8'hFD, 8'hFF, 
			8'h80, 8'h81, 8'h82, 8'h83, 8'h84, 8'h85, 8'h87, 
			8'h88, 8'h89, 8'h8A, 8'h8B, 8'h8C, 8'h8D, 8'h8F, 
			8'h90, 8'h91, 8'h92, 8'h93, 8'h94, 8'h95, 8'h97, 
			8'h98, 8'h99, 8'h9A, 8'h9B, 8'h9C, 8'h9D, 8'h9F, 
			8'hA0, 8'hA1, 8'hA2, 8'hA3, 8'hA4, 8'hA5, 8'hA7, 
			8'hA8, 8'hA9, 8'hAA, 8'hAB, 8'hAC, 8'hAD, 8'hAF, 
			8'hB0, 8'hB1, 8'hB2, 8'hB3, 8'hB4, 8'hB5, 8'hB7, 
			8'hB8, 8'hB9, 8'hBA, 8'hBB, 8'hBC, 8'hBD, 8'hBF:
				func_xybit_undoc = ( xy_state != 2'b00 );
			default:
				func_xybit_undoc = 1'b0;
			endcase
		// --------------------------------------------------------------------
		//	ED prefixed instructions
		// --------------------------------------------------------------------
		default:
			func_xybit_undoc = 1'b0;
		endcase
	endfunction

	assign xybit_undoc = func_xybit_undoc( iset, mcycle, irb, xy_state );

	// --------------------------------------------------------------------
	//	CPL, SCF, CCF, LDI/LDIR/LDD/LDDR, CPI/CPIR/CPD/CPDR, EI, DI, HALT
	// --------------------------------------------------------------------
	assign i_cpl	= ( iset == 2'b00 && irb == 8'h2F );
	assign i_scf	= ( iset == 2'b00 && irb == 8'h37 );
	assign i_ccf	= ( iset == 2'b00 && irb == 8'h3F );
	assign i_djnz	= ( iset == 2'b00 && irb == 8'h10 && (mcycle == 3'd1 || mcycle == 3'd2) );
	assign i_bt		= ( iset[1] == 1'b1 && (irb == 8'hA0 || irb == 8'hA8 || irb == 8'hB0 || irb == 8'hB8) && mcycle == 3'd3 );
	assign i_bc		= ( iset[1] == 1'b1 && (irb == 8'hA1 || irb == 8'hA9 || irb == 8'hB1 || irb == 8'hB9) && mcycle == 3'd3 );
	assign i_rrd	= ( iset[1] == 1'b1 && irb == 8'h67 && mcycle == 3'd4 );
	assign i_rld	= ( iset[1] == 1'b1 && irb == 8'h6F && mcycle == 3'd4 );
	assign i_inrc	= ( iset[1] == 1'b1 && 
		(irb == 8'h40 || irb == 8'h48 || irb == 8'h50 || irb == 8'h58 || 
		 irb == 8'h60 || irb == 8'h68 || irb == 8'h70 || irb == 8'h78 ) && mcycle == 3'd2 );
	assign halt		= ( iset == 2'b00 && irb == 8'h76 );
	assign setdi	= ( iset == 2'b00 && irb == 8'hF3 );
	assign setei	= ( iset == 2'b00 && irb == 8'hFB );
	assign arith16	= ( iset == 2'b00 && (mcycle == 3'd2 || mcycle == 3'd3) &&
		(irb == 8'h09 || irb == 8'h19 || irb == 8'h29 || irb == 8'h39) );

	// --------------------------------------------------------------------
	//	ex, ld sp,(hl), ld r/i, jp (hl)
	// --------------------------------------------------------------------
	assign exchangeaf	= ( iset == 2'b00 && irb == 8'h08 );
	assign exchangedh	= ( iset == 2'b00 && irb == 8'hEB );
	assign exchangers	= ( iset == 2'b00 && irb == 8'hD9 );
	assign jumpxy		= ( iset == 2'b00 && irb == 8'hE9 );
	assign ldsphl		= ( iset == 2'b00 && irb == 8'hF9 );
	assign special_ld	= ( iset[1] == 1'b1 ) ? (
							( irb == 8'h57 ) ? 3'd4:
							( irb == 8'h5F ) ? 3'd5:
							( irb == 8'h47 ) ? 3'd6:
							( irb == 8'h4F ) ? 3'd7: 3'd0 ): 3'd0;
	assign rstp			= ( iset == 2'b00 && mcycle == 3'd3 &&
			(irb == 8'hC7 || irb == 8'hCF || irb == 8'hD7 || irb == 8'hDF || 
			 irb == 8'hE7 || irb == 8'hEF || irb == 8'hF7 || irb == 8'hFF) );

	// --------------------------------------------------------------------
	//	interrupt mode
	// --------------------------------------------------------------------
	assign imode		= ( iset[1] == 1'b1 ) ? (
							( irb == 8'h46 || irb == 8'h4E || irb == 8'h66 || irb == 8'h6E ) ? 2'b00:
							( irb == 8'h56 || irb == 8'h76 ) ? 2'b01:
							( irb == 8'h5E || irb == 8'h77 ) ? 2'b10: 2'b11 ): 2'b11;
endmodule
