// -----------------------------------------------------------------------------
//	ip_debugger.v
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
//		Debugger
// -----------------------------------------------------------------------------

module ip_debugger (
	//	Internal I/F
	input			n_reset,
	input			clk,
	//	Key input
	input	[1:0]	keys,
	input	[1:0]	enable_state,
	input			dh_clk,
	input			dl_clk,
	//	Target signal for observation
	output			req,
	input			ack,
	output			wr,				//	0: read, 1: write
	output	[1:0]	address,
	output	[7:0]	wdata,
	input	[7:0]	rdata,
	input			sdram_busy
);
	localparam		c_vdp_port0			= 2'd0;
	localparam		c_vdp_port1			= 2'd1;
	localparam		c_vdp_port2			= 2'd2;
	localparam		c_vdp_port3			= 2'd3;
	localparam		c_st_palette		= 'd105;
	localparam		c_st_write			= 'd110;

	reg				ff_req;
	reg				ff_wr;
	reg		[1:0]	ff_address;
	reg		[7:0]	ff_wdata;
	reg		[6:0]	ff_state;
	reg		[5:0]	ff_vdp_reg;
	reg		[7:0]	ff_vdp_data;
	reg		[6:0]	ff_next_state;
	reg				ff_sdram_busy;
	reg		[13:0]	ff_rom_address;
	wire	[7:0]	w_rom_data;
	reg		[9:0]	ff_wait_count;

	// --------------------------------------------------------------------
	//	VRAM Image ROM
	// --------------------------------------------------------------------
	vram_image_rom u_rom (
		.clk		( clk				),
		.adr		( ff_rom_address	),
		.dbi		( w_rom_data		)
	);

	// --------------------------------------------------------------------
	//	main thread
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_state		<= 'd0;
			ff_req			<= 1'b0;
			ff_wr			<= 1'b0;
			ff_sdram_busy	<= 1'b1;
		end
		else if( ff_sdram_busy ) begin
			if( !sdram_busy ) begin
				ff_sdram_busy	<= 1'b0;
			end
			else begin
				//	hold
			end
		end
		else if( enable_state != 2'b01 ) begin
			//	hold
		end
		else begin
			case( ff_state )
			'd0:
				begin
					//	wait press the key[0].
					if( keys[0] == 1'b1 ) begin
						ff_state <= ff_state + 'd1;
					end
				end
			'd1:
				begin
					//	R#0: Mode register 0: SCREEN1 (32X24, GRAPHIC1 Mode)
					ff_vdp_reg		<= 5'h00;
					ff_vdp_data		<= 8'b0_0_0_0_000_0;		// [0][DG][IE2][IE1][M5][M4][M3][0]
					ff_next_state	<= ff_state + 'd1;
					ff_state		<= c_st_write;
				end
			'd2:
				begin
					//	R#1: Mode register 1: SCREEN1 (32X24, GRAPHIC1 Mode)
					ff_vdp_reg		<= 5'h01;
					ff_vdp_data		<= 8'b0_1_1_00_0_1_1;		// [0][BL][IE0][M1][M2][0][SI][MAG]
					ff_next_state	<= ff_state + 'd1;
					ff_state		<= c_st_write;
				end
			'd3:
				begin
					//	R#2: Pattern Name Table is 0x1800 = 17'b0_0001_1000_0000_0000
					ff_vdp_reg		<= 5'h02;
					ff_vdp_data		<= 8'b0_0_0001_10;		// [0][A16][A15][A14][A13][A12][A11][A10]
					ff_next_state	<= ff_state + 'd1;
					ff_state		<= c_st_write;
				end
			'd4:
				begin
					//	R#3: Color Table is 0x2000 = 17'b0_0010_0000_0000_0000
					ff_vdp_reg		<= 5'h03;
					ff_vdp_data		<= 8'b10_0000_00;		//	[A13][A12][A11][A10][A9][A8][A7][A6]
					ff_next_state	<= ff_state + 'd1;
					ff_state		<= c_st_write;
				end
			'd5:
				begin
					//	R#4: Pattern Generator Table is 0x0000 = 17'b0_0000_0000_0000_0000
					ff_vdp_reg		<= 5'h04;
					ff_vdp_data		<= 8'b00_0_0000_0;		//	[0][0][A16][A15][A14][A13][A12][A11]
					ff_next_state	<= ff_state + 'd1;
					ff_state		<= c_st_write;
				end
			'd6:
				begin
					//	R#5: Sprite Attribute Table is 0x1B00 = 17'b0_0001_1011_0000_0000
					ff_vdp_reg		<= 5'h05;
					ff_vdp_data		<= 8'b001_101_11;		//	[A14][A13][A12][A11][A10][A9][1][1]
					ff_next_state	<= ff_state + 'd1;
					ff_state		<= c_st_write;
				end
			'd7:
				begin
					//	R#6: Sprite Generator Table is 0x3800 = 17'b0_0011_1000_0000_0000
					ff_vdp_reg		<= 5'h06;
					ff_vdp_data		<= 8'b000_0011_1;		//	[0][0][A16][A15][A14][A13][A12][A11]
					ff_next_state	<= ff_state + 'd1;
					ff_state		<= c_st_write;
				end
			'd8:
				begin
					//	R#7: Set Color (White on Blue)
					ff_vdp_reg		<= 5'h07;
					ff_vdp_data		<= 8'hF7;				//	[TC3][TC2][TC1][TC0][BD3][BD2][BD1][BD0]
					ff_next_state	<= ff_state + 'd1;
					ff_state		<= c_st_write;
				end
			'd9:
				begin
					//	R#8: Mode register 2: Sprite on
					ff_vdp_reg		<= 5'h08;
					ff_vdp_data		<= 8'b0_0_0_0_1_0_0_0;	//	[0][0][TP][CB][1][0][SPD][0]
					ff_next_state	<= ff_state + 'd1;
					ff_state		<= c_st_write;
				end
			'd10:
				begin
					//	R#9: Mode register 3: NTSC
					ff_vdp_reg		<= 5'h09;
					ff_vdp_data		<= 8'b0_00_0_0_0_0;		//	[LN][0][S1][S0][IL][EO][NT][DC]
					ff_next_state	<= ff_state + 'd1;
					ff_state		<= c_st_write;
				end
			'd11:
				begin
					//	R#16: Palette selector #0
					ff_vdp_reg		<= 5'h10;
					ff_vdp_data		<= 8'h00;
					ff_next_state	<= ff_state + 'd1;
					ff_state		<= c_st_write;
				end
			'd12:
				begin
					//	Palette #0 LSB
					ff_vdp_data		<= 8'h00;
					ff_next_state	<= ff_state + 'd1;
					ff_state		<= c_st_palette;
				end
			'd13:
				begin
					//	Palette #0 MSB
					ff_vdp_data		<= 8'h00;
					ff_next_state	<= ff_state + 'd1;
					ff_state		<= c_st_palette;
				end
			'd14:
				begin
					//	Palette #1 LSB
					ff_vdp_data		<= 8'h00;
					ff_next_state	<= ff_state + 'd1;
					ff_state		<= c_st_palette;
				end
			'd15:
				begin
					//	Palette #1 MSB
					ff_vdp_data		<= 8'h00;
					ff_next_state	<= ff_state + 'd1;
					ff_state		<= c_st_palette;
				end
			'd16:
				begin
					//	Palette #2 LSB
//					ff_vdp_data		<= 8'h33;
					ff_vdp_data		<= 8'h11;
					ff_next_state	<= ff_state + 'd1;
					ff_state		<= c_st_palette;
				end
			'd17:
				begin
					//	Palette #2 MSB
//					ff_vdp_data		<= 8'h05;
					ff_vdp_data		<= 8'h06;
					ff_next_state	<= ff_state + 'd1;
					ff_state		<= c_st_palette;
				end
			'd18:
				begin
					//	Palette #3 LSB
//					ff_vdp_data		<= 8'h44;
					ff_vdp_data		<= 8'h33;
					ff_next_state	<= ff_state + 'd1;
					ff_state		<= c_st_palette;
				end
			'd19:
				begin
					//	Palette #3 MSB
//					ff_vdp_data		<= 8'h06;
					ff_vdp_data		<= 8'h07;
					ff_next_state	<= ff_state + 'd1;
					ff_state		<= c_st_palette;
				end
			'd20:
				begin
					//	Palette #4 LSB
//					ff_vdp_data		<= 8'h37;
					ff_vdp_data		<= 8'h17;
					ff_next_state	<= ff_state + 'd1;
					ff_state		<= c_st_palette;
				end
			'd21:
				begin
					//	Palette #4 MSB
//					ff_vdp_data		<= 8'h02;
					ff_vdp_data		<= 8'h01;
					ff_next_state	<= ff_state + 'd1;
					ff_state		<= c_st_palette;
				end
			'd22:
				begin
					//	Palette #5 LSB
//					ff_vdp_data		<= 8'h47;
					ff_vdp_data		<= 8'h27;
					ff_next_state	<= ff_state + 'd1;
					ff_state		<= c_st_palette;
				end
			'd23:
				begin
					//	Palette #5 MSB
//					ff_vdp_data		<= 8'h03;
					ff_vdp_data		<= 8'h03;
					ff_next_state	<= ff_state + 'd1;
					ff_state		<= c_st_palette;
				end
			'd24:
				begin
					//	Palette #6 LSB
//					ff_vdp_data		<= 8'h52;
					ff_vdp_data		<= 8'h51;
					ff_next_state	<= ff_state + 'd1;
					ff_state		<= c_st_palette;
				end
			'd25:
				begin
					//	Palette #6 MSB
//					ff_vdp_data		<= 8'h03;
					ff_vdp_data		<= 8'h01;
					ff_next_state	<= ff_state + 'd1;
					ff_state		<= c_st_palette;
				end
			'd26:
				begin
					//	Palette #7 LSB
//					ff_vdp_data		<= 8'h36;
					ff_vdp_data		<= 8'h27;
					ff_next_state	<= ff_state + 'd1;
					ff_state		<= c_st_palette;
				end
			'd27:
				begin
					//	Palette #7 MSB
//					ff_vdp_data		<= 8'h05;
					ff_vdp_data		<= 8'h06;
					ff_next_state	<= ff_state + 'd1;
					ff_state		<= c_st_palette;
				end
			'd28:
				begin
					//	Palette #8 LSB
//					ff_vdp_data		<= 8'h62;
					ff_vdp_data		<= 8'h71;
					ff_next_state	<= ff_state + 'd1;
					ff_state		<= c_st_palette;
				end
			'd29:
				begin
					//	Palette #8 MSB
//					ff_vdp_data		<= 8'h03;
					ff_vdp_data		<= 8'h01;
					ff_next_state	<= ff_state + 'd1;
					ff_state		<= c_st_palette;
				end
			'd30:
				begin
					//	Palette #9 LSB
//					ff_vdp_data		<= 8'h63;
					ff_vdp_data		<= 8'h73;
					ff_next_state	<= ff_state + 'd1;
					ff_state		<= c_st_palette;
				end
			'd31:
				begin
					//	Palette #9 MSB
//					ff_vdp_data		<= 8'h04;
					ff_vdp_data		<= 8'h03;
					ff_next_state	<= ff_state + 'd1;
					ff_state		<= c_st_palette;
				end
			'd32:
				begin
					//	Palette #10 LSB
//					ff_vdp_data		<= 8'h53;
					ff_vdp_data		<= 8'h61;
					ff_next_state	<= ff_state + 'd1;
					ff_state		<= c_st_palette;
				end
			'd33:
				begin
					//	Palette #10 MSB
//					ff_vdp_data		<= 8'h06;
					ff_vdp_data		<= 8'h06;
					ff_next_state	<= ff_state + 'd1;
					ff_state		<= c_st_palette;
				end
			'd34:
				begin
					//	Palette #11 LSB
//					ff_vdp_data		<= 8'h64;
					ff_vdp_data		<= 8'h64;
					ff_next_state	<= ff_state + 'd1;
					ff_state		<= c_st_palette;
				end
			'd35:
				begin
					//	Palette #11 MSB
//					ff_vdp_data		<= 8'h06;
					ff_vdp_data		<= 8'h06;
					ff_next_state	<= ff_state + 'd1;
					ff_state		<= c_st_palette;
				end
			'd36:
				begin
					//	Palette #12 LSB
//					ff_vdp_data		<= 8'h21;
					ff_vdp_data		<= 8'h11;
					ff_next_state	<= ff_state + 'd1;
					ff_state		<= c_st_palette;
				end
			'd37:
				begin
					//	Palette #12 MSB
//					ff_vdp_data		<= 8'h04;
					ff_vdp_data		<= 8'h04;
					ff_next_state	<= ff_state + 'd1;
					ff_state		<= c_st_palette;
				end
			'd38:
				begin
					//	Palette #13 LSB
//					ff_vdp_data		<= 8'h55;
					ff_vdp_data		<= 8'h65;
					ff_next_state	<= ff_state + 'd1;
					ff_state		<= c_st_palette;
				end
			'd39:
				begin
					//	Palette #13 MSB
//					ff_vdp_data		<= 8'h03;
					ff_vdp_data		<= 8'h02;
					ff_next_state	<= ff_state + 'd1;
					ff_state		<= c_st_palette;
				end
			'd40:
				begin
					//	Palette #14 LSB
					ff_vdp_data		<= 8'h55;
					ff_next_state	<= ff_state + 'd1;
					ff_state		<= c_st_palette;
				end
			'd41:
				begin
					//	Palette #14 MSB
					ff_vdp_data		<= 8'h05;
					ff_next_state	<= ff_state + 'd1;
					ff_state		<= c_st_palette;
				end
			'd42:
				begin
					//	Palette #15 LSB
					ff_vdp_data		<= 8'h77;
					ff_next_state	<= ff_state + 'd1;
					ff_state		<= c_st_palette;
				end
			'd43:
				begin
					//	Palette #15 MSB
					ff_vdp_data		<= 8'h07;
					ff_next_state	<= ff_state + 'd1;
					ff_state		<= c_st_palette;
				end
			'd44:
				begin
					//	set VRAM address
					ff_rom_address	<= 14'd0;
					ff_wr			<= 1'b1;
					ff_address		<= c_vdp_port1;
					ff_req			<= 1'b1;
					ff_state		<= ff_state + 'd1;
					ff_wdata		<= 8'h00;					//	VRAM address[7:0]
				end
			'd45:
				begin
					if( ack == 1'b1 ) begin
						ff_req			<= 1'b0;
						ff_state		<= ff_state + 'd1;
					end
					else begin
						//	hold
					end
				end
			'd46:
				begin
					//	set VRAM address
					ff_wr			<= 1'b1;
					ff_address		<= c_vdp_port1;
					ff_req			<= 1'b1;
					ff_state		<= ff_state + 'd1;
					ff_wdata		<= 8'h40;					//	VRAM address[13:8]
				end
			'd47:
				begin
					if( ack == 1'b1 ) begin
						ff_req			<= 1'b0;
						ff_state		<= ff_state + 'd1;
					end
					else begin
						//	hold
					end
				end
			'd48:
				begin
					//	write VRAM
					ff_wr			<= 1'b1;
					ff_address		<= c_vdp_port0;
					ff_req			<= 1'b1;
					ff_state		<= ff_state + 'd1;
					ff_wdata		<= w_rom_data;				//	write ROM data
				end
			'd49:
				begin
					if( ack == 1'b1 ) begin
						ff_req			<= 1'b0;
						ff_state		<= ff_state + 'd1;
						ff_wait_count	<= 10'd1023;
						ff_rom_address	<= ff_rom_address + 14'd1;
					end
					else begin
						//	hold
					end
				end
			'd50:
				begin
					if( ff_wait_count != 10'd0 ) begin
						ff_wait_count	<= ff_wait_count - 'd1;
					end
					else if( ff_rom_address == 14'h0000 ) begin
						ff_state		<= ff_state + 'd1;
					end
					else begin
						ff_state		<= 'd48;
					end
				end
			'd51:
				begin
					//	hold
				end
				// palette write access
			c_st_palette:
				begin
					ff_wr			<= 1'b1;
					ff_address		<= c_vdp_port2;
					ff_req			<= 1'b1;
					ff_state		<= ff_state + 'd1;
					ff_wdata		<= ff_vdp_data;
				end
			(c_st_palette + 1):
				begin
					if( ack == 1'b1 ) begin
						ff_req			<= 1'b0;
						ff_state		<= ff_state + 'd1;
						ff_wait_count	<= 10'd24;
					end
					else begin
						//	hold
					end
				end
			(c_st_palette + 2):
				begin
					if( ff_wait_count != 10'd0 ) begin
						ff_wait_count	<= ff_wait_count - 10'd1;
					end
					if( ack == 1'b0 ) begin
						ff_state		<= ff_next_state;
					end
					else begin
						//	hold
					end
				end
				// write access
			c_st_write:
				begin
					ff_wr			<= 1'b1;
					ff_address		<= c_vdp_port1;
					ff_req			<= 1'b1;
					ff_state		<= ff_state + 'd1;
					ff_wdata		<= ff_vdp_data;
				end
			(c_st_write + 1):
				begin
					if( ack == 1'b1 ) begin
						ff_req			<= 1'b0;
						ff_state		<= ff_state + 'd1;
						ff_wait_count	<= 10'd24;
					end
					else begin
						//	hold
					end
				end
			(c_st_write + 2):
				begin
					if( ff_wait_count != 10'd0 ) begin
						ff_wait_count	<= ff_wait_count - 10'd1;
					end
					else if( ack == 1'b0 ) begin
						ff_state		<= ff_state + 'd1;
					end
					else begin
						//	hold
					end
				end
			(c_st_write + 3):
				begin
					ff_wr			<= 1'b1;
					ff_address		<= c_vdp_port1;
					ff_req			<= 1'b1;
					ff_state		<= ff_state + 'd1;
					ff_wdata		<= { 2'b10, ff_vdp_reg };
				end
			(c_st_write + 4):
				begin
					if( ack == 1'b1 ) begin
						ff_req			<= 1'b0;
						ff_state		<= ff_state + 'd1;
						ff_wait_count	<= 10'd24;
					end
					else begin
						//	hold
					end
				end
			(c_st_write + 5):
				begin
					if( ff_wait_count != 10'd0 ) begin
						ff_wait_count	<= ff_wait_count - 10'd1;
					end
					if( ack == 1'b0 ) begin
						ff_state		<= ff_next_state;
					end
					else begin
						//	hold
					end
				end
			endcase
		end
	end

	assign req			= ff_req;
	assign wr			= ff_wr;
	assign address		= ff_address;
	assign wdata		= ff_wdata;
endmodule
