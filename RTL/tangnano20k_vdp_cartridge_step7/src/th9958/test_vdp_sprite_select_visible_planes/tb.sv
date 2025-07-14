// -----------------------------------------------------------------------------
//	Test of vdp_sprite_select_visible_planes.v
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

	// Input signals
	reg			[12:0]	screen_pos_x;
	reg			[ 7:0]	pixel_pos_y;
	reg					screen_active;
	reg			[31:0]	vram_rdata;
	reg					sprite_mode2;
	reg					reg_sprite_magify;
	reg					reg_sprite_16x16;
	reg			[16:9]	reg_sprite_attribute_table_base;

	// Output signals
	wire		[16:0]	vram_address;
	wire				vram_valid;
	wire				selected_en;
	wire		[4:0]	selected_plane_num;
	wire		[3:0]	selected_y;
	wire		[7:0]	selected_x;
	wire		[7:0]	selected_pattern;
	wire		[7:0]	selected_color;
	wire		[3:0]	selected_count;
	wire				start_info_collect;

	// VRAM simulation
	reg			[31:0]	sprite_attr_table [0:31];
	integer				i;

	// --------------------------------------------------------------------
	//	DUT
	// --------------------------------------------------------------------
	vdp_sprite_select_visible_planes u_sprite_select_visible_planes (
		.reset_n						( reset_n							),
		.clk							( clk								),
		.screen_pos_x					( screen_pos_x						),
		.pixel_pos_y					( pixel_pos_y						),
		.screen_active					( screen_active						),
		.vram_address					( vram_address						),
		.vram_valid						( vram_valid						),
		.vram_rdata						( vram_rdata						),
		.selected_en					( selected_en						),
		.selected_plane_num				( selected_plane_num				),
		.selected_y						( selected_y						),
		.selected_x						( selected_x						),
		.selected_pattern				( selected_pattern					),
		.selected_color					( selected_color					),
		.selected_count					( selected_count					),
		.start_info_collect				( start_info_collect				),
		.sprite_mode2					( sprite_mode2						),
		.reg_sprite_magify				( reg_sprite_magify					),
		.reg_sprite_16x16				( reg_sprite_16x16					),
		.reg_sprite_attribute_table_base( reg_sprite_attribute_table_base	)
	);

	// --------------------------------------------------------------------
	//	VRAM simulation
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( vram_valid ) begin
			// Extract plane number from VRAM address
			vram_rdata <= sprite_attr_table[vram_address[6:2]];
		end
	end

	// --------------------------------------------------------------------
	//	clock
	// --------------------------------------------------------------------
	always #(clk_base/2) begin
		clk <= ~clk;
	end

	// --------------------------------------------------------------------
	//	Test task
	// --------------------------------------------------------------------
	task automatic wait_cycles;
		input integer cycles;
		begin
			repeat( cycles ) @( posedge clk );
		end
	endtask

	task automatic initialize_sprite_table;
		begin
			// Initialize sprite attribute table
			for( i = 0; i < 32; i = i + 1 ) begin
				sprite_attr_table[i] = 32'h00000000;  // All sprites off-screen initially
			end
			
			// Set up some test sprites
			// Format: [31:24]=color, [23:16]=pattern, [15:8]=x, [7:0]=y
			sprite_attr_table[0]  = 32'h0F1040D0;  // y=208, x=64,  pattern=16, color=15 (visible)
			sprite_attr_table[1]  = 32'h0E2050D8;  // y=216, x=80,  pattern=32, color=14 (visible)
			sprite_attr_table[2]  = 32'h0D3060E0;  // y=224, x=96,  pattern=48, color=13 (not visible)
			sprite_attr_table[3]  = 32'h0C4070C0;  // y=192, x=112, pattern=64, color=12 (visible)
			sprite_attr_table[4]  = 32'h0B5080D0;  // y=208, x=128, pattern=80, color=11 (visible)
		end
	endtask

	task automatic simulate_scanline;
		input [7:0] scan_y;
		begin
			pixel_pos_y = scan_y;
			screen_active = 1'b1;
			
			$display("=== Scanning line Y=%d ===", scan_y);
			
			// Simulate horizontal scan (sprite collection phase)
			for( screen_pos_x = 13'd0; screen_pos_x < 13'd2048; screen_pos_x = screen_pos_x + 13'd1 ) begin
				@( posedge clk );
				
				// Monitor sprite selection
				if( selected_en ) begin
					$display("  Sprite selected: plane=%d, y_offset=%d, x=%d, pattern=%02X, color=%02X, count=%d",
						selected_plane_num, selected_y, selected_x, selected_pattern, selected_color, selected_count);
				end
				
				if( start_info_collect ) begin
					$display("  Info collection phase started");
				end
			end
			
			screen_active = 1'b0;
			wait_cycles(10);
		end
	endtask

	// --------------------------------------------------------------------
	//	Test bench
	// --------------------------------------------------------------------
	initial begin
		$display("=== VDP Sprite Select Visible Planes Test ===");
		
		// Initialize signals
		clk = 1'b0;
		reset_n = 1'b0;
		screen_pos_x = 13'd0;
		pixel_pos_y = 8'd0;
		screen_active = 1'b0;
		vram_rdata = 32'd0;
		sprite_mode2 = 1'b1;
		reg_sprite_magify = 1'b0;
		reg_sprite_16x16 = 1'b0;
		reg_sprite_attribute_table_base = 8'h3E;  // Typical sprite attribute table base

		// Initialize sprite table
		initialize_sprite_table();

		// Reset sequence
		wait_cycles(10);
		reset_n = 1'b1;
		wait_cycles(10);

		$display("=== Test 1: Normal 8x8 sprites ===");
		reg_sprite_16x16 = 1'b0;
		reg_sprite_magify = 1'b0;
		
		// Test scanlines with different Y positions
		simulate_scanline(8'd208);  // Should detect sprites 0, 4
		simulate_scanline(8'd216);  // Should detect sprite 1
		simulate_scanline(8'd192);  // Should detect sprite 3
		simulate_scanline(8'd100);  // Should detect no sprites

		$display("=== Test 2: Magnified 8x8 sprites ===");
		reg_sprite_magify = 1'b1;
		
		simulate_scanline(8'd208);  // Should detect sprites with magnification

		$display("=== Test 3: 16x16 sprites ===");
		reg_sprite_16x16 = 1'b1;
		reg_sprite_magify = 1'b0;
		
		simulate_scanline(8'd208);  // Should detect 16x16 sprites

		$display("=== Test 4: 16x16 magnified sprites ===");
		reg_sprite_16x16 = 1'b1;
		reg_sprite_magify = 1'b1;
		
		simulate_scanline(8'd208);  // Should detect magnified 16x16 sprites

		$display("=== Test completed ===");
		wait_cycles(100);
		$finish;
	end

	// --------------------------------------------------------------------
	//	Monitor
	// --------------------------------------------------------------------
	initial begin
		$dumpfile("wave.vcd");
		$dumpvars(0, tb);
	end

endmodule
