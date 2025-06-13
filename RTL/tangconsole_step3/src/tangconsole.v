// -----------------------------------------------------------------------------
//	tangconsole_step3.v
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

module tangconsole_step3 (
	input			clk,			//	clk			V22 (50MHz)
	output	[7:0]	led				//	led[7:0]	V18, V19, G21, G22, F18, E18, C22, B22
);
	reg				ff_reset_n = 1'b0;
	wire			clk7m;
	wire			enable;
	wire			mreq_n;
	wire			iorq_n;
	wire			rd_n;
	wire			wr_n;
	wire			rfsh_n;
	wire			halt_n;
	wire			busak_n;
	wire	[15:0]	address;
	wire	[7:0]	data;
	wire	[7:0]	gpio_q;
	wire			gpio_q_en;
	wire			rom_cs_n;
	wire	[7:0]	rom_q;
	wire			rom_q_en;
	wire			ram_cs_n;
	wire	[7:0]	ram_q;
	wire			ram_q_en;
	reg				ff_4m;
	reg		[20:0]	ff_count = 0;	//	***

	always @( posedge clk7m ) begin
		ff_count <= ff_count + 21'd1;
	end

	assign led = ff_count[20:13];

	// --------------------------------------------------------------------
	//	RESET
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		ff_reset_n <= 1'b1;
	end

	always @( posedge clk7m ) begin
		if( !ff_reset_n ) begin
			ff_4m <= 1'b0;
		end
		else begin
			ff_4m <= ~ff_4m;
		end
	end

	// --------------------------------------------------------------------
	//	CPU
	// --------------------------------------------------------------------
	SSCPLL_Top u_pll (
		.clkin			( clk			),	//	input 50MHz
		.rstn			( ff_reset_n	),	//	input RESET_N
		.init_clk		( clk			),	//	input 50MHz
		.clkout			( clk7m			)	//	output 7.158MHz
	);
	// --------------------------------------------------------------------
	//	CPU
	// --------------------------------------------------------------------
	cz80_inst u_z80 (
		.reset_n		( ff_reset_n	),
		.clk_n			( clk7m			),
		.enable			( ff_4m			),
		.wait_n			( 1'b1			),
		.int_n			( 1'b1			),
		.nmi_n			( 1'b1			),
		.busrq_n		( 1'b1			),
		.m1_n			( 				),
		.mreq_n			( mreq_n		),
		.iorq_n			( iorq_n		),
		.rd_n			( rd_n			),
		.wr_n			( wr_n			),
		.rfsh_n			( rfsh_n		),
		.halt_n			( halt_n		),
		.busak_n		( busak_n		),
		.a				( address		),
		.d				( data			)
	);

	assign data		= ( rd_n		) ? 8'hZZ	:
					  ( gpio_q_en	) ? gpio_q	:
					  ( ram_q_en	) ? ram_q	:
					  ( rom_q_en	) ? rom_q	: 8'hFF;

	// --------------------------------------------------------------------
	//	ROM ( 0000h-3FFFh )
	// --------------------------------------------------------------------
	ip_led_count_rom u_rom (
		.clk			( clk7m			),
		.n_cs			( rom_cs_n		),
		.n_rd			( rd_n			),
		.address		( address[13:0]	),
		.rdata			( rom_q			),
		.rdata_en		( rom_q_en		)
	);

	assign rom_cs_n	= ( !mreq_n && address[15:14] == 2'b00 ) ? 1'b0: 1'b1;

	// --------------------------------------------------------------------
	//	RAM ( 4000h-7FFFh )
	// --------------------------------------------------------------------
	ip_ram u_ram (
		.clk			( clk7m			),
		.n_cs			( ram_cs_n		),
		.n_wr			( wr_n			),
		.n_rd			( rd_n			),
		.address		( address[13:0]	),
		.wdata			( wdata			),
		.rdata			( ram_q			),
		.rdata_en		( ram_q_en		)
	);

	assign ram_cs_n	= ( !mreq_n && address[15:14] == 2'b01 ) ? 1'b0: 1'b1;

	// --------------------------------------------------------------------
	//	GPIO
	// --------------------------------------------------------------------
	ip_gpio #(
		.io_address		( 8'h10			)
	) u_gpio (
		.reset_n		( ff_reset_n	),
		.clk			( clk7m			),
		.iorq_n			( iorq_n		),
		.address		( address[7:0]	),
		.rd_n			( rd_n			),
		.wr_n			( wr_n			),
		.d				( d				),
		.q				( gpio_q		),
		.q_en			( gpio_q_en		),
		.gpo			( 				),
		.gpi			( 8'd0			)
	);
endmodule
