// -----------------------------------------------------------------------------
//	Test of ip_msxbus.v
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
//		The role of protocol conversion by replacing the asynchronous MSXBUS 
//		signal with an internal clock.
// -----------------------------------------------------------------------------

module tb ();
	localparam		sys_clk_base	= 1000000000/27000;
	localparam		clk_base		= 1000000000/64422;
	//	Internal I/F
	reg				n_reset;
	reg				sys_clk;
	reg				clk;
	reg				mem_clk;
	reg				lock;
	wire			initial_busy;
	//	1st PSRAM
	reg				rd0;			// Set to 1 to read
	reg				wr0;			// Set to 1 to write
	wire			busy0;
	reg		[21:0]	address0;		// Byte address
	reg		[7:0]	wdata0;
	wire	[7:0]	rdata0;
	wire			rdata0_en;
	//	2nd PSRAM
	reg				rd1;			// Set to 1 to read
	reg				wr1;			// Set to 1 to write
	wire			busy1;
	reg		[21:0]	address1;		// Byte address
	reg		[7:0]	wdata1;
	wire	[7:0]	rdata1;
	wire			rdata1_en;
	//	PSRAM I/F
	wire	[1:0]	O_psram_ck;
	wire	[1:0]	O_psram_ck_n;
	wire	[1:0]	IO_psram_rwds;
	wire	[15:0]	IO_psram_dq;
	wire	[1:0]	O_psram_reset_n;
	wire	[1:0]	O_psram_cs_n;
	integer			test_no;

	// --------------------------------------------------------------------
	//	DUT
	// --------------------------------------------------------------------
	ip_psram u_psram (
		.n_reset			( n_reset			),
		.sys_clk			( sys_clk			),
		.clk				( clk				),
		.mem_clk			( mem_clk			),
		.lock				( lock				),
		.initial_busy		( initial_busy		),
		.rd0				( rd0				),
		.wr0				( wr0				),
		.busy0				( busy0				),
		.address0			( address0			),
		.wdata0				( wdata0			),
		.rdata0				( rdata0			),
		.rdata0_en			( rdata0_en			),
		.rd1				( rd1				),
		.wr1				( wr1				),
		.busy1				( busy1				),
		.address1			( address1			),
		.wdata1				( wdata1			),
		.rdata1				( rdata1			),
		.rdata1_en			( rdata1_en			),
		.O_psram_ck			( O_psram_ck		),
		.O_psram_ck_n		( O_psram_ck_n		),
		.IO_psram_rwds		( IO_psram_rwds		),
		.IO_psram_dq		( IO_psram_dq		),
		.O_psram_reset_n	( O_psram_reset_n	),
		.O_psram_cs_n		( O_psram_cs_n		)
	);

	// --------------------------------------------------------------------
	//	clock
	// --------------------------------------------------------------------
	always #(sys_clk_base/2) begin
		sys_clk <= ~sys_clk;
	end

	always #(clk_base/4) begin
		mem_clk <= ~mem_clk;
	end

	always @( posedge mem_clk ) begin
		clk <= ~clk;
	end

	// --------------------------------------------------------------------
	//	Test bench
	// --------------------------------------------------------------------
	initial begin
		test_no = 0;
		n_reset = 0;
		sys_clk = 0;
		clk = 0;
		mem_clk = 0;
		lock = 0;
		rd0 = 0;
		wr0 = 0;
		address0 = 0;
		wdata0 = 0;
		rd1 = 0;
		wr1 = 0;
		address1 = 0;
		wdata1 = 0;

		@( negedge sys_clk );
		@( negedge sys_clk );

		n_reset = 1;
		@( negedge sys_clk );
		repeat( 10 ) @( posedge sys_clk );

		// --------------------------------------------------------------------
		//	Wait complete of initial busy
		// --------------------------------------------------------------------
		while( initial_busy == 1'b1 ) begin
			@( posedge sys_clk );
		end
		@( posedge sys_clk );

		// --------------------------------------------------------------------
		//	write access
		// --------------------------------------------------------------------
		test_no = 1;

		wr0 <= 1;
		address0 <= 123456;
		@( posedge sys_clk );

		wr0 <= 0;
		address0 <= 0;
		@( posedge sys_clk );
		@( posedge sys_clk );
		@( posedge sys_clk );
		@( posedge sys_clk );
		@( posedge sys_clk );
		@( posedge sys_clk );

		wr0 <= 1;
		address0 <= 234567;
		@( posedge sys_clk );

		wr0 <= 0;
		address0 <= 0;
		@( posedge sys_clk );
		@( posedge sys_clk );
		@( posedge sys_clk );
		@( posedge sys_clk );
		@( posedge sys_clk );
		@( posedge sys_clk );

		wr0 <= 1;
		address0 <= 345678;
		@( posedge sys_clk );

		wr0 <= 0;
		address0 <= 0;
		@( posedge sys_clk );
		@( posedge sys_clk );
		@( posedge sys_clk );
		@( posedge sys_clk );
		@( posedge sys_clk );
		@( posedge sys_clk );

		// --------------------------------------------------------------------
		//	read access
		// --------------------------------------------------------------------
		test_no = 2;

		rd0 <= 1;
		address0 <= 123456;
		@( posedge sys_clk );

		rd0 <= 0;
		address0 <= 0;
		@( posedge sys_clk );
		@( posedge sys_clk );
		@( posedge sys_clk );
		@( posedge sys_clk );
		@( posedge sys_clk );
		@( posedge sys_clk );

		rd0 <= 1;
		address0 <= 234567;
		@( posedge sys_clk );

		rd0 <= 0;
		address0 <= 0;
		@( posedge sys_clk );
		@( posedge sys_clk );
		@( posedge sys_clk );
		@( posedge sys_clk );
		@( posedge sys_clk );
		@( posedge sys_clk );

		rd0 <= 1;
		address0 <= 345678;
		@( posedge sys_clk );

		rd0 <= 0;
		address0 <= 0;
		@( posedge sys_clk );
		@( posedge sys_clk );
		@( posedge sys_clk );
		@( posedge sys_clk );
		@( posedge sys_clk );
		@( posedge sys_clk );

		$finish;
	end
endmodule
