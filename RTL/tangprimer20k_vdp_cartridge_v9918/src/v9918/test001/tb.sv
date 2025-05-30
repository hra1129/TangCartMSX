// -----------------------------------------------------------------------------
//	Test of v9918
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
	localparam		clk_base	= 1_000_000_000/42_954_540;	//	ps
	localparam		vdp_port0	= 8'h98;
	localparam		vdp_port1	= 8'h99;
	reg						clk;			//	42.95454MHz
	reg						reset_n;
	reg						initial_busy;
	reg			[15:0]		bus_address;
	reg						bus_ioreq;
	reg						bus_write;
	reg						bus_valid;
	reg			[7:0]		bus_wdata;
	wire		[7:0]		bus_rdata;
	wire					bus_rdata_en;
	wire					int_n;
	wire		[13:0]		p_dram_address;
	wire					p_dram_write;
	wire					p_dram_valid;
	wire					p_dram_ready;
	wire		[7:0]		p_dram_wdata;
	wire		[7:0]		p_dram_rdata;
	wire					p_dram_rdata_en;
	wire					p_vdp_enable;
	wire		[5:0]		p_vdp_r;
	wire		[5:0]		p_vdp_g;
	wire		[5:0]		p_vdp_b;
	wire		[10:0]		p_vdp_hcounter;
	wire		[10:0]		p_vdp_vcounter;
	int						i;

	// --------------------------------------------------------------------
	//	DUT
	// --------------------------------------------------------------------
	vdp_inst u_v9918 (
		.clk					( clk					),
		.reset_n				( reset_n				),
		.initial_busy			( initial_busy			),
		.bus_address			( bus_address			),
		.bus_ioreq				( bus_ioreq				),
		.bus_write				( bus_write				),
		.bus_valid				( bus_valid				),
		.bus_wdata				( bus_wdata				),
		.bus_rdata				( bus_rdata				),
		.bus_rdata_en			( bus_rdata_en			),
		.int_n					( int_n					),
		.p_dram_address			( p_dram_address		),
		.p_dram_write			( p_dram_write			),
		.p_dram_valid			( p_dram_valid			),
		.p_dram_ready			( p_dram_ready			),
		.p_dram_wdata			( p_dram_wdata			),
		.p_dram_rdata			( p_dram_rdata			),
		.p_dram_rdata_en		( p_dram_rdata_en		),
		.p_vdp_enable			( p_vdp_enable			),
		.p_vdp_r				( p_vdp_r				),
		.p_vdp_g				( p_vdp_g				),
		.p_vdp_b				( p_vdp_b				),
		.p_vdp_hcounter			( p_vdp_hcounter		),
		.p_vdp_vcounter			( p_vdp_vcounter		)
	);

	ip_ram u_ram (
		.reset_n				( reset_n				),
		.clk					( clk					),
		.bus_address			( p_dram_address		),
		.bus_valid				( p_dram_valid			),
		.bus_ready				( p_dram_ready			),
		.bus_write				( p_dram_write			),
		.bus_wdata				( p_dram_wdata			),
		.bus_rdata				( p_dram_rdata			),
		.bus_rdata_en			( p_dram_rdata_en		)
	);

	// --------------------------------------------------------------------
	//	clock
	// --------------------------------------------------------------------
	always #(clk_base/2) begin
		clk <= ~clk;
	end

	// --------------------------------------------------------------------
	//	tasks
	// --------------------------------------------------------------------
	task write_io(
		input	[7:0]	address,
		input	[7:0]	wdata
	);
		bus_ioreq		<= 1'b1;
		bus_write		<= 1'b1;
		bus_valid		<= 1'b1;
		bus_address		<= { 8'h00, address };
		bus_wdata		<= wdata;
		@( posedge clk );

		bus_ioreq		<= 1'b0;
		bus_write		<= 1'b0;
		bus_valid		<= 1'b0;
		bus_address		<= 16'd0;
		bus_wdata		<= 8'd0;
		repeat( 23 ) @( posedge clk );
	endtask: write_io

	// --------------------------------------------------------------------
	//	Test bench
	// --------------------------------------------------------------------
	initial begin
		clk = 0;			//	42.95454MHz
		reset_n = 0;
		initial_busy = 0;
		bus_address = 0;
		bus_ioreq = 0;
		bus_write = 0;
		bus_valid = 0;
		bus_wdata = 0;

		@( negedge clk );
		@( negedge clk );

		reset_n = 1;
		@( negedge clk );
		repeat( 4 ) @( posedge clk );

		// --------------------------------------------------------------------
		write_io( vdp_port1, 8'h00 );
		write_io( vdp_port1, 8'h80 );

		write_io( vdp_port1, 8'h40 );
		write_io( vdp_port1, 8'h81 );

		for( i = 0; i < 16; i++ ) begin
			write_io( vdp_port1, i );
			write_io( vdp_port1, 8'h87 );
		end
		@( posedge clk );

		for( i = 0; i < 16; i++ ) begin
			write_io( vdp_port1, i );
			write_io( vdp_port1, 8'h87 );
		end
		@( posedge clk );

		// --------------------------------------------------------------------
		write_io( vdp_port1, 8'h00 );
		write_io( vdp_port1, 8'h40 );

		for( i = 0; i < 16384; i++ ) begin
			write_io( vdp_port0, i & 255 );
		end

		repeat( 1368 * 524 ) @( posedge clk );
		$finish;
	end
endmodule
