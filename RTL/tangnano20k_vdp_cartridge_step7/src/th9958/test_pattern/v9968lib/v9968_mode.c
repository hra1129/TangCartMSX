// --------------------------------------------------------------------
//	V9968 mode
// ====================================================================
//	Copyright 2025 t.hara (HRA!)
// --------------------------------------------------------------------

#include "v9968_common.h"

// --------------------------------------------------------------------
//	set_screen0_w40()
//	input
//		none
// --------------------------------------------------------------------
void set_screen0_w40( void ) {

	#asm
		di
	#endasm

	di_write_vdp( 0, 0 );				//	Mode
	di_write_vdp( 1, 0x50 );			//	Mode
	di_write_vdp( 2, 0 );				//	Pattern Name Table = 0x00000
	di_write_vdp( 4, 0x800 >> 11 );		//	Pattern Generator Table = 0x0800
	di_write_vdp( 7, 0 );				//	Background Color = 0xF4
	di_write_vdp( 8, 0 );				//	Mode2
	di_write_vdp( 9, 0 );				//	Mode3
	di_write_vdp( 14, 0 );				//	VRAM Address
	di_write_vdp( 15, 0 );				//	Status Register Pointer
	di_write_vdp( 16, 0 );				//	Palette Pointer
	di_write_vdp( 17, 0 );				//	Control Register Pointer
	di_write_vdp( 18, 0 );				//	Screen Positon
	di_write_vdp( 19, 0 );				//	Interrupt Line
	di_write_vdp( 20, 0 );				//	Mode5
	di_write_vdp( 21, 0 );				//	Mode6
	di_write_vdp( 23, 0 );				//	Vertical Scroll
	di_write_vdp( 25, 0 );				//	Mode4
	di_write_vdp( 26, 0 );				//	Horizontal Scroll
	di_write_vdp( 27, 0 );				//	Horizontal Scroll

	#asm
		ei
	#endasm
}
