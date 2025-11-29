// ====================================================================
//	DEVCON Demonstration
// --------------------------------------------------------------------
//	Programmed by t.hara
// ====================================================================

#include <msx_vdp.h>
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

static int x1 = 16;
static int pattern1 = 0;

static int x2 = 128;
static int pattern2 = 0;

void state_fighter( void );

// --------------------------------------------------------------------
void fill_rectangle( int x, int y, int nx, int ny, unsigned char color ) {
	int port = vdp_port1 + 2;

	wait_vdp_command();
	vdp_write_reg( 17, 36 );
	outp( port, x & 255 );
	outp( port, x >> 8 );
	outp( port, y & 255 );
	outp( port, y >> 8 );
	outp( port, nx & 255 );
	outp( port, nx >> 8 );
	outp( port, ny & 255 );
	outp( port, ny >> 8 );
	outp( port, color );
	outp( port, 0 );
	outp( port, 0x80 );
}

// --------------------------------------------------------------------
void draw_line( int x, int y, int nx, int ny, unsigned char color ) {
	int port = vdp_port1 + 2;

	wait_vdp_command();
	vdp_write_reg( 17, 36 );
	outp( port, x & 255 );
	outp( port, x >> 8 );
	outp( port, y & 255 );
	outp( port, y >> 8 );
	outp( port, nx & 255 );
	outp( port, nx >> 8 );
	outp( port, ny & 255 );
	outp( port, ny >> 8 );
	outp( port, color );
	outp( port, 0 );
	outp( port, 0x70 );
}

// --------------------------------------------------------------------
void set_initial_palette( void ) {
	static unsigned char rgb[] = {
		 0,  0,  0,		//	0
		31, 22,  8,		//	1
		31, 26,  0,		//	2
		26,  0,  0,		//	3
		 4, 13, 17,		//	4
		13, 17, 22,		//	5
		 0,  8, 17,		//	6
		13, 13, 13,		//	7
		 0,  4, 13,		//	8
		 4,  4,  4,		//	9
		22, 22, 13,		//	10
		 0,  4,  4,		//	11
		 0,  0, 13,		//	12
		 0,  0,  4,		//	13
		 4,  4, 26,		//	14
		31, 31, 31,		//	15
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
		//	Palette set #3
		 0,  0,  0,			//	 0 
		 0,  0,  0,			//	 1 
		 1,  1,  3,			//	 2 
		 2,  2,  6,			//	 3 
		 3,  3,  9,			//	 4 
		 4,  4, 12,			//	 5 
		 5,  5, 15,			//	 6 
		 6,  6, 18,			//	 7 
		 7,  7, 21,			//	 8 
		 8,  8, 24,			//	 9 
		 9,  9, 27,			//	10 
		10, 10, 30,			//	11 
		11, 11, 31,			//	12 
		12, 12, 31,			//	13 
		13, 13, 31,			//	14 
		14, 14, 31,			//	15 
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
	int i, p, x, pattern;
	unsigned char c[] = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 14 };

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
	set_vram_write_address( 0, 0x0000 );
	bload( "bg.SC5" );
	set_initial_palette();
	//	スプライト画像読み込み
	set_sprite_palette();
	set_vram_write_address( 0, 0x8000 );
	bload( "usa.SC5" );
	set_vram_write_address( 1, 0x8000 );
	bload( "font.bin" );
	_di();
	//	スプライトアトリビュートテーブル 0x10000
	vdp_write_reg(  5, 0x03 );
	vdp_write_reg( 11, 0x02 );
	//	スプライトパターンジェネレーターテーブル 0x08000
	vdp_write_reg(  6, 0x10 );
	//	スプライトアトリビュートテーブルをクリアする
	set_vram_write_address( 1, 0x0000 );
	p = vdp_port1 - 1;
	for( i = 0; i < 10 * 8; i+=2 ) {	//	うさぎ2体の分 Plane#0～#9
		outp( p, 0 );
		outp( p, 1 );
	}
	x = 16;
	pattern = 128 + 16;
	for( i = 0; i < 14 * 8; i+=8 ) {	//	メッセージ表示エリア #10～#23
		outp( p, 170 );			//	Y
		outp( p, 1 << 6 );		//	SZ = 16x32
		outp( p, 32 );			//	MGY
		outp( p, 0 );			//	PaletteSet#0, TP = 0% (不透明)
		outp( p, x );			//	X
		outp( p, 0 );
		outp( p, 16 );			//	MGX
		outp( p, pattern );
		x += 16;
		pattern++;
	}
	for( i = 0; i < 1 * 8; i+=2 ) {		//	ウィンドウ枠の分 Plane#24
		outp( p, 0 );
		outp( p, 1 );
	}
	outp( p, 216 );						//	Plane#25 以降非表示
	outp( p, 0 );
	//	スプライトパターン更新
	for( i = 0; i < 16; i++ ) {
		fill_rectangle( 0, 256 + 128 + i, 16, 1, c[i] );
	}
	fill_rectangle( 0, 256 + 128 + 16, 224, 32, 0 );
	//	スプライト表示
	vdp_write_reg(  8, 0x08 );
	_ei();
}

