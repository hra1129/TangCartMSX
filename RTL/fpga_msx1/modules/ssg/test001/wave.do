onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /tb/test_no
add wave -noupdate -radix unsigned /tb/i
add wave -noupdate -radix hexadecimal /tb/u_ssg_inst/reset
add wave -noupdate -radix hexadecimal /tb/u_ssg_inst/clk
add wave -noupdate -radix hexadecimal /tb/u_ssg_inst/enable
add wave -noupdate -radix hexadecimal /tb/u_ssg_inst/bus_io_req
add wave -noupdate -radix hexadecimal /tb/u_ssg_inst/bus_ack
add wave -noupdate -radix hexadecimal /tb/u_ssg_inst/bus_wrt
add wave -noupdate -radix hexadecimal /tb/u_ssg_inst/bus_address
add wave -noupdate -radix hexadecimal /tb/u_ssg_inst/bus_wdata
add wave -noupdate -radix hexadecimal /tb/u_ssg_inst/bus_rdata
add wave -noupdate -radix hexadecimal /tb/u_ssg_inst/bus_rdata_en
add wave -noupdate -radix hexadecimal /tb/u_ssg_inst/joystick_port1
add wave -noupdate -radix hexadecimal /tb/u_ssg_inst/joystick_port2
add wave -noupdate -radix hexadecimal /tb/u_ssg_inst/strobe_port1
add wave -noupdate -radix hexadecimal /tb/u_ssg_inst/strobe_port2
add wave -noupdate -radix hexadecimal /tb/u_ssg_inst/keyboard_type
add wave -noupdate -radix hexadecimal /tb/u_ssg_inst/cmt_read
add wave -noupdate -radix hexadecimal /tb/u_ssg_inst/kana_led
add wave -noupdate -format Analog-Step -height 74 -max 130.0 -radix hexadecimal /tb/u_ssg_inst/sound_out
add wave -noupdate -radix hexadecimal /tb/u_ssg_inst/w_decode
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 0
configure wave -namecolwidth 178
configure wave -valuecolwidth 60
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
WaveRestoreZoom {8292411956 ns} {27941822894 ns}
