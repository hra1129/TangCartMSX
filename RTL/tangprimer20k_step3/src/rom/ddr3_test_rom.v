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
			case( bus_address[12:0] )
			13'd0: ff_rdata <= 8'hF3;
			13'd1: ff_rdata <= 8'h31;
			13'd2: ff_rdata <= 8'h00;
			13'd3: ff_rdata <= 8'h40;
			13'd4: ff_rdata <= 8'hCD;
			13'd5: ff_rdata <= 8'h59;
			13'd6: ff_rdata <= 8'h00;
			13'd7: ff_rdata <= 8'h11;
			13'd8: ff_rdata <= 8'h24;
			13'd9: ff_rdata <= 8'h00;
			13'd10: ff_rdata <= 8'hCD;
			13'd11: ff_rdata <= 8'h6B;
			13'd12: ff_rdata <= 8'h00;
			13'd13: ff_rdata <= 8'hCD;
			13'd14: ff_rdata <= 8'h59;
			13'd15: ff_rdata <= 8'h00;
			13'd16: ff_rdata <= 8'h11;
			13'd17: ff_rdata <= 8'h3E;
			13'd18: ff_rdata <= 8'h00;
			13'd19: ff_rdata <= 8'hCD;
			13'd20: ff_rdata <= 8'h6B;
			13'd21: ff_rdata <= 8'h00;
			13'd22: ff_rdata <= 8'hDB;
			13'd23: ff_rdata <= 8'h30;
			13'd24: ff_rdata <= 8'hB7;
			13'd25: ff_rdata <= 8'h20;
			13'd26: ff_rdata <= 8'hFB;
			13'd27: ff_rdata <= 8'h11;
			13'd28: ff_rdata <= 8'h54;
			13'd29: ff_rdata <= 8'h00;
			13'd30: ff_rdata <= 8'hCD;
			13'd31: ff_rdata <= 8'h6B;
			13'd32: ff_rdata <= 8'h00;
			13'd33: ff_rdata <= 8'hC3;
			13'd34: ff_rdata <= 8'h07;
			13'd35: ff_rdata <= 8'h00;
			13'd36: ff_rdata <= 8'h44;
			13'd37: ff_rdata <= 8'h44;
			13'd38: ff_rdata <= 8'h52;
			13'd39: ff_rdata <= 8'h33;
			13'd40: ff_rdata <= 8'h2D;
			13'd41: ff_rdata <= 8'h53;
			13'd42: ff_rdata <= 8'h44;
			13'd43: ff_rdata <= 8'h52;
			13'd44: ff_rdata <= 8'h41;
			13'd45: ff_rdata <= 8'h4D;
			13'd46: ff_rdata <= 8'h20;
			13'd47: ff_rdata <= 8'h54;
			13'd48: ff_rdata <= 8'h65;
			13'd49: ff_rdata <= 8'h73;
			13'd50: ff_rdata <= 8'h74;
			13'd51: ff_rdata <= 8'h20;
			13'd52: ff_rdata <= 8'h70;
			13'd53: ff_rdata <= 8'h72;
			13'd54: ff_rdata <= 8'h6F;
			13'd55: ff_rdata <= 8'h67;
			13'd56: ff_rdata <= 8'h72;
			13'd57: ff_rdata <= 8'h61;
			13'd58: ff_rdata <= 8'h6D;
			13'd59: ff_rdata <= 8'h0D;
			13'd60: ff_rdata <= 8'h0A;
			13'd61: ff_rdata <= 8'h00;
			13'd62: ff_rdata <= 8'h53;
			13'd63: ff_rdata <= 8'h44;
			13'd64: ff_rdata <= 8'h52;
			13'd65: ff_rdata <= 8'h41;
			13'd66: ff_rdata <= 8'h4D;
			13'd67: ff_rdata <= 8'h20;
			13'd68: ff_rdata <= 8'h42;
			13'd69: ff_rdata <= 8'h75;
			13'd70: ff_rdata <= 8'h73;
			13'd71: ff_rdata <= 8'h79;
			13'd72: ff_rdata <= 8'h20;
			13'd73: ff_rdata <= 8'h43;
			13'd74: ff_rdata <= 8'h68;
			13'd75: ff_rdata <= 8'h65;
			13'd76: ff_rdata <= 8'h63;
			13'd77: ff_rdata <= 8'h6B;
			13'd78: ff_rdata <= 8'h20;
			13'd79: ff_rdata <= 8'h2E;
			13'd80: ff_rdata <= 8'h2E;
			13'd81: ff_rdata <= 8'h2E;
			13'd82: ff_rdata <= 8'h20;
			13'd83: ff_rdata <= 8'h00;
			13'd84: ff_rdata <= 8'h4F;
			13'd85: ff_rdata <= 8'h4B;
			13'd86: ff_rdata <= 8'h0D;
			13'd87: ff_rdata <= 8'h0A;
			13'd88: ff_rdata <= 8'h00;
			13'd89: ff_rdata <= 8'hCD;
			13'd90: ff_rdata <= 8'h68;
			13'd91: ff_rdata <= 8'h00;
			13'd92: ff_rdata <= 8'hE6;
			13'd93: ff_rdata <= 8'h01;
			13'd94: ff_rdata <= 8'h20;
			13'd95: ff_rdata <= 8'hF9;
			13'd96: ff_rdata <= 8'hCD;
			13'd97: ff_rdata <= 8'h68;
			13'd98: ff_rdata <= 8'h00;
			13'd99: ff_rdata <= 8'hE6;
			13'd100: ff_rdata <= 8'h01;
			13'd101: ff_rdata <= 8'h28;
			13'd102: ff_rdata <= 8'hF9;
			13'd103: ff_rdata <= 8'hC9;
			13'd104: ff_rdata <= 8'hDB;
			13'd105: ff_rdata <= 8'h10;
			13'd106: ff_rdata <= 8'hC9;
			13'd107: ff_rdata <= 8'hF5;
			13'd108: ff_rdata <= 8'h1A;
			13'd109: ff_rdata <= 8'h13;
			13'd110: ff_rdata <= 8'hB7;
			13'd111: ff_rdata <= 8'h28;
			13'd112: ff_rdata <= 8'h04;
			13'd113: ff_rdata <= 8'hD3;
			13'd114: ff_rdata <= 8'h10;
			13'd115: ff_rdata <= 8'h18;
			13'd116: ff_rdata <= 8'hF7;
			13'd117: ff_rdata <= 8'hF1;
			13'd118: ff_rdata <= 8'hC9;
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
