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
	input			sdram_init_busy,	//	0: Normal, 1: DDR3 SDRAM Initialization phase.
	input			bus_ioreq,			//	CPU-BUS
	input	[7:0]	bus_address,		//	CPU-BUS
	input			bus_write,			//	CPU-BUS
	input			bus_valid,			//	CPU-BUS
	output			bus_ready,			//	CPU-BUS
	input	[7:0]	bus_wdata,			//	CPU-BUS
	output	[7:0]	bus_rdata,			//	CPU-BUS
	output			bus_rdata_en,		//	CPU-BUS
	output	[26:0]	dram_address,		//	DDR3 Controller 64Mword/16bit: [26:24]=BANK, [23:10]=ROW, [9:0]=COLUMN
	output			dram_write,			//	DDR3 Controller Direction 0: Read, 1: Write
	output			dram_valid,			//	DDR3 Controller 
	input			dram_ready,			//	DDR3 Controller 0: Busy, 1: Ready
	output	[127:0]	dram_wdata,			//	DDR3 Controller 
	output	[15:0]	dram_wdata_mask,	//	DDR3 Controller 
	input	[127:0]	dram_rdata,			//	DDR3 Controller 
	input			dram_rdata_valid	//	DDR3 Controller 
);
	reg		[7:0]	ff_busy_count;		//	dram_ready が来るまでの時間
	reg		[7:0]	ff_delay_count;		//	dram_rdata_valid が来るまでの時間
	reg				ff_delay_end;		//	dram_rdata_valid が来ると 1 になる
	reg		[26:0]	ff_address;
	reg		[127:0]	ff_wdata;
	reg		[15:0]	ff_wdata_mask;
	reg		[127:0]	ff_rdata;
	reg				ff_write;
	reg				ff_valid;
	reg		[7:0]	ff_bus_rdata;
	reg				ff_bus_rdata_en;
	reg				ff_write_request	= 1'b0;
	reg				ff_read_request		= 1'b0;

	// --------------------------------------------------------------------
	//	I/O Read Access
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( bus_valid && !bus_write && bus_ioreq ) begin
			case( bus_address[7:0] )
			8'h20:	ff_bus_rdata	<= ff_rdata[  7:  0];
			8'h21:	ff_bus_rdata	<= ff_rdata[ 15:  8];
			8'h22:	ff_bus_rdata	<= ff_rdata[ 23: 16];
			8'h23:	ff_bus_rdata	<= ff_rdata[ 31: 24];
			8'h24:	ff_bus_rdata	<= ff_rdata[ 39: 32];
			8'h25:	ff_bus_rdata	<= ff_rdata[ 47: 40];
			8'h26:	ff_bus_rdata	<= ff_rdata[ 55: 48];
			8'h27:	ff_bus_rdata	<= ff_rdata[ 63: 56];
			8'h28:	ff_bus_rdata	<= ff_rdata[ 71: 64];
			8'h29:	ff_bus_rdata	<= ff_rdata[ 79: 72];
			8'h2A:	ff_bus_rdata	<= ff_rdata[ 87: 80];
			8'h2B:	ff_bus_rdata	<= ff_rdata[ 95: 88];
			8'h2C:	ff_bus_rdata	<= ff_rdata[103: 96];
			8'h2D:	ff_bus_rdata	<= ff_rdata[111:104];
			8'h2E:	ff_bus_rdata	<= ff_rdata[119:112];
			8'h2F:	ff_bus_rdata	<= ff_rdata[127:120];
			8'h30:	ff_bus_rdata	<= { sdram_init_busy, 6'd0, ~dram_ready };
			8'h31:	ff_bus_rdata	<= ff_busy_count;
			8'h32:	ff_bus_rdata	<= { 7'd0, ff_delay_end };
			8'h33:	ff_bus_rdata	<= ff_delay_count;
			endcase
			ff_bus_rdata_en <= 1'b1;
		end
		else begin
			ff_bus_rdata_en <= 1'b0;
		end
	end

	// --------------------------------------------------------------------
	//	I/O Write Access
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_write_request	<= 1'b0;
			ff_read_request		<= 1'b0;
		end
		else if( bus_valid && bus_write && bus_ioreq ) begin
			ff_write_request	<= 1'b0;
			ff_read_request		<= 1'b0;
			case( bus_address[7:0] )
			8'h20:	ff_wdata[  7:  0]	<= bus_wdata;
			8'h21:	ff_wdata[ 15:  8]	<= bus_wdata;
			8'h22:	ff_wdata[ 23: 16]	<= bus_wdata;
			8'h23:	ff_wdata[ 31: 24]	<= bus_wdata;
			8'h24:	ff_wdata[ 39: 32]	<= bus_wdata;
			8'h25:	ff_wdata[ 47: 40]	<= bus_wdata;
			8'h26:	ff_wdata[ 55: 48]	<= bus_wdata;
			8'h27:	ff_wdata[ 63: 56]	<= bus_wdata;
			8'h28:	ff_wdata[ 71: 64]	<= bus_wdata;
			8'h29:	ff_wdata[ 79: 72]	<= bus_wdata;
			8'h2A:	ff_wdata[ 87: 80]	<= bus_wdata;
			8'h2B:	ff_wdata[ 95: 88]	<= bus_wdata;
			8'h2C:	ff_wdata[103: 96]	<= bus_wdata;
			8'h2D:	ff_wdata[111:104]	<= bus_wdata;
			8'h2E:	ff_wdata[119:112]	<= bus_wdata;
			8'h2F:	ff_wdata[127:120]	<= bus_wdata;
			8'h30:	ff_wdata_mask[ 7:0]	<= bus_wdata;
			8'h31:	ff_wdata_mask[15:8]	<= bus_wdata;
			8'h32:	ff_address[ 7: 0]	<= bus_wdata;
			8'h33:	ff_address[15: 8]	<= bus_wdata;
			8'h34:	ff_address[23:16]	<= bus_wdata;
			8'h35:	ff_address[26:24]	<= bus_wdata[2:0];
			8'h36:	ff_write_request	<= 1'b1;
			8'h37:	ff_read_request		<= 1'b1;
			endcase
		end
		else begin
			ff_write_request	<= 1'b0;
			ff_read_request		<= 1'b0;
		end
	end

	// --------------------------------------------------------------------
	//	busy counter
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_busy_count <= 8'd0;
		end
		else if( ff_write_request || ff_read_request ) begin
			ff_busy_count <= 8'd0;
		end
		else if( !dram_ready ) begin
			if( ff_busy_count != 8'hFF ) begin
				ff_busy_count <= ff_busy_count + 8'd1;
			end
		end
		else begin
			//	hold
		end
	end

	// --------------------------------------------------------------------
	//	delay counter
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_delay_count	<= 8'd0;
			ff_delay_end	<= 1'b1;
		end
		else if( ff_write_request || ff_read_request ) begin
			ff_delay_count	<= 8'd0;
			ff_delay_end	<= 1'b0;
		end
		else if( dram_valid ) begin
			ff_delay_end	<= 1'b1;
		end
		else if( !ff_delay_end ) begin
			ff_delay_count	<= ff_delay_count + 8'd1;
		end
		else begin
			//	hold
		end
	end

	// --------------------------------------------------------------------
	//	DRAM Access
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_rdata <= 128'd0;
		end
		else if( dram_valid ) begin
			ff_rdata <= dram_rdata;
		end
	end

	always @( posedge clk ) begin
		if( !reset_n ) begin
			ff_write	<= 1'b0;
			ff_valid	<= 1'b0;
		end
		else if( ff_write_request ) begin
			ff_write	<= 1'b1;
			ff_valid	<= 1'b1;
		end
		else if( ff_read_request ) begin
			ff_write	<= 1'b0;
			ff_valid	<= 1'b1;
		end
		else if( dram_ready ) begin
			ff_write	<= 1'b0;
			ff_valid	<= 1'b0;
		end
		else begin
			//	hold
		end
	end

	assign dram_address		= ff_address;
	assign dram_write		= ff_write;
	assign dram_valid		= ff_valid;
	assign dram_wdata		= ff_wdata;
	assign dram_wdata_mask	= ff_wdata_mask;

	// --------------------------------------------------------------------
	//	CPU-BUS Response
	// --------------------------------------------------------------------
	assign bus_ready		= 1'b1;
	assign bus_rdata		= ff_bus_rdata_en ? ff_bus_rdata: 8'd0;
	assign bus_rdata_en		= ff_bus_rdata_en;
endmodule
