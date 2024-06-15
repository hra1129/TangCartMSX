// -----------------------------------------------------------------------------
//	ip_vdp9918_timing.v
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
//		Timing Generator
// -----------------------------------------------------------------------------

module ip_vdp9918_timing (
	input			n_reset,
	input			clk,
	input			enable,		//	10.738635MHz
);
	reg		[9:0]	ff_hcnt;
	reg		[8:0]	ff_vcnt;
	wire			w_hcnt_full;
	wire			w_vcnt_full;
	wire	[8:0]	w_ycnt;

	// --------------------------------------------------------------------
	//  Timing signals
	// --------------------------------------------------------------------
	assign w_hcnt_full		= ( ff_hcnt == 10'd683 ) ? 1'b1 : 1'b0;
	assign w_vcnt_full		= ( ff_vcnt ==  9'd262 ) ? 1'b1 : 1'b0;
	assign w_xcnt			= ff_hcnt - 10'd126;
	assign w_ycnt			= ff_vcnt - 9'd26;

	// --------------------------------------------------------------------
	//  Horizontal counter
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( n_reset ) begin
			ff_hcnt <= 10'd0;
		end
		else if( enable ) begin
			if( w_hcnt_full ) begin
				ff_hcnt <= 10'd0;
			end
			else begin
				ff_hcnt <= ff_hcnt + 10'd1;
			end
		end
	end

	// --------------------------------------------------------------------
	//  Vertical counter
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( n_reset ) begin
			ff_vcnt <= 9'd0;
		end
		else if( enable && w_hcnt_full ) begin
			if( w_vcnt_full ) begin
				ff_vcnt <= 9'd0;
			end
			else begin
				ff_vcnt <= ff_vcnt + 9'd1;
			end
		end
	end

endmodule
