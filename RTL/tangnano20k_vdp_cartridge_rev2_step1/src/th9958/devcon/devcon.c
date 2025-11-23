// ====================================================================
//	DEVCON Demonstration
// --------------------------------------------------------------------
//	Programmed by t.hara
// ====================================================================

#include <msx_vdp.h>
#include <msx.h>
#include <stdio.h>

// --------------------------------------------------------------------
void set_initial_palette( void ) {
	static unsigned char rgb[] = {
		 0,  0,  0,
		31, 30,  0,
		 0,  0, 28,
		 0,  0,  0,
		 0,  0,  0,
		 0,  0,  0,
		 0,  0,  0,
		 0,  0,  0,
		 0,  0,  0,
		 0,  0,  0,
		 0,  0,  0,
		 0,  0,  0,
		 0,  0,  0,
		 0,  0,  0,
		31, 31, 31,
	};
	unsigned char *p_rgb;
	int i, p, j, d;

	_di();
	vdp_write_reg( 16, (0 << 4) | 0 );		//	palette set#0, palette#0
	_ei();
	p = vdp_port1 + 1;
	p_rgb = rgb;
	for( i = 0; i < 16 * 3; i++ ) {
		outp( p, 0 );
	}
	set_display_visible( MSX_TRUE );

	for( j = 32; j >= 0; j-- ) {
		_di();
		vdp_write_reg( 16, (0 << 4) | 0 );		//	palette set#0, palette#0
		_ei();
		p = vdp_port1 + 1;
		p_rgb = rgb;
		for( i = 0; i < sizeof(rgb); i++ ) {
			d = (int)*p_rgb - j;
			if( d < 0 ) {
				d = 0;
			}
			outp( p, d );
			p_rgb++;
		}
		wait_vsync( 2 );
	}
}

// --------------------------------------------------------------------
void set_initial_palette( void ) {
	static unsigned char rgb[] = {
		//	Palette set #1
		0,  0,  0,
		31, 30,  0,
		 0,  0, 28,
		10,  0,  0,
		 0, 10,  0,
		 0,  0, 10,
		10, 10,  0,
		 0, 10, 10,
		10,  0, 10,
		20,  0,  0,
		 0, 20,  0,
		 0,  0, 20,
		30,  0,  0,
		 0, 30,  0,
		31, 31, 31,
		//	Palette set #2
		0,  0,  0,
		31, 30,  0,
		 0,  0, 28,
		10,  0,  0,
		 0, 10,  0,
		 0,  0, 10,
		10, 10,  0,
		 0, 10, 10,
		10,  0, 10,
		20,  0,  0,
		 0, 20,  0,
		 0,  0, 20,
		30,  0,  0,
		 0, 30,  0,
		31, 31, 31,
	};
	unsigned char *p_rgb;
	int i, p;

	_di();
	vdp_write_reg( 16, (1 << 4) | 0 );		//	palette set#1, palette#0
	_ei();
	p = vdp_port1 + 1;
	p_rgb = rgb;
	for( i = 0; i < sizeof(rgb); i++ ) {
		outp( p, *p_rgb );
		p_rgb++;
	}
}

// --------------------------------------------------------------------
void initializer( void ) {
	int i;

	if( !init_vdp() ) {
		printf( "Cannot find V9968.\n" );
		exit(0);
	}

	set_screen5();
	//	周辺色黒
	vdp_write_reg( 7, 0x00 );
	//	左端マスク
	vdp_write_reg( 25, 0x02 );
	//	横スクロール初期値
	vdp_write_reg( 27, 7 );
	//	背景読み込み
	bload( "bg.SC5", 0x0000 );
	set_initial_palette();
	//	スプライト画像読み込み
	bload( "usa.SC5", 0x8000 );
	set_sprite_palette();
	_di();
	//	スプライトアトリビュートテーブル 0x10000
	vdp_write_reg(  5, 0x07 );
	vdp_write_reg( 11, 0x02 );
	//	スプライトパターンジェネレーターテーブル 0x08000
	vdp_write_reg(  6, 0x10 );
	//	スプライトアトリビュートテーブルをクリアする
	set_vram_write_address( 1, 0x0000 );
	p = vdp_port1 - 1;
	for( i = 0; i < 64 * 8; i++ ) {
		outp( p, 216 );
	}
	//	スプライト表示
	vdp_write_reg(  8, 0x08 );
	_ei();
}

// --------------------------------------------------------------------
void put_usagi1( 

// --------------------------------------------------------------------
int main() {
	int x, y;

	initializer();

	x = 0;
	y = 0;
	while( 1 ) {
		wait_vsync( 1 );
		vdp_write_reg( 23, y );
		vdp_write_reg( 26, x >> 3 );
		vdp_write_reg( 27, (x & 7) ^ 7 );
		x = (x + 2) & 255;
		y = (y + 1) & 255;
	}
	return 0;
}
