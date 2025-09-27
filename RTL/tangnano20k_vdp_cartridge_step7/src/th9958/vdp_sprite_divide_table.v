//
//	vdp_sprite_divide_table .v
//	Sprite plane's information collector for Timing Control Sprite
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

module vdp_sprite_divide_table (
	input				reset_n,
	input				clk,
	input		[7:0]	x,
	input		[7:0]	reg_mgx,
	input		[1:0]	bit_shift,
	output		[6:0]	sample_x,				//	3clk delay
	output				overflow				//	3clk delay
);
	wire		[2:0]	w_exp;
	reg					ff_mgx0;				//	1clk delay
	reg			[2:0]	ff_exp1;				//	1clk delay
	reg			[8:0]	ff_divide_coeff;		//	1clk delay
	reg			[1:0]	ff_bit_shift1;			//	1clk delay
	reg			[7:0]	ff_x;					//	1clk delay
	wire		[6:0]	w_divide_sel;
	wire		[9:0]	w_coeff;
	wire		[17:0]	w_mul;
	reg			[2:0]	ff_exp2;				//	2clk delay
	reg			[12:0]	ff_mul;					//	2clk delay
	reg			[1:0]	ff_bit_shift2;			//	2clk delay
	wire		[12:0]	w_shift;
	wire		[12:0]	w_sample_x;
	reg			[6:0]	ff_sample_x;			//	3clk delay
	reg					ff_overflow;			//	3clk delay

	function [2:0] func_exp(
		input	[7:0]	reg_mgx
	);
		casex( reg_mgx )
		8'b1XXXXXXX:	func_exp = 3'd7;
		8'b01XXXXXX:	func_exp = 3'd6;
		8'b001XXXXX:	func_exp = 3'd5;
		8'b0001XXXX:	func_exp = 3'd4;
		8'b00001XXX:	func_exp = 3'd3;
		8'b000001XX:	func_exp = 3'd2;
		8'b0000001X:	func_exp = 3'd1;
		default:		func_exp = 3'd0;
		endcase
	endfunction

	assign w_exp		= func_exp( reg_mgx );
	assign w_divide_sel	= (w_exp == 3'd7) ?   reg_mgx[6:0]:
						  (w_exp == 3'd6) ? { reg_mgx[5:0], 1'b0 }:
						  (w_exp == 3'd5) ? { reg_mgx[4:0], 2'b00 }:
						  (w_exp == 3'd4) ? { reg_mgx[3:0], 3'b000 }:
						  (w_exp == 3'd3) ? { reg_mgx[2:0], 4'b0000 }:
						  (w_exp == 3'd2) ? { reg_mgx[1:0], 5'b00000 }:
						  (w_exp == 3'd1) ? { reg_mgx[  0], 6'b000000 }: 7'd0;

	always @( posedge clk ) begin
		ff_mgx0			<= (reg_mgx == 8'd0);
		ff_exp1			<= w_exp;
		ff_bit_shift1	<= bit_shift;
		ff_x			<= x;
		case( w_divide_sel )
		7'd0:		ff_divide_coeff = 9'd256;
		7'd1:		ff_divide_coeff = 9'd252;
		7'd2:		ff_divide_coeff = 9'd248;
		7'd3:		ff_divide_coeff = 9'd244;
		7'd4:		ff_divide_coeff = 9'd240;
		7'd5:		ff_divide_coeff = 9'd236;
		7'd6:		ff_divide_coeff = 9'd233;
		7'd7:		ff_divide_coeff = 9'd229;
		7'd8:		ff_divide_coeff = 9'd225;
		7'd9:		ff_divide_coeff = 9'd222;
		7'd10:		ff_divide_coeff = 9'd218;
		7'd11:		ff_divide_coeff = 9'd215;
		7'd12:		ff_divide_coeff = 9'd212;
		7'd13:		ff_divide_coeff = 9'd208;
		7'd14:		ff_divide_coeff = 9'd205;
		7'd15:		ff_divide_coeff = 9'd202;
		7'd16:		ff_divide_coeff = 9'd199;
		7'd17:		ff_divide_coeff = 9'd195;
		7'd18:		ff_divide_coeff = 9'd192;
		7'd19:		ff_divide_coeff = 9'd189;
		7'd20:		ff_divide_coeff = 9'd186;
		7'd21:		ff_divide_coeff = 9'd183;
		7'd22:		ff_divide_coeff = 9'd180;
		7'd23:		ff_divide_coeff = 9'd178;
		7'd24:		ff_divide_coeff = 9'd175;
		7'd25:		ff_divide_coeff = 9'd172;
		7'd26:		ff_divide_coeff = 9'd169;
		7'd27:		ff_divide_coeff = 9'd166;
		7'd28:		ff_divide_coeff = 9'd164;
		7'd29:		ff_divide_coeff = 9'd161;
		7'd30:		ff_divide_coeff = 9'd158;
		7'd31:		ff_divide_coeff = 9'd156;
		7'd32:		ff_divide_coeff = 9'd153;
		7'd33:		ff_divide_coeff = 9'd151;
		7'd34:		ff_divide_coeff = 9'd148;
		7'd35:		ff_divide_coeff = 9'd146;
		7'd36:		ff_divide_coeff = 9'd143;
		7'd37:		ff_divide_coeff = 9'd141;
		7'd38:		ff_divide_coeff = 9'd138;
		7'd39:		ff_divide_coeff = 9'd136;
		7'd40:		ff_divide_coeff = 9'd134;
		7'd41:		ff_divide_coeff = 9'd131;
		7'd42:		ff_divide_coeff = 9'd129;
		7'd43:		ff_divide_coeff = 9'd127;
		7'd44:		ff_divide_coeff = 9'd125;
		7'd45:		ff_divide_coeff = 9'd122;
		7'd46:		ff_divide_coeff = 9'd120;
		7'd47:		ff_divide_coeff = 9'd118;
		7'd48:		ff_divide_coeff = 9'd116;
		7'd49:		ff_divide_coeff = 9'd114;
		7'd50:		ff_divide_coeff = 9'd112;
		7'd51:		ff_divide_coeff = 9'd110;
		7'd52:		ff_divide_coeff = 9'd108;
		7'd53:		ff_divide_coeff = 9'd106;
		7'd54:		ff_divide_coeff = 9'd104;
		7'd55:		ff_divide_coeff = 9'd102;
		7'd56:		ff_divide_coeff = 9'd100;
		7'd57:		ff_divide_coeff = 9'd98;
		7'd58:		ff_divide_coeff = 9'd96;
		7'd59:		ff_divide_coeff = 9'd94;
		7'd60:		ff_divide_coeff = 9'd92;
		7'd61:		ff_divide_coeff = 9'd90;
		7'd62:		ff_divide_coeff = 9'd88;
		7'd63:		ff_divide_coeff = 9'd87;
		7'd64:		ff_divide_coeff = 9'd85;
		7'd65:		ff_divide_coeff = 9'd83;
		7'd66:		ff_divide_coeff = 9'd81;
		7'd67:		ff_divide_coeff = 9'd80;
		7'd68:		ff_divide_coeff = 9'd78;
		7'd69:		ff_divide_coeff = 9'd76;
		7'd70:		ff_divide_coeff = 9'd74;
		7'd71:		ff_divide_coeff = 9'd73;
		7'd72:		ff_divide_coeff = 9'd71;
		7'd73:		ff_divide_coeff = 9'd70;
		7'd74:		ff_divide_coeff = 9'd68;
		7'd75:		ff_divide_coeff = 9'd66;
		7'd76:		ff_divide_coeff = 9'd65;
		7'd77:		ff_divide_coeff = 9'd63;
		7'd78:		ff_divide_coeff = 9'd62;
		7'd79:		ff_divide_coeff = 9'd60;
		7'd80:		ff_divide_coeff = 9'd59;
		7'd81:		ff_divide_coeff = 9'd57;
		7'd82:		ff_divide_coeff = 9'd56;
		7'd83:		ff_divide_coeff = 9'd54;
		7'd84:		ff_divide_coeff = 9'd53;
		7'd85:		ff_divide_coeff = 9'd51;
		7'd86:		ff_divide_coeff = 9'd50;
		7'd87:		ff_divide_coeff = 9'd48;
		7'd88:		ff_divide_coeff = 9'd47;
		7'd89:		ff_divide_coeff = 9'd46;
		7'd90:		ff_divide_coeff = 9'd44;
		7'd91:		ff_divide_coeff = 9'd43;
		7'd92:		ff_divide_coeff = 9'd41;
		7'd93:		ff_divide_coeff = 9'd40;
		7'd94:		ff_divide_coeff = 9'd39;
		7'd95:		ff_divide_coeff = 9'd37;
		7'd96:		ff_divide_coeff = 9'd36;
		7'd97:		ff_divide_coeff = 9'd35;
		7'd98:		ff_divide_coeff = 9'd33;
		7'd99:		ff_divide_coeff = 9'd32;
		7'd100:		ff_divide_coeff = 9'd31;
		7'd101:		ff_divide_coeff = 9'd30;
		7'd102:		ff_divide_coeff = 9'd28;
		7'd103:		ff_divide_coeff = 9'd27;
		7'd104:		ff_divide_coeff = 9'd26;
		7'd105:		ff_divide_coeff = 9'd25;
		7'd106:		ff_divide_coeff = 9'd24;
		7'd107:		ff_divide_coeff = 9'd22;
		7'd108:		ff_divide_coeff = 9'd21;
		7'd109:		ff_divide_coeff = 9'd20;
		7'd110:		ff_divide_coeff = 9'd19;
		7'd111:		ff_divide_coeff = 9'd18;
		7'd112:		ff_divide_coeff = 9'd17;
		7'd113:		ff_divide_coeff = 9'd15;
		7'd114:		ff_divide_coeff = 9'd14;
		7'd115:		ff_divide_coeff = 9'd13;
		7'd116:		ff_divide_coeff = 9'd12;
		7'd117:		ff_divide_coeff = 9'd11;
		7'd118:		ff_divide_coeff = 9'd10;
		7'd119:		ff_divide_coeff = 9'd9;
		7'd120:		ff_divide_coeff = 9'd8;
		7'd121:		ff_divide_coeff = 9'd7;
		7'd122:		ff_divide_coeff = 9'd6;
		7'd123:		ff_divide_coeff = 9'd5;
		7'd124:		ff_divide_coeff = 9'd4;
		7'd125:		ff_divide_coeff = 9'd3;
		7'd126:		ff_divide_coeff = 9'd2;
		7'd127:		ff_divide_coeff = 9'd1;
		endcase
	end

	//	w_coeff = ff_divide_coeff + 256
	assign w_coeff	= { ff_divide_coeff[8], ~ff_divide_coeff[8], ff_divide_coeff[7:0] };
	assign w_mul	= w_coeff * ff_x;

	always @( posedge clk ) begin
		if( ff_mgx0 ) begin
			ff_mul			<= { ff_x, 3'd0 };
			ff_exp2			<= 3'd7;
		end
		else begin
			ff_mul			<= w_mul[17:5];
			ff_exp2			<= ff_exp1;
		end
		ff_bit_shift2	<= ff_bit_shift1;
	end

	assign w_shift		= (ff_bit_shift2 == 2'd0) ?   ff_mul[12:0]:
						  (ff_bit_shift2 == 2'd1) ? { ff_mul[11:0], 1'b0 }:
						  (ff_bit_shift2 == 2'd2) ? { ff_mul[10:0], 2'd0 }: { 3'd0, ff_mul[9:0], 3'd0 };

	assign w_sample_x	= (ff_exp2 == 3'd0) ?         w_shift[12:0]  :
						  (ff_exp2 == 3'd1) ? { 1'd0, w_shift[12:1] }:
						  (ff_exp2 == 3'd2) ? { 2'd0, w_shift[12:2] }:
						  (ff_exp2 == 3'd3) ? { 3'd0, w_shift[12:3] }:
						  (ff_exp2 == 3'd4) ? { 4'd0, w_shift[12:4] }:
						  (ff_exp2 == 3'd5) ? { 5'd0, w_shift[12:5] }:
						  (ff_exp2 == 3'd6) ? { 6'd0, w_shift[12:6] }: { 7'd0, w_shift[12:7] };

	always @( posedge clk ) begin
		ff_sample_x		<= w_sample_x[6:0];
		ff_overflow		<= (w_sample_x[12:7] != 6'd0);
	end

	assign sample_x		= ff_sample_x;
	assign overflow		= ff_overflow;
endmodule
