// -----------------------------------------------------------------------------
//	tang20cart_msx.v
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
//		Tangnano20K Cartridge for MSX
// -----------------------------------------------------------------------------
module tang20cart_msx (
	//	MSX Cartridge connector
	input			clk27m,			//	27MHz
	input			n_treset,
	input			tclock,			//	3.579454MHz from MSX
	input			n_tsltsl,
	input			n_tiorq,
	input			n_twr,
	input			n_trd,
	output	[1:0]	toe,
	input	[7:0]	ta,
	output			tdir,
	inout	[7:0]	td,
	output			tsnd,
	input	[4:0]	dip_sw,
	input	[1:0]	keys,
	output			twait,

	//	FlashROM
	output			mspi_cs,
	output			mspi_sclk,
	inout			mspi_mosi,
	inout			mspi_miso,

	//	UART
	output			uart_tx,

	//	MicroSD Card
//	output			sd_sclk,
//	inout			sd_cmd,
//	inout			sd_dat0,
//	output			sd_dat1,
	output			sd_dat2,
	output			sd_dat3,

	//	SDRAM
	output			O_sdram_clk,
	output			O_sdram_cke,
	output			O_sdram_cs_n,
	output			O_sdram_cas_n,
	output			O_sdram_ras_n,
	output			O_sdram_wen_n,
	inout	[31:0]	IO_sdram_dq,
	output	[10:0]	O_sdram_addr,
	output	[1:0]	O_sdram_ba,
	output	[3:0]	O_sdram_dqm
);

