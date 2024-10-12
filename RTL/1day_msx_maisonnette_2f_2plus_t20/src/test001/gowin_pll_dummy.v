// --------------------------------------------------------------------
//	Gowin PLL simulation model
// ====================================================================
//	2024/10/10th	t.hara
// --------------------------------------------------------------------

module Gowin_PLL (
	output clkout,
	output clkoutp,
	input clkin
);
	assign clkout	= clkin;
	assign clkoutp	= ~clkin;
endmodule
