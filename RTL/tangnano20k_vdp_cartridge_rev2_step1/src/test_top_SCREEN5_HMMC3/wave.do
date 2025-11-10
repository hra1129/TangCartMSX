onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/reset_n
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/clk
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/command_vram_address
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/command_vram_valid
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/command_vram_ready
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/command_vram_write
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/command_vram_wdata
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/command_vram_wdata_mask
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/command_vram_rdata
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/command_vram_rdata_en
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/register_write
add wave -noupdate -radix unsigned /tb/u_vdp_cartridge/u_v9958/u_command/register_num
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/register_data
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/clear_border_detect
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/read_color
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/status_command_execute
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/status_border_detect
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/status_transfer_ready
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/status_color
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/status_border_position
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/screen_mode
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/vram_interleave
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/reg_text_back_color
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/reg_command_enable
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/reg_command_high_speed_mode
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/reg_ext_command_mode
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/reg_vram256k_mode
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/vram_access_mask
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/intr_command_end
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/ff_command_execute
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/ff_read_pixel
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/ff_read_byte
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/ff_source
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/w_destination
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/w_lop_pixel
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/ff_screen_mode
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/ff_xsel
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/reg_sx
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/reg_dx
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/reg_nx
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/w_reg_nx
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/w_nx_max
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/reg_ny
add wave -noupdate -radix unsigned /tb/u_vdp_cartridge/u_v9958/u_command/ff_sx
add wave -noupdate -radix unsigned /tb/u_vdp_cartridge/u_v9958/u_command/ff_sy
add wave -noupdate -radix unsigned /tb/u_vdp_cartridge/u_v9958/u_command/ff_sx2
add wave -noupdate -radix unsigned /tb/u_vdp_cartridge/u_v9958/u_command/ff_sy2
add wave -noupdate -radix unsigned /tb/u_vdp_cartridge/u_v9958/u_command/ff_dx
add wave -noupdate -radix unsigned /tb/u_vdp_cartridge/u_v9958/u_command/ff_dy
add wave -noupdate -radix unsigned /tb/u_vdp_cartridge/u_v9958/u_command/ff_nx
add wave -noupdate -radix unsigned /tb/u_vdp_cartridge/u_v9958/u_command/ff_ny
add wave -noupdate -radix unsigned /tb/u_vdp_cartridge/u_v9958/u_command/reg_vx
add wave -noupdate -radix unsigned /tb/u_vdp_cartridge/u_v9958/u_command/reg_vy
add wave -noupdate -radix unsigned /tb/u_vdp_cartridge/u_v9958/u_command/reg_wsx
add wave -noupdate -radix unsigned /tb/u_vdp_cartridge/u_v9958/u_command/reg_wsy
add wave -noupdate -radix unsigned /tb/u_vdp_cartridge/u_v9958/u_command/reg_wex
add wave -noupdate -radix unsigned /tb/u_vdp_cartridge/u_v9958/u_command/reg_wey
add wave -noupdate -radix unsigned /tb/u_vdp_cartridge/u_v9958/u_command/w_nx
add wave -noupdate -radix unsigned /tb/u_vdp_cartridge/u_v9958/u_command/w_ny
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/w_nx_end
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/w_ny_end
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/ff_nyb
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/ff_color
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/ff_transfer_ready
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/ff_maj
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/ff_eq
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/ff_dix
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/ff_diy
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/ff_mxs
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/ff_mxd
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/ff_mxc
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/ff_xhr
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/ff_fg4
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/ff_logical_opration
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/ff_command
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/ff_start
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/ff_cache_vram_address
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/ff_cache_vram_valid
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/w_cache_vram_ready
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/ff_cache_vram_write
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/ff_cache_vram_wdata
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/w_cache_vram_rdata
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/w_cache_vram_rdata_en
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/ff_cache_flush_start
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/w_cache_flush_end
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/w_effective_mode
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/w_bpp
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/w_512pixel
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/ff_512pixel
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/w_address_s_pre
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/w_address_d_pre
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/w_address_s
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/w_address_d
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/w_next_nyb
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/w_next
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/w_next_sx
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/w_next_sy
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/w_next_dx
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/w_next_dy
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/w_line_shift
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/ff_border_detect_request
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/ff_border_detect
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/ff_read_color
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/w_sx_active
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/w_dx_active
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/ff_sx_active
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/ff_dx_active
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/w_sx_overflow
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/w_dx_overflow
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/ff_bit_count
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/ff_fore_color
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/ff_font_address
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/ff_bit_pattern
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/ff_state
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/ff_next_state
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/ff_count_valid
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/ff_wait_counter
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/ff_wait_count
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_command/ff_command_end
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {7904391 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 271
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
WaveRestoreZoom {8935580 ns} {8983396 ns}
