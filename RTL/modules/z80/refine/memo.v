	function func_(
		input	[1:0]	iset,
		input	[2:0]	mcycle,
		input	[7:0]	irb
	);
		set_busa_to = 4'h0;
		alu_op = 1'b0 & ir[5:3];
		alu_cpi = 1'b0;
		save_alu = 1'b0;
		preservec = 1'b0;
		arith16 = 1'b0;
		set_addr_to = anone;
		jump = 1'b0;
		jumpe = 1'b0;
		jumpxy = 1'b0;
		call = 1'b0;
		rstp = 1'b0;
		ldz = 1'b0;
		ldw = 1'b0;
		ldsphl = 1'b0;
		special_ld = 3'd0;
		exchangerp = 1'b0;
		i_retn = 1'b0;
		i_btr = 1'b0;
		imode = 2'b11;
		noread = 1'b0;
		write = 1'b0;
		xybit_undoc = 1'b0;

		case( iset )
		// --------------------------------------------------------------------
		//  unprefixed instructions
		// --------------------------------------------------------------------
		2'b00 :
			case( irb )
			8'h40, 8'h41, 8'h42, 8'h43, 8'h44, 8'h45, 8'h47, 
			8'h48, 8'h49, 8'h4A, 8'h4B, 8'h4C, 8'h4D, 8'h4F, 
			8'h50, 8'h51, 8'h52, 8'h53, 8'h54, 8'h55, 8'h57, 
			8'h58, 8'h59, 8'h5A, 8'h5B, 8'h5C, 8'h5D, 8'h5F, 
			8'h60, 8'h61, 8'h62, 8'h63, 8'h64, 8'h65, 8'h67, 
			8'h68, 8'h69, 8'h6A, 8'h6B, 8'h6C, 8'h6D, 8'h6F, 
			8'h78, 8'h79, 8'h7A, 8'h7B, 8'h7C, 8'h7D, 8'h7F:
				begin
					// ld r,r'
					exchangerp = 1'b1;
					set_busa_to[2:0] = ddd;
				end
			8'h06, 8'h0E, 8'h16, 8'h1E, 8'h26, 8'h2E, 8'h3E :
				begin
					// ld r,n
					case( mcycle )
					3'd2:
							set_busa_to[2:0] = ddd;
					others : null;
					endcase
				end
			8'h46, 8'h4E, 8'h56, 8'h5E, 8'h66, 8'h6E, 8'h7E :
				begin
					// ld r,(hl)
					case( mcycle )
					3'd1:
							set_addr_to = axy;
					3'd2:
							set_busa_to[2:0] = ddd;
					others : null;
					endcase
				end
			8'h70, 8'h71, 8'h72, 8'h73, 8'h74, 8'h75, 8'h77 :
				begin
					// ld (hl),r
					case( mcycle )
					3'd1:
							set_addr_to = axy;
					3'd2:
							write = 1'b1;
					others : null;
					endcase
				end
			8'h36 :
				begin
					// ld (hl),n
					case( mcycle )
					3'd2:
						begin
							set_addr_to = axy;
						end
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
			8'h0A :
				begin
					// ld a,(bc)
					case( mcycle )
					3'd1:
							set_addr_to = abc;
					3'd2:
					default:
						begin
							//	hold
						end
					endcase
				end
			8'h1A :
				begin
					// ld a,(de)
					case( mcycle )
					3'd1:
							set_addr_to = ade;
					3'd2:
					default:
						begin
							//	hold
						end
					endcase
				end
			8'h3A :
				begin
					// ld a,(nn)
					case( mcycle )
					3'd2:
							ldz = 1'b1;
					3'd3:
							set_addr_to = azi;
					3'd4:
					default:
						begin
							//	hold
						end
					endcase
				end
			8'h02 :
				begin
					// ld (bc),a
					case( mcycle )
					3'd1:
							set_addr_to = abc;
					3'd2:
							write = 1'b1;
					default:
						begin
							//	hold
						end
					endcase
				end
			8'h12 :
				begin
					// ld (de),a
					case( mcycle )
					3'd1:
							set_addr_to = ade;
					3'd2:
							write = 1'b1;
					default:
						begin
							//	hold
						end
					endcase
				end
			8'h32 :
				begin
					// ld (nn),a
					= 3'd4;
					case( mcycle )
					3'd2:
							ldz = 1'b1;
					3'd3:
							set_addr_to = azi;
					3'd4:
							write = 1'b1;
					default:
						begin
							//	hold
						end
					endcase
				end
			8'h01, 8'h11, 8'h21, 8'h31 :
				begin
					// ld dd,nn
					case( mcycle )
					3'd2:
						begin
							if( dpair == 2'b11 ) begin
									set_busa_to[3:0] = 4'h8;
							end
							else begin
									set_busa_to[2:1] = dpair;
									set_busa_to[0] = 1'b1;
							end
					3'd3:
						begin
							if( dpair == 2'b11 ) begin
									set_busa_to[3:0] = 4'h9;
							end
							else begin
									set_busa_to[2:1] = dpair;
									set_busa_to[0] = 1'b0;
							end
					default:
						begin
							//	hold
						end
					endcase
			8'h2A :
					// ld hl,(nn)
					case( mcycle )
					3'd2:
							ldz = 1'b1;
					3'd3:
							set_addr_to = azi;
							ldw = 1'b1;
					3'd4:
							set_busa_to[2:0] = 3'd5; // l
							set_addr_to = azi;
					3'd5:
							set_busa_to[2:0] = 3'd4; // h
					default:
						begin
							//	hold
						end
					endcase
			8'h22 :
					// ld (nn),hl
					case( mcycle )
					3'd2:
							ldz = 1'b1;
					3'd3:
							set_addr_to = azi;
							ldw = 1'b1;
					3'd4:
							set_addr_to = azi;
							write = 1'b1;
					3'd5:
							write = 1'b1;
					default:
						begin
							//	hold
						end
					endcase
			8'hF9 :
					// ld sp,hl
					ldsphl = 1'b1;
			8'hC5, 8'hD5, 8'hE5, 8'hF5 :
					// push qq
					case( mcycle )
					3'd1:
							set_addr_to = asp;
					3'd2:
							set_addr_to = asp;
							write = 1'b1;
					3'd3:
							write = 1'b1;
					default:
						begin
							//	hold
						end
					endcase
			8'hC1, 8'hD1, 8'hE1, 8'hF1 :
					// pop qq
					case( mcycle )
					3'd1:
							set_addr_to = asp;
					3'd2:
							set_addr_to = asp;
							if( dpair = 2'b11 ) begin
									set_busa_to[3:0] = 4'hB;
							else
									set_busa_to[2:1] = dpair;
									set_busa_to[0] = 1'b1;
							end
					3'd3:
							if( dpair = 2'b11 ) begin
									set_busa_to[3:0] = 4'h7;
							else
									set_busa_to[2:1] = dpair;
									set_busa_to[0] = 1'b0;
							end
					default:
						begin
							//	hold
						end
					endcase
			8'hE3 :
					// ex (sp),hl
					case( mcycle )
					3'd1:
							set_addr_to = asp;
					3'd2:
							set_busa_to = 4'h5;
							set_addr_to = asp;
					3'd3:
							set_addr_to = asp;
							write = 1'b1;
					3'd4:
							set_busa_to = 4'h4;
							set_addr_to = asp;
					3'd5:
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
					// add a,r
					// adc a,r
					// sub a,r
					// sbc a,r
					// and a,r
					// or a,r
					// xor a,r
					// cp a,r
					set_busa_to[2:0] = 3'd7;
					save_alu = 1'b1;
			8'h86, 8'h8E, 8'h96, 8'h9E, 8'hA6, 8'hAE, 8'hB6, 8'hBE :
					// add a,(hl)
					// adc a,(hl)
					// sub a,(hl)
					// sbc a,(hl)
					// and a,(hl)
					// or a,(hl)
					// xor a,(hl)
					// cp a,(hl)
					case( mcycle )
					3'd1:
							set_addr_to = axy;
					3'd2:
							save_alu = 1'b1;
							set_busa_to[2:0] = 3'd7;
					default:
						begin
							//	hold
						end
					endcase
			8'hC6, 8'hCE, 8'hD6, 8'hDE, 8'hE6, 8'hEE, 8'hF6, 8'hFE :
					// add a,n
					// adc a,n
					// sub a,n
					// sbc a,n
					// and a,n
					// or a,n
					// xor a,n
					// cp a,n
					if( mcycle = 3'd2 ) begin
							save_alu = 1'b1;
							set_busa_to[2:0] = 3'd7;
					end
			8'h04, 8'h0C, 8'h14, 8'h1C, 8'h24, 8'h2C, 8'h3C :
					// inc r
					set_busa_to[2:0] = ddd;
					save_alu = 1'b1;
					preservec = 1'b1;
					alu_op = 4'h0;
			8'h34 :
					// inc (hl)
					case( mcycle )
					3'd1:
							set_addr_to = axy;
					3'd2:
							set_addr_to = axy;
							save_alu = 1'b1;
							preservec = 1'b1;
							alu_op = 4'h0;
							set_busa_to[2:0] = ddd;
					3'd3:
							write = 1'b1;
					default:
						begin
							//	hold
						end
					endcase
			8'h05, 8'h0D, 8'h15, 8'h1D, 8'h25, 8'h2D, 8'h3D :
					// dec r
					set_busa_to[2:0] = ddd;
					save_alu = 1'b1;
					preservec = 1'b1;
					alu_op = 4'h2;
			8'h35 :
					// dec (hl)
					case( mcycle )
					3'd1:
							set_addr_to = axy;
					3'd2:
							set_addr_to = axy;
							alu_op = 4'h2;
							save_alu = 1'b1;
							preservec = 1'b1;
							set_busa_to[2:0] = ddd;
					3'd3:
							write = 1'b1;
					default:
						begin
							//	hold
						end
					endcase
			8'h27 :
					// daa
					set_busa_to[2:0] = 3'd7;
					alu_op = 4'hC;
					save_alu = 1'b1;
			8'h00 :
					if( nmicycle = 1'b1 ) begin
							// nmi
							case( mcycle )
							3'd1:
									set_addr_to = asp;
							3'd2:
									write = 1'b1;
									set_addr_to = asp;
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
									set_addr_to = asp;
							3'd2:
									write = 1'b1;
									set_addr_to = asp;
							3'd3:
									write = 1'b1;
							3'd4:
									ldz = 1'b1;
							3'd5:
									jump = 1'b1;
							default:
								begin
									//	hold
								end
							endcase
					else
							// nop
					end
			8'h09, 8'h19, 8'h29, 8'h39 :
					// add hl,ss
					case( mcycle )
					3'd2:
							noread = 1'b1;
							alu_op = 4'h0;
							save_alu = 1'b1;
							set_busa_to[2:0] = 3'd5;
							arith16 = 1'b1;
					3'd3:
							noread = 1'b1;
							save_alu = 1'b1;
							alu_op = 4'h1;
							set_busa_to[2:0] = 3'd4;
							arith16 = 1'b1;
					default:
						begin
							//	hold
						end
					endcase
			8'h03, 8'h13, 8'h23, 8'h33 :
					// inc ss
			8'h0B, 8'h1B, 8'h2B, 8'h3B :
					// dec ss
			8'h07
					// rlca
					, 8'h17
					// rla
					, 8'h0F
					// rrca
					, 8'h1F:
					// rra
					set_busa_to[2:0] = 3'd7;
					alu_op = 4'h8;
					save_alu = 1'b1;
			8'hC3 :
					// jp nn
					case( mcycle )
					3'd2:
							ldz = 1'b1;
					3'd3:
							jump = 1'b1;
					default:
						begin
							//	hold
						end
					endcase
			8'hC2, 8'hCA, 8'hD2, 8'hDA, 8'hE2, 8'hEA, 8'hF2, 8'hFA :
					// jp cc,nn
					case( mcycle )
					3'd2:
							ldz = 1'b1;
					3'd3:
							if( is_cc_true(f, to_bitvector(ir[5:3])) ) begin
									jump = 1'b1;
							end
					default:
						begin
							//	hold
						end
					endcase
			8'h18 :
					// jr e
					case( mcycle )
					3'd3:
							noread = 1'b1;
							jumpe = 1'b1;
					default:
						begin
							//	hold
						end
					endcase
			8'h38 :
					// jr c,e
					case( mcycle )
					3'd3:
							noread = 1'b1;
							jumpe = 1'b1;
					default:
						begin
							//	hold
						end
					endcase
			8'h30 :
					// jr nc,e
					case( mcycle )
					3'd3:
							noread = 1'b1;
							jumpe = 1'b1;
					default:
						begin
							//	hold
						end
					endcase
			8'h28 :
					// jr z,e
					case( mcycle )
					3'd3:
							noread = 1'b1;
							jumpe = 1'b1;
					default:
						begin
							//	hold
						end
					endcase
			8'h20 :
					// jr nz,e
					case( mcycle )
					3'd3:
							noread = 1'b1;
							jumpe = 1'b1;
					default:
						begin
							//	hold
						end
					endcase
			8'hE9 :
					// jp (hl)
					jumpxy = 1'b1;
			8'h10 :
					// djnz,e
					case( mcycle )
					3'd1:
							set_busa_to[2:0] = 3'd0;
							save_alu = 1'b1;
							alu_op = 4'h2;
					3'd3:
							noread = 1'b1;
							jumpe = 1'b1;
					default:
						begin
							//	hold
						end
					endcase
			8'hCD :
					// call nn
					case( mcycle )
					3'd2:
							ldz = 1'b1;
					3'd3:
							set_addr_to = asp;
							ldw = 1'b1;
					3'd4:
							write = 1'b1;
							set_addr_to = asp;
					3'd5:
							write = 1'b1;
							call = 1'b1;
					default:
						begin
							//	hold
						end
					endcase
			8'hC4, 8'hCC, 8'hD4, 8'hDC, 8'hE4, 8'hEC, 8'hF4, 8'hFC :
					// call cc,nn
					case( mcycle )
					3'd2:
							ldz = 1'b1;
					3'd3:
							ldw = 1'b1;
							if( is_cc_true(f, to_bitvector(ir[5:3])) ) begin
									set_addr_to = asp;
							end
					3'd4:
							write = 1'b1;
							set_addr_to = asp;
					3'd5:
							write = 1'b1;
							call = 1'b1;
					default:
						begin
							//	hold
						end
					endcase
			8'hC9 :
					// ret
					case( mcycle )
					3'd1:
							set_addr_to = asp;
					3'd2:
							set_addr_to = asp;
							ldz = 1'b1;
					3'd3:
							jump = 1'b1;
					default:
						begin
							//	hold
						end
					endcase
			8'hC0, 8'hC8, 8'hD0, 8'hD8, 8'hE0, 8'hE8, 8'hF0, 8'hF8 :
					// ret cc
					case( mcycle )
					3'd1:
							if( is_cc_true(f, to_bitvector(ir[5:3])) ) begin
									set_addr_to = asp;
							end
					3'd2:
							set_addr_to = asp;
							ldz = 1'b1;
					3'd3:
							jump = 1'b1;
					default:
						begin
							//	hold
						end
					endcase
			8'hC7, 8'hCF, 8'hD7, 8'hDF, 8'hE7, 8'hEF, 8'hF7, 8'hFF :
					// rst p
					case( mcycle )
					3'd1:
							set_addr_to = asp;
					3'd2:
							write = 1'b1;
							set_addr_to = asp;
					3'd3:
							write = 1'b1;
							rstp = 1'b1;
					default:
						begin
							//	hold
						end
					endcase
			8'hDB :
					// in a,(n)
					case( mcycle )
					3'd2:
							set_addr_to = aioa;
					3'd3:
					default:
						begin
							//	hold
						end
					endcase
			8'hD3 :
					// out (n),a
					case( mcycle )
					3'd2:
							set_addr_to = aioa;
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
		2'b01 :
			set_busa_to[2:0] = ir[2:0];

			case( irb )
			8'h00, 8'h01, 8'h02, 8'h03, 8'h04, 8'h05, 8'h07, 
			8'h10, 8'h11, 8'h12, 8'h13, 8'h14, 8'h15, 8'h17, 
			8'h08, 8'h09, 8'h0A, 8'h0B, 8'h0C, 8'h0D, 8'h0F, 
			8'h18, 8'h19, 8'h1A, 8'h1B, 8'h1C, 8'h1D, 8'h1F, 
			8'h20, 8'h21, 8'h22, 8'h23, 8'h24, 8'h25, 8'h27, 
			8'h28, 8'h29, 8'h2A, 8'h2B, 8'h2C, 8'h2D, 8'h2F, 
			8'h30, 8'h31, 8'h32, 8'h33, 8'h34, 8'h35, 8'h37, 
			8'h38, 8'h39, 8'h3A, 8'h3B, 8'h3C, 8'h3D, 8'h3F:
				// rlc r
				// rl r
				// rrc r
				// rr r
				// sla r
				// sra r
				// srl r
				// sll r (undocumented) / swap r
				if( xy_state=2'b00 ) begin
					if( mcycle = 3'd1 ) begin
					 alu_op = 4'h8;
					 save_alu = 1'b1;
					end
				else
				// r/s (ix+d),reg, undocumented
					xybit_undoc = 1'b1;
					case( mcycle )
					3'd1, 3'd7:
						set_addr_to = axy;
					3'd2:
						alu_op = 4'h8;
						save_alu = 1'b1;
						set_addr_to = axy;
					3'd3:
						write = 1'b1;
					default:
						begin
							//	hold
						end
					endcase
				end


			8'h06, 8'h16, 8'h0E, 8'h1E, 8'h2E, 8'h3E, 8'h26, 8'h36 :
				// rlc (hl)
				// rl (hl)
				// rrc (hl)
				// rr (hl)
				// sra (hl)
				// srl (hl)
				// sla (hl)
				// sll (hl) (undocumented) / swap (hl)
				case( mcycle )
				3'd1, 3'd7:
					set_addr_to = axy;
				3'd2:
					alu_op = 4'h8;
					save_alu = 1'b1;
					set_addr_to = axy;
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
					if( mcycle = 3'd1 ) begin
					 alu_op = 4'h9;
					end
				else
				// bit b,(ix+d), undocumented
					xybit_undoc = 1'b1;
					case( mcycle )
					3'd1, 3'd7:
						set_addr_to = axy;
					3'd2:
						alu_op = 4'h9;
					default:
						begin
							//	hold
						end
					endcase
				end
			8'h46, 8'h4E, 8'h56, 8'h5E, 8'h66, 8'h6E, 8'h76, 8'h7E :
				// bit b,(hl)
				case( mcycle )
				3'd1, 3'd7:
					set_addr_to = axy;
				3'd2:
					alu_op = 4'h9;
				default:
					begin
						//	hold
					end
				endcase
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
					if( mcycle = 3'd1 ) begin
					 alu_op = 4'hA;
					 save_alu = 1'b1;
					end
				else
				// set b,(ix+d),reg, undocumented
					xybit_undoc = 1'b1;
					case( mcycle )
					3'd1, 3'd7:
						set_addr_to = axy;
					3'd2:
						alu_op = 4'hA;
						save_alu = 1'b1;
						set_addr_to = axy;
					3'd3:
						write = 1'b1;
					default:
						begin
							//	hold
						end
					endcase
				end
			8'hC6, 8'hCE, 8'hD6, 8'hDE, 8'hE6, 8'hEE, 8'hF6, 8'hFE :
				// set b,(hl)
				case( mcycle )
				3'd1, 3'd7:
					set_addr_to = axy;
				3'd2:
					alu_op = 4'hA;
					save_alu = 1'b1;
					set_addr_to = axy;
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
					if( mcycle = 3'd1 ) begin
					 alu_op = 4'hB;
					 save_alu = 1'b1;
					end
				else
				// res b,(ix+d),reg, undocumented
					xybit_undoc = 1'b1;
					case( mcycle )
					3'd1, 3'd7:
						set_addr_to = axy;
					3'd2:
						alu_op = 4'hB;
						save_alu = 1'b1;
						set_addr_to = axy;
					3'd3:
						write = 1'b1;
					default:
						begin
							//	hold
						end
					endcase
				end

			8'h86, 8'h8E, 8'h96, 8'h9E, 8'hA6, 8'hAE, 8'hB6, 8'hBE :
				// res b,(hl)
				case( mcycle )
				3'd1, 3'd7:
					set_addr_to = axy;
				3'd2:
					alu_op = 4'hB;
					save_alu = 1'b1;
					set_addr_to = axy;
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
			8'h00, 8'h01, 8'h02, 8'h03, 8'h04, 8'h05, 8'h06, 8'h07
			, 8'h08, 8'h09, 8'h0A, 8'h0B, 8'h0C, 8'h0D, 8'h0E, 8'h0F
			, 8'h10, 8'h11, 8'h12, 8'h13, 8'h14, 8'h15, 8'h16, 8'h17
			, 8'h18, 8'h19, 8'h1A, 8'h1B, 8'h1C, 8'h1D, 8'h1E, 8'h1F
			, 8'h20, 8'h21, 8'h22, 8'h23, 8'h24, 8'h25, 8'h26, 8'h27
			, 8'h28, 8'h29, 8'h2A, 8'h2B, 8'h2C, 8'h2D, 8'h2E, 8'h2F
			, 8'h30, 8'h31, 8'h32, 8'h33, 8'h34, 8'h35, 8'h36, 8'h37
			, 8'h38, 8'h39, 8'h3A, 8'h3B, 8'h3C, 8'h3D, 8'h3E, 8'h3F
			, 8'h80, 8'h81, 8'h82, 8'h83, 8'h84, 8'h85, 8'h86, 8'h87
			, 8'h90, 8'h91, 8'h92, 8'h93, 8'h94, 8'h95, 8'h96, 8'h97
			, 8'h98, 8'h99, 8'h9A, 8'h9B, 8'h9C, 8'h9D, 8'h9E, 8'h9F
			, 											8'hA4, 8'hA5, 8'hA6, 8'hA7
			, 											8'hAC, 8'hAD, 8'hAE, 8'hAF
			, 											8'hB4, 8'hB5, 8'hB6, 8'hB7
			, 											8'hBC, 8'hBD, 8'hBE, 8'hBF
			, 8'hC0, 		  8'hC2, 			8'hC4, 8'hC5, 8'hC6, 8'hC7
			, 8'hC8, 		  8'hCA, 8'hCB, 8'hCC, 8'hCD, 8'hCE, 8'hCF
			, 8'hD0, 		  8'hD2, 8'hD3, 8'hD4, 8'hD5, 8'hD6, 8'hD7
			, 8'hD8, 		  8'hDA, 8'hDB, 8'hDC, 8'hDD, 8'hDE, 8'hDF
			, 8'hE0, 8'hE1, 8'hE2, 8'hE3, 8'hE4, 8'hE5, 8'hE6, 8'hE7
			, 8'hE8, 8'hE9, 8'hEA, 8'hEB, 8'hEC, 8'hED, 8'hEE, 8'hEF
			, 8'hF0, 8'hF1, 8'hF2, 			8'hF4, 8'hF5, 8'hF6, 8'hF7
			, 8'hF8, 8'hF9, 8'hFA, 8'hFB, 8'hFC, 8'hFD, 8'hFE, 8'hFF:
				begin
					//	no operation
				end
			8'h7E, 8'h7F :
				begin
					// nop, undocumented
				end
			// 8 bit load group
			8'h57 :
				begin
					// ld a,i
					special_ld = 3'd4;
				end
			8'h5F :
				begin
					// ld a,r
					special_ld = 3'd5;
				end
			8'h47 :
				begin
					// ld i,a
					special_ld = 3'd6;
				end
			8'h4F :
				begin
					// ld r,a
					special_ld = 3'd7;
				end
			// 16 bit load group
			8'h4B, 8'h5B, 8'h6B, 8'h7B :
				begin
					// ld dd,(nn)
					case( mcycle )
					3'd2:
							ldz = 1'b1;
					3'd3:
							set_addr_to = azi;
							ldw = 1'b1;
					3'd4:
							if( ir[5:4] = 2'b11 ) begin
									set_busa_to = 4'h8;
							else
									set_busa_to[2:1] = ir[5:4];
									set_busa_to[0] = 1'b1;
							end
							set_addr_to = azi;
					3'd5:
							if( ir[5:4] = 2'b11 ) begin
									set_busa_to = 4'h9;
							else
									set_busa_to[2:1] = ir[5:4];
									set_busa_to[0] = 1'b0;
							end
					default:
						begin
							//	hold
						end
					endcase
				end
			8'h43, 8'h53, 8'h63, 8'h73 :
				begin
					// ld (nn),dd
					case( mcycle )
					3'd2:
							ldz = 1'b1;
					3'd3:
							set_addr_to = azi;
							ldw = 1'b1;
					3'd4:
							set_addr_to = azi;
							write = 1'b1;
					3'd5:
							write = 1'b1;
					default:
						begin
							//	hold
						end
					endcase
				end
			8'hA0 ,  8'hA8 ,  8'hB0 ,  8'hB8 :
				begin
					// ldi, ldd, ldir, lddr
					case( mcycle )
					3'd1:
							set_addr_to = axy;
					3'd2:
							set_busa_to[2:0] = 3'd7;
							alu_op = 4'h0;
							set_addr_to = ade;
					3'd3:
							write = 1'b1;
					3'd4:
							noread = 1'b1;
					default:
						begin
							//	hold
						end
					endcase
				end
			8'hA1 ,  8'hA9 ,  8'hB1 ,  8'hB9 :
				begin
					// cpi, cpd, cpir, cpdr
					case( mcycle )
					3'd1:
							set_addr_to = axy;
					3'd2:
							set_busa_to[2:0] = 3'd7;
							alu_op = 4'h7;
							alu_cpi = 1'b1;
							save_alu = 1'b1;
							preservec = 1'b1;
					3'd3:
							noread = 1'b1;
					3'd4:
							noread = 1'b1;
					default:
						begin
							//	hold
						end
					endcase
				end
			8'h44, 8'h4C, 8'h54, 8'h5C, 8'h64, 8'h6C, 8'h74, 8'h7C :
				begin
					// neg
					alu_op = 4'h2;
					set_busa_to = 4'hA;
					save_alu = 1'b1;
				end
			8'h46, 8'h4E, 8'h66, 8'h6E :
				// im 0
				imode = 2'b00;
			8'h56, 8'h76 :
				// im 1
				imode = 2'b01;
			8'h5E, 8'h77 :
				// im 2
				imode = 2'b10;
			// 16 bit arithmetic
			8'h4A, 8'h5A, 8'h6A, 8'h7A:
				begin
					// adc hl,ss
					case( mcycle )
					3'd2:
						begin
							noread = 1'b1;
							alu_op = 4'h1;
							save_alu = 1'b1;
							set_busa_to[2:0] = 3'd5;
						end
					3'd3:
						begin
							noread = 1'b1;
							save_alu = 1'b1;
							alu_op = 4'h1;
							set_busa_to[2:0] = 3'd4;
						end
					default:
					endcase
				end
			8'h42, 8'h52, 8'h62, 8'h72 :
				begin
					// sbc hl,ss
					case( mcycle )
					3'd2:
						begin
							noread = 1'b1;
							alu_op = 4'h3;
							save_alu = 1'b1;
							set_busa_to[2:0] = 3'd5;
						end
					3'd3:
						begin
							noread = 1'b1;
							alu_op = 4'h3;
							save_alu = 1'b1;
							set_busa_to[2:0] = 3'd4;
						end
					default:
						begin
							//	hold
						end
					endcase
				end
			8'h6F :
				begin
					// rld
					case( mcycle )
					3'd2:
						begin
							noread = 1'b1;
							set_addr_to = axy;
						end
					3'd3:
						begin
							set_busa_to[2:0] = 3'd7;
							alu_op = 4'hD;
							set_addr_to = axy;
							save_alu = 1'b1;
						end
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
			8'h67 :
				begin
					// rrd
					case( mcycle )
					3'd2:
						set_addr_to = axy;
					3'd3:
						begin
							set_busa_to[2:0] = 3'd7;
							alu_op = 4'hE;
							set_addr_to = axy;
							save_alu = 1'b1;
						end
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
			8'h45, 8'h4D, 8'h55, 8'h5D, 8'h65, 8'h6D, 8'h75, 8'h7D :
					// reti, retn
					case( mcycle )
					3'd1:
						set_addr_to = asp;
					3'd2:
						begin
							set_addr_to = asp;
							ldz = 1'b1;
						end
					3'd3:
						begin
							jump = 1'b1;
							i_retn = 1'b1;
						end
					default:
						begin
							//	hold
						end
					endcase
			8'h40, 8'h48, 8'h50, 8'h58, 8'h60, 8'h68, 8'h70, 8'h78:
					// in r,(c)
					case( mcycle )
					3'd1:
						set_addr_to = abc;
					3'd2:
						begin
							if( ir[5:3] != 3'd6 ) begin
									set_busa_to[2:0] = ir[5:3];
							end
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
					3'd1:
						begin
							set_addr_to = abc;
						end
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
					3'd1:
						begin
							set_addr_to = abc;
							set_busa_to = 4'h0;
							save_alu = 1'b1;
							alu_op = 4'h2;
						end
					3'd2:
						begin
							set_addr_to = axy;
						end
					3'd3:
						begin
							write = 1'b1;
							i_btr = 1'b1;
						end
					3'd4:
						begin
							noread = 1'b1;
						end
					default:
						begin
							//	hold
						end
					endcase
			8'hA3, 8'hAB, 8'hB3, 8'hBB :
				begin
					// outi, outd, otir, otdr
					case( mcycle )
					3'd1:
						begin
							set_addr_to = axy;
							set_busa_to = 4'h0;
							save_alu = 1'b1;
							alu_op = 4'h2;
						end
					3'd2:
						begin
							set_addr_to = abc;
						end
					3'd3:
						begin
							write = 1'b1;
							i_btr = 1'b1;
						end
					3'd4:
						begin
							noread = 1'b1;
						end
					default:
						begin
							//	hold
						end
					endcase
				end
			8'hC1, 8'hC9, 8'hD1, 8'hD9:
				begin
					//r800 mulub
				end
			8'hC3, 8'hF3 :
				begin
					//r800 muluw
				end
			endcase

		endcase

		if( mcycle == 3'd6 ) begin
			if( mode == 1 ) begin
				set_addr_to = axy;
			end
			if( irb == 8'h36 || irb == 8'hCB ) begin
				set_addr_to = anone;
			end
		end
		if( mcycle == 3'd7 ) begin
			if( iset != 2'b01 ) begin
				set_addr_to = axy;
			end
			if( irb == 8'h36 || iset == 2'b01 ) begin
				// ld (hl),n
			else
				noread = 1'b1;
			end
		end
	end
