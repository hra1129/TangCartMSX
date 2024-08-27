// -----------------------------------------------------------------------------
//	ip_sdram.v
//	Copyright (C)2024 Takayuki Hara (HRA!)
//	
//	 Permission is hereby granted, free of charge, to any person obtaining a 
//	copy of this software and associated documentation files (the "Software"), 
//	to deal in the Software without restriction, including without limitation 
//	the rights to use, copy, modify, merge, publish, distribute, sublicense, 
//	and/or sell copies of the Software, and to permit persons to whom the 
//	Software is furnished to do so, subject to the following conditions:
//	
//	The above copyright notice and this permission notice shall be included in 
//	all copies or substantial portions of the Software.
//	
//	The Software is provided "as is", without warranty of any kind, express or 
//	implied, including but not limited to the warranties of merchantability, 
//	fitness for a particular purpose and noninfringement. In no event shall the 
//	authors or copyright holders be liable for any claim, damages or other 
//	liability, whether in an action of contract, tort or otherwise, arising 
//	from, out of or in connection with the Software or the use or other dealings 
//	in the Software.
// -----------------------------------------------------------------------------
//	Description:
//		SDRAM Controller
// -----------------------------------------------------------------------------

module ip_sdram (
	//	Internal I/F
	input			n_reset,
	input			clk,				// 54MHz
	output			initial_busy,
	//	CPU I/F
	input			rd,					// Set to 1 to read
	input			wr,					// Set to 1 to write
	output			busy,
	input	[21:0]	address,			// Byte address
	input	[7:0]	wdata,
	output	[7:0]	rdata,
	output			rdata_en,
	//	PSRAM I/F
	output			O_sdram_cke,
	output			O_sdram_cs_n,		// chip select
	output			O_sdram_cas_n,		// columns address select
	output			O_sdram_ras_n,		// row address select
	output			O_sdram_wen_n,		// write enable
	inout	[31:0]	IO_sdram_dq,		// 32 bit bidirectional data bus
	output	[10:0]	O_sdram_addr,		// 11 bit multiplexed address bus
	output	[1:0]	O_sdram_ba,			// two banks
	output	[3:0]	O_sdram_dqm			// data mask
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
	localparam	[4:0]	c_main_state_clear_eseram			= 5'd10;
	localparam	[4:0]	c_main_state_wait_clear_eseram		= 5'd11;
	localparam	[4:0]	c_main_state_clear_esescc1			= 5'd12;
	localparam	[4:0]	c_main_state_wait_clear_esescc1		= 5'd13;
	localparam	[4:0]	c_main_state_clear_esescc2			= 5'd14;
	localparam	[4:0]	c_main_state_wait_clear_esescc2		= 5'd15;
	localparam	[4:0]	c_main_state_clear_mainrom			= 5'd16;
	localparam	[4:0]	c_main_state_wait_clear_mainrom		= 5'd17;
	localparam	[4:0]	c_main_state_ready					= 5'd18;

	localparam	[2:0]	c_sub_state_activate				= 3'd0;
	localparam	[2:0]	c_sub_state_nop1					= 3'd1;
	localparam	[2:0]	c_sub_state_nop2					= 3'd2;
	localparam	[2:0]	c_sub_state_read_or_write			= 3'd3;
	localparam	[2:0]	c_sub_state_nop3					= 3'd4;
	localparam	[2:0]	c_sub_state_nop4					= 3'd5;
	localparam	[2:0]	c_sub_state_data_fetch				= 3'd6;
	localparam	[2:0]	c_sub_state_end_of_sub_state		= 3'd7;

	reg		[ 4:0]	ff_main_state				= c_main_state_begin_first_wait;
	reg		[15:0]	ff_main_timer;
	wire			w_end_of_main_timer;
	wire			w_start_of_sub_state;
	wire			w_end_of_sub_state;

	reg				ff_sub_state_drive			= 1'b0;
	reg		[ 2:0]	ff_sub_state;
	reg				ff_do_refresh;

	reg		[ 3:0]	ff_sdram_command			= 4'b0000;
	reg		[14:0]	ff_sdr_address				= 15'd0;
	reg		[31:0]	ff_sdr_data					= 32'd0;
	reg		[ 3:0]	ff_sdr_dq_mask				= 4'b1111;
	reg		[ 7:0]	ff_rdata;
	reg				ff_rdata_en;
	reg				ff_skip_clear				= 1'b0;

	// --------------------------------------------------------------------
	//	Main State
	// --------------------------------------------------------------------
	always @( posedge mem_clk ) begin
		if( sync_reset ) begin
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
			c_main_state_clear_eseram:
				ff_main_state	<= c_main_state_wait_clear_eseram;
			c_main_state_clear_esescc1:
				ff_main_state	<= c_main_state_wait_clear_esescc1;
			c_main_state_clear_esescc2:
				ff_main_state	<= c_main_state_wait_clear_esescc2;
			c_main_state_clear_mainrom:
				ff_main_state	<= c_main_state_wait_clear_mainrom;
			c_main_state_ready:
				begin
					ff_main_state	<= c_main_state_ready;
					ff_skip_clear	<= 1'b1;
				end
			default:
				if( (!ff_sub_state_drive && w_end_of_main_timer) || (ff_sub_state == c_sub_state_end_of_sub_state && !mem_vdp_dh_clk) ) begin
					if( ff_skip_clear && (ff_main_state == c_main_state_wait_mode_register_set) ) begin
						ff_main_state	<= c_main_state_ready;
					end
					else begin
						ff_main_state	<= ff_main_state + 5'd1;
					end
				end
				else begin
					//	hold
				end
			endcase
		end
	end

	assign sdram_ready	= (ff_main_state == c_main_state_ready) ? 1'b1 : 1'b0;

	// --------------------------------------------------------------------
	//	Sub State
	// --------------------------------------------------------------------
	always @( posedge mem_clk ) begin
		if( sync_reset ) begin
			ff_sub_state_drive	<= 1'b0;
		end
		else if( (ff_main_state == c_main_state_wait_mode_register_set) && w_end_of_main_timer ) begin
			ff_sub_state_drive	<= 1'b1;
		end
		else begin
			//	hold
		end
	end

	always @( posedge mem_clk ) begin
		if( sync_reset ) begin
			ff_sub_state	<= c_sub_state_activate;
		end
		else if( ff_sub_state_drive ) begin
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

	assign w_start_of_sub_state	=  mem_vdp_dh_clk || (ff_main_state != c_main_state_ready);
	assign w_end_of_sub_state	= !mem_vdp_dh_clk || (ff_main_state != c_main_state_ready);

	always @( posedge mem_clk ) begin
		if( sync_reset ) begin
			ff_do_refresh	<= 1'b0;
		end
		else if( ff_sub_state_drive ) begin
			if( ff_sub_state == c_sub_state_end_of_sub_state ) begin
				if( iSltRfsh_n == 1'b0 && mem_vdp_dl_clk == 1'b1 ) begin
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
	//	Main Timer
	// --------------------------------------------------------------------
	always @( posedge mem_clk ) begin
		case( ff_main_state )
		c_main_state_begin_first_wait:
			ff_main_timer	<= 16'd42960;		//	500usec
		c_main_state_send_precharge_all:
			ff_main_timer	<= 16'd5;
		c_main_state_send_refresh_all1:
			ff_main_timer	<= 16'd15;
		c_main_state_send_refresh_all2:
			ff_main_timer	<= 16'd15;
		c_main_state_send_mode_register_set:
			ff_main_timer	<= 16'd2;
		default:
			//	ff_main_timer is decrement counter.
			if( !w_end_of_main_timer ) begin
				ff_main_timer	<= ff_main_timer - 16'd1;
			end
			else begin
				//	hold
			end
		endcase
	end

	assign w_end_of_main_timer	= (ff_main_timer == 16'd0) ? 1'b1 : 1'b0;

	// --------------------------------------------------------------------
	//	Data mask
	// --------------------------------------------------------------------
	function [3:0] func_mask(
		input	[1:0]	address
	);
		case( address )
			2'd0:		func_mask = 4'b1110;
			2'd1:		func_mask = 4'b1101;
			2'd2:		func_mask = 4'b1011;
			2'd3:		func_mask = 4'b0111;
			default:	func_mask = 4'b1111;
		endcase
	endfunction

	// --------------------------------------------------------------------
	//	SDRAM Command Signal
	// --------------------------------------------------------------------
	always @( posedge mem_clk ) begin
		case( ff_main_state )
		c_main_state_send_precharge_all:
			begin
				ff_sdram_command	<= c_sdr_command_precharge_all;
				ff_sdr_dq_mask		<= 4'b1111;			//	all disable
			end
		c_main_state_send_refresh_all1, c_main_state_send_refresh_all2:
			begin
				ff_sdram_command	<= c_sdr_command_refresh;
				ff_sdr_dq_mask		<= 4'b0000;			//	all enable
			end
		c_main_state_send_mode_register_set:
			begin
				ff_sdram_command	<= c_sdr_command_mode_register_set;
				ff_sdr_dq_mask		<= 4'b1111;			//	all disable
			end
		default:
			if( ff_sub_state_drive ) begin
				case( ff_sub_state )
				c_sub_state_activate:
					if( ff_do_refresh ) begin
						ff_sdram_command	<= c_sdr_command_refresh;
						ff_sdr_dq_mask		<= 4'b0000;		//	all enable
					end
					else begin
						ff_sdram_command	<= c_sdr_command_activate;
						ff_sdr_dq_mask		<= 4'b1111;		//	all disable
					end
				c_sub_state_read_or_write:
					if( ff_do_refresh ) begin
						ff_sdram_command	<= c_sdr_command_no_operation;
						ff_sdr_dq_mask		<= 4'b1111;		//	all disable
					end
					else begin
						if( ff_main_state > c_main_state_wait_mode_register_set && ff_main_state != c_main_state_ready ) begin
							ff_sdram_command	<= c_sdr_command_write;
							ff_sdr_dq_mask		<= func_mask( address[1:0] );
						end
						else begin
							if( wr && mem_req ) begin
								ff_sdram_command	<= c_sdr_command_write;
								ff_sdr_dq_mask		<= ~address[0];
							end
							else begin
								ff_sdram_command	<= c_sdr_command_read;
								ff_sdr_dq_mask		<= func_mask( address[1:0] );
							end
						end
					end
				default:
					begin
						ff_sdram_command	<= c_sdr_command_no_operation;
						ff_sdr_dq_mask		<= 4'b1111;
					end
				endcase
			end
			else begin
				ff_sdram_command	<= c_sdr_command_no_operation;
				ff_sdr_dq_mask		<= 4'b1111;
			end
		endcase
	end

	always @( posedge mem_clk ) begin
		if( !ff_sub_state_drive ) begin
			ff_sdr_address <= { 2'b00,		//	Bank
				3'b000,						//	Reserved
				1'b1,						//	0: Burst Write, 1: Single Write
				2'b00,						//	Operation mode
				3'b010,						//	CAS Latency 010: 2cyc, 011: 3cyc, others: Reserved
				1'b0,						//	0: Sequential Access, 1: Interleave Access
				3'b000 };					//	Burst length 000: 1, 001: 2, 010: 4, 011: 8, 111: full page (Sequential Access only), others: Reserved
		end
		else begin
			case( ff_sub_state )
			c_sub_state_activate:
				if( ff_main_state == c_main_state_ready ) begin
					ff_sdr_address <= { address[24:23], address[13:1] };		// cpu read/write
				end
				else begin
					ff_sdr_address[14:13]	<= 2'd0;
					ff_sdr_address[12: 0]	<= 13'd0;												// Initialize phase
				end
			c_sub_state_read_or_write:
				begin
					ff_sdr_address[12:9] <= 4'b0010;													// A10 = 1 => enable auto precharge
					if( ff_main_state == c_main_state_ready ) begin
						ff_sdr_address[14:13]	<= address[24:23];
						ff_sdr_address[ 8: 0]	<= address[22:14];
					end
					else begin
						ff_sdr_address[14:13]	<= 2'd0;
						case( ff_main_state )
						c_main_state_wait_clear_esescc2:		//	ESE-SCC2 400000h
							ff_sdr_address[12: 0]	<= 13'b000_0100_0000_00;
						c_main_state_wait_clear_esescc1:		//	ESE-SCC1 500000h
							ff_sdr_address[12: 0]	<= 13'b000_0101_0000_00;
						c_main_state_wait_clear_eseram:			//	ESE-RAM  600000h
							ff_sdr_address[12: 0]	<= 13'b000_0110_0000_00;
						default:
							ff_sdr_address[12: 0]	<= 13'd0;
						endcase
					end
				end
			default:
				begin
					//	hold
				end
			endcase
		end
	end

	always @( posedge mem_clk ) begin
		if( ff_sub_state_drive && ff_sub_state == c_sub_state_read_or_write ) begin
			if( ff_main_state == c_main_state_ready ) begin
				ff_sdr_data <= { wdata, wdata, wdata, wdata };
			end
			else begin
				ff_sdr_data <= 32'd0;
			end
		end
		else begin
			ff_sdr_data <= 32'dz;
		end
	end

	always @( posedge mem_clk ) begin
		if( ff_sub_state_drive && ff_sub_state == c_sub_state_data_fetch ) begin
			if( address[0] == 1'b0 ) begin
				ff_rdata <= pMemDat[ 7:0];
			end
			else begin
				ff_rdata <= pMemDat[15:8];
			end
		end
	end

	always @( posedge reset or posedge clk21m ) begin
		if( reset ) begin
			ff_rdata_en <= 1'b0;
		end
		else if( mem_req == 1'b0 ) begin
			ff_rdata_en <= 1'b0;
		end
		else if( mem_vdp_dl_clk == 1'b0 && mem_vdp_dh_clk == 1'b1 ) begin
			ff_rdata_en <= 1'b1;
		end
	end

	assign O_sdram_cke			= 1'b1;
	assign O_sdram_cs_n			= ff_sdram_command[3];
	assign O_sdram_ras_n		= ff_sdram_command[2];
	assign O_sdram_cas_n		= ff_sdram_command[1];
	assign O_sdram_wen_n		= ff_sdram_command[0];

	assign O_sdram_dqm			= ff_sdr_dq_mask;
	assign O_sdram_ba[1]		= ff_sdr_address[14];
	assign O_sdram_ba[0]		= ff_sdr_address[13];

	assign O_sdram_addr			= ff_sdr_address[12:0];
	assign IO_sdram_dq			= ff_sdr_data;

	assign rdata				= ff_rdata;
	assign rdata_en				= ff_rdata_en;
endmodule
