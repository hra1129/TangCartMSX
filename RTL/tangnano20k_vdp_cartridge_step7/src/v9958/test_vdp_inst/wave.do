onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9958_core/u_vdp_sprite/clk
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9958_core/u_vdp_sprite/reset
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9958_core/u_vdp_sprite/enable
add wave -noupdate -radix unsigned /tb/u_vdp/u_v9958_core/u_vdp_sprite/dot_counter_yp
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9958_core/u_vdp_sprite/bwindow_y
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9958_core/u_vdp_sprite/reg_r1_sp_size
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9958_core/u_vdp_sprite/reg_r1_sp_zoom
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9958_core/u_vdp_sprite/reg_r11r5_sp_atr_addr
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9958_core/u_vdp_sprite/reg_r6_sp_gen_addr
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9958_core/u_vdp_sprite/reg_r8_col0_on
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9958_core/u_vdp_sprite/reg_r8_sp_off
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9958_core/u_vdp_sprite/reg_r23_vstart_line
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9958_core/u_vdp_sprite/reg_r27_h_scroll
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9958_core/u_vdp_sprite/p_sp_mode2
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9958_core/u_vdp_sprite/vram_interleave_mode
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9958_core/u_vdp_sprite/sp_vram_accessing
add wave -noupdate -radix unsigned /tb/u_vdp/u_v9958_core/u_vdp_sprite/p_vram_rdata
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9958_core/u_vdp_sprite/p_vram_address
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9958_core/u_vdp_sprite/sp_color_code_en
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9958_core/u_vdp_sprite/sp_color_code
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9958_core/u_vdp_sprite/reg_r9_y_dots
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9958_core/u_vdp_sprite/ff_sp_en
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9958_core/u_vdp_sprite/ff_cur_y
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9958_core/u_vdp_sprite/ff_prev_cur_y
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9958_core/u_vdp_sprite/ff_vdps0resetack
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9958_core/u_vdp_sprite/ff_vdps5resetack
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9958_core/u_vdp_sprite/w_info_address
add wave -noupdate -radix unsigned /tb/u_vdp/u_v9958_core/u_vdp_sprite/eight_dot_state
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9958_core/u_vdp_sprite/ff_info_ram_we
add wave -noupdate -radix hexadecimal -childformat {{{/tb/u_vdp/u_v9958_core/u_vdp_sprite/w_info_wdata[31]} -radix hexadecimal} {{/tb/u_vdp/u_v9958_core/u_vdp_sprite/w_info_wdata[30]} -radix hexadecimal} {{/tb/u_vdp/u_v9958_core/u_vdp_sprite/w_info_wdata[29]} -radix hexadecimal} {{/tb/u_vdp/u_v9958_core/u_vdp_sprite/w_info_wdata[28]} -radix hexadecimal} {{/tb/u_vdp/u_v9958_core/u_vdp_sprite/w_info_wdata[27]} -radix hexadecimal} {{/tb/u_vdp/u_v9958_core/u_vdp_sprite/w_info_wdata[26]} -radix hexadecimal} {{/tb/u_vdp/u_v9958_core/u_vdp_sprite/w_info_wdata[25]} -radix hexadecimal} {{/tb/u_vdp/u_v9958_core/u_vdp_sprite/w_info_wdata[24]} -radix hexadecimal} {{/tb/u_vdp/u_v9958_core/u_vdp_sprite/w_info_wdata[23]} -radix hexadecimal} {{/tb/u_vdp/u_v9958_core/u_vdp_sprite/w_info_wdata[22]} -radix hexadecimal} {{/tb/u_vdp/u_v9958_core/u_vdp_sprite/w_info_wdata[21]} -radix hexadecimal} {{/tb/u_vdp/u_v9958_core/u_vdp_sprite/w_info_wdata[20]} -radix hexadecimal} {{/tb/u_vdp/u_v9958_core/u_vdp_sprite/w_info_wdata[19]} -radix hexadecimal} {{/tb/u_vdp/u_v9958_core/u_vdp_sprite/w_info_wdata[18]} -radix hexadecimal} {{/tb/u_vdp/u_v9958_core/u_vdp_sprite/w_info_wdata[17]} -radix hexadecimal} {{/tb/u_vdp/u_v9958_core/u_vdp_sprite/w_info_wdata[16]} -radix hexadecimal} {{/tb/u_vdp/u_v9958_core/u_vdp_sprite/w_info_wdata[15]} -radix hexadecimal} {{/tb/u_vdp/u_v9958_core/u_vdp_sprite/w_info_wdata[14]} -radix hexadecimal} {{/tb/u_vdp/u_v9958_core/u_vdp_sprite/w_info_wdata[13]} -radix hexadecimal} {{/tb/u_vdp/u_v9958_core/u_vdp_sprite/w_info_wdata[12]} -radix hexadecimal} {{/tb/u_vdp/u_v9958_core/u_vdp_sprite/w_info_wdata[11]} -radix hexadecimal} {{/tb/u_vdp/u_v9958_core/u_vdp_sprite/w_info_wdata[10]} -radix hexadecimal} {{/tb/u_vdp/u_v9958_core/u_vdp_sprite/w_info_wdata[9]} -radix hexadecimal} {{/tb/u_vdp/u_v9958_core/u_vdp_sprite/w_info_wdata[8]} -radix hexadecimal} {{/tb/u_vdp/u_v9958_core/u_vdp_sprite/w_info_wdata[7]} -radix hexadecimal} {{/tb/u_vdp/u_v9958_core/u_vdp_sprite/w_info_wdata[6]} -radix hexadecimal} {{/tb/u_vdp/u_v9958_core/u_vdp_sprite/w_info_wdata[5]} -radix hexadecimal} {{/tb/u_vdp/u_v9958_core/u_vdp_sprite/w_info_wdata[4]} -radix hexadecimal} {{/tb/u_vdp/u_v9958_core/u_vdp_sprite/w_info_wdata[3]} -radix hexadecimal} {{/tb/u_vdp/u_v9958_core/u_vdp_sprite/w_info_wdata[2]} -radix hexadecimal} {{/tb/u_vdp/u_v9958_core/u_vdp_sprite/w_info_wdata[1]} -radix hexadecimal} {{/tb/u_vdp/u_v9958_core/u_vdp_sprite/w_info_wdata[0]} -radix hexadecimal}} -subitemconfig {{/tb/u_vdp/u_v9958_core/u_vdp_sprite/w_info_wdata[31]} {-radix hexadecimal} {/tb/u_vdp/u_v9958_core/u_vdp_sprite/w_info_wdata[30]} {-radix hexadecimal} {/tb/u_vdp/u_v9958_core/u_vdp_sprite/w_info_wdata[29]} {-radix hexadecimal} {/tb/u_vdp/u_v9958_core/u_vdp_sprite/w_info_wdata[28]} {-radix hexadecimal} {/tb/u_vdp/u_v9958_core/u_vdp_sprite/w_info_wdata[27]} {-radix hexadecimal} {/tb/u_vdp/u_v9958_core/u_vdp_sprite/w_info_wdata[26]} {-radix hexadecimal} {/tb/u_vdp/u_v9958_core/u_vdp_sprite/w_info_wdata[25]} {-radix hexadecimal} {/tb/u_vdp/u_v9958_core/u_vdp_sprite/w_info_wdata[24]} {-radix hexadecimal} {/tb/u_vdp/u_v9958_core/u_vdp_sprite/w_info_wdata[23]} {-radix hexadecimal} {/tb/u_vdp/u_v9958_core/u_vdp_sprite/w_info_wdata[22]} {-radix hexadecimal} {/tb/u_vdp/u_v9958_core/u_vdp_sprite/w_info_wdata[21]} {-radix hexadecimal} {/tb/u_vdp/u_v9958_core/u_vdp_sprite/w_info_wdata[20]} {-radix hexadecimal} {/tb/u_vdp/u_v9958_core/u_vdp_sprite/w_info_wdata[19]} {-radix hexadecimal} {/tb/u_vdp/u_v9958_core/u_vdp_sprite/w_info_wdata[18]} {-radix hexadecimal} {/tb/u_vdp/u_v9958_core/u_vdp_sprite/w_info_wdata[17]} {-radix hexadecimal} {/tb/u_vdp/u_v9958_core/u_vdp_sprite/w_info_wdata[16]} {-radix hexadecimal} {/tb/u_vdp/u_v9958_core/u_vdp_sprite/w_info_wdata[15]} {-radix hexadecimal} {/tb/u_vdp/u_v9958_core/u_vdp_sprite/w_info_wdata[14]} {-radix hexadecimal} {/tb/u_vdp/u_v9958_core/u_vdp_sprite/w_info_wdata[13]} {-radix hexadecimal} {/tb/u_vdp/u_v9958_core/u_vdp_sprite/w_info_wdata[12]} {-radix hexadecimal} {/tb/u_vdp/u_v9958_core/u_vdp_sprite/w_info_wdata[11]} {-radix hexadecimal} {/tb/u_vdp/u_v9958_core/u_vdp_sprite/w_info_wdata[10]} {-radix hexadecimal} {/tb/u_vdp/u_v9958_core/u_vdp_sprite/w_info_wdata[9]} {-radix hexadecimal} {/tb/u_vdp/u_v9958_core/u_vdp_sprite/w_info_wdata[8]} {-radix hexadecimal} {/tb/u_vdp/u_v9958_core/u_vdp_sprite/w_info_wdata[7]} {-radix hexadecimal} {/tb/u_vdp/u_v9958_core/u_vdp_sprite/w_info_wdata[6]} {-radix hexadecimal} {/tb/u_vdp/u_v9958_core/u_vdp_sprite/w_info_wdata[5]} {-radix hexadecimal} {/tb/u_vdp/u_v9958_core/u_vdp_sprite/w_info_wdata[4]} {-radix hexadecimal} {/tb/u_vdp/u_v9958_core/u_vdp_sprite/w_info_wdata[3]} {-radix hexadecimal} {/tb/u_vdp/u_v9958_core/u_vdp_sprite/w_info_wdata[2]} {-radix hexadecimal} {/tb/u_vdp/u_v9958_core/u_vdp_sprite/w_info_wdata[1]} {-radix hexadecimal} {/tb/u_vdp/u_v9958_core/u_vdp_sprite/w_info_wdata[0]} {-radix hexadecimal}} /tb/u_vdp/u_v9958_core/u_vdp_sprite/w_info_wdata
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9958_core/u_vdp_sprite/w_info_rdata
add wave -noupdate -radix unsigned /tb/u_vdp/u_v9958_core/u_vdp_sprite/ff_info_x
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9958_core/u_vdp_sprite/ff_info_pattern
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9958_core/u_vdp_sprite/ff_info_color
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9958_core/u_vdp_sprite/ff_info_cc
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9958_core/u_vdp_sprite/ff_info_ic
add wave -noupdate -radix unsigned /tb/u_vdp/u_v9958_core/u_vdp_sprite/w_info_x
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9958_core/u_vdp_sprite/w_info_pattern
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9958_core/u_vdp_sprite/w_info_color
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9958_core/u_vdp_sprite/w_info_cc
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9958_core/u_vdp_sprite/w_info_ic
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9958_core/u_vdp_sprite/ff_main_state
add wave -noupdate -radix binary /tb/u_vdp/u_v9958_core/u_vdp_sprite/dot_state
add wave -noupdate -radix unsigned /tb/u_vdp/u_v9958_core/u_vdp_sprite/dot_counter_x
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9958_core/u_vdp_sprite/ff_predraw_local_plane_num
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9958_core/u_vdp_sprite/w_vram_address
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9958_core/u_vdp_sprite/ff_y_test_address
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9958_core/u_vdp_sprite/ff_preread_address
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9958_core/u_vdp_sprite/ff_attribute_base_address
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9958_core/u_vdp_sprite/ff_pattern_gen_base_address
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9958_core/u_vdp_sprite/w_attribute_address
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9958_core/u_vdp_sprite/w_read_color_address
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9958_core/u_vdp_sprite/w_read_pattern_address
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9958_core/u_vdp_sprite/ff_y_test_sp_num
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9958_core/u_vdp_sprite/ff_y_test_listup_addr
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9958_core/u_vdp_sprite/ff_y_test_en
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9958_core/u_vdp_sprite/ff_prepare_local_plane_num
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9958_core/u_vdp_sprite/ff_prepare_plane_num
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9958_core/u_vdp_sprite/ff_prepare_line_num
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9958_core/u_vdp_sprite/w_prepare_x_pos
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9958_core/u_vdp_sprite/ff_prepare_pattern_num
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9958_core/u_vdp_sprite/ff_prepare_end
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9958_core/u_vdp_sprite/ff_sp_predraw_end
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9958_core/u_vdp_sprite/ff_draw_x
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9958_core/u_vdp_sprite/ff_draw_pattern
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9958_core/u_vdp_sprite/ff_draw_color
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9958_core/u_vdp_sprite/w_line_buf_address_even
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9958_core/u_vdp_sprite/w_line_buf_address_odd
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9958_core/u_vdp_sprite/w_line_buf_we_even
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9958_core/u_vdp_sprite/w_line_buf_we_odd
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9958_core/u_vdp_sprite/w_line_buf_wdata_even
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9958_core/u_vdp_sprite/w_line_buf_wdata_odd
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9958_core/u_vdp_sprite/w_line_buf_rdata_even
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9958_core/u_vdp_sprite/w_line_buf_rdata_odd
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9958_core/u_vdp_sprite/ff_line_buf_disp_we
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9958_core/u_vdp_sprite/ff_line_buf_draw_we
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9958_core/u_vdp_sprite/ff_line_buf_disp_x
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9958_core/u_vdp_sprite/ff_line_buf_draw_x
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9958_core/u_vdp_sprite/ff_line_buf_draw_color
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9958_core/u_vdp_sprite/w_line_buf_disp_data
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9958_core/u_vdp_sprite/w_line_buf_draw_data
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9958_core/u_vdp_sprite/ff_window_x
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9958_core/u_vdp_sprite/ff_sp_overmap
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9958_core/u_vdp_sprite/ff_sp_overmap_num
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9958_core/u_vdp_sprite/w_listup_y
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9958_core/u_vdp_sprite/w_target_sp_en
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9958_core/u_vdp_sprite/w_sp_off
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9958_core/u_vdp_sprite/w_sp_overmap
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9958_core/u_vdp_sprite/w_active
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9958_core/u_vdp_sprite/ff_window_y
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9958_core/u_vdp_sprite/w_ram_even_we
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9958_core/u_vdp_sprite/w_ram_odd_we
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {4042577 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 297
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
WaveRestoreZoom {4041976 ns} {4043317 ns}
