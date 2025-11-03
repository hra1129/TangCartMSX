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
	v9968_write_vdp( 0, 0 );						//	Mode
	v9968_write_vdp( 1, 0x50 );						//	Mode
	v9968_write_vdp( 2, 0 );						//	Pattern Name Table = 0x00000
	v9968_write_vdp( 4, 0x01 );						//	Pattern Generator Table = 0x0800
	v9968_write_vdp( 7, 0xF4 );						//	Background Color = 0xF4
	v9968_write_vdp( 8, 0x08 );						//	Mode2
	v9968_write_vdp( 9, 0 );						//	Mode3
	v9968_write_vdp( 14, 0 );						//	VRAM Address
	v9968_write_vdp( 15, 0 );						//	Status Register Pointer
	v9968_write_vdp( 16, 0 );						//	Palette Pointer
	v9968_write_vdp( 17, 0 );						//	Control Register Pointer
	v9968_write_vdp( 18, 0 );						//	Screen Positon
	v9968_write_vdp( 19, 0 );						//	Interrupt Line
	v9968_write_vdp( 20, 0 );						//	Mode5
	v9968_write_vdp( 21, 0 );						//	Mode6
	v9968_write_vdp( 23, 0 );						//	Display Offset
	v9968_write_vdp( 25, 0 );						//	Mode4
	v9968_write_vdp( 26, 0 );						//	Horizontal Offset by character
	v9968_write_vdp( 27, 0 );						//	Horizontal Offset by dot
	v9968_nested_ei();

	v9968_fill_vram( 0x0000, 0, 40 * 24 );
	v9968_set_font( 0x0800 );
}

// --------------------------------------------------------------------
//	v9968_set_screen0_w80()
//	input
//		none
// --------------------------------------------------------------------
void v9968_set_screen0_w80( void ) {

	v9968_nested_di();
	v9968_write_vdp( 0, 0x04 );						//	Mode
	v9968_write_vdp( 1, 0x50 );						//	Mode
	v9968_write_vdp( 2, 0x03 );						//	Pattern Name Table = 0x00000
	v9968_write_vdp( 3, 0x27 );						//	Color Table (L) = 0x00800
	v9968_write_vdp( 4, 0x02 );						//	Pattern Generator Table = 0x1000
	v9968_write_vdp( 7, 0xF4 );						//	Background Color = 0xF4
	v9968_write_vdp( 8, 0x08 );						//	Mode2
	v9968_write_vdp( 9, 0 );						//	Mode3
	v9968_write_vdp( 10, 0 );						//	Color Table (H) = 0x00800
	v9968_write_vdp( 14, 0 );						//	VRAM Address
	v9968_write_vdp( 15, 0 );						//	Status Register Pointer
	v9968_write_vdp( 16, 0 );						//	Palette Pointer
	v9968_write_vdp( 17, 0 );						//	Control Register Pointer
	v9968_write_vdp( 18, 0 );						//	Screen Positon
	v9968_write_vdp( 19, 0 );						//	Interrupt Line
	v9968_write_vdp( 20, 0 );						//	Mode5
	v9968_write_vdp( 21, 0 );						//	Mode6
	v9968_write_vdp( 23, 0 );						//	Display Offset
	v9968_write_vdp( 25, 0 );						//	Mode4
	v9968_write_vdp( 26, 0 );						//	Horizontal Offset by character
	v9968_write_vdp( 27, 0 );						//	Horizontal Offset by dot
	v9968_nested_ei();

	v9968_fill_vram( 0x0000, 0, 80 * 24 );
	v9968_fill_vram( 0x0800, 0, 10 * 24 );
	v9968_set_font( 0x1000 );
}

