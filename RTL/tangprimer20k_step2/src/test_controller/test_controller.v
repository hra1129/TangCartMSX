// -----------------------------------------------------------------------------
//	test_controller.v
//	Copyright (C)2025 Takayuki Hara (HRA!)
//	
//	 Permission is hereby granted, free of charge, to any person obtaining a 
//	copy of this software and associated documentation files (the "Software"), 
//	to deal in the Software without restriction, including without limitation 
//	the rights to use, copy, modify, merge, publish, distribute, sublicense, 
//	and/or sell copies of the Software, and to permit persons to whom the 
//	Software is furnished to do so, subject to the following conditions:
//	
//	The above copyright notice and this permission notice shall be included in 
//	all copies or substantial portions of the Software.
//	
//	The Software is provided "as is", without warranty of any kind, express or 
//	implied, including but not limited to the warranties of merchantability, 
//	fitness for a particular purpose and noninfringement. In no event shall the 
//	authors or copyright holders be liable for any claim, damages or other 
//	liability, whether in an action of contract, tort or otherwise, arising 
//	from, out of or in connection with the Software or the use or other dealings 
//	in the Software.
// -----------------------------------------------------------------------------
//	Description:
//		DDR3 Controller test
// -----------------------------------------------------------------------------

module test_controller (
	input			reset_n,
	input			clk,
	input	[4:0]	button,
	output	[5:0]	led,
	input			sdram_init_busy,	//	0: Normal, 1: DDR3 SDRAM Initialization phase.
	output	[7:0]	bus_address,		//	uart Peripheral device address
	output			bus_write,			//	uart Direction 0: Read, 1: Write
	output			bus_valid,			//	uart 
	input			bus_ready,			//	uart 0: Busy, 1: Ready
	output	[7:0]	bus_wdata,			//	uart 
	output	[26:0]	dram_address,		//	DDR3 Controller 64Mword/16bit: [26:24]=BANK, [23:10]=ROW, [9:0]=COLUMN
	output			dram_write,			//	DDR3 Controller Direction 0: Read, 1: Write
	output			dram_valid,			//	DDR3 Controller 
	input			dram_ready,			//	DDR3 Controller 0: Busy, 1: Ready
	output	[127:0]	dram_wdata,			//	DDR3 Controller 
	output	[15:0]	dram_wdata_mask,	//	DDR3 Controller 
	input	[127:0]	dram_rdata,			//	DDR3 Controller 
	input			dram_rdata_valid	//	DDR3 Controller 
);
//	localparam	[127:0]	c_increment_data		= 128'h0B05_0702_0A00_9001_0007_0004_0200_B001;
	localparam	[127:0]	c_increment_data		= 128'h0000_0000_0000_0000_0000_0000_0000_0001;

	localparam	[7:0]	st_init					= 8'd0;
	localparam	[7:0]	st_print_title			= 8'd1;
	localparam	[7:0]	st_print_title_wait		= 8'd2;
	localparam	[7:0]	st_wait_init			= 8'd3;
	localparam	[7:0]	st_print_init_ok		= 8'd4;
	localparam	[7:0]	st_print_init_ok_wait	= 8'd5;
	localparam	[7:0]	st_write_init			= 8'd6;
	localparam	[7:0]	st_write_loop			= 8'd7;
	localparam	[7:0]	st_write				= 8'd8;
	localparam	[7:0]	st_write_wait			= 8'd9;
	localparam	[7:0]	st_read_init			= 8'd10;
	localparam	[7:0]	st_read_loop			= 8'd11;
	localparam	[7:0]	st_read					= 8'd12;
	localparam	[7:0]	st_read_wait			= 8'd13;
	localparam	[7:0]	st_read_data_wait		= 8'd14;
	localparam	[7:0]	st_read_error			= 8'd15;
	localparam	[7:0]	st_read_error_wait		= 8'd16;
	localparam	[7:0]	st_finish				= 8'd17;

	localparam	[3:0]	pst_wait				= 4'd0;
	localparam	[3:0]	pst_putc_chk			= 4'd1;
	localparam	[3:0]	pst_putc				= 4'd2;
	localparam	[3:0]	pst_putc_wait			= 4'd3;
	localparam	[3:0]	pst_putc_address		= 4'd4;
	localparam	[3:0]	pst_putc_address_one	= 4'd5;
	localparam	[3:0]	pst_putc_address_wait	= 4'd6;
	localparam	[3:0]	pst_putc_data			= 4'd7;
	localparam	[3:0]	pst_putc_data_one		= 4'd8;
	localparam	[3:0]	pst_putc_data_wait		= 4'd9;
	localparam	[3:0]	pst_finish				= 4'd10;

	localparam	[6:0]	s_title					= 7'd0;
	localparam	[6:0]	s_init_ok				= 7'd23;
	localparam	[6:0]	s_write					= 7'd40;
	localparam	[6:0]	s_read_error			= 7'd46;
	localparam	[6:0]	s_read					= 7'd62;

	reg		[7:0]	ff_main_state;
	reg		[3:0]	ff_print_state;
	reg		[7:0]	rom_data [0:127];
	reg				ff_print_start;
	reg		[6:0]	ff_print_begin;
	reg		[6:0]	ff_print_ptr;
	reg		[7:0]	ff_put_char;
	reg				ff_put_char_valid;
	reg		[27:0]	ff_put_address;
	reg		[5:0]	ff_led;
	reg		[26:0]	ff_dram_address;
	reg				ff_dram_write;
	reg		[127:0]	ff_dram_wdata;
	reg		[15:0]	ff_dram_wdata_mask;
	reg				ff_dram_valid;
	reg		[127:0]	ff_dram_data;
	reg		[127:0]	ff_put_data;
	reg		[4:0]	ff_count;

	initial begin
		rom_data[0]		= "D";
		rom_data[1]		= "D";
		rom_data[2]		= "R";
		rom_data[3]		= "3";
		rom_data[4]		= " ";
		rom_data[5]		= "T";
		rom_data[6]		= "e";
		rom_data[7]		= "s";
		rom_data[8]		= "t";
		rom_data[9]		= 8'd13;
		rom_data[10]	= 8'd10;
		rom_data[11]	= "W";
		rom_data[12]	= "a";
		rom_data[13]	= "i";
		rom_data[14]	= "t";
		rom_data[15]	= " ";
		rom_data[16]	= "i";
		rom_data[17]	= "n";
		rom_data[18]	= "i";
		rom_data[19]	= "t";
		rom_data[20]	= 8'd13;
		rom_data[21]	= 8'd10;
		rom_data[22]	= 8'd0;

		rom_data[23]	= "I";
		rom_data[24]	= "n";
		rom_data[25]	= "i";
		rom_data[26]	= "t";
		rom_data[27]	= " ";
		rom_data[28]	= "O";
		rom_data[29]	= "K";
		rom_data[30]	= 8'd13;
		rom_data[31]	= 8'd10;
		rom_data[32]	= "W";
		rom_data[33]	= "r";
		rom_data[34]	= "i";
		rom_data[35]	= "t";
		rom_data[36]	= "e";
		rom_data[37]	= 8'd13;
		rom_data[38]	= 8'd10;
		rom_data[39]	= 8'd0;

		rom_data[40]	= "W";
		rom_data[41]	= ":";
		rom_data[42]	= "@";
		rom_data[43]	= 8'd13;
		rom_data[44]	= 8'd10;
		rom_data[45]	= 8'd0;

		rom_data[46]	= " ";
		rom_data[47]	= "R";
		rom_data[48]	= "e";
		rom_data[49]	= "a";
		rom_data[50]	= "d";
		rom_data[51]	= " ";
		rom_data[52]	= "E";
		rom_data[53]	= "r";
		rom_data[54]	= "r";
		rom_data[55]	= " ";
		rom_data[56]	= "@";
		rom_data[57]	= ":";
		rom_data[58]	= "#";
		rom_data[59]	= 8'd13;
		rom_data[60]	= 8'd10;
		rom_data[61]	= 8'd0;

		rom_data[62]	= "R";
		rom_data[63]	= ":";
		rom_data[64]	= "@";
		rom_data[65]	= 8'd13;
		rom_data[66]	= 8'd10;
		rom_data[67]	= 8'd0;

	end

	function [7:0] func_hex(
		input	[3:0]	column
	);
		if( column < 4'd10 ) begin
			func_hex = { 4'd3, column };
		end
		else begin
			func_hex = { 4'd4, 1'b0, column[2:0] } - 8'd1;
		end
	endfunction

	// --------------------------------------------------------------------
	//	Print procedure
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_print_state		<= pst_wait;
			ff_put_char_valid	<= 1'b0;
		end
		else begin
			case( ff_print_state )
			pst_wait:
				//	print開始待ち ---------------------------------------------
				begin
					if( ff_print_start ) begin
						ff_print_state	<= pst_putc_chk;
						ff_print_ptr	<= ff_print_begin;
					end
				end
			pst_putc_chk:
				//	print文字チェック -----------------------------------------
				begin
					case( rom_data[ ff_print_ptr ] )
					8'd0:		ff_print_state		<= pst_finish;
					"@":		ff_print_state		<= pst_putc_address;
					"#":		ff_print_state		<= pst_putc_data;
					default:	ff_print_state		<= pst_putc;
					endcase
				end
			pst_putc:
				//	通常文字の出力 --------------------------------------------
				begin
					ff_put_char			<= rom_data[ ff_print_ptr ];
					ff_put_char_valid	<= 1'b1;
					ff_print_state		<= pst_putc_wait;
				end
			pst_putc_wait:
				//	通常文字の出力完了待ち ------------------------------------
				begin
					if( bus_ready ) begin
						ff_put_char_valid	<= 1'b0;
						ff_print_ptr		<= ff_print_ptr + 7'd1;
						ff_print_state		<= pst_putc_chk;
					end
				end
			pst_putc_address:
				//	アドレスの出力準備 ----------------------------------------
				begin
					ff_put_address		<= { 1'b0, ff_dram_address };
					ff_count			<= 5'd6;
					ff_print_ptr		<= ff_print_ptr + 7'd1;
					ff_print_state		<= pst_putc_address_one;
				end
			pst_putc_address_one:
				//	アドレス最上位桁出力要求 ----------------------------------
				begin
					ff_put_char			<= func_hex( ff_put_address[27:24] );
					ff_put_char_valid	<= 1'b1;
					ff_print_state		<= pst_putc_address_wait;
				end
			pst_putc_address_wait:
				//	アドレス最上位桁出力完了待ち ------------------------------
				begin
					if( bus_ready ) begin
						ff_put_char_valid	<= 1'b0;
						ff_put_address		<= { ff_put_address[23:0], 4'd0 };
						ff_count			<= ff_count - 5'd1;
						if( ff_count == 5'd0 ) begin
							ff_print_state	<= pst_putc_chk;
						end
						else begin
							ff_print_state	<= pst_putc_address_one;
						end
					end
				end
			pst_putc_data:
				//	データの出力準備 ------------------------------------------
				begin
					ff_put_data			<= ff_dram_data;
					ff_count			<= 5'd31;
					ff_print_ptr		<= ff_print_ptr + 7'd1;
					ff_print_state		<= pst_putc_data_one;
				end
			pst_putc_data_one:
				//	データ最上位桁出力要求 ------------------------------------
				begin
					ff_put_char			<= func_hex( ff_put_data[127:124] );
					ff_put_char_valid	<= 1'b1;
					ff_print_state		<= pst_putc_data_wait;
				end
			pst_putc_data_wait:
				//	データ最上位桁出力完了待ち --------------------------------
				begin
					if( bus_ready ) begin
						ff_put_char_valid	<= 1'b0;
						ff_put_data			<= { ff_put_data[123:0], 4'd0 };
						ff_count			<= ff_count - 5'd1;
						if( ff_count == 4'd0 ) begin
							ff_print_state	<= pst_putc_chk;
						end
						else begin
							ff_print_state	<= pst_putc_data_one;
						end
					end
				end
			pst_finish:
				//	print終了 -------------------------------------------------
				begin
					ff_print_state		<= pst_wait;
				end
			endcase
		end
	end

	// --------------------------------------------------------------------
	//	Main state controller
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_main_state		<= st_init;
			ff_print_start		<= 1'b0;
			ff_dram_address		<= 27'd0;
			ff_dram_write		<= 1'b0;
			ff_dram_wdata		<= 128'd0;
			ff_dram_wdata_mask	<= 16'd0;
			ff_dram_valid		<= 1'b0;
			ff_led				<= 6'b101010;
		end
		else begin
			case( ff_main_state )
			st_init:
				//	ボタン押下待ち --------------------------------------------
				if( button != 5'b11111 ) begin
					ff_main_state	<= ff_main_state + 8'd1;
				end
			st_print_title:
				//	DDR3 Test/Wait init を表示要求 ----------------------------
				begin
					ff_main_state	<= ff_main_state + 8'd1;
					ff_print_begin	<= s_title;
					ff_print_start	<= 1'b1;
				end
			st_print_title_wait:
				//	DDR3 Test/Wait init の表示完了待ち ------------------------
				begin
					if( ff_print_state == pst_finish ) begin
						ff_print_start	<= 1'b0;
						ff_main_state	<= ff_main_state + 8'd1;
						ff_led			<= 6'b000011;
					end
				end
			st_wait_init:
				//	sdram_init_busy が L になるのを待機 -----------------------
				begin
					if( !sdram_init_busy ) begin
						ff_main_state	<= ff_main_state + 8'd1;
						ff_led			<= 6'b001100;
					end
				end
			st_print_init_ok:
				//	Init OK を表示要求 ----------------------------------------
				begin
					ff_main_state	<= ff_main_state + 8'd1;
					ff_print_begin	<= s_init_ok;
					ff_print_start	<= 1'b1;
				end
			st_print_init_ok_wait:
				//	Init OK の表示完了待ち ------------------------------------
				begin
					if( ff_print_state == pst_finish ) begin
						ff_print_start	<= 1'b0;
						ff_main_state	<= ff_main_state + 8'd1;
					end
				end
			st_write_init:
				//	連続書き込みテストの下準備 --------------------------------
				begin
					ff_dram_address		<= 27'd0;
					ff_dram_write		<= 1'b1;
					ff_dram_wdata		<= 128'd0;
					ff_dram_wdata_mask	<= 16'h0000;
					ff_main_state		<= ff_main_state + 8'd1;
				end
			st_write_loop:
				//	連続書き込みループ ----------------------------------------
				begin
					if( ff_dram_address[15:0] == 16'd0 ) begin
						//	アドレスの下位 16bit が all 0 なら、アドレスを表示要求を出す 
						ff_print_begin		<= s_write;
						ff_print_start		<= 1'b1;
						ff_main_state		<= ff_main_state + 8'd1;
					end
					else begin
						//	それ以外は、即書き込み要求を発行 ------------------ 
						ff_main_state		<= st_write_wait;
						ff_dram_valid		<= 1'b1;
					end
				end
			st_write:
				//	アドレスの表示完了待ち ------------------------------------
				begin
					if( ff_print_state == pst_finish ) begin
						//	表示完了とともに、書き込み要求を発行 --------------
						ff_print_start		<= 1'b0;
						ff_main_state		<= ff_main_state + 8'd1;
						ff_dram_valid		<= 1'b1;
					end
				end
			st_write_wait:
				//	現在のアドレスへ書き込み完了待ち --------------------------
				begin
					if( dram_ready ) begin
						ff_dram_valid		<= 1'b0;
						ff_dram_address		<= ff_dram_address + 27'd8;
						ff_dram_wdata		<= ff_dram_wdata + c_increment_data;
						if( ff_dram_address == 27'h7FFFFF8 ) begin
							ff_main_state		<= st_read_init;
						end
						else begin
							ff_main_state		<= st_write_loop;
						end
					end
				end
			st_read_init:
				//	連続読み出しテストの下準備 --------------------------------
				begin
					ff_dram_address		<= 27'd0;
					ff_dram_write		<= 1'b0;
					ff_dram_wdata		<= 128'd0;
					ff_dram_wdata_mask	<= 16'h0000;
					ff_main_state		<= ff_main_state + 8'd1;
					ff_led				<= 6'b111110;
				end
			st_read_loop:
				//	連続書き込みループ ----------------------------------------
				begin
					if( ff_dram_address[15:0] == 16'd0 ) begin
						//	アドレスの下位 16bit が all 0 なら、アドレスを表示要求を出す 
						ff_print_begin		<= s_read;
						ff_print_start		<= 1'b1;
						ff_main_state		<= ff_main_state + 8'd1;
					end
					else begin
						//	それ以外は、即書き込み要求を発行 ------------------ 
						ff_main_state		<= st_read_wait;
						ff_dram_valid		<= 1'b1;
					end
				end
			st_read:
				//	アドレスの表示完了待ち ------------------------------------
				begin
					ff_led				<= 6'b111101;
					if( ff_print_state == pst_finish ) begin
						//	表示完了とともに、書き込み要求を発行 --------------
						ff_print_start		<= 1'b0;
						ff_main_state		<= ff_main_state + 8'd1;
						ff_dram_valid		<= 1'b1;
					end
				end
			st_read_wait:
				//	現在のアドレスへ読み込み受理待ち --------------------------
				begin
					ff_led				<= 6'b111100;
					if( dram_ready ) begin
						ff_dram_valid		<= 1'b0;
						ff_main_state		<= ff_main_state + 8'd1;
					end
				end
			st_read_data_wait:
				//	データ受け取り待ち ----------------------------------------
				begin
					ff_led				<= 6'b111011;
					if( dram_rdata_valid ) begin
						if( dram_rdata == ff_dram_wdata ) begin
							ff_dram_address		<= ff_dram_address + 27'd8;
							ff_dram_wdata		<= ff_dram_wdata + c_increment_data;
							if( ff_dram_address == 27'h7FFFFF8 ) begin
								ff_main_state		<= st_finish;
							end
							else begin
								ff_main_state		<= st_read_loop;
							end
						end
						else begin
							ff_dram_data		<= dram_rdata;
							ff_main_state		<= st_read_error;
						end
					end
				end
			st_read_error:
				//	Read Err の表示要求 ---------------------------------------
				begin
					ff_led				<= 6'b111010;
					ff_print_begin		<= s_read_error;
					ff_print_start		<= 1'b1;
					ff_main_state		<= ff_main_state + 8'd1;
				end
			st_read_error_wait:
				//	Read Err の表示完了待ち -----------------------------------
				begin
					ff_led				<= 6'b111001;
					if( ff_print_state == pst_finish ) begin
						ff_print_start		<= 1'b0;
						ff_dram_address		<= ff_dram_address + 27'd8;
						ff_dram_wdata		<= ff_dram_wdata + c_increment_data;
						if( ff_dram_address == 27'h7FFFFF8 ) begin
							ff_main_state		<= st_finish;
						end
						else begin
							ff_main_state		<= st_read_loop;
						end
					end
				end
			st_finish:
				begin
					ff_led				<= 6'b001111;
					//	hold
				end
			default:
				begin
					ff_main_state	<= st_init;
					ff_print_start	<= 1'b0;
				end
			endcase
		end
	end

	assign bus_address			= 8'h10;
	assign bus_write			= 1'b1;
	assign bus_valid			= ff_put_char_valid;
	assign bus_wdata			= ff_put_char;

	assign led					= ff_led;

	assign dram_address			= ff_dram_address;
	assign dram_write			= ff_dram_write;
	assign dram_valid			= ff_dram_valid;
	assign dram_wdata			= ff_dram_wdata;
	assign dram_wdata_mask		= ff_dram_wdata_mask;
endmodule
