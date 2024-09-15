// ------------------------------------------------------------------------------------------------
// IKA-SCC Wrapper
// Copyright 2024 t.hara
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
// ------------------------------------------------------------------------------------------------

module ip_ikascc_wrapper (
	input			n_reset,
	input			clk,
	input			mclk_pcen_n,
	//	MSX-50BUS
	input			n_tsltsl,
	input			n_trd,
	input			n_twr,
	input	[15:0]	ta,
	input	[7:0]	wdata,
	output	[7:0]	rdata,
	output			rdata_en,
	//	SCC
	output	[10:0]	sound_out,		//	digital sound output (11 bits)
	output	[4:0]	n_led
);
	// --------------------------------------------------------------------
	//	IKA-SCC body
	// --------------------------------------------------------------------
	IKASCC #(
		.IMPL_TYPE			( 0							),
		.RAM_BLOCK			( 1							)
	) u_ikascc (
		.i_EMUCLK			( clk						),	//emulator master clock
		.i_MCLK_PCEN_n		( mclk_pcen_n				),	//phiM positive edge clock enable(negative logic)
		.i_RST_n			( n_reset					),	//synchronous reset
		.i_CS_n				( n_tsltsl					),	//asynchronous bus control signal
		.i_RD_n				( n_trd						),	
		.i_WR_n				( n_twr						),	
		.i_ABLO				( ta[7:0]					),	//address bus low(AB7:0), for the SCC
		.i_ABHI				( ta[15:11]					),	//address bus high(AB15:11), for the mapper
		.i_DB				( wdata						),	
		.o_DB				( rdata						),	
		.o_DB_OE			( rdata_en					),	
		.o_ROMCS_n			( w_rom_cs_n				),	
		.o_ROMADDR			( w_rom_ma					),	//MA[18:13]
		.o_SOUND			( sound_out					),
		.o_TEST				( 							)
	);

	reg				ff_led;
	reg		[21:0]	ff_led_count;

	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_led_count <= 'd0;
			ff_led <= 1'b1;
		end
		if( !mclk_pcen_n ) begin
			if( ff_led_count == 'd3579544 ) begin
				ff_led_count <= 'd0;
				ff_led <= ~ff_led;
			end
			else begin
				ff_led_count <= ff_led_count + 'd1;
			end
		end
	end

	assign n_led	= { ff_led, ~ff_led, ff_led, ~ff_led, ff_led };
endmodule
