// -----------------------------------------------------------------------------
//	ip_msxbus.v
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
//		The role of protocol conversion by replacing the asynchronous MSXBUS 
//		signal with an internal clock.
// -----------------------------------------------------------------------------

module ip_msxbus (
	//	cartridge slot signals
	input			n_reset,
	input			clk,
	input	[15:0]	adr,
	input	[7:0]	i_data,
	output	[7:0]	o_data,
	output			is_output,
	output			is_output_d,
	input			n_sltsl,
	input			n_rd,
	input			n_wr,
	input			n_ioreq,
	input			n_mereq,
	//	internal signals
	output	[15:0]	bus_address,
	input			bus_io_cs,
	input			bus_memory_cs,
	input			bus_read_ready,
	input	[7:0]	bus_read_data,
	output	[7:0]	bus_write_data,
	output			bus_read,
	output			bus_write,
	output			bus_io,
	output			bus_memory
);
	//	Flip-flops for asynchronous switching and low-pass
	reg				ff_n_sltsl;
	reg				ff_n_rd;
	reg				ff_n_wr;
	reg				ff_n_ioreq;
	wire			w_mem_rd;
	wire			w_mem_wr;
	wire			w_io_rd;
	wire			w_io_wr;
	reg				ff_mem_rd;
	reg				ff_mem_wr;
	reg				ff_io_rd;
	reg				ff_io_wr;
	//	Make up pulse
	wire			w_mem_rd_pulse;
	wire			w_mem_wr_pulse;
	wire			w_io_rd_pulse;
	wire			w_io_wr_pulse;
	//	Latch
	reg		[15:0]	ff_bus_address;
	reg		[7:0]	ff_bus_read_data;
	reg		[7:0]	ff_bus_write_data;
	reg				ff_bus_read = 1'b0;
	reg				ff_bus_write = 1'b0;
	reg				ff_buf_read_data_en = 1'b0;

	// --------------------------------------------------------------------
	//	Asynchronous switching and low-pass
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_n_sltsl	<= 1'b1;
			ff_n_rd		<= 1'b1;
			ff_n_wr		<= 1'b1;
			ff_n_ioreq	<= 1'b1;
		end
		else begin
			ff_n_sltsl	<= n_sltsl;
			ff_n_rd		<= n_rd;
			ff_n_wr		<= n_wr;
			ff_n_ioreq	<= n_ioreq;
		end
	end

	assign w_mem_rd		= ~ff_n_sltsl & ~ff_n_rd;
	assign w_mem_wr		= ~ff_n_sltsl & ~ff_n_wr;
	assign w_io_rd		= ~ff_n_ioreq & ~ff_n_rd;
	assign w_io_wr		= ~ff_n_ioreq & ~ff_n_wr;

	// --------------------------------------------------------------------
	//	Make up pulse
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_mem_rd <= 1'b0;
			ff_mem_wr <= 1'b0;
			ff_io_rd  <= 1'b0;
			ff_io_wr  <= 1'b0;
		end
		else begin
			ff_mem_rd <= w_mem_rd;
			ff_mem_wr <= w_mem_wr;
			ff_io_rd  <= w_io_rd;
			ff_io_wr  <= w_io_wr;
		end
	end

	assign w_mem_rd_pulse	= ~ff_mem_rd & w_mem_rd;
	assign w_mem_wr_pulse	= ~ff_mem_wr & w_mem_wr;
	assign w_io_rd_pulse	= ~ff_io_rd  & w_io_rd;
	assign w_io_wr_pulse	= ~ff_io_wr  & w_io_wr;

	// --------------------------------------------------------------------
	//	Latch
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		ff_bus_address	<= adr;
	end

	always @( posedge clk ) begin
		if( w_mem_wr_pulse || w_io_wr_pulse ) begin
			ff_bus_write_data	<= i_data;
		end
		else begin
			//	hold
		end
	end

	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_bus_read_data	<= 8'd0;
		end
		else if( bus_read_ready ) begin
			ff_bus_read_data	<= bus_read_data;
		end
		else begin
			//	hold
		end
	end

	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_buf_read_data_en <= 1'b0;
		end
		else if( bus_read_ready ) begin
			ff_buf_read_data_en <= 1'b1;
		end
		else if( ff_n_rd == 1'b1 ) begin
			ff_buf_read_data_en <= 1'b0;
		end
		else begin
			//	hold
		end
	end

	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_bus_write	<= 1'b0;
		end
		else begin
			ff_bus_write	<= w_mem_wr_pulse | w_io_wr_pulse;
		end
	end

	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_bus_read		<= 1'b0;
		end
		else begin
			ff_bus_read		<= w_mem_rd_pulse | w_io_rd_pulse;
		end
	end

	// --------------------------------------------------------------------
	//	Internal BUS signals
	// --------------------------------------------------------------------
	assign bus_address		= ff_bus_address;
	assign bus_write_data	= ff_bus_write_data;
	assign bus_read			= ff_bus_read;
	assign bus_write		= ff_bus_write;
	assign bus_io			= (ff_io_rd  | ff_io_wr ) & bus_io_cs;
	assign bus_memory		= (ff_mem_rd | ff_mem_wr) & bus_memory_cs;

	// --------------------------------------------------------------------
	//	MSX BUS response
	// --------------------------------------------------------------------
	assign o_data			= ff_bus_read_data;
	assign is_output		= ff_buf_read_data_en & ~n_rd;
	assign is_output_d		= ff_buf_read_data_en;
endmodule
