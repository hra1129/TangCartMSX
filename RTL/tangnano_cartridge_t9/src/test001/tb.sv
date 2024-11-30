// -----------------------------------------------------------------------------
//	Test of top entity
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
	localparam	clk_base	= 1_000_000_000/21_477;	//	ps
	int				test_no;

	reg				n_treset;
	reg				tclock;
	reg				n_tsltsl;
	reg				n_tmerq;
	reg				n_tiorq;
	reg				n_twr;
	reg				n_trd;
	reg		[15:0]	ta;
	wire			tdir;
	reg		[7:0]	td;
	wire	[7:0]	w_td;
	wire			tsnd;
	wire	[5:0]	n_led;
	reg		[1:0]	button;
	reg		[6:0]	dip_sw;
	wire			twait;			//	twait 1 or HiZ --> /WAIT= 0  ; 0 --> /WAIT= HiZ
	wire			tint;			//	tint  0 or HiZ --> /INT = HiZ; 1 --> /INT = 0
	wire			midi_out;
	reg				midi_in;

	int				counter;

	// --------------------------------------------------------------------
	//	DUT
	// --------------------------------------------------------------------
	tangcart_msx u_tangcart_msx (
		.n_treset		( n_treset		),
		.tclock			( tclock		),
		.n_tsltsl		( n_tsltsl		),
		.n_tmerq		( n_tmerq		),
		.n_tiorq		( n_tiorq		),
		.n_twr			( n_twr			),
		.n_trd			( n_trd			),
		.ta				( ta			),
		.tdir			( tdir			),
		.td				( w_td			),
		.tsnd			( tsnd			),
		.n_led			( n_led			),
		.button			( button		),
		.dip_sw			( dip_sw		),
		.twait			( twait			),
		.tint			( tint			),
		.midi_out		( midi_out		),
		.midi_in		( midi_in		)
	);

	assign w_td = n_trd ? td : 8'hzz;

	// --------------------------------------------------------------------
	//	clock
	// --------------------------------------------------------------------
	always #(clk_base/2) begin
		tclock <= ~tclock;				//	21.47727MHz
	end

	// --------------------------------------------------------------------
	//	Tasks
	// --------------------------------------------------------------------
	task write_io(
		input	[7:0]	_address,
		input	[7:0]	_wdata
	);
		n_tmerq			<= 1'b1;
		n_tiorq			<= 1'b0;
		n_twr			<= 1'b1;
		ta				<= { 8'd0, _address };
		counter			<= 0;						//	timeout counter
		repeat( 6 ) @( posedge tclock );

		n_twr			<= 1'b0;
		td				<= _wdata;
		repeat( 6 ) @( posedge tclock );

		n_tiorq			<= 1'b1;
		n_twr			<= 1'b1;
		ta				<= 0;
		td				<= 0;
		n_twr			<= 1'b1;
		repeat( 12 ) @( posedge tclock );
	endtask: write_io

	task write_memory(
		input	[15:0]	_address,
		input	[7:0]	_wdata
	);
		n_tsltsl		<= 1'b0;
		n_tmerq			<= 1'b0;
		n_tiorq			<= 1'b1;
		n_twr			<= 1'b1;
		ta				<= _address;
		counter			<= 0;						//	timeout counter
		repeat( 6 ) @( posedge tclock );

		n_twr			<= 1'b0;
		td				<= _wdata;
		repeat( 6 ) @( posedge tclock );

		n_tsltsl		<= 1'b1;
		n_tmerq			<= 1'b1;
		n_twr			<= 1'b1;
		ta				<= 0;
		td				<= 0;
		repeat( 12 ) @( posedge tclock );
	endtask: write_memory

	task read_memory(
		input	[15:0]	_address
	);
		n_tsltsl		<= 1'b0;
		n_tmerq			<= 1'b0;
		n_tiorq			<= 1'b1;
		n_trd			<= 1'b1;
		ta				<= _address;
		counter			<= 0;						//	timeout counter
		repeat( 6 ) @( posedge tclock );

		n_trd			<= 1'b0;
		repeat( 12 ) @( posedge tclock );

		n_tsltsl		<= 1'b1;
		n_tmerq			<= 1'b1;
		n_trd			<= 1'b1;
		ta				<= 0;
		repeat( 12 ) @( posedge tclock );
	endtask: read_memory

	// --------------------------------------------------------------------
	//	Test bench
	// --------------------------------------------------------------------
	initial begin
		test_no			= -1;
		n_treset		= 0;
		tclock			= 1;

		n_tsltsl		= 1;
		n_tmerq			= 1;
		n_tiorq			= 1;
		n_twr			= 1;
		n_trd			= 1;
		ta				= 0;
		td				= 0;
		button			= 0;
		dip_sw			= 0;

		@( negedge tclock );
		@( negedge tclock );
		repeat( 1000 ) @( posedge tclock );

		n_treset		= 1;
		repeat( 100 ) @( posedge tclock );

		read_memory( 16'h4000 );
		read_memory( 16'h4001 );
		read_memory( 16'h4002 );
		read_memory( 16'h4003 );
		read_memory( 16'h4004 );
		read_memory( 16'h4005 );
		read_memory( 16'h4006 );
		read_memory( 16'h4007 );
		read_memory( 16'h4008 );
		read_memory( 16'h4009 );
		read_memory( 16'h400A );
		read_memory( 16'h400B );
		read_memory( 16'h400C );
		read_memory( 16'h400D );
		read_memory( 16'h400E );
		read_memory( 16'h400F );

		$finish;
	end
endmodule
