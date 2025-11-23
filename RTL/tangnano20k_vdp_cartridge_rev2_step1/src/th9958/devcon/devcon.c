// ====================================================================
//	DEVCON Demonstration
// --------------------------------------------------------------------
//	Programmed by t.hara
// ====================================================================

#include <msx_vdp.h>
#include <msx.h>
#include <stdio.h>

typedef struct {
	signed short	y;
	unsigned char	mgy;
	unsigned char	mode;
	signed short	x;
	unsigned char	mgx;
	unsigned char	pattern;
} ATTRIBUTE_T;

// --------------------------------------------------------------------
void set_initial_palette( void ) {
	static unsigned char rgb[] = {
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
void set_sprite_palette( void ) {
	static unsigned char rgb[] = {
		//	Palette set #1
		 0,  0,  0,			//	 0 透明
		 0,  0,  0,			//	 1 黒
		18,  8,  0,			//	 2 オレンジ(暗)
		28, 12,  0,			//	 3 オレンジ(明)
		22, 22, 22,			//	 4 灰(明)
		18, 18, 18,			//	 5 灰(暗)
		31, 20,  0,			//	 6 オレンジ(明明)
		 0,  0, 24,			//	 7 青(明)
		26, 26, 26,			//	 8 灰(明明)
		10, 10, 10,			//	 9 灰(暗暗)
		 0,  0, 12,			//	10 青(暗)
		 6,  6,  6,			//	11 灰(暗暗暗)
		 0,  0, 10,			//	12 
		20,  0, 20,			//	13 
		30, 30, 30,			//	14 
		31, 31, 31,			//	15 白
		//	Palette set #2
		 0,  0,  0,			//	 0 透明
		 0,  0,  0,			//	 1 黒
		 0,  4,  8,			//	 2 ダークブルー(暗)
		 0,  6, 18,			//	 3 ダークブルー(明)
		22, 22, 22,			//	 4 灰(明)
		18, 18, 18,			//	 5 灰(暗)
		 0, 10, 28,			//	 6 ダークブルー(明明)
		 0,  0, 24,			//	 7 青(明)
		26, 26, 26,			//	 8 灰(明明)
		10, 10, 10,			//	 9 灰(暗暗)
		 0,  0, 12,			//	10 青(暗)
		 6,  6,  6,			//	11 灰(暗暗暗)
		 0,  0, 10,			//	12 
		20,  0, 20,			//	13 
		30, 30, 30,			//	14 
		31, 31, 31,			//	15 白
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
	int i, p;

//	if( !init_vdp() ) {
//		printf( "Cannot find V9968.\n" );
//		exit(0);
//	}

	set_screen5();
	//	周辺色黒
	vdp_write_reg( 7, 0x00 );
	//	左端マスク
	vdp_write_reg( 25, 0x02 );
	//	横スクロール初期値
	vdp_write_reg( 27, 7 );
	//	背景読み込み
	set_vram_write_address( 0, 0x0000 );
	bload( "bg.SC5" );
	set_initial_palette();
	//	スプライト画像読み込み
	set_sprite_palette();
	set_vram_write_address( 0, 0x8000 );
	bload( "usa.SC5" );
	_di();
	//	スプライトアトリビュートテーブル 0x10000
	vdp_write_reg(  5, 0x03 );
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
void put_usagi1( int x, int y, int dir ) {
	static ATTRIBUTE_T attribute[] = {
		{	//	左端
			31 | 0xC000,	//	Y (signed, 2bytes)
			128,			//	MGY
			1,				//	Palette Set#1
			16,				//	X (signed, 2bytes)
			16,				//	MGX
			0,				//	Pattern#0
		},
		{	//	中左
			31 | 0xC000,	//	Y (signed, 2bytes)
			128,			//	MGY
			1,				//	Palette Set#1
			32,				//	X (signed, 2bytes)
			16,				//	MGX
			1,				//	Pattern#1
		},
		{	//	中右
			31 | 0xC000,	//	Y (signed, 2bytes)
			128,			//	MGY
			1,				//	Palette Set#1
			48,				//	X (signed, 2bytes)
			16,				//	MGX
			2,				//	Pattern#2
		},
		{	//	右端
			31 | 0xC000,	//	Y (signed, 2bytes)
			128,			//	MGY
			1,				//	Palette Set#1
			64,				//	X (signed, 2bytes)
			16,				//	MGX
			3,				//	Pattern#3
		},
	};
	unsigned char *p = (unsigned char*) attribute;
	int i, port;
	set_vram_write_address( 1, 0x0000 );
	port = vdp_port1 - 1;
	for( i = 0; i < sizeof(attribute); i++ ) {
		outp( port, *p );
		p++;
	}
}

// --------------------------------------------------------------------
int main() {
	int x, y;

	initializer();

	x = 0;
	y = 0;
	while( 1 ) {
		wait_vsync( 1 );
		//	背景スクロール
		vdp_write_reg( 23, y );
		vdp_write_reg( 26, x >> 3 );
		vdp_write_reg( 27, (x & 7) ^ 7 );
		x = (x + 2) & 255;
		y = (y + 1) & 255;
		//	スプライト（うさぎファイター）
		put_usagi1( 0, 0, 0 );
	}
	return 0;
}
