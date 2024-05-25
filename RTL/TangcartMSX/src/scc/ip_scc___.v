// ------------------------------------------------------------------------------------------------
// Wave Table Sound
// Copyright 2024 t.hara
// 
//  Permission is hereby granted, free of charge, to any person obtaining a copy 
// of this software and associated documentation files (the "Software"), to deal 
// in the Software without restriction, including without limitation the rights 
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies 
// of the Software, and to permit persons to whom the Software is furnished to do
// so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all 
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A 
// PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT 
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION 
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH 
// THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
// ------------------------------------------------------------------------------------------------

module ip_scc (
	input			clk,
	input			enable,			//	21.47727MHz
	input			n_reset,
	//	MSX-50BUS
	input	[15:0]	bus_address,
	output			bus_read_ready,
	output	[7:0]	bus_read_data,
	input	[7:0]	bus_write_data,
	input			bus_read,
	input			bus_write,
	input			bus_memory,
	//	SCC
	input			scc_bank_en,
	input			sccp_bank_en,
	output	[10:0]	sound_out		//	digital sound output (11 bits)
);
	scc_core #(
		.add_offset			( 1					)
	) u_scc_core (
		.nreset				( n_reset			),
		.clk				( clk				),
		.wrreq				( w_wrreq			),
		.rdreq				( w_rdreq			),
		.a					( bus_address		),
		.d					( bus_write_data	),
		.q					( bus_read_data		),
		.left_out			( sound_out			)
	);
endmodule
