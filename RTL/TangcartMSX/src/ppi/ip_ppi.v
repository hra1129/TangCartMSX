// -----------------------------------------------------------------------------
//	ip_ppi.v
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
//		simple PPI clone for MSX body
// -----------------------------------------------------------------------------

module ip_ppi (
	//	Internal I/F
	input			n_reset,
	input			clk,
	//	MSX-50BUS
	input	[15:0]	bus_address,
	output			bus_io_cs,
	output			bus_memory_cs,
	output			bus_read_ready,
	output	[7:0]	bus_read_data,
	input	[7:0]	bus_write_data,
	input			bus_read,
	input			bus_write,
	input			bus_io,
	input			bus_memory,
	//	OUTPUT
	output	[7:0]	primary_slot,
	output	[3:0]	key_matrix_row,
	output			motor_off,
	output			cas_write,
	output			caps_led_off,
	output			click_sound,
	input	[7:0]	key_matrix_column
);
	wire			w_ppi_dec;
	reg		[7:0]	ff_primary_slot;
	reg		[3:0]	ff_key_matrix_row;
	reg				ff_motor_off;
	reg				ff_cas_write;
	reg				ff_caps_led_off;
	reg				ff_click_sound;
	wire	[7:0]	w_read;
	reg		[1:0]	ff_address;
	reg				ff_read_ready;

	// --------------------------------------------------------------------
	//	Active bus select
	// --------------------------------------------------------------------
	assign bus_io_cs		= 1'b1;
	assign bus_memory_cs	= 1'b0;

	// --------------------------------------------------------------------
	//	Address decode
	// --------------------------------------------------------------------
	assign w_ppi_dec		= (bus_address[7:2] == 6'b1010_10);		//	A8h...ABh

	// --------------------------------------------------------------------
	//	Write register
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_primary_slot		<= 8'h00;
			ff_key_matrix_row	<= 4'hF;
			ff_motor_off		<= 1'b1;
			ff_cas_write		<= 1'b1;
			ff_caps_led_off		<= 1'b1;
			ff_click_sound		<= 1'b0;
		end
		else if( bus_io && w_ppi_dec && bus_write ) begin
			case( bus_address[1:0] )
			2'd0: begin
				ff_primary_slot		<= bus_write_data;
			end
			2'd2: begin
				ff_key_matrix_row	<= bus_write_data[3:0];
				ff_motor_off		<= bus_write_data[4];
				ff_cas_write		<= bus_write_data[5];
				ff_caps_led_off		<= bus_write_data[6];
				ff_click_sound		<= bus_write_data[7];
			end
			default: begin
				//	hold
			end
			endcase
		end
		else begin
			//	hold
		end
	end
	assign primary_slot		= ff_primary_slot;
	assign key_matrix_row	= ff_key_matrix_row;
	assign motor_off		= ff_motor_off;
	assign cas_write		= ff_cas_write;
	assign caps_led_off		= ff_caps_led_off;
	assign click_sound		= ff_click_sound;

	// --------------------------------------------------------------------
	//	Read response
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_read_ready <= 1'b0;
			ff_address <= 2'd0;
		end
		else if( bus_io && w_ppi_dec && bus_read ) begin
			ff_read_ready <= 1'b1;
			ff_address <= bus_address[1:0];
		end
		else begin
			ff_read_ready <= 1'b0;
			ff_address <= 2'd0;
		end
	end

	assign w_read			= (ff_address[1:0] == 2'd0) ? ff_primary_slot :
	             			  (ff_address[1:0] == 2'd1) ? key_matrix_column :
	             			  (ff_address[1:0] == 2'd2) ? { ff_click_sound, ff_caps_led_off, ff_cas_write, ff_motor_off, ff_key_matrix_row } : 'hFF;
	assign bus_read_data	= ff_read_ready ? w_read : 8'h00;
	assign bus_read_ready	= ff_read_ready;
endmodule
