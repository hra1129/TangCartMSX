// --------------------------------------------------------------------
//	V9968 common
// ====================================================================
//	Copyright 2025 t.hara (HRA!)
// --------------------------------------------------------------------

#ifndef __V9968_COMMON_H__
#define __V9968_COMMON_H__

void v9968_nested_di( void );
void v9968_nested_ei( void );
void v9968_write_vdp( unsigned char reg, unsigned char value );
void v9968_set_write_vram_address( unsigned short address_l, unsigned char address_h );
void v9968_set_read_vram_address( unsigned short address_l, unsigned char address_h );
void v9968_write_vram( unsigned char value );
unsigned char v9968_read_vram( void );
unsigned char v9968_read_vdp_status( unsigned char reg );
void v9968_fill_vram( unsigned short address, unsigned char value, unsigned short size );
void v9968_copy_to_vram( unsigned short destination, const void *p_source, unsigned short size );
void v9968_copy_from_vram( const void *p_destination, unsigned short source, unsigned short size );
void v9968_puts( const char *p );
void v9968_exit( void );
void v9968_wait_vsync( void );
int v9968_get_key( void );
void v9968_wait_key( void );
char v9968_bload( const char *s_file_name );

#endif
