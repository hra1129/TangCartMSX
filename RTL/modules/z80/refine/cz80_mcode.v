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
//	This module is based on T80(Version : 0250_T80) by Daniel Wallner and 
//	modified by Takayuki Hara.
//
//	The following modifications have been made.
//	-- Convert VHDL code to Verilog code.
//	-- Some minor bug fixes.
//-----------------------------------------------------------------------------

module t80_mcode #(
	parameter			mode		= 0
) (
	input				ir			: in std_logic_vector[7:0];
	input				iset		: in std_logic_vector[1:0];
	input				mcycle		: in std_logic_vector[2:0];
	input				f			: in std_logic_vector[7:0];
	input				nmicycle	: in std_logic;
	input				intcycle	: in std_logic;
	input				xy_state	: in std_logic_vector[1:0];
	output				mcycles		: out std_logic_vector[2:0];
	output				tstates		: out std_logic_vector[2:0];
	output				prefix		: out std_logic_vector[1:0]; // none,cb,ed,dd/fd
	output				inc_pc		: out std_logic;
	output				inc_wz		: out std_logic;
	output				incdec_16	: out std_logic_vector[3:0]; // bc,de,hl,sp	 0 is inc
	output				read_to_reg : out std_logic;
	output				read_to_acc : out std_logic;
	output				set_busa_to : out std_logic_vector[3:0]; // b,c,d,e,h,l,di/db,a,sp(l),sp(m),0,f
	output				set_busb_to : out std_logic_vector[3:0]; // b,c,d,e,h,l,di,a,sp(l),sp(m),1,f,pc(l),pc(m),0
	output				alu_op		: out std_logic_vector[3:0];
			// add, adc, sub, sbc, and, xor, or, cp, rot, bit, set, res, daa, rld, rrd, none
	output				alu_cpi		: out std_logic;	//for undoc xy-flags	   
	output				save_alu	: out std_logic;
	output				preservec	: out std_logic;
	output				arith16		: out std_logic;
	output				set_addr_to : out std_logic_vector[2:0]; // anone,axy,aioa,asp,abc,ade,azi
	output				iorq		: out std_logic;
	output				jump		: out std_logic;
	output				jumpe		: out std_logic;
	output				jumpxy		: out std_logic;
	output				call		: out std_logic;
	output				rstp		: out std_logic;
	output				ldz			: out std_logic;
	output				ldw			: out std_logic;
	output				ldsphl		: out std_logic;
	output				special_ld	: out std_logic_vector[2:0]; // a,i;a,r;i,a;r,a;none
	output				exchangedh	: out std_logic;
	output				exchangerp	: out std_logic;
	output				exchangeaf	: out std_logic;
	output				exchangers	: out std_logic;
	output				i_djnz		: out std_logic;
	output				i_cpl		: out std_logic;
	output				i_ccf		: out std_logic;
	output				i_scf		: out std_logic;
	output				i_retn		: out std_logic;
	output				i_bt		: out std_logic;
	output				i_bc		: out std_logic;
	output				i_btr		: out std_logic;
	output				i_rld		: out std_logic;
	output				i_rrd		: out std_logic;
	output				i_inrc		: out std_logic;
	output				setdi		: out std_logic;
	output				setei		: out std_logic;
	output				imode		: out std_logic_vector[1:0];
	output				halt		: out std_logic;
	output				noread		: out std_logic;
	output				write		: out std_logic;
	output				xybit_undoc : out std_logic
);
		localparam			flag_c	= 0;
		localparam			flag_n	= 1;
		localparam			flag_p	= 2;
		localparam			flag_x	= 3;
		localparam			flag_h	= 4;
		localparam			flag_y	= 5;
		localparam			flag_z	= 6;
		localparam			flag_s	= 7

		localparam	[2:0]	anone	= 3'd7;
		localparam	[2:0]	abc		= 3'd0;
		localparam	[2:0]	ade		= 3'd1;
		localparam	[2:0]	axy		= 3'd2;
		localparam	[2:0]	aioa	= 3'd4;
		localparam	[2:0]	asp		= 3'd5;
		localparam	[2:0]	azi		= 3'd6;

		function is_cc_true(
				f : std_logic_vector[7:0];
				cc : bit_vector[2:0]
				) return boolean is
		begin
			case cc is
			 3'd0 : return f[6] = 1'b0; // nz
			 3'd1 : return f[6] = 1'b1; // z
			 3'd2 : return f[0] = 1'b0; // nc
			 3'd3 : return f[0] = 1'b1; // c
			 3'd4 : return f[2] = 1'b0; // po
			 3'd5 : return f[2] = 1'b1; // pe
			 3'd6 : return f[7] = 1'b0; // p
			 3'd7 : return f[7] = 1'b1; // m
			endcase
		end

