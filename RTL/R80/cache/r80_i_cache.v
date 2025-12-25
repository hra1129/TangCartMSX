// -----------------------------------------------------------------------------
//	r80_i_cache.v
//	Copyright (C)2025 Takayuki Hara (HRA!)
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

module r80_i_cache (
	input			clk,
	input			reset_n,
	input			flush,
	//	Read request I/F
	input	[25:0]	address,			//	[1:0] is always ZERO.
	input			address_valid,
	output			address_ready,
	//	Read result I/F
	output	[31:0]	data,
	output			data_valid,
	//	SDRAM I/F
	output	[25:0]	sdram_address,
	output			sdram_valid,
	input			sdram_ready,
	input	[31:0]	sdram_rdata,
	input			sdram_rdata_valid
);
	// --------------------------------------------------------------------
	//	address[25:0]
	//	[25][24][23][22][21][20][19][18][17][16][15][14][13][12][11][10][ 9][ 8][ 7][ 6][ 5][ 4][ 3][ 2][ 1][ 0]
	//	[PS][PS][SS][SS][BK][BK][BK][BK][BK][BK][BK][BK][AD][AD][AD][AD][AD][AD][AD][AD][LN][LN][LN][LN][LN][LN]
	//	PS = Primary Slot#
	//	SS = Secondary Slot#
	//	BK = Mapper Segment#, MegaROM Bank#
	//	AD = CPU Address upper
	//	LN = Cache line address
	// --------------------------------------------------------------------
	//	TAG 1unit
	//	[14][13][12][11][10][ 9][ 8][ 7][ 6][ 5][ 4][ 3][ 2][ 1][ 0]
	//	[AC][L#][L#][PS][PS][SS][SS][BK][BK][BK][BK][BK][BK][BK][BK]
	//	AC = Active flag (0:unused, 1:in use)
	//	L# = Cache line#
	//	PS = Primary Slot#
	//	SS = Secondary Slot#
	//	BK = Mapper Segment#, MegaROM Bank#
	// --------------------------------------------------------------------
endmodule