// --------------------------------------------------------------------
//	v9968_set_screen1()
//	input
//		none
// --------------------------------------------------------------------
void v9968_set_screen1( void ) {

	v9968_nested_di();
	v9968_write_vdp( 0, 0 );						//	Mode0
	v9968_write_vdp( 1, 0x40 );						//	Mode1
	v9968_write_vdp( 2, 0x06 );						//	Pattern Name Table = 0x01800
	v9968_write_vdp( 3, 0x80 );						//	Color Table (L) = 0x02000
	v9968_write_vdp( 4, 0x00 );						//	Pattern Generator Table = 0x0000
	v9968_write_vdp( 5, 0x36 );						//	Sprite Attribute Table (L) = 0x1B00
	v9968_write_vdp( 6, 0x07 );						//	Sprite Pattern Generator Table = 0x3800
	v9968_write_vdp( 7, 0x07 );						//	Background Color = 0x07
	v9968_write_vdp( 8, 0x08 );						//	Mode2
	v9968_write_vdp( 9, 0 );						//	Mode3
	v9968_write_vdp( 10, 0 );						//	Color Table (H) = 0x02000
	v9968_write_vdp( 11, 0 );						//	Sprite Attribute Table (H) = 0x1B00
	v9968_write_vdp( 12, 0 );						//	Text Color/Back Color
	v9968_write_vdp( 13, 0 );						//	Blink Period
	v9968_write_vdp( 14, 0 );						//	VRAM Address
	v9968_write_vdp( 15, 0 );						//	Status Register Pointer
	v9968_write_vdp( 16, 0 );						//	Palette Pointer
	v9968_write_vdp( 17, 0 );						//	Control Register Pointer
	v9968_write_vdp( 18, 0 );						//	Screen Positon
	v9968_write_vdp( 19, 0 );						//	Interrupt Line
	v9968_write_vdp( 20, 0 );						//	Mode5
	v9968_write_vdp( 21, 0 );						//	Mode6
	v9968_write_vdp( 23, 0 );						//	Display Offset
	v9968_write_vdp( 25, 0 );						//	Mode4
	v9968_write_vdp( 26, 0 );						//	Horizontal Offset by character
	v9968_write_vdp( 27, 0 );						//	Horizontal Offset by dot
	v9968_nested_ei();

	v9968_fill_vram( 0x1800, 0, 32 * 24 );
	v9968_fill_vram( 0x1B00, 208, 4 * 32 );
	v9968_fill_vram( 0x2000, 0xF4, 256 >> 3 );
	v9968_fill_vram( 0x3800, 0xFF, 8 * 256 );
	v9968_set_font( 0x0000 );
}

// --------------------------------------------------------------------
//	v9968_set_screen2()
//	input
//		none
// --------------------------------------------------------------------
void v9968_set_screen2( void ) {

	v9968_nested_di();
	v9968_write_vdp( 0, 0x02 );						//	Mode0
	v9968_write_vdp( 1, 0x40 );						//	Mode1
	v9968_write_vdp( 2, 0x06 );						//	Pattern Name Table = 0x01800
	v9968_write_vdp( 3, 0xFF );						//	Color Table (L) = 0x02000
	v9968_write_vdp( 4, 0x03 );						//	Pattern Generator Table = 0x0000
	v9968_write_vdp( 5, 0x36 );						//	Sprite Attribute Table (L) = 0x1B00
	v9968_write_vdp( 6, 0x07 );						//	Sprite Pattern Generator Table = 0x3800
	v9968_write_vdp( 7, 0x07 );						//	Background Color = 0x07
	v9968_write_vdp( 8, 0x08 );						//	Mode2
	v9968_write_vdp( 9, 0 );						//	Mode3
	v9968_write_vdp( 10, 0 );						//	Color Table (H) = 0x02000
	v9968_write_vdp( 11, 0 );						//	Sprite Attribute Table (H) = 0x1B00
	v9968_write_vdp( 12, 0 );						//	Text Color/Back Color
	v9968_write_vdp( 13, 0 );						//	Blink Period
	v9968_write_vdp( 14, 0 );						//	VRAM Address
	v9968_write_vdp( 15, 0 );						//	Status Register Pointer
	v9968_write_vdp( 16, 0 );						//	Palette Pointer
	v9968_write_vdp( 17, 0 );						//	Control Register Pointer
	v9968_write_vdp( 18, 0 );						//	Screen Positon
	v9968_write_vdp( 19, 0 );						//	Interrupt Line
	v9968_write_vdp( 20, 0 );						//	Mode5
	v9968_write_vdp( 21, 0 );						//	Mode6
	v9968_write_vdp( 23, 0 );						//	Display Offset
	v9968_write_vdp( 25, 0 );						//	Mode4
	v9968_write_vdp( 26, 0 );						//	Horizontal Offset by character
	v9968_write_vdp( 27, 0 );						//	Horizontal Offset by dot
	v9968_nested_ei();

	v9968_fill_vram( 0x1800, 0, 32 * 24 );
	v9968_fill_vram( 0x1B00, 208, 4 * 32 );
	v9968_fill_vram( 0x2000, 0xF4, 8 * 256 );
	v9968_fill_vram( 0x3800, 0xFF, 8 * 256 );
	v9968_set_font( 0x0000 );
	v9968_set_font( 0x0800 );
	v9968_set_font( 0x1000 );
}

