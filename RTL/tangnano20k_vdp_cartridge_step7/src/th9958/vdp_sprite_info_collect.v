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

	input		[12:0]	screen_pos_x,
	input		[ 7:0]	pixel_pos_y,
	input				screen_active,

	output		[16:0]	vram_address,
	output				vram_valid,
	input		[31:0]	vram_rdata,

	output		[2:0]	current_plane,
	input		[4:0]	selected_plane_num,
	input		[3:0]	selected_y,
	input		[7:0]	selected_x,
	input		[7:0]	selected_pattern,
	input		[7:0]	selected_color,

	input		[3:0]	selected_count,

	output		[7:0]	pattern_left,
	output				pattern_left_en,
	output		[7:0]	pattern_right,
	output				pattern_right_en,
	output		[7:0]	color,
	output				color_en,

	input				sprite_mode2,
	input				reg_sprite_magify,
	input				reg_sprite_16x16,
	input		[16:9]	reg_sprite_attribute_table_base,
	input		[16:11]	reg_sprite_pattern_generator_table_base
);
	reg			[3:0]	ff_current_plane;		//	Plane#0...#7, and endmark(#8)
	reg			[1:0]	ff_state;				//	#0=info read, #1=pattern left read, #2=pattern right read, #3=color read
	wire		[2:0]	w_sub_phase;			//	Sub phase #0...#7
	reg			[16:0]	ff_vram_address;
	reg					ff_vram_valid;

	// --------------------------------------------------------------------
	//	Pattern left, right and color collector
	// --------------------------------------------------------------------
	assign w_sub_phase	= screen_pos_x[2:0];

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_current_plane	<= 4'd8;
			ff_state			<= 2'd0;
			ff_vram_valid		<= 1'b0;
		end
		else if( start_info_collect ) begin
			ff_current_plane	<= 4'd0;
			ff_state			<= 2'd0;
			ff_vram_valid		<= 1'b0;
		end
		else if( !ff_current_plane[3] || (!ff_current_plane[2] && !sprite_mode2) ) begin
			case( ff_state )
			2'd0:
				if( w_sub_phase == 3'd0 ) begin
					//	Request pattern left address
					ff_vram_address		<= { reg_sprite_pattern_generator_table_base, selected_pattern[7:1], (selected_pattern[0] | selected_y[3]), selected_y[2:0] };
					ff_vram_valid		<= 1'b1;
					ff_state			<= 2'd1;
				end
				else begin
					ff_vram_valid		<= 1'b0;
				end
			2'd1:
				if( w_sub_phase == 3'd0 ) begin
					//	Latch left pattern and request pattern right address
					ff_vram_address		<= { reg_sprite_pattern_generator_table_base, selected_pattern[7:2], 1'b1, selected_y };
					ff_vram_valid		<= reg_sprite_16x16;
					ff_state			<= 2'd2;
				end
				else begin
					ff_vram_valid		<= 1'b0;
				end
			2'd2:
				if( w_sub_phase == 3'd0 ) begin
					//	Latch right pattern and request color address
					ff_vram_address		<= 17'd0;
					ff_vram_valid		<= sprite_mode2;
					ff_state			<= 2'd3;
				end
				else begin
					ff_vram_valid		<= 1'b0;
				end
			2'd3:
				if( w_sub_phase == 3'd7 ) begin
					//	Next plane
					ff_current_plane	<= ff_current_plane + 4'd1;
					ff_state			<= 2'd0;
				end
			endcase
		end
	end

	assign current_plane	= ff_current_plane;
	assign vram_address		= ff_vram_address;
	assign vram_valid		= ff_vram_valid;

	assign pattern_left		= vram_rdata[7:0];
	assign pattern_left_en	= (w_sub_phase == 3'd0 && ff_state == 2'd1);
	assign pattern_right	= reg_sprite_16x16 ? vram_rdata[7:0]: 8'd0;
	assign pattern_right_en	= (w_sub_phase == 3'd0 && ff_state == 2'd2);
	assign color			= sprite_mode2 ? vram_rdata[7:0]: selected_color;
	assign color_en			= (w_sub_phase == 3'd0 && ff_state == 2'd3);
endmodule
