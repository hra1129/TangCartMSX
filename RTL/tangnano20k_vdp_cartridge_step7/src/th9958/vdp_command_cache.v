//
//	vdp_command_cache.v
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

module vdp_command_cache (
	input				reset_n,
	input				clk,
	input				start,						//	1 clock pulse
	//	VDP command interface
	input		[16:0]	cache_vram_address,
	input				cache_vram_valid,
	output				cache_vram_ready,
	input				cache_vram_write,
	input		[7:0]	cache_vram_wdata,
	output		[7:0]	cache_vram_rdata,
	output				cache_vram_rdata_en,
	input				cache_flush_start,
	output				cache_flush_end,
	//	VRAM interface
	output		[16:0]	command_vram_address,
	output				command_vram_valid,
	input				command_vram_ready,
	output				command_vram_write,
	output		[31:0]	command_vram_wdata,
	output		[3:0]	command_vram_wdata_mask,
	input		[31:0]	command_vram_rdata,
	input				command_vram_rdata_en
);
	reg		[16:2]	ff_cache0_address;
	reg		[31:0]	ff_cache0_data;
	reg				ff_cache0_data_en;
	reg		[3:0]	ff_cache0_data_mask;
	reg				ff_cache0_already_read;
	wire			w_cache0_hit;
	reg		[16:2]	ff_cache1_address;
	reg		[31:0]	ff_cache1_data;
	reg				ff_cache1_data_en;
	reg		[3:0]	ff_cache1_data_mask;
	reg				ff_cache1_already_read;
	wire			w_cache1_hit;
	reg		[16:2]	ff_cache2_address;
	reg		[31:0]	ff_cache2_data;
	reg				ff_cache2_data_en;
	reg		[3:0]	ff_cache2_data_mask;
	reg				ff_cache2_already_read;
	wire			w_cache2_hit;
	reg		[16:2]	ff_cache3_address;
	reg		[31:0]	ff_cache3_data;
	reg				ff_cache3_data_en;
	reg		[3:0]	ff_cache3_data_mask;
	reg				ff_cache3_already_read;
	wire			w_cache3_hit;
	reg		[1:0]	ff_priority;
	reg		[7:0]	ff_cache_vram_rdata;
	reg				ff_cache_vram_rdata_en;
	reg				ff_vram_valid;
	reg		[16:2]	ff_vram_address;
	reg				ff_vram_write;				//	0: read, 1: write
	reg		[31:0]	ff_vram_wdata;
	reg		[3:0]	ff_vram_data_mask;
	wire			w_vram_busy;
	reg				ff_prewrite_read;
	reg				ff_busy;
	reg		[2:0]	ff_flush_state;

	assign w_cache0_hit		= ff_cache0_data_en && (ff_cache0_address == cache_vram_address[16:2]);
	assign w_cache1_hit		= ff_cache1_data_en && (ff_cache1_address == cache_vram_address[16:2]);
	assign w_cache2_hit		= ff_cache2_data_en && (ff_cache2_address == cache_vram_address[16:2]);
	assign w_cache3_hit		= ff_cache3_data_en && (ff_cache3_address == cache_vram_address[16:2]);
	assign cache_flush_end	= (ff_flush_state == 3'd1) ? ~ff_vram_valid: 1'b0;

	always @( posedge clk or negedge reset_n ) begin
		if( !reset_n ) begin
			ff_cache0_address		<= 15'd0;
			ff_cache0_data			<= 32'd0;
			ff_cache0_data_en		<= 1'b0;
			ff_cache0_data_mask		<= 4'b1111;
			ff_cache0_already_read	<= 1'b0;
			ff_cache1_address		<= 15'd0;
			ff_cache1_data			<= 32'd0;
			ff_cache1_data_en		<= 1'b0;
			ff_cache1_data_mask		<= 4'b1111;
			ff_cache1_already_read	<= 1'b0;
			ff_cache2_address		<= 15'd0;
			ff_cache2_data			<= 32'd0;
			ff_cache2_data_en		<= 1'b0;
			ff_cache2_data_mask		<= 4'b1111;
			ff_cache2_already_read	<= 1'b0;
			ff_cache3_address		<= 15'd0;
			ff_cache3_data			<= 32'd0;
			ff_cache3_data_en		<= 1'b0;
			ff_cache3_data_mask		<= 4'b1111;
			ff_cache3_already_read	<= 1'b0;
			ff_priority				<= 2'd0;
			ff_vram_address			<= 15'd0;
			ff_vram_valid			<= 1'b0;
			ff_vram_write			<= 1'b0;
			ff_vram_wdata			<= 32'd0;
			ff_vram_data_mask		<= 4'b1111;
			ff_cache_vram_rdata		<= 8'd0;
			ff_cache_vram_rdata_en	<= 1'b0;
			ff_busy					<= 1'b1;
			ff_flush_state			<= 3'd0;
		end
		else if( start ) begin
			//	Clear cache
			ff_cache0_data_en		<= 1'b0;
			ff_cache1_data_en		<= 1'b0;
			ff_cache2_data_en		<= 1'b0;
			ff_cache3_data_en		<= 1'b0;
			ff_priority				<= 2'd0;
			ff_vram_valid			<= 1'b0;
			ff_prewrite_read		<= 1'b0;
			ff_busy					<= 1'b0;
			ff_flush_state			<= 3'd0;
		end
		else if( cache_flush_start ) begin
			ff_flush_state			<= 3'd5;
			ff_busy					<= 1'b1;
		end
		else if( ff_vram_valid ) begin
			if( command_vram_ready ) begin
				ff_vram_valid			<= 1'b0;
			end
			else begin
				//	hold
			end
		end
		else if( ff_flush_state != 3'd0 ) begin
			case( ff_flush_state )
			3'd5: begin
				if( ff_cache0_data_en && ff_cache0_data_mask != 4'b1111 ) begin
					//	If it remains in the cache
					ff_vram_valid			<= 1'b1;
					ff_vram_write			<= 1'b1;
					ff_vram_address			<= ff_cache0_address;
					ff_vram_wdata			<= ff_cache0_data;
					ff_vram_data_mask		<= ff_cache0_data_mask;
					ff_cache0_data_en		<= 1'b0;
				end
				ff_flush_state <= 3'd4;
			end
			3'd4: begin
				if( ff_cache1_data_en && ff_cache1_data_mask != 4'b1111 ) begin
					//	If it remains in the cache
					ff_vram_valid			<= 1'b1;
					ff_vram_write			<= 1'b1;
					ff_vram_address			<= ff_cache1_address;
					ff_vram_wdata			<= ff_cache1_data;
					ff_vram_data_mask		<= ff_cache1_data_mask;
				end
				ff_cache1_data_en		<= 1'b0;
				ff_flush_state <= 3'd3;
			end
			3'd3: begin
				if( ff_cache2_data_en && ff_cache2_data_mask != 4'b1111 ) begin
					//	If it remains in the cache
					ff_vram_valid			<= 1'b1;
					ff_vram_write			<= 1'b1;
					ff_vram_address			<= ff_cache2_address;
					ff_vram_wdata			<= ff_cache2_data;
					ff_vram_data_mask		<= ff_cache2_data_mask;
				end
				ff_cache2_data_en		<= 1'b0;
				ff_flush_state <= 3'd2;
			end
			3'd2: begin
				if( ff_cache3_data_en && ff_cache3_data_mask != 4'b1111 ) begin
					//	If it remains in the cache
					ff_vram_valid			<= 1'b1;
					ff_vram_write			<= 1'b1;
					ff_vram_address			<= ff_cache3_address;
					ff_vram_wdata			<= ff_cache3_data;
					ff_vram_data_mask		<= ff_cache3_data_mask;
				end
				ff_cache3_data_en		<= 1'b0;
				ff_flush_state <= 3'd1;
			end
			3'd1: begin
				ff_flush_state <= 3'd0;
			end
			default: begin
				ff_flush_state <= 3'd0;
			end
			endcase
		end
		else if( ff_cache_vram_rdata_en ) begin
			ff_cache_vram_rdata_en	<= 1'b0;
			ff_busy					<= 1'b0;
		end
		else if( cache_vram_valid && !w_vram_busy ) begin
			if( !cache_vram_write ) begin
				//	Read access
				if(      w_cache0_hit ) begin
					//	Hit cache#0
					if( ff_cache0_already_read || ff_cache0_data_mask[ cache_vram_address[1:0] ] == 1'b0 ) begin
						case( cache_vram_address[1:0] )
						2'd0:	ff_cache_vram_rdata <= ff_cache0_data[ 7: 0];
						2'd1:	ff_cache_vram_rdata <= ff_cache0_data[15: 8];
						2'd2:	ff_cache_vram_rdata <= ff_cache0_data[23:16];
						2'd3:	ff_cache_vram_rdata <= ff_cache0_data[31:24];
						endcase
						ff_cache_vram_rdata_en		<= 1'b1;
					end
					else begin
						//	Read VRAM
						ff_vram_address		<= cache_vram_address[16:2];
						ff_vram_valid		<= 1'b1;
						ff_vram_write		<= 1'b0;
						ff_vram_data_mask	<= 4'b1111;
						ff_priority			<= 2'd0;
					end
					ff_busy				<= 1'b1;
				end
				else if( w_cache1_hit ) begin
					//	Hit cache#1
					if( ff_cache1_already_read || ff_cache1_data_mask[ cache_vram_address[1:0] ] == 1'b0 ) begin
						case( cache_vram_address[1:0] )
						2'd0:	ff_cache_vram_rdata <= ff_cache1_data[ 7: 0];
						2'd1:	ff_cache_vram_rdata <= ff_cache1_data[15: 8];
						2'd2:	ff_cache_vram_rdata <= ff_cache1_data[23:16];
						2'd3:	ff_cache_vram_rdata <= ff_cache1_data[31:24];
						endcase
						ff_cache_vram_rdata_en		<= 1'b1;
					end
					else begin
						//	Read VRAM
						ff_vram_address		<= cache_vram_address[16:2];
						ff_vram_valid		<= 1'b1;
						ff_vram_write		<= 1'b0;
						ff_vram_data_mask	<= 4'b1111;
						ff_priority			<= 2'd1;
					end
					ff_busy				<= 1'b1;
				end
				else if( w_cache2_hit ) begin
					//	Hit cache#2
					if( ff_cache2_already_read || ff_cache2_data_mask[ cache_vram_address[1:0] ] == 1'b0 ) begin
						case( cache_vram_address[1:0] )
						2'd0:	ff_cache_vram_rdata <= ff_cache2_data[ 7: 0];
						2'd1:	ff_cache_vram_rdata <= ff_cache2_data[15: 8];
						2'd2:	ff_cache_vram_rdata <= ff_cache2_data[23:16];
						2'd3:	ff_cache_vram_rdata <= ff_cache2_data[31:24];
						endcase
						ff_cache_vram_rdata_en		<= 1'b1;
					end
					else begin
						//	Read VRAM
						ff_vram_address		<= cache_vram_address[16:2];
						ff_vram_valid		<= 1'b1;
						ff_vram_write		<= 1'b0;
						ff_vram_data_mask	<= 4'b1111;
						ff_priority			<= 2'd2;
					end
					ff_busy				<= 1'b1;
				end
				else if( w_cache3_hit ) begin
					//	Hit cache#3
					if( ff_cache3_already_read || ff_cache3_data_mask[ cache_vram_address[1:0] ] == 1'b0 ) begin
						case( cache_vram_address[1:0] )
						2'd0:	ff_cache_vram_rdata <= ff_cache3_data[ 7: 0];
						2'd1:	ff_cache_vram_rdata <= ff_cache3_data[15: 8];
						2'd2:	ff_cache_vram_rdata <= ff_cache3_data[23:16];
						2'd3:	ff_cache_vram_rdata <= ff_cache3_data[31:24];
						endcase
						ff_cache_vram_rdata_en		<= 1'b1;
					end
					else begin
						//	Read VRAM
						ff_vram_address		<= cache_vram_address[16:2];
						ff_vram_valid		<= 1'b1;
						ff_vram_write		<= 1'b0;
						ff_vram_data_mask	<= 4'b1111;
						ff_priority			<= 2'd3;
					end
					ff_busy				<= 1'b1;
				end
				else begin
					//	Miss hit, Update the cache indicated by the priority flag.
					ff_vram_address				<= cache_vram_address[16:2];
					ff_vram_valid				<= 1'b1;
					ff_vram_write				<= 1'b0;
					ff_vram_data_mask			<= 4'b1111;
					ff_busy						<= 1'b1;
				end
			end
			else begin
				//	Write access
				if(      w_cache0_hit ) begin
					//	Hit cache#0
					case( cache_vram_address[1:0] )
					2'd0:	begin ff_cache0_data_mask[0] <= 1'b0; ff_cache0_data[ 7: 0] <= cache_vram_wdata; end
					2'd1:	begin ff_cache0_data_mask[1] <= 1'b0; ff_cache0_data[15: 8] <= cache_vram_wdata; end
					2'd2:	begin ff_cache0_data_mask[2] <= 1'b0; ff_cache0_data[23:16] <= cache_vram_wdata; end
					2'd3:	begin ff_cache0_data_mask[3] <= 1'b0; ff_cache0_data[31:24] <= cache_vram_wdata; end
					endcase
				end
				else if( w_cache1_hit ) begin
					//	Hit cache#1
					case( cache_vram_address[1:0] )
					2'd0:	begin ff_cache1_data_mask[0] <= 1'b0; ff_cache1_data[ 7: 0] <= cache_vram_wdata; end
					2'd1:	begin ff_cache1_data_mask[1] <= 1'b0; ff_cache1_data[15: 8] <= cache_vram_wdata; end
					2'd2:	begin ff_cache1_data_mask[2] <= 1'b0; ff_cache1_data[23:16] <= cache_vram_wdata; end
					2'd3:	begin ff_cache1_data_mask[3] <= 1'b0; ff_cache1_data[31:24] <= cache_vram_wdata; end
					endcase
				end
				else if( w_cache2_hit ) begin
					//	Hit cache#2
					case( cache_vram_address[1:0] )
					2'd0:	begin ff_cache2_data_mask[0] <= 1'b0; ff_cache2_data[ 7: 0] <= cache_vram_wdata; end
					2'd1:	begin ff_cache2_data_mask[1] <= 1'b0; ff_cache2_data[15: 8] <= cache_vram_wdata; end
					2'd2:	begin ff_cache2_data_mask[2] <= 1'b0; ff_cache2_data[23:16] <= cache_vram_wdata; end
					2'd3:	begin ff_cache2_data_mask[3] <= 1'b0; ff_cache2_data[31:24] <= cache_vram_wdata; end
					endcase
				end
				else if( w_cache3_hit ) begin
					//	Hit cache#3
					case( cache_vram_address[1:0] )
					2'd0:	begin ff_cache3_data_mask[0] <= 1'b0; ff_cache3_data[ 7: 0] <= cache_vram_wdata; end
					2'd1:	begin ff_cache3_data_mask[1] <= 1'b0; ff_cache3_data[15: 8] <= cache_vram_wdata; end
					2'd2:	begin ff_cache3_data_mask[2] <= 1'b0; ff_cache3_data[23:16] <= cache_vram_wdata; end
					2'd3:	begin ff_cache3_data_mask[3] <= 1'b0; ff_cache3_data[31:24] <= cache_vram_wdata; end
					endcase
				end
				else if( ff_cache0_data_en && ff_cache1_data_en && ff_cache2_data_en && ff_cache3_data_en ) begin
					//	When a cache miss occurs and the cache is completely full.
					case( ff_priority )
					2'd0: begin
						//	Flush cache0
						ff_vram_valid		<= 1'b1;
						ff_vram_address		<= ff_cache0_address;
						ff_vram_write		<= 1'b1;
						ff_vram_wdata		<= ff_cache0_data;
						ff_vram_data_mask	<= ff_cache0_data_mask;
						ff_cache0_address	<= cache_vram_address[16:2];
						case( cache_vram_address[1:0] )
						2'd0:	begin ff_cache0_data_mask <= 4'b1110; ff_cache0_data[ 7: 0] <= cache_vram_wdata; end
						2'd1:	begin ff_cache0_data_mask <= 4'b1101; ff_cache0_data[15: 8] <= cache_vram_wdata; end
						2'd2:	begin ff_cache0_data_mask <= 4'b1011; ff_cache0_data[23:16] <= cache_vram_wdata; end
						2'd3:	begin ff_cache0_data_mask <= 4'b0111; ff_cache0_data[31:24] <= cache_vram_wdata; end
						endcase
					end
					2'd1:begin
						//	Flush cache1
						ff_vram_valid		<= 1'b1;
						ff_vram_address		<= ff_cache1_address;
						ff_vram_write		<= 1'b1;
						ff_vram_wdata		<= ff_cache1_data;
						ff_vram_data_mask	<= ff_cache1_data_mask;
						ff_cache1_address	<= cache_vram_address[16:2];
						case( cache_vram_address[1:0] )
						2'd0:	begin ff_cache1_data_mask <= 4'b1110; ff_cache1_data[ 7: 0] <= cache_vram_wdata; end
						2'd1:	begin ff_cache1_data_mask <= 4'b1101; ff_cache1_data[15: 8] <= cache_vram_wdata; end
						2'd2:	begin ff_cache1_data_mask <= 4'b1011; ff_cache1_data[23:16] <= cache_vram_wdata; end
						2'd3:	begin ff_cache1_data_mask <= 4'b0111; ff_cache1_data[31:24] <= cache_vram_wdata; end
						endcase
					end
					2'd2:begin
						//	Flush cache2
						ff_vram_valid		<= 1'b1;
						ff_vram_address		<= ff_cache2_address;
						ff_vram_write		<= 1'b1;
						ff_vram_wdata		<= ff_cache2_data;
						ff_vram_data_mask	<= ff_cache2_data_mask;
						ff_cache2_address	<= cache_vram_address[16:2];
						case( cache_vram_address[1:0] )
						2'd0:	begin ff_cache2_data_mask <= 4'b1110; ff_cache2_data[ 7: 0] <= cache_vram_wdata; end
						2'd1:	begin ff_cache2_data_mask <= 4'b1101; ff_cache2_data[15: 8] <= cache_vram_wdata; end
						2'd2:	begin ff_cache2_data_mask <= 4'b1011; ff_cache2_data[23:16] <= cache_vram_wdata; end
						2'd3:	begin ff_cache2_data_mask <= 4'b0111; ff_cache2_data[31:24] <= cache_vram_wdata; end
						endcase
					end
					2'd3:begin
						//	Flush cache3
						ff_vram_valid		<= 1'b1;
						ff_vram_address		<= ff_cache3_address;
						ff_vram_write		<= 1'b1;
						ff_vram_wdata		<= ff_cache3_data;
						ff_vram_data_mask	<= ff_cache3_data_mask;
						ff_cache3_address	<= cache_vram_address[16:2];
						case( cache_vram_address[1:0] )
						2'd0:	begin ff_cache3_data_mask <= 4'b1110; ff_cache3_data[ 7: 0] <= cache_vram_wdata; end
						2'd1:	begin ff_cache3_data_mask <= 4'b1101; ff_cache3_data[15: 8] <= cache_vram_wdata; end
						2'd2:	begin ff_cache3_data_mask <= 4'b1011; ff_cache3_data[23:16] <= cache_vram_wdata; end
						2'd3:	begin ff_cache3_data_mask <= 4'b0111; ff_cache3_data[31:24] <= cache_vram_wdata; end
						endcase
					end
					endcase
					ff_priority	<= ff_priority + 2'd1;
				end
				else if( !ff_cache0_data_en ) begin
					//	Miss hit, and update cache0.
					ff_cache0_address		<= cache_vram_address[16:2];
					ff_cache0_already_read	<= 1'b0;
					ff_cache0_data_en		<= 1'b1;
					case( cache_vram_address[1:0] )
					2'd0:	begin ff_cache0_data_mask <= 4'b1110; ff_cache0_data[ 7: 0] <= cache_vram_wdata; end
					2'd1:	begin ff_cache0_data_mask <= 4'b1101; ff_cache0_data[15: 8] <= cache_vram_wdata; end
					2'd2:	begin ff_cache0_data_mask <= 4'b1011; ff_cache0_data[23:16] <= cache_vram_wdata; end
					2'd3:	begin ff_cache0_data_mask <= 4'b0111; ff_cache0_data[31:24] <= cache_vram_wdata; end
					endcase
				end
				else if( !ff_cache1_data_en ) begin
					//	Miss hit, and update cache0.
					ff_cache1_address		<= cache_vram_address[16:2];
					ff_cache1_already_read	<= 1'b0;
					ff_cache1_data_en		<= 1'b1;
					case( cache_vram_address[1:0] )
					2'd0:	begin ff_cache1_data_mask <= 4'b1110; ff_cache1_data[ 7: 0] <= cache_vram_wdata; end
					2'd1:	begin ff_cache1_data_mask <= 4'b1101; ff_cache1_data[15: 8] <= cache_vram_wdata; end
					2'd2:	begin ff_cache1_data_mask <= 4'b1011; ff_cache1_data[23:16] <= cache_vram_wdata; end
					2'd3:	begin ff_cache1_data_mask <= 4'b0111; ff_cache1_data[31:24] <= cache_vram_wdata; end
					endcase
				end
				else if( !ff_cache2_data_en ) begin
					//	Miss hit, and update cache0.
					ff_cache2_address		<= cache_vram_address[16:2];
					ff_cache2_already_read	<= 1'b0;
					ff_cache2_data_en		<= 1'b1;
					case( cache_vram_address[1:0] )
					2'd0:	begin ff_cache2_data_mask <= 4'b1110; ff_cache2_data[ 7: 0] <= cache_vram_wdata; end
					2'd1:	begin ff_cache2_data_mask <= 4'b1101; ff_cache2_data[15: 8] <= cache_vram_wdata; end
					2'd2:	begin ff_cache2_data_mask <= 4'b1011; ff_cache2_data[23:16] <= cache_vram_wdata; end
					2'd3:	begin ff_cache2_data_mask <= 4'b0111; ff_cache2_data[31:24] <= cache_vram_wdata; end
					endcase
				end
				else begin	//	if( ff_cache3_data_en ) begin
					//	Miss hit, and update cache0.
					ff_cache3_address		<= cache_vram_address[16:2];
					ff_cache3_already_read	<= 1'b0;
					ff_cache3_data_en		<= 1'b1;
					case( cache_vram_address[1:0] )
					2'd0:	begin ff_cache3_data_mask <= 4'b1110; ff_cache3_data[ 7: 0] <= cache_vram_wdata; end
					2'd1:	begin ff_cache3_data_mask <= 4'b1101; ff_cache3_data[15: 8] <= cache_vram_wdata; end
					2'd2:	begin ff_cache3_data_mask <= 4'b1011; ff_cache3_data[23:16] <= cache_vram_wdata; end
					2'd3:	begin ff_cache3_data_mask <= 4'b0111; ff_cache3_data[31:24] <= cache_vram_wdata; end
					endcase
				end
			end
		end
		else if( command_vram_rdata_en ) begin
			//	Processing responses to VRAM read requests due to cache misses
			ff_busy						<= 1'b0;
			case( ff_priority )
			2'd0:	begin
				ff_cache0_address		<= ff_vram_address;
				ff_cache0_data[ 7: 0]	<= ff_cache0_data_mask[0] ? command_vram_rdata[ 7: 0]: ff_cache0_data[ 7: 0];
				ff_cache0_data[15: 8]	<= ff_cache0_data_mask[1] ? command_vram_rdata[15: 8]: ff_cache0_data[15: 8];
				ff_cache0_data[23:16]	<= ff_cache0_data_mask[2] ? command_vram_rdata[23:16]: ff_cache0_data[23:16];
				ff_cache0_data[31:24]	<= ff_cache0_data_mask[3] ? command_vram_rdata[31:24]: ff_cache0_data[31:24];
				ff_cache0_data_en		<= 1'b1;
				ff_cache0_data_mask		<= 4'b1111;
				ff_cache0_already_read	<= 1'b1;
			end
			2'd1:	begin
				ff_cache1_address		<= ff_vram_address;
				ff_cache1_data[ 7: 0]	<= ff_cache1_data_mask[0] ? command_vram_rdata[ 7: 0]: ff_cache1_data[ 7: 0];
				ff_cache1_data[15: 8]	<= ff_cache1_data_mask[1] ? command_vram_rdata[15: 8]: ff_cache1_data[15: 8];
				ff_cache1_data[23:16]	<= ff_cache1_data_mask[2] ? command_vram_rdata[23:16]: ff_cache1_data[23:16];
				ff_cache1_data[31:24]	<= ff_cache1_data_mask[3] ? command_vram_rdata[31:24]: ff_cache1_data[31:24];
				ff_cache1_data_en		<= 1'b1;
				ff_cache1_data_mask		<= 4'b1111;
				ff_cache1_already_read	<= 1'b1;
			end
			2'd2:	begin
				ff_cache2_address		<= ff_vram_address;
				ff_cache2_data[ 7: 0]	<= ff_cache2_data_mask[0] ? command_vram_rdata[ 7: 0]: ff_cache2_data[ 7: 0];
				ff_cache2_data[15: 8]	<= ff_cache2_data_mask[1] ? command_vram_rdata[15: 8]: ff_cache2_data[15: 8];
				ff_cache2_data[23:16]	<= ff_cache2_data_mask[2] ? command_vram_rdata[23:16]: ff_cache2_data[23:16];
				ff_cache2_data[31:24]	<= ff_cache2_data_mask[3] ? command_vram_rdata[31:24]: ff_cache2_data[31:24];
				ff_cache2_data_en		<= 1'b1;
				ff_cache2_data_mask		<= 4'b1111;
				ff_cache2_already_read	<= 1'b1;
			end
			2'd3:	begin
				ff_cache3_address		<= ff_vram_address;
				ff_cache3_data[ 7: 0]	<= ff_cache3_data_mask[0] ? command_vram_rdata[ 7: 0]: ff_cache3_data[ 7: 0];
				ff_cache3_data[15: 8]	<= ff_cache3_data_mask[1] ? command_vram_rdata[15: 8]: ff_cache3_data[15: 8];
				ff_cache3_data[23:16]	<= ff_cache3_data_mask[2] ? command_vram_rdata[23:16]: ff_cache3_data[23:16];
				ff_cache3_data[31:24]	<= ff_cache3_data_mask[3] ? command_vram_rdata[31:24]: ff_cache3_data[31:24];
				ff_cache3_data_en		<= 1'b1;
				ff_cache3_data_mask		<= 4'b1111;
				ff_cache3_already_read	<= 1'b1;
			end
			endcase

			case( cache_vram_address[1:0] )
			2'd0:	ff_cache_vram_rdata <= command_vram_rdata[ 7: 0];
			2'd1:	ff_cache_vram_rdata <= command_vram_rdata[15: 8];
			2'd2:	ff_cache_vram_rdata <= command_vram_rdata[23:16];
			2'd3:	ff_cache_vram_rdata <= command_vram_rdata[31:24];
			endcase

			ff_cache_vram_rdata_en		<= 1'b1;
			ff_priority					<= ff_priority + 2'd1;
		end
		else begin
			ff_cache_vram_rdata_en		<= 1'b0;
		end
	end

	// --------------------------------------------------------------------
	//	VRAM Access
	// --------------------------------------------------------------------
	assign w_vram_busy				= ff_vram_valid;
	assign cache_vram_ready			= ~w_vram_busy;
	assign cache_vram_rdata			= ff_cache_vram_rdata;
	assign cache_vram_rdata_en		= ff_cache_vram_rdata_en;
	assign command_vram_address		= { ff_vram_address, 2'd0 };
	assign command_vram_valid		= ff_vram_valid;
	assign command_vram_write		= ff_vram_write;
	assign command_vram_wdata		= ff_vram_wdata;
	assign command_vram_wdata_mask	= ff_vram_data_mask;
endmodule
