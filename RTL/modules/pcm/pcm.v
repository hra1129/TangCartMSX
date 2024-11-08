//
//	pcm.v
//	 MSXturboR PCM, PauseKey and R800 LED
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

module pcm(
	input					reset,
	input					clk,			//	85.90908MHz
	input					enable,			//	21.47727MHz
	input					req,
	output					ack,
	input					wrt,
	input		[ 1:0]		address,		//	A4h-A7h
	input		[ 7:0]		wdata,
	output		[ 7:0]		rdata,
	output					rdata_en,
	//	Pause Key
	input					pause_key,		//	PAUSE switch             0:OFF, 1:ON
	output					r800_mode_led,	//	R800 mode LED indicator  0:OFF, 1:ON
	output					pause_led,		//	PAUSE LED indicator      0:OFF, 1:ON
	//	PCM
	input		[ 7:0]		wave_in,		//	-128...127 (two's complement)
	output		[ 7:0]		wave_out		//	-128...127 (two's complement)
);
	wire	[ 7:0]	w_port_a4h;
	wire	[ 7:0]	w_port_a5h;
	wire	[ 7:0]	w_port_a7h;
	wire	[ 7:0]	w_wave_in;
	wire	[ 7:0]	w_wave_out;
	wire	[ 7:0]	w_sample_hold_in;
	wire	[ 7:0]	w_filter_in;
	wire	[ 7:0]	w_filter_out;
	reg		[ 7:0]	ff_sample_hold;
	reg		[ 7:0]	ff_wave_out;
	reg		[10:0]	ff_counter_low;		//	0...1363 (PreScaler by LFSR algorithm)
	wire			w_lfsr_d0;
	wire			w_counter_low_end;
	wire	[ 7:0]	w_active_buffer;
	reg		[ 1:0]	ff_counter;			//	2bit counter (63.5usec)
	reg				ff_adda;			//	ADDA buffer type select	  0: double buffer, 1: single buffer
	reg				ff_mute_off;		//	mute control			  0: mute, 1: active
	reg				ff_filter;			//	sample hold signal select 0: base signal, 1: filter signal
	reg				ff_sel;				//	filter input select		  0: D/A converter output, 1: wave_in
	reg				ff_sample;			//	sample hold				  0: disable, 1: enable
	reg		[ 7:0]	ff_da0;				//	wave data 1st
	reg		[ 7:0]	ff_da1;				//	wave data 2nd
	wire			w_comp;				//	result of comparison	  0: D/A out > sample hold, 1: D/A out < sample hold
	reg				ff_ack;
	reg				ff_r800_mode_led;	//	R800 mode LED indicator  0:OFF, 1:ON
	reg				ff_pause_led;		//	PAUSE LED indicator      0:OFF, 1:ON
	reg				ff_pause_key;
	reg		[ 7:0]	ff_rdata;
	reg				ff_rdata_en;

	//--------------------------------------------------------------
	// latch
	//--------------------------------------------------------------
	always @( posedge clk ) begin
		if( reset ) begin
			ff_da0 <= 8'd127;
		end
		else if( req && wrt && (address == 2'd0) ) begin
			//	port A4h (PCM)
			ff_da0 <= wdata;
		end
		else begin
			//	hold
		end
	end

	always @( posedge clk ) begin
		if( reset ) begin
			ff_da1 <= 8'd127;
		end
		else if( !enable ) begin
			//	hold
		end
		else if( w_counter_low_end ) begin
			ff_da1 <= ff_da0;
		end
		else begin
			//	hold
		end
	end

	assign w_active_buffer	= (ff_adda == 1'b0) ? ff_da1 : ff_da0;

	//--------------------------------------------------------------
	// base counter
	//--------------------------------------------------------------
	xnor(w_lfsr_d0,ff_counter_low[10],ff_counter_low[8]);
	assign w_counter_low_end = (ff_counter_low == 11'd67);	// LFSR count = 1364 clock ticks

	always @( posedge clk ) begin
		if( reset ) begin
			ff_counter_low <= 11'd0;
		end
		else if( !enable ) begin
			//	hold
		end
		else begin
			ff_counter_low <= w_counter_low_end ? 11'd0 : {ff_counter_low[9:0],w_lfsr_d0};
		end
	end

	always @( posedge clk ) begin
		if( reset ) begin
			ff_counter <= 2'd0;
		end
		else if( !enable ) begin
			//	hold
		end
		else if( w_counter_low_end ) begin
			ff_counter <= ff_counter + 2'd1;
		end
		else begin
			//	hold
		end
	end

	//--------------------------------------------------------------
	// sample hold
	//--------------------------------------------------------------
	always @( posedge clk ) begin
		if( reset ) begin
			ff_sample	<= 1'b0;
			ff_sel		<= 1'b0;
			ff_filter	<= 1'b0;
			ff_mute_off	<= 1'b0;
			ff_adda		<= 1'b0;
		end
		else begin
			if( req && wrt && (address == 2'd1) ) begin
				//	port A5h (PCM)
				ff_sample	<= wdata[4];
				ff_sel		<= wdata[3];
				ff_filter	<= wdata[2];
				ff_mute_off	<= wdata[1];
				ff_adda		<= wdata[0];
			end
			else begin
				//	hold
			end
		end
	end

	always @( posedge clk ) begin
		if( reset ) begin
			ff_sample_hold <= 8'd0;
		end
		else if( !ff_sample ) begin
			ff_sample_hold <= w_sample_hold_in;
		end
		else begin
			//	hold
		end
	end

	assign w_sample_hold_in = ( ff_filter ) ? ff_wave_out : w_filter_out;
	assign w_wave_in		= 8'd127 - wave_in;

	//--------------------------------------------------------------
	// digital filter (T.B.D.: currently through)
	//--------------------------------------------------------------
	assign w_filter_in		= ( ff_sel == 1'b0 ) ? ff_wave_out : w_wave_in;
	assign w_filter_out		= w_filter_in;

	//--------------------------------------------------------------
	// comparison for PCM recode
	//--------------------------------------------------------------
	assign w_comp			= (w_active_buffer > ff_sample_hold ) ? 1'b0 : 1'b1;

	//--------------------------------------------------------------
	// LED indicator
	//--------------------------------------------------------------
	always @( posedge clk ) begin
		if( reset ) begin
			ff_r800_mode_led	<= 1'b0;
			ff_pause_led		<= 1'b0;
		end
		else if( req && wrt && (address == 2'd1) ) begin
			ff_r800_mode_led	<= wdata[7];
			ff_pause_led		<= wdata[0];
		end
		else begin
			//	hold
		end
	end

	assign r800_mode_led	= ff_r800_mode_led;
	assign pause_led		= ff_pause_led;

	//--------------------------------------------------------------
	// PCM register read
	//--------------------------------------------------------------
	assign w_port_a4h		= { 6'd0, ff_counter };
	assign w_port_a5h		= { w_comp, 2'd0, ff_sample, ff_sel, ff_filter, ff_mute_off, ff_adda };
	assign w_port_a7h		= { 7'd0, ff_pause_key };

	always @( posedge clk ) begin
		if( reset ) begin
			ff_rdata	<= 8'd0;
			ff_rdata_en	<= 1'b0;
		end
		else if( req && !wrt ) begin
			ff_rdata_en	<= 1'b1;
			case( address )
			2'd0:		ff_rdata <= w_port_a4h;
			2'd1:		ff_rdata <= w_port_a5h;
			2'd3:		ff_rdata <= w_port_a7h;
			default:	ff_rdata <= 8'd0;
			endcase
		end
		else begin
			ff_rdata <= 8'd0;
		end
	end

	assign rdata	= ff_rdata;
	assign rdata_en	= ff_rdata_en;

	//--------------------------------------------------------------
	// PCM data output
	//--------------------------------------------------------------
	assign w_wave_out	= 8'd127 - w_active_buffer;

	always @( posedge clk ) begin
		if( reset ) begin
			ff_wave_out <= 8'd0;
		end
		else if( !enable ) begin
			//	hold
		end
		else begin
			ff_wave_out <= w_wave_out;
		end
	end

	always @( posedge clk ) begin
		if( reset ) begin
			ff_ack <= 1'b0;
		end
		else if( ff_ack ) begin
			ff_ack <= 1'b0;
		end
		else if( req ) begin
			ff_ack <= 1'b1;
		end
		else begin
			//	hold
		end
	end

	assign wave_out		= (ff_mute_off == 1'b0 ) ? 8'd0 : w_filter_out; //	range: -128...127
	assign ack			= ff_ack;
endmodule
