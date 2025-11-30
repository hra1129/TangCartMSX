// ====================================================================
//	MSX VDP Controll
// --------------------------------------------------------------------
//	Programmed by t.hara
// ====================================================================

#ifndef __MSX_VDP_H__
#define __MSX_VDP_H__

#include <stdlib.h>

extern unsigned char vdp_port1;

void _di( void );
void _ei( void );

#define vdp_write_reg( reg, dat )		outp( vdp_port1, (dat) ); outp( vdp_port1, (reg) | 0x80 )
#define vdp_read_stat()					inp( vdp_port1 )

#define MSX_FALSE	0
#define MSX_TRUE	1

int init_vdp( void );
void set_screen5( void );
void bload( const char *p_name );
void set_display_visible( int visible );
void wait_vsync( int n );
void set_vram_write_address( int bank, int address );
int get_cursor_key( void );
void wait_vdp_command( void );

#define KEY_SPACE	0x01
#define KEY_UP		0x20
#define KEY_DOWN	0x40
#define KEY_LEFT	0x10
#define KEY_RIGHT	0x80

#endif
