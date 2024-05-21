// -----------------------------------------------------------------------------
//	ip_kanjirom.v
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
//		KanjiROM
// -----------------------------------------------------------------------------

module ip_kanjirom #(
	parameter		address_h	= 5'b11000		//	[21:18] 5bits
) (
	//	Internal I/F
	input			n_reset,
	input			clk,
	input			enable_jis1,
	input			enable_jis2,
	//	MSX-50BUS
	input	[15:0]	bus_address,
	output			bus_io_cs,
	output			bus_memory_cs,
	output			bus_read_ready,
	output	[7:0]	bus_read_data,
	input	[7:0]	bus_write_data,
	input			bus_read,
	input			bus_write,
	input			bus_io,
	input			bus_memory,
	//	RAM I/F
	output			rd,
	input			busy,
	output	[21:0]	address,
	input	[7:0]	rdata,
	input			rdata_en
);
	wire			w_jis1_dec;
	wire			w_jis2_dec;
	reg		[16:0]	ff_jis1_ptr;
	reg		[16:0]	ff_jis2_ptr;
	wire	[17:0]	w_address_l;

	assign bus_io_cs		= 1'b1;
	assign bus_memory_cs	= 1'b0;

	// --------------------------------------------------------------------
	//	Address registers
	// --------------------------------------------------------------------
	assign w_jis1_dec	= ({ address[7:1], 1'b0 } == 8'hD8);
	always @( negedge n_reset or posedge clk ) begin
		if( !n_reset ) begin
			ff_jis1_ptr <= 17'd0;
		end
		else if( bus_io && bus_write && w_jis1_dec ) begin
			if( address[0] == 1'b0 ) begin
				ff_jis1_ptr[10: 5] <= wdata[5:0];
				ff_jis1_ptr[ 4: 0] <= 5'd0;
			end
			else begin
				ff_jis1_ptr[16:11] <= wdata[5:0];
				ff_jis1_ptr[ 4: 0] <= 5'd0;
			end
		else if( bus_io && bus_read  && w_jis1_dec && enable_jis1 ) begin
			if( address[0] == 1'b1 ) begin
				ff_jis1_ptr[ 4: 0] <= ff_jis1_ptr[ 4: 0] + 5'd1;
			end
		end
		else begin
			//	hold
		end
	end

	assign w_jis2_dec	= ({ address[7:1], 1'b0 } == 8'hDA);
	always @( negedge n_reset or posedge clk ) begin
		if( !n_reset ) begin
			ff_jis2_ptr <= 17'd0;
		end
		else if( bus_io && bus_write && w_jis2_dec ) begin
			if( address[0] == 1'b0 ) begin
				ff_jis2_ptr[10: 5] <= wdata[5:0];
				ff_jis2_ptr[ 4: 0] <= 5'd0;
			end
			else begin
				ff_jis2_ptr[16:11] <= wdata[5:0];
				ff_jis2_ptr[ 4: 0] <= 5'd0;
			end
		else if( bus_io && bus_read  && w_jis2_dec && enable_jis2 ) begin
			if( address[0] == 1'b1 ) begin
				ff_jis2_ptr[ 4: 0] <= ff_jis2_ptr[ 4: 0] + 5'd1;
			end
		end
		else begin
			//	hold
		end
	end

	// --------------------------------------------------------------------
	//	ROM Reader
	// --------------------------------------------------------------------
	assign w_address_l		= ( address[2] == 1'b0 ) ? { 1'b0, ff_jis1_ptr } : { 1'b1, ff_jis2_ptr };
	assign address			= { address_h, w_address_l };
	assign rd				= bus_io & bus_read & ((w_jis1_dec & enable_jis1) | (w_jis2_dec & enable_jis2));

	assign bus_read_ready	= rdata_en;
	assign bus_read_data	= rdata;
endmodule
