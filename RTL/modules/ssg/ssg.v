//
//	ssg.v
//	SSG (YM2149. AY-3-8910 Compatible Processor)
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

module ssg (
	input			clk,
	input			reset_n,
	input			enable,
	input			iorq_n,
	input			wr_n,
	input			rd_n,
	input	[1:0]	address,
	input	[7:0]	wdata,
	output	[7:0]	rdata,
	output			rdata_en,

	inout	[5:0]	ssg_ioa,
	output	[2:0]	ssg_iob,

	input			keyboard_type,		//	PortA bit6: Keyboard type  0: 50音配列, 1: JIS配列 
	input			cmt_read,			//	PortA bit7: CMT Read Signal
	output			kana_led,			//	PortB bit7: KANA LED  0: ON, 1: OFF

	output	[11:0]	sound_out
);
	reg		[7:0]	ff_rdata;
	reg				ff_rdata_en;

	reg		[7:0]	ff_port_a;
	reg		[7:0]	ff_port_b;

	reg		[4:0]	ff_ssg_state;
	reg		[3:0]	ff_ssg_register_ptr;

	reg		[11:0]	ff_ssg_ch_a_counter;
	reg		[11:0]	ff_ssg_ch_b_counter;
	reg		[11:0]	ff_ssg_ch_c_counter;
	reg				ff_ssg_ch_a_tone_wave;
	reg				ff_ssg_ch_b_tone_wave;
	reg				ff_ssg_ch_c_tone_wave;

	reg				ff_ssg_noise;
	reg		[4:0]	ff_ssg_noise_counter;
	reg		[17:0]	ff_ssg_noise_generator;

	wire			w_ssg_tone_disable;
	wire			w_ssg_noise_disable;
	wire			w_ssg_tone_wave;
	wire	[4:0]	w_ssg_volume;
	wire	[4:0]	w_ssg_ch_level;

	reg		[15:0]	ff_ssg_envelope_counter;
	reg		[5:0]	ff_ssg_envelope_ptr;
	reg		[4:0]	ff_ssg_envelope_volume;
	reg				ff_ssg_envelope_req;
	reg				ff_ssg_envelope_ack;

	reg		[11:0]	ff_ssg_ch_a_frequency;
	reg		[11:0]	ff_ssg_ch_b_frequency;
	reg		[11:0]	ff_ssg_ch_c_frequency;
	reg		[4:0]	ff_ssg_noise_frequency;
	reg		[5:0]	ff_ssg_ch_select;
	reg		[4:0]	ff_ssg_ch_a_volume;
	reg		[4:0]	ff_ssg_ch_b_volume;
	reg		[4:0]	ff_ssg_ch_c_volume;
	reg		[15:0]	ff_ssg_envelope_frequency;
	wire	[9:0]	w_out_level;
	reg				ff_hold;
	reg				ff_alternate;
	reg				ff_attack;
	reg				ff_continue;

	reg		[11:0]	ff_ssg_mixer;
	reg		[11:0]	ff_sound_out;
	reg				ff_wr_n;
	reg				ff_rd_n;
	wire			w_wr;
	wire			w_rd;

	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_wr_n	<= 1'b1;
			ff_rd_n	<= 1'b1;
		end
		else begin
			ff_wr_n	<= wr_n;
			ff_rd_n	<= rd_n;
		end
	end

	assign w_wr		= (ff_wr_n && !wr_n);
	assign w_rd		= (ff_rd_n && !rd_n);

	//--------------------------------------------------------------
	// Miscellaneous control / clock enable (divider)
	//--------------------------------------------------------------
	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_ssg_state <= 5'd0;
		end
		else if( enable ) begin
			ff_ssg_state <= ff_ssg_state - 5'd1;
		end
		else begin
			//	hold
		end
	end

	// -------------------------------------------------------------
	// Interface port
	// -------------------------------------------------------------
	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_port_a		<= 8'd0;
		end
		else begin
			ff_port_a[5:0]	<= ssg_ioa;
			ff_port_a[6]	<= keyboard_type;
			ff_port_a[7]	<= cmt_read;
		end
	end

	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_port_b <= 8'd0;
		end
		else if( !iorq_n && w_wr && address == 2'd1 && ff_ssg_register_ptr == 4'd15 ) begin
			ff_port_b <= wdata;
		end
		else begin
			//	hold
		end
	end

	assign rdata				= ff_rdata;
	assign rdata_en				= ff_rdata_en;

	assign ssg_iob[0]			= ff_port_b[4];
	assign ssg_iob[1]			= ff_port_b[5];
	assign ssg_iob[2]			= ff_port_b[6];
	assign kana_led				= ff_port_b[7];

	assign sound_out			= ff_sound_out;

	//--------------------------------------------------------------
	// Register read
	//--------------------------------------------------------------
	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_rdata_en <= 1'b0;
		end
		else if( !iorq_n && w_rd ) begin
			ff_rdata_en <= 1'b1;
		end
		else begin
			ff_rdata_en <= 1'b0;
		end
	end

	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_rdata <= 8'd0;
		end
		else if( !iorq_n && w_rd ) begin
			if( address == 2'd2 ) begin
				case( ff_ssg_register_ptr )
				4'd0:		ff_rdata <= ff_ssg_ch_a_frequency[7:0];
				4'd1:		ff_rdata <= { 4'd0, ff_ssg_ch_a_frequency[11:8] };
				4'd2:		ff_rdata <= ff_ssg_ch_b_frequency[7:0];
				4'd3:		ff_rdata <= { 4'd0, ff_ssg_ch_b_frequency[11:8] };
				4'd4:		ff_rdata <= ff_ssg_ch_c_frequency[7:0];
				4'd5:		ff_rdata <= { 4'd0, ff_ssg_ch_c_frequency[11:8] };
				4'd6:		ff_rdata <= { 3'd0, ff_ssg_noise_frequency };
				4'd7:		ff_rdata <= { 2'd2, ff_ssg_ch_select };
				4'd8:		ff_rdata <= { 3'd0, ff_ssg_ch_a_volume };
				4'd9:		ff_rdata <= { 3'd0, ff_ssg_ch_b_volume };
				4'd10:		ff_rdata <= { 3'd0, ff_ssg_ch_c_volume };
				4'd11:		ff_rdata <= ff_ssg_envelope_frequency[7:0];
				4'd12:		ff_rdata <= ff_ssg_envelope_frequency[15:8];
				4'd13:		ff_rdata <= { 4'd0, ff_continue, ff_attack, ff_alternate, ff_hold };
				4'd14:		ff_rdata <= ff_port_a;
				4'd15:		ff_rdata <= ff_port_b;
				default:	ff_rdata <= 8'hFF;
				endcase
			end
			else begin
				ff_rdata <= 8'hFF;
			end
		end
		else begin
			ff_rdata <= 1'b0;
		end
	end

	//--------------------------------------------------------------
	// Register write
	//--------------------------------------------------------------
	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_ssg_register_ptr			<= 4'd0;
			ff_ssg_ch_a_frequency		<= 12'hFFF;
			ff_ssg_ch_b_frequency		<= 12'hFFF;
			ff_ssg_ch_c_frequency		<= 12'hFFF;
			ff_ssg_noise_frequency		<= 5'd0;
			ff_ssg_ch_select			<= 6'd0;
			ff_ssg_ch_a_volume			<= 5'd0;
			ff_ssg_ch_b_volume			<= 5'd0;
			ff_ssg_ch_c_volume			<= 5'd0;
			ff_ssg_envelope_frequency	<= 16'hFFFF;
			ff_hold 					<= 1'b1;
			ff_alternate				<= 1'b1;
			ff_attack					<= 1'b1;
			ff_continue					<= 1'b1;
			ff_ssg_envelope_req			<= 1'b0;
		end
		else if( !iorq_n && w_wr && address == 2'd0 ) begin
			ff_ssg_register_ptr <= wdata[3:0];
		end
		else if( !iorq_n && w_wr && address == 2'd1 ) begin
			case( ff_ssg_register_ptr )
			4'd0:		ff_ssg_ch_a_frequency[7:0]		<= wdata;
			4'd1:		ff_ssg_ch_a_frequency[11:8]		<= wdata[3:0];
			4'd2:		ff_ssg_ch_b_frequency[7:0]		<= wdata;
			4'd3:		ff_ssg_ch_b_frequency[11:8]		<= wdata[3:0];
			4'd4:		ff_ssg_ch_c_frequency[7:0]		<= wdata;
			4'd5:		ff_ssg_ch_c_frequency[11:8]		<= wdata[3:0];
			4'd6:		ff_ssg_noise_frequency			<= wdata[4:0];
			4'd7:		ff_ssg_ch_select				<= wdata[5:0];
			4'd8:		ff_ssg_ch_a_volume				<= wdata[4:0];
			4'd9:		ff_ssg_ch_b_volume				<= wdata[4:0];
			4'd10:		ff_ssg_ch_c_volume				<= wdata[4:0];
			4'd11:		ff_ssg_envelope_frequency[7:0]	<= wdata;
			4'd12:		ff_ssg_envelope_frequency[15:8]	<= wdata;
			4'd13:
				begin
					ff_hold							<= wdata[0];
					ff_alternate					<= wdata[1];
					ff_attack						<= wdata[2];
					ff_continue						<= wdata[3];
					ff_ssg_envelope_req				<= ~ff_ssg_envelope_ack;
				end
			default:
				begin
					//	hold
				end
			endcase
		end
	end

	//--------------------------------------------------------------
	// Tone generator (Port A)
	//--------------------------------------------------------------
	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_ssg_ch_a_counter		<= 12'd0;
		end
		else if( enable && (ff_ssg_state[3:0] == 4'd0) ) begin
			if( ff_ssg_ch_a_counter != 12'd0) begin
				ff_ssg_ch_a_counter <= ff_ssg_ch_a_counter - 12'd1;
			end
			else if( ff_ssg_ch_a_frequency != 12'd0 ) begin
				ff_ssg_ch_a_counter <= ff_ssg_ch_a_frequency - 12'd1;
			end
		end
	end

	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_ssg_ch_a_tone_wave	<= 1'b0;
		end
		else if( enable && (ff_ssg_state[3:0] == 4'd0) ) begin
			if( ff_ssg_ch_a_counter == 12'd0 ) begin
				ff_ssg_ch_a_tone_wave <= ~ff_ssg_ch_a_tone_wave;
			end
			else begin
				//	hold
			end
		end
	end

	//--------------------------------------------------------------
	// Tone generator (Port B)
	//--------------------------------------------------------------
	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_ssg_ch_b_counter		<= 12'd0;
		end
		else if( enable && (ff_ssg_state[3:0] == 4'd0) ) begin
			if( ff_ssg_ch_b_counter != 12'd0) begin
				ff_ssg_ch_b_counter <= ff_ssg_ch_b_counter - 12'd1;
			end
			else if( ff_ssg_ch_b_frequency != 12'd0 ) begin
				ff_ssg_ch_b_counter <= ff_ssg_ch_b_frequency - 12'd1;
			end
		end
	end

	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_ssg_ch_b_tone_wave	<= 1'b0;
		end
		else if( enable && (ff_ssg_state[3:0] == 4'd0) ) begin
			if( ff_ssg_ch_b_counter == 12'd0 ) begin
				ff_ssg_ch_b_tone_wave <= ~ff_ssg_ch_b_tone_wave;
			end
			else begin
				//	hold
			end
		end
	end

	//--------------------------------------------------------------
	// Tone generator (Port C)
	//--------------------------------------------------------------
	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_ssg_ch_c_counter		<= 12'd0;
		end
		else if( enable && (ff_ssg_state[3:0] == 4'd0) ) begin
			if( ff_ssg_ch_c_counter != 12'd0 ) begin
				ff_ssg_ch_c_counter <= ff_ssg_ch_c_counter - 12'd1;
			end
			else if( ff_ssg_ch_c_frequency != 12'd0 ) begin
				ff_ssg_ch_c_counter <= ff_ssg_ch_c_frequency - 12'd1;
			end
		end
	end

	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_ssg_ch_c_tone_wave	<= 1'b0;
		end
		else if( enable && (ff_ssg_state[3:0] == 4'd0) ) begin
			if( ff_ssg_ch_c_counter == 12'd0 ) begin
				ff_ssg_ch_c_tone_wave <= ~ff_ssg_ch_c_tone_wave;
			end
			else begin
				//	hold
			end
		end
	end

	//--------------------------------------------------------------
	// Noise generator
	//--------------------------------------------------------------
	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_ssg_noise_counter <= 5'd0;
		end
		else begin
			if( enable && (ff_ssg_state == 5'd0) ) begin
				if( ff_ssg_noise_counter != 5'd0 ) begin
					ff_ssg_noise_counter <= ff_ssg_noise_counter - 1;
				end
				else if( ff_ssg_noise_frequency != 5'd0 ) begin
					ff_ssg_noise_counter <= ff_ssg_noise_frequency - 1;
				end
			end
		end
	end

	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_ssg_noise_generator	<= 18'd0;
		end
		else begin
			if( enable && (ff_ssg_state == 5'd0) ) begin
				if( ff_ssg_noise_counter == 5'd0 ) begin
					if( ff_ssg_noise_generator == 18'd0 ) begin
						ff_ssg_noise_generator[0]		<= 1'b1;
						ff_ssg_noise_generator[17:1]	<= ff_ssg_noise_generator[16:0];
					end
					else begin
						ff_ssg_noise_generator[0]		<= ff_ssg_noise_generator[16] ^ ff_ssg_noise_generator[13];
						ff_ssg_noise_generator[17:1]	<= ff_ssg_noise_generator[16:0];
					end
				end
			end
		end
	end

	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_ssg_noise <= 1'b0;
		end
		else if( enable ) begin
			ff_ssg_noise <= ff_ssg_noise_generator[17];
		end
		else begin
			//	hold
		end
	end

	//--------------------------------------------------------------
	// Envelope generator
	//--------------------------------------------------------------
	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_ssg_envelope_counter	<= 16'd0;
		end
		else if( enable && ff_ssg_state[3:0] == 4'd0 ) begin
			// Envelope period counter
			if( ff_ssg_envelope_counter != 16'd0 && ff_ssg_envelope_req == ff_ssg_envelope_ack ) begin
				ff_ssg_envelope_counter <= ff_ssg_envelope_counter - 1;
			end
			else if( ff_ssg_envelope_frequency != 16'd0) begin
				ff_ssg_envelope_counter <= ff_ssg_envelope_frequency - 1;
			end
		end
		else begin
			//	hold
		end
	end

	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_ssg_envelope_ptr		<= 6'b111111;
		end
		else if( enable && ff_ssg_state[3:0] == 4'd0 ) begin
			if( ff_ssg_envelope_req != ff_ssg_envelope_ack ) begin
				ff_ssg_envelope_ptr <= 6'b111111;
			end
			else if( ff_ssg_envelope_counter == 16'd0 && (ff_ssg_envelope_ptr[5] || (!ff_hold && ff_continue)) ) begin
				ff_ssg_envelope_ptr <= ff_ssg_envelope_ptr - 1;
			end
		end
		else begin
			//	hold
		end
	end

	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_ssg_envelope_volume	<= 5'd0;
		end
		else if( enable && ff_ssg_state[3:0] == 4'd0 ) begin
			if( !ff_ssg_envelope_ptr[5] && !ff_continue ) begin
				ff_ssg_envelope_volume <= 5'd0;
			end
			else if( ff_ssg_envelope_ptr[5] || !(ff_alternate ^ ff_hold) ) begin
				ff_ssg_envelope_volume <= ff_attack ? ~ff_ssg_envelope_ptr : ff_ssg_envelope_ptr;
			end
			else begin
				ff_ssg_envelope_volume <= ff_attack ? ff_ssg_envelope_ptr : ~ff_ssg_envelope_ptr;
			end
		end
		else begin
			//	hold
		end
	end

	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_ssg_envelope_ack		<= 1'b0;
		end
		else if( enable && ff_ssg_state[3:0] == 4'd0 ) begin
			ff_ssg_envelope_ack <= ff_ssg_envelope_req;
		end
		else begin
			//	hold
		end
	end

	//--------------------------------------------------------------
	// Mixer control
	//--------------------------------------------------------------
	function [9:0] func_out_level(
		input	[4:0]	w_ssg_ch_level
	);
		case( w_ssg_ch_level )
		5'd31:		func_out_level = 10'd1023;
		5'd30:		func_out_level = 10'd860;
		5'd29:		func_out_level = 10'd723;
		5'd28:		func_out_level = 10'd608;
		5'd27:		func_out_level = 10'd511;
		5'd26:		func_out_level = 10'd430;
		5'd25:		func_out_level = 10'd361;
		5'd24:		func_out_level = 10'd304;
		5'd23:		func_out_level = 10'd255;
		5'd22:		func_out_level = 10'd215;
		5'd21:		func_out_level = 10'd180;
		5'd20:		func_out_level = 10'd152;
		5'd19:		func_out_level = 10'd127;
		5'd18:		func_out_level = 10'd107;
		5'd17:		func_out_level = 10'd90;
		5'd16:		func_out_level = 10'd76;
		5'd15:		func_out_level = 10'd63;
		5'd14:		func_out_level = 10'd53;
		5'd13:		func_out_level = 10'd45;
		5'd12:		func_out_level = 10'd38;
		5'd11:		func_out_level = 10'd31;
		5'd10:		func_out_level = 10'd26;
		5'd9:		func_out_level = 10'd22;
		5'd8:		func_out_level = 10'd19;
		5'd7:		func_out_level = 10'd15;
		5'd6:		func_out_level = 10'd13;
		5'd5:		func_out_level = 10'd11;
		5'd4:		func_out_level = 10'd9;
		5'd3:		func_out_level = 10'd7;
		5'd2:		func_out_level = 10'd3;
		5'd1:		func_out_level = 10'd1;
		default:	func_out_level = 10'd0;
		endcase
	endfunction

	assign w_ssg_tone_disable	= ( ff_ssg_state[1:0] == 2'd3 ) ? ff_ssg_ch_select[0] : 
								  ( ff_ssg_state[1:0] == 2'd2 ) ? ff_ssg_ch_select[1] : 
								  ( ff_ssg_state[1:0] == 2'd1 ) ? ff_ssg_ch_select[2] : 1'b1;

	assign w_ssg_noise_disable	= ( ff_ssg_state[1:0] == 2'd3 ) ? ff_ssg_ch_select[3] : 
								  ( ff_ssg_state[1:0] == 2'd2 ) ? ff_ssg_ch_select[4] : 
								  ( ff_ssg_state[1:0] == 2'd1 ) ? ff_ssg_ch_select[5] : 1'b1;

	assign w_ssg_tone_wave		= ( ff_ssg_state[1:0] == 2'd3 ) ? ff_ssg_ch_a_tone_wave : 
								  ( ff_ssg_state[1:0] == 2'd2 ) ? ff_ssg_ch_b_tone_wave : 
								  ( ff_ssg_state[1:0] == 2'd1 ) ? ff_ssg_ch_c_tone_wave : 1'b1;

	assign w_ssg_volume			= ( ff_ssg_state[1:0] == 2'd3 ) ? ff_ssg_ch_a_volume : 
								  ( ff_ssg_state[1:0] == 2'd2 ) ? ff_ssg_ch_b_volume : 
								  ( ff_ssg_state[1:0] == 2'd1 ) ? ff_ssg_ch_c_volume : 5'd0;

	assign w_ssg_ch_level		= ( !( w_ssg_tone_disable  || w_ssg_tone_wave ) ) ? 4'd0 :
								  ( !( w_ssg_noise_disable || ff_ssg_noise    ) ) ? 4'd0 :
								  ( w_ssg_volume[4]                             ) ? ff_ssg_envelope_volume : { w_ssg_volume[3:0], 1'b1 };

	assign w_out_level			= func_out_level( w_ssg_ch_level );

	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_ssg_mixer	<= 12'd0;
		end
		else if( enable ) begin
			if( ff_ssg_state[1:0] == 2'd0 ) begin
				ff_ssg_mixer[11:4]	<= 8'd0;
			end
			else begin
				ff_ssg_mixer		<= { 2'b00, w_out_level } + ff_ssg_mixer;
			end
		end
	end

	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_sound_out	 <= 12'd0;
		end
		else if( enable ) begin
			if( ff_ssg_state[1:0] == 2'd0 ) begin
				ff_sound_out	<= ff_ssg_mixer;
			end
			else begin
				//	hold
			end
		end
	end
endmodule
