//
//	video_out_sigmoid.v
//	 LCD 800x480 up-scan converter.
//
//	Copyright (C) 2024 Takayuki Hara.
//	All rights reserved.
//									   https://github.com/hra1129
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
// -----------------------------------------------------------------------------

module video_out_sigmoid (
	input			clk,						//	42.95454MHz
	input	[5:0]	coeff,
	output	[5:0]	sigmoid
);
	reg		[5:0]	ff_sigmoid;

	always @( posedge clk ) begin
		case( coeff )
//	4
//		6'd0:		ff_sigmoid	<= 6'd0;
//		6'd1:		ff_sigmoid	<= 6'd0;
//		6'd2:		ff_sigmoid	<= 6'd1;
//		6'd3:		ff_sigmoid	<= 6'd1;
//		6'd4:		ff_sigmoid	<= 6'd1;
//		6'd5:		ff_sigmoid	<= 6'd2;
//		6'd6:		ff_sigmoid	<= 6'd2;
//		6'd7:		ff_sigmoid	<= 6'd2;
//		6'd8:		ff_sigmoid	<= 6'd3;
//		6'd9:		ff_sigmoid	<= 6'd3;
//		6'd10:		ff_sigmoid	<= 6'd3;
//		6'd11:		ff_sigmoid	<= 6'd4;
//		6'd12:		ff_sigmoid	<= 6'd4;
//		6'd13:		ff_sigmoid	<= 6'd5;
//		6'd14:		ff_sigmoid	<= 6'd6;
//		6'd15:		ff_sigmoid	<= 6'd6;
//		6'd16:		ff_sigmoid	<= 6'd7;
//		6'd17:		ff_sigmoid	<= 6'd8;
//		6'd18:		ff_sigmoid	<= 6'd9;
//		6'd19:		ff_sigmoid	<= 6'd10;
//		6'd20:		ff_sigmoid	<= 6'd11;
//		6'd21:		ff_sigmoid	<= 6'd12;
//		6'd22:		ff_sigmoid	<= 6'd14;
//		6'd23:		ff_sigmoid	<= 6'd15;
//		6'd24:		ff_sigmoid	<= 6'd17;
//		6'd25:		ff_sigmoid	<= 6'd18;
//		6'd26:		ff_sigmoid	<= 6'd20;
//		6'd27:		ff_sigmoid	<= 6'd22;
//		6'd28:		ff_sigmoid	<= 6'd24;
//		6'd29:		ff_sigmoid	<= 6'd26;
//		6'd30:		ff_sigmoid	<= 6'd28;
//		6'd31:		ff_sigmoid	<= 6'd30;
//		6'd32:		ff_sigmoid	<= 6'd32;
//		6'd33:		ff_sigmoid	<= 6'd33;
//		6'd34:		ff_sigmoid	<= 6'd35;
//		6'd35:		ff_sigmoid	<= 6'd37;
//		6'd36:		ff_sigmoid	<= 6'd39;
//		6'd37:		ff_sigmoid	<= 6'd41;
//		6'd38:		ff_sigmoid	<= 6'd43;
//		6'd39:		ff_sigmoid	<= 6'd45;
//		6'd40:		ff_sigmoid	<= 6'd46;
//		6'd41:		ff_sigmoid	<= 6'd48;
//		6'd42:		ff_sigmoid	<= 6'd49;
//		6'd43:		ff_sigmoid	<= 6'd51;
//		6'd44:		ff_sigmoid	<= 6'd52;
//		6'd45:		ff_sigmoid	<= 6'd53;
//		6'd46:		ff_sigmoid	<= 6'd54;
//		6'd47:		ff_sigmoid	<= 6'd55;
//		6'd48:		ff_sigmoid	<= 6'd56;
//		6'd49:		ff_sigmoid	<= 6'd57;
//		6'd50:		ff_sigmoid	<= 6'd57;
//		6'd51:		ff_sigmoid	<= 6'd58;
//		6'd52:		ff_sigmoid	<= 6'd59;
//		6'd53:		ff_sigmoid	<= 6'd59;
//		6'd54:		ff_sigmoid	<= 6'd60;
//		6'd55:		ff_sigmoid	<= 6'd60;
//		6'd56:		ff_sigmoid	<= 6'd61;
//		6'd57:		ff_sigmoid	<= 6'd61;
//		6'd58:		ff_sigmoid	<= 6'd61;
//		6'd59:		ff_sigmoid	<= 6'd62;
//		6'd60:		ff_sigmoid	<= 6'd62;
//		6'd61:		ff_sigmoid	<= 6'd62;
//		6'd62:		ff_sigmoid	<= 6'd63;
//		6'd63:		ff_sigmoid	<= 6'd63;
//		default:	ff_sigmoid	<= 6'dX;

