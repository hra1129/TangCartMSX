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

module t80_mcode (
		generic(
				mode		: integer := 0;
				flag_c		: integer := 0;
				flag_n		: integer := 1;
				flag_p		: integer := 2;
				flag_x		: integer := 3;
				flag_h		: integer := 4;
				flag_y		: integer := 5;
				flag_z		: integer := 6;
				flag_s		: integer := 7
		);
		port(
				ir			: in std_logic_vector[7:0];
				iset		: in std_logic_vector[1:0];
				mcycle		: in std_logic_vector[2:0];
				f			: in std_logic_vector[7:0];
				nmicycle	: in std_logic;
				intcycle	: in std_logic;
				xy_state	: in std_logic_vector[1:0];
				mcycles		: out std_logic_vector[2:0];
				tstates		: out std_logic_vector[2:0];
				prefix		: out std_logic_vector[1:0]; // none,cb,ed,dd/fd
				inc_pc		: out std_logic;
				inc_wz		: out std_logic;
				incdec_16	: out std_logic_vector[3:0]; // bc,de,hl,sp	 0 is inc
				read_to_reg : out std_logic;
				read_to_acc : out std_logic;
				set_busa_to : out std_logic_vector[3:0]; // b,c,d,e,h,l,di/db,a,sp(l),sp(m),0,f
				set_busb_to : out std_logic_vector[3:0]; // b,c,d,e,h,l,di,a,sp(l),sp(m),1,f,pc(l),pc(m),0
				alu_op		: out std_logic_vector[3:0];
						// add, adc, sub, sbc, and, xor, or, cp, rot, bit, set, res, daa, rld, rrd, none
				alu_cpi		: out std_logic;	//for undoc xy-flags	   
				save_alu	: out std_logic;
				preservec	: out std_logic;
				arith16		: out std_logic;
				set_addr_to : out std_logic_vector[2:0]; // anone,axy,aioa,asp,abc,ade,azi
				iorq		: out std_logic;
				jump		: out std_logic;
				jumpe		: out std_logic;
				jumpxy		: out std_logic;
				call		: out std_logic;
				rstp		: out std_logic;
				ldz			: out std_logic;
				ldw			: out std_logic;
				ldsphl		: out std_logic;
				special_ld	: out std_logic_vector[2:0]; // a,i;a,r;i,a;r,a;none
				exchangedh	: out std_logic;
				exchangerp	: out std_logic;
				exchangeaf	: out std_logic;
				exchangers	: out std_logic;
				i_djnz		: out std_logic;
				i_cpl		: out std_logic;
				i_ccf		: out std_logic;
				i_scf		: out std_logic;
				i_retn		: out std_logic;
				i_bt		: out std_logic;
				i_bc		: out std_logic;
				i_btr		: out std_logic;
				i_rld		: out std_logic;
				i_rrd		: out std_logic;
				i_inrc		: out std_logic;
				setdi		: out std_logic;
				setei		: out std_logic;
				imode		: out std_logic_vector[1:0];
				halt		: out std_logic;
				noread		: out std_logic;
				write		: out std_logic;
				xybit_undoc : out std_logic
		);
end t80_mcode;

architecture rtl of t80_mcode is

		constant anone	: std_logic_vector[2:0] := 3'b111;
		constant abc	: std_logic_vector[2:0] := 3'b000;
		constant ade	: std_logic_vector[2:0] := 3'b001;
		constant axy	: std_logic_vector[2:0] := 3'b010;
		constant aioa	: std_logic_vector[2:0] := 3'b100;
		constant asp	: std_logic_vector[2:0] := 3'b101;
		constant azi	: std_logic_vector[2:0] := 3'b110;

		function is_cc_true(
				f : std_logic_vector[7:0];
				cc : bit_vector[2:0]
				) return boolean is
		begin
			case cc is
			 3'b000 : return f[6] = 1'b0; // nz
			 3'b001 : return f[6] = 1'b1; // z
			 3'b010 : return f[0] = 1'b0; // nc
			 3'b011 : return f[0] = 1'b1; // c
			 3'b100 : return f[2] = 1'b0; // po
			 3'b101 : return f[2] = 1'b1; // pe
			 3'b110 : return f[7] = 1'b0; // p
			 3'b111 : return f[7] = 1'b1; // m
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

			mcycles <= 3'b001;
			if( mcycle = 3'b001 ) begin
					tstates <= 3'b100;
			else
					tstates <= 3'b011;
			end
			prefix <= 2'b00;
			inc_pc <= 1'b0;
			inc_wz <= 1'b0;
			incdec_16 <= 4'b0000;
			read_to_acc <= 1'b0;
			read_to_reg <= 1'b0;
			set_busb_to <= 4'b0000;
			set_busa_to <= 4'b0000;
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
			special_ld <= 3'b000;
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
			8'b01000000, 8'b01000001, 8'b01000010, 8'b01000011, 8'b01000100, 8'b01000101, 8'b01000111, 
			8'b01001000, 8'b01001001, 8'b01001010, 8'b01001011, 8'b01001100, 8'b01001101, 8'b01001111, 
			8'b01010000, 8'b01010001, 8'b01010010, 8'b01010011, 8'b01010100, 8'b01010101, 8'b01010111, 
			8'b01011000, 8'b01011001, 8'b01011010, 8'b01011011, 8'b01011100, 8'b01011101, 8'b01011111, 
			8'b01100000, 8'b01100001, 8'b01100010, 8'b01100011, 8'b01100100, 8'b01100101, 8'b01100111, 
			8'b01101000, 8'b01101001, 8'b01101010, 8'b01101011, 8'b01101100, 8'b01101101, 8'b01101111, 
			8'b01111000, 8'b01111001, 8'b01111010, 8'b01111011, 8'b01111100, 8'b01111101, 8'b01111111:
				begin
					// ld r,r'
					set_busb_to[2:0] <= sss;
					exchangerp <= 1'b1;
					set_busa_to[2:0] <= ddd;
					read_to_reg <= 1'b1;
				end
			8'b00000110, 8'b00001110, 8'b00010110, 8'b00011110, 8'b00100110, 8'b00101110, 8'b00111110 :
				begin
					// ld r,n
					mcycles <= 3'b010;
					case( mcycle )
					3'd2:
							inc_pc <= 1'b1;
							set_busa_to[2:0] <= ddd;
							read_to_reg <= 1'b1;
					 others : null;
					endcase
				end
			8'b01000110, 8'b01001110, 8'b01010110, 8'b01011110, 8'b01100110, 8'b01101110, 8'b01111110 :
				begin
					// ld r,(hl)
					mcycles <= 3'b010;
					case( mcycle )
					3'd1:
							set_addr_to <= axy;
					3'd2:
							set_busa_to[2:0] <= ddd;
							read_to_reg <= 1'b1;
					 others : null;
					endcase
				end
			 8'b01110000, 8'b01110001, 8'b01110010, 8'b01110011, 8'b01110100, 8'b01110101, 8'b01110111 :
				begin
					// ld (hl),r
					mcycles <= 3'b010;
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
			 8'b00110110 :
				begin
					// ld (hl),n
					mcycles <= 3'b011;
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
			 8'b00001010 :
				begin
					// ld a,(bc)
					mcycles <= 3'b010;
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
			 8'b00011010 :
				begin
					// ld a,(de)
					mcycles <= 3'b010;
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
			 8'b00111010 :
				begin
					// ld a,(nn)
					mcycles <= 3'b100;
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
			 8'b00000010 :
				begin
					// ld (bc),a
					mcycles <= 3'b010;
					case( mcycle )
					3'd1:
							set_addr_to <= abc;
							set_busb_to <= 4'b0111;
					3'd2:
							write <= 1'b1;
					default:
						begin
							//	hold
						end
					endcase
				end
			 8'b00010010 :
				begin
					// ld (de),a
					mcycles <= 3'b010;
					case( mcycle )
					3'd1:
							set_addr_to <= ade;
							set_busb_to <= 4'b0111;
					3'd2:
							write <= 1'b1;
					default:
						begin
							//	hold
						end
					endcase
				end
			 8'b00110010 :
				begin
					// ld (nn),a
					mcycles <= 3'b100;
					case( mcycle )
					3'd2:
							inc_pc <= 1'b1;
							ldz <= 1'b1;
					3'd3:
							set_addr_to <= azi;
							inc_pc <= 1'b1;
							set_busb_to <= 4'b0111;
					3'd4:
							write <= 1'b1;
					default:
						begin
							//	hold
						end
					endcase
				end
// 16 bit load group
			 8'b00000001, 8'b00010001, 8'b00100001, 8'b00110001 :
				begin
					// ld dd,nn
					mcycles <= 3'b011;
					case( mcycle )
					3'd2:
						begin
							inc_pc <= 1'b1;
							read_to_reg <= 1'b1;
							if( dpair == 2'b11 ) begin
									set_busa_to[3:0] <= 4'b1000;
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
									set_busa_to[3:0] <= 4'b1001;
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
			 8'b00101010 :
					// ld hl,(nn)
					mcycles <= 3'b101;
					case( mcycle )
					3'd2:
							inc_pc <= 1'b1;
							ldz <= 1'b1;
					3'd3:
							set_addr_to <= azi;
							inc_pc <= 1'b1;
							ldw <= 1'b1;
					3'd4:
							set_busa_to[2:0] <= 3'b101; // l
							read_to_reg <= 1'b1;
							inc_wz <= 1'b1;
							set_addr_to <= azi;
					3'd5:
							set_busa_to[2:0] <= 3'b100; // h
							read_to_reg <= 1'b1;
					default:
						begin
							//	hold
						end
					endcase
			 8'b00100010 :
					// ld (nn),hl
					mcycles <= 3'b101;
					case( mcycle )
					3'd2:
							inc_pc <= 1'b1;
							ldz <= 1'b1;
					3'd3:
							set_addr_to <= azi;
							inc_pc <= 1'b1;
							ldw <= 1'b1;
							set_busb_to <= 4'b0101; // l
					3'd4:
							inc_wz <= 1'b1;
							set_addr_to <= azi;
							write <= 1'b1;
							set_busb_to <= 4'b0100; // h
					3'd5:
							write <= 1'b1;
					default:
						begin
							//	hold
						end
					endcase
			 8'b11111001 :
					// ld sp,hl
					tstates <= 3'b110;
					ldsphl <= 1'b1;
			 8'b11000101|8'b11010101|8'b11100101|8'b11110101 :
					// push qq
					mcycles <= 3'b011;
					case( mcycle )
					3'd1:
							tstates <= 3'b101;
							incdec_16 <= 4'b1111;
							set_addr_to <= asp;
							if( dpair = 2'b11 ) begin
									set_busb_to <= 4'b0111;
							else
									set_busb_to[2:1] <= dpair;
									set_busb_to[0] <= 1'b0;
									set_busb_to[3] <= 1'b0;
							end
					3'd2:
							incdec_16 <= 4'b1111;
							set_addr_to <= asp;
							if( dpair = 2'b11 ) begin
									set_busb_to <= 4'b1011;
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
			 8'b11000001|8'b11010001|8'b11100001|8'b11110001 :
					// pop qq
					mcycles <= 3'b011;
					case( mcycle )
					3'd1:
							set_addr_to <= asp;
					3'd2:
							incdec_16 <= 4'b0111;
							set_addr_to <= asp;
							read_to_reg <= 1'b1;
							if( dpair = 2'b11 ) begin
									set_busa_to[3:0] <= 4'b1011;
							else
									set_busa_to[2:1] <= dpair;
									set_busa_to[0] <= 1'b1;
							end
					3'd3:
							incdec_16 <= 4'b0111;
							read_to_reg <= 1'b1;
							if( dpair = 2'b11 ) begin
									set_busa_to[3:0] <= 4'b0111;
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
			 8'b11101011 :
					// ex de,hl
					exchangedh <= 1'b1;
			 8'b00001000 :
					// ex af,af'
					exchangeaf <= 1'b1;
			 8'b11011001 :
					// exx
					exchangers <= 1'b1;
			 8'b11100011 :
					// ex (sp),hl
					mcycles <= 3'b101;
					case( mcycle )
					3'd1:
							set_addr_to <= asp;
					3'd2:
							read_to_reg <= 1'b1;
							set_busa_to <= 4'b0101;
							set_busb_to <= 4'b0101;
							set_addr_to <= asp;
					3'd3:
							incdec_16 <= 4'b0111;
							set_addr_to <= asp;
							tstates <= 3'b100;
							write <= 1'b1;
					3'd4:
							read_to_reg <= 1'b1;
							set_busa_to <= 4'b0100;
							set_busb_to <= 4'b0100;
							set_addr_to <= asp;
					3'd5:
							incdec_16 <= 4'b1111;
							tstates <= 3'b101;
							write <= 1'b1;
					default:
						begin
							//	hold
						end
					endcase

// 8 bit arithmetic and logical group
			when 8'b10000000|8'b10000001|8'b10000010|8'b10000011|8'b10000100|8'b10000101|8'b10000111
					|8'b10001000|8'b10001001|8'b10001010|8'b10001011|8'b10001100|8'b10001101|8'b10001111
					|8'b10010000|8'b10010001|8'b10010010|8'b10010011|8'b10010100|8'b10010101|8'b10010111
					|8'b10011000|8'b10011001|8'b10011010|8'b10011011|8'b10011100|8'b10011101|8'b10011111
					|8'b10100000|8'b10100001|8'b10100010|8'b10100011|8'b10100100|8'b10100101|8'b10100111
					|8'b10101000|8'b10101001|8'b10101010|8'b10101011|8'b10101100|8'b10101101|8'b10101111
					|8'b10110000|8'b10110001|8'b10110010|8'b10110011|8'b10110100|8'b10110101|8'b10110111
					|8'b10111000|8'b10111001|8'b10111010|8'b10111011|8'b10111100|8'b10111101|8'b10111111 =>
					// add a,r
					// adc a,r
					// sub a,r
					// sbc a,r
					// and a,r
					// or a,r
					// xor a,r
					// cp a,r
					set_busb_to[2:0] <= sss;
					set_busa_to[2:0] <= 3'b111;
					read_to_reg <= 1'b1;
					save_alu <= 1'b1;
			 8'b10000110|8'b10001110|8'b10010110|8'b10011110|8'b10100110|8'b10101110|8'b10110110|8'b10111110 :
					// add a,(hl)
					// adc a,(hl)
					// sub a,(hl)
					// sbc a,(hl)
					// and a,(hl)
					// or a,(hl)
					// xor a,(hl)
					// cp a,(hl)
					mcycles <= 3'b010;
					case( mcycle )
					3'd1:
							set_addr_to <= axy;
					3'd2:
							read_to_reg <= 1'b1;
							save_alu <= 1'b1;
							set_busb_to[2:0] <= sss;
							set_busa_to[2:0] <= 3'b111;
					default:
						begin
							//	hold
						end
					endcase
			 8'b11000110|8'b11001110|8'b11010110|8'b11011110|8'b11100110|8'b11101110|8'b11110110|8'b11111110 :
					// add a,n
					// adc a,n
					// sub a,n
					// sbc a,n
					// and a,n
					// or a,n
					// xor a,n
					// cp a,n
					mcycles <= 3'b010;
					if( mcycle = 3'b010 ) begin
							inc_pc <= 1'b1;
							read_to_reg <= 1'b1;
							save_alu <= 1'b1;
							set_busb_to[2:0] <= sss;
							set_busa_to[2:0] <= 3'b111;
					end
			 8'b00000100|8'b00001100|8'b00010100|8'b00011100|8'b00100100|8'b00101100|8'b00111100 :
					// inc r
					set_busb_to <= 4'b1010;
					set_busa_to[2:0] <= ddd;
					read_to_reg <= 1'b1;
					save_alu <= 1'b1;
					preservec <= 1'b1;
					alu_op <= 4'b0000;
			 8'b00110100 :
					// inc (hl)
					mcycles <= 3'b011;
					case( mcycle )
					3'd1:
							set_addr_to <= axy;
					3'd2:
							tstates <= 3'b100;
							set_addr_to <= axy;
							read_to_reg <= 1'b1;
							save_alu <= 1'b1;
							preservec <= 1'b1;
							alu_op <= 4'b0000;
							set_busb_to <= 4'b1010;
							set_busa_to[2:0] <= ddd;
					3'd3:
							write <= 1'b1;
					default:
						begin
							//	hold
						end
					endcase
			 8'b00000101|8'b00001101|8'b00010101|8'b00011101|8'b00100101|8'b00101101|8'b00111101 :
					// dec r
					set_busb_to <= 4'b1010;
					set_busa_to[2:0] <= ddd;
					read_to_reg <= 1'b1;
					save_alu <= 1'b1;
					preservec <= 1'b1;
					alu_op <= 4'b0010;
			 8'b00110101 :
					// dec (hl)
					mcycles <= 3'b011;
					case( mcycle )
					3'd1:
							set_addr_to <= axy;
					3'd2:
							tstates <= 3'b100;
							set_addr_to <= axy;
							alu_op <= 4'b0010;
							read_to_reg <= 1'b1;
							save_alu <= 1'b1;
							preservec <= 1'b1;
							set_busb_to <= 4'b1010;
							set_busa_to[2:0] <= ddd;
					3'd3:
							write <= 1'b1;
					default:
						begin
							//	hold
						end
					endcase

// general purpose arithmetic and cpu control groups
			 8'b00100111 :
					// daa
					set_busa_to[2:0] <= 3'b111;
					read_to_reg <= 1'b1;
					alu_op <= 4'b1100;
					save_alu <= 1'b1;
			 8'b00101111 :
					// cpl
					i_cpl <= 1'b1;
			 8'b00111111 :
					// ccf
					i_ccf <= 1'b1;
			 8'b00110111 :
					// scf
					i_scf <= 1'b1;
			 8'b00000000 :
					if( nmicycle = 1'b1 ) begin
							// nmi
							mcycles <= 3'b011;
							case( mcycle )
							3'd1:
									tstates <= 3'b101;
									incdec_16 <= 4'b1111;
									set_addr_to <= asp;
									set_busb_to <= 4'b1101;
							3'd2:
									tstates <= 3'b100;
									write <= 1'b1;
									incdec_16 <= 4'b1111;
									set_addr_to <= asp;
									set_busb_to <= 4'b1100;
							3'd3:
									tstates <= 3'b100;
									write <= 1'b1;
							default:
								begin
									//	hold
								end
							endcase
					else if( intcycle = 1'b1 ) begin
							// int (im 2)
							mcycles <= 3'b101;
							case( mcycle )
							3'd1:
									ldz <= 1'b1;
									tstates <= 3'b101;
									incdec_16 <= 4'b1111;
									set_addr_to <= asp;
									set_busb_to <= 4'b1101;
							3'd2:
									tstates <= 3'b100;
									write <= 1'b1;
									incdec_16 <= 4'b1111;
									set_addr_to <= asp;
									set_busb_to <= 4'b1100;
							3'd3:
									tstates <= 3'b100;
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
			 8'b01110110 :
					// halt
					halt <= 1'b1;
			 8'b11110011 :
					// di
					setdi <= 1'b1;
			 8'b11111011 :
					// ei
					setei <= 1'b1;

// 16 bit arithmetic group
			 8'b00001001|8'b00011001|8'b00101001|8'b00111001 :
					// add hl,ss
					mcycles <= 3'b011;
					case( mcycle )
					3'd2:
							noread <= 1'b1;
							alu_op <= 4'b0000;
							read_to_reg <= 1'b1;
							save_alu <= 1'b1;
							set_busa_to[2:0] <= 3'b101;
							case to_integer(unsigned(ir[5:4])) is
							 3'd0, 3'd1, 3'd2:
									set_busb_to[2:1] <= ir[5:4];
									set_busb_to[0] <= 1'b1;
							 others :
									set_busb_to <= 4'b1000;
							endcase
							tstates <= 3'b100;
							arith16 <= 1'b1;
					3'd3:
							noread <= 1'b1;
							read_to_reg <= 1'b1;
							save_alu <= 1'b1;
							alu_op <= 4'b0001;
							set_busa_to[2:0] <= 3'b100;
							case to_integer(unsigned(ir[5:4])) is
							 3'd0, 3'd1, 3'd2:
									set_busb_to[2:1] <= ir[5:4];
							 others :
									set_busb_to <= 4'b1001;
							endcase
							arith16 <= 1'b1;
					default:
						begin
							//	hold
						end
					endcase
			 8'b00000011|8'b00010011|8'b00100011|8'b00110011 :
					// inc ss
					tstates <= 3'b110;
					incdec_16[3:2] <= 2'b01;
					incdec_16[1:0] <= dpair;
			 8'b00001011|8'b00011011|8'b00101011|8'b00111011 :
					// dec ss
					tstates <= 3'b110;
					incdec_16[3:2] <= 2'b11;
					incdec_16[1:0] <= dpair;

// rotate and shift group
			when 8'b00000111
					// rlca
					|8'b00010111
					// rla
					|8'b00001111
					// rrca
					|8'b00011111 =>
					// rra
					set_busa_to[2:0] <= 3'b111;
					alu_op <= 4'b1000;
					read_to_reg <= 1'b1;
					save_alu <= 1'b1;

// jump group
			 8'b11000011 :
					// jp nn
					mcycles <= 3'b011;
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
			 8'b11000010|8'b11001010|8'b11010010|8'b11011010|8'b11100010|8'b11101010|8'b11110010|8'b11111010 :
					// jp cc,nn
					mcycles <= 3'b011;
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
			 8'b00011000 :
					// jr e
					mcycles <= 3'b011;
					case( mcycle )
					3'd2:
							inc_pc <= 1'b1;
					3'd3:
							noread <= 1'b1;
							jumpe <= 1'b1;
							tstates <= 3'b101;
					default:
						begin
							//	hold
						end
					endcase
			 8'b00111000 :
					// jr c,e
					mcycles <= 3'b011;
					case( mcycle )
					3'd2:
							inc_pc <= 1'b1;
							if( f(flag_c) = 1'b0 ) begin
									mcycles <= 3'b010;
							end
					3'd3:
							noread <= 1'b1;
							jumpe <= 1'b1;
							tstates <= 3'b101;
					default:
						begin
							//	hold
						end
					endcase
			 8'b00110000 :
					// jr nc,e
					mcycles <= 3'b011;
					case( mcycle )
					3'd2:
							inc_pc <= 1'b1;
							if( f(flag_c) = 1'b1 ) begin
									mcycles <= 3'b010;
							end
					3'd3:
							noread <= 1'b1;
							jumpe <= 1'b1;
							tstates <= 3'b101;
					default:
						begin
							//	hold
						end
					endcase
			 8'b00101000 :
					// jr z,e
					mcycles <= 3'b011;
					case( mcycle )
					3'd2:
							inc_pc <= 1'b1;
							if( f(flag_z) = 1'b0 ) begin
									mcycles <= 3'b010;
							end
					3'd3:
							noread <= 1'b1;
							jumpe <= 1'b1;
							tstates <= 3'b101;
					default:
						begin
							//	hold
						end
					endcase
			 8'b00100000 :
					// jr nz,e
					mcycles <= 3'b011;
					case( mcycle )
					3'd2:
							inc_pc <= 1'b1;
							if( f(flag_z) = 1'b1 ) begin
									mcycles <= 3'b010;
							end
					3'd3:
							noread <= 1'b1;
							jumpe <= 1'b1;
							tstates <= 3'b101;
					default:
						begin
							//	hold
						end
					endcase
			 8'b11101001 :
					// jp (hl)
					jumpxy <= 1'b1;
			 8'b00010000 :
					// djnz,e
					mcycles <= 3'b011;
					case( mcycle )
					3'd1:
							tstates <= 3'b101;
							i_djnz <= 1'b1;
							set_busb_to <= 4'b1010;
							set_busa_to[2:0] <= 3'b000;
							read_to_reg <= 1'b1;
							save_alu <= 1'b1;
							alu_op <= 4'b0010;
					3'd2:
							i_djnz <= 1'b1;
							inc_pc <= 1'b1;
					3'd3:
							noread <= 1'b1;
							jumpe <= 1'b1;
							tstates <= 3'b101;
					default:
						begin
							//	hold
						end
					endcase

// call and return group
			 8'b11001101 :
					// call nn
					mcycles <= 3'b101;
					case( mcycle )
					3'd2:
							inc_pc <= 1'b1;
							ldz <= 1'b1;
					3'd3:
							incdec_16 <= 4'b1111;
							inc_pc <= 1'b1;
							tstates <= 3'b100;
							set_addr_to <= asp;
							ldw <= 1'b1;
							set_busb_to <= 4'b1101;
					3'd4:
							write <= 1'b1;
							incdec_16 <= 4'b1111;
							set_addr_to <= asp;
							set_busb_to <= 4'b1100;
					3'd5:
							write <= 1'b1;
							call <= 1'b1;
					default:
						begin
							//	hold
						end
					endcase
			 8'b11000100|8'b11001100|8'b11010100|8'b11011100|8'b11100100|8'b11101100|8'b11110100|8'b11111100 :
					// call cc,nn
					mcycles <= 3'b101;
					case( mcycle )
					3'd2:
							inc_pc <= 1'b1;
							ldz <= 1'b1;
					3'd3:
							inc_pc <= 1'b1;
							ldw <= 1'b1;
							if( is_cc_true(f, to_bitvector(ir[5:3])) ) begin
									incdec_16 <= 4'b1111;
									set_addr_to <= asp;
									tstates <= 3'b100;
									set_busb_to <= 4'b1101;
							else
									mcycles <= 3'b011;
							end
					3'd4:
							write <= 1'b1;
							incdec_16 <= 4'b1111;
							set_addr_to <= asp;
							set_busb_to <= 4'b1100;
					3'd5:
							write <= 1'b1;
							call <= 1'b1;
					default:
						begin
							//	hold
						end
					endcase
			 8'b11001001 :
					// ret
					mcycles <= 3'b011;
					case( mcycle )
					3'd1:
							tstates <= 3'b101;
							set_addr_to <= asp;
					3'd2:
							incdec_16 <= 4'b0111;
							set_addr_to <= asp;
							ldz <= 1'b1;
					3'd3:
							jump <= 1'b1;
							incdec_16 <= 4'b0111;
					default:
						begin
							//	hold
						end
					endcase
			 8'b11000000|8'b11001000|8'b11010000|8'b11011000|8'b11100000|8'b11101000|8'b11110000|8'b11111000 :
					// ret cc
					mcycles <= 3'b011;
					case( mcycle )
					3'd1:
							if( is_cc_true(f, to_bitvector(ir[5:3])) ) begin
									set_addr_to <= asp;
							else
									mcycles <= 3'b001;
							end
							tstates <= 3'b101;
					3'd2:
							incdec_16 <= 4'b0111;
							set_addr_to <= asp;
							ldz <= 1'b1;
					3'd3:
							jump <= 1'b1;
							incdec_16 <= 4'b0111;
					default:
						begin
							//	hold
						end
					endcase
			 8'b11000111|8'b11001111|8'b11010111|8'b11011111|8'b11100111|8'b11101111|8'b11110111|8'b11111111 :
					// rst p
					mcycles <= 3'b011;
					case( mcycle )
					3'd1:
							tstates <= 3'b101;
							incdec_16 <= 4'b1111;
							set_addr_to <= asp;
							set_busb_to <= 4'b1101;
					3'd2:
							write <= 1'b1;
							incdec_16 <= 4'b1111;
							set_addr_to <= asp;
							set_busb_to <= 4'b1100;
					3'd3:
							write <= 1'b1;
							rstp <= 1'b1;
					default:
						begin
							//	hold
						end
					endcase

// input and output group
			 8'b11011011 :
					// in a,(n)
					mcycles <= 3'b011;
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
			 8'b11010011 :
					// out (n),a
					mcycles <= 3'b011;
					case( mcycle )
					3'd2:
							inc_pc <= 1'b1;
							set_addr_to <= aioa;
							set_busb_to		<= 4'b0111;
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

			 8'b11001011 :
					prefix <= 2'b01;

			 8'b11101101 :
					prefix <= 2'b10;

			 8'b11011101|8'b11111101 :
					prefix <= 2'b11;

			endcase

			 2'b01 :

// --------------------------------------------------------------------
//  cb prefixed instructions
// --------------------------------------------------------------------

		set_busa_to[2:0] <= ir[2:0];
		set_busb_to[2:0] <= ir[2:0];

		case irb is
		when 8'b00000000|8'b00000001|8'b00000010|8'b00000011|8'b00000100|8'b00000101|8'b00000111
			|8'b00010000|8'b00010001|8'b00010010|8'b00010011|8'b00010100|8'b00010101|8'b00010111
			|8'b00001000|8'b00001001|8'b00001010|8'b00001011|8'b00001100|8'b00001101|8'b00001111
			|8'b00011000|8'b00011001|8'b00011010|8'b00011011|8'b00011100|8'b00011101|8'b00011111
			|8'b00100000|8'b00100001|8'b00100010|8'b00100011|8'b00100100|8'b00100101|8'b00100111
			|8'b00101000|8'b00101001|8'b00101010|8'b00101011|8'b00101100|8'b00101101|8'b00101111
			|8'b00110000|8'b00110001|8'b00110010|8'b00110011|8'b00110100|8'b00110101|8'b00110111
			|8'b00111000|8'b00111001|8'b00111010|8'b00111011|8'b00111100|8'b00111101|8'b00111111 =>
			// rlc r
			// rl r
			// rrc r
			// rr r
			// sla r
			// sra r
			// srl r
			// sll r (undocumented) / swap r
			if( xy_state=2'b00 ) begin
				if( mcycle = 3'b001 ) begin
				  alu_op <= 4'b1000;
				  read_to_reg <= 1'b1;
				  save_alu <= 1'b1;
				end
			else
			// r/s (ix+d),reg, undocumented
				mcycles <= 3'b011;
				xybit_undoc <= 1'b1;
				case( mcycle )
				3'd1, 3'd7:
					set_addr_to <= axy;
				3'd2:
					alu_op <= 4'b1000;
					read_to_reg <= 1'b1;
					save_alu <= 1'b1;
					set_addr_to <= axy;
					tstates <= 3'b100;
				3'd3:
					write <= 1'b1;
				default:
					begin
						//	hold
					end
				endcase
			end


		 8'b00000110|8'b00010110|8'b00001110|8'b00011110|8'b00101110|8'b00111110|8'b00100110|8'b00110110 :
			// rlc (hl)
			// rl (hl)
			// rrc (hl)
			// rr (hl)
			// sra (hl)
			// srl (hl)
			// sla (hl)
			// sll (hl) (undocumented) / swap (hl)
			mcycles <= 3'b011;
			case( mcycle )
			3'd1, 3'd7:
				set_addr_to <= axy;
			3'd2:
				alu_op <= 4'b1000;
				read_to_reg <= 1'b1;
				save_alu <= 1'b1;
				set_addr_to <= axy;
				tstates <= 3'b100;
			3'd3:
				write <= 1'b1;
			default:
				begin
					//	hold
				end
			endcase
		when 8'b01000000|8'b01000001|8'b01000010|8'b01000011|8'b01000100|8'b01000101|8'b01000111
			|8'b01001000|8'b01001001|8'b01001010|8'b01001011|8'b01001100|8'b01001101|8'b01001111
			|8'b01010000|8'b01010001|8'b01010010|8'b01010011|8'b01010100|8'b01010101|8'b01010111
			|8'b01011000|8'b01011001|8'b01011010|8'b01011011|8'b01011100|8'b01011101|8'b01011111
			|8'b01100000|8'b01100001|8'b01100010|8'b01100011|8'b01100100|8'b01100101|8'b01100111
			|8'b01101000|8'b01101001|8'b01101010|8'b01101011|8'b01101100|8'b01101101|8'b01101111
			|8'b01110000|8'b01110001|8'b01110010|8'b01110011|8'b01110100|8'b01110101|8'b01110111
			|8'b01111000|8'b01111001|8'b01111010|8'b01111011|8'b01111100|8'b01111101|8'b01111111 =>
			// bit b,r
			if( xy_state=2'b00 ) begin
				if( mcycle = 3'b001 ) begin
				  set_busb_to[2:0] <= ir[2:0];
				  alu_op <= 4'b1001;
				end
			else
			// bit b,(ix+d), undocumented
				mcycles <= 3'b010;
				xybit_undoc <= 1'b1;
				case( mcycle )
				3'd1, 3'd7:
					set_addr_to <= axy;
				3'd2:
					alu_op <= 4'b1001;
					tstates <= 3'b100;
				default:
					begin
						//	hold
					end
				endcase
			end
		 8'b01000110|8'b01001110|8'b01010110|8'b01011110|8'b01100110|8'b01101110|8'b01110110|8'b01111110 :
			// bit b,(hl)
			mcycles <= 3'b010;
			case( mcycle )
			3'd1, 3'd7:
				set_addr_to <= axy;
			3'd2:
				alu_op <= 4'b1001;
				tstates <= 3'b100;
			default:
				begin
					//	hold
				end
			endcase
		when 8'b11000000|8'b11000001|8'b11000010|8'b11000011|8'b11000100|8'b11000101|8'b11000111
			|8'b11001000|8'b11001001|8'b11001010|8'b11001011|8'b11001100|8'b11001101|8'b11001111
			|8'b11010000|8'b11010001|8'b11010010|8'b11010011|8'b11010100|8'b11010101|8'b11010111
			|8'b11011000|8'b11011001|8'b11011010|8'b11011011|8'b11011100|8'b11011101|8'b11011111
			|8'b11100000|8'b11100001|8'b11100010|8'b11100011|8'b11100100|8'b11100101|8'b11100111
			|8'b11101000|8'b11101001|8'b11101010|8'b11101011|8'b11101100|8'b11101101|8'b11101111
			|8'b11110000|8'b11110001|8'b11110010|8'b11110011|8'b11110100|8'b11110101|8'b11110111
			|8'b11111000|8'b11111001|8'b11111010|8'b11111011|8'b11111100|8'b11111101|8'b11111111 =>
			// set b,r
			if( xy_state=2'b00 ) begin
				if( mcycle = 3'b001 ) begin
				  alu_op <= 4'b1010;
				  read_to_reg <= 1'b1;
				  save_alu <= 1'b1;
				end
			else
			// set b,(ix+d),reg, undocumented
				mcycles <= 3'b011;
				xybit_undoc <= 1'b1;
				case( mcycle )
				3'd1, 3'd7:
					set_addr_to <= axy;
				3'd2:
					alu_op <= 4'b1010;
					read_to_reg <= 1'b1;
					save_alu <= 1'b1;
					set_addr_to <= axy;
					tstates <= 3'b100;
				3'd3:
					write <= 1'b1;
				default:
					begin
						//	hold
					end
				endcase
			end
		 8'b11000110|8'b11001110|8'b11010110|8'b11011110|8'b11100110|8'b11101110|8'b11110110|8'b11111110 :
			// set b,(hl)
			mcycles <= 3'b011;
			case( mcycle )
			3'd1, 3'd7:
				set_addr_to <= axy;
			3'd2:
				alu_op <= 4'b1010;
				read_to_reg <= 1'b1;
				save_alu <= 1'b1;
				set_addr_to <= axy;
				tstates <= 3'b100;
			3'd3:
				write <= 1'b1;
			default:
				begin
					//	hold
				end
			endcase
		when 8'b10000000|8'b10000001|8'b10000010|8'b10000011|8'b10000100|8'b10000101|8'b10000111
			|8'b10001000|8'b10001001|8'b10001010|8'b10001011|8'b10001100|8'b10001101|8'b10001111
			|8'b10010000|8'b10010001|8'b10010010|8'b10010011|8'b10010100|8'b10010101|8'b10010111
			|8'b10011000|8'b10011001|8'b10011010|8'b10011011|8'b10011100|8'b10011101|8'b10011111
			|8'b10100000|8'b10100001|8'b10100010|8'b10100011|8'b10100100|8'b10100101|8'b10100111
			|8'b10101000|8'b10101001|8'b10101010|8'b10101011|8'b10101100|8'b10101101|8'b10101111
			|8'b10110000|8'b10110001|8'b10110010|8'b10110011|8'b10110100|8'b10110101|8'b10110111
			|8'b10111000|8'b10111001|8'b10111010|8'b10111011|8'b10111100|8'b10111101|8'b10111111 =>
			// res b,r
			if( xy_state=2'b00 ) begin
				if( mcycle = 3'b001 ) begin
				  alu_op <= 4'b1011;
				  read_to_reg <= 1'b1;
				  save_alu <= 1'b1;
				end
			else
			// res b,(ix+d),reg, undocumented
				mcycles <= 3'b011;
				xybit_undoc <= 1'b1;
				case( mcycle )
				3'd1, 3'd7:
					set_addr_to <= axy;
				3'd2:
					alu_op <= 4'b1011;
					read_to_reg <= 1'b1;
					save_alu <= 1'b1;
					set_addr_to <= axy;
					tstates <= 3'b100;
				3'd3:
					write <= 1'b1;
				default:
					begin
						//	hold
					end
				endcase
			end

		 8'b10000110|8'b10001110|8'b10010110|8'b10011110|8'b10100110|8'b10101110|8'b10110110|8'b10111110 :
			// res b,(hl)
			mcycles <= 3'b011;
			case( mcycle )
			3'd1, 3'd7:
				set_addr_to <= axy;
			3'd2:
				alu_op <= 4'b1011;
				read_to_reg <= 1'b1;
				save_alu <= 1'b1;
				set_addr_to <= axy;
				tstates <= 3'b100;
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
			when 8'b00000000|8'b00000001|8'b00000010|8'b00000011|8'b00000100|8'b00000101|8'b00000110|8'b00000111
					|8'b00001000|8'b00001001|8'b00001010|8'b00001011|8'b00001100|8'b00001101|8'b00001110|8'b00001111
					|8'b00010000|8'b00010001|8'b00010010|8'b00010011|8'b00010100|8'b00010101|8'b00010110|8'b00010111
					|8'b00011000|8'b00011001|8'b00011010|8'b00011011|8'b00011100|8'b00011101|8'b00011110|8'b00011111
					|8'b00100000|8'b00100001|8'b00100010|8'b00100011|8'b00100100|8'b00100101|8'b00100110|8'b00100111
					|8'b00101000|8'b00101001|8'b00101010|8'b00101011|8'b00101100|8'b00101101|8'b00101110|8'b00101111
					|8'b00110000|8'b00110001|8'b00110010|8'b00110011|8'b00110100|8'b00110101|8'b00110110|8'b00110111
					|8'b00111000|8'b00111001|8'b00111010|8'b00111011|8'b00111100|8'b00111101|8'b00111110|8'b00111111


					|8'b10000000|8'b10000001|8'b10000010|8'b10000011|8'b10000100|8'b10000101|8'b10000110|8'b10000111
					|8'b10001000|8'b10001001|8'b10001010|8'b10001011|8'b10001100|8'b10001101|8'b10001110|8'b10001111
					|8'b10010000|8'b10010001|8'b10010010|8'b10010011|8'b10010100|8'b10010101|8'b10010110|8'b10010111
					|8'b10011000|8'b10011001|8'b10011010|8'b10011011|8'b10011100|8'b10011101|8'b10011110|8'b10011111
					|											 8'b10100100|8'b10100101|8'b10100110|8'b10100111
					|											 8'b10101100|8'b10101101|8'b10101110|8'b10101111
					|											 8'b10110100|8'b10110101|8'b10110110|8'b10110111
					|											 8'b10111100|8'b10111101|8'b10111110|8'b10111111
					|8'b11000000|		   8'b11000010|			 8'b11000100|8'b11000101|8'b11000110|8'b11000111
					|8'b11001000|		   8'b11001010|8'b11001011|8'b11001100|8'b11001101|8'b11001110|8'b11001111
					|8'b11010000|		   8'b11010010|8'b11010011|8'b11010100|8'b11010101|8'b11010110|8'b11010111
					|8'b11011000|		   8'b11011010|8'b11011011|8'b11011100|8'b11011101|8'b11011110|8'b11011111
					|8'b11100000|8'b11100001|8'b11100010|8'b11100011|8'b11100100|8'b11100101|8'b11100110|8'b11100111
					|8'b11101000|8'b11101001|8'b11101010|8'b11101011|8'b11101100|8'b11101101|8'b11101110|8'b11101111
					|8'b11110000|8'b11110001|8'b11110010|			 8'b11110100|8'b11110101|8'b11110110|8'b11110111
					|8'b11111000|8'b11111001|8'b11111010|8'b11111011|8'b11111100|8'b11111101|8'b11111110|8'b11111111 =>
					null; // nop, undocumented
			 8'b01111110|8'b01111111 :
					// nop, undocumented
					null;
// 8 bit load group
			 8'b01010111 :
					// ld a,i
					special_ld <= 3'b100;
					tstates <= 3'b101;
			 8'b01011111 :
					// ld a,r
					special_ld <= 3'b101;
					tstates <= 3'b101;
			 8'b01000111 :
					// ld i,a
					special_ld <= 3'b110;
					tstates <= 3'b101;
			 8'b01001111 :
					// ld r,a
					special_ld <= 3'b111;
					tstates <= 3'b101;
// 16 bit load group
			 8'b01001011|8'b01011011|8'b01101011|8'b01111011 :
					// ld dd,(nn)
					mcycles <= 3'b101;
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
									set_busa_to <= 4'b1000;
							else
									set_busa_to[2:1] <= ir[5:4];
									set_busa_to[0] <= 1'b1;
							end
							inc_wz <= 1'b1;
							set_addr_to <= azi;
					3'd5:
							read_to_reg <= 1'b1;
							if( ir[5:4] = 2'b11 ) begin
									set_busa_to <= 4'b1001;
							else
									set_busa_to[2:1] <= ir[5:4];
									set_busa_to[0] <= 1'b0;
							end
					default:
						begin
							//	hold
						end
					endcase
			 8'b01000011|8'b01010011|8'b01100011|8'b01110011 :
					// ld (nn),dd
					mcycles <= 3'b101;
					case( mcycle )
					3'd2:
							inc_pc <= 1'b1;
							ldz <= 1'b1;
					3'd3:
							set_addr_to <= azi;
							inc_pc <= 1'b1;
							ldw <= 1'b1;
							if( ir[5:4] = 2'b11 ) begin
									set_busb_to <= 4'b1000;
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
									set_busb_to <= 4'b1001;
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
			 8'b10100000 | 8'b10101000 | 8'b10110000 | 8'b10111000 :
					// ldi, ldd, ldir, lddr
					mcycles <= 3'b100;
					case( mcycle )
					3'd1:
							set_addr_to <= axy;
							incdec_16 <= 4'b1100; // bc
					3'd2:
							set_busb_to <= 4'b0110;
							set_busa_to[2:0] <= 3'b111;
							alu_op <= 4'b0000;
							set_addr_to <= ade;
							if( ir[3] == 1'b0 ) begin
									incdec_16 <= 4'b0110; // ix
							else
									incdec_16 <= 4'b1110;
							end
					3'd3:
							i_bt <= 1'b1;
							tstates <= 3'b101;
							write <= 1'b1;
							if( ir[3] == 1'b0 ) begin
									incdec_16 <= 4'b0101; // de
							else
									incdec_16 <= 4'b1101;
							end
					3'd4:
							noread <= 1'b1;
							tstates <= 3'b101;
					default:
						begin
							//	hold
						end
					endcase
			 8'b10100001 | 8'b10101001 | 8'b10110001 | 8'b10111001 :
					// cpi, cpd, cpir, cpdr
					mcycles <= 3'b100;
					case( mcycle )
					3'd1:
							set_addr_to <= axy;
							incdec_16 <= 4'b1100; // bc
					3'd2:
							set_busb_to <= 4'b0110;
							set_busa_to[2:0] <= 3'b111;
							alu_op <= 4'b0111;
							alu_cpi <= 1'b1;
							save_alu <= 1'b1;
							preservec <= 1'b1;
							if( ir[3] = 1'b0 ) begin
									incdec_16 <= 4'b0110;
							else
									incdec_16 <= 4'b1110;
							end
					3'd3:
							noread <= 1'b1;
							i_bc <= 1'b1;
							tstates <= 3'b101;
					3'd4:
							noread <= 1'b1;
							tstates <= 3'b101;
					default:
						begin
							//	hold
						end
					endcase
			 8'b01000100|8'b01001100|8'b01010100|8'b01011100|8'b01100100|8'b01101100|8'b01110100|8'b01111100 :
					// neg
					alu_op <= 4'b0010;
					set_busb_to <= 4'b0111;
					set_busa_to <= 4'b1010;
					read_to_acc <= 1'b1;
					save_alu <= 1'b1;
			 8'b01000110|8'b01001110|8'b01100110|8'b01101110 :
					// im 0
					imode <= 2'b00;
			 8'b01010110|8'b01110110 :
					// im 1
					imode <= 2'b01;
			 8'b01011110|8'b01110111 :
					// im 2
					imode <= 2'b10;
// 16 bit arithmetic
			 8'b01001010|8'b01011010|8'b01101010|8'b01111010 :
					// adc hl,ss
					mcycles <= 3'b011;
					case( mcycle )
					3'd2:
							noread <= 1'b1;
							alu_op <= 4'b0001;
							read_to_reg <= 1'b1;
							save_alu <= 1'b1;
							set_busa_to[2:0] <= 3'b101;
							case to_integer(unsigned(ir[5:4])) is
							 3'd0, 3'd1, 3'd2:
									set_busb_to[2:1] <= ir[5:4];
							set_busb_to[0] <= 1'b1;
							default:
									set_busb_to <= 4'b1000;
							endcase
							tstates <= 3'b100;
					3'd3:
							noread <= 1'b1;
							read_to_reg <= 1'b1;
							save_alu <= 1'b1;
							alu_op <= 4'b0001;
							set_busa_to[2:0] <= 3'b100;
							case to_integer(unsigned(ir[5:4])) is
							 3'd0, 3'd1, 3'd2:
									set_busb_to[2:1] <= ir[5:4];
									set_busb_to[0] <= 1'b0;
							 default:
									set_busb_to <= 4'b1001;
							endcase
					default:
					endcase
			 8'b01000010|8'b01010010|8'b01100010|8'b01110010 :
					// sbc hl,ss
					mcycles <= 3'b011;
					case( mcycle )
					3'd2:
							noread <= 1'b1;
							alu_op <= 4'b0011;
							read_to_reg <= 1'b1;
							save_alu <= 1'b1;
							set_busa_to[2:0] <= 3'b101;
							case( d[ ir[5:4] ] )
							 3'd0, 3'd1, 3'd2:
							 	begin
									set_busb_to[2:1] <= ir[5:4];
									set_busb_to[0] <= 1'b1;
								end
							 default:
									set_busb_to <= 4'b1000;
							endcase
							tstates <= 3'b100;
					3'd3:
							noread <= 1'b1;
							alu_op <= 4'b0011;
							read_to_reg <= 1'b1;
							save_alu <= 1'b1;
							set_busa_to[2:0] <= 3'b100;
							case to_integer(unsigned(ir[5:4])) is
							 3'd0, 3'd1, 3'd2:
									set_busb_to[2:1] <= ir[5:4];
							 default:
											set_busb_to <= 4'b1001;
							endcase
					default:
						begin
							//	hold
						end
					endcase
			 8'b01101111 :
					// rld
					mcycles <= 3'b100;
					case( mcycle )
					 3'd2:
							noread <= 1'b1;
							set_addr_to <= axy;
					 3'd3:
							read_to_reg <= 1'b1;
							set_busb_to[2:0] <= 3'b110;
							set_busa_to[2:0] <= 3'b111;
							alu_op <= 4'b1101;
							tstates <= 3'b100;
							set_addr_to <= axy;
							save_alu <= 1'b1;
					 3'd4:
							i_rld <= 1'b1;
							write <= 1'b1;
					default:
						begin
							//	hold
						end
					endcase
			 8'b01100111 :
					// rrd
					mcycles <= 3'b100;
					case( mcycle )
					 3'd2:
							set_addr_to <= axy;
					 3'd3:
							read_to_reg <= 1'b1;
							set_busb_to[2:0] <= 3'b110;
							set_busa_to[2:0] <= 3'b111;
							alu_op <= 4'b1110;
							tstates <= 3'b100;
							set_addr_to <= axy;
							save_alu <= 1'b1;
					 3'd4:
							i_rrd <= 1'b1;
							write <= 1'b1;
					default:
						begin
							//	hold
						end
					endcase
			 8'b01000101|8'b01001101|8'b01010101|8'b01011101|8'b01100101|8'b01101101|8'b01110101|8'b01111101 :
					// reti, retn
					mcycles <= 3'b011;
					case( mcycle )
					 3'd1:
							set_addr_to <= asp;
					 3'd2:
							incdec_16 <= 4'b0111;
							set_addr_to <= asp;
							ldz <= 1'b1;
					 3'd3:
							jump <= 1'b1;
							incdec_16 <= 4'b0111;
							i_retn <= 1'b1;
					default:
						begin
							//	hold
						end
					endcase
			 8'b01000000, 8'b01001000, 8'b01010000, 8'b01011000, 8'b01100000, 8'b01101000, 8'b01110000, 8'b01111000:
					// in r,(c)
					mcycles <= 3'b010;
					case( mcycle )
					3'd1:
						set_addr_to <= abc;
					3'd2:
						begin
							iorq <= 1'b1;
							if( ir[5:3] != 3'b110 ) begin
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
			 8'b01000001, 8'b01001001, 8'b01010001, 8'b01011001, 8'b01100001, 8'b01101001, 8'b01110001, 8'b01111001:
					// out (c),r
					// out (c),0
					mcycles <= 3'b010;
					case( mcycle )
					3'd1:
						begin
							set_addr_to <= abc;
							set_busb_to[2:0] <= ir[5:3];
							if( ir[5:3] == 3'b110 ) begin
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
			8'b10100010, 8'b10101010, 8'b10110010, 8'b10111010:
					// ini, ind, inir, indr
					mcycles <= 3'b100;
					case( mcycle )
					3'd1:
						begin
							set_addr_to <= abc;
							set_busb_to <= 4'b1010;
							set_busa_to <= 4'b0000;
							read_to_reg <= 1'b1;
							save_alu <= 1'b1;
							alu_op <= 4'b0010;
						end
					3'd2:
						begin
							iorq <= 1'b1;
							set_busb_to <= 4'b0110;
							set_addr_to <= axy;
						end
					3'd3:
						begin
							if( ir[3] == 1'b0 ) begin
									incdec_16 <= 4'b0110;
							end
							else begin
									incdec_16 <= 4'b1110;
							end
							tstates <= 3'b100;
							write <= 1'b1;
							i_btr <= 1'b1;
						end
					 3'd4:
						begin
							noread <= 1'b1;
							tstates <= 3'b101;
						end
					 default:
					 	begin
					 		//	hold
					 	end
					endcase
			8'b10100011, 8'b10101011, 8'b10110011, 8'b10111011 :
				begin
					// outi, outd, otir, otdr
					mcycles <= 3'd4;
					case( mcycle )
					 3'd1:
					 	begin
							tstates <= 3'd5;
							set_addr_to <= axy;
							set_busb_to <= 4'b1010;
							set_busa_to <= 4'b0000;
							read_to_reg <= 1'b1;
							save_alu <= 1'b1;
							alu_op <= 4'd2;
						end
					 3'd2:
					 	begin
							set_busb_to <= 4'b0110;
							set_addr_to <= abc;
						end
					 3'd3:
					 	begin
							if( ir[3] == 1'b0 ) begin
								incdec_16 <= 4'b0110;	// 0242a
							end
							else begin
								incdec_16 <= 4'b1110;	// 0242a
							end
							iorq <= 1'b1;
							write <= 1'b1;
							i_btr <= 1'b1;
						end
					 3'd4:
					 	begin
							noread <= 1'b1;
							tstates <= 3'b101;
						end
					 default:
					 	begin
					 		//	hold
					 	end
					endcase
				end
			 8'b11000001, 8'b11001001, 8'b11010001, 8'b11011001:
			 	begin
					//r800 mulub
				end
			 8'b11000011, 8'b11110011 :
			 	begin
					//r800 muluw
				end
			endcase

		endcase

		if( mode == 1 ) begin
			if( mcycle == 3'b001 ) begin
//						tstates <= 3'b100;
			end
			else begin
				tstates <= 3'b011;
			end
		end
		else begin
			if( mcycle == 3'b110 ) begin
				inc_pc <= 1'b1;
				if( mode == 1 ) begin
					set_addr_to <= axy;
					tstates <= 3'b100;
					set_busb_to[2:0] <= sss;
					set_busb_to[3] <= 1'b0;
				end
				if( irb == 8'b00110110 || irb == 8'b11001011 ) begin
					set_addr_to <= anone;
				end
			end
			if( mcycle == 3'b111 ) begin
				if( mode == 0 ) begin
					tstates <= 3'b101;
				end
				if( iset != 2'b01 ) begin
					set_addr_to <= axy;
				end
				set_busb_to[2:0] <= sss;
				set_busb_to[3] <= 1'b0;
				if( irb == 8'b00110110 || iset == 2'b01 ) begin
					// ld (hl),n
					inc_pc <= 1'b1;
				else
					noread <= 1'b1;
				end
			end
		end
	end
endmodule
