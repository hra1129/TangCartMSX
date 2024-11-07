// -----------------------------------------------------------------------------
//	ip_msx50bus_cart.v
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

module ip_msx50bus_cart (
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
	output			bus_io_req,
	output			bus_memory_req,
	input			bus_ack,
	output			bus_wrt,
	output			bus_wdata,
	input			bus_rdata,
	input			bus_rdata_en
);
	//	Flip-flops for asynchronous switching
	reg				ff_n_sltsl;
	reg				ff_n_ioreq;
	reg				ff_n_rd;
	reg				ff_n_wr;
	//	Make up pulse
	wire			w_io_req_pulse;
	wire			w_memory_req_pulse;
	wire			w_wrt_pulse;
	//	Latch
	reg		[15:0]	ff_address;
	reg		[7:0]	ff_rdata;
	reg		[7:0]	ff_wdata;
	reg				ff_io_req;
	reg				ff_memory_req;
	reg				ff_is_output;

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

	assign w_io_req			= ~ff_n_ioreq & (~ff_n_wr | ~ff_n_rd);
	assign w_memory_req		= ~ff_n_sltsl & (~ff_n_wr | ~ff_n_rd);
	assign w_wrt			= ~ff_n_wr;

	// --------------------------------------------------------------------
	//	Make up pulse
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_io_req		<= 1'b0;
			ff_memory_req	<= 1'b0;
			ff_wrt			<= 1'b0;
		end
		else begin
			ff_io_req		<= w_io_req;
			ff_memory_req	<= w_memory_req;
			ff_wrt			<= w_wrt;
		end
	end

	assign w_io_req_pulse		= ~ff_io_req     & w_io_req;
	assign w_memory_req_pulse	= ~ff_memory_req & w_memory_req;
	assign w_wrt_pulse			= ~ff_wrt        & w_wrt;

	// --------------------------------------------------------------------
	//	Latch
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_bus_address		<= 'd0;
		end
		else if( w_io_req_pulse || w_memory_req_pulse ) begin
			ff_bus_address		<= adr;
		end
		else begin
			//	hold
		end
	end

	always @( posedge clk ) begin
		if( w_wrt_pulse ) begin
			ff_wdata	<= i_data;
		end
		else begin
			//	hold
		end
	end

	always @( posedge clk ) begin
		if( bus_ack ) begin
			ff_io_req	<= 1'b0;
		end
		else if( w_io_req_pulse ) begin
			ff_io_req	<= 1'b1;
		end
		else begin
			//	hold
		end
	end

	always @( posedge clk ) begin
		if( bus_ack ) begin
			ff_memory_req	<= 1'b0;
		end
		else if( w_memory_req_pulse ) begin
			ff_memory_req	<= 1'b1;
		end
		else begin
			//	hold
		end
	end

	always @( posedge clk ) begin
		if( bus_ack ) begin
			ff_wrt	<= 1'b0;
		end
		else if( w_wrt_pulse ) begin
			ff_wrt	<= 1'b1;
		end
		else begin
			//	hold
		end
	end

	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_rdata		<= 8'd0;
			ff_is_output	<= 1'b0;
		end
		else if( ff_n_rd == 1'b1 ) begin
			ff_rdata		<= 8'd0;
			ff_is_output	<= 1'b0;
		end
		else if( bus_rdata_en ) begin
			ff_rdata		<= bus_rdata;
			ff_is_output	<= 1'b1;
		end
		else begin
			//	hold
		end
	end

	// --------------------------------------------------------------------
	//	Internal BUS signals
	// --------------------------------------------------------------------
	assign bus_address		= ff_address;
	assign bus_io_req		= ff_io_req;
	assign bus_memory_req	= ff_memory_req;
	assign bus_wrt			= ff_wrt;
	assign bus_wdata		= ff_wdata;

	// --------------------------------------------------------------------
	//	MSX BUS response
	// --------------------------------------------------------------------
	assign o_data			= ff_rdata;
	assign is_output		= ff_is_output;
endmodule
