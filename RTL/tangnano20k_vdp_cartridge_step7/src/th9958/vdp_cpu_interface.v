//
//	vdp_cpu_interface.v
//	CPU Interface for Timing Control
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

	input				initial_busy,
	input	[1:0]		bus_address,
	input				bus_ioreq,
	input				bus_write,
	input				bus_valid,
	input	[7:0]		bus_wdata,
	output	[7:0]		bus_rdata,
	output				bus_rdata_en,

	output	[4:0]		reg_screen_mode,
	output				reg_sprite_magify,
	output				reg_sprite_16x16,
	output				reg_display_on,
	output	[16:10]		reg_pattern_name_table_base,
	output	[16:6]		reg_color_table_base,
	output	[16:11]		reg_pattern_generator_table_base,
	output	[16:9]		reg_sprite_attribute_table_base,
	output	[16:11]		reg_sprite_pattern_generator_table_base,
	output	[7:0]		reg_backdrop_color,
	output				reg_sprite_disable,
	output				reg_color0_opaque,
	output				reg_50hz_mode,
	output				reg_interleaving_mode,
	output				reg_interlace_mode,
	output				reg_212lines_mode,
	output	[7:0]		reg_text_back_color,
	output	[7:0]		reg_blink_period,
	output	[3:0]		reg_color_palette_address,
	output	[7:0]		reg_display_adjust,
	output	[7:0]		reg_interrupt_line,
	output	[7:0]		reg_vertical_offset,
	output				reg_scroll_planes,
	output				reg_left_mask,
	output				reg_yjk_mode,
	output				reg_yae_mode,
	output				reg_command_enable,
	output	[8:0]		reg_horizontal_offset
);
	reg		[4:0]		ff_screen_mode;
	reg					ff_line_interrupt_enable;
	reg					ff_frame_interrupt_enable;
	reg					ff_sprite_magify;
	reg					ff_sprite_16x16;
	reg					ff_display_on;
	reg		[16:10]		ff_pattern_name_table_base;
	reg		[16:6]		ff_color_table_base;
	reg		[16:11]		ff_pattern_generator_table_base;
	reg		[16:9]		ff_sprite_attribute_table_base;
	reg		[16:11]		ff_sprite_pattern_generator_table_base;
	reg		[7:0]		ff_backdrop_color;
	reg					ff_sprite_disable;
	reg					ff_color0_opaque;
	reg					ff_50hz_mode;
	reg					ff_interleaving_mode;
	reg					ff_interlace_mode;
	reg					ff_212lines_mode;
	reg		[7:0]		ff_text_back_color;
	reg		[7:0]		ff_blink_period;
	reg		[3:0]		ff_status_register_pointer;
	reg		[3:0]		ff_color_palette_address;
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
	reg		[8:0]		ff_horizontal_offset

	reg					ff_2nd_access;
	reg		[7:0]		ff_1st_byte;
	reg					ff_write;
	reg		[5:0]		ff_register_num;
	reg		[16:0]		ff_vram_address;

	// --------------------------------------------------------------------
	//	Write access
	// --------------------------------------------------------------------
	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_2nd_access		<= 1'b0;
			ff_1st_byte			<= 8'd0;
			ff_register_write	<= 1'b0;
			ff_register_num		<= 6'd0;
		end
		else if( bus_valid && bus_write && bus_address == 2'd1 ) begin
			if( !ff_2nd_access ) begin
				//	1st write access
				ff_1st_byte		<= bus_wdata;
				ff_2nd_access	<= 1'b1;
				ff_vram_address	<= 17'd0;
			end
			else begin
				//	2nd write access
				ff_2nd_access	<= 1'b0;
				case( bus_wdata[7:6] )
				2'd0:			//	Set VRAM Read Address
					begin
						ff_vram_address[7:0]	<= ff_1st_byte;
						ff_vram_address[13:8]	<= bus_wdata[5:0];
					end
				2'd1:			//	Set VRAM Write Address
					begin
						ff_vram_address[7:0]	<= ff_1st_byte;
						ff_vram_address[13:8]	<= bus_wdata[5:0];
					end
				2'd2, 2'd3:		//	Direct Register Write Access
					begin
						ff_register_write		<= 1'b1;
						ff_register_num			<= bus_wdata[5:0];
					end
				default:
					begin
						//	none
					end
				endcase
			end
		end
		else begin
			ff_write		<= 1'b0;
		end
	end

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_screen_mode <= 5'd0;
			ff_sprite_magify <= 1'b0;
			ff_sprite_16x16 <= 1'b0;
			ff_display_on <= 1'b0;
			ff_pattern_name_table_base <= 7'd0;
			ff_color_table_base <= 11'd0;
			ff_pattern_generator_table_base <= 6'd0;
			ff_sprite_attribute_table_base <= 8'd0;
			ff_sprite_pattern_generator_table_base <= 6'd0;
			ff_backdrop_color <= 8'd0;
			ff_sprite_disable <= 1'b0;
			ff_color0_opaque <= 1'b0;
			ff_50hz_mode <= 1'b0;
			ff_interleaving_mode <= 1'b0;
			ff_interlace_mode <= 1'b0;
			ff_212lines_mode <= 1'b0;
			ff_text_back_color <= 8'd0;
			ff_blink_period <= 8'd0;
			ff_status_register_pointer <= 4'd0;
			ff_color_palette_address <= 4'd0;
			ff_display_adjust <= 8'd0;
			ff_interrupt_line <= 8'd0;
			ff_vertical_offset <= 8'd0;
			ff_scroll_planes <= 1'b0;
			ff_left_mask <= 1'b0;
			ff_yjk_mode <= 1'b0;
			ff_yae_mode <= 1'b0;
			ff_command_enable <= 1'b0;
			ff_horizontal_offset <= 9'd0;
		end
		else if( ff_register_write ) begin
			case( ff_register_num )
			6'd0:	//	R#0 = [N/A][N/A][N/A][IE1][M5][M4][M3][N/A]
				begin
					ff_screen_mode[4:2] <= bus_wdata[3:1];
					ff_line_interrupt_enable <= bus_wdata[4];
				end
			6'd1:	//	R#1 = [N/A][BL][IE0][M1][M2][N/A][SI][MAG]
				begin
					ff_sprite_magify <= bus_wdata[0];
					ff_sprite_16x16 <= bus_wdata[1];
					ff_screen_mode[1] <= bus_wdata[3];
					ff_screen_mode[0] <= bus_wdata[4];
					ff_frame_interrupt_enable <= bus_wdata[5];
					ff_display_on <= bus_wdata[6];
				end
			6'd2:	//	R#2 = [N/A][A16][A15][A14][A13][A12][A11][A10]
				begin
					ff_pattern_name_table_base <= bus_wdata[6:0];
				end
			6'd3:	//	R#3 = [A13][A12][A11][A10][A9][A8][A7][A6]
				begin
					ff_color_table_base[13:6] <= bus_wdata;
				end
			6'd4:	//	R#4 = [N/A][N/A][A16][A15][A14][A13][A12][A11]
				begin
					ff_pattern_generator_table_base <= bus_wdata[5:0];
				end
			6'd5:	//	R#5 = [A14][A13][A12][A11][A10][A9][N/A][N/A]
				begin
					ff_sprite_attribute_table_base[14:9] <= bus_wdata[7:2];
				end
			6'd6:	//	R#6 = [N/A][N/A][A16][A15][A14][A13][A12][A11]
				begin
					ff_sprite_pattern_generator_table_base <= bus_wdata[5:0];
				end
			6'd7:	//	R#7 = [BD7][BD6][BD5][BD4][BD3][BD2][BD1][BD0]
				begin
					ff_backdrop_color <= bus_wdata;
				end
			6'd8:	//	R#8 = [N/A][N/A][TP][N/A][N/A][N/A][SPD][N/A]
				begin
					ff_sprite_disable <= bus_wdata[1];
					ff_color0_opaque <= bus_wdata[5];
				end
			6'd9:	//	R#9 = [LN][N/A][N/A][N/A][IL][EO][NT][N/A]
				begin
					ff_50hz_mode <= bus_wdata[1];
					ff_interleaving_mode <= bus_wdata[2];
					ff_interlace_mode <= bus_wdata[3];
					ff_212lines_mode <= bus_wdata[7];
				end
			6'd10:	//	R#10 = [N/A][N/A][N/A][N/A][N/A][A16][A15][A14]
				begin
					ff_color_table_base[16:14] <= bus_wdata[2:0];
				end
			6'd11:	//	R#11 = [N/A][N/A][N/A][N/A][N/A][N/A][A16][A15]
				begin
					ff_sprite_attribute_table_base[16:15] <= bus_wdata[1:0];
				end
			6'd12:	//	R#12 = [T23][T22][T1][T20][BC3][BC2][BC1][BC0]
				begin
					ff_text_back_color <= bus_wdata;
				end
			6'd13:	//	R#13 = [CN3][CN2][CN1][CN0][CF3][CF2][CF1][CF0]
				begin
					ff_blink_period <= bus_wdata;
				end
			6'd14:	//	R#14 = [N/A][N/A][N/A][N/A][N/A][A16][A15][A14]
				begin
					ff_vram_address[16:14] <= bus_wdata[2:0];
				end
			6'd15:	//	R#15 = [N/A][N/A][N/A][N/A][S3][S2][S1][S0]
				begin
					ff_status_register_pointer <= bus_wdata[3:0];
				end
			6'd16:	//	R#16 = [N/A][N/A][N/A][N/A][C3][C2][C1][C0]
				begin
					ff_color_palette_address <= bus_wdata[3:0];
				end
			8'd17:	//	R#17 = [AII][N/A][R5][R4][R3][R2][R1][R0]
				begin
					ff_register_pointer <= bus_wdata[5:0];
					ff_not_increment <= bus_wdata[7];
				end
			8'd18:	//	R#18 = [V3][V2][V1][V0][H3][H2][H1][H0]
				begin
					ff_display_adjust <= bus_wdata;
				end
			8'd19:	//	R#19 = [IL7][IL6][IL5][IL4][IL3][IL2][IL1][IL0]
				begin
					ff_interrupt_line <= bus_wdata;
				end
			8'd23:	//	R#23 = [DO7][DO6][DO5][DO4][DO3][DO2][DO1][DO0]
				begin
					ff_vertical_offset <= bus_wdata;
				end
			8'd25:	//	R#25 = [N/A][CMD][N/A][YAE][YJK][N/A][MSK][SP2]
				begin
					ff_scroll_planes <= bus_wdata[0];
					ff_left_mask <= bus_wdata[1];
					ff_yjk_mode <= bus_wdata[3];
					ff_yae_mode <= bus_wdata[4];
					ff_command_enable <= bus_wdata[6];
				end
			8'd26:	//	R#26 = [N/A][N/A][HO8][HO7][HO6][HO5][HO4][HO3]
				begin
					ff_horizontal_offset[8:3] <= bus_wdata[5:0];
				end
			8'd27:	//	R#27 = [N/A][N/A][N/A][N/A][N/A][HO2][HO1][HO0]
				begin
					ff_horizontal_offset[2:0] <= bus_wdata[2:0];
				end
			default:
				begin
					//	hold
				end
			endcase
		end
	end
endmodule
