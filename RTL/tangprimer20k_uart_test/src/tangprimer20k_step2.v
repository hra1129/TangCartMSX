// -----------------------------------------------------------------------------
//	tangprimer20k_step2.v
//	Copyright (C)2025 Takayuki Hara (HRA!)
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

module tangprimer20k_step2 (
	input			clk27m,				//	clk27m			H11
	input	[4:0]	button,				//	button[4:0]		C7,  D7,  T2,  T3,  T10
	output	[5:0]	led,				//	led[5:0]		L16, L14, N14, N16, A13, C13
	output			uart_tx				//	uart_tx			
);
	reg				ff_reset_n	= 1'b0;
	reg		[5:0]	ff_led		= 6'd0;
	reg		[20:0]	ff_timer	= 21'd0;
	reg		[7:0]	ff_send_state;
	reg		[7:0]	ff_send_data;
	reg				ff_send_req;
	wire			w_send_busy;

	wire			init_calib_complete;
	wire			cmd_ready;
	wire	[2:0]	cmd;
	wire			cmd_en;
	wire	[27:0]	addr;
	wire			wr_data_rdy;
	wire	[127:0]	wr_data;
	wire			wr_data_en;
	wire			wr_data_end;
	wire	[7:0]	wr_data_mask;
	wire	[127:0]	rd_data;
	wire			rd_data_valid;
	wire			rd_data_end;
	wire			sr_req;
	wire			ref_req;
	wire			sr_ack;
	wire			ref_ack;
	wire			burst;

	always @( posedge clk27m ) begin
		ff_timer <= ff_timer + 21'd1;
	end

	always @( posedge clk27m ) begin
		if( ff_timer == 21'd0 ) begin
			ff_reset_n <= 1'b1;
		end
		else begin
			//	hold
		end
	end

	always @( posedge clk27m ) begin
		if( ff_timer == 21'd0 ) begin
			ff_led <= ff_led + 6'd1;
		end
		else if( button[0] == 1'b0 ) begin
			ff_led <= 6'd0;
		end
		else if( button[1] == 1'b0 ) begin
			ff_led <= 6'd1;
		end
		else if( button[2] == 1'b0 ) begin
			ff_led <= 6'd2;
		end
		else if( button[3] == 1'b0 ) begin
			ff_led <= 6'd4;
		end
		else if( button[4] == 1'b0 ) begin
			ff_led <= 6'd8;
		end
		else begin
			//	hold
		end
	end

	assign led	= ~ff_led;

	// --------------------------------------------------------------------
	//	Send test
	// --------------------------------------------------------------------
	always @( posedge clk27m ) begin
		if( !ff_reset_n ) begin
			ff_send_state	<= 8'd0;
			ff_send_data	<= 8'd0;
			ff_send_req		<= 1'b0;
		end
		else if( ff_send_req ) begin
			if( !w_send_busy ) begin
				ff_send_req	<= 1'b0;
			end
			else begin
				//	hold
			end
		end
		else begin
			case( ff_send_state )
			8'd0:
				begin
					ff_send_data	<= "H";
					ff_send_req		<= 1'b1;
					ff_send_state	<= ff_send_state + 8'd1;
				end
			8'd1:
				begin
					ff_send_data	<= "e";
					ff_send_req		<= 1'b1;
					ff_send_state	<= ff_send_state + 8'd1;
				end
			8'd2:
				begin
					ff_send_data	<= "l";
					ff_send_req		<= 1'b1;
					ff_send_state	<= ff_send_state + 8'd1;
				end
			8'd3:
				begin
					ff_send_data	<= "l";
					ff_send_req		<= 1'b1;
					ff_send_state	<= ff_send_state + 8'd1;
				end
			8'd4:
				begin
					ff_send_data	<= "o";
					ff_send_req		<= 1'b1;
					ff_send_state	<= ff_send_state + 8'd1;
				end
			8'd5:
				begin
					ff_send_data	<= ",";
					ff_send_req		<= 1'b1;
					ff_send_state	<= ff_send_state + 8'd1;
				end
			8'd6:
				begin
					ff_send_data	<= " ";
					ff_send_req		<= 1'b1;
					ff_send_state	<= ff_send_state + 8'd1;
				end
			8'd7:
				begin
					ff_send_data	<= "W";
					ff_send_req		<= 1'b1;
					ff_send_state	<= ff_send_state + 8'd1;
				end
			8'd8:
				begin
					ff_send_data	<= "o";
					ff_send_req		<= 1'b1;
					ff_send_state	<= ff_send_state + 8'd1;
				end
			8'd9:
				begin
					ff_send_data	<= "r";
					ff_send_req		<= 1'b1;
					ff_send_state	<= ff_send_state + 8'd1;
				end
			8'd10:
				begin
					ff_send_data	<= "l";
					ff_send_req		<= 1'b1;
					ff_send_state	<= ff_send_state + 8'd1;
				end
			8'd11:
				begin
					ff_send_data	<= "d";
					ff_send_req		<= 1'b1;
					ff_send_state	<= ff_send_state + 8'd1;
				end
			8'd12:
				begin
					ff_send_data	<= "!";
					ff_send_req		<= 1'b1;
					ff_send_state	<= ff_send_state + 8'd1;
				end
			8'd13:
				begin
					ff_send_data	<= " ";
					ff_send_req		<= 1'b1;
					ff_send_state	<= ff_send_state + 8'd1;
				end
			default:
				begin
					if( ff_timer == 21'd0 ) begin
						ff_send_state <= 8'd0;
					end
				end
			endcase
		end
	end

	// --------------------------------------------------------------------
	//	UART
	// --------------------------------------------------------------------
	ip_uart #(
		.clk_freq		( 27000000			),
		.uart_freq		( 115200			)
	) u_uart (
		.n_reset		( ff_reset_n		),
		.clk			( clk27m			),
		.send_data		( ff_send_data		),
		.send_req		( ff_send_req		),
		.send_busy		( w_send_busy		),
		.uart_tx		( uart_tx			)
	);

endmodule
