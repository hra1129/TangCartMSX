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
	input				screen_active,

	output		[16:0]	vram_address,
	output				vram_valid,
	input		[7:0]	vram_rdata,
	//	from select_visible_planes
	input				selected_en,
	input		[4:0]	selected_plane_num,
	input		[3:0]	selected_y,
	input		[7:0]	selected_x,
	input		[7:0]	selected_pattern,
	input		[7:0]	selected_color,

	input		[3:0]	selected_count,
	//	to makeup_pixel
	output		[2:0]	makeup_plane,
	output		[7:0]	plane_x,
	output				plane_x_en,
	output		[7:0]	pattern_left,
	output				pattern_left_en,
	output		[7:0]	pattern_right,
	output				pattern_right_en,
	output		[7:0]	color,
	output				color_en,

	input				sprite_mode2,
	input				reg_display_on,
	input				reg_sprite_magify,
	input				reg_sprite_16x16,
	input		[16:11]	reg_sprite_pattern_generator_table_base
);
	reg			[31:0]	ff_selected_ram [0:7];
	wire		[31:0]	w_selected_d;
	wire		[4:0]	w_selected_plane_num;
	wire		[3:0]	w_selected_y;
	wire		[7:0]	w_selected_x;
	wire		[7:0]	w_selected_pattern;
	wire		[7:0]	w_selected_color;
	reg			[31:0]	ff_selected_q;
	reg			[3:0]	ff_current_plane;		//	Plane#0...#7, and endmark(#8)
	reg			[3:0]	ff_current_plane_d1;	//	Plane#0...#7, and endmark(#8)
	wire		[3:0]	w_next_plane;
	reg			[1:0]	ff_state;				//	#0=info read, #1=pattern left read, #2=pattern right read, #3=color read
	wire		[3:0]	w_sub_phase;			//	Sub phase #0...#15
	reg			[16:0]	ff_vram_address;
	reg					ff_vram_valid;
	reg					ff_vram_valid_d1;
	reg					ff_active;
	reg					ff_active_d1;
	reg					ff_sprite_mode2;

	// --------------------------------------------------------------------
	//	Information RAM
	// --------------------------------------------------------------------
	assign w_selected_d	= { selected_color[7],						//	EC bit
	                   		selected_color[6] & sprite_mode2,		//	CC bit
	                   		selected_color[5] & sprite_mode2,		//	IC bit
	                   		selected_plane_num,						//	Plane#0...#31
	                   		selected_color[3:0],					//	Color
	                   		selected_pattern,
	                   		selected_x,
	                   		selected_y };

	assign w_selected_plane_num	= ff_selected_q[28:24];
	assign w_selected_color		= { ff_selected_q[31:29], 1'b0, ff_selected_q[23:20] };
	assign w_selected_pattern	= ff_selected_q[19:12];
	assign w_selected_x			= ff_selected_q[11: 4];
	assign w_selected_y			= ff_selected_q[ 3: 0];

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_selected_ram[0] <= 32'd0;
			ff_selected_ram[1] <= 32'd0;
			ff_selected_ram[2] <= 32'd0;
			ff_selected_ram[3] <= 32'd0;
			ff_selected_ram[4] <= 32'd0;
			ff_selected_ram[5] <= 32'd0;
			ff_selected_ram[6] <= 32'd0;
			ff_selected_ram[7] <= 32'd0;
		end
		else if( screen_active && reg_display_on ) begin
			if( selected_en ) begin
				//	Update information RAM by select_visible_planes
				ff_selected_ram[ ff_current_plane ] <= w_selected_d;
			end
		end
		else begin
			ff_selected_q <= ff_selected_ram[ ff_current_plane ];
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
	//	Pattern left, right and color collector
	// --------------------------------------------------------------------
	assign w_sub_phase	= screen_pos_x[3:0];

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_state			<= 2'd0;
		end
		else if( start_info_collect && reg_display_on ) begin
			ff_state			<= 2'd0;
		end
		else if( screen_pos_x == 14'h3FFF ) begin
			ff_state			<= 2'd0;
		end
		else if( w_sub_phase == 4'd15 ) begin
			ff_state			<= ff_state + 2'd1;
		end
	end

	assign w_next_plane	= ff_current_plane + 4'd1;

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_current_plane	<= 4'd8;
			ff_vram_address		<= 17'd0;
			ff_vram_valid		<= 1'b0;
			ff_active			<= 1'b0;
		end
		else if( start_info_collect && selected_count != 4'd0 ) begin
			ff_current_plane	<= 4'd0;
			ff_vram_address		<= 17'd0;
			ff_vram_valid		<= 1'b0;
			ff_active			<= reg_display_on;
		end
		else if( screen_pos_x == 14'h3FFF ) begin
			ff_current_plane	<= 4'd0;
			ff_vram_address		<= 17'd0;
			ff_vram_valid		<= 1'b0;
		end
		else if( screen_active ) begin
			if( selected_en ) begin
				ff_current_plane	<= w_next_plane;
			end
		end
		else if( ff_active ) begin
			case( ff_state )
			2'd0:
				begin
					ff_vram_address		<= 17'd0;
					ff_vram_valid		<= 1'b0;
				end
			2'd1:
				if( w_sub_phase == 4'd0 ) begin
					//	Request pattern left address
					ff_vram_address		<= { reg_sprite_pattern_generator_table_base, w_selected_pattern[7:1], (w_selected_pattern[0] | w_selected_y[3]), w_selected_y[2:0] };
					ff_vram_valid		<= 1'b1;
				end
				else begin
					ff_vram_address		<= 17'd0;
					ff_vram_valid		<= 1'b0;
				end
			2'd2:
				if( w_sub_phase == 4'd0 ) begin
					//	Latch left pattern and request pattern right address
					ff_vram_address		<= { reg_sprite_pattern_generator_table_base, w_selected_pattern[7:2], 1'b1, w_selected_y };
					ff_vram_valid		<= reg_sprite_16x16;
				end
				else begin
					ff_vram_address		<= 17'd0;
					ff_vram_valid		<= 1'b0;
				end
			2'd3:
				if( w_sub_phase == 4'd0 ) begin
					//	Latch right pattern and request color address
					ff_vram_address		<= 17'd0;
					ff_vram_valid		<= ff_sprite_mode2;
				end
				else if( w_sub_phase == 4'd15 ) begin
					ff_vram_address		<= 17'd0;
					ff_vram_valid		<= 1'b0;
					if( w_next_plane == selected_count ) begin
						ff_active			<= 1'b0;
					end
					else begin
						ff_current_plane	<= w_next_plane;
					end
				end
				else begin
					ff_vram_address		<= 17'd0;
					ff_vram_valid		<= 1'b0;
				end
			endcase
		end
		else begin
			ff_vram_address		<= 17'd0;
			ff_vram_valid		<= 1'b0;
		end
	end

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_vram_valid_d1	<= 1'b0;
		end
		else begin
			ff_vram_valid_d1	<= ff_vram_valid;
		end
	end

	always @( posedge clk ) begin
		if( w_sub_phase == 4'd15 ) begin
			ff_current_plane_d1	<= ff_current_plane;
			ff_active_d1		<= ff_active;
		end
	end

	assign vram_address		= ff_vram_address;
	assign vram_valid		= ff_vram_valid_d1;

	assign makeup_plane		= ff_current_plane_d1[2:0];
	assign plane_x			= w_selected_x;
	assign plane_x_en		= (ff_active_d1 && w_sub_phase == 4'd2 && ff_state == 2'd1);
	assign pattern_left		= vram_rdata;
	assign pattern_left_en	= (ff_active_d1 && w_sub_phase == 4'd2 && ff_state == 2'd2);
	assign pattern_right	= reg_sprite_16x16 ? vram_rdata: 8'd0;
	assign pattern_right_en	= (ff_active_d1 && w_sub_phase == 4'd2 && ff_state == 2'd3);
	assign color			= ff_sprite_mode2 ? vram_rdata: w_selected_color;
	assign color_en			= (ff_active_d1 && w_sub_phase == 4'd2 && ff_state == 2'd0);
endmodule
