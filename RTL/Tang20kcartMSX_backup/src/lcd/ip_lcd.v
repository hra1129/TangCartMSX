// -----------------------------------------------------------------------------
//	ip_lcd.v
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
//		800x480 LCD Controller
// -----------------------------------------------------------------------------

module ip_lcd (
	//	Internal I/F
	input			n_reset,
	input			clk,				// 87.75MHz
	//	LCD output
	output			lcd_clk,
	output			lcd_hsync,
	output			lcd_vsync,
	output			lcd_de,
	output	[4:0]	lcd_red,
	output	[4:0]	lcd_green,
	output	[4:0]	lcd_blue
);
	// Horizontal timing by ff_h_cnt value
	localparam		h_pulse_end			= 19;
	localparam		h_back_porch_end	= 45;
	localparam		h_active_end		= h_back_porch_end + 800;
	localparam		h_front_porch_end	= h_active_end + 210;
	// Vertical timing by ff_v_cnt value
	localparam		v_pulse_end			= 9;
	localparam		v_back_porch_end	= 22;
	localparam		v_active_end		= v_back_porch_end + 480;
	localparam		v_front_porch_end	= v_active_end + 21;
	reg				ff_lcd_clk;
	reg		[10:0]	ff_h_cnt;
	reg				ff_h_sync;
	reg				ff_h_active;
	wire			w_h_pulse_end;
	wire			w_h_back_porch_end;
	wire			w_h_active_end;
	wire			w_h_front_porch_end;
	reg		[10:0]	ff_v_cnt;
	reg				ff_v_sync;
	reg				ff_v_active;
	wire			w_v_pulse_end;
	wire			w_v_back_porch_end;
	wire			w_v_active_end;
	wire			w_v_front_porch_end;
	reg		[4:0]	ff_red;
	reg		[4:0]	ff_green;
	reg		[4:0]	ff_blue;
	reg		[4:0]	ff_x;

	// --------------------------------------------------------------------
	//	Timing signals
	// --------------------------------------------------------------------
	assign w_h_pulse_end		= (ff_h_cnt == h_pulse_end);
	assign w_h_back_porch_end	= (ff_h_cnt == h_back_porch_end);
	assign w_h_active_end		= (ff_h_cnt == h_active_end);
	assign w_h_front_porch_end	= (ff_h_cnt == h_front_porch_end);
	assign w_v_pulse_end		= (ff_v_cnt == v_pulse_end);
	assign w_v_back_porch_end	= (ff_v_cnt == v_back_porch_end);
	assign w_v_active_end		= (ff_v_cnt == v_active_end);
	assign w_v_front_porch_end	= (ff_v_cnt == v_front_porch_end);

	// --------------------------------------------------------------------
	//	LCD clock
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_lcd_clk <= 1'b0;
		end
		else begin
			ff_lcd_clk <= ~ff_lcd_clk;
		end
	end

	// --------------------------------------------------------------------
	//	H Counter
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_h_cnt <= 11'd0;
		end
		else if( !ff_lcd_clk ) begin
			if( w_h_front_porch_end ) begin
				ff_h_cnt <= 11'd0;
			end
			else begin
				ff_h_cnt <= ff_h_cnt + 11'd1;
			end
		end
		else begin
			//	hold
		end
	end

	// --------------------------------------------------------------------
	//	H Sync
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_h_sync <= 1'b0;
		end
		else if( !ff_lcd_clk ) begin
			if( w_h_front_porch_end ) begin
				ff_h_sync <= 1'b0;
			end
			else if( w_h_pulse_end ) begin
				ff_h_sync <= 1'b1;
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
	//	H Active
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_h_active <= 1'b0;
		end
		else if( !ff_lcd_clk ) begin
			if( w_h_active_end ) begin
				ff_h_active <= 1'b0;
			end
			else if( w_h_back_porch_end ) begin
				ff_h_active <= 1'b1;
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
	//	V Counter
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_v_cnt <= 11'd0;
		end
		else if( !ff_lcd_clk && w_h_front_porch_end ) begin
			if( w_v_front_porch_end ) begin
				ff_v_cnt <= 11'd0;
			end
			else begin
				ff_v_cnt <= ff_v_cnt + 11'd1;
			end
		end
		else begin
			//	hold
		end
	end

	// --------------------------------------------------------------------
	//	V Sync
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_v_sync <= 1'b0;
		end
		else if( !ff_lcd_clk && w_h_front_porch_end ) begin
			if( w_v_front_porch_end ) begin
				ff_v_sync <= 1'b0;
			end
			else if( w_v_pulse_end ) begin
				ff_v_sync <= 1'b1;
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
	//	V Active
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_v_active <= 1'b0;
		end
		else if( !ff_lcd_clk && w_h_front_porch_end ) begin
			if( w_v_active_end ) begin
				ff_v_active <= 1'b0;
			end
			else if( w_v_back_porch_end ) begin
				ff_v_active <= 1'b1;
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
	//	Color
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_red		<= 5'd0;
			ff_green	<= 5'd0;
			ff_blue		<= 5'd0;
		end
		else if( !ff_lcd_clk && w_h_back_porch_end ) begin
			if( (v_back_porch_end         < ff_v_cnt) && (ff_v_cnt <= (v_back_porch_end + 160)) ) begin
				ff_red		<= ff_x;
				ff_green	<= 5'd0;
				ff_blue		<= 5'd0;
			end
			else if( ((v_back_porch_end + 160) < ff_v_cnt) && (ff_v_cnt <= (v_back_porch_end + 320)) ) begin
				ff_red		<= 5'd0;
				ff_green	<= { ff_x[3:0], 1'b0 };
				ff_blue		<= 5'd0;
			end
			else if( ((v_back_porch_end + 320) < ff_v_cnt) && (ff_v_cnt <= (v_back_porch_end + 480)) ) begin
				ff_red		<= 5'd0;
				ff_green	<= 5'd0;
				ff_blue		<= { ff_x[3:0], 1'b0 } + ff_x;
			end
		end
		else if( !ff_lcd_clk && ff_h_active ) begin
			if( (v_back_porch_end         < ff_v_cnt) && (ff_v_cnt <= (v_back_porch_end + 160)) ) begin
				ff_red		<= ff_red + 5'd1;
			end
			else if( ((v_back_porch_end + 160) < ff_v_cnt) && (ff_v_cnt <= (v_back_porch_end + 320)) ) begin
				ff_green	<= ff_green + 5'd1;
			end
			else if( ((v_back_porch_end + 320) < ff_v_cnt) && (ff_v_cnt <= (v_back_porch_end + 480)) ) begin
				ff_blue		<= ff_blue + 5'd1;
			end
		end
		else begin
			//	hold
		end
	end

	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_x <= 5'd0;
		end
		else if( !ff_lcd_clk && w_h_back_porch_end ) begin
			if( w_v_back_porch_end ) begin
				ff_x <= ff_x + 5'd1;
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
	//	Output signals
	// --------------------------------------------------------------------
	assign lcd_clk		= ff_lcd_clk;
	assign lcd_hsync	= ff_h_sync;
	assign lcd_vsync	= ff_v_sync;
	assign lcd_red		= ff_red;
	assign lcd_green	= ff_green;
	assign lcd_blue		= ff_blue;
	assign lcd_de		= ff_h_active & ff_v_active;
endmodule
