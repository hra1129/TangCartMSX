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

typedef void (*CALLBACK_T)( void );

static CALLBACK_T p_state;

static ATTRIBUTE_T rabbit1[] = {
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

static ATTRIBUTE_T rabbit2[] = {
	{	//	左端
		31 | 0xC000,	//	Y (signed, 2bytes)
		128,			//	MGY
		2 | 16,			//	Palette Set#2
		128,			//	X (signed, 2bytes)
		16,				//	MGX
		3,				//	Pattern#0
	},
	{	//	中左
		31 | 0xC000,	//	Y (signed, 2bytes)
		128,			//	MGY
		2 | 16,			//	Palette Set#2
		144,			//	X (signed, 2bytes)
		16,				//	MGX
		2,				//	Pattern#1
	},
	{	//	中右
		31 | 0xC000,	//	Y (signed, 2bytes)
		128,			//	MGY
		2 | 16,			//	Palette Set#2
		160,			//	X (signed, 2bytes)
		16,				//	MGX
		1,				//	Pattern#2
	},
	{	//	右端
		31 | 0xC000,	//	Y (signed, 2bytes)
		128,			//	MGY
		2 | 16,			//	Palette Set#2
		176,			//	X (signed, 2bytes)
		16,				//	MGX
		0,				//	Pattern#3
	},
};

static ATTRIBUTE_T shadow[] = {
	{	//	オレンジうさぎの陰
		153,				//	Y (signed, 2bytes)
		12,				//	MGY
		(2 << 6) | 1,	//	Palette Set#1, TP=50%
		16,				//	X (signed, 2bytes)
		64,				//	MGX
		129,			//	Pattern#0
	},
	{	//	ブルーうさぎの陰
		153,			//	Y (signed, 2bytes)
		12,				//	MGY
		(2 << 6) | 1,	//	Palette Set#1, TP=50%
		32,				//	X (signed, 2bytes)
		64,				//	MGX
		129,			//	Pattern#1
	},
};

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
void put_usagi( ATTRIBUTE_T *p_attribute, ATTRIBUTE_T *p_shadow, int x, int dir ) {
	unsigned char *p = (unsigned char*) p_attribute;
	int i, port;
	port = vdp_port1 - 1;
	x = x & 0x3FF;
	p_shadow->x = x;
	if( dir ) {
		//	右向き
		p_attribute->mode		= p_attribute->mode | 0x10;
		p_attribute->x			= x;
		p_attribute->pattern	= 3;
		p_attribute++;
		p_attribute->mode		= p_attribute->mode | 0x10;
		p_attribute->x			= x + 16;
		p_attribute->pattern	= 2;
		p_attribute++;
		p_attribute->mode		= p_attribute->mode | 0x10;
		p_attribute->x			= x + 32;
		p_attribute->pattern	= 1;
		p_attribute++;
		p_attribute->mode		= p_attribute->mode | 0x10;
		p_attribute->x			= x + 48;
		p_attribute->pattern	= 0;
	}
	else {
		//	左向き
		p_attribute->mode		= p_attribute->mode & 0x0F;
		p_attribute->x			= x;
		p_attribute->pattern	= 0;
		p_attribute++;
		p_attribute->mode		= p_attribute->mode & 0x0F;
		p_attribute->x			= x + 16;
		p_attribute->pattern	= 1;
		p_attribute++;
		p_attribute->mode		= p_attribute->mode & 0x0F;
		p_attribute->x			= x + 32;
		p_attribute->pattern	= 2;
		p_attribute++;
		p_attribute->mode		= p_attribute->mode & 0x0F;
		p_attribute->x			= x + 48;
		p_attribute->pattern	= 3;
	}
	for( i = 0; i < 8 * 4; i++ ) {
		outp( port, *p );
		p++;
	}
}

// --------------------------------------------------------------------
void put_shadow( void ) {
	unsigned char *p = (unsigned char*) shadow;
	int i, port;
	port = vdp_port1 - 1;
	for( i = 0; i < 8 * 2; i++ ) {
		outp( port, *p );
		p++;
	}
}

// --------------------------------------------------------------------
void background_scroll( void ) {
	static int x = 0, y = 0;

	//	背景スクロール
	vdp_write_reg( 23, y );
	vdp_write_reg( 26, x >> 3 );
	vdp_write_reg( 27, (x & 7) ^ 7 );
	x = (x + 2) & 255;
	y = (y + 1) & 255;
}

// --------------------------------------------------------------------
void state_window_animation( void ) {
	static int x1 = 16, x2 = 128;

	wait_vsync( 1 );
	//	スプライト（うさぎファイター）
	set_vram_write_address( 1, 0x0000 + 0 * 8 );
	put_usagi( rabbit1, &shadow[0], x1, 0 );
	set_vram_write_address( 1, 0x0000 + 4 * 8 );
	put_usagi( rabbit2, &shadow[1], x2, 1 );
	set_vram_write_address( 1, 0x0000 + 8 * 8 );
	put_shadow();

	x1++;
	if( x1 == 256 ) {
		x1 = -64;
	}
	x2--;
	if( x2 == -64 ) {
		x2 = 255;
	}
	background_scroll();
}

// --------------------------------------------------------------------
int main() {
	int x, y;

	initializer();
	p_state = state_window_animation;

	while( 1 ) {
		p_state();
	}
	return 0;
}
