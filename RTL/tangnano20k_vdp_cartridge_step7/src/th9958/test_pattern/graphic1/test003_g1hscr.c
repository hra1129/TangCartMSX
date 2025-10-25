// --------------------------------------------------------------------
//	SCREEN0(W40) Horizontal Scroll Test
// ====================================================================
//	Programmed by t.hara
// --------------------------------------------------------------------

#include <stdio.h>
#include <stdlib.h>
#include "v9968.h"

// --------------------------------------------------------------------
int main( int argc, char *argv[] ) {
	int i, h26, h27;

	v9968_set_screen1();

	v9968_set_write_vram_address( 0x1800, 0 );
	for( i = 0; i < 32 * 24; i++ ) {
		v9968_write_vram( i );
	}

	v9968_set_write_vram_address( 0x1800, 0 );
	v9968_puts( "[R#26,R#27]" );
	for( i = 0; i < 256; i++ ) {
		h26 = i >> 3;
		h27 = (i & 7) ^ 7;
		v9968_wait_vsync();
		v9968_write_vdp( 26, h26 );
		v9968_write_vdp( 27, h27 );
	}
	v9968_wait_key();
	v9968_write_vdp( 26, 0 );
	v9968_write_vdp( 27, 0 );

	v9968_set_write_vram_address( 0x1800, 0 );
	v9968_puts( "[R#27 only]" );
	for( i = 0; i < 32; i++ ) {
		v9968_wait_vsync();
		v9968_wait_vsync();
		v9968_wait_vsync();
		v9968_write_vdp( 27, (i & 7) ^ 7 );
	}
	v9968_wait_key();
	v9968_write_vdp( 27, 0 );

	v9968_set_write_vram_address( 0x1800, 0 );
	v9968_puts( "[R#26 only]" );
	for( i = 0; i < 32; i++ ) {
		v9968_wait_vsync();
		v9968_wait_vsync();
		v9968_wait_vsync();
		v9968_write_vdp( 26, i );
	}
	v9968_wait_key();
	v9968_write_vdp( 26, 0 );

	v9968_set_write_vram_address( 0x1800, 0 );
	v9968_puts( "[R#27 MASK]" );
	v9968_write_vdp( 25, 0x02 );
	for( i = 0; i < 32; i++ ) {
		v9968_wait_vsync();
		v9968_wait_vsync();
		v9968_wait_vsync();
		v9968_write_vdp( 27, (i & 7) ^ 7 );
	}
	v9968_wait_key();
	v9968_write_vdp( 27, 0 );

	v9968_exit();
	return 0;
}
