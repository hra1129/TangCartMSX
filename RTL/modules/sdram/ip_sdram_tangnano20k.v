//
// ip_sdram.v
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

module ip_sdram #(
	parameter		FREQ = 85_909_080	//	Hz
) (
	input				n_reset,
	input				clk,				//	85.90908MHz
	input				clk_sdram,
	output				sdram_busy,

	input				dh_clk,				//	10.738635MHz: VideoDHClk
	input				dl_clk,				//	 5.369318MHz: VideoDLClk
	input	[22:0]		address,
	input				is_write,			//	0:Read, 1:Write
	input	[ 7:0]		wdata,
	output	[15:0]		rdata,

	// SDRAM ports
	output				O_sdram_clk,
	output				O_sdram_cke,
	output				O_sdram_cs_n,		// chip select
	output				O_sdram_ras_n,		// row address select
	output				O_sdram_cas_n,		// columns address select
	output				O_sdram_wen_n,		// write enable
	inout	[31:0]		IO_sdram_dq,		// 32 bit bidirectional data bus
	output	[10:0]		O_sdram_addr,		// 11 bit multiplexed address bus
	output	[ 1:0]		O_sdram_ba,			// two banks
	output	[ 3:0]		O_sdram_dqm			// data mask
);
	//	SDRAM commands
	localparam	[3:0]	c_sdr_command_mode_register_set		= 4'b0000;
	localparam	[3:0]	c_sdr_command_refresh				= 4'b0001;
	localparam	[3:0]	c_sdr_command_precharge_all			= 4'b0010;
	localparam	[3:0]	c_sdr_command_activate				= 4'b0011;
	localparam	[3:0]	c_sdr_command_write					= 4'b0100;
	localparam	[3:0]	c_sdr_command_read					= 4'b0101;
	localparam	[3:0]	c_sdr_command_burst_stop			= 4'b0110;
	localparam	[3:0]	c_sdr_command_no_operation			= 4'b0111;
	localparam	[3:0]	c_sdr_command_deselect				= 4'b1111;

	//	State value
	localparam	[4:0]	c_init_state_begin_first_wait		= 5'd0;
	localparam	[4:0]	c_init_state_first_wait				= 5'd1;
	localparam	[4:0]	c_init_state_send_precharge_all		= 5'd2;
	localparam	[4:0]	c_init_state_wait_precharge_all		= 5'd3;
	localparam	[4:0]	c_init_state_send_refresh_all1		= 5'd4;
	localparam	[4:0]	c_init_state_wait_refresh_all1		= 5'd5;
	localparam	[4:0]	c_init_state_send_refresh_all2		= 5'd6;
	localparam	[4:0]	c_init_state_wait_refresh_all2		= 5'd7;
	localparam	[4:0]	c_init_state_send_mode_register_set	= 5'd8;
	localparam	[4:0]	c_init_state_wait_mode_register_set	= 5'd9;
	localparam	[4:0]	c_main_state_activate				= 5'd10;
	localparam	[4:0]	c_main_state_nop1					= 5'd11;
	localparam	[4:0]	c_main_state_nop2					= 5'd12;
	localparam	[4:0]	c_main_state_read_or_write			= 5'd13;
	localparam	[4:0]	c_main_state_nop3					= 5'd14;
	localparam	[4:0]	c_main_state_nop4					= 5'd15;
	localparam	[4:0]	c_main_state_data_fetch				= 5'd16;
	localparam	[4:0]	c_main_state_finish					= 5'd17;

	localparam CLOCK_TIME		= 1_000_000_000 / FREQ;		// nsec
	localparam TIMER_COUNT		= 120_000 / CLOCK_TIME;		// clock
	localparam TIMER_BITS		= $clog2(TIMER_COUNT + 1);
	localparam REFRESH_COUNT	= 15_000 / CLOCK_TIME;		// clock
	localparam REFRESH_BITS		= $clog2(REFRESH_COUNT + 1);
	localparam REFRESH_NONE		= 10_000 / CLOCK_TIME;		// clock

	reg		[ 4:0]				ff_main_state;
	reg		[TIMER_BITS-1:0]	ff_main_timer;
	wire						w_end_of_main_timer;
	wire						w_start_of_main_state;
	wire						w_finish_of_main_state;

	reg							ff_sdr_ready;
	reg							ff_do_main_state;
	reg							ff_do_refresh;
	wire						w_vdp_phase;

	reg		[ 3:0]				ff_sdr_command			= c_sdr_command_no_operation;
	reg		[12:0]				ff_sdr_address			= 13'h0000;
	reg		[31:0]				ff_sdr_write_data		= 32'd0;
	reg		[ 3:0]				ff_sdr_dq_mask			= 4'b1111;
	reg		[15:0]				ff_sdr_read_data		= 16'd0;

	wire						w_refresh;

	reg		[REFRESH_BITS-1:0]	ff_refresh_timer;

	// --------------------------------------------------------------------
	//	Refresh counter
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_refresh_timer	<= 'd0;
		end
		else if( w_refresh ) begin
			if( !dl_clk && ff_do_refresh ) begin
				ff_refresh_timer	<= 'd0;
			end
		end
		else begin
			ff_refresh_timer	<= ff_refresh_timer + 'd1;
		end
	end

	assign w_refresh	= (ff_refresh_timer == REFRESH_COUNT);

	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_do_refresh	<= 1'b0;
		end
		else if( ff_sdr_ready ) begin
			if( ff_main_state == c_main_state_finish ) begin
				if( w_refresh == 1'b1 && dl_clk == 1'b1 ) begin
					ff_do_refresh	<= 1'b1;
				end
				else begin
					ff_do_refresh	<= 1'b0;
				end
			end
			else begin
				//	hold
			end
		end
		else begin
			ff_do_refresh	<= 1'b0;
		end
	end

	// --------------------------------------------------------------------
	//	Main State
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_main_state		<= c_init_state_begin_first_wait;
			ff_do_main_state	<= 1'b0;
		end
		else begin
			case( ff_main_state )
			c_init_state_begin_first_wait:
				ff_main_state	<= c_init_state_first_wait;
			c_init_state_send_precharge_all:
				ff_main_state	<= c_init_state_wait_precharge_all;
			c_init_state_send_refresh_all1:
				ff_main_state	<= c_init_state_wait_refresh_all1;
			c_init_state_send_refresh_all2:
				ff_main_state	<= c_init_state_wait_refresh_all2;
			c_init_state_send_mode_register_set:
				ff_main_state	<= c_init_state_wait_mode_register_set;
			c_main_state_activate:
				if( w_start_of_main_state ) begin
					ff_main_state		<= c_main_state_nop1;
					ff_do_main_state	<= 1'b1;
				end
			c_main_state_finish:
				if( w_finish_of_main_state ) begin
					ff_main_state		<= c_main_state_activate;
					ff_do_main_state	<= 1'b0;
				end
			default:
				if( (!ff_sdr_ready && w_end_of_main_timer) || (ff_sdr_ready && ff_do_main_state) ) begin
					ff_main_state	<= ff_main_state + 5'd1;
				end
				else begin
					//	hold
				end
			endcase
		end
	end

	assign w_start_of_main_state	=  dh_clk;
	assign w_finish_of_main_state	= !dh_clk;

	assign sdram_busy	= !ff_sdr_ready;

	// --------------------------------------------------------------------
	//	Sub State
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_sdr_ready	<= 1'b0;
		end
		else if( (ff_main_state == c_init_state_wait_mode_register_set) && w_end_of_main_timer ) begin
			ff_sdr_ready	<= 1'b1;
		end
		else begin
			//	hold
		end
	end

	// --------------------------------------------------------------------
	//	Main Timer
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		case( ff_main_state )
		c_init_state_begin_first_wait:
			ff_main_timer	<= TIMER_COUNT;		//	120usec
		c_init_state_send_precharge_all:
			ff_main_timer	<= 'd5;
		c_init_state_send_refresh_all1:
			ff_main_timer	<= 'd15;
		c_init_state_send_refresh_all2:
			ff_main_timer	<= 'd15;
		c_init_state_send_mode_register_set:
			ff_main_timer	<= 'd2;
		default:
			//	ff_main_timer is decrement counter.
			if( !w_end_of_main_timer ) begin
				ff_main_timer	<= ff_main_timer - 'd1;
			end
			else begin
				//	hold
			end
		endcase
	end

	assign w_end_of_main_timer	= (ff_main_timer == 'd0) ? 1'b1 : 1'b0;

	// --------------------------------------------------------------------
	//	SDRAM Command Signal
	// --------------------------------------------------------------------
	assign w_vdp_phase	= dl_clk;

	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_sdr_command	<= c_sdr_command_no_operation;
		end
		else begin
			case( ff_main_state )
			c_init_state_send_precharge_all:
				begin
					ff_sdr_command		<= c_sdr_command_precharge_all;
					ff_sdr_dq_mask		<= 4'b1111;
				end
			c_init_state_send_refresh_all1, c_init_state_send_refresh_all2:
				begin
					ff_sdr_command		<= c_sdr_command_refresh;
					ff_sdr_dq_mask		<= 4'b0000;
				end
			c_init_state_send_mode_register_set:
				begin
					ff_sdr_command		<= c_sdr_command_mode_register_set;
					ff_sdr_dq_mask		<= 4'b1111;
				end
			default:
				if( ff_sdr_ready ) begin
					case( ff_main_state )
					c_main_state_activate:
						if( !w_start_of_main_state ) begin
						end
						else if( ff_do_refresh ) begin
//							$display( "do_refresh: precharge_all" );
							ff_sdr_command		<= c_sdr_command_precharge_all;
							ff_sdr_dq_mask		<= 4'b0000;
						end
						else begin
							if( w_vdp_phase ) begin
//								$display( "activate address %X", { address[20:17], address[15:9] } );
								ff_sdr_command		<= c_sdr_command_activate;
								ff_sdr_dq_mask		<= 4'b1111;
							end
							else begin
								ff_sdr_command		<= c_sdr_command_no_operation;
								ff_sdr_dq_mask		<= 4'b1111;
							end
						end
					c_main_state_read_or_write:
						if( ff_do_refresh ) begin
							ff_sdr_command		<= c_sdr_command_refresh;
							ff_sdr_dq_mask		<= 4'b0000;
						end
						else begin
							if( w_vdp_phase ) begin
								if( is_write ) begin
									ff_sdr_command		<= c_sdr_command_write;
									case( { address[0], address[16] } )
									2'b00:		ff_sdr_dq_mask	<= 4'b1110;
									2'b01:		ff_sdr_dq_mask	<= 4'b1101;
									2'b10:		ff_sdr_dq_mask	<= 4'b1011;
									2'b11:		ff_sdr_dq_mask	<= 4'b0111;
									default:	ff_sdr_dq_mask	<= 4'b1111;
									endcase
								end
								else begin
									ff_sdr_command		<= c_sdr_command_read;
									ff_sdr_dq_mask		<= 4'b0000;
								end
							end
							else begin
								ff_sdr_command		<= c_sdr_command_no_operation;
								ff_sdr_dq_mask		<= 4'b1111;
							end
						end
					default:
						begin
							ff_sdr_command		<= c_sdr_command_no_operation;
							ff_sdr_dq_mask		<= 4'b1111;
						end
					endcase
				end
				else begin
					ff_sdr_command		<= c_sdr_command_no_operation;
					ff_sdr_dq_mask		<= 4'b1111;
				end
			endcase
		end
	end

	// --------------------------------------------------------------------
	//	 bit12  11     10   9   8    7    6     5     4     3   2    1    0
	//	[Bank1][Bank0][RSV][WB][OP1][OP0][CAS2][CAS1][CAS0][BT][BL2][BL1][BL0] : mode
	//	
	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_sdr_address			<= 13'd0;
		end
		else if( !ff_sdr_ready ) begin
			case( ff_main_state )
			c_init_state_send_precharge_all:
				ff_sdr_address <= { 
				    2'b00,						//	Ignore
					1'b1,						//	All banks
					10'd0						//	Ignore
				};
			default:
				ff_sdr_address <= { 
				    2'b00,						//	Bank
					1'b0,						//	Reserved
					1'b1,						//	Write burst mode  0: Programmed Burst Length, 1: Single Location Access
					2'b00,						//	Operation mode    00: Standard Operation, others: Reserved
					3'b010,						//	CAS Latency       010: 2cyc, 011: 3cyc, others: Reserved
					1'b0,						//	Burst type        0: Sequential Access, 1: Interleave Access
					3'b000						//	Burst length      000: 1, 001: 2, 010: 4, 011: 8, 111: full page (Sequential Access only), others: Reserved
				};
			endcase
		end
		else begin
			case( ff_main_state )
			c_main_state_activate:
				if( ff_sdr_ready ) begin
					if( w_vdp_phase ) begin
						ff_sdr_address <= { 
							address[22:21],						// Bank
							address[20:17], address[15:9]		// Row address
						};
					end
					else begin
						//	hold
					end
				end
				else begin
					ff_sdr_address <= 13'd0;	// Initialize phase
				end
			c_main_state_read_or_write:
				begin
					if( ff_sdr_ready ) begin
						if( w_vdp_phase ) begin
							ff_sdr_address <= { 
								address[22:21],		// Bank
								1'b1,				// Enable auto precharge
								2'd0,				// 00
								address[8:1] 		// Column address
							};
						end
						else begin
							if( ff_do_refresh ) begin
//								$display( "do_refresh" );
								ff_sdr_address <= { 
									2'b00,				// Ignore
									1'b1,				// All banks
									10'd0				// Ignore
								};
							end
						end
					end
					else begin
						ff_sdr_address <= 13'd0;
					end
				end
			default:
				begin
					//	hold
				end
			endcase
		end
	end

	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_sdr_write_data <= 32'dz;
		end
		else if( ff_sdr_ready && ff_main_state == c_main_state_read_or_write ) begin
			if( ff_sdr_ready ) begin
				if( w_vdp_phase ) begin
					ff_sdr_write_data <= { wdata, wdata, wdata, wdata };
				end
				else begin
					//	HOLD
				end
			end
			else begin
				ff_sdr_write_data <= 32'd0;
			end
		end
		else begin
			ff_sdr_write_data <= 32'dz;
		end
	end

	always @( posedge clk_sdram ) begin
		if( !n_reset ) begin
			ff_sdr_read_data <= 16'd0;
		end
		else if( ff_main_state == c_main_state_data_fetch ) begin
			if( w_vdp_phase ) begin
				if( address[0] == 1'b0 ) begin
					ff_sdr_read_data <= IO_sdram_dq[15:0];
				end
				else begin
					ff_sdr_read_data <= IO_sdram_dq[31:16];
				end
			end
			else begin
				//	hold
			end
		end
	end

	assign O_sdram_clk			= clk_sdram;
	assign O_sdram_cke			= 1'b1;
	assign O_sdram_cs_n			= ff_sdr_command[3];
	assign O_sdram_ras_n		= ff_sdr_command[2];
	assign O_sdram_cas_n		= ff_sdr_command[1];
	assign O_sdram_wen_n		= ff_sdr_command[0];

	assign O_sdram_dqm			= ff_sdr_dq_mask;
	assign O_sdram_ba			= ff_sdr_address[12:11];

	assign O_sdram_addr			= ff_sdr_address[10:0];
	assign IO_sdram_dq			= ff_sdr_write_data;

	assign rdata				= ff_sdr_read_data;
endmodule
