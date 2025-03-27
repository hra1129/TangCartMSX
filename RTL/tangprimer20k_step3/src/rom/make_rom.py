#!/usr/bin/env python3
# coding=utf-8

with open( "hello_world.bin", "rb" ) as f:
	rom_image = f.read( 16384 )

with open( "ip_hello_world_rom.v", "wt" ) as f:
	f.write( "// --------------------------------------------------------------------\n" )
	f.write( "// IP_HELLO_WORLD_ROM\n" )
	f.write( "// --------------------------------------------------------------------\n" )
	f.write( "\n" )
	f.write( "module ip_hello_world_rom (\n" )
	f.write( "	input			reset_n		,\n" )
	f.write( "	input			clk			,\n" )
	f.write( "	input	[15:0]	bus_address	,\n" )
	f.write( "	input			bus_memreq	,\n" )
	f.write( "	input			bus_valid	,\n" )
	f.write( "	output			bus_ready	,\n" )
	f.write( "	input			bus_write	,\n" )
	f.write( "	output	[7:0]	bus_rdata	,\n" )
	f.write( "	output			bus_rdata_en\n" )
	f.write( ");\n" )
	f.write( "	reg		[7:0]	ff_rdata;\n" )
	f.write( "	reg				ff_rdata_en;\n" )
	f.write( "\n" )
	f.write( "	always @( posedge clk ) begin\n" )
	f.write( "		if( !reset_n ) begin\n" )
	f.write( "			ff_rdata	<= 8'd0;\n" )
	f.write( "			ff_rdata_en	<= 1'b0;\n" )
	f.write( "		end\n" )
	f.write( "		else if( bus_address[15:13] == 3'b000 && bus_memreq && bus_valid && !bus_write ) begin\n" )

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
	f.write( "	assign rdata	= ff_rdata_en ? ff_rdata: 8'd0;\n" )
	f.write( "	assign rdata_en	= ff_rdata_en;\n" )
	f.write( "endmodule\n" )
