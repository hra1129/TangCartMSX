// --------------------------------------------------------------------
// RAM 8KB (2000h-3FFFh)
// --------------------------------------------------------------------

module ip_ram (
	input			reset_n		,
	input			clk			,
	input	[15:0]	bus_address	,
	input			bus_memreq	,
	input			bus_valid	,
	output			bus_ready	,
	input			bus_write	,
	input	[7:0]	bus_wdata	,
	output	[7:0]	bus_rdata	,
	output			bus_rdata_en
);
	reg		[7:0]	ff_ram [0:8191];
	reg		[7:0]	ff_rdata;
	reg				ff_rdata_en;

	assign	bus_ready	= 1'b1;

	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_rdata	<= 8'd0;
			ff_rdata_en	<= 1'b0;
		end
		else if( bus_address[15:13] == 3'b001 && bus_memreq && bus_valid && !bus_write ) begin
			ff_rdata	<= ff_ram[ bus_address[12:0] ];
			ff_rdata_en	<= 1'b1;
		end
		else begin
			ff_rdata	<= 8'd0;
			ff_rdata_en	<= 1'b0;
		end
	end

	always @( posedge clk ) begin
		if( bus_address[15:13] == 3'b001 && bus_memreq && bus_valid && bus_write ) begin
			ff_ram[ bus_address[12:0] ] <= bus_wdata;
		end
	end

	assign bus_rdata	= ff_rdata_en ? ff_rdata: 8'd0;
	assign bus_rdata_en	= ff_rdata_en;
endmodule
