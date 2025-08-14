//
//	vdp_command.v
//
//	Copyright (C) 2025 Takayuki Hara
//
//	本ソフトウェアおよび本ソフトウェアに基づいて作成された派生物は、以下の条件を
//	満たす場合に限り、再頒布および使用が許可されます。
//
//	1.ソースコード形式で再頒布する場合、上記の著作権表示、本条件一覧、および下記
//	  免責条項をそのままの形で保持すること。
//	2.バイナリ形式で再頒布する場合、頒布物に付属のドキュメント等の資料に、上記の
//	  著作権表示、本条件一覧、および下記免責条項を含めること。
//	3.書面による事前の許可なしに、本ソフトウェアを販売、および商業的な製品や活動
//	  に使用しないこと。
//
//	本ソフトウェアは、著作権者によって「現状のまま」提供されています。著作権者は、
//	特定目的への適合性の保証、商品性の保証、またそれに限定されない、いかなる明示
//	的もしくは暗黙な保証責任も負いません。著作権者は、事由のいかんを問わず、損害
//	発生の原因いかんを問わず、かつ責任の根拠が契約であるか厳格責任であるか（過失
//	その他の）不法行為であるかを問わず、仮にそのような損害が発生する可能性を知ら
//	されていたとしても、本ソフトウェアの使用によって発生した（代替品または代用サ
//	ービスの調達、使用の喪失、データの喪失、利益の喪失、業務の中断も含め、またそ
//	れに限定されない）直接損害、間接損害、偶発的な損害、特別損害、懲罰的損害、ま
//	たは結果損害について、一切責任を負わないものとします。
//
//	Note that above Japanese version license is the formal document.
//	The following translation is only for reference.
//
//	Redistribution and use of this software or any derivative works,
//	are permitted provided that the following conditions are met:
//
//	1. Redistributions of source code must retain the above copyright
//	   notice, this list of conditions and the following disclaimer.
//	2. Redistributions in binary form must reproduce the above
//	   copyright notice, this list of conditions and the following
//	   disclaimer in the documentation and/or other materials
//	   provided with the distribution.
//	3. Redistributions may not be sold, nor may they be used in a
//	   commercial product or activity without specific prior written
//	   permission.
//
//	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
//	"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
//	LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
//	FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
//	COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
//	INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
//	BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//	LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
//	CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
//	LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
//	ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//	POSSIBILITY OF SUCH DAMAGE.
//
//-----------------------------------------------------------------------------

