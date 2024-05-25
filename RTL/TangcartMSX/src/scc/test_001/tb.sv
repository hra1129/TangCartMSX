// -----------------------------------------------------------------------------
//	Test of ip_scc.v
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
//		Pulse wave modulation
// -----------------------------------------------------------------------------

module tb ();
	localparam		clk_base	= 1000000000/64432;
	reg				n_reset;
	reg				clk;
	wire			enable;
	reg		[15:0]	bus_address;
	wire			bus_read_ready;
	wire	[7:0]	bus_read_data;
	reg		[7:0]	bus_write_data;
	reg				bus_read;
	reg				bus_write;
	reg				bus_memory;
	reg				scc_bank_en;
	reg				sccp_bank_en;
	reg				sccp_en;
	wire	[10:0]	sound_out;		//	digital sound wire (11 bits)
	reg		[1:0]	ff_enable;
	integer			i;

	// --------------------------------------------------------------------
	//	DUT
	// --------------------------------------------------------------------
	ip_scc u_scc (
		.n_reset			( n_reset			),
		.clk				( clk				),
		.enable				( enable			),
		.bus_address		( bus_address		),
		.bus_read_ready		( bus_read_ready	),
		.bus_read_data		( bus_read_data		),
		.bus_write_data		( bus_write_data	),
		.bus_read			( bus_read			),
		.bus_write			( bus_write			),
		.bus_memory			( bus_memory		),
		.scc_bank_en		( scc_bank_en		),
		.sccp_bank_en		( sccp_bank_en		),
		.sccp_en			( sccp_en			),
		.sound_out			( sound_out			)
	);

	// --------------------------------------------------------------------
	//	clock
	// --------------------------------------------------------------------
	always #(clk_base/2) begin
		clk <= ~clk;
	end

	always @( negedge n_reset or posedge clk ) begin
		if( !n_reset ) begin
			ff_enable <= 2'd0;
		end
		else if( ff_enable == 2'd2 ) begin
			ff_enable <= 2'd0;
		end
		else begin
			ff_enable <= ff_enable + 2'd1;
		end
	end

	assign enable = ( ff_enable == 2'd2 );

	// --------------------------------------------------------------------
	//	Test bench
	// --------------------------------------------------------------------
	initial begin
		n_reset = 0;
		clk = 0;
		bus_address = 0;
		bus_write_data = 0;
		bus_read = 0;
		bus_write = 0;
		bus_memory = 0;
		scc_bank_en = 0;
		sccp_bank_en = 0;
		sccp_en = 0;

		@( negedge clk );
		@( negedge clk );
		@( posedge clk );

		n_reset			= 1;
		repeat( 10 ) @( posedge clk );

		$finish;
	end
endmodule
