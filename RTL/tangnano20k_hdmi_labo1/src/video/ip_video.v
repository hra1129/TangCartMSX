// -----------------------------------------------------------------------------
//	ip_video.v
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

module ip_video (
	input			reset_n,
	input			clk,
	//	CPU I/F
	input			iorq_n,
	input	[7:0]	address,
	input			wr_n,
	input	[7:0]	wdata,
	//	SDRAM I/F
	output			vram_mreq_n,
	output	[22:0]	vram_address,
	output			vram_wr_n,
	output			vram_rd_n,
	output			vram_rfsh_n,
	output	[ 7:0]	vram_wdata,
	input	[31:0]	vram_rdata,
	input			vram_rdata_en,
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

	reg				ff_iorq_n;
	reg				ff_wr_n;
//	reg				ff_rd_n;
	wire			w_wr;
//	wire			w_rd;
	reg		[7:0]	ff_wdata;
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
	reg		[22:0]	ff_vram_address;
	reg				ff_vram_wr_n;
	reg				ff_vram_rd_n;
	reg				ff_vram_rfsh_n;
	reg				ff_vram_rd;
	reg		[31:0]	ff_vram_rdata;
	reg				ff_vram_rdata_en;
	reg		[9:0]	ff_buffer_re_address;
	reg		[9:0]	ff_buffer_we_address;
	wire	[9:0]	w_buffer_even_address;
	wire			w_buffer_even_we;
	wire	[7:0]	w_buffer_even_rdata;
	wire	[9:0]	w_buffer_odd_address;
	wire			w_buffer_odd_we;
	wire	[7:0]	w_buffer_odd_rdata;
	wire	[7:0]	w_pixel_index;
	wire			w_palette_we;
	wire	[7:0]	w_palette_r;
	wire	[7:0]	w_palette_g;
	wire	[7:0]	w_palette_b;
	reg		[7:0]	ff_palette_index;
	reg		[1:0]	ff_palette_element;
	reg		[7:0]	ff_wr_palette_index;
	reg		[7:0]	ff_wr_palette_r;
	reg		[7:0]	ff_wr_palette_g;
	reg		[7:0]	ff_wr_palette_b;
	reg				ff_wr_palette;
	reg		[22:0]	ff_wr_vram_address;
	reg		[1:0]	ff_wr_vram_address_phase;
	reg				ff_wr_vram;
	reg		[7:0]	ff_wr_vram_wdata;
	wire	[22:0]	w_rd_vram_address;

	// --------------------------------------------------------------------
	//	CPU I/F
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_iorq_n	<= 1'b1;
			ff_wr_n		<= 1'b1;
//			ff_rd_n		<= 1'b1;
		end
		else begin
			ff_iorq_n	<= iorq_n;
			ff_wr_n		<= wr_n;
//			ff_rd_n		<= rd_n;
		end
	end

	always @( posedge clk ) begin
		if( !wr_n ) begin
			ff_wdata	<= wdata;
		end
	end

	assign w_wr		= !ff_iorq_n && !ff_wr_n &&  wr_n;
//	assign w_rd		= !iorq_n    &&  ff_rd_n && !rd_n;

	// --------------------------------------------------------------------
	//	Registers
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_palette_index	<= 8'd0;
			ff_palette_element	<= 2'd0;
		end
		else if( w_wr && address == 8'h20 ) begin
			//	set palette address
			ff_palette_index	<= wdata;
			ff_palette_element	<= 2'd0;
		end
		else if( w_wr && address == 8'h21 ) begin
			//	auto increment address
			if( ff_palette_element == 2'd2 ) begin
				//	next palette index
				ff_palette_index	<= ff_palette_index + 8'd1;
				ff_palette_element	<= 2'd0;
			end
			else begin
				//	next color element
				ff_palette_element	<= ff_palette_element + 2'd1;
			end
		end
		else begin
			//	hold
		end
	end

	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_wr_palette_r		<= 8'd0;
			ff_wr_palette_g		<= 8'd0;
			ff_wr_palette_b		<= 8'd0;
		end
		else if( w_wr && address == 8'h21 ) begin
			if(      ff_palette_element == 2'd0 ) begin
				ff_wr_palette_r		<= wdata;
			end
			else if( ff_palette_element == 2'd1 ) begin
				ff_wr_palette_g		<= wdata;
			end
			else begin
				ff_wr_palette_b		<= wdata;
			end
		end
	end

	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_wr_palette_index	<= 8'd0;
			ff_wr_palette		<= 1'b0;
		end
		else if( w_wr && address == 8'h21 ) begin
			if( ff_palette_element == 2'd2 ) begin
				//	write request
				ff_wr_palette_index	<= ff_palette_index;
				ff_wr_palette		<= 1'b1;
			end
		end
		else if( ff_h_counter[0] == 1'b1 ) begin
			//	consume request
			ff_wr_palette		<= 1'b0;
		end
	end

	assign w_palette_we = ff_wr_palette & ff_h_counter[0];

	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_wr_vram_address			<= 23'd0;
			ff_wr_vram_address_phase	<= 2'd0;
		end
		else if( ff_wr_vram && ff_h_counter[3:0] == 4'd8 ) begin
			ff_wr_vram_address			<= ff_wr_vram_address + 23'd1;
		end
		else if( w_wr && address == 8'h22 ) begin
			if(      ff_wr_vram_address_phase == 2'd0 ) begin
				ff_wr_vram_address_phase	<= 2'd1;
				ff_wr_vram_address[7:0]		<= wdata;
			end
			else if( ff_wr_vram_address_phase == 2'd1 ) begin
				ff_wr_vram_address_phase	<= 2'd2;
				ff_wr_vram_address[15:8]	<= wdata;
			end
			else if( ff_wr_vram_address_phase == 2'd2 ) begin
				ff_wr_vram_address_phase	<= 2'd0;
				ff_wr_vram_address[22:16]	<= wdata[6:0];
			end
		end
	end

	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_wr_vram			<= 1'b0;
			ff_wr_vram_wdata	<= 8'd0;
		end
		else if( ff_h_counter[3:0] == 4'd8 && ff_wr_vram ) begin
			ff_wr_vram			<= 1'b0;
		end
		else if( w_wr && address == 8'h23 ) begin
			ff_wr_vram			<= 1'b1;
			ff_wr_vram_wdata	<= ff_wdata;
		end
	end

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
	assign w_h_count_end = (ff_h_counter == (c_h_total - 12'd1));

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
	assign w_v_count_end = (ff_v_counter == (c_v_total - 12'd1));

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

	// ---------------------------------------------------------------------------------------------------------
	//	Pixel data
	// ---------------------------------------------------------------------------------------------------------
	//	[HORIZONTAL]
	//	ff_h_counter[3:0] >< 15>< 0 >< 1 >< 2 >< 3 >< 4 >< 5 >< 6 >< 7 >< 8 >< 9 >< 10>< 11>< 12>< 13>< 14>< 15><
	//	ff_vram_rd        ~~~~~~_____~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~_
	//	vram_rdata             ><                                 >< RD><                                      ><
	//	ff_buffer_re_address                                                   0    ><   1    ><   2    ><   3    ><
	//	ff_vram_rdata                                                  >< RD0    >< RD1    >< RD2    >< RD3    ><
	//	ff_vram_rdata_en  ______________________________________________~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~_
	//	w_buffer_we       ______________________________________________~~~~~_____~~~~~_____~~~~~_____~~~~~______
	//
	//	[VERTICAL]
	//	ff_v_counter[1:0] ><  0  ><  1  ><  2  ><  3  ><  0  ><  1  ><  2  ><  3  ><  0  ><  1  ><  2  ><  3  >
	//	w_buffer_even_we  _~~~~~~~~~~~~~~______________~~~~~~~~~~~~~~______________~~~~~~~~~~~~~~______________
	// ---------------------------------------------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_vram_rd <= 1'b1;
		end
		else if( ff_h_counter[2:0] == 3'd7 ) begin
			if( (ff_h_counter[3] == 1'b0) && (ff_v_counter[0] == 1'b0) ) begin
				//	read for display
				ff_vram_rd <= 1'b0;
			end
			else begin
				//	read for CPU
			end
		end
		else begin
			ff_vram_rd <= 1'b1;
		end
	end

	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_vram_rdata		<= 32'd0;
			ff_vram_rdata_en	<= 1'b0;
		end
		else if( ff_h_counter[3:0] == 4'd7 ) begin
			ff_vram_rdata		<= 32'h80808080;	//vram_rdata;
			ff_vram_rdata_en	<= 1'b1;
		end
		else if( ff_vram_rdata_en && ff_h_counter[0] == 1'b1 ) begin
			//	9, 11, 13, 15
			ff_vram_rdata		<= { 8'd0, ff_vram_rdata[31:8] };
			ff_vram_rdata_en	<= (ff_h_counter[3:1] != 3'b111);
		end
	end

	assign w_rd_vram_address	= { ff_v_counter[11:1], ff_h_counter[11:3] };

	assign vram_mreq_n			= 1'b0;
	assign vram_address			= ff_vram_address;
	assign vram_wr_n			= ff_vram_wr_n;
	assign vram_rd_n			= ff_vram_rd_n;
	assign vram_rfsh_n			= ff_vram_rfsh_n;
	assign vram_wdata			= ff_wr_vram_wdata;

	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_vram_address	<= 23'd0;
			ff_vram_wr_n	<= 1'b1;
			ff_vram_rd_n	<= 1'b1;
			ff_vram_rfsh_n	<= 1'b1;
		end
		else begin
			ff_vram_address	<= ff_wr_vram ? ff_wr_vram_address : w_rd_vram_address;
			ff_vram_wr_n	<= (ff_h_counter[3:0] == 4'd7)  ? ~ff_wr_vram : 1'b1;
			ff_vram_rd_n	<= (ff_h_counter[3:0] == 4'd15) ? ~ff_h_window: 1'b1;
			ff_vram_rfsh_n	<= (ff_h_counter[3:0] == 4'd7)  ?  ff_wr_vram : 1'b1;
		end
	end

	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_buffer_re_address <= 10'd0;
		end
		else if( w_h_count_end ) begin
			ff_buffer_re_address <= 10'd0;
		end
		else if( ff_h_window && ff_h_counter[0] ) begin
			ff_buffer_re_address <= ff_buffer_re_address + 10'd1;
		end
	end

	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_buffer_we_address <= 10'd0;
		end
		else if( w_h_count_end && ff_v_counter[0] == 1'b1 ) begin
			ff_buffer_we_address <= 10'd0;
		end
		else if( ~ff_h_counter[0] && ff_vram_rdata_en ) begin
			ff_buffer_we_address <= ff_buffer_we_address + 10'd1;
		end
	end

	assign w_h_position				= ff_h_counter - (c_h_sync + c_h_bporch);
	assign w_buffer_even_address	= ff_v_counter[1] ? ff_buffer_re_address: ff_buffer_we_address;
	assign w_buffer_odd_address		= ff_v_counter[1] ? ff_buffer_we_address: ff_buffer_re_address;
	assign w_buffer_even_we			= ~ff_h_counter[0] & ff_vram_rdata_en & ~ff_v_counter[1];
	assign w_buffer_odd_we			= ~ff_h_counter[0] & ff_vram_rdata_en &  ff_v_counter[1];

	ip_line_buffer u_line_buffer_even (
		.clk			( clk					),
		.address		( w_buffer_even_address	),
		.we				( w_buffer_even_we		),
		.wdata			( ff_vram_rdata[7:0]	),
		.rdata			( w_buffer_even_rdata	)
	);

	ip_line_buffer u_line_buffer_odd (
		.clk			( clk					),
		.address		( w_buffer_odd_address	),
		.we				( w_buffer_odd_we		),
		.wdata			( ff_vram_rdata[7:0]	),
		.rdata			( w_buffer_odd_rdata	)
	);

	assign w_pixel_index = ff_h_counter[0] ? ff_wr_palette_index :
	                       ff_v_counter[1] ? w_buffer_odd_rdata  : w_buffer_even_rdata;

	// ---------------------------------------------------------------------------------------------------------
	//	Pixel index --> palette color
	// ---------------------------------------------------------------------------------------------------------
	//	[HORIZONTAL]
	//	ff_h_counter[3:0] >< 15>< 0 >< 1 >< 2 >< 3 >< 4 >< 5 >< 6 >< 7 >< 8 >< 9 >< 10>< 11>< 12>< 13>< 14>< 15><
	//	w_h_position[10:1]      <   0    ><   1    ><   2    ><   3    ><   4    ><   5    ><   6    ><   7    >
	//	w_pixel_index                <PI0>< X ><PI1>< X ><PI2>< X ><PI3>< X ><PI4>< X ><PI5>< X ><PI6>< X ><PI7>< X >
	//	w_pallette_we                <CPU><   ><CPU><   ><CPU><   ><CPU><   ><CPU><   ><CPU><   ><CPU><   ><CPU><   >   <CPU>は CPUがパレット更新するときに 1 になる
	//	w_palette_r                            < R0>< X >< R1>< X >< R2>< X >< R3>< X >< R4>< X >< R5>< X >< R6>< X >
	//	w_palette_g                            < G0>< X >< G1>< X >< G2>< X >< G3>< X >< G4>< X >< G5>< X >< G6>< X >
	//	w_palette_b                            < B0>< X >< B1>< X >< B2>< X >< B3>< X >< B4>< X >< B5>< X >< B6>< X >
	//
	ip_palette u_palette_r (
		.clk			( clk					),
		.address		( w_pixel_index			),
		.we				( w_palette_we			),
		.wdata			( ff_wr_palette_r		),
		.rdata			( w_palette_r			)
	);

	ip_palette u_palette_g (
		.clk			( clk					),
		.address		( w_pixel_index			),
		.we				( w_palette_we			),
		.wdata			( ff_wr_palette_g		),
		.rdata			( w_palette_g			)
	);

	ip_palette u_palette_b (
		.clk			( clk					),
		.address		( w_pixel_index			),
		.we				( w_palette_we			),
		.wdata			( ff_wr_palette_b		),
		.rdata			( w_palette_b			)
	);

	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_r <= 8'd0;
			ff_g <= 8'd0;
			ff_b <= 8'd0;
		end
		else if( ff_h_counter[0] ) begin
			ff_r <= w_palette_r;
			ff_g <= w_palette_g;
			ff_b <= w_palette_b;
		end
		else begin
			//	hold
		end
	end

	assign video_de	= ff_h_window & ff_v_window;
	assign video_hs	= ff_h_sync;
	assign video_vs	= ff_v_sync;
	assign video_r	= ff_r;
	assign video_g	= ff_g;
	assign video_b	= ff_b;
endmodule
