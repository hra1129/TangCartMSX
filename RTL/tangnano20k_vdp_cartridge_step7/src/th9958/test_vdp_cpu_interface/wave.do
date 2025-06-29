onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/reset_n
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/clk
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/bus_address
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/bus_ioreq
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/bus_write
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/bus_valid
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/bus_ready
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/bus_wdata
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/bus_rdata
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/bus_rdata_en
add wave -noupdate /tb/u_cpu_interface/ff_busy
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/ff_vram_address_inc
add wave -noupdate -radix hexadecimal /tb/ff_last_vram_address
add wave -noupdate -radix hexadecimal /tb/ff_last_vram_wdata
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/vram_address
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/vram_wdata
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/vram_write
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/vram_valid
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/vram_ready
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/vram_rdata
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/vram_rdata_en
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/reg_screen_mode
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/reg_sprite_magify
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/reg_sprite_16x16
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/reg_display_on
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/reg_pattern_name_table_base
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/reg_color_table_base
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/reg_pattern_generator_table_base
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/reg_sprite_attribute_table_base
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/reg_sprite_pattern_generator_table_base
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/reg_backdrop_color
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/reg_sprite_disable
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/reg_color0_opaque
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/reg_50hz_mode
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/reg_interleaving_mode
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/reg_interlace_mode
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/reg_212lines_mode
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/reg_text_back_color
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/reg_blink_period
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/reg_color_palette_address
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/reg_display_adjust
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/reg_interrupt_line
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/reg_vertical_offset
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/reg_scroll_planes
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/reg_left_mask
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/reg_yjk_mode
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/reg_yae_mode
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/reg_command_enable
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/reg_horizontal_offset
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/ff_bus_rdata
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/ff_bus_rdata_en
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/ff_screen_mode
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/ff_line_interrupt_enable
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/ff_frame_interrupt_enable
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/ff_sprite_magify
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/ff_sprite_16x16
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/ff_display_on
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/ff_pattern_name_table_base
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/ff_color_table_base
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/ff_pattern_generator_table_base
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/ff_sprite_attribute_table_base
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/ff_sprite_pattern_generator_table_base
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/ff_backdrop_color
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/ff_sprite_disable
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/ff_color0_opaque
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/ff_50hz_mode
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/ff_interleaving_mode
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/ff_interlace_mode
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/ff_212lines_mode
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/ff_text_back_color
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/ff_blink_period
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/ff_status_register_pointer
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/ff_color_palette_address
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/ff_register_pointer
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/ff_not_increment
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/ff_display_adjust
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/ff_interrupt_line
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/ff_vertical_offset
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/ff_scroll_planes
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/ff_left_mask
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/ff_yjk_mode
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/ff_yae_mode
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/ff_command_enable
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/ff_horizontal_offset
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/ff_2nd_access
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/ff_1st_byte
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/ff_register_write
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/ff_register_num
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/ff_vram_address
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/ff_vram_address_write
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/ff_vram_write
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/ff_vram_wdata
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/ff_vram_rdata
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/ff_vram_valid
add wave -noupdate -radix hexadecimal /tb/u_cpu_interface/w_address_14bit
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {846 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 338
configure wave -valuecolwidth 56
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
WaveRestoreZoom {257 ns} {868 ns}
