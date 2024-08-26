// -----------------------------------------------------------------------------
//	tangcart_msx.v
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
//		Tangnano9K Cartridge for MSX
// -----------------------------------------------------------------------------
module tangcart_msx (
	output			tf_cs,
	output			tf_mosi,
	output			tf_sclk,
	input			tf_miso,

	output			srom_cs,
	output			srom_mosi,
	output			srom_sclk,
	input			srom_miso,

	input			n_treset,
	input			tclock,
	input			n_tsltsl,
	input			n_tmerq,
	input			n_tiorq,
	input			n_twr,
	input			n_trd,
	input	[15:0]	ta,
	output			tdir,
	inout	[7:0]	td,
	output			tsnd,
	output	[5:0]	n_led,
	input	[1:0]	button,
	input	[6:0]	dip_sw,
	output			twait,
	// PSRAM ports
	output	[1:0]	O_psram_ck,
	output	[1:0]	O_psram_ck_n,
	inout	[1:0]	IO_psram_rwds,
	inout	[15:0]	IO_psram_dq,
	output	[1:0]	O_psram_reset_n,
	output	[1:0]	O_psram_cs_n
);

`default_nettype none

	reg		[6:0]	ff_reset = 7'd0;
	reg		[4:0]	ff_wait = 5'b10000;
	wire			clk;
	wire			mem_clk;
	wire			mem_clk_lock;
	reg				ff_21mhz;
	reg		[4:0]	ff_1mhz;
	wire			w_1mhz;
	wire			w_n_reset;
	wire	[7:0]	w_o_data;
	wire	[7:0]	w_gpo;
	wire	[7:0]	w_gpi;
	wire	[15:0]	w_bus_address;
	wire			w_bus_read_ready;
	wire	[7:0]	w_bus_read_data;
	wire	[7:0]	w_bus_write_data;
	wire			w_bus_io_read;
	wire			w_bus_io_write;
	wire			w_bus_memory_read;
	wire			w_bus_memory_write;
	wire			w_is_output;
	wire			w_bus_memory_read0;
	wire			w_bus_memory_write0;
	wire			w_bus_memory_read1;
	wire			w_bus_memory_write1;
	wire			w_bus_memory_read2;
	wire			w_bus_memory_write2;
	wire			w_bus_memory_read3;
	wire			w_bus_memory_write3;
	wire			w_psram_initial_busy;
	wire			w_psram0_rd;
	wire			w_psram0_wr;
	wire			w_psram0_busy;
	wire	[21:0]	w_psram0_address;
	wire	[7:0]	w_psram0_wdata;
	wire	[7:0]	w_psram0_rdata;
	wire			w_psram0_rdata_en;
	wire			w_psram1_rd;
	wire			w_psram1_wr;
	wire			w_psram1_busy;
	wire	[21:0]	w_psram1_address;
	wire	[7:0]	w_psram1_wdata;
	wire	[7:0]	w_psram1_rdata;
	wire			w_psram1_rdata_en;
	wire			w_psram1_megarom_rd;
	wire			w_psram1_megarom_wr;
	wire	[21:0]	w_psram1_megarom_address;
	wire	[7:0]	w_psram1_megarom_wdata;
	wire			w_psram1_srom_wr;
	wire	[21:0]	w_psram1_srom_address;
	wire	[7:0]	w_psram1_srom_wdata;
	wire			w_bus_read_ready_gpio;
	wire	[7:0]	w_bus_read_data_gpio;
	wire			w_bus_read_ready_extslot;
	wire	[7:0]	w_bus_read_data_extslot;
	wire			w_bus_read_ready_mapram;
	wire	[7:0]	w_bus_read_data_mapram;
	wire			w_bus_read_ready_megarom;
	wire	[7:0]	w_bus_read_data_megarom;
	wire			w_bus_read_ready_scc;
	wire	[7:0]	w_bus_read_data_scc;
	wire			w_srom_busy;
	//	SerialROM
	wire			w_srom_n_cs;
	wire			w_srom_rd;
	wire			w_srom_wr;
	wire	[7:0]	w_srom_wdata;
	wire	[7:0]	w_srom_rdata;
	wire			w_srom_rdata_en;
	//	SCC
	wire			w_scc_bank_en;
	wire			w_sccp_bank_en;
	wire			w_sccp_en;
	wire	[10:0]	w_scc_out;
	//	sound generator
	reg		[10:0]	ff_sound;

	wire	[7:0]	w_read_cycle;

	// --------------------------------------------------------------------
	//	Debugger
	// --------------------------------------------------------------------
	ip_debugger u_debugger (
		.n_reset			( w_n_reset				),
		.clk				( clk					),
		.button				( button				),
		.n_led				( n_led					),
		.gpo				( w_gpo					),
		.gpi				( w_gpi					),
		.bus_io_read		( w_bus_io_read			),
		.bus_io_write		( w_bus_io_write		),
		.bus_memory_read	( w_bus_memory_read		),
		.bus_memory_write	( w_bus_memory_write	),
		.psram0_rd			( w_psram0_rd			),
		.psram0_wr			( w_psram0_wr			),
		.psram0_rdata_en	( w_psram0_rdata_en		),
		.psram0_address		( w_psram0_address		),
		.bus_read_ready		( w_bus_read_ready		),
		.read_cycle			( w_read_cycle			)
	);

	// --------------------------------------------------------------------
	//	OUTPUT Assignment
	// --------------------------------------------------------------------
	assign w_n_reset	= ff_reset[6];
	assign tf_cs		= 1'b1;
	assign tf_mosi		= 1'b0;
	assign tf_sclk		= 1'b0;
	assign td			= w_is_output   ? w_o_data : 8'hZZ;
	assign tdir			= w_is_output;
	assign twait		= ff_wait[4] | w_psram_initial_busy;	// | w_srom_busy;

	always @( posedge clk ) begin
		ff_reset[5:0]	<= { ff_reset[4:0], n_treset };
		ff_reset[6]		<= ( ff_reset[5:1] != 5'd0 ) ? 1'b1 : 1'b0;
	end

	always @( posedge clk ) begin
		if( ff_wait[3:0] == 4'b1111 ) begin
			ff_wait[4] <= 1'b0;
		end
		else begin
			ff_wait[3:0] <= ff_wait[3:0] + 4'd1;
			ff_wait[4] <= 1'b1;
		end
	end

	assign w_psram1_rd				= 1'b0;	//	w_psram1_megarom_rd;
	assign w_psram1_wr				= 1'b0;	//	w_psram1_megarom_wr       | w_psram1_srom_wr;
	assign w_psram1_address			= 'd0;	//	w_psram1_megarom_address  | w_psram1_srom_address;
	assign w_psram1_wdata			= 'd0;	//	w_psram1_megarom_wdata    | w_psram1_srom_wdata;

	// --------------------------------------------------------------------
	//	PLL 3.579545MHz --> 50.11363MHz
	// --------------------------------------------------------------------
	Gowin_PLL u_pll (
		.clkout				( mem_clk					),		// output	128.844MHz (x36)
		.lock				( mem_clk_lock				),		// output	lock
		.clkoutd			( clk						),		// output	 64.422MHz (x18)
		.clkin				( tclock					)		// input	  3.579MHz
	);

	always @( posedge clk ) begin
		if( !w_n_reset ) begin
			ff_21mhz <= 1'd0;
		end
		else  begin
			ff_21mhz <= ~ff_21mhz;
		end
	end

	always @( posedge clk ) begin
		if( !w_n_reset ) begin
			ff_1mhz <= 5'd26;
		end
		else if( ff_1mhz == 5'd0 ) begin
			ff_1mhz <= 5'd26;
		end
		else begin
			ff_1mhz <= ff_1mhz - 5'd1;
		end
	end

	assign w_1mhz	= (ff_1mhz == 5'd0);

	// --------------------------------------------------------------------
	//	MSX 50BUS
	// --------------------------------------------------------------------
	ip_msxbus u_msxbus (
		.n_reset			( w_n_reset					),
		.clk				( clk						),		//	64.422MHz
		.adr				( ta						),
		.i_data				( td						),
		.o_data				( w_o_data					),
		.is_output			( w_is_output				),
		.n_sltsl			( n_tsltsl					),
		.n_rd				( n_trd						),
		.n_wr				( n_twr						),
		.n_ioreq			( n_tiorq					),
		.n_mereq			( n_tmerq					),
		.bus_address		( w_bus_address				),
		.bus_read_ready		( w_bus_read_ready			),
		.bus_read_data		( w_bus_read_data			),
		.bus_write_data		( w_bus_write_data			),
		.bus_io_read		( w_bus_io_read				),
		.bus_io_write		( w_bus_io_write			),
		.bus_memory_read	( w_bus_memory_read			),
		.bus_memory_write	( w_bus_memory_write		)
	);

//	assign w_bus_read_ready	= w_bus_read_ready_mapram | w_bus_read_ready_megarom | w_bus_read_ready_extslot | w_bus_read_ready_scc;
//	assign w_bus_read_data	= w_bus_read_data_mapram  | w_bus_read_data_megarom  | w_bus_read_data_extslot  | w_bus_read_data_scc;

	assign w_bus_read_ready	= w_bus_read_ready_mapram | w_bus_read_ready_gpio;
	assign w_bus_read_data	= w_bus_read_data_mapram  | w_bus_read_data_gpio;

	// --------------------------------------------------------------------
	//	GPIO
	// --------------------------------------------------------------------
	ip_gpio u_gpio (
		.n_reset			( w_n_reset					),
		.clk				( clk						),		//	64.422MHz
		.bus_address		( w_bus_address				),
		.bus_read_ready		( w_bus_read_ready_gpio		),
		.bus_read_data		( w_bus_read_data_gpio		),
		.bus_write_data		( w_bus_write_data			),
		.bus_io_read		( w_bus_io_read				),
		.bus_io_write		( w_bus_io_write			),
		.gpo				( w_gpo						),
		.gpi				( w_gpi						)
	);

	// --------------------------------------------------------------------
	//	EXTSLOT
	// --------------------------------------------------------------------
//	ip_extslot u_extslot (
//		.n_reset			( w_n_reset					),
//		.clk				( clk						),		//	64.422MHz
//		.bus_address		( w_bus_address				),
//		.bus_read_ready		( w_bus_read_ready_extslot	),
//		.bus_read_data		( w_bus_read_data_extslot	),
//		.bus_write_data		( w_bus_write_data			),
//		.bus_memory_read	( w_bus_memory_read			),
//		.bus_memory_write	( w_bus_memory_write		),
//		.bus_memory_read0	( w_bus_memory_read0		),
//		.bus_memory_write0	( w_bus_memory_write0		),
//		.bus_memory_read1	( w_bus_memory_read1		),
//		.bus_memory_write1	( w_bus_memory_write1		),
//		.bus_memory_read2	( w_bus_memory_read2		),
//		.bus_memory_write2	( w_bus_memory_write2		),
//		.bus_memory_read3	( w_bus_memory_read3		),
//		.bus_memory_write3	( w_bus_memory_write3		)
//	);

	// --------------------------------------------------------------------
	//	MapperRAM
	// --------------------------------------------------------------------
//	ip_mapperram u_mapperram (
//		.n_reset			( w_n_reset					),
//		.clk				( clk						),		//	64.422MHz
//		.bus_address		( w_bus_address				),
//		.bus_read_ready		( w_bus_read_ready_mapram	),
//		.bus_read_data		( w_bus_read_data_mapram	),
//		.bus_write_data		( w_bus_write_data			),
//		.bus_io_read		( w_bus_io_read				),
//		.bus_io_write		( w_bus_io_write			),
//		.bus_memory_read	( w_bus_memory_read0		),
//		.bus_memory_write	( w_bus_memory_write0		),
//		.rd					( w_psram0_rd				),
//		.wr					( w_psram0_wr				),
//		.busy				( w_psram0_busy				),
//		.address			( w_psram0_address			),
//		.wdata				( w_psram0_wdata			),
//		.rdata				( w_psram0_rdata			),
//		.rdata_en			( w_psram0_rdata_en			)
//	);

//	ip_ram u_ram (
//		.n_reset			( w_n_reset					),
//		.clk				( clk						),		//	64.422MHz
//		.bus_address		( w_bus_address				),
//		.bus_read_ready		( w_bus_read_ready_mapram	),
//		.bus_read_data		( w_bus_read_data_mapram	),
//		.bus_write_data		( w_bus_write_data			),
//		.bus_memory_read	( w_bus_memory_read			),
//		.bus_memory_write	( w_bus_memory_write		)
//	);

	ip_ram2 u_ram (
		.n_reset			( w_n_reset					),
		.clk				( clk						),		//	64.422MHz
		.bus_address		( w_bus_address				),
		.bus_read_ready		( w_bus_read_ready_mapram	),
		.bus_read_data		( w_bus_read_data_mapram	),
		.bus_write_data		( w_bus_write_data			),
		.bus_memory_read	( w_bus_memory_read			),
		.bus_memory_write	( w_bus_memory_write		),
		.rd					( w_psram0_rd				),
		.wr					( w_psram0_wr				),
		.busy				( w_psram0_busy				),
		.address			( w_psram0_address			),
		.wdata				( w_psram0_wdata			),
		.rdata				( w_psram0_rdata			),
		.rdata_en			( w_psram0_rdata_en			),
		.debug_count		( w_read_cycle				)
	);

	// --------------------------------------------------------------------
	//	MegaROM Emulator
	// --------------------------------------------------------------------
//	ip_megarom #(
//		.address_h			( 1'b0						)
//	) u_megarom (
//		.n_reset			( w_n_reset					),
//		.clk				( clk						),		//	64.422MHz
//		.enable				( 1'b1						),
//		.mode				( 3'd5						),
//		.bus_address		( w_bus_address				),
//		.bus_io_cs			( w_bus_io_cs_megarom		),
//		.bus_memory_cs		( w_bus_memory_cs_megarom	),
//		.bus_read_ready		( w_bus_read_ready_megarom	),
//		.bus_read_data		( w_bus_read_data_megarom	),
//		.bus_write_data		( w_bus_write_data			),
//		.bus_read			( w_bus_read				),
//		.bus_write			( w_bus_write				),
//		.bus_io				( w_bus_io					),
//		.bus_memory			( w_extslot_memory3			),
//		.rd					( w_psram1_megarom_rd		),
//		.wr					( w_psram1_megarom_wr		),
//		.busy				( w_psram1_busy				),
//		.address			( w_psram1_megarom_address	),
//		.wdata				( w_psram1_megarom_wdata	),
//		.rdata				( w_psram1_rdata			),
//		.rdata_en			( w_psram1_rdata_en			),
//		.scc_bank_en		( w_scc_bank_en				),
//		.sccp_bank_en		( w_sccp_bank_en			),
//		.sccp_en			( w_sccp_en					),
//		.bank0				( w_bank0					),
//		.bank1				( w_bank1					),
//		.bank2				( w_bank2					),
//		.bank3				( w_bank3					)
//	);

	// --------------------------------------------------------------------
	//	SCC
	// --------------------------------------------------------------------
//	ip_scc u_scc (
//		.n_reset			( w_n_reset					),
//		.clk				( clk						),		//	64.422MHz
//		.enable				( ff_21mhz					),
//		.bus_address		( w_bus_address				),
//		.bus_read_ready		( w_bus_read_ready_scc		),
//		.bus_read_data		( w_bus_read_data_scc		),
//		.bus_write_data		( w_bus_write_data			),
//		.bus_read			( w_bus_read				),
//		.bus_write			( w_bus_write				),
//		.bus_memory			( w_extslot_memory3			),
//		.scc_bank_en		( w_scc_bank_en				),
//		.sccp_bank_en		( w_sccp_bank_en			),
//		.sccp_en			( w_sccp_en					),
//		.sound_out			( w_scc_out					)
//	);
	assign w_scc_out	= 11'd0;

	// --------------------------------------------------------------------
	//	PSRAM
	// --------------------------------------------------------------------
	ip_psram u_psram (
		.n_reset			( w_n_reset					),
		.clk				( clk						),		//	64.422MHz
		.mem_clk			( mem_clk					),
		.lock				( mem_clk_lock				),
		.initial_busy		( w_psram_initial_busy		),
		.rd0				( w_psram0_rd				),
		.wr0				( w_psram0_wr				),
		.busy0				( w_psram0_busy				),
		.address0			( w_psram0_address			),
		.wdata0				( w_psram0_wdata			),
		.rdata0				( w_psram0_rdata			),
		.rdata0_en			( w_psram0_rdata_en			),
		.rd1				( w_psram1_rd				),
		.wr1				( w_psram1_wr				),
		.busy1				( w_psram1_busy				),
		.address1			( w_psram1_address			),
		.wdata1				( w_psram1_wdata			),
		.rdata1				( w_psram1_rdata			),
		.rdata1_en			( w_psram1_rdata_en			),
		.O_psram_ck			( O_psram_ck				),
		.O_psram_ck_n		( O_psram_ck_n				),
		.IO_psram_rwds		( IO_psram_rwds				),
		.IO_psram_dq		( IO_psram_dq				),
		.O_psram_reset_n	( O_psram_reset_n			),
		.O_psram_cs_n		( O_psram_cs_n				)
	);

	// --------------------------------------------------------------------
	//	PSRAM Test Module
	// --------------------------------------------------------------------
//	ip_psram_tester u_psram_tester (
//		.n_reset			( w_n_reset					),
//		.clk				( clk						),		//	64.422MHz
//		.initial_busy		( w_psram_initial_busy		),
//		.rd0				( w_psram0_rd				),
//		.wr0				( w_psram0_wr				),
//		.busy0				( w_psram0_busy				),
//		.address0			( w_psram0_address			),
//		.wdata0				( w_psram0_wdata			),
//		.rdata0				( w_psram0_rdata			),
//		.rdata_en0			( w_psram0_rdata_en			),
//		.rd1				( 							),
//		.wr1				( 							),
//		.busy1				( 1'b0						),
//		.address1			( 							),
//		.wdata1				( 							),
//		.rdata1				( 'd0						),
//		.rdata_en1			( 1'b0						),
//		.send_data			( 							),
//		.send_req			( 							),
//		.send_busy			( 1'b0						),
//		.pc					( w_pc						)
//	);

	// --------------------------------------------------------------------
	//	SerialROM
	// --------------------------------------------------------------------
//	ip_srom #(
//		.END_ADDRESS		( 'h2F_FFFF					)
//	) u_srom (
//		.n_reset			( w_n_reset					),
//		.clk				( clk						),		//	64.422MHz
//		.srom_cs			( srom_cs					),
//		.srom_mosi			( srom_mosi					),
//		.srom_sclk			( srom_sclk					),
//		.srom_miso			( srom_miso					),
//		.n_cs				( w_srom_n_cs				),
//		.rd					( w_srom_rd					),
//		.wr					( w_srom_wr					),
//		.busy				( 							),
//		.wdata				( w_srom_wdata				),
//		.rdata				( w_srom_rdata				),
//		.rdata_en			( w_srom_rdata_en			),
//		.psram1_wr			( w_psram1_srom_wr			),
//		.psram1_busy		( w_psram1_busy				),
//		.psram1_address		( w_psram1_srom_address		),
//		.psram1_wdata		( w_psram1_srom_wdata		),
//		.initial_busy		( w_srom_busy				)
//	);

	// --------------------------------------------------------------------
	//	Sound
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !w_n_reset ) begin
			ff_sound <= 11'h00;
		end
		else begin
			ff_sound <= w_scc_out;
		end
	end

	ip_pwm u_pwm (
		.n_reset			( w_n_reset					),
		.clk				( clk						),		//	64.422MHz
		.enable				( w_1mhz					),
		.signal_level		( { ff_sound, 5'd0 }		),
		.pwm_wave			( tsnd						)
	);
endmodule

`default_nettype wire
