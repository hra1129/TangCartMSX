// --------------------------------------------------------------------
//	V9968 mode
// ====================================================================
//	Copyright 2025 t.hara (HRA!)
// --------------------------------------------------------------------

#include "v9968_common.h"
#include "v9968_mode.h"
#include "v9968_font.h"

// --------------------------------------------------------------------
//	v9968_set_screen0_w40()
//	input
//		none
// --------------------------------------------------------------------
void v9968_set_screen0_w40( void ) {

	v9968_nested_di();
	v9968_write_vdp( 0, 0 );				//	Mode
	v9968_write_vdp( 1, 0x50 );				//	Mode
	v9968_write_vdp( 2, 0 );				//	Pattern Name Table = 0x00000
	v9968_write_vdp( 4, 0x800 >> 11 );		//	Pattern Generator Table = 0x0800
	v9968_write_vdp( 7, 0xF4 );				//	Background Color = 0xF4
	v9968_write_vdp( 8, 0x08 );				//	Mode2
	v9968_write_vdp( 9, 0 );				//	Mode3
	v9968_write_vdp( 14, 0 );				//	VRAM Address
	v9968_write_vdp( 15, 0 );				//	Status Register Pointer
	v9968_write_vdp( 16, 0 );				//	Palette Pointer
	v9968_write_vdp( 17, 0 );				//	Control Register Pointer
	v9968_write_vdp( 18, 0 );				//	Screen Positon
	v9968_write_vdp( 19, 0 );				//	Interrupt Line
	v9968_write_vdp( 20, 0 );				//	Mode5
	v9968_write_vdp( 21, 0 );				//	Mode6
	v9968_write_vdp( 23, 0 );				//	Vertical Scroll
	v9968_write_vdp( 25, 0 );				//	Mode4
	v9968_write_vdp( 26, 0 );				//	Horizontal Scroll
	v9968_write_vdp( 27, 0 );				//	Horizontal Scroll
	v9968_nested_ei();

	v9968_fill_vram( 0x0000, 0, 40 * 24 );
	v9968_set_font( 0x0800 );
}

// --------------------------------------------------------------------
//	v9968_set_screen1()
//	input
//		none
// --------------------------------------------------------------------
void v9968_set_screen1( void ) {

	v9968_nested_di();
	v9968_write_vdp( 0, 0 );				//	Mode
	v9968_write_vdp( 1, 0x40 );				//	Mode
	v9968_write_vdp( 2, 0x1800 >> 10 );		//	Pattern Name Table = 0x01800
	v9968_write_vdp( 3, 0x2000 >>  6 );		//	Color Table = 0x02000
	v9968_write_vdp( 4, 0x0000 >> 11 );		//	Pattern Generator Table = 0x0000
	v9968_write_vdp( 7, 0x07 );				//	Background Color = 0xF4
	v9968_write_vdp( 8, 0x08 );				//	Mode2
	v9968_write_vdp( 9, 0 );				//	Mode3
	v9968_write_vdp( 14, 0 );				//	VRAM Address
	v9968_write_vdp( 15, 0 );				//	Status Register Pointer
	v9968_write_vdp( 16, 0 );				//	Palette Pointer
	v9968_write_vdp( 17, 0 );				//	Control Register Pointer
	v9968_write_vdp( 18, 0 );				//	Screen Positon
	v9968_write_vdp( 19, 0 );				//	Interrupt Line
	v9968_write_vdp( 20, 0 );				//	Mode5
	v9968_write_vdp( 21, 0 );				//	Mode6
	v9968_write_vdp( 23, 0 );				//	Vertical Scroll
	v9968_write_vdp( 25, 0 );				//	Mode4
	v9968_write_vdp( 26, 0 );				//	Horizontal Scroll
	v9968_write_vdp( 27, 0 );				//	Horizontal Scroll
	v9968_nested_ei();

	v9968_fill_vram( 0x1800, 0, 32 * 24 );
	v9968_fill_vram( 0x2000, 0xF4, 256 >> 3 );
	v9968_set_font( 0x0000 );
}
