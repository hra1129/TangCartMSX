// --------------------------------------------------------------------
//	SCREEN0(W40) Sprite mode1 and left mask test
// ====================================================================
//	Programmed by t.hara
// --------------------------------------------------------------------

#include <stdio.h>
#include <stdlib.h>
#include "v9968.h"

#define DIX		4
#define DIY		8

// --------------------------------------------------------------------
void v9968_hmmc( unsigned int dx, unsigned int dy, unsigned int nx, unsigned int ny, unsigned char arg ) {

	v9968_write_vdp( 46, 0xA0 );
	v9968_write_vdp( 46, 0x00 );

	v9968_write_vdp( 36, dx & 255 );
	v9968_write_vdp( 37, dx >> 8 );
	v9968_write_vdp( 38, dy & 255 );
	v9968_write_vdp( 39, dy >> 8 );
	v9968_write_vdp( 40, nx & 255 );
	v9968_write_vdp( 41, nx >> 8 );
	v9968_write_vdp( 42, ny & 255 );
	v9968_write_vdp( 43, ny >> 8 );
	v9968_write_vdp( 45, arg );
	v9968_write_vdp( 46, 0xF0 );
}

// --------------------------------------------------------------------
int main( int argc, char *argv[] ) {
	int i, j;
	unsigned char c;

	v9968_set_screen5();

	v9968_fill_vram( 0x0000, 0, 128 * 212 );

	for( i = 0; i < 16; i++ ) {
		v9968_hmmc( 0, 0, 16, 16, 0 );
		c = i | (i << 4);
		for( j = 0; j < 8 * 16; j++ ) {
			v9968_write_vdp( 44, c );
		}
		v9968_wait_key();
	}

	for( i = 0; i < 16; i++ ) {
		v9968_hmmc( 2, 20, 16, 16, 0 );
		c = i | (i << 4);
		for( j = 0; j < 8 * 16; j++ ) {
			v9968_write_vdp( 44, c );
		}
		v9968_wait_key();
	}

	for( i = 0; i < 16; i++ ) {
		v9968_hmmc( 4, 40, 15, 15, 0 );
		c = i | (i << 4);
		for( j = 0; j < 7 * 14; j++ ) {
			v9968_write_vdp( 44, c );
		}
		v9968_wait_key();
	}
	v9968_wait_key();
	v9968_exit();
	return 0;
}
