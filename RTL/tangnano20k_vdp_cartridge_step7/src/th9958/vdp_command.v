//
//	vdp_command.v
//
//	Copyright (C) 2025 Takayuki Hara
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

module vdp_command (
	input				reset_n,
	input				clk,
	//	VRAM interface
	output		[17:0]	command_vram_address,
	output				command_vram_valid,
	input				command_vram_ready,
	output				command_vram_write,
	output		[31:0]	command_vram_wdata,
	output		[3:0]	command_vram_wdata_mask,
	input		[31:0]	command_vram_rdata,
	input				command_vram_rdata_en,
	//	CPU interface
	input				register_write,
	input		[5:0]	register_num,
	input		[7:0]	register_data,
	input				clear_border_detect,
	input				read_color,
	output				status_command_execute,			//	S#2 bit0
	output				status_border_detect,			//	S#2 bit4
	output				status_transfer_ready,			//	S#2 bit7
	output		[7:0]	status_color,					//	S#7
	output		[8:0]	status_border_position,			//	S#8, S#9
	//	Screen mode
	input		[3:0]	screen_mode,
	input				vram_interleave,
	input		[7:0]	reg_text_back_color,
	input				reg_command_enable,
	input				reg_command_high_speed_mode,
	input				reg_ext_command_mode,
	input				reg_vram256k_mode,
	output				intr_command_end
);
	localparam	c_hmmc		= 4'b1111;
	localparam	c_ymmm		= 4'b1110;
	localparam	c_hmmm		= 4'b1101;
	localparam	c_hmmv		= 4'b1100;
	localparam	c_lmmc		= 4'b1011;
	localparam	c_lmcm		= 4'b1010;
	localparam	c_lmmm		= 4'b1001;
	localparam	c_lmmv		= 4'b1000;
	localparam	c_line		= 4'b0111;
	localparam	c_srch		= 4'b0110;
	localparam	c_pset		= 4'b0101;
	localparam	c_point		= 4'b0100;
	localparam	c_lrmm		= 4'b0011;
	localparam	c_lfmc		= 4'b0010;
	localparam	c_lfmm		= 4'b0001;
	localparam	c_stop		= 4'b0000;

	localparam	c_wait_hmmc	= 6'd40;
	localparam	c_wait_ymmm	= 6'd40;
	localparam	c_wait_hmmm	= 6'd40;
	localparam	c_wait_hmmv	= 6'd40;
	localparam	c_wait_lmmc	= 6'd40;
	localparam	c_wait_lmcm	= 6'd40;
	localparam	c_wait_lmmm	= 6'd40;
	localparam	c_wait_lmmv	= 6'd40;
	localparam	c_wait_line	= 6'd40;
	localparam	c_wait_srch	= 6'd40;
	localparam	c_wait_pset	= 6'd40;
	localparam	c_wait_point= 6'd40;

	localparam	c_imp		= 4'b0000;
	localparam	c_and		= 4'b0001;
	localparam	c_or		= 4'b0010;
	localparam	c_eor		= 4'b0011;
	localparam	c_not		= 4'b0100;
	localparam	c_rsv1		= 4'b0101;
	localparam	c_rsv2		= 4'b0110;
	localparam	c_rsv3		= 4'b0111;
	localparam	c_timp		= 4'b1000;
	localparam	c_tand		= 4'b1001;
	localparam	c_tor		= 4'b1010;
	localparam	c_teor		= 4'b1011;
	localparam	c_tnot		= 4'b1100;
	localparam	c_trsv1		= 4'b1101;
	localparam	c_trsv2		= 4'b1110;
	localparam	c_trsv3		= 4'b1111;

	//	screen_mode code
	localparam	c_g1		= 0;			//	Graphic1 (SCREEN1) w_mode index
	localparam	c_g2		= 1;			//	Graphic2 (SCREEN2) w_mode index
	localparam	c_g3		= 2;			//	Graphic3 (SCREEN4) w_mode index
	localparam	c_g4		= 3;			//	Graphic4 (SCREEN5) w_mode index
	localparam	c_g5		= 4;			//	Graphic5 (SCREEN6) w_mode index
	localparam	c_g6		= 5;			//	Graphic6 (SCREEN7) w_mode index
	localparam	c_g7		= 6;			//	Graphic7 (SCREEN8) w_mode index
	localparam	c_t1		= 7;			//	Text1    (SCREEN0:WIDTH40) w_mode index
	localparam	c_t2		= 8;			//	Text2    (SCREEN0:WIDTH80) w_mode index
	localparam	c_gm		= 9;			//	Mosaic   (SCREEN3) w_mode index

	localparam	c_bpp_2bit	= 0;
	localparam	c_bpp_4bit	= 1;
	localparam	c_bpp_8bit	= 2;

	reg					ff_command_execute;
	reg			[7:0]	ff_read_pixel;
	reg			[7:0]	ff_read_byte;
	reg			[7:0]	ff_source;
	wire		[7:0]	w_destination;
	wire		[7:0]	w_lop_pixel;

	reg			[1:0]	ff_xsel;
	reg			[11:0]	reg_sx;
	reg			[8:0]	reg_dx;
	reg			[10:0]	reg_nx;
	reg			[19:0]	ff_sx;
	reg			[20:0]	ff_sy;
	reg			[19:0]	ff_sx2;
	reg			[20:0]	ff_sy2;
	reg			[8:0]	ff_dx;
	reg			[10:0]	ff_dy;
	reg			[10:0]	ff_nx;
	reg			[10:0]	ff_ny;
	reg			[15:0]	reg_vx;
	reg			[15:0]	reg_vy;
	reg			[8:0]	reg_wsx;
	reg			[10:0]	reg_wsy;
	reg			[8:0]	reg_wex;
	reg			[10:0]	reg_wey;
	wire		[10:0]	w_nx;
	wire		[10:0]	w_ny;
	reg			[11:0]	ff_nyb;
	reg			[7:0]	ff_color;
	reg					ff_transfer_ready;
	reg					ff_maj;
	reg					ff_eq;
	reg					ff_dix;
	reg					ff_diy;
	reg					ff_mxs;
	reg					ff_mxd;
	reg					ff_xhr;
	reg					ff_fg4;
	reg			[3:0]	ff_logical_opration;
	reg			[3:0]	ff_command;
	reg					ff_start;

	reg			[17:0]	ff_cache_vram_address;
	reg					ff_cache_vram_valid;
	wire				w_cache_vram_ready;
	reg					ff_cache_vram_write;
	reg			[7:0]	ff_cache_vram_wdata;
	wire		[7:0]	w_cache_vram_rdata;
	wire				w_cache_vram_rdata_en;
	reg					ff_cache_flush_start;
	wire				w_cache_flush_end;
	wire				w_effective_mode;
	wire		[1:0]	w_bpp;					//	c_bpp_Xbit
	wire				w_512pixel;
	wire		[17:0]	w_address_s_pre;
	wire		[17:0]	w_address_d_pre;
	wire		[17:0]	w_address_s;
	wire		[17:0]	w_address_d;
	wire		[12:0]	w_next_nyb;
	wire		[9:0]	w_next;
	wire		[11:0]	w_next_sx;
	wire		[13:0]	w_next_sy;
	wire		[9:0]	w_next_dx;
	wire		[11:0]	w_next_dy;
	wire				w_line_shift;
	reg					ff_border_detect_request;
	reg					ff_border_detect;
	reg					ff_read_color;
	wire				w_sx_overflow;
	wire				w_dx_overflow;
	reg			[2:0]	ff_bit_count;
	reg			[7:0]	ff_fore_color;
	reg			[17:0]	ff_font_address;
    reg         [7:0]   ff_bit_pattern;

	localparam			c_state_idle				= 6'd0;
	localparam			c_state_stop				= 6'd1;
	localparam			c_state_point				= 6'd2;
	localparam			c_state_pset				= 6'd3;
	localparam			c_state_srch				= 6'd4;
	localparam			c_state_line				= 6'd5;
	localparam			c_state_lmmv				= 6'd6;
	localparam			c_state_lmmm				= 6'd7;
	localparam			c_state_lmcm				= 6'd8;
	localparam			c_state_lmmc				= 6'd9;
	localparam			c_state_hmmv				= 6'd10;
	localparam			c_state_hmmm				= 6'd11;
	localparam			c_state_ymmm				= 6'd12;
	localparam			c_state_hmmc				= 6'd13;
	localparam			c_state_lrmm				= 6'd14;
	localparam			c_state_lfmc				= 6'd15;
	localparam			c_state_lfmm				= 6'd16;
	localparam			c_state_pset_make			= 6'd17;
	localparam			c_state_line_make			= 6'd18;
	localparam			c_state_line_next			= 6'd19;
	localparam			c_state_lmmv_make			= 6'd20;
	localparam			c_state_lmmv_next			= 6'd21;
	localparam			c_state_lmmm_wait_source	= 6'd22;
	localparam			c_state_lmmm_make			= 6'd23;
	localparam			c_state_lmmm_next			= 6'd24;
	localparam			c_state_hmmv_next			= 6'd25;
	localparam			c_state_hmmm_make			= 6'd26;
	localparam			c_state_hmmm_next			= 6'd27;
	localparam			c_state_ymmm_make			= 6'd28;
	localparam			c_state_ymmm_next			= 6'd29;
	localparam			c_state_srch_compare		= 6'd30;
	localparam			c_state_srch_next			= 6'd31;
	localparam			c_state_hmmc_next			= 6'd32;
	localparam			c_state_lmmc_make			= 6'd33;
	localparam			c_state_lmmc_next			= 6'd34;
	localparam			c_state_lmcm_make			= 6'd35;
	localparam			c_state_lmcm_next			= 6'd36;
	localparam			c_state_lrmm_wait_source	= 6'd37;
	localparam			c_state_lrmm_make			= 6'd38;
	localparam			c_state_lrmm_next			= 6'd39;
	localparam			c_state_lfmc_read			= 6'd40;
	localparam			c_state_lfmc_make			= 6'd41;
	localparam			c_state_lfmc_next			= 6'd42;
	localparam			c_state_lfmm_load_source	= 6'd43;
	localparam			c_state_lfmm_read			= 6'd44;
	localparam			c_state_lfmm_make			= 6'd45;
	localparam			c_state_lfmm_next			= 6'd46;
	localparam			c_state_wait_rdata_en		= 6'd60;
	localparam			c_state_wait_counter		= 6'd61;
	localparam			c_state_pre_finish			= 6'd62;
	localparam			c_state_finish				= 6'd63;
	reg			[5:0]	ff_state;
	reg			[5:0]	ff_next_state;
	reg					ff_count_valid;
	reg			[7:0]	ff_wait_counter;
	reg			[5:0]	ff_wait_count;
	reg					ff_command_end;

	// --------------------------------------------------------------------
	//	Mode select
	// --------------------------------------------------------------------
	assign w_effective_mode		= reg_command_enable || ff_fg4 || (screen_mode == c_g4 || screen_mode == c_g5 || screen_mode == c_g6 || screen_mode == c_g7);
	assign w_bpp				= (screen_mode == c_g7) ? c_bpp_8bit:
	            				  (screen_mode == c_g5) ? c_bpp_2bit: c_bpp_4bit;
	assign w_next				= (screen_mode == c_g7 || ff_command[3:2] != 2'b11) ? 10'd1:
	             				  (screen_mode == c_g5) ? 10'd4: 10'd2;
	assign w_512pixel			= (screen_mode == c_g5 || screen_mode == c_g6);

	// --------------------------------------------------------------------
	//	Address
	// --------------------------------------------------------------------
	assign w_address_s_pre		= (screen_mode == c_g4 || ff_fg4) ? { ff_sy[18:8], ff_sx[15: 9] }:	// SCREEN5, 128byte/line, 2pixel/byte, 256line * 8page
	                  			  (screen_mode == c_g5          ) ? { ff_sy[18:8], ff_sx[16:10] }:	// SCREEN6, 128byte/line, 4pixel/byte, 256line * 8page
	                  			  (screen_mode == c_g6          ) ? { ff_sy[17:8], ff_sx[16: 9] }:	// SCREEN7, 256byte/line, 2pixel/byte, 256line * 4page
	                  			                                    { ff_sy[17:8], ff_sx[15: 8] };	// SCREEN8, 256byte/line, 1pixel/byte, 256line * 4page

	assign w_address_d_pre		= (screen_mode == c_g4 || ff_fg4) ? { ff_dy[10:0], ff_dx[ 7: 1] }:	// SCREEN5, 128byte/line, 2pixel/byte, 256line * 8page
	                  			  (screen_mode == c_g5          ) ? { ff_dy[10:0], ff_dx[ 8: 2] }:	// SCREEN6, 128byte/line, 4pixel/byte, 256line * 8page
	                  			  (screen_mode == c_g6          ) ? { ff_dy[ 9:0], ff_dx[ 8: 1] }:	// SCREEN7, 256byte/line, 2pixel/byte, 256line * 4page
	                  			                                    { ff_dy[ 9:0], ff_dx[ 7: 0] };	// SCREEN8, 256byte/line, 1pixel/byte, 256line * 4page

	assign w_address_s			= vram_interleave ? { w_address_s_pre[17], w_address_s_pre[0], w_address_s_pre[16:1] }: w_address_s_pre;
	assign w_address_d			= vram_interleave ? { w_address_d_pre[17], w_address_d_pre[0], w_address_d_pre[16:1] }: w_address_d_pre;

	// --------------------------------------------------------------------
	//	Command complete interrupt
	// --------------------------------------------------------------------
	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_command_end <= 1'b0;
		end
		else if( ff_state == c_state_finish ) begin
			ff_command_end <= w_cache_flush_end;
		end
		else begin
			ff_command_end <= 1'b0;
		end
	end

	assign intr_command_end		= ff_command_end;

	// --------------------------------------------------------------------
	//	Source position registers
	// --------------------------------------------------------------------
	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			reg_sx	<= 12'd0;
		end
		else if( register_write ) begin
			if( register_num == 6'd32 ) begin
				reg_sx[7:0]		<= register_data;
			end
			else if( register_num == 6'd33 ) begin
				reg_sx[11:8]	<= register_data[3:0];
			end
		end
	end

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_font_address	<= 18'd0;
		end
		else if( register_write && register_num == 6'd32 ) begin
			ff_font_address[7:0]	<= register_data;
		end
		else if( register_write && register_num == 6'd33 ) begin
			ff_font_address[15:8]	<= register_data;
		end
		else if( register_write && register_num == 6'd34 ) begin
			ff_font_address[17:16]	<= register_data[1:0];
		end
		else if( ff_cache_vram_valid ) begin
			//	hold
		end
		else if( ff_count_valid && ff_bit_count == 3'd0 ) begin
			ff_font_address	<= ff_font_address + 18'd1;
		end
	end

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_sx <= 20'd0;
		end
		else if( ff_start ) begin
			if( ff_command == c_ymmm ) begin
				ff_sx	<= { 3'd0, reg_dx, 8'd0 };
			end
			else begin
				ff_sx	<= { reg_sx, 8'd0 };
			end
		end
		else if( !ff_command_execute || ff_cache_vram_valid ) begin
			//	hold
		end
		else if( ff_count_valid ) begin
			if( ff_command == c_srch ) begin
				ff_sx <= { w_next_sx, 8'd0 };
			end
			else if( ff_command == c_lrmm ) begin
				if( ff_nx == 11'd0 ) begin
					ff_sx <= ff_sx2 - { { 4 {reg_vy[15]} }, reg_vy };
				end
				else begin
					ff_sx <= ff_sx + { { 4 {reg_vx[15]} }, reg_vx };
				end
			end
			else if( ff_nx == 11'd0 || w_sx_overflow || w_dx_overflow ) begin
				if( ff_command == c_ymmm ) begin
					ff_sx <= { 3'd0, reg_dx, 8'd0 };
				end
				else begin
					ff_sx <= { reg_sx, 8'd0 };
				end
			end
			else begin
				ff_sx <= { w_next_sx, 8'd0 };
			end
		end
	end

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_sy	<= 21'd0;
		end
		else if( register_write && register_num == 6'd34 ) begin
			ff_sy[15:0]	<= { register_data, 8'd0 };
		end
		else if( register_write && register_num == 6'd35 ) begin
			ff_sy[20:16]	<= register_data[4:0];
		end
		else if( !ff_command_execute || ff_cache_vram_valid ) begin
			//	hold
		end
		else if( ff_count_valid ) begin
			if( ff_command == c_lrmm ) begin
				if( ff_nx == 11'd0 ) begin
					ff_sy <= ff_sy2 + ( ff_xhr ? { { 4 {reg_vx[15]} }, reg_vx, 1'b0 } : { { 5 {reg_vx[15]} }, reg_vx } );
				end
				else begin
					ff_sy <= ff_sy  + { { 5 {reg_vy[15]} }, reg_vy };
				end
			end
			else if( ff_nx == 11'd0 || w_sx_overflow || w_dx_overflow ) begin
				if( reg_vram256k_mode ) begin
					ff_sy <= { w_next_sy[10:0], 8'd0 };
				end
				else begin
					ff_sy <= { 1'b0, w_next_sy[9:0], 8'd0 };
				end
			end
		end
	end

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_sx2 <= 20'd0;
			ff_sy2 <= 21'd0;
		end
		else if( ff_start ) begin
			ff_sx2	<= { reg_sx, 8'd0 };
			if( ff_command == c_lfmm ) begin
				ff_sy2	<= { 2'd0, ff_dy, 8'd0 };
			end
			else begin
				ff_sy2	<= ff_sy;
			end
		end
		else if( !ff_command_execute || ff_cache_vram_valid || ff_command == c_lfmm ) begin
			//	hold
		end
		else if( ff_count_valid ) begin
			if( ff_nx == 11'd0 ) begin
				ff_sx2 <= ff_sx2 - ( ff_xhr ? { { 3 {reg_vy[15]} }, reg_vy, 1'b0 } : { { 4 {reg_vy[15]} }, reg_vy } );
				ff_sy2 <= ff_sy2 + { { 5 {reg_vx[15]} }, reg_vx };
			end
		end
	end

	assign w_next_sx	= ff_dix ? ( ff_sx[19:8] - w_next ): ( ff_sx[19:8] + w_next );
	assign w_next_sy	= ff_diy ? ( ff_sy[20:8] - 12'd1  ): ( ff_sy[20:8] + 12'd1  );

	// --------------------------------------------------------------------
	//	Destination position registers
	// --------------------------------------------------------------------
	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			reg_dx	<= 9'd0;
		end
		else if( register_write && register_num == 6'd36 ) begin
			reg_dx[7:0]	<= register_data;
		end
		else if( register_write && register_num == 6'd37 ) begin
			reg_dx[8]	<= register_data[0];
		end
		else if( ff_command == c_lfmm ) begin
			if( ff_count_valid && ff_bit_count == 3'd0 && ff_ny == 11'd0 ) begin
				reg_dx	<= w_next_dx[8:0];
			end
			else begin
				//	hold
			end
		end
	end

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_dx <= 9'd0;
		end
		else if( ff_start ) begin
			ff_dx <= reg_dx;
		end
		else if( !ff_command_execute || ff_cache_vram_valid ) begin
			//	hold
		end
		else if( ff_count_valid ) begin
			if( ff_command == c_line ) begin
				if( ff_maj == 1'b0 ) begin
					//	Long side is X-axis
					ff_dx <= w_next_dx[8:0];
				end
				else begin
					//	Long side is Y-axis
					if( w_line_shift ) begin
						ff_dx <= w_next_dx[8:0];
					end
				end
			end
			else if( ff_command == c_lfmm ) begin
				if( (ff_bit_count == 3'd0 && ff_ny != 11'd0) || w_dx_overflow ) begin
					ff_dx <= reg_dx;
				end
				else begin
					ff_dx <= w_next_dx[8:0];
				end
			end
			else begin
				if( ff_nx == 11'd0 || w_sx_overflow || w_dx_overflow ) begin
					ff_dx <= reg_dx;
				end
				else begin
					ff_dx <= w_next_dx[8:0];
				end
			end
		end
	end

	assign w_line_shift	= w_next_nyb[12] || (w_next_nyb[11:0] == 12'd0);

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_dy	<= 11'd0;
		end
		else if( register_write && register_num == 6'd38 ) begin
			ff_dy[7:0]	<= register_data;
		end
		else if( register_write && register_num == 6'd39 ) begin
			if( reg_vram256k_mode ) begin
				ff_dy[10:8]	<= register_data[2:0];
			end
			else begin
				ff_dy[10:8]	<= { 1'b0, register_data[1:0] };
			end
		end
		else if( !ff_command_execute || ff_cache_vram_valid ) begin
			//	hold
		end
		else if( ff_count_valid ) begin
			if( ff_command == c_line ) begin
				if( ff_maj == 1'b0 ) begin
					//	Long side is X-axis
					if( w_line_shift ) begin
						if( reg_vram256k_mode ) begin
							ff_dy <= w_next_dy[10:0];
						end
						else begin
							ff_dy <= { 1'b0, w_next_dy[9:0] };
						end
					end
				end
				else begin
					//	Long side is Y-axis
					if( reg_vram256k_mode ) begin
						ff_dy <= w_next_dy[10:0];
					end
					else begin
						ff_dy <= { 1'b0, w_next_dy[9:0] };
					end
				end
			end
			else if( ff_command == c_lfmm ) begin
				if( ff_bit_count == 3'd0 || w_dx_overflow ) begin
					if( ff_ny == 11'd0 ) begin
						ff_dy <= ff_sy2[18:8];
					end
					else begin
						ff_dy <= w_next_dy[10:0];
					end
				end
				else begin
					//	hold
				end
			end
			else begin
				if( ff_nx == 11'd0 || w_sx_overflow || w_dx_overflow ) begin
					if( reg_vram256k_mode ) begin
						ff_dy <= w_next_dy[10:0];
					end
					else begin
						ff_dy <= { 1'b0, w_next_dy[9:0] };
					end
				end
			end
		end
	end

	assign w_next_dx		= ff_dix ? ( { 1'b0, ff_dx } - w_next ): ( { 1'b0, ff_dx } + w_next );
	assign w_next_dy		= ff_diy ? ( { 1'b0, ff_dy } - 12'd1  ): ( { 1'b0, ff_dy } + 12'd1  );
	assign w_sx_active		= (ff_command == c_lmmm || ff_command == c_hmmm || ff_command == c_ymmm || ff_command == c_lmcm || ff_command == c_srch);
	assign w_dx_active		= (ff_command == c_lmmm || ff_command == c_hmmm || ff_command == c_ymmm || ff_command == c_lmmc || ff_command == c_hmmc || 
							   ff_command == c_lmmv || ff_command == c_hmmv || ff_command == c_lrmm || ff_command == c_lfmc || ff_command == c_lfmm);
	assign w_sx_overflow	= w_sx_active && (w_next_sx[9] || (!w_512pixel && w_next_sx[8]));
	assign w_dx_overflow	= w_dx_active && (w_next_dx[9] || (!w_512pixel && w_next_dx[8]));

	// --------------------------------------------------------------------
	//	Count N registers
	// --------------------------------------------------------------------
	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			reg_nx	<= 11'd0;
		end
		else if( register_write && register_num == 6'd40 ) begin
			reg_nx[7:0]		<= register_data;
		end
		else if( register_write && register_num == 6'd41 ) begin
			reg_nx[10:8]	<= register_data[2:0];
		end
		else if( ff_count_valid ) begin
			if( ff_command == c_lfmm ) begin
				if( ff_bit_count == 3'd0 && ff_ny == 11'd0 ) begin
					reg_nx	<= ff_nx;
				end
			end
		end
	end

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_nx <= 11'd0;
		end
		else if( ff_start ) begin
			if( ff_command == c_ymmm ) begin
				case( w_bpp )
				c_bpp_8bit:		ff_nx <= 11'd255;
				c_bpp_4bit:		ff_nx <= 11'd510;
				c_bpp_2bit:		ff_nx <= 11'd508;
				default:		ff_nx <= 11'd255;
				endcase
			end
			else if( ff_command == c_line ) begin
				ff_nx <= reg_nx;
			end
			else if( ff_command[3:2] == 2'b11 ) begin
				case( w_bpp )
				c_bpp_8bit:		ff_nx <= w_nx;
				c_bpp_4bit:		ff_nx <= { w_nx[10:1], 1'b0 };
				c_bpp_2bit:		ff_nx <= { w_nx[10:2], 2'd0 };
				default:		ff_nx <= w_nx;
				endcase
			end
			else begin
				ff_nx <= w_nx;
			end
		end
		else if( !ff_command_execute || ff_cache_vram_valid ) begin
			//	hold
		end
		else if( ff_count_valid ) begin
			if( ff_command == c_line ) begin
				if( ff_nx != 11'd0 ) begin
					ff_nx <= ff_nx - 11'd1;
				end
			end
			else if( ff_command == c_lfmm ) begin
				if( ff_ny == 11'd0 ) begin
					ff_nx <= w_nx;
				end
			end
			else if( ff_nx == 11'd0 || w_sx_overflow || w_dx_overflow ) begin
				if( ff_command == c_ymmm ) begin
					ff_nx <= 11'd510;
				end
				else if( ff_command[3:2] == 2'b11 ) begin
					case( w_bpp )
					c_bpp_8bit:		ff_nx <= w_nx;
					c_bpp_4bit:		ff_nx <= { w_nx[10:1], 1'b0 };
					c_bpp_2bit:		ff_nx <= { w_nx[10:2], 2'd0 };
					default:		ff_nx <= w_nx;
					endcase
				end
				else begin
					ff_nx <= w_nx;
				end
			end
			else begin
				ff_nx <= ff_nx - { 1'b0, w_next[9:0] };
			end
		end
	end

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_ny	<= 11'd0;
		end
		else if( register_write && register_num == 6'd42 ) begin
			ff_ny[7:0]	<= register_data;
		end
		else if( register_write && register_num == 6'd43 ) begin
			if( reg_vram256k_mode ) begin
				ff_ny[10:8]	<= register_data[2:0];
			end
			else begin
				ff_ny[10:8]	<= { 1'b0, register_data[1:0] };
			end
		end
		else if( ff_start ) begin
			if( ff_command == c_line ) begin
				//	hold
			end
			else begin
				ff_ny <= w_ny;
			end
		end
		else if( !ff_command_execute || ff_cache_vram_valid ) begin
			//	hold
		end
		else if( ff_command == c_line ) begin
			//	hold
		end
		else if( ff_count_valid ) begin
			if( ff_command == c_lfmm ) begin
				if( ff_bit_count == 3'd0 ) begin
					if( ff_ny == 11'd0 ) begin
						ff_ny <= ff_nyb[10:0];
					end
					else begin
						ff_ny <= w_ny;
					end
				end
			end
			else if( (ff_nx == 11'd0 || w_sx_overflow || w_dx_overflow) && ff_ny != 11'd0 ) begin
				ff_ny <= w_ny;
			end
		end
	end

	//	LINEコマンドの分子を示すカウンタ
	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_nyb	<= 12'd0;
		end
		else if( ff_start ) begin
			if( ff_command == c_lfmm ) begin
				//	元の NY の値を覚えておくために NYB を使う
				ff_nyb	<= { 1'b0, w_ny };
			end
			else begin
				//	線分を構成する水平又は垂直の直線の最初と最後を均等サイズにするために分母の半分の値を事前に足しておく
				ff_nyb	<= { 1'd0, reg_nx[10:1] };
			end
		end
		else if( !ff_command_execute || ff_cache_vram_valid || ff_command == c_lfmm ) begin
			//	hold
		end
		else if( ff_count_valid ) begin
			if( w_line_shift ) begin
				ff_nyb	<= w_next_nyb[11:0] + { 1'b0, reg_nx };
			end
			else begin
				ff_nyb	<= w_next_nyb[11:0];
			end
		end
	end

	assign w_nx			= reg_nx - 9'd1;
	assign w_ny			= ff_ny - 11'd1;
	assign w_next_nyb	= { 1'b0, ff_nyb } - { 2'd0, ff_ny[9:0] };

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_color	<= 8'd0;
		end
		else if( register_write && register_num == 6'd44 ) begin
			ff_color	<= register_data;
		end
		else if( ff_state == c_state_lmcm_make ) begin
			ff_color	<= ff_read_pixel;
		end
	end

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_read_color	<= 1'b0;
		end
		else if( ff_start ) begin
			ff_read_color	<= 1'b0;
		end
		else if( read_color ) begin
			ff_read_color	<= 1'b1;
		end
		else if( ff_state == c_state_lmcm_next ) begin
			ff_read_color	<= 1'b0;
		end
	end

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_transfer_ready		<= 1'b0;
			ff_fore_color			<= 8'd0;
		end
		else if( register_write && (register_num == 6'd44) ) begin
			//	lmmc, hmmc, lfmc が VRAM へ書き終えるまで、転送禁止 (CPU→R#44)
			ff_transfer_ready		<= 1'b0;
		end
		else if( ff_state == c_state_lmmc_next || ff_state == c_state_hmmc_next || (ff_state == c_state_lfmc_next && ff_bit_count == 3'd0) ) begin
			//	lmmc, hmmc, lfmc が VRAM へ書き終えたので、転送許可 (CPU→R#44)
			ff_transfer_ready		<= 1'b1;
		end
		else if( ff_command == c_lmcm && ff_start ) begin
			//	lmcm が開始されたので、転送禁止 (S#7→CPU)
			ff_transfer_ready		<= 1'b0;
		end
		else if( ff_command == c_lfmc && ff_start ) begin
			//	lfmc が開始されたので、転送許可
			ff_transfer_ready		<= 1'b1;
			ff_fore_color			<= ff_color;
		end
		else if( ff_command == c_lfmm && ff_start ) begin
			ff_fore_color			<= ff_color;
		end
		else if( ff_state == c_state_lmcm_make ) begin
			//	lmcm が VRAM を読みだしたので、転送許可 (S#7→CPU)
			ff_transfer_ready		<= 1'b1;
		end
		else if( read_color ) begin
			//	lmcm で 読みだした VRAM の値を転送し終えたので、次のために転送禁止 (S#7→CPU)
			ff_transfer_ready		<= 1'b0;
		end
		else begin
			//	hold
		end
	end

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_maj	<= 1'b0;
			ff_eq	<= 1'b0;
			ff_dix	<= 1'b0;
			ff_diy	<= 1'b0;
			ff_mxs	<= 1'b0;
			ff_mxd	<= 1'b0;
			ff_xhr	<= 1'b0;
			ff_fg4	<= 1'b0;
		end
		else if( register_write ) begin
			if( register_num == 6'd45 ) begin
				ff_maj	<= register_data[0];
				ff_eq	<= register_data[1];
				ff_dix	<= register_data[2];
				ff_diy	<= register_data[3];
				ff_mxs	<= register_data[4];
				ff_mxd	<= register_data[5];
				ff_xhr	<= register_data[6] & reg_ext_command_mode;
				ff_fg4	<= register_data[7] & reg_ext_command_mode;
			end
		end
	end

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_logical_opration	<= 4'd0;
			ff_command			<= 4'd0;
			ff_start			<= 1'b0;
		end
		else if( register_write && (register_num == 6'd46) ) begin
			ff_logical_opration	<= register_data[3:0];
			ff_command			<= register_data[7:4];
			ff_start			<= 1'b1;
		end
		else begin
			ff_start			<= 1'b0;
		end
	end

	// --------------------------------------------------------------------
	//	Rotate vector registers
	// --------------------------------------------------------------------
	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			reg_vx	<= 16'd0;
		end
		else if( register_write ) begin
			if( register_num == 6'd47 ) begin
				reg_vx[7:0]		<= register_data;
			end
			else if( register_num == 6'd48 ) begin
				reg_vx[15:8]	<= register_data;
			end
		end
	end

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			reg_vy	<= 16'd0;
		end
		else if( register_write ) begin
			if( register_num == 6'd49 ) begin
				reg_vy[7:0]		<= register_data;
			end
			else if( register_num == 6'd50 ) begin
				reg_vy[15:8]	<= register_data;
			end
		end
	end

	// --------------------------------------------------------------------
	//	Input window registers
	// --------------------------------------------------------------------
	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			reg_wsx	<= 9'd0;
		end
		else if( register_write ) begin
			if( register_num == 6'd51 ) begin
				reg_wsx[7:0]	<= register_data;
			end
			else if( register_num == 6'd52 ) begin
				reg_wsx[8]		<= register_data[0];
			end
		end
	end

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			reg_wsy	<= 11'd0;
		end
		else if( register_write ) begin
			if( register_num == 6'd53 ) begin
				reg_wsy[7:0]	<= register_data;
			end
			else if( register_num == 6'd54 ) begin
				reg_wsy[10:8]	<= register_data[2:0];
			end
		end
	end

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			reg_wex	<= 9'h1FF;
		end
		else if( register_write ) begin
			if( register_num == 6'd55 ) begin
				reg_wex[7:0]	<= register_data;
			end
			else if( register_num == 6'd56 ) begin
				reg_wex[8]		<= register_data[0];
			end
		end
	end

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			reg_wey	<= 11'h7FF;
		end
		else if( register_write ) begin
			if( register_num == 6'd57 ) begin
				reg_wey[7:0]	<= register_data;
			end
			else if( register_num == 6'd58 ) begin
				reg_wey[10:8]	<= register_data[2:0];
			end
		end
	end

	// --------------------------------------------------------------------
	//	State machine
	// --------------------------------------------------------------------
	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_command_execute <= 1'b0;
		end
		else if( ff_start ) begin
			ff_command_execute <= 1'b1;
		end
		else if( w_cache_flush_end ) begin
			ff_command_execute <= 1'b0;
		end
	end

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_border_detect <= 1'b0;
		end
		else if( w_cache_flush_end ) begin
			ff_border_detect <= ff_border_detect | ff_border_detect_request;
		end
		else if( clear_border_detect ) begin
			ff_border_detect <= 1'b0;
		end
	end

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_read_pixel <= 8'd0;
			ff_read_byte <= 8'd0;
		end
		else if( ff_start ) begin
			ff_read_pixel <= 8'd0;
			ff_read_byte <= 8'd0;
		end
		else if( w_cache_vram_rdata_en ) begin
			case( w_bpp )
			c_bpp_8bit: begin
				ff_read_pixel <= w_cache_vram_rdata;
			end
			c_bpp_4bit: begin
				//	xsel = 0 のときに上位 4bit, xsel = 1 のときに下位 4bit
				ff_read_pixel <= ff_xsel[0] ? { 4'd0, w_cache_vram_rdata[3:0] } : { 4'd0, w_cache_vram_rdata[7:4] };
			end
			c_bpp_2bit: begin
				case( ff_xsel[1:0] )
				2'd0:	ff_read_pixel <= { 6'd0, w_cache_vram_rdata[7:6] };
				2'd1:	ff_read_pixel <= { 6'd0, w_cache_vram_rdata[5:4] };
				2'd2:	ff_read_pixel <= { 6'd0, w_cache_vram_rdata[3:2] };
				2'd3:	ff_read_pixel <= { 6'd0, w_cache_vram_rdata[1:0] };
				endcase
			end
			default: begin
				ff_read_pixel <= w_cache_vram_rdata;
			end
			endcase
			ff_read_byte <= w_cache_vram_rdata;
		end
	end

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_state					<= c_state_idle;
			ff_cache_vram_address		<= 17'd0;
			ff_cache_flush_start		<= 1'b0;
			ff_cache_vram_valid			<= 1'b0;
			ff_cache_vram_write			<= 1'b0;
			ff_cache_vram_wdata			<= 8'd0;
			ff_count_valid				<= 1'b0;
			ff_border_detect_request	<= 1'b0;
			ff_wait_count				<= 6'd0;
			ff_xsel						<= 2'd0;
		end
		else if( ff_start ) begin
			ff_source					<= ff_color;
			ff_count_valid				<= 1'b0;
			ff_border_detect_request	<= 1'b0;
			ff_cache_flush_start		<= 1'b0;
			ff_cache_vram_valid			<= 1'b0;
			ff_wait_count				<= 6'd0;
			ff_xsel						<= 2'd0;
			case( ff_command )
			c_stop:		ff_state <= c_state_stop;
			c_point:	ff_state <= c_state_point;
			c_pset:		ff_state <= c_state_pset;
			c_srch:		ff_state <= c_state_srch;
			c_line:		ff_state <= c_state_line;
			c_lmmv:		ff_state <= c_state_lmmv;
			c_lmmm:		ff_state <= c_state_lmmm;
			c_hmmv:		ff_state <= c_state_hmmv;
			c_hmmm:		ff_state <= c_state_hmmm;
			c_ymmm:		ff_state <= c_state_ymmm;
			c_lmmc:		ff_state <= c_state_lmmc;
			c_hmmc:		ff_state <= c_state_hmmc;
			c_lmcm:		ff_state <= c_state_lmcm;
			c_lrmm:		ff_state <= reg_ext_command_mode ? c_state_lrmm : c_state_stop;
			c_lfmc:		ff_state <= reg_ext_command_mode ? c_state_lfmc : c_state_stop;
			c_lfmm:		ff_state <= reg_ext_command_mode ? c_state_lfmm : c_state_stop;
			default:	ff_state <= c_state_stop;
			endcase
		end
		else if( ff_cache_vram_valid ) begin
			if( w_cache_vram_ready ) begin
				ff_cache_vram_valid <= 1'b0;
			end
		end
		else begin
			case( ff_state )
			//	STOP command --------------------------------------------------
			c_state_stop: begin
				//	Activate cache flush and wait for it to complete.
				ff_cache_flush_start	<= 1'b1;
				ff_state				<= c_state_finish;
			end
			//	POINT command -------------------------------------------------
			c_state_point: begin
				if( ff_sx[8] && !w_512pixel ) begin
					//	Go to finish state when start position is outside of screen.
					ff_cache_flush_start	<= 1'b1;
					ff_state				<= c_state_finish;
				end
				else begin
					//	Read the location of (SX, SY)
					ff_cache_vram_address	<= w_address_s;
					ff_cache_vram_valid		<= 1'b1;
					ff_cache_vram_write		<= 1'b0;
					ff_state				<= c_state_wait_rdata_en;
					ff_next_state			<= c_state_pre_finish;
					ff_wait_count			<= c_wait_point;
					ff_xsel					<= ff_sx[9:8];
				end
			end
			//	PSET command --------------------------------------------------
			c_state_pset: begin
				if( ff_dx[8] && !w_512pixel ) begin
					//	Go to finish state when start position is outside of screen.
					ff_cache_flush_start	<= 1'b1;
					ff_state				<= c_state_finish;
				end
				else begin
					//	Read the location of (DX, DY)
					ff_cache_vram_address	<= w_address_d;
					ff_cache_vram_valid		<= 1'b1;
					ff_cache_vram_write		<= 1'b0;
					ff_state				<= c_state_wait_rdata_en;
					ff_next_state			<= c_state_pset_make;
					ff_wait_count			<= c_wait_pset;
					ff_xsel					<= ff_dx[1:0];
				end
			end
			c_state_pset_make: begin
				//	Write the location of (DX, DY)
				ff_cache_vram_address	<= w_address_d;
				ff_cache_vram_valid		<= 1'b1;
				ff_cache_vram_write		<= 1'b1;
				ff_cache_vram_wdata		<= w_destination;
				if( reg_command_high_speed_mode ) begin
					ff_state				<= c_state_pre_finish;
				end
				else begin
					ff_wait_counter			<= { c_wait_pset, 2'b11 };
					ff_next_state			<= c_state_pre_finish;
					ff_state				<= c_state_wait_counter;
				end
			end

			//	SRCH command --------------------------------------------------
			c_state_srch: begin
				if( ff_sx[9] || (ff_sx[8] && !w_512pixel) ) begin
					//	Go to finish state when start position is outside of screen.
					if( ff_sx == reg_sx ) begin
						//	Start point is out of screen.
						ff_count_valid				<= ~ff_eq;
						ff_border_detect_request	<= ff_eq;
					end
					else begin
						//	
						ff_count_valid				<= 1'b0;
						ff_border_detect_request	<= 1'b0;
					end
					ff_state					<= c_state_pre_finish;
				end
				else begin
					//	Read the location of (SX, SY)
					ff_cache_vram_address		<= w_address_s;
					ff_cache_vram_valid			<= 1'b1;
					ff_cache_vram_write			<= 1'b0;
					ff_state					<= c_state_wait_rdata_en;
					ff_next_state				<= c_state_srch_compare;
					ff_wait_count				<= c_wait_srch;
					ff_xsel						<= ff_sx[9:8];
				end
			end

			c_state_srch_compare: begin
				//	Compare (SX,SY) and R#44
				if( (ff_read_pixel == ff_color) == ff_eq ) begin
					//	Increment/Decrement
					ff_count_valid				<= 1'b1;
					ff_state					<= c_state_srch_next;
				end
				else begin
					ff_cache_flush_start		<= 1'b1;
					ff_state					<= c_state_finish;
					ff_border_detect_request	<= 1'b1;
				end
			end

			c_state_srch_next: begin
				ff_count_valid				<= 1'b0;
				ff_state					<= c_state_srch;
			end

			//	LINE command --------------------------------------------------
			c_state_line: begin
				if( ff_dx[8] && !w_512pixel ) begin
					//	Go to finish state when start position is outside of screen.
					ff_cache_flush_start	<= 1'b1;
					ff_state				<= c_state_finish;
				end
				else begin
					//	Read the location of (DX, DY)
					ff_cache_vram_address	<= w_address_d;
					ff_cache_vram_valid		<= 1'b1;
					ff_cache_vram_write		<= 1'b0;
					ff_state				<= c_state_wait_rdata_en;
					ff_next_state			<= c_state_line_make;
					ff_wait_count			<= c_wait_line;
					ff_xsel					<= ff_dx[1:0];
				end
			end
			c_state_line_make: begin
				//	Write the location of (DX, DY)
				ff_cache_vram_address	<= w_address_d;
				ff_cache_vram_valid		<= 1'b1;
				ff_cache_vram_write		<= 1'b1;
				ff_cache_vram_wdata		<= w_destination;
				ff_count_valid			<= 1'b1;
				if( reg_command_high_speed_mode ) begin
					ff_state				<= c_state_line_next;
				end
				else begin
					ff_wait_counter			<= { c_wait_line, 2'b11 };
					ff_next_state			<= c_state_line_next;
					ff_state				<= c_state_wait_counter;
				end
			end
			c_state_line_next: begin
				ff_count_valid			<= 1'b0;
				if( ff_nx == 11'd0 || w_dx_overflow || (ff_diy == 1'b1 && ff_dy == 11'd0 && w_next_dy[11] == 1'b1) ) begin
					ff_state				<= c_state_pre_finish;
				end
				else begin
					ff_state				<= c_state_line;
				end
			end
			//	LMMV command --------------------------------------------------
			c_state_lmmv: begin
				//	Read the location of (DX, DY)
				ff_cache_vram_address	<= w_address_d;
				ff_cache_vram_valid		<= 1'b1;
				ff_cache_vram_write		<= 1'b0;
				ff_state				<= c_state_wait_rdata_en;
				ff_next_state			<= c_state_lmmv_make;
				ff_wait_count			<= c_wait_lmmv;
				ff_xsel					<= ff_dx[1:0];
			end
			c_state_lmmv_make: begin
				//	Write the location of (DX, DY)
				ff_cache_vram_address	<= w_address_d;
				ff_cache_vram_valid		<= 1'b1;
				ff_cache_vram_write		<= 1'b1;
				ff_cache_vram_wdata		<= w_destination;
				ff_count_valid			<= 1'b1;
				if( reg_command_high_speed_mode ) begin
					ff_state				<= c_state_lmmv_next;
				end
				else begin
					ff_wait_counter			<= { c_wait_lmmv, 2'b11 };
					ff_next_state			<= c_state_lmmv_next;
					ff_state				<= c_state_wait_counter;
				end
			end
			c_state_lmmv_next: begin
				ff_count_valid			<= 1'b0;
				if( (ff_nx == 11'd0 || w_sx_overflow || w_dx_overflow) && ff_ny == 11'd0 ) begin
					ff_state				<= c_state_pre_finish;
				end
				else begin
					ff_state				<= c_state_lmmv;
				end
			end

			//	LMMM command --------------------------------------------------
			c_state_lmmm: begin
				//	Read the location of (SX, SY)
				ff_cache_vram_address	<= w_address_s;
				ff_cache_vram_valid		<= 1'b1;
				ff_cache_vram_write		<= 1'b0;
				ff_state				<= c_state_wait_rdata_en;
				ff_next_state			<= c_state_lmmm_wait_source;
				ff_wait_count			<= c_wait_lmmm;
				ff_xsel					<= ff_sx[9:8];
			end
			c_state_lmmm_wait_source: begin
				//	Copy source pixel value
				ff_source				<= ff_read_pixel;
				//	Read the location of (DX, DY)
				ff_cache_vram_address	<= w_address_d;
				ff_cache_vram_valid		<= 1'b1;
				ff_cache_vram_write		<= 1'b0;
				ff_state				<= c_state_wait_rdata_en;
				ff_next_state			<= c_state_lmmm_make;
				ff_wait_count			<= c_wait_lmmm;
				ff_xsel					<= ff_dx[1:0];
			end
			c_state_lmmm_make: begin
				//	Write the location of (DX, DY)
				ff_cache_vram_address	<= w_address_d;
				ff_cache_vram_valid		<= 1'b1;
				ff_cache_vram_write		<= 1'b1;
				ff_cache_vram_wdata		<= w_destination;
				ff_count_valid			<= 1'b1;
				if( reg_command_high_speed_mode ) begin
					ff_state				<= c_state_lmmm_next;
				end
				else begin
					ff_wait_counter			<= { c_wait_lmmm, 2'b11 };
					ff_next_state			<= c_state_lmmm_next;
					ff_state				<= c_state_wait_counter;
				end
			end
			c_state_lmmm_next: begin
				ff_count_valid			<= 1'b0;
				if( (ff_nx == 11'd0 || w_sx_overflow || w_dx_overflow) && ff_ny == 11'd0 ) begin
					ff_state				<= c_state_pre_finish;
				end
				else begin
					ff_state				<= c_state_lmmm;
				end
			end

			//	LMCM command --------------------------------------------------
			c_state_lmcm: begin
				ff_count_valid			<= 1'b0;
				if( (ff_nx == 11'd0 || w_sx_overflow || w_dx_overflow) && ff_ny == 11'd0 ) begin
					ff_state				<= c_state_pre_finish;
				end
				else begin
					//	Read the location of (DX, DY)
					ff_cache_vram_address	<= w_address_d;
					ff_cache_vram_valid		<= 1'b1;
					ff_cache_vram_write		<= 1'b0;
					ff_state				<= c_state_wait_rdata_en;
					ff_next_state			<= c_state_lmcm_make;
					ff_wait_count			<= c_wait_lmcm;
					ff_xsel					<= ff_dx[1:0];
				end
			end
			c_state_lmcm_make: begin
				ff_state				<= c_state_lmcm_next;
			end
			c_state_lmcm_next: begin
				if( ff_read_color ) begin
					if( (ff_nx == 11'd0 || w_sx_overflow || w_dx_overflow) && ff_ny == 11'd0 ) begin
						ff_state				<= c_state_pre_finish;
					end
					else begin
						ff_count_valid			<= 1'b1;
						ff_state				<= c_state_lmcm;
					end
				end
				else begin
					//	hold
				end
			end

			//	LMMC command --------------------------------------------------
			c_state_lmmc: begin
				if( ff_transfer_ready ) begin
					//	書き込まれる（ff_transfer_ready = 0）まで待機
				end
				else begin
					//	Copy source pixel value
					ff_source				<= ff_color;
					//	Read the location of (DX, DY)
					ff_cache_vram_address	<= w_address_d;
					ff_cache_vram_valid		<= 1'b1;
					ff_cache_vram_write		<= 1'b0;
					ff_state				<= c_state_wait_rdata_en;
					ff_next_state			<= c_state_lmmc_make;
					ff_wait_count			<= c_wait_lmmc;
					ff_xsel					<= ff_dx[1:0];
				end
			end
			c_state_lmmc_make: begin
				//	Write the location of (DX, DY)
				ff_cache_vram_address	<= w_address_d;
				ff_cache_vram_valid		<= 1'b1;
				ff_cache_vram_write		<= 1'b1;
				ff_cache_vram_wdata		<= w_destination;
				ff_count_valid			<= 1'b1;
				if( reg_command_high_speed_mode ) begin
					ff_state				<= c_state_lmmc_next;
				end
				else begin
					ff_wait_counter			<= { c_wait_lmmc, 2'b11 };
					ff_next_state			<= c_state_lmmc_next;
					ff_state				<= c_state_wait_counter;
				end
			end
			c_state_lmmc_next: begin
				ff_count_valid			<= 1'b0;
				if( (ff_nx == 11'd0 || w_dx_overflow) && ff_ny == 11'd0 ) begin
					ff_state				<= c_state_pre_finish;
				end
				else begin
					ff_state				<= c_state_lmmc;
				end
			end

			//	HMMV command --------------------------------------------------
			c_state_hmmv: begin
				//	Write the location of (DX, DY)
				ff_cache_vram_address	<= w_address_d;
				ff_cache_vram_valid		<= 1'b1;
				ff_cache_vram_write		<= 1'b1;
				ff_cache_vram_wdata		<= ff_color;
				if( reg_command_high_speed_mode ) begin
					ff_state				<= c_state_hmmv_next;
				end
				else begin
					ff_wait_counter			<= { c_wait_hmmv, 2'b11 };
					ff_next_state			<= c_state_hmmv_next;
					ff_state				<= c_state_wait_counter;
				end
				ff_count_valid			<= 1'b1;
			end
			c_state_hmmv_next: begin
				ff_count_valid			<= 1'b0;
				if( (ff_nx == 11'd0 || w_sx_overflow || w_dx_overflow) && ff_ny == 11'd0 ) begin
					ff_state				<= c_state_pre_finish;
				end
				else begin
					ff_state				<= c_state_hmmv;
				end
			end

			//	HMMM command --------------------------------------------------
			c_state_hmmm: begin
				//	Read the location of (SX, SY)
				ff_cache_vram_address	<= w_address_s;
				ff_cache_vram_valid		<= 1'b1;
				ff_cache_vram_write		<= 1'b0;
				ff_state				<= c_state_wait_rdata_en;
				ff_next_state			<= c_state_hmmm_make;
				ff_wait_count			<= c_wait_hmmm;
			end
			c_state_hmmm_make: begin
				//	Write the location of (DX, DY)
				ff_cache_vram_address	<= w_address_d;
				ff_cache_vram_valid		<= 1'b1;
				ff_cache_vram_write		<= 1'b1;
				ff_cache_vram_wdata		<= ff_read_byte;
				ff_count_valid			<= 1'b1;
				if( reg_command_high_speed_mode ) begin
					ff_state				<= c_state_hmmm_next;
				end
				else begin
					ff_wait_counter			<= { c_wait_hmmm, 2'b11 };
					ff_next_state			<= c_state_hmmm_next;
					ff_state				<= c_state_wait_counter;
				end
			end
			c_state_hmmm_next: begin
				ff_count_valid			<= 1'b0;
				if( (ff_nx == 11'd0 || w_sx_overflow || w_dx_overflow) && ff_ny == 11'd0 ) begin
					ff_state				<= c_state_pre_finish;
				end
				else begin
					ff_state				<= c_state_hmmm;
				end
			end

			//	YMMM command --------------------------------------------------
			c_state_ymmm: begin
				//	Read the location of (DX, SY)
				ff_cache_vram_address	<= w_address_s;
				ff_cache_vram_valid		<= 1'b1;
				ff_cache_vram_write		<= 1'b0;
				ff_state				<= c_state_wait_rdata_en;
				ff_next_state			<= c_state_ymmm_make;
				ff_wait_count			<= c_wait_ymmm;
			end
			c_state_ymmm_make: begin
				//	Write the location of (DX, DY)
				ff_cache_vram_address	<= w_address_d;
				ff_cache_vram_valid		<= 1'b1;
				ff_cache_vram_write		<= 1'b1;
				ff_cache_vram_wdata		<= ff_read_byte;
				ff_count_valid			<= 1'b1;
				if( reg_command_high_speed_mode ) begin
					ff_state				<= c_state_ymmm_next;
				end
				else begin
					ff_wait_counter			<= { c_wait_ymmm, 2'b11 };
					ff_next_state			<= c_state_ymmm_next;
					ff_state				<= c_state_wait_counter;
				end
			end
			c_state_ymmm_next: begin
				ff_count_valid			<= 1'b0;
				if( (ff_nx == 11'd0 || w_sx_overflow || w_dx_overflow) && ff_ny == 11'd0 ) begin
					ff_state				<= c_state_pre_finish;
				end
				else begin
					ff_state				<= c_state_ymmm;
				end
			end

			//	HMMC command --------------------------------------------------
			c_state_hmmc: begin
				if( ff_transfer_ready ) begin
					//	書き込まれる（ff_transfer_ready = 0）まで待機
				end
				else begin
					//	Write the location of (DX, DY)
					ff_cache_vram_address	<= w_address_d;
					ff_cache_vram_valid		<= 1'b1;
					ff_cache_vram_write		<= 1'b1;
					ff_cache_vram_wdata		<= ff_color;
					ff_count_valid			<= 1'b1;
					if( reg_command_high_speed_mode ) begin
						ff_state				<= c_state_hmmc_next;
					end
					else begin
						ff_wait_counter			<= { c_wait_ymmm, 2'b11 };
						ff_next_state			<= c_state_hmmc_next;
						ff_state				<= c_state_wait_counter;
					end
				end
			end
			c_state_hmmc_next: begin
				ff_count_valid			<= 1'b0;
				if( (ff_nx == 11'd0 || w_dx_overflow) && ff_ny == 11'd0 ) begin
					ff_state				<= c_state_pre_finish;
				end
				else begin
					ff_state				<= c_state_hmmc;
				end
			end

			//	LRMM command --------------------------------------------------
			c_state_lrmm: begin
				//	Read the location of (SX, SY)
				ff_cache_vram_address	<= w_address_s;
				ff_cache_vram_valid		<= 1'b1;
				ff_cache_vram_write		<= 1'b0;
				ff_state				<= c_state_wait_rdata_en;
				ff_next_state			<= c_state_lrmm_wait_source;
				ff_xsel					<= ff_sx[9:8];
			end
			c_state_lrmm_wait_source: begin
				//	Copy source pixel value
				if( ff_sx[17:8] < { 1'b0, reg_wsx } || ff_sy[18:8] < reg_wsy || ff_sx[17:8] > { 1'b0, reg_wex } || ff_sy[18:8] > reg_wey ) begin
					//	Replace color in outside of window
					ff_source				<= ff_color;
				end
				else begin
					ff_source				<= ff_read_pixel;
				end
				//	Read the location of (DX, DY)
				ff_cache_vram_address	<= w_address_d;
				ff_cache_vram_valid		<= 1'b1;
				ff_cache_vram_write		<= 1'b0;
				ff_state				<= c_state_wait_rdata_en;
				ff_next_state			<= c_state_lrmm_make;
				ff_xsel					<= ff_dx[1:0];
			end
			c_state_lrmm_make: begin
				//	Write the location of (DX, DY)
				ff_cache_vram_address	<= w_address_d;
				ff_cache_vram_valid		<= 1'b1;
				ff_cache_vram_write		<= 1'b1;
				ff_cache_vram_wdata		<= w_destination;
				ff_state				<= c_state_lrmm_next;
				ff_count_valid			<= 1'b1;
			end
			c_state_lrmm_next: begin
				ff_count_valid			<= 1'b0;
				if( (ff_nx == 11'd0 || w_dx_overflow) && ff_ny == 11'd0 ) begin
					ff_state				<= c_state_pre_finish;
				end
				else begin
					ff_state				<= c_state_lrmm;
				end
			end

			//	LFMC command --------------------------------------------------
			c_state_lfmc: begin
				if( ff_transfer_ready ) begin
					//	書き込まれる（ff_transfer_ready = 0）まで待機
				end
				else begin
					ff_bit_count			<= 3'd7;
					ff_state				<= c_state_lfmc_read;
				end
			end
			c_state_lfmc_read: begin
				//	Copy source pixel value
				ff_source				<= ff_color[ ff_bit_count ] ? ff_fore_color : reg_text_back_color;
				//	Read the location of (DX, DY)
				ff_cache_vram_address	<= w_address_d;
				ff_cache_vram_valid		<= 1'b1;
				ff_cache_vram_write		<= 1'b0;
				ff_state				<= c_state_wait_rdata_en;
				ff_next_state			<= c_state_lfmc_make;
				ff_xsel					<= ff_dx[1:0];
			end
			c_state_lfmc_make: begin
				//	Write the location of (DX, DY)
				ff_cache_vram_address	<= w_address_d;
				ff_cache_vram_valid		<= 1'b1;
				ff_cache_vram_write		<= 1'b1;
				ff_cache_vram_wdata		<= w_destination;
				ff_count_valid			<= 1'b1;
				ff_state				<= c_state_lfmc_next;
			end
			c_state_lfmc_next: begin
				ff_count_valid			<= 1'b0;
				ff_bit_count			<= ff_bit_count - 3'd1;
				if( (ff_nx == 11'd0 || w_sx_overflow || w_dx_overflow) ) begin
					if( ff_ny == 11'd0 ) begin
						ff_state				<= c_state_pre_finish;
					end
					else begin
						ff_state				<= c_state_lfmc;
					end
				end
				else begin
					ff_state				<= c_state_lfmc_read;
				end
			end

			//	LFMM command --------------------------------------------------
			c_state_lfmm: begin
				//	Read the location of ff_font_address
				ff_cache_vram_address	<= ff_font_address;
				ff_cache_vram_valid		<= 1'b1;
				ff_cache_vram_write		<= 1'b0;
				ff_state				<= c_state_wait_rdata_en;
				ff_next_state			<= c_state_lfmm_load_source;
				ff_xsel					<= ff_font_address[1:0];
				ff_bit_count			<= 3'd7;
			end
			c_state_lfmm_load_source: begin
				//	Copy source bit pattern
				ff_bit_pattern			<= ff_read_byte;
				ff_state				<= c_state_lfmm_read;
			end
			c_state_lfmm_read: begin
				ff_source				<= ff_bit_pattern[ ff_bit_count ] ? ff_fore_color : reg_text_back_color;
				//	Read the location of (DX, DY)
				ff_cache_vram_address	<= w_address_d;
				ff_cache_vram_valid		<= 1'b1;
				ff_cache_vram_write		<= 1'b0;
				ff_state				<= c_state_wait_rdata_en;
				ff_next_state			<= c_state_lfmm_make;
				ff_xsel					<= ff_dx[1:0];
			end
			c_state_lfmm_make: begin
				//	Write the location of (DX, DY)
				ff_cache_vram_address	<= w_address_d;
				ff_cache_vram_valid		<= 1'b1;
				ff_cache_vram_write		<= 1'b1;
				ff_cache_vram_wdata		<= w_destination;
				ff_state				<= c_state_lfmm_next;
				ff_count_valid			<= 1'b1;
			end
			c_state_lfmm_next: begin
				ff_count_valid			<= 1'b0;
				ff_bit_count			<= ff_bit_count - 3'd1;
				if( (ff_nx == 11'd0 || w_dx_overflow) && ff_ny == 11'd0 ) begin
					ff_state				<= c_state_pre_finish;
				end
				else if( ff_bit_count != 3'd0 ) begin
					ff_state				<= c_state_lfmm_read;
				end
				else begin
					ff_state				<= c_state_lfmm;
				end
			end

			//	Wait RDATA_EN subroutine --------------------------------------
			c_state_wait_rdata_en: begin
				//	Wait until the results of the lead request arrive.
				if( w_cache_vram_rdata_en ) begin
					if( reg_command_high_speed_mode || ff_wait_count == 6'd0 ) begin
						//	Activate cache flush and wait for it to complete.
						ff_state				<= ff_next_state;
						ff_cache_flush_start	<= (ff_next_state == c_state_finish);
					end
					else begin
						//	Go to c_state_compatible_wait for compatible speed mode.
						ff_state				<= c_state_wait_counter;
						ff_wait_counter			<= { ff_wait_count, 2'b11 };
					end
				end
			end

			//	Wait counter --------------------------------------------------
			c_state_wait_counter: begin
				ff_cache_vram_valid		<= 1'b0;
				ff_count_valid			<= 1'b0;
				ff_wait_counter			<= ff_wait_counter - 8'd1;
				if( ff_wait_counter == 8'd0 ) begin
					ff_state				<= ff_next_state;
					ff_cache_flush_start	<= (ff_next_state == c_state_finish);
				end
			end

			//	Do Finish process ---------------------------------------------
			c_state_pre_finish: begin
				ff_count_valid			<= 1'b0;
				ff_state				<= c_state_finish;
				ff_cache_flush_start	<= 1'b1;
			end
			c_state_finish: begin
				//	Wait until the cache flush is complete.
				ff_cache_vram_valid		<= 1'b0;
				ff_cache_vram_write		<= 1'b0;
				ff_cache_vram_wdata		<= 8'd0;
				ff_cache_flush_start	<= 1'b0;
				if( w_cache_flush_end ) begin
					ff_state					<= c_state_idle;
					ff_border_detect_request	<= 1'b0;
				end
			end
			default: begin
				ff_state <= c_state_idle;
			end
			endcase
		end
	end

	// --------------------------------------------------------------------
	//	Logical operation
	// --------------------------------------------------------------------
	function [7:0] func_lop(
		input		[3:0]	logical_operation,
		input		[7:0]	source_pixel,
		input		[7:0]	destination_pixel
	);
		case( logical_operation )
		c_imp:		func_lop = source_pixel;
		c_and:		func_lop = source_pixel & destination_pixel;
		c_or:		func_lop = source_pixel | destination_pixel;
		c_eor:		func_lop = source_pixel ^ destination_pixel;
		c_not:		func_lop = ~source_pixel;
		c_rsv1:		func_lop = source_pixel;
		c_rsv2:		func_lop = source_pixel;
		c_rsv3:		func_lop = source_pixel;
		c_timp:		func_lop = (source_pixel == 8'd0) ? destination_pixel: source_pixel;
		c_tand:		func_lop = (source_pixel == 8'd0) ? destination_pixel: source_pixel & destination_pixel;
		c_tor:		func_lop = (source_pixel == 8'd0) ? destination_pixel: source_pixel | destination_pixel;
		c_teor:		func_lop = (source_pixel == 8'd0) ? destination_pixel: source_pixel ^ destination_pixel;
		c_tnot:		func_lop = (source_pixel == 8'd0) ? destination_pixel: ~source_pixel;
		c_trsv1:	func_lop = (source_pixel == 8'd0) ? destination_pixel: source_pixel;
		c_trsv2:	func_lop = (source_pixel == 8'd0) ? destination_pixel: source_pixel;
		c_trsv3:	func_lop = (source_pixel == 8'd0) ? destination_pixel: source_pixel;
		default:	func_lop = source_pixel;
		endcase
	endfunction

	assign w_lop_pixel		= func_lop( ff_logical_opration, ff_source, ff_read_pixel );

	function [7:0] func_destination(
		input		[1:0]	bpp,
		input		[1:0]	dx,
		input		[7:0]	write_pixel,
		input		[7:0]	base_pixel
	);
		case( bpp )
		c_bpp_2bit: begin
			case( dx )
			2'd0:	func_destination = {                  write_pixel[1:0], base_pixel[5:0] };
			2'd1:	func_destination = { base_pixel[7:6], write_pixel[1:0], base_pixel[3:0] };
			2'd2:	func_destination = { base_pixel[7:4], write_pixel[1:0], base_pixel[1:0] };
			2'd3:	func_destination = { base_pixel[7:2], write_pixel[1:0] };
			endcase
		end
		c_bpp_4bit: begin
			case( dx[0] )
			1'b0:	func_destination = {                  write_pixel[3:0], base_pixel[3:0] };
			1'b1:	func_destination = { base_pixel[7:4], write_pixel[3:0] };
			endcase
		end
		c_bpp_8bit: begin
			func_destination = write_pixel;
		end
		default: begin
			func_destination = write_pixel;
		end
		endcase
	endfunction

	assign w_destination	= func_destination( w_bpp, ff_dx[1:0], w_lop_pixel, ff_read_byte );

	// --------------------------------------------------------------------
	//	VRAM Access Cache
	// --------------------------------------------------------------------
	vdp_command_cache u_cache (
		.reset_n						( reset_n						),
		.clk							( clk							),
		.start							( ff_start						),
		.cache_vram_address				( ff_cache_vram_address			),
		.cache_vram_valid				( ff_cache_vram_valid			),
		.cache_vram_ready				( w_cache_vram_ready			),
		.cache_vram_write				( ff_cache_vram_write			),
		.cache_vram_wdata				( ff_cache_vram_wdata			),
		.cache_vram_rdata				( w_cache_vram_rdata			),
		.cache_vram_rdata_en			( w_cache_vram_rdata_en			),
		.cache_flush_start				( ff_cache_flush_start			),
		.cache_flush_end				( w_cache_flush_end				),
		.command_vram_address			( command_vram_address			),
		.command_vram_valid				( command_vram_valid			),
		.command_vram_ready				( command_vram_ready			),
		.command_vram_write				( command_vram_write			),
		.command_vram_wdata				( command_vram_wdata			),
		.command_vram_wdata_mask		( command_vram_wdata_mask		),
		.command_vram_rdata				( command_vram_rdata			),
		.command_vram_rdata_en			( command_vram_rdata_en			)
	);

	// --------------------------------------------------------------------
	//	Status registers
	// --------------------------------------------------------------------
	assign status_command_execute	= ff_command_execute;
	assign status_border_detect		= ff_border_detect;
	assign status_transfer_ready	= ff_transfer_ready;
	assign status_color				= ff_read_pixel;
	assign status_border_position	= ff_sx[8:0];
endmodule
