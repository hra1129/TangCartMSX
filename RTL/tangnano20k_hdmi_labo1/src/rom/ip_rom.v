// --------------------------------------------------------------------
// IP_ROM
// --------------------------------------------------------------------

module ip_rom (
	input			clk,
	input			n_cs,
	input			n_rd,
	input	[9:0]	address,
	output	[7:0]	rdata,
	output			rdata_en
);
	reg		[7:0]	ff_rom		[0:1023];
	reg		[7:0]	ff_rdata;
	reg				ff_rdata_en;

	initial begin
		ff_rom[0] = 8'hF3;
		ff_rom[1] = 8'h31;
		ff_rom[2] = 8'h00;
		ff_rom[3] = 8'h00;
		ff_rom[4] = 8'hAF;
		ff_rom[5] = 8'hD3;
		ff_rom[6] = 8'h20;
		ff_rom[7] = 8'hD3;
		ff_rom[8] = 8'h21;
		ff_rom[9] = 8'hD3;
		ff_rom[10] = 8'h21;
		ff_rom[11] = 8'hD3;
		ff_rom[12] = 8'h21;
		ff_rom[13] = 8'h3C;
		ff_rom[14] = 8'h20;
		ff_rom[15] = 8'hF7;
		ff_rom[16] = 8'hD3;
		ff_rom[17] = 8'h22;
		ff_rom[18] = 8'hD3;
		ff_rom[19] = 8'h22;
		ff_rom[20] = 8'hD3;
		ff_rom[21] = 8'h22;
		ff_rom[22] = 8'h21;
		ff_rom[23] = 8'h68;
		ff_rom[24] = 8'h01;
		ff_rom[25] = 8'hE5;
		ff_rom[26] = 8'h21;
		ff_rom[27] = 8'h80;
		ff_rom[28] = 8'h02;
		ff_rom[29] = 8'h7D;
		ff_rom[30] = 8'hD3;
		ff_rom[31] = 8'h23;
		ff_rom[32] = 8'h2B;
		ff_rom[33] = 8'h7D;
		ff_rom[34] = 8'hB4;
		ff_rom[35] = 8'h20;
		ff_rom[36] = 8'hF8;
		ff_rom[37] = 8'hE1;
		ff_rom[38] = 8'h7D;
		ff_rom[39] = 8'hB4;
		ff_rom[40] = 8'h20;
		ff_rom[41] = 8'hEC;
		ff_rom[42] = 8'hCD;
		ff_rom[43] = 8'h40;
		ff_rom[44] = 8'h00;
		ff_rom[45] = 8'hB7;
		ff_rom[46] = 8'h20;
		ff_rom[47] = 8'hFA;
		ff_rom[48] = 8'hCD;
		ff_rom[49] = 8'h40;
		ff_rom[50] = 8'h00;
		ff_rom[51] = 8'hB7;
		ff_rom[52] = 8'h28;
		ff_rom[53] = 8'hFA;
		ff_rom[54] = 8'h0F;
		ff_rom[55] = 8'h38;
		ff_rom[56] = 8'h03;
		ff_rom[57] = 8'h0F;
		ff_rom[58] = 8'h38;
		ff_rom[59] = 8'h02;
		ff_rom[60] = 8'h18;
		ff_rom[61] = 8'hEC;
		ff_rom[62] = 8'h18;
		ff_rom[63] = 8'hEA;
		ff_rom[64] = 8'hDB;
		ff_rom[65] = 8'h10;
		ff_rom[66] = 8'h07;
		ff_rom[67] = 8'h07;
		ff_rom[68] = 8'hC9;
	end

	always @( posedge clk ) begin
		if( !n_cs && !n_rd ) begin
			ff_rdata <= ff_rom[ address ];
		end
		else begin
			ff_rdata <= 8'd0;
		end
	end

	always @( posedge clk ) begin
		if( !n_cs && !n_rd ) begin
			ff_rdata_en <= 1'b1;
		end
		else begin
			ff_rdata_en <= 1'b0;
		end
	end

	assign rdata	= ff_rdata;
	assign rdata_en	= ff_rdata_en;
endmodule
