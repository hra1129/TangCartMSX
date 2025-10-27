onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_info_collect/reset_n
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_info_collect/clk
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_info_collect/start_info_collect
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_info_collect/screen_pos_x
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_info_collect/screen_active
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_info_collect/w_sub_phase
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_info_collect/vram_address
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_info_collect/vram_valid
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_info_collect/vram_rdata
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_info_collect/selected_en
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_info_collect/selected_plane_num
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_info_collect/selected_y
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_info_collect/selected_x
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_info_collect/selected_pattern
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_info_collect/selected_color
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_info_collect/selected_count
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_info_collect/makeup_plane
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_info_collect/plane_x
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_info_collect/plane_x_en
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_info_collect/pattern_left
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_info_collect/pattern_left_en
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_info_collect/pattern_right
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_info_collect/pattern_right_en
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_info_collect/color
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_info_collect/color_en
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_info_collect/sprite_mode2
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_info_collect/reg_display_on
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_info_collect/reg_sprite_magify
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_info_collect/reg_sprite_16x16
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_info_collect/reg_sprite_pattern_generator_table_base
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_info_collect/w_selected_d
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_info_collect/w_selected_plane_num
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_info_collect/w_selected_y
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_info_collect/w_selected_x
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_info_collect/w_selected_pattern
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_info_collect/w_selected_color
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_info_collect/ff_selected_q
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_info_collect/ff_current_plane
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_info_collect/ff_current_plane_d1
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_info_collect/w_next_plane
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_info_collect/ff_state
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_info_collect/ff_vram_address
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_info_collect/ff_vram_valid
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_info_collect/ff_vram_valid_d1
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_info_collect/ff_active
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_info_collect/ff_active_d1
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_info_collect/ff_sprite_mode2
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 0
configure wave -namecolwidth 268
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
WaveRestoreZoom {73920909 ns} {73921207 ns}
