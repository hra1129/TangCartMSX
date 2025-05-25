// -----------------------------------------------------------------------------
//	ip_vga.v
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
//		VGA OUTPUT TEST
// -----------------------------------------------------------------------------

module ip_vga (
	input			n_reset,
	input			clk42m,
	output	[2:0]	video_r,
	output	[2:0]	video_g,
	output	[2:0]	video_b,
	output			video_hs,
	output			video_vs,
	input	[7:0]	latch_data
);
	//	Horizontal timing values
	localparam c_h_blank	= 10'd79;	//	(1)
	localparam c_h_top		= 10'd120;	//	(2)
	localparam c_h_active	= 10'd670;	//	(3)
	localparam c_h_total	= 10'd683;	//	(4) 0...683 (total 684 clocks)
	//	                  _________________
	//	video_hs   ______| :            :  |
	//	                 : :____________:  :
	//	ff_h_active______:_|            |__:
	//	               (1)(2)          (3)(4)

	//	Vertical timing values
	localparam c_v_blank	= 10'd1;	//	[1]
	localparam c_v_top		= 10'd31;	//	[2]
	localparam c_v_active	= 10'd479;	//	[3]
	localparam c_v_total	= 10'd523;	//	[4] 0...523 (total 524 lines)
	//	                ____________________
	//	video_vs   ____|    :           :   |
	//	               :    :___________:   :
	//	ff_v_active____:____|           |___:
	//	              [1]  [2]         [3] [4]

	//	Latch data position
	localparam c_latch_data_x	= c_h_top + 100;
	localparam c_latch_data_y	= c_v_top + 100;

	reg				ff_enable;
	reg		[9:0]	ff_h_cnt;
	reg		[9:0]	ff_v_cnt;
	reg				ff_h_active;
	reg				ff_v_active;
	reg				ff_hs;
	reg				ff_vs;
	reg		[3:0]	ff_r;
	reg		[3:0]	ff_g;
	reg		[3:0]	ff_b;
	wire			w_h_active;
	wire			w_h_cnt_end;
	wire			w_h_top;
	wire			w_v_active;
	wire			w_v_cnt_end;
	wire			w_v_top;
	wire	[9:0]	w_x;
	wire	[9:0]	w_y;
	wire			w_digit;
	reg				ff_pixel;

	// --------------------------------------------------------------------
	//	Clock divider
	// --------------------------------------------------------------------
	always @( posedge clk42m or negedge n_reset ) begin
		if( !n_reset ) begin
			ff_enable <= 1'b0;
		end
		else begin
			ff_enable <= ~ff_enable;
		end
	end

	// --------------------------------------------------------------------
	//	Horizontal counter
	// --------------------------------------------------------------------
	always @( posedge clk42m or negedge n_reset ) begin
		if( !n_reset ) begin
			ff_h_cnt <= 10'd0;
		end
		else if( ff_enable ) begin
			if( w_h_cnt_end ) begin
				ff_h_cnt <= 10'd0;
			end
			else begin
				ff_h_cnt <= ff_h_cnt + 10'd1;
			end
		end
		else begin
			//	hold
		end
	end

	always @( posedge clk42m or negedge n_reset ) begin
		if( !n_reset ) begin
			ff_hs <= 1'b0;
		end
		else if( ff_enable ) begin
			if( w_h_cnt_end ) begin
				ff_hs <= 1'b0;
			end
			else if( w_h_active ) begin
				ff_hs <= 1'b1;
			end
			else begin
				//	hold
			end
		end
		else begin
			//	hold
		end
	end

	always @( posedge clk42m or negedge n_reset ) begin
		if( !n_reset ) begin
			ff_h_active <= 1'b0;
		end
		else if( ff_enable ) begin
			if( c_h_top ) begin
				ff_h_active <= 1'b1;
			end
			else if( w_h_active ) begin
				ff_h_active <= 1'b0;
			end
			else begin
				//	hold
			end
		end
		else begin
			//	hold
		end
	end

	assign w_h_cnt_end	= (ff_h_cnt == c_h_total ) ? 1'b1: 1'b0;
	assign w_h_top		= (ff_h_cnt == c_h_top   ) ? 1'b1: 1'b0;
	assign w_h_active	= (ff_h_cnt == c_h_active) ? 1'b1: 1'b0;

	// --------------------------------------------------------------------
	//	Vertical counter
	// --------------------------------------------------------------------
	always @( posedge clk42m or negedge n_reset ) begin
		if( !n_reset ) begin
			ff_v_cnt <= 10'd0;
		end
		else if( ff_enable && w_h_cnt_end ) begin
			if( w_v_cnt_end ) begin
				ff_v_cnt <= 10'd0;
			end
			else begin
				ff_v_cnt <= ff_v_cnt + 10'd1;
			end
		end
		else begin
			//	hold
		end
	end

	always @( posedge clk42m or negedge n_reset ) begin
		if( !n_reset ) begin
			ff_vs <= 1'b0;
		end
		else if( ff_enable && w_h_cnt_end ) begin
			if( w_v_cnt_end ) begin
				ff_vs <= 1'b0;
			end
			else if( w_v_active ) begin
				ff_vs <= 1'b1;
			end
			else begin
				//	hold
			end
		end
		else begin
			//	hold
		end
	end

	always @( posedge clk42m or negedge n_reset ) begin
		if( !n_reset ) begin
			ff_v_active <= 1'b0;
		end
		else if( ff_enable && w_h_cnt_end ) begin
			if( c_v_top ) begin
				ff_v_active <= 1'b1;
			end
			else if( w_v_active ) begin
				ff_v_active <= 1'b0;
			end
			else begin
				//	hold
			end
		end
		else begin
			//	hold
		end
	end

	assign w_v_cnt_end	= (ff_v_cnt == c_v_total ) ? 1'b1: 1'b0;
	assign w_v_top		= (ff_v_cnt == c_v_top   ) ? 1'b1: 1'b0;
	assign w_v_active	= (ff_v_cnt == c_v_active) ? 1'b1: 1'b0;

	// --------------------------------------------------------------------
	//	Color signals
	// --------------------------------------------------------------------
	always @( posedge clk42m or negedge n_reset ) begin
		if( !n_reset ) begin
			ff_r <= 4'd0;
		end
		else if( ff_enable ) begin
			if( w_h_cnt_end ) begin
				ff_r <= 4'd0;
			end
			else begin
				ff_r <= ff_r + 4'd1;
			end
		end
	end

	always @( posedge clk42m or negedge n_reset ) begin
		if( !n_reset ) begin
			ff_g <= 4'd0;
		end
		else if( ff_enable ) begin
			if( w_h_cnt_end ) begin
				ff_g <= 4'd0;
			end
			else if( ff_r == 4'b1111 ) begin
				ff_g <= ff_g + 4'd1;
			end
			else begin
				//	hold
			end
		end
	end

	always @( posedge clk42m or negedge n_reset ) begin
		if( !n_reset ) begin
			ff_b <= 4'd0;
		end
		else if( ff_enable && w_h_cnt_end ) begin
			if( w_v_cnt_end ) begin
				ff_b <= 4'd0;
			end
			else begin
				ff_b <= ff_b + 4'd1;
			end
		end
	end

	assign video_r	= (ff_pixel) ? 3'd7: ((ff_h_active && ff_v_active) ? { 1'b0, ff_r[3:2] }: 3'd0);
	assign video_g	= (ff_pixel) ? 3'd7: ((ff_h_active && ff_v_active) ? { 1'b0, ff_g[3:2] }: 3'd0);
	assign video_b	= (ff_pixel) ? 3'd7: ((ff_h_active && ff_v_active) ? { 1'b0, ff_b[3:2] }: 3'd0);
	assign video_hs	= ff_hs;
	assign video_vs	= ff_vs;

	// --------------------------------------------------------------------
	//	Latch data
	//		+-8-+-8-+-8-+-8-+-8-+-8-+-8-+-8-+ total 64 pixels
	//		|   |   |   |   |   |   |   |   |
	//		8   |   |   |   |   |   |   |   |
	//		|   |   |   |   |   |   |   |   |
	//		+-8-+-8-+-8-+-8-+-8-+-8-+-8-+-8-+
	// --------------------------------------------------------------------
	assign w_x		= ff_h_cnt - c_latch_data_x;
	assign w_y		= ff_v_cnt - c_latch_data_y;
	assign w_digit	= latch_data[ ~w_x[5:3] ];
	always @( posedge clk42m ) begin
		if( w_x[9:6] != 5'd0 || w_y[9:3] != 8'd0 || w_x[2:0] == 3'd7 ) begin
			ff_pixel <= 1'b0;
		end
		else if( !w_digit ) begin
			//	Case of '0'
			if( w_y[2:0] == 3'd0 || w_y[2:0] == 3'd7 ) begin
				ff_pixel <= 1'b1;
			end
			else if( w_x[2:0] == 3'd0 || w_x[2:0] == 3'd6 ) begin
				ff_pixel <= 1'b1;
			end
			else begin
				ff_pixel <= 1'b0;
			end
		end
		else begin
			//	Case of '1'
			if( w_x[2:0] == 3'd4 ) begin
				ff_pixel <= 1'b1;
			end
			else begin
				ff_pixel <= 1'b0;
			end
		end
	end
endmodule
