// -----------------------------------------------------------------------------
//	Test of vdp.v
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
	localparam			clk_base		= 1_000_000_000/85_909_080;	//	ns
	localparam			cpu_clk_base	= 1_000_000_000/ 3_579_545;	//	ps

	localparam			vdp_io0			= 8'h88;
	localparam			vdp_io1			= vdp_io0 + 8'h01;
	localparam			vdp_io2			= vdp_io0 + 8'h02;
	localparam			vdp_io3			= vdp_io0 + 8'h03;

	reg				clk;
	reg				clk14m;
	reg				slot_reset_n;
	reg				slot_iorq_n;
	reg				slot_rd_n;
	reg				slot_wr_n;
	wire			slot_wait;
	wire			slot_intr;
	wire			slot_data_dir;
	reg		[7:0]	slot_a;
	wire	[7:0]	slot_d;
	wire			busdir;
	wire			oe_n;
	reg				dipsw;
	wire			ws2812_led;
	reg		[1:0]	button;

	//	HDMI
	wire			tmds_clk_p;
	wire			tmds_clk_n;
	wire	[2:0]	tmds_d_p;
	wire	[2:0]	tmds_d_n;

	wire			O_sdram_clk;
	wire			O_sdram_cke;
	wire			O_sdram_cs_n;
	wire			O_sdram_ras_n;
	wire			O_sdram_cas_n;
	wire			O_sdram_wen_n;
	wire	[31:0]	IO_sdram_dq;
	wire	[10:0]	O_sdram_addr;
	wire	[ 1:0]	O_sdram_ba;
	wire	[ 3:0]	O_sdram_dqm;

	reg		[7:0]	ff_slot_data;
	reg				slot_clk;

	// --------------------------------------------------------------------
	//	Internal signals
	// --------------------------------------------------------------------
	integer				vram_delay_counter;
	integer				bus_ready_timeout_counter;
	integer				interrupt_timeout_counter;

	// --------------------------------------------------------------------
	//	Loop variables
	// --------------------------------------------------------------------
	integer				i, j, k;
	string				s_state;

	// --------------------------------------------------------------------
	//	DUT
	// --------------------------------------------------------------------
	tangnano20k_vdp_cartridge u_vdp_cartridge (
		.clk					( clk					),
		.clk14m					( clk14m				),
		.slot_reset_n			( slot_reset_n			),
		.slot_iorq_n			( slot_iorq_n			),
		.slot_rd_n				( slot_rd_n				),
		.slot_wr_n				( slot_wr_n				),
		.slot_wait				( slot_wait				),
		.slot_intr				( slot_intr				),
		.slot_data_dir			( slot_data_dir			),
		.slot_a					( slot_a				),
		.slot_d					( slot_d				),
		.busdir					( busdir				),
		.oe_n					( oe_n					),
		.dipsw					( dipsw					),
		.ws2812_led				( ws2812_led			),
		.button					( button				),
		.tmds_clk_p				( tmds_clk_p			),
		.tmds_clk_n				( tmds_clk_n			),
		.tmds_d_p				( tmds_d_p				),
		.tmds_d_n				( tmds_d_n				),
		.O_sdram_clk			( O_sdram_clk			),
		.O_sdram_cke			( O_sdram_cke			),
		.O_sdram_cs_n			( O_sdram_cs_n			),
		.O_sdram_ras_n			( O_sdram_ras_n			),
		.O_sdram_cas_n			( O_sdram_cas_n			),
		.O_sdram_wen_n			( O_sdram_wen_n			),
		.IO_sdram_dq			( IO_sdram_dq			),
		.O_sdram_addr			( O_sdram_addr			),
		.O_sdram_ba				( O_sdram_ba			),
		.O_sdram_dqm			( O_sdram_dqm			)
	);

	assign slot_d	= slot_data_dir ? 8'hZZ : ff_slot_data;

	// --------------------------------------------------------------------
	//	Clock generation
	// --------------------------------------------------------------------
	always #(clk_base/2) begin
		clk14m <= ~clk14m;			//	85MHz
	end

	// --------------------------------------------------------------------
	mt48lc2m32b2 u_sdram (
		.Dq					( IO_sdram_dq				), 
		.Addr				( O_sdram_addr				), 
		.Ba					( O_sdram_ba				), 
		.Clk				( O_sdram_clk				), 
		.Cke				( O_sdram_cke				), 
		.Cs_n				( O_sdram_cs_n				), 
		.Ras_n				( O_sdram_ras_n				), 
		.Cas_n				( O_sdram_cas_n				), 
		.We_n				( O_sdram_wen_n				), 
		.Dqm				( O_sdram_dqm				)
	);

	// --------------------------------------------------------------------
	//	tasks
	// --------------------------------------------------------------------
	task write_io(
		input	[15:0]	address,
		input	[7:0]	wdata
	);
		fork
			//	CPU clock
			begin
				//	T1
				s_state		= "T1";
				slot_clk	= 1'b1;
				#(cpu_clk_base/2) slot_clk	= 1'b0;
				//	T2
				s_state		= "T2";
				#(cpu_clk_base/2) slot_clk	= 1'b1;
				#(cpu_clk_base/2) slot_clk	= 1'b0;
				//	TW
				s_state		= "TW";
				#(cpu_clk_base/2) slot_clk	= 1'b1;
				#(cpu_clk_base/2) slot_clk	= 1'b0;
				//	T3
				s_state		= "T3";
				#(cpu_clk_base/2) slot_clk	= 1'b1;
				#(cpu_clk_base/2) slot_clk	= 1'b0;
				//	T4
				s_state		= "T4";
				#(cpu_clk_base/2) slot_clk	= 1'b1;
				#(cpu_clk_base/2) slot_clk	= 1'b0;
				//	T5
				s_state		= "T5";
				#(cpu_clk_base/2) slot_clk	= 1'b1;
				#(cpu_clk_base/2) slot_clk	= 1'b0;
			end
			//	Address
			begin
				#170ns slot_a = address;
			end
			//	/IORQ
			begin
				slot_iorq_n = 1'b1;
				//	T1
				@( negedge slot_clk );
				@( posedge slot_clk );
				#135ns slot_iorq_n = 1'b0;
				@( negedge slot_clk );
				@( negedge slot_clk );
				@( negedge slot_clk );
				#145ns slot_iorq_n = 1'b1;
			end
			//	/WR
			begin
				slot_wr_n = 1'b1;
				//	T1
				@( negedge slot_clk );
				@( posedge slot_clk );
				#125ns slot_wr_n = 1'b0;
				@( negedge slot_clk );
				@( negedge slot_clk );
				@( negedge slot_clk );
				#120ns slot_wr_n = 1'b1;
			end
			//	others
			begin
				ff_slot_data	= wdata;
			end
		join
	endtask

	// --------------------------------------------------------------------
	task write_io_ex(
		input	[15:0]	address,
		input	[7:0]	wdata
	);
		fork
			//	CPU clock
			begin
				//	T1
				s_state		= "T1";
				slot_clk	= 1'b1;
				#(cpu_clk_base/2) slot_clk	= 1'b0;
				//	T2
				s_state		= "T2";
				#(cpu_clk_base/2) slot_clk	= 1'b1;
				#(cpu_clk_base/2) slot_clk	= 1'b0;
				//	TW
				s_state		= "TW";
				#(cpu_clk_base/2) slot_clk	= 1'b1;
				#(cpu_clk_base/2) slot_clk	= 1'b0;
				//	T3
				s_state		= "T3";
				#(cpu_clk_base/2) slot_clk	= 1'b1;
				#(cpu_clk_base/2) slot_clk	= 1'b0;
				//	T4
				s_state		= "T4";
				#(cpu_clk_base/2) slot_clk	= 1'b1;
				#(cpu_clk_base/2) slot_clk	= 1'b0;
				//	T5
				s_state		= "T5";
				#(cpu_clk_base/2) slot_clk	= 1'b1;
				#(cpu_clk_base/2) slot_clk	= 1'b0;
			end
			//	Address
			begin
				#170ns slot_a = address;
			end
			//	/IORQ
			begin
				slot_iorq_n = 1'b1;
				//	T1
				@( negedge slot_clk );
				@( posedge slot_clk );
				#175ns slot_iorq_n = 1'b0;
				@( negedge slot_clk );
				@( negedge slot_clk );
				@( negedge slot_clk );
				#185ns slot_iorq_n = 1'b1;
			end
			//	/WR
			begin
				slot_wr_n = 1'b1;
				//	T1
				@( negedge slot_clk );
				@( posedge slot_clk );
				#165ns slot_wr_n = 1'b0;
				@( negedge slot_clk );
				@( negedge slot_clk );
				@( negedge slot_clk );
				#150ns slot_wr_n = 1'b1;
			end
			//	others
			begin
				ff_slot_data	= wdata;
			end
		join
	endtask

	// --------------------------------------------------------------------
	task read_io(
		input	[15:0]	address,
		output	[7:0]	rdata
	);
		fork
			//	CPU clock
			begin
				//	T1
				s_state		= "T1";
				slot_clk	= 1'b1;
				#(cpu_clk_base/2) slot_clk	= 1'b0;
				//	T2
				s_state		= "T2";
				#(cpu_clk_base/2) slot_clk	= 1'b1;
				#(cpu_clk_base/2) slot_clk	= 1'b0;
				//	TW
				s_state		= "TW";
				#(cpu_clk_base/2) slot_clk	= 1'b1;
				#(cpu_clk_base/2) slot_clk	= 1'b0;
				//	T3
				s_state		= "T3";
				#(cpu_clk_base/2) slot_clk	= 1'b1;
				#(cpu_clk_base/2) slot_clk	= 1'b0;
				//	T4
				s_state		= "T4";
				#(cpu_clk_base/2) slot_clk	= 1'b1;
				#(cpu_clk_base/2) slot_clk	= 1'b0;
				//	T5
				s_state		= "T5";
				#(cpu_clk_base/2) slot_clk	= 1'b1;
				#(cpu_clk_base/2) slot_clk	= 1'b0;
			end
			//	Address
			begin
				#170ns slot_a = address;
			end
			//	/IORQ
			begin
				slot_iorq_n = 1'b1;
				//	T1
				@( negedge slot_clk );
				@( posedge slot_clk );
				#135ns slot_iorq_n = 1'b0;
				@( negedge slot_clk );
				@( negedge slot_clk );
				@( negedge slot_clk );
				#145ns slot_iorq_n = 1'b1;
			end
			//	/RD
			begin
				slot_rd_n = 1'b1;
				//	T1
				@( negedge slot_iorq_n );
				#10ns slot_rd_n = 1'b0;
				@( posedge slot_iorq_n );
				rdata = slot_d;
				slot_rd_n = 1'b1;
			end
		join
	endtask

	// --------------------------------------------------------------------
	task wait_vdp_command;
		logic [7:0] rdata;
		integer		time_out;

		write_io( vdp_io1, 8'd2 );
		write_io( vdp_io1, 8'h80 + 8'd15 );

		time_out	= 10000;
		forever begin
			read_io( vdp_io1, rdata );
			if( rdata[0] == 1'b0 ) begin
				break;
			end
			@( posedge clk14m );
			time_out = time_out - 1;
			if( time_out == 0 ) begin
				$error( "Time out in wait_vdp_command" );
				$finish;
			end
		end

		write_io( vdp_io1, 8'd0 );
		write_io( vdp_io1, 8'h80 + 8'd15 );
	endtask

	// --------------------------------------------------------------------
	//	Test bench
	// --------------------------------------------------------------------
	initial begin
		// Initialize signals
		clk = 0;
		clk14m = 0;
		slot_reset_n = 0;
		slot_iorq_n = 1;
		slot_rd_n = 1;
		slot_wr_n = 1;
		slot_a = 0;
		dipsw = 0;
		button = 0;

		// Reset sequence
		repeat(10) @( posedge clk14m );
		slot_reset_n = 1;
		repeat(10) @( posedge clk14m );
		$display( "[test---] Wait initialization" );
		while( slot_wait == 1'b1 ) begin
			@( posedge clk14m );
		end
		repeat(10) @( posedge clk14m );

		//	SCREEN5
		//	VDP R#0 = 0x06
		write_io( vdp_io1, 8'h06 );
		write_io( vdp_io1, 8'h80 );
		//	VDP R#1 = 0x40
		write_io( vdp_io1, 8'h40 );
		write_io( vdp_io1, 8'h81 );
		//	VDP R#2 = 0x1F
		write_io( vdp_io1, 8'h1F );
		write_io( vdp_io1, 8'h82 );
		//	VDP R#8 = 0x0A
		write_io( vdp_io1, 8'h0A );
		write_io( vdp_io1, 8'h88 );

		$display( "[test001] Write VRAM" );
		//	VRAM 0x00000 ... 0x07FFF = 0x00
		write_io( vdp_io1, 8'h00 );
		write_io( vdp_io1, 8'h40 );

		for( i = 0; i < 32768; i = i + 1 ) begin
			write_io( vdp_io0, (i & 255) );
		end

		repeat(5000) @( posedge clk14m );

		//	VDP Command PSET
		$display( "[test002] VDP Command PSET" );
		write_io( vdp_io1, 8'd36 );
		write_io( vdp_io1, 8'h80 + 8'd17 );
		write_io( vdp_io3, 8'd32 );				//	R#36 DXl
		write_io( vdp_io3, 8'd0 );				//	R#37 DXh
		write_io( vdp_io3, 8'd32 );				//	R#38 DYl
		write_io( vdp_io3, 8'd0 );				//	R#39 DYh
		write_io( vdp_io3, 8'd0 );				//	R#40 ---
		write_io( vdp_io3, 8'd0 );				//	R#41 ---
		write_io( vdp_io3, 8'd0 );				//	R#42 ---
		write_io( vdp_io3, 8'd0 );				//	R#43 ---
		write_io( vdp_io3, 8'd15 );				//	R#44 COLOR
		write_io( vdp_io3, 8'd0 );				//	R#45 ---
		write_io( vdp_io3, 8'h50 );				//	R#46 PSET, IMP
		repeat(500) @( posedge clk14m );

		write_io( vdp_io1, 8'd36 );
		write_io( vdp_io1, 8'h80 + 8'd17 );
		write_io( vdp_io3, 8'd33 );				//	R#36 DXl
		write_io( vdp_io3, 8'd0 );				//	R#37 DXh
		write_io( vdp_io3, 8'd33 );				//	R#38 DYl
		write_io( vdp_io3, 8'd0 );				//	R#39 DYh
		write_io( vdp_io3, 8'd0 );				//	R#40 ---
		write_io( vdp_io3, 8'd0 );				//	R#41 ---
		write_io( vdp_io3, 8'd0 );				//	R#42 ---
		write_io( vdp_io3, 8'd0 );				//	R#43 ---
		write_io( vdp_io3, 8'd14 );				//	R#44 COLOR
		write_io( vdp_io3, 8'd0 );				//	R#45 ---
		write_io( vdp_io3, 8'h50 );				//	R#46 PSET, IMP
		repeat(500) @( posedge clk14m );

		write_io( vdp_io1, 8'd36 );
		write_io( vdp_io1, 8'h80 + 8'd17 );
		write_io( vdp_io3, 8'd34 );				//	R#36 DXl
		write_io( vdp_io3, 8'd0 );				//	R#37 DXh
		write_io( vdp_io3, 8'd34 );				//	R#38 DYl
		write_io( vdp_io3, 8'd0 );				//	R#39 DYh
		write_io( vdp_io3, 8'd0 );				//	R#40 ---
		write_io( vdp_io3, 8'd0 );				//	R#41 ---
		write_io( vdp_io3, 8'd0 );				//	R#42 ---
		write_io( vdp_io3, 8'd0 );				//	R#43 ---
		write_io( vdp_io3, 8'd13 );				//	R#44 COLOR
		write_io( vdp_io3, 8'd0 );				//	R#45 ---
		write_io( vdp_io3, 8'h50 );				//	R#46 PSET, IMP
		repeat(500) @( posedge clk14m );

		write_io( vdp_io1, 8'd36 );
		write_io( vdp_io1, 8'h80 + 8'd17 );
		write_io( vdp_io3, 8'd35 );				//	R#36 DXl
		write_io( vdp_io3, 8'd0 );				//	R#37 DXh
		write_io( vdp_io3, 8'd35 );				//	R#38 DYl
		write_io( vdp_io3, 8'd0 );				//	R#39 DYh
		write_io( vdp_io3, 8'd0 );				//	R#40 ---
		write_io( vdp_io3, 8'd0 );				//	R#41 ---
		write_io( vdp_io3, 8'd0 );				//	R#42 ---
		write_io( vdp_io3, 8'd0 );				//	R#43 ---
		write_io( vdp_io3, 8'd12 );				//	R#44 COLOR
		write_io( vdp_io3, 8'd0 );				//	R#45 ---
		write_io( vdp_io3, 8'h50 );				//	R#46 PSET, IMP
		repeat(500) @( posedge clk14m );

		//	VDP Command POINT
		$display( "[test003] VDP Command POINT" );
		write_io( vdp_io1, 8'd32 );
		write_io( vdp_io1, 8'h80 + 8'd17 );
		write_io( vdp_io3, 8'd32 );				//	R#32 SXl
		write_io( vdp_io3, 8'd0 );				//	R#33 SXh
		write_io( vdp_io3, 8'd32 );				//	R#34 SYl
		write_io( vdp_io3, 8'd0 );				//	R#35 SYh
		write_io( vdp_io1, 8'h40 );				//	R#46 POINT
		write_io( vdp_io1, 8'h80 + 8'd46 );

		write_io( vdp_io1, 8'd32 );
		write_io( vdp_io1, 8'h80 + 8'd17 );
		write_io( vdp_io3, 8'd33 );				//	R#32 SXl
		write_io( vdp_io3, 8'd0 );				//	R#33 SXh
		write_io( vdp_io3, 8'd33 );				//	R#34 SYl
		write_io( vdp_io3, 8'd0 );				//	R#35 SYh
		write_io( vdp_io1, 8'h40 );				//	R#46 POINT
		write_io( vdp_io1, 8'h80 + 8'd46 );

		write_io( vdp_io1, 8'd32 );
		write_io( vdp_io1, 8'h80 + 8'd17 );
		write_io( vdp_io3, 8'd34 );				//	R#32 SXl
		write_io( vdp_io3, 8'd0 );				//	R#33 SXh
		write_io( vdp_io3, 8'd34 );				//	R#34 SYl
		write_io( vdp_io3, 8'd0 );				//	R#35 SYh
		write_io( vdp_io1, 8'h40 );				//	R#46 POINT
		write_io( vdp_io1, 8'h80 + 8'd46 );

		write_io( vdp_io1, 8'd32 );
		write_io( vdp_io1, 8'h80 + 8'd17 );
		write_io( vdp_io3, 8'd35 );				//	R#32 SXl
		write_io( vdp_io3, 8'd0 );				//	R#33 SXh
		write_io( vdp_io3, 8'd35 );				//	R#34 SYl
		write_io( vdp_io3, 8'd0 );				//	R#35 SYh
		write_io( vdp_io1, 8'h40 );				//	R#46 POINT
		write_io( vdp_io1, 8'h80 + 8'd46 );

		wait_vdp_command();
		repeat( 100 ) @( posedge clk14m );

		//	VDP Command LINE
		$display( "[test004] VDP Command LINE" );
		write_io( vdp_io1, 8'd36 );
		write_io( vdp_io1, 8'h80 + 8'd17 );
		write_io( vdp_io3, 8'd10 );				//	R#36 DXl
		write_io( vdp_io3, 8'd0 );				//	R#37 DXh
		write_io( vdp_io3, 8'd20 );				//	R#38 DYl
		write_io( vdp_io3, 8'd0 );				//	R#39 DYh
		write_io( vdp_io3, 8'd100 );			//	R#40 NXl
		write_io( vdp_io3, 8'd0 );				//	R#41 NXh
		write_io( vdp_io3, 8'd100 );			//	R#42 NYl
		write_io( vdp_io3, 8'd0 );				//	R#43 NYh
		write_io( vdp_io3, 8'd8 );				//	R#44 COLOR
		write_io( vdp_io3, 8'd0 );				//	R#45 ARG
		write_io( vdp_io3, 8'h70 );				//	R#46 LINE, IMP

		wait_vdp_command();
		repeat( 100 ) @( posedge clk14m );

		write_io( vdp_io1, 8'd36 );
		write_io( vdp_io1, 8'h80 + 8'd17 );
		write_io( vdp_io3, 8'd10 );				//	R#36 DXl
		write_io( vdp_io3, 8'd0 );				//	R#37 DXh
		write_io( vdp_io3, 8'd20 );				//	R#38 DYl
		write_io( vdp_io3, 8'd0 );				//	R#39 DYh
		write_io( vdp_io3, 8'd100 );			//	R#40 NXl
		write_io( vdp_io3, 8'd0 );				//	R#41 NXh
		write_io( vdp_io3, 8'd50 );				//	R#42 NYl
		write_io( vdp_io3, 8'd0 );				//	R#43 NYh
		write_io( vdp_io3, 8'd10 );				//	R#44 COLOR
		write_io( vdp_io3, 8'd0 );				//	R#45 ARG
		write_io( vdp_io3, 8'h70 );				//	R#46 LINE, IMP

		wait_vdp_command();
		repeat( 100 ) @( posedge clk14m );

		//	VDP Command LMMV
		$display( "[test005] VDP Command LMMV (Box fill)" );
		write_io( vdp_io1, 8'd36 );
		write_io( vdp_io1, 8'h80 + 8'd17 );
		write_io( vdp_io3, 8'd10 );				//	R#36 DXl
		write_io( vdp_io3, 8'd0 );				//	R#37 DXh
		write_io( vdp_io3, 8'd20 );				//	R#38 DYl
		write_io( vdp_io3, 8'd0 );				//	R#39 DYh
		write_io( vdp_io3, 8'd120 );			//	R#40 NXl
		write_io( vdp_io3, 8'd0 );				//	R#41 NXh
		write_io( vdp_io3, 8'd53 );				//	R#42 NYl
		write_io( vdp_io3, 8'd0 );				//	R#43 NYh
		write_io( vdp_io3, 8'd15 );				//	R#44 COLOR
		write_io( vdp_io3, 8'd0 );				//	R#45 ARG
		write_io( vdp_io3, 8'h80 );				//	R#46 LMMV, IMP

		wait_vdp_command();
		repeat( 100 ) @( posedge clk14m );

		write_io( vdp_io1, 8'd36 );
		write_io( vdp_io1, 8'h80 + 8'd17 );
		write_io( vdp_io3, 8'd20 );				//	R#36 DXl
		write_io( vdp_io3, 8'd0 );				//	R#37 DXh
		write_io( vdp_io3, 8'd90 );				//	R#38 DYl
		write_io( vdp_io3, 8'd0 );				//	R#39 DYh
		write_io( vdp_io3, 8'd60 );				//	R#40 NXl
		write_io( vdp_io3, 8'd0 );				//	R#41 NXh
		write_io( vdp_io3, 8'd53 );				//	R#42 NYl
		write_io( vdp_io3, 8'd0 );				//	R#43 NYh
		write_io( vdp_io3, 8'd13 );				//	R#44 COLOR
		write_io( vdp_io3, 8'd0 );				//	R#45 ARG
		write_io( vdp_io3, 8'h83 );				//	R#46 LMMV, IMP

		wait_vdp_command();
		repeat( 100 ) @( posedge clk14m );

		//	VDP Command HMMV
		$display( "[test006] VDP Command HMMV (High speed box fill)" );
		write_io( vdp_io1, 8'd36 );
		write_io( vdp_io1, 8'h80 + 8'd17 );
		write_io( vdp_io3, 8'd100 );			//	R#36 DXl
		write_io( vdp_io3, 8'd0 );				//	R#37 DXh
		write_io( vdp_io3, 8'd20 );				//	R#38 DYl
		write_io( vdp_io3, 8'd0 );				//	R#39 DYh
		write_io( vdp_io3, 8'd99 );				//	R#40 NXl
		write_io( vdp_io3, 8'd0 );				//	R#41 NXh
		write_io( vdp_io3, 8'd50 );				//	R#42 NYl
		write_io( vdp_io3, 8'd0 );				//	R#43 NYh
		write_io( vdp_io3, 8'h1F );				//	R#44 COLOR
		write_io( vdp_io3, 8'd0 );				//	R#45 ARG
		write_io( vdp_io3, 8'hC0 );				//	R#46 HMMV

		wait_vdp_command();
		repeat( 100 ) @( posedge clk14m );

		//	VDP Command LMMM
		$display( "[test007] VDP Command LMMM (Block copy)" );
		write_io( vdp_io1, 8'd32 );
		write_io( vdp_io1, 8'h80 + 8'd17 );
		write_io( vdp_io3, 8'd0 );				//	R#32 SXl
		write_io( vdp_io3, 8'd0 );				//	R#33 SXh
		write_io( vdp_io3, 8'd0 );				//	R#34 SYl
		write_io( vdp_io3, 8'd0 );				//	R#35 SYh
		write_io( vdp_io3, 8'd51 );				//	R#36 DXl
		write_io( vdp_io3, 8'd0 );				//	R#37 DXh
		write_io( vdp_io3, 8'd153 );			//	R#38 DYl
		write_io( vdp_io3, 8'd0 );				//	R#39 DYh
		write_io( vdp_io3, 8'd80 );				//	R#40 NXl
		write_io( vdp_io3, 8'd0 );				//	R#41 NXh
		write_io( vdp_io3, 8'd16 );				//	R#42 NYl
		write_io( vdp_io3, 8'd0 );				//	R#43 NYh
		write_io( vdp_io3, 8'd0 );				//	R#44 COLOR
		write_io( vdp_io3, 8'd0 );				//	R#45 ARG
		write_io( vdp_io3, 8'h90 );				//	R#46 LMMM

		wait_vdp_command();
		repeat( 100 ) @( posedge clk14m );

		//	VDP Command HMMM
		$display( "[test007] VDP Command HMMM (High speed block copy)" );
		write_io( vdp_io1, 8'd32 );
		write_io( vdp_io1, 8'h80 + 8'd17 );
		write_io( vdp_io3, 8'd0 );				//	R#32 SXl
		write_io( vdp_io3, 8'd0 );				//	R#33 SXh
		write_io( vdp_io3, 8'd0 );				//	R#34 SYl
		write_io( vdp_io3, 8'd0 );				//	R#35 SYh
		write_io( vdp_io3, 8'd0 );				//	R#36 DXl
		write_io( vdp_io3, 8'd0 );				//	R#37 DXh
		write_io( vdp_io3, 8'd16 );				//	R#38 DYl
		write_io( vdp_io3, 8'd0 );				//	R#39 DYh
		write_io( vdp_io3, 8'd0 );				//	R#40 NXl
		write_io( vdp_io3, 8'd1 );				//	R#41 NXh
		write_io( vdp_io3, 8'd16 );				//	R#42 NYl
		write_io( vdp_io3, 8'd0 );				//	R#43 NYh
		write_io( vdp_io3, 8'd0 );				//	R#44 COLOR
		write_io( vdp_io3, 8'd0 );				//	R#45 ARG
		write_io( vdp_io3, 8'hD0 );				//	R#46 HMMM

		wait_vdp_command();
		repeat( 100 ) @( posedge clk14m );

//		repeat(2000000) @( posedge clk14m );

		$display( "[test---] All tests completed" );
		repeat( 100 ) @( posedge clk14m );
		$finish;
	end
endmodule
