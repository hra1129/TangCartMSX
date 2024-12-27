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

module cz80 (
	input			reset_n		,
	input			clk_n		,
	input			cen			,
	input			wait_n		,
	input			int_n		,
	input			nmi_n		,
	input			busrq_n		,
	output			m1_n		,
	output			iorq		,
	output			noread		,
	output			write		,
	output			rfsh_n		,
	output			halt_n		,
	output			busak_n		,
	output	[15:0]	a			,
	input	[7:0]	dinst		,
	input	[7:0]	di			,
	output	[7:0]	do			,
	output	[2:0]	mc			,
	output	[2:0]	ts			,
	output			intcycle_n	,
	output			inte		,
	output			stop
);

	localparam		flag_c		= 0;
	localparam		flag_n		= 1;
	localparam		flag_p		= 2;
	localparam		flag_x		= 3;
	localparam		flag_h		= 4;
	localparam		flag_y		= 5;
	localparam		flag_z		= 6;
	localparam		flag_s		= 7;

	localparam	[2:0]	anone	= 3'd7;
	localparam	[2:0]	abc		= 3'd0;
	localparam	[2:0]	ade		= 3'd1;
	localparam	[2:0]	axy		= 3'd2;
	localparam	[2:0]	aioa	= 3'd4;
	localparam	[2:0]	asp		= 3'd5;
	localparam	[2:0]	azi		= 3'd6;

	// registers
	reg		[15:0]	ff_a;
	reg		[7:0]	ff_do;
	reg				ff_rfsh_n;
	reg				ff_m1_n;
	reg		[7:0]	acc;
	reg		[7:0]	f;
	reg		[7:0]	ap;
	reg		[7:0]	fp;
	reg		[7:0]	i;
	reg		[7:0]	r;
	reg		[15:0]	sp;
	reg		[15:0]	pc;
	wire	[7:0]	regdih;
	wire	[7:0]	regdil;
	wire	[15:0]	regbusa;
	wire	[15:0]	regbusb;
	wire	[15:0]	regbusc;
	reg		[2:0]	regaddra_r;
	wire	[2:0]	regaddra;
	reg		[2:0]	regaddrb_r;
	wire	[2:0]	regaddrb;
	reg		[2:0]	regaddrc;
	wire			regweh;
	wire			regwel;
	reg				alternate;

	// help registers
	reg		[15:0]	tmpaddr;			// temporary address register
	reg		[7:0]	ir;					// instruction register
	reg		[1:0]	iset;				// instruction set selector
	reg		[15:0]	regbusa_r;
	reg				oldnmi_n;

	wire	[15:0]	id16;
	wire	[7:0]	save_mux;

	reg		[2:0]	tstate;
	reg		[2:0]	mcycle;
	reg				inte_ff1;
	reg				inte_ff2;
	reg				halt_ff;
	reg				busreq_s;
	reg				busack;
	wire			clken;
	reg				nmi_s;
	reg				int_s;
	reg		[1:0]	istatus;

	wire	[7:0]	di_reg;
	wire			t_res;
	reg		[1:0]	xy_state;
	reg		[2:0]	pre_xy_f_m;
	wire			nextis_xy_fetch;
	reg				xy_ind;
	reg				no_btr;
	reg				btr_r;
	wire			auto_wait;
	reg				auto_wait_t1;
	reg				auto_wait_t2;
	reg				incdecz;

	// alu signals
	reg		[7:0]	busb;
	reg		[7:0]	busa;
	wire	[7:0]	alu_q;
	wire	[7:0]	f_out;

	// registered micro code outputs
	reg		[4:0]	read_to_reg_r;
	reg				arith16_r;
	reg				z16_r;
	reg		[3:0]	alu_op_r;
	reg				alu_cpi_r;
	reg				save_alu_r;
	reg				preservec_r;
	reg		[2:0]	mcycles;

	// micro code outputs
	wire	[2:0]	mcycles_d;
	wire	[2:0]	tstates;
	reg				intcycle;
	reg				nmicycle;
	wire			inc_pc;
	wire			inc_wz;
	wire	[3:0]	incdec_16;
	wire	[1:0]	prefix;
	wire			read_to_acc;
	wire			read_to_reg;
	wire	[3:0]	set_busb_to;
	wire	[3:0]	set_busa_to;
	wire	[3:0]	alu_op;
	wire			alu_cpi;
	wire			save_alu;
	wire			preservec;
	wire			arith16;
	wire	[2:0]	set_addr_to;
	wire			jump;
	wire			jumpe;
	wire			jumpxy;
	wire			call;
	wire			rstp;
	wire			ldz;
	wire			ldw;
	wire			ldsphl;
	wire			iorq_i;
	wire	[2:0]	special_ld;
	wire			exchangedh;
	wire			exchangerp;
	wire			exchangeaf;
	wire			exchangers;
	wire			i_djnz;
	wire			i_cpl;
	wire			i_ccf;
	wire			i_scf;
	wire			i_retn;
	wire			i_bt;
	wire			i_bc;
	wire			i_btr;
	wire			i_rld;
	wire			i_rrd;
	wire			i_inrc;
	wire			setdi;
	wire			setei;
	wire	[1:0]	imode;
	wire			halt;
	wire			xybit_undoc;

	// --------------------------------------------------------------------
	//	Sub module instances
	// --------------------------------------------------------------------
	cz80_mcode u_mcode (
		.ir				( ir				),
		.iset			( iset				),
		.mcycle			( mcycle			),
		.f				( f					),
		.nmicycle		( nmicycle			),
		.intcycle		( intcycle			),
		.xy_state		( xy_state			),
		.mcycles		( mcycles_d			),
		.tstates		( tstates			),
		.prefix			( prefix			),
		.inc_pc			( inc_pc			),
		.inc_wz			( inc_wz			),
		.incdec_16		( incdec_16			),
		.read_to_acc	( read_to_acc		),
		.read_to_reg	( read_to_reg		),
		.set_busb_to	( set_busb_to		),
		.set_busa_to	( set_busa_to		),
		.alu_op			( alu_op			),
		.alu_cpi		( alu_cpi			),
		.save_alu		( save_alu			),
		.preservec		( preservec			),
		.arith16		( arith16			),
		.set_addr_to	( set_addr_to		),
		.iorq			( iorq_i			),
		.jump			( jump				),
		.jumpe			( jumpe				),
		.jumpxy			( jumpxy			),
		.call			( call				),
		.rstp			( rstp				),
		.ldz			( ldz				),
		.ldw			( ldw				),
		.ldsphl			( ldsphl			),
		.special_ld		( special_ld		),
		.exchangedh		( exchangedh		),
		.exchangerp		( exchangerp		),
		.exchangeaf		( exchangeaf		),
		.exchangers		( exchangers		),
		.i_djnz			( i_djnz			),
		.i_cpl			( i_cpl				),
		.i_ccf			( i_ccf				),
		.i_scf			( i_scf				),
		.i_retn			( i_retn			),
		.i_bt			( i_bt				),
		.i_bc			( i_bc				),
		.i_btr			( i_btr				),
		.i_rld			( i_rld				),
		.i_rrd			( i_rrd				),
		.i_inrc			( i_inrc			),
		.setdi			( setdi				),
		.setei			( setei				),
		.imode			( imode				),
		.halt			( halt				),
		.noread			( noread			),
		.write			( write				),
		.xybit_undoc	( xybit_undoc		)
	);

	// --------------------------------------------------------------------
	cz80_alu u_alu (
		.arith16		( arith16_r			),
		.z16			( z16_r				),
		.alu_cpi		( alu_cpi_r			),
		.alu_op			( alu_op_r			),
		.ir				( ir[5:0]			),
		.iset			( iset				),
		.busa			( busa				),
		.busb			( busb				),
		.f_in			( f					),
		.q				( alu_q				),
		.f_out			( f_out				)
	);

	// --------------------------------------------------------------------
	//
	// --------------------------------------------------------------------
	assign clken			= cen & ~busack;
	assign t_res			= (tstate == tstates );
	assign nextis_xy_fetch	= (xy_state != 2'b00 && !xy_ind && ((set_addr_to == axy) || 
							  (mcycle == 3'd1 && ir == 8'hCB) || (mcycle == 3'd1 && ir == 8'h36)) );
	assign save_mux			= exchangerp ? busb: (save_alu_r ? alu_q: di_reg);

	always @( posedge clk_n ) begin
		if( !reset_n ) begin
			pc		<= 16'd0;	// program counter
			ff_a		<= 16'd0;
			tmpaddr	<= 16'd0;
			ir		<= 8'h00;
			iset	<= 2'b00;
			xy_state <= 2'b00;
			istatus <= 2'b00;
			mcycles <= 3'b000;
			ff_do <= 8'h00;

			acc <= 8'hFF;
			f <= 8'hFF;
			ap <= 8'hFF;
			fp <= 8'hFF;
			i <= 8'h00;
			r <= 8'h00;
			sp <= 16'hFFFF;
			alternate <= 1'b0;

			read_to_reg_r <= 5'd0;
			f <= 8'hFF;
			arith16_r <= 1'b0;
			btr_r <= 1'b0;
			z16_r <= 1'b0;
			alu_op_r <= 4'd0;
			alu_cpi_r <= 1'b0;
			save_alu_r <= 1'b0;
			preservec_r <= 1'b0;
			xy_ind <= 1'b0;
		end
		else if( clken ) begin

			alu_op_r <= 4'd0;
			alu_cpi_r <= 1'b0;
			save_alu_r <= 1'b0;
			read_to_reg_r <= 5'd0;

			mcycles <= mcycles_d;

			if( imode != 2'b11 ) begin
				istatus <= imode;
			end

			arith16_r <= arith16;
			preservec_r <= preservec;
			if( iset == 2'b10 && alu_op[2] == 1'b0 && alu_op[0] == 1'b1 && mcycle == 3'b011 ) begin
				z16_r <= 1'b1;
			end
			else begin
				z16_r <= 1'b0;
			end

			if( mcycle  == 3'd1 && tstate[2] == 1'b0 ) begin
			// mcycle == 1 && tstate == 1, 2, || 3

				if( tstate == 2 && wait_n == 1'b1 ) begin
					ff_a[7:0] <= r;
					ff_a[15:8] <= i;
					r[6:0] <= r[6:0] + 7'd1;

					if( jump == 1'b0 && call == 1'b0 && nmicycle == 1'b0 && intcycle == 1'b0 && ~(halt_ff == 1'b1 || halt == 1'b1) ) begin
						pc <= pc + 1;
					end

					if( intcycle == 1'b1 && istatus == 2'b01 ) begin
						ir <= 8'hFF;
					end
					else if( halt_ff == 1'b1 || (intcycle == 1'b1 && istatus == 2'b10) || nmicycle == 1'b1 ) begin
						ir <= 8'h00;
					end
					else begin
						ir <= dinst;
					end

					iset <= 2'b00;
					if( prefix != 2'b00 ) begin
						if( prefix == 2'b11 ) begin
							//	DDh = 11011101, FDh = 11111101h
							if( ir[5] == 1'b1 ) begin
								xy_state <= 2'b10;		//	IY
							end
							else begin
								xy_state <= 2'b01;		//	IX
							end
						end
						else begin
							if( prefix == 2'b10 ) begin
								xy_state <= 2'b00;
								xy_ind <= 1'b0;
							end
							iset <= prefix;
						end
					end
					else begin
						xy_state <= 2'b00;
						xy_ind <= 1'b0;
					end
				end
			end
			else begin
			// either (mcycle > 1) || (mcycle == 1 && tstate > 3)

				if( mcycle == 3'd6 ) begin
					xy_ind <= 1'b1;
					if( prefix == 2'b01 ) begin
						iset <= 2'b01;
					end
				end

				if( t_res == 1'b1 ) begin
					btr_r <= (i_bt || i_bc || i_btr) && ~no_btr;
					if( jump == 1'b1 ) begin
						ff_a[15:8] <= di_reg;
						ff_a[7:0] <= tmpaddr[7:0];
						pc[15:8] <= di_reg;
						pc[7:0] <= tmpaddr[7:0];
					end
					else if( jumpxy == 1'b1 ) begin
						ff_a <= regbusc;
						pc <= regbusc;
					end
					else if( call == 1'b1 || rstp == 1'b1 ) begin
						ff_a <= tmpaddr;
						pc <= tmpaddr;
					end
					else if( mcycle == mcycles && nmicycle == 1'b1 ) begin
						ff_a  <= 16'h0066;
						pc <= 16'h0066;
					end
					else if( mcycle == 3'd3 && intcycle == 1'b1 && istatus == 2'b10 ) begin
						ff_a[15:8] <= i;
						ff_a[7:0] <= tmpaddr[7:0];
						pc[15:8] <= i;
						pc[7:0] <= tmpaddr[7:0];
					end
					else begin
						case( set_addr_to )
						axy:
							if( xy_state == 2'b00 ) begin
								ff_a <= regbusc;
							end
							else begin
								if( nextis_xy_fetch == 1'b1 ) begin
									ff_a <= pc;
								end
								else begin
									ff_a <= tmpaddr;
								end
							end
						aioa:
							ff_a <= { acc, di_reg };
						asp:
							ff_a <= sp;
						abc:
							ff_a <= regbusc;
						ade:
							ff_a <= regbusc;
						azi:
							if( inc_wz == 1'b1 ) begin
								ff_a <= tmpaddr + 16'd1;
							end
							else begin
								ff_a <= { di_reg, tmpaddr[7:0] };
							end
						default:
							ff_a <= pc;
						endcase
					end

					save_alu_r <= save_alu;
					alu_cpi_r <= alu_cpi;
					alu_op_r <= alu_op;

					if( i_cpl == 1'b1 ) begin
						// cpl
						acc <= ~acc;
						f[flag_y] <= ~acc[5];
						f[flag_h] <= 1'b1;
						f[flag_x] <= ~acc[3];
						f[flag_n] <= 1'b1;
					end
					if( i_ccf == 1'b1 ) begin
						// ccf
						f[flag_c] <= ~f[flag_c];
						f[flag_y] <= acc[5];
						f[flag_h] <= f[flag_c];
						f[flag_x] <= acc[3];
						f[flag_n] <= 1'b0;
					end
					if( i_scf == 1'b1 ) begin
						// scf
						f[flag_c] <= 1'b1;
						f[flag_y] <= acc[5];
						f[flag_h] <= 1'b0;
						f[flag_x] <= acc[3];
						f[flag_n] <= 1'b0;
					end
				end

				if( tstate == 3'd2 && wait_n == 1'b1 ) begin
					if( iset == 2'b01 && mcycle == 3'b111 ) begin
						ir <= dinst;
					end
					if( jumpe == 1'b1 ) begin
						pc <= pc + { { 8 { di_reg[7] } }, di_reg };
					end
					else if( inc_pc == 1'b1 ) begin
						pc <= pc + 1;
					end
					if( btr_r == 1'b1 ) begin
						pc <= pc - 2;
					end
					if( rstp == 1'b1 ) begin
						tmpaddr <= { 9'd0, ir[5:3], 3'd0 };
					end
				end
				if( tstate == 3'd3 && mcycle == 3'b110 ) begin
					tmpaddr <= regbusc + { { 8 { di_reg[7] } }, di_reg };
				end

				if( (tstate == 3'd2 && wait_n == 1'b1) || (tstate == 4 && mcycle == 3'b001) ) begin
					if( incdec_16[2:0] == 3'b111 ) begin
						if( incdec_16[3] == 1'b1 ) begin
							sp <= sp - 1;
						end
						else begin
							sp <= sp + 1;
						end
					end
				end

				if( ldsphl == 1'b1 ) begin
					sp <= regbusc;
				end
				if( exchangeaf == 1'b1 ) begin
					ap <= acc;
					acc <= ap;
					fp <= f;
					f <= fp;
				end
				if( exchangers == 1'b1 ) begin
					alternate <= ~alternate;
				end
			end

			if( tstate == 3'd3 ) begin
				if( ldz == 1'b1 ) begin
					tmpaddr[7:0] <= di_reg;
				end
				if( ldw == 1'b1 ) begin
					tmpaddr[15:8] <= di_reg;
				end

				if( special_ld[2] == 1'b1 ) begin
					case( special_ld[1:0] )
					2'b00:
						begin
							acc <= i;
							f[flag_p] <= inte_ff2;
							f[flag_n] <= 1'b0;
							f[flag_h] <= 1'b0;
							f[flag_s] <= i[7];
							f[flag_z] <= ( i == 8'h00 );
						end
					2'b01:
						begin
							acc <= r;
							f[flag_p] <= inte_ff2;
							f[flag_n] <= 1'b0;
							f[flag_h] <= 1'b0;
							f[flag_s] <= r[7];
							f[flag_z] <= ( r == 8'h00 );
						end
					2'b10:
						i <= acc;
					default:
						r <= acc;
					endcase
				end
			end

			if( (i_djnz == 1'b0 && save_alu_r == 1'b1) || alu_op_r == 4'b1001 ) begin
				f[7:1] <= f_out[7:1];
				if( preservec_r == 1'b0 ) begin
					f[flag_c] <= f_out[0];
				end
			end
			if( t_res == 1'b1 && i_inrc == 1'b1 ) begin
				f[flag_h] <= 1'b0;
				f[flag_n] <= 1'b0;
				if( di_reg[7:0] == 8'h00) begin
					f[flag_z] <= 1'b1;
				end
				else begin
					f[flag_z] <= 1'b0;
				end
				f[flag_s] <= di_reg[7];
				f[flag_p] <= ~(di_reg[0] ^ di_reg[1] ^ di_reg[2] ^ di_reg[3] ^
					di_reg[4] ^ di_reg[5] ^ di_reg[6] ^ di_reg[7]);
			end

			if( tstate == 1 && auto_wait_t1 == 1'b0 ) begin
				if( i_rld == 1'b1 ) begin
					ff_do <= { busb[3:0], busa[3:0] };
				end
				else if( i_rrd == 1'b1 ) begin
					ff_do <= { busa[3:0], busb[7:4] };
				end
				else begin
					ff_do <= busb;
				end
			end

			if( t_res == 1'b1 ) begin
				read_to_reg_r[3:0] <= set_busa_to;
				read_to_reg_r[4] <= read_to_reg;
				if( read_to_acc == 1'b1 ) begin
					read_to_reg_r[3:0] <= 4'b0111;
					read_to_reg_r[4] <= 1'b1;
				end
			end

			if( tstate == 1 && i_bt == 1'b1 ) begin
				f[flag_x] <= alu_q[3];
				f[flag_y] <= alu_q[1];
				f[flag_h] <= 1'b0;
				f[flag_n] <= 1'b0;
			end
			if( i_bc == 1'b1 || i_bt == 1'b1 ) begin
				f[flag_p] <= incdecz;
			end

			if( (tstate == 1 && save_alu_r == 1'b0 && auto_wait_t1 == 1'b0) ||
				(save_alu_r == 1'b1 && alu_op_r != 4'b0111) ) begin
				case( read_to_reg_r )
				5'b10111:
					acc <= save_mux;
				5'b10110:
					ff_do <= save_mux;
				5'b11000:
					sp[7:0] <= save_mux;
				5'b11001:
					sp[15:8] <= save_mux;
				5'b11011:
					f <= save_mux;
				default:
					begin
						//	hold
					end
				endcase
				if( xybit_undoc == 1'b1 ) begin
					ff_do <= alu_q;
				end
			end
		end
	end

	// --------------------------------------------------------------------
	// bc('), de('), hl('), ix and iy
	// --------------------------------------------------------------------
	always @( posedge clk_n ) begin
		if( clken ) begin
			// bus a / write
			if( !xy_ind && xy_state != 2'b00 && set_busa_to[2:1] == 2'b10 ) begin
				regaddra_r <= { xy_state[1], 2'b11 };
			end
			else begin
				regaddra_r <= { alternate, set_busa_to[2:1] };
			end

			// bus b
			if( !xy_ind && xy_state != 2'b00 && set_busb_to[2:1] == 2'b10 ) begin
				regaddrb_r <= { xy_state[1], 2'b11 };
			end
			else begin
				regaddrb_r <= { alternate, set_busb_to[2:1] };
			end

			// address from register
			regaddrc <= { alternate, set_addr_to[1:0] };
			// jump (hl), ld sp,hl
			if( jumpxy || ldsphl ) begin
				regaddrc <= { alternate, 2'b10 };
			end
			if( ((jumpxy || ldsphl) && xy_state != 2'b00) || (mcycle == 3'd6) ) begin
				regaddrc <= { xy_state[1], 2'b11 };
			end

			if( (tstate == 3'd2 || (tstate == 3'd3 && mcycle == 3'd1)) && incdec_16[2:0] == 3'd4 ) begin
				if( id16 == 16'd0 ) begin
					incdecz <= 1'b0;
				end
				else begin
					incdecz <= 1'b1;
				end
			end
			else if( i_djnz && save_alu_r ) begin
				incdecz <= f_out[flag_z];
			end

			regbusa_r <= regbusa;
		end
	end

	assign regaddra	=
			// 16 bit increment/decrement
			( (tstate == 3'd2 || (tstate == 3'd3 && mcycle == 3'd1 && incdec_16[2])) && xy_state       == 2'd0 ) ? { alternate, incdec_16[1:0] }:
			( (tstate == 3'd2 || (tstate == 3'd3 && mcycle == 3'd1 && incdec_16[2])) && incdec_16[1:0] == 2'd2 ) ? { xy_state[1], 2'b11 }:
			// ex hl,dl
			( exchangedh && tstate == 3'd3 ) ? { alternate, 2'b10 }:
			( exchangedh && tstate == 3'd4 ) ? { alternate, 2'b01 }:
			// bus a / write
			regaddra_r;

	assign regaddrb	=
			// ex hl,dl
			( exchangedh && tstate == 3'd3 ) ? { alternate, 2'b01 }:
			// bus b
			regaddrb_r;

	assign id16		= incdec_16[3] ? (regbusa - 16'd1) : (regbusa + 16'd1);

	function func_regwe(
		input	[2:0]	tstate,
		input			save_alu_r,
		input			auto_wait_t1,
		input	[3:0]	alu_op_r,
		input	[4:0]	read_to_reg_r,
		input			exchangedh,
		input	[2:0]	incdec_16,
		input			wait_n,
		input	[2:0]	mcycle,
		input			let
	);
		if( incdec_16[2] && ((tstate == 3'd2 && wait_n && mcycle != 3'b001) || (tstate == 3'd3 && mcycle == 3'b001)) ) begin
			case( incdec_16[1:0] )
			2'b00, 2'b01, 2'b10:
				func_regwe = 1'b1;
			default:
				func_regwe = 1'b0;
			endcase
		end
		else if( exchangedh && (tstate == 3'd3 || tstate == 3'd4 ) ) begin
			func_regwe = 1'b1;
		end
		else if( ( tstate == 3'd1 && !save_alu_r && !auto_wait_t1) || (save_alu_r && alu_op_r != 4'b0111) ) begin
			case( read_to_reg_r )
			5'h10, 5'h11, 5'h12, 5'h13, 5'h14, 5'h15:
				func_regwe = let;
			default:
				func_regwe = 1'b0;
			endcase
		end
		else begin
			func_regwe = 1'b0;
		end
	endfunction

	assign regweh = func_regwe( tstate, save_alu_r, auto_wait_t1, alu_op_r, read_to_reg_r, exchangedh, incdec_16, wait_n, mcycle, ~read_to_reg_r[0] );
	assign regwel = func_regwe( tstate, save_alu_r, auto_wait_t1, alu_op_r, read_to_reg_r, exchangedh, incdec_16, wait_n, mcycle,  read_to_reg_r[0] );

	assign regdih	= ( exchangedh && tstate == 3'd3 ) ? regbusb[15:8]:
					  ( exchangedh && tstate == 3'd4 ) ? regbusa_r[15:8]:
					  ( incdec_16[2] && ((tstate == 3'd2 && mcycle != 3'd1) || (tstate == 3'd3 && mcycle == 3'd1)) ) ? id16[15:8] : save_mux;
	assign regdil	= ( exchangedh && tstate == 3'd3 ) ? regbusb[7:0]:
					  ( exchangedh && tstate == 3'd4 ) ? regbusa_r[7:0]:
					  ( incdec_16[2] && ((tstate == 3'd2 && mcycle != 3'd1) || (tstate == 3'd3 && mcycle == 3'd1)) ) ? id16[ 7:0] : save_mux;

	cz80_registers u_regs (
		.clk			( clk_n				),
		.cen			( clken				),
		.we_h			( regweh			),
		.we_l			( regwel			),
		.address_a		( regaddra			),
		.address_b		( regaddrb			),
		.address_c		( regaddrc			),
		.wdata_h		( regdih			),
		.wdata_l		( regdil			),
		.rdata_ah		( regbusa[15:8]		),
		.rdata_al		( regbusa[ 7:0]		),
		.rdata_bh		( regbusb[15:8]		),
		.rdata_bl		( regbusb[ 7:0]		),
		.rdata_ch		( regbusc[15:8]		),
		.rdata_cl		( regbusc[ 7:0]		)
	);

	// --------------------------------------------------------------------
	// buses
	// --------------------------------------------------------------------
	always @( posedge clk_n ) begin
		if( clken ) begin
			case( set_busb_to )
			4'b0111:
				busb <= acc;
			4'b0000, 4'b0010, 4'b0100: 
				busb <= regbusb[15:8];
			4'b0001, 4'b0011, 4'b0101:
				busb <= regbusb[ 7:0];
			4'b0110:
				busb <= di_reg;
			4'b1000:
				busb <= sp[7:0];
			4'b1001:
				busb <= sp[15:8];
			4'b1010:
				busb <= 8'h01;
			4'b1011:
				busb <= f;
			4'b1100:
				busb <= pc[7:0];
			4'b1101:
				busb <= pc[15:8];
			4'b1110:
				busb <= 8'h00;
			default:
				busb <= 8'hXX;
			endcase

			case( set_busa_to )
			4'b0111:
				busa <= acc;
			4'b0000, 4'b0001, 4'b0010, 4'b0011, 4'b0100, 4'b0101:
				busa <= set_busa_to[0] ? regbusa[7:0]: regbusa[15:8];
			4'b0110:
				busa <= di_reg;
			4'b1000:
				busa <= sp[7:0];
			4'b1001:
				busa <= sp[15:8];
			4'b1010:
				busa <= 8'h00;
			default:
				busa <= 8'hXX;
			endcase

			if( xybit_undoc ) begin
				busa <= di_reg;
				busb <= di_reg;
			end
		end
	end

	// --------------------------------------------------------------------
	// generate external control signals
	// --------------------------------------------------------------------
	always @( posedge clk_n ) begin
		if( !reset_n ) begin
			ff_rfsh_n <= 1'b1;
		end
		else if( cen ) begin
			if( mcycle == 3'd1 && ((tstate == 2	&& wait_n) || tstate == 3 ) ) begin
				ff_rfsh_n <= 1'b0;
			end
			else begin
				ff_rfsh_n <= 1'b1;
			end
		end
	end

	assign rfsh_n		= ff_rfsh_n;
	assign mc			= mcycle;
	assign ts			= tstate;
	assign di_reg		= di;
	assign halt_n		= ~halt_ff;
	assign busak_n		= ~busack;
	assign intcycle_n	= ~intcycle;
	assign inte			= inte_ff1;
	assign iorq			= iorq_i;
	assign stop			= i_djnz;

	// --------------------------------------------------------------------
	// syncronise inputs
	// --------------------------------------------------------------------
	always @( posedge clk_n ) begin
		if( !reset_n ) begin
			busreq_s	<= 1'b0;
			int_s		<= 1'b0;
			nmi_s		<= 1'b0;
			oldnmi_n	<= 1'b0;
		end
		else if( cen ) begin
			busreq_s	<= ~busrq_n;
			int_s		<= ~int_n;
			oldnmi_n	<= nmi_n;

			if( nmicycle ) begin
				nmi_s <= 1'b0;
			end
			else if( !nmi_n && oldnmi_n ) begin
				nmi_s <= 1'b1;
			end
		end
	end

	// --------------------------------------------------------------------
	// main state machine
	// --------------------------------------------------------------------
	always @( posedge clk_n ) begin
		if( !reset_n ) begin
			mcycle <= 3'b001;
			tstate <= 3'b000;
			pre_xy_f_m <= 3'b000;
			halt_ff <= 1'b0;
			busack <= 1'b0;
			nmicycle <= 1'b0;
			intcycle <= 1'b0;
			inte_ff1 <= 1'b0;
			inte_ff2 <= 1'b0;
			no_btr <= 1'b0;
			auto_wait_t1 <= 1'b0;
			auto_wait_t2 <= 1'b0;
			ff_m1_n <= 1'b1;
		end
		else if( cen ) begin
			if( t_res ) begin
				auto_wait_t1 <= 1'b0;
			end
			else begin
				auto_wait_t1 <= auto_wait | iorq_i;
			end
			auto_wait_t2 <= auto_wait_t1;
			no_btr <= (i_bt  & (~ir[4] | ~f[flag_p])) |
					  (i_bc  & (~ir[4] |  f[flag_z] | ~f[flag_p])) |
					  (i_btr & (~ir[4] |  f[flag_z]));
			if( tstate == 3'd2 ) begin
				if( setei ) begin
					inte_ff1 <= 1'b1;
					inte_ff2 <= 1'b1;
				end
				if( i_retn ) begin
					inte_ff1 <= inte_ff2;
				end
			end
			if( tstate == 3'd3 ) begin
				if( setdi ) begin
					inte_ff1 <= 1'b0;
					inte_ff2 <= 1'b0;
				end
			end
			if( intcycle || nmicycle ) begin
				halt_ff <= 1'b0;
			end
			if( tstate == 3'd2 && mcycle == 3'd1 && wait_n ) begin
				ff_m1_n <= 1'b1;
			end
			if( busreq_s && busack ) begin
				//	hold
			end
			else begin
				busack <= 1'b0;
				if( tstate == 3'd2 && !wait_n ) begin
					//	hold
				end
				else if( t_res ) begin
					if( halt ) begin
						halt_ff <= 1'b1;
					end
					if( busreq_s ) begin
						busack <= 1'b1;
					end
					else begin
						tstate <= 3'd1;
						if( nextis_xy_fetch ) begin
							mcycle <= 3'b110;
							if( ir == 8'h36 ) begin
								pre_xy_f_m <= 3'd2;
							end
							else begin
								pre_xy_f_m <= mcycle;
							end
						end
						else if( mcycle == 3'd7 ) begin
							mcycle <= pre_xy_f_m + 3'd1;
						end
						else if( (mcycle == mcycles) || no_btr || (mcycle == 3'd2 && i_djnz && incdecz) ) begin
							ff_m1_n <= 1'b0;
							mcycle <= 3'b001;
							if( nmi_s && prefix == 2'd0 ) begin
								intcycle <= 1'b0;
								nmicycle <= 1'b1;
								inte_ff1 <= 1'b0;
							end
							else if( (inte_ff1 && int_s) && prefix == 2'd0 && !setei ) begin
								intcycle <= 1'b1;
								nmicycle <= 1'b0;
								inte_ff1 <= 1'b0;
								inte_ff2 <= 1'b0;
							end
							else begin
								intcycle <= 1'b0;
								nmicycle <= 1'b0;
							end
						end
						else begin
							mcycle <= mcycle + 1;
						end
					end
				end
				else begin
					if( ~( (auto_wait && !auto_wait_t2) || (iorq_i && !auto_wait_t1) ) ) begin
						tstate <= tstate + 3'd1;
					end
				end
			end
			if( tstate == 3'd0 ) begin
				ff_m1_n <= 1'b0;
			end
		end
	end

	assign m1_n			= ff_m1_n;
	assign a			= ff_a;
	assign do			= ff_do;
	assign auto_wait	= ((intcycle || nmicycle) && mcycle == 3'd1);
endmodule
