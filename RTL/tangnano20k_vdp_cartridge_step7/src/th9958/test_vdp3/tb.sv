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

	// --------------------------------------------------------------------
	//	Signal declarations for DUT ports
	// --------------------------------------------------------------------
	logic				clk85m;
	logic				reset_n;
	logic				clk;
	wire				w_dram_init_busy;
	logic		[1:0]	bus_address;
	logic				bus_ioreq;
	logic				bus_write;
	logic				bus_valid;
	logic		[7:0]	bus_wdata;
	wire		[7:0]	bus_rdata;
	wire				bus_rdata_en;
	wire				bus_ready;
	wire				int_n;
	wire		[16:0]	w_vram_address;
	wire				w_vram_write;
	wire				w_vram_valid;
	wire		[7:0]	w_vram_wdata;
	wire		[31:0]	w_vram_rdata;
	wire				w_vram_rdata_en;
	wire				display_hs;
	wire				display_vs;
	wire				display_en;
	wire		[7:0]	display_r;
	wire		[7:0]	display_g;
	wire		[7:0]	display_b;
	logic		[7:0]	status;
	wire				O_sdram_clk;
	wire				O_sdram_cke;
	wire				O_sdram_cs_n;	// chip select
	wire				O_sdram_ras_n;	// row address select
	wire				O_sdram_cas_n;	// columns address select
	wire				O_sdram_wen_n;	// write enable
	wire		[31:0]	IO_sdram_dq;	// 32 bit bidirectional data bus
	wire		[10:0]	O_sdram_addr;	// 11 bit multiplexed address bus
	wire		[ 1:0]	O_sdram_ba;		// two banks
	wire		[ 3:0]	O_sdram_dqm;	// data mask

	// --------------------------------------------------------------------
	//	Internal signals
	// --------------------------------------------------------------------
	integer				vram_delay_counter;
	integer				bus_ready_timeout_counter;
	integer				interrupt_timeout_counter;

	// --------------------------------------------------------------------
	//	Loop variables
	// --------------------------------------------------------------------
	integer				i, j, k;

	// --------------------------------------------------------------------
	//	DUT
	// --------------------------------------------------------------------
	vdp u_vdp (
		.reset_n		( reset_n				),
		.clk			( clk					),
		.initial_busy	( w_dram_init_busy		),
		.bus_address	( bus_address			),
		.bus_ioreq		( bus_ioreq				),
		.bus_write		( bus_write				),
		.bus_valid		( bus_valid				),
		.bus_wdata		( bus_wdata				),
		.bus_rdata		( bus_rdata				),
		.bus_rdata_en	( bus_rdata_en			),
		.bus_ready		( bus_ready				),
		.int_n			( int_n					),
		.vram_address	( w_vram_address[16:0]	),
		.vram_write		( w_vram_write			),
		.vram_valid		( w_vram_valid			),
		.vram_wdata		( w_vram_wdata			),
		.vram_rdata		( w_vram_rdata			),
		.vram_rdata_en	( w_vram_rdata_en		),
		.display_hs		( display_hs			),
		.display_vs		( display_vs			),
		.display_en		( display_en			),
		.display_r		( display_r				),
		.display_g		( display_g				),
		.display_b		( display_b				)
	);

	// --------------------------------------------------------------------
	//	Clock generation
	// --------------------------------------------------------------------
	always #(clk_base/2) begin
		clk85m <= ~clk85m;
	end

	always @( posedge clk85m ) begin
		clk <= ~clk;
	end

	// --------------------------------------------------------------------
	//	VRAM
	// --------------------------------------------------------------------
	ip_sdram #(
		.FREQ				( 85_909_080				)		//	Hz
	) u_sdram_controller (
		.reset_n			( reset_n					),
		.clk				( clk85m					),		//	85.90908MHz
		.clk_sdram			( clk85m					),
		.sdram_init_busy	( w_dram_init_busy			),
		.bus_address		( { 6'd0, w_vram_address }	),
		.bus_valid			( w_vram_valid				),
		.bus_write			( w_vram_write				),
		.bus_refresh		( 1'b0						),
		.bus_wdata			( w_vram_wdata				),
		.bus_rdata			( w_vram_rdata				),
		.bus_rdata_en		( w_vram_rdata_en			),
		.O_sdram_clk		( O_sdram_clk				),
		.O_sdram_cke		( O_sdram_cke				),
		.O_sdram_cs_n		( O_sdram_cs_n				),		// chip select
		.O_sdram_ras_n		( O_sdram_ras_n				),		// row address select
		.O_sdram_cas_n		( O_sdram_cas_n				),		// columns address select
		.O_sdram_wen_n		( O_sdram_wen_n				),		// write enable
		.IO_sdram_dq		( IO_sdram_dq				),		// 32 bit bidirectional data bus
		.O_sdram_addr		( O_sdram_addr				),		// 11 bit multiplexed address bus
		.O_sdram_ba			( O_sdram_ba				),		// two banks
		.O_sdram_dqm		( O_sdram_dqm				)		// data mask
	);

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
	//	CPU bus write task
	// --------------------------------------------------------------------
	task write_io(input [1:0] io_num, input [7:0] data);
		begin
			// First write: data
			bus_address <= io_num;
			bus_ioreq <= 1'b1;
			bus_write <= 1'b1;
			bus_valid <= 1'b1;
			bus_wdata <= data;
			bus_ready_timeout_counter <= 0;
			@( posedge clk );
			
			// Wait for bus_ready with timeout
			while( !bus_ready && bus_ready_timeout_counter < 100 ) begin
				@( posedge clk );
				bus_ready_timeout_counter <= bus_ready_timeout_counter + 1;
			end
			if( bus_ready_timeout_counter >= 100 ) begin
				$display( "ERROR: bus_ready timeout during VDP register write (data phase)" );
				$stop;
			end
			
			bus_valid <= 1'b0;
			@( posedge clk );
		end
	endtask

	task write_vdp_reg(input [7:0] reg_num, input [7:0] data);
		begin
			// First write: data
			bus_address <= 2'd1;
			bus_ioreq <= 1'b1;
			bus_write <= 1'b1;
			bus_valid <= 1'b1;
			bus_wdata <= data;
			bus_ready_timeout_counter <= 0;
			@( posedge clk );

			// Wait for bus_ready with timeout
			while( !bus_ready && bus_ready_timeout_counter < 100 ) begin
				@( posedge clk );
				bus_ready_timeout_counter <= bus_ready_timeout_counter + 1;
			end
			if( bus_ready_timeout_counter >= 100 ) begin
				$display( "ERROR: bus_ready timeout during VDP register write (data phase)" );
				$stop;
			end

			bus_valid <= 1'b0;
			@( posedge clk );

			// Second write: register number with control bit
			bus_address <= 2'd1;
			bus_ioreq <= 1'b1;
			bus_write <= 1'b1;
			bus_valid <= 1'b1;
			bus_wdata <= reg_num | 8'h80;
			bus_ready_timeout_counter <= 0;
			@( posedge clk );

			// Wait for bus_ready with timeout
			while( !bus_ready && bus_ready_timeout_counter < 100 ) begin
				@( posedge clk );
				bus_ready_timeout_counter <= bus_ready_timeout_counter + 1;
			end
			if( bus_ready_timeout_counter >= 100 ) begin
				$display( "ERROR: bus_ready timeout during VDP register write (register phase)" );
				$stop;
			end
			
			bus_valid <= 1'b0;
			@( posedge clk );
		end
	endtask

	task write_vram(input [16:0] addr, input [7:0] data);
		begin
			// Set VRAM address (low byte)
			bus_address <= 2'd1;
			bus_ioreq <= 1'b1;
			bus_write <= 1'b1;
			bus_valid <= 1'b1;
			bus_wdata <= addr[7:0];
			bus_ready_timeout_counter <= 0;
			@( posedge clk );
			
			// Wait for bus_ready with timeout
			while( !bus_ready && bus_ready_timeout_counter < 100 ) begin
				@( posedge clk );
				bus_ready_timeout_counter <= bus_ready_timeout_counter + 1;
			end
			if( bus_ready_timeout_counter >= 100 ) begin
				$display( "ERROR: bus_ready timeout during VRAM address write (low byte)" );
				$stop;
			end

			bus_valid <= 1'b0;
			@( posedge clk );

			// Set VRAM address (high byte with write mode)
			bus_address <= 2'd1;
			bus_ioreq <= 1'b1;
			bus_write <= 1'b1;
			bus_valid <= 1'b1;
			bus_wdata <= { 2'd0, addr[13:8] } | 8'h40;  // Write mode
			bus_ready_timeout_counter <= 0;
			@( posedge clk );

			// Wait for bus_ready with timeout
			while( !bus_ready && bus_ready_timeout_counter < 100 ) begin
				@( posedge clk );
				bus_ready_timeout_counter <= bus_ready_timeout_counter + 1;
			end
			if( bus_ready_timeout_counter >= 100 ) begin
				$display( "ERROR: bus_ready timeout during VRAM address write (high byte)" );
				$stop;
			end

			bus_valid <= 1'b0;
			@( posedge clk );

			// Write data
			bus_address <= 2'd0;
			bus_ioreq <= 1'b1;
			bus_write <= 1'b1;
			bus_valid <= 1'b1;
			bus_wdata <= data;
			bus_ready_timeout_counter <= 0;
			@( posedge clk );

			// Wait for bus_ready with timeout
			while( !bus_ready && bus_ready_timeout_counter < 100 ) begin
				@( posedge clk );
				bus_ready_timeout_counter <= bus_ready_timeout_counter + 1;
			end
			if( bus_ready_timeout_counter >= 100 ) begin
				$display( "ERROR: bus_ready timeout during VRAM data write" );
				$stop;
			end

			bus_valid <= 1'b0;
			@( posedge clk );
		end
	endtask

	task read_status_register(output [7:0] status);
		begin
			bus_address <= 2'd1;
			bus_ioreq <= 1'b1;
			bus_write <= 1'b0;
			bus_valid <= 1'b1;
			bus_ready_timeout_counter <= 0;
			@( posedge clk );

			// Wait for bus_ready with timeout
			while( !bus_ready && bus_ready_timeout_counter < 100 ) begin
				@( posedge clk );
				bus_ready_timeout_counter <= bus_ready_timeout_counter + 1;
			end
			if( bus_ready_timeout_counter >= 100 ) begin
				$display( "ERROR: bus_ready timeout during status register read" );
				$stop;
			end

			bus_valid <= 1'b0;
			bus_ready_timeout_counter <= 0;
			@( posedge clk );
			while( !bus_rdata_en && bus_ready_timeout_counter < 100 ) begin
				@( posedge clk );
				bus_ready_timeout_counter <= bus_ready_timeout_counter + 1;
			end
			status = bus_rdata;
			@( posedge clk );
		end
	endtask

	// --------------------------------------------------------------------
	//	Test bench
	// --------------------------------------------------------------------
	initial begin
		// Initialize signals
		clk85m = 0;
		clk = 0;
		reset_n = 0;
		bus_address = 0;
		bus_ioreq = 0;
		bus_write = 0;
		bus_valid = 0;
		bus_wdata = 0;
		bus_ready_timeout_counter = 0;
		interrupt_timeout_counter = 0;

		// Reset sequence
		repeat(10) @( posedge clk );
		reset_n <= 1;
		repeat(10) @( posedge clk );

		$display( "[test000] Not VRAM access in initial busy period test" );
		repeat( 1368 * 1000 ) @( posedge clk );

		while( w_dram_init_busy ) begin
			@( posedge clk );
		end
		repeat(10) @( posedge clk );

		$display( "[test001] SCREEN5" );
		write_vdp_reg( 8'd00, 8'h06 );	// Mode register 0
		write_vdp_reg( 8'd01, 8'h40 );	// Mode register 1  
		write_vdp_reg( 8'd02, 8'h1F );	// Pattern name table base address
		write_vdp_reg( 8'd07, 8'h07 );	// Backdrop color
		write_vdp_reg( 8'd14, 8'd0  );
		repeat(10) @( posedge clk );

		$display( "[test003] VRAM write test" );
		// Write some test patterns to VRAM
		for( i = 0; i < 32768; i++ ) begin
			write_vram( i, i[7:0] );
		end

		// Run for several frames to observe video output
		for( j = 0; j < 5; j++ ) begin
			// Wait for vertical sync
			@( negedge display_vs );
			@( posedge display_vs );
			$display( "Frame %d completed", j );
		end

		$display( "[test---] All tests completed" );
		repeat( 100 ) @( posedge clk );
		$finish;
	end
endmodule
