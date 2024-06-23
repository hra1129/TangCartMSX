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
//		PSRAM Controller
// -----------------------------------------------------------------------------

module ip_psram #(
	parameter		CLK_FREQ	= 81000000,		// MHz
	parameter		LATENCY		= 3				// 3: ~83MHz, 4: ~104MHz, 5: ~133MHz, 6: ~166MHz
) (
	//	Internal I/F
	input			n_reset,
	input			clk,
	input			n_clk,
	input			rd,				// Set to 1 to read
	input			wr,				// Set to 1 to write
	output			busy,			// Busy signal
	input	[21:0]	address,		// Byte address
	input	[7:0]	wdata,
	output	[7:0]	rdata,
	output			rdata_en,

	//	PSRAM I/F
	output			O_psram_ck,
	inout			IO_psram_rwds,
	inout	[7:0]	IO_psram_dq,
	output			O_psram_cs_n
);
	localparam		INITIAL_TIME	= ((CLK_FREQ + 999999) / 1000000) * 160;		// Initial time is 160usec
	localparam		COUNT_BITS		= $clog2( INITIAL_TIME + 1 );

	reg		[COUNT_BITS:0]	ff_timer;
	wire					w_timer_end;
	reg		[2:0]	ff_state;
	reg				ff_psram_ck_en;
	wire			w_psram_ck_en;
	reg				ff_ram_cs_n;
	reg				ff_wds_pos;
	reg				ff_wds_neg;
	reg				ff_wds_en;
	reg				ff_d_en;
	wire			w_wds;
	wire			w_wds_en;
	wire			w_rds_pos;
	wire			w_rds_neg;
	wire	[7:0]	w_d_pos;
	wire	[7:0]	w_d_neg;
	wire	[7:0]	w_q_pos;
	wire	[7:0]	w_q_neg;
	wire	[7:0]	w_d;
	wire	[7:0]	w_d_en;
	reg		[63:0]	ff_send_bits;
	reg		[3:0]	ff_remain_count;
	reg				ff_latency;
	reg				ff_address0;
	reg		[7:0]	ff_rdata;
	reg				ff_rdata_en;
	wire			w_transaction_end;

	localparam		ST_INITIAL		= 3'd0;
	localparam		ST_CONFIG		= 3'd1;
	localparam		ST_READ			= 3'd2;
	localparam		ST_WRITE		= 3'd3;
	localparam		ST_IDLE			= 3'd7;

	localparam		RR_ID_REG0		= { 8'hE0, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00 };
	localparam		RR_ID_REG1		= { 8'hE0, 8'h00, 8'h00, 8'h00, 8'h00, 8'h01 };
	localparam		RR_CFG_REG0		= { 8'hE0, 8'h00, 8'h01, 8'h00, 8'h00, 8'h00 };
	localparam		WR_CFG_REG0		= { 8'h60, 8'h00, 8'h01, 8'h00, 8'h00, 8'h00 };
	localparam		RR_CFG_REG1		= { 8'hE0, 8'h00, 8'h01, 8'h00, 8'h00, 8'h01 };
	localparam		WR_CFG_REG1		= { 8'h60, 8'h00, 8'h01, 8'h00, 8'h00, 8'h01 };
	localparam		RM_ACCESS		= 14'b100_00000000000;		// CA[47]=1 (READ ), CA[46]=0 (Memory), CA[45]=0 (WrapBurst), CA[44:34]=0 (Reserved)
	localparam		WM_ACCESS		= 14'b000_00000000000;		// CA[47]=0 (WRITE), CA[46]=0 (Memory), CA[45]=0 (WrapBurst), CA[44:34]=0 (Reserved)

	localparam		DEEP_PDE		= 1'b1;									// 0: Deep power down, 1: Normal operation
	localparam		DRIVE_STR		= 3'b000;								// 000: 50ohm, 001: 35ohm, 010: 100ohm, 011: 200ohm, 1--: Reserved
	localparam		INIT_LATENCY	= (LATENCY == 5) ? 4'b0000 :
									  (LATENCY == 6) ? 4'b0001 :
									  (LATENCY == 3) ? 4'b1110 :
									  (LATENCY == 4) ? 4'b1111 : 4'b1110;
	localparam		FIXED_LATENCY	= 1'b1;									// 0: Variable initial latency, 1: Fixed 2 times initial latency
	localparam		BURST_TYPE		= 1'b1;									// 0: Reserved, 1: Wrapped burst sequence in legacy wrapped burst manner
	localparam		BURST_LENGTH	= 2'b10;								// 00: 128bytes, 01: 64bytes, 10: 16bytes, 00: 32bytes

	localparam		TOTAL_LATENCY	= LATENCY + LATENCY - 1;
	localparam		RW_CYCLE		= 2 + TOTAL_LATENCY + 3;
	localparam		RW_ST_LATENCY	= RW_CYCLE - 3;
	localparam		RW_MD_LATENCY	= 2 + LATENCY;
	localparam		RW_ED_LATENCY	= 2;
	localparam		W_OUT_END		= 1;

	// --------------------------------------------------------------------
	//	state machine
	// --------------------------------------------------------------------
	assign busy					= (ff_state != ST_IDLE) ? 1'b1 : 1'b0;
	assign w_transaction_end	= (ff_remain_count == 4'd0) ? 1'b1 : 1'b0;

	always @( negedge n_reset or posedge clk ) begin
		if( !n_reset ) begin
			ff_timer <= INITIAL_TIME;
		end
		else if( w_timer_end ) begin
			//	hold
		end
		else begin
			ff_timer <= ff_timer - 'd1;
		end
	end

	assign w_timer_end	= (ff_timer == 'd0) ? 1'b1 : 1'b0;

	always @( negedge n_reset or posedge clk ) begin
		if( !n_reset ) begin
			ff_state		<= ST_INITIAL;
			ff_send_bits	<= 64'd0;
			ff_ram_cs_n		<= 1'b1;
			ff_d_en			<= 1'b0;
			ff_psram_ck_en	<= 1'b0;
			ff_remain_count	<= 4'd0;
			ff_wds_en		<= 1'b0;
			ff_wds_pos		<= 1'b0;
			ff_wds_neg		<= 1'b0;
			ff_latency		<= 1'b0;
			ff_address0		<= 1'b0;
			ff_rdata		<= 8'd0;
			ff_rdata_en		<= 1'b0;
		end
		else if( ff_state == ST_INITIAL ) begin
			if( w_timer_end ) begin
				ff_state		<= ST_CONFIG;
				ff_send_bits	<= { WR_CFG_REG0, DEEP_PDE, DRIVE_STR, INIT_LATENCY, FIXED_LATENCY, BURST_TYPE, BURST_LENGTH };
				ff_ram_cs_n		<= 1'b0;
				ff_d_en			<= 1'b0;
				ff_psram_ck_en	<= 1'b0;
				ff_remain_count	<= 4'd5;
			end
			else begin
				//	Wait timer end
			end
		end
		else if( ff_state == ST_CONFIG ) begin
			if(      ff_remain_count == 4'd5 ) begin
				ff_d_en			<= 1'b1;
				ff_remain_count	<= 4'd4;
			end
			else if( ff_remain_count == 4'd1 ) begin
				ff_remain_count	<= ff_remain_count - 4'd1;
				ff_send_bits	<= { ff_send_bits[47:0], 16'd0 };
				ff_d_en			<= 1'b0;
			end
			else if( ff_remain_count == 4'd0 ) begin
				ff_state		<= ST_IDLE;
				ff_ram_cs_n		<= 1'b1;
				ff_psram_ck_en	<= 1'b0;
			end
			else begin
				ff_remain_count	<= ff_remain_count - 4'd1;
				ff_send_bits	<= { ff_send_bits[47:0], 16'd0 };
				ff_psram_ck_en	<= 1'b1;
			end
		end
		else if( ff_state == ST_READ ) begin
			if(      ff_remain_count == RW_CYCLE ) begin
				ff_remain_count	<= ff_remain_count - 4'd1;
				ff_d_en			<= 1'b1;
			end
			else if( ff_remain_count == RW_ST_LATENCY ) begin
				ff_remain_count	<= ff_remain_count - 4'd1;
				ff_send_bits	<= { ff_send_bits[47:0], 16'd0 };
				ff_d_en			<= 1'b0;
				ff_latency		<= 1'b1;
			end
			else if( ff_remain_count == RW_ED_LATENCY ) begin
				ff_remain_count	<= ff_remain_count - 4'd1;
				ff_latency		<= 1'b0;
			end
			else if( ff_remain_count == W_OUT_END ) begin
				ff_remain_count	<= ff_remain_count - 4'd1;
			end
			else if( ff_remain_count == 4'd0 ) begin
				if( w_rds_pos == 1'b0 && w_rds_neg == 1'b1 ) begin
					ff_state		<= ST_IDLE;
					ff_ram_cs_n		<= 1'b1;
					ff_psram_ck_en	<= 1'b0;
					ff_rdata		<= ff_address0 ? w_q_pos : w_q_neg;
					ff_rdata_en		<= 1'b1;
				end
				else begin
					//	hold
				end
			end
			else begin
				ff_remain_count	<= ff_remain_count - 4'd1;
				if( !ff_latency ) begin
					ff_send_bits	<= { ff_send_bits[47:0], 16'd0 };
				end
				ff_psram_ck_en	<= 1'b1;
			end
		end
		else if( ff_state == ST_WRITE ) begin
			if(      ff_remain_count == RW_CYCLE ) begin
				ff_remain_count	<= ff_remain_count - 4'd1;
				ff_d_en			<= 1'b1;
			end
			else if( ff_remain_count == RW_ST_LATENCY ) begin
				ff_remain_count	<= ff_remain_count - 4'd1;
				ff_send_bits	<= { ff_send_bits[47:0], 16'd0 };
				ff_d_en			<= 1'b0;
				ff_latency		<= 1'b1;
			end
			else if( ff_remain_count == RW_MD_LATENCY ) begin
				ff_remain_count	<= ff_remain_count - 4'd1;
				ff_wds_en		<= 1'b1;
				ff_wds_pos		<= 1'b0;
				ff_wds_neg		<= 1'b0;
			end
			else if( ff_remain_count == RW_ED_LATENCY ) begin
				ff_remain_count	<= ff_remain_count - 4'd1;
				ff_d_en			<= 1'b1;
				ff_latency		<= 1'b0;
				ff_wds_en		<= 1'b1;
				ff_wds_pos		<= ff_address0;
				ff_wds_neg		<= ~ff_address0;
			end
			else if( ff_remain_count == W_OUT_END ) begin
				ff_remain_count	<= ff_remain_count - 4'd1;
				ff_d_en			<= 1'b0;
				ff_wds_en		<= 1'b0;
			end
			else if( ff_remain_count == 4'd0 ) begin
				ff_state		<= ST_IDLE;
				ff_ram_cs_n		<= 1'b1;
				ff_psram_ck_en	<= 1'b0;
			end
			else begin
				ff_remain_count	<= ff_remain_count - 4'd1;
				if( !ff_latency ) begin
					ff_send_bits	<= { ff_send_bits[47:0], 16'd0 };
				end
				ff_psram_ck_en	<= 1'b1;
			end
		end
		else begin	//	ST_IDLE
			ff_rdata_en		<= 1'b0;
			if( wr ) begin
				//          	     CA[47:34], CA[33:22]     , CA[21:16]   , CA[15:3], CA[2:0]     , D0[7:0], D1[7:0]
				ff_send_bits	<= { WM_ACCESS, address[21:10], address[9:4], 13'd0   , address[3:1], wdata  , wdata };
				ff_d_en			<= 1'b0;
				ff_ram_cs_n		<= 1'b0;
				ff_psram_ck_en	<= 1'b0;
				ff_wds_en		<= 1'b0;
				ff_address0		<= address[0];
				ff_wds_pos		<= 1'b0;
				ff_wds_neg		<= 1'b0;
				ff_remain_count	<= RW_CYCLE;
				ff_state		<= ST_WRITE;
			end
			else if( rd ) begin
				//          	     CA[47:34], CA[33:22]     , CA[21:16]   , CA[15:3], CA[2:0]     , D0[7:0], D1[7:0]
				ff_send_bits	<= { RM_ACCESS, address[21:10], address[9:4], 13'd0   , address[3:1], 8'd0   , 8'd0 };
				ff_d_en			<= 1'b0;
				ff_ram_cs_n		<= 1'b0;
				ff_psram_ck_en	<= 1'b1;
				ff_wds_en		<= 1'b0;
				ff_address0		<= address[0];
				ff_wds_pos		<= 1'b0;
				ff_wds_neg		<= 1'b0;
				ff_remain_count	<= RW_CYCLE;
				ff_state		<= ST_READ;
			end
			else begin
				//	hold
			end
		end
	end

	assign w_d_pos	= ff_send_bits[63:56];
	assign w_d_neg	= ff_send_bits[55:48];
	assign rdata	= ff_rdata;
	assign rdata_en	= ff_rdata_en;

	// --------------------------------------------------------------------
	//	clock
	// --------------------------------------------------------------------
	ODDR oddr_ck (
		.CLK		( n_clk				),
		.D0			( ff_psram_ck_en	),
		.D1			( 1'b0				),
		.TX			( 1'bZ				),
		.Q0			( w_psram_ck_en		),
		.Q1			( 					)
	);
	assign O_psram_ck	= w_psram_ck_en;

	// --------------------------------------------------------------------
	//	chip select
	// --------------------------------------------------------------------
	ODDR oddr_cs_n (
		.CLK		( clk			),
		.D0			( ff_ram_cs_n	),
		.D1			( ff_ram_cs_n	),
		.TX			( 1'bZ			),
		.Q0			( O_psram_cs_n	),
		.Q1			( 				)
	);

	// --------------------------------------------------------------------
	//	read/write data strobe
	// --------------------------------------------------------------------
	ODDR oddr_rwds (
		.CLK		( clk			),
		.D0			( ff_wds_pos	),
		.D1			( ff_wds_neg	),
		.TX			( ff_wds_en		),
		.Q0			( w_wds			),
		.Q1			( w_wds_en		)
	);
	assign IO_psram_rwds = w_wds_en ? w_wds : 1'bz;

	IDDR iddr_rwds(
		.CLK		( clk			),
		.D			( IO_psram_rwds	),
		.Q0			( w_rds_pos		),
		.Q1			( w_rds_neg		)
	);

	// --------------------------------------------------------------------
	//	write data
	// --------------------------------------------------------------------
	ODDR oddr_d0 (
		.CLK		( clk			),
		.D0			( w_d_pos[0]	),
		.D1			( w_d_neg[0]	),
		.TX			( ff_d_en		),
		.Q0			( w_d[0]		),
		.Q1			( w_d_en[0]		)
	);

	ODDR oddr_d1 (
		.CLK		( clk			),
		.D0			( w_d_pos[1]	),
		.D1			( w_d_neg[1]	),
		.TX			( ff_d_en		),
		.Q0			( w_d[1]		),
		.Q1			( w_d_en[1]		)
	);

	ODDR oddr_d2 (
		.CLK		( clk			),
		.D0			( w_d_pos[2]	),
		.D1			( w_d_neg[2]	),
		.TX			( ff_d_en		),
		.Q0			( w_d[2]		),
		.Q1			( w_d_en[2]		)
	);

	ODDR oddr_d3 (
		.CLK		( clk			),
		.D0			( w_d_pos[3]	),
		.D1			( w_d_neg[3]	),
		.TX			( ff_d_en		),
		.Q0			( w_d[3]		),
		.Q1			( w_d_en[3]		)
	);

	ODDR oddr_d4 (
		.CLK		( clk			),
		.D0			( w_d_pos[4]	),
		.D1			( w_d_neg[4]	),
		.TX			( ff_d_en		),
		.Q0			( w_d[4]		),
		.Q1			( w_d_en[4]		)
	);

	ODDR oddr_d5 (
		.CLK		( clk			),
		.D0			( w_d_pos[5]	),
		.D1			( w_d_neg[5]	),
		.TX			( ff_d_en		),
		.Q0			( w_d[5]		),
		.Q1			( w_d_en[5]		)
	);

	ODDR oddr_d6 (
		.CLK		( clk			),
		.D0			( w_d_pos[6]	),
		.D1			( w_d_neg[6]	),
		.TX			( ff_d_en		),
		.Q0			( w_d[6]		),
		.Q1			( w_d_en[6]		)
	);

	ODDR oddr_d7 (
		.CLK		( clk			),
		.D0			( w_d_pos[7]	),
		.D1			( w_d_neg[7]	),
		.TX			( ff_d_en		),
		.Q0			( w_d[7]		),
		.Q1			( w_d_en[7]		)
	);

	assign IO_psram_dq[0]	= w_d_en[0] ? w_d[0] : 1'bz;
	assign IO_psram_dq[1]	= w_d_en[1] ? w_d[1] : 1'bz;
	assign IO_psram_dq[2]	= w_d_en[2] ? w_d[2] : 1'bz;
	assign IO_psram_dq[3]	= w_d_en[3] ? w_d[3] : 1'bz;
	assign IO_psram_dq[4]	= w_d_en[4] ? w_d[4] : 1'bz;
	assign IO_psram_dq[5]	= w_d_en[5] ? w_d[5] : 1'bz;
	assign IO_psram_dq[6]	= w_d_en[6] ? w_d[6] : 1'bz;
	assign IO_psram_dq[7]	= w_d_en[7] ? w_d[7] : 1'bz;

	// --------------------------------------------------------------------
	//	read data
	// --------------------------------------------------------------------
	IDDR iddr_q0 (
		.CLK		( clk				),
		.D			( IO_psram_dq[0]	),
		.Q0			( w_q_pos[0]		),
		.Q1			( w_q_neg[0]		)
	);

	IDDR iddr_q1 (
		.CLK		( clk				),
		.D			( IO_psram_dq[1]	),
		.Q0			( w_q_pos[1]		),
		.Q1			( w_q_neg[1]		)
	);

	IDDR iddr_q2 (
		.CLK		( clk				),
		.D			( IO_psram_dq[2]	),
		.Q0			( w_q_pos[2]		),
		.Q1			( w_q_neg[2]		)
	);

	IDDR iddr_q3 (
		.CLK		( clk				),
		.D			( IO_psram_dq[3]	),
		.Q0			( w_q_pos[3]		),
		.Q1			( w_q_neg[3]		)
	);

	IDDR iddr_q4 (
		.CLK		( clk				),
		.D			( IO_psram_dq[4]	),
		.Q0			( w_q_pos[4]		),
		.Q1			( w_q_neg[4]		)
	);

	IDDR iddr_q5 (
		.CLK		( clk				),
		.D			( IO_psram_dq[5]	),
		.Q0			( w_q_pos[5]		),
		.Q1			( w_q_neg[5]		)
	);

	IDDR iddr_q6 (
		.CLK		( clk				),
		.D			( IO_psram_dq[6]	),
		.Q0			( w_q_pos[6]		),
		.Q1			( w_q_neg[6]		)
	);

	IDDR iddr_q7 (
		.CLK		( clk				),
		.D			( IO_psram_dq[7]	),
		.Q0			( w_q_pos[7]		),
		.Q1			( w_q_neg[7]		)
	);

endmodule
