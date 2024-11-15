onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /tb/u_dcsg/n_reset
add wave -noupdate -radix hexadecimal /tb/u_dcsg/clk
add wave -noupdate -radix hexadecimal /tb/u_dcsg/en_clk_psg_i
add wave -noupdate -radix hexadecimal /tb/u_dcsg/n_ioreq
add wave -noupdate -radix hexadecimal /tb/u_dcsg/n_wr
add wave -noupdate -radix hexadecimal /tb/u_dcsg/address
add wave -noupdate -radix hexadecimal /tb/u_dcsg/wdata
add wave -noupdate -radix hexadecimal /tb/u_dcsg/sound_out
add wave -noupdate -radix hexadecimal /tb/u_dcsg/w_ready_o
add wave -noupdate -radix hexadecimal /tb/u_dcsg/w_ce_n
add wave -noupdate -radix hexadecimal /tb/u_dcsg/ff_wr_state
add wave -noupdate -radix hexadecimal /tb/u_dcsg/ff_ce_n
add wave -noupdate -radix hexadecimal /tb/u_dcsg/ff_wr_n
add wave -noupdate -radix hexadecimal /tb/u_dcsg/ff_wdata
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {6588 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 48
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
WaveRestoreZoom {0 ns} {9911356 ns}
