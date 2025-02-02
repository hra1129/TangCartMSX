// -----------------------------------------------------------------------------
//	ip_line_buffer.v
//	Copyright (C)2025 Takayuki Hara (HRA!)
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
//		Simple video controller
// -----------------------------------------------------------------------------

module ip_line_buffer (
	input			clk,
	input	[9:0]	address,
	input			we,
	input	[7:0]	wdata,
	output	[7:0]	rdata
);
	reg		[7:0]	ff_ram	[0:1023];
	reg		[7:0]	ff_rdata;

	always @( posedge clk ) begin
		if( we ) begin
			ff_ram[ address ] <= wdata;
		end
	end

	always @( posedge clk ) begin
		if( !we ) begin
			ff_rdata <= ff_ram[ address ];
		end
		else begin
			ff_rdata <= 8'd0;
		end
	end

	assign rdata	= ff_rdata;
endmodule