// --------------------------------------------------------------------
void put_usagi( ATTRIBUTE_T *p_attribute, ATTRIBUTE_T *p_shadow, int x, int dir, int pattern ) {
	unsigned char *p = (unsigned char*) p_attribute;
	int i, port;
	port = vdp_port1 - 1;
	x = x & 0x3FF;
	p_shadow->x = x;
	if( dir ) {
		//	右向き
		pattern					+= 3;
		p_attribute->mode		= p_attribute->mode | 0x10;
		p_attribute->x			= x;
		p_attribute->pattern	= pattern--;
		p_attribute++;
		p_attribute->mode		= p_attribute->mode | 0x10;
		p_attribute->x			= x + 16;
		p_attribute->pattern	= pattern--;
		p_attribute++;
		p_attribute->mode		= p_attribute->mode | 0x10;
		p_attribute->x			= x + 32;
		p_attribute->pattern	= pattern--;
		p_attribute++;
		p_attribute->mode		= p_attribute->mode | 0x10;
		p_attribute->x			= x + 48;
		p_attribute->pattern	= pattern;
	}
	else {
		//	左向き
		p_attribute->mode		= p_attribute->mode & 0x0F;
		p_attribute->x			= x;
		p_attribute->pattern	= pattern++;
		p_attribute++;
		p_attribute->mode		= p_attribute->mode & 0x0F;
		p_attribute->x			= x + 16;
		p_attribute->pattern	= pattern++;
		p_attribute++;
		p_attribute->mode		= p_attribute->mode & 0x0F;
		p_attribute->x			= x + 32;
		p_attribute->pattern	= pattern++;
		p_attribute++;
		p_attribute->mode		= p_attribute->mode & 0x0F;
		p_attribute->x			= x + 48;
		p_attribute->pattern	= pattern;
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
	static ATTRIBUTE_T window = {
		-40 & 0x03FF,	//	Y (signed, 2bytes)
		40,				//	MGY
		3 | (1 << 6),	//	Palette Set#3
		16,				//	X (signed, 2bytes)
		16,				//	MGX
		128,			//	Pattern#0
	};
	static int y = -40;
	int i;
	unsigned char *p = (unsigned char *) window;
	int port = vdp_port1 - 1;

	wait_vsync( 1 );
	//	ウィンドウ
	if( y != 166 ) {
		y++;
		window.y = y & 0x03FF;
	}
	else if( window.mgx != 224 ) {
		window.mgx += 2;
	}
	else {
		//	次のステートへ
		p_state = state_fighter;
	}
	set_vram_write_address( 1, 0x0000 + 24 * 8 );
	for( i = 0; i < 8; i++ ) {
		outp( port, *p );
		p++;
	}
	background_scroll();
}

// --------------------------------------------------------------------
void state_fighter( void ) {
	static int count1 = 8;
	static int count2 = 12;

	wait_vsync( 1 );
	//	スプライト（うさぎファイター）
	set_vram_write_address( 1, 0x0000 + 0 * 8 );
	put_usagi( rabbit1, &shadow[0], x1, 0, pattern1 );
	set_vram_write_address( 1, 0x0000 + 4 * 8 );
	put_usagi( rabbit2, &shadow[1], x2, 1, pattern2 );
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
	if( (--count1) == 0 ) {
		pattern1 = 4 - pattern1;
		count1 = 8;
	}
	if( (--count2) == 0 ) {
		pattern2 = 4 - pattern2;
		count2 = 12;
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

