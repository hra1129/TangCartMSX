// --------------------------------------------------------------------
//	SCREEN0(W40) Font Test
// ====================================================================
//	Programmed by t.hara
// --------------------------------------------------------------------

#include <stdio.h>
#include <stdlib.h>
#include "v9968.h"

// --------------------------------------------------------------------
void fill_increment( void ) {
	int i;

	v9968_set_write_vram_address( 0x1800, 0 );
	for( i = 0; i < 768; i++ ) {
		outp( vdp_port0, i & 255 );
	}
}

// --------------------------------------------------------------------
int main( int argc, char *argv[] ) {
	int i;
	static unsigned char d[10];

	v9968_set_screen1();

	fill_increment();
	v9968_set_read_vram_address( 0x1800 + 10, 0 );
	inp( vdp_port0 );

	v9968_set_write_vram_address( 0x1800 + 32 * 1, 0 );
	outp( vdp_port0, '1' );
	d[0] = inp( vdp_port0 );
	outp( vdp_port0, '2' );
	d[1] = inp( vdp_port0 );
	outp( vdp_port0, '3' );
	d[2] = inp( vdp_port0 );
	outp( vdp_port0, d[0] );
	outp( vdp_port0, d[1] );
	outp( vdp_port0, d[2] );

	v9968_set_read_vram_address( 0x1800 + 32 * 2, 0 );
	outp( vdp_port0, '1' );
	d[0] = inp( vdp_port0 );
	outp( vdp_port0, '2' );
	d[1] = inp( vdp_port0 );
	outp( vdp_port0, '3' );
	d[2] = inp( vdp_port0 );
	outp( vdp_port0, d[0] );
	outp( vdp_port0, d[1] );
	outp( vdp_port0, d[2] );

	v9968_wait_key();
	v9968_exit();
	return 0;
}