`default_nettype none

	reg		[25:0]	ff_count = 26'd0;
	reg		[1:0]	ff_led = 2'd0;
	wire	[15:0]	taddress;
	reg		[6:0]	ff_reset = 7'd0;
	reg		[4:0]	ff_wait = 5'b10000;
	wire			clk;
	reg				ff_21mhz = 1'b0;
	reg		[5:0]	ff_1mhz = 6'd0;
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
	//	SDRAM
	wire			w_sdram_initial_busy;
	wire			w_sdram_rd;
	wire			w_sdram_wr;
	wire			w_sdram_busy;
	wire	[22:0]	w_sdram_address;
	wire	[7:0]	w_sdram_wdata;
	wire	[7:0]	w_sdram_rdata;
	wire			w_sdram_rdata_en;
	//	SCC
	wire			w_scc_bank_en;
	wire			w_sccp_bank_en;
	wire			w_sccp_en;
	wire	[10:0]	w_scc_out;
	//	sound generator
	reg		[10:0]	ff_sound;

	wire	[7:0]	w_read_cycle;
	wire	[7:0]	w_send_data;
	wire			w_send_req;
	wire			w_send_busy;

	// --------------------------------------------------------------------
	//	OUTPUT Assignment
	// --------------------------------------------------------------------
	assign w_n_reset	= ff_reset[6];

//	assign sd_sclk		= 1'b0;
//	assign sd_cmd		= 1'b0;
//	assign sd_dat0		= 1'b0;
//	assign sd_dat1		= 1'b0;
	assign sd_dat2		= w_gpo[0];	//~ff_led[0];
	assign sd_dat3		= w_gpo[1];	//~ff_led[1];

//	assign w_is_output	= 1'd0;			// *************************
//	assign w_o_data		= 8'd0;			// *************************

	assign td			= w_is_output   ? w_o_data : 8'hZZ;
	assign tdir			= w_is_output;
	assign twait		= ff_wait[4] | w_sdram_initial_busy;	// | w_srom_busy;

	assign w_sdram_rd	= 1'b0;
	assign w_sdram_wr	= 1'b0;

	always @( posedge clk ) begin
		ff_reset[5:0]	<= { ff_reset[4:0], 1'b1 };	//n_treset };
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

	// --------------------------------------------------------------------
	//	PLL 3.579545MHz --> 42.95454MHz
	// --------------------------------------------------------------------
	Gowin_PLL u_pll (
		.clkout				( clk						),		//output	54MHz (42.95454MHz)
		.clkin				( clk27m					)		//input		27MHz (3.579545MHz)
	);

	always @( posedge clk ) begin
		if( !w_n_reset ) begin
			ff_count <= 'd0;
		end
		else if( ff_count == 'd53999999 ) begin
			ff_count <= 'd0;
		end
		else begin
			ff_count <= ff_count + 'd1;
		end
	end

	always @( posedge clk ) begin
		if( !w_n_reset ) begin
			ff_led <= 'd0;
		end
		else if( ff_count == 'd53999999 ) begin
			ff_led <= ff_led + 'd1;
		end
	end

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
			ff_1mhz <= 6'd42;
		end
		else if( ff_1mhz == 6'd0 ) begin
			ff_1mhz <= 6'd42;
		end
		else begin
			ff_1mhz <= ff_1mhz - 6'd1;
		end
	end

	assign w_1mhz	= (ff_1mhz == 6'd0);
	assign w_gpi	= { 3'd0, dip_sw };

	// --------------------------------------------------------------------
	//	MSX 50BUS
	// --------------------------------------------------------------------
	tang20 u_address_latch (
		.clk				( clk						),
		.n_reset			( w_n_reset					),
		.ta					( ta						),
		.toe				( toe						),
		.address			( taddress					)
	);

	ip_msxbus u_msxbus (
		.n_reset			( w_n_reset					),
		.clk				( clk						),
		.adr				( taddress					),
		.i_data				( td						),
		.o_data				( w_o_data					),
		.is_output			( w_is_output				),
		.n_sltsl			( n_tsltsl					),
		.n_rd				( n_trd						),
		.n_wr				( n_twr						),
		.n_ioreq			( n_tiorq					),
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

	assign w_bus_read_ready	= w_bus_read_ready_gpio;
	assign w_bus_read_data	= w_bus_read_data_gpio;

	// --------------------------------------------------------------------
	//	GPIO
	// --------------------------------------------------------------------
	ip_gpio u_gpio (
		.n_reset			( w_n_reset					),
		.clk				( clk						),
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
//		.clk				( clk						),
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
//		.clk				( clk						),
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
//		.clk				( clk						),
//		.bus_address		( w_bus_address				),
//		.bus_read_ready		( w_bus_read_ready_mapram	),
//		.bus_read_data		( w_bus_read_data_mapram	),
//		.bus_write_data		( w_bus_write_data			),
//		.bus_memory_read	( w_bus_memory_read			),
//		.bus_memory_write	( w_bus_memory_write		)
//	);

//	ip_ram2 u_ram (
//		.n_reset			( w_n_reset					),
//		.clk				( clk						),
//		.bus_address		( w_bus_address				),
//		.bus_read_ready		( w_bus_read_ready_mapram	),
//		.bus_read_data		( w_bus_read_data_mapram	),
//		.bus_write_data		( w_bus_write_data			),
//		.bus_memory_read	( w_bus_memory_read			),
//		.bus_memory_write	( w_bus_memory_write		),
//		.rd					( w_psram0_rd				),
//		.wr					( w_psram0_wr				),
//		.busy				( w_psram0_busy				),
//		.address			( w_psram0_address			),
//		.wdata				( w_psram0_wdata			),
//		.rdata				( w_psram0_rdata			),
//		.rdata_en			( w_psram0_rdata_en			),
//		.debug_count		( w_read_cycle				)
//	);

	// --------------------------------------------------------------------
	//	MegaROM Emulator
	// --------------------------------------------------------------------
//	ip_megarom #(
//		.address_h			( 1'b0						)
//	) u_megarom (
//		.n_reset			( w_n_reset					),
//		.clk				( clk						),
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
	//	SDRAM
	// --------------------------------------------------------------------
	ip_sdram u_sdram (
		.n_reset			( w_n_reset					),
		.clk				( clk						),
		.initial_busy		( w_sdram_initial_busy		),
		.rd					( w_sdram_rd				),
		.wr					( w_sdram_wr				),
		.busy				( w_sdram_busy				),
		.address			( w_sdram_address			),
		.wdata				( w_sdram_wdata				),
		.rdata				( w_sdram_rdata				),
		.rdata_en			( w_sdram_rdata_en			),
		.O_sdram_clk		( O_sdram_clk				),
		.O_sdram_cke		( O_sdram_cke				),
		.O_sdram_cs_n		( O_sdram_cs_n				),
		.O_sdram_cas_n		( O_sdram_cas_n				),
		.O_sdram_ras_n		( O_sdram_ras_n				),
		.O_sdram_wen_n		( O_sdram_wen_n				),
		.IO_sdram_dq		( IO_sdram_dq				),
		.O_sdram_addr		( O_sdram_addr				),
		.O_sdram_ba			( O_sdram_ba				),
		.O_sdram_dqm		( O_sdram_dqm				)
	);

	// --------------------------------------------------------------------
	//	SCC
	// --------------------------------------------------------------------
//	ip_scc u_scc (
//		.n_reset			( w_n_reset					),
//		.clk				( clk						),
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
	reg		[25:0]		ff_sound_count;
	reg					ff_sound_out;

	always @( posedge clk ) begin
		if( !w_n_reset ) begin
			ff_sound_count	<= 'd0;
			ff_sound_out	<= 1'b0;
		end
		else if( ff_sound_count == 'd61364 ) begin		//	880Hz
			ff_sound_count	<= 'd0;
			ff_sound_out	<= ~ff_sound_out;			//	440Hz
		end
		else begin
			ff_sound_count	<= ff_sound_count + 'd1;
		end
	end

	assign w_scc_out	= { 11 {ff_sound_out} };

	// --------------------------------------------------------------------
	//	SerialROM
	// --------------------------------------------------------------------
//	ip_srom #(
//		.END_ADDRESS		( 'h2F_FFFF					)
//	) u_srom (
//		.n_reset			( w_n_reset					),
//		.clk				( clk						),
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
	ip_uart #(
		.clk_freq			( 54000000					),
		.uart_freq			( 115200					)
	) u_uart (
		.n_reset			( w_n_reset					),
		.clk				( clk						),
		.send_data			( w_send_data				),
		.send_req			( w_send_req				),
		.send_busy			( w_send_busy				),
		.uart_tx			( uart_tx					)
	);

	ip_debugger u_debugger (
		.n_reset			( w_n_reset					),
		.clk				( clk						),
		.send_data			( w_send_data				),
		.send_req			( w_send_req				),
		.send_busy			( w_send_busy				),
		.keys				( keys						),
		.address			( taddress					),
		.n_twr				( n_twr						),
		.n_trd				( n_trd						),
		.n_tsltsl			( n_tsltsl					),
		.n_tiorq			( n_tiorq					)
	);

	// --------------------------------------------------------------------
	//	Sound
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !w_n_reset ) begin
			ff_sound <= 11'h00;
		end
		else begin
			ff_sound <= 11'd0;	//w_scc_out;
		end
	end

	ip_pwm u_pwm (
		.n_reset			( w_n_reset					),
		.clk				( clk						),
		.enable				( w_1mhz					),
		.signal_level		( { ff_sound, 5'd0 }		),
		.pwm_wave			( tsnd						)
	);
endmodule

`default_nettype wire
