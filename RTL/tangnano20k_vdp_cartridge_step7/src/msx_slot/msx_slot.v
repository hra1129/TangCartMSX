//
//	msx_slot.v
//	 MSX Slot top entity
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

module msx_slot(
	input			clk,
	input			initial_busy,
	//	MSX Slot Signal
	input			p_slot_reset_n,
	input			p_slot_ioreq_n,
	input			p_slot_wr_n,
	input			p_slot_rd_n,
	input	[7:0]	p_slot_address,
	inout	[7:0]	p_slot_data,
	output			p_slot_int,				//	0 or HiZ: Normal, 1: Interrupt
	output			p_slot_data_dir,		//	0: MSX→Cartridge (Write), 1: Cartridge→MSX (Read)
	output			busdir,					//	0: MSX→Cartridge (Write), 1: Cartridge→MSX (Read)
	//	Local BUS
	input			int_n,
	output	[2:0]	bus_address,
	output			bus_ioreq,
	output			bus_write,
	output			bus_valid,
	input			bus_ready,
	output	[7:0]	bus_wdata,
	input	[7:0]	bus_rdata,
	input			bus_rdata_en
);
	reg				ff_pre_slot_ioreq_n	= 1'b1;
	reg				ff_pre_slot_wr_n	= 1'b1;
	reg				ff_pre_slot_rd_n	= 1'b1;

	reg				ff_slot_ioreq_n		= 1'b1;
	reg				ff_slot_wr_n		= 1'b1;
	reg				ff_slot_rd_n		= 1'b1;

	reg		[7:0]	ff_slot_address;
	reg		[7:0]	ff_slot_data;
	reg		[2:0]	ff_bus_address;
	wire			w_active;
	reg				ff_initial_busy		= 1'b1;
	reg				ff_iorq_wr			= 1'b0;
	reg				ff_iorq_rd			= 1'b0;
	reg				ff_active			= 1'b0;
	reg				ff_write			= 1'b0;
	reg				ff_valid			= 1'b0;
	reg				ff_ioreq			= 1'b0;
	reg		[7:0]	ff_rdata			= 8'd0;
	reg				ff_rdata_en			= 1'b0;

	// --------------------------------------------------------------------
	//	Initial busy latch
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !p_slot_reset_n ) begin
			ff_initial_busy	<= 1'b1;
		end
		else begin
			ff_initial_busy	<= initial_busy;
		end
	end

	// --------------------------------------------------------------------
	//	非同期載せ替えのために 2回叩いておく
	//	Pass through FF twice for asynchronous replacement.
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		ff_pre_slot_ioreq_n		<= p_slot_ioreq_n;
		ff_pre_slot_wr_n		<= p_slot_wr_n;
		ff_pre_slot_rd_n		<= p_slot_rd_n;

		ff_slot_ioreq_n			<= ff_pre_slot_ioreq_n;
		ff_slot_wr_n			<= ff_pre_slot_wr_n;
		ff_slot_rd_n			<= ff_pre_slot_rd_n;
	end

	always @( posedge clk or negedge p_slot_reset_n ) begin
		if( !p_slot_reset_n ) begin
			ff_iorq_wr			<= 1'b0;
			ff_iorq_rd			<= 1'b0;
		end
		else if( ff_initial_busy ) begin
			//	hold
		end
		else begin
			ff_iorq_wr			<= ~ff_slot_ioreq_n & ~ff_slot_wr_n;
			ff_iorq_rd			<= ~ff_slot_ioreq_n & ~ff_slot_rd_n;
		end
	end

	// --------------------------------------------------------------------
	//	ff_slot_ioreq_n == 0 のタイミングでは、
	//	アドレスと書き込み時のデータは確定済み
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !ff_slot_ioreq_n ) begin
			ff_slot_address		<= p_slot_address;
		end
	end

	always @( posedge clk ) begin
		if( !ff_slot_wr_n ) begin
			ff_slot_data		<= p_slot_data;
		end
	end

	// --------------------------------------------------------------------
	//	Transaction active signal
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !p_slot_reset_n ) begin
			ff_active <= 1'b0;
		end
		else begin
			ff_active <= w_active;
		end
	end

	assign w_active		= ff_iorq_wr | ff_iorq_rd;

	// --------------------------------------------------------------------
	//	Address latch
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !p_slot_reset_n ) begin
			ff_valid	<= 1'b0;
			ff_ioreq	<= 1'b0;
			ff_write	<= 1'b1;
		end
		else if( ff_valid ) begin
			if( bus_ready || !ff_ioreq ) begin
				ff_valid	<= 1'b0;
			end
		end
		else if( !ff_active && w_active ) begin
			if( { ff_slot_address[7:3], 3'd0 } == 8'h88 ) begin
				ff_bus_address	<= ff_slot_address[2:0];
				ff_ioreq		<= ff_iorq_wr | ff_iorq_rd;
				ff_valid		<= 1'b1;
			end
			else begin
				ff_ioreq	<= 1'b0;
			end
			ff_write	<= ff_iorq_wr;
		end
		else if( !ff_active ) begin
			ff_ioreq	<= 1'b0;
			ff_write	<= 1'b1;
		end
	end

	// --------------------------------------------------------------------
	//	Read data
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !p_slot_reset_n ) begin
			ff_rdata	<= 8'h00;
			ff_rdata_en	<= 1'b0;
		end
		else if( !ff_ioreq ) begin
			ff_rdata	<= 8'h00;
			ff_rdata_en	<= 1'b0;
		end
		else if( bus_rdata_en ) begin
			ff_rdata	<= bus_rdata;
			ff_rdata_en	<= 1'b1;
		end
	end

	assign bus_ioreq		= ff_ioreq;
	assign bus_address		= ff_bus_address;
	assign bus_wdata		= ff_slot_data;
	assign bus_write		= ff_write;
	assign bus_valid		= ff_valid;
	assign p_slot_data		= (ff_ioreq & ff_iorq_rd) ? ff_rdata: 8'hZZ;
	assign p_slot_int		= ~int_n;

	//	0: Cartridge <- CPU (Write or Idle), 1: Cartridge -> CPU (Read)
	assign p_slot_data_dir	= ff_ioreq & ff_iorq_rd;
	assign busdir			= ff_ioreq & ff_iorq_rd;
endmodule
