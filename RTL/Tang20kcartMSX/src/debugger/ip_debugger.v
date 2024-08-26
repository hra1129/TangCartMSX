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

module ip_debugger (
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
	input	[15:0]	address
);
	reg		[1:0]	ff_keys;
	wire	[1:0]	w_keys;
	reg		[3:0]	ff_state;
	reg		[7:0]	ff_send_data;
	reg				ff_send_req;

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

	// --------------------------------------------------------------------
	//	State machine
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !n_reset ) begin
			ff_state <= 'd0;
			ff_send_req <= 1'b0;
		end
		else if( send_busy ) begin
			//	hold
		end
		else begin
			if( ff_state != 'd0 ) begin
				//	Change to next state
				if( ff_state >= 'd10 ) begin
					ff_state = 'd0;
					ff_send_req <= 1'b0;
				end
				else begin
					ff_state = ff_state + 'd1;
				end
			end
			else if( w_keys[0] ) begin
				ff_send_req <= 1'b1;
				ff_state = 'd1;
			end
			else begin
				//	hold
			end

			case( ff_state )
			'd0:
				begin
					//	hold
				end
			'd1:
				begin
					ff_send_data <= 'h41;		//	'A'
				end
			'd2:
				begin
					ff_send_data <= 'h44;		//	'D'
				end
			'd3:
				begin
					ff_send_data <= 'h52;		//	'R'
				end
			'd4:
				begin
					ff_send_data <= 'h3A;		//	':'
				end
			'd5:
				begin
					ff_send_data <= func_conv( address[15:12] );
				end
			'd6:
				begin
					ff_send_data <= func_conv( address[11: 8] );
				end
			'd7:
				begin
					ff_send_data <= func_conv( address[ 7: 4] );
				end
			'd8:
				begin
					ff_send_data <= func_conv( address[ 3: 0] );
				end
			'd9:
				begin
					ff_send_data <= 'h0D;
				end
			'd10:
				begin
					ff_send_data <= 'h0A;
				end
			default:
				begin
					//	hold
				end
			endcase
		end
	end

	assign send_data	= ff_send_data;
	assign send_req		= ff_send_req;
endmodule
