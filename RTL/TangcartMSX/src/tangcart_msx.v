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
	input			n_reset,
	output			tf_cs,
	output			tf_mosi,
	output			tf_sclk,
	input			tf_miso,
	output			n_twait,
	output			n_tint,
	input			n_tiorq,
	input			n_tmerq,
	input			n_twr,
	input			n_trd,
	input			n_treset,
	input	[15:0]	ta,
	inout	[7:0]	td,
	output			tsnd,
	output			toe,
	input			n_tsltsl,
	output	[5:0]	n_led,
	// PSRAM ports
	output	[1:0]	O_psram_ck,
	output	[1:0]	O_psram_ck_n,
	inout	[1:0]	IO_psram_rwds,
	inout	[15:0]	IO_psram_dq,
	output	[1:0]	O_psram_reset_n,
	output	[1:0]	O_psram_cs_n,
	// UART
	output			uart_tx
);
	wire			clk;
	wire			n_clk;
	wire			w_n_reset;
	reg		[7:0]	ff_send_data;
	reg				ff_send_req;
	wire			w_send_busy;
	reg		[25:0]	ff_cnt;
	reg		[23:0]	ff_address;
	reg		[7:0]	ff_wdata;
	reg				ff_rd0;
	reg				ff_wr0;
	wire			w_busy0;
	wire	[7:0]	w_rdata0;
	wire			w_rdata0_en;
	reg				ff_rd1;
	reg				ff_wr1;
	wire			w_busy1;
	wire	[7:0]	w_rdata1;
	wire			w_rdata1_en;
	reg				ff_ram_id;
	reg		[3:0]	ff_state;
	reg				ff_failed;

	// --------------------------------------------------------------------
	//	OUTPUT Assignment
	// --------------------------------------------------------------------
	assign w_n_reset			= n_reset;	// & n_treset;
	assign tf_cs				= 1'b0;
	assign tf_mosi				= 1'b0;
	assign tf_sclk				= 1'b0;
	assign n_twait				= 1'bZ;
	assign n_tint				= 1'bZ;
	assign tsnd					= 1'b0;
	assign toe					= 1'b0;
	assign td					= 8'dZ;
	assign n_led				= { w_busy1, w_busy0, ff_state };

	// --------------------------------------------------------------------
	//	PLL 27MHz --> 81MHz
	// --------------------------------------------------------------------
	Gowin_PLL u_pll (
		.clkout			( mem_clk			),		//output	108MHz
		.lock			( mem_clk_lock		),		//output	lock
		.clkoutd		( clk				),		//output	54MHz
		.clkin			( sys_clk			)		//input		27MHz
	);

	// --------------------------------------------------------------------
	//	MSX 50BUS
	// --------------------------------------------------------------------
