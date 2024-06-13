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
	input			sys_clk,

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
	input	[7:0]	dip_sw,
	// PSRAM ports
	output	[1:0]	O_psram_ck,
	output	[1:0]	O_psram_ck_n,
	inout	[1:0]	IO_psram_rwds,
	inout	[15:0]	IO_psram_dq,
	output	[1:0]	O_psram_reset_n,
	output	[1:0]	O_psram_cs_n
	// UART
//	output			uart_tx
);
	reg		[6:0]	ff_reset = 7'd0;
	wire			clk;
	wire			n_clk;
	wire			mem_clk;
	wire			mem_clk_lock;
	wire			w_n_reset;
	wire	[7:0]	w_o_data;
//	reg		[7:0]	ff_send_data;
//	reg				ff_send_req;
//	wire			w_send_busy;
//	reg		[25:0]	ff_cnt;
//	reg		[23:0]	ff_address;
//	reg		[7:0]	ff_wdata;
//	reg				ff_rd0;
//	reg				ff_wr0;
	wire			w_busy0;
	wire	[7:0]	w_rdata0;
	wire			w_rdata0_en;
//	reg				ff_rd1;
//	reg				ff_wr1;
	wire			w_busy1;
	wire	[7:0]	w_rdata1;
	wire			w_rdata1_en;
	reg				ff_ram_id;
	reg		[2:0]	ff_state;
	reg				ff_failed;
	wire	[7:0]	w_gpo;
	wire	[7:0]	w_gpo_mem;
	wire	[15:0]	w_bus_address;
	wire			w_bus_io_cs;
	wire			w_bus_memory_cs;
	wire			w_bus_read_ready;
	wire	[7:0]	w_bus_read_data;
	wire	[7:0]	w_bus_write_data;
	wire			w_bus_read;
	wire			w_bus_write;
	wire			w_bus_io;
	wire			w_bus_memory;
	reg		[6:0]	ff_1mhz_count;
	wire			w_1mhz;
	reg		[7:0]	ff_sound;
	reg		[7:0]	ff_sound_level;
	reg		[15:0]	ff_div_count;
	reg		[15:0]	ff_div_freq;
	reg		[16:0]	ff_state_count;
	wire			w_state_change;
	wire			w_is_output;
	wire			w_is_output_d;
	wire			w_extslot_memory0;
	wire			w_extslot_memory1;
	wire			w_extslot_memory2;
	wire			w_extslot_memory3;
	wire			w_psram0_rd;
	wire			w_psram0_wr;
	wire			w_psram0_busy;
	wire	[21:0]	w_psram0_address;
	wire	[7:0]	w_psram0_wdata;
	wire	[7:0]	w_psram0_rdata;
	wire			w_psram0_rdata_en;
	wire			w_bus_io_cs_extslot;
	wire			w_bus_memory_cs_extslot;
	wire			w_bus_read_ready_extslot;
	wire	[7:0]	w_bus_read_data_extslot;
	wire			w_bus_io_cs_gpio;
	wire			w_bus_memory_cs_gpio;
	wire			w_bus_read_ready_gpio;
	wire	[7:0]	w_bus_read_data_gpio;
	wire			w_bus_io_cs_gpio_mem;
	wire			w_bus_memory_cs_gpio_mem;
	wire			w_bus_read_ready_gpio_mem;
	wire	[7:0]	w_bus_read_data_gpio_mem;
	wire			w_bus_io_cs_mapram;
	wire			w_bus_memory_cs_mapram;
	wire			w_bus_read_ready_mapram;
	wire	[7:0]	w_bus_read_data_mapram;

	// --------------------------------------------------------------------
	//	OUTPUT Assignment
	// --------------------------------------------------------------------
	assign w_n_reset	= ff_reset[6];
	assign tf_cs		= 1'b0;
	assign tf_mosi		= 1'b0;
	assign tf_sclk		= 1'b0;
	assign n_led		= w_gpo_mem[5:0];
	assign td			= (w_is_output   & dip_sw[7]) ? w_o_data : 8'hZZ;
	assign tdir			= (w_is_output_d & dip_sw[7]);

	always @( posedge clk ) begin
		ff_reset[5:0]	<= { ff_reset[4:0], n_treset };
		ff_reset[6]		<= (ff_reset[5:0] == 6'b111111) ? 1'b1 : 1'b0;
	end

	// --------------------------------------------------------------------
	//	PLL 3.579545MHz --> 64.43181MHz
	// --------------------------------------------------------------------
	Gowin_PLL u_pll (
		.clkout			( mem_clk			),		//output	128.86362MHz
		.lock			( mem_clk_lock		),		//output	lock
		.clkoutd		( clk				),		//output	64.43181MHz
		.clkin			( tclock			)		//input		3.579545MHz
	);
//	Gowin_PLL u_pll (
//		.clkout			( mem_clk			),		//output	162.0MHz
//		.lock			( mem_clk_lock		),		//output	lock
//		.clkoutd		( clk				),		//output	81.0MHz
//		.clkin			( sys_clk			)		//input		27.0MHz
//	);

	// --------------------------------------------------------------------
	//	MSX 50BUS
	// --------------------------------------------------------------------
	ip_msxbus u_msxbus (
		.n_reset			( w_n_reset			),
		.clk				( clk				),
		.adr				( ta				),
		.i_data				( td				),
		.o_data				( w_o_data			),
		.is_output			( w_is_output		),
		.is_output_d		( w_is_output_d		),
		.n_sltsl			( n_tsltsl			),
		.n_rd				( n_trd				),
		.n_wr				( n_twr				),
		.n_ioreq			( n_tiorq			),
		.n_mereq			( n_tmerq			),
		.bus_address		( w_bus_address		),
		.bus_io_cs			( w_bus_io_cs		),
		.bus_memory_cs		( w_bus_memory_cs	),
		.bus_read_ready		( w_bus_read_ready	),
		.bus_read_data		( w_bus_read_data	),
		.bus_write_data		( w_bus_write_data	),
		.bus_read			( w_bus_read		),
		.bus_write			( w_bus_write		),
		.bus_io				( w_bus_io			),
		.bus_memory			( w_bus_memory		)
	);
	assign w_bus_io_cs		= w_bus_io_cs_gpio_mem      | w_bus_io_cs_gpio      | w_bus_io_cs_mapram      | w_bus_io_cs_extslot;
	assign w_bus_memory_cs	= w_bus_memory_cs_gpio_mem  | w_bus_memory_cs_gpio  | w_bus_memory_cs_mapram  | w_bus_memory_cs_extslot;
	assign w_bus_read_ready	= w_bus_read_ready_gpio_mem | w_bus_read_ready_gpio | w_bus_read_ready_mapram | w_bus_read_ready_extslot;
	assign w_bus_read_data	= w_bus_read_data_gpio_mem  | w_bus_read_data_gpio  | w_bus_read_data_mapram  | w_bus_read_data_extslot;

	// --------------------------------------------------------------------
	//	EXTSLOT
	// --------------------------------------------------------------------
	ip_extslot u_extslot (
		.n_reset			( w_n_reset					),
		.clk				( clk						),
		.bus_address		( w_bus_address				),
		.bus_io_cs			( w_bus_io_cs_extslot		),
		.bus_memory_cs		( w_bus_memory_cs_extslot	),
		.bus_read_ready		( w_bus_read_ready_extslot	),
		.bus_read_data		( w_bus_read_data_extslot	),
		.bus_write_data		( w_bus_write_data			),
		.bus_read			( w_bus_read				),
		.bus_write			( w_bus_write				),
		.bus_io				( w_bus_io					),
		.bus_memory			( w_bus_memory				),
		.extslot_memory0	( w_extslot_memory0			),
		.extslot_memory1	( w_extslot_memory1			),
		.extslot_memory2	( w_extslot_memory2			),
		.extslot_memory3	( w_extslot_memory3			)
	);

	// --------------------------------------------------------------------
	//	MapperRAM
	// --------------------------------------------------------------------
	ip_mapperram u_mapperram (
		.n_reset			( w_n_reset					),
		.clk				( clk						),
		.bus_address		( w_bus_address				),
		.bus_io_cs			( w_bus_io_cs_mapram		),
		.bus_memory_cs		( w_bus_memory_cs_mapram	),
		.bus_read_ready		( w_bus_read_ready_mapram	),
		.bus_read_data		( w_bus_read_data_mapram	),
		.bus_write_data		( w_bus_write_data			),
		.bus_read			( w_bus_read				),
		.bus_write			( w_bus_write				),
		.bus_io				( w_bus_io					),
		.bus_memory			( w_extslot_memory3			),
		.rd					( w_psram0_rd				),
		.wr					( w_psram0_wr				),
		.busy				( w_psram0_busy				),
		.address			( w_psram0_address			),
		.wdata				( w_psram0_wdata			),
		.rdata				( w_psram0_rdata			),
		.rdata_en			( w_psram0_rdata_en			)
	);

	// --------------------------------------------------------------------
	//	PSRAM
	// --------------------------------------------------------------------
	ip_psram u_psram (
		.n_reset				( w_n_reset				),
		.clk					( clk					),
		.mem_clk				( mem_clk				),
		.lock					( mem_clk_lock			),
		.rd0					( w_psram0_rd			),
		.wr0					( w_psram0_wr			),
		.busy0					( w_psram0_busy			),
		.address0				( w_psram0_address		),
		.wdata0					( w_psram0_wdata		),
		.rdata0					( w_psram0_rdata		),
		.rdata0_en				( w_psram0_rdata_en		),
		.rd1					( 1'b0					),
		.wr1					( 1'b0					),
		.busy1					( 						),
		.address1				( 22'd0					),
		.wdata1					( 8'd0					),
		.rdata1					( 						),
		.rdata1_en				( 						),
		.O_psram_ck				( O_psram_ck			),
		.O_psram_ck_n			( O_psram_ck_n			),
		.IO_psram_rwds			( IO_psram_rwds			),
		.IO_psram_dq			( IO_psram_dq			),
		.O_psram_reset_n		( O_psram_reset_n		),
		.O_psram_cs_n			( O_psram_cs_n			)
	);

	// --------------------------------------------------------------------
	//	Sound
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !w_n_reset ) begin
			ff_1mhz_count <= 7'd0;
		end
		else if( w_1mhz ) begin
			ff_1mhz_count <= 7'd63;
		end
		else begin
			ff_1mhz_count <= ff_1mhz_count - 7'd1;
		end
	end
	assign w_1mhz	= (ff_1mhz_count == 7'd0);

	always @( posedge clk ) begin
		if( !w_n_reset ) begin
			ff_sound <= 8'h00;
		end
		else if( w_1mhz ) begin
			if( w_sound_flip ) begin
				if( ff_sound != 8'h00 ) begin
					ff_sound <= 8'h00;
				end
				else begin
					ff_sound <= ff_sound_level;
				end
			end
			else begin
				//	hold
			end
		end
	end

	always @( posedge clk ) begin
		if( !w_n_reset ) begin
			ff_div_count <= 16'd0;
		end
		else if( w_1mhz ) begin
			if( w_sound_flip ) begin
				ff_div_count <= ff_div_freq;
			end
			else begin
				ff_div_count <= ff_div_count - 16'd1;
			end
		end
	end
	assign w_sound_flip		= (ff_div_count == 16'd0);

	always @( posedge clk ) begin
		if( !w_n_reset ) begin
			ff_state_count <= 17'd100000;
		end
		else if( w_1mhz ) begin
			if( w_state_change ) begin
				ff_state_count <= 17'd100000;
			end
			else begin
				ff_state_count <= ff_state_count - 17'd1;
			end
		end
	end
	assign w_state_change	= (ff_state_count == 17'd0);

	always @( posedge clk ) begin
		if( !w_n_reset ) begin
			ff_state <= 3'd0;
		end
		else if( w_1mhz && w_state_change ) begin
			ff_state <= ff_state + 3'd1;
		end
	end

	always @( posedge clk ) begin
		if( !w_n_reset ) begin
			ff_div_freq		<= 16'd0;
			ff_sound_level	<= 8'hFF;
		end
		else if( w_1mhz ) begin
			if( w_state_change ) begin
				case( ff_state )
				3'd0:		ff_div_freq <= 16'd1911;	//	C4
				3'd1:		ff_div_freq <= 16'd1702;	//	D4
				3'd2:		ff_div_freq <= 16'd1516;	//	E4
				3'd3:		ff_div_freq <= 16'd1431;	//	F4
				3'd4:		ff_div_freq <= 16'd1275;	//	G4
				3'd5:		ff_div_freq <= 16'd1136;	//	A4
				3'd6:		ff_div_freq <= 16'd1012;	//	B4
				default:	ff_div_freq <= 16'd955;		//	C5
				endcase

				case( ff_state )
				3'd0:		ff_sound_level <= 8'hFF;	//	C4
				3'd1:		ff_sound_level <= 8'hCC;	//	D4
				3'd2:		ff_sound_level <= 8'hAA;	//	E4
				3'd3:		ff_sound_level <= 8'h88;	//	F4
				3'd4:		ff_sound_level <= 8'h66;	//	G4
				3'd5:		ff_sound_level <= 8'h44;	//	A4
				3'd6:		ff_sound_level <= 8'h22;	//	B4
				default:	ff_sound_level <= 8'd11;	//	C5
				endcase
			end
			else begin
				//	hold
			end
		end
	end

	ip_pwm u_pwm (
		.n_reset		( w_n_reset				),
		.clk			( clk					),
		.enable			( w_1mhz				),
		.signal_level	( { ff_sound, 8'd0 }	),
		.pwm_wave		( tsnd					)
	);

	// --------------------------------------------------------------------
	//	GPIO
	// --------------------------------------------------------------------
	ip_gpio #(
		.io_address		( 8'h01					)
	) u_gpio (
		.n_reset		( w_n_reset				),
		.clk			( clk					),
		.bus_address	( w_bus_address			),
		.bus_io_cs		( w_bus_io_cs_gpio		),
		.bus_memory_cs	( w_bus_memory_cs_gpio	),
		.bus_read_ready	( w_bus_read_ready_gpio	),
		.bus_read_data	( w_bus_read_data_gpio	),
		.bus_write_data	( w_bus_write_data		),
		.bus_read		( w_bus_read			),
		.bus_write		( w_bus_write			),
		.bus_io			( w_bus_io				),
		.bus_memory		( w_bus_memory			),
		.gpo			( w_gpo					),
		.gpi			( dip_sw				)
	);

	// --------------------------------------------------------------------
	//	GPIO_MEM
	// --------------------------------------------------------------------
	ip_gpio_mem #(
		.io_address		( 16'h8001					)
	) u_gpio_mem (
		.n_reset		( w_n_reset					),
		.clk			( clk						),
		.bus_address	( w_bus_address				),
		.bus_io_cs		( w_bus_io_cs_gpio_mem		),
		.bus_memory_cs	( w_bus_memory_cs_gpio_mem	),
		.bus_read_ready	( w_bus_read_ready_gpio_mem	),
		.bus_read_data	( w_bus_read_data_gpio_mem	),
		.bus_write_data	( w_bus_write_data			),
		.bus_read		( w_bus_read				),
		.bus_write		( w_bus_write				),
		.bus_io			( w_bus_io					),
		.bus_memory		( w_extslot_memory0			),
		.gpo			( w_gpo_mem					),
		.gpi			( dip_sw					)
	);

//	function [7:0] func_hex2chr(
//		input	[3:0]	hex
//	);
//		case( hex )
//		4'd0:		func_hex2chr = 8'h30;
//		4'd1:		func_hex2chr = 8'h31;
//		4'd2:		func_hex2chr = 8'h32;
//		4'd3:		func_hex2chr = 8'h33;
//		4'd4:		func_hex2chr = 8'h34;
//		4'd5:		func_hex2chr = 8'h35;
//		4'd6:		func_hex2chr = 8'h36;
//		4'd7:		func_hex2chr = 8'h37;
//		4'd8:		func_hex2chr = 8'h38;
//		4'd9:		func_hex2chr = 8'h39;
//		4'd10:		func_hex2chr = 8'h41;
//		4'd11:		func_hex2chr = 8'h42;
//		4'd12:		func_hex2chr = 8'h43;
//		4'd13:		func_hex2chr = 8'h44;
//		4'd14:		func_hex2chr = 8'h45;
//		4'd15:		func_hex2chr = 8'h46;
//		default:	func_hex2chr = 8'h30;
//		endcase
//	endfunction
//
//	always @( posedge clk ) begin
//		if( !n_reset ) begin
//			ff_ram_id	<= 1'b0;	//	0: u_psram0, 1: u_psram1
//			ff_address	<= 24'd0;	//	2^22 = 4MB, [23:22] = 2'b00 is dummy data
//			ff_state	<= 4'd0;
//			ff_wr0		<= 1'b0;
//			ff_rd0		<= 1'b0;
//			ff_wr1		<= 1'b0;
//			ff_rd1		<= 1'b0;
//			ff_failed	<= 1'b0;
//		end
//		else if( w_busy0 || w_busy1 || w_send_busy || ff_send_req || ff_wr0 || ff_wr1 || ff_rd0 || ff_rd1 ) begin
//			//	hold
//			ff_send_req		<= 1'b0;
//			ff_wr0			<= 1'b0;
//			ff_rd0			<= 1'b0;
//			ff_wr1			<= 1'b0;
//			ff_rd1			<= 1'b0;
//		end
//		else begin
//			if( ff_state == 4'd0 ) begin
//				ff_send_data	<= 8'h57;		//	'W'
//				ff_send_req		<= 1'b1;
//				ff_state		<= 4'd1;
//			end
//			//       [23:20]             [19:16]             [15:12]             [11:8]              [7:4]               [3:0]
//			else if( ff_state == 4'd1 || ff_state == 4'd2 || ff_state == 4'd3 || ff_state == 4'd4 || ff_state == 4'd5 || ff_state == 4'd6 ) begin
//				ff_send_data	<= func_hex2chr( ff_address[23:20] );
//				ff_send_req		<= 1'b1;
//				ff_state		<= ff_state + 4'd1;
//				ff_address		<= { ff_address[19:0], ff_address[23:20] };
//			end
//			else if( ff_state == 4'd7 ) begin
//				ff_send_data	<= 8'h3A;		//	':'
//				ff_send_req		<= 1'b1;
//				ff_state		<= ff_state + 4'd1;
//			end
//			else if( ff_state == 4'd8 ) begin
//				ff_wdata		<= ~ff_address[7:0];
//				ff_ram_id		<= ~ff_ram_id;
//				if( ff_ram_id == 1'b0 ) begin
//					ff_wr0		<= 1'b1;
//				end
//				else begin
//					ff_wr1		<= 1'b1;
//					ff_address	<= ff_address + 'd1;
//					if( ff_address[7:0] == 8'hFF ) begin
//						ff_state <= ff_state + 4'd1;
//					end
//				end
//			end
//			else if( ff_state == 4'd9 ) begin
//				ff_send_data	<= 8'h52;		//	'R'
//				ff_send_req		<= 1'b1;
//				ff_state		<= ff_state + 4'd1;
//			end
//			else if( ff_state == 4'd10 ) begin
//				ff_wdata		<= ~ff_address[7:0];
//				ff_state		<= ff_state + 4'd1;
//				if( ff_ram_id == 1'b0 ) begin
//					ff_rd0		<= 1'b1;
//				end
//				else begin
//					ff_rd1		<= 1'b1;
//					ff_address	<= ff_address + 'd1;
//				end
//			end
//			else if( ff_state == 4'd11 ) begin
//				if(      w_rdata0_en && (w_rdata0 != ff_wdata) ) begin
//					ff_failed	<= 1'b1;	//	Failed
//				end
//				else if( w_rdata1_en && (w_rdata1 != ff_wdata) ) begin
//					ff_failed	<= 1'b1;	//	Failed
//				end
//				if( w_rdata0_en || w_rdata1_en ) begin
//					if( ff_address[7:0] == 8'd0 ) begin
//						ff_state <= 4'd12;
//					end
//					else begin
//						ff_state <= 4'd10;
//					end
//				end
//			end
//			else if( ff_state == 4'd12 ) begin
//				if( ff_failed ) begin
//					ff_send_data	<= 8'h53;		//	'S'
//				end
//				else begin
//					ff_send_data	<= 8'h46;		//	'F'
//				end
//				ff_send_req		<= 1'b1;
//				ff_state		<= ff_state + 4'd1;
//			end
//			else if( ff_state == 4'd13 ) begin
//				ff_send_data	<= 8'h0D;		//	CR
//				ff_send_req		<= 1'b1;
//				ff_state		<= ff_state + 4'd1;
//			end
//			else if( ff_state == 4'd14 ) begin
//				ff_send_data	<= 8'h0A;		//	LF
//				ff_send_req		<= 1'b1;
//				if( ff_address[21:8] == 'b11_1111_1111 ) begin
//					ff_state		<= ff_state + 4'd1;
//				end
//				else begin
//					ff_state		<= 4'd0;
//				end
//			end
//			else begin
//				//	hold
//			end
//		end
//	end

	// --------------------------------------------------------------------
	//	UART
	// --------------------------------------------------------------------
//	always @( posedge clk ) begin
//		if( !w_n_reset ) begin
//			ff_cnt <= 26'd0;
//		end
//		else begin
//			ff_cnt <= ff_cnt + 26'd1;
//		end
//	end

//	reg		[3:0]	ff_state;
//	always @( posedge clk ) begin
//		if( !w_n_reset ) begin
//			ff_state <= 4'd0;
//			ff_send_data <= 8'd32;
//			ff_send_req <= 1'b0;
//		end
//		else if( w_send_busy == 1'b0 ) begin
//			ff_send_req <= 1'b1;
//			if( ff_state == 4'd12 ) begin
//				ff_state <= 4'd0;
//			end
//			else begin
//				ff_state <= ff_state + 4'd1;
//			end
//			//	HELLO! WORLD
//			case( ff_state )
//			4'd0:	ff_send_data <= 8'h48;
//			4'd1:	ff_send_data <= 8'h45;
//			4'd2:	ff_send_data <= 8'h4C;
//			4'd3:	ff_send_data <= 8'h4C;
//			4'd4:	ff_send_data <= 8'h4F;
//			4'd5:	ff_send_data <= 8'h21;
//			4'd6:	ff_send_data <= 8'h20;
//			4'd7:	ff_send_data <= 8'h57;
//			4'd8:	ff_send_data <= 8'h4F;
//			4'd9:	ff_send_data <= 8'h52;
//			4'd10:	ff_send_data <= 8'h4C;
//			4'd11:	ff_send_data <= 8'h44;
//			4'd12:	ff_send_data <= 8'h20;
//			endcase
//		end
//	end

//	ip_uart #(
//		.clk_freq		( 54000000			),
//		.uart_freq		( 115200			)
//	) u_uart (
//		.n_reset		( w_n_reset			),
//		.clk			( clk				),
//		.send_data		( ff_send_data		),
//		.send_req		( ff_send_req		),
//		.send_busy		( w_send_busy		),
//		.uart_tx		( uart_tx			)
//	);
endmodule
