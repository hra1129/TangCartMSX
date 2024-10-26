//
// ip_sdram.v
//
// Copyright (c) 2024 Takayuki Hara
// All rights reserved.
//
// Redistribution and use of this source code or any derivative works, are
// permitted provided that the following conditions are met:
//
// 1. Redistributions of source code must retain the above copyright notice,
//	  this list of conditions and the following disclaimer.
// 2. Redistributions in binary form must reproduce the above copyright
//	  notice, this list of conditions and the following disclaimer in the
//	  documentation and/or other materials provided with the distribution.
// 3. Redistributions may not be sold, nor may they be used in a commercial
//	  product or activity without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
// PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
// CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
// EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
// OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
// WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
// OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
// ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
// ----------------------------------------------------------------------------

module ip_sdram #(
	parameter		FREQ = 85_909_080	//	Hz
) (
	input				n_reset,
	input				clk,				//	85.90908MHz
	input				clk_sdram,
	input	[1:0]		enable_state,
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
	localparam	[3:0]	c_sdr_command_mode_register_set		= 4'b0000;
	localparam	[3:0]	c_sdr_command_refresh				= 4'b0001;
	localparam	[3:0]	c_sdr_command_precharge_all			= 4'b0010;
	localparam	[3:0]	c_sdr_command_activate				= 4'b0011;
	localparam	[3:0]	c_sdr_command_write					= 4'b0100;
	localparam	[3:0]	c_sdr_command_read					= 4'b0101;
	localparam	[3:0]	c_sdr_command_burst_stop			= 4'b0110;
	localparam	[3:0]	c_sdr_command_no_operation			= 4'b0111;
	localparam	[3:0]	c_sdr_command_deselect				= 4'b1111;

	localparam	[4:0]	c_main_state_begin_first_wait		= 5'd0;
	localparam	[4:0]	c_main_state_first_wait				= 5'd1;
	localparam	[4:0]	c_main_state_send_precharge_all		= 5'd2;
	localparam	[4:0]	c_main_state_wait_precharge_all		= 5'd3;
	localparam	[4:0]	c_main_state_send_refresh_all1		= 5'd4;
	localparam	[4:0]	c_main_state_wait_refresh_all1		= 5'd5;
	localparam	[4:0]	c_main_state_send_refresh_all2		= 5'd6;
	localparam	[4:0]	c_main_state_wait_refresh_all2		= 5'd7;
	localparam	[4:0]	c_main_state_send_mode_register_set	= 5'd8;
	localparam	[4:0]	c_main_state_wait_mode_register_set	= 5'd9;
	localparam	[4:0]	c_main_state_ready					= 5'd10;

	localparam	[2:0]	c_sub_state_activate				= 3'd0;
	localparam	[2:0]	c_sub_state_nop1					= 3'd1;
	localparam	[2:0]	c_sub_state_nop2					= 3'd2;
	localparam	[2:0]	c_sub_state_read_or_write			= 3'd3;
	localparam	[2:0]	c_sub_state_nop3					= 3'd4;
	localparam	[2:0]	c_sub_state_nop4					= 3'd5;
	localparam	[2:0]	c_sub_state_data_fetch				= 3'd6;
	localparam	[2:0]	c_sub_state_end_of_sub_state		= 3'd7;

	localparam CLOCK_TIME		= 1_000_000_000 / FREQ;		// nsec
	localparam TIMER_COUNT		= 120_000 / CLOCK_TIME;		// clock
	localparam TIMER_BITS		= $clog2(TIMER_COUNT + 1);
	localparam REFRESH_COUNT	= 15_000 / CLOCK_TIME;		// clock
	localparam REFRESH_BITS		= $clog2(REFRESH_COUNT + 1);
	localparam REFRESH_NONE		= 10_000 / CLOCK_TIME;		// clock

	reg		[ 4:0]				ff_main_state;
	reg		[TIMER_BITS-1:0]	ff_main_timer;
	wire						w_end_of_main_timer;
	wire						w_start_of_sub_state;
	wire						w_end_of_sub_state;

	reg							ff_sdram_ready;
	reg		[ 2:0]				ff_sub_state;
	reg							ff_do_refresh;
	wire						w_vdp_phase;

	reg		[ 3:0]				ff_sdram_command			= c_sdr_command_no_operation;
	reg		[12:0]				ff_sdr_address				= 13'h0000;
	reg		[31:0]				ff_sdr_data					= 32'd0;
	reg		[ 3:0]				ff_sdr_dq_mask				= 4'b1111;
	reg		[15:0]				ff_mem_vdp_read_data		= 16'd0;

	wire						w_refresh;
	wire						mem_req;
	wire	[22:0]				mem_cpu_address;
	wire						mem_cpu_write;
	wire	[ 7:0]				mem_cpu_write_data;
	wire	[ 7:0]				vram_slot_ids;

	reg		[REFRESH_BITS-1:0]	ff_refresh_timer;

	assign mem_req				= 1'b0;
	assign mem_cpu_address		= 23'd0;
	assign mem_cpu_write		= 1'b0;
	assign mem_cpu_write_data	= 8'd0;
	assign vram_slot_ids		= 8'd0;

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
		else if( ff_sdram_ready ) begin
			if( ff_sub_state == c_sub_state_end_of_sub_state ) begin
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
			ff_main_state	<= c_main_state_begin_first_wait;
		end
		else begin
			case( ff_main_state )
			c_main_state_begin_first_wait:
				ff_main_state	<= c_main_state_first_wait;
			c_main_state_send_precharge_all:
				ff_main_state	<= c_main_state_wait_precharge_all;
			c_main_state_send_refresh_all1:
				ff_main_state	<= c_main_state_wait_refresh_all1;
			c_main_state_send_refresh_all2:
				ff_main_state	<= c_main_state_wait_refresh_all2;
			c_main_state_send_mode_register_set:
				ff_main_state	<= c_main_state_wait_mode_register_set;
			c_main_state_ready:
				begin
					//	hold
				end
			default:
				if( (!ff_sdram_ready && w_end_of_main_timer) || (ff_sub_state == c_sub_state_end_of_sub_state && dh_clk && (enable_state == 2'b00)) ) begin
					ff_main_state	<= ff_main_state + 5'd1;
				end
				else begin
					//	hold
				end
			endcase
		end
	end

	assign sdram_busy	= !ff_sdram_ready;

	// --------------------------------------------------------------------
	//	Sub State
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_sdram_ready	<= 1'b0;
		end
		else if( (ff_main_state == c_main_state_wait_mode_register_set) && w_end_of_main_timer ) begin
			ff_sdram_ready	<= 1'b1;
		end
		else begin
			//	hold
		end
	end

	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_sub_state	<= c_sub_state_activate;
		end
		else if( ff_sdram_ready ) begin
			case( ff_sub_state )
			c_sub_state_activate:
				if( w_start_of_sub_state ) begin
					ff_sub_state <= c_sub_state_nop1;
				end
			c_sub_state_end_of_sub_state:
				if( w_end_of_sub_state ) begin
					ff_sub_state <= c_sub_state_activate;
				end
			default:
				ff_sub_state <= ff_sub_state + 3'd1;
			endcase
		end
		else begin
			//	hold
		end
	end

	assign w_start_of_sub_state	=  dh_clk || (ff_main_state != c_main_state_ready);
	assign w_end_of_sub_state	= !dh_clk || (ff_main_state != c_main_state_ready);

	// --------------------------------------------------------------------
	//	Main Timer
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		case( ff_main_state )
		c_main_state_begin_first_wait:
			ff_main_timer	<= TIMER_COUNT;		//	120usec
		c_main_state_send_precharge_all:
			ff_main_timer	<= 'd5;
		c_main_state_send_refresh_all1:
			ff_main_timer	<= 'd15;
		c_main_state_send_refresh_all2:
			ff_main_timer	<= 'd15;
		c_main_state_send_mode_register_set:
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
			ff_sdram_command	<= c_sdr_command_no_operation;
		end
		else begin
			case( ff_main_state )
			c_main_state_send_precharge_all:
				begin
					ff_sdram_command		<= c_sdr_command_precharge_all;
					ff_sdr_dq_mask			<= 4'b1111;
				end
			c_main_state_send_refresh_all1, c_main_state_send_refresh_all2:
				begin
					ff_sdram_command		<= c_sdr_command_refresh;
					ff_sdr_dq_mask			<= 4'b0000;
				end
			c_main_state_send_mode_register_set:
				begin
					ff_sdram_command		<= c_sdr_command_mode_register_set;
					ff_sdr_dq_mask			<= 4'b1111;
				end
			default:
				if( ff_sdram_ready ) begin
					case( ff_sub_state )
					c_sub_state_activate:
						if( !w_start_of_sub_state ) begin
						end
						else if( ff_do_refresh ) begin
//							$display( "do_refresh: precharge_all" );
							ff_sdram_command		<= c_sdr_command_precharge_all;
							ff_sdr_dq_mask			<= 4'b0000;
						end
						else begin
							if( w_vdp_phase ) begin
//								$display( "activate address %X", { address[20:17], address[15:9] } );
								ff_sdram_command		<= c_sdr_command_activate;
								ff_sdr_dq_mask			<= 4'b1111;
							end
							else begin
								ff_sdram_command		<= c_sdr_command_no_operation;
								ff_sdr_dq_mask			<= 4'b1111;
							end
						end
					c_sub_state_read_or_write:
						if( ff_do_refresh ) begin
							ff_sdram_command		<= c_sdr_command_refresh;
							ff_sdr_dq_mask			<= 4'b0000;
						end
						else begin
							if( w_vdp_phase ) begin
								if( is_write ) begin
									ff_sdram_command		<= c_sdr_command_write;
									case( { address[0], address[16] } )
									2'b00:		ff_sdr_dq_mask	<= 4'b1110;
									2'b01:		ff_sdr_dq_mask	<= 4'b1101;
									2'b10:		ff_sdr_dq_mask	<= 4'b1011;
									2'b11:		ff_sdr_dq_mask	<= 4'b0111;
									default:	ff_sdr_dq_mask	<= 4'b1111;
									endcase
								end
								else begin
									ff_sdram_command		<= c_sdr_command_read;
									ff_sdr_dq_mask			<= 4'b0000;
								end
							end
							else begin
								ff_sdram_command		<= c_sdr_command_no_operation;
								ff_sdr_dq_mask			<= 4'b1111;
							end
						end
					default:
						begin
							ff_sdram_command		<= c_sdr_command_no_operation;
							ff_sdr_dq_mask			<= 4'b1111;
						end
					endcase
				end
				else begin
					ff_sdram_command		<= c_sdr_command_no_operation;
					ff_sdr_dq_mask			<= 4'b1111;
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
		else if( !ff_sdram_ready ) begin
			case( ff_main_state )
			c_main_state_send_precharge_all:
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
			case( ff_sub_state )
			c_sub_state_activate:
				if( ff_main_state == c_main_state_ready ) begin
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
			c_sub_state_read_or_write:
				begin
					if( ff_main_state == c_main_state_ready ) begin
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
			ff_sdr_data <= 32'dz;
		end
		else if( ff_sdram_ready && ff_sub_state == c_sub_state_read_or_write ) begin
			if( ff_main_state == c_main_state_ready ) begin
				if( w_vdp_phase ) begin
					ff_sdr_data <= { wdata, wdata, wdata, wdata };
				end
//				else begin
//					ff_sdr_data <= { mem_cpu_write_data, mem_cpu_write_data };
//				end
			end
			else begin
				ff_sdr_data <= 32'd0;
			end
		end
		else begin
			ff_sdr_data <= 32'dz;
		end
	end

	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_mem_vdp_read_data <= 16'd0;
		end
		else if( ff_sdram_ready && ff_sub_state == c_sub_state_data_fetch ) begin
			if( w_vdp_phase ) begin
				if( address[0] == 1'b0 ) begin
					ff_mem_vdp_read_data <= IO_sdram_dq[15:0];
				end
				else begin
					ff_mem_vdp_read_data <= IO_sdram_dq[31:16];
				end
			end
		end
	end

	assign O_sdram_clk			= clk_sdram;
	assign O_sdram_cke			= 1'b1;
	assign O_sdram_cs_n			= ff_sdram_command[3];
	assign O_sdram_ras_n		= ff_sdram_command[2];
	assign O_sdram_cas_n		= ff_sdram_command[1];
	assign O_sdram_wen_n		= ff_sdram_command[0];

	assign O_sdram_dqm			= ff_sdr_dq_mask;
	assign O_sdram_ba			= ff_sdr_address[12:11];

	assign O_sdram_addr			= ff_sdr_address[10:0];
	assign IO_sdram_dq			= ff_sdr_data;

	assign rdata				= ff_mem_vdp_read_data;
endmodule
