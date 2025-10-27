onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_timing_control/u_g123m/reset_n
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_timing_control/u_g123m/clk
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_timing_control/u_g123m/screen_pos_x
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_timing_control/u_g123m/pixel_pos_y
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_timing_control/u_g123m/screen_active
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_timing_control/u_g123m/vram_address
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_timing_control/u_g123m/vram_valid
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_timing_control/u_g123m/vram_rdata
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_timing_control/u_g123m/display_color
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_timing_control/u_g123m/reg_screen_mode
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_timing_control/u_g123m/reg_pattern_name_table_base
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_timing_control/u_g123m/reg_color_table_base
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_timing_control/u_g123m/reg_pattern_generator_table_base
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_timing_control/u_g123m/reg_backdrop_color
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_timing_control/u_g123m/w_mode
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_timing_control/u_g123m/w_phase
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_timing_control/u_g123m/w_sub_phase
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_timing_control/u_g123m/w_pos_x
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_timing_control/u_g123m/w_pattern_name
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_timing_control/u_g123m/ff_pattern_num
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_timing_control/u_g123m/w_pattern_generator_g1
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_timing_control/u_g123m/w_pattern_generator_g23
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_timing_control/u_g123m/w_pattern_generator
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_timing_control/u_g123m/ff_next_pattern
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_timing_control/u_g123m/ff_pattern
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_timing_control/u_g123m/w_color_g1
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_timing_control/u_g123m/w_color_g23
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_timing_control/u_g123m/w_color_gm
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_timing_control/u_g123m/w_color
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_timing_control/u_g123m/ff_next_color
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_timing_control/u_g123m/ff_color
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_timing_control/u_g123m/ff_vram_address
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_timing_control/u_g123m/ff_vram_valid
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_timing_control/u_g123m/ff_display_color
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {369043 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 293
configure wave -valuecolwidth 71
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
WaveRestoreZoom {368339 ns} {369147 ns}
