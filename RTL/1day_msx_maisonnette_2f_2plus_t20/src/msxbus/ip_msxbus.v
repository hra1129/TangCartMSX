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
	//	internal signals
	output	[15:0]	bus_address,
	input	[7:0]	bus_read_data,
	input			bus_read_data_en,
	output	[7:0]	bus_write_data,
	output			bus_io_req,
	output			bus_memory_req,
	input			bus_ack,
	output			bus_write
);
	//	Flip-flops for asynchronous switching and low-pass
	reg				ff_n_sltsl;
	reg				ff_n_rd;
	reg				ff_n_wr;
	reg				ff_n_ioreq;
	wire			w_wr_req;
	wire			w_rd_req;
	wire			w_n_io_req;
	wire			w_n_memory_req;
	reg				ff_io_req;
	reg				ff_memory_req;
	reg				ff_access_hold;
	//	Latch
	reg		[15:0]	ff_bus_address;
	reg		[7:0]	ff_bus_write_data;
	reg		[7:0]	ff_bus_read_data;
	reg				ff_bus_read_data_en;

	// --------------------------------------------------------------------
	//	Asynchronous switching
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

	assign w_wr_req			= ff_n_wr & ~n_wr;
	assign w_rd_req			= ff_n_rd & ~n_rd;
	assign w_n_io_req		= n_ioreq | ~(w_wr_req | w_rd_req);
	assign w_n_memory_req	= n_sltsl | ~(w_wr_req | w_rd_req);

	// --------------------------------------------------------------------
	//	Make up pulse
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_io_req <= 1'b0;
		end
		else if( bus_ack ) begin
			ff_io_req <= 1'b0;
		end
		else if( !w_n_io_req && !ff_access_hold ) begin
			ff_io_req <= 1'b1;
		end
		else begin
			//	hold
		end
	end

	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_memory_req <= 1'b0;
		end
		else if( bus_ack ) begin
			ff_memory_req <= 1'b0;
		end
		else if( !w_n_memory_req && !ff_access_hold ) begin
			ff_memory_req <= 1'b1;
		end
		else begin
			//	hold
		end
	end

	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_access_hold <= 1'b0;
		end
		else if( !w_n_io_req || !w_n_memory_req ) begin
			ff_access_hold <= 1'b1;
		end
		else if( ff_n_rd && ff_n_wr ) begin
			ff_access_hold <= 1'b0;
		end
		else begin
			//	hold
		end
	end

	// --------------------------------------------------------------------
	//	Latch
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_bus_address		<= 'd0;
		end
		else if( (!w_n_io_req || !w_n_memory_req) && !ff_access_hold ) begin
			ff_bus_address		<= adr;
		end
		else begin
			//	hold
		end
	end

	always @( posedge clk ) begin
		if( w_wr_req ) begin
			ff_bus_write_data	<= i_data;
		end
		else begin
			//	hold
		end
	end

	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_bus_read_data	<= 8'd0;
			ff_bus_read_data_en	<= 1'b0;
		end
		else if( ff_n_rd == 1'b1 ) begin
			ff_bus_read_data	<= 8'd0;
			ff_bus_read_data_en	<= 1'b0;
		end
		else if( bus_read_data_en ) begin
			ff_bus_read_data	<= bus_read_data;
			ff_bus_read_data_en	<= 1'b1;
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
	assign bus_io_req		= ff_io_req;
	assign bus_memory_req	= ff_memory_req;
	assign bus_write		= ~ff_n_wr;

	// --------------------------------------------------------------------
	//	MSX BUS response
	// --------------------------------------------------------------------
	assign o_data			= ff_bus_read_data;
	assign is_output		= ff_bus_read_data_en & ~n_rd;
endmodule
