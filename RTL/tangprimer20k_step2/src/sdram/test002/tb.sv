// -----------------------------------------------------------------------------
//	Test of ip_sdram_tangprimer20k.v
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

`timescale 1ps / 1ps

module tb ();
	localparam		clk85_base	= 64'd1_000_000_000 / 64'd85_909;	//	ps
	localparam		clk_base	= 64'd1_000_000_000 / 64'd343_636;	//	ps
	localparam		TIMEOUT		= 100;
	reg				reset_n;
	reg				clk;				//	85.90908MHz
	reg				memory_clk;			//	343.63632MHz
	reg				pll_lock;
	wire			clk_out;			//	85.90908MHz
	wire			sdram_init_busy;

	reg		[26:0]	bus_address;		//	64Mword/16bit: [26:24]=BANK, [23:10]=ROW, [9:0]=COLUMN
	reg				bus_write;			//	Direction 0: Read, 1: Write
	reg				bus_valid;			//
	wire			bus_ready;			//	0: Busy, 1: Ready
	reg		[127:0]	bus_wdata;
	reg		[15:0]	bus_wdata_mask;
	wire	[127:0]	bus_rdata;
	wire			bus_rdata_valid;

	wire			ddr3_rst_n;
	wire			ddr3_clk;
	wire			ddr3_clk_n;
	wire			ddr3_cke;
	wire			ddr3_cs_n;			// chip select
	wire			ddr3_ras_n;			// row address select
	wire			ddr3_cas_n;			// columns address select
	wire			ddr3_we_n;			// write enable
	wire	[15:0]	ddr3_dq;			// 32 bit bidirectional data bus
	wire	[13:0]	ddr3_addr;			// 14 bit multiplexed address bus
	wire	[ 2:0]	ddr3_ba;			// eight banks
	wire	[ 1:0]	ddr3_dm_tdqs;		// data mask
	wire	[ 1:0]	ddr3_dqs;			// 
	wire	[ 1:0]	ddr3_dqs_n;			// 
	wire	[ 1:0]	ddr3_tdqs_n;		// No use
	wire			ddr3_odt;

	int				i, j, k;
	int				count;
	int				clk_enable;

	// --------------------------------------------------------------------
	//	DUT
	// --------------------------------------------------------------------
	ip_sdram u_sdram_controller (
		.reset_n			( reset_n			),
		.clk				( clk				),
		.memory_clk			( memory_clk		),
		.clk_out			( clk_out			),
		.pll_lock			( pll_lock			),
		.sdram_init_busy	( sdram_init_busy	),
		.bus_address		( bus_address		),
		.bus_write			( bus_write			),
		.bus_valid			( bus_valid			),
		.bus_ready			( bus_ready			),
		.bus_wdata			( bus_wdata			),
		.bus_wdata_mask		( bus_wdata_mask	),
		.bus_rdata			( bus_rdata			),
		.bus_rdata_valid	( bus_rdata_valid	),
		.ddr3_rst_n			( ddr3_rst_n		),
		.ddr3_clk			( ddr3_clk			),
		.ddr3_clk_n			( ddr3_clk_n		),
		.ddr3_cke			( ddr3_cke			),
		.ddr3_cs_n			( ddr3_cs_n			),
		.ddr3_ras_n			( ddr3_ras_n		),
		.ddr3_cas_n			( ddr3_cas_n		),
		.ddr3_we_n			( ddr3_we_n			),
		.ddr3_dq			( ddr3_dq			),
		.ddr3_addr			( ddr3_addr			),
		.ddr3_ba			( ddr3_ba			),
		.ddr3_dm_tdqs		( ddr3_dm_tdqs		),
		.ddr3_dqs			( ddr3_dqs			),
		.ddr3_dqs_n			( ddr3_dqs_n		),
		.ddr3_odt			( ddr3_odt			)
	);

	// --------------------------------------------------------------------
	ddr3 u_ddr3 (
		.rst_n				( ddr3_rst_n		),
		.ck					( ddr3_clk			),
		.ck_n				( ddr3_clk_n		),
		.cke				( ddr3_cke			),
		.cs_n				( ddr3_cs_n			),
		.ras_n				( ddr3_ras_n		),
		.cas_n				( ddr3_cas_n		),
		.we_n				( ddr3_we_n			),
		.dm_tdqs			( ddr3_dm_tdqs		),
		.ba					( ddr3_ba			),
		.addr				( ddr3_addr[12:0]	),
		.dq					( ddr3_dq			),
		.dqs				( ddr3_dqs			),
		.dqs_n				( ddr3_dqs_n		),
		.tdqs_n				( ddr3_tdqs_n		),
		.odt				( ddr3_odt			)
	);

	// --------------------------------------------------------------------
	//	clock
	// --------------------------------------------------------------------
	always #(clk85_base/2) begin
		if( clk_enable ) begin
			clk <= ~clk;
		end
	end

	always #(clk_base/2) begin
		if( clk_enable ) begin
			memory_clk <= ~memory_clk;
		end
	end

	// --------------------------------------------------------------------
	//	Tasks
	// --------------------------------------------------------------------
	task write_data(
		input	[26:0]	p_address,
		input	[127:0]	p_data
	);
		$display( "write_data( 0x%07X )", p_address, p_data );
		bus_address		<= p_address;
		bus_write		<= 1'b1;
		bus_wdata		<= p_data;
		bus_wdata_mask	<= 16'hFFFF;
		bus_valid		<= 1'b1;

		count			= 0;
		while( !bus_ready ) begin
			@( posedge clk );
			count++;
			if( count > TIMEOUT ) begin
				$display( "[ERROR] write data timeout" );
				break;
			end
		end

		bus_address		<= 'd0;
		bus_write		<= 1'b0;
		bus_wdata		<= 128'd0;
		bus_wdata_mask	<= 16'h0000;
		bus_valid		<= 1'b0;
		@( posedge clk );
	endtask: write_data

	// --------------------------------------------------------------------
	task read_data(
		input	[26:0]	p_address,
		input	[127:0]	p_data
	);
		int time_out;

		$display( "read_data( 0x%07X )", p_address );
		bus_address		<= p_address;
		bus_write		<= 1'b0;
		bus_wdata		<= 128'd0;
		bus_wdata_mask	<= 16'h0000;
		bus_valid		<= 1'b1;

		count			= 0;
		while( !bus_ready ) begin
			@( posedge clk );
			count++;
			if( count > TIMEOUT ) begin
				$display( "[ERROR] read data1 timeout" );
				break;
			end
		end

		bus_address		<= 'd0;
		bus_write		<= 1'b0;
		bus_wdata		<= 128'd0;
		bus_wdata_mask	<= 16'h0000;
		bus_valid		<= 1'b0;
		@( posedge clk );

		count			= 0;
		while( !bus_rdata_valid ) begin
			@( posedge clk );
			count++;
			if( count > TIMEOUT ) begin
				$display( "[ERROR] read data2 timeout" );
				break;
			end
		end
		assert( bus_rdata == p_data );
		if( bus_rdata != p_data ) begin
			$display( "-- p_data = %02X:%02X:%02X:%02X:%02X:%02X:%02X:%02X:%02X:%02X:%02X:%02X:%02X:%02X:%02X:%02X", 
				p_data[  7: 0], p_data[ 15:  8], p_data[ 23: 16], p_data[ 31: 24],
				p_data[ 39:32], p_data[ 47: 40], p_data[ 55: 48], p_data[ 63: 56],
				p_data[ 71:64], p_data[ 79: 72], p_data[ 87: 80], p_data[ 95: 88],
				p_data[103:96], p_data[111:104], p_data[119:112], p_data[127:120] );
			$display( "-- rdata  = %02X:%02X:%02X:%02X:%02X:%02X:%02X:%02X:%02X:%02X:%02X:%02X:%02X:%02X:%02X:%02X", 
				bus_rdata[  7: 0], bus_rdata[ 15:  8], bus_rdata[ 23: 16], bus_rdata[ 31: 24],
				bus_rdata[ 39:32], bus_rdata[ 47: 40], bus_rdata[ 55: 48], bus_rdata[ 63: 56],
				bus_rdata[ 71:64], bus_rdata[ 79: 72], bus_rdata[ 87: 80], bus_rdata[ 95: 88],
				bus_rdata[103:96], bus_rdata[111:104], bus_rdata[119:112], bus_rdata[127:120] );
		end
		@( posedge clk );
	endtask: read_data

	// --------------------------------------------------------------------
	//	Test bench
	// --------------------------------------------------------------------
	initial begin
		clk_enable		= 1;
		reset_n			= 1'b0;
		clk				= 1'b0;
		memory_clk		= 1'b0;
		pll_lock		= 1'b1;
		bus_address		= 26'd0;
		bus_write		= 1'b1;
		bus_valid		= 1'b0;
		bus_wdata		= 128'd0;
		bus_wdata_mask	= 16'd0;

		repeat( 16 ) @( posedge clk );
		reset_n	= 1;
		repeat( 16 ) @( posedge clk );

		count			= 0;
		while( sdram_init_busy ) begin
			@( posedge clk );
			count++;
			if( count == 256 ) begin
				$display( "wait sdram_init_busy" );
				count = 0;
			end
		end

		repeat( 16 ) @( posedge clk );

		$display( "===============================" );
		$display( "write -------------------------" );
		$display( "===============================" );
		write_data( 'h000000, 'h12 );
		write_data( 'h000001, 'h23 );
		write_data( 'h000002, 'h34 );
		write_data( 'h000003, 'h45 );
		write_data( 'h000004, 'h56 );
		write_data( 'h000005, 'h67 );
		write_data( 'h000006, 'h78 );
		write_data( 'h000007, 'h89 );

//		$display( "read -------------------------" );
//		read_data(  'h000000, 'h12 );
//		read_data(  'h000001, 'h23 );
//		read_data(  'h000002, 'h34 );
//		read_data(  'h000003, 'h45 );
//		read_data(  'h000004, 'h56 );
//		read_data(  'h000005, 'h67 );
//		read_data(  'h000006, 'h78 );
//		read_data(  'h000007, 'h89 );
//
//		read_data(  'h000007, 'h89 );
//		read_data(  'h000006, 'h78 );
//		read_data(  'h000005, 'h67 );
//		read_data(  'h000004, 'h56 );
//		read_data(  'h000003, 'h45 );
//		read_data(  'h000002, 'h34 );
//		read_data(  'h000001, 'h23 );
//		read_data(  'h000000, 'h12 );
//
//		$display( "write -------------------------" );
//		write_data( 'h400000, 'h21 );
//		write_data( 'h400001, 'h32 );
//		write_data( 'h400002, 'h43 );
//		write_data( 'h400003, 'h54 );
//		write_data( 'h400004, 'h65 );
//		write_data( 'h400005, 'h76 );
//		write_data( 'h400006, 'h87 );
//		write_data( 'h400007, 'h98 );
//
//		$display( "read -------------------------" );
//		read_data(  'h400000, 'h21 );
//		read_data(  'h400001, 'h32 );
//		read_data(  'h400002, 'h43 );
//		read_data(  'h400003, 'h54 );
//		read_data(  'h400004, 'h65 );
//		read_data(  'h400005, 'h76 );
//		read_data(  'h400006, 'h87 );
//		read_data(  'h400007, 'h98 );
//
//		read_data(  'h000000, 'h12 );
//		read_data(  'h000001, 'h23 );
//		read_data(  'h000002, 'h34 );
//		read_data(  'h000003, 'h45 );
//		read_data(  'h000004, 'h56 );
//		read_data(  'h000005, 'h67 );
//		read_data(  'h000006, 'h78 );
//		read_data(  'h000007, 'h89 );
//
//		read_data(  'h400007, 'h98 );
//		read_data(  'h400006, 'h87 );
//		read_data(  'h400005, 'h76 );
//		read_data(  'h400004, 'h65 );
//		read_data(  'h400003, 'h54 );
//		read_data(  'h400002, 'h43 );
//		read_data(  'h400001, 'h32 );
//		read_data(  'h400000, 'h21 );
//
//		read_data(  'h000007, 'h89 );
//		read_data(  'h000006, 'h78 );
//		read_data(  'h000005, 'h67 );
//		read_data(  'h000004, 'h56 );
//		read_data(  'h000003, 'h45 );
//		read_data(  'h000002, 'h34 );
//		read_data(  'h000001, 'h23 );
//		read_data(  'h000000, 'h12 );
//
//		$display( "Wait -------------------------------" );
//		for( i = 0; i < 100; i++ ) begin
//			$display( "** %d **", i );
//			repeat( 100 ) @( posedge clk );
//		end
//
//		$display( "delay read -------------------------" );
//		read_data(  'h400000, 'h21 );
//		read_data(  'h400001, 'h32 );
//		read_data(  'h400002, 'h43 );
//		read_data(  'h400003, 'h54 );
//		read_data(  'h400004, 'h65 );
//		read_data(  'h400005, 'h76 );
//		read_data(  'h400006, 'h87 );
//		read_data(  'h400007, 'h98 );
//
//		read_data(  'h000000, 'h12 );
//		read_data(  'h000001, 'h23 );
//		read_data(  'h000002, 'h34 );
//		read_data(  'h000003, 'h45 );
//		read_data(  'h000004, 'h56 );
//		read_data(  'h000005, 'h67 );
//		read_data(  'h000006, 'h78 );
//		read_data(  'h000007, 'h89 );
//
//		read_data(  'h400007, 'h98 );
//		read_data(  'h400006, 'h87 );
//		read_data(  'h400005, 'h76 );
//		read_data(  'h400004, 'h65 );
//		read_data(  'h400003, 'h54 );
//		read_data(  'h400002, 'h43 );
//		read_data(  'h400001, 'h32 );
//		read_data(  'h400000, 'h21 );
//
//		read_data(  'h000007, 'h89 );
//		read_data(  'h000006, 'h78 );
//		read_data(  'h000005, 'h67 );
//		read_data(  'h000004, 'h56 );
//		read_data(  'h000003, 'h45 );
//		read_data(  'h000002, 'h34 );
//		read_data(  'h000001, 'h23 );
//		read_data(  'h000000, 'h12 );
//
//		$display( "Read write -------------------------" );
//		for( j = 0; j < 4; j++ ) begin
//			for( i = 0; i < 256; i++ ) begin
//				write_data( (j << 21) | i, (i + j * 10) & 255 );
//			end
//		end
//
//		for( j = 0; j < 4; j++ ) begin
//			for( i = 0; i < 256; i++ ) begin
//				read_data( (j << 21) | i, (i + j * 10) & 255 );
//			end
//		end
//
//		repeat( 100 ) @( posedge clk );
//
//		$display( "write -------------------------" );
//		write_data( 'h000000, 'h12 );
//		write_data( 'h000001, 'h23 );
//		write_data( 'h000002, 'h34 );
//		write_data( 'h000003, 'h45 );
//		write_data( 'h000004, 'h56 );
//		write_data( 'h000005, 'h67 );
//		write_data( 'h000006, 'h78 );
//		write_data( 'h000007, 'h89 );
//
//		$display( "read -------------------------" );
//		read_data(  'h000000, 'h12 );
//		read_data(  'h000001, 'h23 );
//		read_data(  'h000002, 'h34 );
//		read_data(  'h000003, 'h45 );
//		read_data(  'h000004, 'h56 );
//		read_data(  'h000005, 'h67 );
//		read_data(  'h000006, 'h78 );
//		read_data(  'h000007, 'h89 );
//
//		read_data(  'h000007, 'h89 );
//		read_data(  'h000006, 'h78 );
//		read_data(  'h000005, 'h67 );
//		read_data(  'h000004, 'h56 );
//		read_data(  'h000003, 'h45 );
//		read_data(  'h000002, 'h34 );
//		read_data(  'h000001, 'h23 );
//		read_data(  'h000000, 'h12 );
//
//		$display( "write -------------------------" );
//		write_data( 'h400000, 'h21 );
//		write_data( 'h400001, 'h32 );
//		write_data( 'h400002, 'h43 );
//		write_data( 'h400003, 'h54 );
//		write_data( 'h400004, 'h65 );
//		write_data( 'h400005, 'h76 );
//		write_data( 'h400006, 'h87 );
//		write_data( 'h400007, 'h98 );
//
//		$display( "read -------------------------" );
//		read_data(  'h400000, 'h21 );
//		read_data(  'h400001, 'h32 );
//		read_data(  'h400002, 'h43 );
//		read_data(  'h400003, 'h54 );
//		read_data(  'h400004, 'h65 );
//		read_data(  'h400005, 'h76 );
//		read_data(  'h400006, 'h87 );
//		read_data(  'h400007, 'h98 );
//
//		read_data(  'h000000, 'h12 );
//		read_data(  'h000001, 'h23 );
//		read_data(  'h000002, 'h34 );
//		read_data(  'h000003, 'h45 );
//		read_data(  'h000004, 'h56 );
//		read_data(  'h000005, 'h67 );
//		read_data(  'h000006, 'h78 );
//		read_data(  'h000007, 'h89 );
//
//		read_data(  'h400007, 'h98 );
//		read_data(  'h400006, 'h87 );
//		read_data(  'h400005, 'h76 );
//		read_data(  'h400004, 'h65 );
//		read_data(  'h400003, 'h54 );
//		read_data(  'h400002, 'h43 );
//		read_data(  'h400001, 'h32 );
//		read_data(  'h400000, 'h21 );
//
//		read_data(  'h000007, 'h89 );
//		read_data(  'h000006, 'h78 );
//		read_data(  'h000005, 'h67 );
//		read_data(  'h000004, 'h56 );
//		read_data(  'h000003, 'h45 );
//		read_data(  'h000002, 'h34 );
//		read_data(  'h000001, 'h23 );
//		read_data(  'h000000, 'h12 );
//
//		$display( "Wait -------------------------------" );
//		for( i = 0; i < 100; i++ ) begin
//			$display( "** %d **", i );
//			repeat( 100 ) @( posedge clk );
//		end
//
//		$display( "delay read -------------------------" );
//		read_data(  'h400000, 'h21 );
//		read_data(  'h400001, 'h32 );
//		read_data(  'h400002, 'h43 );
//		read_data(  'h400003, 'h54 );
//		read_data(  'h400004, 'h65 );
//		read_data(  'h400005, 'h76 );
//		read_data(  'h400006, 'h87 );
//		read_data(  'h400007, 'h98 );
//
//		read_data(  'h000000, 'h12 );
//		read_data(  'h000001, 'h23 );
//		read_data(  'h000002, 'h34 );
//		read_data(  'h000003, 'h45 );
//		read_data(  'h000004, 'h56 );
//		read_data(  'h000005, 'h67 );
//		read_data(  'h000006, 'h78 );
//		read_data(  'h000007, 'h89 );
//
//		read_data(  'h400007, 'h98 );
//		read_data(  'h400006, 'h87 );
//		read_data(  'h400005, 'h76 );
//		read_data(  'h400004, 'h65 );
//		read_data(  'h400003, 'h54 );
//		read_data(  'h400002, 'h43 );
//		read_data(  'h400001, 'h32 );
//		read_data(  'h400000, 'h21 );
//
//		read_data(  'h000007, 'h89 );
//		read_data(  'h000006, 'h78 );
//		read_data(  'h000005, 'h67 );
//		read_data(  'h000004, 'h56 );
//		read_data(  'h000003, 'h45 );
//		read_data(  'h000002, 'h34 );
//		read_data(  'h000001, 'h23 );
//		read_data(  'h000000, 'h12 );
//
//		$display( "Read write -------------------------" );
//		for( j = 0; j < 4; j++ ) begin
//			for( i = 0; i < 256; i++ ) begin
//				write_data( (j << 21) | i, (i + j * 10) & 255 );
//			end
//		end
//
//		for( j = 0; j < 4; j++ ) begin
//			for( i = 0; i < 256; i++ ) begin
//				read_data( (j << 21) | i, (i + j * 10) & 255 );
//			end
//		end

		$finish;
	end
endmodule
