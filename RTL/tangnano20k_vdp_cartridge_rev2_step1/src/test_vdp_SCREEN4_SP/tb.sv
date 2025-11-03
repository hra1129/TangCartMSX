// -----------------------------------------------------------------------------
//	Test of vdp.v
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
	localparam			clk_base		= 1_000_000_000/85_909_080;	//	ns
	localparam			cpu_clk_base	= 1_000_000_000/ 3_579_545;	//	ps

	localparam			vdp_io0			= 8'h88;
	localparam			vdp_io1			= vdp_io0 + 8'h01;
	localparam			vdp_io2			= vdp_io0 + 8'h02;
	localparam			vdp_io3			= vdp_io0 + 8'h03;

	reg				clk;
	reg				clk14m;
	reg				slot_reset_n;
	reg				slot_iorq_n;
	reg				slot_rd_n;
	reg				slot_wr_n;
	wire			slot_wait;
	wire			slot_intr;
	wire			slot_data_dir;
	reg		[7:0]	slot_a;
	wire	[7:0]	slot_d;
	wire			oe_n;
	reg		[1:0]	dipsw;
	wire			ws2812_led;
	reg		[1:0]	button;

	//	HDMI
	wire			tmds_clk_p;
	wire			tmds_clk_n;
	wire	[2:0]	tmds_d_p;
	wire	[2:0]	tmds_d_n;

	wire			O_sdram_clk;
	wire			O_sdram_cke;
	wire			O_sdram_cs_n;
	wire			O_sdram_ras_n;
	wire			O_sdram_cas_n;
	wire			O_sdram_wen_n;
	wire	[31:0]	IO_sdram_dq;
	wire	[10:0]	O_sdram_addr;
	wire	[ 1:0]	O_sdram_ba;
	wire	[ 3:0]	O_sdram_dqm;

	reg		[7:0]	ff_slot_data;
	reg				slot_clk;

	// --------------------------------------------------------------------
	//	Internal signals
	// --------------------------------------------------------------------
	integer				vram_delay_counter;
	integer				bus_ready_timeout_counter;
	integer				interrupt_timeout_counter;

	// --------------------------------------------------------------------
	//	Loop variables
	// --------------------------------------------------------------------
	integer				i, j, k, x, y;
	string				s_state;

	// --------------------------------------------------------------------
	//	DUT
	// --------------------------------------------------------------------
	tangnano20k_vdp_cartridge u_vdp_cartridge (
		.clk					( clk					),
		.clk14m					( clk14m				),
		.slot_reset_n			( slot_reset_n			),
		.slot_iorq_n			( slot_iorq_n			),
		.slot_rd_n				( slot_rd_n				),
		.slot_wr_n				( slot_wr_n				),
		.slot_wait				( slot_wait				),
		.slot_intr				( slot_intr				),
		.slot_data_dir			( slot_data_dir			),
		.slot_a					( slot_a				),
		.slot_d					( slot_d				),
		.oe_n					( oe_n					),
		.dipsw					( dipsw					),
		.ws2812_led				( ws2812_led			),
		.button					( button				),
		.tmds_clk_p				( tmds_clk_p			),
		.tmds_clk_n				( tmds_clk_n			),
		.tmds_d_p				( tmds_d_p				),
		.tmds_d_n				( tmds_d_n				),
		.O_sdram_clk			( O_sdram_clk			),
		.O_sdram_cke			( O_sdram_cke			),
		.O_sdram_cs_n			( O_sdram_cs_n			),
		.O_sdram_ras_n			( O_sdram_ras_n			),
		.O_sdram_cas_n			( O_sdram_cas_n			),
		.O_sdram_wen_n			( O_sdram_wen_n			),
		.IO_sdram_dq			( IO_sdram_dq			),
		.O_sdram_addr			( O_sdram_addr			),
		.O_sdram_ba				( O_sdram_ba			),
		.O_sdram_dqm			( O_sdram_dqm			)
	);

	assign slot_d	= slot_data_dir ? 8'hZZ : ff_slot_data;

	// --------------------------------------------------------------------
	//	Clock generation
	// --------------------------------------------------------------------
	always #(clk_base/2) begin
		clk14m <= ~clk14m;			//	85MHz
	end

	// --------------------------------------------------------------------
	mt48lc2m32b2 u_sdram (
		.Dq					( IO_sdram_dq				), 
		.Addr				( O_sdram_addr				), 
		.Ba					( O_sdram_ba				), 
		.Clk				( O_sdram_clk				), 
		.Cke				( O_sdram_cke				), 
		.Cs_n				( O_sdram_cs_n				), 
		.Ras_n				( O_sdram_ras_n				), 
		.Cas_n				( O_sdram_cas_n				), 
		.We_n				( O_sdram_wen_n				), 
		.Dqm				( O_sdram_dqm				)
	);

	// --------------------------------------------------------------------
	//	tasks
	// --------------------------------------------------------------------
	task write_io(
		input	[15:0]	address,
		input	[7:0]	wdata
	);
		fork
			//	CPU clock
			begin
				//	T1
				s_state		= "T1";
				slot_clk	= 1'b1;
				#(cpu_clk_base/2) slot_clk	= 1'b0;
				//	T2
				s_state		= "T2";
				#(cpu_clk_base/2) slot_clk	= 1'b1;
				#(cpu_clk_base/2) slot_clk	= 1'b0;
				//	TW
				s_state		= "TW";
				#(cpu_clk_base/2) slot_clk	= 1'b1;
				#(cpu_clk_base/2) slot_clk	= 1'b0;
				//	T3
				s_state		= "T3";
				#(cpu_clk_base/2) slot_clk	= 1'b1;
				#(cpu_clk_base/2) slot_clk	= 1'b0;
				//	T4
				s_state		= "T4";
				#(cpu_clk_base/2) slot_clk	= 1'b1;
				#(cpu_clk_base/2) slot_clk	= 1'b0;
				//	T5
				s_state		= "T5";
				#(cpu_clk_base/2) slot_clk	= 1'b1;
				#(cpu_clk_base/2) slot_clk	= 1'b0;
			end
			//	Address
			begin
				#170ns slot_a = address;
			end
			//	/IORQ
			begin
				slot_iorq_n = 1'b1;
				//	T1
				@( negedge slot_clk );
				@( posedge slot_clk );
				#135ns slot_iorq_n = 1'b0;
				@( negedge slot_clk );
				@( negedge slot_clk );
				@( negedge slot_clk );
				#145ns slot_iorq_n = 1'b1;
			end
			//	/WR
			begin
				slot_wr_n = 1'b1;
				//	T1
				@( negedge slot_clk );
				@( posedge slot_clk );
				#125ns slot_wr_n = 1'b0;
				@( negedge slot_clk );
				@( negedge slot_clk );
				@( negedge slot_clk );
				#120ns slot_wr_n = 1'b1;
			end
			//	others
			begin
				ff_slot_data	= wdata;
			end
		join
	endtask: write_io

	// --------------------------------------------------------------------
	task write_io_ex(
		input	[15:0]	address,
		input	[7:0]	wdata
	);
		fork
			//	CPU clock
			begin
				//	T1
				s_state		= "T1";
				slot_clk	= 1'b1;
				#(cpu_clk_base/2) slot_clk	= 1'b0;
				//	T2
				s_state		= "T2";
				#(cpu_clk_base/2) slot_clk	= 1'b1;
				#(cpu_clk_base/2) slot_clk	= 1'b0;
				//	TW
				s_state		= "TW";
				#(cpu_clk_base/2) slot_clk	= 1'b1;
				#(cpu_clk_base/2) slot_clk	= 1'b0;
				//	T3
				s_state		= "T3";
				#(cpu_clk_base/2) slot_clk	= 1'b1;
				#(cpu_clk_base/2) slot_clk	= 1'b0;
				//	T4
				s_state		= "T4";
				#(cpu_clk_base/2) slot_clk	= 1'b1;
				#(cpu_clk_base/2) slot_clk	= 1'b0;
				//	T5
				s_state		= "T5";
				#(cpu_clk_base/2) slot_clk	= 1'b1;
				#(cpu_clk_base/2) slot_clk	= 1'b0;
			end
			//	Address
			begin
				#170ns slot_a = address;
			end
			//	/IORQ
			begin
				slot_iorq_n = 1'b1;
				//	T1
				@( negedge slot_clk );
				@( posedge slot_clk );
				#175ns slot_iorq_n = 1'b0;
				@( negedge slot_clk );
				@( negedge slot_clk );
				@( negedge slot_clk );
				#185ns slot_iorq_n = 1'b1;
			end
			//	/WR
			begin
				slot_wr_n = 1'b1;
				//	T1
				@( negedge slot_clk );
				@( posedge slot_clk );
				#165ns slot_wr_n = 1'b0;
				@( negedge slot_clk );
				@( negedge slot_clk );
				@( negedge slot_clk );
				#150ns slot_wr_n = 1'b1;
			end
			//	others
			begin
				ff_slot_data	= wdata;
			end
		join
	endtask: write_io_ex

	// --------------------------------------------------------------------
	//	Test bench
	// --------------------------------------------------------------------
	initial begin
		// Initialize signals
		clk = 0;
		clk14m = 0;
		slot_reset_n = 0;
		slot_iorq_n = 1;
		slot_rd_n = 1;
		slot_wr_n = 1;
		slot_a = 0;
		dipsw = 0;
		button = 0;

		// Reset sequence
		repeat(10) @( posedge clk14m );
		slot_reset_n = 1;
		repeat(10) @( posedge clk14m );
		$display( "[test---] Wait initialization" );
		while( slot_wait == 1'b1 ) begin
			@( posedge clk14m );
		end
		repeat(10) @( posedge clk14m );

		$display( "[test001] Write VRAM" );
		//	SCREEN4
		//	VDP R#0 = 0x04
		write_io( vdp_io1, 8'h04 );
		write_io( vdp_io1, 8'h80 );
		//	VDP R#1 = 0x43 Sprite 16x16, magnify
		write_io( vdp_io1, 8'h43 );
		write_io( vdp_io1, 8'h81 );
		//	VDP R#2 = 0xC0 Pattern name table = 0x1800
		write_io( vdp_io1, 8'h06 );
		write_io( vdp_io1, 8'h82 );
		//	VDP R#3 = 0x00 Color name table = 0x2000
		write_io( vdp_io1, 8'h80 );
		write_io( vdp_io1, 8'h83 );
		//	VDP R#4 = 0x00 Pattern generator table = 0x1B00
		write_io( vdp_io1, 8'h00 );
		write_io( vdp_io1, 8'h84 );
		//	VDP R#5 = 0x3F Sprite attribute table
		write_io( vdp_io1, 8'h3F );
		write_io( vdp_io1, 8'h85 );
		//	VDP R#6 = 0x07 Sprite pattern generator table
		write_io( vdp_io1, 8'h07 );
		write_io( vdp_io1, 8'h86 );
		//	VDP R#7 = 0xF4 Background colore
		write_io( vdp_io1, 8'hF4 );
		write_io( vdp_io1, 8'h87 );

		//	VRAM 0x00000 ... 0x07FFF = 0x00
		write_io( vdp_io1, 8'h00 );
		write_io( vdp_io1, 8'h40 );

		for( i = 0; i < 16384; i = i + 1 ) begin
			write_io( vdp_io0, (i & 255) );
		end

		//	VRAM 0x01E00 にアトリビュートを書き込む
		write_io( vdp_io1, 8'h00 );
		write_io( vdp_io1, 8'h80 + 8'd14 );
		write_io( vdp_io1, 0 );
		write_io( vdp_io1, 8'h40 + 8'h1E );
		for( y = 0; y < 4; y++ ) begin
			for( x = 0; x < 4; x++ ) begin
				write_io( vdp_io0, y * 36 );
				write_io( vdp_io0, 40 * x + 50 );
				write_io( vdp_io0, y * 4 );
				write_io( vdp_io0, 0 );
			end
		end

		//	VRAM 0x03800 にパターンを書き込む
		write_io( vdp_io1, 8'h00 );
		write_io( vdp_io1, 8'h80 + 8'd14 );
		write_io( vdp_io1, 8'h00 );
		write_io( vdp_io1, 8'h40 + 8'h38 );
		repeat( 8 ) begin
			repeat( 16 ) write_io( vdp_io0, 8'h11 );	//	#0
			repeat( 16 ) write_io( vdp_io0, 8'h22 );	//	
			repeat( 16 ) write_io( vdp_io0, 8'h33 );	//	#1
			repeat( 16 ) write_io( vdp_io0, 8'h44 );	//	
			repeat( 16 ) write_io( vdp_io0, 8'h55 );	//	#2
			repeat( 16 ) write_io( vdp_io0, 8'h66 );	//	
			repeat( 16 ) write_io( vdp_io0, 8'h77 );	//	#3
			repeat( 16 ) write_io( vdp_io0, 8'h88 );	//	
			repeat( 16 ) write_io( vdp_io0, 8'h99 );	//	#4
			repeat( 16 ) write_io( vdp_io0, 8'hAA );	//	
			repeat( 16 ) write_io( vdp_io0, 8'hBB );	//	#5
			repeat( 16 ) write_io( vdp_io0, 8'hCC );	//	
			repeat( 16 ) write_io( vdp_io0, 8'hDD );	//	#6
			repeat( 16 ) write_io( vdp_io0, 8'hEE );	//	
			repeat( 16 ) write_io( vdp_io0, 8'hFF );	//	#7
			repeat( 16 ) write_io( vdp_io0, 8'h12 );	//	
		end

		//	VRAM 0x01C00 に色を書き込む
		write_io( vdp_io1, 8'h00 );
		write_io( vdp_io1, 8'h80 + 8'd14 );
		write_io( vdp_io1, 8'h00 );
		write_io( vdp_io1, 8'h40 + 8'h1C );
		repeat( 16 ) write_io( vdp_io0, 8'h01 );
		repeat( 16 ) write_io( vdp_io0, 8'h02 );
		repeat( 16 ) write_io( vdp_io0, 8'h03 );
		repeat( 16 ) write_io( vdp_io0, 8'h04 );
		repeat( 16 ) write_io( vdp_io0, 8'h05 );
		repeat( 16 ) write_io( vdp_io0, 8'h06 );
		repeat( 16 ) write_io( vdp_io0, 8'h07 );
		repeat( 16 ) write_io( vdp_io0, 8'h08 );

		repeat( 16 ) write_io( vdp_io0, 8'h09 );
		repeat( 16 ) write_io( vdp_io0, 8'h0A );
		repeat( 16 ) write_io( vdp_io0, 8'h0B );
		repeat( 16 ) write_io( vdp_io0, 8'h0C );
		repeat( 16 ) write_io( vdp_io0, 8'h0D );
		repeat( 16 ) write_io( vdp_io0, 8'h0E );
		repeat( 16 ) write_io( vdp_io0, 8'h0F );
		repeat( 16 ) write_io( vdp_io0, 8'h01 );

		repeat( 16 ) write_io( vdp_io0, 8'h02 );
		repeat( 16 ) write_io( vdp_io0, 8'h03 );
		repeat( 16 ) write_io( vdp_io0, 8'h04 );
		repeat( 16 ) write_io( vdp_io0, 8'h05 );
		repeat( 16 ) write_io( vdp_io0, 8'h06 );
		repeat( 16 ) write_io( vdp_io0, 8'h07 );
		repeat( 16 ) write_io( vdp_io0, 8'h08 );
		repeat( 16 ) write_io( vdp_io0, 8'h09 );

		repeat( 16 ) write_io( vdp_io0, 8'h0A );
		repeat( 16 ) write_io( vdp_io0, 8'h0B );
		repeat( 16 ) write_io( vdp_io0, 8'h0C );
		repeat( 16 ) write_io( vdp_io0, 8'h0D );
		repeat( 16 ) write_io( vdp_io0, 8'h0E );
		repeat( 16 ) write_io( vdp_io0, 8'h0F );
		repeat( 16 ) write_io( vdp_io0, 8'h01 );
		repeat( 16 ) write_io( vdp_io0, 8'h02 );

		repeat(5000000) @( posedge clk14m );

		$display( "[test---] All tests completed" );
		repeat( 100 ) @( posedge clk14m );
		$finish;
	end
endmodule
