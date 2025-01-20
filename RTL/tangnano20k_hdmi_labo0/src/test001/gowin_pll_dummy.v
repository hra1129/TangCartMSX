// --------------------------------------------------------------------
//	PLL dummy
// ====================================================================
//	t.hara
// --------------------------------------------------------------------
module Gowin_rPLL (
	output			clkout,			//	371.25MHz
	output			lock,
	input			clkin			//	371.25MHz
);
	assign clkout	= clkin;
endmodule

// --------------------------------------------------------------------
module Gowin_CLKDIV (
	output			clkout,			//	74.25MHz
	input			hclkin,			//	371.25MHz
	input			resetn
);
	reg	[2:0]	ff_divider = 3'd0;
	reg			ff_clkout = 1'b0;

	always @( edge hclkin ) begin
		if( !resetn ) begin
			ff_divider	<= 3'd0;
			ff_clkout	<= 1'b0;
		end
		else if( ff_divider == 3'd5 ) begin
			ff_divider	<= 3'd0;
			ff_clkout	<= ~ff_clkout;
		end
		else begin
			ff_divider	<= ff_divider + 3'd1;
		end
	end

	assign clkout	= ff_clkout;
endmodule