//	ip_msxbus u_msxbus (
//		.n_reset		( n_reset			),
//		.clk			( clk				),
//		.adr			( adr				),
//		.i_data			( i_data			),
//		.o_data			( o_data			),
//		.is_output		( is_output			),
//		.n_sltsl		( n_sltsl			),
//		.n_rd			( n_rd				),
//		.n_wr			( n_wr				),
//		.n_ioreq		( n_ioreq			),
//		.n_mereq		( n_mereq			),
//		.bus_address	( bus_address		),
//		.bus_io_cs		( bus_io_cs			),
//		.bus_memory_cs	( bus_memory_cs		),
//		.bus_read_ready	( bus_read_ready	),
//		.bus_read_data	( bus_read_data		),
//		.bus_write_data	( bus_write_data	),
//		.bus_read		( bus_read			),
//		.bus_write		( bus_write			),
//		.bus_io			( bus_io			),
//		.bus_memory		( bus_memory		)
//	);

	// --------------------------------------------------------------------
	//	PSRAM
	// --------------------------------------------------------------------
	function [7:0] func_hex2chr(
		input	[3:0]	hex
	);
		case( hex )
		4'd0:		func_hex2chr = 8'h30;
		4'd1:		func_hex2chr = 8'h31;
		4'd2:		func_hex2chr = 8'h32;
		4'd3:		func_hex2chr = 8'h33;
		4'd4:		func_hex2chr = 8'h34;
		4'd5:		func_hex2chr = 8'h35;
		4'd6:		func_hex2chr = 8'h36;
		4'd7:		func_hex2chr = 8'h37;
		4'd8:		func_hex2chr = 8'h38;
		4'd9:		func_hex2chr = 8'h39;
		4'd10:		func_hex2chr = 8'h41;
		4'd11:		func_hex2chr = 8'h42;
		4'd12:		func_hex2chr = 8'h43;
		4'd13:		func_hex2chr = 8'h44;
		4'd14:		func_hex2chr = 8'h45;
		4'd15:		func_hex2chr = 8'h46;
		default:	func_hex2chr = 8'h30;
		endcase
	endfunction

	always @( negedge n_reset or posedge clk ) begin
		if( !n_reset ) begin
			ff_ram_id	<= 1'b0;	//	0: u_psram0, 1: u_psram1
			ff_address	<= 24'd0;	//	2^22 = 4MB, [23:22] = 2'b00 is dummy data
			ff_state	<= 4'd0;
			ff_wr0		<= 1'b0;
			ff_rd0		<= 1'b0;
			ff_wr1		<= 1'b0;
			ff_rd1		<= 1'b0;
			ff_failed	<= 1'b0;
		end
		else if( w_busy0 || w_busy1 || w_send_busy || ff_send_req || ff_wr0 || ff_wr1 || ff_rd0 || ff_rd1 ) begin
			//	hold
			ff_send_req		<= 1'b0;
			ff_wr0			<= 1'b0;
			ff_rd0			<= 1'b0;
			ff_wr1			<= 1'b0;
			ff_rd1			<= 1'b0;
		end
		else begin
			if( ff_state == 4'd0 ) begin
				ff_send_data	<= 8'h57;		//	'W'
				ff_send_req		<= 1'b1;
				ff_state		<= 4'd1;
			end
			//       [23:20]             [19:16]             [15:12]             [11:8]              [7:4]               [3:0]
			else if( ff_state == 4'd1 || ff_state == 4'd2 || ff_state == 4'd3 || ff_state == 4'd4 || ff_state == 4'd5 || ff_state == 4'd6 ) begin
				ff_send_data	<= func_hex2chr( ff_address[23:20] );
				ff_send_req		<= 1'b1;
				ff_state		<= ff_state + 4'd1;
				ff_address		<= { ff_address[19:0], ff_address[23:20] };
			end
			else if( ff_state == 4'd7 ) begin
				ff_send_data	<= 8'h3A;		//	':'
				ff_send_req		<= 1'b1;
				ff_state		<= ff_state + 4'd1;
			end
			else if( ff_state == 4'd8 ) begin
				ff_wdata		<= ~ff_address[7:0];
				ff_ram_id		<= ~ff_ram_id;
				if( ff_ram_id == 1'b0 ) begin
					ff_wr0		<= 1'b1;
				end
				else begin
					ff_wr1		<= 1'b1;
					ff_address	<= ff_address + 'd1;
					if( ff_address[7:0] == 8'hFF ) begin
						ff_state <= ff_state + 4'd1;
					end
				end
			end
			else if( ff_state == 4'd9 ) begin
				ff_send_data	<= 8'h52;		//	'R'
				ff_send_req		<= 1'b1;
				ff_state		<= ff_state + 4'd1;
			end
			else if( ff_state == 4'd10 ) begin
				ff_wdata		<= ~ff_address[7:0];
				ff_state		<= ff_state + 4'd1;
				if( ff_ram_id == 1'b0 ) begin
					ff_rd0		<= 1'b1;
				end
				else begin
					ff_rd1		<= 1'b1;
					ff_address	<= ff_address + 'd1;
				end
			end
			else if( ff_state == 4'd11 ) begin
				if(      w_rdata0_en && (w_rdata0 != ff_wdata) ) begin
					ff_failed	<= 1'b1;	//	Failed
				end
				else if( w_rdata1_en && (w_rdata1 != ff_wdata) ) begin
					ff_failed	<= 1'b1;	//	Failed
				end
				if( w_rdata0_en || w_rdata1_en ) begin
					if( ff_address[7:0] == 8'd0 ) begin
						ff_state <= 4'd12;
					end
					else begin
						ff_state <= 4'd10;
					end
				end
			end
			else if( ff_state == 4'd12 ) begin
				if( ff_failed ) begin
					ff_send_data	<= 8'h53;		//	'S'
				end
				else begin
					ff_send_data	<= 8'h46;		//	'F'
				end
				ff_send_req		<= 1'b1;
				ff_state		<= ff_state + 4'd1;
			end
			else if( ff_state == 4'd13 ) begin
				ff_send_data	<= 8'h0D;		//	CR
				ff_send_req		<= 1'b1;
				ff_state		<= ff_state + 4'd1;
			end
			else if( ff_state == 4'd14 ) begin
				ff_send_data	<= 8'h0A;		//	LF
				ff_send_req		<= 1'b1;
				if( ff_address[21:8] == 'b11_1111_1111 ) begin
					ff_state		<= ff_state + 4'd1;
				end
				else begin
					ff_state		<= 4'd0;
				end
			end
			else begin
				//	hold
			end
		end
	end

	ip_psram u_psram (
		.n_reset				( n_reset				),
		.clk					( clk					),
		.mem_clk				( mem_clk				),
		.lock					( mem_clk_lock			),
		.rd0					( ff_rd0				),
		.wr0					( ff_wr0				),
		.busy0					( w_busy0				),
		.address0				( ff_address			),
		.wdata0					( ff_wdata				),
		.rdata0					( w_rdata0				),
		.rdata0_en				( w_rdata0_en			),
		.rd1					( ff_rd1				),
		.wr1					( ff_wr1				),
		.busy1					( w_busy1				),
		.address1				( ff_address			),
		.wdata1					( ff_wdata				),
		.rdata1					( w_rdata1				),
		.rdata1_en				( w_rdata1_en			),
		.O_psram_ck				( O_psram_ck			),
		.O_psram_ck_n			( O_psram_ck_n			),
		.IO_psram_rwds			( IO_psram_rwds			),
		.IO_psram_dq			( IO_psram_dq			),
		.O_psram_reset_n		( O_psram_reset_n		),
		.O_psram_cs_n			( O_psram_cs_n			)
	);

	// --------------------------------------------------------------------
	//	UART
	// --------------------------------------------------------------------
	always @( negedge w_n_reset or posedge clk ) begin
		if( !w_n_reset ) begin
			ff_cnt <= 26'd0;
		end
		else begin
			ff_cnt <= ff_cnt + 26'd1;
		end
	end

//	reg		[3:0]	ff_state;
//	always @( negedge w_n_reset or posedge clk ) begin
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

	ip_uart #(
		.clk_freq		( 54000000			),
		.uart_freq		( 115200			)
	) u_uart (
		.n_reset		( w_n_reset			),
		.clk			( clk				),
		.send_data		( ff_send_data		),
		.send_req		( ff_send_req		),
		.send_busy		( w_send_busy		),
		.uart_tx		( uart_tx			)
	);
endmodule
