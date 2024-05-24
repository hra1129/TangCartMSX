// -----------------------------------------------------------------------------
//	ip_megarom.v
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
//		MegaROM
// -----------------------------------------------------------------------------

module ip_megarom #(
	parameter		address_h	= 1'b0		//	[21] 1bit
) (
	//	Internal I/F
	input			n_reset,
	input			clk,
	input	[2:0]	mode,				//	0: ASC8, 1: ASC16, 2: Normal, 3: Kon4, 4: SCC, 5: SCC+, 6: Generic8, 7: Generic16
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
	//	RAM I/F
	output			rd,
	output			wr,
	input			busy,
	output	[21:0]	address,
	output	[7:0]	wdata,
	input	[7:0]	rdata,
	input			rdata_en
);
	localparam c_mode_asc8		= 3'd0;
	localparam c_mode_asc16		= 3'd1;
	localparam c_mode_normal	= 3'd2;
	localparam c_mode_kon4		= 3'd3;
	localparam c_mode_scc		= 3'd4;
	localparam c_mode_sccp		= 3'd5;
	localparam c_mode_gen8		= 3'd6;
	localparam c_mode_gen16		= 3'd7;

	reg		[7:0]	ff_bank0;
	reg		[7:0]	ff_bank1;
	reg		[7:0]	ff_bank2;
	reg		[7:0]	ff_bank3;
	wire			w_asc8_b0;
	wire			w_asc8_b1;
	wire			w_asc8_b2;
	wire			w_asc8_b3;
	wire			w_asc16_b0;
	wire			w_asc16_b1;
	wire			w_asc16_b2;
	wire			w_asc16_b3;
	wire			w_gen8_b0;
	wire			w_gen8_b1;
	wire			w_gen8_b2;
	wire			w_gen8_b3;
	wire			w_gen16_b0;
	wire			w_gen16_b1;
	wire			w_gen16_b2;
	wire			w_gen16_b3;
	wire			w_kon4_b1;
	wire			w_kon4_b2;
	wire			w_kon4_b3;
	wire			w_scc_b0;
	wire			w_scc_b1;
	wire			w_scc_b2;
	wire			w_scc_b3;
	wire			w_scc;
	wire			w_sccp;
	reg				ff_sccp_en;
	reg				ff_sccp_ram_en;
	wire	[7:0]	w_address_m;

	assign bus_io_cs		= 1'b0;
	assign bus_memory_cs	= 1'b1;

	// --------------------------------------------------------------------
	//	ASC8 Mapper
	// --------------------------------------------------------------------
	assign w_asc8_b0	= (bus_address[15:11] == 5'b0110_0);		// 16'b0110_0XXX_XXXX_XXXX : 6000h-67FFh
	assign w_asc8_b1	= (bus_address[15:11] == 5'b0110_1);		// 16'b0110_1XXX_XXXX_XXXX : 6800h-6FFFh
	assign w_asc8_b2	= (bus_address[15:11] == 5'b0111_0);		// 16'b0111_0XXX_XXXX_XXXX : 7000h-77FFh
	assign w_asc8_b3	= (bus_address[15:11] == 5'b0111_1);		// 16'b0111_1XXX_XXXX_XXXX : 7800h-7FFFh

	// --------------------------------------------------------------------
	//	ASC16 Mapper
	// --------------------------------------------------------------------
	assign w_asc16_b0	= (bus_address[15:11] == 5'b0110_0);		// 16'b0110_0XXX_XXXX_XXXX : 6000h-67FFh
	assign w_asc16_b1	= (bus_address[15:11] == 5'b0110_0);		// 16'b0110_0XXX_XXXX_XXXX : 6000h-67FFh
	assign w_asc16_b2	= (bus_address[15:11] == 5'b0111_0);		// 16'b0111_0XXX_XXXX_XXXX : 7000h-77FFh
	assign w_asc16_b3	= (bus_address[15:11] == 5'b0111_0);		// 16'b0111_0XXX_XXXX_XXXX : 7000h-77FFh

	// --------------------------------------------------------------------
	//	Generic8 Mapper
	// --------------------------------------------------------------------
	assign w_gen8_b0	= (bus_address[15:13] == 3'b010 && bus_address[11] == 1'b0);	// 16'b010X_0XXX_XXXX_XXXX : 4000h-47FFh, 5000h-57FFh
	assign w_gen8_b1	= (bus_address[15:13] == 3'b011 && bus_address[11] == 1'b0);	// 16'b011X_0XXX_XXXX_XXXX : 6000h-67FFh, 7000h-77FFh
	assign w_gen8_b2	= (bus_address[15:13] == 3'b100 && bus_address[11] == 1'b0);	// 16'b100X_0XXX_XXXX_XXXX : 8000h-87FFh, 9000h-97FFh
	assign w_gen8_b3	= (bus_address[15:13] == 3'b101 && bus_address[11] == 1'b0);	// 16'b101X_0XXX_XXXX_XXXX : A000h-A7FFh, B000h-B7FFh

	// --------------------------------------------------------------------
	//	Generic16 Mapper
	// --------------------------------------------------------------------
	assign w_gen16_b0	= w_gen8_b0 | w_gen8_b1;
	assign w_gen16_b1	= w_gen8_b0 | w_gen8_b1;
	assign w_gen16_b2	= w_gen8_b2 | w_gen8_b3;
	assign w_gen16_b3	= w_gen8_b2 | w_gen8_b3;

	// --------------------------------------------------------------------
	//	Kon4 Mapper
	// --------------------------------------------------------------------
	assign w_kon4_b1	= (bus_address[15:13] == 3'b011);		// 16'b011X_XXXX_XXXX_XXXX : 6000h-7FFFh
	assign w_kon4_b2	= (bus_address[15:13] == 3'b100);		// 16'b100X_XXXX_XXXX_XXXX : 8000h-9FFFh
	assign w_kon4_b3	= (bus_address[15:13] == 3'b101);		// 16'b101X_XXXX_XXXX_XXXX : A000h-BFFFh

	// --------------------------------------------------------------------
	//	SCC/SCC-I Mapper
	// --------------------------------------------------------------------
	assign w_scc_b0		= (bus_address[15:11] == 5'b01010);		// 16'b010X_0XXX_XXXX_XXXX : 5000h-57FFh
	assign w_scc_b1		= (bus_address[15:11] == 5'b01110);		// 16'b011X_0XXX_XXXX_XXXX : 7000h-77FFh
	assign w_scc_b2		= (bus_address[15:11] == 5'b10010);		// 16'b100X_0XXX_XXXX_XXXX : 9000h-97FFh
	assign w_scc_b3		= (bus_address[15:11] == 5'b10110);		// 16'b101X_0XXX_XXXX_XXXX : B000h-B7FFh
	assign w_scc		= (bus_address[15:14] == 2'b10) && (ff_bank2 == 8'h3e) && ((mode == c_mode_scc) || (mode == c_mode_sccp));
	assign w_sccp		= (bus_address[15:14] == 2'b11) && ff_bank3[7] && (mode == c_mode_sccp);
	assign w_sccp_mode	= (bus_address[15:1] == 16'b1011_1111_1111_111) && (mode == c_mode_sccp) && bus_write;

	// --------------------------------------------------------------------
	//	SCC-I Mode Register
	// --------------------------------------------------------------------
	always @( negedge n_reset or posedge clk ) begin
		if( !n_reset ) begin
			ff_sccp_en		<= 1'b0;
			ff_sccp_ram_en	<= 1'b0;
		end
		else if( bus_memory && w_sccp_mode ) begin
			ff_sccp_en		<= bus_write_data[5];
			ff_sccp_ram_en	<= bus_write_data[4];
		end
		else begin
			ff_sccp_en		<= 1'b0;
			ff_sccp_ram_en	<= 1'b0;
		end
	end

	// --------------------------------------------------------------------
	//	Bank Register
	// --------------------------------------------------------------------
	always @( negedge n_reset or posedge clk ) begin
		if( !n_reset ) begin
			ff_bank0 <= 8'd0;
			ff_bank1 <= 8'd1;
			ff_bank2 <= 8'd2;
			ff_bank3 <= 8'd3;
		end
		else if( bus_write ) begin
			case( mode )
			c_mode_asc8: begin
				if( w_asc8_b0 ) begin
					ff_bank0 <= bus_write_data;
				end
				if( w_asc8_b1 ) begin
					ff_bank1 <= bus_write_data;
				end
				if( w_asc8_b2 ) begin
					ff_bank2 <= bus_write_data;
				end
				if( w_asc8_b3 ) begin
					ff_bank3 <= bus_write_data;
				end
			end
			c_mode_asc16: begin
				if( w_asc16_b0 ) begin
					ff_bank0 <= { bus_write_data[6:0], 1'b0 };
				end
				if( w_asc16_b1 ) begin
					ff_bank1 <= { bus_write_data[6:0], 1'b1 };
				end
				if( w_asc16_b2 ) begin
					ff_bank2 <= { bus_write_data[6:0], 1'b0 };
				end
				if( w_asc16_b3 ) begin
					ff_bank3 <= { bus_write_data[6:0], 1'b1 };
				end
			end
			c_mode_kon4: begin
				if( w_kon4_b1 ) begin
					ff_bank1 <= bus_write_data;
				end
				if( w_kon4_b2 ) begin
					ff_bank2 <= bus_write_data;
				end
				if( w_kon4_b3 ) begin
					ff_bank3 <= bus_write_data;
				end
			end
			c_mode_scc, c_mode_sccp: begin
				if( w_scc_b0 ) begin
					ff_bank0 <= bus_write_data;
				end
				if( w_scc_b1 ) begin
					ff_bank1 <= bus_write_data;
				end
				if( w_scc_b2 ) begin
					ff_bank2 <= bus_write_data;
				end
				if( w_scc_b3 ) begin
					ff_bank3 <= bus_write_data;
				end
			end
			c_mode_gen8: begin
				if( w_gen8_b0 ) begin
					ff_bank0 <= bus_write_data;
				end
				if( w_gen8_b1 ) begin
					ff_bank1 <= bus_write_data;
				end
				if( w_gen8_b2 ) begin
					ff_bank2 <= bus_write_data;
				end
				if( w_gen8_b3 ) begin
					ff_bank3 <= bus_write_data;
				end
			end
			c_mode_gen16: begin
				if( w_gen16_b0 ) begin
					ff_bank0 <= { bus_write_data[6:0], 1'b0 };
				end
				if( w_gen16_b1 ) begin
					ff_bank1 <= { bus_write_data[6:0], 1'b1 };
				end
				if( w_gen16_b2 ) begin
					ff_bank2 <= { bus_write_data[6:0], 1'b0 };
				end
				if( w_gen16_b3 ) begin
					ff_bank3 <= { bus_write_data[6:0], 1'b1 };
				end
			end
			default: begin
				ff_bank0 <= 8'd0;
				ff_bank1 <= 8'd1;
				ff_bank2 <= 8'd2;
				ff_bank3 <= 8'd3;
			end
			endcase
		end
		else begin
			//	hold
		end
	end

	// --------------------------------------------------------------------
	//	ROM Reader
	// --------------------------------------------------------------------
	assign w_address_m		= (bus_address[14:13] == 2'b10) ? ff_bank0 :
	                  		  (bus_address[14:13] == 2'b11) ? ff_bank1 :
	                  		  (bus_address[14:13] == 2'b00) ? ff_bank2 : ff_bank3;
	assign address			= { address_h, w_address_m, bus_address[12:0] };
	assign rd				= bus_memory & bus_read & ~(w_scc | w_sccp);
	assign wr				= bus_memory & bus_write & ff_sccp_ram_en & ~(w_scc | w_sccp | w_sccp_mode);
	assign wdata			= bus_write_data;
	assign bus_read_ready	= rdata_en;
	assign bus_read_data	= rdata;
endmodule
