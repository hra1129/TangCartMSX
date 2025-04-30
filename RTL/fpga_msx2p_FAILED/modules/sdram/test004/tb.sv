// -----------------------------------------------------------------------------
//	Test of ip_sdram_tangnano20k_cv.v
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
	localparam		clk_base	= 1_000_000_000/85_909_080;	//	ps
	reg					reset_n;
	reg					clk;				//	85.90908MHz
	reg					clk_sdram;
	wire				sdram_init_busy;
	wire				sdram_busy;
	reg					cpu_freeze;
	//	CPU port
	reg					cpu_mreq_n;
	reg		[22:0]		cpu_address;
	reg					cpu_wr_n;
	reg					cpu_rd_n;
	reg					cpu_rfsh_n;
	reg		[ 7:0]		cpu_wdata;
	wire	[ 7:0]		cpu_rdata;
	wire				cpu_rdata_en;
	//	VDP port
	reg					vdp_access;
	reg		[16:0]		vdp_address;
	reg					vdp_wr_n;
	reg					vdp_rd_n;
	reg		[ 7:0]		vdp_wdata;
	wire	[15:0]		vdp_rdata;
	wire				vdp_rdata_en;
	// SDRAM ports
	wire				O_sdram_clk;
	wire				O_sdram_cke;
	wire				O_sdram_cs_n;		// chip select
	wire				O_sdram_ras_n;		// row address select
	wire				O_sdram_cas_n;		// columns address select
	wire				O_sdram_wen_n;		// write enable
	wire	[31:0]		IO_sdram_dq;		// 32 bit bidirectional data bus
	wire	[10:0]		O_sdram_addr;		// 11 bit multiplexed address bus
	wire	[ 1:0]		O_sdram_ba;			// two banks
	wire	[ 3:0]		O_sdram_dqm;		// data mask

	int					i, j, k;
	reg		[ 3:0]		ff_vdp_access;

	// --------------------------------------------------------------------
	//	DUT
	// --------------------------------------------------------------------
	ip_sdram u_sdram_controller (
		.reset_n			( reset_n			),
		.clk				( clk				),
		.clk_sdram			( clk_sdram			),
		.sdram_init_busy	( sdram_init_busy	),
		.sdram_busy			( sdram_busy		),
		.cpu_freeze			( cpu_freeze		),
		.cpu_mreq_n			( cpu_mreq_n		),
		.cpu_address		( cpu_address		),
		.cpu_wr_n			( cpu_wr_n			),
		.cpu_rd_n			( cpu_rd_n			),
		.cpu_rfsh_n			( cpu_rfsh_n		),
		.cpu_wdata			( cpu_wdata			),
		.cpu_rdata			( cpu_rdata			),
		.cpu_rdata_en		( cpu_rdata_en		),
		.vdp_access			( vdp_access		),
		.vdp_address		( vdp_address		),
		.vdp_wr_n			( vdp_wr_n			),
		.vdp_rd_n			( vdp_rd_n			),
		.vdp_wdata			( vdp_wdata			),
		.vdp_rdata			( vdp_rdata			),
		.vdp_rdata_en		( vdp_rdata_en		),
		.O_sdram_clk		( O_sdram_clk		),
		.O_sdram_cke		( O_sdram_cke		),
		.O_sdram_cs_n		( O_sdram_cs_n		),
		.O_sdram_ras_n		( O_sdram_ras_n		),
		.O_sdram_cas_n		( O_sdram_cas_n		),
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
		ff_vdp_access <= ff_vdp_access + 4'd1;
	end
	assign vdp_access	= ff_vdp_access[3];

	// --------------------------------------------------------------------
	//	Tasks
	// --------------------------------------------------------------------
	task cpu_write_data(
		input	[22:0]	p_address,
		input	[7:0]	p_data
	);
		$display( "cpu_write_data( 0x%06X, 0x%02X )", p_address, p_data );
		@( negedge sdram_busy );

		cpu_address		= p_address;
		cpu_wdata		= p_data;
		cpu_mreq_n		= 1'b0;
		cpu_wr_n		= 1'b0;
		repeat( 4 ) @( posedge clk );

		cpu_address		= 0;
		cpu_wdata		= 0;
		cpu_mreq_n		= 1'b1;
		cpu_wr_n		= 1'b1;
		@( posedge clk );
	endtask: cpu_write_data

	// --------------------------------------------------------------------
	task cpu_read_data(
		input	[22:0]	p_address,
		input	[7:0]	p_data
	);
		int time_out;

		$display( "cpu_read_data( 0x%06X, 0x%02X )", p_address, p_data );
		@( negedge sdram_busy );

		cpu_address		<= p_address;
		cpu_mreq_n		<= 1'b0;
		cpu_rd_n		<= 1'b0;
		repeat( 4 ) @( posedge clk );

		cpu_address		<= 0;
		cpu_mreq_n		<= 1'b1;
		cpu_rd_n		<= 1'b1;
		while( !cpu_rdata_en ) begin
			@( posedge clk );
		end
		assert( cpu_rdata == p_data );
		if( cpu_rdata != p_data ) begin
			$display( "-- p_data = %02X", p_data );
		end
		@( posedge clk );
	endtask: cpu_read_data

	// --------------------------------------------------------------------
	task cpu_read_data_refresh(
		input	[22:0]	p_address,
		input	[15:0]	p_data
	);
		int time_out;

		$display( "cpu_read_data( 0x%06X, 0x%02X )", p_address, p_data );
		@( negedge sdram_busy );

		cpu_address		<= p_address;
		cpu_mreq_n		<= 1'b0;
		cpu_rd_n		<= 1'b0;
		repeat( 4 ) @( posedge clk );

		cpu_address		<= 0;
		cpu_mreq_n		<= 1'b1;
		cpu_rd_n		<= 1'b1;
		while( !cpu_rdata_en ) begin
			@( posedge clk );
		end
		assert( cpu_rdata == p_data );
		if( cpu_rdata != p_data ) begin
			$display( "-- p_data = %02X", p_data );
		end

		@( negedge sdram_busy );
		cpu_rfsh_n		<= 1'b0;
		repeat( 4 ) @( posedge clk );

		cpu_rfsh_n		<= 1'b1;
		@( posedge clk );

	endtask: cpu_read_data_refresh

	// --------------------------------------------------------------------
	task vdp_write_data(
		input	[16:0]	p_address,
		input	[7:0]	p_data
	);
		$display( "vdp_write_data( 0x%06X, 0x%02X )", p_address, p_data );
		vdp_address		= p_address;
		vdp_wdata		= p_data;
		while( ff_vdp_access != 3'd7 ) begin
			@( posedge clk );
		end
		vdp_wr_n		= 1'b0;
		repeat( 8 ) @( posedge clk );

		vdp_address		= 0;
		vdp_wdata		= 0;
		vdp_wr_n		= 1'b1;
		@( posedge clk );
	endtask: vdp_write_data

	// --------------------------------------------------------------------
	task vdp_read_data(
		input	[16:0]	p_address,
		input	[15:0]	p_data
	);
		int time_out;

		$display( "vdp_read_data( 0x%06X, 0x%04X )", p_address, p_data );
		vdp_address		= p_address;
		while( ff_vdp_access != 3'd7 ) begin
			@( posedge clk );
		end
		vdp_rd_n		= 1'b0;
		@( posedge clk );

		vdp_address		= 0;
		while( !vdp_rdata_en ) begin
			@( posedge clk );
		end
		vdp_rd_n		= 1'b1;
		assert( vdp_rdata == p_data );
		if( vdp_rdata != p_data ) begin
			$display( "-- p_data = %04X", p_data );
		end
		@( posedge clk );
	endtask: vdp_read_data

	// --------------------------------------------------------------------
	//	Test bench
	// --------------------------------------------------------------------
	initial begin
		reset_n = 0;
		clk = 0;
		clk_sdram = 1;
		cpu_mreq_n = 1;
		cpu_wr_n = 1;
		cpu_rd_n = 1;
		cpu_rfsh_n = 1;
		cpu_address = 0;
		cpu_wdata = 0;
		vdp_wr_n = 1;
		vdp_rd_n = 1;
		vdp_address = 0;
		vdp_wdata = 0;
		ff_vdp_access = 0;
		cpu_freeze = 1;

		@( negedge clk );
		@( negedge clk );
		@( posedge clk );

		reset_n			= 1;
		@( posedge clk );

		while( sdram_init_busy ) begin
			@( posedge clk );
		end

		repeat( 16 ) @( posedge clk );
		repeat( 7 ) @( posedge clk );

		$display( "====================================" );
		$display( "=       cpu_freeze = 1;            =" );
		$display( "====================================" );

		$display( "write -------------------------" );
		vdp_write_data( 'h00000, 'h12 );
		vdp_write_data( 'h00001, 'h23 );
		vdp_write_data( 'h00002, 'h34 );
		vdp_write_data( 'h00003, 'h45 );
		vdp_write_data( 'h00004, 'h56 );
		vdp_write_data( 'h00005, 'h67 );
		vdp_write_data( 'h00006, 'h78 );
		vdp_write_data( 'h00007, 'h89 );

		$display( "read -------------------------" );
		vdp_read_data(  'h00000, 'h2312 );
		vdp_read_data(  'h00001, 'h2312 );
		vdp_read_data(  'h00002, 'h4534 );
		vdp_read_data(  'h00003, 'h4534 );
		vdp_read_data(  'h00004, 'h6756 );
		vdp_read_data(  'h00005, 'h6756 );
		vdp_read_data(  'h00006, 'h8978 );
		vdp_read_data(  'h00007, 'h8978 );

		vdp_read_data(  'h00007, 'h8978 );
		vdp_read_data(  'h00006, 'h8978 );
		vdp_read_data(  'h00005, 'h6756 );
		vdp_read_data(  'h00004, 'h6756 );
		vdp_read_data(  'h00003, 'h4534 );
		vdp_read_data(  'h00002, 'h4534 );
		vdp_read_data(  'h00001, 'h2312 );
		vdp_read_data(  'h00000, 'h2312 );

		$display( "write -------------------------" );
		vdp_write_data( 'h10000, 'h21 );
		vdp_write_data( 'h10001, 'h32 );
		vdp_write_data( 'h10002, 'h43 );
		vdp_write_data( 'h10003, 'h54 );
		vdp_write_data( 'h10004, 'h65 );
		vdp_write_data( 'h10005, 'h76 );
		vdp_write_data( 'h10006, 'h87 );
		vdp_write_data( 'h10007, 'h98 );

		$display( "read -------------------------" );
		vdp_read_data(  'h10000, 'h3221 );
		vdp_read_data(  'h10001, 'h3221 );
		vdp_read_data(  'h10002, 'h5443 );
		vdp_read_data(  'h10003, 'h5443 );
		vdp_read_data(  'h10004, 'h7665 );
		vdp_read_data(  'h10005, 'h7665 );
		vdp_read_data(  'h10006, 'h9887 );
		vdp_read_data(  'h10007, 'h9887 );

		vdp_read_data(  'h00000, 'h2312 );
		vdp_read_data(  'h00001, 'h2312 );
		vdp_read_data(  'h00002, 'h4534 );
		vdp_read_data(  'h00003, 'h4534 );
		vdp_read_data(  'h00004, 'h6756 );
		vdp_read_data(  'h00005, 'h6756 );
		vdp_read_data(  'h00006, 'h8978 );
		vdp_read_data(  'h00007, 'h8978 );

		vdp_read_data(  'h10007, 'h9887 );
		vdp_read_data(  'h10006, 'h9887 );
		vdp_read_data(  'h10005, 'h7665 );
		vdp_read_data(  'h10004, 'h7665 );
		vdp_read_data(  'h10003, 'h5443 );
		vdp_read_data(  'h10002, 'h5443 );
		vdp_read_data(  'h10001, 'h3221 );
		vdp_read_data(  'h10000, 'h3221 );

		vdp_read_data(  'h00007, 'h8978 );
		vdp_read_data(  'h00006, 'h8978 );
		vdp_read_data(  'h00005, 'h6756 );
		vdp_read_data(  'h00004, 'h6756 );
		vdp_read_data(  'h00003, 'h4534 );
		vdp_read_data(  'h00002, 'h4534 );
		vdp_read_data(  'h00001, 'h2312 );
		vdp_read_data(  'h00000, 'h2312 );

		$display( "CPU Read write ---------------------" );
		cpu_write_data( 'h0000000, 'h12 );
		cpu_write_data( 'h0000001, 'h23 );
		cpu_write_data( 'h0000002, 'h34 );
		cpu_write_data( 'h0000003, 'h45 );

		cpu_read_data( 'h0000000, 'h12 );
		cpu_read_data( 'h0000001, 'h23 );
		cpu_read_data( 'h0000002, 'h34 );
		cpu_read_data( 'h0000003, 'h45 );

		$display( "Read write -------------------------" );
		for( j = 0; j < 4; j++ ) begin
			for( i = 0; i < 256; i++ ) begin
				cpu_write_data( (j << 21) | i, (i + j * 10) & 255 );
			end
		end

		for( j = 0; j < 4; j++ ) begin
			for( i = 0; i < 256; i++ ) begin
				cpu_read_data( (j << 21) | i, (i + j * 10) & 255 );
			end
		end

		$display( "====================================" );
		$display( "=       cpu_freeze = 0;            =" );
		$display( "====================================" );
		cpu_freeze	<= 1'b0;

		repeat( 100 ) @( posedge clk );

		$display( "write -------------------------" );
		cpu_write_data( 'h000000, 'h12 );
		cpu_write_data( 'h000001, 'h23 );
		cpu_write_data( 'h000002, 'h34 );
		cpu_write_data( 'h000003, 'h45 );
		cpu_write_data( 'h000004, 'h56 );
		cpu_write_data( 'h000005, 'h67 );
		cpu_write_data( 'h000006, 'h78 );
		cpu_write_data( 'h000007, 'h89 );

		$display( "read -------------------------" );
		cpu_read_data_refresh(  'h000000, 'h12 );
		cpu_read_data_refresh(  'h000001, 'h23 );
		cpu_read_data_refresh(  'h000002, 'h34 );
		cpu_read_data_refresh(  'h000003, 'h45 );
		cpu_read_data_refresh(  'h000004, 'h56 );
		cpu_read_data_refresh(  'h000005, 'h67 );
		cpu_read_data_refresh(  'h000006, 'h78 );
		cpu_read_data_refresh(  'h000007, 'h89 );

		cpu_read_data_refresh(  'h000007, 'h89 );
		cpu_read_data_refresh(  'h000006, 'h78 );
		cpu_read_data_refresh(  'h000005, 'h67 );
		cpu_read_data_refresh(  'h000004, 'h56 );
		cpu_read_data_refresh(  'h000003, 'h45 );
		cpu_read_data_refresh(  'h000002, 'h34 );
		cpu_read_data_refresh(  'h000001, 'h23 );
		cpu_read_data_refresh(  'h000000, 'h12 );

		$display( "write -------------------------" );
		cpu_write_data( 'h400000, 'h21 );
		vdp_write_data( 'h10000, 'h21 );
		cpu_write_data( 'h400001, 'h32 );
		vdp_write_data( 'h10001, 'h32 );
		cpu_write_data( 'h400002, 'h43 );
		vdp_write_data( 'h10002, 'h43 );
		cpu_write_data( 'h400003, 'h54 );
		vdp_write_data( 'h10003, 'h54 );
		cpu_write_data( 'h400004, 'h65 );
		vdp_write_data( 'h10004, 'h65 );
		cpu_write_data( 'h400005, 'h76 );
		vdp_write_data( 'h10005, 'h76 );
		cpu_write_data( 'h400006, 'h87 );
		vdp_write_data( 'h10006, 'h87 );
		cpu_write_data( 'h400007, 'h98 );
		vdp_write_data( 'h10007, 'h98 );

		$display( "read -------------------------" );
		cpu_read_data_refresh(  'h400000, 'h21 );
		vdp_read_data(  'h10000, 'h3221 );
		cpu_read_data_refresh(  'h400001, 'h32 );
		vdp_read_data(  'h10001, 'h3221 );
		cpu_read_data_refresh(  'h400002, 'h43 );
		vdp_read_data(  'h10002, 'h5443 );
		cpu_read_data_refresh(  'h400003, 'h54 );
		vdp_read_data(  'h10003, 'h5443 );
		cpu_read_data_refresh(  'h400004, 'h65 );
		vdp_read_data(  'h10004, 'h7665 );
		cpu_read_data_refresh(  'h400005, 'h76 );
		vdp_read_data(  'h10005, 'h7665 );
		cpu_read_data_refresh(  'h400006, 'h87 );
		vdp_read_data(  'h10006, 'h9887 );
		cpu_read_data_refresh(  'h400007, 'h98 );
		vdp_read_data(  'h10007, 'h9887 );


		cpu_read_data_refresh(  'h000000, 'h12 );
		vdp_read_data(  'h00000, 'h2312 );
		cpu_read_data_refresh(  'h000001, 'h23 );
		vdp_read_data(  'h00001, 'h2312 );
		cpu_read_data_refresh(  'h000002, 'h34 );
		vdp_read_data(  'h00002, 'h4534 );
		cpu_read_data_refresh(  'h000003, 'h45 );
		vdp_read_data(  'h00003, 'h4534 );
		cpu_read_data_refresh(  'h000004, 'h56 );
		vdp_read_data(  'h00004, 'h6756 );
		cpu_read_data_refresh(  'h000005, 'h67 );
		vdp_read_data(  'h00005, 'h6756 );
		cpu_read_data_refresh(  'h000006, 'h78 );
		vdp_read_data(  'h00006, 'h8978 );
		cpu_read_data_refresh(  'h000007, 'h89 );
		vdp_read_data(  'h00007, 'h8978 );


		cpu_read_data_refresh(  'h400007, 'h98 );
		vdp_read_data(  'h10007, 'h9887 );
		cpu_read_data_refresh(  'h400006, 'h87 );
		vdp_read_data(  'h10006, 'h9887 );
		cpu_read_data_refresh(  'h400005, 'h76 );
		vdp_read_data(  'h10005, 'h7665 );
		cpu_read_data_refresh(  'h400004, 'h65 );
		vdp_read_data(  'h10004, 'h7665 );
		cpu_read_data_refresh(  'h400003, 'h54 );
		vdp_read_data(  'h10003, 'h5443 );
		cpu_read_data_refresh(  'h400002, 'h43 );
		vdp_read_data(  'h10002, 'h5443 );
		cpu_read_data_refresh(  'h400001, 'h32 );
		vdp_read_data(  'h10001, 'h3221 );
		cpu_read_data_refresh(  'h400000, 'h21 );
		vdp_read_data(  'h10000, 'h3221 );

		fork
			begin
				cpu_read_data_refresh(  'h000007, 'h89 );
				cpu_read_data_refresh(  'h000006, 'h78 );
				cpu_read_data_refresh(  'h000005, 'h67 );
				cpu_read_data_refresh(  'h000004, 'h56 );
				cpu_read_data_refresh(  'h000003, 'h45 );
				cpu_read_data_refresh(  'h000002, 'h34 );
				cpu_read_data_refresh(  'h000001, 'h23 );
				cpu_read_data_refresh(  'h000000, 'h12 );
			end
			begin
				vdp_read_data(  'h00007, 'h8978 );
				vdp_read_data(  'h00006, 'h8978 );
				vdp_read_data(  'h00005, 'h6756 );
				vdp_read_data(  'h00004, 'h6756 );
				vdp_read_data(  'h00003, 'h4534 );
				vdp_read_data(  'h00002, 'h4534 );
				vdp_read_data(  'h00001, 'h2312 );
				vdp_read_data(  'h00000, 'h2312 );
			end
		join

		$display( "Wait -------------------------------" );
		for( i = 0; i < 100; i++ ) begin
			$display( "** %d **", i );
			repeat( 100 ) @( posedge clk );
		end

		$display( "delay read -------------------------" );
		cpu_read_data_refresh(  'h400000, 'h21 );
		cpu_read_data_refresh(  'h400001, 'h32 );
		cpu_read_data_refresh(  'h400002, 'h43 );
		cpu_read_data_refresh(  'h400003, 'h54 );
		cpu_read_data_refresh(  'h400004, 'h65 );
		cpu_read_data_refresh(  'h400005, 'h76 );
		cpu_read_data_refresh(  'h400006, 'h87 );
		cpu_read_data_refresh(  'h400007, 'h98 );

		cpu_read_data_refresh(  'h000000, 'h12 );
		cpu_read_data_refresh(  'h000001, 'h23 );
		cpu_read_data_refresh(  'h000002, 'h34 );
		cpu_read_data_refresh(  'h000003, 'h45 );
		cpu_read_data_refresh(  'h000004, 'h56 );
		cpu_read_data_refresh(  'h000005, 'h67 );
		cpu_read_data_refresh(  'h000006, 'h78 );
		cpu_read_data_refresh(  'h000007, 'h89 );

		cpu_read_data_refresh(  'h400007, 'h98 );
		cpu_read_data_refresh(  'h400006, 'h87 );
		cpu_read_data_refresh(  'h400005, 'h76 );
		cpu_read_data_refresh(  'h400004, 'h65 );
		cpu_read_data_refresh(  'h400003, 'h54 );
		cpu_read_data_refresh(  'h400002, 'h43 );
		cpu_read_data_refresh(  'h400001, 'h32 );
		cpu_read_data_refresh(  'h400000, 'h21 );

		cpu_read_data_refresh(  'h000007, 'h89 );
		cpu_read_data_refresh(  'h000006, 'h78 );
		cpu_read_data_refresh(  'h000005, 'h67 );
		cpu_read_data_refresh(  'h000004, 'h56 );
		cpu_read_data_refresh(  'h000003, 'h45 );
		cpu_read_data_refresh(  'h000002, 'h34 );
		cpu_read_data_refresh(  'h000001, 'h23 );
		cpu_read_data_refresh(  'h000000, 'h12 );

		$display( "Read write -------------------------" );
		for( j = 0; j < 4; j++ ) begin
			for( i = 0; i < 256; i++ ) begin
				cpu_write_data( (j << 21) | i, (i + j * 10) & 255 );
			end
		end

		for( j = 0; j < 4; j++ ) begin
			for( i = 0; i < 256; i++ ) begin
				cpu_read_data_refresh( (j << 21) | i, (i + j * 10) & 255 );
			end
		end

		repeat( 100 ) @( posedge clk );
		$finish;
	end
endmodule