begin

	process (ir, iset, mcycle, f, nmicycle, intcycle, xy_state)
			variable ddd : std_logic_vector[2:0];
			variable sss : std_logic_vector[2:0];
			variable dpair : std_logic_vector[1:0];
			variable irb : bit_vector[7:0];
	begin
			ddd := ir[5:3];
			sss := ir[2:0];
			dpair := ir[5:4];
			irb := to_bitvector(ir);

			mcycles <= 3'd1;
			if( mcycle = 3'd1 ) begin
					tstates <= 3'd4;
			else
					tstates <= 3'd3;
			end
			prefix <= 2'b00;
			inc_pc <= 1'b0;
			inc_wz <= 1'b0;
			incdec_16 <= 4'h0;
			read_to_acc <= 1'b0;
			read_to_reg <= 1'b0;
			set_busb_to <= 4'h0;
			set_busa_to <= 4'h0;
			alu_op <= 1'b0 & ir[5:3];
			alu_cpi <= 1'b0;
			save_alu <= 1'b0;
			preservec <= 1'b0;
			arith16 <= 1'b0;
			iorq <= 1'b0;
			set_addr_to <= anone;
			jump <= 1'b0;
			jumpe <= 1'b0;
			jumpxy <= 1'b0;
			call <= 1'b0;
			rstp <= 1'b0;
			ldz <= 1'b0;
			ldw <= 1'b0;
			ldsphl <= 1'b0;
			special_ld <= 3'd0;
			exchangedh <= 1'b0;
			exchangerp <= 1'b0;
			exchangeaf <= 1'b0;
			exchangers <= 1'b0;
			i_djnz <= 1'b0;
			i_cpl <= 1'b0;
			i_ccf <= 1'b0;
			i_scf <= 1'b0;
			i_retn <= 1'b0;
			i_bt <= 1'b0;
			i_bc <= 1'b0;
			i_btr <= 1'b0;
			i_rld <= 1'b0;
			i_rrd <= 1'b0;
			i_inrc <= 1'b0;
			setdi <= 1'b0;
			setei <= 1'b0;
			imode <= 2'b11;
			halt <= 1'b0;
			noread <= 1'b0;
			write <= 1'b0;
			xybit_undoc <= 1'b0;

			case( iset )
			 2'b00 :
				// --------------------------------------------------------------------
				//  unprefixed instructions
				// --------------------------------------------------------------------

			case( irb )
// 8 bit load group
			8'h40, 8'h41, 8'h42, 8'h43, 8'h44, 8'h45, 8'h47, 
			8'h48, 8'h49, 8'h4A, 8'h4B, 8'h4C, 8'h4D, 8'h4F, 
			8'h50, 8'h51, 8'h52, 8'h53, 8'h54, 8'h55, 8'h57, 
			8'h58, 8'h59, 8'h5A, 8'h5B, 8'h5C, 8'h5D, 8'h5F, 
			8'h60, 8'h61, 8'h62, 8'h63, 8'h64, 8'h65, 8'h67, 
			8'h68, 8'h69, 8'h6A, 8'h6B, 8'h6C, 8'h6D, 8'h6F, 
			8'h78, 8'h79, 8'h7A, 8'h7B, 8'h7C, 8'h7D, 8'h7F:
				begin
					// ld r,r'
					set_busb_to[2:0] <= sss;
					exchangerp <= 1'b1;
					set_busa_to[2:0] <= ddd;
					read_to_reg <= 1'b1;
				end
			8'h06, 8'h0E, 8'h16, 8'h1E, 8'h26, 8'h2E, 8'h3E :
				begin
					// ld r,n
					mcycles <= 3'd2;
					case( mcycle )
					3'd2:
							inc_pc <= 1'b1;
							set_busa_to[2:0] <= ddd;
							read_to_reg <= 1'b1;
					 others : null;
					endcase
				end
			8'h46, 8'h4E, 8'h56, 8'h5E, 8'h66, 8'h6E, 8'h7E :
				begin
					// ld r,(hl)
					mcycles <= 3'd2;
					case( mcycle )
					3'd1:
							set_addr_to <= axy;
					3'd2:
							set_busa_to[2:0] <= ddd;
							read_to_reg <= 1'b1;
					 others : null;
					endcase
				end
			 8'h70, 8'h71, 8'h72, 8'h73, 8'h74, 8'h75, 8'h77 :
				begin
					// ld (hl),r
					mcycles <= 3'd2;
					case( mcycle )
					3'd1:
							set_addr_to <= axy;
							set_busb_to[2:0] <= sss;
							set_busb_to[3] <= 1'b0;
					3'd2:
							write <= 1'b1;
					 others : null;
					endcase
				end
			 8'h36 :
				begin
					// ld (hl),n
					mcycles <= 3'd3;
					case( mcycle )
					3'd2:
						begin
							inc_pc <= 1'b1;
							set_addr_to <= axy;
							set_busb_to[2:0] <= sss;
							set_busb_to[3] <= 1'b0;
						end
					3'd3:
						begin
							write <= 1'b1;
						end
					default:
						begin
							//	hold
						end
					endcase
				end
			 8'h0A :
				begin
					// ld a,(bc)
					mcycles <= 3'd2;
					case( mcycle )
					3'd1:
							set_addr_to <= abc;
					3'd2:
							read_to_acc <= 1'b1;
					default:
						begin
							//	hold
						end
					endcase
				end
			 8'h1A :
				begin
					// ld a,(de)
					mcycles <= 3'd2;
					case( mcycle )
					3'd1:
							set_addr_to <= ade;
					3'd2:
							read_to_acc <= 1'b1;
					default:
						begin
							//	hold
						end
					endcase
				end
			 8'h3A :
				begin
					// ld a,(nn)
					mcycles <= 3'd4;
					case( mcycle )
					3'd2:
							inc_pc <= 1'b1;
							ldz <= 1'b1;
					3'd3:
							set_addr_to <= azi;
							inc_pc <= 1'b1;
					3'd4:
							read_to_acc <= 1'b1;
					default:
						begin
							//	hold
						end
					endcase
				end
			 8'h02 :
				begin
					// ld (bc),a
					mcycles <= 3'd2;
					case( mcycle )
					3'd1:
							set_addr_to <= abc;
							set_busb_to <= 4'h7;
					3'd2:
							write <= 1'b1;
					default:
						begin
							//	hold
						end
					endcase
				end
			 8'h12 :
				begin
					// ld (de),a
					mcycles <= 3'd2;
					case( mcycle )
					3'd1:
							set_addr_to <= ade;
							set_busb_to <= 4'h7;
					3'd2:
							write <= 1'b1;
					default:
						begin
							//	hold
						end
					endcase
				end
			 8'h32 :
				begin
					// ld (nn),a
					mcycles <= 3'd4;
					case( mcycle )
					3'd2:
							inc_pc <= 1'b1;
							ldz <= 1'b1;
					3'd3:
							set_addr_to <= azi;
							inc_pc <= 1'b1;
							set_busb_to <= 4'h7;
					3'd4:
							write <= 1'b1;
					default:
						begin
							//	hold
						end
					endcase
				end
// 16 bit load group
			 8'h01, 8'h11, 8'h21, 8'h31 :
				begin
					// ld dd,nn
					mcycles <= 3'd3;
					case( mcycle )
					3'd2:
						begin
							inc_pc <= 1'b1;
							read_to_reg <= 1'b1;
							if( dpair == 2'b11 ) begin
									set_busa_to[3:0] <= 4'h8;
							end
							else begin
									set_busa_to[2:1] <= dpair;
									set_busa_to[0] <= 1'b1;
							end
					3'd3:
						begin
							inc_pc <= 1'b1;
							read_to_reg <= 1'b1;
							if( dpair == 2'b11 ) begin
									set_busa_to[3:0] <= 4'h9;
							end
							else begin
									set_busa_to[2:1] <= dpair;
									set_busa_to[0] <= 1'b0;
							end
					default:
						begin
							//	hold
						end
					endcase
			 8'h2A :
					// ld hl,(nn)
					mcycles <= 3'd5;
					case( mcycle )
					3'd2:
							inc_pc <= 1'b1;
							ldz <= 1'b1;
					3'd3:
							set_addr_to <= azi;
							inc_pc <= 1'b1;
							ldw <= 1'b1;
					3'd4:
							set_busa_to[2:0] <= 3'd5; // l
							read_to_reg <= 1'b1;
							inc_wz <= 1'b1;
							set_addr_to <= azi;
					3'd5:
							set_busa_to[2:0] <= 3'd4; // h
							read_to_reg <= 1'b1;
					default:
						begin
							//	hold
						end
					endcase
			 8'h22 :
					// ld (nn),hl
					mcycles <= 3'd5;
					case( mcycle )
					3'd2:
							inc_pc <= 1'b1;
							ldz <= 1'b1;
					3'd3:
							set_addr_to <= azi;
							inc_pc <= 1'b1;
							ldw <= 1'b1;
							set_busb_to <= 4'h5; // l
					3'd4:
							inc_wz <= 1'b1;
							set_addr_to <= azi;
							write <= 1'b1;
							set_busb_to <= 4'h4; // h
					3'd5:
							write <= 1'b1;
					default:
						begin
							//	hold
						end
					endcase
			 8'hF9 :
					// ld sp,hl
					tstates <= 3'd6;
					ldsphl <= 1'b1;
			 8'hC5, 8'hD5, 8'hE5, 8'hF5 :
					// push qq
					mcycles <= 3'd3;
					case( mcycle )
					3'd1:
							tstates <= 3'd5;
							incdec_16 <= 4'hF;
							set_addr_to <= asp;
							if( dpair = 2'b11 ) begin
									set_busb_to <= 4'h7;
							else
									set_busb_to[2:1] <= dpair;
									set_busb_to[0] <= 1'b0;
									set_busb_to[3] <= 1'b0;
							end
					3'd2:
							incdec_16 <= 4'hF;
							set_addr_to <= asp;
							if( dpair = 2'b11 ) begin
									set_busb_to <= 4'hB;
							else
									set_busb_to[2:1] <= dpair;
									set_busb_to[0] <= 1'b1;
									set_busb_to[3] <= 1'b0;
							end
							write <= 1'b1;
					3'd3:
							write <= 1'b1;
					default:
						begin
							//	hold
						end
					endcase
			 8'hC1, 8'hD1, 8'hE1, 8'hF1 :
					// pop qq
					mcycles <= 3'd3;
					case( mcycle )
					3'd1:
							set_addr_to <= asp;
					3'd2:
							incdec_16 <= 4'h7;
							set_addr_to <= asp;
							read_to_reg <= 1'b1;
							if( dpair = 2'b11 ) begin
									set_busa_to[3:0] <= 4'hB;
							else
									set_busa_to[2:1] <= dpair;
									set_busa_to[0] <= 1'b1;
							end
					3'd3:
							incdec_16 <= 4'h7;
							read_to_reg <= 1'b1;
							if( dpair = 2'b11 ) begin
									set_busa_to[3:0] <= 4'h7;
							else
									set_busa_to[2:1] <= dpair;
									set_busa_to[0] <= 1'b0;
							end
					default:
						begin
							//	hold
						end
					endcase

// exchange, block transfer and search group
			 8'hEB :
					// ex de,hl
					exchangedh <= 1'b1;
			 8'h08 :
					// ex af,af'
					exchangeaf <= 1'b1;
			 8'hD9 :
					// exx
					exchangers <= 1'b1;
			 8'hE3 :
					// ex (sp),hl
					mcycles <= 3'd5;
					case( mcycle )
					3'd1:
							set_addr_to <= asp;
					3'd2:
							read_to_reg <= 1'b1;
							set_busa_to <= 4'h5;
							set_busb_to <= 4'h5;
							set_addr_to <= asp;
					3'd3:
							incdec_16 <= 4'h7;
							set_addr_to <= asp;
							tstates <= 3'd4;
							write <= 1'b1;
					3'd4:
							read_to_reg <= 1'b1;
							set_busa_to <= 4'h4;
							set_busb_to <= 4'h4;
							set_addr_to <= asp;
					3'd5:
							incdec_16 <= 4'hF;
							tstates <= 3'd5;
							write <= 1'b1;
					default:
						begin
							//	hold
						end
					endcase

// 8 bit arithmetic and logical group
			8'h80, 8'h81, 8'h82, 8'h83, 8'h84, 8'h85, 8'h87
			, 8'h88, 8'h89, 8'h8A, 8'h8B, 8'h8C, 8'h8D, 8'h8F
			, 8'h90, 8'h91, 8'h92, 8'h93, 8'h94, 8'h95, 8'h97
			, 8'h98, 8'h99, 8'h9A, 8'h9B, 8'h9C, 8'h9D, 8'h9F
			, 8'hA0, 8'hA1, 8'hA2, 8'hA3, 8'hA4, 8'hA5, 8'hA7
			, 8'hA8, 8'hA9, 8'hAA, 8'hAB, 8'hAC, 8'hAD, 8'hAF
			, 8'hB0, 8'hB1, 8'hB2, 8'hB3, 8'hB4, 8'hB5, 8'hB7
			, 8'hB8, 8'hB9, 8'hBA, 8'hBB, 8'hBC, 8'hBD, 8'hBF:
					// add a,r
					// adc a,r
					// sub a,r
					// sbc a,r
					// and a,r
					// or a,r
					// xor a,r
					// cp a,r
					set_busb_to[2:0] <= sss;
					set_busa_to[2:0] <= 3'd7;
					read_to_reg <= 1'b1;
					save_alu <= 1'b1;
			 8'h86, 8'h8E, 8'h96, 8'h9E, 8'hA6, 8'hAE, 8'hB6, 8'hBE :
					// add a,(hl)
					// adc a,(hl)
					// sub a,(hl)
					// sbc a,(hl)
					// and a,(hl)
					// or a,(hl)
					// xor a,(hl)
					// cp a,(hl)
					mcycles <= 3'd2;
					case( mcycle )
					3'd1:
							set_addr_to <= axy;
					3'd2:
							read_to_reg <= 1'b1;
							save_alu <= 1'b1;
							set_busb_to[2:0] <= sss;
							set_busa_to[2:0] <= 3'd7;
					default:
						begin
							//	hold
						end
					endcase
			 8'hC6, 8'hCE, 8'hD6, 8'hDE, 8'hE6, 8'hEE, 8'hF6, 8'hFE :
					// add a,n
					// adc a,n
					// sub a,n
					// sbc a,n
					// and a,n
					// or a,n
					// xor a,n
					// cp a,n
					mcycles <= 3'd2;
					if( mcycle = 3'd2 ) begin
							inc_pc <= 1'b1;
							read_to_reg <= 1'b1;
							save_alu <= 1'b1;
							set_busb_to[2:0] <= sss;
							set_busa_to[2:0] <= 3'd7;
					end
			 8'h04, 8'h0C, 8'h14, 8'h1C, 8'h24, 8'h2C, 8'h3C :
					// inc r
					set_busb_to <= 4'hA;
					set_busa_to[2:0] <= ddd;
					read_to_reg <= 1'b1;
					save_alu <= 1'b1;
					preservec <= 1'b1;
					alu_op <= 4'h0;
			 8'h34 :
					// inc (hl)
					mcycles <= 3'd3;
					case( mcycle )
					3'd1:
							set_addr_to <= axy;
					3'd2:
							tstates <= 3'd4;
							set_addr_to <= axy;
							read_to_reg <= 1'b1;
							save_alu <= 1'b1;
							preservec <= 1'b1;
							alu_op <= 4'h0;
							set_busb_to <= 4'hA;
							set_busa_to[2:0] <= ddd;
					3'd3:
							write <= 1'b1;
					default:
						begin
							//	hold
						end
					endcase
			 8'h05, 8'h0D, 8'h15, 8'h1D, 8'h25, 8'h2D, 8'h3D :
					// dec r
					set_busb_to <= 4'hA;
					set_busa_to[2:0] <= ddd;
					read_to_reg <= 1'b1;
					save_alu <= 1'b1;
					preservec <= 1'b1;
					alu_op <= 4'h2;
			 8'h35 :
					// dec (hl)
					mcycles <= 3'd3;
					case( mcycle )
					3'd1:
							set_addr_to <= axy;
					3'd2:
							tstates <= 3'd4;
							set_addr_to <= axy;
							alu_op <= 4'h2;
							read_to_reg <= 1'b1;
							save_alu <= 1'b1;
							preservec <= 1'b1;
							set_busb_to <= 4'hA;
							set_busa_to[2:0] <= ddd;
					3'd3:
							write <= 1'b1;
					default:
						begin
							//	hold
						end
					endcase

// general purpose arithmetic and cpu control groups
			 8'h27 :
					// daa
					set_busa_to[2:0] <= 3'd7;
					read_to_reg <= 1'b1;
					alu_op <= 4'hC;
					save_alu <= 1'b1;
			 8'h2F :
					// cpl
					i_cpl <= 1'b1;
			 8'h3F :
					// ccf
					i_ccf <= 1'b1;
			 8'h37 :
					// scf
					i_scf <= 1'b1;
			 8'h00 :
					if( nmicycle = 1'b1 ) begin
							// nmi
							mcycles <= 3'd3;
							case( mcycle )
							3'd1:
									tstates <= 3'd5;
									incdec_16 <= 4'hF;
									set_addr_to <= asp;
									set_busb_to <= 4'hD;
							3'd2:
									tstates <= 3'd4;
									write <= 1'b1;
									incdec_16 <= 4'hF;
									set_addr_to <= asp;
									set_busb_to <= 4'hC;
							3'd3:
									tstates <= 3'd4;
									write <= 1'b1;
							default:
								begin
									//	hold
								end
							endcase
					else if( intcycle = 1'b1 ) begin
							// int (im 2)
							mcycles <= 3'd5;
							case( mcycle )
							3'd1:
									ldz <= 1'b1;
									tstates <= 3'd5;
									incdec_16 <= 4'hF;
									set_addr_to <= asp;
									set_busb_to <= 4'hD;
							3'd2:
									tstates <= 3'd4;
									write <= 1'b1;
									incdec_16 <= 4'hF;
									set_addr_to <= asp;
									set_busb_to <= 4'hC;
							3'd3:
									tstates <= 3'd4;
									write <= 1'b1;
							3'd4:
									inc_pc <= 1'b1;
									ldz <= 1'b1;
							3'd5:
									jump <= 1'b1;
							default:
								begin
									//	hold
								end
							endcase
					else
							// nop
					end
			 8'h76 :
					// halt
					halt <= 1'b1;
			 8'hF3 :
					// di
					setdi <= 1'b1;
			 8'hFB :
					// ei
					setei <= 1'b1;

// 16 bit arithmetic group
			 8'h09, 8'h19, 8'h29, 8'h39 :
					// add hl,ss
					mcycles <= 3'd3;
					case( mcycle )
					3'd2:
							noread <= 1'b1;
							alu_op <= 4'h0;
							read_to_reg <= 1'b1;
							save_alu <= 1'b1;
							set_busa_to[2:0] <= 3'd5;
							case to_integer(unsigned(ir[5:4])) is
							 3'd0, 3'd1, 3'd2:
									set_busb_to[2:1] <= ir[5:4];
									set_busb_to[0] <= 1'b1;
							 others :
									set_busb_to <= 4'h8;
							endcase
							tstates <= 3'd4;
							arith16 <= 1'b1;
					3'd3:
							noread <= 1'b1;
							read_to_reg <= 1'b1;
							save_alu <= 1'b1;
							alu_op <= 4'h1;
							set_busa_to[2:0] <= 3'd4;
							case to_integer(unsigned(ir[5:4])) is
							 3'd0, 3'd1, 3'd2:
									set_busb_to[2:1] <= ir[5:4];
							 others :
									set_busb_to <= 4'h9;
							endcase
							arith16 <= 1'b1;
					default:
						begin
							//	hold
						end
					endcase
			 8'h03, 8'h13, 8'h23, 8'h33 :
					// inc ss
					tstates <= 3'd6;
					incdec_16[3:2] <= 2'b01;
					incdec_16[1:0] <= dpair;
			 8'h0B, 8'h1B, 8'h2B, 8'h3B :
					// dec ss
					tstates <= 3'd6;
					incdec_16[3:2] <= 2'b11;
					incdec_16[1:0] <= dpair;

// rotate and shift group
			8'h07
					// rlca
					, 8'h17
					// rla
					, 8'h0F
					// rrca
					, 8'h1F:
					// rra
					set_busa_to[2:0] <= 3'd7;
					alu_op <= 4'h8;
					read_to_reg <= 1'b1;
					save_alu <= 1'b1;

// jump group
			 8'hC3 :
					// jp nn
					mcycles <= 3'd3;
					case( mcycle )
					3'd2:
							inc_pc <= 1'b1;
							ldz <= 1'b1;
					3'd3:
							inc_pc <= 1'b1;
							jump <= 1'b1;
					default:
						begin
							//	hold
						end
					endcase
			 8'hC2, 8'hCA, 8'hD2, 8'hDA, 8'hE2, 8'hEA, 8'hF2, 8'hFA :
					// jp cc,nn
					mcycles <= 3'd3;
					case( mcycle )
					3'd2:
							inc_pc <= 1'b1;
							ldz <= 1'b1;
					3'd3:
							inc_pc <= 1'b1;
							if( is_cc_true(f, to_bitvector(ir[5:3])) ) begin
									jump <= 1'b1;
							end
					default:
						begin
							//	hold
						end
					endcase
			 8'h18 :
					// jr e
					mcycles <= 3'd3;
					case( mcycle )
					3'd2:
							inc_pc <= 1'b1;
					3'd3:
							noread <= 1'b1;
							jumpe <= 1'b1;
							tstates <= 3'd5;
					default:
						begin
							//	hold
						end
					endcase
			 8'h38 :
					// jr c,e
					mcycles <= 3'd3;
					case( mcycle )
					3'd2:
							inc_pc <= 1'b1;
							if( f(flag_c) = 1'b0 ) begin
									mcycles <= 3'd2;
							end
					3'd3:
							noread <= 1'b1;
							jumpe <= 1'b1;
							tstates <= 3'd5;
					default:
						begin
							//	hold
						end
					endcase
			 8'h30 :
					// jr nc,e
					mcycles <= 3'd3;
					case( mcycle )
					3'd2:
							inc_pc <= 1'b1;
							if( f(flag_c) = 1'b1 ) begin
									mcycles <= 3'd2;
							end
					3'd3:
							noread <= 1'b1;
							jumpe <= 1'b1;
							tstates <= 3'd5;
					default:
						begin
							//	hold
						end
					endcase
			 8'h28 :
					// jr z,e
					mcycles <= 3'd3;
					case( mcycle )
					3'd2:
							inc_pc <= 1'b1;
							if( f(flag_z) = 1'b0 ) begin
									mcycles <= 3'd2;
							end
					3'd3:
							noread <= 1'b1;
							jumpe <= 1'b1;
							tstates <= 3'd5;
					default:
						begin
							//	hold
						end
					endcase
			 8'h20 :
					// jr nz,e
					mcycles <= 3'd3;
					case( mcycle )
					3'd2:
							inc_pc <= 1'b1;
							if( f(flag_z) = 1'b1 ) begin
									mcycles <= 3'd2;
							end
					3'd3:
							noread <= 1'b1;
							jumpe <= 1'b1;
							tstates <= 3'd5;
					default:
						begin
							//	hold
						end
					endcase
			 8'hE9 :
					// jp (hl)
					jumpxy <= 1'b1;
			 8'h10 :
					// djnz,e
					mcycles <= 3'd3;
					case( mcycle )
					3'd1:
							tstates <= 3'd5;
							i_djnz <= 1'b1;
							set_busb_to <= 4'hA;
							set_busa_to[2:0] <= 3'd0;
							read_to_reg <= 1'b1;
							save_alu <= 1'b1;
							alu_op <= 4'h2;
					3'd2:
							i_djnz <= 1'b1;
							inc_pc <= 1'b1;
					3'd3:
							noread <= 1'b1;
							jumpe <= 1'b1;
							tstates <= 3'd5;
					default:
						begin
							//	hold
						end
					endcase

// call and return group
			 8'hCD :
					// call nn
					mcycles <= 3'd5;
					case( mcycle )
					3'd2:
							inc_pc <= 1'b1;
							ldz <= 1'b1;
					3'd3:
							incdec_16 <= 4'hF;
							inc_pc <= 1'b1;
							tstates <= 3'd4;
							set_addr_to <= asp;
							ldw <= 1'b1;
							set_busb_to <= 4'hD;
					3'd4:
							write <= 1'b1;
							incdec_16 <= 4'hF;
							set_addr_to <= asp;
							set_busb_to <= 4'hC;
					3'd5:
							write <= 1'b1;
							call <= 1'b1;
					default:
						begin
							//	hold
						end
					endcase
			 8'hC4, 8'hCC, 8'hD4, 8'hDC, 8'hE4, 8'hEC, 8'hF4, 8'hFC :
					// call cc,nn
					mcycles <= 3'd5;
					case( mcycle )
					3'd2:
							inc_pc <= 1'b1;
							ldz <= 1'b1;
					3'd3:
							inc_pc <= 1'b1;
							ldw <= 1'b1;
							if( is_cc_true(f, to_bitvector(ir[5:3])) ) begin
									incdec_16 <= 4'hF;
									set_addr_to <= asp;
									tstates <= 3'd4;
									set_busb_to <= 4'hD;
							else
									mcycles <= 3'd3;
							end
					3'd4:
							write <= 1'b1;
							incdec_16 <= 4'hF;
							set_addr_to <= asp;
							set_busb_to <= 4'hC;
					3'd5:
							write <= 1'b1;
							call <= 1'b1;
					default:
						begin
							//	hold
						end
					endcase
			 8'hC9 :
					// ret
					mcycles <= 3'd3;
					case( mcycle )
					3'd1:
							tstates <= 3'd5;
							set_addr_to <= asp;
					3'd2:
							incdec_16 <= 4'h7;
							set_addr_to <= asp;
							ldz <= 1'b1;
					3'd3:
							jump <= 1'b1;
							incdec_16 <= 4'h7;
					default:
						begin
							//	hold
						end
					endcase
			 8'hC0, 8'hC8, 8'hD0, 8'hD8, 8'hE0, 8'hE8, 8'hF0, 8'hF8 :
					// ret cc
					mcycles <= 3'd3;
					case( mcycle )
					3'd1:
							if( is_cc_true(f, to_bitvector(ir[5:3])) ) begin
									set_addr_to <= asp;
							else
									mcycles <= 3'd1;
							end
							tstates <= 3'd5;
					3'd2:
							incdec_16 <= 4'h7;
							set_addr_to <= asp;
							ldz <= 1'b1;
					3'd3:
							jump <= 1'b1;
							incdec_16 <= 4'h7;
					default:
						begin
							//	hold
						end
					endcase
			 8'hC7, 8'hCF, 8'hD7, 8'hDF, 8'hE7, 8'hEF, 8'hF7, 8'hFF :
					// rst p
					mcycles <= 3'd3;
					case( mcycle )
					3'd1:
							tstates <= 3'd5;
							incdec_16 <= 4'hF;
							set_addr_to <= asp;
							set_busb_to <= 4'hD;
					3'd2:
							write <= 1'b1;
							incdec_16 <= 4'hF;
							set_addr_to <= asp;
							set_busb_to <= 4'hC;
					3'd3:
							write <= 1'b1;
							rstp <= 1'b1;
					default:
						begin
							//	hold
						end
					endcase

// input and output group
			 8'hDB :
					// in a,(n)
					mcycles <= 3'd3;
					case( mcycle )
					3'd2:
							inc_pc <= 1'b1;
							set_addr_to <= aioa;
					3'd3:
							read_to_acc <= 1'b1;
							iorq <= 1'b1;
					default:
						begin
							//	hold
						end
					endcase
			 8'hD3 :
					// out (n),a
					mcycles <= 3'd3;
					case( mcycle )
					3'd2:
							inc_pc <= 1'b1;
							set_addr_to <= aioa;
							set_busb_to		<= 4'h7;
					3'd3:
							write <= 1'b1;
							iorq <= 1'b1;
					default:
						begin
							//	hold
						end
					endcase

// --------------------------------------------------------------------
//  multibyte instructions
// --------------------------------------------------------------------

			 8'hCB :
					prefix <= 2'b01;

			 8'hED :
					prefix <= 2'b10;

			 8'hDD, 8'hFD :
					prefix <= 2'b11;

			endcase

			 2'b01 :

// --------------------------------------------------------------------
//  cb prefixed instructions
// --------------------------------------------------------------------

		set_busa_to[2:0] <= ir[2:0];
		set_busb_to[2:0] <= ir[2:0];

		case( irb )
		8'h00, 8'h01, 8'h02, 8'h03, 8'h04, 8'h05, 8'h07
		, 8'h10, 8'h11, 8'h12, 8'h13, 8'h14, 8'h15, 8'h17
		, 8'h08, 8'h09, 8'h0A, 8'h0B, 8'h0C, 8'h0D, 8'h0F
		, 8'h18, 8'h19, 8'h1A, 8'h1B, 8'h1C, 8'h1D, 8'h1F
		, 8'h20, 8'h21, 8'h22, 8'h23, 8'h24, 8'h25, 8'h27
		, 8'h28, 8'h29, 8'h2A, 8'h2B, 8'h2C, 8'h2D, 8'h2F
		, 8'h30, 8'h31, 8'h32, 8'h33, 8'h34, 8'h35, 8'h37
		, 8'h38, 8'h39, 8'h3A, 8'h3B, 8'h3C, 8'h3D, 8'h3F:
			// rlc r
			// rl r
			// rrc r
			// rr r
			// sla r
			// sra r
			// srl r
			// sll r (undocumented) / swap r
			if( xy_state=2'b00 ) begin
				if( mcycle = 3'd1 ) begin
				  alu_op <= 4'h8;
				  read_to_reg <= 1'b1;
				  save_alu <= 1'b1;
				end
			else
			// r/s (ix+d),reg, undocumented
				mcycles <= 3'd3;
				xybit_undoc <= 1'b1;
				case( mcycle )
				3'd1, 3'd7:
					set_addr_to <= axy;
				3'd2:
					alu_op <= 4'h8;
					read_to_reg <= 1'b1;
					save_alu <= 1'b1;
					set_addr_to <= axy;
					tstates <= 3'd4;
				3'd3:
					write <= 1'b1;
				default:
					begin
						//	hold
					end
				endcase
			end


		 8'h06, 8'h16, 8'h0E, 8'h1E, 8'h2E, 8'h3E, 8'h26, 8'h36 :
			// rlc (hl)
			// rl (hl)
			// rrc (hl)
			// rr (hl)
			// sra (hl)
			// srl (hl)
			// sla (hl)
			// sll (hl) (undocumented) / swap (hl)
			mcycles <= 3'd3;
			case( mcycle )
			3'd1, 3'd7:
				set_addr_to <= axy;
			3'd2:
				alu_op <= 4'h8;
				read_to_reg <= 1'b1;
				save_alu <= 1'b1;
				set_addr_to <= axy;
				tstates <= 3'd4;
			3'd3:
				write <= 1'b1;
			default:
				begin
					//	hold
				end
			endcase
		8'h40, 8'h41, 8'h42, 8'h43, 8'h44, 8'h45, 8'h47
		, 8'h48, 8'h49, 8'h4A, 8'h4B, 8'h4C, 8'h4D, 8'h4F
		, 8'h50, 8'h51, 8'h52, 8'h53, 8'h54, 8'h55, 8'h57
		, 8'h58, 8'h59, 8'h5A, 8'h5B, 8'h5C, 8'h5D, 8'h5F
		, 8'h60, 8'h61, 8'h62, 8'h63, 8'h64, 8'h65, 8'h67
		, 8'h68, 8'h69, 8'h6A, 8'h6B, 8'h6C, 8'h6D, 8'h6F
		, 8'h70, 8'h71, 8'h72, 8'h73, 8'h74, 8'h75, 8'h77
		, 8'h78, 8'h79, 8'h7A, 8'h7B, 8'h7C, 8'h7D, 8'h7F:
			// bit b,r
			if( xy_state=2'b00 ) begin
				if( mcycle = 3'd1 ) begin
				  set_busb_to[2:0] <= ir[2:0];
				  alu_op <= 4'h9;
				end
			else
			// bit b,(ix+d), undocumented
				mcycles <= 3'd2;
				xybit_undoc <= 1'b1;
				case( mcycle )
				3'd1, 3'd7:
					set_addr_to <= axy;
				3'd2:
					alu_op <= 4'h9;
					tstates <= 3'd4;
				default:
					begin
						//	hold
					end
				endcase
			end
		 8'h46, 8'h4E, 8'h56, 8'h5E, 8'h66, 8'h6E, 8'h76, 8'h7E :
			// bit b,(hl)
			mcycles <= 3'd2;
			case( mcycle )
			3'd1, 3'd7:
				set_addr_to <= axy;
			3'd2:
				alu_op <= 4'h9;
				tstates <= 3'd4;
			default:
				begin
					//	hold
				end
			endcase
		8'hC0, 8'hC1, 8'hC2, 8'hC3, 8'hC4, 8'hC5, 8'hC7
		, 8'hC8, 8'hC9, 8'hCA, 8'hCB, 8'hCC, 8'hCD, 8'hCF
		, 8'hD0, 8'hD1, 8'hD2, 8'hD3, 8'hD4, 8'hD5, 8'hD7
		, 8'hD8, 8'hD9, 8'hDA, 8'hDB, 8'hDC, 8'hDD, 8'hDF
		, 8'hE0, 8'hE1, 8'hE2, 8'hE3, 8'hE4, 8'hE5, 8'hE7
		, 8'hE8, 8'hE9, 8'hEA, 8'hEB, 8'hEC, 8'hED, 8'hEF
		, 8'hF0, 8'hF1, 8'hF2, 8'hF3, 8'hF4, 8'hF5, 8'hF7
		, 8'hF8, 8'hF9, 8'hFA, 8'hFB, 8'hFC, 8'hFD, 8'hFF:
			// set b,r
			if( xy_state=2'b00 ) begin
				if( mcycle = 3'd1 ) begin
				  alu_op <= 4'hA;
				  read_to_reg <= 1'b1;
				  save_alu <= 1'b1;
				end
			else
			// set b,(ix+d),reg, undocumented
				mcycles <= 3'd3;
				xybit_undoc <= 1'b1;
				case( mcycle )
				3'd1, 3'd7:
					set_addr_to <= axy;
				3'd2:
					alu_op <= 4'hA;
					read_to_reg <= 1'b1;
					save_alu <= 1'b1;
					set_addr_to <= axy;
					tstates <= 3'd4;
				3'd3:
					write <= 1'b1;
				default:
					begin
						//	hold
					end
				endcase
			end
		 8'hC6, 8'hCE, 8'hD6, 8'hDE, 8'hE6, 8'hEE, 8'hF6, 8'hFE :
			// set b,(hl)
			mcycles <= 3'd3;
			case( mcycle )
			3'd1, 3'd7:
				set_addr_to <= axy;
			3'd2:
				alu_op <= 4'hA;
				read_to_reg <= 1'b1;
				save_alu <= 1'b1;
				set_addr_to <= axy;
				tstates <= 3'd4;
			3'd3:
				write <= 1'b1;
			default:
				begin
					//	hold
				end
			endcase
		8'h80, 8'h81, 8'h82, 8'h83, 8'h84, 8'h85, 8'h87
		, 8'h88, 8'h89, 8'h8A, 8'h8B, 8'h8C, 8'h8D, 8'h8F
		, 8'h90, 8'h91, 8'h92, 8'h93, 8'h94, 8'h95, 8'h97
		, 8'h98, 8'h99, 8'h9A, 8'h9B, 8'h9C, 8'h9D, 8'h9F
		, 8'hA0, 8'hA1, 8'hA2, 8'hA3, 8'hA4, 8'hA5, 8'hA7
		, 8'hA8, 8'hA9, 8'hAA, 8'hAB, 8'hAC, 8'hAD, 8'hAF
		, 8'hB0, 8'hB1, 8'hB2, 8'hB3, 8'hB4, 8'hB5, 8'hB7
		, 8'hB8, 8'hB9, 8'hBA, 8'hBB, 8'hBC, 8'hBD, 8'hBF:
			// res b,r
			if( xy_state=2'b00 ) begin
				if( mcycle = 3'd1 ) begin
				  alu_op <= 4'hB;
				  read_to_reg <= 1'b1;
				  save_alu <= 1'b1;
				end
			else
			// res b,(ix+d),reg, undocumented
				mcycles <= 3'd3;
				xybit_undoc <= 1'b1;
				case( mcycle )
				3'd1, 3'd7:
					set_addr_to <= axy;
				3'd2:
					alu_op <= 4'hB;
					read_to_reg <= 1'b1;
					save_alu <= 1'b1;
					set_addr_to <= axy;
					tstates <= 3'd4;
				3'd3:
					write <= 1'b1;
				default:
					begin
						//	hold
					end
				endcase
			end

		 8'h86, 8'h8E, 8'h96, 8'h9E, 8'hA6, 8'hAE, 8'hB6, 8'hBE :
			// res b,(hl)
			mcycles <= 3'd3;
			case( mcycle )
			3'd1, 3'd7:
				set_addr_to <= axy;
			3'd2:
				alu_op <= 4'hB;
				read_to_reg <= 1'b1;
				save_alu <= 1'b1;
				set_addr_to <= axy;
				tstates <= 3'd4;
			3'd3:
				write <= 1'b1;
			default:
				begin
					//	hold
				end
			endcase
		endcase

	default:

//////////////////////////////////////////////////////////////////////////////
//
//		ed prefixed instructions
//
//////////////////////////////////////////////////////////////////////////////

			case( irb )
			8'h00, 8'h01, 8'h02, 8'h03, 8'h04, 8'h05, 8'h06, 8'h07
			, 8'h08, 8'h09, 8'h0A, 8'h0B, 8'h0C, 8'h0D, 8'h0E, 8'h0F
			, 8'h10, 8'h11, 8'h12, 8'h13, 8'h14, 8'h15, 8'h16, 8'h17
			, 8'h18, 8'h19, 8'h1A, 8'h1B, 8'h1C, 8'h1D, 8'h1E, 8'h1F
			, 8'h20, 8'h21, 8'h22, 8'h23, 8'h24, 8'h25, 8'h26, 8'h27
			, 8'h28, 8'h29, 8'h2A, 8'h2B, 8'h2C, 8'h2D, 8'h2E, 8'h2F
			, 8'h30, 8'h31, 8'h32, 8'h33, 8'h34, 8'h35, 8'h36, 8'h37
			, 8'h38, 8'h39, 8'h3A, 8'h3B, 8'h3C, 8'h3D, 8'h3E, 8'h3F
			, 8'h80, 8'h81, 8'h82, 8'h83, 8'h84, 8'h85, 8'h86, 8'h87
			, 8'h90, 8'h91, 8'h92, 8'h93, 8'h94, 8'h95, 8'h96, 8'h97
			, 8'h98, 8'h99, 8'h9A, 8'h9B, 8'h9C, 8'h9D, 8'h9E, 8'h9F
			, 											 8'hA4, 8'hA5, 8'hA6, 8'hA7
			, 											 8'hAC, 8'hAD, 8'hAE, 8'hAF
			, 											 8'hB4, 8'hB5, 8'hB6, 8'hB7
			, 											 8'hBC, 8'hBD, 8'hBE, 8'hBF
			, 8'hC0, 		   8'hC2, 			 8'hC4, 8'hC5, 8'hC6, 8'hC7
			, 8'hC8, 		   8'hCA, 8'hCB, 8'hCC, 8'hCD, 8'hCE, 8'hCF
			, 8'hD0, 		   8'hD2, 8'hD3, 8'hD4, 8'hD5, 8'hD6, 8'hD7
			, 8'hD8, 		   8'hDA, 8'hDB, 8'hDC, 8'hDD, 8'hDE, 8'hDF
			, 8'hE0, 8'hE1, 8'hE2, 8'hE3, 8'hE4, 8'hE5, 8'hE6, 8'hE7
			, 8'hE8, 8'hE9, 8'hEA, 8'hEB, 8'hEC, 8'hED, 8'hEE, 8'hEF
			, 8'hF0, 8'hF1, 8'hF2, 			 8'hF4, 8'hF5, 8'hF6, 8'hF7
			, 8'hF8, 8'hF9, 8'hFA, 8'hFB, 8'hFC, 8'hFD, 8'hFE, 8'hFF:
				begin
					//	no operation
				end
			 8'h7E, 8'h7F :
			 	begin
					// nop, undocumented
				end
			// 8 bit load group
			 8'h57 :
			 	begin
					// ld a,i
					special_ld <= 3'd4;
					tstates <= 3'd5;
				end
			 8'h5F :
			 	begin
					// ld a,r
					special_ld <= 3'd5;
					tstates <= 3'd5;
				end
			 8'h47 :
			 	begin
					// ld i,a
					special_ld <= 3'd6;
					tstates <= 3'd5;
				end
			 8'h4F :
			 	begin
					// ld r,a
					special_ld <= 3'd7;
					tstates <= 3'd5;
				end
			// 16 bit load group
			 8'h4B, 8'h5B, 8'h6B, 8'h7B :
			 	begin
					// ld dd,(nn)
					mcycles <= 3'd5;
					case( mcycle )
					3'd2:
							inc_pc <= 1'b1;
							ldz <= 1'b1;
					3'd3:
							set_addr_to <= azi;
							inc_pc <= 1'b1;
							ldw <= 1'b1;
					3'd4:
							read_to_reg <= 1'b1;
							if( ir[5:4] = 2'b11 ) begin
									set_busa_to <= 4'h8;
							else
									set_busa_to[2:1] <= ir[5:4];
									set_busa_to[0] <= 1'b1;
							end
							inc_wz <= 1'b1;
							set_addr_to <= azi;
					3'd5:
							read_to_reg <= 1'b1;
							if( ir[5:4] = 2'b11 ) begin
									set_busa_to <= 4'h9;
							else
									set_busa_to[2:1] <= ir[5:4];
									set_busa_to[0] <= 1'b0;
							end
					default:
						begin
							//	hold
						end
					endcase
				end
			 8'h43, 8'h53, 8'h63, 8'h73 :
			 	begin
					// ld (nn),dd
					mcycles <= 3'd5;
					case( mcycle )
					3'd2:
							inc_pc <= 1'b1;
							ldz <= 1'b1;
					3'd3:
							set_addr_to <= azi;
							inc_pc <= 1'b1;
							ldw <= 1'b1;
							if( ir[5:4] = 2'b11 ) begin
									set_busb_to <= 4'h8;
							else
									set_busb_to[2:1] <= ir[5:4];
									set_busb_to[0] <= 1'b1;
									set_busb_to[3] <= 1'b0;
							end
					3'd4:
							inc_wz <= 1'b1;
							set_addr_to <= azi;
							write <= 1'b1;
							if( ir[5:4] = 2'b11 ) begin
									set_busb_to <= 4'h9;
							else
									set_busb_to[2:1] <= ir[5:4];
									set_busb_to[0] <= 1'b0;
									set_busb_to[3] <= 1'b0;
							end
					3'd5:
							write <= 1'b1;
					default:
						begin
							//	hold
						end
					endcase
				end
			 8'hA0 ,  8'hA8 ,  8'hB0 ,  8'hB8 :
			 	begin
					// ldi, ldd, ldir, lddr
					mcycles <= 3'd4;
					case( mcycle )
					3'd1:
							set_addr_to <= axy;
							incdec_16 <= 4'hC; // bc
					3'd2:
							set_busb_to <= 4'h6;
							set_busa_to[2:0] <= 3'd7;
							alu_op <= 4'h0;
							set_addr_to <= ade;
							if( ir[3] == 1'b0 ) begin
									incdec_16 <= 4'h6; // ix
							else
									incdec_16 <= 4'hE;
							end
					3'd3:
							i_bt <= 1'b1;
							tstates <= 3'd5;
							write <= 1'b1;
							if( ir[3] == 1'b0 ) begin
									incdec_16 <= 4'h5; // de
							else
									incdec_16 <= 4'hD;
							end
					3'd4:
							noread <= 1'b1;
							tstates <= 3'd5;
					default:
						begin
							//	hold
						end
					endcase
				end
			 8'hA1 ,  8'hA9 ,  8'hB1 ,  8'hB9 :
			 	begin
					// cpi, cpd, cpir, cpdr
					mcycles <= 3'd4;
					case( mcycle )
					3'd1:
							set_addr_to <= axy;
							incdec_16 <= 4'hC; // bc
					3'd2:
							set_busb_to <= 4'h6;
							set_busa_to[2:0] <= 3'd7;
							alu_op <= 4'h7;
							alu_cpi <= 1'b1;
							save_alu <= 1'b1;
							preservec <= 1'b1;
							if( ir[3] = 1'b0 ) begin
									incdec_16 <= 4'h6;
							else
									incdec_16 <= 4'hE;
							end
					3'd3:
							noread <= 1'b1;
							i_bc <= 1'b1;
							tstates <= 3'd5;
					3'd4:
							noread <= 1'b1;
							tstates <= 3'd5;
					default:
						begin
							//	hold
						end
					endcase
				end
			 8'h44, 8'h4C, 8'h54, 8'h5C, 8'h64, 8'h6C, 8'h74, 8'h7C :
				begin
					// neg
					alu_op <= 4'h2;
					set_busb_to <= 4'h7;
					set_busa_to <= 4'hA;
					read_to_acc <= 1'b1;
					save_alu <= 1'b1;
				end
			 8'h46, 8'h4E, 8'h66, 8'h6E :
				// im 0
				imode <= 2'b00;
			 8'h56, 8'h76 :
				// im 1
				imode <= 2'b01;
			 8'h5E, 8'h77 :
				// im 2
				imode <= 2'b10;
			// 16 bit arithmetic
			 8'h4A, 8'h5A, 8'h6A, 8'h7A:
				begin
					// adc hl,ss
					mcycles <= 3'd3;
					case( mcycle )
					3'd2:
						begin
							noread <= 1'b1;
							alu_op <= 4'h1;
							read_to_reg <= 1'b1;
							save_alu <= 1'b1;
							set_busa_to[2:0] <= 3'd5;
							case to_integer(unsigned(ir[5:4])) is
							 3'd0, 3'd1, 3'd2:
									set_busb_to[2:1] <= ir[5:4];
							set_busb_to[0] <= 1'b1;
							default:
									set_busb_to <= 4'h8;
							endcase
							tstates <= 3'd4;
						end
					3'd3:
						begin
							noread <= 1'b1;
							read_to_reg <= 1'b1;
							save_alu <= 1'b1;
							alu_op <= 4'h1;
							set_busa_to[2:0] <= 3'd4;
							case to_integer(unsigned(ir[5:4])) is
							 3'd0, 3'd1, 3'd2:
									set_busb_to[2:1] <= ir[5:4];
									set_busb_to[0] <= 1'b0;
							 default:
									set_busb_to <= 4'h9;
							endcase
						end
					default:
					endcase
				end
			 8'h42, 8'h52, 8'h62, 8'h72 :
				begin
					// sbc hl,ss
					mcycles <= 3'd3;
					case( mcycle )
					3'd2:
						begin
							noread <= 1'b1;
							alu_op <= 4'h3;
							read_to_reg <= 1'b1;
							save_alu <= 1'b1;
							set_busa_to[2:0] <= 3'd5;
							case( d[ ir[5:4] ] )
							 3'd0, 3'd1, 3'd2:
							 	begin
									set_busb_to[2:1] <= ir[5:4];
									set_busb_to[0] <= 1'b1;
								end
							 default:
								set_busb_to <= 4'h8;
							endcase
							tstates <= 3'd4;
						end
					3'd3:
						begin
							noread <= 1'b1;
							alu_op <= 4'h3;
							read_to_reg <= 1'b1;
							save_alu <= 1'b1;
							set_busa_to[2:0] <= 3'd4;
							case( ir[5:4] )
							 3'd0, 3'd1, 3'd2:
								set_busb_to[2:1] <= ir[5:4];
							 default:
								set_busb_to <= 4'h9;
							endcase
						end
					default:
						begin
							//	hold
						end
					endcase
				end
			 8'h6F :
				begin
					// rld
					mcycles <= 3'd4;
					case( mcycle )
					 3'd2:
					 	begin
							noread <= 1'b1;
							set_addr_to <= axy;
						end
					 3'd3:
					 	begin
							read_to_reg <= 1'b1;
							set_busb_to[2:0] <= 3'd6;
							set_busa_to[2:0] <= 3'd7;
							alu_op <= 4'hD;
							tstates <= 3'd4;
							set_addr_to <= axy;
							save_alu <= 1'b1;
						end
					 3'd4:
					 	begin
							i_rld <= 1'b1;
							write <= 1'b1;
						end
					default:
						begin
							//	hold
						end
					endcase
				end
			 8'h67 :
				begin
					// rrd
					mcycles <= 3'd4;
					case( mcycle )
					 3'd2:
						set_addr_to <= axy;
					 3'd3:
					 	begin
							read_to_reg <= 1'b1;
							set_busb_to[2:0] <= 3'd6;
							set_busa_to[2:0] <= 3'd7;
							alu_op <= 4'hE;
							tstates <= 3'd4;
							set_addr_to <= axy;
							save_alu <= 1'b1;
						end
					 3'd4:
					 	begin
							i_rrd <= 1'b1;
							write <= 1'b1;
						end
					default:
						begin
							//	hold
						end
					endcase
				end
			 8'h45, 8'h4D, 8'h55, 8'h5D, 8'h65, 8'h6D, 8'h75, 8'h7D :
					// reti, retn
					mcycles <= 3'd3;
					case( mcycle )
					 3'd1:
						set_addr_to <= asp;
					 3'd2:
					 	begin
							incdec_16 <= 4'h7;
							set_addr_to <= asp;
							ldz <= 1'b1;
						end
					 3'd3:
					 	begin
							jump <= 1'b1;
							incdec_16 <= 4'h7;
							i_retn <= 1'b1;
						end
					default:
						begin
							//	hold
						end
					endcase
			 8'h40, 8'h48, 8'h50, 8'h58, 8'h60, 8'h68, 8'h70, 8'h78:
					// in r,(c)
					mcycles <= 3'd2;
					case( mcycle )
					3'd1:
						set_addr_to <= abc;
					3'd2:
						begin
							iorq <= 1'b1;
							if( ir[5:3] != 3'd6 ) begin
									read_to_reg <= 1'b1;
									set_busa_to[2:0] <= ir[5:3];
							end
							i_inrc <= 1'b1;
						end
					default:
						begin
							//	hold
						end
					endcase
			 8'h41, 8'h49, 8'h51, 8'h59, 8'h61, 8'h69, 8'h71, 8'h79:
					// out (c),r
					// out (c),0
					mcycles <= 3'd2;
					case( mcycle )
					3'd1:
						begin
							set_addr_to <= abc;
							set_busb_to[2:0] <= ir[5:3];
							if( ir[5:3] == 3'd6 ) begin
									set_busb_to[3] <= 1'b1;
							end
						end
					3'd2:
						begin
							write <= 1'b1;
							iorq <= 1'b1;
						end
					default:
						begin
							//	hold
						end
					endcase
			8'hA2, 8'hAA, 8'hB2, 8'hBA:
					// ini, ind, inir, indr
					mcycles <= 3'd4;
					case( mcycle )
					3'd1:
						begin
							set_addr_to <= abc;
							set_busb_to <= 4'hA;
							set_busa_to <= 4'h0;
							read_to_reg <= 1'b1;
							save_alu <= 1'b1;
							alu_op <= 4'h2;
						end
					3'd2:
						begin
							iorq <= 1'b1;
							set_busb_to <= 4'h6;
							set_addr_to <= axy;
						end
					3'd3:
						begin
							if( ir[3] == 1'b0 ) begin
									incdec_16 <= 4'h6;
							end
							else begin
									incdec_16 <= 4'hE;
							end
							tstates <= 3'd4;
							write <= 1'b1;
							i_btr <= 1'b1;
						end
					 3'd4:
						begin
							noread <= 1'b1;
							tstates <= 3'd5;
						end
					 default:
					 	begin
					 		//	hold
					 	end
					endcase
			8'hA3, 8'hAB, 8'hB3, 8'hBB :
				begin
					// outi, outd, otir, otdr
					mcycles <= 3'd4;
					case( mcycle )
					 3'd1:
					 	begin
							tstates <= 3'd5;
							set_addr_to <= axy;
							set_busb_to <= 4'hA;
							set_busa_to <= 4'h0;
							read_to_reg <= 1'b1;
							save_alu <= 1'b1;
							alu_op <= 4'h2;
						end
					 3'd2:
					 	begin
							set_busb_to <= 4'h6;
							set_addr_to <= abc;
						end
					 3'd3:
					 	begin
							if( ir[3] == 1'b0 ) begin
								incdec_16 <= 4'h6;	// 0242a
							end
							else begin
								incdec_16 <= 4'hE;	// 0242a
							end
							iorq <= 1'b1;
							write <= 1'b1;
							i_btr <= 1'b1;
						end
					 3'd4:
					 	begin
							noread <= 1'b1;
							tstates <= 3'd5;
						end
					 default:
					 	begin
					 		//	hold
					 	end
					endcase
				end
			 8'hC1, 8'hC9, 8'hD1, 8'hD9:
			 	begin
					//r800 mulub
				end
			 8'hC3, 8'hF3 :
			 	begin
					//r800 muluw
				end
			endcase

		endcase

		if( mode == 1 ) begin
			if( mcycle == 3'd1 ) begin
//						tstates <= 3'd4;
			end
			else begin
				tstates <= 3'd3;
			end
		end
		else begin
			if( mcycle == 3'd6 ) begin
				inc_pc <= 1'b1;
				if( mode == 1 ) begin
					set_addr_to <= axy;
					tstates <= 3'd4;
					set_busb_to[2:0] <= sss;
					set_busb_to[3] <= 1'b0;
				end
				if( irb == 8'h36 || irb == 8'hCB ) begin
					set_addr_to <= anone;
				end
			end
			if( mcycle == 3'd7 ) begin
				if( mode == 0 ) begin
					tstates <= 3'd5;
				end
				if( iset != 2'b01 ) begin
					set_addr_to <= axy;
				end
				set_busb_to[2:0] <= sss;
				set_busb_to[3] <= 1'b0;
				if( irb == 8'h36 || iset == 2'b01 ) begin
					// ld (hl),n
					inc_pc <= 1'b1;
				else
					noread <= 1'b1;
				end
			end
		end
	end
endmodule
