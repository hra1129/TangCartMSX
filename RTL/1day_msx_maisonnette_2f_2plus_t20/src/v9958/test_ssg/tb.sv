// -----------------------------------------------------------------------------
//	Test of vdp_ssg entity
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
//		Pulse wave modulation
// -----------------------------------------------------------------------------

module tb ();
	localparam		clk_base	= 1_000_000_000/87_750;	//	ps
	reg					reset;
	reg					clk;
	reg					enable;

	wire		[10:0]	h_cnt;
	wire		[10:0]	v_cnt;
	wire		[1:0]	dot_state;
	wire		[2:0]	eight_dot_state;
	wire		[8:0]	pre_dot_counter_x;
	wire		[8:0]	pre_dot_counter_y;
	wire		[8:0]	pre_dot_counter_yp;
	wire				pre_window_y;
	wire				pre_window_y_sp;
	wire				field;
	wire				window_x;
	wire				p_video_dh_clk;
	wire				p_video_dl_clk;
	wire				p_video_vs_n;

	wire				hd;
	wire				vd;
	wire				hsync;
	wire				hsync_en;
	wire				v_blanking_start;

	reg					vdp_r9_pal_mode;
	reg					reg_r9_interlace_mode;
	reg					reg_r9_y_dots;
	reg			[7:0]	reg_r18_adj;
	reg			[7:0]	reg_r23_vstart_line;
	reg					reg_r25_msk;
	reg			[2:0]	reg_r27_h_scroll;
	reg					reg_r25_yjk;
	reg					centeryjk_r25_n;
	int					i, j;

	// --------------------------------------------------------------------
	//	DUT
	// --------------------------------------------------------------------
	vdp_ssg u_vdp_ssg (
		.reset					( reset					),
		.clk					( clk					),
		.enable					( enable				),
		.h_cnt					( h_cnt					),
		.v_cnt					( v_cnt					),
		.dot_state				( dot_state				),
		.eight_dot_state		( eight_dot_state		),
		.pre_dot_counter_x		( pre_dot_counter_x		),
		.pre_dot_counter_y		( pre_dot_counter_y		),
		.pre_dot_counter_yp		( pre_dot_counter_yp	),
		.pre_window_y			( pre_window_y			),
		.pre_window_y_sp		( pre_window_y_sp		),
		.field					( field					),
		.window_x				( window_x				),
		.p_video_dh_clk			( p_video_dh_clk		),
		.p_video_dl_clk			( p_video_dl_clk		),
		.p_video_vs_n			( p_video_vs_n			),
		.hd						( hd					),
		.vd						( vd					),
		.hsync					( hsync					),
		.hsync_en				( hsync_en				),
		.v_blanking_start		( v_blanking_start		),
		.vdp_r9_pal_mode		( vdp_r9_pal_mode		),
		.reg_r9_interlace_mode	( reg_r9_interlace_mode	),
		.reg_r9_y_dots			( reg_r9_y_dots			),
		.reg_r18_adj			( reg_r18_adj			),
		.reg_r23_vstart_line	( reg_r23_vstart_line	),
		.reg_r25_msk			( reg_r25_msk			),
		.reg_r27_h_scroll		( reg_r27_h_scroll		),
		.reg_r25_yjk			( reg_r25_yjk			),
		.centeryjk_r25_n		( centeryjk_r25_n		)
	);

	// --------------------------------------------------------------------
	//	clock
	// --------------------------------------------------------------------
	always #(clk_base/2) begin
		clk <= ~clk;
	end

	// --------------------------------------------------------------------
	//	Test bench
	// --------------------------------------------------------------------
	initial begin
		reset					= 1;
		clk						= 0;
		enable					= 1;
		vdp_r9_pal_mode			= 0;
		reg_r9_interlace_mode	= 0;
		reg_r9_y_dots			= 0;
		reg_r18_adj				= 0;
		reg_r23_vstart_line		= 0;
		reg_r25_msk				= 0;
		reg_r27_h_scroll		= 0;
		reg_r25_yjk				= 0;
		centeryjk_r25_n			= 0;

		@( negedge clk );
		@( negedge clk );
		@( posedge clk );

		reset					= 0;
		@( posedge clk );

		for( i = 0; i < 10; i++ ) begin
			$display( "[%d]", i );
			repeat( 1368 * 1000 ) begin
				@( posedge clk );
			end
		end

		$finish;
	end
endmodule
