#!/usr/bin/env python3
# coding=utf-8

import sys

# --------------------------------------------------------------------
def usage():
	print( "Usage> bin2v.py input.bin output.v" )

# --------------------------------------------------------------------
def main():
	# 引数チェック
	if len( sys.argv ) != 3:
		usage()
		return
	# 書き出し
	with open( sys.argv[2], "w" ) as f_out:
		f_out.write( """// -----------------------------------------------------------------------------
//	vram_image_rom.v
//	Copyright (C)2024 Takayuki Hara (HRA!)
//	
//	 Permission is hereby granted, free of charge, to any person obtaining a 
//	copy of this software and associated documentation files (the "Software"), 
//	to deal in the Software without restriction, including without limitation 
//	the rights to use, copy, modify, merge, publish, distribute, sublicense, 
//	and/or sell copies of the Software, and to permit persons to whom the 
//	Software is furnished to do so, subject to the following conditions:
//	
//	The above copyright notice and this permission notice shall be included in 
//	all copies or substantial portions of the Software.
//	
//	The Software is provided "as is", without warranty of any kind, express or 
//	implied, including but not limited to the warranties of merchantability, 
//	fitness for a particular purpose and noninfringement. In no event shall the 
//	authors or copyright holders be liable for any claim, damages or other 
//	liability, whether in an action of contract, tort or otherwise, arising 
//	from, out of or in connection with the Software or the use or other dealings 
//	in the Software.
// -----------------------------------------------------------------------------
//	Description:
//		Debugger
// -----------------------------------------------------------------------------

module vram_image_rom (
	input			clk,
	input	[13:0]	adr,
	output	[ 7:0]	dbi
);
	reg		[ 7:0]	ff_dbi1;
	reg		[ 7:0]	ff_dbi2;
	reg		[ 7:0]	ff_ram [0:16383];

	initial begin
""" )

		with open( sys.argv[1], "rb" ) as f_in:
			in_data = f_in.read( 16384 )

		address = 0
		for d in in_data:
			f_out.write( "\t\tff_ram[%d] = 8'h%02X;\n" % ( address, d ) )
			address = address + 1

		f_out.write( """	end

	always @( posedge clk ) begin
		ff_dbi1 <= ff_ram[ adr ];
		ff_dbi2 <= ff_dbi1;
	end

	assign dbi = ff_dbi2;
endmodule
""" )

# --------------------------------------------------------------------
if __name__ == "__main__":
	main()
