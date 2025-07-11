// -----------------------------------------------------------------------------
//	Test of vdp_inst.v
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
	localparam		clk_base		= 1_000_000_000/42_954_540;	//	ps
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

	wire		[16:0]		p_dram_address;
	wire					p_dram_write;
	wire					p_dram_valid;
	wire		[7:0]		p_dram_wdata;
	wire		[31:0]		p_dram_rdata;
	wire					p_dram_rdata_en;

	wire					p_vdp_enable;
	wire		[5:0]		p_vdp_r;
	wire		[5:0]		p_vdp_g;
	wire		[5:0]		p_vdp_b;
	wire		[10:0]		p_vdp_hcounter;
	wire		[10:0]		p_vdp_vcounter;

	reg			[31:0]		ff_rdata0;
	reg			[31:0]		ff_rdata1;
	reg			[31:0]		ff_rdata2;
	reg			[31:0]		ff_rdata3;
	reg						ff_rdata_en0;
	reg						ff_rdata_en1;
	reg						ff_rdata_en2;
	reg						ff_rdata_en3;

	// --------------------------------------------------------------------
	//	DUT
	// --------------------------------------------------------------------
	vdp_inst u_vdp (
		.clk,
		.reset_n,
		.initial_busy,
		.bus_address,
		.bus_ioreq,
		.bus_write,
		.bus_valid,
		.bus_wdata,
		.bus_rdata,
		.bus_rdata_en,
		.int_n,
		.p_dram_address,
		.p_dram_write,
		.p_dram_valid,
		.p_dram_wdata,
		.p_dram_rdata,
		.p_dram_rdata_en,
		.p_vdp_enable,
		.p_vdp_r,
		.p_vdp_g,
		.p_vdp_b,
		.p_vdp_hcounter,
		.p_vdp_vcounter
	);

	// --------------------------------------------------------------------
	//	clock
	// --------------------------------------------------------------------
	always #(clk_base/2) begin
		clk <= ~clk;
	end

	always @( posedge clk ) begin
		if( p_dram_valid && !p_dram_write ) begin
			case( p_dram_address[16:2] )
			15'h0000:	ff_rdata0 <= { 8'b00111111, 8'b00011111, 8'b00001111, 8'b00000011 };
			15'h0001:	ff_rdata0 <= { 8'b11111111, 8'b11111111, 8'b01111111, 8'b01111111 };
			15'h0002:	ff_rdata0 <= { 8'b01111111, 8'b01111111, 8'b11111111, 8'b11111111 };
			15'h0003:	ff_rdata0 <= { 8'b00000011, 8'b00001111, 8'b00011111, 8'b00111111 };
			15'h0004:	ff_rdata0 <= { 8'b11111100, 8'b11111000, 8'b11110000, 8'b11000000 };
			15'h0005:	ff_rdata0 <= { 8'b11111111, 8'b11111111, 8'b11111110, 8'b11111110 };
			15'h0006:	ff_rdata0 <= { 8'b11111110, 8'b11111110, 8'b11111111, 8'b11111111 };
			15'h0007:	ff_rdata0 <= { 8'b11000000, 8'b11110000, 8'b11111000, 8'b11111100 };
			15'h0600:	ff_rdata0 <= { 8'd15, 8'd0, 8'd50, 8'd20 };		//	{ Color, Pattern, X, Y }
			default:	ff_rdata0 <= 32'd0;
			endcase
		end
		ff_rdata1		<= ff_rdata0;
		ff_rdata2		<= ff_rdata1;
		ff_rdata3		<= ff_rdata2;
		ff_rdata_en0	<= p_dram_valid && !p_dram_write;
		ff_rdata_en1	<= ff_rdata_en0;
		ff_rdata_en2	<= ff_rdata_en1;
		ff_rdata_en3	<= ff_rdata_en2;
	end

	assign p_dram_rdata		= { 24'd0, ff_rdata3 };
	assign p_dram_rdata_en	= ff_rdata_en3;

	task write_io(
		input	[7:0]	address,
		input	[7:0]	wdata
	);
		bus_address		<= { 8'd0, address };
		bus_wdata		<= wdata;
		bus_write		<= 1'b1;
		bus_valid		<= 1'b1;
		@( posedge clk );

		bus_write		<= 1'b0;
		bus_valid		<= 1'b0;
		@( posedge clk );
	endtask: write_io

	// --------------------------------------------------------------------
	//	Test bench
	// --------------------------------------------------------------------
	initial begin
		clk = 0;
		reset_n = 0;
		initial_busy = 0;
		bus_address = 0;
		bus_ioreq = 0;
		bus_write = 0;
		bus_valid = 0;
		bus_wdata = 0;

		@( posedge clk );
		@( posedge clk );
		@( posedge clk );
		reset_n <= 1;
		@( posedge clk );

		//	R#0 = 0 (SCREEN1)
		write_io( 8'h99, 8'h00 );
		write_io( 8'h99, 8'h80 );
		//	R#1 = 0 (SCREEN1)
		write_io( 8'h99, 8'h02 );
		write_io( 8'h99, 8'h81 );
		//	R#5 = 0
		write_io( 8'h99, 8'b0011_0000 );
		write_io( 8'h99, 8'h85 );
		//	R#11 = 0
		write_io( 8'h99, 8'h00 );
		write_io( 8'h99, 8'h8B );

		repeat( 1368 * 600 ) @( posedge clk );

		repeat( 10 ) @( posedge clk );
		$finish;
	end
endmodule
