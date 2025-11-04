//
//	vdp_sprite_select_visible_planes.v
//	Select visible sprite planes for Timing Control Sprite
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

module vdp_sprite_select_visible_planes (
	input				reset_n,
	input				clk,					//	42.95454MHz

	input		[13:0]	screen_pos_x,
	input		[8:0]	screen_pos_y,
	input		[7:0]	pixel_pos_y,
	input				screen_v_active,
	input				screen_h_active,

	output		[17:0]	vram_address,
	output				vram_valid,
	input		[31:0]	vram_rdata,
	input				vram_interleave,

	output				selected_en,
	output		[5:0]	selected_plane_num,
	output		[31:0]	selected_attribute,

	output		[4:0]	selected_count,
	output				start_info_collect,

	output				sprite_overmap,
	output		[4:0]	sprite_overmap_id,
	input				clear_sprite_collision,

	input				sprite_mode2,
	input				reg_display_on,
	input				reg_sprite_disable,
	input				reg_sprite_magify,
	input				reg_sprite_16x16,
	input		[17:7]	reg_sprite_attribute_table_base,
	input				reg_sprite_nonR23_mode,
	input				reg_sprite_mode3,
	input				reg_sprite16_mode,
	input				reg_sprite_priority_shuffle
);
	//	Phase
	wire		[9:0]	w_screen_pos_x;
	wire		[2:0]	w_phase;
	wire		[3:0]	w_sub_phase;
	wire		[8:0]	w_pixel_pos_y;
	reg			[5:0]	ff_plane_count;
	reg			[5:0]	ff_current_plane_num;		//	Plane#0...#63
	reg			[5:0]	ff_current_plane_num_start;	//	Plane#0...#63
	reg					ff_vram_valid;
	reg			[4:0]	ff_selected_count;			//	表示するスプライトのカウント 0～16
	reg					ff_select_finish;
	reg			[5:0]	ff_selected_plane_num1;		//	Plane#0...#63
	reg			[5:0]	ff_selected_plane_num2;		//	Plane#0...#63
	wire		[5:0]	w_selected_plane_num;
	reg					ff_selected_en1;
	reg					ff_selected_en2;
	reg			[31:0]	ff_attribute1;
	reg			[31:0]	ff_attribute2;
	wire		[31:0]	w_attribute;
	wire		[9:0]	w_y;
	wire		[7:0]	w_mgy;
	wire		[9:0]	w_offset_y;
	wire		[7:0]	w_attribute_y;
	wire		[7:3]	w_invisible12;
	wire				w_invisible3;
	wire				w_invisible;
	wire				w_selected_full;
	wire		[9:0]	w_finish_line;
	wire		[17:0]	w_sprite_mode1_attribute;
	wire		[17:0]	w_sprite_mode2_attribute;
	wire		[17:0]	w_sprite_mode2_attribute_i;
	wire		[17:0]	w_sprite_mode3_attribute;
	reg					ff_sprite_overmap;
	reg			[4:0]	ff_sprite_overmap_id;

	// --------------------------------------------------------------------
	//	Phase
	// --------------------------------------------------------------------
	assign w_sprite_mode1_attribute		= { reg_sprite_attribute_table_base[17:7],        ff_current_plane_num[4:0], 2'd0 };
	assign w_sprite_mode2_attribute		= { reg_sprite_attribute_table_base[17:9], 2'b00, ff_current_plane_num[4:0], 2'd0 };
	assign w_sprite_mode2_attribute_i	= { reg_sprite_attribute_table_base[17:9], 2'b00, ff_current_plane_num[4:1], 1'b0, 2'd1 };
	assign w_sprite_mode3_attribute		= { reg_sprite_attribute_table_base[17:9], (reg_sprite_attribute_table_base[8:7] & ff_current_plane_num[5:4]), ff_current_plane_num[3:0], 3'd0 };

	assign w_screen_pos_x			= screen_pos_x[13:4];
	assign w_phase					= w_screen_pos_x[2:0];
	assign w_sub_phase				= screen_pos_x[3:0];
	assign vram_address				= ff_vram_valid ? 
										(reg_sprite_mode3               ? w_sprite_mode3_attribute  :
										(w_phase[2] && vram_interleave) ? w_sprite_mode2_attribute_i:
										(    sprite_mode2               ? w_sprite_mode2_attribute  : w_sprite_mode1_attribute)) :18'd0;
	assign w_selected_full			= ff_select_finish | (
										(reg_sprite_mode3 || reg_sprite16_mode) ? ff_selected_count[4]:
										     sprite_mode2                       ? (ff_selected_count[4] | ff_selected_count[3] | ff_plane_count[5]): 
										                                          (ff_selected_count[4] | ff_selected_count[3] | ff_selected_count[2] | ff_plane_count[5]) );
	assign w_finish_line			= (reg_sprite_mode3 || sprite_mode2) ? 10'd216: 10'd208;

	// --------------------------------------------------------------------
	//	Read VRAM request for sprite attribute table
	// --------------------------------------------------------------------
	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_current_plane_num_start <= 6'd0;
		end
		else if( !reg_sprite_priority_shuffle ) begin
			//	シャッフルしないモード
			ff_current_plane_num_start <= 6'd0;
		end
		else begin
			//	シャッフルするモード
			if( screen_pos_y == 9'h1FF ) begin
				if( screen_pos_x == 14'h3FFF ) begin
					if( vram_interleave ) begin
						ff_current_plane_num_start[5:1]	<= ff_current_plane_num_start[5:1] + 5'd9;
						ff_current_plane_num_start[0]	<= 1'b0;
					end
					else begin
						ff_current_plane_num_start <= ff_current_plane_num_start + 6'd17;
					end
				end
			end
		end
	end

	// --------------------------------------------------------------------
	//	VRAM Read Timing Generator
	// --------------------------------------------------------------------
	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_plane_count			<= 6'd0;
			ff_current_plane_num	<= 6'd0;
			ff_vram_valid			<= 1'b0;
		end
		else if( !screen_v_active || !screen_h_active || !reg_display_on || w_screen_pos_x[9]  ) begin
			//	hold
		end
		else if( w_phase == 3'd2 && w_sub_phase == 4'd0 ) begin
			if( screen_pos_x[13:7] == 7'd0 ) begin
				ff_plane_count			<= 6'd0;
				ff_current_plane_num	<= reg_sprite_priority_shuffle ? ff_current_plane_num_start: 6'd0;
				ff_vram_valid			<= 1'b1;
			end
			else begin
				ff_plane_count			<= ff_plane_count + 6'd1;
				if( vram_interleave ) begin
					ff_current_plane_num	<= ff_current_plane_num + (reg_sprite_priority_shuffle ? 6'd37: 6'd1 );
				end
				else begin
					ff_current_plane_num	<= ff_current_plane_num + (reg_sprite_priority_shuffle ? 6'd19: 6'd1 );
				end
				ff_vram_valid			<= ~w_selected_full;
			end
		end
		else if( w_phase == 3'd4 && w_sub_phase == 4'd0 ) begin
			ff_plane_count			<= ff_plane_count + 6'd1;
			if( vram_interleave ) begin
				ff_current_plane_num	<= ff_current_plane_num + 6'd1;
			end
			else begin
				ff_current_plane_num	<= ff_current_plane_num + (reg_sprite_priority_shuffle ? 6'd19: 6'd1 );
			end
			ff_vram_valid			<= ~w_selected_full;
		end
		else begin
			ff_vram_valid		<= 1'b0;
		end
	end

	assign vram_valid	= ff_vram_valid & ~reg_sprite_disable;

	// --------------------------------------------------------------------
	//	Receive value of attribute table
	// --------------------------------------------------------------------
	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_attribute1	<= 32'd0;
			ff_attribute2	<= 32'd0;
		end
		else if( !screen_v_active || !screen_h_active || !reg_display_on ) begin
			//	hold
		end
		else if( w_sub_phase == 4'd15 ) begin
			if( vram_interleave ) begin
				//	Sprite mode2 on Graphic6/7
				if( w_phase == 3'd2 ) begin
					//	vram_rdata = { Pattern1, Y1, Pattern0, Y0 };
					ff_attribute1		<= vram_rdata;
				end
				else if( w_phase == 3'd3 ) begin
					ff_attribute1[7:0]	<= w_attribute_y;
				end
				else if( w_phase == 3'd4 ) begin
					//	vram_rdata = { --, X1, --, X0 };
					ff_attribute1		<= { 8'd0, ff_attribute1[15: 8], vram_rdata[ 7: 0], ff_attribute1[ 7: 0] };
					ff_attribute2		<= { 8'd0, ff_attribute1[31:24], vram_rdata[23:16], ff_attribute1[23:16] };
				end
				else if( w_phase == 3'd5 ) begin
					ff_attribute2[7:0]	<= w_attribute_y;
				end
			end
			else begin
				if( w_phase == 3'd2 ) begin
					ff_attribute1		<= vram_rdata;
				end
				else if( w_phase == 3'd3 ) begin
					ff_attribute1[7:0]	<= w_attribute_y;
				end
				else if( w_phase == 3'd4 ) begin
					ff_attribute2		<= vram_rdata;
				end
				else if( w_phase == 3'd5 ) begin
					ff_attribute2[7:0]	<= w_attribute_y;
				end
			end
		end
	end

	// --------------------------------------------------------------------
	//	Check visible plane ( phase #3, #5 )
	//		Phase#3 ( w_phase[1]): ff_attribute1
	//		Phase#5 (!w_phase[1]): ff_attribute2
	// --------------------------------------------------------------------
	assign w_attribute		= w_phase[1] ? ff_attribute1: ff_attribute2;
	assign w_y				= reg_sprite_mode3 ? w_attribute[9:0] : { 2'd0, w_attribute[7:0] };
	assign w_mgy			= w_attribute[23:16];

	assign w_pixel_pos_y	= reg_sprite_nonR23_mode ? screen_pos_y     : { 1'b0, pixel_pos_y };
	assign w_offset_y		= { w_pixel_pos_y[8], w_pixel_pos_y } - w_y;
	assign w_attribute_y	= reg_sprite_mode3 ? w_offset_y[7:0]: ( reg_sprite_magify ? { 3'd0, w_offset_y[4:1] }: { 3'd0, w_offset_y[3:0] } );

	assign w_invisible12	= (!reg_sprite_16x16 && !reg_sprite_magify) ?   w_offset_y[7:3]        : 
	                  		  (!reg_sprite_16x16 || !reg_sprite_magify) ? { w_offset_y[7:4], 1'd0 }: { w_offset_y[7:5], 2'd0 };
	assign w_invisible3		= (w_mgy == 8'd0) ? (w_offset_y[9:8] != 2'd0): ( { 2'd0, w_mgy } <= w_offset_y );
	assign w_invisible		= reg_sprite_mode3 ? w_invisible3: (w_invisible12 != 5'd0);

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_selected_count	<= 5'd0;
			ff_select_finish	<= 1'b0;
			ff_selected_en1		<= 1'b0;
			ff_selected_en2		<= 1'b0;
		end
		else if( screen_pos_x == 14'h3FFF || reg_sprite_disable ) begin
			ff_selected_count	<= 5'd0;
			ff_select_finish	<= 1'b0;
			ff_selected_en1		<= 1'b0;
			ff_selected_en2		<= 1'b0;
		end
		else if( !screen_v_active || !screen_h_active || !reg_display_on ) begin
			//	hold
		end
		else if( w_phase == 3'd3 ) begin
			if( w_sub_phase == 4'd7 ) begin
				if( w_y == w_finish_line && !reg_sprite_priority_shuffle ) begin
					ff_select_finish		<= 1'b1;
					ff_selected_en1			<= 1'b0;
				end
				else if( !w_invisible && !w_selected_full ) begin
					ff_selected_en1			<= 1'b1;
					ff_selected_plane_num1	<= ff_current_plane_num;
				end
			end
			else if( w_sub_phase == 4'd15 ) begin
				if( ff_selected_en1 ) begin
					ff_selected_count		<= ff_selected_count + 5'd1;
				end
			end
		end
		else if( w_phase == 3'd5 ) begin
			if( w_sub_phase == 4'd7 ) begin
				if( w_y == w_finish_line && !reg_sprite_priority_shuffle ) begin
					ff_select_finish		<= 1'b1;
					ff_selected_en2			<= 1'b0;
				end
				else if( !w_invisible && !w_selected_full ) begin
					ff_selected_en2			<= 1'b1;
					ff_selected_plane_num2	<= ff_current_plane_num;
				end
			end
			else if( w_sub_phase == 4'd15 ) begin
				if( ff_selected_en2 ) begin
					ff_selected_count	<= ff_selected_count + 5'd1;
				end
			end
		end
		else if( w_phase == 3'd7 ) begin
			if( w_sub_phase == 4'd15 ) begin
				ff_selected_en1		<= 1'b0;
				ff_selected_en2		<= 1'b0;
			end
		end
	end

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_sprite_overmap		<= 1'b0;
			ff_sprite_overmap_id	<= 5'd0;
		end
		else if( ff_sprite_overmap ) begin
			if( clear_sprite_collision ) begin
				//	Clear overmap flag when Read S#0
				ff_sprite_overmap	<= 1'b0;
			end
			else begin
				//	hold
			end
		end
		else if( !screen_v_active || !screen_h_active || !reg_display_on ) begin
			//	hold
		end
		else if( w_phase == 3'd3 || w_phase == 3'd5 ) begin
			if( w_sub_phase == 4'd7 ) begin
				if( !w_invisible && w_selected_full ) begin
					ff_sprite_overmap		<= 1'b1;
				end
				ff_sprite_overmap_id	<= ff_current_plane_num[4:0];
			end
		end
	end

	assign selected_en				= (w_phase == 3'd6 && w_sub_phase == 4'd15) ? ff_selected_en1: 
									  (w_phase == 3'd7 && w_sub_phase == 4'd15) ? ff_selected_en2: 1'b0;

	assign w_selected_plane_num		= (w_phase[0] == 1'b0) ? ff_selected_plane_num1: ff_selected_plane_num2;
	assign selected_plane_num		= reg_sprite_mode3 ? w_selected_plane_num : { 1'b0, w_selected_plane_num[4:0] };
	assign selected_attribute		= (w_phase[0] == 1'b0) ? ff_attribute1: ff_attribute2;
	assign selected_count			= ff_selected_count;

	assign start_info_collect		= (screen_v_active && screen_pos_x[13:4] == 10'd259 && w_sub_phase == 4'd14);

	assign sprite_overmap			= ff_sprite_overmap;
	assign sprite_overmap_id		= ff_sprite_overmap_id;
endmodule
