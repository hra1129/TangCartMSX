onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/u_dut/clk
add wave -noupdate /tb/u_dut/clk42m
add wave -noupdate -radix hexadecimal /tb/u_dut/u_z80/u_cz80/sp
add wave -noupdate -radix hexadecimal /tb/u_dut/u_z80/u_cz80/pc
add wave -noupdate -radix hexadecimal /tb/u_dut/u_z80/d
add wave -noupdate -radix hexadecimal /tb/u_dut/u_z80/a
add wave -noupdate -radix hexadecimal /tb/u_dut/u_ppi/u_ppi/ff_port_a
add wave -noupdate -radix hexadecimal /tb/u_dut/u_v9918/int_n
add wave -noupdate -radix hexadecimal /tb/u_dut/u_v9918/iorq_n
add wave -noupdate -radix hexadecimal /tb/u_dut/u_v9918/rd_n
add wave -noupdate -radix hexadecimal /tb/u_dut/u_v9918/wr_n
add wave -noupdate -radix hexadecimal /tb/u_dut/u_v9918/address
add wave -noupdate /tb/u_dut/u_exp_slot3/sltsl_ext0
add wave -noupdate /tb/u_dut/u_exp_slot3/sltsl_ext1
add wave -noupdate /tb/u_dut/u_exp_slot3/sltsl_ext2
add wave -noupdate /tb/u_dut/u_exp_slot3/sltsl_ext3
add wave -noupdate /tb/u_dut/u_exp_slot3/sltsl
add wave -noupdate -radix hexadecimal /tb/u_dut/u_exp_slot3/address
add wave -noupdate -divider {SDRAM Controller}
add wave -noupdate -radix hexadecimal /tb/u_dut/u_sdram/rd_n
add wave -noupdate -radix hexadecimal /tb/u_dut/u_sdram/wr_n
add wave -noupdate -radix hexadecimal /tb/u_dut/u_sdram/rfsh_n
add wave -noupdate -radix hexadecimal /tb/u_dut/u_sdram/rdata
add wave -noupdate -radix hexadecimal /tb/u_dut/u_sdram/rdata_en
add wave -noupdate -radix hexadecimal /tb/u_dut/u_sdram/ff_main_state
add wave -noupdate /tb/u_dut/u_sdram/ff_rd_n
add wave -noupdate /tb/u_dut/u_sdram/ff_do_refresh
add wave -noupdate -format Analog-Step -height 74 -max 254.99999999999997 -radix unsigned /tb/u_dut/u_sdram/ff_no_refresh
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {345493728215 ps} 0} {{Cursor 2} {582391150560 ps} 0} {{Cursor 3} {345512308320 ps} 0}
quietly wave cursor active 3
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
WaveRestoreZoom {345510798913 ps} {345512783408 ps}
