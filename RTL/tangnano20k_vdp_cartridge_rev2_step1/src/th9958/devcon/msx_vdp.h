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
void bload( const char *p_name, int address );
void set_display_visible( int visible );
void wait_vsync( int n );
void set_vram_write_address( int bank, int address );

#endif
