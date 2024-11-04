//
//	vdp_command.v
//
//	Copyright (C) 2024 Takayuki Hara
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
//----------------------------------------------------------------------------

module vdp_command (
	input				reset				,
	input				clk					,
	input				enable				,

	input				vdp_mode_graphic4		,
	input				vdp_mode_graphic5		,
	input				vdp_mode_graphic6		,
	input				vdp_mode_graphic7		,
	input				vdp_mode_is_highres	,

	input				vramwrack			,
	input				vramrdack			,
	input	[7:0]		vramrddata			,
	input				regwrreq			,
	input				trclrreq			,
	input	[3:0]		regnum				,
	input	[7:0]		regdata				,
	output				pregwrack			,
	output				ptrclrack			,
	output				pvramwrreq			,
	output				pvramrdreq			,
	output	[16:0]		pvramaccessaddr		,
	output	[7:0]		pvramwrdata			,
	output	[7:0]		pclr				,	// r44, s#7
	output				pce					,	// s#2 (bit 0)
	output				pbd					,	// s#2 (bit 4)
	output				ptr					,	// s#2 (bit 7)
	output	[10:0]		psxtmp				,	// s#8, s#9

	output	[7:4]		cur_vdp_command		,

	input				reg_r25_cmd			
);

	wire				w_graphic46;

	//	VDP command registers ------------------------------
	reg		[8:0]		ff_r32r33_sx;
	reg		[9:0]		ff_r34r35_sy;
	reg		[8:0]		ff_r36r37_dx;
	reg		[9:0]		ff_r38r39_dy;
	reg		[9:0]		ff_r40r41_nx;
	reg		[9:0]		ff_r42r43_ny;
	reg					ff_r45_mm;					// bit 0
	reg					ff_r45_eq;					// bit 1
	reg					ff_r45_dix;					// bit 2
	reg					ff_r45_diy;					// bit 3
