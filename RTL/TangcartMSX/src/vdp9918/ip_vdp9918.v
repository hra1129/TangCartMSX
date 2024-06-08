// -----------------------------------------------------------------------------
//	ip_vdp9918.v
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

module ip_vdp9918 #(
	parameter		io_address		= 8'h98,
 (
	input			n_reset,
	input			clk,
	input			enable,			//	10.738635MHz
	//	MSX-50BUS
	input	[15:0]	bus_address,
	output			bus_io_cs,
	output			bus_memory_cs,
	output			bus_read_ready,
	output	[7:0]	bus_read_data,
	input	[7:0]	bus_write_data,
	input			bus_read,
	input			bus_write,
	input			bus_io,
	input			bus_memory,
	//	OUTPUT
	inout			n_interrupt,
	output			hsync,
	output			vsync,
	output	[4:0]	r,
	output	[4:0]	g,
	output	[4:0]	b
);
	wire			w_cs;			//	chip select
	wire			w_interrupt;
	wire			w_vram_read;
	wire			w_vram_write;
	wire			w_vram_busy;
	wire	[7:0]	w_vram_write_data;
	wire			w_vram_read_ready;
	wire	[7:0]	w_vram_read_data;

	// --------------------------------------------------------------------
	//	Active bus select
	// --------------------------------------------------------------------
	assign bus_io_cs		= 1'b1;
	assign bus_memory_cs	= 1'b0;

	// --------------------------------------------------------------------
	//	Address decode
	// --------------------------------------------------------------------
	assign w_cs			= ( {bus_address[7:1] == io_address );

	// --------------------------------------------------------------------
	//	Interrupt signal
	// --------------------------------------------------------------------
	assign n_interrupt	= w_interrupt ? 1'b0 : 1'bZ;

	// --------------------------------------------------------------------
	//	Registers
	// --------------------------------------------------------------------
	ip_vdp9918_register vdp9918_register (
		.n_reset				( n_reset				),
		.clk					( clk					),
		.cs						( w_cs					),
		.enable					( enable				),
		.bus_address			( bus_address			),
		.bus_read_ready			( bus_read_ready		),
		.bus_read_data			( bus_read_data			),
		.bus_write_data			( bus_write_data		),
		.bus_read				( bus_read				),
		.bus_write				( bus_write				),
		.bus_io					( bus_io				),
		.vram_read				( w_vram_read			),
		.vram_write				( w_vram_write			),
		.vram_busy				( w_vram_busy			),
		.vram_write_data		( w_vram_write_data		),
		.vram_read_ready		( w_vram_read_ready		),
		.vram_read_data			( w_vram_read_data		),
		.interrupt				( w_interrupt			),
		.mode					( mode					),
		.blank_en				( blank_en				),
		.sprite_size			( sprite_size			),
		.sprite_mag				( sprite_mag			),
		.name_table				( name_table			),
		.color_table			( color_table			),
		.pattern_generator		( pattern_generator		),
		.sprite_attribute		( sprite_attribute		),
		.sprite_pattern			( sprite_pattern		),
		.text_color				( text_color			),
		.backdrop_color			( backdrop_color		),
		.coinc					( coinc					),
		.update_fifth_sprite	( update_fifth_sprite	),
		.fifth_sptite_no		( fifth_sptite_no		),
		.vsync					( vsync					)
	);
endmodule
