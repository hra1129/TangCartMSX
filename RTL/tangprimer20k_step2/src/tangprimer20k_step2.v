// -----------------------------------------------------------------------------
//	tangprimer20k_step2.v
//	Copyright (C)2025 Takayuki Hara (HRA!)
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

module tangprimer20k_step2 (
	input			clk27m,				//	clk27m			H11
	input	[4:0]	button,				//	button[4:0]		C7,  D7,  T2,  T3,  T10
	output	[5:0]	led,				//	led[5:0]		L16, L14, N14, N16, A13, C13
	//	DDR3-SDRAM I/F
	output	[13:0]	ddr_addr,			//	DDR3_A[13:0]	C8, A3, B7, K3, F9, A5, D8, B1, E6, C4, F8, D6, A4, F7
	output	[2:0]	ddr_ba,				//	DDR3_BA[2:0]	H5, D3, H4
	output			ddr_cs_n,			//	DDR3_CS_N		P5
	output			ddr_ras_n,			//	DDR3_RAS_N		J3
	output			ddr_cas_n,			//	DDR3_CAS_N		K3
	output			ddr_we_n,			//	DDR3_WE_N		L3
	output			ddr_clk,			//	DDR3_CK_P		J1
	output			ddr_clk_n,			//	DDR3_CK_N		J3
	output			ddr_cke,			//	DDR3_CKEN		J2
	output			ddr_odt,			//	DDR3_ODT0_N		R3
	output			ddr_reset_n,		//	DDR3_RST_N		B9
	output	[1:0]	ddr_dqm,			//	DDR3_DQM[1:0]	K5, G1
	inout	[15:0]	ddr_dq,				//	DDR3_DQ[15:0]	M2, R1, H3, P4, L1, N2, K4, M3, B3, E1, C1, E2, F3, F4, F5, G5
	inout	[1:0]	ddr_dqs,			//	DDR3_DQS_P[1:0]	J5, G2
	inout	[1:0]	ddr_dqs_n			//	DDR3_DQS_N[1:0]	K6, G3
);
	wire			clk85m;
	wire			pll_lock;
	reg		[5:0]	ff_led		= 6'd0;
	reg		[20:0]	ff_timer	= 21'd0;

	wire			init_calib_complete;
	wire			cmd_ready;
	wire	[2:0]	cmd;
	wire			cmd_en;
	wire	[27:0]	addr;
	wire			wr_data_rdy;
	wire	[127:0]	wr_data;
	wire			wr_data_en;
	wire			wr_data_end;
	wire	[7:0]	wr_data_mask;
	wire	[127:0]	rd_data;
	wire			rd_data_valid;
	wire			rd_data_end;
	wire			sr_req;
	wire			ref_req;
	wire			sr_ack;
	wire			ref_ack;
	wire			burst;

	always @( posedge clk85m ) begin
		ff_timer <= ff_timer + 21'd1;
	end

	always @( posedge clk85m ) begin
		if( ff_timer == 21'd0 ) begin
			ff_led <= ff_led + 6'd1;
		end
		else if( button[0] == 1'b0 ) begin
			ff_led <= 6'd0;
		end
		else if( button[1] == 1'b0 ) begin
			ff_led <= 6'd1;
		end
		else if( button[2] == 1'b0 ) begin
			ff_led <= 6'd2;
		end
		else if( button[3] == 1'b0 ) begin
			ff_led <= 6'd4;
		end
		else if( button[4] == 1'b0 ) begin
			ff_led <= 6'd8;
		end
		else begin
			//	hold
		end
	end

	assign led	= ~ff_led;

	// --------------------------------------------------------------------
	//	CLOCK
	// --------------------------------------------------------------------
	Gowin_rPLL u_pll (
		.clkout					( clk85m				),		//	output clkout
		.lock					( pll_lock				),		//	output lock
		.clkin					( clk27m				)		//	input clkin
	);

	// --------------------------------------------------------------------
	//	DRAM Controller
	// --------------------------------------------------------------------
	DDR3_Memory_Interface_Top u_ddr3_if (
		.clk					( clk27m				),		//	input clk
		.memory_clk				( clk85m				),		//	input memory_clk
		.pll_lock				( pll_lock				),		//	input pll_lock
		.rst_n					( 1'b1					),		//	input rst_n
		.clk_out				( 						),		//	output clk_out
		.ddr_rst				( 						),		//	output ddr_rst
		.init_calib_complete	( init_calib_complete	),		//	output init_calib_complete
		.cmd_ready				( cmd_ready				),		//	output cmd_ready
		.cmd					( cmd					),		//	input [2:0] cmd
		.cmd_en					( cmd_en				),		//	input cmd_en
		.addr					( addr					),		//	input [27:0] addr
		.wr_data_rdy			( wr_data_rdy			),		//	output wr_data_rdy
		.wr_data				( wr_data				),		//	input [127:0] wr_data
		.wr_data_en				( wr_data_en			),		//	input wr_data_en
		.wr_data_end			( wr_data_end			),		//	input wr_data_end
		.wr_data_mask			( wr_data_mask			),		//	input [7:0] wr_data_mask
		.rd_data				( rd_data				),		//	output [127:0] rd_data
		.rd_data_valid			( rd_data_valid			),		//	output rd_data_valid
		.rd_data_end			( rd_data_end			),		//	output rd_data_end
		.sr_req					( sr_req				),		//	input sr_req
		.ref_req				( ref_req				),		//	input ref_req
		.sr_ack					( sr_ack				),		//	output sr_ack
		.ref_ack				( ref_ack				),		//	output ref_ack
		.burst					( burst					),		//	input burst
		.O_ddr_addr				( ddr_addr				),		//	output [13:0] O_ddr_addr
		.O_ddr_ba				( ddr_ba				),		//	output [2:0] O_ddr_ba
		.O_ddr_cs_n				( ddr_cs_n				),		//	output O_ddr_cs_n
		.O_ddr_ras_n			( ddr_ras_n				),		//	output O_ddr_ras_n
		.O_ddr_cas_n			( ddr_cas_n				),		//	output O_ddr_cas_n
		.O_ddr_we_n				( ddr_we_n				),		//	output O_ddr_we_n
		.O_ddr_clk				( ddr_clk				),		//	output O_ddr_clk
		.O_ddr_clk_n			( ddr_clk_n				),		//	output O_ddr_clk_n
		.O_ddr_cke				( ddr_cke				),		//	output O_ddr_cke
		.O_ddr_odt				( ddr_odt				),		//	output O_ddr_odt
		.O_ddr_reset_n			( ddr_reset_n			),		//	output O_ddr_reset_n
		.O_ddr_dqm				( ddr_dqm				),		//	output [1:0] O_ddr_dqm
		.IO_ddr_dq				( ddr_dq				),		//	inout [15:0] IO_ddr_dq
		.IO_ddr_dqs				( ddr_dqs				),		//	inout [1:0] IO_ddr_dqs
		.IO_ddr_dqs_n			( ddr_dqs_n				)		//	inout [1:0] IO_ddr_dqs_n
	);

endmodule
