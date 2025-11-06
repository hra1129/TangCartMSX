// --------------------------------------------------------------------
//	V9968 common
// ====================================================================
//	Copyright 2025 t.hara (HRA!)
// --------------------------------------------------------------------

#include <stdio.h>
#include <stdlib.h>
#include "v9968_common.h"

static int di_count = 0;

#pragma pack(1)
typedef struct {
	unsigned char	signature;
	unsigned short	start;
	unsigned short	end;
	unsigned short	execute;
} BSAVE_HEADER_T;

static unsigned char s_buffer[ 1024 ];

// --------------------------------------------------------------------
//	v9968_nested_di()
// --------------------------------------------------------------------
void v9968_nested_di( void ) {

	#asm
		di
	#endasm

	di_count++;
}

// --------------------------------------------------------------------
//	v9968_nested_ei()
// --------------------------------------------------------------------
void v9968_nested_ei( void ) {

	if( di_count == 0 ) return;
	di_count--;
	if( di_count == 0 ) {
		#asm
			ei
		#endasm
	}
}

// --------------------------------------------------------------------
//	v9968_write_vdp()
//	input
//		reg ..... control register number
//		value ... value
// --------------------------------------------------------------------
void v9968_write_vdp( unsigned char reg, unsigned char value ) {

	v9968_nested_di();
	outp( vdp_port1, value );
	outp( vdp_port1, reg | 0x80 );
	v9968_nested_ei();
}

// --------------------------------------------------------------------
//	v9968_set_write_vram_address()
//	input
//		address_l ... 0x0000-0xFFFF
//		address_h ... 0-3
// --------------------------------------------------------------------
void v9968_set_write_vram_address( unsigned short address_l, unsigned char address_h ) {

	v9968_nested_di();
	v9968_write_vdp( 14, (address_l >> 14) | (address_h << 3) );
	outp( vdp_port1, address_l & 0xFF );
	outp( vdp_port1, ((unsigned char)(address_l >> 8) & 0x3F) | 0x40 );
	v9968_nested_ei();
}

// --------------------------------------------------------------------
//	v9968_set_read_vram_address()
//	input
//		address_l ... 0x0000-0xFFFF
//		address_h ... 0-3
// --------------------------------------------------------------------
void v9968_set_read_vram_address( unsigned short address_l, unsigned char address_h ) {

	v9968_nested_di();
	v9968_write_vdp( 14, (address_l >> 14) | (address_h << 3) );
	outp( vdp_port1, address_l & 0xFF );
	outp( vdp_port1, (address_l >> 8) & 0x3F );
	v9968_nested_ei();
}

// --------------------------------------------------------------------
//	v9968_write_vram()
//	input
//		value ... write data
// --------------------------------------------------------------------
void v9968_write_vram( unsigned char value ) {

	outp( vdp_port0, value );
}

// --------------------------------------------------------------------
//	v9968_read_vram()
//	result:
//		read data
// --------------------------------------------------------------------
unsigned char v9968_read_vram( void ) {

	return inp( vdp_port0 );
}

// --------------------------------------------------------------------
//	v9968_read_vdp_status()
//	input:
//		reg ..... status register number
//	result:
//		read data
// --------------------------------------------------------------------
unsigned char v9968_read_vdp_status( unsigned char reg ) {
	unsigned char r;

	v9968_nested_di();
	v9968_write_vdp( 15, reg );
	r = inp( vdp_port1 );
	v9968_write_vdp( 15, 0 );
	v9968_nested_ei();
	return r;
}

// --------------------------------------------------------------------
//	v9968_fill_vram()
//	input:
//		address ... target address
//		value ..... fill byte
//		size ...... size
// --------------------------------------------------------------------
void v9968_fill_vram( unsigned short address, unsigned char value, unsigned short size ) {
	unsigned short i;

	v9968_set_write_vram_address( address, 0 );
	for( i = 0; i < size; i++ ) {
		outp( vdp_port0, value );
	}
}

