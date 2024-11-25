	function func_(
		input	[1:0]	iset,
		input	[2:0]	mcycle,
		input	[7:0]	irb
	);
		call = 1'b0;
		ldz = 1'b0;
		ldw = 1'b0;
		exchangerp = 1'b0;
		i_retn = 1'b0;
		i_btr = 1'b0;
		write = 1'b0;
		xybit_undoc = 1'b0;

		case( iset )
		// --------------------------------------------------------------------
		//  unprefixed instructions
		// --------------------------------------------------------------------
		2'b00:
			case( irb )
			8'h40, 8'h41, 8'h42, 8'h43, 8'h44, 8'h45, 8'h47, 
			8'h48, 8'h49, 8'h4A, 8'h4B, 8'h4C, 8'h4D, 8'h4F, 
			8'h50, 8'h51, 8'h52, 8'h53, 8'h54, 8'h55, 8'h57, 
			8'h58, 8'h59, 8'h5A, 8'h5B, 8'h5C, 8'h5D, 8'h5F, 
			8'h60, 8'h61, 8'h62, 8'h63, 8'h64, 8'h65, 8'h67, 
			8'h68, 8'h69, 8'h6A, 8'h6B, 8'h6C, 8'h6D, 8'h6F, 
			8'h78, 8'h79, 8'h7A, 8'h7B, 8'h7C, 8'h7D, 8'h7F:
				begin
					exchangerp = 1'b1;
				end
			8'h70, 8'h71, 8'h72, 8'h73, 8'h74, 8'h75, 8'h77:
				begin
					// ld (hl),r
					case( mcycle )
					3'd2:
							write = 1'b1;
					endcase
				end
			8'h36:
				begin
					// ld (hl),n
					case( mcycle )
					3'd3:
						begin
							write = 1'b1;
						end
					default:
						begin
							//	hold
						end
					endcase
				end
			8'h3A:
				begin
					// ld a,(nn)
					case( mcycle )
					3'd2:
							ldz = 1'b1;
					default:
						begin
							//	hold
						end
					endcase
				end
			8'h02:
				begin
					// ld (bc),a
					case( mcycle )
					3'd2:
							write = 1'b1;
					default:
						begin
							//	hold
						end
					endcase
				end
			8'h12:
				begin
					// ld (de),a
					case( mcycle )
					3'd2:
							write = 1'b1;
					default:
						begin
							//	hold
						end
					endcase
				end
			8'h32:
				begin
					case( mcycle )
					3'd2:
							ldz = 1'b1;
					3'd4:
							write = 1'b1;
					default:
						begin
							//	hold
						end
					endcase
				end
			8'h2A:
					// ld hl,(nn)
					case( mcycle )
					3'd2:
							ldz = 1'b1;
					3'd3:
							ldw = 1'b1;
					3'd5:
					default:
						begin
							//	hold
						end
					endcase
			8'h22:
					// ld (nn),hl
					case( mcycle )
					3'd2:
							ldz = 1'b1;
					3'd3:
							ldw = 1'b1;
					3'd4:
							write = 1'b1;
					3'd5:
							write = 1'b1;
					default:
						begin
							//	hold
						end
					endcase
			8'hF9:

			8'hC5, 8'hD5, 8'hE5, 8'hF5:
					// push qq
					case( mcycle )
					3'd2:
							write = 1'b1;
					3'd3:
							write = 1'b1;
					default:
						begin
							//	hold
						end
					endcase
			8'hE3:
					// ex (sp),hl
					case( mcycle )
					3'd3:
							write = 1'b1;
					3'd5:
							write = 1'b1;
					default:
						begin
							//	hold
						end
					endcase
			8'h34:
					// inc (hl)
					case( mcycle )
					3'd3:
							write = 1'b1;
					default:
						begin
							//	hold
						end
					endcase
			8'h35:
					// dec (hl)
					case( mcycle )
					3'd3:
							write = 1'b1;
					default:
						begin
							//	hold
						end
					endcase
			8'h27:
					// daa
			8'h00:
					if( nmicycle = 1'b1 ) begin
							// nmi
							case( mcycle )
							3'd2:
									write = 1'b1;
							3'd3:
									write = 1'b1;
							default:
								begin
									//	hold
								end
							endcase
					else if( intcycle = 1'b1 ) begin
							// int (im 2)
							case( mcycle )
							3'd1:
									ldz = 1'b1;
							3'd2:
									write = 1'b1;
							3'd3:
									write = 1'b1;
							3'd4:
									ldz = 1'b1;
							default:
								begin
									//	hold
								end
							endcase
					else
							// nop
					end
			8'hC3:
					// jp nn
					case( mcycle )
					3'd2:
							ldz = 1'b1;
					default:
						begin
							//	hold
						end
					endcase
			8'hC2, 8'hCA, 8'hD2, 8'hDA, 8'hE2, 8'hEA, 8'hF2, 8'hFA:
					// jp cc,nn
					case( mcycle )
					3'd2:
							ldz = 1'b1;
					default:
						begin
							//	hold
						end
					endcase
			8'hCD:
					// call nn
					case( mcycle )
					3'd2:
							ldz = 1'b1;
					3'd3:
							ldw = 1'b1;
					3'd4:
							write = 1'b1;
					3'd5:
							write = 1'b1;
							call = 1'b1;
					default:
						begin
							//	hold
						end
					endcase
			8'hC4, 8'hCC, 8'hD4, 8'hDC, 8'hE4, 8'hEC, 8'hF4, 8'hFC:
					// call cc,nn
					case( mcycle )
					3'd2:
							ldz = 1'b1;
					3'd3:
							ldw = 1'b1;
					3'd4:
							write = 1'b1;
					3'd5:
							write = 1'b1;
							call = 1'b1;
					default:
						begin
							//	hold
						end
					endcase
			8'hC9:
					case( mcycle )
					3'd2:
							ldz = 1'b1;
					default:
						begin
							//	hold
						end
					endcase
			8'hC0, 8'hC8, 8'hD0, 8'hD8, 8'hE0, 8'hE8, 8'hF0, 8'hF8:
					case( mcycle )
					3'd2:
							ldz = 1'b1;
					default:
						begin
							//	hold
						end
					endcase
			8'hC7, 8'hCF, 8'hD7, 8'hDF, 8'hE7, 8'hEF, 8'hF7, 8'hFF:
					case( mcycle )
					3'd2:
							write = 1'b1;
					3'd3:
							write = 1'b1;
					default:
						begin
							//	hold
						end
					endcase
			8'hD3:
					// out (n),a
					case( mcycle )
					3'd3:
							write = 1'b1;
					default:
						begin
							//	hold
						end
					endcase
			endcase
		// --------------------------------------------------------------------
		//  cb prefixed instructions
		// --------------------------------------------------------------------
		2'b01:

			case( irb )
			8'h00, 8'h01, 8'h02, 8'h03, 8'h04, 8'h05, 8'h07, 
			8'h10, 8'h11, 8'h12, 8'h13, 8'h14, 8'h15, 8'h17, 
			8'h08, 8'h09, 8'h0A, 8'h0B, 8'h0C, 8'h0D, 8'h0F, 
			8'h18, 8'h19, 8'h1A, 8'h1B, 8'h1C, 8'h1D, 8'h1F, 
			8'h20, 8'h21, 8'h22, 8'h23, 8'h24, 8'h25, 8'h27, 
			8'h28, 8'h29, 8'h2A, 8'h2B, 8'h2C, 8'h2D, 8'h2F, 
			8'h30, 8'h31, 8'h32, 8'h33, 8'h34, 8'h35, 8'h37, 
			8'h38, 8'h39, 8'h3A, 8'h3B, 8'h3C, 8'h3D, 8'h3F:
				if( xy_state=2'b00 ) begin
				else
					xybit_undoc = 1'b1;
					case( mcycle )
					3'd3:
						write = 1'b1;
					default:
						begin
							//	hold
						end
					endcase
				end
			8'h06, 8'h16, 8'h0E, 8'h1E, 8'h2E, 8'h3E, 8'h26, 8'h36:
				case( mcycle )
				3'd3:
					write = 1'b1;
				default:
					begin
						//	hold
					end
				endcase
			8'h40, 8'h41, 8'h42, 8'h43, 8'h44, 8'h45, 8'h47, 
			8'h48, 8'h49, 8'h4A, 8'h4B, 8'h4C, 8'h4D, 8'h4F, 
			8'h50, 8'h51, 8'h52, 8'h53, 8'h54, 8'h55, 8'h57, 
			8'h58, 8'h59, 8'h5A, 8'h5B, 8'h5C, 8'h5D, 8'h5F, 
			8'h60, 8'h61, 8'h62, 8'h63, 8'h64, 8'h65, 8'h67, 
			8'h68, 8'h69, 8'h6A, 8'h6B, 8'h6C, 8'h6D, 8'h6F, 
			8'h70, 8'h71, 8'h72, 8'h73, 8'h74, 8'h75, 8'h77, 
			8'h78, 8'h79, 8'h7A, 8'h7B, 8'h7C, 8'h7D, 8'h7F:
				// bit b,r
				if( xy_state=2'b00 ) begin
				else
				// bit b,(ix+d), undocumented
					xybit_undoc = 1'b1;
				end
			8'hC0, 8'hC1, 8'hC2, 8'hC3, 8'hC4, 8'hC5, 8'hC7, 
			8'hC8, 8'hC9, 8'hCA, 8'hCB, 8'hCC, 8'hCD, 8'hCF, 
			8'hD0, 8'hD1, 8'hD2, 8'hD3, 8'hD4, 8'hD5, 8'hD7, 
			8'hD8, 8'hD9, 8'hDA, 8'hDB, 8'hDC, 8'hDD, 8'hDF, 
			8'hE0, 8'hE1, 8'hE2, 8'hE3, 8'hE4, 8'hE5, 8'hE7, 
			8'hE8, 8'hE9, 8'hEA, 8'hEB, 8'hEC, 8'hED, 8'hEF, 
			8'hF0, 8'hF1, 8'hF2, 8'hF3, 8'hF4, 8'hF5, 8'hF7, 
			8'hF8, 8'hF9, 8'hFA, 8'hFB, 8'hFC, 8'hFD, 8'hFF:
				// set b,r
				if( xy_state=2'b00 ) begin
				else
				// set b,(ix+d),reg, undocumented
					xybit_undoc = 1'b1;
					case( mcycle )
					3'd3:
						write = 1'b1;
					default:
						begin
							//	hold
						end
					endcase
				end
			8'hC6, 8'hCE, 8'hD6, 8'hDE, 8'hE6, 8'hEE, 8'hF6, 8'hFE:
				// set b,(hl)
				case( mcycle )
				3'd3:
					write = 1'b1;
				default:
					begin
						//	hold
					end
				endcase
			8'h80, 8'h81, 8'h82, 8'h83, 8'h84, 8'h85, 8'h87, 
			8'h88, 8'h89, 8'h8A, 8'h8B, 8'h8C, 8'h8D, 8'h8F, 
			8'h90, 8'h91, 8'h92, 8'h93, 8'h94, 8'h95, 8'h97, 
			8'h98, 8'h99, 8'h9A, 8'h9B, 8'h9C, 8'h9D, 8'h9F, 
			8'hA0, 8'hA1, 8'hA2, 8'hA3, 8'hA4, 8'hA5, 8'hA7, 
			8'hA8, 8'hA9, 8'hAA, 8'hAB, 8'hAC, 8'hAD, 8'hAF, 
			8'hB0, 8'hB1, 8'hB2, 8'hB3, 8'hB4, 8'hB5, 8'hB7, 
			8'hB8, 8'hB9, 8'hBA, 8'hBB, 8'hBC, 8'hBD, 8'hBF:
				// res b,r
				if( xy_state=2'b00 ) begin
				else
				// res b,(ix+d),reg, undocumented
					xybit_undoc = 1'b1;
					case( mcycle )
					3'd3:
						write = 1'b1;
					default:
						begin
							//	hold
						end
					endcase
				end

			8'h86, 8'h8E, 8'h96, 8'h9E, 8'hA6, 8'hAE, 8'hB6, 8'hBE:
				// res b,(hl)
				case( mcycle )
				3'd3:
					write = 1'b1;
				default:
					begin
						//	hold
					end
				endcase
			endcase

		// --------------------------------------------------------------------
		//	ED prefixed instructions
		// --------------------------------------------------------------------
		default:
			case( irb )
			8'h4B, 8'h5B, 8'h6B, 8'h7B:
				begin
					// ld dd,(nn)
					case( mcycle )
					3'd2:
							ldz = 1'b1;
					3'd3:
							ldw = 1'b1;
					3'd5:
					default:
						begin
							//	hold
						end
					endcase
				end
			8'h43, 8'h53, 8'h63, 8'h73:
				begin
					// ld (nn),dd
					case( mcycle )
					3'd2:
							ldz = 1'b1;
					3'd3:
							ldw = 1'b1;
					3'd4:
							write = 1'b1;
					3'd5:
							write = 1'b1;
					default:
						begin
							//	hold
						end
					endcase
				end
			8'hA0, 8'hA8, 8'hB0, 8'hB8:
				begin
					// ldi, ldd, ldir, lddr
					case( mcycle )
					3'd3:
							write = 1'b1;
					default:
						begin
							//	hold
						end
					endcase
				end
			8'h6F:
				begin
					// rld
					case( mcycle )
					3'd4:
						begin
							write = 1'b1;
						end
					default:
						begin
							//	hold
						end
					endcase
				end
			8'h67:
				begin
					// rrd
					case( mcycle )
					3'd4:
						begin
							write = 1'b1;
						end
					default:
						begin
							//	hold
						end
					endcase
				end
			8'h45, 8'h4D, 8'h55, 8'h5D, 8'h65, 8'h6D, 8'h75, 8'h7D:
					// reti, retn
					case( mcycle )
					3'd2:
							ldz = 1'b1;
					3'd3:
						begin
							i_retn = 1'b1;
						end
					default:
						begin
							//	hold
						end
					endcase
			8'h41, 8'h49, 8'h51, 8'h59, 8'h61, 8'h69, 8'h71, 8'h79:
					// out (c),r
					// out (c),0
					case( mcycle )
					3'd2:
						begin
							write = 1'b1;
						end
					default:
						begin
							//	hold
						end
					endcase
			8'hA2, 8'hAA, 8'hB2, 8'hBA:
					// ini, ind, inir, indr
					case( mcycle )
					3'd3:
						begin
							write = 1'b1;
							i_btr = 1'b1;
						end
					default:
						begin
							//	hold
						end
					endcase
			8'hA3, 8'hAB, 8'hB3, 8'hBB:
				begin
					// outi, outd, otir, otdr
					case( mcycle )
					3'd3:
						begin
							write = 1'b1;
							i_btr = 1'b1;
						end
					default:
						begin
							//	hold
						end
					endcase
				end
			endcase
		endcase
	end
