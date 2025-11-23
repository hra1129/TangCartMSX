// ====================================================================
//	MSX VDP Controll
// --------------------------------------------------------------------
//	Programmed by t.hara
// ====================================================================

#include <msx_vdp.h>
#include <stdio.h>

unsigned char vdp_port1 = 0x99;

static unsigned char s_buffer[ 2048 ];

// --------------------------------------------------------------------
void _di( void ) {
#asm
	di
#endasm
}

// --------------------------------------------------------------------
void _ei( void ) {
#asm
	ei
#endasm
}

// --------------------------------------------------------------------
int init_vdp( void ) {
	int id;

	//	まず本体内を調べる
	vdp_port1 = 0x99;
	_di();
	vdp_write_reg( 21, 0x3A );
	vdp_write_reg( 15, 1 );
	id = (vdp_read_stat() >> 1) & 0x1F;
	vdp_write_reg( 15, 0 );
	vdp_write_reg( 21, 0x3B );
	_ei();
	if( id >= 3 ) {
		return 1;
	}
	//	拡張スロットを調べる
	vdp_port1 = 0x89;
	_di();
	vdp_write_reg( 21, 0x3A );
	vdp_write_reg( 15, 1 );
	id = (vdp_read_stat() >> 1) & 0x1F;
	vdp_write_reg( 15, 0 );
	vdp_write_reg( 21, 0x3B );
	_ei();
	if( id >= 3 ) {
		return 1;
	}
	vdp_port1 = 0x99;
	return 0;
}

// --------------------------------------------------------------------
void set_screen5( void ) {
	static unsigned char reg_data[] = {
		0, 0x06,		//	Mode0
		1, 0x00,		//	Mode1
		2, 0x1F,		//	Pattern Name Table = Page0
		5, 0xEF,		//	Sprite Attribute Table(L)
		6, 0x0F,		//	Sprite Pattern Generator
		7, 0x07,		//	Background Color
		8, 0x0A,		//	Mode2
		9, 0x80,		//	Mode3
		11, 0,			//	Sprite Attribute Table(H)
		18, 0,			//	Set Adjust
		19, 0,			//	Interrupt line
		20, 0xFF,		//	Mode5
		21, 0,			//	Mode6
		23, 0,			//	Display Offset
		25, 0,			//	Mode4
		26, 0,			//	Horizontal Offset by character
		27, 0,			//	Horizontal Offset by dot
		255
	};
	unsigned char *p;

	_di();
	for( p = reg_data; p[0] != 255; p += 2 ) {
		vdp_write_reg( p[0], p[1] );
	}
	_ei();
}

// --------------------------------------------------------------------
void bload( const char *p_name ) {
	FILE *p_file;
	unsigned int start, end, size, block_size;
	int i, port;
	unsigned char *p;

	p_file = fopen( p_name, "rb" );
	if( p_file == NULL ) {
		//	failed
		return;
	}
	fread( s_buffer, 7, 1, p_file );
	start	= (int)s_buffer[1] | ((int)s_buffer[2] << 8);
	end		= (int)s_buffer[3] | ((int)s_buffer[4] << 8);
	size	= end - start + 1;
	port = vdp_port1 - 1;
	while( size ) {
		if( size > sizeof(s_buffer) ) {
			block_size = sizeof(s_buffer);
		}
		else {
			block_size = size;
		}
		fread( s_buffer, block_size, 1, p_file );
		p = s_buffer;
		size -= block_size;
		while( block_size ) {
			outp( port, *p );
			p++;
			block_size--;
		}
	}
	fclose( p_file );
}

// --------------------------------------------------------------------
void set_display_visible( int visible ) {

	_di();
	if( visible ) {
		//	visible
		vdp_write_reg( 1, 0x40 );
	}
	else {
		//	invisible
		vdp_write_reg( 1, 0x00 );
	}
	_ei();
}

// --------------------------------------------------------------------
void wait_vsync( int n ) {

	_di();
	while( n ) {
		while( (inp( vdp_port1 ) & 0x80) == 0 );
		n--;
	}
	_ei();
}

// --------------------------------------------------------------------
void set_vram_write_address( int bank, int address ) {

	_di();
	vdp_write_reg( 14, ((bank & 3) << 2) | ((address >> 14) & 0x03) );
	outp( vdp_port1, address & 0xFF );
	outp( vdp_port1, ((address >> 8) & 0x3F) | 0x40 );
	_ei();
}
