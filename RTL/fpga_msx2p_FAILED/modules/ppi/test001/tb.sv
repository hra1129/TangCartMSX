// -----------------------------------------------------------------------------
//	Test of ppi_inst.v
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
	localparam		clk_base	= 1_000_000_000/85_909;	//	ps
	reg						reset_n;
	reg						clk;
	reg						iorq_n;
	reg						wr_n;
	reg						rd_n;
	reg			[15:0]		address;
	reg			[7:0]		wdata;
	wire		[7:0]		rdata;
	wire					rdata_en;
	wire		[3:0]		matrix_y;
	reg			[7:0]		matrix_x;
	wire					cmt_motor_off;
	wire					cmt_write_signal;
	wire					keyboard_caps_led_off;
	wire					click_sound;
	wire					sltsl0;
	wire					sltsl1;
	wire					sltsl2;
	wire					sltsl3;

	// --------------------------------------------------------------------
	//	DUT
	// --------------------------------------------------------------------
	ppi_inst u_ppi (
		.reset_n					( reset_n					),
		.clk						( clk						),
		.iorq_n						( iorq_n					),
		.wr_n						( wr_n						),
		.rd_n						( rd_n						),
		.address					( address					),
		.wdata						( wdata						),
		.rdata						( rdata						),
		.rdata_en					( rdata_en					),
		.matrix_y					( matrix_y					),
		.matrix_x					( matrix_x					),
		.cmt_motor_off				( cmt_motor_off				),
		.cmt_write_signal			( cmt_write_signal			),
		.keyboard_caps_led_off		( keyboard_caps_led_off		),
		.click_sound				( click_sound				),
		.sltsl0						( sltsl0					),
		.sltsl1						( sltsl1					),
		.sltsl2						( sltsl2					),
		.sltsl3						( sltsl3					)
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
		iorq_n		<= 1'b0;
		wr_n		<= 1'b0;
		address		<= p_address;
		wdata		<= p_data;
		@( posedge clk );

		iorq_n		<= 1'b1;
		wr_n		<= 1'b1;
		address		<= 16'd0;
		wdata		<= 'dZ;
		@( posedge clk );
	endtask : reg_write

	// --------------------------------------------------------------------
	task reg_read(
		input	[15:0]	p_address,
		input	[7:0]	p_reference_data
	);
		int count;

		count		<= 0;
		iorq_n		<= 1'b0;
		rd_n		<= 1'b0;
		address		<= p_address;
		wdata		<= 8'd0;
		@( posedge clk );

		iorq_n		<= 1'b1;
		rd_n		<= 1'b1;
		while( !rdata_en && count < 5 ) begin
			count	<= count + 1;
			@( posedge clk );
		end

		while( !rdata_en ) begin
			@( posedge clk );
		end

		if( rdata == p_reference_data ) begin
			$display( "[OK] read( %04X ) == %02X", p_address, p_reference_data );
		end
		else begin
			$display( "[NG] read( %04X ) == %02X != %02X", p_address, p_reference_data, rdata );
		end
		@( posedge clk );
	endtask : reg_read

	// --------------------------------------------------------------------
	task check_slot(
		input	[15:0]	p_address,
		input	[3:0]	p_slot
	);
		address	<= p_address;
		@( posedge clk );

		if( p_slot == { sltsl3, sltsl2, sltsl1, sltsl0 } ) begin
			$display( "[OK] slot check( %04X ) : sltsl OK", p_address );
		end
		else begin
			$display( "[NG] slot check( %04X ) : %01X != %01X", p_address, p_slot, { sltsl3, sltsl2, sltsl1, sltsl0 } );
		end
		@( posedge clk );
	endtask : check_slot

	// --------------------------------------------------------------------
	task check_matrix_sel(
		input	[7:0]	p_sel
	);
		if( p_sel == { click_sound, keyboard_caps_led_off, cmt_write_signal, cmt_motor_off, matrix_y } ) begin
			$display( "[OK] matrix select check : OK" );
		end
		else begin
			$display( "[NG] matrix select check : %02X != %02X", p_sel, { click_sound, keyboard_caps_led_off, cmt_write_signal, cmt_motor_off, matrix_y } );
		end
		@( posedge clk );
	endtask : check_matrix_sel

	// --------------------------------------------------------------------
	task check_matrix(
		input	[7:0]	p_matrix_x
	);
		matrix_x <= p_matrix_x;
		@( posedge clk );

		reg_read( 16'h00A9, p_matrix_x );
	endtask : check_matrix

	// --------------------------------------------------------------------
	//	Test bench
	// --------------------------------------------------------------------
	initial begin
		reset_n				= 0;
		clk					= 0;
		iorq_n				= 1;
		wr_n				= 1;
		rd_n				= 1;
		address				= 0;
		wdata				= 0;
		matrix_x			= 0;

		@( negedge clk );
		@( negedge clk );
		@( posedge clk );

		reset_n				= 1'b1;
		@( posedge clk );
		repeat( 10 ) @( posedge clk );

		reg_write( 16'h00AA, 8'h23 );							//	PortC

		$display( "<<TEST001>> Primary slot write Test" );
		reg_write( 16'h00A8, { 2'd0, 2'd1, 2'd2, 2'd3 } );		//	PortA

		$display( "<<TEST002>> Primary slot read Test" );
		check_slot( 16'h0000, 4'b1000 );
		check_slot( 16'h4000, 4'b0100 );
		check_slot( 16'h8000, 4'b0010 );
		check_slot( 16'hC000, 4'b0001 );

		check_slot( 16'h0159, 4'b1000 );
		check_slot( 16'h4A26, 4'b0100 );
		check_slot( 16'h87B3, 4'b0010 );
		check_slot( 16'hC48C, 4'b0001 );

		check_slot( 16'h0591, 4'b1000 );
		check_slot( 16'h426A, 4'b0100 );
		check_slot( 16'h8B37, 4'b0010 );
		check_slot( 16'hC8C4, 4'b0001 );

		$display( "<<TEST003>> Primary slot write Test" );
		reg_write( 16'h00A8, { 2'd2, 2'd3, 2'd0, 2'd1 } );		//	PortA

		$display( "<<TEST004>> Primary slot read Test" );
		check_slot( 16'h0000, 4'b0010 );
		check_slot( 16'h4000, 4'b0001 );
		check_slot( 16'h8000, 4'b1000 );
		check_slot( 16'hC000, 4'b0100 );

		check_slot( 16'h0159, 4'b0010 );
		check_slot( 16'h4A26, 4'b0001 );
		check_slot( 16'h87B3, 4'b1000 );
		check_slot( 16'hC48C, 4'b0100 );

		check_slot( 16'h0591, 4'b0010 );
		check_slot( 16'h426A, 4'b0001 );
		check_slot( 16'h8B37, 4'b1000 );
		check_slot( 16'hC8C4, 4'b0100 );

		$display( "<<TEST005>> PortC write Test" );
		reg_write( 16'h00AA, 8'h12 );		//	PortC
		check_matrix_sel( 8'h12 );
		reg_write( 16'h00AA, 8'h34 );		//	PortC
		check_matrix_sel( 8'h34 );
		reg_write( 16'h00AA, 8'hAB );		//	PortC
		check_matrix_sel( 8'hAB );
		reg_write( 16'h00AA, 8'h9F );		//	PortC
		check_matrix_sel( 8'h9F );

		$display( "<<TEST006>> PortB read Test" );
		check_matrix( 8'h19 );
		check_matrix( 8'hA5 );
		check_matrix( 8'hD2 );
		check_matrix( 8'h8A );
		check_matrix( 8'h46 );
		check_matrix( 8'hFF );
		check_matrix( 8'h00 );

		$finish;
	end
endmodule
