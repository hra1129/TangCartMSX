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
	localparam		clk_base	= 1_000_000_000/42_954_540;	//	ps
	reg						clk;			//	42.95454MHz
	reg						reset_n;
	reg						iorq_n;
	reg						wr_n;
	reg						rd_n;
	reg						address;
	wire		[7:0]		rdata;
	wire					rdata_en;
	reg			[7:0]		wdata;

	wire					int_n;

	wire					w_vram_read_n;
	wire					w_vram_write_n;
	wire		[13:0]		w_vram_address;
	reg			[7:0]		ff_vram_rdata;
	wire		[7:0]		w_vram_wdata;
	wire		[7:0]		w_vram_rdata;
	wire					w_vram_rdata_en;

	// video wire
	wire					pvideo_clk;
	wire					pvideo_data_en;

	wire		[5:0]		pvideor;
	wire		[5:0]		pvideog;
	wire		[5:0]		pvideob;

	wire					pvideohs_n;
	wire					pvideovs_n;

	wire					p_video_dh_clk;
	wire					p_video_dl_clk;

	int						i, j, k;
	reg						timing;

	// --------------------------------------------------------------------
	//	DUT
	// --------------------------------------------------------------------
	vdp_inst u_vdp (
		.clk				( clk				),
		.reset_n			( reset_n			),
		.initial_busy		( 1'b0				),
		.iorq_n				( iorq_n			),
		.wr_n				( wr_n				),
		.rd_n				( rd_n				),
		.address			( address			),
		.rdata				( rdata				),
		.rdata_en			( rdata_en			),
		.wdata				( wdata				),
		.int_n				( int_n				),
		.p_dram_oe_n		( w_vram_read_n		),
		.p_dram_we_n		( w_vram_write_n	),
		.p_dram_address		( w_vram_address	),
		.p_dram_rdata		( ff_vram_rdata		),
		.p_dram_wdata		( w_vram_wdata		),
		.pvideo_clk			( pvideo_clk		),
		.pvideo_data_en		( pvideo_data_en	),
		.pvideor			( pvideor			),
		.pvideog			( pvideog			),
		.pvideob			( pvideob			),
		.pvideohs_n			( pvideohs_n		),
		.pvideovs_n			( pvideovs_n		),
		.p_video_dh_clk		( p_video_dh_clk	),
		.p_video_dl_clk		( p_video_dl_clk	)
	);

	// --------------------------------------------------------------------
	ip_ram u_vram (
		.clk					( clk					),
		.n_cs					( 1'b0					),
		.n_wr					( w_vram_write_n		),
		.n_rd					( w_vram_read_n			),
		.address				( w_vram_address		),
		.wdata					( w_vram_wdata			),
		.rdata					( w_vram_rdata			),
		.rdata_en				( w_vram_rdata_en		)
	);

	always @( posedge clk ) begin
		if( w_vram_rdata_en ) begin
			ff_vram_rdata <= w_vram_rdata;
		end
	end

	// --------------------------------------------------------------------
	//	clock
	// --------------------------------------------------------------------
	always #(clk_base/2) begin
		clk <= ~clk;
	end

	// --------------------------------------------------------------------
	//	Tasks
	// --------------------------------------------------------------------
	task write_data(
		input			p_address,
		input	[7:0]	p_data
	);
		$display( "write_data( 0x%06X, 0x%02X )", p_address, p_data );
		address		<= p_address;
		wdata		<= p_data;
		iorq_n		<= 1'b0;
		wr_n		<= 1'b0;
		@( posedge clk );
		@( posedge clk );

		iorq_n		<= 1'b1;
		wr_n		<= 1'b1;
		@( posedge clk );
		@( posedge clk );
		@( posedge clk );
		@( posedge clk );
		@( posedge clk );
		@( posedge clk );
	endtask: write_data

	// --------------------------------------------------------------------
	task read_data(
		input	[22:0]	p_address,
		input	[15:0]	p_data
	);
		int time_out;

		$display( "read_data( 0x%06X, 0x%02X )", p_address, p_data );
		address		<= p_address;
		iorq_n		<= 1'b0;
		@( posedge clk );
		rd_n		<= 1'b0;
		repeat( 16 ) @( negedge clk );

		iorq_n		<= 1'b1;
		rd_n		<= 1'b1;
		@( posedge clk );

		assert( rdata == p_data );
		if( rdata != p_data ) begin
			$display( "-- p_data = %08X (ref: %08X)", rdata, p_data );
		end

		@( posedge clk );
		@( posedge clk );
		@( posedge clk );
		@( posedge clk );
	endtask: read_data

	// --------------------------------------------------------------------
	//	Test bench
	// --------------------------------------------------------------------
	initial begin
		timing = 0;
		reset_n = 0;
		clk = 0;
		reset_n = 0;
		iorq_n = 1;
		wr_n = 1;
		rd_n = 1;
		address = 0;
		wdata = 0;
		ff_vram_rdata = 0;

		@( negedge clk );
		@( negedge clk );
		@( posedge clk );

		reset_n			= 1;
		@( posedge clk );

		//	連続書き込みのアドレス指定 
		write_data( 1, 8'h00 );
		write_data( 1, 8'h40 );

		write_data( 0, 8'hAA );
		write_data( 0, 8'h55 );
		write_data( 0, 8'hA5 );
		write_data( 0, 8'h5A );
		write_data( 0, 8'h12 );
		write_data( 0, 8'h34 );
		write_data( 0, 8'h56 );
		write_data( 0, 8'h78 );

		//	連続読み出しのアドレス指定
		write_data( 1, 8'h00 );
		write_data( 1, 8'h00 );

		read_data( 0, 8'hAA );
		read_data( 0, 8'h55 );
		read_data( 0, 8'hA5 );
		read_data( 0, 8'h5A );
		read_data( 0, 8'h12 );
		read_data( 0, 8'h34 );
		read_data( 0, 8'h56 );
		read_data( 0, 8'h78 );

		//	ステータスレジスタの読み出し
		read_data( 1, 8'h1f );

		//	レジスタ書き込み
		write_data( 1, 8'hA0 );
		write_data( 1, 8'h81 );

		repeat( 100 ) @( posedge clk );

		//	GRAPHIC1 (SCREEN1) にセットする 
		timing = 1;
		write_data( 1, 8'h00 );
		write_data( 1, 8'h80 );			//	R#0 = 0x00
		write_data( 1, 8'h00 );
		write_data( 1, 8'h81 );			//	R#1 = 0x00
		write_data( 1, 8'h06 );
		write_data( 1, 8'h82 );			//	R#2 = 0x06 : Pattern Name Table      0x1800 = 01_1000_0000_0000 → 01_10
		write_data( 1, 8'h80 );
		write_data( 1, 8'h83 );			//	R#3 = 0x80 : Color Table             0x2000 = 10_0000_0000_0000 → 10_0000_00
		write_data( 1, 8'h00 );
		write_data( 1, 8'h84 );			//	R#4 = 0x00 : Pattern Generator Table 0x0000 = 00_0000_0000_0000 → 00_0
		timing = 0;

		//	Pattern Name Table にインクリメント値をセットする 
		write_data( 1, 8'h00 );
		write_data( 1, 8'h58 );			//	VRAM Ptr. = 0x1800
		for( i = 0; i < 768; i++ ) begin
			write_data( 0, i & 255 );
		end

		//	Pattern Generator Table にインクリメント値をセットする 
		write_data( 1, 8'h00 );
		write_data( 1, 8'h40 );			//	VRAM Ptr. = 0x0000
		for( i = 0; i < 256; i++ ) begin
			for( j = 0; j < 8; j++ ) begin
				write_data( 0, j + ((i << 4) & 255) );
			end
		end

		//	Pattern Name Table にインクリメント値をセットする 
		write_data( 1, 8'h00 );
		write_data( 1, 8'h60 );			//	VRAM Ptr. = 0x2000
		for( i = 0; i < 32; i++ ) begin
			write_data( 0, 8'hF4 );
		end

		timing = 1;
		@( posedge clk );

		timing = 0;
		repeat( 3000 ) @( posedge clk );
		$finish;
	end
endmodule
