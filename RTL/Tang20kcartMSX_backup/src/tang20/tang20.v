// -----------------------------------------------------------------------------
//	tang20.v
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
//		Tangnano20K Cartridge for MSX
// -----------------------------------------------------------------------------
module tang20 (
	input			clk,
	input			n_reset,
	input	[7:0]	ta,
	output	[1:0]	toe,
	output	[15:0]	address
);

`default_nettype none

	reg		[1:0]	ff_state;
	reg		[7:0]	ff_pre_address;
	reg		[15:0]	ff_address;

	// --------------------------------------------------------------------
	//	Address latch
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_state <= 2'd0;
		end
		else begin
			ff_state <= ff_state + 2'd1;
		end
	end

	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_pre_address <= 8'd0;
		end
		else if( ff_state == 2'b01 ) begin
			ff_pre_address <= ta;
		end
	end

	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_address <= 16'd0;
		end
		else if( ff_state == 2'b11 ) begin
			ff_address[ 0] <= ff_pre_address[0];
			ff_address[ 1] <= ff_pre_address[1];
			ff_address[ 2] <= ff_pre_address[2];
			ff_address[ 3] <= ff_pre_address[3];
			ff_address[ 4] <= ff_pre_address[4];
			ff_address[ 5] <= ff_pre_address[5];
			ff_address[13] <= ff_pre_address[6];
			ff_address[14] <= ff_pre_address[7];

			ff_address[11] <= ta[0];
			ff_address[ 6] <= ta[1];
			ff_address[ 7] <= ta[2];
			ff_address[10] <= ta[3];
			ff_address[12] <= ta[4];
			ff_address[15] <= ta[5];
			ff_address[ 9] <= ta[6];
			ff_address[ 8] <= ta[7];
		end
	end

	assign address	= ff_address;
	assign toe[0]	= !n_reset ? 1'b1 : ff_state[1];
	assign toe[1]	= !n_reset ? 1'b1 : ~ff_state[1];
endmodule

`default_nettype wire
