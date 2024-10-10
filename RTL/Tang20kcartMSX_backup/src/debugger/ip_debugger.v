// -----------------------------------------------------------------------------
//	ip_debugger.v
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
//		Debugger
// -----------------------------------------------------------------------------

module ip_debugger #( 
	parameter		TEST_ROWS = 15'b111_1111_1111_1111
) (
	//	Internal I/F
	input			n_reset,
	input			clk,
	//	UART output
	output	[7:0]	send_data,
	output			send_req,
	input			send_busy,
	//	Key input
	input	[1:0]	keys,
	//	Target signal for observation
	output			sdram_rd,
	output			sdram_wr,
	input			sdram_busy,
	output	[22:0]	sdram_address,
	output	[7:0]	sdram_wdata,
	input	[7:0]	sdram_rdata,
	input			sdram_rdata_en
);
	reg		[1:0]	ff_keys;
	wire	[1:0]	w_keys;
	reg		[5:0]	ff_state;
	reg		[7:0]	ff_send_data;
	reg				ff_send_req;
	reg		[22:0]	ff_sdram_address;
	reg				ff_sdram_rd;
	reg				ff_sdram_wr;
	reg		[7:0]	ff_sdram_wdata;
	reg		[7:0]	ff_sdram_rdata;

	// --------------------------------------------------------------------
	//	4bit binary --> 8bit ASCII code converter
	//	0000...1001 --> '0'...'9'
	//	1010...1111 --> 'A'...'F'
	//
	function [7:0] func_conv(
		input	[3:0]	d
	);
		case( d )
		4'h0:		func_conv = 8'h30;
		4'h1:		func_conv = 8'h31;
		4'h2:		func_conv = 8'h32;
		4'h3:		func_conv = 8'h33;
		4'h4:		func_conv = 8'h34;
		4'h5:		func_conv = 8'h35;
		4'h6:		func_conv = 8'h36;
		4'h7:		func_conv = 8'h37;
		4'h8:		func_conv = 8'h38;
		4'h9:		func_conv = 8'h39;
		4'hA:		func_conv = 8'h41;
		4'hB:		func_conv = 8'h42;
		4'hC:		func_conv = 8'h43;
		4'hD:		func_conv = 8'h44;
		4'hE:		func_conv = 8'h45;
		4'hF:		func_conv = 8'h46;
		default:	func_conv = 8'h3F;
		endcase
	endfunction

	// --------------------------------------------------------------------
	//	Key press detecter
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_keys <= 2'd0;
		end
		else begin
			ff_keys <= keys;
		end
	end

	assign w_keys[0] = ~ff_keys[0] & keys[0];
	assign w_keys[1] = ~ff_keys[1] & keys[1];

	always @( posedge clk ) begin
		if( sdram_rdata_en ) begin
			ff_sdram_rdata <= sdram_rdata;
		end
		else begin
			//	hold
		end
	end

	// --------------------------------------------------------------------
	//	State machine
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_state <= 'd0;
			ff_send_req <= 1'b0;
			ff_sdram_address <= 'd0;
			ff_sdram_rd <= 1'b0;
			ff_sdram_wr <= 1'b0;
			ff_sdram_wdata <= 'd0;
		end
		else if( send_busy ) begin
			//	hold
		end
		else begin
			case( ff_state )
			'd0:
				begin
					if( w_keys[0] ) begin
						ff_state <= 'd1;
					end
				end
			'd1:
				begin
					ff_send_data <= 'h53;		//	'S'
					ff_send_req <= 1'b1;
					ff_state <= 'd2;
				end
			'd2:
				begin
					ff_send_data <= 'h44;		//	'D'
					ff_send_req <= 1'b1;
					ff_state <= 'd3;
				end
			'd3:
				begin
					ff_send_data <= 'h52;		//	'R'
					ff_send_req <= 1'b1;
					ff_state <= 'd4;
				end
			'd4:
				begin
					ff_send_data <= 'h20;		//	' '
					ff_send_req <= 1'b1;
					ff_state <= 'd5;
				end
			'd5:
				begin
					ff_send_data <= 'h54;		//	'T'
					ff_send_req <= 1'b1;
					ff_state <= 'd6;
				end
			'd6:
				begin
					ff_send_data <= 'h45;		//	'E'
					ff_send_req <= 1'b1;
					ff_state <= 'd7;
				end
			'd7:
				begin
					ff_send_data <= 'h53;		//	'S'
					ff_send_req <= 1'b1;
					ff_state <= 'd8;
				end
			'd8:
				begin
					ff_send_data <= 'h54;		//	'T'
					ff_send_req <= 1'b1;
					ff_state <= 'd9;
				end
			'd9:
				begin
					ff_send_data <= 'h0D;		//	CR
					ff_send_req <= 1'b1;
					ff_state <= 'd10;
				end
			'd10:
				begin
					ff_send_data <= 'h0A;		//	LF
					ff_sdram_address <= 'd0;
					ff_send_req <= 1'b1;
					ff_state <= 'd11;
				end
			'd11:
				begin
					//	Start write datas
					ff_send_req <= 1'b0;
					ff_state <= 'd12;
					ff_sdram_address[7:0] <= 8'd0;
					ff_sdram_wdata <= 8'hFF;
				end
			'd12:
				begin
					ff_sdram_wr <= 1'b1;
					ff_state <= 'd13;
					ff_send_req <= 1'b0;
				end
			'd13:
				begin
					ff_send_req <= 1'b0;
					if( !sdram_busy ) begin
						if( ff_sdram_address[7:0] == 8'hFF ) begin
							ff_state <= 'd14;
						end
						else begin
							ff_sdram_wdata <= ff_sdram_wdata - 8'd1;
							ff_state <= 'd12;
						end
						ff_sdram_wr <= 1'b0;
						ff_sdram_address[7:0] <= ff_sdram_address[7:0] + 8'd1;
					end
					else begin
						//	hold
					end
				end
			'd14:
				begin
					//ff_send_data <= 'h2A;		//	'*'
					//ff_send_req <= 1'b1;
					ff_state <= 'd15;
				end
			'd15:
				begin
					ff_send_req <= 1'b0;
					ff_sdram_address[22:8] <= ff_sdram_address[22:8] + 15'd1;
					if( ff_sdram_address[22:8] == TEST_ROWS ) begin
						ff_state <= 'd16;
					end
					else begin
						ff_state <= 'd11;
					end
				end
			'd16:
				begin
					ff_send_data <= 'h57;		//	'W'
					ff_send_req <= 1'b1;
					ff_state <= 'd17;
				end
			'd17:
				begin
					ff_send_data <= 'h52;		//	'R'
					ff_send_req <= 1'b1;
					ff_state <= 'd18;
				end
			'd18:
				begin
					ff_send_data <= 'h54;		//	'T'
					ff_send_req <= 1'b1;
					ff_state <= 'd19;
				end
			'd19:
				begin
					ff_send_data <= 'h20;		//	' '
					ff_send_req <= 1'b1;
					ff_state <= 'd20;
				end
			'd20:
				begin
					ff_send_data <= 'h4F;		//	'O'
					ff_send_req <= 1'b1;
					ff_state <= 'd21;
				end
			'd21:
				begin
					ff_send_data <= 'h4B;		//	'K'
					ff_send_req <= 1'b1;
					ff_state <= 'd22;
				end
			'd22:
				begin
					ff_send_req <= 1'b0;		//	•¶Žš’âŽ~
					ff_sdram_address <= 'd0;
					ff_state <= 'd23;
				end
			'd23:
				begin
					//	Start read datas
					ff_send_req <= 1'b0;
					ff_state <= 'd24;
					ff_sdram_address[7:0] <= 8'd0;
					ff_sdram_wdata <= 8'hFF;
				end
			'd24:
				begin
					ff_sdram_rd <= 1'b1;
					ff_state <= 'd25;
					ff_send_req <= 1'b0;
				end
			'd25:
				begin
					ff_send_req <= 1'b0;
					if( !sdram_busy ) begin
						if( ff_sdram_rdata != ff_sdram_wdata ) begin
							ff_state <= 'd34;	// error
						end
						else if( ff_sdram_address[7:0] == 8'hFF ) begin
							ff_state <= 'd26;
						end
						else begin
							ff_sdram_wdata <= ff_sdram_wdata - 8'd1;
							ff_state <= 'd24;
						end
						ff_sdram_rd <= 1'b0;
						ff_sdram_address[7:0] <= ff_sdram_address[7:0] + 8'd1;
					end
					else begin
						//	hold
					end
				end
			'd26:
				begin
					//ff_send_data <= 'h2A;		//	'*'
					//ff_send_req <= 1'b1;
					ff_state <= 'd27;
				end
			'd27:
				begin
					ff_send_req <= 1'b0;
					ff_sdram_address[22:8] <= ff_sdram_address[22:8] + 15'd1;
					if( ff_sdram_address[22:8] == TEST_ROWS ) begin
						ff_state <= 'd28;
					end
					else begin
						ff_state <= 'd23;
					end
				end
			'd28:
				begin
					ff_send_data <= 'h52;		//	'R'
					ff_send_req <= 1'b1;
					ff_state <= 'd29;
				end
			'd29:
				begin
					ff_send_data <= 'h44;		//	'D'
					ff_send_req <= 1'b1;
					ff_state <= 'd30;
				end
			'd30:
				begin
					ff_send_data <= 'h20;		//	' '
					ff_send_req <= 1'b1;
					ff_state <= 'd31;
				end
			'd31:
				begin
					ff_send_data <= 'h4F;		//	'O'
					ff_send_req <= 1'b1;
					ff_state <= 'd32;
				end
			'd32:
				begin
					ff_send_data <= 'h4B;		//	'K'
					ff_send_req <= 1'b1;
					ff_state <= 'd33;
				end
			'd33:
				begin
					ff_send_req <= 1'b0;
					ff_state <= 'd0;
				end
			'd34:
				begin
					ff_send_data <= 'h52;		//	'R'
					ff_send_req <= 1'b1;
					ff_state <= 'd35;
				end
			'd35:
				begin
					ff_send_data <= 'h44;		//	'D'
					ff_send_req <= 1'b1;
					ff_state <= 'd36;
				end
			'd36:
				begin
					ff_send_data <= 'h20;		//	' '
					ff_send_req <= 1'b1;
					ff_state <= 'd37;
				end
			'd37:
				begin
					ff_send_data <= 'h4E;		//	'N'
					ff_send_req <= 1'b1;
					ff_state <= 'd38;
				end
			'd38:
				begin
					ff_send_data <= 'h47;		//	'G'
					ff_send_req <= 1'b1;
					ff_state <= 'd33;
				end
			default:
				begin
					//	hold
				end
			endcase
		end
	end

	assign send_data		= ff_send_data;
	assign send_req			= ff_send_req;

	assign sdram_rd			= ff_sdram_rd;
	assign sdram_wr			= ff_sdram_wr;
	assign sdram_address	= ff_sdram_address;
	assign sdram_wdata		= ff_sdram_wdata;
endmodule
