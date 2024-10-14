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

module ip_sdram #(
	parameter		FREQ = 54_000_000	//	Hz
) (
	//	Internal I/F
	input			n_reset,
	input			clk,				// 54MHz
	input			clk_sdram,			// 54MHz with 180degree delay
	//	CPU I/F
	input			rd_n,				// Set to 0 to read
	input			wr_n,				// Set to 0 to write
	output			busy,
	input	[22:0]	address,			// Byte address (8MBytes)
	input	[7:0]	wdata,
	output	[15:0]	rdata,
	output			rdata_en,
	//	SDRAM I/F
	output			O_sdram_clk,
	output			O_sdram_cke,
	output			O_sdram_cs_n,		// chip select
	output			O_sdram_ras_n,		// row address select
	output			O_sdram_cas_n,		// columns address select
	output			O_sdram_wen_n,		// write enable
	inout	[31:0]	IO_sdram_dq,		// 32 bit bidirectional data bus
	output	[10:0]	O_sdram_addr,		// 11 bit multiplexed address bus
	output	[1:0]	O_sdram_ba,			// two banks
	output	[3:0]	O_sdram_dqm			// data mask
);
	localparam CLOCK_TIME		= 1_000_000_000 / FREQ;		// nsec
	localparam TIMER_COUNT		= 120_000 / CLOCK_TIME;		// clock
	localparam TIMER_BITS		= $clog2(TIMER_COUNT + 1);
	localparam REFRESH_COUNT	= 15_000 / CLOCK_TIME;		// clock
	localparam REFRESH_BITS		= $clog2(REFRESH_COUNT + 1);
	localparam REFRESH_NONE		= 10_000 / CLOCK_TIME;		// clock

	// --------------------------------------------------------------------
	//	Timer for initialization process
	// --------------------------------------------------------------------
	reg		[TIMER_BITS - 1: 0]		ff_timer;
	wire							w_initial_done;

	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_timer <= 'd0;
		end
		else if( w_initial_done ) begin
			//	hold
		end
		else begin
			ff_timer <= ff_timer + 'd1;
		end
	end
	assign w_initial_done	= (ff_timer == TIMER_COUNT) ? 1'b1: 1'b0;

	// --------------------------------------------------------------------
	//	State machine
	// --------------------------------------------------------------------
	localparam		ST_INIT_WAIT_TIMER		= 6'd0;
	localparam		ST_INIT_PRECHARGE		= 6'd1;
	localparam		ST_INIT_AUTO_REFRESH1	= 6'd2;
	localparam		ST_INIT_AUTO_REFRESH2	= 6'd3;
	localparam		ST_INIT_LMR				= 6'd4;
	localparam		ST_INIT_ACTIVE			= 6'd5;
	localparam		ST_IDLE					= 6'd6;
	localparam		ST_WRITE				= 6'd7;
	localparam		ST_WRITE_PRECHARGE		= 6'd9;
	localparam		ST_WRITE_AUTO_REFRESH	= 6'd10;
	localparam		ST_READ					= 6'd11;
	localparam		ST_READ_PRECHARGE		= 6'd12;
	localparam		ST_READ_AUTO_REFRESH	= 6'd13;
	localparam		ST_NOP1					= 6'd14;
	localparam		ST_NOP2					= 6'd15;
	localparam		ST_NOP3					= 6'd16;
	reg		[5:0]	ff_state		= ST_INIT_WAIT_TIMER;
	reg		[5:0]	ff_next_state;

	localparam		CMD_NOP					= 3'b111;
	localparam		CMD_PRECHARGE			= 3'b010;
	localparam		CMD_AUTO_REFRESH		= 3'b001;
	localparam		CMD_LOAD_MODE_REGISTER	= 3'b000;
	localparam		CMD_ACTIVE				= 3'b011;
	localparam		CMD_WRITE				= 3'b100;
	localparam		CMD_READ				= 3'b101;
	reg		[2:0]				ff_command;
	reg		[2:0]				ff_next_command;

	reg		[3:0]				ff_data_mask;
	reg		[2:0]				ff_bank;
	reg		[10:0]				ff_row;
	reg		[10:0]				ff_address;
	reg		[7:0]				ff_data;
	reg							ff_write;
	reg							ff_read;
	reg		[15:0]				ff_rdata;
	reg							ff_rdata_en;
	reg		[7:0]				ff_column;
	reg							ff_word_sel;
	reg		[REFRESH_BITS-1:0]	ff_refresh_timer;
	reg							ff_busy;

	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_busy				<= 1'b0;
		end
		else if( ff_state == ST_IDLE ) begin
			ff_busy				<= 1'b0;
		end
		else begin
			ff_busy				<= 1'b1;
		end
	end

	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_refresh_timer	<= 'd0;
		end
		else if( ff_command == CMD_AUTO_REFRESH ) begin
			ff_refresh_timer	<= 'd0;
		end
		else if( ff_refresh_timer == REFRESH_COUNT ) begin
			//	hold
		end
		else begin
			ff_refresh_timer	<= ff_refresh_timer + 'd1;
		end
	end

	always @( posedge clk_sdram ) begin
		if( !n_reset ) begin
			ff_state			<= ST_INIT_WAIT_TIMER;
			ff_command			<= CMD_NOP;
			ff_data_mask		<= 4'b1111;
			ff_bank				<= 3'b000;
			ff_address			<= 11'd0;
			ff_write			<= 1'b0;
			ff_read				<= 1'b0;
			ff_word_sel			<= 1'b0;
		end
		else begin
			case( ff_state )
			// ----------------------------------------------------------------
			//	Initialzation process
			// ----------------------------------------------------------------
			ST_INIT_WAIT_TIMER: begin
					if( w_initial_done ) begin
						ff_state		<= ST_INIT_PRECHARGE;
						ff_command		<= CMD_PRECHARGE;
						ff_address		<= 11'b100_0000_0000;
					end
					else begin
						ff_command		<= CMD_NOP;
					end
				end
			ST_INIT_PRECHARGE: begin
					ff_state			<= ST_INIT_AUTO_REFRESH1;
					ff_command			<= CMD_AUTO_REFRESH;
				end
			ST_INIT_AUTO_REFRESH1: begin
					ff_state			<= ST_NOP3;
					ff_command			<= CMD_NOP;
					ff_next_state		<= ST_INIT_AUTO_REFRESH2;
					ff_next_command		<= CMD_AUTO_REFRESH;
					ff_address			<= { 1'b0, 1'b0, 2'b00, 3'b010, 1'b0, 3'b000 };		//	CAS Latency: 2cyc, Burst length: 1
