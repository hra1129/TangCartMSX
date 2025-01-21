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
	parameter		io_address = 8'h10
) (
	//	Internal I/F
	input			reset_n,
	input			clk,
	//	MSX-50BUS
	input			iorq_n,
	input	[7:0]	address,
	input			rd_n,
	input			wr_n,
	input	[7:0]	d,
	output	[7:0]	q,
	output			q_en,
	//	OUTPUT
	output	[7:0]	gpo,
	input	[7:0]	gpi
);
	wire			w_gpio_dec;
	reg		[7:0]	ff_gpo;
	reg				ff_iorq_n;
	reg				ff_wr_n;
	reg				ff_rd_n;
	wire			w_wr;
	wire			w_rd;
	reg				ff_q_en;

	// --------------------------------------------------------------------
	//	Pulse conversion
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_wr_n		<= 1'b1;
			ff_rd_n		<= 1'b1;
			ff_iorq_n	<= 1'b1;
		end
		else begin
			ff_wr_n		<= wr_n;
			ff_rd_n		<= rd_n;
			ff_iorq_n	<= iorq_n;
		end
	end

	assign w_wr	= ~ff_iorq_n & ~ff_wr_n &  wr_n;
	assign w_rd	=    ~iorq_n &  ff_rd_n & ~rd_n;

	// --------------------------------------------------------------------
	//	Address decode
	// --------------------------------------------------------------------
	assign w_gpio_dec		= (address == io_address);

	// --------------------------------------------------------------------
	//	Write register
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_gpo <= 8'h00;
		end
		else if( w_wr && w_gpio_dec ) begin
			ff_gpo <= d;
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
		if( !reset_n ) begin
			ff_q_en <= 1'b0;
		end
		else if( w_rd && w_gpio_dec ) begin
			ff_q_en <= 1'b1;
		end
		else begin
			ff_q_en <= 1'b0;
		end
	end

	assign q	= ff_q_en ? gpi : 8'h00;
	assign q_en	= ff_q_en;
endmodule
