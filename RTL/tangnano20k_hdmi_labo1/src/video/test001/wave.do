onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /tb/u_dut/address
add wave -noupdate /tb/u_dut/iorq_n
add wave -noupdate /tb/u_dut/wr_n
add wave -noupdate /tb/u_dut/ff_iorq_n
add wave -noupdate /tb/u_dut/ff_wr_n
add wave -noupdate /tb/u_dut/w_wr
add wave -noupdate -radix hexadecimal /tb/u_dut/ff_h_counter
add wave -noupdate -radix hexadecimal /tb/u_dut/vram_mreq_n
add wave -noupdate -radix hexadecimal /tb/u_dut/vram_address
add wave -noupdate -radix hexadecimal /tb/u_dut/vram_wr_n
add wave -noupdate -radix hexadecimal /tb/u_dut/vram_rd_n
add wave -noupdate -radix hexadecimal /tb/u_dut/vram_rfsh_n
add wave -noupdate /tb/u_dut/ff_wr_vram
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 150
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
WaveRestoreZoom {21238998 ps} {21800907 ps}
