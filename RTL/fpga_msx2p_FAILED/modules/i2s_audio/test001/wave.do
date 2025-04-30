onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/u_i2s_audio/clk
add wave -noupdate /tb/u_i2s_audio/reset_n
add wave -noupdate /tb/u_i2s_audio/sound_in
add wave -noupdate -radix unsigned /tb/u_i2s_audio/i2s_audio_en
add wave -noupdate -radix unsigned /tb/u_i2s_audio/i2s_audio_din
add wave -noupdate -radix unsigned /tb/u_i2s_audio/i2s_audio_lrclk
add wave -noupdate -radix unsigned /tb/u_i2s_audio/i2s_audio_bclk
add wave -noupdate -radix unsigned /tb/u_i2s_audio/ff_divider
add wave -noupdate -radix unsigned /tb/u_i2s_audio/w_96khz_pulse
add wave -noupdate -radix unsigned /tb/u_i2s_audio/ff_clk_en
add wave -noupdate -radix unsigned /tb/u_i2s_audio/ff_bclk
add wave -noupdate -radix unsigned /tb/u_i2s_audio/ff_lrclk
add wave -noupdate -radix unsigned /tb/u_i2s_audio/ff_bit_count
add wave -noupdate /tb/u_i2s_audio/ff_shift_reg
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {46560852 ps} 0} {{Cursor 2} {10313228718 ps} 0}
quietly wave cursor active 2
configure wave -namecolwidth 192
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
WaveRestoreZoom {0 ps} {11687741168 ps}
