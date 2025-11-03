// --------------------------------------------------------------------
//	SCREEN7 Sprite mode2
// ====================================================================
//	Programmed by t.hara
// --------------------------------------------------------------------

#include <stdio.h>
#include <stdlib.h>
#include "v9968.h"
#include "v9968_font.h"

// --------------------------------------------------------------------
void put_sprite( unsigned char plane, unsigned char x, unsigned char y, unsigned char pattern ) {

	v9968_set_write_vram_address( 0xFA00 + (plane << 2), 0 );
	v9968_write_vram( y );
	v9968_write_vram( x );
	v9968_write_vram( pattern );
}

// --------------------------------------------------------------------
int main( int argc, char *argv[] ) {
	int i, j;

	v9968_set_screen7();
	v9968_write_vdp( 7, 0x00 );
	v9968_set_font( 0xF000 );
	v9968_fill_vram( 0x0000, 0x44, 256 * 212 );
	v9968_fill_vram( 0xF800, 0x0F, 16 * 32 );
	v9968_fill_vram( 0xFA00, 216, 4 * 32 );
	v9968_write_vdp( 1, 0x43 );						//	Display ON, Sprite 16x16 magnify
	for( i = 0; i < 4; i++ ) {
		for( j = 0; j < 8; j++ ) {
			put_sprite( j + (i << 3), j * 32, i * 32, (j + (i << 3)) << 2 );
		}
	}
	v9968_wait_key();
	v9968_exit();
	return 0;
}
