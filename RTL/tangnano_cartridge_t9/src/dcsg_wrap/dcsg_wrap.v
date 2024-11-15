// --------------------------------------------------------------------
//	DCSG (SN76489) Wrapper
// ====================================================================
//	2024/11/15 t.hara
// --------------------------------------------------------------------

module ip_dcsg_wrapper (
	input			n_reset,
	input			clk,
	input			en_clk_psg_i,
	input			n_ioreq,
	input			n_wr,
	input	[15:0]	address,
	input	[7:0]	wdata,
	output	[13:0]	sound_out			//	signed
);
	localparam		c_io_port	= 8'h3F;
	wire			w_ready_o;
	wire			w_ce_n;
	reg		[1:0]	ff_wr_state;
	reg				ff_ce_n;
	reg				ff_wr_n;
	reg		[7:0]	ff_wdata;

	// --------------------------------------------------------------------
	//	Address decoder
	// --------------------------------------------------------------------
	assign w_ce_n	= (address[7:0]  == c_io_port ) ? n_ioreq : 1'b1;

	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_wr_state		<= 2'd0;
			ff_wr_n			<= 1'b1;
			ff_ce_n			<= 1'b1;
		end
		else if( en_clk_psg_i ) begin
			case( ff_wr_state )
			default:
				begin
					if( w_ce_n == 1'b0 ) begin
						ff_wr_state	<= 2'd1;
						ff_wr_n		<= 1'b0;
						ff_ce_n		<= 1'b0;
						ff_wdata	<= wdata;
					end
				end
			2'd1:
				begin
					if( w_ready_o ) begin
						ff_wr_state	<= 2'd2;
						ff_wr_n		<= 1'b1;
						ff_ce_n		<= 1'b0;
					end
					else begin
						//	hold
					end
				end
			2'd2:
				begin
					ff_wr_state	<= 2'd0;
					ff_wr_n		<= 1'b1;
					ff_ce_n		<= 1'b1;
				end
			endcase
		end
	end

	// --------------------------------------------------------------------
	//	SN76489 body
	// --------------------------------------------------------------------
	sn76489_audio #(
		// 0 = normal I/O, 32 clocks per write
		// 1 = fast I/O, around 2 clocks per write
		.FAST_IO_G			( 1'b0			),
		// Minimum allowable period count (see comments further
		// down for more information), recommended:
		//  6	18643.46Hz First audible count.
		// 17	 6580.04Hz Counts at 16 are known to be used for
		//		 amplitude-modulation.
		.MIN_PERIOD_CNT_G	( 6				)
	) u_sn76489_audio (
		.clk_i				( clk			),
		.en_clk_psg_i		( en_clk_psg_i	),
		.ce_n_i				( ff_ce_n		),
		.wr_n_i				( ff_wr_n		),
		.ready_o			( w_ready_o		),
		.data_i				( ff_wdata		),
		.ch_a_o				( 				),
		.ch_b_o				( 				),
		.ch_c_o				( 				),
		.noise_o			( 				),
		.mix_audio_o		( 				),
		.pcm14s_o			( sound_out		)
	);
endmodule
