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
	output	[5:0]	n_led,
	input	[1:0]	button,
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
	reg		[6:0]	ff_reset = 7'd0;
	wire			clk;
	wire			clk_n;
//	wire			mem_clk;
//	wire			mem_clk_lock;
	wire			w_n_reset;
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
	wire	[7:0]	w_send_data;
	wire			w_send_req;
	wire			w_send_busy;
	wire	[7:0]	w_pc;

	// --------------------------------------------------------------------
	//	OUTPUT Assignment
	// --------------------------------------------------------------------
	assign w_n_reset	= ff_reset[6];
	assign n_led		= ~w_psram0_address[21:16];
//	assign n_led		= ~w_pc[5:0];

	always @( posedge clk ) begin
		ff_reset[5:0]	<= { ff_reset[4:0], button[0] };
		ff_reset[6]		<= (ff_reset[5:0] == 6'b111111) ? 1'b1 : 1'b0;
	end

	// --------------------------------------------------------------------
	//	PLL
	// --------------------------------------------------------------------
	Gowin_PLL u_pll (
		.clkout				( mem_clk					),		//output	108.0MHz
		.lock				( mem_clk_lock				),		//output	lock
		.clkoutd			( clk						),		//output	54.0MHz
		.clkin				( sys_clk					)		//input		27.0MHz
	);

	// --------------------------------------------------------------------
	//	PSRAM Test Module
	// --------------------------------------------------------------------
	ip_psram_tester u_psram_tester (
		.n_reset			( w_n_reset					),
		.clk				( clk						),
		.rd0				( w_psram0_rd				),
		.wr0				( w_psram0_wr				),
		.address0			( w_psram0_address			),
		.wdata0				( w_psram0_wdata			),
		.rdata0				( w_psram0_rdata			),
		.rdata_en0			( w_psram0_rdata_en			),
		.busy0				( w_psram0_busy				),
		.rd1				( w_psram1_rd				),
		.wr1				( w_psram1_wr				),
		.address1			( w_psram1_address			),
		.wdata1				( w_psram1_wdata			),
		.rdata1				( w_psram1_rdata			),
		.rdata_en1			( w_psram1_rdata_en			),
		.busy1				( w_psram1_busy				),
		.send_data			( w_send_data				),
		.send_req			( w_send_req				),
		.send_busy			( w_send_busy				),
		.pc					( w_pc						)
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
		.rd1					( w_psram1_rd			),
		.wr1					( w_psram1_wr			),
		.busy1					( w_psram1_busy			),
		.address1				( w_psram1_address		),
		.wdata1					( w_psram1_wdata		),
		.rdata1					( w_psram1_rdata		),
		.rdata1_en				( w_psram1_rdata_en		),
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
	ip_uart #(
		.clk_freq				( 54000000				),
		.uart_freq				( 115200				)
	) u_uart (
		.n_reset				( w_n_reset				),
		.clk					( clk					),
		.send_data				( w_send_data			),
		.send_req				( w_send_req			),
		.send_busy				( w_send_busy			),
		.uart_tx				( uart_tx				)
	);
endmodule
