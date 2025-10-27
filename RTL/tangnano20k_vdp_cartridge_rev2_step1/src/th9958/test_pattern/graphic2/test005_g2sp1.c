// --------------------------------------------------------------------
//	SCREEN0(W40) Sprite mode1 test
// ====================================================================
//	Programmed by t.hara
// --------------------------------------------------------------------

#include <stdio.h>
#include <stdlib.h>
#include "v9968.h"

// --------------------------------------------------------------------
void put_sprite( unsigned char plane, unsigned char x, unsigned char y, unsigned char color, unsigned char pattern ) {

	v9968_set_write_vram_address( 0x1B00 + (plane << 2), 0 );
	v9968_write_vram( y );
	v9968_write_vram( x );
	v9968_write_vram( pattern );
	v9968_write_vram( color );
}

// --------------------------------------------------------------------
int main( int argc, char *argv[] ) {
	int i, j;
	static unsigned char x[32], y[32], pattern[32], color[32];
	static signed char vx[32], vy[32];

	v9968_set_screen2();

	v9968_fill_vram( 0x1800, ' ', 32 * 24 );
	v9968_fill_vram( 0x2000, 0xF1, 8 * 256 );

	//	初期化
	for( i = 0; i < 32; i++ ) {
		x[i] = (i * 19) & 255;
		y[i] = (i * 17) & 255;
		if( y[i] > 191 ) {
			y[i] = y[i] - 191;
		}
		pattern[i] = i * 4 + 32;
		color[i] = (i & 7) + 2;
		vx[i] = ((i & 1) << 1) - 1;
		vy[i] = ((i & 1) << 1) - 1;
	}

	//	スプライトパターンを文字フォントと同じ形状にする
	v9968_write_vdp( 6, 0 );

	//	mode1 8x8 normal size
	v9968_set_write_vram_address( 0x1800, 0 );
	v9968_puts( "Sprite Mode1 8x8" );
	v9968_write_vdp( 1, 0x40 );
	for( j = 0; j < 300; j++ ) {
		v9968_wait_vsync();
		for( i = 0; i < 32; i++ ) {
			put_sprite( i, x[i], y[i], color[i], pattern[i] );
			x[i] += vx[i];
			y[i] += vy[i];
			if( y[i] == 192 ) {
				y[i] = 191;
				vy[i] = -vy[i];
			}
			else if( y[i] == 255 ) {
				y[i] = 0;
				vy[i] = -vy[i];
			}
		}
	}
	v9968_wait_key();

	//	mode1 8x8 magnify
	v9968_set_write_vram_address( 0x1800, 0 );
	v9968_puts( "Sprite Mode1 8x8 magnify" );
	v9968_write_vdp( 1, 0x41 );
	for( j = 0; j < 300; j++ ) {
		v9968_wait_vsync();
		for( i = 0; i < 32; i++ ) {
			put_sprite( i, x[i], y[i], color[i], pattern[i] );
			x[i] += vx[i];
			y[i] += vy[i];
			if( y[i] == 192 ) {
				y[i] = 191;
				vy[i] = -vy[i];
			}
			else if( y[i] == 255 ) {
				y[i] = 0;
				vy[i] = -vy[i];
			}
		}
	}
	v9968_wait_key();

	//	mode1 16x16 normal size
	v9968_set_write_vram_address( 0x1800, 0 );
	v9968_puts( "Sprite Mode1 16x16" );
	v9968_write_vdp( 1, 0x42 );
	for( j = 0; j < 300; j++ ) {
		v9968_wait_vsync();
		for( i = 0; i < 32; i++ ) {
			put_sprite( i, x[i], y[i], color[i], pattern[i] );
			x[i] += vx[i];
			y[i] += vy[i];
			if( y[i] == 192 ) {
				y[i] = 191;
				vy[i] = -vy[i];
			}
			else if( y[i] == 255 ) {
				y[i] = 0;
				vy[i] = -vy[i];
			}
		}
	}
	v9968_wait_key();

	//	mode1 16x16 magnify
	v9968_set_write_vram_address( 0x1800, 0 );
	v9968_puts( "Sprite Mode1  magnify" );
	v9968_write_vdp( 1, 0x43 );
	for( j = 0; j < 300; j++ ) {
		v9968_wait_vsync();
		for( i = 0; i < 32; i++ ) {
			put_sprite( i, x[i], y[i], color[i], pattern[i] );
			x[i] += vx[i];
			y[i] += vy[i];
			if( y[i] == 192 ) {
				y[i] = 191;
				vy[i] = -vy[i];
			}
			else if( y[i] == 255 ) {
				y[i] = 0;
				vy[i] = -vy[i];
			}
		}
	}
	v9968_wait_key();
	v9968_exit();
	return 0;
}
