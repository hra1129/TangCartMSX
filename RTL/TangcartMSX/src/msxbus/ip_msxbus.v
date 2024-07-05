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
	input			n_sltsl,
	input			n_rd,
	input			n_wr,
	input			n_ioreq,
	input			n_mereq,
	//	internal signals
	output	[15:0]	bus_address,
	input			bus_read_ready,
	input	[7:0]	bus_read_data,
	output	[7:0]	bus_write_data,
	output			bus_io_read,
	output			bus_io_write,
	output			bus_memory_read,
	output			bus_memory_write
);
	//	Flip-flops for asynchronous switching and low-pass
	reg				ff_n_sltsl;
	reg				ff_n_rd;
	reg				ff_n_wr;
	reg				ff_n_ioreq;
	wire			w_memory_read;
	wire			w_memory_write;
	wire			w_io_read;
	wire			w_io_write;
	reg				ff_memory_read;
	reg				ff_memory_write;
	reg				ff_io_read;
	reg				ff_io_write;
	//	Make up pulse
	wire			w_memory_read_pulse;
	wire			w_memory_write_pulse;
	wire			w_io_read_pulse;
	wire			w_io_write_pulse;
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

	assign w_memory_read	= ~ff_n_sltsl & ~ff_n_rd;
	assign w_memory_write	= ~ff_n_sltsl & ~ff_n_wr;
	assign w_io_read		= ~ff_n_ioreq & ~ff_n_rd;
	assign w_io_write		= ~ff_n_ioreq & ~ff_n_wr;

	// --------------------------------------------------------------------
	//	Make up pulse
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_memory_read	<= 1'b0;
			ff_memory_write	<= 1'b0;
			ff_io_read		<= 1'b0;
			ff_io_write		<= 1'b0;
		end
		else begin
			ff_memory_read	<= w_memory_read;
			ff_memory_write	<= w_memory_write;
			ff_io_read		<= w_io_read;
			ff_io_write		<= w_io_write;
		end
	end

	assign w_memory_read_pulse	= ~ff_memory_read  & w_memory_read;
	assign w_memory_write_pulse	= ~ff_memory_write & w_memory_write;
	assign w_io_read_pulse		= ~ff_io_read      & w_io_read;
	assign w_io_write_pulse		= ~ff_io_write     & w_io_write;

	// --------------------------------------------------------------------
	//	Latch
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		ff_bus_address	<= adr;
	end

	always @( posedge clk ) begin
		if( w_memory_write_pulse || w_io_write_pulse ) begin
			ff_bus_write_data	<= i_data;
		end
		else begin
			//	hold
		end
	end

	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_bus_read_data	<= 8'd0;
			ff_buf_read_data_en <= 1'b0;
		end
		else if( ff_n_rd == 1'b1 ) begin
			ff_bus_read_data	<= 8'd0;
			ff_buf_read_data_en <= 1'b0;
		end
		else if( bus_read_ready ) begin
			ff_bus_read_data	<= bus_read_data;
			ff_buf_read_data_en <= 1'b1;
		end
		else begin
			//	hold
		end
	end

	// --------------------------------------------------------------------
	//	Internal BUS signals
	// --------------------------------------------------------------------
	assign bus_address		= ff_bus_address;
	assign bus_write_data	= ff_bus_write_data;
	assign bus_io_read		= ff_io_read;
	assign bus_io_write		= ff_io_write;
	assign bus_memory_read	= ff_memory_read;
	assign bus_memory_write	= ff_memory_write;

	// --------------------------------------------------------------------
	//	MSX BUS response
	// --------------------------------------------------------------------
	assign o_data			= ff_bus_read_data;
	assign is_output		= ff_buf_read_data_en & ~n_rd;
endmodule
