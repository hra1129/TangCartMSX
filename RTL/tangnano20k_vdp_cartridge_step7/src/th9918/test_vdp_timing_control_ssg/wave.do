onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /tb/u_sprite/clk
add wave -noupdate -radix hexadecimal /tb/u_sprite/reset
add wave -noupdate -radix hexadecimal /tb/u_sprite/enable
add wave -noupdate -radix hexadecimal /tb/u_sprite/bwindow_y
add wave -noupdate -radix hexadecimal /tb/u_sprite/p_s0_sp_collision_incidence
add wave -noupdate -radix hexadecimal /tb/u_sprite/p_s0_sp_overmapped
add wave -noupdate -radix hexadecimal /tb/u_sprite/p_s0_sp_overmapped_num
add wave -noupdate -radix hexadecimal /tb/u_sprite/p_s3s4_sp_collision_x
add wave -noupdate -radix hexadecimal /tb/u_sprite/p_s5s6_sp_collision_y
add wave -noupdate -radix hexadecimal /tb/u_sprite/p_s0_reset_req
add wave -noupdate -radix hexadecimal /tb/u_sprite/p_s0_reset_ack
add wave -noupdate -radix hexadecimal /tb/u_sprite/p_s5_reset_req
add wave -noupdate -radix hexadecimal /tb/u_sprite/p_s5_reset_ack
add wave -noupdate -radix hexadecimal /tb/u_sprite/reg_r1_sp_size
add wave -noupdate -radix hexadecimal /tb/u_sprite/reg_r1_sp_zoom
add wave -noupdate -radix hexadecimal /tb/u_sprite/reg_r11r5_sp_atr_addr
add wave -noupdate -radix hexadecimal /tb/u_sprite/reg_r6_sp_gen_addr
add wave -noupdate -radix hexadecimal /tb/u_sprite/reg_r8_col0_on
add wave -noupdate -radix hexadecimal /tb/u_sprite/reg_r8_sp_off
add wave -noupdate -radix hexadecimal /tb/u_sprite/reg_r23_vstart_line
add wave -noupdate -radix hexadecimal /tb/u_sprite/reg_r27_h_scroll
add wave -noupdate -radix hexadecimal /tb/u_sprite/p_sp_mode2
add wave -noupdate -radix hexadecimal /tb/u_sprite/vram_interleave_mode
add wave -noupdate -radix hexadecimal /tb/u_sprite/sp_vram_accessing
add wave -noupdate -radix unsigned /tb/u_sprite/dot_counter_x
add wave -noupdate -radix unsigned /tb/u_sprite/dot_counter_yp
add wave -noupdate -radix binary /tb/u_sprite/dot_state
add wave -noupdate -radix hexadecimal /tb/u_sprite/eight_dot_state
add wave -noupdate -radix unsigned /tb/u_sprite/ff_main_state
add wave -noupdate -radix hexadecimal /tb/u_sprite/ff_preread_address
add wave -noupdate -radix hexadecimal /tb/u_sprite/p_vram_address
add wave -noupdate -radix hexadecimal /tb/ff_dram_address_cbus
add wave -noupdate -radix hexadecimal /tb/ff_valid_cbus
add wave -noupdate -radix hexadecimal /tb/ff_address_inst
add wave -noupdate /tb/ff_valid_inst
add wave -noupdate -radix unsigned /tb/ff_rdata0
add wave -noupdate /tb/ff_valid0
add wave -noupdate -radix unsigned /tb/ff_rdata1
add wave -noupdate /tb/ff_valid1
add wave -noupdate -radix unsigned /tb/ff_rdata2
add wave -noupdate /tb/ff_valid2
add wave -noupdate -radix unsigned /tb/ff_rdata3
add wave -noupdate /tb/ff_valid3
add wave -noupdate -radix unsigned /tb/u_sprite/p_vram_rdata
add wave -noupdate -radix unsigned /tb/u_sprite/eight_dot_state
add wave -noupdate /tb/u_sprite/dot_state
add wave -noupdate -radix hexadecimal /tb/u_sprite/sp_color_code_en
add wave -noupdate -radix hexadecimal /tb/u_sprite/sp_color_code
add wave -noupdate -radix hexadecimal /tb/u_sprite/reg_r9_y_dots
add wave -noupdate -radix hexadecimal /tb/u_sprite/ff_sp_en
add wave -noupdate -radix hexadecimal /tb/u_sprite/ff_cur_y
add wave -noupdate -radix hexadecimal /tb/u_sprite/ff_prev_cur_y
add wave -noupdate -radix hexadecimal /tb/u_sprite/ff_vdps0resetack
add wave -noupdate -radix hexadecimal /tb/u_sprite/ff_vdps5resetack
add wave -noupdate -radix hexadecimal /tb/u_sprite/w_info_address
add wave -noupdate -radix hexadecimal /tb/u_sprite/ff_info_ram_we
add wave -noupdate -radix hexadecimal /tb/u_sprite/w_info_wdata
add wave -noupdate -radix hexadecimal /tb/u_sprite/w_info_rdata
add wave -noupdate -radix unsigned /tb/u_sprite/ff_info_x
add wave -noupdate -radix hexadecimal /tb/u_sprite/ff_info_pattern
add wave -noupdate -radix hexadecimal /tb/u_sprite/ff_info_color
add wave -noupdate -radix hexadecimal /tb/u_sprite/ff_info_cc
add wave -noupdate -radix hexadecimal /tb/u_sprite/ff_info_ic
add wave -noupdate -radix hexadecimal /tb/u_sprite/w_info_x
add wave -noupdate -radix hexadecimal /tb/u_sprite/w_info_pattern
add wave -noupdate -radix hexadecimal /tb/u_sprite/w_info_color
add wave -noupdate -radix hexadecimal /tb/u_sprite/w_info_cc
add wave -noupdate -radix hexadecimal /tb/u_sprite/w_info_ic
add wave -noupdate -radix hexadecimal /tb/u_sprite/ff_main_state
add wave -noupdate -radix hexadecimal /tb/u_sprite/w_vram_address
add wave -noupdate -radix hexadecimal /tb/u_sprite/ff_y_test_address
add wave -noupdate -radix hexadecimal /tb/u_sprite/ff_preread_address
add wave -noupdate -radix hexadecimal /tb/u_sprite/ff_attribute_base_address
add wave -noupdate -radix hexadecimal /tb/u_sprite/ff_pattern_gen_base_address
add wave -noupdate -radix hexadecimal /tb/u_sprite/w_attribute_address
add wave -noupdate -radix hexadecimal /tb/u_sprite/w_read_color_address
add wave -noupdate -radix hexadecimal /tb/u_sprite/w_read_pattern_address
add wave -noupdate -radix hexadecimal /tb/u_sprite/ff_y_test_sp_num
add wave -noupdate -radix hexadecimal /tb/u_sprite/ff_y_test_listup_addr
add wave -noupdate -radix hexadecimal /tb/u_sprite/ff_y_test_en
add wave -noupdate -radix hexadecimal /tb/u_sprite/ff_prepare_local_plane_num
add wave -noupdate -radix hexadecimal /tb/u_sprite/ff_prepare_plane_num
add wave -noupdate -radix hexadecimal /tb/u_sprite/ff_prepare_line_num
add wave -noupdate -radix hexadecimal /tb/u_sprite/w_prepare_x_pos
add wave -noupdate -radix hexadecimal /tb/u_sprite/ff_prepare_pattern_num
add wave -noupdate -radix hexadecimal /tb/u_sprite/ff_prepare_end
add wave -noupdate -radix hexadecimal /tb/u_sprite/ff_predraw_local_plane_num
add wave -noupdate -radix hexadecimal /tb/u_sprite/ff_sp_predraw_end
add wave -noupdate -radix hexadecimal /tb/u_sprite/ff_draw_x
add wave -noupdate -radix hexadecimal /tb/u_sprite/ff_draw_pattern
add wave -noupdate -radix hexadecimal /tb/u_sprite/ff_draw_color
add wave -noupdate -radix hexadecimal /tb/u_sprite/w_line_buf_address_even
add wave -noupdate -radix hexadecimal /tb/u_sprite/w_line_buf_address_odd
add wave -noupdate -radix hexadecimal /tb/u_sprite/w_line_buf_we_even
add wave -noupdate -radix hexadecimal /tb/u_sprite/w_line_buf_we_odd
add wave -noupdate -radix hexadecimal /tb/u_sprite/w_line_buf_wdata_even
add wave -noupdate -radix hexadecimal /tb/u_sprite/w_line_buf_wdata_odd
add wave -noupdate -radix hexadecimal /tb/u_sprite/w_line_buf_rdata_even
add wave -noupdate -radix hexadecimal /tb/u_sprite/w_line_buf_rdata_odd
add wave -noupdate -radix hexadecimal /tb/u_sprite/ff_line_buf_disp_we
add wave -noupdate -radix hexadecimal /tb/u_sprite/ff_line_buf_draw_we
add wave -noupdate -radix hexadecimal /tb/u_sprite/ff_line_buf_disp_x
add wave -noupdate -radix hexadecimal /tb/u_sprite/ff_line_buf_draw_x
add wave -noupdate -radix hexadecimal /tb/u_sprite/ff_line_buf_draw_color
add wave -noupdate -radix hexadecimal /tb/u_sprite/w_line_buf_disp_data
add wave -noupdate -radix hexadecimal /tb/u_sprite/w_line_buf_draw_data
add wave -noupdate -radix hexadecimal /tb/u_sprite/ff_window_x
add wave -noupdate -radix hexadecimal /tb/u_sprite/ff_sp_overmap
add wave -noupdate -radix hexadecimal /tb/u_sprite/ff_sp_overmap_num
add wave -noupdate -radix hexadecimal /tb/u_sprite/w_listup_y
add wave -noupdate -radix hexadecimal /tb/u_sprite/w_target_sp_en
add wave -noupdate -radix hexadecimal /tb/u_sprite/w_sp_off
add wave -noupdate -radix hexadecimal /tb/u_sprite/w_sp_overmap
add wave -noupdate -radix hexadecimal /tb/u_sprite/w_active
add wave -noupdate -radix hexadecimal /tb/u_sprite/ff_window_y
add wave -noupdate -radix hexadecimal /tb/u_sprite/w_ram_even_we
add wave -noupdate -radix hexadecimal /tb/u_sprite/w_ram_odd_we
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {116 ns} 0}
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
WaveRestoreZoom {0 ns} {1723 ns}