//	reg					ff_r45_mxs;					// bit 4	※拡張VRAM用レジスタ
//	reg					ff_r45_mxd;					// bit 5	※拡張VRAM用レジスタ
	reg		[7:0]		ff_r46_cmr;


	//	VDP command internal registers ---------------------
	reg		[9:0]		ff_dx_tmp;
	reg		[9:0]		ff_nx_tmp;
	reg					ff_reg_wr_ack;
	reg					ff_tr_clr_ack;
	reg					ff_vdpcmd_start;
	reg					ff_vram_wr_req;
	reg					ff_vram_rd_req;
	reg		[16:0]		ff_vram_address;
	reg		[7:0]		ff_vram_wdata;

	reg		[7:0]		ff_r44_clr;		// r44, s#7

	// vdp command signals - can be read by cpu
	reg					ff_s2_ce;			// s#2 (bit 0)
	reg					ff_s2_bd;			// s#2 (bit 4)
	reg					ff_s2_tr;			// s#2 (bit 7)
	reg		[10:0]		ff_s8s9_sx_tmp;		// s#8, s#9

	wire				w_vdpcmd_en;

	// vdp command ff_state register
	localparam			state_idle					= 0;
	localparam			state_chk_loop				= 1;
	localparam			state_read_cpu				= 2;
	localparam			state_wait_cpu				= 3;
	localparam			state_read_vram				= 4;
	localparam			state_wait_read_vram		= 5;
	localparam			state_point_wait_read_vram	= 6;
	localparam			state_srch_wait_read_vram	= 7;
	localparam			state_pre_read_vram			= 8;
	localparam			state_wait_pre_read_vram	= 9;
	localparam			state_write_vram			= 10;
	localparam			state_wait_write_vram		= 11;
	localparam			state_line_new_pos			= 12;
	localparam			state_line_chk_loop			= 13;
	localparam			state_srch_chk_loop			= 14;
	localparam			state_exec_end				= 15;
	reg			[3:0]	ff_state;

	localparam	[3:0]	cmd_hmmc		= 4'b1111;
	localparam	[3:0]	cmd_ymmm		= 4'b1110;
	localparam	[3:0]	cmd_hmmm		= 4'b1101;
	localparam	[3:0]	cmd_hmmv		= 4'b1100;
	localparam	[3:0]	cmd_lmmc		= 4'b1011;
	localparam	[3:0]	cmd_lmcm		= 4'b1010;
	localparam	[3:0]	cmd_lmmm		= 4'b1001;
	localparam	[3:0]	cmd_lmmv		= 4'b1000;
	localparam	[3:0]	cmd_line		= 4'b0111;
	localparam	[3:0]	cmd_srch		= 4'b0110;
	localparam	[3:0]	cmd_pset		= 4'b0101;
	localparam	[3:0]	cmd_point		= 4'b0100;
	localparam	[3:0]	cmd_stop		= 4'b0000;

	localparam	[2:0]	logop_imp		= 3'b000;
	localparam	[2:0]	logop_and		= 3'b001;
	localparam	[2:0]	logop_or		= 3'b010;
	localparam	[2:0]	logop_eor		= 3'b011;
	localparam	[2:0]	logop_not		= 3'b100;

	assign pregwrack		=	ff_reg_wr_ack;
	assign ptrclrack		=	ff_tr_clr_ack;
	assign pvramwrreq		=	( w_vdpcmd_en ) ? ff_vram_wr_req : vramwrack;
	assign pvramrdreq		=	ff_vram_rd_req;
	assign pvramaccessaddr	=	ff_vram_address;
	assign pvramwrdata		=	ff_vram_wdata;
	assign pclr				=	ff_r44_clr;
	assign pce				=	ff_s2_ce;
	assign pbd				=	ff_s2_bd;
	assign ptr				=	ff_s2_tr;
	assign psxtmp			=	ff_s8s9_sx_tmp;

	assign cur_vdp_command	=	ff_r46_cmr[7:4];

	// r25 cmd bit
	// 0 = normal
	// 1 = vdp command on text/graphic1/graphic2/graphic3/mosaic mode
	assign w_vdpcmd_en	= ( !(vdp_mode_graphic4 | vdp_mode_graphic5 | vdp_mode_graphic6) ) ? (vdp_mode_graphic7 | reg_r25_cmd) : (vdp_mode_graphic4 | vdp_mode_graphic5 | vdp_mode_graphic6);
	assign w_graphic46	= vdp_mode_graphic4 | vdp_mode_graphic6;

	always @( posedge clk ) begin: vdp_command_processor
		reg				ff_initializing;
		reg		[9:0]	ff_nx_count;
		reg		[10:0]	ff_x_count_delta;
		reg		[9:0]	ff_y_count_delta;
		reg				ff_nx_loop_end;
		reg				dyend;
		reg				syend;
		reg				nyloopend;
		reg		[9:0]	nx_minus_one;
		reg		[1:0]	ff_read_x_low;
		reg		[7:0]	rdpoint;
		reg		[7:0]	ff_col_mask;
		reg		[1:0]	maxxmask;
		reg		[7:0]	ff_logop_dest_col;
		reg				srcheqrslt;
		reg		[9:0]	ff_current_y;
		reg		[8:0]	ff_current_x;

		if( reset ) begin
			ff_state			<= state_idle;	// very important for xilinx synthesis tool(xst)
			ff_r32r33_sx		<= 9'd0;	// r32
			ff_r34r35_sy		<= 10'd0;	// r34
			ff_r36r37_dx		<= 9'd0;	// r36
			ff_r38r39_dy		<= 10'd0;	// r38
			ff_r40r41_nx		<= 10'd0;	// r40
			ff_r42r43_ny		<= 10'd0;	// r42
			ff_r44_clr			<= 8'd0;	// r44
			ff_r45_mm			<= 1'b0; // r45 bit 0
			ff_r45_eq			<= 1'b0; // r45 bit 1
			ff_r45_dix			<= 1'b0; // r45 bit 2
			ff_r45_diy			<= 1'b0; // r45 bit 3
