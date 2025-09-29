//
//	vdp_sprite_info_collect .v
//	Sprite plane's information collector for Timing Control Sprite
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

module vdp_sprite_info_collect (
	input				reset_n,
	input				clk,					//	42.95454MHz
	input				start_info_collect,

	input		[13:0]	screen_pos_x,
	input				screen_v_active,
	input				screen_h_active,

	output		[17:0]	vram_address,
	output				vram_valid,
	input		[7:0]	vram_rdata8,
	input		[31:0]	vram_rdata,
	//	from select_visible_planes
	input				selected_en,
	input		[5:0]	selected_plane_num,
	input		[31:0]	selected_attribute,

	input		[4:0]	selected_count,
	//	to/from divider
	output		[7:0]	y,
	output		[7:0]	mgy,
	output		[1:0]	bit_shift,
	input		[6:0]	sample_y,
	//	to makeup_pixel
	output		[3:0]	makeup_plane,
	output		[7:0]	color,
	output		[9:0]	plane_x,
	output				color_plane_x_en,
	output		[31:0]	pattern,
	output				pattern_left_en,
	output				pattern_right_en,

	input				sprite_mode2,
	input				reg_display_on,
	input				reg_sprite_magify,
	input				reg_sprite_16x16,
	input		[17:11]	reg_sprite_pattern_generator_table_base,
	input		[17:7]	reg_sprite_attribute_table_base,
	input				reg_sprite_mode3
);
	reg			[37:0]	ff_selected_ram [0:15];
	wire		[37:0]	w_selected_d;
	wire		[5:0]	w_selected_plane_num;
	wire		[7:0]	w_selected_y;
	wire		[7:0]	w_selected_m12_x;
	wire		[7:0]	w_selected_m12_pattern;
	wire		[7:0]	w_selected_m12_color;
	wire		[1:0]	w_selected_m3_bit_shift;
	wire		[7:0]	w_selected_m3_mgy;
	wire		[9:0]	w_selected_m3_x;
	wire		[7:0]	w_selected_m3_mgx;
	wire		[1:0]	w_selected_m3_transparent;
	wire				w_selected_m3_rvy;
	wire				w_selected_m3_rvx;
	wire		[3:0]	w_selected_m3_palette_set;
	wire		[7:0]	w_selected_m3_pattern;
	wire		[6:0]	w_selected_m3_y;
	reg			[37:0]	ff_selected_q;
	reg			[4:0]	ff_current_plane;		//	Plane#0...#15, and endmark(#16)
	reg			[3:0]	ff_previous_plane;
	wire		[4:0]	w_next_plane;
	reg			[1:0]	ff_state;				//	#0=info read, #1=pattern left read, #2=pattern right read, #3=color read
	wire		[3:0]	w_sub_phase;			//	Sub phase #0...#15
	reg			[17:0]	ff_vram_address;
	reg					ff_vram_valid;
	reg					ff_active;
	reg					ff_active_delay;
	reg					ff_sprite_mode2;
	reg			[31:0]	ff_attribute2;
	wire		[14:3]	w_pattern_address;

	// --------------------------------------------------------------------
	//	Information RAM
	// --------------------------------------------------------------------
	assign w_selected_d	= { selected_plane_num, selected_attribute };

	assign w_selected_plane_num			= ff_selected_q[37:32];
	assign w_selected_m12_color			= ff_selected_q[31:24];
	assign w_selected_m12_pattern		= ff_selected_q[23:16];
	assign w_selected_m12_x				= ff_selected_q[15: 8];
	assign w_selected_y					= ff_selected_q[ 7: 0];
	assign w_selected_m3_transparent  	= ff_selected_q[31:30];
	assign w_selected_m3_rvy			= ff_selected_q[29];
	assign w_selected_m3_rvx			= ff_selected_q[28];
	assign w_selected_m3_palette_set	= ff_selected_q[27:24];
	assign w_selected_m3_mgy			= ff_selected_q[23:16];
	assign w_selected_m3_bit_shift  	= ff_selected_q[15:14];

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_selected_ram[0]	<= 38'd0;
			ff_selected_ram[1]	<= 38'd0;
			ff_selected_ram[2]	<= 38'd0;
			ff_selected_ram[3]	<= 38'd0;
			ff_selected_ram[4]	<= 38'd0;
			ff_selected_ram[5]	<= 38'd0;
			ff_selected_ram[6]	<= 38'd0;
			ff_selected_ram[7]	<= 38'd0;
			ff_selected_ram[8]	<= 38'd0;
			ff_selected_ram[9]	<= 38'd0;
			ff_selected_ram[10]	<= 38'd0;
			ff_selected_ram[11]	<= 38'd0;
			ff_selected_ram[12]	<= 38'd0;
			ff_selected_ram[13]	<= 38'd0;
			ff_selected_ram[14]	<= 38'd0;
			ff_selected_ram[15]	<= 38'd0;
		end
		else if( screen_v_active && screen_h_active && reg_display_on ) begin
			if( selected_en ) begin
				//	Update information RAM by select_visible_planes
				ff_selected_ram[ ff_current_plane[3:0] ] <= w_selected_d;
			end
		end
		else begin
			ff_selected_q <= ff_selected_ram[ ff_current_plane[3:0] ];
		end
	end

	// --------------------------------------------------------------------
	//	Hold sprite mode 2
	// --------------------------------------------------------------------
	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_sprite_mode2 <= 1'b0;
		end
		else if( start_info_collect && reg_display_on ) begin
			ff_sprite_mode2 <= sprite_mode2;
		end
	end

	// --------------------------------------------------------------------
	//	Latch 2nd attribute for sprite mode3
	// --------------------------------------------------------------------
	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_attribute2 <= 32'd0;
		end
		else if( ff_active && ff_state == 2'd0 && w_sub_phase == 4'd12 ) begin
			ff_attribute2 <= vram_rdata;
		end
	end

	assign w_selected_m3_x			= ff_attribute2[ 9: 0];
	assign w_selected_m3_mgx		= ff_attribute2[23:16];
	assign w_selected_m3_pattern	= ff_attribute2[31:24];
	assign w_selected_m3_y			= w_selected_m3_rvy ? ~sample_y: sample_y;
	assign w_pattern_address		= { 4'd0, w_selected_m3_pattern } + { 1'd0, w_selected_m3_y, 4'd0 };

	// --------------------------------------------------------------------
	//	Pattern left, right and color collector
	// --------------------------------------------------------------------
	assign w_sub_phase	= screen_pos_x[3:0];

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_state <= 2'd0;
		end
		else if( start_info_collect && reg_display_on ) begin
			ff_state <= 2'd0;
		end
		else if( screen_pos_x == 14'h3FFF ) begin
			ff_state <= 2'd0;
		end
		else if( w_sub_phase == 4'd12 ) begin
			if( ff_state == 2'd2 ) begin
				ff_state <= 2'd0;
			end
			else begin
				ff_state <= ff_state + 2'd1;
			end
		end
	end

	assign w_next_plane	= ff_current_plane + 5'd1;

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_current_plane	<= 5'd8;
			ff_vram_address		<= 17'd0;
			ff_vram_valid		<= 1'b0;
			ff_active			<= 1'b0;
		end
		else if( start_info_collect && selected_count != 4'd0 ) begin
			ff_current_plane	<= 5'd0;
			ff_vram_address		<= 17'd0;
			ff_vram_valid		<= 1'b0;
			ff_active			<= reg_display_on;
		end
		else if( screen_pos_x == 14'h3FFF ) begin
			ff_current_plane	<= 5'd0;
			ff_vram_address		<= 17'd0;
			ff_vram_valid		<= 1'b0;
		end
		else if( screen_v_active && screen_h_active ) begin
			//	映像期間に VRAM から情報収集
			if( selected_en ) begin
				ff_current_plane	<= w_next_plane;
			end
			ff_vram_valid		<= 1'b0;
		end
		else if( ff_active ) begin
			//	ブランキング期間中に表示するスプライトの情報を収集
			case( ff_state )
			2'd0:
				if( w_sub_phase == 4'd0 ) begin
					if( reg_sprite_mode3 ) begin
						//	Request 2nd attribute
						ff_vram_address		<= { reg_sprite_attribute_table_base[17:9], w_selected_plane_num, 3'd4 };
						ff_vram_valid		<= 1'b1;
					end
					else if( ff_sprite_mode2 ) begin
						//	Request color address
						ff_vram_address		<= { reg_sprite_attribute_table_base[17:10], 1'b0, (reg_sprite_attribute_table_base[8:7] & w_selected_plane_num[4:3]), w_selected_plane_num[2:0], w_selected_y[3:0] };
						ff_vram_valid		<= 1'b1;
					end
					else begin
						ff_vram_valid		<= 1'b0;
					end
				end
				else begin
					ff_vram_valid		<= 1'b0;
				end
			2'd1:
				if( w_sub_phase == 4'd0 ) begin
					if( reg_sprite_mode3 ) begin
						//	Latch 2nd attribute and Request pattern left address
						ff_vram_address		<= { reg_sprite_pattern_generator_table_base, 11'd0 } + { 3'd0, w_pattern_address, 3'd0 };
					end
					else begin
						//	Latch color and Request pattern left address
						if( reg_sprite_16x16 ) begin
							ff_vram_address		<= { reg_sprite_pattern_generator_table_base, w_selected_m12_pattern[7:2], 1'b0, w_selected_y[3:0] };
						end
						else begin
							ff_vram_address		<= { reg_sprite_pattern_generator_table_base, w_selected_m12_pattern, w_selected_y[2:0] };
						end
					end
					ff_vram_valid		<= 1'b1;
				end
				else begin
					ff_vram_valid		<= 1'b0;
				end
			2'd2:
				if( w_sub_phase == 4'd0 ) begin
					if( reg_sprite_mode3 ) begin
						//	Latch left pattern and request pattern right address
						ff_vram_address		<= { reg_sprite_pattern_generator_table_base, 11'd0 } + { 3'd0, w_pattern_address, 3'd4 };
					end
					else begin
						//	Latch left pattern and request pattern right address
						if( reg_sprite_16x16 ) begin
							ff_vram_address		<= { reg_sprite_pattern_generator_table_base, w_selected_m12_pattern[7:2], 1'b1, w_selected_y[3:0] };
							ff_vram_valid		<= 1'b1;
						end
						else begin
							ff_vram_valid		<= 1'b0;
						end
					end
				end
				else if( w_sub_phase == 4'd12 ) begin
					if( w_next_plane == selected_count ) begin
						ff_active			<= 1'b0;
					end
					else begin
						ff_current_plane	<= w_next_plane;
					end
					ff_vram_valid		<= 1'b0;
				end
				else begin
					ff_vram_valid		<= 1'b0;
				end
			endcase
		end
	end

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_active_delay		<= 1'b0;
			ff_previous_plane	<= 4'd0;
		end
		else if( w_sub_phase == 4'd12 ) begin
			ff_active_delay		<= ff_active;
			ff_previous_plane	<= ff_current_plane[3:0];
		end
	end

	assign y				= ff_active ? w_selected_y: 8'd0;
	assign mgy				= ff_active ? w_selected_m3_mgy: 8'd0;
	assign bit_shift		= ff_active ? w_selected_m3_bit_shift: 2'd0;

	assign vram_address		= ff_vram_valid ? ff_vram_address: 18'd0;
	assign vram_valid		= ff_vram_valid;

	assign makeup_plane		= ff_active_delay ? ff_previous_plane :  ff_current_plane[3:0];
	assign color			= ff_sprite_mode2 ? vram_rdata8: w_selected_m12_color;
	assign plane_x			= reg_sprite_mode3 ? w_selected_m3_x: { 2'd0, w_selected_m12_x };
	assign color_plane_x_en	= (ff_active_delay && w_sub_phase == 4'd15 && ff_state == 2'd1);
	assign pattern			= reg_sprite_mode3 ? vram_rdata:
	              			  (ff_state == 2'd0 && !reg_sprite_16x16) ? 32'd0: { 24'd0, vram_rdata8 };
	assign pattern_left_en	= (ff_active_delay && w_sub_phase == 4'd15 && ff_state == 2'd2);
	assign pattern_right_en	= (ff_active_delay && w_sub_phase == 4'd15 && ff_state == 2'd0);
endmodule
