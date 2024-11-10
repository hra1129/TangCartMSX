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
	localparam		clk_base	= 1_000_000_000/85_909;	//	ps
	reg						reset;
	reg						clk;
	reg						bus_sltsl;
	reg						bus_memory_req;
	wire					bus_ack;
	reg						bus_wrt;
	reg			[15:0]		bus_address;
	reg			[7:0]		bus_wdata;
	wire		[7:0]		bus_rdata;
	wire					bus_rdata_en;
	wire					sltsl_ext0;
	wire					sltsl_ext1;
	wire					sltsl_ext2;
	wire					sltsl_ext3;

	// --------------------------------------------------------------------
	//	DUT
	// --------------------------------------------------------------------
	secondary_slot_inst u_secondary_slot_inst (
		.reset				( reset				),
		.clk				( clk				),
		.bus_sltsl			( bus_sltsl			),
		.bus_memory_req		( bus_memory_req	),
		.bus_ack			( bus_ack			),
		.bus_wrt			( bus_wrt			),
		.bus_address		( bus_address		),
		.bus_wdata			( bus_wdata			),
		.bus_rdata			( bus_rdata			),
		.bus_rdata_en		( bus_rdata_en		),
		.sltsl_ext0			( sltsl_ext0		),
		.sltsl_ext1			( sltsl_ext1		),
		.sltsl_ext2			( sltsl_ext2		),
		.sltsl_ext3			( sltsl_ext3		)
	);

	// --------------------------------------------------------------------
	//	clock
	// --------------------------------------------------------------------
	always #(clk_base/2) begin
		clk <= ~clk;
	end

	// --------------------------------------------------------------------
	//	Tasks
	// --------------------------------------------------------------------
	task reg_write(
		input	[15:0]	p_address,
		input	[7:0]	p_data
	);
		int count;

		count			<= 0;
		bus_sltsl		<= 1'b1;
		bus_memory_req	<= 1'b1;
		bus_wrt			<= 1'b1;
		bus_address		<= p_address;
		bus_wdata		<= p_data;
		@( posedge clk );

		while( !bus_ack && count < 5 ) begin
			count	<= count + 1;
			@( posedge clk );
		end

		bus_sltsl		<= 1'b0;
		bus_memory_req	<= 1'b0;
		bus_wrt			<= 1'b0;
		@( posedge clk );
	endtask : reg_write

	// --------------------------------------------------------------------
	task reg_read(
		input	[15:0]	p_address,
		input	[7:0]	p_reference_data
	);
		int count;

		count			<= 0;
		bus_sltsl		<= 1'b1;
		bus_memory_req	<= 1'b1;
		bus_wrt			<= 1'b0;
		bus_address		<= p_address;
		bus_wdata		<= 8'd0;
		@( posedge clk );

		while( !bus_ack && count < 5 ) begin
			count	<= count + 1;
			@( posedge clk );
		end

		bus_sltsl		<= 1'b0;
		bus_memory_req	<= 1'b0;

		while( !bus_rdata_en ) begin
			@( posedge clk );
		end

		if( bus_rdata == p_reference_data ) begin
			$display( "[OK] read( %04X ) == %02X", p_address, p_reference_data );
		end
		else begin
			$display( "[NG] read( %04X ) == %02X != %02X", p_address, p_reference_data, bus_rdata );
		end
		@( posedge clk );
	endtask : reg_read

	// --------------------------------------------------------------------
	task check_sltsl(
		input	[15:0]	p_address,
		input	[3:0]	p_sltsl
	);
		bus_sltsl		<= 1'b1;
		bus_memory_req	<= 1'b1;
		bus_wrt			<= 1'b0;
		bus_address		<= p_address;
		@( posedge clk );

		if( p_sltsl == { sltsl_ext3, sltsl_ext2, sltsl_ext1, sltsl_ext0 } ) begin
			$display( "[OK] SLTSL == %02X", p_sltsl );
		end
		else begin
			$display( "[NG] SLTSL == %02X != %02X", p_sltsl, { sltsl_ext3, sltsl_ext2, sltsl_ext1, sltsl_ext0 } );
		end
		@( posedge clk );
	endtask : check_sltsl

	// --------------------------------------------------------------------
	//	Test bench
	// --------------------------------------------------------------------
	initial begin
		reset				= 1;
		clk					= 0;
		bus_sltsl			= 0;
		bus_memory_req		= 0;
		bus_wrt				= 0;
		bus_address			= 0;
		bus_wdata			= 0;

		@( negedge clk );
		@( negedge clk );
		@( posedge clk );

		reset			= 1'b0;
		@( posedge clk );
		repeat( 10 ) @( posedge clk );

		$display( "<<TEST001>> FFFFh register Test" );
		reg_write( 16'hFFFF, 8'h12 );
		reg_read( 16'hFFFF, ~8'h12 );
		reg_write( 16'hFFFF, 8'h23 );
		reg_read( 16'hFFFF, ~8'h23 );
		reg_write( 16'hFFFF, 8'h34 );
		reg_read( 16'hFFFF, ~8'h34 );
		reg_write( 16'hFFFF, 8'h56 );
		reg_read( 16'hFFFF, ~8'h56 );
		reg_write( 16'hFFFF, 8'haf );
		reg_read( 16'hFFFF, ~8'haf );
		reg_write( 16'hFFFF, 8'h9a );
		reg_read( 16'hFFFF, ~8'h9a );

		$display( "<<TEST002>> SLTSL signals Test" );
		reg_write( 16'hFFFF, { 2'd3, 2'd2, 2'd1, 2'd0 } );
		check_sltsl( 16'h0000, 4'b0001 );
		check_sltsl( 16'h4000, 4'b0010 );
		check_sltsl( 16'h8000, 4'b0100 );
		check_sltsl( 16'hC000, 4'b1000 );

		reg_write( 16'hFFFF, { 2'd0, 2'd1, 2'd2, 2'd3 } );
		check_sltsl( 16'h0000, 4'b1000 );
		check_sltsl( 16'h4000, 4'b0100 );
		check_sltsl( 16'h8000, 4'b0010 );
		check_sltsl( 16'hC000, 4'b0001 );
		$finish;
	end
endmodule
