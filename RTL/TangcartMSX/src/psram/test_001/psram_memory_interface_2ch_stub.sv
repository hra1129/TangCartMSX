module PSRAM_Memory_Interface_2CH_Top(
	input clk,
	input rst_n,
	output [1:0] O_psram_ck,
	output [1:0] O_psram_ck_n,
	inout [1:0] IO_psram_rwds,
	output [1:0] O_psram_reset_n,
	inout [15:0] IO_psram_dq,
	output [1:0] O_psram_cs_n,
	output init_calib0,
	output init_calib1,
	output clk_out,
	input cmd0,
	input cmd1,
	input cmd_en0,
	input cmd_en1,
	input [20:0] addr0,
	input [20:0] addr1,
	input [31:0] wr_data0,
	input [31:0] wr_data1,
	output [31:0] rd_data0,
	output [31:0] rd_data1,
	output rd_data_valid0,
	output rd_data_valid1,
	input [3:0] data_mask0,
	input [3:0] data_mask1,
	input memory_clk,
	input pll_lock
);
	reg				ff_cmd0;
	reg				ff_cmd1;
	reg				ff_cmd0_en;
	reg				ff_cmd1_en;
	reg		[3:0]	ff_cmd0_cyc;
	reg		[3:0]	ff_cmd1_cyc;
	reg				ff_rd_data_valid0;
	reg				ff_rd_data_valid1;
	reg		[31:0]	ff_rd_data0;
	reg		[31:0]	ff_rd_data1;
	reg		[7:0]	ff_initial_timer;

	// --------------------------------------------------------------------
	//	initial timer
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !rst_n ) begin
			ff_initial_timer <= 'd0;
		end
		else if( ff_initial_timer != 'd255 ) begin
			ff_initial_timer <= ff_initial_timer + 'd1;
		end
	end

	assign init_calib0 = (ff_initial_timer == 'd255) ? 1'b1 : 1'b0;
	assign init_calib1 = (ff_initial_timer == 'd255) ? 1'b1 : 1'b0;

	// --------------------------------------------------------------------
	//	ch0 dummy
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !rst_n ) begin
			ff_cmd0 <= 1'b0;
			ff_cmd0_en <= 1'b0;
			ff_cmd0_cyc <= 'd0;
		end
		else if( cmd_en0 ) begin
			assert( ff_cmd0_en == 1'b0 ) $display( "Enter CMD_EN0" ); else $display( "[ERROR!!] BAD CMD_EN0" );
			ff_cmd0_en <= 1'b1;
			ff_cmd0 <= cmd0;
			if( cmd0 == 1'b0 ) begin
				//	case of read
				ff_cmd0_cyc <= 'd10;
			end
			else begin
				//	case of write
				ff_cmd0_cyc <= 'd10;
			end
		end
		else if( ff_cmd0_cyc != 'd0 ) begin
			ff_cmd0_cyc <= ff_cmd0_cyc - 'd1;
		end
		else begin
			ff_cmd0 <= 1'b0;
			ff_cmd0_en <= 1'b0;
		end
	end

	always @( posedge clk ) begin
		if( !rst_n ) begin
			ff_rd_data_valid0 <= 1'b0;
		end
		else if( ff_cmd0_en && !ff_cmd0 ) begin
			if( ff_cmd0_cyc == 'd4 ) begin
				ff_rd_data_valid0 <= 1'b1;
				ff_rd_data0 <= { 8'd100, 8'd101, 8'd102, 8'd103 };
			end
			else if( ff_cmd0_cyc == 'd0 ) begin
				ff_rd_data_valid0 <= 1'b0;
			end
			else begin
				ff_rd_data0 <= ff_rd_data0 + { 8'd1, 8'd1, 8'd1, 8'd1 };
			end
		end
	end

	assign rd_data0			= ff_rd_data0;
	assign rd_data_valid0	= ff_rd_data_valid0;

	// --------------------------------------------------------------------
	//	ch1 dummy
	// --------------------------------------------------------------------
	always @( posedge clk ) begin
		if( !rst_n ) begin
			ff_cmd1 <= 1'b0;
			ff_cmd1_en <= 1'b0;
			ff_cmd1_cyc <= 'd0;
		end
		else if( cmd_en1 ) begin
			assert( ff_cmd1_en == 1'b0 ) $display( "Enter CMD_EN1" ); else $display( "[ERROR!!] BAD CMD_EN1" );
			ff_cmd1_en <= 1'b1;
			ff_cmd1 <= cmd1;
			if( cmd1 == 1'b0 ) begin
				//	case of read
				ff_cmd1_cyc <= 'd10;
			end
			else begin
				//	case of write
				ff_cmd1_cyc <= 'd10;
			end
		end
		else if( ff_cmd1_cyc != 'd0 ) begin
			ff_cmd1_cyc <= ff_cmd1_cyc - 'd1;
		end
		else begin
			ff_cmd1 <= 1'b0;
			ff_cmd1_en <= 1'b0;
		end
	end

	always @( posedge clk ) begin
		if( !rst_n ) begin
			ff_rd_data_valid1 <= 1'b0;
		end
		else if( ff_cmd1_en && !ff_cmd1 ) begin
			if( ff_cmd1_cyc == 'd4 ) begin
				ff_rd_data_valid1 <= 1'b1;
				ff_rd_data1 <= { 8'd100, 8'd101, 8'd102, 8'd103 };
			end
			else if( ff_cmd1_cyc == 'd0 ) begin
				ff_rd_data_valid1 <= 1'b0;
			end
			else begin
				ff_rd_data1 <= ff_rd_data1 + { 8'd1, 8'd1, 8'd1, 8'd1 };
			end
		end
	end

	assign rd_data1			= ff_rd_data1;
	assign rd_data_valid1	= ff_rd_data_valid1;

	// --------------------------------------------------------------------
	//	Others
	// --------------------------------------------------------------------
	assign O_psram_ck = 'd0;
	assign O_psram_ck_n = 'd0;
	assign O_psram_reset_n = 'd0;
	assign O_psram_cs_n = 'd0;
	assign clk_out = 'd0;
	assign IO_psram_rwds = 'd0;
	assign IO_psram_dq = 'd0;
endmodule
