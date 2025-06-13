#!/usr/bin/env python3
# coding=utf-8

with open( "led_count.bin", "rb" ) as f:
	rom_image = f.read( 16384 )

with open( "ip_led_count_rom.v", "wt" ) as f:
	f.write( "// --------------------------------------------------------------------\n" )
	f.write( "// IP_led_count_ROM\n" )
	f.write( "// --------------------------------------------------------------------\n" )
	f.write( "\n" )
	f.write( "module ip_led_count_rom (\n" )
	f.write( "	input			clk,\n" )
	f.write( "	input			n_cs,\n" )
	f.write( "	input			n_rd,\n" )
	f.write( "	input	[13:0]	address,\n" )
	f.write( "	output	[7:0]	rdata,\n" )
	f.write( "	output			rdata_en\n" )
	f.write( ");\n" )
	f.write( "	reg		[7:0]	ff_rdata;\n" )
	f.write( "	reg				ff_rdata_en;\n" )
	f.write( "\n" )
	f.write( "	always @( posedge clk ) begin\n" )
	f.write( "		if( !n_cs && !n_rd ) begin\n" )
	f.write( "			case( address )\n" )

	i = 0
	for d in rom_image:
		f.write( "			14'd%d: ff_rdata <= 8'h%02X;\n" % ( i, d ) )
		i = i + 1
	f.write( "			default: ff_rdata <= 8'd0;\n" )
	f.write( "			endcase\n" )
	f.write( "			ff_rdata_en <= 1'b1;\n" )
	f.write( "		end\n" )
	f.write( "		else begin\n" )
	f.write( "			ff_rdata <= 8'd0;\n" )
	f.write( "			ff_rdata_en <= 1'b0;\n" )
	f.write( "		end\n" )
	f.write( "	end\n" )
	f.write( "\n" )
	f.write( "	assign rdata	= ff_rdata;\n" )
	f.write( "	assign rdata_en	= ff_rdata_en;\n" )
	f.write( "endmodule\n" )
