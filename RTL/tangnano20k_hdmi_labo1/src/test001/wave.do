onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/u_dut/u_video/clk
add wave -noupdate -radix hexadecimal /tb/u_dut/u_video/ff_h_counter
add wave -noupdate -radix hexadecimal /tb/u_dut/u_video/w_h_counter
add wave -noupdate -radix hexadecimal /tb/u_dut/u_video/ff_v_counter
add wave -noupdate -radix hexadecimal /tb/u_dut/u_video/ff_h_pre_window
add wave -noupdate -radix hexadecimal /tb/u_dut/u_video/ff_v_pre_window
add wave -noupdate -radix hexadecimal /tb/u_dut/u_video/ff_h_out_window
add wave -noupdate -radix hexadecimal /tb/u_dut/u_video/ff_v_out_window
add wave -noupdate /tb/u_dut/u_video/w_buffer_even_we
add wave -noupdate /tb/u_dut/u_video/w_buffer_odd_we
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 199
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
WaveRestoreZoom {3956414 ps} {4606730 ps}
