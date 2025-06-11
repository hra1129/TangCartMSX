//
// ip_sdram.v
//
//	Copyright (C) 2025 Takayuki Hara
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
//-----------------------------------------------------------------------------

module ip_sdram (
	input				reset_n,
	input				clk,				//	50MHz
	input				memory_clk,			//	171.81816MHz
	output				clk_out,			//	42.95454MHz
	input				pll_lock,
	output				sdram_init_busy,	//	0: Normal, 1: Busy

	input	[26:0]		bus_address,		//	64Mword/16bit: [26:24]=BANK, [23:10]=ROW, [9:0]=COLUMN
	input				bus_write,			//	Direction 0: Read, 1: Write
	input				bus_valid,			//
	output				bus_ready,			//	0: Busy, 1: Ready
	input	[127:0]		bus_wdata,
	input	[15:0]		bus_wdata_mask,
	output	[127:0]		bus_rdata,
	output				bus_rdata_en,

	input				refresh_req,
	output				refresh_ack,

	// DDR3-SDRAM ports
	output				ddr3_rst_n,
	output				ddr3_clk,
	output				ddr3_clk_n,
	output				ddr3_cke,
	output				ddr3_cs_n,			// chip select
	output				ddr3_ras_n,			// row address select
	output				ddr3_cas_n,			// columns address select
	output				ddr3_we_n,			// write enable
	inout	[15:0]		ddr3_dq,			// 32 bit bidirectional data bus
	output	[13:0]		ddr3_addr,			// 14 bit multiplexed address bus
	output	[ 2:0]		ddr3_ba,			// eight banks
	inout	[ 1:0]		ddr3_dm_tdqs,		// data mask
	inout	[ 1:0]		ddr3_dqs,			// 
	inout	[ 1:0]		ddr3_dqs_n,			// 
	output				ddr3_odt
);
	localparam	[2:0]	cmd_write		= 3'b000;
	localparam	[2:0]	cmd_read		= 3'b001;
	wire				clk42m;
	wire				w_init_complete;
	wire				w_wr_data_ready;
	wire				w_cmd_ready;
	wire		[2:0]	w_cmd;
	wire				w_write;
	wire				w_cmd_en;
	wire				w_dram_valid;
	wire		[127:0]	w_rdata;
	wire				w_rdata_en;
	reg			[127:0]	ff_rdata;
	reg					ff_rdata_en;

	always @( posedge clk42m ) begin
		if( !reset_n ) begin
			ff_rdata	<= 128'd0;
			ff_rdata_en	<= 1'b0;
		end
		else if( w_rdata_en ) begin
			ff_rdata	<= w_rdata;
			ff_rdata_en	<= w_rdata_en;
		end
		else begin
			ff_rdata	<= 128'd0;
			ff_rdata_en	<= 1'b0;
		end
	end

	assign clk_out				= clk42m;
	assign w_dram_valid			= bus_valid;
	assign bus_ready			= w_cmd_ready & w_wr_data_ready;
	assign w_cmd_en				= w_cmd_ready & w_wr_data_ready & w_dram_valid;
	assign sdram_init_busy		= ~w_init_complete;
	assign w_cmd				= bus_write ? cmd_write : cmd_read;
	assign w_write				= w_cmd_en & bus_write;

	assign bus_rdata			= ff_rdata;
	assign bus_rdata_en			= ff_rdata_en;

	DDR3_Memory_Interface_Top u_ddr3_controller (
		.clk					( clk					),		//	input clk						50MHz
		.memory_clk				( memory_clk			),		//	input memory_clk				171.81816MHz
		.pll_lock				( pll_lock				),		//	input pll_lock					
		.rst_n					( reset_n				),		//	input rst_n						
		.clk_out				( clk42m				),		//	output clk_out					42.95454MHz
		.ddr_rst				( 						),		//	output ddr_rst					
		.init_calib_complete	( w_init_complete		),		//	output init_calib_complete		初期化が完了すると 1 になる
		.cmd_ready				( w_cmd_ready			),		//	output cmd_ready				0: busy, 1: ready
		.cmd					( w_cmd					),		//	input [2:0] cmd					コマンドコード
		.cmd_en					( w_cmd_en				),		//	input cmd_en					0: NOP, 1: コマンド有効
		.addr					( { 1'b0, bus_address }	),		//	input [27:0] addr				
		.wr_data_rdy			( w_wr_data_ready		),		//	output wr_data_rdy				
		.wr_data				( bus_wdata				),		//	input [127:0] wr_data			
		.wr_data_en				( w_write				),		//	input wr_data_en				
		.wr_data_end			( w_write				),		//	input wr_data_end				
		.wr_data_mask			( bus_wdata_mask		),		//	input [15:0] wr_data_mask		各ビットが 1byte に対応するデータマスク 0:無効, 1:有効
		.rd_data				( w_rdata				),		//	output [127:0] rd_data			
		.rd_data_valid			( w_rdata_en			),		//	output rd_data_valid			
		.rd_data_end			( 						),		//	output rd_data_end				
		.sr_req					( 1'b0					),		//	input sr_req					セルフリフレッシュ要求
		.ref_req				( refresh_req			),		//	input ref_req					ユーザーリフレッシュ要求
		.sr_ack					( 						),		//	output sr_ack					セルフリフレッシュ応答
		.ref_ack				( refresh_ack			),		//	output ref_ack					ユーザーリフレッシュ応答
		.burst					( 1'b1					),		//	input burst						0: BC4, 1: BL8
		.O_ddr_addr				( ddr3_addr				),		//	output [13:0] O_ddr_addr		DDR3へ繋ぐ信号
		.O_ddr_ba				( ddr3_ba				),		//	output [2:0] O_ddr_ba			DDR3へ繋ぐ信号
		.O_ddr_cs_n				( ddr3_cs_n				),		//	output O_ddr_cs_n				DDR3へ繋ぐ信号
		.O_ddr_ras_n			( ddr3_ras_n			),		//	output O_ddr_ras_n				DDR3へ繋ぐ信号
		.O_ddr_cas_n			( ddr3_cas_n			),		//	output O_ddr_cas_n				DDR3へ繋ぐ信号
		.O_ddr_we_n				( ddr3_we_n				),		//	output O_ddr_we_n				DDR3へ繋ぐ信号
		.O_ddr_clk				( ddr3_clk				),		//	output O_ddr_clk				DDR3へ繋ぐ信号
		.O_ddr_clk_n			( ddr3_clk_n			),		//	output O_ddr_clk_n				DDR3へ繋ぐ信号
		.O_ddr_cke				( ddr3_cke				),		//	output O_ddr_cke				DDR3へ繋ぐ信号
		.O_ddr_odt				( ddr3_odt				),		//	output O_ddr_odt				DDR3へ繋ぐ信号
		.O_ddr_reset_n			( ddr3_rst_n			),		//	output O_ddr_reset_n			DDR3へ繋ぐ信号
		.O_ddr_dqm				( ddr3_dm_tdqs			),		//	output [1:0] O_ddr_dqm			DDR3へ繋ぐ信号
		.IO_ddr_dq				( ddr3_dq				),		//	inout [15:0] IO_ddr_dq			DDR3へ繋ぐ信号
		.IO_ddr_dqs				( ddr3_dqs				),		//	inout [1:0] IO_ddr_dqs			DDR3へ繋ぐ信号
		.IO_ddr_dqs_n			( ddr3_dqs_n			)		//	inout [1:0] IO_ddr_dqs_n		DDR3へ繋ぐ信号
	);
endmodule
