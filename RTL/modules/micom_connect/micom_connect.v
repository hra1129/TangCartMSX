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
	//	keyboard I/F
	input	[3:0]	matrix_y,
	output	[7:0]	matrix_x,
	//	Memory write I/F
	output	[21:0]	address,
	output			req,
	output	[7:0]	wdata,
	//	Status
	input			sdram_busy
);
	localparam		st_initial		= 4'd0;
	localparam		st_idle			= 4'd1;
	localparam		st_command		= 4'd2;

	localparam		sst_idle		= 2'd0;
	localparam		sst_clk_low		= 2'd1;
	localparam		sst_clk_hi		= 2'd2;
	localparam		sst_byte_end	= 2'd3;

	localparam		dt_signature	= 8'hA5;

	reg		[3:0]	ff_state;
	reg		[1:0]	ff_serial_state;
	reg		[2:0]	ff_bit;
	reg		[7:0]	ff_recv_data;
	reg		[7:0]	ff_send_data;
	reg		[7:0]	ff_data;
	reg				ff_connect_req;
	reg		[7:0]	ff_command;
	reg				ff_do_command;
	wire			w_command_req;
	reg				ff_command_end;
	reg		[14:0]	ff_address;
	wire	[14:0]	w_address;
	reg				ff_msx_reset_n;
	reg		[7:0]	ff_key_matrix [0:15];
	reg		[3:0]	ff_y;
	reg		[7:0]	ff_bank;
	reg		[7:0]	ff_wdata;
	reg				ff_req;

	// --------------------------------------------------------------------
	//	State
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_state		<= st_initial;
			ff_data			<= dt_signature;
			ff_connect_req	<= 1'b0;
		end
		else if( spi_cs_n ) begin
			ff_state		<= st_idle;
		end
		else begin
			case( ff_state )
			st_initial:
				begin
					ff_data			<= dt_signature;
				end
			st_idle:
				begin
					ff_state		<= st_command;
					ff_bit			<= 3'd0;
					ff_connect_req	<= 1'b1;
				end
			st_command:
				begin
					ff_connect_req	<= 1'b0;
					if( w_command_req ) begin
						ff_state	<= st_idle;
						if( !ff_do_command && ff_recv_data == 8'h05 ) begin
							ff_data			<= { 7'd0, sdram_busy };
						end
						else begin
							ff_data			<= dt_signature;
						end
					end
				end
			default:
				ff_state	<= st_idle;
			endcase
		end
	end

	// --------------------------------------------------------------------
	//	Serial state
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_serial_state	<= sst_idle;
			ff_recv_data	<= 8'd0;
			ff_send_data	<= 8'd0;
		end
		else if( spi_cs_n ) begin
			ff_serial_state <= sst_idle;
			ff_recv_data	<= 8'd0;
		end
		else begin
			case( ff_serial_state )
			sst_idle:
				if( ff_connect_req ) begin
					ff_serial_state <= sst_clk_low;
					ff_bit			<= 3'd0;
					ff_send_data	<= ff_data;
				end
			sst_clk_low:
				if( spi_clk ) begin
					ff_serial_state <= sst_clk_hi;
					ff_recv_data	<= { ff_recv_data[6:0], spi_mosi };
				end
			sst_clk_hi:
				if( !spi_clk ) begin
					ff_send_data	<= { ff_send_data[6:0], 1'b0 };
					ff_bit			<= ff_bit + 3'd1;
					if( ff_bit == 3'd7 ) begin
						ff_serial_state	<= sst_byte_end;
					end
					else begin
						ff_serial_state	<= sst_clk_low;
					end
				end
			default:
				ff_serial_state	<= sst_idle;
			endcase
		end
	end

	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_address		<= 15'd0;
		end
		else if( spi_cs_n ) begin
			ff_address		<= 15'd0;
		end
		else if( ff_command_end ) begin
			ff_address		<= 15'd0;
		end
		else if( w_command_req ) begin
			ff_address		<= ff_address + 15'd1;
		end
		else begin
			//	hold
		end
	end

	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_command		<= 8'd0;
			ff_do_command	<= 1'b0;
		end
		else if( spi_cs_n ) begin
			ff_command		<= 8'd0;
			ff_do_command	<= 1'b0;
		end
		else if( ff_command_end ) begin
			ff_command		<= 8'd0;
			ff_do_command	<= 1'b0;
		end
		else if( !ff_do_command && w_command_req ) begin
			ff_command		<= ff_recv_data;
			ff_do_command	<= 1'b1;
		end
		else begin
			//	hold
		end
	end

	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_command_end <= 1'b0;
		end
		else if( ff_do_command ) begin
			case( ff_command )
			8'h03:
				if( ff_address[7:0] == 8'h02 ) begin
					ff_command_end <= w_command_req;
				end
			8'h04:
				if( ff_address == 15'd16385 ) begin
					ff_command_end <= w_command_req;
				end
			8'h03:
				if( ff_address[7:0] == 8'h01 ) begin
					ff_command_end <= w_command_req;
				end
			default:
				ff_command_end <= w_command_req;
			endcase
		end
		else begin
			ff_command_end <= 1'b0;
		end
	end

	assign w_command_req	= (ff_serial_state == sst_byte_end);
	assign spi_miso			= ff_send_data[7];

	// --------------------------------------------------------------------
	//	MSX Reset Signal
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_msx_reset_n <= 1'b0;
		end
		else if( ff_do_command ) begin
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
	//	Key matrix
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_y <= 4'd0;
		end
		else if( ff_do_command && w_command_req ) begin
			if( ff_command == 8'h03 ) begin
				if(      ff_address[7:0] == 8'h1 ) begin
					ff_y <= ff_recv_data[3:0];
				end
				else if( ff_address[7:0] == 8'h2 ) begin
					ff_key_matrix[ ff_y ] <= ff_recv_data;
				end
			end
			else begin
				//	hold
			end
		end
		else begin
			//	hold
		end
	end

	assign matrix_x	= ff_key_matrix[ matrix_y ];

	// --------------------------------------------------------------------
	//	Memory I/F
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_bank		<= 8'd0;
			ff_req		<= 1'b0;
			ff_wdata	<= 8'h00;
		end
		else if( ff_do_command && w_command_req ) begin
			if( ff_command == 8'h04 ) begin
				if(      ff_address[7:0] == 8'h1 ) begin
					ff_bank		<= ff_recv_data;
				end
				else begin
					ff_wdata	<= ff_recv_data;
					ff_req		<= 1'b1;
				end
			end
			else begin
				//	hold
			end
		end
		else begin
			ff_req		<= 1'b0;
		end
	end

	assign w_address	= ff_address - 15'd3;
	assign address		= { ff_bank, w_address[13:0] };
	assign wdata		= ff_wdata;
	assign req			= ff_req;
endmodule