// --------------------------------------------------------------------
//	v9968_copy_to_vram()
//	input:
//		destination ... target address (VRAM)
//		p_source ...... source data address (CPU-Memory)
//		size .......... size
// --------------------------------------------------------------------
void v9968_copy_to_vram( unsigned short destination, const void *p_source, unsigned short size ) {
	unsigned short i;

	v9968_set_write_vram_address( destination, 0 );
	for( i = 0; i < size; i++ ) {
		outp( vdp_port0, *p_source );
		p_source++;
	}
}

// --------------------------------------------------------------------
//	v9968_copy_from_vram()
//	input:
//		destination ... target address (VRAM)
//		p_source ...... source data address (CPU-Memory)
//		size .......... size
// --------------------------------------------------------------------
void v9968_copy_from_vram( const void *p_destination, unsigned short source, unsigned short size ) {
	unsigned short i;

	v9968_set_read_vram_address( source, 0 );
	for( i = 0; i < size; i++ ) {
		p_destination = inp( vdp_port0 );
		p_destination++;
	}
}

// --------------------------------------------------------------------
//	v9968_puts()
//	input:
//		p ........ string
// --------------------------------------------------------------------
void v9968_puts( const char *p ) {

	while( *p ) {
		outp( vdp_port0, *p );
		p++;
	}
}

// --------------------------------------------------------------------
//	v9968_exit()
//	input:
//		none
// --------------------------------------------------------------------
void v9968_exit( void ) {

	v9968_write_vdp(  0, 0x00 );
	v9968_write_vdp(  1, 0x40 );
	v9968_write_vdp(  2, 0x36 );
	v9968_write_vdp(  7, 0x07 );
	v9968_write_vdp(  8, 0x08 );
	v9968_write_vdp(  9, 0x00 );
	v9968_write_vdp( 14, 0x00 );
	v9968_write_vdp( 20, 0x00 );
	v9968_write_vdp( 21, 0x00 );
	v9968_write_vdp( 23, 0x00 );
	v9968_write_vdp( 25, 0x00 );
	v9968_write_vdp( 26, 0x00 );
	v9968_write_vdp( 27, 0x00 );
	v9968_write_vdp( 45, 0x00 );
	v9968_color_new();

	#asm
		ld		iy, [0xFCC1 - 1]
		ld		ix, 0x0156				//	kilbuf
		call	0x001c					//	calslt

		ld		a, 1
		ld		iy, [0xFCC1 - 1]
		ld		ix, 0x005F				//	chgmod
		call	0x001c					//	calslt

		xor		a
		ld		iy, [0xFCC1 - 1]
		ld		ix, 0x005F				//	chgmod
		call	0x001c					//	calslt
	#endasm
}

// --------------------------------------------------------------------
//	v9968_wait_vsync()
//	input:
//		none
// --------------------------------------------------------------------
void v9968_wait_vsync( void ) {

	v9968_nested_di();
	v9968_write_vdp( 15, 2 );
	while( !(inp( vdp_port1 ) & 0x40) );
	while( inp( vdp_port1 ) & 0x40 );
	v9968_write_vdp( 15, 0 );
	v9968_nested_ei();
}

// --------------------------------------------------------------------
//	v9968_get_key()
//	input:
//		none
//	result:
//		0x00 .... release
//		0xFF .... pressed
// --------------------------------------------------------------------
int v9968_get_key( void ) {
	#asm
		xor		a
		ld		iy, [0xFCC1 - 1]
		ld		ix, 0x00D8				//	kilbuf
		call	0x001c					//	calslt
		push	af

		ld		a, 1
		ld		iy, [0xFCC1 - 1]
		ld		ix, 0x00D8				//	kilbuf
		call	0x001c					//	calslt
		ei
		pop		bc
		or		a, b
		ld		h, 0
		ld		l, a
		ret
	#endasm
}

