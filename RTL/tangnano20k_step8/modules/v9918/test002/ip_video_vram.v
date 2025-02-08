// --------------------------------------------------------------------
// IP_MSXMUSIC_ROM
// --------------------------------------------------------------------

module ip_video_vram (
	input			clk,
	input			n_mreq,
	input			n_wr,
	input			n_rd,
	input	[22:0]	address,
	input	[7:0]	wdata,
	output	[31:0]	rdata,
	output			rdata_en
);
	reg		[7:0]	ff_ram[0:1048575];
	reg		[31:0]	ff_rdata;
	reg				ff_rdata_en;
	integer			i;

	always @( posedge clk ) begin
		if( !n_mreq && !n_rd ) begin
			ff_rdata	<= { 
				ff_ram[ { address[17:2], 2'd3 } ], 
				ff_ram[ { address[17:2], 2'd2 } ], 
				ff_ram[ { address[17:2], 2'd1 } ], 
				ff_ram[ { address[17:2], 2'd0 } ]
			};
			ff_rdata_en	<= 1'b1;
		end
		else begin
			ff_rdata	<= 32'd0;
			ff_rdata_en	<= 1'b0;
		end
	end

	always @( posedge clk ) begin
		if( !n_mreq && !n_wr ) begin
			ff_ram[ address ] <= wdata;
		end
	end

	assign rdata	= ff_rdata;
	assign rdata_en	= ff_rdata_en;

	initial begin
		for( i = 0; i < 640 * 360; i = i + 1 ) begin
			ff_ram[i] = (i & 255);
		end
	end
endmodule
