// --------------------------------------------------------------------
//	SCREEN0(W40) Sprite mode1 and left mask test
// ====================================================================
//	Programmed by t.hara
// --------------------------------------------------------------------

#include <stdio.h>
#include <stdlib.h>
#include "v9968.h"

// --------------------------------------------------------------------
void put_sprite( int x, int y, unsigned char color, unsigned char pattern ) {

	v9968_write_vram( y & 255 );
	v9968_write_vram( ((y >> 8) & 0x0F) | 0x40 );
	v9968_write_vram( 32 );
	v9968_write_vram( color );
	v9968_write_vram( x & 255 );
	v9968_write_vram( ((x >> 8) & 0x0F) | 0x10 );
	v9968_write_vram( 16 );
	v9968_write_vram( pattern );
}

// --------------------------------------------------------------------
int main( int argc, char *argv[] ) {
	int i, j;
	static int x[64], y[64], vx[64], vy[64];
	static unsigned char pattern[64], color[64];

	v9968_set_screen2();
	v9968_bload( "image1.SC5" );

	v9968_fill_vram( 0x1800, ' ', 32 * 24 );
	v9968_fill_vram( 0x2000, 0xF1, 8 * 256 );
	v9968_write_vdp( 5, 0x3F );						//	Sprite Attribute Table (L) = 0x1E00	
	v9968_set_write_vram_address( 0x1E00, 0 );
	for( i = 0; i < 64; i++ ) {
		put_sprite( 0, 216, 0, 0 );
	}

	if( (v9968_read_vdp_status( 1 ) & 0x3E) <= 4 ) {
		v9968_set_write_vram_address( 0x1800, 0 );
		v9968_puts( "This test requires V9968 or later." );
		v9968_wait_key();
		v9968_exit();
		return 0;
	}

	v9968_write_vdp( 20, 0xFF );

	//	初期化
	for( i = 0; i < 64; i++ ) {
		x[i] = rand() & 255;
		y[i] = rand() & 255;
		if( y[i] > 191 ) {
			y[i] -= 191;
		}
		pattern[i] = 0;
		color[i] = 0;
		vx[i] = (rand() & 7) - 3;
		vy[i] = (rand() & 7) - 3;
		if( vx[i] == 0 ) {
			vx[i]++;
		}
		if( vy[i] == 0 ) {
			vy[i]++;
		}
	}

	//	スプライトパターンを定義する
	v9968_write_vdp( 6, 0 );

	//	左8dotマスク
	v9968_write_vdp( 25, 2 );

	for( j = 0; j < 600; j++ ) {
		v9968_wait_vsync();
		v9968_set_write_vram_address( 0x1E00, 0 );
		for( i = 0; i < 64; i++ ) {
			put_sprite( x[i], y[i], color[i], pattern[i] );
			x[i] += vx[i];
			if( x[i] < -15 ) {
				x[i] = -15;
				vx[i] = -vx[i];
			}
			else if( x[i] > 255 ) {
				x[i] = 255;
				vx[i] = -vx[i];
			}

			y[i] += vy[i];
			if( y[i] < -15 ) {
				y[i] = -15;
				vy[i] = -vy[i];
			}
			else if( y[i] > 192 ) {
				y[i] = 192;
				vy[i] = -vy[i];
			}
		}
	}
	v9968_wait_key();
	v9968_exit();
	return 0;
}
