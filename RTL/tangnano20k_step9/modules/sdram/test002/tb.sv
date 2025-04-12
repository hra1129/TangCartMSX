// -----------------------------------------------------------------------------
//	Test of ip_sdram.v
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
	reg				n_reset;
	reg				clk;				// 108MHz
	reg				clk_sdram;			// 108MHz with 180dgree delay
	wire			rd;					// Set to 1 to read
	wire			wr;					// Set to 1 to write
	wire			busy;
	wire	[22:0]	address;			// Byte address (8MBytes)
	wire	[7:0]	wdata;
	wire	[15:0]	rdata;
	wire			rdata_en;
	wire			O_sdram_clk;
	wire			O_sdram_cke;
	wire			O_sdram_cs_n;		// chip select
	wire			O_sdram_cas_n;		// columns address select
	wire			O_sdram_ras_n;		// row address select
	wire			O_sdram_wen_n;		// write enable
	wire	[31:0]	IO_sdram_dq;		// 32 bit bidirectional data bus
	wire	[10:0]	O_sdram_addr;		// 11 bit multiplexed address bus
	wire	[1:0]	O_sdram_ba;			// two banks
	wire	[3:0]	O_sdram_dqm;		// data mask
	reg		[1:0]	ff_keys;
	wire	[7:0]	send_data;
	wire			send_req;
	wire			send_busy;
	wire			w_uart_tx;

	// --------------------------------------------------------------------
	//	DUT
	// --------------------------------------------------------------------
	ip_debugger #(
		.TEST_ROWS			( 15'b000_0000_1111_1111)
	) u_debugger (
		.n_reset			( n_reset				),
		.clk				( clk					),
		.send_data			( send_data				),
		.send_req			( send_req				),
		.send_busy			( send_busy				),
		.keys				( ff_keys				),
		.sdram_rd			( rd					),
		.sdram_wr			( wr					),
		.sdram_busy			( busy					),
		.sdram_address		( address				),
		.sdram_wdata		( wdata					),
		.sdram_rdata		( rdata[7:0]			),
		.sdram_rdata_en		( rdata_en				)
	);

	ip_uart #(
		.clk_freq			( 108000000				),
		.uart_freq			( 115200				)
	) u_uart (
		.n_reset			( n_reset				),
		.clk				( clk					),
		.send_data			( send_data				),
		.send_req			( send_req				),
		.send_busy			( send_busy				),
		.uart_tx			( w_uart_tx				)
	);

	ip_sdram u_sdram_controller (
		.n_reset			( n_reset				),
		.clk				( clk					),
		.clk_sdram			( clk_sdram				),
		.rd_n				( !rd					),
		.wr_n				( !wr					),
		.busy				( busy					),
		.address			( address				),
		.wdata				( wdata					),
		.rdata				( rdata					),
		.rdata_en			( rdata_en				),
		.O_sdram_clk		( O_sdram_clk			),
		.O_sdram_cke		( O_sdram_cke			),
		.O_sdram_cs_n		( O_sdram_cs_n			),
		.O_sdram_cas_n		( O_sdram_cas_n			),
		.O_sdram_ras_n		( O_sdram_ras_n			),
		.O_sdram_wen_n		( O_sdram_wen_n			),
		.IO_sdram_dq		( IO_sdram_dq			),
		.O_sdram_addr		( O_sdram_addr			),
		.O_sdram_ba			( O_sdram_ba			),
		.O_sdram_dqm		( O_sdram_dqm			)
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

	// --------------------------------------------------------------------
	//	Test bench
	// --------------------------------------------------------------------
	initial begin
		n_reset = 0;
		clk = 0;
		clk_sdram = 1;
		ff_keys = 0;

		@( negedge clk );
		@( negedge clk );
		@( posedge clk );

		n_reset			= 1;
		repeat( 10 ) @( posedge clk );

		ff_keys <= 2'b01;
		@( posedge clk );

		ff_keys <= 2'b00;
		@( posedge clk );

		repeat( 2500000 ) @( posedge clk );

		$finish;
	end
endmodule
