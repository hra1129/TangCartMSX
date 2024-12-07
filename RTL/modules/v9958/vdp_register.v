//
//	vdp_register.v
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

module vdp_register (
	input				reset,
	input				clk,
	input				enable,

	input				wr_req,
	input				rd_req,
	input		[1:0]	address,
	output reg	[7:0]	rdata,
	output				rdata_en,
	input		[7:0]	wdata,

	input		[1:0]	dot_state,

	input				vdp_cmd_tr_clr_ack,
	input				vdp_cmd_reg_wr_ack,
	input				hsync,

	input				vdp_s0_sp_collision_incidence,
	input				vdp_s0_sp_overmapped,
	input		[4:0]	vdp_s0_sp_overmapped_num,
	output				sp_vdp_s0_reset_req,
	input				sp_vdp_s0_reset_ack,
	output reg			sp_vdp_s5_reset_req,
	input				sp_vdp_s5_reset_ack,

	input				vdp_cmd_tr,					// s#2
	input				vd,							// s#2
	input				hd,							// s#2
	input				vdp_cmd_bd,					// s#2
	input				field,						// s#2
	input				vdp_cmd_ce,					// s#2
	input		[8:0]	vdp_s3_s4_sp_collision_x,	// s#3,s#4
	input		[8:0]	vdp_s5_s6_sp_collision_y,	// s#5,s#6
	input		[7:0]	vdp_cmd_clr,				// r44,s#7
	input		[10:0]	vdp_cmd_sx_tmp,				// s#8,s#9

	output reg	[7:0]	vdp_vram_wdata_cpu,
	output reg	[16:0]	vdp_vram_address_cpu,
	output reg			vdp_vram_addr_set_req,
	input				vdp_vram_addr_set_ack,
	output reg			vdp_vram_wr_req,
	input				vdp_vram_wr_ack,
	input		[7:0]	vdp_vram_rd_data,
	output reg			vdp_vram_rd_req,
	input				vdp_vram_rd_ack,

	output reg	[3:0]	vdp_cmd_reg_num,
	output reg	[7:0]	vdp_cmd_reg_data,
	output reg			vdp_cmd_reg_wr_req,
	output reg			vdp_cmd_tr_clr_req,

	output		[7:0]	palette_address,
	output				palette_we,
	output		[4:0]	palette_wdata_r,
	output		[4:0]	palette_wdata_g,
	output		[4:0]	palette_wdata_b,

		// interrupt
	output reg			clr_vsync_int,
	output reg			clr_hsync_int,
	input				req_vsync_int_n,
	input				req_hsync_int_n,

		// register value
	output reg			reg_r0_hsync_int_en,
	output reg			reg_r1_sp_size,
	output reg			reg_r1_sp_zoom,
	output reg			reg_r1_bl_clks,
	output reg			reg_r1_vsync_int_en,
	output reg			reg_r1_disp_on,
	output reg	[6:0]	reg_r2_pattern_name,
	output reg	[5:0]	reg_r4_pattern_generator,
	output reg	[10:0]	reg_r10r3_color,
	output reg	[9:0]	reg_r11r5_sp_atr_addr,
	output reg	[5:0]	reg_r6_sp_gen_addr,
	output reg	[7:0]	reg_r7_frame_col,
	output reg			reg_r8_sp_off,
	output reg			reg_r8_col0_on,
	output reg			reg_r9_pal_mode,
	output reg			reg_r9_interlace_mode,
	output reg			reg_r9_y_dots,
	output reg	[7:0]	reg_r12_blink_mode,
	output reg	[7:0]	reg_r13_blink_period,
	output	[7:0]		reg_r18_adj,
	output reg	[7:0]	reg_r19_hsync_int_line,
	output reg	[7:0]	reg_r23_vstart_line,
	output reg			reg_r25_cmd,
	output reg			reg_r25_yae,
	output reg			reg_r25_yjk,
	output reg			reg_r25_msk,
	output reg			reg_r25_sp2,
	output reg	[8:3]	reg_r26_h_scroll,
	output reg	[2:0]	reg_r27_h_scroll,

	//	mode
	output				vdp_mode_text1,
	output				vdp_mode_text1q,
	output				vdp_mode_text2,
	output				vdp_mode_multi,
	output				vdp_mode_multiq,
	output				vdp_mode_graphic1,
	output				vdp_mode_graphic2,
	output				vdp_mode_graphic3,
	output				vdp_mode_graphic4,
	output				vdp_mode_graphic5,
	output				vdp_mode_graphic6,
	output				vdp_mode_graphic7,
	output				vdp_mode_is_high_res,
	output				sp_mode_2,
	output				vdp_mode_is_vram_interleave,

	// switched i/o signals
	input				forced_v_mode,
	input		[4:0]	vdp_id
);
	reg				ff_ack;
	reg				ff_rdata_en;

	reg				vdp_p1_is_1st_byte;
	reg				vdp_p2_is_1st_byte;
	reg		[7:0]	vdp_p1_data;
	reg		[5:0]	vdp_reg_ptr;
	reg				vdpregwrpulse;
	reg		[3:0]	vdp_r15_status_reg_num;

	reg		[3:0]	vdp_r16_pal_num;
	reg		[5:0]	vdp_r17_reg_num;
	reg				vdp_r17_inc_reg_num;

	wire	[7:0]	palette_addr;
	wire			w_palette_we;
	reg		[2:0]	ff_palette_data_r;
	reg		[2:0]	ff_palette_data_g;
	reg		[2:0]	ff_palette_data_b;
	reg		[3:0]	ff_palette_address;
	reg				ff_palette_wr_req;
	reg				ff_palette_wr_ack;
	reg				ff_palette_we;
	reg		[6:0]	ff_r2_pt_nam_addr;
	reg				ff_r9_2page_mode;
	reg		[1:0]	reg_r1_disp_mode;
	reg				ff_r1_disp_on;
	reg		[1:0]	ff_r1_disp_mode;
	reg				ff_r25_sp2;
	reg		[8:3]	ff_r26_h_scroll;
	reg		[3:0]	reg_r18_vert;
	reg		[3:0]	reg_r18_horz;
	reg		[3:1]	reg_r0_disp_mode;
	reg		[3:1]	ff_r0_disp_mode;
	reg				ff_sp_vdp_s0_reset_req;

	wire			w_even_dotstate;
	wire			w_is_bitmap_mode;

	assign sp_vdp_s0_reset_req			= ff_sp_vdp_s0_reset_req;

	assign vdp_mode_graphic1			=	( { reg_r0_disp_mode, reg_r1_disp_mode[0], reg_r1_disp_mode[1] } == 5'b00000 ) ? 1'b1: 1'b0;
	assign vdp_mode_text1				=	( { reg_r0_disp_mode, reg_r1_disp_mode[0], reg_r1_disp_mode[1] } == 5'b00001 ) ? 1'b1: 1'b0;
	assign vdp_mode_multi				=	( { reg_r0_disp_mode, reg_r1_disp_mode[0], reg_r1_disp_mode[1] } == 5'b00010 ) ? 1'b1: 1'b0;
	assign vdp_mode_graphic2			=	( { reg_r0_disp_mode, reg_r1_disp_mode[0], reg_r1_disp_mode[1] } == 5'b00100 ) ? 1'b1: 1'b0;
	assign vdp_mode_text1q				=	( { reg_r0_disp_mode, reg_r1_disp_mode[0], reg_r1_disp_mode[1] } == 5'b00101 ) ? 1'b1: 1'b0;
	assign vdp_mode_multiq				=	( { reg_r0_disp_mode, reg_r1_disp_mode[0], reg_r1_disp_mode[1] } == 5'b00110 ) ? 1'b1: 1'b0;
	assign vdp_mode_graphic3			=	( { reg_r0_disp_mode, reg_r1_disp_mode[0], reg_r1_disp_mode[1] } == 5'b01000 ) ? 1'b1: 1'b0;
	assign vdp_mode_text2				=	( { reg_r0_disp_mode, reg_r1_disp_mode[0], reg_r1_disp_mode[1] } == 5'b01001 ) ? 1'b1: 1'b0;
	assign vdp_mode_graphic4			=	( { reg_r0_disp_mode, reg_r1_disp_mode[0], reg_r1_disp_mode[1] } == 5'b01100 ) ? 1'b1: 1'b0;
	assign vdp_mode_graphic5			=	( { reg_r0_disp_mode, reg_r1_disp_mode[0], reg_r1_disp_mode[1] } == 5'b10000 ) ? 1'b1: 1'b0;
	assign vdp_mode_graphic6			=	( { reg_r0_disp_mode, reg_r1_disp_mode[0], reg_r1_disp_mode[1] } == 5'b10100 ) ? 1'b1: 1'b0;
	assign vdp_mode_graphic7			=	( { reg_r0_disp_mode, reg_r1_disp_mode[0], reg_r1_disp_mode[1] } == 5'b11100 ) ? 1'b1: 1'b0;

	assign vdp_mode_is_high_res			=	( reg_r0_disp_mode[3:2] == 2'b10 && reg_r1_disp_mode == 2'b00 ) ? 1'b1: 1'b0;
	assign sp_mode_2					=	( reg_r1_disp_mode == 2'b00 && (reg_r0_disp_mode[3] || reg_r0_disp_mode[2]) ) ? 1'b1: 1'b0;

	assign vdp_mode_is_vram_interleave	=	( reg_r0_disp_mode[3] && reg_r0_disp_mode[1] ) ? 1'b1: 1'b0;

	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( reset ) begin
			ff_ack <= 1'b0;
			ff_rdata_en <= 1'b0;
		end
		else if( ff_ack ) begin
			ff_ack <= 1'b0;
			ff_rdata_en <= 1'b0;
		end
		else if( !enable ) begin
			//	hold
		end
		else if( wr_req || rd_req ) begin
			ff_ack <= 1'b1;
			ff_rdata_en <= rd_req;
		end
		else begin
			//	hold
		end
	end

	assign rdata_en		= ff_rdata_en;

	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( reset ) begin
			reg_r1_disp_on		<= 1'b0;
			reg_r0_disp_mode	<= 3'b000;
			reg_r1_disp_mode	<= 2'b00;
			reg_r25_sp2			<= 1'b0;
			reg_r26_h_scroll	<= 6'd0;
		end
		else if( !enable ) begin
			//	hold
		end
		else if( hsync ) begin
			reg_r1_disp_on		<= ff_r1_disp_on;
			reg_r0_disp_mode	<= ff_r0_disp_mode;
			reg_r1_disp_mode	<= ff_r1_disp_mode;
			if( vdp_id != 5'b00000 ) begin
				reg_r25_sp2			<= ff_r25_sp2;
				reg_r26_h_scroll	<= ff_r26_h_scroll;
			end
		end
	end

	// --------------------------------------------------------------------
	assign w_is_bitmap_mode		=	( reg_r0_disp_mode[3] || reg_r0_disp_mode == 3'b011 ) ? 1'b1: 1'b0;

	always @( posedge clk ) begin
		if( reset ) begin
			reg_r2_pattern_name <= 7'd0;
		end
		else if( !enable ) begin
			//	hold
		end
		else if( w_is_bitmap_mode && ff_r9_2page_mode ) begin
			reg_r2_pattern_name <= (ff_r2_pt_nam_addr & 7'b1011111) | { 1'b0, field, 5'b00000 };
		end
		else begin
			reg_r2_pattern_name <= ff_r2_pt_nam_addr;
		end
	end

	// --------------------------------------------------------------------
	assign w_even_dotstate	= ( dot_state == 2'b00 || dot_state == 2'b11 ) ? 1'b1: 1'b0;

	// --------------------------------------------------------------------
	// palette register
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( reset ) begin
			ff_palette_we <= 1'b0;
		end
		else if( !enable ) begin
			//	hold
		end
		else if( w_even_dotstate ) begin
			ff_palette_we <= 1'b0;
		end
		else begin
			if( ff_palette_wr_req != ff_palette_wr_ack ) begin
				ff_palette_we <= 1'b1;
			end
		end
	end

	always @( posedge clk ) begin
		if( reset ) begin
			ff_palette_wr_ack <= 1'b0;
		end
		else if( !enable ) begin
			//	hold
		end
		else if( !w_even_dotstate ) begin
			if( ff_palette_wr_req != ff_palette_wr_ack ) begin
				ff_palette_wr_ack <= ~ff_palette_wr_ack;
			end
		end
	end

	assign palette_address		= { 4'd0, ff_palette_address };
	assign palette_we			= ff_palette_we;
	assign palette_wdata_r		= { ff_palette_data_r, 2'b0 };
	assign palette_wdata_g		= { ff_palette_data_g, 2'b0 };
	assign palette_wdata_b		= { ff_palette_data_b, 2'b0 };

	// --------------------------------------------------------------------
	// process of cpu read request
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( reset ) begin
			rdata <= 8'h00;
		end
		else if( !enable ) begin
			//	hold
		end
		else if( rd_req && !ff_ack ) begin
			// read request
			case( address[1:0] )
			2'b00: // port#0 (0x98):read vram
				rdata <= vdp_vram_rd_data;
			2'b01: // port#1 (0x99):read status register
				case( vdp_r15_status_reg_num )
				4'b0000: // read s#0
					rdata <= { (~req_vsync_int_n), vdp_s0_sp_overmapped, vdp_s0_sp_collision_incidence, vdp_s0_sp_overmapped_num };
				4'b0001: // read s#1
					rdata <= { 2'b00, vdp_id, (~req_hsync_int_n) };
				4'b0010: // read s#2
					rdata <= { vdp_cmd_tr, vd, hd, vdp_cmd_bd, 2'b11, field, vdp_cmd_ce };
				4'b0011: // read s#3
					rdata <= vdp_s3_s4_sp_collision_x[7:0];
				4'b0100: // read s#4
					rdata <= { 7'b0000000, vdp_s3_s4_sp_collision_x[8] };
				4'b0101: // read s#5
					rdata <= vdp_s5_s6_sp_collision_y[7:0];
				4'b0110: // read s#6
					rdata <= { 7'b0000000, vdp_s5_s6_sp_collision_y[8] };
				4'b0111: // read s#7:the color register
					rdata <= vdp_cmd_clr;
				4'b1000: // read s#8:sxtmp lsb
					rdata <= vdp_cmd_sx_tmp[7:0];
				4'b1001: // read s#9:sxtmp msb
					rdata <= { 7'b1111111, vdp_cmd_sx_tmp[8] };
				default:
					rdata <= 8'h00;
				endcase
			default: // port#2, #3:not supported in read mode
				rdata <= 8'hFF;
			endcase
		end
	end

	// --------------------------------------------------------------------
	// hsync interrupt reset control
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( reset ) begin
			clr_hsync_int <= 1'b0;
		end
		else if( !enable ) begin
			//	hold
		end
		else if( rd_req && !ff_ack ) begin
			// case of read request
			if( address[1:0] == 2'b01 && vdp_r15_status_reg_num == 4'b0001 ) begin
				// clear hsync interrupt by read s#1
				clr_hsync_int <= 1'b1;
			end
			else begin
				clr_hsync_int <= 1'b0;
			end
		end
		else if( vdpregwrpulse ) begin
			if( vdp_reg_ptr == 6'b010011 || (vdp_reg_ptr == 6'b000000 && vdp_p1_data[4] == 1'b1) ) begin
				// clear hsync interrupt by write r19, r0
				clr_hsync_int <= 1'b1;
			end
			else begin
				clr_hsync_int <= 1'b0;
			end
		end
		else begin
			clr_hsync_int <= 1'b0;
		end
	end

	// --------------------------------------------------------------------
	// vsync interrupt reset control
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( reset ) begin
			clr_vsync_int <= 1'b0;
		end
		else if( !enable ) begin
			//	hold
		end
		else if( rd_req && !ff_ack ) begin
			// case of read request
			if( address[1:0] == 2'b01 && vdp_r15_status_reg_num == 4'b0000 ) begin
				// clear vsync interrupt by read s#0
				clr_vsync_int <= 1'b1;
			end
			else begin
				clr_vsync_int <= 1'b0;
			end
		end
		else begin
			clr_vsync_int <= 1'b0;
		end
	end

	assign reg_r18_adj		= { reg_r18_vert, reg_r18_horz };

	// --------------------------------------------------------------------
	// process of cpu write request
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( reset ) begin
			vdp_p1_data					<= 'd0;
			vdp_p1_is_1st_byte			<= 1'b1;
			vdp_p2_is_1st_byte			<= 1'b1;
			vdpregwrpulse				<= 1'b0;
			vdp_reg_ptr					<= 'd0;
			vdp_vram_wr_req				<= 1'b0;
			vdp_vram_rd_req				<= 1'b0;
			vdp_vram_addr_set_req		<= 1'b0;
			vdp_vram_address_cpu	<= 'd0;
			vdp_vram_wdata_cpu		<= 'd0;
			ff_r0_disp_mode				<= 'd0;

			reg_r0_hsync_int_en			<= 1'b0;
			ff_r1_disp_mode				<= 'd0;
			reg_r1_sp_size				<= 1'b0;
			reg_r1_sp_zoom				<= 1'b0;
			reg_r1_bl_clks				<= 1'b0;
			reg_r1_vsync_int_en			<= 1'b0;
			ff_r1_disp_on				<= 1'b0;
			ff_r2_pt_nam_addr			<= 'd0;
			reg_r4_pattern_generator	<= 'd0;
			reg_r12_blink_mode			<= 'd0;
			reg_r13_blink_period		<= 'd0;
			reg_r6_sp_gen_addr			<= 'd0;
			reg_r7_frame_col			<= 'd0;
			reg_r8_sp_off				<= 1'b0;
			reg_r8_col0_on				<= 1'b0;
			reg_r9_pal_mode				<= forced_v_mode;
			ff_r9_2page_mode			<= 1'b0;
			reg_r9_interlace_mode		<= 1'b0;
			reg_r9_y_dots				<= 1'b0;
			reg_r10r3_color				<= 'd0;
			reg_r11r5_sp_atr_addr		<= 'd0;
			vdp_r15_status_reg_num		<= 'd0;
			vdp_r16_pal_num				<= 4'd0;
			vdp_r17_reg_num				<= 6'd0;
			vdp_r17_inc_reg_num			<= 1'b0;
			reg_r18_vert				<= 'd0;
			reg_r18_horz				<= 'd0;
			reg_r19_hsync_int_line		<= 'd0;
			reg_r23_vstart_line			<= 'd0;
			reg_r25_cmd					<= 1'b0;
			reg_r25_yae					<= 1'b0;
			reg_r25_yjk					<= 1'b0;
			reg_r25_msk					<= 1'b0;
			ff_r25_sp2					<= 1'b0;
			ff_r26_h_scroll				<= 'd0;
			reg_r27_h_scroll			<= 'd0;
			vdp_cmd_reg_num				<= 'd0;
			vdp_cmd_reg_data			<= 'd0;
			vdp_cmd_reg_wr_req			<= 1'b0;
			vdp_cmd_tr_clr_req			<= 1'b0;
			ff_sp_vdp_s0_reset_req		<= 1'b0;
			sp_vdp_s5_reset_req			<= 1'b0;

			// palette
			ff_palette_data_r			<= 3'd0;
			ff_palette_data_b			<= 3'd0;
			ff_palette_data_g			<= 3'd0;
			ff_palette_wr_req			<= 1'b0;
			ff_palette_address			<= 'd0;
		end
		else if( !enable ) begin
			//	hold
		end
		else if( rd_req && !ff_ack ) begin
			// read request
			case( address[1:0] )
			2'b00: // port#0 (0x98):read vram
				vdp_vram_rd_req	<= ~vdp_vram_rd_ack;
			2'b01: // port#1 (0x99):read status register
				begin
					vdp_p1_is_1st_byte	<= 1'b1;
					case( vdp_r15_status_reg_num )
					4'b0000: // read s#0
						ff_sp_vdp_s0_reset_req		<= ~sp_vdp_s0_reset_ack;
					4'b0101: // read s#5
						sp_vdp_s5_reset_req		<= ~sp_vdp_s5_reset_ack;
					4'b0111: // read s#7:the color register
						vdp_cmd_tr_clr_req		<= ~vdp_cmd_tr_clr_ack;
					default:
						begin
							//	hold
						end
					endcase
				end
			default: // port#3:not supported in read mode
				begin
					//	hold
				end
			endcase
		end
		else if( wr_req && !ff_ack ) begin
			// write request
			case( address[1:0] )
			2'b00: // port#0 (0x98):write vram
				begin
					vdp_vram_wdata_cpu	<= wdata;
					vdp_vram_wr_req		<= ~vdp_vram_wr_ack;
				end
			2'b01: // port#1 (0x99):register write or vram addr setup
				begin
					if( vdp_p1_is_1st_byte ) begin
						// it is the first byte; buffer it
						vdp_p1_is_1st_byte	<= 1'b0;
						vdp_p1_data			<= wdata;
					end
					else begin
						// it is the second byte; process both bytes
						vdp_p1_is_1st_byte <= 1'b1;
						case( wdata[7:6] )
						2'b01:	// set vram access address(write)
							begin
								vdp_vram_address_cpu[7:0]	<= vdp_p1_data[7:0];
								vdp_vram_address_cpu[13:8]	<= wdata[5:0];
								vdp_vram_addr_set_req			<= ~vdp_vram_addr_set_ack;
							end
						2'b00:	// set vram access address(read)
							begin
								vdp_vram_address_cpu[7:0]	<= vdp_p1_data[7:0];
								vdp_vram_address_cpu[13:8]	<= wdata[5:0];
								vdp_vram_addr_set_req			<= ~vdp_vram_addr_set_ack;
								vdp_vram_rd_req					<= ~vdp_vram_rd_ack;
							end
						2'b10:	// direct register selection
							begin
								vdp_reg_ptr			<= wdata[5:0];
								vdpregwrpulse		<= 1'b1;
							end
						2'b11:	// direct register selection ??
							begin
								vdp_reg_ptr			<= wdata[5:0];
								vdpregwrpulse		<= 1'b1;
							end
						default:
							begin
								//	hold
							end
						endcase
					end
				end
			2'b10:	// port#2:palette write
				begin
					if( vdp_p2_is_1st_byte ) begin
						ff_palette_data_r			<= wdata[6:4];
						ff_palette_data_b			<= wdata[2:0];
						vdp_p2_is_1st_byte			<= 1'b0;
					end
					else begin
						// パレットはrgbのデータが揃った時に一度に書き換える。
						// (実機で動作を確認した)
						ff_palette_data_g			<= wdata[2:0];
						ff_palette_address			<= vdp_r16_pal_num;
						ff_palette_wr_req			<= ~ff_palette_wr_ack;
						vdp_p2_is_1st_byte			<= 1'b1;
						vdp_r16_pal_num				<= vdp_r16_pal_num + 4'd1;
					end
				end
			2'b11:	// port#3:indirect register write
				begin
					if( vdp_r17_reg_num != 6'b010001 ) begin
						// register 17 can not be modified. all others are ok
						vdpregwrpulse <= 1'b1;
					end
					vdp_p1_data <= wdata;
					vdp_reg_ptr <= vdp_r17_reg_num;
					if( vdp_r17_inc_reg_num ) begin
						vdp_r17_reg_num <= vdp_r17_reg_num + 6'd1;
					end
				end
			default:
				begin
					//	hold
				end
			endcase
		end
		else if( vdpregwrpulse ) begin
			// write to register (if previously requested)
			vdpregwrpulse <= 1'b0;
			if( !vdp_reg_ptr[5] ) begin
				// it is a not a command engine register:
				case( vdp_reg_ptr[4:0] )
				5'b00000:		// #00
					begin
						ff_r0_disp_mode			<= vdp_p1_data[3:1];
						reg_r0_hsync_int_en		<= vdp_p1_data[4];
					end
				5'b00001:		// #01
					begin
						reg_r1_sp_zoom			<= vdp_p1_data[0];
						reg_r1_sp_size			<= vdp_p1_data[1];
						reg_r1_bl_clks			<= vdp_p1_data[2];
						ff_r1_disp_mode			<= vdp_p1_data[4:3];
						reg_r1_vsync_int_en		<= vdp_p1_data[5];
						ff_r1_disp_on			<= vdp_p1_data[6];
					end
				5'b00010:		// #02
					ff_r2_pt_nam_addr			<= vdp_p1_data[6:0];
				5'b00011:		// #03
					reg_r10r3_color[7:0]		<= vdp_p1_data[7:0];
				5'b00100:		// #04
					reg_r4_pattern_generator	<= vdp_p1_data[5:0];
				5'b00101:		// #05
					reg_r11r5_sp_atr_addr[7:0]	<= vdp_p1_data;
				5'b00110:		// #06
					reg_r6_sp_gen_addr			<= vdp_p1_data[5:0];
				5'b00111:		// #07
					reg_r7_frame_col			<= vdp_p1_data[7:0];
				5'b01000:		// #08
					begin
						reg_r8_sp_off			<= vdp_p1_data[1];
						reg_r8_col0_on			<= vdp_p1_data[5];
					end
				5'b01001:		// #09
					begin
						reg_r9_pal_mode			<= vdp_p1_data[1];
						ff_r9_2page_mode		<= vdp_p1_data[2];
						reg_r9_interlace_mode	<= vdp_p1_data[3];
						reg_r9_y_dots			<= vdp_p1_data[7];
					end
				5'b01010:		// #10
					reg_r10r3_color[10:8]	<= vdp_p1_data[2:0];
				5'b01011:		// #11
					reg_r11r5_sp_atr_addr[9:8]	<= vdp_p1_data[1:0];
				5'b01100:		// #12
					reg_r12_blink_mode			<= vdp_p1_data;
				5'b01101:		// #13
					reg_r13_blink_period		<= vdp_p1_data;
				5'b01110:		// #14
					begin
						vdp_vram_address_cpu[16:14]	<= vdp_p1_data[2:0];
						vdp_vram_addr_set_req			<= ~vdp_vram_addr_set_ack;
					end
				5'b01111:		// #15
					vdp_r15_status_reg_num		<= vdp_p1_data[3:0];
				5'b10000:		// #16
					begin
						vdp_r16_pal_num			<= vdp_p1_data[3:0];
						vdp_p2_is_1st_byte		<= 1'b1;
					end
				5'b10001:		// #17
					begin
						vdp_r17_reg_num			<= vdp_p1_data[5:0];
						vdp_r17_inc_reg_num		<= ~vdp_p1_data[7];
					end
				5'b10010:		// #18
					begin
						reg_r18_vert			<= vdp_p1_data[7:4];
						reg_r18_horz			<= vdp_p1_data[3:0];
					end
				5'b10011:		// #19
					reg_r19_hsync_int_line		<= vdp_p1_data;
				5'b10111:		// #23
					reg_r23_vstart_line			<= vdp_p1_data;
				5'b11001:		// #25
					begin
						reg_r25_cmd				<= vdp_p1_data[6];
						reg_r25_yae				<= vdp_p1_data[4];
						reg_r25_yjk				<= vdp_p1_data[3];
						reg_r25_msk				<= vdp_p1_data[1];
						ff_r25_sp2				<= vdp_p1_data[0];
					end
				5'b11010:		// #26
					begin
						ff_r26_h_scroll			<= vdp_p1_data[5:0];
					end
				5'b11011:		// #27
					begin
						reg_r27_h_scroll		<= vdp_p1_data[2:0];
					end
				default:
					begin
						//	hold
					end
				endcase
			end
			else if( !vdp_reg_ptr[4] ) begin
				// registers for vdp command
				vdp_cmd_reg_num					<= vdp_reg_ptr[3:0];
				vdp_cmd_reg_data				<= vdp_p1_data;
				vdp_cmd_reg_wr_req				<= ~vdp_cmd_reg_wr_ack;
			end
		end
	end
endmodule
