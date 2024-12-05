// --------------------------------------------------------------------
// IP_HELLO_WORLD_ROM
// --------------------------------------------------------------------

module ip_hello_world_rom (
	input			clk,
	input			n_cs,
	input			n_rd,
	input	[13:0]	address,
	output	[7:0]	rdata,
	output			rdata_en
);
	reg		[7:0]	ff_rdata;
	reg				ff_rdata_en;

	always @( posedge clk ) begin
		if( !n_cs && !n_rd ) begin
			case( address )
			14'd0: ff_rdata <= 8'hF3;
			14'd1: ff_rdata <= 8'h31;
			14'd2: ff_rdata <= 8'h00;
			14'd3: ff_rdata <= 8'h80;
			14'd4: ff_rdata <= 8'hCD;
			14'd5: ff_rdata <= 8'h26;
			14'd6: ff_rdata <= 8'h00;
			14'd7: ff_rdata <= 8'hB7;
			14'd8: ff_rdata <= 8'h20;
			14'd9: ff_rdata <= 8'hFA;
			14'd10: ff_rdata <= 8'hCD;
			14'd11: ff_rdata <= 8'h26;
			14'd12: ff_rdata <= 8'h00;
			14'd13: ff_rdata <= 8'hB7;
			14'd14: ff_rdata <= 8'h28;
			14'd15: ff_rdata <= 8'hFA;
			14'd16: ff_rdata <= 8'h0F;
			14'd17: ff_rdata <= 8'h38;
			14'd18: ff_rdata <= 8'h03;
			14'd19: ff_rdata <= 8'h0F;
			14'd20: ff_rdata <= 8'h38;
			14'd21: ff_rdata <= 8'h08;
			14'd22: ff_rdata <= 8'h21;
			14'd23: ff_rdata <= 8'h3F;
			14'd24: ff_rdata <= 8'h00;
			14'd25: ff_rdata <= 8'hCD;
			14'd26: ff_rdata <= 8'h36;
			14'd27: ff_rdata <= 8'h00;
			14'd28: ff_rdata <= 8'h18;
			14'd29: ff_rdata <= 8'hE6;
			14'd30: ff_rdata <= 8'h21;
			14'd31: ff_rdata <= 8'h5E;
			14'd32: ff_rdata <= 8'h00;
			14'd33: ff_rdata <= 8'hCD;
			14'd34: ff_rdata <= 8'h36;
			14'd35: ff_rdata <= 8'h00;
			14'd36: ff_rdata <= 8'h18;
			14'd37: ff_rdata <= 8'hDE;
			14'd38: ff_rdata <= 8'hDB;
			14'd39: ff_rdata <= 8'h10;
			14'd40: ff_rdata <= 8'h07;
			14'd41: ff_rdata <= 8'h07;
			14'd42: ff_rdata <= 8'hC9;
			14'd43: ff_rdata <= 8'h0E;
			14'd44: ff_rdata <= 8'h10;
			14'd45: ff_rdata <= 8'hED;
			14'd46: ff_rdata <= 8'h40;
			14'd47: ff_rdata <= 8'hCB;
			14'd48: ff_rdata <= 8'h18;
			14'd49: ff_rdata <= 8'h38;
			14'd50: ff_rdata <= 8'hFA;
			14'd51: ff_rdata <= 8'hED;
			14'd52: ff_rdata <= 8'h79;
			14'd53: ff_rdata <= 8'hC9;
			14'd54: ff_rdata <= 8'h7E;
			14'd55: ff_rdata <= 8'h23;
			14'd56: ff_rdata <= 8'hB7;
			14'd57: ff_rdata <= 8'hC8;
			14'd58: ff_rdata <= 8'hCD;
			14'd59: ff_rdata <= 8'h2B;
			14'd60: ff_rdata <= 8'h00;
			14'd61: ff_rdata <= 8'h18;
			14'd62: ff_rdata <= 8'hF7;
			14'd63: ff_rdata <= 8'h50;
			14'd64: ff_rdata <= 8'h72;
			14'd65: ff_rdata <= 8'h65;
			14'd66: ff_rdata <= 8'h73;
			14'd67: ff_rdata <= 8'h73;
			14'd68: ff_rdata <= 8'h65;
			14'd69: ff_rdata <= 8'h64;
			14'd70: ff_rdata <= 8'h20;
			14'd71: ff_rdata <= 8'h42;
			14'd72: ff_rdata <= 8'h55;
			14'd73: ff_rdata <= 8'h54;
			14'd74: ff_rdata <= 8'h54;
			14'd75: ff_rdata <= 8'h4F;
			14'd76: ff_rdata <= 8'h4E;
			14'd77: ff_rdata <= 8'h30;
			14'd78: ff_rdata <= 8'h21;
			14'd79: ff_rdata <= 8'h21;
			14'd80: ff_rdata <= 8'h20;
			14'd81: ff_rdata <= 8'h54;
			14'd82: ff_rdata <= 8'h68;
			14'd83: ff_rdata <= 8'h61;
			14'd84: ff_rdata <= 8'h6E;
			14'd85: ff_rdata <= 8'h6B;
			14'd86: ff_rdata <= 8'h20;
			14'd87: ff_rdata <= 8'h79;
			14'd88: ff_rdata <= 8'h6F;
			14'd89: ff_rdata <= 8'h75;
			14'd90: ff_rdata <= 8'h21;
			14'd91: ff_rdata <= 8'h0D;
			14'd92: ff_rdata <= 8'h0A;
			14'd93: ff_rdata <= 8'h00;
			14'd94: ff_rdata <= 8'h50;
			14'd95: ff_rdata <= 8'h72;
			14'd96: ff_rdata <= 8'h65;
			14'd97: ff_rdata <= 8'h73;
			14'd98: ff_rdata <= 8'h73;
			14'd99: ff_rdata <= 8'h65;
			14'd100: ff_rdata <= 8'h64;
			14'd101: ff_rdata <= 8'h20;
			14'd102: ff_rdata <= 8'h42;
			14'd103: ff_rdata <= 8'h55;
			14'd104: ff_rdata <= 8'h54;
			14'd105: ff_rdata <= 8'h54;
			14'd106: ff_rdata <= 8'h4F;
			14'd107: ff_rdata <= 8'h4E;
			14'd108: ff_rdata <= 8'h31;
			14'd109: ff_rdata <= 8'h21;
			14'd110: ff_rdata <= 8'h21;
			14'd111: ff_rdata <= 8'h20;
			14'd112: ff_rdata <= 8'h48;
			14'd113: ff_rdata <= 8'h65;
			14'd114: ff_rdata <= 8'h6C;
			14'd115: ff_rdata <= 8'h6C;
			14'd116: ff_rdata <= 8'h6F;
			14'd117: ff_rdata <= 8'h21;
			14'd118: ff_rdata <= 8'h21;
			14'd119: ff_rdata <= 8'h0D;
			14'd120: ff_rdata <= 8'h0A;
			14'd121: ff_rdata <= 8'h00;
			default: ff_rdata <= 8'd0;
			endcase
			ff_rdata_en <= 1'b1;
		end
		else begin
			ff_rdata <= 8'd0;
			ff_rdata_en <= 1'b0;
		end
	end

	assign rdata	= ff_rdata;
	assign rdata_en	= ff_rdata_en;
endmodule
