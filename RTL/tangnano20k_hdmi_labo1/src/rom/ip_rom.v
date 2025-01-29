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
		ff_rom[7] = 8'hF5;
		ff_rom[8] = 8'hD3;
		ff_rom[9] = 8'h21;
		ff_rom[10] = 8'hCB;
		ff_rom[11] = 8'h3F;
		ff_rom[12] = 8'hD3;
		ff_rom[13] = 8'h21;
		ff_rom[14] = 8'hCB;
		ff_rom[15] = 8'h3F;
		ff_rom[16] = 8'hD3;
		ff_rom[17] = 8'h21;
		ff_rom[18] = 8'hF1;
		ff_rom[19] = 8'h3C;
		ff_rom[20] = 8'h20;
		ff_rom[21] = 8'hF1;
		ff_rom[22] = 8'hD3;
		ff_rom[23] = 8'h22;
		ff_rom[24] = 8'hD3;
		ff_rom[25] = 8'h22;
		ff_rom[26] = 8'hD3;
		ff_rom[27] = 8'h22;
		ff_rom[28] = 8'h06;
		ff_rom[29] = 8'hFF;
		ff_rom[30] = 8'h3E;
		ff_rom[31] = 8'h80;
		ff_rom[32] = 8'hD3;
		ff_rom[33] = 8'h20;
		ff_rom[34] = 8'h78;
		ff_rom[35] = 8'hD3;
		ff_rom[36] = 8'h21;
		ff_rom[37] = 8'hCB;
		ff_rom[38] = 8'h3F;
		ff_rom[39] = 8'hD3;
		ff_rom[40] = 8'h21;
		ff_rom[41] = 8'hCB;
		ff_rom[42] = 8'h3F;
		ff_rom[43] = 8'hD3;
		ff_rom[44] = 8'h21;
		ff_rom[45] = 8'h21;
		ff_rom[46] = 8'hE8;
		ff_rom[47] = 8'h03;
		ff_rom[48] = 8'h2B;
		ff_rom[49] = 8'h7D;
		ff_rom[50] = 8'hB4;
		ff_rom[51] = 8'h20;
		ff_rom[52] = 8'hFB;
		ff_rom[53] = 8'h05;
		ff_rom[54] = 8'hC3;
		ff_rom[55] = 8'h1E;
		ff_rom[56] = 8'h00;
		ff_rom[57] = 8'hDB;
		ff_rom[58] = 8'h10;
		ff_rom[59] = 8'h07;
		ff_rom[60] = 8'h07;
		ff_rom[61] = 8'hC9;
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
