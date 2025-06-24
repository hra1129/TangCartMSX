//
//	vdp_graphic4567.v
//	  Imprementation of Graphic Mode 4,5,6 and 7.
//
//	Copyright (C) 2024 Takayuki Hara
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

module vdp_graphic4567(
	// vdp clock ... 21.477mhz
	input				clk,
	input				reset,
	input				enable,

	input		[1:0]	dot_state,
	input		[2:0]	eight_dot_state,
	input		[8:0]	dot_counter_x,
	input		[8:0]	dotcountery,

	input				vdp_mode_graphic4,
	input				vdp_mode_graphic5,
	input				vdp_mode_graphic6,
	input				vdp_mode_graphic7,

	// registers
	input				reg_r1_bl_clks,
	input		[6:0]	reg_r2_pattern_name,
	input		[7:0]	reg_r13_blink_period,
	input		[8:3]	reg_r26_h_scroll,
	input		[2:0]	reg_r27_h_scroll,
	input				reg_r25_yae,
	input				reg_r25_yjk,
	input				reg_r25_sp2,

	//
	input		[7:0]	p_vram_rdata,
	input		[7:0]	pramdatpair,
	output reg	[16:0]	p_vram_address,

	output reg	[7:0]	pcolorcode,

	output reg	[5:0]	p_yjk_r,
	output reg	[5:0]	p_yjk_g,
	output reg	[5:0]	p_yjk_b,
	output reg			p_yjk_en
);

	wire	[16:0]	w_vram_address_g45;
	wire	[16:0]	w_vram_address_g67;
	reg		[8:0]	ff_local_dot_counter_x;
	reg		[6:0]	ff_pattern_name_base_address;

	wire	[7:0]	w_fifo_address;
	reg		[7:0]	ff_fifo_write_address;
	reg		[7:0]	ff_fifo_read_address;
	wire			w_fifo_we;
	reg				ff_fifo_write;
	wire	[7:0]	w_fifo_wdata;
	wire	[7:0]	w_fifo_rdata;

	reg		[7:0]	ff_fifo0;
	reg		[7:0]	ff_fifo1;
	reg		[7:0]	ff_fifo2;
	reg		[7:0]	ff_fifo3;
	reg		[7:0]	ff_pix0;
	reg		[7:0]	ff_pix1;
	reg		[7:0]	ff_pix2;
	reg		[7:0]	ff_pix3;

	reg		[7:0]	ff_color_data;
	wire	[8:0]	w_dot_counter_x;
	wire			w_sp2_h_scroll;
	wire	[7:0]	w_pix;

	wire	[4:0]	w_y;
	wire	[5:0]	w_k;
	wire	[5:0]	w_j;
	wire	[6:0]	w_r_yjk;
	wire	[6:0]	w_g_yjk;
	wire	[7:0]	w_b_y;
	wire	[7:0]	w_b_jk;
	wire	[8:0]	w_b_yjkp;
	wire	[6:0]	w_b_yjk;
	wire	[5:0]	w_r;
	wire	[5:0]	w_g;
	wire	[5:0]	w_b;
	reg		[3:0]	ff_blink_clk_cnt;
	reg				ff_blink_state;
	reg		[3:0]	ff_blink_period_cnt;
	wire	[3:0]	w_blink_cnt_max;
	wire			w_blink_sync;
	wire			w_ram_we;

	// --------------------------------------------------------------------
	// fifo and control signals
	// --------------------------------------------------------------------
	assign w_fifo_address	=	( ff_fifo_write ) ? ff_fifo_write_address : ff_fifo_read_address;
	assign w_fifo_we		=	ff_fifo_write;
	assign w_fifo_wdata		=	( (dot_state == 2'b00) || (dot_state == 2'b01) ) ? p_vram_rdata : pramdatpair;

	assign w_ram_we			= w_fifo_we & enable;

	vdp_ram_256byte u_fifo_ram (
		.clk		( clk				),
		.enable		( enable			),
		.address	( w_fifo_address	),
		.we			( w_ram_we			),
		.wdata		( w_fifo_wdata		),
		.rdata		( w_fifo_rdata		)
	);

	always @( posedge clk ) begin
		if( !enable ) begin
			//	hold
		end
		else if( dot_state == 2'b01 ) begin
			case( eight_dot_state[1:0] )
			2'b00:	ff_fifo0	<= w_fifo_rdata;
			2'b01:	ff_fifo1	<= w_fifo_rdata;
			2'b10:	ff_fifo2	<= w_fifo_rdata;
			2'b11:	ff_fifo3	<= w_fifo_rdata;
			default:
				begin
					//	hold
				end
			endcase
		end
	end

	always @( posedge clk ) begin
		if( !enable ) begin
			//	hold
		end
		else if( dot_state == 2'b00 && eight_dot_state[1:0] == 2'b00 ) begin
			ff_pix0 <= ff_fifo0;
			ff_pix1 <= ff_fifo1;
			ff_pix2 <= ff_fifo2;
			ff_pix3 <= ff_fifo3;
		end
	end

	assign w_pix	=	( eight_dot_state[1:0] == 2'b00) ? ff_pix0 :
						( eight_dot_state[1:0] == 2'b01) ? ff_pix1 :
						( eight_dot_state[1:0] == 2'b10) ? ff_pix2 : ff_pix3;

	// two screen h-scroll mode (r25 sp2 = 1'b1)
	// consider r#13 blinking to flip pages
	assign w_sp2_h_scroll	=	( reg_r25_sp2 && ff_pattern_name_base_address[5] ) ? ff_local_dot_counter_x[8] :
								( !ff_blink_state                                ) ? ff_pattern_name_base_address[5] : 1'b0;

	// vram address mappings.
	assign w_vram_address_g45	=	{ ff_pattern_name_base_address[6], w_sp2_h_scroll, 
			(ff_pattern_name_base_address[4:0] & dotcountery[7:3]), dotcountery[2:0], ff_local_dot_counter_x[7:1] };

	assign w_vram_address_g67	=	{ w_sp2_h_scroll, 
			(ff_pattern_name_base_address[4:0] & dotcountery[7:3]), dotcountery[2:0], ff_local_dot_counter_x[7:0] };

	// fifo control
	always @( posedge clk ) begin
		if( reset ) begin
			ff_fifo_write_address <= 8'd0;
		end
		else if( !enable ) begin
			//	hold
		end
		else if( dot_state == 2'b00 ) begin
			if( eight_dot_state == 3'b000 && dot_counter_x == 0 ) begin
				ff_fifo_write_address <= 8'd0;
			end
		end
		else if( ff_fifo_write ) begin
			ff_fifo_write_address <= ff_fifo_write_address + 1;
		end
	end

	always @( posedge clk ) begin
		if( reset ) begin
			ff_fifo_read_address <= 8'd0;
		end
		else if( !enable ) begin
			//	hold
		end
		else begin
			case( dot_state )
			2'b00:
				begin
					//	hold
				end
			2'b01:
				begin
					if( !vdp_mode_graphic4 && !vdp_mode_graphic5 ) begin
						ff_fifo_read_address <= ff_fifo_read_address + 1;
					end
					else if( !eight_dot_state[0] ) begin
						// graphic4, 5
						ff_fifo_read_address <= ff_fifo_read_address + 1;
					end
				end
			2'b11:
				begin
					//	hold
				end
			2'b10:
				begin
					if( dot_counter_x == 9'h004 ) begin
						ff_fifo_read_address <= 8'd0;
					end
				end
			default:
				begin
					//	hold
				end
			endcase
		end
	end

	always @( posedge clk ) begin
		if( reset ) begin
			ff_fifo_write <= 1'b0;
		end
		else if( !enable ) begin
			//	hold
		end
		else begin
			case( dot_state )
			2'b10:
				begin
					if(		eight_dot_state == 3'd0 ) begin
						ff_fifo_write <= 1'b0;
					end
					else if((eight_dot_state == 3'd1) ||
							(eight_dot_state == 3'd2) ||
							(eight_dot_state == 3'd3) ||
							(eight_dot_state == 3'd4) ) begin
						ff_fifo_write <= 1'b1;
					end
				end
			2'b00:
				ff_fifo_write <= 1'b0;
			2'b01:
				begin
					if( (vdp_mode_graphic6 || vdp_mode_graphic7) &&
						(	(eight_dot_state == 3'd2) ||
							(eight_dot_state == 3'd3) ||
							(eight_dot_state == 3'd4) ||
							(eight_dot_state == 3'd5)) ) begin
						ff_fifo_write <= 1'b1;
					end
				end
			2'b11:
				ff_fifo_write <= 1'b0;
			default:
				begin
					//	hold
				end
			endcase
		end
	end

	// fifo out latch
	always @( posedge clk ) begin
		if( reset ) begin
			ff_color_data	<= 8'd0;
			pcolorcode		<= 8'd0;
		end
		else if( !enable ) begin
			//	hold
		end
		else begin
			case( dot_state )
			2'b00:
				begin
					//	hold
				end
			2'b01:
				begin
					if( vdp_mode_graphic4 || vdp_mode_graphic5 ) begin
						if( !eight_dot_state[0] ) begin
							ff_color_data		<= w_pix;
							pcolorcode[7:4]		<= 4'd0;
							pcolorcode[3:0]		<= w_pix[7:4];
						end
						else begin
							pcolorcode[7:4]		<= 4'd0;
							pcolorcode[3:0]		<= ff_color_data[3:0];
						end
					end
					else if( vdp_mode_graphic6 || reg_r25_yae ) begin
						ff_color_data		<= w_pix;
						pcolorcode[7:4]		<= 4'd0;
						pcolorcode[3:0]		<= w_pix[7:4];
					end
					else begin
						// graphic7
						pcolorcode	<= w_pix;
					end
				end
			2'b11:
				begin
					//	hold
				end
			2'b10:
				// high resolution mode .
				if( vdp_mode_graphic6 ) begin
					pcolorcode[7:4]		<= 4'd0;
					pcolorcode[3:0]		<= ff_color_data[3:0];
				end
			default:
				begin
					//	hold
				end
			endcase
		end
	end

	// yjk color convert
	assign w_y		=	w_pix[7:3];													//	y ( 0...31)
	assign w_j		=	{ ff_pix3[2:0], ff_pix2[2:0] };								//	j (-32...31)
	assign w_k		=	{ ff_pix1[2:0], ff_pix0[2:0] };								//	k (-32...31)

	assign w_r_yjk	=	{ 2'b00, w_y } + { w_j[5], w_j };							//	r (-32...62)
	assign w_g_yjk	=	{ 2'b00, w_y } + { w_k[5], w_k };							//	b (-32...62)
	assign w_b_y	=	{ 1'b0, w_y, 2'b00 } + { 3'd0, w_y };						//	y * 5				( 0...155 )
	assign w_b_jk	=	{ w_j[5], w_j, 1'b0 } + { w_k[5], w_k[5], w_k };			//	j * 2 + k			( -96...93 )
	assign w_b_yjkp	=	{ 1'b0, w_b_y } - { w_b_jk[7], w_b_jk } + 9'b000000010;		//	(y * 5 - (j * 2 + k) + 2)	(-91...253)
	assign w_b_yjk	=	w_b_yjkp[8:2];												//	(y * 5 - (j * 2 + k) + 2)/4 (-22...63)

	assign w_r		=	( w_r_yjk[6] ) ? 6'b000000 :	// under limit
						( w_r_yjk[5] ) ? 6'b111111 :	// over limit
						{ w_r_yjk[4:0], 1'b0 };
	assign w_g		=	( w_g_yjk[6] ) ? 6'b000000 :	// under limit
						( w_g_yjk[5] ) ? 6'b111111 :	// over limit
						{ w_g_yjk[4:0], 1'b0 };
	assign w_b		=	( w_b_yjk[6] ) ? 6'b000000 :	// under limit
						( w_b_yjk[5] ) ? 6'b111111 :	// over limit
						{ w_b_yjk[4:0], 1'b0 };

	always @( posedge clk ) begin
		if( reset ) begin
			p_yjk_r <=	6'd0;
			p_yjk_g <=	6'd0;
			p_yjk_b <=	6'd0;
		end
		else if( !enable ) begin
			//	hold
		end
		else if( dot_state == 2'b01 ) begin
			p_yjk_r <= w_r;
			p_yjk_g <= w_g;
			p_yjk_b <= w_b;
		end
	end

	always @( posedge clk ) begin
		if( reset ) begin
			p_yjk_en <= 1'b0;
		end
		else if( !enable ) begin
			//	hold
		end
		else if( dot_state == 2'b01 ) begin
			if( reg_r25_yae && w_pix[3] ) begin
				// palette color on screen10/screen11
				p_yjk_en <= 1'b0;
			end
			else begin
				p_yjk_en <= reg_r25_yjk;
			end
		end
	end

	// vram read address
	always @( posedge clk ) begin
		if( reset ) begin
			p_vram_address <= 17'd0;
		end
		if( !enable ) begin
			//	hold
		end
		else if( dot_state == 2'b11 ) begin
			if( vdp_mode_graphic4 || vdp_mode_graphic5 ) begin
				p_vram_address <= w_vram_address_g45[16:0];
			end
			else begin
				p_vram_address <= { w_vram_address_g67[0], w_vram_address_g67[16:1] };
			end
		end
	end

	always @( posedge clk ) begin
		if( reset ) begin
			ff_pattern_name_base_address	<= 7'd0;
		end
		else if( !enable ) begin
			//	hold
		end
		else if( dot_state == 2'b00 && eight_dot_state == 3'b000 ) begin
			ff_pattern_name_base_address <= reg_r2_pattern_name;
		end
	end

	assign w_dot_counter_x	=	{ (dot_counter_x[8:3] + reg_r26_h_scroll), 3'b000 };

	always @( posedge clk ) begin
		if( reset ) begin
			ff_local_dot_counter_x <= 9'd0;
		end
		else if( !enable ) begin
			//	hold
		end
		else if( dot_state == 2'b00 ) begin
			case( eight_dot_state )
			3'd0:
				ff_local_dot_counter_x <= w_dot_counter_x;
			3'd1, 3'd2, 3'd3, 3'd4:
				ff_local_dot_counter_x <= ff_local_dot_counter_x + 9'd2;
			default:
				begin
					//	hold
				end
			endcase
		end
	end

	assign w_blink_cnt_max	=	( ff_blink_state ) ? reg_r13_blink_period[3:0] : reg_r13_blink_period[7:4];
	assign w_blink_sync		=	( (dot_counter_x == 0) && (dotcountery == 0) && (dot_state == 2'b00) && !reg_r1_bl_clks ) ? 1'b1 :
								( (dot_counter_x == 0) &&                       (dot_state == 2'b00) &&  reg_r1_bl_clks ) ? 1'b1 : 1'b0;

	always @( posedge clk ) begin
		if( reset ) begin
			ff_blink_clk_cnt	<= 4'd0;
			ff_blink_state		<= 1'b0;
			ff_blink_period_cnt	<= 4'd0;
		end
		else if( !enable ) begin
				//	hold
		end
		else if( w_blink_sync ) begin

			if( ff_blink_clk_cnt == 4'd9 ) begin
				ff_blink_clk_cnt <= 4'd0;
				ff_blink_period_cnt <= ff_blink_period_cnt + 1;
			end
			else begin
				ff_blink_clk_cnt <= ff_blink_clk_cnt + 1;
			end

			if( ff_blink_period_cnt >= w_blink_cnt_max ) begin
				ff_blink_period_cnt <= 4'd0;
				if(reg_r13_blink_period[7:4] == 4'b0000) begin
					 // when on period is 0, the page selected should be always odd / r#2
					 ff_blink_state <= 1'b0;
				end
				else if( reg_r13_blink_period[3:0] == 4'b0000 ) begin
					 // when off period is 0 and on not, the page select should be always the r#2 even pair
					 ff_blink_state <= 1'b1;
				end
				else begin
					 // neither are 0, so just keep switching when period ends
					 ff_blink_state <= ~ff_blink_state;
				end
			end
		end
	end
endmodule
