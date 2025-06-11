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
	output			refresh_req,
	input			refresh_ack,
	output	[26:0]	dram_address,		//	DDR3 Controller 64Mword/16bit: [26:24]=BANK, [23:10]=ROW, [9:0]=COLUMN
	output			dram_write,			//	DDR3 Controller Direction 0: Read, 1: Write
	output			dram_valid,			//	DDR3 Controller 
	input			dram_ready,			//	DDR3 Controller 0: Busy, 1: Ready
	output	[127:0]	dram_wdata,			//	DDR3 Controller 
	output	[15:0]	dram_wdata_mask,	//	DDR3 Controller 
	input	[127:0]	dram_rdata,			//	DDR3 Controller 
	input			dram_rdata_valid	//	DDR3 Controller 
);
	localparam	[15:0]	c_increment_data0			= 16'h0001;
	localparam	[15:0]	c_increment_data1			= 16'h0003;
	localparam	[15:0]	c_increment_data2			= 16'h0005;
	localparam	[15:0]	c_increment_data3			= 16'h0007;
	localparam	[15:0]	c_increment_data4			= 16'h0009;
	localparam	[15:0]	c_increment_data5			= 16'h000B;
	localparam	[15:0]	c_increment_data6			= 16'h000D;
	localparam	[15:0]	c_increment_data7			= 16'h000F;

	localparam	[7:0]	st_init						= 8'd0;
	localparam	[7:0]	st_print_title				= 8'd1;
	localparam	[7:0]	st_print_title_wait			= 8'd2;
	localparam	[7:0]	st_wait_init				= 8'd3;
	localparam	[7:0]	st_print_init_ok			= 8'd4;
	localparam	[7:0]	st_print_init_ok_wait		= 8'd5;
	localparam	[7:0]	st_write_init				= 8'd6;
	localparam	[7:0]	st_write_loop				= 8'd7;
	localparam	[7:0]	st_write					= 8'd8;
	localparam	[7:0]	st_write_wait				= 8'd9;
	localparam	[7:0]	st_read_init				= 8'd10;
	localparam	[7:0]	st_read_loop				= 8'd11;
	localparam	[7:0]	st_read						= 8'd12;
	localparam	[7:0]	st_read_wait				= 8'd13;
	localparam	[7:0]	st_read_data_wait			= 8'd14;
	localparam	[7:0]	st_byte_wnr_test			= 8'd15;
	localparam	[7:0]	st_read_wnr_test_wait		= 8'd16;
	localparam	[7:0]	st_byte_write0				= 8'd17;
	localparam	[7:0]	st_byte_write1				= 8'd18;
	localparam	[7:0]	st_byte_write2				= 8'd19;
	localparam	[7:0]	st_byte_write3				= 8'd20;
	localparam	[7:0]	st_byte_write4				= 8'd21;
	localparam	[7:0]	st_byte_write5				= 8'd22;
	localparam	[7:0]	st_byte_write6				= 8'd23;
	localparam	[7:0]	st_byte_write7				= 8'd24;
	localparam	[7:0]	st_byte_write8				= 8'd25;
	localparam	[7:0]	st_byte_write9				= 8'd26;
	localparam	[7:0]	st_byte_write10				= 8'd27;
	localparam	[7:0]	st_byte_write11				= 8'd28;
	localparam	[7:0]	st_byte_write12				= 8'd29;
	localparam	[7:0]	st_byte_write13				= 8'd30;
	localparam	[7:0]	st_byte_write14				= 8'd31;
	localparam	[7:0]	st_byte_write15				= 8'd32;
	localparam	[7:0]	st_byte_write16				= 8'd33;
	localparam	[7:0]	st_byte_read				= 8'd34;
	localparam	[7:0]	st_byte_read_wait			= 8'd35;
	localparam	[7:0]	st_byte_read_data_wait		= 8'd36;
	localparam	[7:0]	st_byte_wnr_result			= 8'd37;
	localparam	[7:0]	st_byte_read2				= 8'd38;
	localparam	[7:0]	st_byte_read_wait2			= 8'd39;
	localparam	[7:0]	st_byte_read_data_wait2		= 8'd40;
	localparam	[7:0]	st_byte_wnr_result2			= 8'd41;
	localparam	[7:0]	st_byte_read3				= 8'd42;
	localparam	[7:0]	st_byte_read_wait3			= 8'd43;
	localparam	[7:0]	st_byte_read_data_wait3		= 8'd44;
	localparam	[7:0]	st_byte_wnr_result3			= 8'd45;
	localparam	[7:0]	st_byte_read4				= 8'd46;
	localparam	[7:0]	st_byte_read_wait4			= 8'd47;
	localparam	[7:0]	st_byte_read_data_wait4		= 8'd48;
	localparam	[7:0]	st_byte_wnr_result4			= 8'd49;
	localparam	[7:0]	st_byte_read5				= 8'd50;
	localparam	[7:0]	st_byte_read_wait5			= 8'd51;
	localparam	[7:0]	st_byte_read_data_wait5		= 8'd52;
	localparam	[7:0]	st_byte_wnr_result5			= 8'd53;
	localparam	[7:0]	st_byte_read6				= 8'd54;
	localparam	[7:0]	st_byte_read_wait6			= 8'd55;
	localparam	[7:0]	st_byte_read_data_wait6		= 8'd56;
	localparam	[7:0]	st_byte_wnr_result6			= 8'd57;
	localparam	[7:0]	st_print_read_wait_count	= 8'd58;
	localparam	[7:0]	st_print_read_wait_count_end= 8'd59;
	localparam	[7:0]	st_read_error				= 8'd60;
	localparam	[7:0]	st_read_error_wait			= 8'd61;
	localparam	[7:0]	st_finish					= 8'd62;

	localparam	[3:0]	pst_wait					= 4'd0;
	localparam	[3:0]	pst_putc_chk				= 4'd1;
	localparam	[3:0]	pst_putc					= 4'd2;
	localparam	[3:0]	pst_putc_wait				= 4'd3;
	localparam	[3:0]	pst_putc_address			= 4'd4;
	localparam	[3:0]	pst_putc_address_one		= 4'd5;
	localparam	[3:0]	pst_putc_address_wait		= 4'd6;
	localparam	[3:0]	pst_putc_data				= 4'd7;
	localparam	[3:0]	pst_putc_data_one			= 4'd8;
	localparam	[3:0]	pst_putc_data_wait			= 4'd9;
	localparam	[3:0]	pst_finish					= 4'd10;

	localparam	[6:0]	s_title						= 7'd0;
	localparam	[6:0]	s_init_ok					= 7'd23;
	localparam	[6:0]	s_write						= 7'd40;
	localparam	[6:0]	s_read_error				= 7'd46;
	localparam	[6:0]	s_read						= 7'd62;
	localparam	[6:0]	s_byte_wr_test				= 7'd68;
	localparam	[6:0]	s_byte_wr_result			= 7'd79;
	localparam	[6:0]	s_count						= 7'd87;

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
	reg				ff_refresh_req;
	reg		[26:0]	ff_dram_address;
	reg				ff_dram_write;
	reg		[15:0]	ff_dram_wdata [0:7];
	reg		[15:0]	ff_dram_wdata_mask;
	reg				ff_dram_valid;
	reg		[15:0]	ff_dram_data [0:7];
	reg		[15:0]	ff_put_data [0:7];
	reg		[4:0]	ff_count;
	reg		[7:0]	ff_read_wait_count;
	reg		[7:0]	ff_read_wait_count_max;
	reg				ff_read_active;

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

		rom_data[68]	= "B";
		rom_data[69]	= "y";
		rom_data[70]	= "t";
		rom_data[71]	= "e";
		rom_data[72]	= " ";
		rom_data[73]	= "W";
		rom_data[74]	= "/";
		rom_data[75]	= "R";
		rom_data[76]	= 8'd13;
		rom_data[77]	= 8'd10;
		rom_data[78]	= 8'd0;

		rom_data[79]	= "B";
		rom_data[80]	= ":";
		rom_data[81]	= "@";
		rom_data[82]	= "=";
		rom_data[83]	= "#";
		rom_data[84]	= 8'd13;
		rom_data[85]	= 8'd10;
		rom_data[86]	= 8'd0;

		rom_data[87]	= "C";
		rom_data[88]	= ":";
		rom_data[89]	= "#";
		rom_data[90]	= 8'd13;
		rom_data[91]	= 8'd10;
		rom_data[92]	= 8'd0;

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
	//	Read wait counter
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_read_wait_count	<= 8'd0;
			ff_read_active		<= 1'b0;
		end
		else if( ff_read_active ) begin
			if( dram_rdata_valid ) begin
				ff_read_active	<= 1'b0;
			end
			else begin
				ff_read_wait_count	<= ff_read_wait_count + 8'd1;
			end
		end
		else if( !ff_dram_write && ff_dram_valid && dram_ready ) begin
			ff_read_wait_count	<= 8'd1;
			ff_read_active		<= 1'b1;
		end
	end

	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_read_wait_count_max	<= 8'b0;
		end
		else if( ff_read_wait_count_max < ff_read_wait_count ) begin
			ff_read_wait_count_max	<= ff_read_wait_count;
		end
	end

	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_refresh_req <= 1'b0;
		end
		else if( ff_refresh_req ) begin
			if( refresh_ack ) begin
				ff_refresh_req <= 1'b0;
			end
		end
		else if( dram_rdata_valid ) begin
			ff_refresh_req <= 1'b1;
		end
		else if( ff_dram_write && ff_dram_valid && dram_ready ) begin
			ff_refresh_req <= 1'b1;
		end
	end

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
					ff_put_data[0]		<= ff_dram_data[0];
					ff_put_data[1]		<= ff_dram_data[1];
					ff_put_data[2]		<= ff_dram_data[2];
					ff_put_data[3]		<= ff_dram_data[3];
					ff_put_data[4]		<= ff_dram_data[4];
					ff_put_data[5]		<= ff_dram_data[5];
					ff_put_data[6]		<= ff_dram_data[6];
					ff_put_data[7]		<= ff_dram_data[7];
					ff_count			<= 5'd31;
					ff_print_ptr		<= ff_print_ptr + 7'd1;
					ff_print_state		<= pst_putc_data_one;
				end
			pst_putc_data_one:
				//	データ最上位桁出力要求 ------------------------------------
				begin
					ff_put_char			<= func_hex( ff_put_data[7][15:12] );
					ff_put_char_valid	<= 1'b1;
					ff_print_state		<= pst_putc_data_wait;
				end
			pst_putc_data_wait:
				//	データ最上位桁出力完了待ち --------------------------------
				begin
					if( bus_ready ) begin
						ff_put_char_valid	<= 1'b0;
						ff_put_data[0]		<= { ff_put_data[0][11:0], 4'd0 };
						ff_put_data[1]		<= { ff_put_data[1][11:0], ff_put_data[0][15:12] };
						ff_put_data[2]		<= { ff_put_data[2][11:0], ff_put_data[1][15:12] };
						ff_put_data[3]		<= { ff_put_data[3][11:0], ff_put_data[2][15:12] };
						ff_put_data[4]		<= { ff_put_data[4][11:0], ff_put_data[3][15:12] };
						ff_put_data[5]		<= { ff_put_data[5][11:0], ff_put_data[4][15:12] };
						ff_put_data[6]		<= { ff_put_data[6][11:0], ff_put_data[5][15:12] };
						ff_put_data[7]		<= { ff_put_data[7][11:0], ff_put_data[6][15:12] };
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
			ff_dram_wdata[0]	<= 16'd0;
			ff_dram_wdata[1]	<= 16'd0;
			ff_dram_wdata[2]	<= 16'd0;
			ff_dram_wdata[3]	<= 16'd0;
			ff_dram_wdata[4]	<= 16'd0;
			ff_dram_wdata[5]	<= 16'd0;
			ff_dram_wdata[6]	<= 16'd0;
			ff_dram_wdata[7]	<= 16'd0;
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
					ff_dram_wdata[0]	<= 16'd0;
					ff_dram_wdata[1]	<= 16'd0;
					ff_dram_wdata[2]	<= 16'd0;
					ff_dram_wdata[3]	<= 16'd0;
					ff_dram_wdata[4]	<= 16'd0;
					ff_dram_wdata[5]	<= 16'd0;
					ff_dram_wdata[6]	<= 16'd0;
					ff_dram_wdata[7]	<= 16'd0;
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
						ff_dram_wdata[0]	<= ff_dram_wdata[0] + c_increment_data0;
						ff_dram_wdata[1]	<= ff_dram_wdata[1] + c_increment_data1;
						ff_dram_wdata[2]	<= ff_dram_wdata[2] + c_increment_data2;
						ff_dram_wdata[3]	<= ff_dram_wdata[3] + c_increment_data3;
						ff_dram_wdata[4]	<= ff_dram_wdata[4] + c_increment_data4;
						ff_dram_wdata[5]	<= ff_dram_wdata[5] + c_increment_data5;
						ff_dram_wdata[6]	<= ff_dram_wdata[6] + c_increment_data6;
						ff_dram_wdata[7]	<= ff_dram_wdata[7] + c_increment_data7;
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
					ff_dram_wdata[0]	<= 16'd0;
					ff_dram_wdata[1]	<= 16'd0;
					ff_dram_wdata[2]	<= 16'd0;
					ff_dram_wdata[3]	<= 16'd0;
					ff_dram_wdata[4]	<= 16'd0;
					ff_dram_wdata[5]	<= 16'd0;
					ff_dram_wdata[6]	<= 16'd0;
					ff_dram_wdata[7]	<= 16'd0;
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
					if( refresh_ack ) begin
						if( dram_rdata == { ff_dram_wdata[7], ff_dram_wdata[6], ff_dram_wdata[5], ff_dram_wdata[4], ff_dram_wdata[3], ff_dram_wdata[2], ff_dram_wdata[1], ff_dram_wdata[0] } ) begin
							ff_dram_address		<= ff_dram_address + 27'd8;
							ff_dram_wdata[0]	<= ff_dram_wdata[0] + c_increment_data0;
							ff_dram_wdata[1]	<= ff_dram_wdata[1] + c_increment_data1;
							ff_dram_wdata[2]	<= ff_dram_wdata[2] + c_increment_data2;
							ff_dram_wdata[3]	<= ff_dram_wdata[3] + c_increment_data3;
							ff_dram_wdata[4]	<= ff_dram_wdata[4] + c_increment_data4;
							ff_dram_wdata[5]	<= ff_dram_wdata[5] + c_increment_data5;
							ff_dram_wdata[6]	<= ff_dram_wdata[6] + c_increment_data6;
							ff_dram_wdata[7]	<= ff_dram_wdata[7] + c_increment_data7;
							if( ff_dram_address == 27'h7FFFFF8 ) begin
								ff_main_state		<= st_byte_wnr_test;
							end
							else begin
								ff_main_state		<= st_read_loop;
							end
						end
						else begin
							ff_dram_data[0]		<= dram_rdata[ 15:  0];
							ff_dram_data[1]		<= dram_rdata[ 31: 16];
							ff_dram_data[2]		<= dram_rdata[ 47: 32];
							ff_dram_data[3]		<= dram_rdata[ 63: 48];
							ff_dram_data[4]		<= dram_rdata[ 79: 64];
							ff_dram_data[5]		<= dram_rdata[ 95: 80];
							ff_dram_data[6]		<= dram_rdata[111: 96];
							ff_dram_data[7]		<= dram_rdata[127:112];
							ff_main_state		<= st_read_error;
						end
					end
				end
			st_byte_wnr_test:
				//	Byte W/R の表示要求 ---------------------------------------
				begin
					ff_led				<= 6'b110000;
					ff_print_begin		<= s_byte_wr_test;
					ff_print_start		<= 1'b1;
					ff_main_state		<= ff_main_state + 8'd1;
				end
			st_read_wnr_test_wait:
				//	Byte W/R の表示完了待ち -----------------------------------
				begin
					ff_led				<= 6'b001111;
					if( ff_print_state == pst_finish ) begin
						ff_print_start		<= 1'b0;
						ff_main_state		<= st_byte_write0;
					end
				end
			st_byte_write0:
				//	XX-XX-XX-XX-XX-XX-XX-XX-XX-XX-XX-XX-XX-XX-XX-10 を書き込み 
				begin
					ff_dram_address		<= 27'd0;
					ff_dram_write		<= 1'b1;
					ff_dram_wdata[0]	<= 16'h1010;
					ff_dram_wdata[1]	<= 16'h1010;
					ff_dram_wdata[2]	<= 16'h1010;
					ff_dram_wdata[3]	<= 16'h1010;
					ff_dram_wdata[4]	<= 16'h1010;
					ff_dram_wdata[5]	<= 16'h1010;
					ff_dram_wdata[6]	<= 16'h1010;
					ff_dram_wdata[7]	<= 16'h1010;
					ff_dram_wdata_mask	<= 16'hFFFE;
					ff_main_state		<= ff_main_state + 8'd1;
					ff_dram_valid		<= 1'b1;
				end
			st_byte_write1:
				//	XX-XX-XX-XX-XX-XX-XX-XX-XX-XX-XX-XX-XX-XX-32-XX を書き込み 
				if( dram_ready ) begin
					ff_dram_address		<= 27'd0;
					ff_dram_write		<= 1'b1;
					ff_dram_wdata[0]	<= 16'h3232;
					ff_dram_wdata[1]	<= 16'h3232;
					ff_dram_wdata[2]	<= 16'h3232;
					ff_dram_wdata[3]	<= 16'h3232;
					ff_dram_wdata[4]	<= 16'h3232;
					ff_dram_wdata[5]	<= 16'h3232;
					ff_dram_wdata[6]	<= 16'h3232;
					ff_dram_wdata[7]	<= 16'h3232;
					ff_dram_wdata_mask	<= 16'hFFFD;
					ff_main_state		<= ff_main_state + 8'd1;
					ff_dram_valid		<= 1'b1;
				end
			st_byte_write2:
				//	XX-XX-XX-XX-XX-XX-XX-XX-XX-XX-XX-XX-XX-54-XX-XX を書き込み 
				if( dram_ready ) begin
					ff_dram_address		<= 27'd0;
					ff_dram_write		<= 1'b1;
					ff_dram_wdata[0]	<= 16'h5454;
					ff_dram_wdata[1]	<= 16'h5454;
					ff_dram_wdata[2]	<= 16'h5454;
					ff_dram_wdata[3]	<= 16'h5454;
					ff_dram_wdata[4]	<= 16'h5454;
					ff_dram_wdata[5]	<= 16'h5454;
					ff_dram_wdata[6]	<= 16'h5454;
					ff_dram_wdata[7]	<= 16'h5454;
					ff_dram_wdata_mask	<= 16'hFFFB;
					ff_main_state		<= ff_main_state + 8'd1;
					ff_dram_valid		<= 1'b1;
				end
			st_byte_write3:
				//	XX-XX-XX-XX-XX-XX-XX-XX-XX-XX-XX-XX-76-XX-XX-XX を書き込み 
				if( dram_ready ) begin
					ff_dram_address		<= 27'd0;
					ff_dram_write		<= 1'b1;
					ff_dram_wdata[0]	<= 16'h7676;
					ff_dram_wdata[1]	<= 16'h7676;
					ff_dram_wdata[2]	<= 16'h7676;
					ff_dram_wdata[3]	<= 16'h7676;
					ff_dram_wdata[4]	<= 16'h7676;
					ff_dram_wdata[5]	<= 16'h7676;
					ff_dram_wdata[6]	<= 16'h7676;
					ff_dram_wdata[7]	<= 16'h7676;
					ff_dram_wdata_mask	<= 16'hFFF7;
					ff_main_state		<= ff_main_state + 8'd1;
					ff_dram_valid		<= 1'b1;
				end
			st_byte_write4:
				//	XX-XX-XX-XX-XX-XX-XX-XX-XX-XX-XX-98-XX-XX-XX-XX を書き込み 
				if( dram_ready ) begin
					ff_dram_address		<= 27'd0;
					ff_dram_write		<= 1'b1;
					ff_dram_wdata[0]	<= 16'h9898;
					ff_dram_wdata[1]	<= 16'h9898;
					ff_dram_wdata[2]	<= 16'h9898;
					ff_dram_wdata[3]	<= 16'h9898;
					ff_dram_wdata[4]	<= 16'h9898;
					ff_dram_wdata[5]	<= 16'h9898;
					ff_dram_wdata[6]	<= 16'h9898;
					ff_dram_wdata[7]	<= 16'h9898;
					ff_dram_wdata_mask	<= 16'hFFEF;
					ff_main_state		<= ff_main_state + 8'd1;
					ff_dram_valid		<= 1'b1;
				end
			st_byte_write5:
				//	XX-XX-XX-XX-XX-XX-XX-XX-XX-XX-BA-XX-XX-XX-XX-XX を書き込み 
				if( dram_ready ) begin
					ff_dram_address		<= 27'd0;
					ff_dram_write		<= 1'b1;
					ff_dram_wdata[0]	<= 16'hBABA;
					ff_dram_wdata[1]	<= 16'hBABA;
					ff_dram_wdata[2]	<= 16'hBABA;
					ff_dram_wdata[3]	<= 16'hBABA;
					ff_dram_wdata[4]	<= 16'hBABA;
					ff_dram_wdata[5]	<= 16'hBABA;
					ff_dram_wdata[6]	<= 16'hBABA;
					ff_dram_wdata[7]	<= 16'hBABA;
					ff_dram_wdata_mask	<= 16'hFFDF;
					ff_main_state		<= ff_main_state + 8'd1;
					ff_dram_valid		<= 1'b1;
				end
			st_byte_write6:
				//	XX-XX-XX-XX-XX-XX-XX-XX-XX-DC-XX-XX-XX-XX-XX-XX を書き込み 
				if( dram_ready ) begin
					ff_dram_address		<= 27'd0;
					ff_dram_write		<= 1'b1;
					ff_dram_wdata[0]	<= 16'hDCDC;
					ff_dram_wdata[1]	<= 16'hDCDC;
					ff_dram_wdata[2]	<= 16'hDCDC;
					ff_dram_wdata[3]	<= 16'hDCDC;
					ff_dram_wdata[4]	<= 16'hDCDC;
					ff_dram_wdata[5]	<= 16'hDCDC;
					ff_dram_wdata[6]	<= 16'hDCDC;
					ff_dram_wdata[7]	<= 16'hDCDC;
					ff_dram_wdata_mask	<= 16'hFFBF;
					ff_main_state		<= ff_main_state + 8'd1;
					ff_dram_valid		<= 1'b1;
				end
			st_byte_write7:
				//	XX-XX-XX-XX-XX-XX-XX-XX-FE-XX-XX-XX-XX-XX-XX-XX を書き込み 
				if( dram_ready ) begin
					ff_dram_address		<= 27'd0;
					ff_dram_write		<= 1'b1;
					ff_dram_wdata[0]	<= 16'hFEFE;
					ff_dram_wdata[1]	<= 16'hFEFE;
					ff_dram_wdata[2]	<= 16'hFEFE;
					ff_dram_wdata[3]	<= 16'hFEFE;
					ff_dram_wdata[4]	<= 16'hFEFE;
					ff_dram_wdata[5]	<= 16'hFEFE;
					ff_dram_wdata[6]	<= 16'hFEFE;
					ff_dram_wdata[7]	<= 16'hFEFE;
					ff_dram_wdata_mask	<= 16'hFF7F;
					ff_main_state		<= ff_main_state + 8'd1;
					ff_dram_valid		<= 1'b1;
				end
			st_byte_write8:
				//	XX-XX-XX-XX-XX-XX-XX-01-XX-XX-XX-XX-XX-XX-XX-XX を書き込み 
				if( dram_ready ) begin
					ff_dram_address		<= 27'd0;
					ff_dram_write		<= 1'b1;
					ff_dram_wdata[0]	<= 16'h0101;
					ff_dram_wdata[1]	<= 16'h0101;
					ff_dram_wdata[2]	<= 16'h0101;
					ff_dram_wdata[3]	<= 16'h0101;
					ff_dram_wdata[4]	<= 16'h0101;
					ff_dram_wdata[5]	<= 16'h0101;
					ff_dram_wdata[6]	<= 16'h0101;
					ff_dram_wdata[7]	<= 16'h0101;
					ff_dram_wdata_mask	<= 16'hFEFF;
					ff_main_state		<= ff_main_state + 8'd1;
					ff_dram_valid		<= 1'b1;
				end
			st_byte_write9:
				//	XX-XX-XX-XX-XX-XX-23-XX-XX-XX-XX-XX-XX-XX-XX-XX を書き込み 
				if( dram_ready ) begin
					ff_dram_address		<= 27'd0;
					ff_dram_write		<= 1'b1;
					ff_dram_wdata[0]	<= 16'h2323;
					ff_dram_wdata[1]	<= 16'h2323;
					ff_dram_wdata[2]	<= 16'h2323;
					ff_dram_wdata[3]	<= 16'h2323;
					ff_dram_wdata[4]	<= 16'h2323;
					ff_dram_wdata[5]	<= 16'h2323;
					ff_dram_wdata[6]	<= 16'h2323;
					ff_dram_wdata[7]	<= 16'h2323;
					ff_dram_wdata_mask	<= 16'hFDFF;
					ff_main_state		<= ff_main_state + 8'd1;
					ff_dram_valid		<= 1'b1;
				end
			st_byte_write10:
				//	XX-XX-XX-XX-XX-45-XX-XX-XX-XX-XX-XX-XX-XX-XX-XX を書き込み 
				if( dram_ready ) begin
					ff_dram_address		<= 27'd0;
					ff_dram_write		<= 1'b1;
					ff_dram_wdata[0]	<= 16'h4545;
					ff_dram_wdata[1]	<= 16'h4545;
					ff_dram_wdata[2]	<= 16'h4545;
					ff_dram_wdata[3]	<= 16'h4545;
					ff_dram_wdata[4]	<= 16'h4545;
					ff_dram_wdata[5]	<= 16'h4545;
					ff_dram_wdata[6]	<= 16'h4545;
					ff_dram_wdata[7]	<= 16'h4545;
					ff_dram_wdata_mask	<= 16'hFBFF;
					ff_main_state		<= ff_main_state + 8'd1;
					ff_dram_valid		<= 1'b1;
				end
			st_byte_write11:
				//	XX-XX-XX-XX-67-XX-XX-XX-XX-XX-XX-XX-XX-XX-XX-XX を書き込み 
				if( dram_ready ) begin
					ff_dram_address		<= 27'd0;
					ff_dram_write		<= 1'b1;
					ff_dram_wdata[0]	<= 16'h6767;
					ff_dram_wdata[1]	<= 16'h6767;
					ff_dram_wdata[2]	<= 16'h6767;
					ff_dram_wdata[3]	<= 16'h6767;
					ff_dram_wdata[4]	<= 16'h6767;
					ff_dram_wdata[5]	<= 16'h6767;
					ff_dram_wdata[6]	<= 16'h6767;
					ff_dram_wdata[7]	<= 16'h6767;
					ff_dram_wdata_mask	<= 16'hF7FF;
					ff_main_state		<= ff_main_state + 8'd1;
					ff_dram_valid		<= 1'b1;
				end
			st_byte_write12:
				//	XX-XX-XX-89-XX-XX-XX-XX-XX-XX-XX-XX-XX-XX-XX-XX を書き込み 
				if( dram_ready ) begin
					ff_dram_address		<= 27'd0;
					ff_dram_write		<= 1'b1;
					ff_dram_wdata[0]	<= 16'h8989;
					ff_dram_wdata[1]	<= 16'h8989;
					ff_dram_wdata[2]	<= 16'h8989;
					ff_dram_wdata[3]	<= 16'h8989;
					ff_dram_wdata[4]	<= 16'h8989;
					ff_dram_wdata[5]	<= 16'h8989;
					ff_dram_wdata[6]	<= 16'h8989;
					ff_dram_wdata[7]	<= 16'h8989;
					ff_dram_wdata_mask	<= 16'hEFFF;
					ff_main_state		<= ff_main_state + 8'd1;
					ff_dram_valid		<= 1'b1;
				end
			st_byte_write13:
				//	XX-XX-AB-XX-XX-XX-XX-XX-XX-XX-XX-XX-XX-XX-XX-XX を書き込み 
				if( dram_ready ) begin
					ff_dram_address		<= 27'd0;
					ff_dram_write		<= 1'b1;
					ff_dram_wdata[0]	<= 16'hABAB;
					ff_dram_wdata[1]	<= 16'hABAB;
					ff_dram_wdata[2]	<= 16'hABAB;
					ff_dram_wdata[3]	<= 16'hABAB;
					ff_dram_wdata[4]	<= 16'hABAB;
					ff_dram_wdata[5]	<= 16'hABAB;
					ff_dram_wdata[6]	<= 16'hABAB;
					ff_dram_wdata[7]	<= 16'hABAB;
					ff_dram_wdata_mask	<= 16'hDFFF;
					ff_main_state		<= ff_main_state + 8'd1;
					ff_dram_valid		<= 1'b1;
				end
			st_byte_write14:
				//	XX-CD-XX-XX-XX-XX-XX-XX-XX-XX-XX-XX-XX-XX-XX-XX を書き込み 
				if( dram_ready ) begin
					ff_dram_address		<= 27'd0;
					ff_dram_write		<= 1'b1;
					ff_dram_wdata[0]	<= 16'hCDCD;
					ff_dram_wdata[1]	<= 16'hCDCD;
					ff_dram_wdata[2]	<= 16'hCDCD;
					ff_dram_wdata[3]	<= 16'hCDCD;
					ff_dram_wdata[4]	<= 16'hCDCD;
					ff_dram_wdata[5]	<= 16'hCDCD;
					ff_dram_wdata[6]	<= 16'hCDCD;
					ff_dram_wdata[7]	<= 16'hCDCD;
					ff_dram_wdata_mask	<= 16'hBFFF;
					ff_main_state		<= ff_main_state + 8'd1;
					ff_dram_valid		<= 1'b1;
				end
			st_byte_write15:
				//	EF-XX-XX-XX-XX-XX-XX-XX-XX-XX-XX-XX-XX-XX-XX-XX を書き込み 
				if( dram_ready ) begin
					ff_dram_address		<= 27'd0;
					ff_dram_write		<= 1'b1;
					ff_dram_wdata[0]	<= 16'hEFEF;
					ff_dram_wdata[1]	<= 16'hEFEF;
					ff_dram_wdata[2]	<= 16'hEFEF;
					ff_dram_wdata[3]	<= 16'hEFEF;
					ff_dram_wdata[4]	<= 16'hEFEF;
					ff_dram_wdata[5]	<= 16'hEFEF;
					ff_dram_wdata[6]	<= 16'hEFEF;
					ff_dram_wdata[7]	<= 16'hEFEF;
					ff_dram_wdata_mask	<= 16'h7FFF;
					ff_main_state		<= ff_main_state + 8'd1;
					ff_dram_valid		<= 1'b1;
				end
			st_byte_write16:
				//	6F-FF-5E-EE-4D-DD-3C-CC-2V-VV-1A-AA-BE-EF-DE-AD を書き込み 
				if( dram_ready ) begin
					ff_dram_address		<= 27'h4000000;
					ff_dram_write		<= 1'b1;
					ff_dram_wdata[0]	<= 16'hDEAD;
					ff_dram_wdata[1]	<= 16'hBEEF;
					ff_dram_wdata[2]	<= 16'h1AAA;
					ff_dram_wdata[3]	<= 16'h2BBB;
					ff_dram_wdata[4]	<= 16'h3CCC;
					ff_dram_wdata[5]	<= 16'h4DDD;
					ff_dram_wdata[6]	<= 16'h5EEE;
					ff_dram_wdata[7]	<= 16'h6FFF;
					ff_dram_wdata_mask	<= 16'h0000;
					ff_main_state		<= ff_main_state + 8'd1;
					ff_dram_valid		<= 1'b1;
				end
			st_byte_read:
				//	読み出し --------------------------------------------------
				if( dram_ready ) begin
					ff_dram_address		<= 27'd0;
					ff_dram_write		<= 1'b0;
					ff_dram_wdata[0]	<= 16'hAA55;
					ff_dram_wdata[1]	<= 16'hAA55;
					ff_dram_wdata[2]	<= 16'hAA55;
					ff_dram_wdata[3]	<= 16'hAA55;
					ff_dram_wdata[4]	<= 16'hAA55;
					ff_dram_wdata[5]	<= 16'hAA55;
					ff_dram_wdata[6]	<= 16'hAA55;
					ff_dram_wdata[7]	<= 16'hAA55;
					ff_dram_wdata_mask	<= 16'h0000;
					ff_main_state		<= ff_main_state + 8'd1;
					ff_dram_valid		<= 1'b1;
				end
			st_byte_read_wait:
				//	読み出し完了待ち ------------------------------------------
				if( dram_ready ) begin
					ff_dram_valid		<= 1'b0;
					ff_main_state		<= ff_main_state + 8'd1;
				end
			st_byte_read_data_wait:
				//	読み出し結果受け取りと B:address=data の表示要求 ----------
				if( refresh_ack ) begin
					ff_dram_data[0]		<= dram_rdata[ 15:  0];
					ff_dram_data[1]		<= dram_rdata[ 31: 16];
					ff_dram_data[2]		<= dram_rdata[ 47: 32];
					ff_dram_data[3]		<= dram_rdata[ 63: 48];
					ff_dram_data[4]		<= dram_rdata[ 79: 64];
					ff_dram_data[5]		<= dram_rdata[ 95: 80];
					ff_dram_data[6]		<= dram_rdata[111: 96];
					ff_dram_data[7]		<= dram_rdata[127:112];
					ff_print_begin		<= s_byte_wr_result;
					ff_print_start		<= 1'b1;
					ff_main_state		<= ff_main_state + 8'd1;
				end
			st_byte_wnr_result:
				//	B:address=data の表示完了待ち -----------------------------
				if( ff_print_state == pst_finish ) begin
					ff_print_start		<= 1'b0;
					ff_main_state		<= ff_main_state + 8'd1;
				end
			st_byte_read2:
				//	読み出し --------------------------------------------------
				if( dram_ready ) begin
					ff_dram_address		<= 27'd1;
					ff_dram_write		<= 1'b0;
					ff_dram_wdata[0]	<= 16'hAA55;
					ff_dram_wdata[1]	<= 16'hAA55;
					ff_dram_wdata[2]	<= 16'hAA55;
					ff_dram_wdata[3]	<= 16'hAA55;
					ff_dram_wdata[4]	<= 16'hAA55;
					ff_dram_wdata[5]	<= 16'hAA55;
					ff_dram_wdata[6]	<= 16'hAA55;
					ff_dram_wdata[7]	<= 16'hAA55;
					ff_dram_wdata_mask	<= 16'h0000;
					ff_main_state		<= ff_main_state + 8'd1;
					ff_dram_valid		<= 1'b1;
				end
			st_byte_read_wait2:
				//	読み出し完了待ち ------------------------------------------
				if( dram_ready ) begin
					ff_dram_valid		<= 1'b0;
					ff_main_state		<= ff_main_state + 8'd1;
				end
			st_byte_read_data_wait2:
				//	読み出し結果受け取りと B:address=data の表示要求 ----------
				if( refresh_ack ) begin
					ff_dram_data[0]		<= dram_rdata[ 15:  0];
					ff_dram_data[1]		<= dram_rdata[ 31: 16];
					ff_dram_data[2]		<= dram_rdata[ 47: 32];
					ff_dram_data[3]		<= dram_rdata[ 63: 48];
					ff_dram_data[4]		<= dram_rdata[ 79: 64];
					ff_dram_data[5]		<= dram_rdata[ 95: 80];
					ff_dram_data[6]		<= dram_rdata[111: 96];
					ff_dram_data[7]		<= dram_rdata[127:112];
					ff_print_begin		<= s_byte_wr_result;
					ff_print_start		<= 1'b1;
					ff_main_state		<= ff_main_state + 8'd1;
				end
			st_byte_wnr_result2:
				//	B:address=data の表示完了待ち -----------------------------
				if( ff_print_state == pst_finish ) begin
					ff_print_start		<= 1'b0;
					ff_main_state		<= ff_main_state + 8'd1;
				end
			st_byte_read3:
				//	読み出し --------------------------------------------------
				if( dram_ready ) begin
					ff_dram_address		<= 27'd2;
					ff_dram_write		<= 1'b0;
					ff_dram_wdata[0]	<= 16'hAA55;
					ff_dram_wdata[1]	<= 16'hAA55;
					ff_dram_wdata[2]	<= 16'hAA55;
					ff_dram_wdata[3]	<= 16'hAA55;
					ff_dram_wdata[4]	<= 16'hAA55;
					ff_dram_wdata[5]	<= 16'hAA55;
					ff_dram_wdata[6]	<= 16'hAA55;
					ff_dram_wdata[7]	<= 16'hAA55;
					ff_dram_wdata_mask	<= 16'h0000;
					ff_main_state		<= ff_main_state + 8'd1;
					ff_dram_valid		<= 1'b1;
				end
			st_byte_read_wait3:
				//	読み出し完了待ち ------------------------------------------
				if( dram_ready ) begin
					ff_dram_valid		<= 1'b0;
					ff_main_state		<= ff_main_state + 8'd1;
				end
			st_byte_read_data_wait3:
				//	読み出し結果受け取りと B:address=data の表示要求 ----------
				if( refresh_ack ) begin
					ff_dram_data[0]		<= dram_rdata[ 15:  0];
					ff_dram_data[1]		<= dram_rdata[ 31: 16];
					ff_dram_data[2]		<= dram_rdata[ 47: 32];
					ff_dram_data[3]		<= dram_rdata[ 63: 48];
					ff_dram_data[4]		<= dram_rdata[ 79: 64];
					ff_dram_data[5]		<= dram_rdata[ 95: 80];
					ff_dram_data[6]		<= dram_rdata[111: 96];
					ff_dram_data[7]		<= dram_rdata[127:112];
					ff_print_begin		<= s_byte_wr_result;
					ff_print_start		<= 1'b1;
					ff_main_state		<= ff_main_state + 8'd1;
				end
			st_byte_wnr_result3:
				//	B:address=data の表示完了待ち -----------------------------
				if( ff_print_state == pst_finish ) begin
					ff_print_start		<= 1'b0;
					ff_main_state		<= ff_main_state + 8'd1;
				end
			st_byte_read4:
				//	読み出し --------------------------------------------------
				if( dram_ready ) begin
					ff_dram_address		<= 27'h4000000;
					ff_dram_write		<= 1'b0;
					ff_dram_wdata[0]	<= 16'hAA55;
					ff_dram_wdata[1]	<= 16'hAA55;
					ff_dram_wdata[2]	<= 16'hAA55;
					ff_dram_wdata[3]	<= 16'hAA55;
					ff_dram_wdata[4]	<= 16'hAA55;
					ff_dram_wdata[5]	<= 16'hAA55;
					ff_dram_wdata[6]	<= 16'hAA55;
					ff_dram_wdata[7]	<= 16'hAA55;
					ff_dram_wdata_mask	<= 16'h0000;
					ff_main_state		<= ff_main_state + 8'd1;
					ff_dram_valid		<= 1'b1;
				end
			st_byte_read_wait4:
				//	読み出し完了待ち ------------------------------------------
				if( dram_ready ) begin
					ff_dram_valid		<= 1'b0;
					ff_main_state		<= ff_main_state + 8'd1;
				end
			st_byte_read_data_wait4:
				//	読み出し結果受け取りと B:address=data の表示要求 ----------
				if( refresh_ack ) begin
					ff_dram_data[0]		<= dram_rdata[ 15:  0];
					ff_dram_data[1]		<= dram_rdata[ 31: 16];
					ff_dram_data[2]		<= dram_rdata[ 47: 32];
					ff_dram_data[3]		<= dram_rdata[ 63: 48];
					ff_dram_data[4]		<= dram_rdata[ 79: 64];
					ff_dram_data[5]		<= dram_rdata[ 95: 80];
					ff_dram_data[6]		<= dram_rdata[111: 96];
					ff_dram_data[7]		<= dram_rdata[127:112];
					ff_print_begin		<= s_byte_wr_result;
					ff_print_start		<= 1'b1;
					ff_main_state		<= ff_main_state + 8'd1;
				end
			st_byte_wnr_result4:
				//	B:address=data の表示完了待ち -----------------------------
				if( ff_print_state == pst_finish ) begin
					ff_print_start		<= 1'b0;
					ff_main_state		<= ff_main_state + 8'd1;
				end
			st_byte_read5:
				//	読み出し --------------------------------------------------
				if( dram_ready ) begin
					ff_dram_address		<= 27'h4000001;
					ff_dram_write		<= 1'b0;
					ff_dram_wdata[0]	<= 16'hAA55;
					ff_dram_wdata[1]	<= 16'hAA55;
					ff_dram_wdata[2]	<= 16'hAA55;
					ff_dram_wdata[3]	<= 16'hAA55;
					ff_dram_wdata[4]	<= 16'hAA55;
					ff_dram_wdata[5]	<= 16'hAA55;
					ff_dram_wdata[6]	<= 16'hAA55;
					ff_dram_wdata[7]	<= 16'hAA55;
					ff_dram_wdata_mask	<= 16'h0000;
					ff_main_state		<= ff_main_state + 8'd1;
					ff_dram_valid		<= 1'b1;
				end
			st_byte_read_wait5:
				//	読み出し完了待ち ------------------------------------------
				if( dram_ready ) begin
					ff_dram_valid		<= 1'b0;
					ff_main_state		<= ff_main_state + 8'd1;
				end
			st_byte_read_data_wait5:
				//	読み出し結果受け取りと B:address=data の表示要求 ----------
				if( refresh_ack ) begin
					ff_dram_data[0]		<= dram_rdata[ 15:  0];
					ff_dram_data[1]		<= dram_rdata[ 31: 16];
					ff_dram_data[2]		<= dram_rdata[ 47: 32];
					ff_dram_data[3]		<= dram_rdata[ 63: 48];
					ff_dram_data[4]		<= dram_rdata[ 79: 64];
					ff_dram_data[5]		<= dram_rdata[ 95: 80];
					ff_dram_data[6]		<= dram_rdata[111: 96];
					ff_dram_data[7]		<= dram_rdata[127:112];
					ff_print_begin		<= s_byte_wr_result;
					ff_print_start		<= 1'b1;
					ff_main_state		<= ff_main_state + 8'd1;
				end
			st_byte_wnr_result5:
				//	B:address=data の表示完了待ち -----------------------------
				if( ff_print_state == pst_finish ) begin
					ff_print_start		<= 1'b0;
					ff_main_state		<= ff_main_state + 8'd1;
				end
			st_byte_read6:
				//	読み出し --------------------------------------------------
				if( dram_ready ) begin
					ff_dram_address		<= 27'h4000002;
					ff_dram_write		<= 1'b0;
					ff_dram_wdata[0]	<= 16'hAA55;
					ff_dram_wdata[1]	<= 16'hAA55;
					ff_dram_wdata[2]	<= 16'hAA55;
					ff_dram_wdata[3]	<= 16'hAA55;
					ff_dram_wdata[4]	<= 16'hAA55;
					ff_dram_wdata[5]	<= 16'hAA55;
					ff_dram_wdata[6]	<= 16'hAA55;
					ff_dram_wdata[7]	<= 16'hAA55;
					ff_dram_wdata_mask	<= 16'h0000;
					ff_main_state		<= ff_main_state + 8'd1;
					ff_dram_valid		<= 1'b1;
				end
			st_byte_read_wait6:
				//	読み出し完了待ち ------------------------------------------
				if( dram_ready ) begin
					ff_dram_valid		<= 1'b0;
					ff_main_state		<= ff_main_state + 8'd1;
				end
			st_byte_read_data_wait6:
				//	読み出し結果受け取りと B:address=data の表示要求 ----------
				if( refresh_ack ) begin
					ff_dram_data[0]		<= dram_rdata[ 15:  0];
					ff_dram_data[1]		<= dram_rdata[ 31: 16];
					ff_dram_data[2]		<= dram_rdata[ 47: 32];
					ff_dram_data[3]		<= dram_rdata[ 63: 48];
					ff_dram_data[4]		<= dram_rdata[ 79: 64];
					ff_dram_data[5]		<= dram_rdata[ 95: 80];
					ff_dram_data[6]		<= dram_rdata[111: 96];
					ff_dram_data[7]		<= dram_rdata[127:112];
					ff_print_begin		<= s_byte_wr_result;
					ff_print_start		<= 1'b1;
					ff_main_state		<= ff_main_state + 8'd1;
				end
			st_byte_wnr_result6:
				//	B:address=data の表示完了待ち -----------------------------
				if( ff_print_state == pst_finish ) begin
					ff_print_start		<= 1'b0;
					ff_main_state		<= st_print_read_wait_count;
				end
			st_print_read_wait_count:
				//	Read Wait Count の表示 ----------------------------------------
				begin
					ff_dram_data[0]			<= { 8'd0, ff_read_wait_count_max };
					ff_dram_data[1]			<= { 8'd0, ff_read_wait_count     };
					ff_dram_data[2]			<= 16'd0;
					ff_dram_data[3]			<= 16'd0;
					ff_dram_data[4]			<= 16'd0;
					ff_dram_data[5]			<= 16'd0;
					ff_dram_data[6]			<= 16'd0;
					ff_dram_data[7]			<= 16'd0;
					ff_print_begin			<= s_count;
					ff_print_start			<= 1'b1;
					ff_main_state			<= ff_main_state + 8'd1;
				end
			st_print_read_wait_count_end:
				if( ff_print_state == pst_finish ) begin
					ff_print_start		<= 1'b0;
					ff_main_state		<= st_finish;
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
						ff_dram_wdata[0]	<= ff_dram_wdata[0] + c_increment_data0;
						ff_dram_wdata[1]	<= ff_dram_wdata[1] + c_increment_data1;
						ff_dram_wdata[2]	<= ff_dram_wdata[2] + c_increment_data2;
						ff_dram_wdata[3]	<= ff_dram_wdata[3] + c_increment_data3;
						ff_dram_wdata[4]	<= ff_dram_wdata[4] + c_increment_data4;
						ff_dram_wdata[5]	<= ff_dram_wdata[5] + c_increment_data5;
						ff_dram_wdata[6]	<= ff_dram_wdata[6] + c_increment_data6;
						ff_dram_wdata[7]	<= ff_dram_wdata[7] + c_increment_data7;
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
	assign dram_wdata			= { ff_dram_wdata[7], ff_dram_wdata[6], ff_dram_wdata[5], ff_dram_wdata[4], ff_dram_wdata[3], ff_dram_wdata[2], ff_dram_wdata[1], ff_dram_wdata[0] };
	assign dram_wdata_mask		= ff_dram_wdata_mask;
endmodule