//					ff_address			<= { 1'b0, 1'b0, 2'b00, 3'b011, 1'b0, 3'b000 };		//	CAS Latency: 3cyc, Burst length: 1
				end
			ST_INIT_AUTO_REFRESH2: begin
					ff_state			<= ST_NOP3;
					ff_command			<= CMD_NOP;
					ff_next_state		<= ST_INIT_LMR;
					ff_next_command		<= CMD_LOAD_MODE_REGISTER;
				end
			ST_INIT_LMR: begin
					ff_state			<= ST_NOP1;
					ff_command			<= CMD_NOP;
					ff_next_state		<= ST_INIT_ACTIVE;
					ff_next_command		<= CMD_ACTIVE;
					ff_address			<= 11'd0;
					ff_bank				<= 3'd0;
					ff_row				<= 11'd0;
				end
			ST_INIT_ACTIVE: begin
					ff_state			<= ST_NOP2;
					ff_command			<= CMD_NOP;
					ff_next_state		<= ST_IDLE;
					ff_next_command		<= CMD_NOP;
				end
			// ----------------------------------------------------------------
			//	Idle process
			// ----------------------------------------------------------------
			ST_IDLE: begin
					if( !wr_n ) begin
						ff_state			<= ST_NOP2;
						ff_next_state		<= ST_WRITE;
						ff_next_command		<= CMD_WRITE;
						if( ff_bank == { 1'b0, address[22:21] } && ff_row == address[20:10] ) begin
							ff_command			<= CMD_NOP;
						end
						else begin
							ff_command			<= CMD_ACTIVE;
						end
						ff_bank				<= { 1'b0, address[22:21] };	//	Bank Address
						ff_address			<= address[20:10];				//	Row Address
						ff_row				<= address[20:10];				//	Row Address
						ff_column			<= address[ 9: 2];				//	Column Address
						ff_data_mask		<= (address[1:0] == 2'b00) ? 4'b1110 :
						            		   (address[1:0] == 2'b01) ? 4'b1101 :
						            		   (address[1:0] == 2'b10) ? 4'b1011 : 4'b0111;
						ff_data				<= wdata;
						ff_write			<= 1'b0;
					end
					else if( !rd_n ) begin
						ff_state			<= ST_NOP2;
						ff_next_state		<= ST_READ;
						ff_next_command		<= CMD_READ;
						if( ff_bank == { 1'b0, address[22:21] } && ff_row == address[20:10] ) begin
							ff_command			<= CMD_NOP;
						end
						else begin
							ff_command			<= CMD_ACTIVE;
						end
						ff_bank				<= { 1'b0, address[22:21] };	//	Bank Address
						ff_address			<= address[20:10];				//	Row Address
						ff_row				<= address[20:10];				//	Row Address
						ff_column			<= address[ 9: 2];				//	Column Address
						ff_data_mask		<= 4'b0000;
						ff_word_sel			<= address[1];
						ff_write			<= 1'b0;
					end
					else if( ff_refresh_timer == REFRESH_COUNT ) begin
						ff_state			<= ST_WRITE_AUTO_REFRESH;
						ff_command			<= CMD_AUTO_REFRESH;
					end
					else begin
						//	hold
					end
				end
			// ----------------------------------------------------------------
			//	Write process
			// ----------------------------------------------------------------
			ST_WRITE: begin
					ff_state			<= ST_NOP1;
					ff_command			<= CMD_NOP;
					ff_next_state		<= ST_WRITE_PRECHARGE;
					ff_next_command		<= CMD_PRECHARGE;
					ff_write			<= 1'b0;
				end
			ST_WRITE_PRECHARGE: begin
					ff_state			<= ST_NOP1;
					ff_command			<= CMD_NOP;
					if( ff_refresh_timer < REFRESH_NONE ) begin
						ff_next_state		<= ST_IDLE;
						ff_next_command		<= CMD_NOP;
					end
					else begin
						ff_next_state		<= ST_WRITE_AUTO_REFRESH;
						ff_next_command		<= CMD_AUTO_REFRESH;
					end
				end
			ST_WRITE_AUTO_REFRESH: begin
					ff_state			<= ST_NOP3;
					ff_command			<= CMD_NOP;
					ff_next_state		<= ST_IDLE;
					ff_next_command		<= CMD_NOP;
					ff_bank				<= 3'b100;
				end
			ST_READ: begin
					ff_state			<= ST_READ_PRECHARGE;
					ff_command			<= CMD_PRECHARGE;
					ff_write			<= 1'b0;
					ff_address[10]		<= 1'b1;
				end
			ST_READ_PRECHARGE: begin
					ff_state			<= ST_NOP1;						//	CAS Latency 2
					ff_read				<= 1'b1;
					if( ff_refresh_timer < REFRESH_NONE ) begin
						ff_command			<= CMD_NOP;
						ff_next_state		<= ST_IDLE;
						ff_next_command		<= CMD_NOP;
						ff_bank				<= 3'b100;
					end
					else begin
						ff_command			<= CMD_NOP;
						ff_next_state		<= ST_READ_AUTO_REFRESH;
						ff_next_command		<= CMD_AUTO_REFRESH;
					end
				end
			ST_READ_AUTO_REFRESH: begin
					ff_state			<= ST_NOP2;
					ff_command			<= CMD_NOP;
					ff_next_state		<= ST_IDLE;
					ff_next_command		<= CMD_NOP;
					ff_bank				<= 3'b100;
				end

			// ----------------------------------------------------------------
			//	Read process
			// ----------------------------------------------------------------

			// ----------------------------------------------------------------
			//	NOP subroutine
			// ----------------------------------------------------------------
			ST_NOP3: begin
					ff_state			<= ST_NOP2;
					ff_command			<= CMD_NOP;
				end
			ST_NOP2: begin
					ff_state			<= ST_NOP1;
					ff_command			<= CMD_NOP;
				end
			ST_NOP1: begin
					ff_state			<= ff_next_state;
					ff_command			<= ff_next_command;
					if( ff_next_command == CMD_WRITE ) begin
						ff_write			<= 1'b1;
						ff_address[10]		<= 1'b0;					//	Disable auto precharge
						ff_address[9:8]		<= 2'b0;					//	N/A
						ff_address[7:0]		<= ff_column;				//	Column address
					end
					else if( ff_next_command == CMD_READ ) begin
						ff_address[10]		<= 1'b0;					//	Disable auto precharge
						ff_address[9:8]		<= 2'b0;					//	N/A
						ff_address[7:0]		<= ff_column;				//	Column address
					end
					if( ff_read ) begin
						ff_read				<= 1'b0;
					end
				end
			// ----------------------------------------------------------------
			//	Others
			// ----------------------------------------------------------------
			default: begin
					ff_state			<= ST_IDLE;
				end
			endcase
		end
	end

	// ----------------------------------------------------------------
	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_rdata_en <= 1'b0;
		end
		else if( ff_state == ST_NOP1 ) begin
			ff_rdata_en <= ff_read;
		end
		else begin
			ff_rdata_en <= 1'b0;
		end
	end

	always @( posedge clk ) begin
		if( ff_read ) begin
 			ff_rdata	<= (ff_word_sel == 1'b0) ? IO_sdram_dq[15: 0]: IO_sdram_dq[31:16];
		end
	end

	// ----------------------------------------------------------------
	//	I/F port assignment
	// ----------------------------------------------------------------
	assign busy				= ff_busy;
	assign rdata			= ff_rdata;
	assign rdata_en			= ff_rdata_en;

	// ----------------------------------------------------------------
	//	SDRAM port assignment
	// ----------------------------------------------------------------
	assign O_sdram_clk		= clk;
	assign O_sdram_cke		= 1'b1;
	assign O_sdram_cs_n		= 1'b0;
	assign O_sdram_ras_n	= ff_command[2];
	assign O_sdram_cas_n	= ff_command[1];
	assign O_sdram_wen_n	= ff_command[0];
	assign O_sdram_dqm		= ff_data_mask;
	assign O_sdram_ba		= ff_bank[1:0];
	assign O_sdram_addr		= ff_address;
	assign IO_sdram_dq		= ff_write ? { ff_data, ff_data, ff_data, ff_data } : 32'hzzzzzzzz;
endmodule
