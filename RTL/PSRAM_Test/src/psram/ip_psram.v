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
	reg			[7:0]	ff_rd_data0;
	reg			[7:0]	ff_rd_data1;
	wire		[31:0]	w_rd_data0;
	wire		[31:0]	w_rd_data1;
	wire				w_rdata0_en;
	wire				w_rdata1_en;
	reg					ff_rd_data0_en;
	reg					ff_rd_data1_en;
	reg					ff_rd_address0;
	reg					ff_rd_address1;
	reg					ff_rd_data0_dump;
	reg					ff_rd_data1_dump;

	PSRAM_Memory_Interface_2CH_Top u_gowin_psram_if_2ch (
		.clk				( clk					), //input clk
		.rst_n				( n_reset				), //input rst_n
		.O_psram_ck			( O_psram_ck			), //output [1:0] O_psram_ck
		.O_psram_ck_n		( O_psram_ck_n			), //output [1:0] O_psram_ck_n
		.IO_psram_rwds		( IO_psram_rwds			), //inout [1:0] IO_psram_rwds
		.O_psram_reset_n	( O_psram_reset_n		), //output [1:0] O_psram_reset_n
		.IO_psram_dq		( IO_psram_dq			), //inout [15:0] IO_psram_dq
		.O_psram_cs_n		( O_psram_cs_n			), //output [1:0] O_psram_cs_n
		.init_calib0		( w_init_complete0		), //output init_calib0
		.init_calib1		( w_init_complete1		), //output init_calib1
		.clk_out			( 						), //output clk_out
		.cmd0				( wr0					), //input cmd0
		.cmd1				( wr1					), //input cmd1
		.cmd_en0			( w_cmd0_en				), //input cmd_en0
		.cmd_en1			( w_cmd1_en				), //input cmd_en1
		.addr0				( address0[21:1]		), //input [20:0] addr0
		.addr1				( address1[21:1]		), //input [20:0] addr1
		.wr_data0			( w_wr_data0			), //input [31:0] wr_data0
		.wr_data1			( w_wr_data1			), //input [31:0] wr_data1
		.rd_data0			( w_rd_data0			), //output [31:0] rd_data0
		.rd_data1			( w_rd_data1			), //output [31:0] rd_data1
		.rd_data_valid0		( w_rdata0_en			), //output rd_data_valid0
		.rd_data_valid1		( w_rdata1_en			), //output rd_data_valid1
		.data_mask0			( w_wr_mask0			), //input [3:0] data_mask0
		.data_mask1			( w_wr_mask1			), //input [3:0] data_mask1
		.memory_clk			( mem_clk				), //input memory_clk
		.pll_lock			( lock					)  //input pll_lock
	);

	// --------------------------------------------------------------------
	//	Busy signal
	// --------------------------------------------------------------------
	assign busy0		= ~w_init_complete0;
	assign busy1		= ~w_init_complete1;

	// --------------------------------------------------------------------
	//	Command
	// --------------------------------------------------------------------
	assign w_cmd0_en	= wr0 | rd0;
	assign w_cmd1_en	= wr1 | rd1;

	// --------------------------------------------------------------------
	//	Write data signal
	// --------------------------------------------------------------------
	assign w_wr_data0	= address0[0] ? { 8'd0, wdata0, 8'd0, 8'd0 } : { wdata0, 8'd0, 8'd0, 8'd0 };
	assign w_wr_data1	= address1[0] ? { 8'd0, wdata1, 8'd0, 8'd0 } : { wdata1, 8'd0, 8'd0, 8'd0 };

	function [3:0] func_mask_decode(
		input			address,
		input			cmd_en
	);
		if( cmd_en ) begin
			if( !address ) begin
				func_mask_decode = 4'b0111;
			end
			else begin
				func_mask_decode = 4'b1011;
			end
		end
		else begin
			func_mask_decode = 4'b1111;
		end
	endfunction

	assign w_wr_mask0	= func_mask_decode( address0[0], wr0 );
	assign w_wr_mask1	= func_mask_decode( address1[0], wr1 );

	// --------------------------------------------------------------------
	//	Read data signal
	// --------------------------------------------------------------------
	function [7:0] func_rd_data(
		input			address,
		input	[31:0]	rd_data
	);
		if( !address ) begin
			func_rd_data = rd_data[31:24];
		end
		else begin
			func_rd_data = rd_data[23:16];
		end
	endfunction

	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_rd_data0_en		<= 1'b0;
			ff_rd_data0_dump	<= 1'b0;
			ff_rd_data0			<= 8'd0;
		end
		else if( rd0 ) begin
			ff_rd_data0_dump	<= 1'b0;
			ff_rd_address0		<= address0[0];
		end
		else if( !ff_rd_data0_dump && w_rdata0_en ) begin
			ff_rd_data0_en		<= 1'b1;
			ff_rd_data0_dump	<= 1'b1;
			ff_rd_data0			<= func_rd_data( ff_rd_address0, w_rd_data0 );
		end
		else begin
			ff_rd_data0_en		<= 1'b0;
			ff_rd_data0			<= 8'd0;
		end
	end

	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_rd_data1_en		<= 1'b0;
			ff_rd_data1_dump	<= 1'b0;
			ff_rd_data1			<= 8'd0;
		end
		else if( rd1 ) begin
			ff_rd_data1_dump	<= 1'b0;
			ff_rd_address1		<= address1[0];
		end
		else if( !ff_rd_data1_dump && w_rdata1_en ) begin
			ff_rd_data1_en		<= 1'b1;
			ff_rd_data1_dump	<= 1'b1;
			ff_rd_data1			<= func_rd_data( ff_rd_address1, w_rd_data1 );
		end
		else begin
			ff_rd_data1_en		<= 1'b0;
			ff_rd_data1			<= 8'd0;
		end
	end

	assign rdata0_en	= ff_rd_data0_en;
	assign rdata0		= ff_rd_data0_en ? ff_rd_data0 : 8'd0;
	assign rdata1_en	= ff_rd_data1_en;
	assign rdata1		= ff_rd_data1_en ? ff_rd_data1 : 8'd0;
endmodule
