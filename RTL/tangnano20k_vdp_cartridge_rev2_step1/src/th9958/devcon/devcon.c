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

static signed short rotate[] = {
	0, 1235, 256, 0,
	-3, 1231, 255, 6,
	-6, 1228, 255, 12,
	-8, 1225, 255, 18,
	-10, 1221, 254, 25,
	-12, 1218, 254, 31,
	-15, 1215, 253, 37,
	-17, 1211, 252, 43,
	-19, 1208, 251, 49,
	-21, 1204, 249, 56,
	-22, 1200, 248, 62,
	-24, 1197, 246, 68,
	-26, 1193, 244, 74,
	-27, 1189, 243, 80,
	-29, 1185, 241, 86,
	-30, 1182, 238, 92,
	-31, 1178, 236, 97,
	-32, 1174, 234, 103,
	-33, 1170, 231, 109,
	-34, 1166, 228, 115,
	-35, 1162, 225, 120,
	-36, 1158, 222, 126,
	-37, 1154, 219, 131,
	-37, 1150, 216, 136,
	-38, 1146, 212, 142,
	-38, 1142, 209, 147,
	-38, 1138, 205, 152,
	-38, 1134, 201, 157,
	-38, 1130, 197, 162,
	-38, 1126, 193, 167,
	-38, 1122, 189, 171,
	-38, 1117, 185, 176,
	-38, 1113, 181, 181,
	-37, 1109, 176, 185,
	-37, 1105, 171, 189,
	-36, 1101, 167, 193,
	-35, 1097, 162, 197,
	-35, 1093, 157, 201,
	-34, 1089, 152, 205,
	-33, 1086, 147, 209,
	-32, 1082, 142, 212,
	-30, 1078, 136, 216,
	-29, 1074, 131, 219,
	-28, 1070, 126, 222,
	-26, 1066, 120, 225,
	-25, 1063, 115, 228,
	-23, 1059, 109, 231,
	-21, 1055, 103, 234,
	-19, 1052, 97, 236,
	-17, 1048, 92, 238,
	-15, 1044, 86, 241,
	-13, 1041, 80, 243,
	-11, 1038, 74, 244,
	-9, 1034, 68, 246,
	-6, 1031, 62, 248,
	-4, 1028, 56, 249,
	-1, 1025, 49, 251,
	1, 1021, 43, 252,
	4, 1018, 37, 253,
	7, 1015, 31, 254,
	10, 1012, 25, 254,
	12, 1010, 18, 255,
	15, 1007, 12, 255,
	18, 1004, 6, 255,
	22, 1002, 0, 256,
	25, 999, -7, 255,
	28, 996, -13, 255,
	31, 994, -19, 255,
	35, 992, -26, 254,
	38, 990, -32, 254,
	41, 987, -38, 253,
	45, 985, -44, 252,
	48, 983, -50, 251,
	52, 981, -57, 249,
	56, 980, -63, 248,
	59, 978, -69, 246,
	63, 976, -75, 244,
	67, 975, -81, 243,
	71, 973, -87, 241,
	74, 972, -93, 238,
	78, 971, -98, 236,
	82, 970, -104, 234,
	86, 969, -110, 231,
	90, 968, -116, 228,
	94, 967, -121, 225,
	98, 966, -127, 222,
	102, 965, -132, 219,
	106, 965, -137, 216,
	110, 964, -143, 212,
	114, 964, -148, 209,
	118, 964, -153, 205,
	122, 964, -158, 201,
	126, 964, -163, 197,
	130, 964, -168, 193,
	134, 964, -172, 189,
	139, 964, -177, 185,
	143, 964, -182, 181,
	147, 965, -186, 176,
	151, 965, -190, 171,
	155, 966, -194, 167,
	159, 967, -198, 162,
	163, 967, -202, 157,
	167, 968, -206, 152,
	170, 969, -210, 147,
	174, 970, -213, 142,
	178, 972, -217, 136,
	182, 973, -220, 131,
	186, 974, -223, 126,
	190, 976, -226, 120,
	193, 977, -229, 115,
	197, 979, -232, 109,
	201, 981, -235, 103,
	204, 983, -237, 97,
	208, 985, -239, 92,
	212, 987, -242, 86,
	215, 989, -244, 80,
	218, 991, -245, 74,
	222, 993, -247, 68,
	225, 996, -249, 62,
	228, 998, -250, 56,
	231, 1001, -252, 49,
	235, 1003, -253, 43,
	238, 1006, -254, 37,
	241, 1009, -255, 31,
	244, 1012, -255, 25,
	246, 1014, -256, 18,
	249, 1017, -256, 12,
	252, 1020, -256, 6,
	255, 1024, -256, 0,
	257, 1027, -256, -7,
	260, 1030, -256, -13,
	262, 1033, -256, -19,
	264, 1037, -255, -26,
	266, 1040, -255, -32,
	269, 1043, -254, -38,
	271, 1047, -253, -44,
	273, 1050, -252, -50,
	275, 1054, -250, -57,
	276, 1058, -249, -63,
	278, 1061, -247, -69,
	280, 1065, -245, -75,
	281, 1069, -244, -81,
	283, 1073, -242, -87,
	284, 1076, -239, -93,
	285, 1080, -237, -98,
	286, 1084, -235, -104,
	287, 1088, -232, -110,
	288, 1092, -229, -116,
	289, 1096, -226, -121,
	290, 1100, -223, -127,
	291, 1104, -220, -132,
	291, 1108, -217, -137,
	292, 1112, -213, -143,
	292, 1116, -210, -148,
	292, 1120, -206, -153,
	292, 1124, -202, -158,
	292, 1128, -198, -163,
	292, 1132, -194, -168,
	292, 1136, -190, -172,
	292, 1141, -186, -177,
	292, 1145, -182, -182,
	291, 1149, -177, -186,
	291, 1153, -172, -190,
	290, 1157, -168, -194,
	289, 1161, -163, -198,
	289, 1165, -158, -202,
	288, 1169, -153, -206,
	287, 1172, -148, -210,
	286, 1176, -143, -213,
	284, 1180, -137, -217,
	283, 1184, -132, -220,
	282, 1188, -127, -223,
	280, 1192, -121, -226,
	279, 1195, -116, -229,
	277, 1199, -110, -232,
	275, 1203, -104, -235,
	273, 1206, -98, -237,
	271, 1210, -93, -239,
	269, 1214, -87, -242,
	267, 1217, -81, -244,
	265, 1220, -75, -245,
	263, 1224, -69, -247,
	260, 1227, -63, -249,
	258, 1230, -57, -250,
	255, 1233, -50, -252,
	253, 1237, -44, -253,
	250, 1240, -38, -254,
	247, 1243, -32, -255,
	244, 1246, -26, -255,
	242, 1248, -19, -256,
	239, 1251, -13, -256,
	236, 1254, -7, -256,
	233, 1257, -1, -256,
	229, 1259, 6, -256,
	226, 1262, 12, -256,
	223, 1264, 18, -256,
	219, 1266, 25, -255,
	216, 1268, 31, -255,
	213, 1271, 37, -254,
	209, 1273, 43, -253,
	206, 1275, 49, -252,
	202, 1277, 56, -250,
	198, 1278, 62, -249,
	195, 1280, 68, -247,
	191, 1282, 74, -245,
	187, 1283, 80, -244,
	183, 1285, 86, -242,
	180, 1286, 92, -239,
	176, 1287, 97, -237,
	172, 1288, 103, -235,
	168, 1289, 109, -232,
	164, 1290, 115, -229,
	160, 1291, 120, -226,
	156, 1292, 126, -223,
	152, 1293, 131, -220,
	148, 1293, 136, -217,
	144, 1294, 142, -213,
	140, 1294, 147, -210,
	136, 1294, 152, -206,
	132, 1294, 157, -202,
	128, 1294, 162, -198,
	124, 1294, 167, -194,
	120, 1294, 171, -190,
	115, 1294, 176, -186,
	111, 1294, 181, -182,
	107, 1293, 185, -177,
	103, 1293, 189, -172,
	99, 1292, 193, -168,
	95, 1291, 197, -163,
	91, 1291, 201, -158,
	87, 1290, 205, -153,
	84, 1289, 209, -148,
	80, 1288, 212, -143,
	76, 1286, 216, -137,
	72, 1285, 219, -132,
	68, 1284, 222, -127,
	64, 1282, 225, -121,
	61, 1281, 228, -116,
	57, 1279, 231, -110,
	53, 1277, 234, -104,
	50, 1275, 236, -98,
	46, 1273, 238, -93,
	42, 1271, 241, -87,
	39, 1269, 243, -81,
	36, 1267, 244, -75,
	32, 1265, 246, -69,
	29, 1262, 248, -63,
	26, 1260, 249, -57,
	23, 1257, 251, -50,
	19, 1255, 252, -44,
	16, 1252, 253, -38,
	13, 1249, 254, -32,
	10, 1246, 254, -26,
	8, 1244, 255, -19,
	5, 1241, 255, -13,
	2, 1238, 255, -7,
};

