// --------------------------------------------------------------------
// ddr3_test ROM
// --------------------------------------------------------------------

module ip_rom (
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
			case( bus_address[9:0] )
			10'd0: ff_rdata <= 8'hF3;
			10'd1: ff_rdata <= 8'h31;
			10'd2: ff_rdata <= 8'h00;
			10'd3: ff_rdata <= 8'h40;
			10'd4: ff_rdata <= 8'hCD;
			10'd5: ff_rdata <= 8'h59;
			10'd6: ff_rdata <= 8'h00;
			10'd7: ff_rdata <= 8'h11;
			10'd8: ff_rdata <= 8'h24;
			10'd9: ff_rdata <= 8'h00;
			10'd10: ff_rdata <= 8'hCD;
			10'd11: ff_rdata <= 8'h6B;
			10'd12: ff_rdata <= 8'h00;
			10'd13: ff_rdata <= 8'hCD;
			10'd14: ff_rdata <= 8'h59;
			10'd15: ff_rdata <= 8'h00;
			10'd16: ff_rdata <= 8'h11;
			10'd17: ff_rdata <= 8'h3E;
			10'd18: ff_rdata <= 8'h00;
			10'd19: ff_rdata <= 8'hCD;
			10'd20: ff_rdata <= 8'h6B;
			10'd21: ff_rdata <= 8'h00;
			10'd22: ff_rdata <= 8'hDB;
			10'd23: ff_rdata <= 8'h30;
			10'd24: ff_rdata <= 8'hB7;
			10'd25: ff_rdata <= 8'h20;
			10'd26: ff_rdata <= 8'hFB;
			10'd27: ff_rdata <= 8'h11;
			10'd28: ff_rdata <= 8'h54;
			10'd29: ff_rdata <= 8'h00;
			10'd30: ff_rdata <= 8'hCD;
			10'd31: ff_rdata <= 8'h6B;
			10'd32: ff_rdata <= 8'h00;
			10'd33: ff_rdata <= 8'hC3;
			10'd34: ff_rdata <= 8'h07;
			10'd35: ff_rdata <= 8'h00;
			10'd36: ff_rdata <= 8'h44;
			10'd37: ff_rdata <= 8'h44;
			10'd38: ff_rdata <= 8'h52;
			10'd39: ff_rdata <= 8'h33;
			10'd40: ff_rdata <= 8'h2D;
			10'd41: ff_rdata <= 8'h53;
			10'd42: ff_rdata <= 8'h44;
			10'd43: ff_rdata <= 8'h52;
			10'd44: ff_rdata <= 8'h41;
			10'd45: ff_rdata <= 8'h4D;
			10'd46: ff_rdata <= 8'h20;
			10'd47: ff_rdata <= 8'h54;
			10'd48: ff_rdata <= 8'h65;
			10'd49: ff_rdata <= 8'h73;
			10'd50: ff_rdata <= 8'h74;
			10'd51: ff_rdata <= 8'h20;
			10'd52: ff_rdata <= 8'h70;
			10'd53: ff_rdata <= 8'h72;
			10'd54: ff_rdata <= 8'h6F;
			10'd55: ff_rdata <= 8'h67;
			10'd56: ff_rdata <= 8'h72;
			10'd57: ff_rdata <= 8'h61;
			10'd58: ff_rdata <= 8'h6D;
			10'd59: ff_rdata <= 8'h0D;
			10'd60: ff_rdata <= 8'h0A;
			10'd61: ff_rdata <= 8'h00;
			10'd62: ff_rdata <= 8'h53;
			10'd63: ff_rdata <= 8'h44;
			10'd64: ff_rdata <= 8'h52;
			10'd65: ff_rdata <= 8'h41;
			10'd66: ff_rdata <= 8'h4D;
			10'd67: ff_rdata <= 8'h20;
			10'd68: ff_rdata <= 8'h42;
			10'd69: ff_rdata <= 8'h75;
			10'd70: ff_rdata <= 8'h73;
			10'd71: ff_rdata <= 8'h79;
			10'd72: ff_rdata <= 8'h20;
			10'd73: ff_rdata <= 8'h43;
			10'd74: ff_rdata <= 8'h68;
			10'd75: ff_rdata <= 8'h65;
			10'd76: ff_rdata <= 8'h63;
			10'd77: ff_rdata <= 8'h6B;
			10'd78: ff_rdata <= 8'h20;
			10'd79: ff_rdata <= 8'h2E;
			10'd80: ff_rdata <= 8'h2E;
			10'd81: ff_rdata <= 8'h2E;
			10'd82: ff_rdata <= 8'h20;
			10'd83: ff_rdata <= 8'h00;
			10'd84: ff_rdata <= 8'h4F;
			10'd85: ff_rdata <= 8'h4B;
			10'd86: ff_rdata <= 8'h0D;
			10'd87: ff_rdata <= 8'h0A;
			10'd88: ff_rdata <= 8'h00;
			10'd89: ff_rdata <= 8'hCD;
			10'd90: ff_rdata <= 8'h68;
			10'd91: ff_rdata <= 8'h00;
			10'd92: ff_rdata <= 8'hE6;
			10'd93: ff_rdata <= 8'h01;
			10'd94: ff_rdata <= 8'h20;
			10'd95: ff_rdata <= 8'hF9;
			10'd96: ff_rdata <= 8'hCD;
			10'd97: ff_rdata <= 8'h68;
			10'd98: ff_rdata <= 8'h00;
			10'd99: ff_rdata <= 8'hE6;
			10'd100: ff_rdata <= 8'h01;
			10'd101: ff_rdata <= 8'h28;
			10'd102: ff_rdata <= 8'hF9;
			10'd103: ff_rdata <= 8'hC9;
			10'd104: ff_rdata <= 8'hDB;
			10'd105: ff_rdata <= 8'h10;
			10'd106: ff_rdata <= 8'hC9;
			10'd107: ff_rdata <= 8'hF5;
			10'd108: ff_rdata <= 8'h1A;
			10'd109: ff_rdata <= 8'h13;
			10'd110: ff_rdata <= 8'hB7;
			10'd111: ff_rdata <= 8'h28;
			10'd112: ff_rdata <= 8'h04;
			10'd113: ff_rdata <= 8'hD3;
			10'd114: ff_rdata <= 8'h10;
			10'd115: ff_rdata <= 8'h18;
			10'd116: ff_rdata <= 8'hF7;
			10'd117: ff_rdata <= 8'hF1;
			10'd118: ff_rdata <= 8'hC9;
			default: ff_rdata <= 8'd0;
			endcase
			ff_rdata_en <= 1'b1;
		end
		else begin
			ff_rdata <= 8'd0;
			ff_rdata_en <= 1'b0;
		end
	end

	assign bus_ready	= 1'b1;
	assign bus_rdata	= ff_rdata_en ? ff_rdata: 8'd0;
	assign bus_rdata_en	= ff_rdata_en;
endmodule
