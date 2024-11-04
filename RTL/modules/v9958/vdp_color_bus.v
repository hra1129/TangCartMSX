//
//	vdp_color_bus.v
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
//----------------------------------------------------------------------------

module vdp_color_bus (
	input			reset							,
	input			clk								,
	input			enable							,

	input	[1:0]	dot_state						,
	input	[2:0]	eight_dot_state					,

	output			p_vram_oe_n						,
	output			p_vram_we_n						,
	output	[16:0]	p_vram_address					,
	output	[ 7:0]	p_vram_wdata					,
	input	[15:0]	p_vram_rdata					,

	input			p_vdp_mode_text1				,
	input			p_vdp_mode_text1q				,
	input			p_vdp_mode_text2				,
	input			p_vdp_mode_multi				,
	input			p_vdp_mode_multiq				,
	input			p_vdp_mode_graphic1				,
	input			p_vdp_mode_graphic2				,
	input			p_vdp_mode_graphic3				,
	input			p_vdp_mode_graphic4				,
	input			p_vdp_mode_graphic5				,
	input			p_vdp_mode_graphic6				,
	input			p_vdp_mode_graphic7				,

	input	[16:0]	p_vram_address_cpu				,
	input	[16:0]	p_vram_address_sprite			,
	input	[16:0]	p_vram_address_text12			,
	input	[16:0]	p_vram_address_graphic123m		,
	input	[16:0]	p_vram_address_graphic4567		,

	input	[7:0]	p_vram_wdata_cpu				,
	output	[7:0]	p_vram_rdata_cpu				,
	output	[7:0]	p_vram_data						,
	output	[7:0]	p_vram_data_pair				,

	input			p_prewindow						,
	input			p_prewindow_x					,
	input			p_vdp_command_active			,
	output			p_vdp_command_drive				,
	input			p_vram_addr_set_req				,
	output			p_vram_addr_set_ack				,
	input			p_vram_write_req				,
	output			p_vram_write_ack				,
	input			p_vram_rd_req					,
	output			p_vram_rd_ack					,
	output			p_vdpcmd_vram_write_ack			,
	output			p_vdpcmd_vram_read_ack			,
	input			p_vdpcmd_vram_read_req			,
	input			p_vdpcmd_vram_write_req			,
	input	[16:0]	p_vdpcmd_vram_address			,
	input	[7:0]	p_vdpcmd_vram_wdata				,
	output	[7:0]	p_vdpcmd_vram_rdata				,
	input			p_tx_vram_read_en				,
	input			p_prewindow_y_sp				,
	input			p_sp_vram_accessing				,

	input			reg_r1_disp_on					
);
	localparam	[2:0]	state_idle	= 3'd0;
	localparam	[2:0]	state_draw	= 3'd1;
	localparam	[2:0]	state_cpuw	= 3'd2;
	localparam	[2:0]	state_cpur	= 3'd3;
	localparam	[2:0]	state_sprt	= 3'd4;
	localparam	[2:0]	state_vdpw	= 3'd5;
	localparam	[2:0]	state_vdpr	= 3'd6;
	localparam	[2:0]	state_vdps	= 3'd7;

	reg		[16:0]	ff_vram_access_address;
	reg		[16:0]	ff_vram_address;
	reg				ff_vram_oe_n;
	reg				ff_vram_we_n;
	reg				ff_vram_address_set_ack;
	reg				ff_vram_write_ack;
	reg		[7:0]	ff_vram_wdata;
	reg		[7:0]	ff_vram_rdata;
	reg				ff_vram_rd_ack;
	reg				ff_vdp_command_drive;
	reg				ff_vdpcmd_vram_write_ack;
	reg				ff_vdpcmd_vram_read_ack;
	reg				ff_vdpcmd_vram_reading_req;
	reg				ff_vdpcmd_vram_reading_ack;
	reg		[7:0]	ff_vdpcmd_vram_rdata;
	wire			w_vram_rdata_sel;
	wire	[7:0]	w_vram_data;
	wire	[7:0]	w_vram_data_pair;
	reg				ff_vram_reading_req;
	reg				ff_vram_reading_ack;
	wire			w_text_mode;

	// --------------------------------------------------------------------
	//	port assignment
	// --------------------------------------------------------------------
	assign p_vram_oe_n				= ff_vram_oe_n;
	assign p_vram_we_n				= ff_vram_we_n;
	assign p_vram_address			= ff_vram_address;
	assign p_vram_wdata				= ff_vram_wdata;
	assign p_vdpcmd_vram_rdata		= ff_vdpcmd_vram_rdata;
	assign p_vram_rdata_cpu			= ff_vram_rdata;
	assign p_vram_data				= w_vram_data;
	assign p_vram_data_pair			= w_vram_data_pair;
	assign p_vdpcmd_vram_write_ack	= ff_vdpcmd_vram_write_ack;
	assign p_vdpcmd_vram_read_ack	= ff_vdpcmd_vram_read_ack;
	assign p_vdp_command_drive		= ff_vdp_command_drive;
	assign p_vram_rd_ack			= ff_vram_rd_ack;
	assign p_vram_write_ack			= ff_vram_write_ack;
	assign p_vram_addr_set_ack		= ff_vram_address_set_ack;

	// --------------------------------------------------------------------
	//	internal signals
	// --------------------------------------------------------------------
	assign w_vram_rdata_sel		= ff_vram_address[16];
	assign w_vram_data			= ( !w_vram_rdata_sel ) ? p_vram_rdata[ 7:0] : p_vram_rdata[15:8];
	assign w_vram_data_pair		= (  w_vram_rdata_sel ) ? p_vram_rdata[ 7:0] : p_vram_rdata[15:8];
	assign w_text_mode			= p_vdp_mode_text1 | p_vdp_mode_text1q | p_vdp_mode_text2;

	// --------------------------------------------------------------------
	//	state machine
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( reset ) begin
			ff_vram_rdata			<= 8'd0;
			ff_vram_reading_ack		<= 1'b0;
		end
		else if( !enable ) begin
			// hold
		end
		else if( dot_state == 2'b01 ) begin
			if( ff_vram_reading_req != ff_vram_reading_ack ) begin
				ff_vram_rdata			<= w_vram_data;
				ff_vram_reading_ack		<= ~ff_vram_reading_ack;
			end
		end
	end

	always @( posedge clk ) begin
		if( reset ) begin
			ff_vdpcmd_vram_rdata		<= 8'd0;
			ff_vdpcmd_vram_read_ack		<= 1'b0;
			ff_vdpcmd_vram_reading_ack	<= 1'b0;
		end
		else if( !enable ) begin
			// hold
		end
		else if( dot_state == 2'b01 ) begin
			if( ff_vdpcmd_vram_reading_req != ff_vdpcmd_vram_reading_ack ) begin
				ff_vdpcmd_vram_rdata		<= w_vram_data;
				ff_vdpcmd_vram_read_ack		<= ~ff_vdpcmd_vram_read_ack;
				ff_vdpcmd_vram_reading_ack	<= ~ff_vdpcmd_vram_reading_ack;
			end
		end
	end

	always @( posedge clk ) begin: vram_access
		reg		[16:0]	ff_vram_access_address_pre;
		reg		[2:0]	ff_color_bus_state;

		if( reset ) begin
			ff_vram_address		<= 17'b11111111111111111;
			ff_vram_wdata		<= 8'd0;
			ff_vram_oe_n		<= 1'b1;
			ff_vram_we_n		<= 1'b1;

			ff_vram_reading_req <= 1'b0;

			ff_vram_rd_ack <= 1'b0;
			ff_vram_write_ack <= 1'b0;
			ff_vram_address_set_ack <= 1'b0;
			ff_vram_access_address <= 17'd0;

			ff_vdpcmd_vram_write_ack <= 1'b0;
			ff_vdpcmd_vram_reading_req <= 1'b0;
			ff_vdp_command_drive <= 1'b0;
		end
		else if( !enable ) begin
			// hold
		end
		else begin
			//
			// vram access arbiter.
			//
			// vramアクセスタイミングを、eight_dot_state によって制御している
			if( dot_state == 2'b10 ) begin
				if( p_prewindow && reg_r1_disp_on &&
					((eight_dot_state == 3'd0) || (eight_dot_state == 3'd1) || (eight_dot_state == 3'd2) ||
					 (eight_dot_state == 3'd3) || (eight_dot_state == 3'd4)) ) begin
					//	eight_dot_state が 0～4 で、表示中の場合
					ff_color_bus_state = state_draw;
				end
				else if( p_prewindow && reg_r1_disp_on && p_tx_vram_read_en ) begin
					//	eight_dot_state が 5～7 で、表示中で、テキストモードの場合
					ff_color_bus_state = state_draw;
				end
				else if( p_prewindow_x && p_prewindow_y_sp && p_sp_vram_accessing && (eight_dot_state == 3'd5) && !w_text_mode ) begin
					// for sprite y-testing
					ff_color_bus_state = state_sprt;
				end
				else if( !p_prewindow_x && p_prewindow_y_sp && p_sp_vram_accessing && !w_text_mode && (
							(eight_dot_state == 3'd0) || (eight_dot_state == 3'd1) || (eight_dot_state == 3'd2) ||
							(eight_dot_state == 3'd3) || (eight_dot_state == 3'd4) || (eight_dot_state == 3'd5)) ) begin
					// for sprite prepareing
					ff_color_bus_state = state_sprt;
				end
				else if( p_vram_write_req != ff_vram_write_ack ) begin
					// vram write request by cpu
					ff_color_bus_state = state_cpuw;
				end
				else if( p_vram_rd_req != ff_vram_rd_ack ) begin
					// vram read request by cpu
					ff_color_bus_state = state_cpur;
				end
				else begin
					// vdp command
					if( p_vdp_command_active ) begin
						if( p_vdpcmd_vram_write_req != ff_vdpcmd_vram_write_ack ) begin
							ff_color_bus_state = state_vdpw;
						end
						else if( p_vdpcmd_vram_read_req != ff_vdpcmd_vram_read_ack ) begin
							ff_color_bus_state = state_vdpr;
						end
						else begin
							ff_color_bus_state = state_vdps;
						end
					end
					else begin
						ff_color_bus_state = state_vdps;
					end
				end
			end
			else begin
				ff_color_bus_state = state_draw;
			end

			if( ff_color_bus_state == state_vdpw ||
				ff_color_bus_state == state_vdpr ||
				ff_color_bus_state == state_vdps ) begin
				ff_vdp_command_drive <= 1'b1;
			end
			else begin
				ff_vdp_command_drive <= 1'b0;
			end

			//
			// vram access address switch
			//
			if( ff_color_bus_state == state_cpuw ) begin
				// vram write by cpu
				// jp: graphic6,7ではvram上のアドレスと ram上のアドレスの関係が
				// jp: 他の画面モードと異るので注意
				if( p_vdp_mode_graphic6 || p_vdp_mode_graphic7 ) begin
					ff_vram_address <= { ff_vram_access_address[0], ff_vram_access_address[16:1] };
				end
				else begin
					ff_vram_address <= ff_vram_access_address;
				end
				if( p_vdp_mode_text1 || p_vdp_mode_text1q || p_vdp_mode_multi || p_vdp_mode_multiq || p_vdp_mode_graphic1 || p_vdp_mode_graphic2 ) begin
					ff_vram_access_address[13:0]	<= ff_vram_access_address[13:0] + 14'd1;
				end
				else begin
					ff_vram_access_address		<= ff_vram_access_address + 1;
				end
				ff_vram_wdata		<= p_vram_wdata_cpu;
				ff_vram_oe_n		<= 1'b1;
				ff_vram_we_n		<= 1'b0;
				ff_vram_write_ack	<= ~ff_vram_write_ack;
			end
			else if( ff_color_bus_state == state_cpur ) begin
				// vram read by cpu
				if( p_vram_addr_set_req != ff_vram_address_set_ack ) begin
					ff_vram_access_address_pre = p_vram_address_cpu;
					// clear vram address set request signal
					ff_vram_address_set_ack <= ~ff_vram_address_set_ack;
				end
				else begin
					ff_vram_access_address_pre = ff_vram_access_address;
				end

				// jp: graphic6,7ではvram上のアドレスと ram上のアドレスの関係が
				// jp: 他の画面モードと異るので注意
				if( p_vdp_mode_graphic6 || p_vdp_mode_graphic7 ) begin
					ff_vram_address <= { ff_vram_access_address_pre[0], ff_vram_access_address_pre[16:1] };
				end
				else begin
					ff_vram_address <= ff_vram_access_address_pre;
				end
				if( p_vdp_mode_text1 || p_vdp_mode_text1q || p_vdp_mode_multi || p_vdp_mode_multiq || p_vdp_mode_graphic1 || p_vdp_mode_graphic2 ) begin
					ff_vram_access_address[13:0] <= ff_vram_access_address_pre[13:0] + 1;
				end
				else begin
					ff_vram_access_address <= ff_vram_access_address_pre + 1;
				end
				ff_vram_wdata			<= 8'd0;
				ff_vram_oe_n			<= 1'b0;
				ff_vram_we_n			<= 1'b1;
				ff_vram_rd_ack			<= ~ff_vram_rd_ack;
				ff_vram_reading_req		<= ~ff_vram_reading_ack;
			end
			else if( ff_color_bus_state == state_vdpw ) begin
				// vram write by vdp command
				// vdp command write vram.
				// jp: Graphic6, 7 (Screen 7, 8) ではアドレスと ram上の位置が他の画面モードと
				// jp: 異るので注意
				if( p_vdp_mode_graphic6 || p_vdp_mode_graphic7 ) begin
					ff_vram_address	<= { p_vdpcmd_vram_address[0], p_vdpcmd_vram_address[16:1] };
				end
				else begin
					ff_vram_address	<= p_vdpcmd_vram_address;
				end
				ff_vram_wdata				<= p_vdpcmd_vram_wdata;
				ff_vram_oe_n				<= 1'b1;
				ff_vram_we_n				<= 1'b0;
				ff_vdpcmd_vram_write_ack	<= ~ff_vdpcmd_vram_write_ack;
			end
			else if( ff_color_bus_state == state_vdpr ) begin
				// vram read by vdp command
				// jp: Graphic6, 7 (Screen 7, 8) ではアドレスと ram上の位置が他の画面モードと
				// jp: 異るので注意
				if( p_vdp_mode_graphic6 || p_vdp_mode_graphic7 ) begin
					ff_vram_address	<= { p_vdpcmd_vram_address[0], p_vdpcmd_vram_address[16:1] };
				end
				else begin
					ff_vram_address	<= p_vdpcmd_vram_address;
				end
				ff_vram_wdata				<= 8'd0;
				ff_vram_oe_n				<= 1'b0;
				ff_vram_we_n				<= 1'b1;
				ff_vdpcmd_vram_reading_req	<= ~ff_vdpcmd_vram_reading_ack;
			end
			else if( ff_color_bus_state == state_sprt ) begin
				// vram read by sprite module
				ff_vram_address		<= p_vram_address_sprite;
				ff_vram_oe_n		<= 1'b0;
				ff_vram_we_n		<= 1'b1;
				ff_vram_wdata		<= 8'd0;
			end
			else begin
				// state_draw
				// vram read for screen image building
				if( dot_state == 2'b10 ) begin
					ff_vram_wdata	<= 8'd0;
					ff_vram_oe_n	<= 1'b0;
					ff_vram_we_n	<= 1'b1;
					if( w_text_mode ) begin
						ff_vram_address <= p_vram_address_text12;
					end
					else if( p_vdp_mode_graphic1 || p_vdp_mode_graphic2 || p_vdp_mode_graphic3 || p_vdp_mode_multi || p_vdp_mode_multiq ) begin
						ff_vram_address <= p_vram_address_graphic123m;
					end
					else if( p_vdp_mode_graphic4 || p_vdp_mode_graphic5 || p_vdp_mode_graphic6 || p_vdp_mode_graphic7 ) begin
						ff_vram_address <= p_vram_address_graphic4567;
					end
				end
				else begin
					ff_vram_wdata	<= 8'd0;
					ff_vram_oe_n	<= 1'b1;
					ff_vram_we_n	<= 1'b1;
				end

				if( (dot_state == 2'b11) && (p_vram_addr_set_req != ff_vram_address_set_ack) ) begin
					ff_vram_access_address	<= p_vram_address_cpu;
					ff_vram_address_set_ack	<= ~ff_vram_address_set_ack;
				end
			end
		end
	end
endmodule
