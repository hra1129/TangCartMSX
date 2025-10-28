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
void v9968_hmmm( unsigned int sx, unsigned int sy, unsigned int dx, unsigned int dy, unsigned int nx, unsigned int ny, unsigned char arg ) {

	v9968_write_vdp( 32, sx & 255 );
	v9968_write_vdp( 33, sx >> 8 );
	v9968_write_vdp( 34, sy & 255 );
	v9968_write_vdp( 35, sy >> 8 );
	v9968_write_vdp( 36, dx & 255 );
	v9968_write_vdp( 37, dx >> 8 );
	v9968_write_vdp( 38, dy & 255 );
	v9968_write_vdp( 39, dy >> 8 );
	v9968_write_vdp( 40, nx & 255 );
	v9968_write_vdp( 41, nx >> 8 );
	v9968_write_vdp( 42, ny & 255 );
	v9968_write_vdp( 43, ny >> 8 );
	v9968_write_vdp( 45, arg );
	v9968_write_vdp( 46, 0xD0 );
}

// --------------------------------------------------------------------
int main( int argc, char *argv[] ) {
	int i, j;

	v9968_set_screen5();
	v9968_write_vdp( 7, 0x00 );
	v9968_bload( "F1_CAR2.SC5" );
	v9968_color_restore( 0x7680 );	//	read palette data on VRAM and set palette

	for( i = 0; i < 16; i++ ) {
		v9968_hmmm( 239, 0, 255, 0, 240, 212, DIX );
		v9968_wait_key();
	}
	v9968_wait_key();
	v9968_exit();
	return 0;
}
