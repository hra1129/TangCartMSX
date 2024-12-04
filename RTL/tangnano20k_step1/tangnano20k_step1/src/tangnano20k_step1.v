// -----------------------------------------------------------------------------
//	tangnano20k_step1.v
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

module tangnano20k_step1 (
	input			clk,			//	27MHz
	input	[1:0]	button,
	output			uart_tx
);
	reg				ff_reset_n = 1'b0;
	reg		[1:0]	ff_clock_div = 2'd0;
	wire			w_enable;

	wire			wait_n;
	wire			int_n;
	wire			nmi_n;
	wire			busrq_n;
	wire			m1_n;
	wire			mreq_n;
	wire			iorq_n;
	wire			rd_n;
	wire			wr_n;
	wire			rfsh_n;
	wire			halt_n;
	wire			busak_n;
	wire	[15:0]	a;
	wire	[7:0]	d;

	// --------------------------------------------------------------------
	//	clock
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !ff_reset_n ) begin
			ff_clock_div <= 3'd0;
		end
		else begin
			ff_clock_div <= ff_clock_div + 2'd1;
		end
	end
	assign w_enable		= (ff_clock_div == 2'd3);

	// --------------------------------------------------------------------
	//	reset
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( button[0] == 1'b0 ) begin
			ff_reset_n <= 1'b1;
		end
	end

	// --------------------------------------------------------------------
	//	Z80 core
	// --------------------------------------------------------------------
	cz80_inst u_z80 (
		.reset_n		( ff_reset_n	),
		.clk_n			( clk			),
		.enable			( w_enable		),
		.wait_n			( wait_n		),
		.int_n			( int_n			),
		.nmi_n			( nmi_n			),
		.busrq_n		( busrq_n		),
		.m1_n			( m1_n			),
		.mreq_n			( mreq_n		),
		.iorq_n			( iorq_n		),
		.rd_n			( rd_n			),
		.wr_n			( wr_n			),
		.rfsh_n			( rfsh_n		),
		.halt_n			( halt_n		),
		.busak_n		( busak_n		),
		.a				( a				),
		.d				( d				)
	);

	// --------------------------------------------------------------------
	//	UART
	// --------------------------------------------------------------------
	ip_uart #(
		.clk_freq		( 27000000		),
		.uart_freq		( 115200		)
	) u_uart (
		n_reset			( ff_reset_n	),
		clk				( clk			),
		send_data		( w_send_data	),
		send_req		( w_send_req	),
		send_busy		( w_send_ack	),
		uart_tx			( uart_tx		)
	);

endmodule
