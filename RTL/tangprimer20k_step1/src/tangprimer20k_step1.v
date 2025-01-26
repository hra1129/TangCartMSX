// -----------------------------------------------------------------------------
//	tangprimer20k_step1.v
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

module tangprimer20k_step1 (
	input			clk27m,				//	clk27m		IOT27A/H11	27MHz
	input	[4:0]	button,				//	button[0]	IOR35B/T10	
										//	button[1]	IOB52B/T3	
										//	button[2]	IOB48B/T2	
										//	button[3]	IOL53B/D7	
										//	button[4]	IOL40B/C7	
	output	[5:0]	led					//	led[0]		IOR32B/C13	
										//	led[1]		IOR31A/A13	
										//	led[2]		IOT52A/N16	
										//	led[3]		IOT52B/N14	
										//	led[4]		IOT34B/L14	
										//	led[5]		IOT34A/L16	
);
	reg		[5:0]	ff_led		= 6'd0;
	reg		[20:0]	ff_timer	= 21'd0;

	always @( posedge clk27m ) begin
		ff_timer <= ff_timer + 21'd1;
	end

	always @( posedge clk27m ) begin
		if( ff_timer == 21'd0 ) begin
			ff_led <= ff_led + 6'd1;
		end
		else if( button[0] == 1'b0 ) begin
			ff_led <= 6'd0;
		end
		else if( button[1] == 1'b0 ) begin
			ff_led <= 6'd1;
		end
		else if( button[2] == 1'b0 ) begin
			ff_led <= 6'd2;
		end
		else if( button[3] == 1'b0 ) begin
			ff_led <= 6'd4;
		end
		else if( button[4] == 1'b0 ) begin
			ff_led <= 6'd8;
		end
		else begin
			//	hold
		end
	end

	assign led	= ~ff_led;
endmodule
