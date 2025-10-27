// --------------------------------------------------------------------
// IP_MSXMUSIC_ROM
// --------------------------------------------------------------------

module ip_ram (
	input			clk,
	input			n_cs,
	input			n_wr,
	input			n_rd,
	input	[13:0]	address,
	input	[7:0]	wdata,
	output	[7:0]	rdata,
	output			rdata_en
);
	reg		[7:0]	ff_ram [0:16383];
	reg		[7:0]	ff_rdata;
	reg				ff_rdata_en;

	always @( posedge clk ) begin
		if( !n_cs && !n_rd ) begin
			ff_rdata	<= ff_ram[ address ];
			ff_rdata_en	<= 1'b1;
		end
		else begin
			ff_rdata	<= 8'd0;
			ff_rdata_en	<= 1'b0;
		end
	end

	always @( posedge clk ) begin
		if( !n_cs && !n_wr ) begin
			ff_ram[ address ] <= wdata;
		end
	end

	assign rdata	= ff_rdata;
	assign rdata_en	= ff_rdata_en;
endmodule
