// -----------------------------------------------------------------------------
//	ip_debugger.v
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
//		Debugger
// -----------------------------------------------------------------------------

module ip_debugger (
	//	Internal I/F
	input			n_reset,
	input			clk,			//	42MHz
	input	[1:0]	button,
	output	[5:0]	n_led,
	//	Signals
	input			bus_io_read,
	input			bus_io_write,
	input			bus_memory_read,
	input			bus_memory_write,
	input			psram0_rd,
	input			psram0_wr,
	input			psram0_rdata_en,
	input	[21:0]	psram0_address
);
	reg		[23:0]	ff_timer;
	wire			w_01sec;
	reg				ff_1shot_bus_io_read;
	reg				ff_1shot_bus_io_write;
	reg				ff_1shot_bus_memory_read;
	reg				ff_1shot_bus_memory_write;
	reg				ff_1shot_psram0_rd;
	reg				ff_1shot_psram0_wr;
	reg				ff_1shot_psram0_rdata_en;
	reg		[3:0]	ff_counter_bus_io_read;
	reg		[3:0]	ff_counter_bus_io_write;
	reg		[3:0]	ff_counter_bus_memory_read;
	reg		[3:0]	ff_counter_bus_memory_write;
	reg		[3:0]	ff_counter_psram0_rd;
	reg		[3:0]	ff_counter_psram0_wr;
	reg		[3:0]	ff_counter_psram0_rdata_en;
	wire	[5:0]	w_led0;
	wire	[5:0]	w_led1;
	wire	[5:0]	w_led2;
	reg		[1:0]	ff_state;
	reg		[1:0]	ff_button0;
	reg		[1:0]	ff_button1;

	// --------------------------------------------------------------------
	//	0.5sec timer
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_timer <= 'd0;
		end
		else if( w_01sec ) begin
			ff_timer <= 'd4200000;
		end
		else begin
			ff_timer <= ff_timer - 'd1;
		end
	end

	assign w_01sec		= ( ff_timer == 'd0 );

	// --------------------------------------------------------------------
	//	state machine
	// --------------------------------------------------------------------
	assign w_led0	= { 2'b11, ~ff_1shot_bus_memory_write, ~ff_1shot_bus_memory_read, ~ff_1shot_bus_io_write, ~ff_1shot_bus_io_read };
	assign w_led1	= { 2'b10, 1'b1, ~ff_1shot_psram0_rdata_en, ~ff_1shot_psram0_wr, ~ff_1shot_psram0_rd };
	assign w_led2	= { ~psram0_address[21:16] };
	assign n_led	= ( ff_state == 2'd0 ) ? w_led0 : 
	                  ( ff_state == 2'd1 ) ? w_led1 : w_led2;

	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_state <= 1'b0;
		end
		else if( !ff_button0[0] && ff_button1[0] ) begin
			if( ff_state == 2'd2 ) begin
				ff_state <= 2'd0;
			end
			else begin
				ff_state <= ff_state + 2'd1;
			end
		end
		else if( !ff_button0[1] && ff_button1[1] ) begin
			if( ff_state == 2'd0 ) begin
				ff_state <= 2'd2;
			end
			else begin
				ff_state <= ff_state - 2'd1;
			end
		end
		else begin
			//	hold
		end
	end

	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_button0 <= 2'b11;
			ff_button1 <= 2'b11;
		end
		else if( w_01sec ) begin
			ff_button1 <= ff_button0;
			ff_button0 <= button;
		end
		else begin
			//	hold
		end
	end

	// --------------------------------------------------------------------
	//	sig0 : bus_io_read
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_1shot_bus_io_read <= 1'b0;
			ff_counter_bus_io_read <= 4'd0;
		end
		else if( bus_io_read ) begin
			ff_1shot_bus_io_read <= 1'b1;
			ff_counter_bus_io_read <= 4'd15;
		end
		else if( ff_counter_bus_io_read != 4'd0 ) begin
			if( w_01sec ) begin
				ff_counter_bus_io_read <= ff_counter_bus_io_read - 4'd1;
			end
		end
		else begin
			ff_1shot_bus_io_read <= 1'b0;
			ff_counter_bus_io_read <= 4'd0;
		end
	end

	// --------------------------------------------------------------------
	//	sig1 : bus_io_write
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_1shot_bus_io_write <= 1'b0;
			ff_counter_bus_io_write <= 4'd0;
		end
		else if( bus_io_write ) begin
			ff_1shot_bus_io_write <= 1'b1;
			ff_counter_bus_io_write <= 4'd15;
		end
		else if( ff_counter_bus_io_write != 4'd0 ) begin
			if( w_01sec ) begin
				ff_counter_bus_io_write <= ff_counter_bus_io_write - 4'd1;
			end
		end
		else begin
			ff_1shot_bus_io_write <= 1'b0;
			ff_counter_bus_io_write <= 4'd0;
		end
	end

	// --------------------------------------------------------------------
	//	sig2 : bus_memory_read
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_1shot_bus_memory_read <= 1'b0;
			ff_counter_bus_memory_read <= 4'd0;
		end
		else if( bus_memory_read ) begin
			ff_1shot_bus_memory_read <= 1'b1;
			ff_counter_bus_memory_read <= 4'd15;
		end
		else if( ff_counter_bus_memory_read != 4'd0 ) begin
			if( w_01sec ) begin
				ff_counter_bus_memory_read <= ff_counter_bus_memory_read - 4'd1;
			end
		end
		else begin
			ff_1shot_bus_memory_read <= 1'b0;
			ff_counter_bus_memory_read <= 4'd0;
		end
	end

	// --------------------------------------------------------------------
	//	sig3 : bus_memory_write
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_1shot_bus_memory_write <= 1'b0;
			ff_counter_bus_memory_write <= 4'd0;
		end
		else if( bus_memory_write ) begin
			ff_1shot_bus_memory_write <= 1'b1;
			ff_counter_bus_memory_write <= 4'd15;
		end
		else if( ff_counter_bus_memory_write != 4'd0 ) begin
			if( w_01sec ) begin
				ff_counter_bus_memory_write <= ff_counter_bus_memory_write - 4'd1;
			end
		end
		else begin
			ff_1shot_bus_memory_write <= 1'b0;
			ff_counter_bus_memory_write <= 4'd0;
		end
	end

	// --------------------------------------------------------------------
	//	sig4 : psram0_rd
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_1shot_psram0_rd <= 1'b0;
			ff_counter_psram0_rd <= 4'd0;
		end
		else if( psram0_rd ) begin
			ff_1shot_psram0_rd <= 1'b1;
			ff_counter_psram0_rd <= 4'd15;
		end
		else if( ff_counter_psram0_rd != 4'd0 ) begin
			if( w_01sec ) begin
				ff_counter_psram0_rd <= ff_counter_psram0_rd - 4'd1;
			end
		end
		else begin
			ff_1shot_psram0_rd <= 1'b0;
			ff_counter_psram0_rd <= 4'd0;
		end
	end

	// --------------------------------------------------------------------
	//	sig5 : psram0_wr
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_1shot_psram0_wr <= 1'b0;
			ff_counter_psram0_wr <= 4'd0;
		end
		else if( psram0_wr ) begin
			ff_1shot_psram0_wr <= 1'b1;
			ff_counter_psram0_wr <= 4'd15;
		end
		else if( ff_counter_psram0_wr != 4'd0 ) begin
			if( w_01sec ) begin
				ff_counter_psram0_wr <= ff_counter_psram0_wr - 4'd1;
			end
		end
		else begin
			ff_1shot_psram0_wr <= 1'b0;
			ff_counter_psram0_wr <= 4'd0;
		end
	end

	// --------------------------------------------------------------------
	//	sig6 : psram0_rdata_en
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_1shot_psram0_rdata_en <= 1'b0;
			ff_counter_psram0_rdata_en <= 4'd0;
		end
		else if( psram0_rdata_en ) begin
			ff_1shot_psram0_rdata_en <= 1'b1;
			ff_counter_psram0_rdata_en <= 4'd15;
		end
		else if( ff_counter_psram0_rdata_en != 4'd0 ) begin
			if( w_01sec ) begin
				ff_counter_psram0_rdata_en <= ff_counter_psram0_rdata_en - 4'd1;
			end
		end
		else begin
			ff_1shot_psram0_rdata_en <= 1'b0;
			ff_counter_psram0_rdata_en <= 4'd0;
		end
	end

endmodule
