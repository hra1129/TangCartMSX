// -----------------------------------------------------------------------------
//	Test of vdp_sprite_info_collect.v
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

	// Clock and reset
	reg					reset_n;
	reg					clk;					//	42.95454MHz
	
	// DUT input signals
	wire				start_info_collect;
	reg		[12:0]		screen_pos_x;
	wire				screen_active;
	reg		[31:0]		vram_rdata;
	reg		[2:0]		current_plane;
	reg					selected_en;
	reg		[4:0]		selected_plane_num;
	reg		[3:0]		selected_y;
	reg		[7:0]		selected_x;
	reg		[7:0]		selected_pattern;
	reg		[7:0]		selected_color;
	reg		[3:0]		selected_count;
	reg					sprite_mode2;
	reg					reg_sprite_magify;
	reg					reg_sprite_16x16;
	reg		[16:9]		reg_sprite_attribute_table_base;
	reg		[16:11]		reg_sprite_pattern_generator_table_base;
	
	// DUT output signals
	wire	[16:0]		vram_address;
	wire				vram_valid;
	wire	[2:0]		makeup_plane;
	wire	[7:0]		pattern_left;
	wire				pattern_left_en;
	wire	[7:0]		pattern_right;
	wire				pattern_right_en;
	wire	[7:0]		color;
	wire				color_en;

	// --------------------------------------------------------------------
	//	DUT
	// --------------------------------------------------------------------
	vdp_sprite_info_collect u_sprite_info_collect (
		.reset_n									( reset_n										),
		.clk										( clk											),
		.start_info_collect							( start_info_collect							),
		.screen_pos_x								( screen_pos_x									),
		.screen_active								( screen_active									),
		.vram_address								( vram_address									),
		.vram_valid									( vram_valid									),
		.vram_rdata									( vram_rdata									),
		.selected_en								( selected_en									),
		.selected_plane_num							( selected_plane_num							),
		.selected_y									( selected_y									),
		.selected_x									( selected_x									),
		.selected_pattern							( selected_pattern								),
		.selected_color								( selected_color								),
		.selected_count								( selected_count								),
		.makeup_plane								( makeup_plane									),
		.pattern_left								( pattern_left									),
		.pattern_left_en							( pattern_left_en								),
		.pattern_right								( pattern_right									),
		.pattern_right_en							( pattern_right_en								),
		.color										( color											),
		.color_en									( color_en										),
		.sprite_mode2								( sprite_mode2									),
		.reg_sprite_magify							( reg_sprite_magify								),
		.reg_sprite_16x16							( reg_sprite_16x16								),
		.reg_sprite_attribute_table_base			( reg_sprite_attribute_table_base				),
		.reg_sprite_pattern_generator_table_base	( reg_sprite_pattern_generator_table_base		)
	);

	// Simple VRAM model - returns test pattern data
	always @(posedge clk) begin
		if (vram_valid) begin
			// Return test pattern based on address
			vram_rdata <= {24'h0, vram_address[7:0]};
		end
	end

	always @( posedge clk ) begin
		if( !reset_n ) begin
			screen_pos_x <= 'd0;
		end
		else if( screen_pos_x == 'd2735 ) begin
			screen_pos_x <= 'd0;
		end
		else begin
			screen_pos_x <= screen_pos_x + 'd1;
		end
	end

	assign start_info_collect	= (screen_pos_x == 'd2047);
	assign screen_active		= (screen_pos_x >= 'd0 && screen_active <= 'd2047);

	// --------------------------------------------------------------------
	//	clock
	// --------------------------------------------------------------------
	always #(clk_base/2) begin
		clk <= ~clk;
	end

	// Task to wait for N clock cycles
	task wait_clocks(input integer cycles);
		repeat(cycles) @(posedge clk);
	endtask

	task wait_start_info_collect();
		while( start_info_collect == 1'b0 ) begin
			@( posedge clk );
		end
	endtask

	// Task to initialize signals
	task init_signals();
		vram_rdata <= 32'h0;
		current_plane <= 3'd0;
		selected_en <= 1'b0;
		selected_plane_num <= 5'd0;
		selected_y <= 4'd0;
		selected_x <= 8'd0;
		selected_pattern <= 8'h55;
		selected_color <= 8'h0F;
		selected_count <= 4'd0;
		sprite_mode2 <= 1'b0;
		reg_sprite_magify <= 1'b0;
		reg_sprite_16x16 <= 1'b0;
		reg_sprite_attribute_table_base <= 8'h1B;
		reg_sprite_pattern_generator_table_base <= 6'h07;
	endtask
	
	// Task to perform reset
	task reset_dut();
		reset_n <= 1'b0;
		wait_clocks(10);
		reset_n <= 1'b1;
		wait_clocks(5);
	endtask

	// --------------------------------------------------------------------
	//	Test bench
	// --------------------------------------------------------------------
	initial begin
		$display("Starting vdp_sprite_info_collect testbench");
		
		// Initialize signals
		clk = 1'b0;
		init_signals();
		
		// Reset the DUT
		reset_dut();
		
		// Test 1: Basic operation in 8x8 sprite mode
		$display("Test 1: Basic 8x8 sprite collection");
		selected_pattern <= 8'h42;
		selected_color <= 8'h0C;
		selected_y <= 4'd3;
		sprite_mode2 <= 1'b0;
		reg_sprite_16x16 <= 1'b0;
		
		wait_start_info_collect();
		wait_clocks(200);
		
		// Test 2: 16x16 sprite mode
		$display("Test 2: 16x16 sprite collection");
		reg_sprite_16x16 <= 1'b1;
		sprite_mode2 <= 1'b0;
		selected_pattern <= 8'h24;

		wait_start_info_collect();
		wait_clocks(200);
		
		// Test 3: Sprite mode 2
		$display("Test 3: Sprite mode 2 collection");
		sprite_mode2 <= 1'b1;
		reg_sprite_16x16 <= 1'b0;
		selected_pattern <= 8'h33;
		
		wait_start_info_collect();
		wait_clocks(200);
		
		// Test 4: Screen position cycling test
		$display("Test 4: Screen position cycling");
		sprite_mode2 <= 1'b0;
		reg_sprite_16x16 <= 1'b0;
		
		wait_start_info_collect();
		wait_clocks(200);
		
		wait_start_info_collect();
		$display("Testbench completed successfully");
		$finish;
	end
	
	// Monitor important signals
	always @(posedge clk) begin
		if (pattern_left_en) begin
			$display("Time %0t: Pattern left collected: 0x%02X (plane %0d)", $time, pattern_left, current_plane);
		end
		if (pattern_right_en) begin
			$display("Time %0t: Pattern right collected: 0x%02X (plane %0d)", $time, pattern_right, current_plane);
		end
		if (color_en) begin
			$display("Time %0t: Color collected: 0x%02X (plane %0d)", $time, color, current_plane);
		end
		if (vram_valid) begin
			$display("Time %0t: VRAM access - Address: 0x%05X", $time, vram_address);
		end
	end

endmodule
