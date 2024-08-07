// -----------------------------------------------------------------------------
//	ip_mapperram.v
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
//		MapperRAM
// -----------------------------------------------------------------------------

module ip_mapperram (
	//	Internal I/F
	input			n_reset,
	input			clk,
	//	MSX-50BUS
	input	[15:0]	bus_address,
	output			bus_read_ready,
	output	[7:0]	bus_read_data,
	input	[7:0]	bus_write_data,
	input			bus_io_read,
	input			bus_io_write,
	input			bus_memory_read,
	input			bus_memory_write,
	//	RAM I/F
	output			rd,
	output			wr,
	input			busy,
	output	[21:0]	address,
	output	[7:0]	wdata,
	input	[7:0]	rdata,
	input			rdata_en
);
	reg				ff_memory_read;
	reg				ff_memory_write;
	wire			w_memory_read_rising_edge;
	wire			w_memory_write_rising_edge;
	reg		[7:0]	ff_p0;
	reg		[7:0]	ff_p1;
	reg		[7:0]	ff_p2;
	reg		[7:0]	ff_p3;
	reg				ff_read;
	wire	[7:0]	w_address_h;

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
	//	Segment registers
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_p0 <= 8'd0;
		end
		else if( bus_io_write && (bus_address[7:0] == 8'hFC) ) begin
			ff_p0 <= bus_write_data;
		end
		else begin
			//	hold
		end
	end

	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_p1 <= 8'd0;
		end
		else if( bus_io_write && (bus_address[7:0] == 8'hFD) ) begin
			ff_p1 <= bus_write_data;
		end
		else begin
			//	hold
		end
	end

	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_p2 <= 8'd0;
		end
		else if( bus_io_write && (bus_address[7:0] == 8'hFE) ) begin
			ff_p2 <= bus_write_data;
		end
		else begin
			//	hold
		end
	end

	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_p3 <= 8'd0;
		end
		else if( bus_io_write && (bus_address[7:0] == 8'hFF) ) begin
			ff_p3 <= bus_write_data;
		end
		else begin
			//	hold
		end
	end

	// --------------------------------------------------------------------
	//	Address decode
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_read <= 1'b0;
		end
		else if( w_memory_read_rising_edge ) begin
			ff_read <= 1'b1;
		end
		else if( rdata_en ) begin
			ff_read <= 1'b0;
		end
		else begin
			//	hold
		end
	end

	// --------------------------------------------------------------------
	//	Page address decoder
	// --------------------------------------------------------------------
	function [7:0] page_dec (
		input	[1:0]	page,
		input	[7:0]	ff_p0,
		input	[7:0]	ff_p1,
		input	[7:0]	ff_p2,
		input	[7:0]	ff_p3
	);
		case( page )
		2'd0:		page_dec = ff_p0;
		2'd1:		page_dec = ff_p1;
		2'd2:		page_dec = ff_p2;
		2'd3:		page_dec = ff_p3;
		default:	page_dec = ff_p0;
		endcase
	endfunction

	assign w_address_h		= page_dec( bus_address[15:14], ff_p0, ff_p1, ff_p2, ff_p3 );
	assign address			= { w_address_h, bus_address[13:0] };
	assign rd				= w_memory_read_rising_edge;
	assign wr				= w_memory_write_rising_edge;
	assign wdata			= bus_write_data;

	assign bus_read_ready	= rdata_en & ff_read;
	assign bus_read_data	= (rdata_en & ff_read) ? rdata : 8'd0;
endmodule
