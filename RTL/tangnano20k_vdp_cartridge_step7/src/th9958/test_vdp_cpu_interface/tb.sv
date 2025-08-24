// -----------------------------------------------------------------------------
//	Test of vdp_cpu_interface.v
//	Copyright (C)2025 Takayuki Hara (HRA!)
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
// --------------------------------------------------------------------

module tb ();
	localparam		clk_base		= 1_000_000_000/42_954_540;	//	ns
	localparam		c_time_out		= 100;

	reg					reset_n;
	reg					clk;					//	42.95454MHz

	reg		[1:0]		bus_address;
	reg					bus_ioreq;
	reg					bus_write;
	reg					bus_valid;
	wire				bus_ready;
	reg		[7:0]		bus_wdata;
	wire	[7:0]		bus_rdata;
	wire				bus_rdata_en;

	wire	[16:0]		vram_address;
	wire				vram_write;
	wire				vram_valid;
	reg					vram_ready;
	wire	[7:0]		vram_wdata;
	reg		[7:0]		vram_rdata;
	reg					vram_rdata_en;

	wire				palette_valid;
	wire		[3:0]	palette_num;
	wire		[2:0]	palette_r;
	wire		[2:0]	palette_g;
	wire		[2:0]	palette_b;

	reg			[4:0]	ff_last_palette_num;
	reg			[2:0]	ff_last_palette_r;
	reg			[2:0]	ff_last_palette_g;
	reg			[2:0]	ff_last_palette_b;

	wire				int_n;
	reg					intr_line;					//	pulse
	reg					intr_frame;					//	pulse

	wire				clear_sprite_collision;		//	pulse
	reg					sprite_collision;
	wire				clear_sprite_collision_xy;	//	pulse
	reg			[8:0]	sprite_collision_x;
	reg			[9:0]	sprite_collision_y;

	wire				register_write;
	wire		[5:0]	register_num;
	wire		[7:0]	register_data;

	reg					status_command_enable;		//	S#2 bit0
	reg					status_border_detect;		//	S#2 bit4
	reg					status_transfer_ready;		//	S#2 bit7
	reg			[7:0]	status_color;				//	S#7
	reg			[8:0]	status_border_position;		//	S#8, S#9

	wire	[4:0]		reg_screen_mode;
	wire				reg_sprite_magify;
	wire				reg_sprite_16x16;
	wire				reg_display_on;
	wire	[16:10]		reg_pattern_name_table_base;
	wire	[16:6]		reg_color_table_base;
	wire	[16:11]		reg_pattern_generator_table_base;
	wire	[16:7]		reg_sprite_attribute_table_base;
	wire	[16:11]		reg_sprite_pattern_generator_table_base;
	wire	[7:0]		reg_backdrop_color;
	wire				reg_sprite_disable;
	wire				reg_color0_opaque;
	wire				reg_50hz_mode;
	wire				reg_interleaving_mode;
	wire				reg_interlace_mode;
	wire				reg_212lines_mode;
	wire	[7:0]		reg_text_back_color;
	wire	[7:0]		reg_blink_period;
	wire	[3:0]		reg_color_palette_address;
	wire	[7:0]		reg_display_adjust;
	wire	[7:0]		reg_interrupt_line;
	wire	[7:0]		reg_vertical_offset;
	wire				reg_scroll_planes;
	wire				reg_left_mask;
	wire				reg_yjk_mode;
	wire				reg_yae_mode;
	wire				reg_command_enable;
	wire	[8:0]		reg_horizontal_offset;
	reg		[2:0]		reg_horizontal_offset_l;
	reg		[8:3]		reg_horizontal_offset_h;
	reg		[16:0]		ff_last_vram_address;
	reg		[7:0]		ff_last_vram_wdata;

	// --------------------------------------------------------------------
	//	DUT
	// --------------------------------------------------------------------
	vdp_cpu_interface u_cpu_interface ( .* );

	// --------------------------------------------------------------------
	//	clock
	// --------------------------------------------------------------------
	always #(clk_base/2) begin
		clk <= ~clk;
	end

	// --------------------------------------------------------------------
	//	palette
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( palette_valid ) begin
			ff_last_palette_num	<= { 1'b0, palette_num };
			ff_last_palette_r	<= palette_r;
			ff_last_palette_g	<= palette_g;
			ff_last_palette_b	<= palette_b;
		end
	end

	// --------------------------------------------------------------------
	//	Wait ready
	// --------------------------------------------------------------------
	task wait_ready();
		int time_out;

		time_out = 0;
		while( bus_ready == 1'b0 || bus_ready === 1'bx ) begin
			if( time_out >= c_time_out ) begin
				$display( "[ERROR] wait_ready time out" );
				break;
			end
			@( posedge clk );
			time_out = time_out + 1;
		end
	endtask: wait_ready

	// --------------------------------------------------------------------
	//	Write Access
	// --------------------------------------------------------------------
	task write_io(
		input	[1:0]	address,
		input	[7:0]	wdata
	);
		bus_ioreq <= 1'b1;
		bus_address <= address;
		bus_wdata <= wdata;
		bus_write <= 1'b1;
		bus_valid <= 1'b1;
		@( posedge clk );

		wait_ready();

		bus_ioreq <= 1'b0;
		bus_valid <= 1'b0;
		@( posedge clk );
		@( posedge clk );
		@( posedge clk );
		@( posedge clk );
	endtask: write_io

	// --------------------------------------------------------------------
	//	Read Access
	// --------------------------------------------------------------------
	task read_io(
		input	[1:0]	address,
		input	[7:0]	rdata
	);
		int time_out;

		bus_ioreq <= 1'b1;
		bus_address <= address;
		bus_write <= 1'b0;
		bus_valid <= 1'b1;
		@( posedge clk );

		wait_ready();

		bus_ioreq <= 1'b0;
		bus_valid <= 1'b0;
		time_out = 0;
		while( !vram_ready ) begin
			if( time_out >= c_time_out ) begin
				$display( "[ERROR] vram_ready time out" );
				break;
			end
			@( posedge clk );
			time_out = time_out + 1;
		end
		vram_rdata <= rdata;
		vram_rdata_en <= 1'b1;
		@( posedge clk );
		vram_rdata_en <= 1'b0;
		time_out = 0;
		while( !bus_rdata_en ) begin
			if( time_out >= c_time_out ) begin
				$display( "[ERROR] bus_rdata_en time out" );
				break;
			end
			@( posedge clk );
			time_out = time_out + 1;
		end

		assert( rdata == bus_rdata );
	endtask: read_io

	// --------------------------------------------------------------------
	//	Background task
	// --------------------------------------------------------------------
	task vram_response();
		vram_ready <= 1'b0;
		forever begin
			while( vram_valid == 1'b0 || vram_valid === 1'bx ) begin
				@( posedge clk );
			end
			@( posedge clk );
			@( posedge clk );
			vram_ready <= 1'b1;
			@( posedge clk );
			ff_last_vram_address <= vram_address;
			ff_last_vram_wdata <= vram_wdata;
			vram_ready <= 1'b0;
			@( posedge clk );
		end
	endtask: vram_response

	// --------------------------------------------------------------------
	//	Test bench
	// --------------------------------------------------------------------
	initial begin
		clk = 0;
		reset_n = 0;

		bus_address = 0;
		bus_ioreq = 0;
		bus_write = 0;
		bus_valid = 0;
		bus_wdata = 0;

		vram_ready = 0;
		vram_rdata = 0;
		vram_rdata_en = 0;
		ff_last_vram_address = 0;

		ff_last_palette_num = 5'b11111;
		ff_last_palette_r = 0;
		ff_last_palette_g = 0;
		ff_last_palette_b = 0;

		intr_line = 0;
		intr_frame = 0;
		sprite_collision = 0;
		sprite_collision_x = 0;
		sprite_collision_y = 0;

		status_command_enable = 0;		//	S#2 bit0
		status_border_detect = 0;		//	S#2 bit4
		status_transfer_ready = 0;		//	S#2 bit7
		status_color = 0;				//	S#7
		status_border_position = 0;		//	S#8, S#9

		fork
			vram_response();
		join_none

		@( posedge clk );
		@( posedge clk );
		@( posedge clk );
		reset_n <= 1;
		@( posedge clk );

		$display( "[test001] VRAM Write" );
		write_io( 1, 8'h00 );
		write_io( 1, 8'h40 );
		write_io( 0, 8'h12 );
		repeat( 10 ) @( posedge clk );
		assert( ff_last_vram_address == 17'h00000 );
		assert( ff_last_vram_wdata == 8'h12 );

		write_io( 1, 8'h23 );
		write_io( 1, 8'h41 );
		write_io( 0, 8'hAB );
		repeat( 10 ) @( posedge clk );
		assert( ff_last_vram_address == 17'h00123 );
		assert( ff_last_vram_wdata == 8'hAB );

		$display( "[test002] VRAM Write Address Auto Increment" );
		write_io( 0, 8'hCD );
		repeat( 10 ) @( posedge clk );
		assert( ff_last_vram_address == 17'h00124 );
		assert( ff_last_vram_wdata == 8'hCD );

		write_io( 0, 8'hEF );
		repeat( 10 ) @( posedge clk );
		assert( ff_last_vram_address == 17'h00125 );
		assert( ff_last_vram_wdata == 8'hEF );

		$display( "[test003] VRAM Read Address" );
		write_io( 1, 8'h21 );
		write_io( 1, 8'h03 );
		read_io( 0, 8'h56 );
		assert( ff_last_vram_address == 17'h00321 );

		$display( "[test004] VRAM Read Address Auto Increment" );
		read_io( 0, 8'hAB );
		assert( ff_last_vram_address == 17'h00322 );

		read_io( 0, 8'h19 );
		assert( ff_last_vram_address == 17'h00323 );

		read_io( 0, 8'h74 );
		assert( ff_last_vram_address == 17'h00324 );

		$display( "[test005] Write Control Registers" );
		$display( "-- R#0 = 0" );
		write_io( 1, 8'h00 );
		write_io( 1, 8'h80 );
		assert( reg_screen_mode[4:2] == 3'd0 );

		$display( "-- R#0 = 2" );
		write_io( 1, 8'h02 );
		write_io( 1, 8'h80 );
		assert( reg_screen_mode[4:2] == 3'd1 );

		$display( "-- R#0 = 4" );
		write_io( 1, 8'h04 );
		write_io( 1, 8'h80 );
		assert( reg_screen_mode[4:2] == 3'd2 );

		$display( "-- R#0 = 8" );
		write_io( 1, 8'h08 );
		write_io( 1, 8'h80 );
		assert( reg_screen_mode[4:2] == 3'd4 );

		$display( "-- R#0 = 14" );
		write_io( 1, 8'h0E );
		write_io( 1, 8'h80 );
		assert( reg_screen_mode[4:2] == 3'd7 );

		$display( "-- R#1 = 1" );
		write_io( 1, 8'h01 );
		write_io( 1, 8'h81 );
		assert( reg_sprite_magify == 1'd1 );
		assert( reg_sprite_16x16 == 1'd0 );
		assert( reg_screen_mode[1:0] == 2'd0 );
		assert( reg_display_on == 1'd0 );

		$display( "-- R#1 = 2" );
		write_io( 1, 8'h02 );
		write_io( 1, 8'h81 );
		assert( reg_sprite_magify == 1'd0 );
		assert( reg_sprite_16x16 == 1'd1 );
		assert( reg_screen_mode[1:0] == 2'd0 );
		assert( reg_display_on == 1'd0 );

		$display( "-- R#1 = 4" );
		write_io( 1, 8'h04 );
		write_io( 1, 8'h81 );
		assert( reg_sprite_magify == 1'd0 );
		assert( reg_sprite_16x16 == 1'd0 );
		assert( reg_screen_mode[1:0] == 2'd0 );
		assert( reg_display_on == 1'd0 );

		$display( "-- R#1 = 8" );
		write_io( 1, 8'h08 );
		write_io( 1, 8'h81 );
		assert( reg_sprite_magify == 1'd0 );
		assert( reg_sprite_16x16 == 1'd0 );
		assert( reg_screen_mode[1:0] == 2'd2 );
		assert( reg_display_on == 1'd0 );

		$display( "-- R#1 = 16" );
		write_io( 1, 8'h10 );
		write_io( 1, 8'h81 );
		assert( reg_sprite_magify == 1'd0 );
		assert( reg_sprite_16x16 == 1'd0 );
		assert( reg_screen_mode[1:0] == 2'd1 );
		assert( reg_display_on == 1'd0 );

		$display( "-- R#1 = 32" );
		write_io( 1, 8'h20 );
		write_io( 1, 8'h81 );
		assert( reg_sprite_magify == 1'd0 );
		assert( reg_sprite_16x16 == 1'd0 );
		assert( reg_screen_mode[1:0] == 2'd0 );
		assert( reg_display_on == 1'd0 );

		$display( "-- R#1 = 64" );
		write_io( 1, 8'h40 );
		write_io( 1, 8'h81 );
		assert( reg_sprite_magify == 1'd0 );
		assert( reg_sprite_16x16 == 1'd0 );
		assert( reg_screen_mode[1:0] == 2'd0 );
		assert( reg_display_on == 1'd1 );

		$display( "-- R#1 = 128" );
		write_io( 1, 8'h80 );
		write_io( 1, 8'h81 );
		assert( reg_sprite_magify == 1'd0 );
		assert( reg_sprite_16x16 == 1'd0 );
		assert( reg_screen_mode[1:0] == 2'd0 );
		assert( reg_display_on == 1'd0 );

		$display( "-- R#1 = 255" );
		write_io( 1, 8'hFF );
		write_io( 1, 8'h81 );
		assert( reg_sprite_magify == 1'd1 );
		assert( reg_sprite_16x16 == 1'd1 );
		assert( reg_screen_mode[1:0] == 2'd3 );
		assert( reg_display_on == 1'd1 );

		$display( "-- R#2 = 255" );
		write_io( 1, 8'hFF );
		write_io( 1, 8'h82 );
		assert( reg_pattern_name_table_base == 7'h7F );

		$display( "-- R#2 = 55h" );
		write_io( 1, 8'h55 );
		write_io( 1, 8'h82 );
		assert( reg_pattern_name_table_base == 7'h55 );

		$display( "-- R#2 = AAh" );
		write_io( 1, 8'hAA );
		write_io( 1, 8'h82 );
		assert( reg_pattern_name_table_base == 7'h2A );

		$display( "-- R#3 = FFh" );
		write_io( 1, 8'hFF );
		write_io( 1, 8'h83 );
		assert( reg_color_table_base[13:6] == 8'hFF );

		$display( "-- R#3 = 55h" );
		write_io( 1, 8'h55 );
		write_io( 1, 8'h83 );
		assert( reg_color_table_base[13:6] == 8'h55 );

		$display( "-- R#3 = AAh" );
		write_io( 1, 8'hAA );
		write_io( 1, 8'h83 );
		assert( reg_color_table_base[13:6] == 8'hAA );

		$display( "-- R#4 = FFh" );
		write_io( 1, 8'hFF );
		write_io( 1, 8'h84 );
		assert( reg_pattern_generator_table_base == 6'h3F );

		$display( "-- R#4 = 55h" );
		write_io( 1, 8'h55 );
		write_io( 1, 8'h84 );
		assert( reg_pattern_generator_table_base == 6'h15 );

		$display( "-- R#4 = AAh" );
		write_io( 1, 8'hAA );
		write_io( 1, 8'h84 );
		assert( reg_pattern_generator_table_base == 6'h2A );

		$display( "-- R#5 = FFh" );
		write_io( 1, 8'hFF );
		write_io( 1, 8'h85 );
		assert( reg_sprite_attribute_table_base[14:9] == 6'h3F );

		$display( "-- R#5 = 55h" );
		write_io( 1, 8'h55 );
		write_io( 1, 8'h85 );
		assert( reg_sprite_attribute_table_base[14:9] == 6'h15 );

		$display( "-- R#5 = AAh" );
		write_io( 1, 8'hAA );
		write_io( 1, 8'h85 );
		assert( reg_sprite_attribute_table_base[14:9] == 6'h2A );

		$display( "-- R#6 = FFh" );
		write_io( 1, 8'hFF );
		write_io( 1, 8'h86 );
		assert( reg_sprite_pattern_generator_table_base == 6'h3F );

		$display( "-- R#6 = 55h" );
		write_io( 1, 8'h55 );
		write_io( 1, 8'h86 );
		assert( reg_sprite_pattern_generator_table_base == 6'h15 );

		$display( "-- R#6 = AAh" );
		write_io( 1, 8'hAA );
		write_io( 1, 8'h86 );
		assert( reg_sprite_pattern_generator_table_base == 6'h2A );

		$display( "-- R#7 = FFh" );
		write_io( 1, 8'hFF );
		write_io( 1, 8'h87 );
		assert( reg_backdrop_color == 8'hFF );

		$display( "-- R#7 = 55h" );
		write_io( 1, 8'h55 );
		write_io( 1, 8'h87 );
		assert( reg_backdrop_color == 8'h55 );

		$display( "-- R#7 = AAh" );
		write_io( 1, 8'hAA );
		write_io( 1, 8'h87 );
		assert( reg_backdrop_color == 8'hAA );

		$display( "-- R#8 = FFh" );
		write_io( 1, 8'hFF );
		write_io( 1, 8'h88 );
		assert( reg_sprite_disable == 1'b1 );
		assert( reg_color0_opaque == 1'b1 );

		$display( "-- R#8 = 55h" );
		write_io( 1, 8'h55 );
		write_io( 1, 8'h88 );
		assert( reg_sprite_disable == 1'b0 );
		assert( reg_color0_opaque == 1'b0 );

		$display( "-- R#8 = AAh" );
		write_io( 1, 8'hAA );
		write_io( 1, 8'h88 );
		assert( reg_sprite_disable == 1'b1 );
		assert( reg_color0_opaque == 1'b1 );

		$display( "-- R#9 = FFh" );
		write_io( 1, 8'hFF );
		write_io( 1, 8'h89 );
		assert( reg_50hz_mode == 1'b1 );
		assert( reg_interleaving_mode == 1'b1 );
		assert( reg_interlace_mode == 1'b1 );
		assert( reg_212lines_mode == 1'b1 );

		$display( "-- R#9 = 55h" );
		write_io( 1, 8'h55 );
		write_io( 1, 8'h89 );
		assert( reg_50hz_mode == 1'b0 );
		assert( reg_interleaving_mode == 1'b1 );
		assert( reg_interlace_mode == 1'b0 );
		assert( reg_212lines_mode == 1'b0 );

		$display( "-- R#9 = AAh" );
		write_io( 1, 8'hAA );
		write_io( 1, 8'h89 );
		assert( reg_50hz_mode == 1'b1 );
		assert( reg_interleaving_mode == 1'b0 );
		assert( reg_interlace_mode == 1'b1 );
		assert( reg_212lines_mode == 1'b1 );

		$display( "-- R#10 = FFh" );
		write_io( 1, 8'hFF );
		write_io( 1, 8'h8A );
		assert( reg_color_table_base[16:14] == 3'd7 );

		$display( "-- R#10 = 55h" );
		write_io( 1, 8'h55 );
		write_io( 1, 8'h8A );
		assert( reg_color_table_base[16:14] == 3'd5 );

		$display( "-- R#10 = AAh" );
		write_io( 1, 8'hAA );
		write_io( 1, 8'h8A );
		assert( reg_color_table_base[16:14] == 3'd2 );

		$display( "-- R#11 = FFh" );
		write_io( 1, 8'hFF );
		write_io( 1, 8'h8B );
		assert( reg_sprite_attribute_table_base[16:15] == 2'd3 );

		$display( "-- R#11 = 55h" );
		write_io( 1, 8'h55 );
		write_io( 1, 8'h8B );
		assert( reg_sprite_attribute_table_base[16:15] == 2'd1 );

		$display( "-- R#11 = AAh" );
		write_io( 1, 8'hAA );
		write_io( 1, 8'h8B );
		assert( reg_sprite_attribute_table_base[16:15] == 2'd2 );

		$display( "-- R#12 = FFh" );
		write_io( 1, 8'hFF );
		write_io( 1, 8'h8C );
		assert( reg_text_back_color == 8'hFF );

		$display( "-- R#12 = 55h" );
		write_io( 1, 8'h55 );
		write_io( 1, 8'h8C );
		assert( reg_text_back_color == 8'h55 );

		$display( "-- R#12 = AAh" );
		write_io( 1, 8'hAA );
		write_io( 1, 8'h8C );
		assert( reg_text_back_color == 8'hAA );

		$display( "-- R#13 = FFh" );
		write_io( 1, 8'hFF );
		write_io( 1, 8'h8D );
		assert( reg_blink_period == 8'hFF );

		$display( "-- R#13 = 55h" );
		write_io( 1, 8'h55 );
		write_io( 1, 8'h8D );
		assert( reg_blink_period == 8'h55 );

		$display( "-- R#13 = AAh" );
		write_io( 1, 8'hAA );
		write_io( 1, 8'h8D );
		assert( reg_blink_period == 8'hAA );

		$display( "-- R#18 = FFh" );
		write_io( 1, 8'hFF );
		write_io( 1, 8'h92 );
		assert( reg_display_adjust == 8'hFF );

		$display( "-- R#18 = 55h" );
		write_io( 1, 8'h55 );
		write_io( 1, 8'h92 );
		assert( reg_display_adjust == 8'h55 );

		$display( "-- R#18 = AAh" );
		write_io( 1, 8'hAA );
		write_io( 1, 8'h92 );
		assert( reg_display_adjust == 8'hAA );

		$display( "-- R#19 = FFh" );
		write_io( 1, 8'hFF );
		write_io( 1, 8'h93 );
		assert( reg_interrupt_line == 8'hFF );

		$display( "-- R#19 = 55h" );
		write_io( 1, 8'h55 );
		write_io( 1, 8'h93 );
		assert( reg_interrupt_line == 8'h55 );

		$display( "-- R#19 = AAh" );
		write_io( 1, 8'hAA );
		write_io( 1, 8'h93 );
		assert( reg_interrupt_line == 8'hAA );

		$display( "-- R#23 = FFh" );
		write_io( 1, 8'hFF );
		write_io( 1, 8'h97 );
		assert( reg_vertical_offset == 8'hFF );

		$display( "-- R#23 = 55h" );
		write_io( 1, 8'h55 );
		write_io( 1, 8'h97 );
		assert( reg_vertical_offset == 8'h55 );

		$display( "-- R#23 = AAh" );
		write_io( 1, 8'hAA );
		write_io( 1, 8'h97 );
		assert( reg_vertical_offset == 8'hAA );

		$display( "-- R#25 = FFh" );
		write_io( 1, 8'hFF );
		write_io( 1, 8'h99 );
		assert( reg_scroll_planes == 1'b1 );
		assert( reg_left_mask == 1'b1 );
		assert( reg_yjk_mode == 1'b1 );
		assert( reg_yae_mode == 1'b1 );
		assert( reg_command_enable == 1'b1 );

		$display( "-- R#25 = 55h" );
		write_io( 1, 8'h55 );
		write_io( 1, 8'h99 );
		assert( reg_scroll_planes == 1'b1 );
		assert( reg_left_mask == 1'b0 );
		assert( reg_yjk_mode == 1'b0 );
		assert( reg_yae_mode == 1'b1 );
		assert( reg_command_enable == 1'b1 );

		$display( "-- R#25 = AAh" );
		write_io( 1, 8'hAA );
		write_io( 1, 8'h99 );
		assert( reg_scroll_planes == 1'b0 );
		assert( reg_left_mask == 1'b1 );
		assert( reg_yjk_mode == 1'b1 );
		assert( reg_yae_mode == 1'b0 );
		assert( reg_command_enable == 1'b0 );

		$display( "-- R#26 = FFh" );
		write_io( 1, 8'hFF );
		write_io( 1, 8'h9A );
		assert( reg_horizontal_offset_h == 6'h3F );

		$display( "-- R#26 = 55h" );
		write_io( 1, 8'h55 );
		write_io( 1, 8'h9A );
		assert( reg_horizontal_offset_h == 6'h15 );

		$display( "-- R#26 = AAh" );
		write_io( 1, 8'hAA );
		write_io( 1, 8'h9A );
		assert( reg_horizontal_offset_h == 6'h2A );

		$display( "-- R#27 = FFh" );
		write_io( 1, 8'hFF );
		write_io( 1, 8'h9B );
		assert( reg_horizontal_offset_l == 3'h7 );

		$display( "-- R#27 = 55h" );
		write_io( 1, 8'h55 );
		write_io( 1, 8'h9B );
		assert( reg_horizontal_offset_l == 3'h5 );

		$display( "-- R#27 = AAh" );
		write_io( 1, 8'hAA );
		write_io( 1, 8'h9B );
		assert( reg_horizontal_offset_l == 3'h2 );

		$display( "[test006] Palette Write" );
		$display( "-- R#16 = 4" );
		write_io( 1, 8'h04 );
		write_io( 1, 8'h90 );

		assert( ff_last_palette_num == 5'b11111 );
		assert( ff_last_palette_r == 0 );
		assert( ff_last_palette_g == 0 );
		assert( ff_last_palette_b == 0 );

		write_io( 2, 8'h13 );

		assert( ff_last_palette_num == 5'b11111 );
		assert( ff_last_palette_r == 0 );
		assert( ff_last_palette_g == 0 );
		assert( ff_last_palette_b == 0 );

		write_io( 2, 8'h02 );

		assert( ff_last_palette_num == 5'd4 );
		assert( ff_last_palette_r == 1 );
		assert( ff_last_palette_g == 2 );
		assert( ff_last_palette_b == 3 );

		write_io( 2, 8'h46 );

		assert( ff_last_palette_num == 5'd4 );
		assert( ff_last_palette_r == 1 );
		assert( ff_last_palette_g == 2 );
		assert( ff_last_palette_b == 3 );

		write_io( 2, 8'h05 );

		assert( ff_last_palette_num == 5'd5 );
		assert( ff_last_palette_r == 4 );
		assert( ff_last_palette_g == 5 );
		assert( ff_last_palette_b == 6 );

		repeat( 10 ) @( posedge clk );
		$finish;
	end
endmodule
