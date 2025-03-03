//
// ip_sdram.v
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

module ip_sdram #(
	parameter		FREQ = 64'd343_636_320	//	343.636320MHz
) (
	input				reset_n,
	input				clk,
	input				clk_n,
	output				sdram_init_busy,
	output				sdram_busy,
	input				cpu_freeze,

	input				mreq_n,
	input	[26:0]		address,		//	128MB: [26:24]=BANK, [23:11]=ROW, [10:0]=COLUMN
	input				wr_n,
	input				rd_n,
	input				rfsh_n,
	input	[ 7:0]		wdata,
	output	[ 7:0]		rdata,
	output				rdata_en,

	// ddrAM ports
	output				ddr3_rst_n,
	output				ddr3_clk,
	output				ddr3_clk_n,
	output				ddr3_cke,
	output				ddr3_cs_n,		// chip select
	output				ddr3_ras_n,		// row address select
	output				ddr3_cas_n,		// columns address select
	output				ddr3_we_n,		// write enable
	inout	[15:0]		ddr3_dq,		// 32 bit bidirectional data bus
	output	[12:0]		ddr3_addr,		// 13 bit multiplexed address bus
	output	[ 2:0]		ddr3_ba,		// eight banks
	inout	[ 1:0]		ddr3_dm_tdqs,	// 
	inout	[ 1:0]		ddr3_dqs,		// 
	inout	[ 1:0]		ddr3_dqs_n,		// 
	input	[ 1:0]		ddr3_tdqs_n,	// 
	input				ddr3_odt
);
	//	ddrAM commands
	localparam	[3:0]	c_ddr_command_mode_register_set			= 4'b0000;
	localparam	[3:0]	c_ddr_command_zqcl						= 4'b0110;

	localparam	[3:0]	c_ddr_command_refresh					= 4'b0001;
	localparam	[3:0]	c_ddr_command_precharge_all				= 4'b0010;
	localparam	[3:0]	c_ddr_command_activate					= 4'b0011;
	localparam	[3:0]	c_ddr_command_write						= 4'b0100;
	localparam	[3:0]	c_ddr_command_read						= 4'b0101;
	localparam	[3:0]	c_ddr_command_burst_stop				= 4'b0110;
	localparam	[3:0]	c_ddr_command_no_operation				= 4'b0111;
	localparam	[3:0]	c_ddr_command_deselect					= 4'b1111;

	//	State value
	localparam	[5:0]	c_init_state_reset_on					= 6'd0;
	localparam	[5:0]	c_init_state_reset_on_wait				= 6'd1;
	localparam	[5:0]	c_init_state_reset_off					= 6'd2;
	localparam	[5:0]	c_init_state_reset_off_wait				= 6'd3;
	localparam	[5:0]	c_init_state_nop						= 6'd4;
	localparam	[5:0]	c_init_state_nop_wait					= 6'd5;
	localparam	[5:0]	c_init_state_mode_register_set2			= 6'd6;
	localparam	[5:0]	c_init_state_mode_register_set2_wait	= 6'd7;
	localparam	[5:0]	c_init_state_mode_register_set3			= 6'd8;
	localparam	[5:0]	c_init_state_mode_register_set3_wait	= 6'd9;
	localparam	[5:0]	c_init_state_mode_register_set1			= 6'd10;
	localparam	[5:0]	c_init_state_mode_register_set1_wait	= 6'd11;
	localparam	[5:0]	c_init_state_mode_register_set0			= 6'd12;
	localparam	[5:0]	c_init_state_mode_register_set0_wait	= 6'd13;
	localparam	[5:0]	c_init_state_zqcl						= 6'd14;
	localparam	[5:0]	c_init_state_zqcl_wait					= 6'd15;
	localparam	[5:0]	c_init_state_precharge_all				= 6'd16;
	localparam	[5:0]	c_init_state_precharge_all_wait			= 6'd17;
	localparam	[5:0]	c_init_state_active0					= 6'd18;
	localparam	[5:0]	c_init_state_active0_wait				= 6'd19;
	localparam	[5:0]	c_init_state_active1					= 6'd20;
	localparam	[5:0]	c_init_state_active1_wait				= 6'd21;
	localparam	[5:0]	c_init_state_active2					= 6'd22;
	localparam	[5:0]	c_init_state_active2_wait				= 6'd23;
	localparam	[5:0]	c_init_state_active3					= 6'd24;
	localparam	[5:0]	c_init_state_active3_wait				= 6'd25;
	localparam	[5:0]	c_init_state_active4					= 6'd26;
	localparam	[5:0]	c_init_state_active4_wait				= 6'd27;
	localparam	[5:0]	c_init_state_active5					= 6'd28;
	localparam	[5:0]	c_init_state_active5_wait				= 6'd29;
	localparam	[5:0]	c_init_state_active6					= 6'd30;
	localparam	[5:0]	c_init_state_active6_wait				= 6'd31;
	localparam	[5:0]	c_init_state_active7					= 6'd32;
	localparam	[5:0]	c_init_state_active7_wait				= 6'd33;
	localparam	[5:0]	c_main_state_ready						= 6'd34;
	localparam	[5:0]	c_main_state_activate					= 6'd35;
	localparam	[5:0]	c_main_state_nop1						= 6'd36;
	localparam	[5:0]	c_main_state_nop2						= 6'd37;
	localparam	[5:0]	c_main_state_read_or_write				= 6'd38;
	localparam	[5:0]	c_main_state_nop3						= 6'd39;
	localparam	[5:0]	c_main_state_nop4						= 6'd40;
	localparam	[5:0]	c_main_state_data_fetch					= 6'd41;
	localparam	[5:0]	c_main_state_finish						= 6'd42;
	localparam	[5:0]	c_main_state_nop5						= 6'd43;
	localparam	[5:0]	c_main_state_nop6						= 6'd44;
	localparam	[5:0]	c_main_state_nop7						= 6'd45;
	localparam	[5:0]	c_main_state_nop8						= 6'd46;
	localparam	[5:0]	c_main_state_finish2					= 6'd47;

	localparam CLOCK_TIME		= 64'd1_000_000_000_000 / FREQ;		// 1sec = 1_000_000_000_000psec
	localparam TIMER_COUNT		= 64'd510_000_000 / CLOCK_TIME;		// clock
	localparam RESET_COUNT		= 64'd210_000_000 / CLOCK_TIME;		// clock
	localparam REFRESH_COUNT	= 64'd15_000_000 / CLOCK_TIME;		// clock
	localparam REFRESH_NONE		= 64'd10_000_000 / CLOCK_TIME;		// clock
	localparam TIMER_BITS		= $clog2(TIMER_COUNT + 1);
	localparam REFRESH_BITS		= $clog2(REFRESH_COUNT + 1);

	reg		[ 5:0]				ff_main_state;
	reg		[TIMER_BITS-1:0]	ff_main_timer;
	reg		[ 7:0]				ff_no_refresh;
	wire						w_end_of_main_timer;

	reg							ff_ddr_rst_n			= 1'b0;
	reg							ff_ddr_cke				= 1'b0;
	reg							ff_ddr_odt;
	reg							ff_ddr_ready;
	reg							ff_do_main_state;
	reg							ff_do_refresh;

	reg		[ 3:0]				ff_ddr_command			= c_ddr_command_no_operation;
	reg		[ 2:0]				ff_ddr_ba;
	reg		[12:0]				ff_ddr_address			= 13'h0000;
	reg		[31:0]				ff_ddr_write_data		= 32'd0;
	reg		[ 1:0]				ff_ddr_dq_mask			= 2'b11;
	reg		[ 7:0]				ff_ddr_read_data		= 8'd0;
	reg							ff_ddr_read_data_en		= 1'b0;
	reg							ff_req;
	reg							ff_rd_n;
	reg							ff_wr_n;
	reg							ff_rd_wr_accept;
	reg							ff_rfsh_accept;
	reg							ff_is_write;
	reg		[ 7:0]				ff_wdata;
	reg		[22:0]				ff_address;
	wire						w_busy;
	wire						w_has_request_latch;
	reg		[12:0]				ff_bank_row [0:7];

	// --------------------------------------------------------------------
	//	Request latch
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_rd_n	<= 1'b1;
		end
		else if( !ff_rd_wr_accept && !mreq_n && !rd_n && !w_has_request_latch ) begin
			ff_rd_n	<= 1'b0;
		end
		else if( ff_ddr_read_data_en ) begin
			ff_rd_n	<= 1'b1;
		end
	end

	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_wr_n		<= 1'b1;
			ff_wdata	<= 8'd0;
		end
		else if( !ff_rd_wr_accept && !mreq_n && !wr_n && !w_has_request_latch ) begin
			ff_wr_n		<= 1'b0;
			ff_wdata	<= wdata;
		end
		else if( ff_main_state == c_main_state_data_fetch ) begin
			ff_wr_n		<= 1'b1;
		end
	end

	assign w_has_request_latch	= (!ff_rd_n) | (!ff_wr_n);

	always @( posedge clk_n ) begin
		if( !reset_n ) begin
			ff_address <= 23'd0;
		end
		else if( !ff_rd_wr_accept && !mreq_n && !rd_n && !w_has_request_latch ) begin
			ff_address <= address;
		end
		else if( !ff_rd_wr_accept && !mreq_n && !wr_n && !w_has_request_latch ) begin
			ff_address <= address;
		end
		else begin
			//	hold
		end
	end

	// --------------------------------------------------------------------
	//	Request
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_req			<= 1'b0;
			ff_is_write		<= 1'b0;
			ff_do_refresh	<= 1'b0;
		end
		else if( ff_req ) begin
			if( ff_main_state == c_main_state_finish || ff_main_state == c_main_state_finish2 ) begin
				ff_req			<= 1'b0;
				ff_is_write		<= 1'b0;
				ff_do_refresh	<= 1'b0;
			end
		end
		else if( ff_main_state == c_main_state_activate ) begin
			if( (!ff_rfsh_accept && !rfsh_n) || (cpu_freeze && ff_no_refresh == 8'hFF) ) begin
				ff_req			<= 1'b1;
				ff_do_refresh	<= 1'b1;
			end
			else if( !ff_rd_wr_accept && (!ff_rd_n || (!mreq_n && !rd_n)) ) begin
				ff_req			<= 1'b1;
				ff_is_write		<= 1'b0;
			end
			else if( !ff_rd_wr_accept && (!ff_wr_n || (!mreq_n && !wr_n)) ) begin
				ff_req			<= 1'b1;
				ff_is_write		<= 1'b1;
			end
		end
	end

	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_rd_wr_accept <= 1'b0;
		end
		else if( ff_rd_wr_accept && (ff_main_state == c_main_state_data_fetch) ) begin
			ff_rd_wr_accept <= 1'b0;
		end
		else if( ff_main_state == c_main_state_activate ) begin
			if( (!ff_rfsh_accept && !rfsh_n) || (cpu_freeze && ff_no_refresh == 8'hFF) ) begin
				//	hold
			end
			else if( !ff_rd_wr_accept && !ff_rd_n ) begin
				ff_rd_wr_accept <= 1'b1;
			end
			else if( !ff_rd_wr_accept && !ff_wr_n ) begin
				ff_rd_wr_accept <= 1'b1;
			end
			else begin
				//	hold
			end
		end
	end

	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_rfsh_accept <= 1'b0;
		end
		else if( ff_rfsh_accept && rfsh_n ) begin
			ff_rfsh_accept <= 1'b0;
		end
		else if( ff_main_state == c_main_state_activate ) begin
			if( !ff_rfsh_accept && !rfsh_n ) begin
				ff_rfsh_accept <= 1'b1;
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
		if( !reset_n ) begin
			ff_no_refresh <= 8'hFF;
		end
		else if( ff_no_refresh != 8'hFF ) begin
			ff_no_refresh <= ff_no_refresh + 8'd1;
		end
		else if( ff_do_refresh ) begin
			ff_no_refresh <= 8'h00;
		end
		else begin
			//	hold
		end
	end

	always @( posedge clk_n ) begin
		if( !reset_n ) begin
			ff_ddr_odt <= 1'b0;
		end
		else if( ff_main_state == c_init_state_mode_register_set1 || ff_main_state == c_init_state_mode_register_set0 || ff_main_state == c_init_state_zqcl ) begin
			ff_ddr_odt <= 1'b0;
		end
		else begin
			ff_ddr_odt <= 1'b1;
		end
	end

	assign ddr3_odt		= ff_ddr_odt;

	// --------------------------------------------------------------------
	//	Main State
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_main_state		<= c_init_state_reset_on;
			ff_do_main_state	<= 1'b0;
		end
		else begin
			case( ff_main_state )
			c_init_state_reset_on, c_init_state_reset_off,
			c_init_state_mode_register_set2, c_init_state_mode_register_set3, 
			c_init_state_mode_register_set1, c_init_state_mode_register_set0, 
			c_init_state_active0, c_init_state_active1, c_init_state_active2, c_init_state_active3, 
			c_init_state_active4, c_init_state_active5, c_init_state_active6, c_init_state_active7, 
			c_init_state_nop, c_init_state_zqcl:
				ff_main_state	<= ff_main_state + 6'd1;
			c_main_state_ready:
				if( (!ff_rfsh_accept && !rfsh_n) || (cpu_freeze && ff_no_refresh == 8'hFF) ) begin
					ff_main_state		<= c_main_state_activate;
					ff_do_main_state	<= 1'b1;
				end
				else if( !ff_rd_wr_accept && (!ff_rd_n || (!mreq_n && !rd_n && !w_busy)) ) begin
					ff_main_state		<= c_main_state_activate;
					ff_do_main_state	<= 1'b1;
				end
				else if( !ff_rd_wr_accept && (!ff_wr_n || (!mreq_n && !wr_n && !w_busy)) ) begin
					ff_main_state		<= c_main_state_activate;
					ff_do_main_state	<= 1'b1;
				end
			c_main_state_read_or_write:
				begin
					if( ff_do_refresh ) begin
						ff_main_state		<= c_main_state_nop5;
					end
					else begin
						ff_main_state		<= c_main_state_nop3;
					end
				end
			c_main_state_finish, c_main_state_finish2:
				begin
					ff_main_state		<= c_main_state_ready;
					ff_do_main_state	<= 1'b0;
				end
			default:
				if( (!ff_ddr_ready && w_end_of_main_timer) || (ff_ddr_ready && ff_do_main_state) ) begin
					ff_main_state	<= ff_main_state + 5'd1;
				end
				else begin
					//	hold
				end
			endcase
		end
	end

	assign w_busy			= w_has_request_latch || (cpu_freeze && ff_no_refresh == 8'hFF);
	assign sdram_busy		= w_busy;
	assign sdram_init_busy	= !ff_ddr_ready;

	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_ddr_rst_n <= 1'b0;
		end
		else if( ff_main_state == c_init_state_reset_on ) begin
			ff_ddr_rst_n <= 1'b0;
		end
		else if( ff_main_state == c_init_state_reset_on_wait ) begin
			if( w_end_of_main_timer ) begin
				ff_ddr_rst_n <= 1'b1;
			end
			else begin
				//	hold
			end
		end
		else begin
			//	hold
		end
	end

	always @( posedge clk_n ) begin
		if( !reset_n ) begin
			ff_ddr_cke <= 1'b0;
		end
		else if( ff_main_state == c_init_state_nop ) begin
			ff_ddr_cke <= 1'b1;
		end
		else begin
			//	hold
		end
	end

	// --------------------------------------------------------------------
	//	Sub State
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_ddr_ready	<= 1'b0;
		end
		else if( (ff_main_state == c_init_state_active7_wait) && w_end_of_main_timer ) begin
			ff_ddr_ready	<= 1'b1;
		end
		else begin
			//	hold
		end
	end

	// --------------------------------------------------------------------
	//	Main Timer
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_main_timer	<= 'd0;
		end
		else begin
			case( ff_main_state )
			c_init_state_reset_on:
				ff_main_timer	<= RESET_COUNT;		//	210usec
			c_init_state_reset_off:
				ff_main_timer	<= TIMER_COUNT;		//	510usec
			c_init_state_nop:
				ff_main_timer	<= 'd42 - 'd2;		//	tXPR = max( 5ck, 120ns ) = 42ck
			c_init_state_mode_register_set1, c_init_state_mode_register_set2, c_init_state_mode_register_set3:
				ff_main_timer	<= 'd4 - 'd2;		//	tMRD = 4ck
			c_init_state_mode_register_set0:
				ff_main_timer	<= 'd12 - 'd2;		//	tMOD = max( 12ck, 15ns ) = 12ck
			c_init_state_zqcl:
				ff_main_timer	<= 'd512 - 'd2;		//	tZQinit = 512ck
			c_init_state_precharge_all:
				ff_main_timer	<= 'd3 - 'd2;		//	tRP = 3ck
			c_init_state_active0, c_init_state_active1, c_init_state_active2, c_init_state_active3,
			c_init_state_active4, c_init_state_active5, c_init_state_active6, c_init_state_active7:
				ff_main_timer	<= 'd4 - 'd2;		//	tRRD = 4ck
			default:
				//	ff_main_timer is decrement counter.
				if( !w_end_of_main_timer ) begin
					ff_main_timer	<= ff_main_timer - 'd1;
				end
				else begin
					//	hold
				end
			endcase
		end
	end

	assign w_end_of_main_timer	= (ff_main_timer == 'd0) ? 1'b1 : 1'b0;

	always @( posedge clk ) begin
		case( ff_main_state )
		c_init_state_active0:
			ff_bank_row[0] <= 13'd0;
		c_init_state_active1:
			ff_bank_row[1] <= 13'd0;
		c_init_state_active2:
			ff_bank_row[2] <= 13'd0;
		c_init_state_active3:
			ff_bank_row[3] <= 13'd0;
		c_init_state_active4:
			ff_bank_row[4] <= 13'd0;
		c_init_state_active5:
			ff_bank_row[5] <= 13'd0;
		c_init_state_active6:
			ff_bank_row[6] <= 13'd0;
		c_init_state_active7:
			ff_bank_row[7] <= 13'd0;
		default:
			begin
				//	hold
			end
		endcase
	end

	// --------------------------------------------------------------------
	//	SDRAM Command Signal
	// --------------------------------------------------------------------
	always @( posedge clk_n ) begin
		if( !reset_n ) begin
			ff_ddr_command	<= c_ddr_command_no_operation;
		end
		else begin
			case( ff_main_state )
			c_init_state_nop:
				begin
					ff_ddr_command		<= c_ddr_command_no_operation;
					ff_ddr_dq_mask		<= 2'b11;
				end
			c_init_state_mode_register_set0, c_init_state_mode_register_set1, c_init_state_mode_register_set2, c_init_state_mode_register_set3:
				begin
					ff_ddr_command		<= c_ddr_command_mode_register_set;
					ff_ddr_dq_mask		<= 2'b11;
				end
			c_init_state_active0, c_init_state_active1, c_init_state_active2, c_init_state_active3,
			c_init_state_active4, c_init_state_active5, c_init_state_active6, c_init_state_active7:
				begin
					ff_ddr_command		<= c_ddr_command_activate;
					ff_ddr_dq_mask		<= 2'b11;
				end
			c_init_state_zqcl:
				begin
					ff_ddr_command		<= c_ddr_command_zqcl;
					ff_ddr_dq_mask		<= 2'b11;
				end
			c_init_state_precharge_all:
				begin
					ff_ddr_command		<= c_ddr_command_precharge_all;
					ff_ddr_dq_mask		<= 2'b11;
				end
			default:
				if( ff_ddr_ready ) begin
					case( ff_main_state )
					c_main_state_activate:
						if( (!ff_rfsh_accept && !rfsh_n) || (cpu_freeze && ff_no_refresh == 8'hFF) ) begin
//							$display( "do_refresh: precharge_all" );
							ff_ddr_command		<= c_ddr_command_precharge_all;
							ff_ddr_dq_mask		<= 2'b00;
						end
						else if( !ff_rd_wr_accept && (!ff_rd_n || !ff_wr_n) ) begin
//							$display( "activate address %X", ff_address[20:10] );
							ff_ddr_command		<= c_ddr_command_activate;
							ff_ddr_dq_mask		<= 2'b11;
						end
					c_main_state_read_or_write:
						if( ff_do_refresh ) begin
							ff_ddr_command		<= c_ddr_command_refresh;
							ff_ddr_dq_mask		<= 2'b00;
						end
						else if( ff_is_write ) begin
							ff_ddr_command		<= c_ddr_command_write;
							case( ff_address[0] )
							2'd0:		ff_ddr_dq_mask	<= 2'b10;
							2'd1:		ff_ddr_dq_mask	<= 2'b01;
							default:	ff_ddr_dq_mask	<= 2'b11;
							endcase
						end
						else begin
							ff_ddr_command		<= c_ddr_command_read;
							ff_ddr_dq_mask		<= 4'b00;
						end
					default:
						begin
							ff_ddr_command		<= c_ddr_command_no_operation;
							ff_ddr_dq_mask		<= 2'b11;
						end
					endcase
				end
				else begin
					ff_ddr_command		<= c_ddr_command_no_operation;
					ff_ddr_dq_mask		<= 2'b11;
				end
			endcase
		end
	end

	// --------------------------------------------------------------------
	//	 bit12  11     10   9   8    7    6     5     4     3   2    1    0
	//	[Bank1][Bank0][RSV][WB][OP1][OP0][CAS2][CAS1][CAS0][BT][BL2][BL1][BL0] : mode
	//	
	always @( posedge clk_n ) begin
		if( !reset_n ) begin
			ff_ddr_ba				<= 3'd0;
			ff_ddr_address			<= 13'd0;
		end
		else if( !ff_ddr_ready ) begin
			case( ff_main_state )
			c_init_state_mode_register_set0:
				begin
					//	Write Recovery: roundup( tWR/ tCK ) = 3 : tWR >= 15ns, tCK = 2.91ns (343MHz)
					ff_ddr_ba		<= 3'd0;		//	MRS0
					ff_ddr_address	<= {
						1'b1,						//	[12]  : Precharge PD
						3'b010,						//	[11:9]: Write Recovery 001: 5, 010: 6, 011: 7, 100: 8, 101: 10, 110: 12
						1'b1,						//	[8]   : DLL RESET    0: OFF, 1: DLL RESET START
						1'b0,						//	[7]   : Reserved: always 0
						3'b010,						//	[6:4] : CAS# latency 001: CL5, 010: CL6, ... , 111: CL11
						1'b0,						//	[3]   : Burst Type   0: Sequential, 1: Interleaved
						1'b0,						//	[2]   : Reserved: always 0
						2'd0						//	[1:0] : Burst Length 0: Fixed BL8, 1: BL4 or LB8, 2: Fixed BC4(Chop)
					};
				end
			c_init_state_mode_register_set1:
				begin
					ff_ddr_ba		<= 3'd1;		//	MRS1
					ff_ddr_address	<= {
						1'b0,						//	[12]  : OUTPUT Enable 0: Enable, 1: Disable
						1'b0,						//	[11]  : TDQS 0: Disabled(DM), 1: Enabled(TDQS)
						1'b0,						//	[10]  : Reserved always 0
						1'b0,						//	[9]   : RTT
						1'b0,						//	[8]   : Reserved, always 0
						1'b0,						//	[7]   : Write Levelization 0: Disable(normal), 1: Enable
						1'b0,						//	[6]   : RTT
						1'b0,						//	[5]   : Output Drive Strength: Always 0
						2'd0,						//	[4:3] : Additive Latency 0: Disabled, 1: AL=CL-1, 2: AL=CL-2
						1'b0,						//	[2]   : RTT
						2'd0,						//	[1]   : Output Drive Strength: 0: RZQ/6(40ohm), 1: RZQ/7(34ohm)
						1'b0						//	[0]   : DLL 0: disable, 1: enable(normal)
					};
				end
			c_init_state_mode_register_set2:
				begin
					ff_ddr_ba		<= 3'd2;		//	MRS2
					ff_ddr_address	<= {
						2'd0,						//	[12:11]: Reserved always 0
						2'd0,						//	[10:9] : RTT
						1'b0,						//	[8]    : Reserved always 0
						1'b0,						//	[7]    : Self Refresh Temperature 0: Normal, 1: Extended
						1'b0,						//	[6]    : Auto Self Refresh 0: Disabled, 1: Enabled
						3'd0,						//	[5:3]  : CAS Write Latency 0: 5ck, 1: 6ck, 2: 7ck, 3: 8ck
						3'd0						//	[2:0]  : Reserved always 0
					};
				end
			c_init_state_mode_register_set3:
				begin
					ff_ddr_ba		<= 3'd3;		//	MRS3
					ff_ddr_address	<= {
						10'd0,						//	[12:3] : Reserved always 0
						1'b0,						//	[2]    : MPR Enable: 0: Normal DRAM operations2, 1: Dataflow from MPR
						2'd0						//	[1:0]  : MPR READ Function: Predifined pattern
					};
				end
			c_init_state_zqcl:
				begin
					ff_ddr_ba		<= 3'd0;		//	N/A
					ff_ddr_address	<= {
						1'b1,						//	[12]  : Precharge PD
						3'b011,						//	[11:9]: Write Recovery 001: 5, 010: 6, 011: 7, 100: 8, 101: 10, 110: 12
						1'b1,						//	[8]   : DLL RESET    0: OFF, 1: DLL RESET START
						1'b0,						//	[7]   : Reserved: always 0
						3'b001,						//	[6:4] : CAS# latency 001: CL5, 010: CL6, ... , 111: CL11
						1'b0,						//	[3]   : Burst Type   0: Sequential, 1: Interleaved
						1'b0,						//	[2]   : Reserved: always 0
						2'd0						//	[1:0] : Burst Length 0: Fixed BL8, 1: BL4 or LB8, 2: Fixed BC4(Chop)
					};
				end
			c_init_state_precharge_all:
				begin
					ff_ddr_ba		<= 3'd0;		//	MRS1
					ff_ddr_address	<= {
						2'd0,						//	[12:11]: N/A
						1'b1,						//	[10]   : All banks
						10'b0						//	[9:0]  : N/A
					};
				end
			c_init_state_active0:
				begin
					ff_ddr_ba		<= 3'd0;		//	BANK#0
					ff_ddr_address	<= 13'd0;
				end
			c_init_state_active1:
				begin
					ff_ddr_ba		<= 3'd1;		//	BANK#1
					ff_ddr_address	<= 13'd0;
				end
			c_init_state_active2:
				begin
					ff_ddr_ba		<= 3'd2;		//	BANK#2
					ff_ddr_address	<= 13'd0;
				end
			c_init_state_active3:
				begin
					ff_ddr_ba		<= 3'd3;		//	BANK#3
					ff_ddr_address	<= 13'd0;
				end
			c_init_state_active4:
				begin
					ff_ddr_ba		<= 3'd4;		//	BANK#4
					ff_ddr_address	<= 13'd0;
				end
			c_init_state_active5:
				begin
					ff_ddr_ba		<= 3'd5;		//	BANK#5
					ff_ddr_address	<= 13'd0;
				end
			c_init_state_active6:
				begin
					ff_ddr_ba		<= 3'd6;		//	BANK#6
					ff_ddr_address	<= 13'd0;
				end
			c_init_state_active7:
				begin
					ff_ddr_ba		<= 3'd7;		//	BANK#7
					ff_ddr_address	<= 13'd0;
				end
			default:
				begin
					ff_ddr_ba		<= 3'b000;
					ff_ddr_address	<= 13'd0;
				end
			endcase
		end
		else begin
			case( ff_main_state )
			c_main_state_activate:
				if( ff_ddr_ready ) begin
					ff_ddr_ba		<= 3'b000;
					ff_ddr_address	<= { 
						ff_address[22:21],			// Bank
						ff_address[19:9]			// Row address
					};
				end
				else begin
					ff_ddr_ba		<= 3'b000;
					ff_ddr_address <= 13'd0;	// Initialize phase
				end
			c_main_state_read_or_write:
				begin
					if( ff_ddr_ready ) begin
						if( ff_do_refresh ) begin
//							$display( "do_refresh" );
							ff_ddr_ba		<= 3'b000;
							ff_ddr_address	<= { 
								2'b00,				// Ignore
								1'b1,				// All banks
								10'd0				// Ignore
							};
						end
						else begin
							ff_ddr_ba		<= 3'b000;
							ff_ddr_address	<= { 
								ff_address[22:21],	// Bank
								1'b1,				// Enable auto precharge
								2'd0,				// 00
								ff_address[8:1] 	// Column address
							};
						end
					end
					else begin
						ff_ddr_ba		<= 3'b000;
						ff_ddr_address	<= 13'd0;
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
		if( !reset_n ) begin
			ff_ddr_write_data <= 32'dz;
		end
		else if( ff_ddr_ready && ff_main_state == c_main_state_read_or_write ) begin
			if( ff_ddr_ready ) begin
				ff_ddr_write_data <= { ff_wdata, ff_wdata, ff_wdata, ff_wdata };
			end
			else begin
				ff_ddr_write_data <= 32'd0;
			end
		end
		else begin
			ff_ddr_write_data <= 32'dz;
		end
	end

	always @( posedge clk_n ) begin
		if( !reset_n ) begin
			ff_ddr_read_data	<= 8'd0;
			ff_ddr_read_data_en	<= 1'b0;
		end
		else if( ff_main_state == c_main_state_data_fetch ) begin
			case( ff_address[0] )
			2'd0:		ff_ddr_read_data <= ddr3_dq[7 :0 ];
			2'd1:		ff_ddr_read_data <= ddr3_dq[15:8 ];
			default:	ff_ddr_read_data <= 8'd0;
			endcase
			ff_ddr_read_data_en	<= ~ff_rd_n;
		end
		else begin
			ff_ddr_read_data_en	<= 1'b0;
		end
	end

	assign ddr3_rst_n		= ff_ddr_rst_n;
	assign ddr3_clk			= clk;
	assign ddr3_clk_n		= clk_n;
	assign ddr3_cke			= ff_ddr_cke;
	assign ddr3_cs_n		= ff_ddr_command[3];
	assign ddr3_ras_n		= ff_ddr_command[2];
	assign ddr3_cas_n		= ff_ddr_command[1];
	assign ddr3_we_n		= ff_ddr_command[0];

	assign ddr3_dm_tdqs		= ff_ddr_dq_mask;
	assign ddr3_ba			= ff_ddr_ba;

	assign ddr3_addr		= ff_ddr_address;
	assign ddr3_dq			= ff_ddr_write_data;

	assign rdata			= ff_ddr_read_data;
	assign rdata_en			= ff_ddr_read_data_en;
endmodule
