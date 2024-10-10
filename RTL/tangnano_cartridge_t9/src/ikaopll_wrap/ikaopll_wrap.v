// --------------------------------------------------------------------
//	IKAOPLL Wrapper
// ====================================================================
//	2024/09/15 t.hara
// --------------------------------------------------------------------

module ip_ikaopll_wrapper #(
	parameter		BUILT_IN_MODE = 0		// 0: Cartridge mode, 1: Built in mode
) (
	input			n_reset,
	input			clk,
	input			mclkpcen_n,
	input			n_ioreq,
	input			n_sltsl,
	input			n_wr,
	input	[15:0]	address,
	input	[7:0]	wdata,
	output	[15:0]	sound_out
);
	reg				ff_io_en;
	wire			w_memio_dec_n;
	wire			w_io_dec_n;
	wire			w_cs_n;

	// --------------------------------------------------------------------
	//	Address decoder
	// --------------------------------------------------------------------
	assign w_memio_dec_n	= (address[15:1] == 15'b0111_1111_1111_010) ? (n_sltsl | n_wr     ): 1'b1;
	assign w_io_dec_n		= (address[7:1]  == 7'b0111_110           ) ? (n_ioreq | ~ff_io_en): 1'b1;
	assign w_cs_n			= w_memio_dec_n & w_io_dec_n;

	// --------------------------------------------------------------------
	//	I/O port enabler
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_io_en <= BUILT_IN_MODE;
		end
		else if( !n_sltsl && !n_wr && (address == 16'h7FF6) ) begin
			//	Write 7FF6h
			ff_io_en <= wdata[0];
		end
		else begin
			//	hold
		end
	end

	// --------------------------------------------------------------------
	//	IKAOPLL body
	// --------------------------------------------------------------------
	IKAOPLL #(
		.FULLY_SYNCHRONOUS			( 1					),		//	use DFF only
		.FAST_RESET					( 1					),		//	speed up reset
		.ALTPATCH_CONFIG_MODE		( 0					),		//	0 to use external wire, 1 to use bit[4] of TEST register
		.USE_PIPELINED_MULTIPLIER	( 1					)		//	1 to add pipelined multiplier to increase fmax
	) u_ikaopll (
		.i_XIN_EMUCLK				( clk				),
		.o_XOUT						( 					),		//	no use: Clock output
		.i_phiM_PCEN_n				( mclkpcen_n		),
		.i_IC_n						( n_reset			),
		.i_ALTPATCH_EN				( 1'b0				),		//	VRC7 patch disable
		.i_CS_n						( w_cs_n			),
		.i_WR_n						( n_wr				),
		.i_A0						( address[0]		),
		.i_D						( wdata				),
		.o_D						( 					),		//	no use: Read test bits
		.o_D_OE						( 					),		//	no use: o_D enable
		.o_DAC_EN_MO				( 					),		//	no use
		.o_DAC_EN_RO				( 					),		//	no use
		.o_IMP_NOFLUC_SIGN			( 					),		//	no use
		.o_IMP_NOFLUC_MAG			( 					),		//	no use
		.o_IMP_FLUC_SIGNED_MO		( 					),		//	no use
		.o_IMP_FLUC_SIGNED_RO		( 					),		//	no use
		.i_ACC_SIGNED_MOVOL			( 5'd10				),		//	Melody volume level: -16...15 (SIGNED)
		.i_ACC_SIGNED_ROVOL			( 5'd15				),		//	Drum volume level  : -16...15 (SIGNED)
		.o_ACC_SIGNED_STRB			( 					),		//	no use
		.o_ACC_SIGNED				( sound_out			)		//	sound out
	);
endmodule
