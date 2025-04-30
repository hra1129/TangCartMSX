// -----------------------------------------------------------------------------
//	Test of vdp_top entity
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
	localparam		clk_base	= 1_000_000_000/42_955;	//	ps

	reg						clk;			//	42.95454MHz
	reg						reset_n;
	reg						initial_busy;
	reg						iorq_n;
	reg						wr_n;
	reg						rd_n;
	reg			[1:0]		address;
	wire		[7:0]		rdata;
	wire					rdata_en;
	reg			[7:0]		wdata;

	wire					int_n;

	wire					p_dram_oe_n;
	wire					p_dram_we_n;
	wire		[16:0]		p_dram_address;
	reg			[7:0]		p_dram_rdata;
	wire		[7:0]		p_dram_wdata;
	wire					p_dram_rdata_en;

	// video wire
	wire					p_vdp_enable;
	wire		[5:0]		p_vdp_r;
	wire		[5:0]		p_vdp_g;
	wire		[5:0]		p_vdp_b;
	wire		[10:0]		p_vdp_hcounter;
	wire		[10:0]		p_vdp_vcounter;

	wire					p_video_dh_clk;
	wire					p_video_dl_clk;

	reg			[15:0]		ff_dram_rdata0;
	reg			[15:0]		ff_dram_rdata1;
	reg			[15:0]		ff_dram_rdata2;
	int						i;

	// --------------------------------------------------------------------
	//	DUT
	// --------------------------------------------------------------------
	vdp_inst u_v9958 (
		.clk				( clk				),			//	42.95454MHz
		.reset_n			( reset_n			),
		.initial_busy		( initial_busy		),
		.iorq_n				( iorq_n			),
		.wr_n				( wr_n				),
		.rd_n				( rd_n				),
		.address			( address			),
		.rdata				( rdata				),
		.rdata_en			( rdata_en			),
		.wdata				( wdata				),
		.int_n				( int_n				),
		.p_dram_oe_n		( p_dram_oe_n		),
		.p_dram_we_n		( p_dram_we_n		),
		.p_dram_address		( p_dram_address	),
		.p_dram_rdata		( ff_dram_rdata2	),
		.p_dram_wdata		( p_dram_wdata		),
		.p_vdp_enable		( p_vdp_enable		),
		.p_vdp_r			( p_vdp_r			),
		.p_vdp_g			( p_vdp_g			),
		.p_vdp_b			( p_vdp_b			),
		.p_vdp_hcounter		( p_vdp_hcounter	),
		.p_vdp_vcounter		( p_vdp_vcounter	),
		.p_video_dh_clk		( p_video_dh_clk	),
		.p_video_dl_clk		( p_video_dl_clk	)
	);

	// --------------------------------------------------------------------
	//	VRAM
	// --------------------------------------------------------------------
	ip_ram u_ram (
		.clk				( clk					),
		.n_cs				( 1'b0					),
		.n_wr				( p_dram_we_n			),
		.n_rd				( p_dram_oe_n			),
		.address			( p_dram_address[13:0]	),
		.wdata				( p_dram_wdata			),
		.rdata				( p_dram_rdata			),
		.rdata_en			( p_dram_rdata_en		)
	);

	always @( posedge clk ) begin
		if( p_dram_rdata_en ) begin
			ff_dram_rdata0 <= { p_dram_rdata, p_dram_rdata };
		end
	end

	always @( posedge clk ) begin
		ff_dram_rdata1 <= ff_dram_rdata0;
		ff_dram_rdata2 <= ff_dram_rdata1;
	end

	// --------------------------------------------------------------------
	//	Clock
	// --------------------------------------------------------------------
	always #(clk_base/2) begin
		clk <= ~clk;
	end

	// --------------------------------------------------------------------
	//	Tasks
	// --------------------------------------------------------------------
	task outport(
		input	[7:0]	p_address,
		input	[7:0]	p_data
	);
		address		= p_address[1:0];
		wdata		= $random;
		iorq_n		= 0;
		wr_n		= 0;
		repeat( 1 * 6 ) @( posedge clk );
		wdata		= p_data;
		repeat( 1 * 6 ) @( posedge clk );

		address		= 0;
		wdata		= 0;
		iorq_n		= 1;
		wr_n		= 1;
		repeat( 2 * 6 ) @( posedge clk );
	endtask: outport

	// --------------------------------------------------------------------
	task write_reg(
		input	[7:0]	p_reg_address,
		input	[7:0]	p_data
	);
		$display( "Write VDP Reg#%2d: 0x%02X", p_reg_address, p_data );
		outport( 8'h99, p_data );
		outport( 8'h99, { 2'b10, p_reg_address[5:0] } );
	endtask: write_reg

	// --------------------------------------------------------------------
	task vpoke(
		input	[13:0]	p_vram_address,
		input	[7:0]	p_data
	);
		$display( "Vpoke( 0x%05X, 0x%02X )", p_vram_address, p_data );
		outport( 8'h99, p_vram_address[7:0] );
		outport( 8'h99, { 2'b01, p_vram_address[13:8] } );
		outport( 8'h98, p_data );
	endtask: vpoke

	// --------------------------------------------------------------------
	//	Test bench
	// --------------------------------------------------------------------
	initial begin
		clk						= 0;
		reset_n					= 0;
		initial_busy			= 0;
		iorq_n					= 1;
		wr_n					= 1;
		rd_n					= 1;
		address					= 0;
		wdata					= 0;;
		repeat( 10 ) @( negedge clk );

		reset_n					= 1;
		repeat( 10 ) @( posedge clk );

		@( posedge clk );

		// --------------------------------------------------------------------
		//	Initialization for SCREEN1
		// --------------------------------------------------------------------
		write_reg( 8'd00, 8'h00 );		//	Mode Register#0
		write_reg( 8'd01, 8'h60 );		//	Mode Register#1
		write_reg( 8'd08, 8'h08 );		//	Mode Register#2
		write_reg( 8'd09, 8'h00 );		//	Mode Register#3
		write_reg( 8'd25, 8'h00 );		//	Mode Register#4

		write_reg( 8'd02, 8'h06 );		//	Name Table

		write_reg( 8'd03, 8'h80 );		//	Color Table
		write_reg( 8'd10, 8'h00 );		//	Color Table

		write_reg( 8'd04, 8'h00 );		//	Pattern Generator Table

		write_reg( 8'd05, 8'h36 );		//	Sprite Attribute Table
		write_reg( 8'd11, 8'h00 );		//	Sprite Attribute Table

		write_reg( 8'd06, 8'h07 );		//	Sprite Pattern Generator Table

		write_reg( 8'd07, 8'h07 );		//	Text Color
		write_reg( 8'd12, 8'h00 );		//	Text Blink Color
		write_reg( 8'd13, 8'h00 );		//	Text Blink Period

		write_reg( 8'd18, 8'h00 );		//	Set Adjust
		write_reg( 8'd19, 8'h00 );		//	Line Interrupt
		write_reg( 8'd23, 8'h00 );		//	Vertical Scroll
		write_reg( 8'd26, 8'h00 );		//	Horizontal Scroll
		write_reg( 8'd27, 8'h00 );		//	Horizontal Scroll

		write_reg( 8'd14, 8'h00 );		//	VRAM High Address
		write_reg( 8'd15, 8'h00 );		//	Status Register Address
		write_reg( 8'd16, 8'h00 );		//	Palette Entry Address
		write_reg( 8'd17, 8'h00 );		//	Indirect Register Access Address

		vpoke( 14'h0000, 8'h12 );
		vpoke( 14'h0001, 8'h23 );
		vpoke( 14'h0002, 8'h34 );
		vpoke( 14'h0003, 8'h45 );

		// --------------------------------------------------------------------
		//	Wait
		// --------------------------------------------------------------------
		for( i = 0; i < 262 * 1; i++ ) begin
			$display( "LINE#[%d]", i );
			repeat( 1368 * 4 ) begin
				@( posedge clk );
			end
		end

		repeat( 10 ) @( posedge clk );
		$finish;
	end
endmodule