static int x1 = -64;
static int pattern1 = 0;

static int x2 = 256;
static int pattern2 = 0;

static int run_demo = 0;
static int message_state = 32;
static int mag = 0;
static int scroll_x = 0, scroll_y = 0;
static int theta = 0;

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
void rotate_copy( void ) {

	wait_vdp_command();

	#asm
	ld		a, (_vdp_port1)
	ld		c, a

	ld		hl, (_theta)
	add		hl, hl			//	sizeof(signed short) = 2 の 2倍
	add		hl, hl			//	4要素あるので 4倍
	add		hl, hl
	ld		de, _rotate + 7
	add		hl, de
	//	VX, VY
	//	R#17 = 47
	ld		a, 47
	di
	out		(c), a
	ld		a, 0x80 + 17
	out		(c), a
	inc		c
	inc		c
	ld		b, (hl)			//	VY High
	dec		hl
	ld		a, (hl)			//	VY Low
	dec		hl
	ld		d, (hl)			//	VX High
	dec		hl
	ld		e, (hl)			//	VX Low
	dec		hl
	out		(c), e
	out		(c), d
	out		(c), a
	out		(c), b
	//	SX, SY
	//	R#17 = 32
	dec		c
	dec		c
	ld		a, 32
	out		(c), a
	ld		a, 0x80 + 17
	out		(c), a
	inc		c
	inc		c
	ld		b, (hl)			//	SY High
	dec		hl
	ld		a, (hl)			//	SY Low
	dec		hl
	ld		d, (hl)			//	SX High
	dec		hl
	ld		e, (hl)			//	SX Low
	out		(c), e
	out		(c), d
	out		(c), a
	out		(c), b
	//	DX, DY
	xor		a
	out		(c), a
	out		(c), a
	out		(c), a
	out		(c), a
	//	NX, NY
	ld		de, 256			//	NX
	out		(c), e
	out		(c), d
	ld		de, 212			//	NY
	out		(c), e
	out		(c), d
	//	COLOR, ARG, CMD
	out		(c), a			//	COLOR
	out		(c), a			//	ARG
	ld		a, 0x30			//	CMD: LRMM, IMP
	ei
	out		(c), a
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
	if( scroll_x || scroll_y ) {
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

	rotate_copy();
	theta = (theta + 1) & 255;

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

	rotate_copy();
	theta = (theta + 2) & 255;

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

	rotate_copy();
	theta = (theta - 3) & 255;

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
