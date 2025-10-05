onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /tb/u_dut/reset_n
add wave -noupdate -radix unsigned /tb/u_dut/clk
add wave -noupdate -format Analog-Step -height 74 -max 254.99999999999997 -radix unsigned /tb/u_dut/x
add wave -noupdate -radix unsigned /tb/u_dut/reg_mgx
add wave -noupdate -radix unsigned /tb/u_dut/bit_shift
add wave -noupdate -format Analog-Step -height 74 -max 127.0 -radix unsigned /tb/u_dut/sample_x
add wave -noupdate -radix unsigned /tb/u_dut/w_exp
add wave -noupdate -radix unsigned /tb/u_dut/ff_mgx0
add wave -noupdate -radix unsigned /tb/u_dut/ff_exp1
add wave -noupdate -radix unsigned /tb/u_dut/ff_divide_coeff
add wave -noupdate -radix unsigned /tb/u_dut/ff_bit_shift1
add wave -noupdate -radix unsigned /tb/u_dut/ff_x
add wave -noupdate -radix unsigned /tb/u_dut/w_divide_sel
add wave -noupdate -radix unsigned /tb/u_dut/w_coeff
add wave -noupdate -format Analog-Step -height 74 -max 130559.99999999999 -radix unsigned /tb/u_dut/w_mul
add wave -noupdate -radix unsigned /tb/u_dut/ff_exp2
add wave -noupdate -format Analog-Step -height 74 -max 4079.9999999999995 -radix unsigned /tb/u_dut/ff_mul
add wave -noupdate -radix unsigned /tb/u_dut/ff_bit_shift2
add wave -noupdate -format Analog-Step -height 74 -max 8184.0000000000009 -radix unsigned /tb/u_dut/w_shift
add wave -noupdate -radix unsigned /tb/u_dut/w_sample_x
add wave -noupdate -radix unsigned /tb/u_dut/ff_sample_x
add wave -noupdate -radix unsigned /tb/u_dut/ff_overflow
add wave -noupdate -radix unsigned /tb/u_dut/ff_bit_shift3
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {7455 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 182
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
WaveRestoreZoom {5670 ns} {8386 ns}
