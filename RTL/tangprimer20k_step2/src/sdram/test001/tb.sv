// -----------------------------------------------------------------------------
//	Test of ip_sdram_tangprimer20k_c.v
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
//	localparam		clk_base	= 64'd1_000_000_000 / 64'd171_818;	//	ps
	localparam		clk_base	= 64'd1_000_000_000 / 64'd343_636;	//	ps
	reg				reset_n;
	reg				clk;				//	171.81816MHz
	reg				clk_n;				//	171.81816MHz
	wire			sdram_init_busy;
	wire			sdram_busy;
	reg				cpu_freeze;

	reg				mreq_n;
	reg		[26:0]	address;
	reg				wr_n;
	reg				rd_n;
	reg				rfsh_n;
	reg		[ 7:0]	wdata;
	wire	[ 7:0]	rdata;
	wire			rdata_en;

	wire			ddr3_rst_n;
	wire			ddr3_clk;
	wire			ddr3_clk_n;
	wire			ddr3_cke;
	wire			ddr3_cs_n;
	wire			ddr3_ras_n;
	wire			ddr3_cas_n;
	wire			ddr3_we_n;
	wire	[1:0]	ddr3_dm_tdqs;
	wire	[2:0]	ddr3_ba;
	wire	[12:0]	ddr3_addr;
	wire	[15:0]	ddr3_dq;
	wire	[1:0]	ddr3_dqs;
	wire	[1:0]	ddr3_dqs_n;
	wire	[1:0]	ddr3_tdqs_n;
	wire			ddr3_odt;

	int				i, j, k;

	// --------------------------------------------------------------------
	//	DUT
	// --------------------------------------------------------------------
	ip_sdram u_sdram_controller (
		.reset_n			( reset_n			),
		.clk				( clk				),
		.clk_n				( clk_n				),
		.sdram_init_busy	( sdram_init_busy	),
		.sdram_busy			( sdram_busy		),
		.cpu_freeze			( cpu_freeze		),
		.mreq_n				( mreq_n			),
		.address			( address			),
		.wr_n				( wr_n				),
		.rd_n				( rd_n				),
		.rfsh_n				( rfsh_n			),
		.wdata				( wdata				),
		.rdata				( rdata				),
		.rdata_en			( rdata_en			),
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
		.ddr3_tdqs_n		( ddr3_tdqs_n		),
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
		.addr				( ddr3_addr			),
		.dq					( ddr3_dq			),
		.dqs				( ddr3_dqs			),
		.dqs_n				( ddr3_dqs_n		),
		.tdqs_n				( ddr3_tdqs_n		),
		.odt				( ddr3_odt			)
	);

	// --------------------------------------------------------------------
	//	clock
	// --------------------------------------------------------------------
	always #(clk_base/2) begin
		clk <= ~clk;
		clk_n <= ~clk_n;
	end

	// --------------------------------------------------------------------
	//	Tasks
	// --------------------------------------------------------------------
	task write_data(
		input	[26:0]	p_address,
		input	[7:0]	p_data
	);
		$display( "write_data( 0x%07X, 0x%02X )", p_address, p_data );
		address		<= p_address;
		wdata		<= p_data;
		mreq_n		<= 1'b0;
		wr_n		<= 1'b0;
		while( sdram_busy ) begin
			@( posedge clk );
		end
		@( posedge clk );
		@( posedge clk );
		@( posedge clk );
		@( posedge clk );

		address		<= 0;
		wdata		<= 0;
		mreq_n		<= 1'b1;
		wr_n		<= 1'b1;
		@( posedge clk );
	endtask: write_data

	// --------------------------------------------------------------------
	task read_data(
		input	[26:0]	p_address,
		input	[15:0]	p_data
	);
		int time_out;

		$display( "read_data( 0x%07X, 0x%02X )", p_address, p_data );
		address		<= p_address;
		mreq_n		<= 1'b0;
		rd_n		<= 1'b0;
		while( sdram_busy ) begin
			@( posedge clk );
		end
		@( posedge clk );
		@( posedge clk );
		@( posedge clk );
		@( posedge clk );

		address		<= 0;
		mreq_n		<= 1'b1;
		rd_n		<= 1'b1;
		while( !rdata_en ) begin
			@( posedge clk );
		end
		assert( rdata == p_data );
		if( rdata != p_data ) begin
			$display( "-- p_data = %08X", p_data );
		end
		@( posedge clk );
	endtask: read_data

	// --------------------------------------------------------------------
	task cpu_read_data(
		input	[26:0]	p_address,
		input	[15:0]	p_data
	);
		int time_out;

		$display( "cpu_read_data( 0x%07X, 0x%02X )", p_address, p_data );
		address		<= p_address;
		mreq_n		<= 1'b0;
		rd_n		<= 1'b0;
		while( sdram_busy ) begin
			@( posedge clk );
		end
		@( posedge clk );
		@( posedge clk );
		@( posedge clk );
		@( posedge clk );

		address		<= 0;
		mreq_n		<= 1'b1;
		rd_n		<= 1'b1;
		while( !rdata_en ) begin
			@( posedge clk );
		end
		assert( rdata == p_data );
		if( rdata != p_data ) begin
			$display( "-- p_data = %08X", p_data );
		end
		@( posedge clk );

		rfsh_n		<= 1'b0;
		while( sdram_busy ) begin
			@( posedge clk );
		end
		@( posedge clk );
		@( posedge clk );
		@( posedge clk );
		@( posedge clk );

		rfsh_n		<= 1'b1;
		@( posedge clk );

	endtask: cpu_read_data

	// --------------------------------------------------------------------
	//	Test bench
	// --------------------------------------------------------------------
	initial begin
		reset_n			= 1'b0;
		clk				= 1'b0;
		clk_n			= 1'b1;
		mreq_n			= 1'b1;
		wr_n			= 1'b1;
		rd_n			= 1'b1;
		rfsh_n			= 1'b1;
		address			= 1'b0;
		wdata			= 1'b0;
		cpu_freeze		= 1'b1;

		repeat( 8 ) @( negedge clk );

		reset_n			= 1;
		@( posedge clk );

		# 800us @( posedge clk );

		while( sdram_init_busy ) begin
			@( posedge clk );
		end

		repeat( 16 ) @( posedge clk );
		repeat( 7 ) @( posedge clk );

		$display( "====================================" );
		$display( "=       cpu_freeze = 1;            =" );
		$display( "====================================" );

		$display( "write -------------------------" );
		write_data( 'h000000, 'h12 );
		write_data( 'h000001, 'h23 );
		write_data( 'h000002, 'h34 );
		write_data( 'h000003, 'h45 );
		write_data( 'h000004, 'h56 );
		write_data( 'h000005, 'h67 );
		write_data( 'h000006, 'h78 );
		write_data( 'h000007, 'h89 );

		$display( "read -------------------------" );
		read_data(  'h000000, 'h12 );
		read_data(  'h000001, 'h23 );
		read_data(  'h000002, 'h34 );
		read_data(  'h000003, 'h45 );
		read_data(  'h000004, 'h56 );
		read_data(  'h000005, 'h67 );
		read_data(  'h000006, 'h78 );
		read_data(  'h000007, 'h89 );

		read_data(  'h000007, 'h89 );
		read_data(  'h000006, 'h78 );
		read_data(  'h000005, 'h67 );
		read_data(  'h000004, 'h56 );
		read_data(  'h000003, 'h45 );
		read_data(  'h000002, 'h34 );
		read_data(  'h000001, 'h23 );
		read_data(  'h000000, 'h12 );

		$display( "write -------------------------" );
		write_data( 'h400000, 'h21 );
		write_data( 'h400001, 'h32 );
		write_data( 'h400002, 'h43 );
		write_data( 'h400003, 'h54 );
		write_data( 'h400004, 'h65 );
		write_data( 'h400005, 'h76 );
		write_data( 'h400006, 'h87 );
		write_data( 'h400007, 'h98 );

		$display( "read -------------------------" );
		read_data(  'h400000, 'h21 );
		read_data(  'h400001, 'h32 );
		read_data(  'h400002, 'h43 );
		read_data(  'h400003, 'h54 );
		read_data(  'h400004, 'h65 );
		read_data(  'h400005, 'h76 );
		read_data(  'h400006, 'h87 );
		read_data(  'h400007, 'h98 );

		read_data(  'h000000, 'h12 );
		read_data(  'h000001, 'h23 );
		read_data(  'h000002, 'h34 );
		read_data(  'h000003, 'h45 );
		read_data(  'h000004, 'h56 );
		read_data(  'h000005, 'h67 );
		read_data(  'h000006, 'h78 );
		read_data(  'h000007, 'h89 );

		read_data(  'h400007, 'h98 );
		read_data(  'h400006, 'h87 );
		read_data(  'h400005, 'h76 );
		read_data(  'h400004, 'h65 );
		read_data(  'h400003, 'h54 );
		read_data(  'h400002, 'h43 );
		read_data(  'h400001, 'h32 );
		read_data(  'h400000, 'h21 );

		read_data(  'h000007, 'h89 );
		read_data(  'h000006, 'h78 );
		read_data(  'h000005, 'h67 );
		read_data(  'h000004, 'h56 );
		read_data(  'h000003, 'h45 );
		read_data(  'h000002, 'h34 );
		read_data(  'h000001, 'h23 );
		read_data(  'h000000, 'h12 );

		$display( "Wait -------------------------------" );
		for( i = 0; i < 100; i++ ) begin
			$display( "** %d **", i );
			repeat( 100 ) @( posedge clk );
		end

		$display( "delay read -------------------------" );
		read_data(  'h400000, 'h21 );
		read_data(  'h400001, 'h32 );
		read_data(  'h400002, 'h43 );
		read_data(  'h400003, 'h54 );
		read_data(  'h400004, 'h65 );
		read_data(  'h400005, 'h76 );
		read_data(  'h400006, 'h87 );
		read_data(  'h400007, 'h98 );

		read_data(  'h000000, 'h12 );
		read_data(  'h000001, 'h23 );
		read_data(  'h000002, 'h34 );
		read_data(  'h000003, 'h45 );
		read_data(  'h000004, 'h56 );
		read_data(  'h000005, 'h67 );
		read_data(  'h000006, 'h78 );
		read_data(  'h000007, 'h89 );

		read_data(  'h400007, 'h98 );
		read_data(  'h400006, 'h87 );
		read_data(  'h400005, 'h76 );
		read_data(  'h400004, 'h65 );
		read_data(  'h400003, 'h54 );
		read_data(  'h400002, 'h43 );
		read_data(  'h400001, 'h32 );
		read_data(  'h400000, 'h21 );

		read_data(  'h000007, 'h89 );
		read_data(  'h000006, 'h78 );
		read_data(  'h000005, 'h67 );
		read_data(  'h000004, 'h56 );
		read_data(  'h000003, 'h45 );
		read_data(  'h000002, 'h34 );
		read_data(  'h000001, 'h23 );
		read_data(  'h000000, 'h12 );

		$display( "Read write -------------------------" );
		for( j = 0; j < 4; j++ ) begin
			for( i = 0; i < 256; i++ ) begin
				write_data( (j << 21) | i, (i + j * 10) & 255 );
			end
		end

		for( j = 0; j < 4; j++ ) begin
			for( i = 0; i < 256; i++ ) begin
				read_data( (j << 21) | i, (i + j * 10) & 255 );
			end
		end

		$display( "====================================" );
		$display( "=       cpu_freeze = 0;            =" );
		$display( "====================================" );
		cpu_freeze	<= 1'b0;

		repeat( 100 ) @( posedge clk );

		$display( "write -------------------------" );
		write_data( 'h000000, 'h12 );
		write_data( 'h000001, 'h23 );
		write_data( 'h000002, 'h34 );
		write_data( 'h000003, 'h45 );
		write_data( 'h000004, 'h56 );
		write_data( 'h000005, 'h67 );
		write_data( 'h000006, 'h78 );
		write_data( 'h000007, 'h89 );

		$display( "read -------------------------" );
		cpu_read_data(  'h000000, 'h12 );
		cpu_read_data(  'h000001, 'h23 );
		cpu_read_data(  'h000002, 'h34 );
		cpu_read_data(  'h000003, 'h45 );
		cpu_read_data(  'h000004, 'h56 );
		cpu_read_data(  'h000005, 'h67 );
		cpu_read_data(  'h000006, 'h78 );
		cpu_read_data(  'h000007, 'h89 );

		cpu_read_data(  'h000007, 'h89 );
		cpu_read_data(  'h000006, 'h78 );
		cpu_read_data(  'h000005, 'h67 );
		cpu_read_data(  'h000004, 'h56 );
		cpu_read_data(  'h000003, 'h45 );
		cpu_read_data(  'h000002, 'h34 );
		cpu_read_data(  'h000001, 'h23 );
		cpu_read_data(  'h000000, 'h12 );

		$display( "write -------------------------" );
		write_data( 'h400000, 'h21 );
		write_data( 'h400001, 'h32 );
		write_data( 'h400002, 'h43 );
		write_data( 'h400003, 'h54 );
		write_data( 'h400004, 'h65 );
		write_data( 'h400005, 'h76 );
		write_data( 'h400006, 'h87 );
		write_data( 'h400007, 'h98 );

		$display( "read -------------------------" );
		cpu_read_data(  'h400000, 'h21 );
		cpu_read_data(  'h400001, 'h32 );
		cpu_read_data(  'h400002, 'h43 );
		cpu_read_data(  'h400003, 'h54 );
		cpu_read_data(  'h400004, 'h65 );
		cpu_read_data(  'h400005, 'h76 );
		cpu_read_data(  'h400006, 'h87 );
		cpu_read_data(  'h400007, 'h98 );

		cpu_read_data(  'h000000, 'h12 );
		cpu_read_data(  'h000001, 'h23 );
		cpu_read_data(  'h000002, 'h34 );
		cpu_read_data(  'h000003, 'h45 );
		cpu_read_data(  'h000004, 'h56 );
		cpu_read_data(  'h000005, 'h67 );
		cpu_read_data(  'h000006, 'h78 );
		cpu_read_data(  'h000007, 'h89 );

		cpu_read_data(  'h400007, 'h98 );
		cpu_read_data(  'h400006, 'h87 );
		cpu_read_data(  'h400005, 'h76 );
		cpu_read_data(  'h400004, 'h65 );
		cpu_read_data(  'h400003, 'h54 );
		cpu_read_data(  'h400002, 'h43 );
		cpu_read_data(  'h400001, 'h32 );
		cpu_read_data(  'h400000, 'h21 );

		cpu_read_data(  'h000007, 'h89 );
		cpu_read_data(  'h000006, 'h78 );
		cpu_read_data(  'h000005, 'h67 );
		cpu_read_data(  'h000004, 'h56 );
		cpu_read_data(  'h000003, 'h45 );
		cpu_read_data(  'h000002, 'h34 );
		cpu_read_data(  'h000001, 'h23 );
		cpu_read_data(  'h000000, 'h12 );

		$display( "Wait -------------------------------" );
		for( i = 0; i < 100; i++ ) begin
			$display( "** %d **", i );
			repeat( 100 ) @( posedge clk );
		end

		$display( "delay read -------------------------" );
		cpu_read_data(  'h400000, 'h21 );
		cpu_read_data(  'h400001, 'h32 );
		cpu_read_data(  'h400002, 'h43 );
		cpu_read_data(  'h400003, 'h54 );
		cpu_read_data(  'h400004, 'h65 );
		cpu_read_data(  'h400005, 'h76 );
		cpu_read_data(  'h400006, 'h87 );
		cpu_read_data(  'h400007, 'h98 );

		cpu_read_data(  'h000000, 'h12 );
		cpu_read_data(  'h000001, 'h23 );
		cpu_read_data(  'h000002, 'h34 );
		cpu_read_data(  'h000003, 'h45 );
		cpu_read_data(  'h000004, 'h56 );
		cpu_read_data(  'h000005, 'h67 );
		cpu_read_data(  'h000006, 'h78 );
		cpu_read_data(  'h000007, 'h89 );

		cpu_read_data(  'h400007, 'h98 );
		cpu_read_data(  'h400006, 'h87 );
		cpu_read_data(  'h400005, 'h76 );
		cpu_read_data(  'h400004, 'h65 );
		cpu_read_data(  'h400003, 'h54 );
		cpu_read_data(  'h400002, 'h43 );
		cpu_read_data(  'h400001, 'h32 );
		cpu_read_data(  'h400000, 'h21 );

		cpu_read_data(  'h000007, 'h89 );
		cpu_read_data(  'h000006, 'h78 );
		cpu_read_data(  'h000005, 'h67 );
		cpu_read_data(  'h000004, 'h56 );
		cpu_read_data(  'h000003, 'h45 );
		cpu_read_data(  'h000002, 'h34 );
		cpu_read_data(  'h000001, 'h23 );
		cpu_read_data(  'h000000, 'h12 );

		$display( "Read write -------------------------" );
		for( j = 0; j < 4; j++ ) begin
			for( i = 0; i < 256; i++ ) begin
				write_data( (j << 21) | i, (i + j * 10) & 255 );
			end
		end

		for( j = 0; j < 4; j++ ) begin
			for( i = 0; i < 256; i++ ) begin
				cpu_read_data( (j << 21) | i, (i + j * 10) & 255 );
			end
		end

		$finish;
	end
endmodule
