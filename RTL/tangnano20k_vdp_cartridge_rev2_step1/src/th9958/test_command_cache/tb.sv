// -----------------------------------------------------------------------------
//	Test of vdp_command_cache.v
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
	localparam			clk_base	= 1_000_000_000/42_954_540;    //      ns

	// --------------------------------------------------------------------
	//	Signal declarations for DUT ports
	// --------------------------------------------------------------------
	logic				reset_n;
	logic				clk;
	logic				start;
	logic				cache_flush_start;
	wire				cache_flush_end;
	
	// VDP command interface
	logic	[16:0]		cache_vram_address;
	logic				cache_vram_valid;
	wire				cache_vram_ready;
	logic				cache_vram_write;
	logic	[7:0]		cache_vram_wdata;
	wire	[7:0]		cache_vram_rdata;
	wire				cache_vram_rdata_en;
	
	// VRAM interface
	wire	[16:0]		command_vram_address;
	wire				command_vram_valid;
	logic				command_vram_ready;
	wire				command_vram_write;
	wire	[31:0]		command_vram_wdata;
	wire	[3:0]		command_vram_wdata_mask;
	logic	[31:0]		command_vram_rdata;
	logic				command_vram_rdata_en;
	logic	[31:0]		last_vram_wdata;
	logic	[3:0]		last_vram_wdata_mask;
	logic	[31:0]		last_vram_rdata;
	integer				last_vram_write_count = 0;
	integer				last_vram_read_count = 0;

	// --------------------------------------------------------------------
	//	Internal signals
	// --------------------------------------------------------------------
	logic	[31:0]		vram_memory [0:32767];		// 128KB VRAM simulation (32K×32bit)
	integer				vram_delay_counter;
	integer				timeout_counter;

	// --------------------------------------------------------------------
	//	Loop variables
	// --------------------------------------------------------------------
	integer			i, j, k;

	// --------------------------------------------------------------------
	//	DUT: Device Under Test
	// --------------------------------------------------------------------
	vdp_command_cache u_dut (
		.reset_n					( reset_n					),
		.clk						( clk						),
		.start						( start						),
		.cache_flush_start			( cache_flush_start			),
		.cache_flush_end			( cache_flush_end			),
		// VDP command interface
		.cache_vram_address			( cache_vram_address		),
		.cache_vram_valid			( cache_vram_valid			),
		.cache_vram_ready			( cache_vram_ready			),
		.cache_vram_write			( cache_vram_write			),
		.cache_vram_wdata			( cache_vram_wdata			),
		.cache_vram_rdata			( cache_vram_rdata			),
		.cache_vram_rdata_en		( cache_vram_rdata_en		),
		// VRAM interface
		.command_vram_address		( command_vram_address		),
		.command_vram_valid			( command_vram_valid		),
		.command_vram_ready			( command_vram_ready		),
		.command_vram_write			( command_vram_write		),
		.command_vram_wdata			( command_vram_wdata		),
		.command_vram_wdata_mask	( command_vram_wdata_mask	),
		.command_vram_rdata			( command_vram_rdata		),
		.command_vram_rdata_en		( command_vram_rdata_en		)
	);

	// --------------------------------------------------------------------
	//	Clock generation
	// --------------------------------------------------------------------
	initial begin
		clk = 1'b0;
		forever begin
			#(clk_base/2) clk = ~clk;
		end
	end

	// --------------------------------------------------------------------
	//	VRAM memory simulation
	// --------------------------------------------------------------------
	always_ff @( posedge clk ) begin
		if( !reset_n ) begin
			vram_delay_counter	<= 0;
			command_vram_ready	<= 1'b1;
			command_vram_rdata	<= 32'd0;
			command_vram_rdata_en	<= 1'b0;
		end
		else begin
			command_vram_rdata_en	<= 1'b0;
			
			if( command_vram_valid && command_vram_ready ) begin
				command_vram_ready	<= 1'b0;
				vram_delay_counter	<= 8;  // 8 clock delay for VRAM access

				if( command_vram_write ) begin
					// Write operation
					if( command_vram_address[16:2] < 32768 ) begin
						if( !command_vram_wdata_mask[0] ) vram_memory[command_vram_address[16:2]][7:0]	 <= command_vram_wdata[7:0];
						if( !command_vram_wdata_mask[1] ) vram_memory[command_vram_address[16:2]][15:8]	 <= command_vram_wdata[15:8];
						if( !command_vram_wdata_mask[2] ) vram_memory[command_vram_address[16:2]][23:16] <= command_vram_wdata[23:16];
						if( !command_vram_wdata_mask[3] ) vram_memory[command_vram_address[16:2]][31:24] <= command_vram_wdata[31:24];
					end
					last_vram_wdata_mask	<= command_vram_wdata_mask;
					last_vram_wdata			<= command_vram_wdata;
					last_vram_write_count	<= last_vram_write_count + 1;
				end
				else begin
					// Read operation
					if( command_vram_address[16:2] < 32768 ) begin
						command_vram_rdata	<= vram_memory[command_vram_address[16:2]];
						last_vram_rdata		<= vram_memory[command_vram_address[16:2]];
					end
					else begin
						command_vram_rdata	<= 32'h00000000;
						last_vram_rdata		<= 32'h00000000;
					end
					last_vram_read_count	<= last_vram_read_count + 1;
				end
			end
			else if( vram_delay_counter > 0 ) begin
				vram_delay_counter <= vram_delay_counter - 1;
				if( vram_delay_counter == 1 ) begin
					command_vram_ready	<= 1'b1;
					command_vram_rdata_en	<= !command_vram_write;
				end
			end
		end
	end

	// --------------------------------------------------------------------
	//	Test task: Wait for specified clock cycles
	// --------------------------------------------------------------------
	task wait_clocks;
		input integer clocks;
		begin
			repeat( clocks ) @( posedge clk );
		end
	endtask

	// --------------------------------------------------------------------
	//	Test task: Generate start pulse
	// --------------------------------------------------------------------
	task generate_start_pulse;
		begin
			start = 1'b1;
			wait_clocks( 1 );
			start = 1'b0;
		end
	endtask

	// --------------------------------------------------------------------
	//	Test task: Generate cache flush pulse and wait for completion
	// --------------------------------------------------------------------
	task flush_cache;
		begin
			$display( "[%t] Cache flush start", $time );
			cache_flush_start = 1'b1;
			wait_clocks( 1 );
			cache_flush_start = 1'b0;
			
			// Wait for flush completion
			timeout_counter = 1000;
			while( !cache_flush_end && timeout_counter > 0 ) begin
				wait_clocks( 1 );
				timeout_counter = timeout_counter - 1;
			end
			
			if( timeout_counter == 0 ) begin
				$display( "[%t] ERROR: Cache flush timeout", $time );
				$finish;
			end
			
			$display( "[%t] Cache flush completed", $time );
		end
	endtask

	// --------------------------------------------------------------------
	//	Test task: Prepare for new test (flush + start for 2nd+ tests)
	// --------------------------------------------------------------------
	task prepare_new_test;
		begin
			// For 2nd and subsequent tests, must flush before start
			flush_cache();
			generate_start_pulse();
			wait_clocks( 2 );
		end
	endtask

	// --------------------------------------------------------------------
	//	Test task: Reset sequence
	// --------------------------------------------------------------------
	task reset_sequence;
		begin
			$display( "[%t] Reset sequence start", $time );
			reset_n = 1'b0;
			start = 1'b0;
			cache_flush_start = 1'b0;
			cache_vram_address	= 17'd0;
			cache_vram_valid	= 1'b0;
			cache_vram_write	= 1'b0;
			cache_vram_wdata	= 8'd0;
			wait_clocks( 10 );
			reset_n = 1'b1;
			wait_clocks( 2 );
			// Generate 1-clock pulse for start signal
			generate_start_pulse();
			wait_clocks( 2 );
			$display( "[%t] Reset sequence complete", $time );
		end
	endtask

	// --------------------------------------------------------------------
	//	Test task: Write to cache
	// --------------------------------------------------------------------
	task cache_write;
		input [16:0] address;
		input [7:0]  data;
		begin
			$display( "[%t] Cache write: addr=0x%05X, data=0x%02X", $time, address, data );
			
			cache_vram_address	<= address;
			cache_vram_write	<= 1'b1;
			cache_vram_wdata	<= data;
			cache_vram_valid	<= 1'b1;
			wait_clocks( 1 );

			timeout_counter = 100;
			while( !cache_vram_ready && timeout_counter > 0 ) begin
				wait_clocks( 1 );
				timeout_counter = timeout_counter - 1;
			end
			
			if( timeout_counter == 0 ) begin
				$display( "[%t] ERROR: Cache write timeout", $time );
				$finish;
			end
			cache_vram_valid	<= 1'b0;
			cache_vram_write	<= 1'b0;
			
			$display( "[%t] Cache write completed", $time );
		end
	endtask

	// --------------------------------------------------------------------
	//	Test task: Read from cache
	// --------------------------------------------------------------------
	task cache_read;
		input  [16:0] address;
		output [7:0]  data;
		begin
			$display( "[%t] Cache read: addr=0x%05X", $time, address );
			
			cache_vram_address	<= address;
			cache_vram_write	<= 1'b0;
			cache_vram_valid	<= 1'b1;
			wait_clocks( 1 );
			
			timeout_counter = 100;
			while( !cache_vram_ready && timeout_counter > 0 ) begin
				wait_clocks( 1 );
				timeout_counter = timeout_counter - 1;
			end
			
			if( timeout_counter == 0 ) begin
				$display( "[%t] ERROR: Cache read timeout", $time );
				$finish;
			end
			cache_vram_valid	<= 1'b0;
			
			// Wait for rdata_en signal
			timeout_counter = 100;
			while( !cache_vram_rdata_en && timeout_counter > 0 ) begin
				wait_clocks( 1 );
				timeout_counter = timeout_counter - 1;
			end
			
			if( timeout_counter == 0 ) begin
				$display( "[%t] ERROR: Cache read data timeout", $time );
				$finish;
			end
			
			data = cache_vram_rdata;
			
			$display( "[%t] Cache read completed: data=0x%02X", $time, data );
		end
	endtask

	// --------------------------------------------------------------------
	//	Test task: Initialize VRAM with test pattern
	// --------------------------------------------------------------------
	task init_vram;
		begin
			$display( "[%t] Initializing VRAM with test pattern", $time );
			for( i = 0; i < 32768; i = i + 1 ) begin
				vram_memory[i] = {8'h80+i[7:0], 8'h40+i[7:0], 8'h20+i[7:0], 8'h10+i[7:0]};
			end
			$display( "[%t] VRAM initialization complete", $time );
		end
	endtask

	// --------------------------------------------------------------------
	//	Test case: Basic read/write operations
	// --------------------------------------------------------------------
	task test_basic_operations;
		logic [7:0] read_data;
		begin
			$display( "\n=== Test Case: Basic Operations ===" );
			
			// Test single byte write/read at different positions
			cache_write( 17'h00000, 8'hAA );
			cache_read( 17'h00000, read_data );
			if( read_data != 8'hAA ) begin
				$error( "Basic write/read failed. Expected: 0xAA, Got: 0x%02X", read_data );
				assert( 0 );
				$finish;
			end
			
			cache_write( 17'h00001, 8'hBB );
			cache_read( 17'h00001, read_data );
			if( read_data != 8'hBB ) begin
				$error( "Basic write/read failed. Expected: 0xBB, Got: 0x%02X", read_data );
				assert( 0 );
				$finish;
			end
			
			cache_write( 17'h00002, 8'hCC );
			cache_read( 17'h00002, read_data );
			if( read_data != 8'hCC ) begin
				$error( "Basic write/read failed. Expected: 0xCC, Got: 0x%02X", read_data );
				assert( 0 );
				$finish;
			end
			
			cache_write( 17'h00003, 8'hDD );
			cache_read( 17'h00003, read_data );
			if( read_data != 8'hDD ) begin
				$error( "Basic write/read failed. Expected: 0xDD, Got: 0x%02X", read_data );
				assert( 0 );
				$finish;
			end
			
			$display( "Basic operations test PASSED" );
		end
	endtask

	// --------------------------------------------------------------------
	//	Test case: Cache hit test
	// --------------------------------------------------------------------
	task test_cache_hit;
		logic [7:0] read_data;
		begin
			$display( "\n=== Test Case: Cache Hit Test ===" );
			
			// Prepare for new test (flush + start)
			prepare_new_test();
			
			// Write to same 32-bit boundary multiple times (should hit cache)
			cache_write( 17'h01000, 8'h11 );
			cache_write( 17'h01001, 8'h22 );
			cache_write( 17'h01002, 8'h33 );
			cache_write( 17'h01003, 8'h44 );
			
			// Read back from cache
			cache_read( 17'h01000, read_data );
			if( read_data != 8'h11 ) begin
				$error( "Cache hit test failed. Expected: 0x11, Got: 0x%02X", read_data );
				assert( 0 );
				$finish;
			end
			
			cache_read( 17'h01001, read_data );
			if( read_data != 8'h22 ) begin
				$error( "Cache hit test failed. Expected: 0x22, Got: 0x%02X", read_data );
				assert( 0 );
				$finish;
			end
			
			cache_read( 17'h01002, read_data );
			if( read_data != 8'h33 ) begin
				$error( "Cache hit test failed. Expected: 0x33, Got: 0x%02X", read_data );
				assert( 0 );
				$finish;
			end
			
			cache_read( 17'h01003, read_data );
			if( read_data != 8'h44 ) begin
				$error( "Cache hit test failed. Expected: 0x44, Got: 0x%02X", read_data );
				assert( 0 );
				$finish;
			end
			
			$display( "Cache hit test PASSED" );
		end
	endtask

	// --------------------------------------------------------------------
	//	Test case: Cache miss and replacement test
	// --------------------------------------------------------------------
	task test_cache_replacement;
		logic [7:0] read_data;
		begin
			$display( "\n=== Test Case: Cache Replacement Test ===" );
			
			// Prepare for new test (flush + start)
			prepare_new_test();
			
			// Fill up cache entries with different addresses
			cache_write( 17'h02000, 8'hA1 );  // Cache entry 0
			cache_write( 17'h03000, 8'hA2 );  // Cache entry 1
			cache_write( 17'h04000, 8'hA3 );  // Cache entry 2
			cache_write( 17'h05000, 8'hA4 );  // Cache entry 3
			
			// Access that should cause cache replacement
			cache_write( 17'h06000, 8'hA5 );  // Should replace entry 0
			cache_write( 17'h07000, 8'hA6 );  // Should replace entry 1
			
			// Read back to verify replacement worked
			cache_read( 17'h06000, read_data );
			if( read_data != 8'hA5 ) begin
				$error( "Cache replacement test failed. Expected: 0xA5, Got: 0x%02X", read_data );
				assert( 0 );
				$finish;
			end
			
			cache_read( 17'h07000, read_data );
			if( read_data != 8'hA6 ) begin
				$error( "Cache replacement test failed. Expected: 0xA6, Got: 0x%02X", read_data );
				assert( 0 );
				$finish;
			end
			
			$display( "Cache replacement test PASSED" );
		end
	endtask

	// --------------------------------------------------------------------
	//	Test case: Read from pre-initialized VRAM
	// --------------------------------------------------------------------
	task test_vram_read;
		logic [7:0] read_data;
		logic [7:0] expected_data;
		begin
			$display( "\n=== Test Case: VRAM Read Test ===" );
			
			// Prepare for new test (flush + start)
			prepare_new_test();
			
			// Read from VRAM locations with known pattern
			cache_read( 17'h08000, read_data );
			expected_data = 8'h10;	// From init_vram pattern
			if( read_data != expected_data ) begin
				$error( "VRAM read test failed. Expected: 0x%02X, Got: 0x%02X", expected_data, read_data );
				assert( 0 );
				$finish;
			end
			
			cache_read( 17'h08001, read_data );
			expected_data = 8'h20;	// From init_vram pattern
			if( read_data != expected_data ) begin
				$error( "VRAM read test failed. Expected: 0x%02X, Got: 0x%02X", expected_data, read_data );
				assert( 0 );
				$finish;
			end
			
			cache_read( 17'h08002, read_data );
			expected_data = 8'h40;	// From init_vram pattern
			if( read_data != expected_data ) begin
				$error( "VRAM read test failed. Expected: 0x%02X, Got: 0x%02X", expected_data, read_data );
				assert( 0 );
				$finish;
			end
			
			cache_read( 17'h08003, read_data );
			expected_data = 8'h80;	// From init_vram pattern
			if( read_data != expected_data ) begin
				$error( "VRAM read test failed. Expected: 0x%02X, Got: 0x%02X", expected_data, read_data );
				assert( 0 );
				$finish;
			end
			
			$display( "VRAM read test PASSED" );
		end
	endtask

	// --------------------------------------------------------------------
	//	Test case: 4way full test
	// --------------------------------------------------------------------
	task test_4way_full();
		logic [7:0] read_data;
		logic [7:0] expected_data;
		begin
			$display( "\n=== Test Case: 4way Full Test ===" );

			flush_cache();
			init_vram();
			generate_start_pulse();

			last_vram_write_count	= 0;
			last_vram_read_count	= 0;

			cache_read( 17'h08000, read_data );
			expected_data = 8'h10;	// From init_vram pattern
			if( read_data != expected_data ) begin
				$error( "VRAM read test failed. Expected: 0x%02X, Got: 0x%02X", expected_data, read_data );
				$finish;
			end
			assert( last_vram_write_count == 0 );
			assert( last_vram_read_count == 1 );

			cache_read( 17'h08004, read_data );
			expected_data = 8'h11;	// From init_vram pattern
			if( read_data != expected_data ) begin
				$error( "VRAM read test failed. Expected: 0x%02X, Got: 0x%02X", expected_data, read_data );
				$finish;
			end
			assert( last_vram_write_count == 0 );
			assert( last_vram_read_count == 2 );

			cache_read( 17'h08008, read_data );
			expected_data = 8'h12;	// From init_vram pattern
			if( read_data != expected_data ) begin
				$error( "VRAM read test failed. Expected: 0x%02X, Got: 0x%02X", expected_data, read_data );
				$finish;
			end
			assert( last_vram_write_count == 0 );
			assert( last_vram_read_count == 3 );

			cache_read( 17'h0800C, read_data );
			expected_data = 8'h13;	// From init_vram pattern
			if( read_data != expected_data ) begin
				$error( "VRAM read test failed. Expected: 0x%02X, Got: 0x%02X", expected_data, read_data );
				$finish;
			end
			assert( last_vram_write_count == 0 );
			assert( last_vram_read_count == 4 );

			cache_read( 17'h08000, read_data );
			expected_data = 8'h10;	// From init_vram pattern
			if( read_data != expected_data ) begin
				$error( "VRAM read test failed. Expected: 0x%02X, Got: 0x%02X", expected_data, read_data );
				$finish;
			end
			assert( last_vram_write_count == 0 );
			assert( last_vram_read_count == 4 );

			cache_read( 17'h08004, read_data );
			expected_data = 8'h11;	// From init_vram pattern
			if( read_data != expected_data ) begin
				$error( "VRAM read test failed. Expected: 0x%02X, Got: 0x%02X", expected_data, read_data );
				$finish;
			end
			assert( last_vram_write_count == 0 );
			assert( last_vram_read_count == 4 );

			cache_read( 17'h08008, read_data );
			expected_data = 8'h12;	// From init_vram pattern
			if( read_data != expected_data ) begin
				$error( "VRAM read test failed. Expected: 0x%02X, Got: 0x%02X", expected_data, read_data );
				$finish;
			end
			assert( last_vram_write_count == 0 );
			assert( last_vram_read_count == 4 );

			cache_read( 17'h0800C, read_data );
			expected_data = 8'h13;	// From init_vram pattern
			if( read_data != expected_data ) begin
				$error( "VRAM read test failed. Expected: 0x%02X, Got: 0x%02X", expected_data, read_data );
				$finish;
			end
			assert( last_vram_write_count == 0 );
			assert( last_vram_read_count == 4 );

			cache_read( 17'h08001, read_data );
			expected_data = 8'h20;	// From init_vram pattern
			if( read_data != expected_data ) begin
				$error( "VRAM read test failed. Expected: 0x%02X, Got: 0x%02X", expected_data, read_data );
				$finish;
			end
			assert( last_vram_write_count == 0 );
			assert( last_vram_read_count == 4 );

			cache_read( 17'h08005, read_data );
			expected_data = 8'h21;	// From init_vram pattern
			if( read_data != expected_data ) begin
				$error( "VRAM read test failed. Expected: 0x%02X, Got: 0x%02X", expected_data, read_data );
				$finish;
			end
			assert( last_vram_write_count == 0 );
			assert( last_vram_read_count == 4 );

			cache_read( 17'h08009, read_data );
			expected_data = 8'h22;	// From init_vram pattern
			if( read_data != expected_data ) begin
				$error( "VRAM read test failed. Expected: 0x%02X, Got: 0x%02X", expected_data, read_data );
				$finish;
			end
			assert( last_vram_write_count == 0 );
			assert( last_vram_read_count == 4 );

			cache_read( 17'h0800D, read_data );
			expected_data = 8'h23;	// From init_vram pattern
			if( read_data != expected_data ) begin
				$error( "VRAM read test failed. Expected: 0x%02X, Got: 0x%02X", expected_data, read_data );
				$finish;
			end
			assert( last_vram_write_count == 0 );
			assert( last_vram_read_count == 4 );

			cache_read( 17'h08002, read_data );
			expected_data = 8'h40;	// From init_vram pattern
			if( read_data != expected_data ) begin
				$error( "VRAM read test failed. Expected: 0x%02X, Got: 0x%02X", expected_data, read_data );
				$finish;
			end
			assert( last_vram_write_count == 0 );
			assert( last_vram_read_count == 4 );

			cache_read( 17'h08006, read_data );
			expected_data = 8'h41;	// From init_vram pattern
			if( read_data != expected_data ) begin
				$error( "VRAM read test failed. Expected: 0x%02X, Got: 0x%02X", expected_data, read_data );
				$finish;
			end
			assert( last_vram_write_count == 0 );
			assert( last_vram_read_count == 4 );

			cache_read( 17'h0800A, read_data );
			expected_data = 8'h42;	// From init_vram pattern
			if( read_data != expected_data ) begin
				$error( "VRAM read test failed. Expected: 0x%02X, Got: 0x%02X", expected_data, read_data );
				$finish;
			end
			assert( last_vram_write_count == 0 );
			assert( last_vram_read_count == 4 );

			cache_read( 17'h0800E, read_data );
			expected_data = 8'h43;	// From init_vram pattern
			if( read_data != expected_data ) begin
				$error( "VRAM read test failed. Expected: 0x%02X, Got: 0x%02X", expected_data, read_data );
				$finish;
			end
			assert( last_vram_write_count == 0 );
			assert( last_vram_read_count == 4 );

			cache_read( 17'h08003, read_data );
			expected_data = 8'h80;	// From init_vram pattern
			if( read_data != expected_data ) begin
				$error( "VRAM read test failed. Expected: 0x%02X, Got: 0x%02X", expected_data, read_data );
				$finish;
			end
			assert( last_vram_write_count == 0 );
			assert( last_vram_read_count == 4 );

			cache_read( 17'h08007, read_data );
			expected_data = 8'h81;	// From init_vram pattern
			if( read_data != expected_data ) begin
				$error( "VRAM read test failed. Expected: 0x%02X, Got: 0x%02X", expected_data, read_data );
				$finish;
			end
			assert( last_vram_write_count == 0 );
			assert( last_vram_read_count == 4 );

			cache_read( 17'h0800B, read_data );
			expected_data = 8'h82;	// From init_vram pattern
			if( read_data != expected_data ) begin
				$error( "VRAM read test failed. Expected: 0x%02X, Got: 0x%02X", expected_data, read_data );
				$finish;
			end
			assert( last_vram_write_count == 0 );
			assert( last_vram_read_count == 4 );

			cache_read( 17'h0800F, read_data );
			expected_data = 8'h83;	// From init_vram pattern
			if( read_data != expected_data ) begin
				$error( "VRAM read test failed. Expected: 0x%02X, Got: 0x%02X", expected_data, read_data );
				$finish;
			end
			assert( last_vram_write_count == 0 );
			assert( last_vram_read_count == 4 );

			//	------------------------------------------------------------
			//	キャッシュが溢れて、新しいワードを読みだす。
			//	溢れた部分は、まだ何も書き替えていないので、書き出しは発生しない
			cache_read( 17'h08010, read_data );
			expected_data = 8'h14;	// From init_vram pattern
			if( read_data != expected_data ) begin
				$error( "VRAM read test failed. Expected: 0x%02X, Got: 0x%02X", expected_data, read_data );
				$finish;
			end
			assert( last_vram_write_count == 0 );
			assert( last_vram_read_count == 5 );

			cache_read( 17'h08014, read_data );
			expected_data = 8'h15;	// From init_vram pattern
			if( read_data != expected_data ) begin
				$error( "VRAM read test failed. Expected: 0x%02X, Got: 0x%02X", expected_data, read_data );
				$finish;
			end
			assert( last_vram_write_count == 0 );
			assert( last_vram_read_count == 6 );

			cache_read( 17'h08018, read_data );
			expected_data = 8'h16;	// From init_vram pattern
			if( read_data != expected_data ) begin
				$error( "VRAM read test failed. Expected: 0x%02X, Got: 0x%02X", expected_data, read_data );
				$finish;
			end
			assert( last_vram_write_count == 0 );
			assert( last_vram_read_count == 7 );

			cache_read( 17'h0801C, read_data );
			expected_data = 8'h17;	// From init_vram pattern
			if( read_data != expected_data ) begin
				$error( "VRAM read test failed. Expected: 0x%02X, Got: 0x%02X", expected_data, read_data );
				$finish;
			end
			assert( last_vram_write_count == 0 );
			assert( last_vram_read_count == 8 );

			//	------------------------------------------------------------
			//	キャッシュに書き込みをしてから、溢れると DRAM への書き出しが発生する。
			cache_write( 17'h08010, 8'hAA );
			assert( last_vram_write_count == 0 );
			assert( last_vram_read_count == 8 );

			cache_write( 17'h08014, 8'hBB );
			assert( last_vram_write_count == 0 );
			assert( last_vram_read_count == 8 );

			cache_write( 17'h08018, 8'hCC );
			assert( last_vram_write_count == 0 );
			assert( last_vram_read_count == 8 );

			cache_write( 17'h0801C, 8'hDD );
			assert( last_vram_write_count == 0 );
			assert( last_vram_read_count == 8 );

			cache_read( 17'h08020, read_data );
			expected_data = 8'h18;	// From init_vram pattern
			if( read_data != expected_data ) begin
				$error( "VRAM read test failed. Expected: 0x%02X, Got: 0x%02X", expected_data, read_data );
				$finish;
			end
			assert( last_vram_write_count == 1 );
			assert( last_vram_read_count == 9 );

			cache_read( 17'h08024, read_data );
			expected_data = 8'h19;	// From init_vram pattern
			if( read_data != expected_data ) begin
				$error( "VRAM read test failed. Expected: 0x%02X, Got: 0x%02X", expected_data, read_data );
				$finish;
			end
			assert( last_vram_write_count == 2 );
			assert( last_vram_read_count == 10 );

			cache_read( 17'h08028, read_data );
			expected_data = 8'h1A;	// From init_vram pattern
			if( read_data != expected_data ) begin
				$error( "VRAM read test failed. Expected: 0x%02X, Got: 0x%02X", expected_data, read_data );
				$finish;
			end
			assert( last_vram_write_count == 3 );
			assert( last_vram_read_count == 11 );

			cache_read( 17'h0802C, read_data );
			expected_data = 8'h1B;	// From init_vram pattern
			if( read_data != expected_data ) begin
				$error( "VRAM read test failed. Expected: 0x%02X, Got: 0x%02X", expected_data, read_data );
				$finish;
			end
			assert( last_vram_write_count == 4 );
			assert( last_vram_read_count == 12 );
		end
	endtask

	// --------------------------------------------------------------------
	//	Test case: Write and Read
	// --------------------------------------------------------------------
	task test_vram_write_and_read;
		logic [7:0] read_data;
		logic [7:0] expected_data;
		begin
			$display( "\n=== Test Case: Read and Write Test ===" );

			cache_write( 17'h08500, 8'h12 );
			cache_write( 17'h08501, 8'h23 );
			cache_write( 17'h08502, 8'h34 );
			cache_write( 17'h08503, 8'h45 );

			cache_write( 17'h08600, 8'h56 );
			cache_write( 17'h08601, 8'h67 );
			cache_write( 17'h08602, 8'h78 );
			cache_write( 17'h08603, 8'h89 );

			cache_write( 17'h08700, 8'h9a );
			cache_write( 17'h08701, 8'hab );
			cache_write( 17'h08702, 8'hcd );
			cache_write( 17'h08703, 8'hde );

			cache_write( 17'h08800, 8'hef );
			cache_write( 17'h08801, 8'hf0 );
			cache_write( 17'h08802, 8'h01 );
			cache_write( 17'h08803, 8'h12 );

			cache_write( 17'h08900, 8'hAA );
			cache_write( 17'h08901, 8'hAA );
			cache_write( 17'h08902, 8'hAA );
			cache_write( 17'h08903, 8'hAA );

			cache_write( 17'h08A00, 8'h55 );
			cache_write( 17'h08A01, 8'h55 );
			cache_write( 17'h08A02, 8'h55 );
			cache_write( 17'h08A03, 8'h55 );

			cache_write( 17'h08B00, 8'hA5 );
			cache_write( 17'h08B01, 8'hA5 );
			cache_write( 17'h08B02, 8'hA5 );
			cache_write( 17'h08B03, 8'hA5 );

			cache_write( 17'h08C00, 8'h5A );
			cache_write( 17'h08C01, 8'h5A );
			cache_write( 17'h08C02, 8'h5A );
			cache_write( 17'h08C03, 8'h5A );

			flush_cache();
			wait_clocks( 10 );
			generate_start_pulse();
			wait_clocks( 1 );

			// --------------------------------------------------------------------
			//	Write byte --> Read nearest byte
			cache_write( 17'h08500, 8'hAB );
			cache_read(  17'h08501, read_data );
			expected_data = 8'h23;	// From init_vram pattern
			if( read_data != expected_data ) begin
				$error( "VRAM read test failed. Expected: 0x%02X, Got: 0x%02X", expected_data, read_data );
				$finish;
			end

			cache_read(  17'h08502, read_data );
			expected_data = 8'h34;	// From init_vram pattern
			if( read_data != expected_data ) begin
				$error( "VRAM read test failed. Expected: 0x%02X, Got: 0x%02X", expected_data, read_data );
				$finish;
			end

			cache_read(  17'h08503, read_data );
			expected_data = 8'h45;	// From init_vram pattern
			if( read_data != expected_data ) begin
				$error( "VRAM read test failed. Expected: 0x%02X, Got: 0x%02X", expected_data, read_data );
				$finish;
			end

			cache_read(  17'h08500, read_data );
			expected_data = 8'hAB;	// From init_vram pattern
			if( read_data != expected_data ) begin
				$error( "VRAM read test failed. Expected: 0x%02X, Got: 0x%02X", expected_data, read_data );
				$finish;
			end

			// --------------------------------------------------------------------
			//	Write byte --> Read nearest byte
			cache_write( 17'h08601, 8'hCB );
			cache_read(  17'h08600, read_data );
			expected_data = 8'h56;	// From init_vram pattern
			if( read_data != expected_data ) begin
				$error( "VRAM read test failed. Expected: 0x%02X, Got: 0x%02X", expected_data, read_data );
				$finish;
			end

			cache_read(  17'h08602, read_data );
			expected_data = 8'h78;	// From init_vram pattern
			if( read_data != expected_data ) begin
				$error( "VRAM read test failed. Expected: 0x%02X, Got: 0x%02X", expected_data, read_data );
				$finish;
			end

			cache_read(  17'h08603, read_data );
			expected_data = 8'h89;	// From init_vram pattern
			if( read_data != expected_data ) begin
				$error( "VRAM read test failed. Expected: 0x%02X, Got: 0x%02X", expected_data, read_data );
				$finish;
			end

			cache_read(  17'h08601, read_data );
			expected_data = 8'hCB;	// From init_vram pattern
			if( read_data != expected_data ) begin
				$error( "VRAM read test failed. Expected: 0x%02X, Got: 0x%02X", expected_data, read_data );
				$finish;
			end

			// --------------------------------------------------------------------
			//	Write byte --> Read nearest byte
			cache_write( 17'h08702, 8'hFC );
			cache_read(  17'h08700, read_data );
			expected_data = 8'h9a;	// From init_vram pattern
			if( read_data != expected_data ) begin
				$error( "VRAM read test failed. Expected: 0x%02X, Got: 0x%02X", expected_data, read_data );
				$finish;
			end

			cache_read(  17'h08701, read_data );
			expected_data = 8'hab;	// From init_vram pattern
			if( read_data != expected_data ) begin
				$error( "VRAM read test failed. Expected: 0x%02X, Got: 0x%02X", expected_data, read_data );
				$finish;
			end

			cache_read(  17'h08703, read_data );
			expected_data = 8'hde;	// From init_vram pattern
			if( read_data != expected_data ) begin
				$error( "VRAM read test failed. Expected: 0x%02X, Got: 0x%02X", expected_data, read_data );
				$finish;
			end

			cache_read(  17'h08702, read_data );
			expected_data = 8'hFC;	// From init_vram pattern
			if( read_data != expected_data ) begin
				$error( "VRAM read test failed. Expected: 0x%02X, Got: 0x%02X", expected_data, read_data );
				$finish;
			end

			// --------------------------------------------------------------------
			//	Write byte --> Read nearest byte
			cache_write( 17'h08803, 8'h9D );
			cache_read(  17'h08800, read_data );
			expected_data = 8'hef;	// From init_vram pattern
			if( read_data != expected_data ) begin
				$error( "VRAM read test failed. Expected: 0x%02X, Got: 0x%02X", expected_data, read_data );
				$finish;
			end

			cache_read(  17'h08801, read_data );
			expected_data = 8'hf0;	// From init_vram pattern
			if( read_data != expected_data ) begin
				$error( "VRAM read test failed. Expected: 0x%02X, Got: 0x%02X", expected_data, read_data );
				$finish;
			end

			cache_read(  17'h08802, read_data );
			expected_data = 8'h01;	// From init_vram pattern
			if( read_data != expected_data ) begin
				$error( "VRAM read test failed. Expected: 0x%02X, Got: 0x%02X", expected_data, read_data );
				$finish;
			end

			cache_read(  17'h08803, read_data );
			expected_data = 8'h9D;	// From init_vram pattern
			if( read_data != expected_data ) begin
				$error( "VRAM read test failed. Expected: 0x%02X, Got: 0x%02X", expected_data, read_data );
				$finish;
			end
		end
	endtask

	// --------------------------------------------------------------------
	//	Test case: Cache flush functionality test
	// --------------------------------------------------------------------
	task test_cache_flush;
		logic [7:0] read_data;
		begin
			$display( "\n=== Test Case: Cache Flush Test ===" );
			
			// Write some data to cache
			cache_write( 17'h0A000, 8'hAA );
			cache_write( 17'h0A001, 8'hBB );
			cache_write( 17'h0A002, 8'hCC );
			cache_write( 17'h0A003, 8'hDD );
			
			// Verify data is in cache
			cache_read( 17'h0A000, read_data );
			if( read_data != 8'hAA ) begin
				$display( "Cache flush test setup failed. Expected: 0xAA, Got: 0x%02X", read_data );
				$finish;
			end
			
			// Perform cache flush
			flush_cache();
			
			// After flush, need to start again before any access
			generate_start_pulse();
			wait_clocks( 2 );
			
			// Try to read the data (should come from VRAM, not cache)
			cache_read( 17'h0A000, read_data );
			if( read_data != 8'hAA ) begin
				$display( "Cache flush test failed. Expected: 0xAA, Got: 0x%02X", read_data );
				$finish;
			end
			
			$display( "Cache flush test PASSED" );
		end
	endtask

	// --------------------------------------------------------------------
	//	Test case: Start signal control test
	// --------------------------------------------------------------------
	task test_start_control;
		logic [7:0] read_data;
		begin
			$display( "\n=== Test Case: Start Signal Control Test ===" );
			
			// Start signal should be normally 0
			start = 1'b0;
			wait_clocks( 2 );
			
			// Try normal operation (start should be pulsed when needed)
			cache_write( 17'h09000, 8'h55 );
			
			// Before second start, must flush cache
			flush_cache();
			
			// Generate start pulse for cache operation
			generate_start_pulse();
			wait_clocks( 1 );

			// Try read operation
			cache_read( 17'h09000, read_data );
			if( read_data != 8'h55 ) begin
				$display( "Start control test failed. Expected: 0x55, Got: 0x%02X", read_data );
				$finish;
			end
			
			$display( "Start signal control test PASSED" );
		end
	endtask

	// --------------------------------------------------------------------
	//	Main test sequence
	// --------------------------------------------------------------------
	initial begin
		$display( "=== VDP Command Cache Test Start ===" );

		init_vram();
		wait_clocks( 100 );

		reset_sequence();
		wait_clocks( 100 );

		test_basic_operations();
		wait_clocks( 100 );

		test_cache_hit();
		wait_clocks( 100 );

		test_cache_replacement();
		wait_clocks( 100 );

		test_vram_read();
		wait_clocks( 100 );

		test_4way_full();
		wait_clocks( 100 );

		test_vram_write_and_read();
		wait_clocks( 100 );

		test_cache_flush();
		wait_clocks( 100 );

		test_start_control();
		wait_clocks( 100 );
		
		$display( "\n=== All Tests PASSED ===" );
		$display( "Test completed successfully at time %t", $time );
		$finish;
	end

	// --------------------------------------------------------------------
	//	Timeout watchdog
	// --------------------------------------------------------------------
	initial begin
		#(clk_base * 50000);   // 50000 clock timeout
		$error( "Test timeout!" );
		assert( 0 );
		$finish;
	end

endmodule
