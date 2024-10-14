--
-- ip_sdram_dummy.vhd
--	 16384 bytes of block memory
--	 Revision 1.00
--
-- Copyright (c) 2024 Takayuki Hara
-- All rights reserved.
--
-- Redistribution and use of this source code or any derivative works, are
-- permitted provided that the following conditions are met:
--
-- 1. Redistributions of source code must retain the above copyright notice,
--		this list of conditions and the following disclaimer.
-- 2. Redistributions in binary form must reproduce the above copyright
--		notice, this list of conditions and the following disclaimer in the
--		documentation and/or other materials provided with the distribution.
-- 3. Redistributions may not be sold, nor may they be used in a commercial
--		product or activity without specific prior written permission.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
-- "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
-- TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
-- PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
-- CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
-- EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
-- PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
-- OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
-- WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
-- OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
-- ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity ip_sdram is
	port (
		n_reset			: in	std_logic;
		clk				: in	std_logic;
		clk_sdram		: in	std_logic;
		rd_n			: in	std_logic;
		wr_n			: in	std_logic;
		busy			: out	std_logic;
		address			: in	std_logic_vector( 22 downto 0 );
		wdata			: in	std_logic_vector( 7 downto 0 );
		rdata			: out	std_logic_vector( 15 downto 0 );
		rdata_en		: out	std_logic;
		O_sdram_clk		: out	std_logic;
		O_sdram_cke		: out	std_logic;
		O_sdram_cs_n	: out	std_logic;
		O_sdram_ras_n	: out	std_logic;
		O_sdram_cas_n	: out	std_logic;
		O_sdram_wen_n	: out	std_logic;
		IO_sdram_dq		: inout	std_logic_vector( 31 downto 0 );
		O_sdram_addr	: out	std_logic_vector( 10 downto 0 );
		O_sdram_ba		: out	std_logic_vector( 1 downto 0 );
		O_sdram_dqm		: out	std_logic_vector( 3 downto 0 )
	);
end ip_sdram;

architecture RTL of ip_sdram is
	type typram is array ( 16383 downto 0 ) of std_logic_vector( 7 downto 0 );
	signal	blkram		: typram;
	signal	ff_rdata	: std_logic_vector( 7 downto 0 );
	signal	ff_rdata_en	: std_logic;
begin

	process (clk)
	begin
		if( clk'event and clk ='1' )then
			if( wr_n = '0' )then
				blkram( conv_integer( address( 13 downto 0 ) ) ) <= wdata;
				ff_rdata_en	<= '0';
			elsif( rd_n = '0' )then
				ff_rdata	<= blkram( conv_integer( address( 13 downto 0 ) ) );
				ff_rdata_en	<= '1';
			else
				ff_rdata_en	<= '0';
			end if;
		end if;
	end process;

	O_sdram_clk		<= '0';
	O_sdram_cke		<= '0';
	O_sdram_cs_n	<= '0';
	O_sdram_ras_n	<= '0';
	O_sdram_cas_n	<= '0';
	O_sdram_wen_n	<= '0';
	IO_sdram_dq		<= (others => 'Z');
	O_sdram_addr	<= (others => '0');
	O_sdram_ba		<= "00";
	O_sdram_dqm		<= "0000";

	busy			<= '0';
	rdata			<= ff_rdata & ff_rdata;
	rdata_en		<= ff_rdata_en;
end RTL;
