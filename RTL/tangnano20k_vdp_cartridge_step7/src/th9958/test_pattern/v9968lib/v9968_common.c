// --------------------------------------------------------------------
//	V9968 common
// ====================================================================
//	Copyright 2025 t.hara (HRA!)
// --------------------------------------------------------------------

#include <stdlib.h>

static const unsigned char vdp_port0 = 0x98;	//	TMS9918/V9938/V9958/V9968/V9978
static const unsigned char vdp_port1 = 0x99;	//	TMS9918/V9938/V9958/V9968/V9978
static const unsigned char vdp_port2 = 0x9A;	//	V9938/V9958/V9968/V9978
static const unsigned char vdp_port3 = 0x9B;	//	V9938/V9958/V9968/V9978
static const unsigned char vdp_port4 = 0x9C;	//	V9968/V9978

static int di_count = 0;

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
	outp( vdp_port1, ((address_l >> 8) & 0x3F) | 0x40 );
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
	v9968_write_vdp(  7, 0xF7 );
	v9968_write_vdp(  8, 0x02 );
	v9968_write_vdp(  9, 0x00 );
	v9968_write_vdp( 20, 0x00 );
	v9968_write_vdp( 21, 0x00 );
	v9968_write_vdp( 23, 0x00 );
	v9968_write_vdp( 25, 0x00 );
	v9968_write_vdp( 26, 0x00 );
	v9968_write_vdp( 27, 0x00 );
	v9968_write_vdp( 45, 0x00 );
	#asm
		ld		iy, [0xFCC1 - 1]
		ld		ix, 0x0156				//	kilbuf
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
