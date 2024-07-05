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
//		SimpleRAM (BlockRAM version)
// -----------------------------------------------------------------------------

module ip_ram (
	//	Internal I/F
	input			n_reset,
	input			clk,
	//	MSX-50BUS
	input	[15:0]	bus_address,
	output			bus_read_ready,
	output	[7:0]	bus_read_data,
	input	[7:0]	bus_write_data,
	input			bus_memory_read,
	input			bus_memory_write
);
	reg				ff_memory_read;
	reg				ff_memory_write;
	wire			w_memory_read_rising_edge;
	wire			w_memory_write_rising_edge;
	reg		[7:0]	ff_ram[0:16383];
	reg		[7:0]	ff_read;
	reg				ff_read_ready;

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
	//	Block ram access
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_read_ready <= 1'b0;
			ff_read <= 8'd0;
		end
		else if( bus_address[15:14] == 2'd2 ) begin
			if( w_memory_read_rising_edge ) begin
				ff_read_ready <= 1'b1;
				ff_read <= ff_ram[ bus_address[13:0] ];
			end
			else if( w_memory_write_rising_edge ) begin
				ff_read_ready <= 1'b0;
				ff_ram[ bus_address[13:0] ] <= bus_write_data;
			end
			else begin
				ff_read_ready <= 1'b0;
			end
		end
		else begin
			ff_read_ready <= 1'b0;
		end
	end

	assign bus_read_data	= ff_read_ready ? ff_read : 8'd0;
	assign bus_read_ready	= ff_read_ready;
endmodule
