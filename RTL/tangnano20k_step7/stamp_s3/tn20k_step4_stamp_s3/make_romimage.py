#!/usr/bin/env python3
# coding=utf-8

import os

# ( ROM name, SDRAM address ), SDRAM address は 16KB単位 
target_list = [
	( "main"                 , 0x020000 ),
	( "basicn"               , 0x030000 ),
	( "rabbit_adventure"     , 0x204000 ),
	( "rabbit_adventure_demo", 0x204000 ),
	( "hello_world"          , 0x204000 ),
	( "stepper"              , 0x208000 ),
	( "super_cobra"          , 0x200000 ),
	( "kings_valley"         , 0x200000 ),
	( "dragon_quest2"        , 0x200000 ),
	( "gall_force"           , 0x200000 ),
	( "megarom_asc8"         , 0x200000 ),
]

s_rom_image_path = "./rom_image/"

# --------------------------------------------------------
def write_one_block( f_save, index, rom_image, s_rom_name, bank_id ):
	f_save.write( "\n" )
	f_save.write( "static const byte rom_%s_%02X[] = {\n" % (s_rom_name, index) )
	f_save.write( "\t0x04, 0x%02X, \n" % bank_id )
	l = len( rom_image )
	if l >= 16384:
		l = 16384
	for i in range( 0, l ):
		if (i % 16) == 0:
			f_save.write( "\t" )
		f_save.write( "0x%02X, " % rom_image[i] )
		if (i % 16) == 15:
			f_save.write( "\n" )
	f_save.write( "};\n" )

# --------------------------------------------------------
def save_rom_image( s_rom_name, address ):
	print( "%s => 0x%06X" % ( s_rom_name, address ) )
	s_target_file	= s_rom_image_path + s_rom_name + ".rom"
	s_save_file		= "romimage_" + s_rom_name + ".h"
	if not os.path.isfile( s_target_file ):
		print( "ERROR: Cannot find the '%s'." % s_target_file )
		exit(1)
	with open( s_target_file, "rb" ) as f_rom_image:
		rom_image = f_rom_image.read()
	with open( s_save_file, "wt" ) as f_save:
		f_save.write( "// --------------------------------------------------------------------\n" )
		f_save.write( "//  ROM Image File\n" )
		f_save.write( "//  ROM Name: %s\n" % s_target_file )
		f_save.write( "// --------------------------------------------------------------------\n" )
		index = 0
		bank_id = address // 16384
		while( len( rom_image ) > 0 ):
			write_one_block( f_save, index, rom_image, s_rom_name, bank_id )
			index = index + 1
			bank_id = bank_id + 1
			if len( rom_image ) >= 16384:
				rom_image = rom_image[16384:]
			else:
				rom_image = ()

# --------------------------------------------------------
def main():
	for target in target_list:
		save_rom_image( target[0], target[1] )

# --------------------------------------------------------
if __name__ == "__main__":
	main()
