onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_screen_mode/reset_n
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_screen_mode/clk
add wave -noupdate -radix unsigned /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_screen_mode/screen_pos_x
add wave -noupdate -radix unsigned /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_screen_mode/screen_pos_y
add wave -noupdate -radix unsigned /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_screen_mode/pixel_pos_x
add wave -noupdate -radix unsigned /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_screen_mode/pixel_pos_y
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_screen_mode/screen_v_active
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_screen_mode/ff_screen_h_in_active
add wave -noupdate -radix unsigned /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_screen_mode/w_scroll_pos_x
add wave -noupdate -radix unsigned /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_screen_mode/ff_phase
add wave -noupdate -radix unsigned /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_screen_mode/w_sub_phase
add wave -noupdate -radix unsigned /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_screen_mode/ff_pos_x
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_screen_mode/w_pattern_name_t12_pre
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_screen_mode/w_pattern_name_t1
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_screen_mode/w_pattern_generator_t1
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_screen_mode/vram_address
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_screen_mode/vram_valid
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_screen_mode/vram_rdata
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_screen_mode/ff_vram_rdata_sel
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_screen_mode/w_vram_rdata8
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_screen_mode/ff_next_vram0
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_screen_mode/ff_next_vram1
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_screen_mode/ff_next_vram2
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_screen_mode/ff_pattern0
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_screen_mode/ff_pattern1
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_screen_mode/ff_pattern2
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_screen_mode/ff_pattern3
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_screen_mode/ff_pattern4
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_screen_mode/ff_pattern5
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_screen_mode/ff_pattern6
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_screen_mode/ff_pattern7
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2746 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 260
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
WaveRestoreZoom {30871719 ns} {30872016 ns}
