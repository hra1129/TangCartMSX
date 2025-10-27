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
	localparam			clk_base		= 1_000_000_000/42_954_540;	//	ns

	// --------------------------------------------------------------------
	//	Signal declarations for DUT ports
	// --------------------------------------------------------------------
	logic				reset_n;
	logic				clk;
	logic				initial_busy;
	logic		[1:0]	bus_address;
	logic				bus_ioreq;
	logic				bus_write;
	logic				bus_valid;
	logic		[7:0]	bus_wdata;
	wire		[7:0]	bus_rdata;
	wire				bus_rdata_en;
	wire				bus_ready;
	wire				int_n;
	wire		[16:0]	vram_address;
	wire				vram_write;
	wire				vram_valid;
	wire		[7:0]	vram_wdata;
	logic		[31:0]	vram_rdata;
	logic				vram_rdata_en;
	wire				display_hs;
	wire				display_vs;
	wire				display_en;
	wire		[7:0]	display_r;
	wire		[7:0]	display_g;
	wire		[7:0]	display_b;
	logic		[7:0]	status;

	// --------------------------------------------------------------------
	//	Internal signals
	// --------------------------------------------------------------------
	logic		[31:0]	vram_memory [0:32767];		// 128KB VRAM simulation (32K×32bit)
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
		.reset_n		( reset_n		),
		.clk			( clk			),
		.initial_busy	( initial_busy	),
		.bus_address	( bus_address	),
		.bus_ioreq		( bus_ioreq		),
		.bus_write		( bus_write		),
		.bus_valid		( bus_valid		),
		.bus_wdata		( bus_wdata		),
		.bus_rdata		( bus_rdata		),
		.bus_rdata_en	( bus_rdata_en	),
		.bus_ready		( bus_ready		),
		.int_n			( int_n			),
		.vram_address	( vram_address	),
		.vram_write		( vram_write	),
		.vram_valid		( vram_valid	),
		.vram_wdata		( vram_wdata	),
		.vram_rdata		( vram_rdata	),
		.vram_rdata_en	( vram_rdata_en	),
		.display_hs		( display_hs	),
		.display_vs		( display_vs	),
		.display_en		( display_en	),
		.display_r		( display_r		),
		.display_g		( display_g		),
		.display_b		( display_b		)
	);

	// --------------------------------------------------------------------
	//	Clock generation
	// --------------------------------------------------------------------
	always #(clk_base/2) begin
		clk <= ~clk;
	end

	// --------------------------------------------------------------------
	//	VRAM simulation
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !reset_n ) begin
			vram_rdata_en <= 1'b0;
			vram_delay_counter <= 0;
		end
		else if( vram_delay_counter ) begin
			if( vram_delay_counter == 1 ) begin
				vram_rdata_en <= 1'b1;
			end
			vram_delay_counter <= vram_delay_counter - 1;
		end
		else begin
			if( vram_valid && !vram_write ) begin
				// Read operation with some delay simulation
				// 下位2bitは無効、4byteアラインで32bit読み出し
				vram_rdata <= vram_memory[vram_address[16:2]];
				vram_rdata_en <= 1'b0;
				vram_delay_counter <= 3;
			end
			else if( vram_valid && vram_write ) begin
				// Write operation
				// 17bit全てのアドレスが有効、8bit書き込み
				case( vram_address[1:0] )
					2'b00: vram_memory[vram_address[16:2]][7:0]   <= vram_wdata;
					2'b01: vram_memory[vram_address[16:2]][15:8]  <= vram_wdata;
					2'b10: vram_memory[vram_address[16:2]][23:16] <= vram_wdata;
					2'b11: vram_memory[vram_address[16:2]][31:24] <= vram_wdata;
				endcase
				vram_rdata_en <= 1'b0;
				vram_delay_counter <= 0;
			end
			else begin
				vram_rdata_en <= 1'b0;
				vram_delay_counter <= 0;
			end
		end
	end

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

	task read_io(input [1:0] io_num, output [7:0] data);
		begin
			// First write: data
			bus_address <= io_num;
			bus_ioreq <= 1'b1;
			bus_write <= 1'b0;
			bus_valid <= 1'b1;
			bus_wdata <= 8'd0;
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
			bus_ready_timeout_counter <= 0;
			@( posedge clk );
			while( !bus_rdata_en && bus_ready_timeout_counter < 100 ) begin
				@( posedge clk );
				bus_ready_timeout_counter <= bus_ready_timeout_counter + 1;
			end
			data = bus_rdata;
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
			bus_wdata <= { 2'b01, addr[13:8] };  // Write mode
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
		clk = 0;
		reset_n = 0;
		initial_busy = 1;
		bus_address = 0;
		bus_ioreq = 0;
		bus_write = 0;
		bus_valid = 0;
		bus_wdata = 0;
		vram_rdata = 0;
		vram_rdata_en = 0;
		bus_ready_timeout_counter = 0;
		interrupt_timeout_counter = 0;

		// Initialize VRAM
		for( i = 0; i < 32768; i++ ) begin
			vram_memory[i] = 32'hF4F4F4F4;
		end

		// Reset sequence
		repeat(10) @( posedge clk );
		reset_n <= 1;
		repeat(10) @( posedge clk );
		initial_busy = 0;
		repeat(10) @( posedge clk );

		$display( "[test001] VDP SCREEN1 test" );
		write_vdp_reg( 8'd00, 8'h00 );	// Mode register 0
		write_vdp_reg( 8'd01, 8'h00 );	// Mode register 1  
		write_vdp_reg( 8'd02, 8'h06 );	// Pattern name table base address
		write_vdp_reg( 8'd03, 8'h80 );	// Color table base address
		write_vdp_reg( 8'd04, 8'h00 );	// Pattern generator table base address
		write_vdp_reg( 8'd05, 8'h20 );	// Sprite attribute table base address
		write_vdp_reg( 8'd06, 8'h00 );	// Sprite pattern generator table base address
		write_vdp_reg( 8'd07, 8'h07 );	// Backdrop color

		$display( "[test002] Enable display test" );
		
		// Enable display
		write_vdp_reg( 8'h01, 8'h40 );	// Display enable

		$display( "[test003] display signal test" );

		for( i = 0; i < 2000; i++ ) begin
			for( j = 0; j < 1368; j++ ) begin
				@( posedge clk );
			end
		end
		for( j = 0; j < 700; j++ ) begin
			@( posedge clk );
		end

		$display( "[test004] VRAM write test" );
		write_io( 2'd1, 8'h00 );	// VRAM Address 0
		write_io( 2'd1, 8'h40 );

		write_io( 2'd0, 8'h01 );
		write_io( 2'd0, 8'h02 );
		write_io( 2'd0, 8'h04 );
		write_io( 2'd0, 8'h08 );
		write_io( 2'd0, 8'h10 );
		write_io( 2'd0, 8'h20 );
		write_io( 2'd0, 8'h40 );
		write_io( 2'd0, 8'h80 );

		$display( "[test005] VRAM read test" );
		write_io( 2'd1, 8'h00 );	// VRAM Address 0
		write_io( 2'd1, 8'h00 );

		read_io( 2'd0, status );	assert( status == 8'h01 );
		read_io( 2'd0, status );	assert( status == 8'h02 );
		read_io( 2'd0, status );	assert( status == 8'h04 );
		read_io( 2'd0, status );	assert( status == 8'h08 );
		read_io( 2'd0, status );	assert( status == 8'h10 );
		read_io( 2'd0, status );	assert( status == 8'h20 );
		read_io( 2'd0, status );	assert( status == 8'h40 );
		read_io( 2'd0, status );	assert( status == 8'h80 );
		repeat( 100 ) @( posedge clk );

		$display( "[test006] VDP SCREEN0(W40) test" );
		write_vdp_reg( 8'd00, 8'h00 );	// Mode register 0
		write_vdp_reg( 8'd01, 8'h10 );	// Mode register 1  
		write_vdp_reg( 8'd02, 8'h00 );	// Pattern name table base address
		write_vdp_reg( 8'd03, 8'h80 );	// Color table base address
		write_vdp_reg( 8'd04, 8'h01 );	// Pattern generator table base address
		write_vdp_reg( 8'd05, 8'h20 );	// Sprite attribute table base address
		write_vdp_reg( 8'd06, 8'h00 );	// Sprite pattern generator table base address
		write_vdp_reg( 8'd07, 8'h04 );	// Backdrop color

		for( i = 0; i < 2000; i++ ) begin
			for( j = 0; j < 1368; j++ ) begin
				@( posedge clk );
			end
		end
		for( j = 0; j < 600; j++ ) begin
			@( posedge clk );
		end

		$display( "[test005] VRAM read test" );
		write_io( 2'd1, 8'h00 );	// VRAM Address 0
		write_io( 2'd1, 8'h00 );

		read_io( 2'd0, status );	assert( status == 8'h01 );
		@( posedge clk );
		read_io( 2'd0, status );	assert( status == 8'h02 );
		@( posedge clk );
		read_io( 2'd0, status );	assert( status == 8'h04 );
		@( posedge clk );
		read_io( 2'd0, status );	assert( status == 8'h08 );
		@( posedge clk );
		read_io( 2'd0, status );	assert( status == 8'h10 );
		@( posedge clk );
		read_io( 2'd0, status );	assert( status == 8'h20 );
		@( posedge clk );
		read_io( 2'd0, status );	assert( status == 8'h40 );
		@( posedge clk );
		read_io( 2'd0, status );	assert( status == 8'h80 );
		@( posedge clk );

		$display( "[test---] All tests completed" );
		repeat( 100 ) @( posedge clk );

		$finish;
	end

	// --------------------------------------------------------------------
	//	Monitor display signals
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( display_en && display_r != 0 && display_g != 0 && display_b != 0 ) begin
			// $display( "Active pixel at time %t: R=%02h G=%02h B=%02h", $time, display_r, display_g, display_b );
		end
	end

endmodule
