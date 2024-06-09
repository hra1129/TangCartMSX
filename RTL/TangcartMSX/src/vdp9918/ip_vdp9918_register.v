// -----------------------------------------------------------------------------
//	ip_vdp9918_register.v
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

module ip_vdp9918_register (
	input			n_reset,
	input			clk,
	input			cs,
	input			enable,			//	10.738635MHz
	input			bus_address,
	output			bus_read_ready,
	output	[7:0]	bus_read_data,
	input	[7:0]	bus_write_data,
	input			bus_read,
	input			bus_write,
	input			bus_io,
	//	VRAM I/F
	output			vram_read,
	output			vram_write,
	input			vram_busy,
	output	[7:0]	vram_write_data,
	input			vram_read_ready,
	input	[7:0]	vram_read_data,
	//	OUTPUT
	output			interrupt,
	output	[2:0]	mode,
	output			blank_en,
	output			sprite_size,
	output			sprite_mag,
	output	[3:0]	name_table,
	output	[7:0]	color_table,
	output	[2:0]	pattern_generator,
	output	[6:0]	sprite_attribute,
	output	[2:0]	sprite_pattern,
	output	[3:0]	text_color,
	output	[3:0]	backdrop_color,
	//	INPUT
	input			coinc,
	input			update_fifth_sprite,
	input	[4:0]	fifth_sptite_no,
	input			vsync
);
	reg		[7:0]	ff_data;		//	data
	reg		[13:0]	ff_address;		//	address
	reg				ff_vram_read;	//	VRAM read request
	reg				ff_vram_write;	//	VRAM write request
	reg		[7:0]	ff_vram_data;	//	VRAM write data
	reg				ff_state;		//	0: data, 1: reg#
	reg		[1:0]	ff_r0;			//	mode0 (NOT SUPPORT: External VDP)
	reg		[7:0]	ff_r1;			//	mode1 (NOT SUPPORT: 4/16K selection)
	reg		[3:0]	ff_r2;			//	name table base address
	reg		[7:0]	ff_r3;			//	color table base address
	reg		[2:0]	ff_r4;			//	pattern generator base address
	reg		[6:0]	ff_r5;			//	sprite attribute table base address
	reg		[2:0]	ff_r6;			//	sprite pattern generator base address
	reg		[7:0]	ff_r7;			//	text color/backdrop color
	reg				ff_coinc;
	reg				ff_fifth_s;
	reg		[4:0]	ff_fifth_s_num;
	reg				ff_interrupt;

	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_state <= 1'b0;
		end
		else if( cs && bus_io && bus_address && bus_write ) begin
			//	Write VDP PORT1
			if( ff_state == 1'b0 ) begin
				ff_state <= 1'b1;
				ff_data <= bus_write_data;
			end
			else if( bus_write_data[7:3] == 2'b1000_0 ) begin
				//	Write Register
				ff_state <= 1'b0;
				case( bus_write_data[2:0] )
				3'd0:		ff_r0 <= ff_data[1:0];
				3'd1:		ff_r1 <= ff_data;
				3'd2:		ff_r2 <= ff_data[3:0];
				3'd3:		ff_r3 <= ff_data;
				3'd4:		ff_r4 <= ff_data[2:0];
				3'd5:		ff_r5 <= ff_data[6:0];
				3'd6:		ff_r6 <= ff_data[2:0];
				3'd7:		ff_r7 <= ff_data;
				default:	ff_r0 <= ff_data[1:0];
				endcase
			end
			else if( bus_write_data[7] == 1'b0 ) begin
				//	VRAM Read/Write
				ff_state <= 1'b0;
				ff_address <= { bus_write_data[5:0], ff_data };
			end
			else begin
				//	case of bus_write_data[7:6] == 2'b11
				//	-- no operation
			end
		end
	end

	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_bus_read_ready <= 1'b0;
			ff_bus_read_data <= 8'd0;
		end
		else if( vram_read_ready ) begin
			ff_bus_read_ready <= 1'b1;
			ff_bus_read_data <= vram_read_data;
		end
		else if( cs && bus_io && bus_address && bus_read ) begin
			//	read status register
			ff_bus_read_ready <= 1'b1;
			ff_bus_read_data <= { ff_interrupt, ff_fifth_s, ff_coinc, ff_fifth_s_num };
		end
		else begin
			ff_bus_read_ready <= 1'b0;
			ff_bus_read_data <= 8'd0;
		end
	end

	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_vram_read <= 1'b0;
		end
		else if( cs && bus_io && !bus_address && bus_read ) begin
			//	read VRAM
			ff_vram_read <= 1'b1;
		end
		else if( !vram_busy ) begin
			ff_vram_read <= 1'b0;
		end
		else begin
			//	hold
		end
	end

	assign bus_read_ready		= ff_bus_read_ready;
	assign bus_read_data		= ff_bus_read_data;

	assign vram_read			= ff_vram_read;
	assign vram_write			= ff_vram_write;
	assign vram_write_data		= ff_vram_data;

	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_fifth_s <= 1'b0;
			ff_fifth_s_num <= 5'd0;
		end
		else if( cs && bus_io && bus_address && bus_read ) begin
			ff_fifth_s <= 1'b0;
			ff_fifth_s_num <= 5'd0;
		end
		else if( update_fifth_sprite ) begin
			ff_fifth_s <= 1'b1;
			ff_fifth_s_num <= fifth_sptite_no;
		end
		else begin
			//	hold
		end
	end

	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_coinc <= 1'b0;
		end
		else if( cs && bus_io && bus_address && bus_read ) begin
			ff_coinc <= 1'b0;
		end
		else if( coinc ) begin
			ff_coinc <= 1'b1;
		end
		else begin
			//	hold
		end
	end

	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_interrupt <= 1'b0;
		end
		else if( cs && bus_io && bus_address && bus_read ) begin
			ff_interrupt <= 1'b0;
		end
		else if( enable && vsync ) begin
			ff_interrupt <= 1'b1;
		end
		else begin
			//	hold
		end
	end

	assign mode					= { ff_r1[3], ff_r1[4], ff_r0[1] };
	assign blank_en				= ff_r1[6];
	assign sprite_size			= ff_r1[1];
	assign sprite_mag			= ff_r1[0];
	assign name_table			= ff_r2;
	assign color_table			= ff_r3;
	assign pattern_generator	= ff_r4;
	assign sprite_attribute		= ff_r5;
	assign sprite_pattern		= ff_r6;
	assign text_color			= ff_r7[7:4];
	assign backdrop_color		= ff_r7[3:0];
	assign interrupt			= ff_r1[5] & ff_interrupt;
endmodule
