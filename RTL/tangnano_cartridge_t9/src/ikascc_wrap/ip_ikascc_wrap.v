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
	output	[10:0]	sound_out		//	digital sound output (11 bits)
);
	wire			w_rom_pre_cs_n;
	wire			w_rom_cs_n;
	wire			w_ram_cs_n;
	wire	[5:0]	w_rom_ma;
	wire	[7:0]	w_scc_rdata;
	wire			w_scc_rdata_en;
	wire	[7:0]	w_rom_rdata;
	wire			w_rom_rdata_en;
	wire	[7:0]	w_ram_rdata;
	wire			w_ram_rdata_en;
	reg				ff_a14_inv;
	reg		[3:0]	ff_scc_mask;
	wire	[15:11]	w_abhi;
	wire			w_n_scc_mask;
	wire			w_n_scc_trd;
	wire			w_n_scc_twr;

	// --------------------------------------------------------------------
	//	IKA-SCC body
	// --------------------------------------------------------------------
	IKASCC #(
		.IMPL_TYPE			( 0								),
		.RAM_BLOCK			( 1								)
	) u_ikascc (
		.i_EMUCLK			( clk							),	//emulator master clock
		.i_MCLK_PCEN_n		( mclk_pcen_n					),	//phiM positive edge clock enable(negative logic)
		.i_RST_n			( n_reset						),	//synchronous reset
		.i_CS_n				( n_tsltsl						),	//asynchronous bus control signal
		.i_RD_n				( w_n_scc_trd					),	
		.i_WR_n				( w_n_scc_twr					),	
		.i_ABLO				( ta[7:0]						),	//address bus low(AB7:0), for the SCC
		.i_ABHI				( w_abhi						),	//address bus high(AB15:11), for the mapper
		.i_DB				( wdata							),	
		.o_DB				( w_scc_rdata					),	
		.o_DB_OE			( w_scc_rdata_en				),	
		.o_ROMCS_n			( w_rom_pre_cs_n				),	
		.o_ROMADDR			( w_rom_ma						),	//MA[18:13]
		.o_SOUND			( sound_out						),
		.o_TEST				( 								)
	);

	// --------------------------------------------------------------------
	//	ROM(Bank#0, #1)
	// --------------------------------------------------------------------
	ip_msxmusic_rom u_rom (
		.clk				( clk							),
		.n_cs				( w_rom_cs_n					),
		.n_rd				( n_trd							),
		.address			( { w_rom_ma[0], ta[12:0] }		),
		.rdata				( w_rom_rdata					),
		.rdata_en			( w_rom_rdata_en				)
	);

	// --------------------------------------------------------------------
	//	RAM (Bank#2, #3)
	// --------------------------------------------------------------------
	ip_ram u_ram (
		.clk				( clk							),
		.n_cs				( w_ram_cs_n					),
		.n_wr				( n_twr							),
		.n_rd				( n_trd							),
		.address			( { w_rom_ma[0], ta[12:0] }		),
		.wdata				( wdata							),
		.rdata				( w_ram_rdata					),
		.rdata_en			( w_ram_rdata_en				)
	);

	// --------------------------------------------------------------------
	//	Address bit14 inverter
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_a14_inv		<= 1'b0;
			ff_scc_mask		<= 4'd0;
		end
		else if( !n_tsltsl && !n_twr && ta == 16'h7FFC ) begin
			ff_a14_inv		<= wdata[7];
			ff_scc_mask		<= wdata[3:0];
		end
		else begin
			//	hold
		end
	end

	// --------------------------------------------------------------------
	//	SCC read/write mask
	// --------------------------------------------------------------------
	assign w_n_scc_mask	= (w_abhi[14:13] == 2'b10) ? ff_scc_mask[0]:
						  (w_abhi[14:13] == 2'b11) ? ff_scc_mask[1]:
						  (w_abhi[14:13] == 2'b00) ? ff_scc_mask[2]: ff_scc_mask[3];
	assign w_n_scc_trd	= w_n_scc_mask | n_trd;
	assign w_n_scc_twr	= w_n_scc_mask | n_twr;
	assign w_abhi		= { ta[15], ta[14] ^ ff_a14_inv, ta[13:11] };
	assign w_rom_cs_n	= (w_rom_ma[5:1] == 4'd0) ? w_rom_pre_cs_n: 1'b1;
	assign w_ram_cs_n	= (w_rom_ma[5:1] == 4'd1) ? w_rom_pre_cs_n: 1'b1;
	assign rdata		= w_scc_rdata | w_rom_rdata | w_ram_rdata;
	assign rdata_en		= w_scc_rdata_en | w_rom_rdata_en | w_ram_rdata_en;
endmodule
