//
//	vdp_cpu_interface.v
//	CPU Interface for VDP
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

module vdp_cpu_interface (
	input				reset_n,
	input				clk,					//	42.95454MHz

	input	[2:0]		bus_address,
	input				bus_ioreq,
	input				bus_write,
	input				bus_valid,
	output				bus_ready,
	input	[7:0]		bus_wdata,
	output	[7:0]		bus_rdata,
	output				bus_rdata_en,

	output	[17:0]		vram_address,
	output				vram_write,
	output				vram_valid,
	input				vram_ready,
	output	[7:0]		vram_wdata,
	input	[7:0]		vram_rdata,
	input				vram_rdata_en,

	output				palette_valid,
	output		[7:0]	palette_num,
	output		[4:0]	palette_r,
	output		[4:0]	palette_g,
	output		[4:0]	palette_b,

	output				int_n,
	input				intr_line,					//	pulse
	input				intr_frame,					//	pulse
	input				intr_command_end,			//	pulse

	output				clear_sprite_collision,		//	pulse
	input				sprite_collision,
	output				clear_sprite_collision_xy,	//	pulse
	input		[8:0]	sprite_collision_x,
	input		[9:0]	sprite_collision_y,
	input				sprite_overmap,
	input		[4:0]	sprite_overmap_id,
	output				clear_border_detect,		//	pulse
	output				read_color,					//	pulse

	output				register_write,
	output		[5:0]	register_num,
	output		[7:0]	register_data,

	input				status_command_execute,		//	S#2 bit0
	input				status_field,				//	S#2 bit1
	input				status_border_detect,		//	S#2 bit4
	input				status_hsync,				//	S#2 bit5
	input				status_vsync,				//	S#2 bit6
	input				status_transfer_ready,		//	S#2 bit7
	input		[7:0]	status_color,				//	S#7
	input		[8:0]	status_border_position,		//	S#8, S#9
	input				vram_access_mask,			//	MXC

	output	[4:0]		reg_screen_mode,
	output				reg_sprite_magify,
	output				reg_sprite_16x16,
	output				reg_display_on,
	output	[17:10]		reg_pattern_name_table_base,
	output	[17:6]		reg_color_table_base,
	output	[17:11]		reg_pattern_generator_table_base,
	output	[17:7]		reg_sprite_attribute_table_base,
	output	[17:11]		reg_sprite_pattern_generator_table_base,
	output	[7:0]		reg_backdrop_color,
	output				reg_sprite_disable,
	output				reg_color0_opaque,
	output				reg_50hz_mode,
	output				reg_interleaving_mode,
	output				reg_interlace_mode,
	output				reg_212lines_mode,
	output	[7:0]		reg_text_back_color,
	output	[7:0]		reg_blink_period,
	output	[7:0]		reg_display_adjust,
	output	[7:0]		reg_interrupt_line,
	output	[7:0]		reg_vertical_offset,
	output				reg_scroll_planes,
	output				reg_left_mask,
	output				reg_yjk_mode,
	output				reg_yae_mode,
	output				reg_command_enable,
	output				reg_sprite_priority_shuffle,
	output	[2:0]		reg_horizontal_offset_l,
	output	[8:3]		reg_horizontal_offset_h,
	output				reg_command_high_speed_mode,
	output				reg_sprite_nonR23_mode,
	output				reg_interrupt_line_nonR23_mode,
	output				reg_sprite_mode3,
	output				reg_ext_palette_mode,
	output				reg_ext_command_mode,
	output				reg_vram256k_mode,
	output				reg_sprite16_mode,
	output				reg_flat_interlace_mode,

	output				pulse0,
	output				pulse1,
	output				pulse2,
	output				pulse3,
	output				pulse4,
	output				pulse5,
	output				pulse6,
	output				pulse7
);
	localparam	[4:0]	c_vdp_id			= 5'b00011;
	reg					ff_bus_ioreq;
	reg					ff_bus_write;
	reg					ff_bus_valid;
	reg					ff_bus_ready;
	reg		[7:0]		ff_bus_wdata;
	reg		[7:0]		ff_status_register;

	reg					ff_port0;
	reg					ff_port1;
	reg					ff_port2;
	reg					ff_port3;
	reg					ff_port4;
	wire				w_write;
	wire				w_read;
	reg		[7:0]		ff_bus_rdata;
	reg					ff_bus_rdata_en;
	reg		[4:0]		ff_screen_mode;
	reg					ff_line_interrupt_enable = 1'b0;
	reg					ff_frame_interrupt_enable = 1'b0;
	reg					ff_command_end_interrupt_enable = 1'b0;
	reg					ff_sprite_magify;
	reg					ff_sprite_16x16;
	reg					ff_display_on;
	reg		[17:10]		ff_pattern_name_table_base;
	reg		[17:6]		ff_color_table_base;
	reg		[17:11]		ff_pattern_generator_table_base;
	reg		[17:7]		ff_sprite_attribute_table_base;
	reg		[17:11]		ff_sprite_pattern_generator_table_base;
	reg		[7:0]		ff_backdrop_color;
	reg					ff_sprite_disable;
	reg					ff_vram_type;
	reg					ff_color0_opaque;
	reg					ff_50hz_mode;
	reg					ff_interleaving_mode;
	reg					ff_interlace_mode;
	reg					ff_212lines_mode;
	reg		[7:0]		ff_text_back_color;
	reg		[7:0]		ff_blink_period;
	reg		[3:0]		ff_status_register_pointer;
	reg		[7:0]		ff_color_palette_address;
	reg		[1:0]		ff_color_palette_phase;
	reg					ff_color_palette_valid;
	reg		[4:0]		ff_palette_r;
	reg		[4:0]		ff_palette_g;
	reg		[4:0]		ff_palette_b;
	reg		[5:0]		ff_register_pointer;
	reg					ff_not_increment;
	reg		[7:0]		ff_display_adjust;
	reg		[7:0]		ff_interrupt_line;
	reg		[7:0]		ff_vertical_offset;
	reg					ff_scroll_planes;
	reg					ff_left_mask;
	reg					ff_yjk_mode;
	reg					ff_yae_mode;
	reg					ff_command_enable;
	reg					ff_sprite_priority_shuffle;
	reg		[2:0]		ff_horizontal_offset_l;
	reg		[8:3]		ff_horizontal_offset_h;
	reg					ff_command_high_speed_mode;
	reg					ff_sprite_nonR23_mode;
	reg					ff_interrupt_line_nonR23_mode;
	reg					ff_sprite_mode3;
	reg					ff_ext_palette_mode;
	reg					ff_ext_command_mode;
	reg					ff_vram256k_mode;
	reg					ff_sprite16_mode;
	reg					ff_flat_interlace_mode;

	reg					ff_2nd_access;
	reg		[7:0]		ff_1st_byte;
	reg					ff_register_write;
	reg					ff_port3_write;
	reg		[5:0]		ff_register_num;
	reg		[17:0]		ff_vram_address;
	wire	[17:0]		w_next_vram_address;
	reg					ff_vram_address_write;		//	アドレス設定が書き込み用に設定されたかどうか
	reg					ff_vram_write;				//	実際のアクセスが書き込みアクセスかどうか
	reg		[7:0]		ff_vram_wdata;
	reg					ff_vram_address_inc;		//	アドレスインクリメント要求
	reg					ff_vram_valid;
	reg					ff_busy;

	reg					ff_line_interrupt = 1'b0;
	reg					ff_frame_interrupt = 1'b0;
	reg					ff_command_end_interrupt = 1'b0;

	assign pulse0		= 1'b0;										// red
	assign pulse1		= ff_vram_valid;							// green
	assign pulse2		= ff_vram_address_inc;						// blue
	assign pulse3		= (bus_valid && bus_address == 3'b000);		// yellow
	assign pulse4		= (bus_valid && bus_address == 3'b001);		// cyan
	assign pulse5		= (bus_valid && bus_address == 3'b010);		// purple
	assign pulse6		= (bus_valid && bus_address == 3'b011);		// pink
	assign pulse7		= 1'b0;

	// --------------------------------------------------------------------
	//	Latch
	// --------------------------------------------------------------------
	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_bus_ioreq	<= 1'b0;
			ff_bus_write	<= 1'b0;
			ff_bus_wdata	<= 1'b0;
			ff_port0		<= 1'b0;
			ff_port1		<= 1'b0;
			ff_port2		<= 1'b0;
			ff_port3		<= 1'b0;
			ff_port4		<= 1'b0;
			ff_bus_valid	<= 1'b0;
			ff_bus_ready	<= 1'b1;
		end
		else if( bus_valid && ff_bus_ready ) begin
			ff_bus_ioreq	<= bus_ioreq;
			ff_bus_write	<= bus_write;
			ff_bus_wdata	<= bus_wdata;
			ff_port0		<= (!bus_address[2] && !bus_address[1] && !bus_address[0]);
			ff_port1		<= (!bus_address[2] && !bus_address[1] &&  bus_address[0]);
			ff_port2		<= (!bus_address[2] &&  bus_address[1] && !bus_address[0]);
			ff_port3		<= (!bus_address[2] &&  bus_address[1] &&  bus_address[0]);
			ff_port4		<= ( bus_address[2] && !bus_address[1] && !bus_address[0]);
			ff_bus_valid	<= 1'b1;
			ff_bus_ready	<= 1'b0;
		end
		else begin
			ff_bus_valid	<= 1'b0;
			ff_bus_ready	<= bus_ioreq;
		end
	end

	assign bus_ready	= ff_bus_ready & ~ff_busy;

	assign w_write		= ff_bus_valid &  ff_bus_write & ~ff_busy;
	assign w_read		= ff_bus_valid & ~ff_bus_write & ~ff_busy;

	// --------------------------------------------------------------------
	//	VRAM Read/Write access
	// --------------------------------------------------------------------
	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_2nd_access			<= 1'b0;
			ff_1st_byte				<= 8'd0;
			ff_vram_address_write	<= 1'b0;
			ff_register_write		<= 1'b0;
			ff_port3_write			<= 1'b0;
			ff_register_num			<= 6'd0;
		end
		else if( ff_busy ) begin
			//	hold
		end
		else if( w_write && ff_port1 ) begin
			ff_2nd_access	<= ~ff_2nd_access;
			if( !ff_2nd_access ) begin
				//	1st write access
				ff_1st_byte		<= ff_bus_wdata;
			end
			else begin
				//	2nd write access
				ff_register_num	<= ff_bus_wdata[5:0];
				if( !ff_bus_wdata[7] ) begin
					//	Set VRAM Address
					ff_register_write		<= 1'b0;
					ff_port3_write			<= 1'b0;
					ff_vram_address_write	<= ff_bus_wdata[6];
				end
				else begin
					ff_register_write		<= 1'b1;
					ff_port3_write			<= 1'b0;
				end
			end
		end
		else if( w_write && ff_port3 ) begin
			ff_register_write	<= 1'b1;
			ff_port3_write		<= 1'b1;
			ff_register_num		<= ff_register_pointer;
			ff_1st_byte			<= ff_bus_wdata;
		end
		else begin
			ff_register_write	<= 1'b0;
			ff_port3_write		<= 1'b0;
		end
	end

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_register_pointer	<= 5'd0;
			ff_not_increment	<= 1'b0;
		end
		else if( w_write && ff_port3 ) begin
			if( !ff_not_increment ) begin
				ff_register_pointer <= ff_register_pointer + 5'd1;
			end
		end
		else if( ff_register_write ) begin
			if( ff_register_num == 8'd17 && !ff_port3_write ) begin
				//	R#17 = [AII][N/A][R5][R4][R3][R2][R1][R0]
				ff_register_pointer	<= ff_1st_byte[5:0];
				ff_not_increment	<= ff_1st_byte[7];
			end
		end
	end

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_vram_valid		<= 1'b0;
			ff_vram_write		<= 1'b0;
			ff_vram_wdata		<= 8'd0;
			ff_vram_address_inc	<= 1'b0;
			ff_busy				<= 1'b0;
		end
		else if( vram_rdata_en ) begin
			ff_vram_address_inc <= 1'b1;
		end
		else if( ff_vram_address_inc ) begin
			ff_vram_address_inc	<= 1'b0;
			ff_busy				<= 1'b0;
		end
		else if( ff_vram_valid ) begin
			if( vram_ready ) begin
				ff_vram_valid		<= 1'b0;
				ff_vram_address_inc <= ff_bus_write;
			end
		end
		else if( w_write && ff_port0 ) begin
			if( vram_access_mask ) begin
				ff_vram_valid		<= 1'b0;
				ff_busy				<= 1'b1;
				ff_vram_address_inc <= 1'b1;
			end
			else begin
				ff_vram_valid		<= 1'b1;
				ff_busy				<= 1'b1;
				ff_vram_address_inc <= 1'b0;
			end
			ff_vram_write		<= 1'b1;
			ff_vram_wdata		<= ff_bus_wdata;
		end
		else if( w_read && ff_port0 ) begin
			ff_vram_valid		<= 1'b1;
			ff_vram_write		<= 1'b0;
			ff_vram_wdata		<= 8'd0;
			ff_busy				<= 1'b1;
		end
	end

	assign w_next_vram_address	= ff_vram_address + 18'd1;

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_vram_address	<= 18'd0;
		end
		else if( ff_vram_address_inc ) begin		//	1clock pulse
			if( (ff_screen_mode[4:3] == 2'b00) || !ff_vram_type ) begin
				ff_vram_address[13:0]	<= w_next_vram_address[13:0];
			end
			else begin
				ff_vram_address			<= w_next_vram_address;
			end
		end
		else if( ff_register_write && ff_register_num == 6'd14 ) begin
			//	R#14 = [N/A][N/A][N/A][N/A][A17][A16][A15][A14]
			if( !ff_vram_type ) begin
				ff_vram_address[17:14]	<= 4'd0;
			end
			else begin
				ff_vram_address[17:14]	<= ff_1st_byte[3:0];
			end
		end
		else if( w_write && ff_port1 ) begin
			if( ff_2nd_access ) begin
				//	2nd write access
				case( ff_bus_wdata[7:6] )
				2'd0:			//	Set VRAM Read Address
					begin
						ff_vram_address[7:0]	<= ff_1st_byte;
						ff_vram_address[13:8]	<= ff_bus_wdata[5:0];
					end
				2'd1:			//	Set VRAM Write Address
					begin
						ff_vram_address[7:0]	<= ff_1st_byte;
						ff_vram_address[13:8]	<= ff_bus_wdata[5:0];
					end
				default:
					begin
						//	none
					end
				endcase
			end
		end
	end

	// --------------------------------------------------------------------
	//	Control registers
	// --------------------------------------------------------------------
	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_screen_mode <= 5'd0;
			ff_line_interrupt_enable <= 1'b0;
			ff_sprite_magify <= 1'b0;
			ff_sprite_16x16 <= 1'b0;
			ff_frame_interrupt_enable <= 1'b0;
			ff_display_on <= 1'b0;
			ff_pattern_name_table_base <= 8'd0;
			ff_color_table_base <= 12'd0;
			ff_pattern_generator_table_base <= 7'd0;
			ff_sprite_attribute_table_base <= 11'd0;
			ff_sprite_pattern_generator_table_base <= 7'd0;
			ff_backdrop_color <= 8'd0;
			ff_sprite_disable <= 1'b0;
			ff_vram_type <= 1'b1;
			ff_color0_opaque <= 1'b0;
			ff_50hz_mode <= 1'b0;
			ff_interleaving_mode <= 1'b0;
			ff_interlace_mode <= 1'b0;
			ff_212lines_mode <= 1'b0;
			ff_text_back_color <= 8'd0;
			ff_blink_period <= 8'd0;
			ff_status_register_pointer <= 4'd0;
			ff_display_adjust <= 8'd0;
			ff_interrupt_line <= 8'd0;
			ff_vertical_offset <= 8'd0;
			ff_scroll_planes <= 1'b0;
			ff_left_mask <= 1'b0;
			ff_yjk_mode <= 1'b0;
			ff_yae_mode <= 1'b0;
			ff_command_enable <= 1'b0;
			ff_sprite_priority_shuffle <= 1'b0;
			ff_horizontal_offset_l <= 3'd0;
			ff_horizontal_offset_h <= 6'd0;
			ff_command_high_speed_mode <= 1'b0;
			ff_sprite_nonR23_mode <= 1'b0;
			ff_interrupt_line_nonR23_mode <= 1'b0;
			ff_sprite_mode3 <= 1'b0;
			ff_ext_palette_mode <= 1'b0;
			ff_ext_command_mode <= 1'b0;
			ff_vram256k_mode <= 1'b0;
			ff_sprite16_mode <= 1'b0;
			ff_command_end_interrupt_enable <= 1'b0;
			ff_flat_interlace_mode <= 1'b0;
		end
		else if( ff_register_write ) begin
			case( ff_register_num )
			6'd0:	//	R#0 = [N/A][N/A][N/A][IE1][M5][M4][M3][N/A]
				begin
					ff_screen_mode[4:2] <= ff_1st_byte[3:1];
					ff_line_interrupt_enable <= ff_1st_byte[4];
				end
			6'd1:	//	R#1 = [N/A][BL][IE0][M1][M2][N/A][SI][MAG]
				begin
					ff_sprite_magify <= ff_1st_byte[0];
					ff_sprite_16x16 <= ff_1st_byte[1];
					ff_screen_mode[1] <= ff_1st_byte[3];
					ff_screen_mode[0] <= ff_1st_byte[4];
					ff_frame_interrupt_enable <= ff_1st_byte[5];
					ff_display_on <= ff_1st_byte[6];
				end
			6'd2:	//	R#2 = [A17][A16][A15][A14][A13][A12][A11][A10]
				begin
					ff_pattern_name_table_base <= ff_1st_byte;
				end
			6'd3:	//	R#3 = [A13][A12][A11][A10][A9][A8][A7][A6]
				begin
					ff_color_table_base[13:6] <= ff_1st_byte;
				end
			6'd4:	//	R#4 = [N/A][A17][A16][A15][A14][A13][A12][A11]
				begin
					ff_pattern_generator_table_base <= ff_1st_byte[6:0];
				end
			6'd5:	//	R#5 = [A14][A13][A12][A11][A10][A9][A8][A7]
				begin
					ff_sprite_attribute_table_base[14:7] <= ff_1st_byte;
				end
			6'd6:	//	R#6 = [N/A][A17][A16][A15][A14][A13][A12][A11]
				begin
					ff_sprite_pattern_generator_table_base <= ff_1st_byte[6:0];
				end
			6'd7:	//	R#7 = [BD7][BD6][BD5][BD4][BD3][BD2][BD1][BD0]
				begin
					ff_backdrop_color <= ff_1st_byte;
				end
			6'd8:	//	R#8 = [N/A][N/A][TP][N/A][VR][N/A][SPD][N/A]
				begin
					ff_sprite_disable <= ff_1st_byte[1];
					ff_vram_type <= ff_1st_byte[3];
					ff_color0_opaque <= ff_1st_byte[5];
				end
			6'd9:	//	R#9 = [LN][N/A][N/A][N/A][IL][EO][NT][N/A]
				begin
					ff_50hz_mode <= ff_1st_byte[1];
					ff_interleaving_mode <= ff_1st_byte[2];
					ff_interlace_mode <= ff_1st_byte[3];
					ff_212lines_mode <= ff_1st_byte[7];
				end
			6'd10:	//	R#10 = [N/A][N/A][N/A][N/A][A17][A16][A15][A14]
				begin
					ff_color_table_base[17:14] <= ff_1st_byte[3:0];
				end
			6'd11:	//	R#11 = [N/A][N/A][N/A][N/A][N/A][A17][A16][A15]
				begin
					ff_sprite_attribute_table_base[17:15] <= ff_1st_byte[2:0];
				end
			6'd12:	//	R#12 = [T23][T22][T1][T20][BC3][BC2][BC1][BC0]
				begin
					ff_text_back_color <= ff_1st_byte;
				end
			6'd13:	//	R#13 = [CN3][CN2][CN1][CN0][CF3][CF2][CF1][CF0]
				begin
					ff_blink_period <= ff_1st_byte;
				end

			//	6'd14 は、ff_vram_address の always文にある

			6'd15:	//	R#15 = [N/A][N/A][N/A][N/A][S3][S2][S1][S0]
				begin
					ff_status_register_pointer <= ff_1st_byte[3:0];
				end

			//	6'd16 は、color palette interface の always文にある

			//	6'd17 は、register pointer の always文にある

			8'd18:	//	R#18 = [V3][V2][V1][V0][H3][H2][H1][H0]
				begin
					ff_display_adjust <= ff_1st_byte;
				end
			8'd19:	//	R#19 = [IL7][IL6][IL5][IL4][IL3][IL2][IL1][IL0]
				begin
					ff_interrupt_line <= ff_1st_byte;
				end
			8'd20:	//	R#20 = [S16][EVR][ECOM][EPAL][SCOL][ILNS][SVNS][HS]
				begin
					ff_command_high_speed_mode <= ff_1st_byte[0];
					ff_sprite_nonR23_mode <= ff_1st_byte[1];
					ff_interrupt_line_nonR23_mode <= ff_1st_byte[2];
					ff_sprite_mode3 <= ff_1st_byte[3];
					ff_ext_palette_mode <= ff_1st_byte[4];
					ff_ext_command_mode <= ff_1st_byte[5];
					ff_vram256k_mode <= ff_1st_byte[6];
					ff_sprite16_mode <= ff_1st_byte[7];
				end
			8'd21:	//	R#21 = [CEIE][N/A][N/A][N/A][N/A][N/A][N/A][N/A]
				begin
					ff_flat_interlace_mode <= ff_1st_byte[6];
					ff_command_end_interrupt_enable <= ff_1st_byte[7];
				end
			8'd23:	//	R#23 = [DO7][DO6][DO5][DO4][DO3][DO2][DO1][DO0]
				begin
					ff_vertical_offset <= ff_1st_byte;
				end
			8'd25:	//	R#25 = [N/A][CMD][N/A][YAE][YJK][N/A][MSK][SP2]
				begin
					ff_scroll_planes <= ff_1st_byte[0];
					ff_left_mask <= ff_1st_byte[1];
					ff_yjk_mode <= ff_1st_byte[3];
					ff_yae_mode <= ff_1st_byte[4];
					ff_command_enable <= ff_1st_byte[6];
					ff_sprite_priority_shuffle <= ff_1st_byte[7];
				end
			8'd26:	//	R#26 = [N/A][N/A][HO8][HO7][HO6][HO5][HO4][HO3]
				begin
					ff_horizontal_offset_h <= ff_1st_byte[5:0];
				end
			8'd27:	//	R#27 = [N/A][N/A][N/A][N/A][N/A][HO2][HO1][HO0]
				begin
					ff_horizontal_offset_l <= ff_1st_byte[2:0];
				end
			default:
				begin
					//	hold
				end
			endcase
		end
	end

	// --------------------------------------------------------------------
	//	Color palette interface
	// --------------------------------------------------------------------
	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_color_palette_address	<= 8'd0;
			ff_color_palette_valid		<= 1'b0;
			ff_color_palette_phase		<= 2'd0;
		end
		else if( ff_register_write ) begin
			if( ff_register_num == 6'd16 ) begin
				//	R#16 = [C7][C6][C5][C4][C3][C2][C1][C0]
				if( ff_ext_palette_mode ) begin
					ff_color_palette_address	<= ff_1st_byte;
				end
				else begin
					ff_color_palette_address	<= { 4'd0, ff_1st_byte[3:0] };
				end
				ff_color_palette_phase		<= 2'd0;
			end
		end
		else if( w_write && ff_port2 ) begin
			if( ff_ext_palette_mode ) begin
				if( ff_color_palette_phase == 2'd0 ) begin
					//	P#2 = [N/A][N/A][N/A][R][R][R][R][R]
					ff_palette_r				<= ff_bus_wdata[4:0];
					ff_color_palette_phase		<= 2'd1;
					ff_color_palette_valid		<= 1'b0;
				end
				else if( ff_color_palette_phase == 2'd1 ) begin
					//	P#2 = [N/A][N/A][N/A][G][G][G][G][G]
					ff_palette_g				<= ff_bus_wdata[4:0];
					ff_color_palette_phase		<= 2'd2;
					ff_color_palette_valid		<= 1'b0;
				end
				else begin
					//	P#2 = [N/A][N/A][N/A][B][B][B][B][B]
					ff_palette_b				<= ff_bus_wdata[4:0];
					ff_color_palette_phase		<= 2'd0;
					ff_color_palette_valid		<= 1'b1;
				end
			end
			else begin
				if( ff_color_palette_phase == 2'd0 ) begin
					//	P#2 = [0][R][R][R][0][B][B][B]
					ff_palette_r				<= { ff_bus_wdata[6:4], 2'd0 };
					ff_palette_b				<= { ff_bus_wdata[2:0], 2'd0 };
					ff_color_palette_phase		<= 2'd1;
					ff_color_palette_valid		<= 1'b0;
				end
				else begin
					//	P#2 = [0][0][0][0][0][G][G][G]
					ff_palette_g				<= { ff_bus_wdata[2:0], 2'd0 };
					ff_color_palette_phase		<= 2'd0;
					ff_color_palette_valid		<= 1'b1;
				end
			end
		end
		else if( ff_color_palette_valid ) begin
			if( ff_ext_palette_mode ) begin
				ff_color_palette_address		<= ff_color_palette_address + 8'd1;
			end
			else begin
				ff_color_palette_address[3:0]	<= ff_color_palette_address[3:0] + 4'd1;
				ff_color_palette_address[7:4]	<= 4'd0;
			end
			ff_color_palette_valid		<= 1'b0;
		end
	end

	// --------------------------------------------------------------------
	//	Read data latch
	// --------------------------------------------------------------------

	always @( posedge clk ) begin
		case( ff_status_register_pointer )
		4'd0:		ff_status_register <= { ff_frame_interrupt, sprite_overmap, sprite_collision, sprite_overmap_id };
		4'd1:		ff_status_register <= { 2'd0, c_vdp_id, ff_line_interrupt };
		4'd2:		ff_status_register <= { status_transfer_ready, status_vsync, status_hsync, status_border_detect, 2'b11, status_field, status_command_execute };
		4'd3:		ff_status_register <= sprite_collision_x[7:0];
		4'd4:		ff_status_register <= { 7'b1111111, sprite_collision_x[8] };
		4'd5:		ff_status_register <= sprite_collision_y[7:0];
		4'd6:		ff_status_register <= { 6'b111111, sprite_collision_y[9:8] };
		4'd7:		ff_status_register <= status_color;
		4'd8:		ff_status_register <= status_border_position[7:0];
		4'd9:		ff_status_register <= { 7'b1111111, status_border_position[8] };
		default:	ff_status_register <= 8'b11111111;
		endcase
	end

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_bus_rdata_en		<= 1'b0;
		end
		else if( vram_rdata_en ) begin
			if( vram_access_mask ) begin
				ff_bus_rdata		<= 8'b11111111;
			end
			else begin
				ff_bus_rdata		<= vram_rdata;
			end
			ff_bus_rdata_en		<= 1'b1;
		end
		else if( w_read ) begin
			if( ff_port0 ) begin
				ff_bus_rdata	<= 8'b11111111;
				ff_bus_rdata_en	<= 1'b0;
			end
			else if( ff_port1 ) begin
				ff_bus_rdata	<= ff_status_register;
				ff_bus_rdata_en	<= 1'b1;
			end
			else if( ff_port4 ) begin
				ff_bus_rdata	<= { 5'd0, ff_command_end_interrupt, ff_line_interrupt, ff_frame_interrupt };
				ff_bus_rdata_en	<= 1'b1;
			end
			else begin
				ff_bus_rdata	<= 8'b11111111;
				ff_bus_rdata_en	<= 1'b1;
			end
		end
		else begin
			ff_bus_rdata	<= 8'd0;
			ff_bus_rdata_en	<= 1'b0;
		end
	end

	assign clear_sprite_collision		= (w_read && ff_port1 && ff_status_register_pointer == 4'd0);
	assign clear_sprite_collision_xy	= (w_read && ff_port1 && ff_status_register_pointer == 4'd5);
	assign read_color					= (w_read && ff_port1 && ff_status_register_pointer == 4'd7);
	assign clear_border_detect			= (w_read && ff_port1 && ff_status_register_pointer == 4'd9);

	// --------------------------------------------------------------------
	//	Interrupt
	// --------------------------------------------------------------------
	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_frame_interrupt			<= 1'b0;
			ff_line_interrupt			<= 1'b0;
			ff_command_end_interrupt	<= 1'b0;
		end
		else if( w_read && ff_port1 ) begin
			if( ff_status_register_pointer == 4'd0 ) begin
				//	Clear frame interrupt flag
				ff_frame_interrupt <= 1'b0;
			end
			else if( ff_status_register_pointer == 4'd1 ) begin
				//	Clear line interrupt flag
				ff_line_interrupt <= 1'b0;
			end
			else if( ff_status_register_pointer == 4'd10 ) begin
				//	Clear line interrupt flag
				ff_command_end_interrupt <= 1'b0;
			end
		end
		else if( w_write && ff_port4 ) begin
			if( ff_bus_wdata[0] == 1'b1 ) begin
				//	Clear frame interrupt flag
				ff_frame_interrupt <= 1'b0;
			end
			if( ff_bus_wdata[1] == 1'b1 ) begin
				//	Clear line interrupt flag
				ff_line_interrupt <= 1'b0;
			end
			if( ff_bus_wdata[2] == 1'b1 ) begin
				//	Clear line interrupt flag
				ff_command_end_interrupt <= 1'b0;
			end
		end
		else begin
			if( ff_frame_interrupt_enable == 1'b0 ) begin
				ff_frame_interrupt <= 1'b0;
			end
			else if( intr_frame ) begin
				//	Happend line interrupt
				ff_frame_interrupt <= 1'b1;
			end

			if( ff_line_interrupt_enable == 1'b0 ) begin
				ff_line_interrupt <= 1'b0;
			end
			else if( intr_line ) begin
				//	Happend line interrupt
				ff_line_interrupt <= 1'b1;
			end

			if( ff_command_end_interrupt_enable == 1'b0 ) begin
				ff_command_end_interrupt <= 1'b0;
			end
			else if( intr_command_end ) begin
				//	Happend line interrupt
				ff_command_end_interrupt <= 1'b1;
			end
		end
	end

	assign int_n = ~(ff_line_interrupt | ff_frame_interrupt | ff_command_end_interrupt);

	// --------------------------------------------------------------------
	//	Output assignment
	// --------------------------------------------------------------------
	assign register_write							= ff_register_write;
	assign register_num								= ff_register_num;
	assign register_data							= ff_1st_byte;

	assign bus_rdata								= ff_bus_rdata;
	assign bus_rdata_en								= ff_bus_rdata_en;

	assign vram_address								= ff_vram_address;
	assign vram_write								= ff_vram_write;
	assign vram_valid								= ff_vram_valid;
	assign vram_wdata								= ff_vram_wdata;

	assign palette_valid							= ff_color_palette_valid;
	assign palette_num								= ff_color_palette_address;
	assign palette_r								= ff_palette_r;
	assign palette_g								= ff_palette_g;
	assign palette_b								= ff_palette_b;

	assign reg_screen_mode							= ff_screen_mode;
	assign reg_sprite_magify						= ff_sprite_magify;
	assign reg_sprite_16x16							= ff_sprite_16x16;
	assign reg_display_on							= ff_display_on;
	assign reg_pattern_name_table_base				= ff_pattern_name_table_base;
	assign reg_color_table_base						= ff_color_table_base;
	assign reg_pattern_generator_table_base			= ff_pattern_generator_table_base;
	assign reg_sprite_attribute_table_base			= ff_sprite_attribute_table_base;
	assign reg_sprite_pattern_generator_table_base	= ff_sprite_pattern_generator_table_base;
	assign reg_backdrop_color						= ff_backdrop_color;
	assign reg_sprite_disable						= ff_sprite_disable;
	assign reg_color0_opaque						= ff_color0_opaque;
	assign reg_50hz_mode							= ff_50hz_mode;
	assign reg_interleaving_mode					= ff_interleaving_mode;
	assign reg_interlace_mode						= ff_interlace_mode;
	assign reg_212lines_mode						= ff_212lines_mode;
	assign reg_text_back_color						= ff_text_back_color;
	assign reg_blink_period							= ff_blink_period;
	assign reg_display_adjust						= ff_display_adjust;
	assign reg_interrupt_line						= ff_interrupt_line;
	assign reg_vertical_offset						= ff_vertical_offset;
	assign reg_scroll_planes						= ff_scroll_planes;
	assign reg_left_mask							= ff_left_mask;
	assign reg_yjk_mode								= ff_yjk_mode;
	assign reg_yae_mode								= ff_yae_mode;
	assign reg_command_enable						= ff_command_enable;
	assign reg_sprite_priority_shuffle				= ff_sprite_priority_shuffle;
	assign reg_horizontal_offset_l					= ff_horizontal_offset_l;
	assign reg_horizontal_offset_h					= ff_horizontal_offset_h;
	assign reg_command_high_speed_mode				= ff_command_high_speed_mode;
	assign reg_sprite_nonR23_mode					= ff_sprite_nonR23_mode;
	assign reg_interrupt_line_nonR23_mode			= ff_interrupt_line_nonR23_mode;
	assign reg_sprite_mode3							= ff_sprite_mode3;
	assign reg_ext_palette_mode						= ff_ext_palette_mode;
	assign reg_ext_command_mode						= ff_ext_command_mode;
	assign reg_vram256k_mode						= ff_vram256k_mode;
	assign reg_sprite16_mode						= ff_sprite16_mode;
	assign reg_flat_interlace_mode					= ff_flat_interlace_mode;
endmodule
