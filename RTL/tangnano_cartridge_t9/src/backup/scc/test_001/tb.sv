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
	integer			test_no;

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
	//	Tasks
	// --------------------------------------------------------------------
	task write_memory(
		input	[15:0]	address,
		input	[7:0]	data
	);
		bus_address		<= address;
		bus_write_data	<= data;
		bus_write		<= 1'b1;
		bus_memory		<= 1'b1;
		@( posedge clk );

		bus_address		<= 'd0;
		bus_write_data	<= 'd0;
		bus_write		<= 1'b0;
		bus_memory		<= 1'b0;
		@( posedge clk );
		@( posedge clk );
		@( posedge clk );
	endtask: write_memory

	task read_memory(
		input	[15:0]	address,
		input	[7:0]	data
	);
		integer count;
	
		bus_address		<= address;
		bus_read		<= 1'b1;
		bus_memory		<= 1'b1;
		@( posedge clk );

		bus_address		<= 'd0;
		bus_read		<= 1'b0;
		bus_memory		<= 1'b0;
		@( posedge clk );

		count = 0;
		while( !bus_read_ready && count < 100 ) begin
			@( posedge clk );
			count = count + 1;
		end

		assert( count < 100 );
		assert( bus_read_data == data );
		@( posedge clk );
		@( posedge clk );
		@( posedge clk );
	endtask: read_memory

	task read_memory_timeout(
		input	[15:0]	address
	);
		int counter;

		bus_address		<= address;
		bus_read		<= 1'b1;
		bus_memory		<= 1'b1;
		@( posedge clk );

		bus_address		<= 'd0;
		bus_read		<= 1'b0;
		bus_memory		<= 1'b0;
		@( posedge clk );

		counter = 0;
		while( !bus_read_ready && counter < 10 ) begin
			@( posedge clk );
			counter = counter + 1;
		end

		assert( bus_read_ready == 1'b0 );
		@( posedge clk );
		@( posedge clk );
		@( posedge clk );
	endtask: read_memory_timeout

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

		// --------------------------------------------------------------------
		//	Check for inaccessibility when the enable signal is low.
		// --------------------------------------------------------------------
		test_no			= 0;
		$display( "000: Check for inaccessibility when the enable signal is low." );
		scc_bank_en = 0;
		sccp_bank_en = 0;
		sccp_en = 0;

		read_memory_timeout( 'h9800 );
		read_memory_timeout( 'h9F00 );
		read_memory_timeout( 'h9FFF );
		read_memory_timeout( 'hB800 );
		read_memory_timeout( 'hBF00 );
		read_memory_timeout( 'hBFFD );

		$finish;
	end
endmodule
