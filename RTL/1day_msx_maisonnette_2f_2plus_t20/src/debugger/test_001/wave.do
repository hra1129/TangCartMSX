onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/u_pwm/n_reset
add wave -noupdate /tb/u_pwm/clk
add wave -noupdate /tb/u_pwm/enable
add wave -noupdate -radix unsigned /tb/u_pwm/signal_level
add wave -noupdate /tb/u_pwm/pwm_wave
add wave -noupdate -radix unsigned /tb/u_pwm/ff_integ
add wave -noupdate -radix unsigned /tb/u_pwm/w_integ
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 175
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
WaveRestoreZoom {0 ps} {562212 ps}
