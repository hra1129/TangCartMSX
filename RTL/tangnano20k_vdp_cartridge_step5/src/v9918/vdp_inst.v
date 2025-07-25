//
//	vdp_inst.v
//	 FPGA9918 top entity
//
//	Copyright (C) 2024-2025 Takayuki Hara
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
	input					clk,			//	42.95454MHz
	input					reset_n,
	input					initial_busy,
	input		[15:0]		bus_address,
	input					bus_ioreq,
	input					bus_write,
	input					bus_valid,
	input		[7:0]		bus_wdata,
	output		[7:0]		bus_rdata,
	output					bus_rdata_en,

	output					int_n,

	output		[13:0]		p_dram_address,
	output					p_dram_write,
	output					p_dram_valid,
	input					p_dram_ready,
	output		[7:0]		p_dram_wdata,
	input		[7:0]		p_dram_rdata,
	input					p_dram_rdata_en,

	// video output
	output					p_vdp_enable,
	output		[5:0]		p_vdp_r,
	output		[5:0]		p_vdp_g,
	output		[5:0]		p_vdp_b,
	output		[10:0]		p_vdp_hcounter,
	output		[10:0]		p_vdp_vcounter
);
	reg				ff_initial_busy;
	reg				ff_enable;
	reg				ff_write;
	reg		[13:0]	ff_address;
	reg		[7:0]	ff_wdata;
	reg				ff_valid;
	reg		[7:0]	ff_rdata;
	wire			w_dram_oe_n;
	wire			w_dram_we_n;
	wire	[13:0]	w_dram_address;
	wire	[7:0]	w_dram_wdata;
	wire			w_ioreq;

	assign w_ioreq	= ( { bus_address[7:1], 1'b0 } == 8'h98 );
//	assign w_ioreq	= ( { bus_address[7:1], 1'b0 } == 8'h88 );

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
			ff_enable	<= 1'b0;
		end
		else begin
			ff_enable	<= ~ff_enable;
		end
	end

	assign p_vdp_enable	= ff_enable;

	//--------------------------------------------------------------
	// VRAM access
	//--------------------------------------------------------------
	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_address <= 14'd0;
			ff_write <= 1'b0;
			ff_valid <= 1'b0;
			ff_wdata <= 8'd0;
		end
		else if( ff_valid ) begin
			if( p_dram_ready ) begin
				ff_valid <= 1'b0;
			end
			else begin
				//	hold
			end
		end
		else if( !w_dram_oe_n ) begin
			ff_address	<= w_dram_address;
			ff_write	<= 1'b0;
			ff_valid	<= 1'b1;
		end
		else if( !w_dram_we_n ) begin
			ff_address	<= w_dram_address;
			ff_write	<= 1'b1;
			ff_valid	<= 1'b1;
			ff_wdata	<= w_dram_wdata;
		end
		else begin
			//	hold
		end
	end

	assign p_dram_address	= ff_address;
	assign p_dram_write		= ff_write;
	assign p_dram_valid		= ff_valid;
	assign p_dram_wdata		= ff_wdata;

	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_rdata <= 8'd0;
		end
		else if( p_dram_rdata_en ) begin
			ff_rdata <= p_dram_rdata;
		end
	end

	//--------------------------------------------------------------
	// VDP core
	//--------------------------------------------------------------
	vdp u_v9918_core (
		.reset				( ~reset_n					),	// IN	
		.initial_busy		( ff_initial_busy			),	// IN	
		.clk				( clk						),	// IN	
		.enable				( ff_enable					),	// OUT	
		.bus_address		( bus_address[0]			),	// IN	
		.bus_ioreq			( w_ioreq					),	// IN	
		.bus_write			( bus_write					),	// IN	
		.bus_valid			( bus_valid					),	// IN	
		.bus_wdata			( bus_wdata					),	// IN	[ 7: 0 ];
		.bus_rdata			( bus_rdata					),	// OUT	[ 7: 0 ];
		.bus_rdata_en		( bus_rdata_en				),	// OUT
		.int_n				( int_n						),	// OUT	
		.p_dram_oe_n		( w_dram_oe_n				),	// OUT	
		.p_dram_we_n		( w_dram_we_n				),	// OUT	
		.p_dram_address		( w_dram_address			),	// OUT	[13: 0 ];
		.p_dram_rdata		( ff_rdata					),	// IN	[ 7: 0 ];
		.p_dram_wdata		( w_dram_wdata				),	// OUT	[ 7: 0 ];
		.p_vdp_r			( p_vdp_r					),	// OUT	[ 5: 0 ];
		.p_vdp_g			( p_vdp_g					),	// OUT	[ 5: 0 ];
		.p_vdp_b			( p_vdp_b					),	// OUT	[ 5: 0 ];
		.p_vdp_hcounter		( p_vdp_hcounter			),	// OUT	[10: 0 ];
		.p_vdp_vcounter		( p_vdp_vcounter			),	// OUT	[10: 0 ];
		.p_video_dh_clk		( p_video_dh_clk			),	// OUT	
		.p_video_dl_clk		( p_video_dl_clk			)	// OUT	
    );
endmodule
