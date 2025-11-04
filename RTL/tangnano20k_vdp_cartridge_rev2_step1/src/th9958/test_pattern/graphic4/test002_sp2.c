// --------------------------------------------------------------------
//	SCREEN5 Sprite mode3
// ====================================================================
//	Programmed by t.hara
// --------------------------------------------------------------------

#include <stdio.h>
#include <stdlib.h>
#include "v9968.h"
#include "v9968_font.h"

typedef struct {
	short y;
	unsigned char mgy;
	unsigned char mode;
	short x;
	unsigned char mgx;
	unsigned char pattern;
} ATTRIBUTE_T;

// --------------------------------------------------------------------
void put_sprite( unsigned char plane, ATTRIBUTE_T *p ) {

	v9968_copy_to_vram( 0x7600 + (plane << 3), (void*)p, 8 );
}

// --------------------------------------------------------------------
void set_page( unsigned char page ) {

	v9968_write_vdp( 2, (page << 5) | 0x1F );
}

// --------------------------------------------------------------------
int main( int argc, char *argv[] ) {
	int i, j;
	static ATTRIBUTE_T attribute[64];

	v9968_set_screen5();
	set_page( 0 );
	v9968_write_vdp( 7, 0 );
	v9968_write_vdp( 6, 0 );
	v9968_bload( "PARTS.SC5" );

	v9968_write_vdp( 20, 0x00 );		//	従来パレットを読み込むので、拡張パレットOFF
	v9968_color_restore( 0x7680 );
	v9968_write_vdp( 20, 0xFF );		//	従来パレットを読み込むので、拡張パレットON
	v9968_fill_vram( 0x7600, 216, 8 * 64 );
	v9968_wait_key();

	for( i = 0; i < 64; i++ ) {
		attribute[i].x = (i & 15) << 4;
		attribute[i].y = i & ~15;
		attribute[i].mgx = 16;
		attribute[i].mgy = 16;
		attribute[i].mode = 0;
		attribute[i].pattern = 0;
		put_sprite( i, &attribute[i] );
		v9968_wait_key();
	}
	v9968_wait_key();
	v9968_exit();
	return 0;
}
