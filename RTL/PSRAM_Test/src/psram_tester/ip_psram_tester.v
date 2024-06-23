// -----------------------------------------------------------------------------
//	ip_psram_tester.v
//	Copyright (C)2024 Takayuki Hara (HRA!)
//	
//	 Permission is hereby granted, free of charge, to any person obtaining a 
//	copy of this software and associated documentation files (the "Software"), 
//	to deal in the Software without restriction, including without limitation 
//	the rights to use, copy, modify, merge, publish, distribute, sublicense, 
//	and/or sell copies of the Software, and to permit persons to whom the 
//	Software is furnished to do so, subject to the following conditions:
//	
//	The above copyright notice and this permission notice shall be included in 
//	all copies or substantial portions of the Software.
//	
//	The Software is provided "as is", without warranty of any kind, express or 
//	implied, including but not limited to the warranties of merchantability, 
//	fitness for a particular purpose and noninfringement. In no event shall the 
//	authors or copyright holders be liable for any claim, damages or other 
//	liability, whether in an action of contract, tort or otherwise, arising 
//	from, out of or in connection with the Software or the use or other dealings 
//	in the Software.
// -----------------------------------------------------------------------------
//	Description:
//		PSRAM Test Module
// -----------------------------------------------------------------------------

module ip_psram_tester (
	//	Internal I/F
	input			n_reset,
	input			clk,
	//	RAM0 I/F
	output			rd0,
	output			wr0,
	output	[21:0]	address0,
	output	[7:0]	wdata0,
	input	[7:0]	rdata0,
	input			rdata_en0,
	input			busy0,
	//	RAM1 I/F
	output			rd1,
	output			wr1,
	output	[21:0]	address1,
	output	[7:0]	wdata1,
	input	[7:0]	rdata1,
	input			rdata_en1,
	input			busy1,
	//	UART I/F
	output	[7:0]	send_data,
	output			send_req,
	input			send_busy,
	//	DEBUG
	output	[7:0]	pc
);
	localparam c_cr = 8'h0d;
	localparam c_lf = 8'h0a;
	localparam c_sp = 8'h20;
	localparam c_0 = 8'h30;
	localparam c_1 = 8'h31;
	localparam c_2 = 8'h32;
	localparam c_3 = 8'h33;
	localparam c_4 = 8'h34;
	localparam c_5 = 8'h35;
	localparam c_6 = 8'h36;
	localparam c_7 = 8'h37;
	localparam c_8 = 8'h38;
	localparam c_9 = 8'h39;
	localparam c_a = 8'h41;
	localparam c_b = 8'h42;
	localparam c_c = 8'h43;
	localparam c_d = 8'h44;
	localparam c_e = 8'h45;
	localparam c_f = 8'h46;
	localparam c_g = 8'h47;
	localparam c_h = 8'h48;
	localparam c_i = 8'h49;
	localparam c_j = 8'h4A;
	localparam c_k = 8'h4B;
	localparam c_l = 8'h4C;
	localparam c_m = 8'h4D;
	localparam c_n = 8'h4E;
	localparam c_o = 8'h4F;
	localparam c_p = 8'h50;
	localparam c_q = 8'h51;
	localparam c_r = 8'h52;
	localparam c_s = 8'h53;
	localparam c_t = 8'h54;
	localparam c_u = 8'h55;
	localparam c_v = 8'h56;
	localparam c_w = 8'h57;
	localparam c_x = 8'h58;
	localparam c_y = 8'h59;
	localparam c_z = 8'h5A;

	reg				ff_fail;
	reg		[7:0]	ff_pc;
	reg		[7:0]	ff_ret;
	reg		[7:0]	ff_send_data;
	reg				ff_send_req;
	reg		[31:0]	ff_wait;
	reg				ff_rd_state;
	reg				ff_rd0;
	reg				ff_wr0;
	reg		[21:0]	ff_address0;
	reg		[7:0]	ff_wdata0;
	reg		[7:0]	ff_rdata0;
	reg				ff_rd1;
	reg				ff_wr1;
	reg		[21:0]	ff_address1;
	reg		[7:0]	ff_wdata1;
	reg		[7:0]	ff_rdata1;

	assign pc			= ff_pc;

	assign send_data	= ff_send_data;
	assign send_req		= ff_send_req;

	assign rd0			= ff_rd0;
	assign wr0			= ff_wr0;
	assign address0		= ff_address0;
	assign wdata0		= ff_wdata0;
	assign rd1			= ff_rd1;
	assign wr1			= ff_wr1;
	assign address1		= ff_address1;
	assign wdata1		= ff_wdata1;

	function [7:0] func_bin2hex(
		input	[3:0]	d
	);
		if( d < 4'd10 ) begin
			func_bin2hex = { 4'd3, d };
		end
		else begin
			func_bin2hex = { 4'd0, d } + ( 8'h41 - 8'd10 );
		end
	endfunction

	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_pc <= 'd0;
			ff_send_req <= 1'b0;
			ff_wait <= 'd0;
			ff_rd_state <= 1'b0;
			ff_rd0 <= 1'b0;
			ff_wr0 <= 1'b0;
			ff_address0 <= 'd0;
			ff_wdata0 <= 'd0;
			ff_rd1 <= 1'b0;
			ff_wr1 <= 1'b0;
			ff_address1 <= 'd0;
			ff_wdata1 <= 'd0;
		end
		else if( ff_rd_state ) begin
			ff_rd0 <= 1'b0;
			ff_rd1 <= 1'b0;
			if( rdata_en0 ) begin
				ff_rd_state <= 1'b0;
				ff_rdata0 <= rdata0;
				ff_pc <= ff_pc + 'd1;
			end
			else if( rdata_en1 ) begin
				ff_rd_state <= 1'b0;
				ff_rdata1 <= rdata1;
				ff_pc <= ff_pc + 'd1;
			end
		end
		else if( ff_rd1 ) begin
			if( rdata_en1 ) begin
				ff_rd1 <= 1'b0;
				ff_rdata1 <= rdata1;
				ff_pc <= ff_pc + 'd1;
			end
		end
		else if( ff_wait != 'd0 ) begin
			ff_wr0 <= 1'b0;
			ff_wdata0 <= 'd0;
			ff_wr1 <= 1'b0;
			ff_wdata1 <= 'd0;
			ff_wait <= ff_wait - 'd1;
			if( ff_wait == 'd1 ) begin
				ff_pc <= ff_pc + 'd1;
			end
		end
		else if( ff_send_req ) begin
			if( !send_busy ) begin
				ff_send_req <= 1'b0;
				ff_pc <= ff_pc + 'd1;
			end
		end
		else begin
			case( ff_pc )
			// --------------------------------------------------------------------
			// put "PSRAM TEST\r\n"
			'd0:
				begin
					ff_send_data <= c_p;
					ff_send_req <= 1'b1;
				end
			'd1:
				begin
					ff_send_data <= c_s;
					ff_send_req <= 1'b1;
				end
			'd2:
				begin
					ff_send_data <= c_r;
					ff_send_req <= 1'b1;
				end
			'd3:
				begin
					ff_send_data <= c_a;
					ff_send_req <= 1'b1;
				end
			'd4:
				begin
					ff_send_data <= c_m;
					ff_send_req <= 1'b1;
				end
			'd5:
				begin
					ff_send_data <= c_sp;
					ff_send_req <= 1'b1;
				end
			'd6:
				begin
					ff_send_data <= c_t;
					ff_send_req <= 1'b1;
				end
			'd7:
				begin
					ff_send_data <= c_e;
					ff_send_req <= 1'b1;
				end
			'd8:
				begin
					ff_send_data <= c_s;
					ff_send_req <= 1'b1;
				end
			'd9:
				begin
					ff_send_data <= c_t;
					ff_send_req <= 1'b1;
				end
			'd10:
				begin
					ff_send_data <= c_cr;
					ff_send_req <= 1'b1;
				end
			'd11:
				begin
					ff_send_data <= c_lf;
					ff_send_req <= 1'b1;
				end
			// --------------------------------------------------------------------
			// wait busy out
			'd12:
				begin
					if( busy0 || busy1 ) begin
						//	hold
					end
					else begin
						ff_pc <= ff_pc + 'd1;
					end
				end
			'd13:
				begin
					ff_send_data <= c_o;
					ff_send_req <= 1'b1;
				end
			'd14:
				begin
					ff_send_data <= c_k;
					ff_send_req <= 1'b1;
				end
			'd15:
				begin
					ff_send_data <= c_cr;
					ff_send_req <= 1'b1;
				end
			'd16:
				begin
					ff_send_data <= c_lf;
					ff_send_req <= 1'b1;
				end
			// --------------------------------------------------------------------
			// wait 1sec
			'd17:
				begin
					ff_wait <= 'd75000000;
				end
			// --------------------------------------------------------------------
			// put "RAM0\r\n"
			'd18:
				begin
					ff_send_data <= c_r;
					ff_send_req <= 1'b1;
				end
			'd19:
				begin
					ff_send_data <= c_a;
					ff_send_req <= 1'b1;
				end
			'd20:
				begin
					ff_send_data <= c_m;
					ff_send_req <= 1'b1;
				end
			'd21:
				begin
					ff_send_data <= c_0;
					ff_send_req <= 1'b1;
				end
			'd22:
				begin
					ff_send_data <= c_cr;
					ff_send_req <= 1'b1;
				end
			'd23:
				begin
					ff_send_data <= c_lf;
					ff_send_req <= 1'b1;
				end
			// --------------------------------------------------------------------
			// ff_address0 = 0
			'd24:
				begin
					ff_address0 <= 'd0;
					ff_pc <= ff_pc + 'd1;
					ff_fail <= 1'b0;
				end
			// --------------------------------------------------------------------
			// loop
			'd25:
				begin
					ff_wdata0 <= ff_address0[7:0] ^ 8'b1001_1100;
					ff_wr0 <= 1'b1;
					ff_wait <= 'd28;
				end
			'd26:
				begin
					if( ff_address0[7:0] == 8'hFF ) begin
						ff_address0[7:0] <= 'd0;
						ff_pc <= 'd27;
					end
					else begin
						ff_address0[7:0] <= ff_address0[7:0] + 'd1;
						ff_pc <= 'd25;
					end
				end
			'd27:
				begin
					ff_wait <= 'd5;
				end
			'd28:
				begin
					ff_rd_state <= 1'b1;
					ff_rd0 <= 1'b1;
				end
			'd29:
				begin
					if( ff_rdata0 != (ff_address0[7:0] ^ 8'b1001_1100) ) begin
						ff_fail <= 1'b1;
						ff_pc <= 'd30;
					end
					else begin
						if( ff_address0[7:0] == 8'hFF ) begin
							ff_address0[7:0] <= 'd0;
							ff_pc <= 'd30;
						end
						else begin
							ff_address0[7:0] <= ff_address0[7:0] + 'd1;
							ff_pc <= 'd27;
						end
					end
				end
			'd30:
				begin
					ff_ret <= 'd31;
					if( ff_fail ) begin
						ff_pc <= 'd237;
					end
					else if( ff_address0[21:8] == 'b11_1111_1111_1111 ) begin
						ff_pc <= 'd251;
					end
					else begin
						ff_address0[21:8] <= ff_address0[21:8] + 'd1;
						ff_pc <= 'd25;
					end
				end

			// --------------------------------------------------------------------
			//	put "NG XXXXX\r\n"
			'd237:
				begin
					ff_send_data <= c_n;
					ff_send_req <= 1'b1;
				end
			'd238:
				begin
					ff_send_data <= c_g;
					ff_send_req <= 1'b1;
				end
			'd239:
				begin
					ff_send_data <= func_bin2hex( { 2'd0, ff_address0[21:20] } );
					ff_send_req <= 1'b1;
				end
			'd240:
				begin
					ff_send_data <= func_bin2hex( ff_address0[19:16] );
					ff_send_req <= 1'b1;
				end
			'd241:
				begin
					ff_send_data <= func_bin2hex( ff_address0[15:12] );
					ff_send_req <= 1'b1;
				end
			'd242:
				begin
					ff_send_data <= func_bin2hex( ff_address0[11:8] );
					ff_send_req <= 1'b1;
				end
			'd243:
				begin
					ff_send_data <= func_bin2hex( ff_address0[7:4] );
					ff_send_req <= 1'b1;
				end
			'd244:
				begin
					ff_send_data <= func_bin2hex( ff_address0[3:0] );
					ff_send_req <= 1'b1;
				end
			'd245:
				begin
					ff_send_data <= c_sp;
					ff_send_req <= 1'b1;
				end
			'd246:
				begin
					ff_send_data <= func_bin2hex( ff_rdata0[7:4] );
					ff_send_req <= 1'b1;
				end
			'd247:
				begin
					ff_send_data <= func_bin2hex( ff_rdata0[3:0] );
					ff_send_req <= 1'b1;
				end
			'd248:
				begin
					ff_send_data <= c_cr;
					ff_send_req <= 1'b1;
				end
			'd249:
				begin
					ff_send_data <= c_lf;
					ff_send_req <= 1'b1;
				end
			'd250:
				begin
					ff_fail <= 1'b0;
					ff_pc <= ff_ret;
				end

			// --------------------------------------------------------------------
			//	put "OK\r\n"
			'd251:
				begin
					ff_send_data <= c_o;
					ff_send_req <= 1'b1;
				end
			'd252:
				begin
					ff_send_data <= c_k;
					ff_send_req <= 1'b1;
				end
			'd253:
				begin
					ff_send_data <= c_cr;
					ff_send_req <= 1'b1;
				end
			'd254:
				begin
					ff_send_data <= c_lf;
					ff_send_req <= 1'b1;
				end
			'd255:
				begin
					ff_pc <= ff_ret;
				end

			default:
				begin
					ff_pc <= 'd0;
				end
			endcase
		end
	end
endmodule
