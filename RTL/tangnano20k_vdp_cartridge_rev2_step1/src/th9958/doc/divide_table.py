#!/usr/bin/env python3
# -*- coding=utf-8 -*-

def main():
	with open( "divide_table.v", "w" ) as f:
		f.write( "case( divide_sel )\n" )
		for i in range( 0, 128 ):
			d = (int( 65536 / ( i + 128 ) ) - 256) % 256
			f.write( f"  7'd{i}:\t\tff_divide_coeff = 8'd{d};\n" )
		f.write( "endcase\n" )

if __name__ == "__main__":
	main()
