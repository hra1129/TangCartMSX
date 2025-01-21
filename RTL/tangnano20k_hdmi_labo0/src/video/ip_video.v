// -----------------------------------------------------------------------------
//	ip_video.v
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
//		UART (TX ONLY)
// -----------------------------------------------------------------------------

module ip_video (
	input			reset_n,
	input			clk,
	//	CPU I/F

	//	SDRAM I/F

	//	Monitor I/F
	output			video_de,
	output			video_hs,
	output			video_vs,
	output	[7:0]	video_r,
	output	[7:0]	video_g,
	output	[7:0]	video_b
);
	//												// 800x600   // 1024x768  // 1280x720  
	localparam	[11:0]	c_h_total   = 12'd1650;		// 12'd1056  // 12'd1344  // 12'd1650  
	localparam	[11:0]	c_h_sync    = 12'd40;		// 12'd128   // 12'd136   // 12'd40    
	localparam	[11:0]	c_h_bporch  = 12'd220;		// 12'd88    // 12'd160   // 12'd220   
	localparam	[11:0]	c_h_res     = 12'd1280;		// 12'd800   // 12'd1024  // 12'd1280  
	localparam	[11:0]	c_v_total   = 12'd750;		// 12'd628   // 12'd806   // 12'd750   
	localparam	[11:0]	c_v_sync    = 12'd5;		// 12'd4     // 12'd6     // 12'd5     
	localparam	[11:0]	c_v_bporch  = 12'd20;		// 12'd23    // 12'd29    // 12'd20    
	localparam	[11:0]	c_v_res     = 12'd720;		// 12'd600   // 12'd768   // 12'd720   

	reg		[11:0]	ff_h_counter;
	reg		[11:0]	ff_v_counter;
	reg				ff_h_window;
	reg				ff_v_window;
	reg				ff_h_sync;
	reg				ff_v_sync;
	wire			w_h_count_end;
	wire			w_v_count_end;
	reg		[7:0]	ff_r;
	reg		[7:0]	ff_g;
	reg		[7:0]	ff_b;

	// --------------------------------------------------------------------
	//	Horizontal counter
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_h_counter <= 12'd0;
		end
		else if( w_h_count_end ) begin
			ff_h_counter <= 12'd0;
		end
		else begin
			ff_h_counter <= ff_h_counter + 12'd1;
		end
	end
	assign w_h_count_end = (ff_h_counter == (c_h_total - 12'd1));;

	// --------------------------------------------------------------------
	//	Vertical counter
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_v_counter <= 12'd0;
		end
		else if( w_h_count_end ) begin
			if( w_v_count_end ) begin
				ff_v_counter <= 12'd0;
			end
			else begin
				ff_v_counter <= ff_v_counter + 12'd1;
			end
		end
		else begin
			//	hold
		end
	end
	assign w_v_count_end = (ff_v_counter == (c_v_total - 12'd1));;

	// --------------------------------------------------------------------
	//	Horizontal window
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_h_window <= 1'b0;
		end
		else if( ff_h_counter == (c_h_sync + c_h_bporch - 12'd1) ) begin
			ff_h_window <= 1'b1;
		end
		else if( ff_h_counter == (c_h_sync + c_h_bporch + c_h_res - 12'd1) ) begin
			ff_h_window <= 1'b0;
		end
		else begin
			//	hold
		end
	end

	// --------------------------------------------------------------------
	//	Vertical window
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_v_window <= 1'b0;
		end
		else if( w_h_count_end ) begin
			if(      ff_v_counter == (c_v_sync + c_v_bporch - 12'd1) ) begin
				ff_v_window <= 1'b1;
			end
			else if( ff_v_counter == (c_v_sync + c_v_bporch + c_v_res - 12'd1) ) begin
				ff_v_window <= 1'b0;
			end
			else begin
				//	hold
			end
		end
		else begin
			//	hold
		end
	end

	// --------------------------------------------------------------------
	//	Horizontal synchronous signal
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_h_sync <= 1'b0;
		end
		else if( w_h_count_end ) begin
			ff_h_sync <= 1'b1;
		end
		else if( ff_h_counter == (c_h_sync - 12'd1) ) begin
			ff_h_sync <= 1'b0;
		end
		else begin
			//	hold
		end
	end

	// --------------------------------------------------------------------
	//	Horizontal synchronous signal
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_v_sync <= 1'b0;
		end
		else if( w_h_count_end ) begin
			if( w_v_count_end ) begin
				ff_v_sync <= 1'b1;
			end
			else if( ff_v_counter == (c_v_sync - 12'd1) ) begin
				ff_v_sync <= 1'b0;
			end
			else begin
				//	hold
			end
		end
	end

	// --------------------------------------------------------------------
	//	Pixel data
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_r <= 8'd0;
			ff_g <= 8'd0;
			ff_b <= 8'd0;
		end
		else begin
			ff_r <= ff_h_counter[7:0];
			ff_g <= ff_h_counter[7:0] ^ 8'hFF;
			ff_b <= ff_v_counter[7:0];
		end
	end

	assign video_de	= ff_h_window & ff_v_window;
	assign video_hs	= ff_h_sync;
	assign video_vs	= ff_v_sync;
	assign video_r	= ff_r;
	assign video_g	= ff_g;
	assign video_b	= ff_b;
endmodule
