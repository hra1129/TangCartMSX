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

	localparam		anone		= 3'd7;
	localparam		abc			= 3'd0;
	localparam		ade			= 3'd1;
	localparam		axy			= 3'd2;
	localparam		aioa		= 3'd3;
	localparam		asp			= 3'd4;
	localparam		azi			= 3'd5;

	// registers
	reg		[7:0]	acc;
	reg		[7:0]	f;
	reg		[7:0]	ap;
	reg		[7:0]	fp;
	reg		[7:0]	i;
	reg		[7:0]	r;
	reg		[15:0]	sp, pc;
	reg		[7:0]	regdih;
	reg		[7:0]	regdil;
	reg		[15:0]	regbusa;
	reg		[15:0]	regbusb;
	reg		[15:0]	regbusc;
	reg		[2:0]	regaddra_r;
	reg		[2:0]	regaddra;
	reg		[2:0]	regaddrb_r;
	reg		[2:0]	regaddrb;
	reg		[2:0]	regaddrc;
	reg				regweh;
	reg				regwel;
	reg				alternate;

	// help registers
	reg		[15:0]	tmpaddr;			// temporary address register
	reg		[7:0]	ir;					// instruction register
	reg		[1:0]	iset;				// instruction set selector
	reg		[15:0]	regbusa_r;
	reg				oldnmi_n;

	signal id16				: signed(15 downto 0);
	signal save_mux			: std_logic_vector(7 downto 0);

	signal tstate			: unsigned(2 downto 0);
	signal mcycle			: std_logic_vector(2 downto 0);
	signal inte_ff1			: std_logic;
	signal inte_ff2			: std_logic;
	signal halt_ff			: std_logic;
	signal busreq_s			: std_logic;
	signal busack			: std_logic;
	signal clken			: std_logic;
	signal nmi_s			: std_logic;
	signal int_s			: std_logic;
	signal istatus			: std_logic_vector(1 downto 0);

	signal di_reg			: std_logic_vector(7 downto 0);
	signal t_res			: std_logic;
	signal xy_state			: std_logic_vector(1 downto 0);
	signal pre_xy_f_m		: std_logic_vector(2 downto 0);
	signal nextis_xy_fetch	: std_logic;
	signal xy_ind			: std_logic;
	signal no_btr			: std_logic;
	signal btr_r			: std_logic;
	signal auto_wait		: std_logic;
	signal auto_wait_t1		: std_logic;
	signal auto_wait_t2		: std_logic;
	signal incdecz			: std_logic;

	// alu signals
	signal busb				: std_logic_vector(7 downto 0);
	signal busa				: std_logic_vector(7 downto 0);
	signal alu_q			: std_logic_vector(7 downto 0);
	signal f_out			: std_logic_vector(7 downto 0);

	// registered micro code outputs
	signal read_to_reg_r	: std_logic_vector(4 downto 0);
	signal arith16_r		: std_logic;
	signal z16_r			: std_logic;
	signal alu_op_r			: std_logic_vector(3 downto 0);
	signal alu_cpi_r		: std_logic;
	signal save_alu_r		: std_logic;
	signal preservec_r		: std_logic;
	signal mcycles			: std_logic_vector(2 downto 0);

	// micro code outputs
	signal mcycles_d		: std_logic_vector(2 downto 0);
	signal tstates			: std_logic_vector(2 downto 0);
	signal intcycle			: std_logic;
	signal nmicycle			: std_logic;
	signal inc_pc			: std_logic;
	signal inc_wz			: std_logic;
	signal incdec_16		: std_logic_vector(3 downto 0);
	signal prefix			: std_logic_vector(1 downto 0);
	signal read_to_acc		: std_logic;
	signal read_to_reg		: std_logic;
	signal set_busb_to		: std_logic_vector(3 downto 0);
	signal set_busa_to		: std_logic_vector(3 downto 0);
	signal alu_op			: std_logic_vector(3 downto 0);
	signal alu_cpi			: std_logic;
	signal save_alu			: std_logic;
	signal preservec		: std_logic;
	signal arith16			: std_logic;
	signal set_addr_to		: std_logic_vector(2 downto 0);
	signal jump				: std_logic;
	signal jumpe			: std_logic;
	signal jumpxy			: std_logic;
	signal call				: std_logic;
	signal rstp				: std_logic;
	signal ldz				: std_logic;
	signal ldw				: std_logic;
	signal ldsphl			: std_logic;
	signal iorq_i			: std_logic;
	signal special_ld		: std_logic_vector(2 downto 0);
	signal exchangedh		: std_logic;
	signal exchangerp		: std_logic;
	signal exchangeaf		: std_logic;
	signal exchangers		: std_logic;
	signal i_djnz			: std_logic;
	signal i_cpl			: std_logic;
	signal i_ccf			: std_logic;
	signal i_scf			: std_logic;
	signal i_retn			: std_logic;
	signal i_bt				: std_logic;
	signal i_bc				: std_logic;
	signal i_btr			: std_logic;
	signal i_rld			: std_logic;
	signal i_rrd			: std_logic;
	signal i_inrc			: std_logic;
	signal setdi			: std_logic;
	signal setei			: std_logic;
	signal imode			: std_logic_vector(1 downto 0);
	signal halt				: std_logic;
	signal xybit_undoc		: std_logic;

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
								(mcycle == 3'd1 && ir == 8'hCB) || (mcycle == 3'd1 && ir == 8'h36));
	assign save_mux			= exchangerp ? busb: (save_alu_r ? alu_q: di_reg);

	always @( posedge clk_n ) begin
		if( !reset_n ) begin
			pc		<= 16'd0;	// program counter
			a		<= 16'd0;
			tmpaddr	<= 16'd0;
			ir		<= 8'h00;
			iset	<= 2'b00;
			xy_state <= 2'b00;
			istatus <= 2'b00;
			mcycles <= 3'b000;
			do <= "00000000";

			acc <= (others => 1'b1);
			f <= (others => 1'b1);
			ap <= (others => 1'b1);
			fp <= (others => 1'b1);
			i <= (others => 1'b0);
			r <= (others => 1'b0);
			sp <= (others => 1'b1);
			alternate <= 1'b0;

			read_to_reg_r <= "00000";
			f <= (others => 1'b1);
			arith16_r <= 1'b0;
			btr_r <= 1'b0;
			z16_r <= 1'b0;
			alu_op_r <= 4'b0000;
			alu_cpi_r <= 1'b0;
			save_alu_r <= 1'b0;
			preservec_r <= 1'b0;
			xy_ind <= 1'b0;

		else if clk_n'event and clk_n = 1'b1 begin

			if clken = 1'b1 begin

			alu_op_r <= 4'b0000;
			alu_cpi_r <= 1'b0;
			save_alu_r <= 1'b0;
			read_to_reg_r <= "00000";

			mcycles <= mcycles_d;

			if imode != 2'b11 begin
				istatus <= imode;
			end

			arith16_r <= arith16;
			preservec_r <= preservec;
			if iset = 2'b10 and alu_op(2) = 1'b0 and alu_op(0) = 1'b1 and mcycle = 3'b011 begin
				z16_r <= 1'b1;
			else
				z16_r <= 1'b0;
			end

			if mcycle  = 3'b001 and tstate(2) = 1'b0 begin
			// mcycle = 1 and tstate = 1, 2, or 3

				if tstate = 2 and wait_n = 1'b1 begin
					a(7 downto 0) <= std_logic_vector(r);
					a(15 downto 8) <= i;
					r(6 downto 0) <= r(6 downto 0) + 1;

					if jump = 1'b0 and call = 1'b0 and nmicycle = 1'b0 and intcycle = 1'b0 and not (halt_ff = 1'b1 or halt = 1'b1) begin
						pc <= pc + 1;
					end

					if intcycle = 1'b1 and istatus = 2'b01 begin
						ir <= "11111111";
					else if halt_ff = 1'b1 or (intcycle = 1'b1 and istatus = 2'b10) or nmicycle = 1'b1 begin
						ir <= "00000000";
					else
						ir <= dinst;
					end

					iset <= 2'b00;
					if prefix != 2'b00 begin
						if prefix = 2'b11 begin
							if ir(5) = 1'b1 begin
								xy_state <= 2'b10;
							else
								xy_state <= 2'b01;
							end
						else
							if prefix = 2'b10 begin
								xy_state <= 2'b00;
								xy_ind <= 1'b0;
							end
							iset <= prefix;
						end
					else
						xy_state <= 2'b00;
						xy_ind <= 1'b0;
					end
				end

			else
			// either (mcycle > 1) or (mcycle = 1 and tstate > 3)

				if mcycle = 3'b110 begin
					xy_ind <= 1'b1;
					if prefix = 2'b01 begin
						iset <= 2'b01;
					end
				end

				if t_res = 1'b1 begin
					btr_r <= (i_bt or i_bc or i_btr) and not no_btr;
					if jump = 1'b1 begin
						a(15 downto 8) <= di_reg;
						a(7 downto 0) <= tmpaddr(7 downto 0);
						pc(15 downto 8) <= unsigned(di_reg);
						pc(7 downto 0) <= unsigned(tmpaddr(7 downto 0));
					else if jumpxy = 1'b1 begin
						a <= regbusc;
						pc <= unsigned(regbusc);
					else if call = 1'b1 or rstp = 1'b1 begin
						a <= tmpaddr;
						pc <= unsigned(tmpaddr);
					else if mcycle = mcycles and nmicycle = 1'b1 begin
						a <= "0000000001100110";
						pc <= "0000000001100110";
					else if mcycle = 3'b011 and intcycle = 1'b1 and istatus = 2'b10 begin
						a(15 downto 8) <= i;
						a(7 downto 0) <= tmpaddr(7 downto 0);
						pc(15 downto 8) <= unsigned(i);
						pc(7 downto 0) <= unsigned(tmpaddr(7 downto 0));
					else
						case set_addr_to is
						axy:
							if xy_state = 2'b00 begin
								a <= regbusc;
							else
								if nextis_xy_fetch = 1'b1 begin
									a <= std_logic_vector(pc);
								else
									a <= tmpaddr;
								end
							end
						aioa:
							a(15 downto 8) <= acc;
							a(7 downto 0) <= di_reg;
						asp:
							a <= std_logic_vector(sp);
						abc:
							a <= regbusc;
						ade:
							a <= regbusc;
						azi:
							if inc_wz = 1'b1 begin
								a <= std_logic_vector(unsigned(tmpaddr) + 1);
							else
								a(15 downto 8) <= di_reg;
								a(7 downto 0) <= tmpaddr(7 downto 0);
							end
						others:
							a <= std_logic_vector(pc);
						end case;
					end

					save_alu_r <= save_alu;
					alu_cpi_r <= alu_cpi;
					alu_op_r <= alu_op;

					if i_cpl = 1'b1 begin
						// cpl
						acc <= not acc;
						f(flag_y) <= not acc(5);
						f(flag_h) <= 1'b1;
						f(flag_x) <= not acc(3);
						f(flag_n) <= 1'b1;
					end
					if i_ccf = 1'b1 begin
						// ccf
						f(flag_c) <= not f(flag_c);
						f(flag_y) <= acc(5);
						f(flag_h) <= f(flag_c);
						f(flag_x) <= acc(3);
						f(flag_n) <= 1'b0;
					end
					if i_scf = 1'b1 begin
						// scf
						f(flag_c) <= 1'b1;
						f(flag_y) <= acc(5);
						f(flag_h) <= 1'b0;
						f(flag_x) <= acc(3);
						f(flag_n) <= 1'b0;
					end
				end

				if tstate = 2 and wait_n = 1'b1 begin
					if iset = 2'b01 and mcycle = 3'b111 begin
						ir <= dinst;
					end
					if jumpe = 1'b1 begin
						pc <= unsigned(signed(pc) + signed(di_reg));
					else if inc_pc = 1'b1 begin
						pc <= pc + 1;
					end
					if btr_r = 1'b1 begin
						pc <= pc - 2;
					end
					if rstp = 1'b1 begin
						tmpaddr <= (others =>1'b0);
						tmpaddr(5 downto 3) <= ir(5 downto 3);
					end
				end
				if tstate = 3 and mcycle = 3'b110 begin
					tmpaddr <= std_logic_vector(signed(regbusc) + signed(di_reg));
				end

				if (tstate = 2 and wait_n = 1'b1) or (tstate = 4 and mcycle = 3'b001) begin
					if incdec_16(2 downto 0) = 3'b111 begin
						if incdec_16(3) = 1'b1 begin
							sp <= sp - 1;
						else
							sp <= sp + 1;
						end
					end
				end

				if ldsphl = 1'b1 begin
					sp <= unsigned(regbusc);
				end
				if exchangeaf = 1'b1 begin
					ap <= acc;
					acc <= ap;
					fp <= f;
					f <= fp;
				end
				if exchangers = 1'b1 begin
					alternate <= not alternate;
				end
			end

			if tstate = 3 begin
				if ldz = 1'b1 begin
					tmpaddr(7 downto 0) <= di_reg;
				end
				if ldw = 1'b1 begin
					tmpaddr(15 downto 8) <= di_reg;
				end

				if special_ld(2) = 1'b1 begin
					case special_ld(1 downto 0) is
					2'b00:
						acc <= i;
						f(flag_p) <= inte_ff2;
						f(flag_n) <= 1'b0;			// added by t.hara, 2022/nov/05th
						f(flag_h) <= 1'b0;			// added by t.hara, 2022/nov/05th
						f(flag_s) <= i(7);			// added by t.hara, 2022/nov/05th
						if i = "00000000" begin		// added by t.hara, 2022/nov/05th
							f(flag_z) <= 1'b1;
						else
							f(flag_z) <= 1'b0;
						end
					2'b01:
						acc <= std_logic_vector(r);
						f(flag_p) <= inte_ff2;
						f(flag_n) <= 1'b0;							// added by t.hara, 2022/nov/05th
						f(flag_h) <= 1'b0;							// added by t.hara, 2022/nov/05th
						f(flag_s) <= std_logic(r(7));				// added by t.hara, 2022/nov/05th
						if std_logic_vector(r) = "00000000" begin	// added by t.hara, 2022/nov/05th
							f(flag_z) <= 1'b1;
						else
							f(flag_z) <= 1'b0;
						end
					2'b10:
						i <= acc;
					others:
						r <= unsigned(acc);
					end case;
				end
			end

			if (i_djnz = 1'b0 and save_alu_r = 1'b1) or alu_op_r = 4'b1001 begin
				f(7 downto 1) <= f_out(7 downto 1);
				if preservec_r = 1'b0 begin
					f(flag_c) <= f_out(0);
				end
			end
			if t_res = 1'b1 and i_inrc = 1'b1 begin
				f(flag_h) <= 1'b0;
				f(flag_n) <= 1'b0;
				if di_reg(7 downto 0) = "00000000" begin
					f(flag_z) <= 1'b1;
				else
					f(flag_z) <= 1'b0;
				end
				f(flag_s) <= di_reg(7);
				f(flag_p) <= not (di_reg(0) xor di_reg(1) xor di_reg(2) xor di_reg(3) xor
					di_reg(4) xor di_reg(5) xor di_reg(6) xor di_reg(7));
			end

			if tstate = 1 and auto_wait_t1 = 1'b0 begin
				do <= busb;
				if i_rld = 1'b1 begin
					do(3 downto 0) <= busa(3 downto 0);
					do(7 downto 4) <= busb(3 downto 0);
				end
				if i_rrd = 1'b1 begin
					do(3 downto 0) <= busb(7 downto 4);
					do(7 downto 4) <= busa(3 downto 0);
				end
			end

			if t_res = 1'b1 begin
				read_to_reg_r(3 downto 0) <= set_busa_to;
				read_to_reg_r(4) <= read_to_reg;
				if read_to_acc = 1'b1 begin
					read_to_reg_r(3 downto 0) <= 4'b0111;
					read_to_reg_r(4) <= 1'b1;
				end
			end

			if tstate = 1 and i_bt = 1'b1 begin
				f(flag_x) <= alu_q(3);
				f(flag_y) <= alu_q(1);
				f(flag_h) <= 1'b0;
				f(flag_n) <= 1'b0;
			end
			if i_bc = 1'b1 or i_bt = 1'b1 begin
				f(flag_p) <= incdecz;
			end

			if (tstate = 1 and save_alu_r = 1'b0 and auto_wait_t1 = 1'b0) or
				(save_alu_r = 1'b1 and alu_op_r != 4'b0111) begin
				case read_to_reg_r is
				"10111":
					acc <= save_mux;
				"10110":
					do <= save_mux;
				"11000":
					sp(7 downto 0) <= unsigned(save_mux);
				"11001":
					sp(15 downto 8) <= unsigned(save_mux);
				"11011":
					f <= save_mux;
				others:
				end case;
				if xybit_undoc=1'b1 begin
					do <= alu_q;
				end
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

			if( (tstate == 3'd2 || (tstate == 3'd3 && mcycle = 3'd1)) && incdec_16[2:0] == 3'd4 ) begin
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

	assign id16	= incdec_16[3] ? (regbusa - 16'd1) : (regbusa + 16'd1);

	process (save_alu_r, auto_wait_t1, alu_op_r, read_to_reg_r,
			exchangedh, incdec_16, mcycle, tstate, wait_n)
	begin
		regweh <= 1'b0;
		regwel <= 1'b0;
		if (tstate = 1 and save_alu_r = 1'b0 and auto_wait_t1 = 1'b0) or
			(save_alu_r = 1'b1 and alu_op_r != 4'b0111) begin
			case read_to_reg_r is
			"10000" | "10001" | "10010" | "10011" | "10100" | "10101":
				regweh <= not read_to_reg_r(0);
				regwel <= read_to_reg_r(0);
			others:
			end case;
		end

		if exchangedh = 1'b1 and (tstate = 3 or tstate = 4) begin
			regweh <= 1'b1;
			regwel <= 1'b1;
		end

		if incdec_16(2) = 1'b1 and ((tstate = 2 and wait_n = 1'b1 and mcycle != 3'b001) or (tstate = 3 and mcycle = 3'b001)) begin
			case incdec_16(1 downto 0) is
			2'b00 | 2'b01 | 2'b10:
				regweh <= 1'b1;
				regwel <= 1'b1;
			others:
			end case;
		end
	end

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
			4'b0000, 4'b0001, 4'b0010, 4'b0011, 4'b0100, 4'b0101:
				busb <= set_busb_to[0] ? regbusb[ 7:0]: regbusb[15:8];
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
				busa <= std_logic_vector(sp(7 downto 0));
			4'b1001:
				busa <= std_logic_vector(sp(15 downto 8));
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
			rfsh_n <= 1'b1;
		end
		else if( cen ) begin
			if( mcycle == 3'd1 && ((tstate == 2	&& wait_n) || tstate == 3 ) begin
				rfsh_n <= 1'b0;
			end
			else begin
				rfsh_n <= 1'b1;
			end
		end
	end

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
			m1_n <= 1'b1;
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
				m1_n <= 1'b1;
			end
			if( busreq_s && busack ) begin
				//	hold
			end
			else begin
				busack <= 1'b0;
				if( tstate == 3'd2 && !wait_n ) begin
				else if t_res = 1'b1 begin
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
							pre_xy_f_m <= mcycle;
							if( ir == 8'h36 ) begin
								pre_xy_f_m <= 3'd2;
							end
						end
						else if( mcycle == 3'd7 ) begin
							mcycle <= pre_xy_f_m + 3'd1;
						end
						else if( (mcycle == mcycles) || no_btr || (mcycle == 3'd2 && i_djnz && incdecz) ) begin
							m1_n <= 1'b0;
							mcycle <= 3'b001;
							intcycle <= 1'b0;
							nmicycle <= 1'b0;
							if( nmi_s && prefix == 2'd0 ) begin
								nmicycle <= 1'b1;
								inte_ff1 <= 1'b0;
							end
							else if( (inte_ff1 && int_s) && prefix == 2'd0 && !setei ) begin
								intcycle <= 1'b1;
								inte_ff1 <= 1'b0;
								inte_ff2 <= 1'b0;
							end
						end
						else begin
							mcycle <= std_logic_vector(unsigned(mcycle) + 1);
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
				m1_n <= 1'b0;
			end
		end
	end

	assign auto_wait	= ((intcycle || nmicycle) && mcycle == 3'd1);
endmodule
