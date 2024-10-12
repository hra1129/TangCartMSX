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
	localparam		c_st_palette		= 'd45;
	localparam		c_st_write			= 'd50;

	reg				ff_req;
	reg				ff_wr;
	reg		[1:0]	ff_address;
	reg		[7:0]	ff_wdata;
	reg		[5:0]	ff_state;
	reg		[5:0]	ff_vdp_reg;
	reg		[7:0]	ff_vdp_data;
	reg		[5:0]	ff_next_state;
	reg				ff_sdram_busy;

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
					//	R#0: SCREEN0 (40X24, TEXT Mode)
					ff_vdp_reg		<= 5'h00;
					ff_vdp_data		<= 8'h00;
					ff_next_state	<= ff_state + 'd1;
					ff_state		<= c_st_write;
				end
			'd2:
				begin
					//	R#1: SCREEN0 (40X24, TEXT Mode)
					ff_vdp_reg		<= 5'h01;
					ff_vdp_data		<= 8'h50;
					ff_next_state	<= ff_state + 'd1;
					ff_state		<= c_st_write;
				end
			'd3:
				begin
					//	R#2: Pattern Name Table is 0x0000
					ff_vdp_reg		<= 5'h02;
					ff_vdp_data		<= 8'h00;
					ff_next_state	<= ff_state + 'd1;
					ff_state		<= c_st_write;
				end
			'd4:
				begin
					//	R#4: Pattern Generator Table is 0x0800
					ff_vdp_reg		<= 5'h04;
					ff_vdp_data		<= 8'h01;
					ff_next_state	<= ff_state + 'd1;
					ff_state		<= c_st_write;
				end
			'd5:
				begin
					//	R#7: Set Color (White on Blue)
					ff_vdp_reg		<= 5'h07;
					ff_vdp_data		<= 8'hF4;
					ff_next_state	<= ff_state + 'd1;
					ff_state		<= c_st_write;
				end
			'd6:
				begin
					//	R#16: Palette selector #0
					ff_vdp_reg		<= 5'h10;
					ff_vdp_data		<= 8'h00;
					ff_next_state	<= ff_state + 'd1;
					ff_state		<= c_st_write;
				end
			'd7:
				begin
					//	Palette #0 LSB
					ff_vdp_data		<= 8'h00;
					ff_next_state	<= ff_state + 'd1;
					ff_state		<= c_st_palette;
				end
			'd8:
				begin
					//	Palette #0 MSB
					ff_vdp_data		<= 8'h00;
					ff_next_state	<= ff_state + 'd1;
					ff_state		<= c_st_palette;
				end
			'd9:
				begin
					//	Palette #1 LSB
					ff_vdp_data		<= 8'h00;
					ff_next_state	<= ff_state + 'd1;
					ff_state		<= c_st_palette;
				end
			'd10:
				begin
					//	Palette #1 MSB
					ff_vdp_data		<= 8'h00;
					ff_next_state	<= ff_state + 'd1;
					ff_state		<= c_st_palette;
				end
			'd11:
				begin
					//	Palette #2 LSB
					ff_vdp_data		<= 8'h33;
					ff_next_state	<= ff_state + 'd1;
					ff_state		<= c_st_palette;
				end
			'd12:
				begin
					//	Palette #2 MSB
					ff_vdp_data		<= 8'h05;
					ff_next_state	<= ff_state + 'd1;
					ff_state		<= c_st_palette;
				end
			'd13:
				begin
					//	Palette #3 LSB
					ff_vdp_data		<= 8'h44;
					ff_next_state	<= ff_state + 'd1;
					ff_state		<= c_st_palette;
				end
			'd14:
				begin
					//	Palette #3 MSB
					ff_vdp_data		<= 8'h06;
					ff_next_state	<= ff_state + 'd1;
					ff_state		<= c_st_palette;
				end
			'd15:
				begin
					//	Palette #4 LSB
					ff_vdp_data		<= 8'h37;
					ff_next_state	<= ff_state + 'd1;
					ff_state		<= c_st_palette;
				end
			'd16:
				begin
					//	Palette #4 MSB
					ff_vdp_data		<= 8'h02;
					ff_next_state	<= ff_state + 'd1;
					ff_state		<= c_st_palette;
				end
			'd17:
				begin
					//	Palette #5 LSB
					ff_vdp_data		<= 8'h47;
					ff_next_state	<= ff_state + 'd1;
					ff_state		<= c_st_palette;
				end
			'd18:
				begin
					//	Palette #5 MSB
					ff_vdp_data		<= 8'h03;
					ff_next_state	<= ff_state + 'd1;
					ff_state		<= c_st_palette;
				end
			'd19:
				begin
					//	Palette #6 LSB
					ff_vdp_data		<= 8'h52;
					ff_next_state	<= ff_state + 'd1;
					ff_state		<= c_st_palette;
				end
			'd20:
				begin
					//	Palette #6 MSB
					ff_vdp_data		<= 8'h03;
					ff_next_state	<= ff_state + 'd1;
					ff_state		<= c_st_palette;
				end
			'd21:
				begin
					//	Palette #7 LSB
					ff_vdp_data		<= 8'h36;
					ff_next_state	<= ff_state + 'd1;
					ff_state		<= c_st_palette;
				end
			'd22:
				begin
					//	Palette #7 MSB
					ff_vdp_data		<= 8'h05;
					ff_next_state	<= ff_state + 'd1;
					ff_state		<= c_st_palette;
				end
			'd23:
				begin
					//	Palette #8 LSB
					ff_vdp_data		<= 8'h62;
					ff_next_state	<= ff_state + 'd1;
					ff_state		<= c_st_palette;
				end
			'd24:
				begin
					//	Palette #8 MSB
					ff_vdp_data		<= 8'h03;
					ff_next_state	<= ff_state + 'd1;
					ff_state		<= c_st_palette;
				end
			'd25:
				begin
					//	Palette #9 LSB
					ff_vdp_data		<= 8'h63;
					ff_next_state	<= ff_state + 'd1;
					ff_state		<= c_st_palette;
				end
			'd26:
				begin
					//	Palette #9 MSB
					ff_vdp_data		<= 8'h04;
					ff_next_state	<= ff_state + 'd1;
					ff_state		<= c_st_palette;
				end
			'd27:
				begin
					//	Palette #10 LSB
					ff_vdp_data		<= 8'h53;
					ff_next_state	<= ff_state + 'd1;
					ff_state		<= c_st_palette;
				end
			'd28:
				begin
					//	Palette #10 MSB
					ff_vdp_data		<= 8'h06;
					ff_next_state	<= ff_state + 'd1;
					ff_state		<= c_st_palette;
				end
			'd29:
				begin
					//	Palette #11 LSB
					ff_vdp_data		<= 8'h64;
					ff_next_state	<= ff_state + 'd1;
					ff_state		<= c_st_palette;
				end
			'd30:
				begin
					//	Palette #11 MSB
					ff_vdp_data		<= 8'h06;
					ff_next_state	<= ff_state + 'd1;
					ff_state		<= c_st_palette;
				end
			'd31:
				begin
					//	Palette #12 LSB
					ff_vdp_data		<= 8'h21;
					ff_next_state	<= ff_state + 'd1;
					ff_state		<= c_st_palette;
				end
			'd32:
				begin
					//	Palette #12 MSB
					ff_vdp_data		<= 8'h04;
					ff_next_state	<= ff_state + 'd1;
					ff_state		<= c_st_palette;
				end
			'd33:
				begin
					//	Palette #13 LSB
					ff_vdp_data		<= 8'h55;
					ff_next_state	<= ff_state + 'd1;
					ff_state		<= c_st_palette;
				end
			'd34:
				begin
					//	Palette #13 MSB
					ff_vdp_data		<= 8'h03;
					ff_next_state	<= ff_state + 'd1;
					ff_state		<= c_st_palette;
				end
			'd35:
				begin
					//	Palette #14 LSB
					ff_vdp_data		<= 8'h55;
					ff_next_state	<= ff_state + 'd1;
					ff_state		<= c_st_palette;
				end
			'd36:
				begin
					//	Palette #14 MSB
					ff_vdp_data		<= 8'h05;
					ff_next_state	<= ff_state + 'd1;
					ff_state		<= c_st_palette;
				end
			'd37:
				begin
					//	Palette #15 LSB
					ff_vdp_data		<= 8'h77;
					ff_next_state	<= ff_state + 'd1;
					ff_state		<= c_st_palette;
				end
			'd38:
				begin
					//	Palette #15 MSB
					ff_vdp_data		<= 8'h07;
					ff_next_state	<= ff_state + 'd1;
					ff_state		<= c_st_palette;
				end
			'd39:
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
					end
					else begin
						//	hold
					end
				end
			(c_st_palette + 2):
				begin
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
					end
					else begin
						//	hold
					end
				end
			(c_st_write + 2):
				begin
					if( ack == 1'b0 ) begin
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
					end
					else begin
						//	hold
					end
				end
			(c_st_write + 5):
				begin
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
