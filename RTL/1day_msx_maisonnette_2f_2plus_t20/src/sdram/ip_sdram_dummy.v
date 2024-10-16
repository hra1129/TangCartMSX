//
// ip_sdram_dummy.vhd
//	 16384 bytes of block memory
//	 Revision 1.00
//
// Copyright (c) 2024 Takayuki Hara
// All rights reserved.
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

module ip_sdram (
	input				n_reset			,
	input				clk				,
	input				clk_sdram		,
	input				rd_n			,
	input				wr_n			,
	output				busy			,
	input	[16:0]		address			,
	input	[7:0]		wdata			,
	output	[15:0]		rdata			,
	output				rdata_en		,
	output				O_sdram_clk		,
	output				O_sdram_cke		,
	output				O_sdram_cs_n	,
	output				O_sdram_ras_n	,
	output				O_sdram_cas_n	,
	output				O_sdram_wen_n	,
	inout	[31:0]		IO_sdram_dq		,
	output	[10:0]		O_sdram_addr	,
	output	[1:0]		O_sdram_ba		,
	output	[3:0]		O_sdram_dqm		
);
	reg		[7:0]	ff_ram [0:16383];
	reg		[13:0]	ff_address;
	reg				ff_rd_n;
	reg				ff_wr_n;
	reg		[7:0]	ff_rdata;
	reg		[7:0]	ff_wdata;

	always @( posedge clk ) begin
		if( !wr_n || !rd_n ) begin
			ff_address	<= address[13:0];
			ff_wr_n		<= wr_n;
			ff_rd_n		<= rd_n;
			ff_wdata	<= wdata;
		end
		else begin
			ff_wr_n		<= 1'b1;
			ff_rd_n		<= 1'b1;
		end
	end

	always @( posedge clk ) begin
		if( ff_wr_n == 1'b0 ) begin
			ff_ram[ ff_address ] <= ff_wdata;
		end
		else if( ff_rd_n == 1'b0 ) begin
			ff_rdata <= ff_ram[ ff_address ];
		end
		else begin
			//	hold
		end
	end

	assign O_sdram_clk		= 1'b0;
	assign O_sdram_cke		= 1'b0;
	assign O_sdram_cs_n		= 1'b0;
	assign O_sdram_ras_n	= 1'b0;
	assign O_sdram_cas_n	= 1'b0;
	assign O_sdram_wen_n	= 1'b0;
	assign IO_sdram_dq		= 32'hZ;
	assign O_sdram_addr		= 11'd0;
	assign O_sdram_ba		= 2'b00;
	assign O_sdram_dqm		= 4'b0000;

	assign busy				= 1'b0;
	assign rdata			= { ff_rdata, ff_rdata };
	assign rdata_en			= 1'b0;
endmodule
