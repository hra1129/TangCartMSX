// --------------------------------------------------------------------
// RAM 4K word (32bit/word)
// --------------------------------------------------------------------

module ip_ram (
	input			reset_n		,
	input			clk			,
	input	[11:0]	bus_address	,
	input			bus_valid	,
	output			bus_ready	,
	input			bus_write	,
	input	[31:0]	bus_wdata	,
	output	[31:0]	bus_rdata	,
	output			bus_rdata_en
);
	reg		[31:0]	ff_ram [0:4095];
	reg		[31:0]	ff_rdata;
	reg				ff_rdata_en;

	assign	bus_ready	= 1'b1;

	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_rdata	<= 32'd0;
			ff_rdata_en	<= 1'b0;
		end
		else if( bus_valid && !bus_write ) begin
			ff_rdata	<= ff_ram[ bus_address ];
			ff_rdata_en	<= 1'b1;
		end
		else begin
			ff_rdata	<= 32'd0;
			ff_rdata_en	<= 1'b0;
		end
	end

	always @( posedge clk ) begin
		if( bus_valid && bus_write ) begin
			ff_ram[ bus_address ] <= bus_wdata;
		end
	end

	assign bus_rdata	= ff_rdata;
	assign bus_rdata_en	= ff_rdata_en;
endmodule
