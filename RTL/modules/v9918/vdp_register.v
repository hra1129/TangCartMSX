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
	input				address,
	output reg	[7:0]	rdata,
	output				rdata_en,
	input		[7:0]	wdata,

	input		[1:0]	dot_state,

	input				hsync,

	input				vdp_s0_sp_collision_incidence,
	input				vdp_s0_sp_overmapped,
	input		[4:0]	vdp_s0_sp_overmapped_num,
	output				sp_vdp_s0_reset_req,
	input				sp_vdp_s0_reset_ack,

	input				vd,							// s#2
	input				hd,							// s#2
	input				field,						// s#2

	output reg	[7:0]	vdp_vram_wdata_cpu,
	output reg	[13:0]	vdp_vram_address_cpu,
	output reg			vdp_vram_addr_set_req,
	input				vdp_vram_addr_set_ack,
	output reg			vdp_vram_wr_req,
	input				vdp_vram_wr_ack,
	input		[7:0]	vdp_vram_rd_data,
	output reg			vdp_vram_rd_req,
	input				vdp_vram_rd_ack,

	// interrupt
	output reg			clr_vsync_int,
	input				req_vsync_int_n,

	// register value
	output reg			reg_r0_hsync_int_en,
	output reg			reg_r1_sp_size,
	output reg			reg_r1_sp_zoom,
	output reg			reg_r1_bl_clks,
	output reg			reg_r1_vsync_int_en,
	output reg			reg_r1_disp_on,
	output reg	[3:0]	reg_r2_pattern_name,
	output reg	[2:0]	reg_r4_pattern_generator,
	output reg	[7:0]	reg_r3_color,
	output reg	[6:0]	reg_r5_sp_atr_addr,
	output reg	[2:0]	reg_r6_sp_gen_addr,
	output reg	[7:0]	reg_r7_frame_col,

	//	mode
	output				vdp_mode_text1,
	output				vdp_mode_text1q,
	output				vdp_mode_multi,
	output				vdp_mode_multiq,
	output				vdp_mode_graphic1,
	output				vdp_mode_graphic2
);
	reg				ff_rdata_en;
	reg				ff_wr_req;
	reg				ff_rd_req;

	reg				vdp_p1_is_1st_byte;
	reg				vdp_p2_is_1st_byte;
	reg		[7:0]	vdp_p1_data;
	reg		[2:0]	vdp_reg_ptr;
	reg				vdpregwrpulse;

	reg		[3:0]	ff_r2_pt_nam_addr;
	reg		[1:0]	reg_r1_disp_mode;
	reg				ff_r1_disp_on;
	reg		[1:0]	ff_r1_disp_mode;
	reg		[3:1]	reg_r0_disp_mode;
	reg		[3:1]	ff_r0_disp_mode;
	reg				ff_sp_vdp_s0_reset_req;

	wire			w_even_dotstate;

	assign sp_vdp_s0_reset_req			= ff_sp_vdp_s0_reset_req;

	assign vdp_mode_graphic1			=	( { reg_r0_disp_mode, reg_r1_disp_mode[0], reg_r1_disp_mode[1] } == 5'b00000 ) ? 1'b1: 1'b0;
	assign vdp_mode_text1				=	( { reg_r0_disp_mode, reg_r1_disp_mode[0], reg_r1_disp_mode[1] } == 5'b00001 ) ? 1'b1: 1'b0;
	assign vdp_mode_multi				=	( { reg_r0_disp_mode, reg_r1_disp_mode[0], reg_r1_disp_mode[1] } == 5'b00010 ) ? 1'b1: 1'b0;
	assign vdp_mode_graphic2			=	( { reg_r0_disp_mode, reg_r1_disp_mode[0], reg_r1_disp_mode[1] } == 5'b00100 ) ? 1'b1: 1'b0;
	assign vdp_mode_text1q				=	( { reg_r0_disp_mode, reg_r1_disp_mode[0], reg_r1_disp_mode[1] } == 5'b00101 ) ? 1'b1: 1'b0;
	assign vdp_mode_multiq				=	( { reg_r0_disp_mode, reg_r1_disp_mode[0], reg_r1_disp_mode[1] } == 5'b00110 ) ? 1'b1: 1'b0;

	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( reset ) begin
			ff_rdata_en <= 1'b0;
		end
		else if( ff_rdata_en && enable ) begin
			ff_rdata_en <= 1'b0;
		end
		else if( !ff_rd_req && rd_req ) begin
			ff_rdata_en <= rd_req;
		end
		else begin
			//	hold
		end
	end

	assign rdata_en		= ff_rdata_en;

	always @( posedge clk ) begin
		if( reset ) begin
			ff_wr_req <= 1'b0;
			ff_rd_req <= 1'b0;
		end
		else begin
			ff_wr_req <= wr_req;
			ff_rd_req <= rd_req;
		end
	end

	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( reset ) begin
			reg_r1_disp_on		<= 1'b0;
			reg_r0_disp_mode	<= 3'b000;
			reg_r1_disp_mode	<= 2'b00;
		end
		else if( !enable ) begin
			//	hold
		end
		else if( hsync ) begin
			reg_r1_disp_on		<= ff_r1_disp_on;
			reg_r0_disp_mode	<= ff_r0_disp_mode;
			reg_r1_disp_mode	<= ff_r1_disp_mode;
		end
	end

	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( reset ) begin
			reg_r2_pattern_name <= 4'd0;
		end
		else if( !enable ) begin
			//	hold
		end
		else begin
			reg_r2_pattern_name <= ff_r2_pt_nam_addr;
		end
	end

	// --------------------------------------------------------------------
	assign w_even_dotstate	= ( dot_state == 2'b00 || dot_state == 2'b11 ) ? 1'b1: 1'b0;

	// --------------------------------------------------------------------
	// process of cpu read request
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( reset ) begin
			rdata <= 8'h00;
		end
		else if( !ff_rd_req && rd_req ) begin
			// read request
			if( !address ) begin
				// port#0 (0x98):read vram
				rdata <= vdp_vram_rd_data;
			end
			else begin
				// port#1 (0x99):read status register
				rdata <= { (~req_vsync_int_n), vdp_s0_sp_overmapped, vdp_s0_sp_collision_incidence, vdp_s0_sp_overmapped_num };
			end
		end
	end

	// --------------------------------------------------------------------
	// vsync interrupt reset control
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( reset ) begin
			clr_vsync_int <= 1'b0;
		end
		else if( !ff_rd_req && rd_req ) begin
			// case of read request
			if( address ) begin
				// clear vsync interrupt by read s#0
				clr_vsync_int <= 1'b1;
			end
			else if( !enable ) begin
				//	hold
			end
			else begin
				clr_vsync_int <= 1'b0;
			end
		end
		else if( !enable ) begin
			//	hold
		end
		else begin
			clr_vsync_int <= 1'b0;
		end
	end

	// --------------------------------------------------------------------
	// process of cpu write request
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( reset ) begin
			vdp_p1_data					<= 'd0;
			vdp_p1_is_1st_byte			<= 1'b1;
			vdp_p2_is_1st_byte			<= 1'b1;
			vdpregwrpulse				<= 1'b0;
			vdp_reg_ptr					<= 3'd0;
			vdp_vram_wr_req				<= 1'b0;
			vdp_vram_rd_req				<= 1'b0;
			vdp_vram_addr_set_req		<= 1'b0;
			vdp_vram_address_cpu		<= 'd0;
			vdp_vram_wdata_cpu			<= 'd0;
			ff_r0_disp_mode				<= 'd0;

			reg_r0_hsync_int_en			<= 1'b0;
			ff_r1_disp_mode				<= 'd0;
			reg_r1_sp_size				<= 1'b0;
			reg_r1_sp_zoom				<= 1'b0;
			reg_r1_bl_clks				<= 1'b0;
			reg_r1_vsync_int_en			<= 1'b0;
			ff_r1_disp_on				<= 1'b0;
			ff_r2_pt_nam_addr			<= 4'd0;
			reg_r4_pattern_generator	<= 3'd0;
			reg_r6_sp_gen_addr			<= 3'd0;
			reg_r7_frame_col			<= 8'd0;
			reg_r3_color				<= 8'd0;
			reg_r5_sp_atr_addr			<= 7'd0;
			ff_sp_vdp_s0_reset_req		<= 1'b0;
		end
		else if( !ff_rd_req && rd_req ) begin
			// read request
			if( !address ) begin
				// port#0 (0x98):read vram
				vdp_vram_rd_req	<= ~vdp_vram_rd_ack;
			end
			begin
				// port#1 (0x99):read status register
				vdp_p1_is_1st_byte		<= 1'b1;
				ff_sp_vdp_s0_reset_req	<= ~sp_vdp_s0_reset_ack;
			end
		end
		else if( ff_wr_req && !wr_req ) begin
			// write request
			if( !address ) begin
				vdp_vram_wdata_cpu	<= wdata;
				vdp_vram_wr_req		<= ~vdp_vram_wr_ack;
			end
			else begin
				// port#1 (0x99):register write or vram addr setup
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
							vdp_vram_addr_set_req		<= ~vdp_vram_addr_set_ack;
						end
					2'b00:	// set vram access address(read)
						begin
							vdp_vram_address_cpu[7:0]	<= vdp_p1_data[7:0];
							vdp_vram_address_cpu[13:8]	<= wdata[5:0];
							vdp_vram_addr_set_req		<= ~vdp_vram_addr_set_ack;
							vdp_vram_rd_req				<= ~vdp_vram_rd_ack;
						end
					2'b10:	// direct register selection
						begin
							vdp_reg_ptr			<= wdata[2:0];
							vdpregwrpulse		<= 1'b1;
						end
					2'b11:	// direct register selection ??
						begin
							vdp_reg_ptr			<= wdata[2:0];
							vdpregwrpulse		<= 1'b1;
						end
					default:
						begin
							//	hold
						end
					endcase
				end
			end
		end
		else if( vdpregwrpulse ) begin
			// write to register (if previously requested)
			vdpregwrpulse <= 1'b0;
			// it is a not a command engine register:
			case( vdp_reg_ptr )
			3'b000:		// #00
				begin
					ff_r0_disp_mode			<= vdp_p1_data[3:1];
					reg_r0_hsync_int_en		<= vdp_p1_data[4];
				end
			3'b001:		// #01
				begin
					reg_r1_sp_zoom			<= vdp_p1_data[0];
					reg_r1_sp_size			<= vdp_p1_data[1];
					reg_r1_bl_clks			<= vdp_p1_data[2];
					ff_r1_disp_mode			<= vdp_p1_data[4:3];
					reg_r1_vsync_int_en		<= vdp_p1_data[5];
					ff_r1_disp_on			<= vdp_p1_data[6];
				end
			3'b010:		// #02
				ff_r2_pt_nam_addr			<= vdp_p1_data[3:0];
			3'b011:		// #03
				reg_r3_color				<= vdp_p1_data;
			3'b100:		// #04
				reg_r4_pattern_generator	<= vdp_p1_data[2:0];
			3'b101:		// #05
				reg_r5_sp_atr_addr			<= vdp_p1_data[6:0];
			3'b110:		// #06
				reg_r6_sp_gen_addr			<= vdp_p1_data[2:0];
			3'b111:		// #07
				reg_r7_frame_col			<= vdp_p1_data[7:0];
			default:
				begin
					//	hold
				end
			endcase
		end
	end
endmodule
