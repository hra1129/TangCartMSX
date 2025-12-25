// --------------------------------------------------------------------
//	SCREEN0(W40) Sprite mode1 and left mask test
// ====================================================================
//	Programmed by t.hara
// --------------------------------------------------------------------

#include <stdio.h>
#include <stdlib.h>
#include "v9968.h"

static unsigned char palette[] = {
	0x00, 0x00, 0x11, 0x01, 
	0x33, 0x03, 0x31, 0x02, 
	0x16, 0x04, 0x25, 0x03, 
	0x21, 0x02, 0x13, 0x02, 
	0x10, 0x01, 0x63, 0x06, 
	0x63, 0x03, 0x52, 0x04, 
	0x24, 0x04, 0x10, 0x00, 
	0x63, 0x02, 0x77, 0x07
};

static unsigned char buffer[4096];
static unsigned int read_s;

// --------------------------------------------------------------------
void load( void ) {
	FILE *p_file;
	unsigned int s;

	p_file = fopen( "A1MAN.BIN", "rb" );
	s = 256 * 212;
	while( s ) {
		read_s = s;
		if( read_s > sizeof(buffer) ) {
			read_s = sizeof(buffer);
		}
		fread( buffer, read_s, 1, p_file );
		#asm
		ld		c, vdp_port1
		di
		inc		c
		inc		c
		ld		hl, _buffer
		ld		de, (_read_s)
	loop:
		outi
		dec		de
		ld		a, e
		or		d
		jp		nz, loop
		ei
		#endasm
		s -= read_s;
	}
}

// --------------------------------------------------------------------
int main( int argc, char *argv[] ) {
	int i, j;

	v9968_set_screen7();
	#asm
	//	set background color
	ld		c, vdp_port1
	di
	xor		a
	out		(c), a
	ld		a, 0x80 + 7
	out		(c), a
	//	set palette
	xor		a
	out		(c), a
	ld		a, 0x80 + 16
	out		(c), a
	ld		hl, _palette
	ld		b, 32
	inc		c
	otir
	dec		c
	//	LMCM Å® STOP
	ld		a, 0xA0
	out		(c), a
	ld		a, 0x80 + 46
	out		(c), a
	xor		a
	out		(c), a
	ld		a, 0x80 + 46
	out		(c), a
	//	HMMC
	ld		a, 36
	out		(c), a
	ld		a, 0x80 + 17
	out		(c), a
	inc		c
	inc		c
	xor		a
	out		(c), a			//	DX = 0
	out		(c), a
	out		(c), a			//	DY = 0
	out		(c), a
	out		(c), a			//	NX = 0 (512)
	out		(c), a
	ld		hl, 212
	out		(c), l			//	NY = 212
	out		(c), h
	dec		c
	dec		c
	ld		b, 0x80 + 45
	out		(c), a			//	ARG
	out		(c), b
	ld		a, 0xF0
	inc		b
	out		(c), a			//	CMD
	out		(c), b
	ld		a, 0x80 + 44
	ld		b, 0x80 + 17
	out		(c), a
	out		(c), b
	ei
	#endasm
	
	load();
	v9968_wait_key();
	v9968_exit();
	return 0;
}
