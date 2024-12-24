// -----------------------------------------------------------------------------
//	Test of ip_sdram_tangnano20k_c.v
//	Copyright (C)2024 Takayuki Hara (HRA!)
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
	localparam		clk_base	= 1_000_000_000/108_000;	//	ps
	reg				reset_n;
	reg				clk;				//	85.90908MHz
	reg				clk_sdram;			//	85.90908MHz
	wire			sdram_busy;
	reg				cpu_freeze;

	reg				mreq_n;
	reg		[22:0]	address;
	reg				wr_n;
	reg				rd_n;
	reg				rfsh_n;
	reg		[ 7:0]	wdata;
	wire	[ 7:0]	rdata;
	wire			rdata_en;

	wire			O_sdram_clk;
	wire			O_sdram_cke;
	wire			O_sdram_cs_n;		// chip select
	wire			O_sdram_cas_n;		// columns address select
	wire			O_sdram_ras_n;		// row address select
	wire			O_sdram_wen_n;		// write enable
	wire	[31:0]	IO_sdram_dq;		// 32 bit bidirectional data bus
	wire	[10:0]	O_sdram_addr;		// 11 bit multiplexed address bus
	wire	[ 1:0]	O_sdram_ba;			// two banks
	wire	[ 3:0]	O_sdram_dqm;		// data mask
	reg		[ 1:0]	ff_video_clk;

	int				i;

	// --------------------------------------------------------------------
	//	DUT
	// --------------------------------------------------------------------
	ip_sdram u_sdram_controller (
		.reset_n			( reset_n			),
		.clk				( clk				),
		.clk_sdram			( clk				),
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
		.O_sdram_clk		( O_sdram_clk		),
		.O_sdram_cke		( O_sdram_cke		),
		.O_sdram_cs_n		( O_sdram_cs_n		),
		.O_sdram_cas_n		( O_sdram_cas_n		),
		.O_sdram_ras_n		( O_sdram_ras_n		),
		.O_sdram_wen_n		( O_sdram_wen_n		),
		.IO_sdram_dq		( IO_sdram_dq		),
		.O_sdram_addr		( O_sdram_addr		),
		.O_sdram_ba			( O_sdram_ba		),
		.O_sdram_dqm		( O_sdram_dqm		)
	);

	// --------------------------------------------------------------------
	mt48lc2m32b2 u_sdram (
		.Dq					( IO_sdram_dq		), 
		.Addr				( O_sdram_addr		), 
		.Ba					( O_sdram_ba		), 
		.Clk				( O_sdram_clk		), 
		.Cke				( O_sdram_cke		), 
		.Cs_n				( O_sdram_cs_n		), 
		.Ras_n				( O_sdram_ras_n		), 
		.Cas_n				( O_sdram_cas_n		), 
		.We_n				( O_sdram_wen_n		), 
		.Dqm				( O_sdram_dqm		)
	);

	// --------------------------------------------------------------------
	//	clock
	// --------------------------------------------------------------------
	always #(clk_base/2) begin
		clk <= ~clk;
		clk_sdram <= ~clk_sdram;
	end

	always @( posedge clk ) begin
		ff_video_clk <= ff_video_clk + 2'd1;
	end

	// --------------------------------------------------------------------
	//	Tasks
	// --------------------------------------------------------------------
	task write_data(
		input	[22:0]	p_address,
		input	[7:0]	p_data
	);
		$display( "write_data( 0x%06X, 0x%02X )", p_address, p_data );
		address		<= p_address;
		wdata		<= p_data;
		mreq_n		<= 1'b0;
		wr_n		<= 1'b0;
		@( posedge clk );
		@( posedge clk );
		@( posedge clk );
		@( posedge clk );

		address		<= 0;
		wdata		<= 0;
		mreq_n		<= 1'b1;
		wr_n		<= 1'b1;
		repeat( 12 ) @( posedge clk );
	endtask: write_data

	// --------------------------------------------------------------------
	task read_data(
		input	[22:0]	p_address,
		input	[15:0]	p_data
	);
		int time_out;

		$display( "read_data( 0x%06X, 0x%02X )", p_address, p_data );
		address		<= p_address;
		mreq_n		<= 1'b0;
		rd_n		<= 1'b0;
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
		repeat( 16 ) @( posedge clk );
	endtask: read_data

	// --------------------------------------------------------------------
	//	Test bench
	// --------------------------------------------------------------------
	initial begin
		reset_n = 0;
		clk = 0;
		clk_sdram = 1;
		mreq_n = 1;
		wr_n = 1;
		rd_n = 1;
		rfsh_n = 1;
		address = 0;
		wdata = 0;
		ff_video_clk = 0;
		cpu_freeze = 1;

		@( negedge clk );
		@( negedge clk );
		@( posedge clk );

		reset_n			= 1;
		@( posedge clk );

		while( sdram_busy ) begin
			@( posedge clk );
		end

		repeat( 16 ) @( posedge clk );
		repeat( 7 ) @( posedge clk );

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

		$finish;
	end
endmodule
