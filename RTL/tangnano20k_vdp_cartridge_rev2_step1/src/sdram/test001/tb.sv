// -----------------------------------------------------------------------------
//	Test of ip_sdram.v
//	Copyright (C)2025 Takayuki Hara (HRA!)
//	
//	�{�\�t�g�E�F�A����і{�\�t�g�E�F�A�Ɋ�Â��č쐬���ꂽ�h�����́A�ȉ��̏�����
//	�������ꍇ�Ɍ���A�ĔЕz����юg�p��������܂��B
//
//	1.�\�[�X�R�[�h�`���ōĔЕz����ꍇ�A��L�̒��쌠�\���A�{�����ꗗ�A����щ��L
//	  �Ɛӏ��������̂܂܂̌`�ŕێ����邱�ƁB
//	2.�o�C�i���`���ōĔЕz����ꍇ�A�Еz���ɕt���̃h�L�������g���̎����ɁA��L��
//	  ���쌠�\���A�{�����ꗗ�A����щ��L�Ɛӏ������܂߂邱�ƁB
//	3.���ʂɂ�鎖�O�̋��Ȃ��ɁA�{�\�t�g�E�F�A��̔��A����я��ƓI�Ȑ��i�⊈��
//	  �Ɏg�p���Ȃ����ƁB
//
//	�{�\�t�g�E�F�A�́A���쌠�҂ɂ���āu����̂܂܁v�񋟂���Ă��܂��B���쌠�҂́A
//	����ړI�ւ̓K�����̕ۏ؁A���i���̕ۏ؁A�܂�����Ɍ��肳��Ȃ��A�����Ȃ閾��
//	�I�������͈ÖقȕۏؐӔC�������܂���B���쌠�҂́A���R�̂�������킸�A���Q
//	�����̌�����������킸�A���ӔC�̍������_��ł��邩���i�ӔC�ł��邩�i�ߎ�
//	���̑��́j�s�@�s�ׂł��邩���킸�A���ɂ��̂悤�ȑ��Q����������\����m��
//	����Ă����Ƃ��Ă��A�{�\�t�g�E�F�A�̎g�p�ɂ���Ĕ��������i��֕i�܂��͑�p�T
//	�[�r�X�̒��B�A�g�p�̑r���A�f�[�^�̑r���A���v�̑r���A�Ɩ��̒��f���܂߁A�܂���
//	��Ɍ��肳��Ȃ��j���ڑ��Q�A�Ԑڑ��Q�A�����I�ȑ��Q�A���ʑ��Q�A�����I���Q�A��
//	���͌��ʑ��Q�ɂ��āA��ؐӔC�𕉂�Ȃ����̂Ƃ��܂��B
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
	localparam		TIMEOUT_COUNT	= 50;
	longint			clk_base		= 64'd1_000_000_000_000 / 64'd85_909_080;	//	ps
	reg				reset_n;
	reg				clk21m;				//	21.47727MHz
	reg		[1:0]	ff_21m;
	reg				clk;				//	85.90908MHz
	reg				clk_sdram;			//	85.90908MHz
	wire			sdram_init_busy;
	reg		[22:0]	bus_address;
	reg				bus_valid;
	reg				bus_write;
	reg				bus_refresh;
	reg		[ 7:0]	bus_wdata;
	wire	[15:0]	bus_rdata;
	wire			bus_rdata_en;
	wire			O_sdram_clk;
	wire			O_sdram_cke;
	wire			O_sdram_cs_n;		// chip select
	wire			O_sdram_cas_n;		// columns address select
	wire			O_sdram_ras_n;		// row address select
	wire			O_sdram_wen_n;		// write enable
	wire	[31:0]	IO_sdram_dq;		// 32 bit bidirectional data bus
	wire	[10:0]	O_sdram_addr;		// 11 bit multiplexed address bus
	wire	[ 1:0]	O_sdram_ba;			// two banks
	wire	[ 3:0]	O_sdram_dqm;		// data mask
	reg		[ 1:0]	ff_video_clk;

	// --------------------------------------------------------------------
	//	DUT
	// --------------------------------------------------------------------
	ip_sdram u_sdram_controller (
		.reset_n			( reset_n			),
		.clk				( clk				),
		.clk_sdram			( clk				),
		.sdram_init_busy	( sdram_init_busy	),
		.bus_address		( bus_address		),
		.bus_valid			( bus_valid			),
		.bus_write			( bus_write			),
		.bus_refresh		( bus_refresh		),
		.bus_wdata			( bus_wdata			),
		.bus_rdata			( bus_rdata			),
		.bus_rdata_en		( bus_rdata_en		),
		.O_sdram_clk		( O_sdram_clk		),
		.O_sdram_cke		( O_sdram_cke		),
		.O_sdram_cs_n		( O_sdram_cs_n		),
		.O_sdram_cas_n		( O_sdram_cas_n		),
		.O_sdram_ras_n		( O_sdram_ras_n		),
		.O_sdram_wen_n		( O_sdram_wen_n		),
		.IO_sdram_dq		( IO_sdram_dq		),
		.O_sdram_addr		( O_sdram_addr		),
		.O_sdram_ba			( O_sdram_ba		),
		.O_sdram_dqm		( O_sdram_dqm		)
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

	always @( posedge clk ) begin
		ff_21m <= ff_21m + 2'd1;
	end
	assign clk21m	= ff_21m[1];

	// --------------------------------------------------------------------
	//	Tasks
	// --------------------------------------------------------------------
	task write_data(
		input	[22:0]	p_address,
		input	[7:0]	p_data
	);
		int timeout;

		@( posedge clk21m );
		bus_address		<= p_address;
		bus_wdata		<= p_data;
		bus_write		<= 1'b1;
		bus_valid		<= 1'b1;
		@( posedge clk21m );

		$display( "[%t] write( 0x%06X, 0x%02X )", $realtime, p_address, p_data );
		bus_address		<= 0;
		bus_wdata		<= 0;
		bus_write		<= 1'b0;
		bus_valid		<= 1'b0;
		@( posedge clk21m );
		$display( "-- done" );
	endtask: write_data

	// --------------------------------------------------------------------
	task read_data(
		input	[22:0]	p_address,
		input	[15:0]	p_data
	);
		int timeout;

		@( posedge clk21m );
		bus_address		<= p_address;
		bus_write		<= 1'b0;
		bus_valid		<= 1'b1;
		@( posedge clk21m );

		$display( "[%t] read( 0x%06X )", $realtime, p_address );
		bus_valid		<= 1'b0;
		timeout			<= 0;
		while( !bus_rdata_en && (timeout < TIMEOUT_COUNT) ) begin
			@( posedge clk21m );
			timeout++;
		end
		@( posedge clk21m );
		assert( p_data == bus_rdata );
		if( p_data == bus_rdata ) begin
			$display( "-- done (0x%04X)", bus_rdata );
		end
		else begin
			$display( "[ERROR] no match (0x%04X != 0x%04X(ref))", bus_rdata, p_data );
		end
	endtask: read_data

	// --------------------------------------------------------------------
	task exec_refresh(
	);
		@( posedge clk21m );
		bus_refresh		<= 1'b1;
		@( posedge clk21m );
		bus_refresh		<= 1'b0;
		@( posedge clk21m );
	endtask: exec_refresh

	// --------------------------------------------------------------------
	//	Test bench
	// --------------------------------------------------------------------
	initial begin
		ff_21m = 0;
		reset_n = 0;
		clk = 0;
		clk_sdram = 1;
		bus_write = 0;
		bus_valid = 0;
		bus_address = 0;
		bus_wdata = 0;
		bus_refresh = 0;

		@( negedge clk );
		@( negedge clk );
		@( posedge clk );

		reset_n			= 1;
		@( posedge clk );

		$display( "Wait initialization of SDRAM" );
		while( sdram_init_busy ) begin
			@( posedge clk );
		end
		$display( "Finished initialization" );

		repeat( 16 ) @( posedge clk );
		repeat( 7 ) @( posedge clk );

		write_data( 'h000000, 'h12 );
		write_data( 'h000001, 'h23 );
		write_data( 'h000002, 'h34 );
		write_data( 'h000003, 'h45 );
		write_data( 'h000004, 'h56 );
		write_data( 'h000005, 'h67 );
		write_data( 'h000006, 'h78 );
		write_data( 'h000007, 'h89 );

		read_data(  'h000000, 'h2312 );
		read_data(  'h000001, 'h2312 );
		read_data(  'h000002, 'h4534 );
		read_data(  'h000003, 'h4534 );
		read_data(  'h000004, 'h6756 );
		read_data(  'h000005, 'h6756 );
		read_data(  'h000006, 'h8978 );
		read_data(  'h000007, 'h8978 );

		exec_refresh();
		exec_refresh();
		exec_refresh();

		repeat( 12 ) @( posedge clk );
		$finish;
	end
endmodule