// --------------------------------------------------------------------
//	v9968_set_screen3()
//	input
//		none
// --------------------------------------------------------------------
void v9968_set_screen3( void ) {

	v9968_nested_di();
	v9968_write_vdp( 0, 0x00 );						//	Mode0
	v9968_write_vdp( 1, 0x48 );						//	Mode1
	v9968_write_vdp( 2, 0x02 );						//	Pattern Name Table = 0x00800
	v9968_write_vdp( 3, 0x80 );						//	Color Table (L) = 0x02000
	v9968_write_vdp( 4, 0x00 );						//	Pattern Generator Table = 0x0000
	v9968_write_vdp( 5, 0x36 );						//	Sprite Attribute Table (L) = 0x1B00
	v9968_write_vdp( 6, 0x07 );						//	Sprite Pattern Generator Table = 0x3800
	v9968_write_vdp( 7, 0x07 );						//	Background Color = 0x07
	v9968_write_vdp( 8, 0x08 );						//	Mode2
	v9968_write_vdp( 9, 0 );						//	Mode3
	v9968_write_vdp( 10, 0 );						//	Color Table (H) = 0x02000
	v9968_write_vdp( 11, 0 );						//	Sprite Attribute Table (H) = 0x1B00
	v9968_write_vdp( 12, 0 );						//	Text Color/Back Color
	v9968_write_vdp( 13, 0 );						//	Blink Period
	v9968_write_vdp( 14, 0 );						//	VRAM Address
	v9968_write_vdp( 15, 0 );						//	Status Register Pointer
	v9968_write_vdp( 16, 0 );						//	Palette Pointer
	v9968_write_vdp( 17, 0 );						//	Control Register Pointer
	v9968_write_vdp( 18, 0 );						//	Screen Positon
	v9968_write_vdp( 19, 0 );						//	Interrupt Line
	v9968_write_vdp( 20, 0 );						//	Mode5
	v9968_write_vdp( 21, 0 );						//	Mode6
	v9968_write_vdp( 23, 0 );						//	Display Offset
	v9968_write_vdp( 25, 0 );						//	Mode4
	v9968_write_vdp( 26, 0 );						//	Horizontal Offset by character
	v9968_write_vdp( 27, 0 );						//	Horizontal Offset by dot
	v9968_nested_ei();

	v9968_fill_vram( 0x0800, 0, 32 * 24 );
	v9968_fill_vram( 0x1B00, 208, 4 * 32 );
	v9968_fill_vram( 0x3800, 0xFF, 8 * 256 );
	v9968_set_font( 0x0000 );
}

