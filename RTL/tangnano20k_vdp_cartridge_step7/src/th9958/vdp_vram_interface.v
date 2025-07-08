//
//	vdp_vram_interface.v
//	VRAM Interface for VDP
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

module vdp_vram_interface (
	input				reset_n,
	input				clk,					//	42.95454MHz

	input				initial_busy,
	input		[2:0]	h_count,

	input		[16:0]	t12_vram_address,
	input				t12_vram_valid,
	output		[7:0]	t12_vram_rdata,

	input		[16:0]	g123m_vram_address,
	input				g123m_vram_valid,
	output		[7:0]	g123m_vram_rdata,

	input		[16:0]	g4567_vram_address,
	input				g4567_vram_valid,
	output		[31:0]	g4567_vram_rdata,

	input		[16:0]	sprite_vram_address,
	input				sprite_vram_valid,
	output		[31:0]	sprite_vram_rdata,

	input		[16:0]	command_vram_address,
	input				command_vram_valid,
	output				command_vram_ready,
	input				command_vram_write,
	input		[7:0]	command_vram_wdata,
	output		[31:0]	command_vram_rdata,
	output				command_vram_rdata_en,

	input		[16:0]	cpu_vram_address,
	input				cpu_vram_valid,
	output				cpu_vram_ready,
	input				cpu_vram_write,
	input		[7:0]	cpu_vram_wdata,
	output		[7:0]	cpu_vram_rdata,
	output				cpu_vram_rdata_en,

	output		[16:0]	vram_address,
	output				vram_valid,
	output				vram_write,
	output		[7:0]	vram_wdata,
	input		[31:0]	vram_rdata,
	input				vram_rdata_en
);
	localparam			c_idle		= 3'd0;
	localparam			c_t12		= 3'd1;
	localparam			c_g123m		= 3'd2;
	localparam			c_g4567		= 3'd3;
	localparam			c_sprite	= 3'd4;
	localparam			c_cpu		= 3'd5;
	localparam			c_command	= 3'd6;

	localparam			c_wait_count = 3'd4;
	reg			[16:0]	ff_vram_address;
	reg					ff_vram_valid;
	reg					ff_vram_write;
	reg			[7:0]	ff_vram_wdata;
	reg			[2:0]	ff_vram_rdata_sel;
	reg			[2:0]	ff_wait;
	wire		[7:0]	w_rdata8;
	reg			[7:0]	ff_t12_vram_rdata;
	reg			[7:0]	ff_g123m_vram_rdata;
	reg			[31:0]	ff_g4567_vram_rdata;
	reg			[31:0]	ff_sprite_vram_rdata;
	reg			[7:0]	ff_cpu_vram_rdata;
	reg					ff_cpu_vram_rdata_en;
	reg			[31:0]	ff_command_vram_rdata;
	reg					ff_command_vram_rdata_en;

	// --------------------------------------------------------------------
	//	Priority selector
	// --------------------------------------------------------------------
	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_vram_address		<= 17'd0;
			ff_vram_valid		<= 1'b0;
			ff_vram_write		<= 1'b0;
			ff_vram_wdata		<= 8'd0;
			ff_vram_rdata_sel	<= 3'd0;
			ff_wait				<= 3'd0;
		end
		else if( ff_wait != 3'd0 ) begin
			ff_wait				<= ff_wait - 3'd1;
			ff_vram_valid		<= 1'b0;
		end
		else begin
			if( initial_busy ) begin
				ff_vram_valid		<= 1'b0;
				ff_vram_rdata_sel	<= 3'd0;
			end
			else if( t12_vram_valid ) begin
				ff_vram_address		<= t12_vram_address;
				ff_vram_valid		<= 1'b1;
				ff_vram_write		<= 1'b0;
				ff_vram_wdata		<= 8'd0;
				ff_vram_rdata_sel	<= c_t12;
				ff_wait				<= c_wait_count;
			end
			else if( g123m_vram_valid ) begin
				ff_vram_address		<= g123m_vram_address;
				ff_vram_valid		<= 1'b1;
				ff_vram_write		<= 1'b0;
				ff_vram_wdata		<= 8'd0;
				ff_vram_rdata_sel	<= c_g123m;
				ff_wait				<= c_wait_count;
			end
			else if( g4567_vram_valid ) begin
				ff_vram_address		<= g4567_vram_address;
				ff_vram_valid		<= 1'b1;
				ff_vram_write		<= 1'b0;
				ff_vram_wdata		<= 8'd0;
				ff_vram_rdata_sel	<= c_g4567;
				ff_wait				<= c_wait_count;
			end
			else if( sprite_vram_valid ) begin
				ff_vram_address		<= sprite_vram_address;
				ff_vram_valid		<= 1'b1;
				ff_vram_write		<= 1'b0;
				ff_vram_wdata		<= 8'd0;
				ff_vram_rdata_sel	<= c_sprite;
				ff_wait				<= c_wait_count;
			end
			else if( cpu_vram_valid && (h_count == 3'd0) ) begin
				ff_vram_address		<= cpu_vram_address;
				ff_vram_valid		<= 1'b1;
				ff_vram_write		<= cpu_vram_write;
				ff_vram_wdata		<= cpu_vram_wdata;
				ff_vram_rdata_sel	<= c_cpu;
				ff_wait				<= c_wait_count;
			end
			else if( command_vram_valid ) begin
				ff_vram_address		<= command_vram_address;
				ff_vram_valid		<= 1'b1;
				ff_vram_write		<= command_vram_write;
				ff_vram_wdata		<= command_vram_wdata;
				ff_vram_rdata_sel	<= c_command;
				ff_wait				<= c_wait_count;
			end
			else if( vram_rdata_en ) begin
				ff_vram_rdata_sel	<= c_idle;
			end
		end
	end

	assign cpu_vram_ready		= (h_count[2:0] == 3'd0) ? ~(t12_vram_valid | g123m_vram_valid | g4567_vram_valid | sprite_vram_valid) : 1'b0;
	assign command_vram_ready	= (h_count[2:0] == 3'd0) ? ~(t12_vram_valid | g123m_vram_valid | g4567_vram_valid | sprite_vram_valid | cpu_vram_valid) : 1'b0;

	function [7:0] func_rdata_sel(
		input	[1:0]	address,
		input	[31:0]	rdata
	);
		case( address )
		2'd0:		func_rdata_sel = rdata[ 7: 0];
		2'd1:		func_rdata_sel = rdata[15: 8];
		2'd2:		func_rdata_sel = rdata[23:16];
		2'd3:		func_rdata_sel = rdata[31:24];
		default:	func_rdata_sel = 8'dx;
		endcase
	endfunction

	assign w_rdata8 = func_rdata_sel( ff_vram_address[1:0], vram_rdata );

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_t12_vram_rdata			<= 8'd0;
			ff_g123m_vram_rdata			<= 8'd0;
			ff_g4567_vram_rdata			<= 32'd0;
			ff_sprite_vram_rdata		<= 32'd0;
			ff_cpu_vram_rdata			<= 8'd0;
			ff_cpu_vram_rdata_en		<= 1'b0;
			ff_command_vram_rdata		<= 32'd0;
			ff_command_vram_rdata_en	<= 1'b0;
		end
		else if( vram_rdata_en ) begin
			case( ff_vram_rdata_sel )
			c_t12:		begin ff_t12_vram_rdata		<= w_rdata8; end
			c_g123m:	begin ff_g123m_vram_rdata	<= w_rdata8; end
			c_g4567:	begin ff_g4567_vram_rdata	<= vram_rdata; end
			c_sprite:	begin ff_sprite_vram_rdata	<= vram_rdata; end
			c_cpu:		begin ff_cpu_vram_rdata		<= w_rdata8;	ff_cpu_vram_rdata_en <= 1'b1;		end
			c_command:	begin ff_command_vram_rdata	<= vram_rdata;	ff_command_vram_rdata_en <= 1'b1;	end
			endcase
		end
	end

	assign t12_vram_rdata			= ff_t12_vram_rdata;
	assign g123m_vram_rdata			= ff_g123m_vram_rdata;
	assign g4567_vram_rdata			= ff_g4567_vram_rdata;
	assign sprite_vram_rdata		= ff_sprite_vram_rdata;
	assign cpu_vram_rdata			= ff_cpu_vram_rdata;
	assign cpu_vram_rdata_en		= ff_cpu_vram_rdata_en;
	assign command_vram_rdata		= ff_command_vram_rdata;
	assign command_vram_rdata_en	= ff_command_vram_rdata_en;

	assign vram_address				= ff_vram_address;
	assign vram_valid				= ff_vram_valid;
	assign vram_write				= ff_vram_write;
	assign vram_wdata				= ff_vram_wdata;
endmodule
