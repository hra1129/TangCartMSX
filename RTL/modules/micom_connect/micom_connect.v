//
//	micom_connect.v
//	 micom_connect module
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
//	SPI Slave になって、FPGA外部のマイコンと通信するモジュール。
//-----------------------------------------------------------------------------

module micom_connect (
	input			reset_n,
	input			clk,			//	85.90908MHz
	input			spi_cs_n,
	input			spi_clk,
	input			spi_mosi,
	output			spi_miso,
	//	Reset
	output			msx_reset_n,
	output			cpu_freeze,
	//	keyboard I/F
	input	[3:0]	matrix_y,
	output	[7:0]	matrix_x,
	//	Memory write I/F
	output	[22:0]	address,
	output			req_n,
	output	[7:0]	wdata,
	//	Status
	input			sdram_busy,
	input			keyboard_caps_led_off,
	input			keyboard_kana_led_off,
	output			keyboard_type,
	output	[2:0]	megarom1_mode,
	output	[2:0]	megarom2_mode
);
	localparam		st_idle			= 3'd0;
	localparam		st_command		= 3'd1;
	localparam		st_operand1		= 3'd2;
	localparam		st_operand2		= 3'd3;
	localparam		st_data			= 3'd4;
	localparam		st_exec			= 3'd5;

	localparam		sst_idle		= 2'd0;
	localparam		sst_clk_low		= 2'd1;
	localparam		sst_clk_hi		= 2'd2;
	localparam		sst_byte_end	= 2'd3;

	localparam		dt_signature	= 8'hA5;

	reg				ff_spi_cs_n;
	reg				ff_spi_clk;
	reg				ff_spi_mosi;
	reg		[2:0]	ff_state;
	reg		[1:0]	ff_serial_state;
	reg		[2:0]	ff_bit;
	reg		[7:0]	ff_recv_data;
	reg		[7:0]	ff_send_data;
	reg		[7:0]	ff_command;
	reg		[13:0]	ff_address;
	reg				ff_address_msb;
	reg				ff_msx_reset_n;
	reg				ff_cpu_freeze;
	reg		[7:0]	ff_key_matrix [0:15];
	reg		[7:0]	ff_operand1;
	reg		[7:0]	ff_matrix_x;
	reg		[2:0]	ff_megarom1_mode;
	reg		[2:0]	ff_megarom2_mode;

	// --------------------------------------------------------------------
	//	flip-flop to receive
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		ff_spi_cs_n		<= spi_cs_n;
		ff_spi_clk		<= spi_clk;
		ff_spi_mosi		<= spi_mosi;
	end

	// --------------------------------------------------------------------
	//	Serial state
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_serial_state <= sst_idle;
		end
		else begin
			case( ff_serial_state )
			sst_idle:
				if( ff_spi_cs_n == 1'b0 ) begin
					ff_serial_state <= sst_clk_low;
				end
			sst_clk_low:
				if( ff_spi_cs_n == 1'b1 ) begin
					ff_serial_state <= sst_idle;
				end
				else if( ff_spi_clk == 1'b1 ) begin
					ff_serial_state <= sst_clk_hi;
				end
			sst_clk_hi:
				if( ff_spi_cs_n == 1'b1 ) begin
					ff_serial_state <= sst_idle;
				end
				else if( ff_spi_clk == 1'b0 ) begin
					if( ff_bit == 3'd7 ) begin
						ff_serial_state <= sst_byte_end;
					end
					else begin
						ff_serial_state <= sst_clk_low;
					end
				end
			sst_byte_end:
				if( ff_spi_cs_n == 1'b1 ) begin
					ff_serial_state <= sst_idle;
				end
				else begin
					ff_serial_state <= sst_clk_low;
				end
			default:
				ff_serial_state <= sst_idle;
			endcase
		end
	end

	// --------------------------------------------------------------------
	//	bit state
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_bit <= 3'd7;
		end
		else if( ff_bit != 3'd7 && ff_spi_cs_n == 1'b1 ) begin
			ff_bit <= 3'd7;
		end
		else if( ff_serial_state == sst_clk_low && ff_spi_clk == 1'b1 ) begin
			ff_bit <= ff_bit + 3'd1;
		end
		else begin
			//	hold
		end
	end

	// --------------------------------------------------------------------
	//	Receive byte
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_recv_data <= 8'd0;
		end
		else if( ff_serial_state == sst_clk_low && ff_spi_clk == 1'b1 ) begin
			ff_recv_data <= { ff_recv_data[6:0], ff_spi_mosi };
		end
		else begin
			//	hold
		end
	end

	// --------------------------------------------------------------------
	//	Send byte
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_send_data <= 8'd0;
		end
		else if( ff_state == st_idle && ff_spi_cs_n == 1'b1 ) begin
			ff_send_data <= dt_signature;
		end
		else if( ff_state == st_command && ff_serial_state == sst_byte_end && ff_recv_data == 8'h05 ) begin
			ff_send_data <= { 5'd0, keyboard_kana_led_off, keyboard_caps_led_off, sdram_busy };
		end
		else if( ff_serial_state == sst_clk_hi && ff_spi_clk == 1'b0 ) begin
			ff_send_data <= { ff_send_data[6:0], ff_send_data[7] };
		end
		else begin
			//	hold
		end
	end

	assign spi_miso		= ff_send_data[7];

	// --------------------------------------------------------------------
	//	Command state
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_state <= st_idle;
		end
		else if( ff_state != st_idle && ff_spi_cs_n == 1'b1 ) begin
			ff_state <= st_idle;
		end
		else begin
			case( ff_state )
			st_idle:
				if( ff_spi_cs_n == 1'b0 ) begin
					ff_state <= st_command;
				end
			st_command:
				if( ff_serial_state == sst_byte_end ) begin
					if( ff_recv_data == 8'h00 || ff_recv_data == 8'h01 || ff_recv_data == 8'h02 || ff_recv_data == 8'h06 ) begin
						ff_state <= st_exec;
					end
					else begin
						ff_state <= st_operand1;
					end
				end
			st_operand1:
				if( ff_serial_state == sst_byte_end ) begin
					if( ff_command == 8'h05 || ff_command == 8'h07 || ff_command == 8'h08 || ff_command == 8'h09 ) begin
						ff_state <= st_exec;
					end
					else if( ff_command == 8'h04 ) begin
						ff_state <= st_data;
					end
					else begin
						ff_state <= st_operand2;
					end
				end
			st_operand2:
				if( ff_serial_state == sst_byte_end ) begin
					ff_state <= st_exec;
				end
			st_data:
				if( ff_serial_state == sst_byte_end ) begin
					if( ff_address == 14'd16383 ) begin
						ff_state <= st_exec;
					end
					else begin
						//	hold
					end
				end
			st_exec:
				ff_state <= st_idle;
			default:
				ff_state <= st_idle;
			endcase
		end
	end

	// --------------------------------------------------------------------
	//	Command latch
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_command <= 8'd0;
		end
		else if( ff_state == st_command ) begin
			if( ff_serial_state == sst_byte_end ) begin
				ff_command <= ff_recv_data;
			end
			else begin
				//	hold
			end
		end
	end

	// --------------------------------------------------------------------
	//	Operand1 latch
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_operand1 <= 8'd0;
		end
		else if( ff_state == st_operand1 ) begin
			if( ff_serial_state == sst_byte_end ) begin
				ff_operand1 <= ff_recv_data;
			end
			else begin
				//	hold
			end
		end
	end

	// --------------------------------------------------------------------
	//	MSX Reset Signal
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_msx_reset_n <= 1'b0;
		end
		else if( ff_state == st_exec ) begin
			if(      ff_command == 8'h01 ) begin
				ff_msx_reset_n <= 1'b0;
			end
			else if( ff_command == 8'h02 ) begin
				ff_msx_reset_n <= 1'b1;
			end
			else begin
				//	hold
			end
		end
		else begin
			//	hold
		end
	end

	assign msx_reset_n	= ff_msx_reset_n;

	// --------------------------------------------------------------------
	//	CPU Freeze
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_cpu_freeze <= 1'b1;
		end
		else if( ff_state == st_exec ) begin
			if(      ff_command == 8'h06 ) begin
				ff_cpu_freeze <= 1'b0;
			end
			else begin
				//	hold
			end
		end
		else begin
			//	hold
		end
	end

	assign cpu_freeze	= ff_cpu_freeze;

	// --------------------------------------------------------------------
	//	Key matrix
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( ff_state == st_operand2 ) begin
			if( ff_serial_state == sst_byte_end ) begin
				ff_key_matrix[ ff_operand1[3:0] ] <= ff_recv_data;
			end
			else begin
				//	hold
			end
		end
		else begin
			//	hold
		end
	end

	always @( posedge clk ) begin
		ff_matrix_x	<= ff_key_matrix[ matrix_y ];
	end

	assign matrix_x	= ff_matrix_x;

	// --------------------------------------------------------------------
	//	Memory MSB
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_address_msb <= 1'b0;
		end
		else if( ff_state == st_exec ) begin
			if( ff_command == 8'h07 ) begin
				ff_address_msb <= ff_recv_data[0];
			end
			else begin
				//	hold
			end
		end
		else begin
			//	hold
		end
	end

	// --------------------------------------------------------------------
	//	Memory I/F
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_address	<= 14'd0;
		end
		else if( ff_state == st_operand1 ) begin
			if( ff_serial_state == sst_byte_end ) begin
				ff_address	<= 14'd0;
			end
		end
		else if( ff_state == st_data ) begin
			if( ff_serial_state == sst_byte_end ) begin
				ff_address	<= ff_address + 14'd1;
			end
		end
		else begin
			//	hold
		end
	end

	// --------------------------------------------------------------------
	//	MegaROM mode
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_megarom1_mode <= 3'b0;
			ff_megarom2_mode <= 3'b0;
		end
		else if( ff_state == st_exec ) begin
			if(      ff_command == 8'h08 ) begin
				ff_megarom1_mode <= ff_recv_data[2:0];
			end
			else if( ff_command == 8'h09 ) begin
				ff_megarom2_mode <= ff_recv_data[2:0];
			end
			else begin
				//	hold
			end
		end
		else begin
			//	hold
		end
	end

	assign address			= { ff_address_msb, ff_operand1, ff_address };
	assign req_n			= !((ff_state == st_data) && (ff_serial_state == sst_byte_end));
	assign wdata			= ff_recv_data;
	assign keyboard_type	= 1'b0;
	assign megarom1_mode	= ff_megarom1_mode;
	assign megarom2_mode	= ff_megarom2_mode;
endmodule