// --------------------------------------------------------------------
//	v9968_wait_key()
//	input:
//		none
//	result:
//		none
// --------------------------------------------------------------------
void v9968_wait_key( void ) {

	v9968_wait_vsync();
	v9968_wait_vsync();
	v9968_wait_vsync();
	while( v9968_get_key() );

	v9968_wait_vsync();
	v9968_wait_vsync();
	v9968_wait_vsync();
	while( !v9968_get_key() );
}

// --------------------------------------------------------------------
//	v9968_bload()
//	input:
//		s_file_name ... target file name
//	result:
//		1 .... success
//		0 .... error
// --------------------------------------------------------------------
static void _v9968_bload( FILE *p_file, unsigned short start, unsigned short size ) {
	unsigned short block, i, ptr;

	ptr = start;
	while( size ) {
		if( size > 1024 ) {
			block = 1024;
		}
		else {
			block = size;
		}
		fread( s_buffer, block, 1, p_file );
		size -= block;
		v9968_copy_to_vram( ptr, s_buffer, block );
		ptr += block;
	}
}

// --------------------------------------------------------------------
//	v9968_bload()
//	input:
//		s_file_name ... target file name
//	result:
//		1 .... success
//		0 .... error
// --------------------------------------------------------------------
char v9968_bload( const char *s_file_name ) {
	FILE *p_file;
	BSAVE_HEADER_T *p_header;
	unsigned short size;

	p_header = (BSAVE_HEADER_T*) s_buffer;

	p_file = fopen( s_file_name, "rb" );
	if( p_file == NULL ) {
		return 0;
	}
	p_header->signature = 0;
	fread( p_header, 7, 1, p_file );
	if( p_header->signature != 0xFE ) {
		fclose( p_file );
		return 0;
	}
	size = p_header->end - p_header->start + 1;
	_v9968_bload( p_file, p_header->start, size );
	fclose( p_file );
	return 1;
}

// --------------------------------------------------------------------
//	v9968_bload()
//	input:
//		s_file_name ... target file name
//	result:
//		1 .... success
//		0 .... error
// --------------------------------------------------------------------
char v9968_bload_to( const char *s_file_name, unsigned short start ) {
	FILE *p_file;
	BSAVE_HEADER_T *p_header;
	unsigned short size;

	p_header = (BSAVE_HEADER_T*) s_buffer;

	p_file = fopen( s_file_name, "rb" );
	if( p_file == NULL ) {
		return 0;
	}
	p_header->signature = 0;
	fread( p_header, 7, 1, p_file );
	if( p_header->signature != 0xFE ) {
		fclose( p_file );
		return 0;
	}
	size = p_header->end - p_header->start + 1;
	_v9968_bload( p_file, start, size );
	fclose( p_file );
	return 1;
}

// --------------------------------------------------------------------
//	v9968_color_restore()
//	input:
//		palette_address ... address of palette data on VRAM
//	result:
//		none
// --------------------------------------------------------------------
void v9968_color_restore( unsigned short palette_address ) {
	int i;

	v9968_write_vdp( 16, 0 );
	v9968_set_read_vram_address( palette_address, 0 );
	for( i = 0; i < 32; i++ ) {
		outp( vdp_port2, inp( vdp_port0 ) );
	}
}

// --------------------------------------------------------------------
//	v9968_color_new()
//	input:
//		none
//	result:
//		none
// --------------------------------------------------------------------
void v9968_color_new( void ) {
	int i;
	static const unsigned char init_palette[] = {
		0x00, 0x00,
		0x00, 0x00,
		0x11, 0x06,
		0x33, 0x07,
		0x17, 0x01,
		0x27, 0x03,
		0x51, 0x01,
		0x27, 0x06,
		0x71, 0x01,
		0x73, 0x03,
		0x61, 0x06,
		0x64, 0x06,
		0x11, 0x04,
		0x65, 0x02, 
		0x55, 0x05,
		0x77, 0x07,
	};
	v9968_write_vdp( 16, 0 );
	for( i = 0; i < sizeof(init_palette); i++ ) {
		outp( vdp_port2, init_palette[i] );
	}
}
