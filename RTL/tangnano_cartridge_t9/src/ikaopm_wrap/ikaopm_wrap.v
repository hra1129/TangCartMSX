// --------------------------------------------------------------------
//	IKAOPLL Wrapper
// ====================================================================
//	2024/09/15 t.hara
// --------------------------------------------------------------------

module ip_ikaopm_wrapper (
	input			n_reset,
	input			clk,
	input			mclkpcen_n,
	input			n_memreq,
	input			n_sltsl,
	input			n_wr,
	input			n_rd,
	input	[15:0]	address,
	input	[7:0]	wdata,
	output	[7:0]	rdata,
	output			rdata_en,
	output	[16:0]	sound_out,
	output			opm_int_n
);
	localparam		c_memory_mapped_io	= 16'h3FF0;		//	0x3FF0, 0x3FF1, 0x7FF0, 0x7FF1 (ignore bit0 and bit14)
	localparam		c_memory_signature	= 16'h0080;
	reg				ff_io_en;
	wire			w_memio_dec_n;
	wire			w_io_dec_n;
	wire			w_cs_n;
	reg				ff_rom_rdata_en;
	reg				ff_rdata_en;
	reg				ff_rom_rdata;
	wire	[7:0]	w_opm_rdata;
	wire			w_opm_rdata_en;
	wire	[15:0]	w_opm_out_r;
	wire	[15:0]	w_opm_out_l;

	// --------------------------------------------------------------------
	//	Address decoder
	// --------------------------------------------------------------------
	assign w_cs_n			= ( { address[15], 1'b0, address[13:1], 1'b0 } == c_memory_mapped_io ) ? (n_sltsl | n_memreq): 1'b1;
	assign rdata			= ff_rom_rdata_en ? ff_rom_rdata : w_opm_rdata;
	assign rdata_en			= ff_rdata_en;
	assign sound_out		= { w_opm_out_r[15], w_opm_out_r } + { w_opm_out_l[15], w_opm_out_l };

	// --------------------------------------------------------------------
	//	Internal ROM
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_rom_rdata_en	<= 1'b0;
			ff_rdata_en		<= 1'b0;
		end
		else if( !n_sltsl && !n_rd && ( address[15:14] == 2'd0 ) ) begin
			ff_rom_rdata_en	<= ~w_cs_n;
			ff_rdata_en		<= ~w_cs_n | w_opm_rdata_en;
		end
		else begin
			ff_rom_rdata_en <= 1'b0;
			ff_rdata_en		<= 1'b0;
		end
	end

	always @( posedge clk ) begin
		if( {address[15:4], 4'd0 } == c_memory_signature ) begin
			case( address[3:0] )
			4'h0:		ff_rom_rdata	<= 8'h4D;	//	'M'
			4'h1:		ff_rom_rdata	<= 8'h43;	//	'C'
			4'h2:		ff_rom_rdata	<= 8'h48;	//	'H'
			4'h3:		ff_rom_rdata	<= 8'h46;	//	'F'
			4'h4:		ff_rom_rdata	<= 8'h4D;	//	'M'
			4'h5:		ff_rom_rdata	<= 8'h30;	//	'0'
			4'h6:		ff_rom_rdata	<= 8'h08;	//	ROM serial #
			4'h7:		ff_rom_rdata	<= 8'h00;	//	FM sound chip type
			4'h8:		ff_rom_rdata	<= 8'h00;	//	software version #
			default:	ff_rom_rdata	<= 8'hC9;
			endcase
		end
		else begin
			ff_rom_rdata	<= 8'hC9;
		end
	end

	// --------------------------------------------------------------------
	//	IKAOPLL body
	// --------------------------------------------------------------------
	IKAOPM #(
		.FULLY_SYNCHRONOUS	( 1					), 
		.FAST_RESET			( 1					),
		.USE_BRAM			( 1					)
	) u_ym2151 (
		.i_EMUCLK			( clk				),		// emulator master clock
		.i_phiM_PCEN_n		( mclkpcen_n		),		// phiM positive edge clock enable(negative logic)
		.i_IC_n				( n_reset			),		// Chip Reset
		.o_phi1				(					),
		.i_CS_n				( w_cs_n			),
		.i_RD_n				( n_rd				),
		.i_WR_n				( n_wr				),
		.i_A0				( address[0]		),
		.i_D				( wdata				),
		.o_D				( w_opm_rdata		),
		.o_D_OE				( w_opm_rdata_en	),
		.o_CT2				( 					),		// BIT7 of register 0x1B, pin 8
		.o_CT1				( 					),		// BIT6 of register 0x1B, pin 9
		.o_IRQ_n			( opm_int_n			),
		.o_SH1				( 					),
		.o_SH2				( 					),
		.o_SO				( 					),
		.o_EMU_R_SAMPLE		( 					),
		.o_EMU_L_SAMPLE		( 					),
		.o_EMU_R_EX			( 					),
		.o_EMU_L_EX			( 					),
		.o_EMU_R			( w_opm_out_r		),
		.o_EMU_L			( w_opm_out_l		)
	);
endmodule
