// -----------------------------------------------------------------------------
//	Test of msx_slot.v
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
	reg				clk42m;
	reg				reset_n;
	reg				initial_busy;
	reg				p_slot_reset_n;
	reg				p_slot_sltsl_n;
	reg				p_slot_mreq_n;
	reg				p_slot_ioreq_n;
	reg				p_slot_wr_n;
	reg				p_slot_rd_n;
	reg		[15:0]	p_slot_address;
	wire	[7:0]	p_slot_data;
	reg		[7:0]	ff_slot_data;
	wire			p_slot_data_dir;
	wire			p_slot_int;
	wire			p_slot_wait;
	reg				int_n;
	wire			bus_memreq;
	wire			bus_ioreq;
	wire	[15:0]	bus_address;
	wire			bus_write;
	wire			bus_valid;
	reg				bus_ready;
	wire	[7:0]	bus_wdata;
	reg		[7:0]	bus_rdata;
	reg				bus_rdata_en;

	// --------------------------------------------------------------------
	//	DUT
	// --------------------------------------------------------------------
	msx_slot u_msx_slot (
		.clk42m					( clk42m				),
		.reset_n				( reset_n				),
		.initial_busy			( initial_busy			),
		.p_slot_reset_n			( p_slot_reset_n		),
		.p_slot_sltsl_n			( p_slot_sltsl_n		),
		.p_slot_mreq_n			( p_slot_mreq_n			),
		.p_slot_ioreq_n			( p_slot_ioreq_n		),
		.p_slot_wr_n			( p_slot_wr_n			),
		.p_slot_rd_n			( p_slot_rd_n			),
		.p_slot_address			( p_slot_address		),
		.p_slot_data			( p_slot_data			),
		.p_slot_data_dir		( p_slot_data_dir		),
		.p_slot_int				( p_slot_int			),
		.p_slot_wait			( p_slot_wait			),
		.int_n					( int_n					),
		.bus_memreq				( bus_memreq			),
		.bus_ioreq				( bus_ioreq				),
		.bus_address			( bus_address			),
		.bus_write				( bus_write				),
		.bus_valid				( bus_valid				),
		.bus_ready				( bus_ready				),
		.bus_wdata				( bus_wdata				),
		.bus_rdata				( bus_rdata				),
		.bus_rdata_en			( bus_rdata_en			)
	);

	assign p_slot_data	= (p_slot_data_dir == 1'b1) ? 8'hZZ: ff_slot_data;

	// --------------------------------------------------------------------
	//	clock
	// --------------------------------------------------------------------
	always #(clk_base/2) begin
		clk42m <= ~clk42m;
	end

	// --------------------------------------------------------------------
	//	tasks
	// --------------------------------------------------------------------
	task write_io(
		input	[15:0]	address,
		input	[7:0]	wdata
	);
		p_slot_sltsl_n	<= 1'b1;
		p_slot_mreq_n	<= 1'b1;
		p_slot_ioreq_n	<= 1'b0;
		p_slot_wr_n		<= 1'b0;
		p_slot_rd_n		<= 1'b1;
		p_slot_address	<= address;
		ff_slot_data	<= wdata;
		repeat( 4 ) @( posedge clk42m );
		assert( bus_valid );
		assert( bus_address == address );
		assert( bus_wdata == wdata );
		assert( bus_write == 1'b1 );
		bus_ready		<= 1'b1;
		@( posedge clk42m );
		bus_ready		<= 1'b0;
		repeat( 19 ) @( posedge clk42m );

		p_slot_sltsl_n	<= 1'b1;
		p_slot_mreq_n	<= 1'b1;
		p_slot_ioreq_n	<= 1'b1;
		p_slot_wr_n		<= 1'b1;
		p_slot_rd_n		<= 1'b1;
		p_slot_address	<= 15'd0;
		ff_slot_data	<= 8'd0;
		repeat( 4 ) @( posedge clk42m );
	endtask: write_io

	// --------------------------------------------------------------------
	task write_mem(
		input	[15:0]	address,
		input	[7:0]	wdata
	);
		p_slot_sltsl_n	<= 1'b0;
		p_slot_mreq_n	<= 1'b0;
		p_slot_ioreq_n	<= 1'b1;
		p_slot_wr_n		<= 1'b0;
		p_slot_rd_n		<= 1'b1;
		p_slot_address	<= address;
		ff_slot_data	<= wdata;
		repeat( 4 ) @( posedge clk42m );
		assert( bus_valid );
		assert( bus_address == address );
		assert( bus_wdata == wdata );
		assert( bus_write == 1'b1 );
		bus_ready		<= 1'b1;
		@( posedge clk42m );
		bus_ready		<= 1'b0;
		repeat( 19 ) @( posedge clk42m );

		p_slot_sltsl_n	<= 1'b1;
		p_slot_mreq_n	<= 1'b1;
		p_slot_ioreq_n	<= 1'b1;
		p_slot_wr_n		<= 1'b1;
		p_slot_rd_n		<= 1'b1;
		p_slot_address	<= 15'd0;
		ff_slot_data	<= 8'd0;
		repeat( 4 ) @( posedge clk42m );
	endtask: write_mem

	// --------------------------------------------------------------------
	task write_mem_invalid(
		input	[15:0]	address,
		input	[7:0]	wdata
	);
		p_slot_sltsl_n	<= 1'b1;
		p_slot_mreq_n	<= 1'b0;
		p_slot_ioreq_n	<= 1'b1;
		p_slot_wr_n		<= 1'b0;
		p_slot_rd_n		<= 1'b1;
		p_slot_address	<= address;
		ff_slot_data	<= wdata;
		repeat( 4 ) @( posedge clk42m );
		assert( !bus_valid );
		bus_ready		<= 1'b1;
		@( posedge clk42m );
		bus_ready		<= 1'b0;
		repeat( 19 ) @( posedge clk42m );

		p_slot_sltsl_n	<= 1'b1;
		p_slot_mreq_n	<= 1'b1;
		p_slot_ioreq_n	<= 1'b1;
		p_slot_wr_n		<= 1'b1;
		p_slot_rd_n		<= 1'b1;
		p_slot_address	<= 15'd0;
		ff_slot_data	<= 8'd0;
		repeat( 4 ) @( posedge clk42m );
	endtask: write_mem_invalid

	// --------------------------------------------------------------------
	task read_io(
		input	[15:0]	address,
		input	[7:0]	rdata
	);
		p_slot_sltsl_n	<= 1'b1;
		p_slot_mreq_n	<= 1'b1;
		p_slot_ioreq_n	<= 1'b0;
		p_slot_wr_n		<= 1'b1;
		p_slot_rd_n		<= 1'b0;
		p_slot_address	<= address;
		repeat( 4 ) @( posedge clk42m );
		assert( bus_valid );
		assert( bus_address == address );
		assert( bus_write == 1'b0 );
		bus_ready		<= 1'b1;
		@( posedge clk42m );
		bus_ready		<= 1'b0;
		repeat( 10 ) @( posedge clk42m );

		bus_rdata		<= rdata;
		bus_rdata_en	<= 1'b1;
		@( posedge clk42m );

		bus_rdata		<= 8'hXX;
		bus_rdata_en	<= 1'b0;
		repeat( 4 ) @( posedge clk42m );

		assert( p_slot_data == rdata );
		repeat( 4 ) @( posedge clk42m );

		p_slot_sltsl_n	<= 1'b1;
		p_slot_mreq_n	<= 1'b1;
		p_slot_ioreq_n	<= 1'b1;
		p_slot_wr_n		<= 1'b1;
		p_slot_rd_n		<= 1'b1;
		p_slot_address	<= 15'd0;
		repeat( 4 ) @( posedge clk42m );
	endtask: read_io

	// --------------------------------------------------------------------
	task read_mem(
		input	[15:0]	address,
		input	[7:0]	rdata
	);
		p_slot_sltsl_n	<= 1'b0;
		p_slot_mreq_n	<= 1'b0;
		p_slot_ioreq_n	<= 1'b1;
		p_slot_wr_n		<= 1'b1;
		p_slot_rd_n		<= 1'b0;
		p_slot_address	<= address;
		repeat( 4 ) @( posedge clk42m );
		assert( bus_valid );
		assert( bus_address == address );
		assert( bus_write == 1'b0 );
		bus_ready		<= 1'b1;
		@( posedge clk42m );
		bus_ready		<= 1'b0;
		repeat( 10 ) @( posedge clk42m );

		bus_rdata		<= rdata;
		bus_rdata_en	<= 1'b1;
		@( posedge clk42m );

		bus_rdata		<= 8'hXX;
		bus_rdata_en	<= 1'b0;
		repeat( 4 ) @( posedge clk42m );

		assert( p_slot_data == rdata );
		repeat( 4 ) @( posedge clk42m );

		p_slot_sltsl_n	<= 1'b1;
		p_slot_mreq_n	<= 1'b1;
		p_slot_ioreq_n	<= 1'b1;
		p_slot_wr_n		<= 1'b1;
		p_slot_rd_n		<= 1'b1;
		p_slot_address	<= 15'd0;
		repeat( 4 ) @( posedge clk42m );
	endtask: read_mem

	// --------------------------------------------------------------------
	task read_mem_invalid(
		input	[15:0]	address,
		input	[7:0]	rdata
	);
		p_slot_sltsl_n	<= 1'b1;
		p_slot_mreq_n	<= 1'b0;
		p_slot_ioreq_n	<= 1'b1;
		p_slot_wr_n		<= 1'b1;
		p_slot_rd_n		<= 1'b0;
		p_slot_address	<= address;
		repeat( 4 ) @( posedge clk42m );
		assert( !bus_valid );
		bus_ready		<= 1'b1;
		@( posedge clk42m );
		bus_ready		<= 1'b0;
		repeat( 10 ) @( posedge clk42m );
		@( posedge clk42m );
		repeat( 4 ) @( posedge clk42m );
		repeat( 4 ) @( posedge clk42m );

		p_slot_sltsl_n	<= 1'b1;
		p_slot_mreq_n	<= 1'b1;
		p_slot_ioreq_n	<= 1'b1;
		p_slot_wr_n		<= 1'b1;
		p_slot_rd_n		<= 1'b1;
		p_slot_address	<= 15'd0;
		repeat( 4 ) @( posedge clk42m );
	endtask: read_mem_invalid

	// --------------------------------------------------------------------
	//	Test bench
	// --------------------------------------------------------------------
	initial begin
		clk42m				= 0;			//	42.95454MHz
		initial_busy		= 0;
		p_slot_reset_n		= 0;
		p_slot_sltsl_n		= 1;
		p_slot_mreq_n		= 1;
		p_slot_ioreq_n		= 1;
		p_slot_wr_n			= 1;
		p_slot_rd_n			= 1;
		p_slot_address		= 0;
		bus_ready			= 0;
		bus_rdata			= 0;
		bus_rdata_en		= 0;
		int_n				= 1;

		@( negedge clk42m );
		@( negedge clk42m );

		p_slot_reset_n		= 1;
		@( posedge clk42m );
		@( posedge clk42m );

		// --------------------------------------------------------------------
		write_io( 16'h98, 8'h12 );
		write_io( 16'h89, 8'h23 );
		write_io( 16'h78, 8'h34 );
		write_io( 16'h67, 8'h45 );
		write_io( 16'h56, 8'h56 );
		write_io( 16'h45, 8'h67 );

		write_mem( 16'h1234, 8'h12 );
		write_mem( 16'h2345, 8'h23 );
		write_mem( 16'h3456, 8'h34 );
		write_mem( 16'h4567, 8'h45 );
		write_mem( 16'h89AB, 8'h56 );
		write_mem( 16'hCDEF, 8'h67 );

		read_io( 16'h98, 8'h12 );
		read_io( 16'h89, 8'h23 );
		read_io( 16'h78, 8'h34 );
		read_io( 16'h67, 8'h45 );
		read_io( 16'h56, 8'h56 );
		read_io( 16'h45, 8'h67 );

		read_mem( 16'h1234, 8'h12 );
		read_mem( 16'h2345, 8'h23 );
		read_mem( 16'h3456, 8'h34 );
		read_mem( 16'h4567, 8'h45 );
		read_mem( 16'h89AB, 8'h56 );
		read_mem( 16'hCDEF, 8'h67 );

		write_mem_invalid( 16'h1234, 8'h12 );
		write_mem_invalid( 16'h2345, 8'h23 );
		write_mem_invalid( 16'h3456, 8'h34 );
		write_mem_invalid( 16'h4567, 8'h45 );
		write_mem_invalid( 16'h89AB, 8'h56 );
		write_mem_invalid( 16'hCDEF, 8'h67 );

		read_mem_invalid( 16'h1234, 8'h12 );
		read_mem_invalid( 16'h2345, 8'h23 );
		read_mem_invalid( 16'h3456, 8'h34 );
		read_mem_invalid( 16'h4567, 8'h45 );
		read_mem_invalid( 16'h89AB, 8'h56 );
		read_mem_invalid( 16'hCDEF, 8'h67 );

		repeat( 10 ) @( posedge clk42m );
		$finish;
	end
endmodule
