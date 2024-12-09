//
// vdp_ram_palette.v
//	 256 bytes of block memory
//	 Revision 1.00
//
// Copyright (c) 2024 Takayuki Hara
//
// Redistribution and use of this source code or any derivative works, are
// permitted provided that the following conditions are met:
//
// 1. Redistributions of source code must retain the above copyright notice,
//		this list of conditions and the following disclaimer.
// 2. Redistributions in binary form must reproduce the above copyright
//		notice, this list of conditions and the following disclaimer in the
//		documentation and/or other materials provided with the distribution.
// 3. Redistributions may not be sold, nor may they be used in a commercial
//		product or activity without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
// PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
// CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
// EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
// OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
// WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
// OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
// ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

module vdp_ram_palette (
	input			clk,
	input			reset,
	input			enable,
	input	[7:0]	address,
	input			we,
	input	[4:0]	d_r,
	input	[4:0]	d_g,
	input	[4:0]	d_b,
	output	[4:0]	q_r,
	output	[4:0]	q_g,
	output	[4:0]	q_b
);
	reg		[4:0]	ff_palette_initial_state;
	reg		[4:0]	ff_delay_state;
	reg		[4:0]	ff_palette_r;
	reg		[4:0]	ff_palette_g;
	reg		[4:0]	ff_palette_b;
	reg		[7:0]	ff_palette_address;
	reg				ff_palette_we;
	reg		[7:0]	ff_address;
	reg				ff_we;
	reg				ff_enable1;
	reg				ff_enable2;
	reg				ff_enable3;
	reg		[4:0]	ff_d_r;
	reg		[4:0]	ff_d_g;
	reg		[4:0]	ff_d_b;
	reg		[4:0]	ff_block_ram_r [0:255];
	reg		[4:0]	ff_block_ram_g [0:255];
	reg		[4:0]	ff_block_ram_b [0:255];
	reg		[4:0]	ff_q_r;
	reg		[4:0]	ff_q_g;
	reg		[4:0]	ff_q_b;
	reg		[4:0]	ff_q_r_out;
	reg		[4:0]	ff_q_g_out;
	reg		[4:0]	ff_q_b_out;

	//---------------------------------------------------------------------------
	// palette initializer
	//---------------------------------------------------------------------------
	always @( posedge clk ) begin
		if( reset ) begin
			ff_palette_initial_state <= 5'd0;
		end
		else if( !ff_palette_initial_state[4] ) begin
			ff_palette_initial_state <= ff_palette_initial_state + 5'd1;
		end
		else begin
			//	hold
		end
	end

	always @( posedge clk ) begin
		if( reset ) begin
			ff_palette_r <= 3'd0;
			ff_palette_g <= 3'd0;
			ff_palette_b <= 3'd0;
		end
		else if( !ff_palette_initial_state[4] ) begin
			case( ff_palette_initial_state[3:0] )
			4'd0:		begin ff_palette_r <= 3'd0; ff_palette_g <= 3'd0; ff_palette_b <= 3'd0; end
			4'd1:		begin ff_palette_r <= 3'd0; ff_palette_g <= 3'd0; ff_palette_b <= 3'd0; end
			4'd2:		begin ff_palette_r <= 3'd1; ff_palette_g <= 3'd6; ff_palette_b <= 3'd1; end
			4'd3:		begin ff_palette_r <= 3'd3; ff_palette_g <= 3'd7; ff_palette_b <= 3'd3; end
			4'd4:		begin ff_palette_r <= 3'd1; ff_palette_g <= 3'd1; ff_palette_b <= 3'd7; end
			4'd5:		begin ff_palette_r <= 3'd2; ff_palette_g <= 3'd3; ff_palette_b <= 3'd7; end
			4'd6:		begin ff_palette_r <= 3'd5; ff_palette_g <= 3'd1; ff_palette_b <= 3'd1; end
			4'd7:		begin ff_palette_r <= 3'd2; ff_palette_g <= 3'd6; ff_palette_b <= 3'd7; end
			4'd8:		begin ff_palette_r <= 3'd7; ff_palette_g <= 3'd1; ff_palette_b <= 3'd1; end
			4'd9:		begin ff_palette_r <= 3'd7; ff_palette_g <= 3'd3; ff_palette_b <= 3'd3; end
			4'd10:		begin ff_palette_r <= 3'd6; ff_palette_g <= 3'd6; ff_palette_b <= 3'd1; end
			4'd11:		begin ff_palette_r <= 3'd6; ff_palette_g <= 3'd6; ff_palette_b <= 3'd4; end
			4'd12:		begin ff_palette_r <= 3'd1; ff_palette_g <= 3'd4; ff_palette_b <= 3'd1; end
			4'd13:		begin ff_palette_r <= 3'd6; ff_palette_g <= 3'd2; ff_palette_b <= 3'd5; end
			4'd14:		begin ff_palette_r <= 3'd5; ff_palette_g <= 3'd5; ff_palette_b <= 3'd5; end
			default:	begin ff_palette_r <= 3'd7; ff_palette_g <= 3'd7; ff_palette_b <= 3'd7; end
			endcase
		end
	end

	always @( posedge clk ) begin
		if( reset ) begin
			ff_delay_state <= 5'b0;
		end
		else begin
			ff_delay_state <= ff_palette_initial_state;
		end
	end

	// --------------------------------------------------------------------
	//		enable		1 0 0 0
	//		ff_enable1	0 1 0 0
	//		ff_enable2	0 0 1 0
	//		ff_enable3	0 0 0 1
	//		address		A A A A
	//		ff_address	X A A A A
	//		ff_q		X X q Q Q Q Q   © SRAM_Q
	//		ff_q_out	X X X X Q Q Q Q © ff_enable3 ‚Å ff_q Žæ‚èž‚Ý
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		ff_enable1		<= enable | ~ff_delay_state[4];
		ff_enable2		<= ff_enable1;
		ff_enable3		<= ff_enable2;
	end

	// --------------------------------------------------------------------
	//	enable
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !ff_delay_state[4] ) begin
			ff_address	<= { 4'd0, ff_delay_state[3:0] };
			ff_we		<= 1'b1;
			ff_d_r		<= { ff_palette_r, ff_palette_r[2:1] };
			ff_d_g		<= { ff_palette_g, ff_palette_g[2:1] };
			ff_d_b		<= { ff_palette_b, ff_palette_b[2:1] };
		end
		else if( enable ) begin
			ff_address	<= address;
			ff_we		<= we;
			ff_d_r		<= d_r;
			ff_d_g		<= d_g;
			ff_d_b		<= d_b;
		end
		else begin
			ff_we		<= 1'b0;
		end
	end

	// --------------------------------------------------------------------
	//	ff_enable1
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( ff_enable1 ) begin
			if( ff_we ) begin
				ff_block_ram_r[ ff_address ]	<= ff_d_r;
				ff_block_ram_g[ ff_address ]	<= ff_d_g;
				ff_block_ram_b[ ff_address ]	<= ff_d_b;
			end
			else begin
				ff_q_r							<= ff_block_ram_r[ ff_address ];
				ff_q_g							<= ff_block_ram_g[ ff_address ];
				ff_q_b							<= ff_block_ram_b[ ff_address ];
			end
		end
	end

	always @( posedge clk ) begin
		if( ff_enable3 ) begin
			ff_q_r_out <= ff_q_r;
			ff_q_g_out <= ff_q_g;
			ff_q_b_out <= ff_q_b;
		end
	end

	assign q_r = ff_q_r_out;
	assign q_g = ff_q_g_out;
	assign q_b = ff_q_b_out;
endmodule
