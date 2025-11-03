onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_select_visible_planes/reset_n
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_select_visible_planes/clk
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_select_visible_planes/screen_pos_x
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_select_visible_planes/screen_pos_y
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_select_visible_planes/pixel_pos_y
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_select_visible_planes/screen_v_active
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_select_visible_planes/screen_h_active
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_select_visible_planes/vram_address
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_select_visible_planes/vram_valid
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_select_visible_planes/vram_rdata
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_select_visible_planes/vram_interleave
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_select_visible_planes/selected_en
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_select_visible_planes/selected_plane_num
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_select_visible_planes/selected_attribute
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_select_visible_planes/selected_count
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_select_visible_planes/start_info_collect
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_select_visible_planes/sprite_overmap
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_select_visible_planes/sprite_overmap_id
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_select_visible_planes/clear_sprite_collision
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_select_visible_planes/sprite_mode2
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_select_visible_planes/reg_display_on
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_select_visible_planes/reg_sprite_disable
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_select_visible_planes/reg_sprite_magify
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_select_visible_planes/reg_sprite_16x16
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_select_visible_planes/reg_sprite_attribute_table_base
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_select_visible_planes/reg_sprite_nonR23_mode
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_select_visible_planes/reg_sprite_mode3
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_select_visible_planes/reg_sprite16_mode
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_select_visible_planes/reg_sprite_priority_shuffle
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_select_visible_planes/w_screen_pos_x
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_select_visible_planes/w_phase
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_select_visible_planes/w_sub_phase
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_select_visible_planes/w_pixel_pos_y
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_select_visible_planes/ff_plane_count
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_select_visible_planes/ff_current_plane_num
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_select_visible_planes/ff_current_plane_num_start
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_select_visible_planes/ff_vram_valid
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_select_visible_planes/ff_selected_count
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_select_visible_planes/ff_select_finish
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_select_visible_planes/ff_selected_plane_num
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_select_visible_planes/w_selected_plane_num
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_select_visible_planes/ff_selected_en1
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_select_visible_planes/ff_selected_en2
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_select_visible_planes/ff_attribute1
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_select_visible_planes/ff_attribute2
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_select_visible_planes/w_attribute
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_select_visible_planes/w_y
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_select_visible_planes/w_mgy
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_select_visible_planes/w_offset_y
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_select_visible_planes/w_attribute_y
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_select_visible_planes/w_invisible12
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_select_visible_planes/w_invisible3
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_select_visible_planes/w_invisible
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_select_visible_planes/w_selected_full
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_select_visible_planes/w_finish_line
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_select_visible_planes/w_sprite_mode1_attribute
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_select_visible_planes/w_sprite_mode2_attribute
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_select_visible_planes/w_sprite_mode2_attribute_i
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_select_visible_planes/w_sprite_mode3_attribute
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_select_visible_planes/ff_sprite_overmap
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_sprite/u_select_visible_planes/ff_sprite_overmap_id
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 0
configure wave -namecolwidth 340
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
WaveRestoreZoom {4658208 ns} {4658426 ns}
