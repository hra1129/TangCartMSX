// --------------------------------------------------------------------
//	SCREEN0(W40) Sprite mode1 and left mask test
// ====================================================================
//	Programmed by t.hara
// --------------------------------------------------------------------

#include <stdio.h>
#include <stdlib.h>
#include "v9968.h"

// --------------------------------------------------------------------
int main( int argc, char *argv[] ) {
	int i, j;

	v9968_set_screen6();
	v9968_write_vdp( 7, 0x00 );
	v9968_bload( "F1_CAR2.SC6" );
	v9968_color_restore( 0x7680 );	//	read palette data on VRAM and set palette
	v9968_wait_key();
	v9968_exit();
	return 0;
}
