// --------------------------------------------------------------------
//	SCREEN0(W40) Set Adjust Test
// ====================================================================
//	Programmed by t.hara
// --------------------------------------------------------------------

#include <stdio.h>
#include <stdlib.h>
#include "v9968.h"

// --------------------------------------------------------------------
int main( int argc, char *argv[] ) {
	int i, x, y;
	char s_buffer[32];

	v9968_set_screen1();

	v9968_set_write_vram_address( 0x1800, 0 );
	for( i = 0; i < 40 * 24; i++ ) {
		v9968_write_vram( i );
	}

	v9968_wait_vsync();
	for( y = -8; y < 8; y++ ) {
		for( x = -8; x < 8; x++ ) {
			sprintf( s_buffer, "R#18 = [%d,%d]  ", x, y );
			v9968_set_write_vram_address( 0x1800, 0 );
			v9968_puts( s_buffer );
			v9968_write_vdp( 18, (x & 15) | ((y & 15) << 4) );
			v9968_wait_vsync();
			v9968_wait_vsync();
		}
	}
	v9968_wait_key();

	v9968_wait_vsync();
	v9968_write_vdp( 25, 0x02 );
	for( y = -8; y < 8; y++ ) {
		for( x = -8; x < 8; x++ ) {
			sprintf( s_buffer, "R#18 = [%d,%d]MASK ", x, y );
			v9968_set_write_vram_address( 0x1800, 0 );
			v9968_puts( s_buffer );
			v9968_write_vdp( 18, (x & 15) | ((y & 15) << 4) );
			v9968_wait_vsync();
			v9968_wait_vsync();
		}
	}
	v9968_wait_key();
	v9968_exit();
	return 0;
}
