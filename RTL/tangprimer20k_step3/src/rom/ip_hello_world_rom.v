// --------------------------------------------------------------------
// IP_HELLO_WORLD_ROM
// --------------------------------------------------------------------

module ip_hello_world_rom (
	input			reset_n		,
	input			clk			,
	input	[15:0]	bus_address	,
	input			bus_memreq	,
	input			bus_valid	,
	output			bus_ready	,
	input			bus_write	,
	output	[7:0]	bus_rdata	,
	output			bus_rdata_en
);
	reg		[7:0]	ff_rdata;
	reg				ff_rdata_en;

	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_rdata	<= 8'd0;
			ff_rdata_en	<= 1'b0;
		end
		else if( bus_address[15:13] == 3'b000 && bus_memreq && bus_valid && !bus_write ) begin
			14'd0: ff_rdata <= 8'hF3;
			14'd1: ff_rdata <= 8'hC3;
			14'd2: ff_rdata <= 8'h08;
			14'd3: ff_rdata <= 8'h00;
			14'd4: ff_rdata <= 8'h00;
			14'd5: ff_rdata <= 8'hC3;
			14'd6: ff_rdata <= 8'h2E;
			14'd7: ff_rdata <= 8'h00;
			14'd8: ff_rdata <= 8'h31;
			14'd9: ff_rdata <= 8'h00;
			14'd10: ff_rdata <= 8'h40;
			14'd11: ff_rdata <= 8'hCD;
			14'd12: ff_rdata <= 8'h2B;
			14'd13: ff_rdata <= 8'h00;
			14'd14: ff_rdata <= 8'hE6;
			14'd15: ff_rdata <= 8'h01;
			14'd16: ff_rdata <= 8'h28;
			14'd17: ff_rdata <= 8'hF9;
			14'd18: ff_rdata <= 8'h11;
			14'd19: ff_rdata <= 8'h1B;
			14'd20: ff_rdata <= 8'h00;
			14'd21: ff_rdata <= 8'hCD;
			14'd22: ff_rdata <= 8'h2E;
			14'd23: ff_rdata <= 8'h00;
			14'd24: ff_rdata <= 8'hC3;
			14'd25: ff_rdata <= 8'h0B;
			14'd26: ff_rdata <= 8'h00;
			14'd27: ff_rdata <= 8'h48;
			14'd28: ff_rdata <= 8'h65;
			14'd29: ff_rdata <= 8'h6C;
			14'd30: ff_rdata <= 8'h6C;
			14'd31: ff_rdata <= 8'h6F;
			14'd32: ff_rdata <= 8'h2C;
			14'd33: ff_rdata <= 8'h20;
			14'd34: ff_rdata <= 8'h77;
			14'd35: ff_rdata <= 8'h6F;
			14'd36: ff_rdata <= 8'h72;
			14'd37: ff_rdata <= 8'h6C;
			14'd38: ff_rdata <= 8'h64;
			14'd39: ff_rdata <= 8'h21;
			14'd40: ff_rdata <= 8'h0D;
			14'd41: ff_rdata <= 8'h0A;
			14'd42: ff_rdata <= 8'h00;
			14'd43: ff_rdata <= 8'hDB;
			14'd44: ff_rdata <= 8'h10;
			14'd45: ff_rdata <= 8'hC9;
			14'd46: ff_rdata <= 8'hF5;
			14'd47: ff_rdata <= 8'h1A;
			14'd48: ff_rdata <= 8'h13;
			14'd49: ff_rdata <= 8'hB7;
			14'd50: ff_rdata <= 8'h28;
			14'd51: ff_rdata <= 8'h04;
			14'd52: ff_rdata <= 8'hD3;
			14'd53: ff_rdata <= 8'h10;
			14'd54: ff_rdata <= 8'h18;
			14'd55: ff_rdata <= 8'hF7;
			14'd56: ff_rdata <= 8'hF1;
			14'd57: ff_rdata <= 8'hC9;
			default: ff_rdata <= 8'd0;
			endcase
			ff_rdata_en <= 1'b1;
		end
		else begin
			ff_rdata <= 8'd0;
			ff_rdata_en <= 1'b0;
		end
	end

	assign rdata	= ff_rdata_en ? ff_rdata: 8'd0;
	assign rdata_en	= ff_rdata_en;
endmodule
