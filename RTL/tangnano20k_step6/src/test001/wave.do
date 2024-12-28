onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider CPU
add wave -noupdate -radix hexadecimal /tb/u_dut/u_z80/u_cz80/sp
add wave -noupdate -radix hexadecimal /tb/u_dut/u_z80/u_cz80/pc
add wave -noupdate -radix hexadecimal /tb/u_dut/u_z80/d
add wave -noupdate -radix hexadecimal /tb/u_dut/u_z80/a
add wave -noupdate /tb/u_dut/u_z80/m1_n
add wave -noupdate /tb/u_dut/u_z80/rd_n
add wave -noupdate /tb/u_dut/u_z80/wr_n
add wave -noupdate -divider PPI
add wave -noupdate -radix hexadecimal /tb/u_dut/u_ppi/u_ppi/ff_port_a
add wave -noupdate -divider VDP
add wave -noupdate -radix hexadecimal /tb/u_dut/u_v9918/int_n
add wave -noupdate -radix hexadecimal /tb/u_dut/u_v9918/iorq_n
add wave -noupdate -radix hexadecimal /tb/u_dut/u_v9918/rd_n
add wave -noupdate -radix hexadecimal /tb/u_dut/u_v9918/wr_n
add wave -noupdate -radix hexadecimal /tb/u_dut/u_v9918/address
add wave -noupdate -divider {SDRAM Controller}
add wave -noupdate -radix hexadecimal /tb/u_dut/u_sdram/rd_n
add wave -noupdate -radix hexadecimal /tb/u_dut/u_sdram/wr_n
add wave -noupdate -radix hexadecimal /tb/u_dut/u_sdram/rfsh_n
add wave -noupdate -max 4259839.0 -radix hexadecimal /tb/u_dut/u_sdram/address
add wave -noupdate -radix hexadecimal /tb/u_dut/u_sdram/wdata
add wave -noupdate -radix hexadecimal /tb/u_dut/u_sdram/O_sdram_dqm
add wave -noupdate -radix hexadecimal /tb/u_dut/u_sdram/rdata
add wave -noupdate -radix hexadecimal /tb/u_dut/u_sdram/rdata_en
add wave -noupdate -radix hexadecimal /tb/u_dut/u_sdram/ff_main_state
add wave -noupdate /tb/u_dut/u_sdram/ff_rd_n
add wave -noupdate /tb/u_dut/u_sdram/ff_do_refresh
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {345493728215 ps} 0} {{Cursor 2} {2341668141960 ps} 0} {{Cursor 3} {345512308320 ps} 0} {{Cursor 4} {2218999920480 ps} 0} {{Cursor 5} {2341530268287 ps} 0}
quietly wave cursor active 5
configure wave -namecolwidth 187
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 2
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {2341183495382 ps} {2341185787382 ps}
