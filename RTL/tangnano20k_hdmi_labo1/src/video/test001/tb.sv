// -----------------------------------------------------------------------------
//	Test of secondary_slot_inst.v
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
// -----------------------------------------------------------------------------

module tb ();
	localparam		clk_base	= 1_000_000_000/74_250;	//	ps
	reg				reset_n;
	reg				clk;
	reg				iorq_n;
	reg		[7:0]	address;
	reg				wr_n;
	reg		[7:0]	wdata;
	wire			vram_mreq_n;
	wire	[22:0]	vram_address;
	wire			vram_wr_n;
	wire			vram_rd_n;
	wire			vram_rfsh_n;
	wire	[ 7:0]	vram_wdata;
	reg		[31:0]	vram_rdata;
	reg				vram_rdata_en;

	reg		[31:0]	vram_rdata0;
	reg		[31:0]	vram_rdata1;
	reg		[31:0]	vram_rdata2;
	reg		[31:0]	vram_rdata3;
	reg		[31:0]	vram_rdata4;
	reg		[31:0]	vram_rdata5;
	reg				vram_rdata_en0;
	reg				vram_rdata_en1;
	reg				vram_rdata_en2;
	reg				vram_rdata_en3;
	reg				vram_rdata_en4;
	reg				vram_rdata_en5;

	wire			video_de;
	wire			video_hs;
	wire			video_vs;
	wire	[7:0]	video_r;
	wire	[7:0]	video_g;
	wire	[7:0]	video_b;
	int				i, j, k, p;
	reg		[7:0]	ff_ram [0: 8192 * 1024 - 1];

	// --------------------------------------------------------------------
	//	DUT
	// --------------------------------------------------------------------
	ip_video u_dut (
		.reset_n			( reset_n			),
		.clk				( clk				),
		.iorq_n				( iorq_n			),
		.wr_n				( wr_n				),
		.address			( address			),
		.wdata				( wdata				),
		.vram_mreq_n		( vram_mreq_n		),
		.vram_address		( vram_address		),
		.vram_wr_n			( vram_wr_n			),
		.vram_rd_n			( vram_rd_n			),
		.vram_rfsh_n		( vram_rfsh_n		),
		.vram_wdata			( vram_wdata		),
		.vram_rdata			( vram_rdata		),
		.vram_rdata_en		( vram_rdata_en		),
		.video_de			( video_de			),
		.video_hs			( video_hs			),
		.video_vs			( video_vs			),
		.video_r			( video_r			),
		.video_g			( video_g			),
		.video_b			( video_b			)
	);

	// --------------------------------------------------------------------
	//	clock
	// --------------------------------------------------------------------
	always #(clk_base/2) begin
		clk <= ~clk;
	end

	// --------------------------------------------------------------------
	//	RAM
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !vram_mreq_n ) begin
			if( !vram_wr_n ) begin
				ff_ram[ vram_address ] <= vram_wdata;
				vram_rdata_en0	<= 1'b0;
			end
			else if( !vram_rd_n ) begin
				vram_rdata0		<= { 
					ff_ram[ { vram_address[22:2], 2'd3 } ], 
					ff_ram[ { vram_address[22:2], 2'd2 } ], 
					ff_ram[ { vram_address[22:2], 2'd1 } ], 
					ff_ram[ { vram_address[22:2], 2'd0 } ] };
				vram_rdata_en0	<= 1'b1;
			end
			else begin
				vram_rdata_en0	<= 1'b0;
			end
		end
		else begin
			vram_rdata_en0	<= 1'b0;
		end
	end

	always @( posedge clk ) begin
		vram_rdata_en1 <= vram_rdata_en0;
		vram_rdata_en2 <= vram_rdata_en1;
		vram_rdata_en3 <= vram_rdata_en2;
		vram_rdata_en4 <= vram_rdata_en3;
		vram_rdata_en5 <= vram_rdata_en4;
		vram_rdata_en  <= vram_rdata_en5;

		vram_rdata1 <= vram_rdata0;
		vram_rdata2 <= vram_rdata1;
		vram_rdata3 <= vram_rdata2;
		vram_rdata4 <= vram_rdata3;
		vram_rdata5 <= vram_rdata4;
		vram_rdata  <= vram_rdata5;
	end

	// --------------------------------------------------------------------
	//	task
	// --------------------------------------------------------------------
	task set_palette_address(
		input	[7:0]	palette
	);
		iorq_n	<= 1'b0;
		wr_n	<= 1'b0;
		address	<= 8'h20;
		wdata	<= palette;
		@( posedge clk );

		iorq_n	<= 1'b1;
		wr_n	<= 1'b1;
		@( posedge clk );
	endtask: set_palette_address

	// --------------------------------------------------------------------
	task set_palette_color(
		input	[7:0]	palette_r,
		input	[7:0]	palette_g,
		input	[7:0]	palette_b
	);
		iorq_n	<= 1'b0;
		wr_n	<= 1'b0;
		address	<= 8'h21;
		wdata	<= palette_r;
		@( posedge clk );

		iorq_n	<= 1'b1;
		wr_n	<= 1'b1;
		@( posedge clk );

		iorq_n	<= 1'b0;
		wr_n	<= 1'b0;
		address	<= 8'h21;
		wdata	<= palette_g;
		@( posedge clk );

		iorq_n	<= 1'b1;
		wr_n	<= 1'b1;
		@( posedge clk );

		iorq_n	<= 1'b0;
		wr_n	<= 1'b0;
		address	<= 8'h21;
		wdata	<= palette_b;
		@( posedge clk );

		iorq_n	<= 1'b1;
		wr_n	<= 1'b1;
		@( posedge clk );
	endtask: set_palette_color

	// --------------------------------------------------------------------
	task set_address(
		input	[22:0]	p_address
	);
		iorq_n	<= 1'b0;
		wr_n	<= 1'b0;
		address	<= 8'h22;
		wdata	<= p_address[7:0];
		@( posedge clk );

		iorq_n	<= 1'b1;
		wr_n	<= 1'b1;
		@( posedge clk );

		iorq_n	<= 1'b0;
		wr_n	<= 1'b0;
		address	<= 8'h22;
		wdata	<= p_address[15:8];
		@( posedge clk );

		iorq_n	<= 1'b1;
		wr_n	<= 1'b1;
		@( posedge clk );

		iorq_n	<= 1'b0;
		wr_n	<= 1'b0;
		address	<= 8'h22;
		wdata	<= { 1'b0, p_address[22:16] };
		@( posedge clk );

		iorq_n	<= 1'b1;
		wr_n	<= 1'b1;
		@( posedge clk );
	endtask: set_address

	// --------------------------------------------------------------------
	task set_data(
		input	[7:0]	data
	);
		iorq_n	<= 1'b0;
		wr_n	<= 1'b0;
		address	<= 8'h23;
		wdata	<= data;
		@( posedge clk );

		iorq_n	<= 1'b1;
		wr_n	<= 1'b1;
		@( posedge clk );
	endtask: set_data

	// --------------------------------------------------------------------
	//	Test bench
	// --------------------------------------------------------------------
	initial begin
		reset_n			= 0;
		clk				= 0;
		iorq_n			= 1;
		address			= 0;
		wr_n			= 1;
		wdata			= 0;
		vram_rdata		= 0;
		vram_rdata_en	= 0;

		@( negedge clk );
		@( negedge clk );
		@( posedge clk );

		reset_n				= 1'b1;
		@( posedge clk );
		repeat( 10 ) @( posedge clk );

		// --------------------------------------------------------------------
		//	set palette color
		// --------------------------------------------------------------------
		set_palette_address( 0 );
		for( i = 0; i < 8; i++ ) begin
			for( j = 0; j < 8; j++ ) begin
				for( k = 0; k < 4; k++ ) begin
					set_palette_color( i * 255 / 7, j * 255 / 7, k * 255 / 3 );
				end
			end
		end

		repeat( 10 ) @( posedge clk );

		set_address( 0 );
		for( i = 0; i < 360; i++ ) begin
			for( j = 0; j < 640; j++ ) begin
				set_data( i & 255 );
				repeat( 20 ) @( posedge clk );
			end
		end

		repeat( 100000 ) @( posedge clk );
		$finish;
	end
endmodule