// --------------------------------------------------------------------
//	v9968_set_screen4()
//	input
//		none
// --------------------------------------------------------------------
void v9968_set_screen4( void ) {

	v9968_nested_di();
	v9968_write_vdp( 0, 0x04 );						//	Mode0
	v9968_write_vdp( 1, 0x40 );						//	Mode1
	v9968_write_vdp( 2, 0x06 );						//	Pattern Name Table = 0x01800
	v9968_write_vdp( 3, 0xFF );						//	Color Table (L) = 0x02000
	v9968_write_vdp( 4, 0x03 );						//	Pattern Generator Table = 0x0000
	v9968_write_vdp( 5, 0x3F );						//	Sprite Attribute Table (L) = 0x1E00
	v9968_write_vdp( 6, 0x07 );						//	Sprite Pattern Generator Table = 0x3800
	v9968_write_vdp( 7, 0x07 );						//	Background Color = 0x07
	v9968_write_vdp( 8, 0x08 );						//	Mode2
	v9968_write_vdp( 9, 0 );						//	Mode3
	v9968_write_vdp( 10, 0 );						//	Color Table (H) = 0x02000
	v9968_write_vdp( 11, 0 );						//	Sprite Attribute Table (H) = 0x1B00
	v9968_write_vdp( 12, 0 );						//	Text Color/Back Color
	v9968_write_vdp( 13, 0 );						//	Blink Period
	v9968_write_vdp( 14, 0 );						//	VRAM Address
	v9968_write_vdp( 15, 0 );						//	Status Register Pointer
	v9968_write_vdp( 16, 0 );						//	Palette Pointer
	v9968_write_vdp( 17, 0 );						//	Control Register Pointer
	v9968_write_vdp( 18, 0 );						//	Screen Positon
	v9968_write_vdp( 19, 0 );						//	Interrupt Line
	v9968_write_vdp( 20, 0 );						//	Mode5
	v9968_write_vdp( 21, 0 );						//	Mode6
	v9968_write_vdp( 23, 0 );						//	Display Offset
	v9968_write_vdp( 25, 0 );						//	Mode4
	v9968_write_vdp( 26, 0 );						//	Horizontal Offset by character
	v9968_write_vdp( 27, 0 );						//	Horizontal Offset by dot
	v9968_nested_ei();

	v9968_fill_vram( 0x1800, 0, 32 * 24 );
	v9968_fill_vram( 0x1E00, 216, 4 * 32 );
	v9968_fill_vram( 0x2000, 0xF4, 8 * 256 );
	v9968_fill_vram( 0x3800, 0xFF, 8 * 256 );
	v9968_set_font( 0x0000 );
	v9968_set_font( 0x0800 );
	v9968_set_font( 0x1000 );
}

// --------------------------------------------------------------------
//	v9968_set_screen5()
//	input
//		none
// --------------------------------------------------------------------
void v9968_set_screen5( void ) {

	v9968_nested_di();
	v9968_write_vdp( 0, 0x06 );						//	Mode0
	v9968_write_vdp( 1, 0x40 );						//	Mode1
	v9968_write_vdp( 2, 0x1F );						//	Pattern Name Table = 0x00000
	v9968_write_vdp( 5, 0xEF );						//	Sprite Attribute Table (L) = 0x7600
	v9968_write_vdp( 6, 0x0F );						//	Sprite Pattern Generator Table = 0x7800
	v9968_write_vdp( 7, 0x07 );						//	Background Color = 0x07
	v9968_write_vdp( 8, 0x08 );						//	Mode2
	v9968_write_vdp( 9, 0x80 );						//	Mode3
	v9968_write_vdp( 10, 0 );						//	Color Table (H) = 0x02000
	v9968_write_vdp( 11, 0 );						//	Sprite Attribute Table (H) = 0x1B00
	v9968_write_vdp( 12, 0 );						//	Text Color/Back Color
	v9968_write_vdp( 13, 0 );						//	Blink Period
	v9968_write_vdp( 14, 0 );						//	VRAM Address
	v9968_write_vdp( 15, 0 );						//	Status Register Pointer
	v9968_write_vdp( 16, 0 );						//	Palette Pointer
	v9968_write_vdp( 17, 0 );						//	Control Register Pointer
	v9968_write_vdp( 18, 0 );						//	Screen Positon
	v9968_write_vdp( 19, 0 );						//	Interrupt Line
	v9968_write_vdp( 20, 0 );						//	Mode5
	v9968_write_vdp( 21, 0 );						//	Mode6
	v9968_write_vdp( 23, 0 );						//	Display Offset
	v9968_write_vdp( 25, 0 );						//	Mode4
	v9968_write_vdp( 26, 0 );						//	Horizontal Offset by character
	v9968_write_vdp( 27, 0 );						//	Horizontal Offset by dot
	v9968_nested_ei();

	v9968_fill_vram( 0x7600, 216, 4 * 32 );
}

