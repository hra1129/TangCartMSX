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

static unsigned char rgb[] = {
	 0,  0,  0,		//	0
	31, 22,  8,		//	1
	31, 26,  0,		//	2
	 0,  0, 26,		//	3
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

static unsigned char sprite_rgb[] = {
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

static ATTRIBUTE_T shadow_mag[] = {
	{	//	オレンジうさぎの陰
		147,				//	Y (signed, 2bytes)
		20,				//	MGY
		(2 << 6) | 1,	//	Palette Set#1, TP=50%
		16,				//	X (signed, 2bytes)
		128,			//	MGX
		129,			//	Pattern#0
	},
	{	//	ブルーうさぎの陰
		147,			//	Y (signed, 2bytes)
		20,				//	MGY
		(2 << 6) | 1,	//	Palette Set#1, TP=50%
		32,				//	X (signed, 2bytes)
		128,			//	MGX
		129,			//	Pattern#1
	},
};

static int x1 = -64;
static int pattern1 = 0;

static int x2 = 256;
static int pattern2 = 0;

static int run_demo = 0;
static int message_state = 32;
static int mag = 0;
static int scroll_x = 0, scroll_y = 0;

void state_window_animation( void );
void state_dot_by_dot( void );
void state_size_select( void );
void state_transparent( void );
void state_magnify( void );
void state_maximum_puts( void );
void state_all_screen( void );
void state_color( void );
void state_reverse( void );
void state_patterns( void );
void state_easy( void );
void state_highspeed_command( void );
void state_font_command( void );
void state_end( void );
void state_fighter( void );

// --------------------------------------------------------------------
void fill_rectangle( int sx, int sy, int nx, int ny, unsigned char color ) {
	int port = vdp_port1 + 2;

	wait_vdp_command();

	#asm
	ld		hl, 2 + 2 + 9
	add		hl, sp

	ld		a, ( _vdp_port1 )
	ld		c, a
	ld		a, 36
	di
	out		(c), a
	ld		a, 0x80 + 17
	out		(c), a
	inc		c
	inc		c

	ld		d, (hl)		//	sx
	dec		hl
	ld		e, (hl)		//	sx
	dec		hl
	out		(c), e
	out		(c), d

	ld		d, (hl)		//	sy
	dec		hl
	ld		e, (hl)		//	sy
	dec		hl
	out		(c), e
	out		(c), d

	ld		d, (hl)		//	nx
	dec		hl
	ld		e, (hl)		//	nx
	dec		hl
	out		(c), e
	out		(c), d

	ld		d, (hl)		//	ny
	dec		hl
	ld		e, (hl)		//	ny
	dec		hl
	out		(c), e
	out		(c), d

	dec		hl
	ld		a, (hl)		//	color
	out		(c), a
	xor		a
	out		(c), a
	ld		a, 0x80
	out		(c), a
	ei
	#endasm
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
void block_copy( int sx, int sy, int nx, int ny, int dx, int dy ) {
	int port = vdp_port1 + 2;

	wait_vdp_command();
	vdp_write_reg( 17, 32 );
	outp( port, sx & 255 );
	outp( port, sx >> 8 );
	outp( port, sy & 255 );
	outp( port, sy >> 8 );
	outp( port, dx & 255 );
	outp( port, dx >> 8 );
	outp( port, dy & 255 );
	outp( port, dy >> 8 );
	outp( port, nx & 255 );
	outp( port, nx >> 8 );
	outp( port, ny & 255 );
	outp( port, ny >> 8 );
	outp( port, 0 );
	outp( port, 0 );
	outp( port, 0x90 );
}

// --------------------------------------------------------------------
void set_initial_palette( void ) {
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
void fadeout_palette( void ) {
	unsigned char *p_rgb;
	int i, p, j, d;

	p = vdp_port1 + 1;
	p_rgb = rgb;
	for( j = 0; j <= 32; j++ ) {
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
	fill_rectangle( 0, 0, 256, 256, 0 );
}

// --------------------------------------------------------------------
void set_default_palette( void ) {
	static const unsigned char init_palette[] = {
		0x00, 0x0,
		0x00, 0x0,
		0x11, 0x6,
		0x33, 0x7,
		0x17, 0x1,
		0x27, 0x3,
		0x51, 0x1,
		0x27, 0x6,
		0x71, 0x1,
		0x73, 0x3,
		0x61, 0x6,
		0x64, 0x6,
		0x11, 0x4,
		0x65, 0x2,
		0x55, 0x5,
		0x77, 0x7,
	};
	int i, p;
	p = vdp_port1 + 1;
	vdp_write_reg( 16, 0 );
	for( i = 0; i < sizeof(init_palette); i++ ) {
		outp( p, init_palette[i] );
	}
}

// --------------------------------------------------------------------
void set_sprite_palette( void ) {
	unsigned char *p_rgb;
	int i, p;

	_di();
	vdp_write_reg( 16, (1 << 4) | 0 );		//	palette set#1, palette#0
	_ei();
	p = vdp_port1 + 1;
	p_rgb = sprite_rgb;
	for( i = 0; i < sizeof(sprite_rgb); i++ ) {
		outp( p, *p_rgb );
		p_rgb++;
	}
}

// --------------------------------------------------------------------
static unsigned char sprite_fade_count1 = 0;
static unsigned char sprite_fade_count2 = 0;

void set_sprite_fade_palette( void ) {

	#asm
	ld		a, (_sprite_fade_count1)
	ld		e, a
	ld		a, (_sprite_fade_count2)
	ld		d, a

	ld		hl, _sprite_rgb
	//	R#16 = (1 << 4) | 0
	ld		a, (_vdp_port1)
	ld		c, a
	ld		a, (1 << 4) | 0
	di
	out		(c), a
	ld		a, 0x80 | 16
	ei
	out		(c), a

	inc		c
	ld		b, 16 * 3
loop1:
	ld		a, (hl)
	sub		a, e
	jr		nc, skip1
	xor		a
skip1:
	out		(c), a
	inc		hl
	djnz	loop1

	ld		b, 16 * 3
loop2:
	ld		a, (hl)
	sub		a, d
	jr		nc, skip2
	xor		a
skip2:
	out		(c), a
	inc		hl
	djnz	loop2

	ld		a, e
	inc		a
	and		31
	ld		(_sprite_fade_count1), a
	and		1
	jr		z, skip3

	ld		a, d
	inc		a
	and		31
	ld		(_sprite_fade_count2), a
skip3:
	#endasm
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
	//	page0背景を page4へコピー
	block_copy( 0, 0, 256, 256, 0, 1024 );
	//	LRMM時のソースウィンドウを設定
	vdp_write_reg( 17, 51 );
	outp( vdp_port1, 0 );			//	Wsx = 0
	outp( vdp_port1, 0 );
	outp( vdp_port1, 0 );			//	Wsy = 0, page4
	outp( vdp_port1, 4 );
	outp( vdp_port1, 255 );			//	Wex = 255
	outp( vdp_port1, 0 );
	outp( vdp_port1, 255 );			//	Wey = 255, page4
	outp( vdp_port1, 4 );
	//	スプライト表示
	vdp_write_reg(  8, 0x08 );
	_ei();
}

// --------------------------------------------------------------------
void terminator( void ) {
	int i;

	//	パレットをフェードアウトして画面を消す
	fadeout_palette();

	//	V9958互換モードに戻す
	_di();
	vdp_write_reg(  9, 0x00 );
	vdp_write_reg( 10, 0x00 );
	vdp_write_reg( 11, 0x00 );
	vdp_write_reg( 20, 0x00 );
	vdp_write_reg( 21, 0x00 );
	vdp_write_reg( 23, 0x00 );
	vdp_write_reg( 25, 0x00 );
	vdp_write_reg( 26, 0x00 );
	vdp_write_reg( 27, 0x00 );

	//	初期状態のパレットに戻す
	set_default_palette();

	//	レジスタを初期状態に戻す
	vdp_write_reg( 14, 0 );
	for( i = 0; i < 8; i++ ) {
		vdp_write_reg( i, bpeek( 0xF3DF + i ) );
	}
	_ei();

	//	いったん SCREEN 3 に変える
	#asm
	ld		a, 3
	ld		ix, 0x005f		//	CHGMOD
	ld		iy, ( 0xFCC1 - 1 )
	call	0x001C			//	CALSLT
	#endasm
}

// --------------------------------------------------------------------
void put_usagi( ATTRIBUTE_T *p_attribute, ATTRIBUTE_T *p_shadow, int x, int dir, int pattern ) {
	unsigned char *p = (unsigned char*) p_attribute;

	x = x & 0x3FF;
	p_shadow->x = x;
	if( dir ) {
		//	左向き
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
		//	右向き
		p_attribute->mode		= p_attribute->mode & 0xEF;
		p_attribute->x			= x;
		p_attribute->pattern	= pattern++;
		p_attribute++;
		p_attribute->mode		= p_attribute->mode & 0xEF;
		p_attribute->x			= x + 16;
		p_attribute->pattern	= pattern++;
		p_attribute++;
		p_attribute->mode		= p_attribute->mode & 0xEF;
		p_attribute->x			= x + 32;
		p_attribute->pattern	= pattern++;
		p_attribute++;
		p_attribute->mode		= p_attribute->mode & 0xEF;
		p_attribute->x			= x + 48;
		p_attribute->pattern	= pattern;
	}
	#asm
	ld		hl, 0
	add		hl, sp
	ld		e, (hl)
	inc		hl
	ld		d, (hl)
	ex		de, hl
	ld		b, 8 * 4
	ld		a, (_vdp_port1)
	dec		a
	ld		c, a
	otir
	#endasm
}

// --------------------------------------------------------------------
void put_usagi_mag( ATTRIBUTE_T *p_attribute, ATTRIBUTE_T *p_shadow, int x, int dir, int pattern ) {
	unsigned char *p = (unsigned char*) p_attribute;

	x = x & 0x3FF;
	p_shadow->x = x;
	if( dir ) {
		//	左向き
		pattern					+= 3;
		p_attribute->y			= 0xFF9F;
		p_attribute->mgy		= 0;
		p_attribute->mode		= p_attribute->mode | 0x10;
		p_attribute->x			= x;
		p_attribute->mgx		= 32;
		p_attribute->pattern	= pattern--;
		p_attribute++;
		p_attribute->y			= 0xFF9F;
		p_attribute->mgy		= 0;
		p_attribute->mode		= p_attribute->mode | 0x10;
		p_attribute->x			= x + 32;
		p_attribute->mgx		= 32;
		p_attribute->pattern	= pattern--;
		p_attribute++;
		p_attribute->y			= 0xFF9F;
		p_attribute->mgy		= 0;
		p_attribute->mode		= p_attribute->mode | 0x10;
		p_attribute->x			= x + 64;
		p_attribute->mgx		= 32;
		p_attribute->pattern	= pattern--;
		p_attribute++;
		p_attribute->y			= 0xFF9F;
		p_attribute->mgy		= 0;
		p_attribute->mode		= p_attribute->mode | 0x10;
		p_attribute->x			= x + 96;
		p_attribute->mgx		= 32;
		p_attribute->pattern	= pattern;
	}
	else {
		//	右向き
		p_attribute->y			= 0xFF9F;
		p_attribute->mgy		= 0;
		p_attribute->mode		= p_attribute->mode & 0xEF;
		p_attribute->x			= x;
		p_attribute->mgx		= 32;
		p_attribute->pattern	= pattern++;
		p_attribute++;
		p_attribute->y			= 0xFF9F;
		p_attribute->mgy		= 0;
		p_attribute->mode		= p_attribute->mode & 0xEF;
		p_attribute->x			= x + 32;
		p_attribute->mgx		= 32;
		p_attribute->pattern	= pattern++;
		p_attribute++;
		p_attribute->y			= 0xFF9F;
		p_attribute->mgy		= 0;
		p_attribute->mode		= p_attribute->mode & 0xEF;
		p_attribute->x			= x + 64;
		p_attribute->mgx		= 32;
		p_attribute->pattern	= pattern++;
		p_attribute++;
		p_attribute->y			= 0xFF9F;
		p_attribute->mgy		= 0;
		p_attribute->mode		= p_attribute->mode & 0xEF;
		p_attribute->x			= x + 96;
		p_attribute->mgx		= 32;
		p_attribute->pattern	= pattern;
	}
	#asm
	ld		hl, 0
	add		hl, sp
	ld		e, (hl)
	inc		hl
	ld		d, (hl)
	ex		de, hl
	ld		b, 8 * 4
	ld		a, (_vdp_port1)
	dec		a
	ld		c, a
	otir
	#endasm
}

// --------------------------------------------------------------------
void put_shadow( void ) {

	#asm
	ld		hl, _shadow
	ld		a, (_vdp_port1)
	dec		a
	ld		c, a
	ld		b, 8 * 2
	otir
	#endasm
}

// --------------------------------------------------------------------
void put_shadow_mag( void ) {

	#asm
	ld		hl, _shadow_mag
	ld		a, (_vdp_port1)
	dec		a
	ld		c, a
	ld		b, 8 * 2
	otir
	#endasm
}

// --------------------------------------------------------------------
void put_message( int n ) {

	message_state = 0;
	wait_vdp_command();

	#asm
	ld		ix, 2
	add		ix, sp
	//	HL = n * 896 + 0x8000 (フォントデータは 0x18000 + n * 896 にある)
	//	896 = 0x380 → n * 896 = ((n * 256) >> 1) + (n * 256) + ((n * 256) << 1)
	ld		h, (ix + 0)		//	HL = n * 256
	ld		l, 0
	ld		e, l			//	DE = n * 256
	ld		d, h
	rrc		h				//	HL >>= 1
	rr		l
	add		hl, de			//	HL = HL + DE = ((n * 256) >> 1) + (n * 256)
	ex		de, hl			//	HL = (n * 256); DE = ((n * 256) >> 1) + (n * 256)
	add		hl, hl			//	HL = ((n * 256) << 1)
	add		hl, de			//	HL = n * 896
	ld		a, 0x80
	or		a, h
	ld		h, a			//	HL = n * 896 + 0x8000
	//	R#12 = 0
	ld		a, [ _vdp_port1 ]
	ld		c, a
	ld		de, 0 | ((0x80 + 12) << 8)
	di
	out		(c), e
	out		(c), d
	//	R#17 = 32
	ld		de, 32 | ((0x80 + 17) << 8)
	out		(c), e
	out		(c), d
	inc		c
	inc		c
	//	ADDRESS (R#32, R#33, R#34, R#35) = n * 896 + 0x18000
	out		(c), l
	out		(c), h
	ld		a, 1
	out		(c), a
	dec		a
	out		(c), a
	//	DX (R#36, R#37) = 0
	out		(c), a
	out		(c), a
	//	DY (R#38, R#39) = 256 + 128 + 16 + 32
	ld		de, 256 + 128 + 16 + 32
	out		(c), e
	out		(c), d
	//	NX (R#40, R#41) = 224 >> 3
	ld		e, 224 >> 3
	out		(c), e								//	ここに書き込むと暗転する、なぜ！？
	out		(c), a
	//	NY (R#42, R#43) = 32
	ld		e, 32
	out		(c), e
	out		(c), a
	//	CLR (R#44) = 15
	ld		e, 15
	out		(c), e
	//	ARG (R#45) = 0
	out		(c), a
	//	CMD (R#46) = 0x10
	ld		e, 0x10				//	run LFMM
	ei
	out		(c), e
	#endasm
}

// --------------------------------------------------------------------
void scroll_message( void ) {

	wait_vdp_command();

	#asm
	//	R#17 = 32
	ld		a, [ _vdp_port1 ]
	ld		c, a
	ld		de, 32 | ((0x80 + 17) << 8)
	di
	out		(c), e
	out		(c), d
	inc		c
	inc		c
	//	SX (R#32, R#33) = 0
	xor		a
	out		(c), a
	out		(c), a
	//	SY (R#34, R#35) = 256 + 128 + 16 + 1
	ld		de, 256 + 128 + 16 + 1
	out		(c), e
	out		(c), d
	//	DX (R#36, R#37) = 0
	out		(c), a
	out		(c), a
	//	DY (R#38, R#39) = 256 + 16
	dec		de
	out		(c), e
	out		(c), d
	//	NX (R#40, R#41) = 224
	ld		e, 224
	out		(c), e
	out		(c), a
	//	NY (R#42, R#43) = 63
	ld		e, 63
	out		(c), e
	out		(c), a
	//	CLR (R#44) = 0
	out		(c), a
	//	ARG (R#45) = 0
	out		(c), a
	//	CMD (R#46) = 0xD0
	ld		e, 0xD0				//	run HMMM
	ei
	out		(c), e
	#endasm
}

// --------------------------------------------------------------------
void background_scroll( void ) {

	scroll_x = (scroll_x + 2) & 255;
	scroll_y = (scroll_y + 1) & 255;

	//	背景スクロール
	vdp_write_reg( 23, scroll_y );
	vdp_write_reg( 26, scroll_x >> 3 );
	vdp_write_reg( 27, (scroll_x & 7) ^ 7 );
}

// --------------------------------------------------------------------
void background_scroll_finish( void ) {

	if( scroll_x ) scroll_x--;
	if( scroll_y ) scroll_y--;

	//	背景スクロール
	vdp_write_reg( 23, scroll_y );
	vdp_write_reg( 26, scroll_x >> 3 );
	vdp_write_reg( 27, (scroll_x & 7) ^ 7 );
}

// --------------------------------------------------------------------
void background_rotate( void ) {

}

// --------------------------------------------------------------------
int random( void ) {
	static unsigned int seed = 19739;

	seed = (seed ^ 0x8412) + 1917;
	return (int) seed;
}

// --------------------------------------------------------------------
void fill_rectangle_sub() {
	int sx, sy, nx, ny;

	sx = random() & 255;
	sy = random() & 255;
	nx = (random() & 255) | 1;
	ny = (random() & 255) | 1;
	if( (sy + ny) >= 256 ) {
		ny = 256 - sy;
	}
	fill_rectangle( sx, sy, nx, ny, random() & 15 );
}

// --------------------------------------------------------------------
void background_fill( void ) {

	fill_rectangle_sub();
	fill_rectangle_sub();
	fill_rectangle_sub();
}

// --------------------------------------------------------------------
int message_animation( void ) {
	static int result = 0;

	if( message_state < 32 ) {
		scroll_message();
		message_state++;
		result = 0;
	}
	else if( message_state == 32 ) {
		if( get_cursor_key() == 0 ) {
			result = 1;
		}
	}
	return result;
}

// --------------------------------------------------------------------
void puts_fighter( void ) {
	static int count1 = 8;
	static int count2 = 12;

	//	スプライト（うさぎファイター）
	if( mag ) {
		set_vram_write_address( 1, 0x0000 + 0 * 8 );
		put_usagi_mag( rabbit1, &shadow_mag[0], x1, 0, pattern1 );
		set_vram_write_address( 1, 0x0000 + 4 * 8 );
		put_usagi_mag( rabbit2, &shadow_mag[1], x2, 1, pattern2 );
		set_vram_write_address( 1, 0x0000 + 8 * 8 );
		put_shadow_mag();
	}
	else {
		set_vram_write_address( 1, 0x0000 + 0 * 8 );
		put_usagi( rabbit1, &shadow[0], x1, 0, pattern1 );
		set_vram_write_address( 1, 0x0000 + 4 * 8 );
		put_usagi( rabbit2, &shadow[1], x2, 1, pattern2 );
		set_vram_write_address( 1, 0x0000 + 8 * 8 );
		put_shadow();
	}

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
		p_state = state_dot_by_dot;
		put_message( 0 );
	}
	set_vram_write_address( 1, 0x0000 + 24 * 8 );
	for( i = 0; i < 8; i++ ) {
		outp( port, *p );
		p++;
	}
	background_scroll();
	message_animation();
}

// --------------------------------------------------------------------
void state_dot_by_dot( void ) {
	int key;

	wait_vsync( 1 );
	background_scroll();
	puts_fighter();

	if( !message_animation() ) {
		return;
	}
	
	key = get_cursor_key();
	if( key & KEY_DOWN ) {
		//	次のステートへ
		p_state = state_size_select;
		put_message( 1 );
	}
}

// --------------------------------------------------------------------
void state_size_select( void ) {
	int key;
	static int count = 10;
	static int size = 0;
	static int mgy = 16;

	wait_vsync( 1 );
	background_scroll();
	puts_fighter();

	count--;
	if( count == 0 ) {
		count = 10;
		rabbit1[0].y = 31 | size;
		rabbit1[0].mgy = mgy;
		size = size + 0x4000;
		mgy = (mgy == 128) ? 16: (mgy << 1);
		rabbit1[1].y = 31 | size;
		rabbit1[1].mgy = mgy;
		size = size + 0x4000;
		mgy = (mgy == 128) ? 16: (mgy << 1);
		rabbit1[2].y = 31 | size;
		rabbit1[2].mgy = mgy;
		size = size + 0x4000;
		mgy = (mgy == 128) ? 16: (mgy << 1);
		rabbit1[3].y = 31 | size;
		rabbit1[3].mgy = mgy;
	}

	if( !message_animation() ) {
		return;
	}
	
	key = get_cursor_key();
	if( key & KEY_DOWN ) {
		rabbit1[0].y = 31 | 0xC000;
		rabbit1[0].mgy = 128;
		rabbit1[1].y = 31 | 0xC000;
		rabbit1[1].mgy = 128;
		rabbit1[2].y = 31 | 0xC000;
		rabbit1[2].mgy = 128;
		rabbit1[3].y = 31 | 0xC000;
		rabbit1[3].mgy = 128;
		//	次のステートへ
		p_state = state_transparent;
		put_message( 2 );
	}
}

// --------------------------------------------------------------------
void state_transparent( void ) {
	int key;
	static int count = 10;
	static int mode = 1;

	wait_vsync( 1 );
	background_scroll();
	puts_fighter();

	count--;
	if( count == 0 ) {
		count = 10;
		rabbit1[0].mode = mode;
		rabbit1[1].mode = mode;
		rabbit1[2].mode = mode;
		rabbit1[3].mode = mode;
		mode = mode + 0x40;
	}

	if( !message_animation() ) {
		return;
	}
	
	key = get_cursor_key();
	if( key & KEY_DOWN ) {
		rabbit1[0].mode = 1;
		rabbit1[1].mode = 1;
		rabbit1[2].mode = 1;
		rabbit1[3].mode = 1;
		//	次のステートへ
		p_state = state_magnify;
		put_message( 3 );
	}
}

// --------------------------------------------------------------------
void state_magnify( void ) {
	int key;
	int i;

	wait_vsync( 1 );
	background_scroll();
	mag = 1;
	puts_fighter();

	if( !message_animation() ) {
		return;
	}
	
	key = get_cursor_key();
	if( key & KEY_DOWN ) {
		mag = 0;
		for( i = 0; i < 4; i++ ) {
			rabbit1[i].y		= 31 | 0xC000;
			rabbit1[i].mgy		= 128;
			rabbit1[i].mgx		= 16;
			rabbit2[i].y		= 31 | 0xC000;
			rabbit2[i].mgy		= 128;
			rabbit2[i].mgx		= 16;
		}
		//	次のステートへ
		p_state = state_maximum_puts;
		put_message( 4 );
	}
}

// --------------------------------------------------------------------
void state_maximum_puts( void ) {
	int key;

	wait_vsync( 1 );
	background_scroll();
	puts_fighter();

	if( !message_animation() ) {
		return;
	}
	
	key = get_cursor_key();
	if( key & KEY_DOWN ) {
		//	次のステートへ
		p_state = state_all_screen;
		put_message( 5 );
	}
}

// --------------------------------------------------------------------
void state_all_screen( void ) {
	int key;

	wait_vsync( 1 );
	background_scroll();
	puts_fighter();

	if( !message_animation() ) {
		return;
	}
	
	key = get_cursor_key();
	if( key & KEY_DOWN ) {
		//	次のステートへ
		p_state = state_color;
		put_message( 6 );
	}
}

// --------------------------------------------------------------------
void state_color( void ) {
	int key;

	wait_vsync( 1 );
	background_scroll();
	puts_fighter();
	set_sprite_fade_palette();

	if( !message_animation() ) {
		return;
	}
	
	key = get_cursor_key();
	if( key & KEY_DOWN ) {
		set_sprite_palette();
		//	次のステートへ
		p_state = state_reverse;
		put_message( 7 );
	}
}

// --------------------------------------------------------------------
void state_reverse( void ) {
	static int count = 10;
	static int reverse = 1;
	int key;

	wait_vsync( 1 );
	background_scroll();
	puts_fighter();

	count--;
	if( count == 0 ) {
		count = 10;
		if( reverse ) {
			rabbit1[0].mode |= 0x20;
			rabbit1[1].mode |= 0x20;
			rabbit1[2].mode |= 0x20;
			rabbit1[3].mode |= 0x20;
		}
		else {
			rabbit1[0].mode &= 0xDF;
			rabbit1[1].mode &= 0xDF;
			rabbit1[2].mode &= 0xDF;
			rabbit1[3].mode &= 0xDF;
		}
		reverse ^= 1;
	}

	if( !message_animation() ) {
		return;
	}
	
	key = get_cursor_key();
	if( key & KEY_DOWN ) {
		rabbit1[0].mode &= 0xDF;
		rabbit1[1].mode &= 0xDF;
		rabbit1[2].mode &= 0xDF;
		rabbit1[3].mode &= 0xDF;
		//	次のステートへ
		p_state = state_patterns;
		put_message( 8 );
	}
}

// --------------------------------------------------------------------
void state_patterns( void ) {
	int key;

	wait_vsync( 1 );
	background_scroll_finish();
	puts_fighter();

	if( !message_animation() ) {
		return;
	}
	
	key = get_cursor_key();
	if( key & KEY_DOWN ) {
		//	次のステートへ
		p_state = state_easy;
		put_message( 9 );
	}
}

// --------------------------------------------------------------------
void state_easy( void ) {
	int key;

	wait_vsync( 1 );
	background_rotate();
	puts_fighter();

	if( !message_animation() ) {
		return;
	}
	
	key = get_cursor_key();
	if( key & KEY_DOWN ) {
		//	次のステートへ
		p_state = state_highspeed_command;
		put_message( 10 );
	}
}

// --------------------------------------------------------------------
void state_highspeed_command( void ) {
	int key;

	wait_vsync( 1 );
	background_fill();
	puts_fighter();

	if( !message_animation() ) {
		return;
	}
	
	key = get_cursor_key();
	if( key & KEY_DOWN ) {
		//	次のステートへ
		p_state = state_font_command;
		put_message( 11 );
	}
}

// --------------------------------------------------------------------
void state_font_command( void ) {
	int key;

	wait_vsync( 1 );
	background_rotate();
	puts_fighter();

	if( !message_animation() ) {
		return;
	}
	
	key = get_cursor_key();
	if( key & KEY_DOWN ) {
		//	次のステートへ
		p_state = state_end;
		fill_rectangle( 0, 256 + 128 + 16 + 32, 224, 32, 0 );
		message_state = 0;
	}
}

// --------------------------------------------------------------------
void state_end( void ) {
	int key;

	wait_vsync( 1 );
	background_rotate();
	if( !message_animation() ) {
		return;
	}
	
	key = get_cursor_key();
	if( key & KEY_DOWN ) {
		//	終わる
		run_demo = 0;
	}
}

// --------------------------------------------------------------------
int main() {
	int x, y;

	initializer();
	p_state = state_window_animation;
	run_demo = 1;

	while( run_demo ) {
		p_state();
	}

	terminator();
	return 0;
}