//	3
		6'd0:		ff_sigmoid	<= 6'd0;
		6'd1:		ff_sigmoid	<= 6'd1;
		6'd2:		ff_sigmoid	<= 6'd2;
		6'd3:		ff_sigmoid	<= 6'd3;
		6'd4:		ff_sigmoid	<= 6'd4;
		6'd5:		ff_sigmoid	<= 6'd4;
		6'd6:		ff_sigmoid	<= 6'd5;
		6'd7:		ff_sigmoid	<= 6'd5;
		6'd8:		ff_sigmoid	<= 6'd6;
		6'd9:		ff_sigmoid	<= 6'd6;
		6'd10:		ff_sigmoid	<= 6'd7;
		6'd11:		ff_sigmoid	<= 6'd7;
		6'd12:		ff_sigmoid	<= 6'd8;
		6'd13:		ff_sigmoid	<= 6'd9;
		6'd14:		ff_sigmoid	<= 6'd9;
		6'd15:		ff_sigmoid	<= 6'd10;
		6'd16:		ff_sigmoid	<= 6'd11;
		6'd17:		ff_sigmoid	<= 6'd12;
		6'd18:		ff_sigmoid	<= 6'd13;
		6'd19:		ff_sigmoid	<= 6'd14;
		6'd20:		ff_sigmoid	<= 6'd15;
		6'd21:		ff_sigmoid	<= 6'd16;
		6'd22:		ff_sigmoid	<= 6'd18;
		6'd23:		ff_sigmoid	<= 6'd19;
		6'd24:		ff_sigmoid	<= 6'd20;
		6'd25:		ff_sigmoid	<= 6'd21;
		6'd26:		ff_sigmoid	<= 6'd23;
		6'd27:		ff_sigmoid	<= 6'd24;
		6'd28:		ff_sigmoid	<= 6'd26;
		6'd29:		ff_sigmoid	<= 6'd27;
		6'd30:		ff_sigmoid	<= 6'd29;
		6'd31:		ff_sigmoid	<= 6'd30;
		6'd32:		ff_sigmoid	<= 6'd32;
		6'd33:		ff_sigmoid	<= 6'd33;
		6'd34:		ff_sigmoid	<= 6'd34;
		6'd35:		ff_sigmoid	<= 6'd36;
		6'd36:		ff_sigmoid	<= 6'd37;
		6'd37:		ff_sigmoid	<= 6'd39;
		6'd38:		ff_sigmoid	<= 6'd40;
		6'd39:		ff_sigmoid	<= 6'd42;
		6'd40:		ff_sigmoid	<= 6'd43;
		6'd41:		ff_sigmoid	<= 6'd44;
		6'd42:		ff_sigmoid	<= 6'd45;
		6'd43:		ff_sigmoid	<= 6'd47;
		6'd44:		ff_sigmoid	<= 6'd48;
		6'd45:		ff_sigmoid	<= 6'd49;
		6'd46:		ff_sigmoid	<= 6'd50;
		6'd47:		ff_sigmoid	<= 6'd51;
		6'd48:		ff_sigmoid	<= 6'd52;
		6'd49:		ff_sigmoid	<= 6'd53;
		6'd50:		ff_sigmoid	<= 6'd54;
		6'd51:		ff_sigmoid	<= 6'd54;
		6'd52:		ff_sigmoid	<= 6'd55;
		6'd53:		ff_sigmoid	<= 6'd56;
		6'd54:		ff_sigmoid	<= 6'd56;
		6'd55:		ff_sigmoid	<= 6'd57;
		6'd56:		ff_sigmoid	<= 6'd57;
		6'd57:		ff_sigmoid	<= 6'd58;
		6'd58:		ff_sigmoid	<= 6'd58;
		6'd59:		ff_sigmoid	<= 6'd59;
		6'd60:		ff_sigmoid	<= 6'd60;
		6'd61:		ff_sigmoid	<= 6'd61;
		6'd62:		ff_sigmoid	<= 6'd62;
		6'd63:		ff_sigmoid	<= 6'd63;
		default:	ff_sigmoid	<= 6'dX;
		endcase
	end

































































	assign sigmoid	= ff_sigmoid;
endmodule
