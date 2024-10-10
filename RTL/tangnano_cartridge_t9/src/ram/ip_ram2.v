// -----------------------------------------------------------------------------
//	ip_ram.v
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
//		SimpleRAM (PSRAM version)
// -----------------------------------------------------------------------------

module ip_ram2 (
	//	Internal I/F
	input			n_reset,
	input			clk,
	//	MSX-50BUS
	input	[15:0]	bus_address,
	output			bus_read_ready,
	output	[7:0]	bus_read_data,
	input	[7:0]	bus_write_data,
	input			bus_memory_read,
	input			bus_memory_write,
	output			rd,
	output			wr,
	input			busy,
	output	[21:0]	address,
	output	[7:0]	wdata,
	input	[7:0]	rdata,
	input			rdata_en,
	output	[7:0]	debug_count
);
	reg				ff_memory_read;
	reg				ff_memory_write;
	wire			w_memory_read_rising_edge;
	wire			w_memory_write_rising_edge;
	reg		[7:0]	ff_read;
	reg				ff_read_ready;
	reg				ff_rd;
	reg				ff_wr;
	reg		[7:0]	ff_wdata;
	reg		[13:0]	ff_address;
	wire			w_dec;
	reg				ff_debug_count_en;
	reg		[7:0]	ff_debug_count;

	// --------------------------------------------------------------------
	//	Pulse conversion
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_memory_read		<= 1'b0;
			ff_memory_write		<= 1'b0;
		end
		else begin
			ff_memory_read		<= bus_memory_read;
			ff_memory_write		<= bus_memory_write;
		end
	end

	assign w_memory_read_rising_edge	= ~ff_memory_read & bus_memory_read;
	assign w_memory_write_rising_edge	= ~ff_memory_write & bus_memory_write;

	// --------------------------------------------------------------------
	//	Address decode
	// --------------------------------------------------------------------
	assign w_dec			= (bus_address[15:14] == 2'd2);

	// --------------------------------------------------------------------
	//	Read response
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_read_ready <= 1'b0;
			ff_read <= 8'd0;
		end
		else if( bus_memory_read && w_dec ) begin
			if( rdata_en ) begin
				ff_read_ready <= 1'b1;
				ff_read <= rdata;
			end
		end
		else begin
			ff_read_ready <= 1'b0;
			ff_read <= 8'd0;
		end
	end

	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_rd <= 1'b0;
			ff_wr <= 1'b0;
			ff_wdata <= 8'd0;
			ff_address <= 14'd0;
		end
		else if( w_dec ) begin
			if( w_memory_read_rising_edge ) begin
				ff_rd <= 1'b1;
				ff_address <= bus_address[13:0];
			end
			else if( w_memory_write_rising_edge ) begin
				ff_wr <= 1'b1;
				ff_address <= bus_address[13:0];
				ff_wdata <= bus_write_data;
			end
			else if( !busy ) begin
				ff_rd <= 1'b0;
				ff_wr <= 1'b0;
				ff_address <= 'd0;
				ff_wdata <= 8'd0;
			end
		end
		else begin
			ff_rd <= 1'b0;
			ff_wr <= 1'b0;
			ff_address <= 'd0;
			ff_wdata <= 8'd0;
		end
	end

	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_debug_count_en <= 1'b0;
			ff_debug_count <= 'd0;
		end
		else if( w_memory_read_rising_edge && w_dec ) begin
			ff_debug_count_en <= 1'b1;
			ff_debug_count <= 'd0;
		end
		else if( ff_read_ready ) begin
			ff_debug_count_en <= 1'b0;
		end
		else if( ff_debug_count_en ) begin
			ff_debug_count <= ff_debug_count + 'd1;
		end
	end

	assign debug_count		= ff_debug_count;

	assign bus_read_data	= ff_read;
	assign bus_read_ready	= ff_read_ready;

	assign rd				= ff_rd;
	assign wr				= ff_wr;
	assign address			= ff_address;
	assign wdata			= ff_wdata;
endmodule
