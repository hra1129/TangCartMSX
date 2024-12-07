//
//	vdp_inst.v
//	 FPGA9958 top entity
//
//	Copyright (C) 2024 Takayuki Hara
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

module vdp_inst(
	input					clk,			//	85.90908MHz
	output		[1:0]		enable_state,	//	00, 01, 10, 11, 00, ...
	input					reset_n,
	input					initial_busy,
	input					iorq_n,
	input					wr_n,
	input					rd_n,
	input		[1:0]		address,
	output		[7:0]		rdata,
	output					rdata_en,
	input		[7:0]		wdata,

	output					int_n,

	output					p_dram_oe_n,
	output					p_dram_we_n,
	output		[16:0]		p_dram_address,
	input		[15:0]		p_dram_rdata,
	output		[7:0]		p_dram_wdata,

	// video output
	output					pvideo_clk,
	output					pvideo_data_en,

	output		[5:0]		pvideor,
	output		[5:0]		pvideog,
	output		[5:0]		pvideob,

	output					pvideohs_n,
	output					pvideovs_n,

	output					p_video_dh_clk,
	output					p_video_dl_clk
);
//	localparam		c_vdpid			= 5'b00001;		// V9938
	localparam		c_vdpid			= 5'b00010;		// V9958

	reg				ff_initial_busy;
	reg				ff_enable;
	reg		[1:0]	ff_enable_cnt;

	//--------------------------------------------------------------
	// wait
	//--------------------------------------------------------------
	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_initial_busy <= 1'b1;
		end
		else if( !initial_busy ) begin
			ff_initial_busy <= 1'b0;
		end
		else begin
			// hold
		end
	end

	//--------------------------------------------------------------
	// clock divider
	//--------------------------------------------------------------
	always @( posedge clk ) begin
		if( !reset_n || ff_initial_busy ) begin
			ff_enable_cnt	<= 2'b00;
		end
		else begin
			ff_enable_cnt	<= ff_enable_cnt + 2'b01;
		end
	end

	always @( posedge clk ) begin
		if( !reset_n || ff_initial_busy ) begin
			ff_enable			<= 1'b0;
		end
		else begin
			if( ff_enable_cnt == 2'b11 ) begin
				ff_enable		<= 1'b1;
			end
			else begin
				ff_enable		<= 1'b0;
			end
		end
	end

	assign enable_state		= ff_enable_cnt;

	vdp u_v9958_core (
		.reset				( !reset_n					),	// IN	
		.initial_busy		( ff_initial_busy			),	// IN	
		.clk				( clk						),	// IN	
		.enable				( ff_enable					),	// OUT	
		.iorq_n				( iorq_n					),	// IN	
		.wr_n				( wr_n						),	// IN	
		.rd_n				( rd_n						),	// IN	
		.address			( address					),	// IN	[ 1: 0 ];
		.rdata				( rdata						),	// OUT	[ 7: 0 ];
		.rdata_en			( rdata_en					),	// OUT
		.wdata				( wdata						),	// IN	[ 7: 0 ];
		.int_n				( int_n						),	// OUT	
		.p_dram_oe_n		( p_dram_oe_n				),	// OUT	
		.p_dram_we_n		( p_dram_we_n				),	// OUT	
		.p_dram_address		( p_dram_address			),	// OUT	[16: 0 ];
		.p_dram_rdata		( p_dram_rdata				),	// IN	[15: 0 ];
		.p_dram_wdata		( p_dram_wdata				),	// OUT	[ 7: 0 ];
		.vdp_speed_mode		( 1'b0						),	// IN	
		.ratio_mode			( 3'b000					),	// IN	[ 2: 0 ];
		.centeryjk_r25_n	( 1'b1						),	// IN	
		.pvideo_clk			( pvideo_clk				),	// OUT	
		.pvideo_data_en		( pvideo_data_en			),	// OUT	
		.pvideor			( pvideor					),	// OUT	[ 5: 0 ];
		.pvideog			( pvideog					),	// OUT	[ 5: 0 ];
		.pvideob			( pvideob					),	// OUT	[ 5: 0 ];
		.pvideohs_n			( pvideohs_n				),	// OUT	
		.pvideovs_n			( pvideovs_n				),	// OUT	
		.p_video_dh_clk		( p_video_dh_clk			),	// OUT	
		.p_video_dl_clk		( p_video_dl_clk			),	// OUT	
		.dispreso			( 1'b1						),	// IN	
		.legacy_vga			( 1'b0						),	// IN	
		.vdp_id				( c_vdpid					)	// IN	[ 4: 0 ];
    );
endmodule
