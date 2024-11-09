// -----------------------------------------------------------------------------
//	ip_s2024.v
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

module ip_s2024 (
	//	internal signals
	input			n_reset,
	input			clk,				//	85.90908MHz
	//	cartridge slot signals
	output			slot_pin01_n_cs1,
	output			slot_pin02_n_cs2,
	output			slot_pin03_n_cs12,
	output			slot_pin04_n_sltsl1,
	output			slot_pin04_n_sltsl2,
	output			slot_pin06_n_rfsh,
	input			slot_pin07_n_wait,
	input			slot_pin08_n_int,
	output			slot_pin09_n_m1,
	output			slot_pin11_n_iorq,
	output			slot_pin12_n_merq,
	output			slot_pin13_n_wr,
	output			slot_pin14_n_rd,
	inout			slot_pin15_n_reset,
	output	[15:0]	slot_pin17_pin32_a,
	inout	[7:0]	slot_pin33_pin40_d,
	output			slot_pin42_clock,
	output			slot_d_output,
	//	internal signals
	output	[15:0]	bus_address,
	output			bus_io_req,
	output			bus_memory_req,
	input			bus_ack,
	output			bus_wrt,
	output	[7:0]	bus_wdata,
	input	[7:0]	bus_rdata,
	input			bus_rdata_en,
	//	slot
	input			sltsl1,
	input			sltsl2,
	//	CPU0
	input			cpu0_reset_n,
	output			cpu0_enable,
	output			cpu0_wait_n,
	output			cpu0_int_n,
	input			cpu0_m1_n,
	input			cpu0_mreq_n,
	input			cpu0_iorq_n,
	input			cpu0_rd_n,
	input			cpu0_wr_n,
	input			cpu0_rfsh_n,
	input			cpu0_halt_n,
	input			cpu0_busak_n,
	input	[15:0]	cpu0_a,
	inout	[7:0]	cou0_d,
	//	CPU1
	input			cpu1_reset_n,
	output			cpu1_enable,
	output			cpu1_wait_n,
	output			cpu1_int_n,
	input			cpu1_m1_n,
	input			cpu1_mreq_n,
	input			cpu1_iorq_n,
	input			cpu1_rd_n,
	input			cpu1_wr_n,
	input			cpu1_rfsh_n,
	input			cpu1_halt_n,
	input			cpu1_busak_n,
	input	[15:0]	cpu1_a,
	inout	[7:0]	cou1_d,
);
endmodule
