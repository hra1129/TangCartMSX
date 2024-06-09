// -----------------------------------------------------------------------------
//	ip_extslot.v
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
//		EXTENDED SLOT
// -----------------------------------------------------------------------------

module ip_extslot (
	//	Internal I/F
	input			n_reset,
	input			clk,
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
	//	OUTPUT
	output			extslot_memory0,
	output			extslot_memory1,
	output			extslot_memory2,
	output			extslot_memory3
);
	wire			w_extslot_dec;
	wire	[1:0]	w_extslot_reg;
	reg		[7:0]	ff_extslot_reg;
	reg				ff_read_ready;

	// --------------------------------------------------------------------
	//	Active bus select
	// --------------------------------------------------------------------
	assign bus_io_cs		= 1'b0;
	assign bus_memory_cs	= 1'b1;

	// --------------------------------------------------------------------
	//	Address decode
	// --------------------------------------------------------------------
	assign w_extslot_dec	= (bus_address == 16'hFFFF);

	// --------------------------------------------------------------------
	//	Write register
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_extslot_reg <= 8'h00;
		end
		else if( bus_memory && w_extslot_dec && bus_write ) begin
			ff_extslot_reg <= bus_write_data;
		end
		else begin
			//	hold
		end
	end

	// --------------------------------------------------------------------
	//	Read response
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_read_ready <= 1'b0;
		end
		else if( bus_memory && w_extslot_dec && bus_read ) begin
			ff_read_ready <= 1'b1;
		end
		else begin
			ff_read_ready <= 1'b0;
		end
	end

	assign bus_read_data	= ff_read_ready ? ~ff_extslot_reg : 8'h00;
	assign bus_read_ready	= ff_read_ready;

	// --------------------------------------------------------------------
	//	/SLTSL
	// --------------------------------------------------------------------
	function [1:0] func_page_sel(
		input	[1:0]	page_no,
		input	[7:0]	ff_extslot_reg
	);
		case( page_no )
		2'd0:		func_page_sel = ff_extslot_reg[1:0];
		2'd1:		func_page_sel = ff_extslot_reg[3:2];
		2'd2:		func_page_sel = ff_extslot_reg[5:4];
		2'd3:		func_page_sel = ff_extslot_reg[7:6];
		default:	func_page_sel = ff_extslot_reg[1:0];
		endcase
	endfunction

	assign w_extslot_reg	= func_page_sel( bus_address[15:14], ff_extslot_reg );
	assign extslot_memory0	= bus_memory & ~w_extslot_dec & (w_extslot_reg == 2'd0);
	assign extslot_memory1	= bus_memory & ~w_extslot_dec & (w_extslot_reg == 2'd1);
	assign extslot_memory2	= bus_memory & ~w_extslot_dec & (w_extslot_reg == 2'd2);
	assign extslot_memory3	= bus_memory & ~w_extslot_dec & (w_extslot_reg == 2'd3);
endmodule
