// -----------------------------------------------------------------------------
//	ip_gpio.v
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
//		1byte GPIO
// -----------------------------------------------------------------------------

module ip_gpio #(
	parameter		io_address = 8'h01
) (
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
	//	OUTPUT
	output	[7:0]	gpo,
	input	[7:0]	gpi
);
	wire			w_gpio_dec;
	reg		[7:0]	ff_gpo;
	reg				ff_read_ready;

	// --------------------------------------------------------------------
	//	Address decode
	// --------------------------------------------------------------------
	assign w_gpio_dec		= (bus_address[7:0] == io_address);

	// --------------------------------------------------------------------
	//	Write register
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_gpo <= 8'h00;
		end
		else if( w_gpio_dec && bus_io_write ) begin
			ff_gpo <= bus_write_data;
		end
		else begin
			//	hold
		end
	end
	assign gpo		= ff_gpo;

	// --------------------------------------------------------------------
	//	Read response
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_read_ready <= 1'b0;
		end
		else if( w_gpio_dec && bus_io_read ) begin
			ff_read_ready <= 1'b1;
		end
		else begin
			ff_read_ready <= 1'b0;
		end
	end

	assign bus_read_data	= ff_read_ready ? gpi : 8'h00;
	assign bus_read_ready	= ff_read_ready;
endmodule
