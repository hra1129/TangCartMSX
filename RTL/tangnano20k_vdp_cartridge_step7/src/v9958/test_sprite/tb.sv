// -----------------------------------------------------------------------------
//	Test of vdp_sprite.v
//	Copyright (C)2025 Takayuki Hara (HRA!)
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
// --------------------------------------------------------------------

module tb ();
	localparam		clk_base		= 1_000_000_000/42_954_540;	//	ps
	reg				clk;
	reg				reset;
	reg				enable;
	reg		[1:0]	dot_state;
	reg		[2:0]	eight_dot_state;
	reg		[8:0]	dot_counter_x;
	reg		[8:0]	dot_counter_yp;
	reg				bwindow_y;
	wire			p_s0_sp_collision_incidence;
	wire			p_s0_sp_overmapped;
	wire	[4:0]	p_s0_sp_overmapped_num;
	wire	[8:0]	p_s3s4_sp_collision_x;
	wire	[8:0]	p_s5s6_sp_collision_y;
	reg				p_s0_reset_req;
	wire			p_s0_reset_ack;
	reg				p_s5_reset_req;
	wire			p_s5_reset_ack;
	reg				reg_r1_sp_size;
	reg				reg_r1_sp_zoom;
	reg		[9:0]	reg_r11r5_sp_atr_addr;
	reg		[5:0]	reg_r6_sp_gen_addr;
	reg				reg_r8_col0_on;
	reg				reg_r8_sp_off;
	reg		[7:0]	reg_r23_vstart_line;
	reg		[2:0]	reg_r27_h_scroll;
	reg				p_sp_mode2;
	reg				vram_interleave_mode;
	wire			sp_vram_accessing;
	wire	[7:0]	p_vram_rdata;
	wire	[16:0]	p_vram_address;
	wire			sp_color_code_en;
	wire	[3:0]	sp_color_code;
	reg				reg_r9_y_dots;
	reg		[16:0]	ff_dram_address_cbus;
	reg				ff_valid_cbus;
	reg		[16:0]	ff_address_inst;
	reg				ff_valid_inst;
	reg		[7:0]	ff_rdata0;
	reg		[7:0]	ff_rdata1;
	reg		[7:0]	ff_rdata2;
	reg		[7:0]	ff_rdata3;
	reg				ff_valid0;
	reg				ff_valid1;
	reg				ff_valid2;
	reg				ff_valid3;
	reg		[7:0]	ff_rdata_inst;
	wire			w_dot_counter_x_end;

	// --------------------------------------------------------------------
	//	DUT
	// --------------------------------------------------------------------
	vdp_sprite u_sprite (
		.clk							( clk							),
		.reset							( reset							),
		.enable							( enable						),
		.dot_state						( dot_state						),
		.eight_dot_state				( eight_dot_state				),
		.dot_counter_x					( dot_counter_x					),
		.dot_counter_yp					( dot_counter_yp				),
		.bwindow_y						( bwindow_y						),
		.p_s0_sp_collision_incidence	( p_s0_sp_collision_incidence	),
		.p_s0_sp_overmapped				( p_s0_sp_overmapped			),
		.p_s0_sp_overmapped_num			( p_s0_sp_overmapped_num		),
		.p_s3s4_sp_collision_x			( p_s3s4_sp_collision_x			),
		.p_s5s6_sp_collision_y			( p_s5s6_sp_collision_y			),
		.p_s0_reset_req					( p_s0_reset_req				),
		.p_s0_reset_ack					( p_s0_reset_ack				),
		.p_s5_reset_req					( p_s5_reset_req				),
		.p_s5_reset_ack					( p_s5_reset_ack				),
		.reg_r1_sp_size					( reg_r1_sp_size				),
		.reg_r1_sp_zoom					( reg_r1_sp_zoom				),
		.reg_r11r5_sp_atr_addr			( reg_r11r5_sp_atr_addr			),
		.reg_r6_sp_gen_addr				( reg_r6_sp_gen_addr			),
		.reg_r8_col0_on					( reg_r8_col0_on				),
		.reg_r8_sp_off					( reg_r8_sp_off					),
		.reg_r23_vstart_line			( reg_r23_vstart_line			),
		.reg_r27_h_scroll				( reg_r27_h_scroll				),
		.p_sp_mode2						( p_sp_mode2					),
		.vram_interleave_mode			( vram_interleave_mode			),
		.sp_vram_accessing				( sp_vram_accessing				),
		.p_vram_rdata					( p_vram_rdata					),
		.p_vram_address					( p_vram_address				),
		.sp_color_code_en				( sp_color_code_en				),
		.sp_color_code					( sp_color_code					),
		.reg_r9_y_dots					( reg_r9_y_dots					)
	);

	// --------------------------------------------------------------------
	//	clock
	// --------------------------------------------------------------------
	always #(clk_base/2) begin
		clk <= ~clk;
	end

	always @( posedge clk or posedge reset ) begin
		if( reset ) begin
			enable <= 0;
		end
		else begin
			enable <= ~enable;
		end
	end

	always @( posedge clk or posedge reset ) begin
		if( reset ) begin
			dot_state <= 0;
		end
		else if( enable == 1'b1 ) begin
			case( dot_state )
				2'b00:		dot_state <= 2'b01;
				2'b01:		dot_state <= 2'b11;
				2'b11:		dot_state <= 2'b10;
				2'b10:		dot_state <= 2'b00;
				default:	dot_state <= 2'b00;
			endcase
		end
	end

	always @( posedge clk or posedge reset ) begin
		if( reset ) begin
			eight_dot_state <= 3'd0;
		end
		else if( enable == 1'b1 ) begin
			if( dot_state == 2'b10 ) begin
				if( w_dot_counter_x_end ) begin
					eight_dot_state <= 3'd0;
				end
				else begin
					eight_dot_state <= eight_dot_state + 3'd1;
				end
			end
		end
	end

	always @( posedge clk or posedge reset ) begin
		if( reset ) begin
			dot_counter_x <= 0;
		end
		else if( enable == 1'b1 && dot_state == 2'b10 ) begin
			if( w_dot_counter_x_end ) begin
				dot_counter_x <= 9'd0;
			end
			else begin
				dot_counter_x <= dot_counter_x + 9'd1;
			end
		end
	end

	assign w_dot_counter_x_end = (dot_counter_x == 9'd341) ? 1'b1: 1'b0;

	always @( posedge clk or posedge reset ) begin
		if( reset ) begin
			dot_counter_yp <= 0;
		end
		else if( enable == 1'b1 && dot_state == 2'b10 ) begin
			if( dot_counter_x == 9'd341 ) begin
				if( dot_counter_yp == 9'd253 ) begin
					dot_counter_yp <= 9'd0;
				end
				else begin
					dot_counter_yp <= dot_counter_yp + 9'd1;
				end
			end
		end
	end

	always @( posedge clk or posedge reset ) begin
		if( reset ) begin
			bwindow_y <= 0;
		end
		else if( enable ) begin
			if( dot_counter_yp < 212 ) begin
				if( dot_counter_x < 264 ) begin
					bwindow_y <= 1'b1;
				end
				else begin
					bwindow_y <= 1'b0;
				end
			end
			else begin
				bwindow_y <= 1'b0;
			end
		end
	end

	always @( posedge clk ) begin
		if( !enable ) begin
			//	hold
		end
		else if( dot_state == 2'b10 ) begin
			if( sp_vram_accessing ) begin
				if( dot_counter_x < 264 ) begin
					if( eight_dot_state == 3'd5 ) begin
						ff_dram_address_cbus	<= p_vram_address;
						ff_valid_cbus			<= 1'b1;
					end
				end
				else begin
					if( eight_dot_state < 3'd6 ) begin
						ff_dram_address_cbus	<= p_vram_address;
						ff_valid_cbus			<= 1'b1;
					end
				end
			end
		end
		else begin
			ff_valid_cbus			<= 1'b0;
		end
	end

	always @( posedge clk ) begin
		ff_address_inst		<= ff_dram_address_cbus;
		ff_valid_inst		<= ff_valid_cbus;
	end

	always @( posedge clk ) begin
		ff_valid0	<= ff_valid_inst;
		ff_valid1	<= ff_valid0;
		ff_valid2	<= ff_valid1;
		ff_valid3	<= ff_valid2;
		case( ff_address_inst )
		17'h00000:	ff_rdata0 <= 8'b00000011;
		17'h00001:	ff_rdata0 <= 8'b00001111;
		17'h00002:	ff_rdata0 <= 8'b00011111;
		17'h00003:	ff_rdata0 <= 8'b00111111;
		17'h00004:	ff_rdata0 <= 8'b01111111;
		17'h00005:	ff_rdata0 <= 8'b01111111;
		17'h00006:	ff_rdata0 <= 8'b11111111;
		17'h00007:	ff_rdata0 <= 8'b11111111;
		17'h00008:	ff_rdata0 <= 8'b11111111;
		17'h00009:	ff_rdata0 <= 8'b11111111;
		17'h0000A:	ff_rdata0 <= 8'b01111111;
		17'h0000B:	ff_rdata0 <= 8'b01111111;
		17'h0000C:	ff_rdata0 <= 8'b00111111;
		17'h0000D:	ff_rdata0 <= 8'b00011111;
		17'h0000E:	ff_rdata0 <= 8'b00001111;
		17'h0000F:	ff_rdata0 <= 8'b00000011;
		17'h00010:	ff_rdata0 <= 8'b11000000;
		17'h00011:	ff_rdata0 <= 8'b11110000;
		17'h00012:	ff_rdata0 <= 8'b11111000;
		17'h00013:	ff_rdata0 <= 8'b11111100;
		17'h00014:	ff_rdata0 <= 8'b11111110;
		17'h00015:	ff_rdata0 <= 8'b11111110;
		17'h00016:	ff_rdata0 <= 8'b11111111;
		17'h00017:	ff_rdata0 <= 8'b11111111;
		17'h00018:	ff_rdata0 <= 8'b11111111;
		17'h00019:	ff_rdata0 <= 8'b11111111;
		17'h0001A:	ff_rdata0 <= 8'b11111110;
		17'h0001B:	ff_rdata0 <= 8'b11111110;
		17'h0001C:	ff_rdata0 <= 8'b11111100;
		17'h0001D:	ff_rdata0 <= 8'b11111000;
		17'h0001E:	ff_rdata0 <= 8'b11110000;
		17'h0001F:	ff_rdata0 <= 8'b11000000;
		17'h01800:	ff_rdata0 <= 20;		//	Y
		17'h01801:	ff_rdata0 <= 50;		//	X
		17'h01802:	ff_rdata0 <= 0;			//	Pattern
		17'h01803:	ff_rdata0 <= 15;		//	Color
		default:	ff_rdata0 <= 0;
		endcase
		ff_rdata1	<= ff_rdata0;
		ff_rdata2	<= ff_rdata1;
		ff_rdata3	<= ff_rdata2;
	end

	always @( posedge clk ) begin
		if( ff_valid3 ) begin
			ff_rdata_inst	<= ff_rdata3;
		end
	end

	assign p_vram_rdata = ff_rdata_inst;

	// --------------------------------------------------------------------
	//	Test bench
	// --------------------------------------------------------------------
	initial begin
		clk = 0;
		reset = 1;
		enable = 0;
		dot_state = 0;
		eight_dot_state = 0;
		dot_counter_x = 0;
		dot_counter_yp = 0;
		bwindow_y = 0;
		p_s0_reset_req = 0;
		p_s5_reset_req = 0;
		reg_r1_sp_size = 1;
		reg_r1_sp_zoom = 0;
		reg_r11r5_sp_atr_addr = 10'b00_0011_0000;		//	1800h
		reg_r6_sp_gen_addr = 0;							//	0000h
		reg_r8_col0_on = 0;
		reg_r8_sp_off = 0;
		reg_r23_vstart_line = 0;
		reg_r27_h_scroll = 0;
		p_sp_mode2 = 0;
		vram_interleave_mode = 0;
		reg_r9_y_dots = 0;

		@( posedge clk );
		@( posedge clk );
		@( posedge clk );
		reset <= 0;
		@( posedge clk );

		repeat( 1368 * 600 ) @( posedge clk );

		repeat( 10 ) @( posedge clk );
		$finish;
	end
endmodule
