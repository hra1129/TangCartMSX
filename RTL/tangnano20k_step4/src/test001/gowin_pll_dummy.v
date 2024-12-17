// --------------------------------------------------------------------
//	PLL dummy
// ====================================================================
//	t.hara
// --------------------------------------------------------------------
module Gowin_PLL (
	output			clkout,			//	85.909MHz
	output			clkoutd,		//	42.9545MHz
	input			clkin			//	85.909MHz
);
	reg		ff_clkoutd = 1'b0;

	always @( posedge clkin ) begin
		ff_clkoutd <= ~ff_clkoutd;
	end

	assign clkoutd	= ff_clkoutd;
	assign clkout	= clkin;
endmodule
