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
	wire			clk,
	wire			n_clk,
	wire			w_n_reset;
	reg		[7:0]	ff_send_data;
	reg				ff_send_req;
	wire			w_send_busy;
	reg		[20:0]	ff_cnt;

	// --------------------------------------------------------------------
	//	OUTPUT Assignment
	// --------------------------------------------------------------------
	assign w_n_reset	= n_reset;	// & n_treset;
	assign tf_cs		= 1'b0;
	assign tf_mosi		= 1'b0;
	assign tf_sclk		= 1'b0;
	assign n_twait		= 1'bZ;
	assign n_tint		= 1'bZ;
	assign tsnd			= 1'b0;
	assign toe			= 1'b0;
	assign td			= 8'dZ;
	assign n_led		= { ff_cnt[20], ff_state };	//6'b101010;

	// --------------------------------------------------------------------
	//	PLL 27MHz --> 81MHz
	// --------------------------------------------------------------------
	Gowin_rPLL your_instance_name(
		.clkout			( clk				),	// output	clkout
		.clkoutp		( n_clk				),	// output	clkoutp
		.clkin			( sys_clk			)	// input	clkin
	);

	// --------------------------------------------------------------------
	//	MSX 50BUS
	// --------------------------------------------------------------------
	ip_msxbus u_msxbus (
		.n_reset		( n_reset			),
		.clk			( clk				),
		.adr			( adr				),
		.i_data			( i_data			),
		.o_data			( o_data			),
		.is_output		( is_output			),
		.n_sltsl		( n_sltsl			),
		.n_rd			( n_rd				),
		.n_wr			( n_wr				),
		.n_ioreq		( n_ioreq			),
		.n_mereq		( n_mereq			),
		.bus_address	( bus_address		),
		.bus_io_cs		( bus_io_cs			),
		.bus_memory_cs	( bus_memory_cs		),
		.bus_read_ready	( bus_read_ready	),
		.bus_read_data	( bus_read_data		),
		.bus_write_data	( bus_write_data	),
		.bus_read		( bus_read			),
		.bus_write		( bus_write			),
		.bus_io			( bus_io			),
		.bus_memory		( bus_memory		)
	);

	// --------------------------------------------------------------------
	//	PSRAM
	// --------------------------------------------------------------------

	// --------------------------------------------------------------------
	//	UART
	// --------------------------------------------------------------------
	always @( negedge w_n_reset or posedge sys_clk ) begin
		if( !w_n_reset ) begin
			ff_cnt <= 21'd0;
		end
		else begin
			ff_cnt <= ff_cnt + 21'd1;
		end
	end

	reg		[3:0]	ff_state;
	always @( negedge w_n_reset or posedge sys_clk ) begin
		if( !w_n_reset ) begin
			ff_state <= 4'd0;
			ff_send_data <= 8'd32;
			ff_send_req <= 1'b0;
		end
		else if( w_send_busy == 1'b0 ) begin
			ff_send_req <= 1'b1;
			if( ff_state == 4'd12 ) begin
				ff_state <= 4'd0;
			end
			else begin
				ff_state <= ff_state + 4'd1;
			end
			//	HELLO! WORLD
			case( ff_state )
			4'd0:	ff_send_data <= 8'h48;
			4'd1:	ff_send_data <= 8'h45;
			4'd2:	ff_send_data <= 8'h4C;
			4'd3:	ff_send_data <= 8'h4C;
			4'd4:	ff_send_data <= 8'h4F;
			4'd5:	ff_send_data <= 8'h21;
			4'd6:	ff_send_data <= 8'h20;
			4'd7:	ff_send_data <= 8'h57;
			4'd8:	ff_send_data <= 8'h4F;
			4'd9:	ff_send_data <= 8'h52;
			4'd10:	ff_send_data <= 8'h4C;
			4'd11:	ff_send_data <= 8'h44;
			4'd12:	ff_send_data <= 8'h20;
			endcase
		end
	end

	ip_uart #(
		.clk_freq		( 27000000			),
		.uart_freq		( 115200			)
	) u_uart (
		.n_reset		( w_n_reset			),
		.clk			( sys_clk			),
		.send_data		( ff_send_data		),
		.send_req		( ff_send_req		),
		.send_busy		( w_send_busy		),
		.uart_tx		( uart_tx			)
	);
endmodule
