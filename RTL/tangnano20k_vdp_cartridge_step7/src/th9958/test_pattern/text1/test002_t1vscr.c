// --------------------------------------------------------------------
//	SCREEN0(W40) Vertical Scroll Test
// ====================================================================
//	Programmed by t.hara
// --------------------------------------------------------------------

#include <stdio.h>
#include <stdlib.h>
#include "v9968.h"

// --------------------------------------------------------------------
int main( int argc, char *argv[] ) {
	int i;

	v9968_set_screen0_w40();

	v9968_set_write_vram_address( 0, 0 );
	for( i = 0; i < 40 * 24; i++ ) {
		v9968_write_vram( i );
	}

	for( i = 0; i < 256; i++ ) {
		v9968_write_vdp( 23, i );
		v9968_wait_vsync();
	}

	v9968_wait_key();
	v9968_exit();
	return 0;
}