// --------------------------------------------------------------------
//	v9968_set_screen6()
//	input
//		none
// --------------------------------------------------------------------
void v9968_set_screen6( void ) {

	v9968_nested_di();
	v9968_write_vdp( 0, 0x08 );						//	Mode0
	v9968_write_vdp( 1, 0x40 );						//	Mode1
	v9968_write_vdp( 2, 0x1F );						//	Pattern Name Table = 0x00000
	v9968_write_vdp( 3, 0x80 );						//	Color Table (L) = 0x02000
	v9968_write_vdp( 4, 0x00 );						//	Pattern Generator Table = 0x0000
	v9968_write_vdp( 5, 0xEF );						//	Sprite Attribute Table (L) = 0x7600
	v9968_write_vdp( 6, 0x0F );						//	Sprite Pattern Generator Table = 0x7800
	v9968_write_vdp( 7, 0x07 );						//	Background Color = 0x07
	v9968_write_vdp( 8, 0x08 );						//	Mode2
	v9968_write_vdp( 9, 0x80 );						//	Mode3
	v9968_write_vdp( 10, 0 );						//	Color Table (H) = 0x02000
	v9968_write_vdp( 11, 0 );						//	Sprite Attribute Table (H) = 0x1B00
	v9968_write_vdp( 12, 0 );						//	Text Color/Back Color
	v9968_write_vdp( 13, 0 );						//	Blink Period
	v9968_write_vdp( 14, 0 );						//	VRAM Address
	v9968_write_vdp( 15, 0 );						//	Status Register Pointer
	v9968_write_vdp( 16, 0 );						//	Palette Pointer
	v9968_write_vdp( 17, 0 );						//	Control Register Pointer
	v9968_write_vdp( 18, 0 );						//	Screen Positon
	v9968_write_vdp( 19, 0 );						//	Interrupt Line
	v9968_write_vdp( 20, 0 );						//	Mode5
	v9968_write_vdp( 21, 0 );						//	Mode6
	v9968_write_vdp( 23, 0 );						//	Display Offset
	v9968_write_vdp( 25, 0 );						//	Mode4
	v9968_write_vdp( 26, 0 );						//	Horizontal Offset by character
	v9968_write_vdp( 27, 0 );						//	Horizontal Offset by dot
	v9968_nested_ei();

	v9968_fill_vram( 0x7600, 216, 4 * 32 );
}