module vdp_command (
	input				reset_n,
	input				clk,
	//	VRAM interface
	output		[16:0]	command_vram_address,
	output				command_vram_valid,
	input				command_vram_ready,
	output				command_vram_write,
	output		[31:0]	command_vram_wdata,
	output		[3:0]	command_vram_wdata_mask,
	input		[31:0]	command_vram_rdata,
	input				command_vram_rdata_en,
	//	CPU interface
	input				register_write,
	input		[5:0]	register_num,
	input		[7:0]	register_data,
	//	Screen mode
	input		[3:0]	screen_mode,
	input				reg_command_enable
);
	localparam c_hmmc	= 4'b1111;
	localparam c_ymmm	= 4'b1110;
	localparam c_hmmm	= 4'b1101;
	localparam c_hmmv	= 4'b1100;
	localparam c_lmmc	= 4'b1011;
	localparam c_lmcm	= 4'b1010;
	localparam c_lmmm	= 4'b1001;
	localparam c_lmmv	= 4'b1000;
	localparam c_line	= 4'b0111;
	localparam c_srch	= 4'b0110;
	localparam c_pset	= 4'b0101;
	localparam c_point	= 4'b0100;
	localparam c_stop	= 4'b0000;

	reg			[8:0]	ff_sx;
	reg			[9:0]	ff_sy;
	reg			[8:0]	ff_dx;
	reg			[9:0]	ff_dy;
	reg			[8:0]	ff_nx;
	reg			[9:0]	ff_ny;
	reg			[7:0]	ff_color;
	reg					ff_maj;
	reg					ff_eq;
	reg					ff_dix;
	reg					ff_diy;
	reg					ff_mxs;
	reg					ff_mxd;
	reg					ff_mxc;
	reg			[3:0]	ff_logical_opration;
	reg			[3:0]	ff_command;
	reg					ff_start;

	// --------------------------------------------------------------------
	//	Registers
	// --------------------------------------------------------------------
	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_sx	<= 9'd0;
		end
		else if( register_write ) begin
			if( register_num == 6'd32 ) begin
				ff_sx[7:0]	<= register_data;
			end
			else if( register_num == 6'd33 ) begin
				ff_sx[8]	<= register_data[0];
			end
		end
	end

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_sy	<= 10'd0;
		end
		else if( register_write ) begin
			if( register_num == 6'd34 ) begin
				ff_sy[7:0]	<= register_data;
			end
			else if( register_num == 6'd35 ) begin
				ff_sy[9:8]	<= register_data[1:0];
			end
		end
	end

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_dx	<= 9'd0;
		end
		else if( register_write ) begin
			if( register_num == 6'd36 ) begin
				ff_dx[7:0]	<= register_data;
			end
			else if( register_num == 6'd37 ) begin
				ff_dx[8]	<= register_data[0];
			end
		end
	end

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_dy	<= 10'd0;
		end
		else if( register_write ) begin
			if( register_num == 6'd38 ) begin
				ff_dy[7:0]	<= register_data;
			end
			else if( register_num == 6'd39 ) begin
				ff_dy[9:8]	<= register_data[1:0];
			end
		end
	end

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_nx	<= 9'd0;
		end
		else if( register_write ) begin
			if( register_num == 6'd40 ) begin
				ff_nx[7:0]	<= register_data;
			end
			else if( register_num == 6'd41 ) begin
				ff_nx[8]	<= register_data[0];
			end
		end
	end

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_ny	<= 10'd0;
		end
		else if( register_write ) begin
			if( register_num == 6'd42 ) begin
				ff_ny[7:0]	<= register_data;
			end
			else if( register_num == 6'd43 ) begin
				ff_ny[9:8]	<= register_data[1:0];
			end
		end
	end

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_color	<= 8'd0;
		end
		else if( register_write ) begin
			if( register_num == 6'd44 ) begin
				ff_color	<= register_data;
			end
		end
	end

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_maj	<= 1'd0;
			ff_eq	<= 1'd0;
			ff_dix	<= 1'd0;
			ff_diy	<= 1'd0;
			ff_mxs	<= 1'd0;
			ff_mxd	<= 1'd0;
			ff_mxc	<= 1'd0;
		end
		else if( register_write ) begin
			if( register_num == 6'd45 ) begin
				ff_maj	<= register_data[0];
				ff_eq	<= register_data[1];
				ff_dix	<= register_data[2];
				ff_diy	<= register_data[3];
				ff_mxs	<= register_data[4];
				ff_mxd	<= register_data[5];
				ff_mxc	<= register_data[6];
			end
		end
	end

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_logical_opration	<= 4'd0;
			ff_command			<= 4'd0;
			ff_start			<= 1'b0;
		end
		else if( register_write ) begin
			if( register_num == 6'd46 ) begin
				ff_logical_opration	<= register_data[3:0];
				ff_command			<= register_data[7:4];
				ff_start			<= 1'b1;
			end
			else begin
				ff_start			<= 1'b0;
			end
		end
		else begin
			ff_start			<= 1'b0;
		end
	end

	// --------------------------------------------------------------------
	//	VRAM Access
	// --------------------------------------------------------------------
	assign command_vram_address		= 17'd0;
	assign command_vram_valid		= 1'b0;
	assign command_vram_write		= 1'b0;
	assign command_vram_wdata		= 32'd0;
	assign command_vram_wdata_mask	= 4'd0;
endmodule
