// -----------------------------------------------------------------------------
//	ip_srom.v
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
//		32Mbits (4MBytes) Serial ROM Controller
// -----------------------------------------------------------------------------

module ip_srom #(
	parameter		END_ADDRESS = 'h30_0000 - 1
) (
	//	Internal I/F
	input			n_reset,
	input			clk,
	//	Serial ROM I/F
	output			srom_cs,
	output			srom_mosi,
	output			srom_sclk,
	input			srom_miso,
	//	Internal I/F
	input			n_cs,
	input			rd,
	input			wr,
	output			busy,
	input	[7:0]	wdata,
	output	[7:0]	rdata,
	output			rdata_en,
	//	PSRAM I/F
	output			psram1_wr,
	input			psram1_busy,
	output	[21:0]	psram1_address,
	output	[7:0]	psram1_wdata,
	//	others
	output			initial_busy
);
	//	State
	localparam STATE_RSTEN			= 'd0;
	localparam STATE_RSTEN_S		= 'd1;
	localparam STATE_RSTEN_W		= 'd2;
	localparam STATE_RST			= 'd3;
	localparam STATE_RST_S			= 'd4;
	localparam STATE_RST_W			= 'd5;
	localparam STATE_TREADY			= 'd6;
	localparam STATE_READ_ALL		= 'd7;
	localparam STATE_READ_ALL_S		= 'd8;
	localparam STATE_READ_ALL_W		= 'd9;
	localparam STATE_READ_A0		= 'd10;
	localparam STATE_READ_A0_S		= 'd11;
	localparam STATE_READ_A0_W		= 'd12;
	localparam STATE_READ_A1		= 'd13;
	localparam STATE_READ_A1_S		= 'd14;
	localparam STATE_READ_A1_W		= 'd15;
	localparam STATE_READ_A2		= 'd16;
	localparam STATE_READ_A2_S		= 'd17;
	localparam STATE_READ_A2_W		= 'd18;
	localparam STATE_READ_D			= 'd19;
	localparam STATE_READ_D_S		= 'd20;
	localparam STATE_READ_D_W		= 'd21;
	localparam STATE_IDLE			= 'd22;
	localparam STATE_SEND			= 'd23;
	localparam STATE_SEND_S			= 'd24;
	localparam STATE_SEND_W			= 'd25;
	localparam STATE_RECV			= 'd26;
	localparam STATE_RECV_S			= 'd27;
	localparam STATE_RECV_W			= 'd28;
	//	Serial state
	localparam SSTATE_IDLE			= 'd0;
	localparam SSTATE_D0L			= 'd1;
	localparam SSTATE_D0H			= 'd2;
	localparam SSTATE_D1L			= 'd3;
	localparam SSTATE_D1H			= 'd4;
	localparam SSTATE_D2L			= 'd5;
	localparam SSTATE_D2H			= 'd6;
	localparam SSTATE_D3L			= 'd7;
	localparam SSTATE_D3H			= 'd8;
	localparam SSTATE_D4L			= 'd9;
	localparam SSTATE_D4H			= 'd10;
	localparam SSTATE_D5L			= 'd11;
	localparam SSTATE_D5H			= 'd12;
	localparam SSTATE_D6L			= 'd13;
	localparam SSTATE_D6H			= 'd14;
	localparam SSTATE_D7L			= 'd15;
	localparam SSTATE_D7H			= 'd16;
	localparam SSTATE_FIN			= 'd17;

	localparam TREADY_WAIT = 'd1620;	//	30usec @ 54MHz

	reg		[21:0]	ff_timer;
	reg		[4:0]	ff_state;
	reg		[7:0]	ff_send_data;
	reg		[4:0]	ff_serial_state;
	reg				ff_sclk;
	reg				ff_n_cs;
	reg				ff_busy;
	reg				ff_dir_out;
	reg		[7:0]	ff_rdata;
	reg				ff_rdata_en;
	reg				ff_send;
	reg				ff_receive;
	reg				ff_wr;
	reg		[7:0]	ff_wdata;
	reg		[21:0]	ff_address;
	wire			w_initial_busy;

	assign w_initial_busy		= (ff_state < STATE_IDLE);
	assign initial_busy			= w_initial_busy;

	// --------------------------------------------------------------------
	//	State
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_state <= STATE_RSTEN;
		end
		else if( ff_state == STATE_IDLE ) begin
			if( ff_busy ) begin
				//	hold
			end
			else if( wr ) begin
				ff_state <= STATE_SEND;
			end
			else if( rd ) begin
				ff_state <= STATE_RECV;
			end
		end
		else if( ff_state == STATE_RSTEN || ff_state == STATE_RST || ff_state == STATE_READ_ALL || 
		         ff_state == STATE_READ_A0 || ff_state == STATE_READ_A1 || ff_state == STATE_READ_A2 || ff_state == STATE_READ_D ||
		         ff_state == STATE_SEND || ff_state == STATE_RECV ) begin
			ff_state <= ff_state + 'd1;
		end
		else if( ff_state == STATE_RSTEN_S || ff_state == STATE_RST_S || ff_state == STATE_READ_ALL_S || 
		         ff_state == STATE_READ_A0_S || ff_state == STATE_READ_A1_S || ff_state == STATE_READ_A2_S ||
		         ff_state == STATE_SEND_S || ff_state == STATE_RECV_S ) begin
			if( ff_serial_state == SSTATE_FIN ) begin
				ff_state <= ff_state + 'd1;
			end
		end
		else if( ff_state == STATE_READ_D_S ) begin
			if( ff_serial_state == SSTATE_FIN ) begin
				ff_state <= ff_state + 'd1;
			end
		end
		else if( ff_state == STATE_SEND_W || ff_state == STATE_RECV_W ) begin
			ff_state <= STATE_IDLE;
		end
		else if( ff_state == STATE_RSTEN_W || ff_state == STATE_RST_W ) begin
			ff_state <= ff_state + 'd1;
			ff_timer <= TREADY_WAIT;
		end
		else if( ff_state == STATE_READ_ALL_W || ff_state == STATE_READ_A0_W || ff_state == STATE_READ_A1_W || ff_state == STATE_READ_A2_W ) begin
			ff_state <= ff_state + 'd1;
		end
		else if( ff_state == STATE_TREADY ) begin
			if( ff_timer == 'd0 ) begin
				ff_state <= ff_state + 'd1;
			end
			else begin
				ff_timer <= ff_timer - 'd1;
			end
		end
		else if( ff_state == STATE_READ_D_W ) begin
			if( ff_timer != END_ADDRESS ) begin
				ff_timer <= ff_timer + 'd1;
				ff_state <= STATE_READ_D;
			end
			else begin
				ff_state <= STATE_IDLE;
			end
		end
	end

	// --------------------------------------------------------------------
	//	Chip select
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_n_cs <= 1'b1;
		end
		else if( ff_send || ff_receive ) begin
			ff_n_cs <= 1'b0;
		end
		else if( ff_state == STATE_RSTEN_W || ff_state == STATE_RST_W  ) begin
			ff_n_cs <= 1'b1;
		end
		else if( ff_state == STATE_IDLE ) begin
			ff_n_cs <= n_cs;
		end
		else begin
			//	hold
		end
	end

	assign srom_cs		= ff_n_cs;

	// --------------------------------------------------------------------
	//	Read/Write direction
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_dir_out <= 1'b0;
		end
		else if( ff_send || ff_receive ) begin
			ff_dir_out <= wr || ff_send;
		end
		else begin
			//	hold
		end
	end

	// --------------------------------------------------------------------
	//	Busy signal
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_busy <= 1'b0;
		end
		else if( w_initial_busy ) begin
			//	hold
		end
		else if( !ff_busy && (wr || rd) ) begin
			ff_busy <= 1'b1;
		end
		else if( ff_state == STATE_IDLE ) begin
			ff_busy <= 1'b0;
		end
		else begin
			//	hold
		end
	end

	assign busy			= ff_busy;

	// --------------------------------------------------------------------
	//	Serial state
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_serial_state <= SSTATE_IDLE;
		end
		else if( ff_serial_state == SSTATE_IDLE ) begin
			if( ff_send || ff_receive ) begin
				ff_serial_state <= SSTATE_D0L;
			end
			else begin
				//	hold
			end
		end
		else if( ff_serial_state == SSTATE_FIN ) begin
			ff_serial_state <= SSTATE_IDLE;
		end
		else begin
			ff_serial_state <= ff_serial_state + 'd1;
		end
	end

	// --------------------------------------------------------------------
	//	SCLK
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_sclk <= 1'b0;		//	SPI mode 0
		end
		else if( ff_serial_state == SSTATE_IDLE ) begin
			ff_sclk <= 1'b0;		//	SPI mode 0
		end
		else if( ff_serial_state == SSTATE_FIN ) begin
			ff_sclk <= 1'b0;
		end
		else begin
			ff_sclk <= ~ff_sclk;
		end
	end

	assign srom_sclk = ff_sclk;

	// --------------------------------------------------------------------
	//	Send data
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_send_data <= 8'd0;
			ff_send <= 1'b0;
			ff_receive <= 1'b0;
		end
		else if( ff_serial_state != SSTATE_IDLE ) begin
			if( !ff_serial_state[0] ) begin
				ff_send_data <= { ff_send_data[6:0], 1'b0 };
			end
		end
		else if( ff_state == STATE_IDLE ) begin
			//	hold
		end
		else if( ff_state == STATE_SEND ) begin
			ff_send_data <= wdata;
			ff_send <= 1'b1;
		end
		else if( ff_state == STATE_RSTEN ) begin
			ff_send_data <= 8'h66;
			ff_send <= 1'b1;
		end
		else if( ff_state == STATE_RST ) begin
			ff_send_data <= 8'h99;
			ff_send <= 1'b1;
		end
		else if( ff_state == STATE_READ_ALL ) begin
			ff_send_data <= 8'h03;
			ff_send <= 1'b1;
		end
		else if( ff_state == STATE_READ_A0 || ff_state == STATE_READ_A1 || ff_state == STATE_READ_A2 ) begin
			ff_send_data <= 8'h00;
			ff_send <= 1'b1;
		end
		else if( ff_state == STATE_READ_D || ff_state == STATE_RECV ) begin
			ff_receive <= 1'b1;
		end
		else if( ff_state == STATE_RSTEN_S || ff_state == STATE_RST_S || ff_state == STATE_READ_ALL_S || 
		         ff_state == STATE_READ_A0_S || ff_state == STATE_READ_A1_S || ff_state == STATE_READ_A2_S || ff_state == STATE_READ_D_S ||
		         ff_state == STATE_SEND_S || ff_state == STATE_RECV_S ) begin
			ff_send <= 1'b0;
			ff_receive <= 1'b0;
		end
	end

	assign srom_mosi	= ff_send_data[7];

	// --------------------------------------------------------------------
	//	Receive data
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_rdata <= 8'd0;
		end
		else if( !ff_dir_out && !ff_serial_state[0] ) begin
			ff_rdata <= { ff_rdata[6:0], srom_miso };
		end
	end

	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_rdata_en <= 1'b0;
		end
		else if( ff_state == STATE_RECV_W ) begin
			ff_rdata_en <= 1'b1;
		end
		else begin
			ff_rdata_en <= 1'b0;
		end
	end

	assign rdata		= ff_rdata_en ? ff_rdata : 8'd0;
	assign rdata_en		= ff_rdata_en;

	// --------------------------------------------------------------------
	//	PSRAM I/F
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_wr <= 1'b0;
			ff_wdata <= 8'd0;
			ff_address <= 'd0;
		end
		else if( ff_state == STATE_READ_D_W ) begin
			ff_wr <= 1'b1;
			ff_wdata <= ff_rdata;
			ff_address <= ff_timer;
		end
		else if( psram1_busy == 1'b0 ) begin
			ff_wr <= 1'b0;
			ff_wdata <= 8'd0;
			ff_address <= 'd0;
		end
	end

	assign psram1_address	= ff_address;
	assign psram1_wr		= ff_wr;
	assign psram1_wdata		= ff_wdata;
endmodule
