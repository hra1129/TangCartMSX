//
// vdp_wait_control.v
//	 VDP wait controller for VDP command
//	 Revision 1.00
//
// Copyright (c) 2024 Takayuki Hara
//
// Redistribution and use of this source code or any derivative works, are
// permitted provided that the following conditions are met:
//
// 1. Redistributions of source code must retain the above copyright notice,
//	  this list of conditions and the following disclaimer.
// 2. Redistributions in binary form must reproduce the above copyright
//	  notice, this list of conditions and the following disclaimer in the
//	  documentation and/or other materials provided with the distribution.
// 3. Redistributions may not be sold, nor may they be used in a commercial
//	  product or activity without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
// PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
// CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
// EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
// OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
// WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
// OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
// ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

module vdp_wait_control (
	input			reset,
	input			clk,
	input			enable,

	input	[7:4]	vdp_command,

	input			vdpr9palmode,		// 0=60hz (ntsc), 1=50hz (pal)
	input			reg_r1_disp_on,		// 0=display off, 1=display on
	input			reg_r8_sp_off,		// 0=sprite on, 1=sprite off
	input			reg_r9_y_dots,		// 0=192 lines, 1=212 lines

	input			vdp_speed_mode,
	input			drive,

	output			active
);
	reg		[15:0]	ff_wait_cnt;
	// sprite on, 212 lines, 50hz
	reg		[15:0]	c_wait_table_501 [0:15];
	// sprite on, 192 lines, 50hz
	reg		[15:0]	c_wait_table_502 [0:15];
	// sprite off, 212 lines, 50hz
	reg		[15:0]	c_wait_table_503 [0:15];
	// sprite off, 192 lines, 50hz
	reg		[15:0]	c_wait_table_504 [0:15];
	// blank, 50hz (test: sprite on, 212 lines)
	reg		[15:0]	c_wait_table_505 [0:15];
	// sprite on, 212 lines, 60hz
	reg		[15:0]	c_wait_table_601 [0:15];
	// sprite on, 192 lines, 60hz
	reg		[15:0]	c_wait_table_602 [0:15];
	// sprite off, 212 lines, 60hz
	reg		[15:0]	c_wait_table_603 [0:15];
	// sprite off, 192 lines, 60hz
	reg		[15:0]	c_wait_table_604 [0:15];
	// blank, 60hz (test: sprite on, 212 lines)
	reg		[15:0]	c_wait_table_605 [0:15];

	initial begin
		// sprite on, 212 lines, 50hz
		c_wait_table_501[ 0] = 16'h8000;	//	stop
		c_wait_table_501[ 1] = 16'h8000;	//	xxxx
		c_wait_table_501[ 2] = 16'h8000;	//	xxxx
		c_wait_table_501[ 3] = 16'h8000;	//	xxxx
		c_wait_table_501[ 4] = 16'h8000;	//	point
		c_wait_table_501[ 5] = 16'h8000;	//	pset
		c_wait_table_501[ 6] = 16'h19e4;	//	srch
		c_wait_table_501[ 7] = 16'h0f30;	//	line
		c_wait_table_501[ 8] = 16'h10f8;	//	lmmv
		c_wait_table_501[ 9] = 16'h1288;	//	lmmm
		c_wait_table_501[10] = 16'h8000;	//	lmcm
		c_wait_table_501[11] = 16'h8000;	//	lmmc
		c_wait_table_501[12] = 16'h119c;	//	hmmv
		c_wait_table_501[13] = 16'h1964;	//	hmmm
		c_wait_table_501[14] = 16'h1590;	//	ymmm
		c_wait_table_501[15] = 16'h8000;	//	hmmc

		// sprite on, 192 lines, 50hz
		c_wait_table_502[ 0] = 16'h8000;	//	stop
		c_wait_table_502[ 1] = 16'h8000;	//	xxxx
		c_wait_table_502[ 2] = 16'h8000;	//	xxxx
		c_wait_table_502[ 3] = 16'h8000;	//	xxxx
		c_wait_table_502[ 4] = 16'h8000;	//	poin
		c_wait_table_502[ 5] = 16'h8000;	//	pset
		c_wait_table_502[ 6] = 16'h18c8;	//	srch
		c_wait_table_502[ 7] = 16'h0e80;	//	line
		c_wait_table_502[ 8] = 16'h1018;	//	lmmv
		c_wait_table_502[ 9] = 16'h11b4;	//	lmmm
		c_wait_table_502[10] = 16'h8000;	//	lmcm
		c_wait_table_502[11] = 16'h8000;	//	lmmc
		c_wait_table_502[12] = 16'h10b0;	//	hmmv
		c_wait_table_502[13] = 16'h1848;	//	hmmm
		c_wait_table_502[14] = 16'h1514;	//	ymmm
		c_wait_table_502[15] = 16'h8000;	//	hmmc

		// sprite off, 212 lines, 50hz
		c_wait_table_503[ 0] = 16'h8000;	//	stop
		c_wait_table_503[ 1] = 16'h8000;	//	xxxx
		c_wait_table_503[ 2] = 16'h8000;	//	xxxx
		c_wait_table_503[ 3] = 16'h8000;	//	xxxx
		c_wait_table_503[ 4] = 16'h8000;	//	poin
		c_wait_table_503[ 5] = 16'h8000;	//	pset
		c_wait_table_503[ 6] = 16'h1678;	//	srch
		c_wait_table_503[ 7] = 16'h0a10;	//	line
		c_wait_table_503[ 8] = 16'h0ce4;	//	lmmv
		c_wait_table_503[ 9] = 16'h10ac;	//	lmmm
		c_wait_table_503[10] = 16'h8000;	//	lmcm
		c_wait_table_503[11] = 16'h8000;	//	lmmc
		c_wait_table_503[12] = 16'h0ca8;	//	hmmv
		c_wait_table_503[13] = 16'h15f8;	//	hmmm
		c_wait_table_503[14] = 16'h1520;	//	ymmm
		c_wait_table_503[15] = 16'h8000;	//	hmmc

		// sprite off, 192 lines, 50hz
		c_wait_table_504[ 0] = 16'h8000;	//	stop
		c_wait_table_504[ 1] = 16'h8000;	//	xxxx
		c_wait_table_504[ 2] = 16'h8000;	//	xxxx
		c_wait_table_504[ 3] = 16'h8000;	//	xxxx
		c_wait_table_504[ 4] = 16'h8000;	//	poin
		c_wait_table_504[ 5] = 16'h8000;	//	pset
		c_wait_table_504[ 6] = 16'h15b8;	//	srch
		c_wait_table_504[ 7] = 16'h0a00;	//	line
		c_wait_table_504[ 8] = 16'h0c78;	//	lmmv
		c_wait_table_504[ 9] = 16'h0ffc;	//	lmmm
		c_wait_table_504[10] = 16'h8000;	//	lmcm
		c_wait_table_504[11] = 16'h8000;	//	lmmc
		c_wait_table_504[12] = 16'h0c5c;	//	hmmv
		c_wait_table_504[13] = 16'h1538;	//	hmmm
		c_wait_table_504[14] = 16'h144c;	//	ymmm
		c_wait_table_504[15] = 16'h8000;	//	hmmc

		// blank, 50hz (test: sprite on, 212 lines)
		c_wait_table_505[ 0] = 16'h8000;	//	stop
		c_wait_table_505[ 1] = 16'h8000;	//	xxxx
		c_wait_table_505[ 2] = 16'h8000;	//	xxxx
		c_wait_table_505[ 3] = 16'h8000;	//	xxxx
		c_wait_table_505[ 4] = 16'h8000;	//	poin
		c_wait_table_505[ 5] = 16'h8000;	//	pset
		c_wait_table_505[ 6] = 16'h13c4;	//	srch
		c_wait_table_505[ 7] = 16'h08d4;	//	line
		c_wait_table_505[ 8] = 16'h0cc4;	//	lmmv
		c_wait_table_505[ 9] = 16'h0e68;	//	lmmm
		c_wait_table_505[10] = 16'h8000;	//	lmcm
		c_wait_table_505[11] = 16'h8000;	//	lmmc
		c_wait_table_505[12] = 16'h0cac;	//	hmmv
		c_wait_table_505[13] = 16'h1384;	//	hmmm
		c_wait_table_505[14] = 16'h12dc;	//	ymmm
		c_wait_table_505[15] = 16'h8000;	//	hmmc

		// sprite on, 212 lines, 60hz
		c_wait_table_601[ 0] = 16'h8000;	//	stop
		c_wait_table_601[ 1] = 16'h8000;	//	xxxx
		c_wait_table_601[ 2] = 16'h8000;	//	xxxx
		c_wait_table_601[ 3] = 16'h8000;	//	xxxx
		c_wait_table_601[ 4] = 16'h8000;	//	poin
		c_wait_table_601[ 5] = 16'h8000;	//	pset
		c_wait_table_601[ 6] = 16'h1ac4;	//	srch
		c_wait_table_601[ 7] = 16'h10f0;	//	line
		c_wait_table_601[ 8] = 16'h13dc;	//	lmmv
		c_wait_table_601[ 9] = 16'h15b4;	//	lmmm
		c_wait_table_601[10] = 16'h8000;	//	lmcm
		c_wait_table_601[11] = 16'h8000;	//	lmmc
		c_wait_table_601[12] = 16'h14cc;	//	hmmv
		c_wait_table_601[13] = 16'h1a44;	//	hmmm
		c_wait_table_601[14] = 16'h182c;	//	ymmm
		c_wait_table_601[15] = 16'h8000;	//	hmmc

		// sprite on, 192 lines, 60hz
		c_wait_table_602[ 0] = 16'h8000;	//	stop
		c_wait_table_602[ 1] = 16'h8000;	//	xxxx
		c_wait_table_602[ 2] = 16'h8000;	//	xxxx
		c_wait_table_602[ 3] = 16'h8000;	//	xxxx
		c_wait_table_602[ 4] = 16'h8000;	//	point
		c_wait_table_602[ 5] = 16'h8000;	//	pset
		c_wait_table_602[ 6] = 16'h18e4;	//	srch
		c_wait_table_602[ 7] = 16'h0fc0;	//	line
		c_wait_table_602[ 8] = 16'h1274;	//	lmmv
		c_wait_table_602[ 9] = 16'h1424;	//	lmmm
		c_wait_table_602[10] = 16'h8000;	//	lmcm
		c_wait_table_602[11] = 16'h8000;	//	lmmc
		c_wait_table_602[12] = 16'h1318;	//	hmmv
		c_wait_table_602[13] = 16'h1864;	//	hmmm
		c_wait_table_602[14] = 16'h16fc;	//	ymmm
		c_wait_table_602[15] = 16'h8000;	//	hmmc

		// sprite off, 212 lines, 60hz
		c_wait_table_603[ 0] = 16'h8000;	//	stop
		c_wait_table_603[ 1] = 16'h8000;	//	xxxx
		c_wait_table_603[ 2] = 16'h8000;	//	xxxx
		c_wait_table_603[ 3] = 16'h8000;	//	xxxx
		c_wait_table_603[ 4] = 16'h8000;	//	point
		c_wait_table_603[ 5] = 16'h8000;	//	pset
		c_wait_table_603[ 6] = 16'h1674;	//	srch
		c_wait_table_603[ 7] = 16'h0ab0;	//	line
		c_wait_table_603[ 8] = 16'h0e24;	//	lmmv
		c_wait_table_603[ 9] = 16'h12b4;	//	lmmm
		c_wait_table_603[10] = 16'h8000;	//	lmcm
		c_wait_table_603[11] = 16'h8000;	//	lmmc
		c_wait_table_603[12] = 16'h0dfc;	//	hmmv
		c_wait_table_603[13] = 16'h15f4;	//	hmmm
		c_wait_table_603[14] = 16'h17b4;	//	ymmm
		c_wait_table_603[15] = 16'h8000;	//	hmmc

		// sprite off, 192 lines, 60hz
		c_wait_table_604[ 0] = 16'h8000;	//	stop
		c_wait_table_604[ 1] = 16'h8000;	//	xxxx
		c_wait_table_604[ 2] = 16'h8000;	//	xxxx
		c_wait_table_604[ 3] = 16'h8000;	//	xxxx
		c_wait_table_604[ 4] = 16'h8000;	//	point
		c_wait_table_604[ 5] = 16'h8000;	//	pset
		c_wait_table_604[ 6] = 16'h1564;	//	srch
		c_wait_table_604[ 7] = 16'h0a40;	//	line
		c_wait_table_604[ 8] = 16'h0d7c;	//	lmmv
		c_wait_table_604[ 9] = 16'h11ac;	//	lmmm
		c_wait_table_604[10] = 16'h8000;	//	lmcm
		c_wait_table_604[11] = 16'h8000;	//	lmmc
		c_wait_table_604[12] = 16'h0d58;	//	hmmv
		c_wait_table_604[13] = 16'h14e4;	//	hmmm
		c_wait_table_604[14] = 16'h167c;	//	ymmm
		c_wait_table_604[15] = 16'h8000;	//	hmmc

		// blank, 60hz (test: sprite on, 212 lines)
		c_wait_table_605[ 0] = 16'h8000;	//	stop
		c_wait_table_605[ 1] = 16'h8000;	//	xxxx
		c_wait_table_605[ 2] = 16'h8000;	//	xxxx
		c_wait_table_605[ 3] = 16'h8000;	//	xxxx
		c_wait_table_605[ 4] = 16'h8000;	//	point
		c_wait_table_605[ 5] = 16'h8000;	//	pset
		c_wait_table_605[ 6] = 16'h1278;	//	srch
		c_wait_table_605[ 7] = 16'h08f0;	//	line
		c_wait_table_605[ 8] = 16'h0d58;	//	lmmv
		c_wait_table_605[ 9] = 16'h0efc;	//	lmmm
		c_wait_table_605[10] = 16'h8000;	//	lmcm
		c_wait_table_605[11] = 16'h8000;	//	lmmc
		c_wait_table_605[12] = 16'h0d38;	//	hmmv
		c_wait_table_605[13] = 16'h11f8;	//	hmmm
		c_wait_table_605[14] = 16'h13d4;	//	ymmm
		c_wait_table_605[15] = 16'h8000;	//	hmmc
	end

	always @( posedge clk ) begin
		if( reset )begin
			ff_wait_cnt <= 16'd0;
		end
		else if( !enable )begin
			// hold
		end
		else if( drive )begin
			if( vdpr9palmode )begin
				// 50hz (pal)
				if( reg_r1_disp_on )begin
					// display on
					if( !reg_r8_sp_off )begin
						// sprite on
						if( reg_r9_y_dots )begin
							// 212 lines
							ff_wait_cnt <= {1'b0, ff_wait_cnt[14:0]} + c_wait_table_501[ vdp_command ];
						end
						else begin
							// 192 lines
							ff_wait_cnt <= {1'b0, ff_wait_cnt[14:0]} + c_wait_table_502[ vdp_command ];
						end
					end
					else begin
						// sprite off
						if( reg_r9_y_dots )begin
							// 212 lines
							ff_wait_cnt <= {1'b0, ff_wait_cnt[14:0]} + c_wait_table_503[ vdp_command ];
						end
						else begin
							// 192 lines
							ff_wait_cnt <= {1'b0, ff_wait_cnt[14:0]} + c_wait_table_504[ vdp_command ];
						end
					end
				// display off (blank)
				end
				else begin
					ff_wait_cnt <= (1'b0 & ff_wait_cnt[14:0]) + c_wait_table_505[ vdp_command ];
				end
			end
			else begin
				// 60hz (ntsc)
				if( reg_r1_disp_on )begin
					// display on
					if( !reg_r8_sp_off )begin
						// sprite on
						if( reg_r9_y_dots )begin
							// 212 lines
							ff_wait_cnt <= {1'b0, ff_wait_cnt[14:0]} + c_wait_table_601[ vdp_command ];
						end
						else begin
							// 192 lines
							ff_wait_cnt <= {1'b0, ff_wait_cnt[14:0]} + c_wait_table_602[ vdp_command ];
						end
					end
					else begin
						// sprite off
						if( reg_r9_y_dots )begin
							// 212 lines
							ff_wait_cnt <= {1'b0, ff_wait_cnt[14:0]} + c_wait_table_603[ vdp_command ];
						end
						else begin
							// 192 lines
							ff_wait_cnt <= {1'b0, ff_wait_cnt[14:0]} + c_wait_table_604[ vdp_command ];
						end
					end
				end
				else begin
					// display off (blank)
					ff_wait_cnt <= {1'b0, ff_wait_cnt[14:0]} + c_wait_table_605[ vdp_command ];
				end
			end
		end
	end

	assign active	= ff_wait_cnt[15] || vdp_speed_mode;
endmodule
