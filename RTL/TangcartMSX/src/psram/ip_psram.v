// -----------------------------------------------------------------------------
//	ip_psram.v
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
//		PSRAM Controller wapper
// -----------------------------------------------------------------------------

module ip_psram (
	//	Internal I/F
	input			n_reset,
	input			clk,
	input			mem_clk,
	input			lock,
	//	1st PSRAM
	input			rd0,			// Set to 1 to read
	input			wr0,			// Set to 1 to write
	output			busy0,			// Busy signal
	input	[21:0]	address0,		// Byte address
	input	[7:0]	wdata0,
	output	[7:0]	rdata0,
	output			rdata0_en,
	//	2nd PSRAM
	input			rd1,			// Set to 1 to read
	input			wr1,			// Set to 1 to write
	output			busy1,			// Busy signal
	input	[21:0]	address1,		// Byte address
	input	[7:0]	wdata1,
	output	[7:0]	rdata1,
	output			rdata1_en,

	//	PSRAM I/F
	output	[1:0]	O_psram_ck,
	output	[1:0]	O_psram_ck_n,
	inout	[1:0]	IO_psram_rwds,
	inout	[15:0]	IO_psram_dq,
	output	[1:0]	O_psram_reset_n,
	output	[1:0]	O_psram_cs_n
);
	wire				w_init_complete0;
	wire				w_init_complete1;
	wire				w_cmd0_en;
	wire				w_cmd1_en;
	wire		[31:0]	w_wr_data0;
	wire		[31:0]	w_wr_data1;
	wire		[3:0]	w_wr_mask0;
	wire		[3:0]	w_wr_mask1;
	reg			[3:0]	ff_wait_cnt0;
	reg			[3:0]	ff_wait_cnt1;
	reg			[7:0]	ff_rd_data0;
	reg			[7:0]	ff_rd_data1;
	wire				w_rdata0_en;
	wire				w_rdata1_en;
	reg					ff_rd_data0_en;
	reg					ff_rd_data1_en;
	localparam	[3:0]	WAIT_CNT		= 14;

	PSRAM_Memory_Interface_2CH_Top u_gowin_psram_if_2ch (
		.clk				( clk						), //input clk
		.rst_n				( n_reset					), //input rst_n
		.O_psram_ck			( O_psram_ck				), //output [1:0] O_psram_ck
		.O_psram_ck_n		( O_psram_ck_n				), //output [1:0] O_psram_ck_n
		.IO_psram_rwds		( IO_psram_rwds				), //inout [1:0] IO_psram_rwds
		.O_psram_reset_n	( O_psram_reset_n			), //output [1:0] O_psram_reset_n
		.IO_psram_dq		( IO_psram_dq				), //inout [15:0] IO_psram_dq
		.O_psram_cs_n		( O_psram_cs_n				), //output [1:0] O_psram_cs_n
		.init_calib0		( w_init_complete0			), //output init_calib0
		.init_calib1		( w_init_complete1			), //output init_calib1
		.clk_out			( 							), //output clk_out
		.cmd0				( wr0						), //input cmd0
		.cmd1				( wr1						), //input cmd1
		.cmd_en0			( w_cmd0_en					), //input cmd_en0
		.cmd_en1			( w_cmd1_en					), //input cmd_en1
		.addr0				( { 1'b0, address0[21:2] }	), //input [20:0] addr0
		.addr1				( { 1'b0, address1[21:2] }	), //input [20:0] addr1
		.wr_data0			( wr_data0_i				), //input [31:0] wr_data0
		.wr_data1			( wr_data1_i				), //input [31:0] wr_data1
		.rd_data0			( w_rd_data0				), //output [31:0] rd_data0
		.rd_data1			( w_rd_data1				), //output [31:0] rd_data1
		.rd_data_valid0		( w_rdata0_en				), //output rd_data_valid0
		.rd_data_valid1		( w_rdata1_en				), //output rd_data_valid1
		.data_mask0			( w_wr_mask0				), //input [3:0] data_mask0
		.data_mask1			( w_wr_mask1				), //input [3:0] data_mask1
		.memory_clk			( mem_clk					), //input memory_clk
		.pll_lock			( lock						)  //input pll_lock
	);

	// --------------------------------------------------------------------
	//	Busy signal
	// --------------------------------------------------------------------
	assign busy0		= ~w_init_complete0 | (ff_wait_cnt0 != 4'd0);
	assign busy1		= ~w_init_complete1 | (ff_wait_cnt1 != 4'd0);

	// --------------------------------------------------------------------
	//	Command
	// --------------------------------------------------------------------
	assign w_cmd0_en	= wr0 | rd0;
	assign w_cmd1_en	= wr1 | rd1;

	always @( negedge n_reset or posedge clk ) begin
		if( !n_reset ) begin
			ff_wait_cnt0 <= 4'd0;
		end
		else if( ff_wait_cnt0 != 4'd0 ) begin
			ff_wait_cnt0 <= ff_wait_cnt0 - 4'd1;
		end
		else if( w_cmd0_en ) begin
			ff_wait_cnt0 <= WAIT_CNT;
		end
		else begin
			//	hold
		end
	end

	always @( negedge n_reset or posedge clk ) begin
		if( !n_reset ) begin
			ff_wait_cnt1 <= 4'd0;
		end
		else if( ff_wait_cnt1 != 4'd0 ) begin
			ff_wait_cnt1 <= ff_wait_cnt1 - 4'd1;
		end
		else if( w_cmd1_en ) begin
			ff_wait_cnt1 <= WAIT_CNT;
		end
		else begin
			//	hold
		end
	end

	// --------------------------------------------------------------------
	//	Write data signal
	// --------------------------------------------------------------------
	assign w_wr_data0	= { wdata0, wdata0, wdata0, wdata0 };
	assign w_wr_data1	= { wdata1, wdata1, wdata1, wdata1 };

	function [3:0] func_mask_decode(
		input	[1:0]	address,
		input			cmd_en
	);
		if( cmd_en ) begin
			case( address )
			2'b00:		func_mask_decode = 4'b1110;
			2'b01:		func_mask_decode = 4'b1101;
			2'b10:		func_mask_decode = 4'b1011;
			2'b11:		func_mask_decode = 4'b0111;
			default:	func_mask_decode = 4'b1110;
			endcase
		end
		else begin
			func_mask_decode = 4'b1111;
		end
	endfunction

	assign w_wr_mask0	= func_mask_decode( address0[1:0], w_cmd0_en );
	assign w_wr_mask1	= func_mask_decode( address1[1:0], w_cmd1_en );

	// --------------------------------------------------------------------
	//	Read data signal
	// --------------------------------------------------------------------
	function [7:0] func_rd_data(
		input	[1:0]	address,
		input	[31:0]	rd_data
	);
		case( address )
		2'b00:		func_rd_data = rd_data[ 7: 0];
		2'b01:		func_rd_data = rd_data[15: 8];
		2'b10:		func_rd_data = rd_data[23:16];
		2'b11:		func_rd_data = rd_data[31:24];
		default:	func_rd_data = rd_data[ 7: 0];
		endcase
	endfunction

	always @( negedge n_reset or posedge clk ) begin
		if( !n_reset ) begin
			ff_rd_data0_en	<= 1'b0;
			ff_rd_data0		<= 8'd0;
		end
		else if( rd0 ) begin
			ff_rd_data0_en	<= 1'b0;
			ff_rd_data0		<= 8'd0;
		end
		else if( !ff_rd_data0_en && w_rdata0_en ) begin
			ff_rd_data0_en	<= 1'b1;
			ff_rd_data0		<= func_rd_data( address0[1:0], w_rd_data0 );
		end
		else begin
			//	hold
		end
	end

	always @( negedge n_reset or posedge clk ) begin
		if( !n_reset ) begin
			ff_rd_data1_en	<= 1'b0;
			ff_rd_data1		<= 8'd0;
		end
		else if( rd1 ) begin
			ff_rd_data1_en	<= 1'b0;
			ff_rd_data1		<= 8'd0;
		end
		else if( !ff_rd_data1_en && w_rdata1_en ) begin
			ff_rd_data1_en	<= 1'b1;
			ff_rd_data1		<= func_rd_data( address1[1:0], w_rd_data1 );
		end
		else begin
			//	hold
		end
	end

	assign rdata0_en	= ff_rd_data0_en;
	assign rdata0		= ff_rd_data0;
	assign rdata1_en	= ff_rd_data1_en;
	assign rdata1		= ff_rd_data1;
endmodule
