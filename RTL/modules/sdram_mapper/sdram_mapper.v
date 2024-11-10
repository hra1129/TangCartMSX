//
//	sdram_mapper.v
//	 SDRAM Address Mapper top entity
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
//
//	000000h +-------------------------+
//	        | Slot#0-0 page0, 1       |  32KB		MAIN-ROM
//	008000h +-------------------------+
//			| Slot#0-1 page1, 2       |  32KB		IoT-BASIC
//	010000h +-------------------------+
//			| Slot#0-2 page1, 2       |  32KB		MSX-MUSIC
//	018000h +-------------------------+
//			| Slot#0-3 page1          |  16KB		OpeningROM
//	01C000h +-------------------------+
//			| Slot#3-1 page0          |  16KB		SUB-ROM
//	020000h +-------------------------+
//			| Slot#3-2 page1          |  128KB		Nextor (16KB * 8banks MegaROM)
//	040000h +-------------------------+
//	        | Kanji ROM               |  256KB		Kanji ROM (JIS1/JIS2)
//	080000h +-------------------------+
//			| Slot#3-1 page1, 2       |  512KB		KanjiDriver, MSX-JE (MegaROM)
//	100000h	+-------------------------+
//			| Slot#2                  |  1024KB		MegaROM Emulator
//	200000h	+-------------------------+
//			| Slot#1                  |  2048KB		MegaROM Emulator
//	400000h +-------------------------+
//			| Slot#3-0                |  4096KB		MapperRAM
//	800000h +-------------------------+
//
module sdram_mapper(
	input				reset,
	input				clk,
	input	[15:0]		bus_address,
	input	[7:0]		mapper_segment,
	input				sltsl00_en,
	input				sltsl01_en,
	input				sltsl02_en,
	input				sltsl03_en,
	input				sltsl1_en,
	input				sltsl2_en,
	input				sltsl30_en,
	input				sltsl31_en,
	input				sltsl32_en,
	input				sltsl33_en,
	input	[20:0]		slot1_megarom_address,
	input	[19:0]		slot2_megarom_address,
	input	[16:0]		nextor_address,
	input	[18:0]		kanji_driver_address,
	input	[17:0]		kanji_rom_address,
	input				kanji_rom_address_en,
	output	[22:0]		sdram_address
);
	reg		[22:0]		ff_sdram_address;

	assign sdram_address	= ff_sdram_address;

	always @( posedge clk ) begin
		if( reset ) begin
			ff_sdram_address <= 23'd0;
		end
		else if( sltsl30_en ) begin
			//	400000h +-------------------------+
			//			| Slot#3-0                |  4096KB		MapperRAM
			ff_sdram_address <= { 1'b1, mapper_segment, bus_address[13:0] }
		end
		else if( sltsl1_en ) begin
			//	200000h	+-------------------------+
			//			| Slot#1                  |  2048KB		MegaROM Emulator
			ff_sdram_address <= { 2'b01, slot1_megarom_address }
		end
		else if( sltsl2_en ) begin
			//	100000h	+-------------------------+
			//			| Slot#2                  |  1024KB		MegaROM Emulator
			ff_sdram_address <= { 3'b001, slot2_megarom_address }
		end
		else if( sltsl33_en ) begin
			//	080000h +-------------------------+
			//			| Slot#3-1 page1, 2       |  512KB		KanjiDriver, MSX-JE (MegaROM)
			ff_sdram_address <= { 6'b000_1, kanji_driver_address }
		end
		else if( kanji_rom_address_en ) begin
			//	040000h +-------------------------+
			//	        | Kanji ROM               |  256KB		Kanji ROM (JIS1/JIS2)
			ff_sdram_address <= { 5'b000_01, kanji_rom_address }
		end
		else if( sltsl32_en ) begin
			//	020000h +-------------------------+
			//			| Slot#3-2 page1          |  128KB		Nextor (16KB * 8banks MegaROM)
			ff_sdram_address <= { 6'b000_001, nextor_address }
		end
		else if( sltsl00_en ) begin
			//	000000h +-------------------------+
			//	        | Slot#0-0 page0, 1       |  32KB		MAIN-ROM
			ff_sdram_address <= { 8'b000_0000_0, bus_address[14:0] }
		end
		else if( sltsl01_en ) begin
			//	008000h +-------------------------+
			//			| Slot#0-1 page1, 2       |  32KB		IoT-BASIC
			ff_sdram_address <= { 8'b000_0000_1, ~bus_address[14], bus_address[13:0] }
		end
		else if( sltsl02_en ) begin
			//	010000h +-------------------------+
			//			| Slot#0-2 page1, 2       |  32KB		MSX-MUSIC
			ff_sdram_address <= { 8'b000_0001_0, ~bus_address[14], bus_address[13:0] }
		end
		else if( sltsl03_en ) begin
			//	018000h +-------------------------+
			//			| Slot#0-3 page1          |  16KB		OpeningROM
			ff_sdram_address <= { 9'b000_0001_10, bus_address[13:0] }
		end
		else if( sltsl31_en ) begin
			//	01C000h +-------------------------+
			//			| Slot#3-1 page0          |  16KB		SUB-ROM
			ff_sdram_address <= { 9'b000_0001_11, bus_address[13:0] }
		end
	end
endmodule
