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
//		SDRAM Controller wrapper
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
	input	[22:0]	address,			// Byte address (8MBytes)
	input	[7:0]	wdata,
	output	[7:0]	rdata,
	output			rdata_en,
	//	SDRAM I/F
	output			O_sdram_clk,
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
	wire			O_sdram_clk;
	wire			O_sdram_cke;
	wire			O_sdram_cs_n;
	wire			O_sdram_cas_n;
	wire			O_sdram_ras_n;
	wire			O_sdram_wen_n;
	wire	[3:0]	O_sdram_dqm;
	wire	[10:0]	O_sdram_addr;
	wire	[1:0]	O_sdram_ba;
	wire	[31:0]	IO_sdram_dq;
	wire			I_sdrc_clk;
	wire			I_sdram_clk;
	wire			I_sdrc_wr_n;
	wire			I_sdrc_rd_n;
	wire	[20:0]	I_sdrc_addr;
	wire	[7:0]	I_sdrc_data_len;
	wire	[3:0]	I_sdrc_dqm;
	wire	[31:0]	I_sdrc_data;
	wire	[31:0]	O_sdrc_data;
	wire			O_sdrc_init_done;
	wire			O_sdrc_busy_n;
	wire			O_sdrc_rd_valid;
	wire			O_sdrc_wrd_ack;
	wire	[31:0]	O_sdrc_data_o;
	wire			O_sdrc_init_done_o;
	wire			O_sdrc_busy_n_o;
	wire			O_sdrc_rd_valid_o;
	wire			O_sdrc_wrd_ack_o;

	// ------------------------------------------------------------------------
	//  64Mbits SDRAM
	// ------------------------------------------------------------------------
	SDRAM_controller_top_SIP u_sdram_controller (
		.O_sdram_clk			( O_sdram_clk				),		// output O_sdram_clk
		.O_sdram_cke			( O_sdram_cke				),		// output O_sdram_cke
		.O_sdram_cs_n			( O_sdram_cs_n				),		// output O_sdram_cs_n
		.O_sdram_cas_n			( O_sdram_cas_n				),		// output O_sdram_cas_n
		.O_sdram_ras_n			( O_sdram_ras_n				),		// output O_sdram_ras_n
		.O_sdram_wen_n			( O_sdram_wen_n				),		// output O_sdram_wen_n
		.O_sdram_dqm			( O_sdram_dqm				),		// output [3:0] O_sdram_dqm
		.O_sdram_addr			( O_sdram_addr				),		// output [10:0] O_sdram_addr
		.O_sdram_ba				( O_sdram_ba				),		// output [1:0] O_sdram_ba
		.IO_sdram_dq			( IO_sdram_dq				),		// inout [31:0] IO_sdram_dq
		.I_sdrc_rst_n			( n_reset					),		// input I_sdrc_rst_n
		.I_sdrc_clk				( clk						),		// input I_sdrc_clk
		.I_sdram_clk			( clk						),		// input I_sdram_clk
		.I_sdrc_selfrefresh		( 1'b1						),		// input I_sdrc_selfrefresh
		.I_sdrc_power_down		( 1'b0						),		// input I_sdrc_power_down
		.I_sdrc_wr_n			( I_sdrc_wr_n_i				),		// input I_sdrc_wr_n
		.I_sdrc_rd_n			( I_sdrc_rd_n_i				),		// input I_sdrc_rd_n
		.I_sdrc_addr			( I_sdrc_addr_i				),		// input [20:0] I_sdrc_addr
		.I_sdrc_data_len		( I_sdrc_data_len_i			),		// input [7:0] I_sdrc_data_len
		.I_sdrc_dqm				( I_sdrc_dqm_i				),		// input [3:0] I_sdrc_dqm
		.I_sdrc_data			( I_sdrc_data_i				),		// input [31:0] I_sdrc_data
		.O_sdrc_data			( O_sdrc_data_o				),		// output [31:0] O_sdrc_data
		.O_sdrc_init_done		( O_sdrc_init_done_o		),		// output O_sdrc_init_done
		.O_sdrc_busy_n			( O_sdrc_busy_n_o			),		// output O_sdrc_busy_n
		.O_sdrc_rd_valid		( O_sdrc_rd_valid_o			),		// output O_sdrc_rd_valid
		.O_sdrc_wrd_ack			( O_sdrc_wrd_ack_o			)		// output O_sdrc_wrd_ack
	);

	assign I_sdrc_wr_n_i		= ~wr;
	assign I_sdrc_rd_n_i		= ~rd;
	assign I_sdrc_addr_i		= address[22:2];
	assign I_sdrc_data_len_i	= 8'd1;
	assign I_sdrc_data_i		= { wdata, wdata, wdata, wdata };
	assign I_sdrc_dqm_i			= (address[1:0] == 2'd0) ? 4'b1110 :
								  (address[1:0] == 2'd0) ? 4'b1101 :
								  (address[1:0] == 2'd0) ? 4'b1011 : 4'b0111;

	assign initial_busy			= ~O_sdrc_init_done_o;
	assign busy					= ~O_sdrc_busy_n_o;
	assign rdata_en				= O_sdrc_rd_valid_o;
	assign rdata				= (address[1:0] == 2'd0) ? O_sdrc_data_o[ 7: 0] :
								  (address[1:0] == 2'd1) ? O_sdrc_data_o[15: 8] :
								  (address[1:0] == 2'd2) ? O_sdrc_data_o[23:16] : O_sdrc_data_o[31:24];
endmodule
