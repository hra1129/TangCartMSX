module Gowin_CLKDIV (
	output			clkout,
	input			hclkin,
	input			resetn
);
	assign clkout = hclkin;
endmodule

module Gowin_rPLL (
	output			clkout,
	output			lock,
	input			clkin
);
	assign lock		= 1'b1;
	assign clkout	= clkin;
endmodule

module Gowin_rPLL2 (
	output			clkout,
	output			lock,
	output			clkoutp,
	input			clkin
);
	assign lock		= 1'b1;
	assign clkout	= clkin;
	assign clkoutp	= ~clkin;
endmodule

module DVI_TX_Top (
	input			I_rst_n,
	input			I_serial_clk,
	input			I_rgb_clk,
	input			I_rgb_vs,
	input			I_rgb_hs,
	input			I_rgb_de,
	input	[7:0]	I_rgb_r,
	input	[7:0]	I_rgb_g,
	input	[7:0]	I_rgb_b,
	output			O_tmds_clk_p,
	output			O_tmds_clk_n,
	output	[2:0]	O_tmds_data_p,
	output	[2:0]	O_tmds_data_n 
);
	assign O_tmds_clk_p		= 1'b0;
	assign O_tmds_clk_n		= 1'b0;
	assign O_tmds_data_p	= 3'd0;
	assign O_tmds_data_n	= 3'd0;
endmodule