// --------------------------------------------------------------------
//	v9968_set_screen7()
//	input
//		none
// --------------------------------------------------------------------
void v9968_set_screen7( void ) {

	v9968_nested_di();
	v9968_write_vdp( 0, 0x0A );						//	Mode0
	v9968_write_vdp( 1, 0x40 );						//	Mode1
	v9968_write_vdp( 2, 0x1F );						//	Pattern Name Table = 0x00000
	v9968_write_vdp( 3, 0x80 );						//	Color Table (L) = 0x02000
	v9968_write_vdp( 4, 0x00 );						//	Pattern Generator Table = 0x0000
	v9968_write_vdp( 5, 0xF7 );						//	Sprite Attribute Table (L) = 0xFA00
	v9968_write_vdp( 6, 0x1E );						//	Sprite Pattern Generator Table = 0xF000
	v9968_write_vdp( 7, 0x07 );						//	Background Color = 0x07
	v9968_write_vdp( 8, 0x08 );						//	Mode2
	v9968_write_vdp( 9, 0x80 );						//	Mode3
	v9968_write_vdp( 10, 0 );						//	Color Table (H) = 0x02000
	v9968_write_vdp( 11, 0x01 );					//	Sprite Attribute Table (H) = 0xFA00
	v9968_write_vdp( 12, 0 );						//	Text Color/Back Color
	v9968_write_vdp( 13, 0 );						//	Blink Period
	v9968_write_vdp( 14, 0 );						//	VRAM Address
	v9968_write_vdp( 15, 0 );						//	Status Register Pointer
	v9968_write_vdp( 16, 0 );						//	Palette Pointer
	v9968_write_vdp( 17, 0 );						//	Control Register Pointer
	v9968_write_vdp( 18, 0 );						//	Screen Positon
	v9968_write_vdp( 19, 0 );						//	Interrupt Line
	v9968_write_vdp( 20, 0 );						//	Mode5
	v9968_write_vdp( 21, 0 );						//	Mode6
	v9968_write_vdp( 23, 0 );						//	Display Offset
	v9968_write_vdp( 25, 0 );						//	Mode4
	v9968_write_vdp( 26, 0 );						//	Horizontal Offset by character
	v9968_write_vdp( 27, 0 );						//	Horizontal Offset by dot
	v9968_nested_ei();

	v9968_fill_vram( 0xFA00, 216, 4 * 32 );
}

// --------------------------------------------------------------------
//	v9968_set_screen8()
//	input
//		none
// --------------------------------------------------------------------
void v9968_set_screen8( void ) {

	v9968_nested_di();
	v9968_write_vdp( 0, 0x0E );						//	Mode0
	v9968_write_vdp( 1, 0x40 );						//	Mode1
	v9968_write_vdp( 2, 0x1F );						//	Pattern Name Table = 0x00000
	v9968_write_vdp( 3, 0x80 );						//	Color Table (L) = 0x02000
	v9968_write_vdp( 4, 0x00 );						//	Pattern Generator Table = 0x0000
	v9968_write_vdp( 5, 0xF7 );						//	Sprite Attribute Table (L) = 0x1B00
	v9968_write_vdp( 6, 0x07 );						//	Sprite Pattern Generator Table = 0x3800
	v9968_write_vdp( 7, 0x07 );						//	Background Color = 0x07
	v9968_write_vdp( 8, 0x08 );						//	Mode2
	v9968_write_vdp( 9, 0x80 );						//	Mode3
	v9968_write_vdp( 10, 0x00 );					//	Color Table (H) = 0x02000
	v9968_write_vdp( 11, 0x01 );					//	Sprite Attribute Table (H) = 0x1B00
	v9968_write_vdp( 12, 0x00 );					//	Text Color/Back Color
	v9968_write_vdp( 13, 0 );						//	Blink Period
	v9968_write_vdp( 14, 0 );						//	VRAM Address
	v9968_write_vdp( 15, 0 );						//	Status Register Pointer
	v9968_write_vdp( 16, 0 );						//	Palette Pointer
	v9968_write_vdp( 17, 0 );						//	Control Register Pointer
	v9968_write_vdp( 18, 0 );						//	Screen Positon
	v9968_write_vdp( 19, 0 );						//	Interrupt Line
	v9968_write_vdp( 20, 0 );						//	Mode5
	v9968_write_vdp( 21, 0 );						//	Mode6
	v9968_write_vdp( 23, 0 );						//	Display Offset
	v9968_write_vdp( 25, 0 );						//	Mode4
	v9968_write_vdp( 26, 0 );						//	Horizontal Offset by character
	v9968_write_vdp( 27, 0 );						//	Horizontal Offset by dot
	v9968_nested_ei();

	v9968_fill_vram( 0xFA00, 216, 4 * 32 );
}

