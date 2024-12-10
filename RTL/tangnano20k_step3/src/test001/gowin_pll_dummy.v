// --------------------------------------------------------------------
//	PLL dummy
// ====================================================================
//	t.hara
// --------------------------------------------------------------------
module Gowin_PLL (
	output			clkout,
	output			clkoutd,
	input			clkin
);
	reg		ff_clkoutd = 1'b0;

	always @( posedge clkin ) begin
		ff_clkoutd <= ~ff_clkoutd;
	end

	assign clkoutd	= ff_clkoutd;
	assign clkout	= clkin;
endmodule