//			ff_r45_mxs			<= 1'b0; // r45 bit 4
//			ff_r45_mxd			<= 1'b0; // r45 bit 5
			ff_r46_cmr			<= 8'd0;
			ff_s8s9_sx_tmp		<= 11'd0;
			ff_dx_tmp			<= 10'd0;
			ff_nx_tmp			<= 10'd0;
			ff_vdpcmd_start		<= 1'b0;
			ff_reg_wr_ack		<= 1'b0;
			ff_vram_wr_req		<= 1'b0;
			ff_vram_rd_req		<= 1'b0;
			ff_vram_wdata		<= 8'd0;

			ff_s2_tr			<= 1'b1; // transfer ready
			ff_s2_ce			<= 1'b0; // command executing
			ff_s2_bd			<= 1'b0; // border color found
			ff_tr_clr_ack		<= 1'b0;
			ff_vram_address		<= 17'd0;

			ff_initializing		= 1'b0;
			ff_nx_count			= 10'd0;
			ff_nx_loop_end		= 1'b0;
			ff_x_count_delta	= 11'd0;
			ff_y_count_delta	= 10'd0;
			ff_col_mask			= 8'd0;
			ff_read_x_low		= 2'b00;
			ff_current_y		= 10'd0;
			ff_current_x		= 9'd0;
		end
		else if( !enable ) begin
			// hold
		end
		else begin
			if( !enable ) begin
				// hold
			end
			else begin
				case( ff_r46_cmr[7:6] )
				2'b11:
					begin
						// byte command
						if( w_graphic46 ) begin
							// Graphic 4 or Graphic 6 (Screen 5 or Screen 7)
							ff_nx_count = { 1'b0, ff_r40r41_nx[9:1] };
							if( !ff_r45_dix ) begin
								ff_x_count_delta = 11'b00000000010; // +2
							end
							else begin
								ff_x_count_delta = 11'b11111111110; // -2
							end
						end
						else if( vdp_mode_graphic5 == 1'b1 ) begin
							// graphic5 (screen 6)
							ff_nx_count = 2'b00 & ff_r40r41_nx[9:2];
							if( !ff_r45_dix ) begin
								ff_x_count_delta = 11'b00000000100; // +4
							end
							else begin
								ff_x_count_delta = 11'b11111111100; // -4;
							end
						end
						else begin
							// graphic7 (screen 8) and other
							ff_nx_count = ff_r40r41_nx;
							if( !ff_r45_dix ) begin
								ff_x_count_delta = 11'b00000000001; // +1
							end
							else begin
								ff_x_count_delta = 11'b11111111111; // -1
							end
						end
						ff_col_mask = 8'b11111111;
					end
				default:
					begin
						// dot command
						ff_nx_count = ff_r40r41_nx;
						if( !ff_r45_dix ) begin
							ff_x_count_delta = 11'b00000000001; // +1;
						end
						else begin
							ff_x_count_delta = 11'b11111111111; // -1;
						end
						if( w_graphic46 ) begin
							ff_col_mask = 8'b00001111;
						end
						else if(vdp_mode_graphic5 == 1'b1) begin
							ff_col_mask = 8'b00000011;
						end
						else begin
							ff_col_mask = 8'b11111111;
						end
					end
				endcase
			end

			if( !enable ) begin
				// hold
			end
			else if( !ff_r45_diy ) begin
				ff_y_count_delta = 10'b0000000001;
			end
			else begin
				ff_y_count_delta = 10'b1111111111;
			end

			if( !enable ) begin
				// hold
			end
			else if(vdp_mode_is_highres == 1'b1) begin
				// graphic 5,6 (screen 6, 7)
				maxxmask = 2'b10;
			end
			else begin
				maxxmask = 2'b01;
			end

			// determine if x-loop is finished
			if( !enable ) begin
				// hold
			end
			else begin
				case( ff_r46_cmr[7:4] )
				cmd_hmmv, cmd_hmmc, cmd_lmmv, cmd_lmmc:
					if( (ff_nx_tmp == 10'd0) || ( (ff_dx_tmp[9:8] & maxxmask) == maxxmask ) ) begin
						ff_nx_loop_end = 1'b1;
					end
					else begin
						ff_nx_loop_end = 1'b0;
					end
				cmd_ymmm:
					if( (ff_dx_tmp[9:8] & maxxmask) == maxxmask ) begin
						ff_nx_loop_end = 1'b1;
					end
					else begin
						ff_nx_loop_end = 1'b0;
					end
				cmd_hmmm, cmd_lmmm:
					if( (ff_nx_tmp == 10'd0) || ( (ff_s8s9_sx_tmp[9:8] & maxxmask) == maxxmask ) ||
							((ff_dx_tmp[9:8] & maxxmask) == maxxmask)) begin
						ff_nx_loop_end = 1'b1;
					end
					else begin
						ff_nx_loop_end = 1'b0;
					end
				cmd_lmcm:
					if((ff_nx_tmp == 0) ||
							((ff_s8s9_sx_tmp[9:8] & maxxmask) == maxxmask)) begin
						ff_nx_loop_end = 1'b1;
					end
					else begin
						ff_nx_loop_end = 1'b0;
					end
				cmd_srch:
					if((ff_s8s9_sx_tmp[9:8] & maxxmask) == maxxmask) begin
						ff_nx_loop_end = 1'b1;
					end
					else begin
						ff_nx_loop_end = 1'b0;
					end
				default:
					ff_nx_loop_end = 1'b1;
				endcase

				// retrieve the 'cmd_point' out of the byte that was most recently read
				if(w_graphic46 == 1'b1) begin
					// Graphic 4 or Graphic 6 (Screen 5 or Screen 7)
					if( !ff_read_x_low[0] ) begin
						rdpoint = { 4'b0000, vramrddata[7:4] };
					end
					else begin
						rdpoint = { 4'b0000, vramrddata[3:0] };
					end
				end
				else if(vdp_mode_graphic5 == 1'b1) begin
					// Graphic 5 (Screen 6)
					case( ff_read_x_low )
					2'b00:
						rdpoint = { 6'b000000, vramrddata[7:6] };
					2'b01:
						rdpoint = { 6'b000000, vramrddata[5:4] };
					2'b10:
						rdpoint = { 6'b000000, vramrddata[3:2] };
					default:
						rdpoint = { 6'b000000, vramrddata[1:0] };
					endcase
				end
				else begin
					// Graphic 7 (Screen 8) and other modes
					rdpoint = vramrddata;
				end

				// perform logical operation on most recently read cmd_point and
				// on the cmd_point to be written.
				if( !ff_r46_cmr[3] || ((ff_vram_wdata & ff_col_mask) != 8'b00000000) ) begin
					case( ff_r46_cmr[2:0] )
					logop_imp:
						ff_logop_dest_col = (ff_vram_wdata & ff_col_mask);
					logop_and:
						ff_logop_dest_col = (ff_vram_wdata & ff_col_mask) & rdpoint;
					logop_or:
						ff_logop_dest_col = (ff_vram_wdata & ff_col_mask) | rdpoint;
					logop_eor:
						ff_logop_dest_col = (ff_vram_wdata & ff_col_mask) ^ rdpoint;
					logop_not:
						ff_logop_dest_col = ~(ff_vram_wdata & ff_col_mask);
					default:
						ff_logop_dest_col = rdpoint;
					endcase
				end
				else begin
					ff_logop_dest_col = rdpoint;
				end

				// process register update request, clear 'transfer ready' request
				// or process any ongoing command.
				if( regwrreq != ff_reg_wr_ack ) begin
					ff_reg_wr_ack <= ~ff_reg_wr_ack;
					case( regnum )
					4'b0000:		// #32
						ff_r32r33_sx[7:0] <= regdata;
					4'b0001:		// #33
						ff_r32r33_sx[8] <= regdata[0];
					4'b0010:		// #34
						ff_r34r35_sy[7:0] <= regdata;
					4'b0011:		// #35
						ff_r34r35_sy[9:8] <= regdata[1:0];
					4'b0100:		// #36
						ff_r36r37_dx[7:0] <= regdata;
					4'b0101:		// #37
						ff_r36r37_dx[8] <= regdata[0];
					4'b0110:		// #38
						ff_r38r39_dy[7:0] <= regdata;
					4'b0111:		// #39
						ff_r38r39_dy[9:8] <= regdata[1:0];
					4'b1000:		// #40
						ff_r40r41_nx[7:0] <= regdata;
					4'b1001:		// #41
						ff_r40r41_nx[9:8] <= regdata[1:0];
					4'b1010:		// #42
						ff_r42r43_ny[7:0] <= regdata;
					4'b1011:		// #43
						ff_r42r43_ny[9:8] <= regdata[1:0];
					4'b1100:		// #44
						begin
							if( ff_s2_ce ) begin
								ff_r44_clr <= regdata & ff_col_mask;
							end
							else begin
								ff_r44_clr <= regdata;
							end
							ff_s2_tr <= 1'b0;		// data is transferred from cpu to vdp color register
						end
					4'b1101:		// #45
						begin
							ff_r45_mm	<= regdata[0];
							ff_r45_eq	<= regdata[1];
							ff_r45_dix <= regdata[2];
							ff_r45_diy <= regdata[3];
	//						ff_r45_mxd <= regdata[5];
						end
					4'b1110:		// #46
						begin
							// initialize the new command
							// note that this will abort any ongoing command!
							ff_r46_cmr		<= regdata;
							ff_vdpcmd_start	<= w_vdpcmd_en;
							ff_state		<= state_idle;
						end
					default:
						begin
							//	hold
						end
					endcase
				end
				else if( trclrreq != ff_tr_clr_ack ) begin
					// reset the data transfer register (cpu has just read the color register)
					ff_tr_clr_ack <= ~ff_tr_clr_ack;
					ff_s2_tr <= 1'b0;
				end
				else begin
					// process the vdp command ff_state
					case( ff_state )
					state_idle:
						begin
							if( !ff_vdpcmd_start ) begin
								ff_s2_ce <= 1'b0;
							end
							else begin
								// exec new vdp command
								ff_vdpcmd_start <= 1'b0;
								ff_s2_ce <= 1'b1;
								ff_s2_bd <= 1'b0;
								if( ff_r46_cmr[7:4] == cmd_line ) begin
									// cmd_line command requires special ff_s8s9_sx_tmp and ff_nx_tmp set-up
									nx_minus_one = ff_r40r41_nx - 1;
									ff_s8s9_sx_tmp <= { 2'b00, nx_minus_one[9:1] };
									ff_nx_tmp <= 10'd0;
								end
								else begin
									if( ff_r46_cmr[7:4] == cmd_ymmm ) begin
										// for cmd_ymmm, ff_s8s9_sx_tmp = ff_dx_tmp = ff_r36r37_dx
										ff_s8s9_sx_tmp <= { 2'b00, ff_r36r37_dx };
									end
									else begin
										// for all others, ff_s8s9_sx_tmp is busines as usual
										ff_s8s9_sx_tmp <= { 2'b00, ff_r32r33_sx };
									end
									// ff_nx_tmp is business as usual for all but the cmd_line command
									ff_nx_tmp <= ff_nx_count;
								end
								ff_dx_tmp <= { 1'b0, ff_r36r37_dx };
								ff_initializing = 1'b1;
								ff_state <= state_chk_loop;
							end
						end
					state_read_cpu:
						begin
							// applicable to cmd_hmmc, cmd_lmmc
							if( !ff_s2_tr ) begin
								// cpu has transferred data to (or from) the color register
								ff_s2_tr <= 1'b1;	// vdp is ready to receive the next transfer.
								ff_vram_wdata <= ff_r44_clr;
								if( !ff_r46_cmr[6] ) begin
									// it is cmd_lmmc
									ff_state <= state_pre_read_vram;
								end
								else begin
									// it is cmd_hmmc
									ff_state <= state_write_vram;
								end
							end
						end
					state_wait_cpu:
						begin
							// applicable to cmd_lmcm
							if( !ff_s2_tr ) begin
								// cpu has transferred data from (or to) the color register
								// vdp may read the next value into the color register
								ff_state <= state_read_vram;
							end
						end
					state_read_vram:
						begin
							// applicable to cmd_ymmm, cmd_hmmm, cmd_lmcm, cmd_lmmm, cmd_srch, cmd_point
							ff_current_y = ff_r34r35_sy;
							ff_current_x = ff_s8s9_sx_tmp[8:0];
							ff_read_x_low = ff_s8s9_sx_tmp[1:0];
							ff_vram_rd_req <= ~vramrdack;
							case( ff_r46_cmr[7:4] )
							cmd_point:
								ff_state <= state_point_wait_read_vram;
							cmd_srch:
								ff_state <= state_srch_wait_read_vram;
							default:
								ff_state <= state_wait_read_vram;
							endcase
						end
					state_point_wait_read_vram:
						begin
							// applicable to cmd_point
							if( ff_vram_rd_req == vramrdack ) begin
								ff_r44_clr <= rdpoint;
								ff_state <= state_exec_end;
							end
						end
					state_srch_wait_read_vram:
						begin
							// applicable to cmd_srch
							if( ff_vram_rd_req == vramrdack ) begin
								if(rdpoint == ff_r44_clr) begin
									srcheqrslt = 1'b0;
								end
								else begin
									srcheqrslt = 1'b1;
								end
								if( ff_r45_eq == srcheqrslt ) begin
									ff_s2_bd <= 1'b1;
									ff_state <= state_exec_end;
								end
								else begin
									ff_s8s9_sx_tmp <= ff_s8s9_sx_tmp + ff_x_count_delta;
									ff_state <= state_srch_chk_loop;
								end
							end
						end
					state_wait_read_vram:
						begin
							// applicable to cmd_ymmm, cmd_hmmm, cmd_lmcm, cmd_lmmm
							if( ff_vram_rd_req == vramrdack ) begin
								ff_s8s9_sx_tmp			<= ff_s8s9_sx_tmp + ff_x_count_delta;
								case( ff_r46_cmr[7:4] )
								cmd_lmmm:
									begin
										ff_vram_wdata	<= rdpoint;
										ff_state		<= state_pre_read_vram;
									end
								cmd_lmcm:
									begin
										ff_r44_clr				<= rdpoint;
										ff_s2_tr				<= 1'b1;
										ff_nx_tmp		<= ff_nx_tmp - 1;
										ff_state		<= state_chk_loop;
									end
								default: // remaining: cmd_ymmm, cmd_hmmm
									begin
										ff_vram_wdata	<= vramrddata;
										ff_state		<= state_write_vram;
									end
								endcase
							end
						end
					state_pre_read_vram:
						begin
							// applicable to cmd_lmmc, cmd_lmmm, cmd_lmmv, cmd_line, cmd_pset
							ff_current_y	= ff_r38r39_dy;
							ff_current_x	= ff_dx_tmp[8:0];
							ff_read_x_low			= ff_dx_tmp[1:0];
							ff_vram_rd_req	<= ~vramrdack;
							ff_state		<= state_wait_pre_read_vram;
						end
					state_wait_pre_read_vram:
						begin
							// applicable to cmd_lmmc, cmd_lmmm, cmd_lmmv, cmd_line, cmd_pset
							if( ff_vram_rd_req == vramrdack ) begin
								if( w_graphic46 ) begin
									// Graphic4 or Graphic6 (Screen 5 or Screen 7)
									if( !ff_read_x_low[0] ) begin
										ff_vram_wdata	<= { ff_logop_dest_col[3:0], vramrddata[3:0] };
									end
									else begin
										ff_vram_wdata	<= { vramrddata[7:4], ff_logop_dest_col[3:0] };
									end
								end
								else if( vdp_mode_graphic5 ) begin
									// screen 6
									case( ff_read_x_low )
										2'b00:
											ff_vram_wdata	<= { ff_logop_dest_col[1:0], vramrddata[5:0] };
										2'b01:
											ff_vram_wdata	<= { vramrddata[7:6], ff_logop_dest_col[1:0], vramrddata[3:0] };
										2'b10:
											ff_vram_wdata	<= { vramrddata[7:4], ff_logop_dest_col[1:0], vramrddata[1:0] };
										default:
											ff_vram_wdata	<= { vramrddata[7:2], ff_logop_dest_col[1:0] };
									endcase
								end
								else begin
									// screen 8 and other modes
									ff_vram_wdata	<= ff_logop_dest_col;
								end
								ff_state	<= state_write_vram;
							end
						end
					state_write_vram:
						begin
							// applicable to cmd_hmmc, cmd_ymmm, cmd_hmmm, cmd_hmmv, cmd_lmmc, cmd_lmmm, cmd_lmmv, cmd_line, cmd_pset
							ff_current_y	= ff_r38r39_dy;
							ff_current_x	= ff_dx_tmp[8:0];
							ff_vram_wr_req	<= ~vramwrack;
							ff_state		<= state_wait_write_vram;
						end
					state_wait_write_vram:
						begin
							// applicable to cmd_hmmc, cmd_ymmm, cmd_hmmm, cmd_hmmv, cmd_lmmc, cmd_lmmm, cmd_lmmv, cmd_line, cmd_pset
							if( ff_vram_wr_req == vramwrack ) begin
								case( ff_r46_cmr[7:4] )
								cmd_pset:
									ff_state <= state_exec_end;
								cmd_line:
									begin
										ff_s8s9_sx_tmp <= ff_s8s9_sx_tmp - ff_r42r43_ny;
										if( !ff_r45_mm ) begin
											ff_dx_tmp <= ff_dx_tmp + ff_x_count_delta[9:0];
										end
										else begin
											ff_r38r39_dy <= ff_r38r39_dy + ff_y_count_delta;
										end
										ff_state <= state_line_new_pos;
									end
								default:
									begin
										ff_dx_tmp <= ff_dx_tmp + ff_x_count_delta[9:0];
										ff_nx_tmp <= ff_nx_tmp - 1;
										ff_state <= state_chk_loop;
									end
								endcase
							end
						end
					state_line_new_pos:
						begin
							// applicable to cmd_line
							if( ff_s8s9_sx_tmp[10] ) begin
								ff_s8s9_sx_tmp <= { 1'b0, (ff_s8s9_sx_tmp[9:0] + ff_r40r41_nx) };
								if( !ff_r45_mm ) begin
									ff_r38r39_dy <= ff_r38r39_dy + ff_y_count_delta;
								end
								else begin
									ff_dx_tmp <= ff_dx_tmp + ff_x_count_delta[9:0];
								end
							end
							ff_state		<= state_line_chk_loop;
						end
					state_line_chk_loop:
						begin
							// applicable to cmd_line
							if( (ff_nx_tmp == ff_r40r41_nx) || ((ff_dx_tmp[9:8] & maxxmask) == maxxmask) ) begin
								ff_state <= state_exec_end;
							end
							else begin
								ff_vram_wdata	<= ff_r44_clr;
								// color must be re-masked, just in case that screenmode was changed
								ff_r44_clr				<= ff_r44_clr & ff_col_mask;
								ff_state		<= state_pre_read_vram;
							end
							ff_nx_tmp		<= ff_nx_tmp + 1;
						end
					state_srch_chk_loop:
						begin
							// applicable to cmd_srch
							if( ff_nx_loop_end ) begin
								ff_state	<= state_exec_end;
							end
							else begin
								// color must be re-masked, just in case that screenmode was changed
								ff_r44_clr	<= ff_r44_clr & ff_col_mask;
								ff_state	<= state_read_vram;
							end
						end
					state_chk_loop:
						begin
							// when ff_initializing == 1'b1:
							//	 applicable to all commands
							// when ff_initializing == 1'b0:
							// applicable to cmd_hmmc, cmd_ymmm, cmd_hmmm, cmd_hmmv, cmd_lmmc, cmd_lmcm, cmd_lmmm, cmd_lmmv

							// determine nyloopend
							dyend = 1'b0;
							syend = 1'b0;
							if( ff_r45_diy ) begin
								if( (ff_r38r39_dy == 0) && (ff_r46_cmr[7:4] != cmd_lmcm) ) begin
									dyend = 1'b1;
								end
								if( (ff_r34r35_sy == 0) && (ff_r46_cmr[5] != ff_r46_cmr[4]) ) begin
									// bit5 != bit4 is true for commands cmd_ymmm, cmd_hmmm, cmd_lmcm, cmd_lmmm
									syend = 1'b1;
								end
							end
							if( (ff_r42r43_ny == 1) || dyend || syend == 1'b1 ) begin
								nyloopend = 1'b1;
							end
							else begin
								nyloopend = 1'b0;
							end

							if( !ff_initializing && ff_nx_loop_end && nyloopend ) begin
								ff_state <= state_exec_end;
							end
							else begin
								// command not yet finished or command initializing. determine next/first step
								// color must be (re-)masked, just in case that screenmode was changed
								ff_r44_clr <= ff_r44_clr & ff_col_mask;
								case( ff_r46_cmr[7:4] )
								cmd_hmmc:
									ff_state <= state_read_cpu;
								cmd_ymmm:
									ff_state <= state_read_vram;
								cmd_hmmm:
									ff_state <= state_read_vram;
								cmd_hmmv:
									begin
										ff_vram_wdata	<= ff_r44_clr;
										ff_state		<= state_write_vram;
									end
								cmd_lmmc:
									ff_state <= state_read_cpu;
								cmd_lmcm:
									ff_state <= state_wait_cpu;
								cmd_lmmm:
									ff_state <= state_read_vram;
								cmd_lmmv, cmd_line, cmd_pset:
									begin
										ff_vram_wdata	<= ff_r44_clr;
										ff_state		<= state_pre_read_vram;
									end
								cmd_srch:
									ff_state <= state_read_vram;
								cmd_point:
									ff_state <= state_read_vram;
								default:
									ff_state <= state_exec_end;
								endcase
							end
							if( !ff_initializing && ff_nx_loop_end ) begin
								ff_nx_tmp <= ff_nx_count;
								if( ff_r46_cmr[7:4] == cmd_ymmm ) begin
									ff_s8s9_sx_tmp <= { 2'b00, ff_r36r37_dx };
								end
								else begin
									ff_s8s9_sx_tmp <= { 2'b00, ff_r32r33_sx };
								end
								ff_dx_tmp <= { 1'b0, ff_r36r37_dx };
								ff_r42r43_ny <= ff_r42r43_ny - 1;
								if( ff_r46_cmr[5] != ff_r46_cmr[4] ) begin
									// bit5 != bit4 is true for commands cmd_ymmm, cmd_hmmm, cmd_lmcm, cmd_lmmm
									ff_r34r35_sy <= ff_r34r35_sy + ff_y_count_delta;
								end
								if( ff_r46_cmr[7:4] != cmd_lmcm ) begin
									ff_r38r39_dy <= ff_r38r39_dy + ff_y_count_delta;
								end
							end
							else begin
								ff_s8s9_sx_tmp[10] <= 1'b0;
							end
							ff_initializing = 1'b0;
						end
					default:
						begin
							ff_state	<= state_idle;
							ff_s2_ce	<= 1'b0;
							ff_r46_cmr	<= 8'd0;
						end
					endcase
				end

				if(      vdp_mode_graphic4 ) begin
					//	Graphic4 (Screen5)
					ff_vram_address <= { ff_current_y[9:0], ff_current_x[7:1] };
				end
				else if( vdp_mode_graphic5 ) begin
					//	Graphic5 (Screen6)
					ff_vram_address <= { ff_current_y[9:0], ff_current_x[8:2] };
				end
				else if( vdp_mode_graphic6 ) begin
					//	Graphic6 (Screen7)
					ff_vram_address <= { ff_current_y[8:0], ff_current_x[8:1] };
				end
				else begin
					//	Graphic7 (Screen8)
					ff_vram_address <= { ff_current_y[8:0], ff_current_x[7:0] };
				end
			end
		end
	end
endmodule
