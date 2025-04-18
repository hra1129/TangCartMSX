//
// vdp_ram_256byte.v
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

module vdp_ram_256byte (
	input			clk,
	input			enable,
	input	[7:0]	address,
	input			we,
	input	[7:0]	wdata,
	output	[7:0]	rdata
);
	reg		[7:0]	ff_address;
	reg				ff_we;
	reg		[7:0]	ff_d;
	reg		[7:0]	ff_block_ram [0:255];
	reg		[7:0]	ff_q;

	always @( posedge clk ) begin
		if( enable ) begin
			ff_address	<= address;
			ff_we		<= we;
			ff_d		<= wdata;
		end
		else begin
			ff_we		<= 1'b0;
		end
	end

	always @( posedge clk ) begin
		if( ff_we ) begin
			ff_block_ram[ ff_address ]	<= ff_d;
		end
	end

	always @( posedge clk ) begin
		if( !ff_we ) begin
			ff_q		<= ff_block_ram[ ff_address ];
		end
	end

	assign rdata = ff_q;
endmodule
