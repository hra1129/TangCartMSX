onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /tb/u_video_out/clk
add wave -noupdate -radix hexadecimal /tb/u_video_out/reset_n
add wave -noupdate -radix hexadecimal /tb/u_video_out/h_count
add wave -noupdate -radix hexadecimal /tb/u_video_out/v_count
add wave -noupdate -radix hexadecimal /tb/u_video_out/has_scanline
add wave -noupdate -radix hexadecimal /tb/u_video_out/w_x_position_w
add wave -noupdate -format Analog-Step -height 74 -max 254.99999999999997 -radix hexadecimal /tb/u_video_out/vdp_r
add wave -noupdate -radix hexadecimal /tb/u_video_out/display_hs
add wave -noupdate -radix hexadecimal /tb/u_video_out/display_vs
add wave -noupdate -radix hexadecimal /tb/u_video_out/display_en
add wave -noupdate -format Analog-Step -height 74 -max 128.0 -radix hexadecimal /tb/u_video_out/display_r
add wave -noupdate -radix hexadecimal /tb/u_video_out/w_hold
add wave -noupdate -radix hexadecimal /tb/u_video_out/reg_denominator
add wave -noupdate -radix hexadecimal /tb/u_video_out/reg_normalize
add wave -noupdate -radix unsigned /tb/u_video_out/ff_x_position_r
add wave -noupdate -radix hexadecimal /tb/u_video_out/ff_active
add wave -noupdate /tb/u_video_out/w_enable
add wave -noupdate -radix unsigned /tb/u_video_out/ff_numerator
add wave -noupdate -radix unsigned /tb/u_video_out/w_next_numerator
add wave -noupdate -radix hexadecimal /tb/u_video_out/w_active_start
add wave -noupdate -radix hexadecimal /tb/u_video_out/w_active_end
add wave -noupdate -radix hexadecimal /tb/u_video_out/w_h_cnt_end
add wave -noupdate -radix hexadecimal /tb/u_video_out/w_is_write_odd
add wave -noupdate -radix hexadecimal /tb/u_video_out/w_pixel_r
add wave -noupdate -radix hexadecimal /tb/u_video_out/w_normalized_numerator
add wave -noupdate -radix hexadecimal /tb/u_video_out/ff_coeff
add wave -noupdate -radix hexadecimal /tb/u_video_out/ff_coeff1
add wave -noupdate -radix hexadecimal /tb/u_video_out/ff_coeff2
add wave -noupdate -radix hexadecimal /tb/u_video_out/ff_hold0
add wave -noupdate -radix hexadecimal /tb/u_video_out/ff_hold1
add wave -noupdate -radix hexadecimal /tb/u_video_out/ff_hold2
add wave -noupdate -radix hexadecimal /tb/u_video_out/ff_hold3
add wave -noupdate -radix hexadecimal /tb/u_video_out/ff_hold4
add wave -noupdate -radix hexadecimal /tb/u_video_out/ff_tap0_r
add wave -noupdate -radix hexadecimal /tb/u_video_out/ff_tap1_r
add wave -noupdate -radix hexadecimal /tb/u_video_out/w_bilinear_r
add wave -noupdate -radix hexadecimal /tb/u_video_out/w_scanline_gain
add wave -noupdate -radix hexadecimal /tb/u_video_out/w_gain
add wave -noupdate -radix hexadecimal /tb/u_video_out/ff_bilinear_r
add wave -noupdate -radix hexadecimal /tb/u_video_out/ff_gain
add wave -noupdate -radix hexadecimal /tb/u_video_out/w_display_r
add wave -noupdate -radix hexadecimal /tb/u_video_out/ff_display_r
add wave -noupdate -radix hexadecimal /tb/u_video_out/ff_h_en
add wave -noupdate -radix hexadecimal /tb/u_video_out/ff_v_en
add wave -noupdate -radix hexadecimal /tb/u_video_out/ff_hs
add wave -noupdate -radix hexadecimal /tb/u_video_out/ff_vs
add wave -noupdate -radix hexadecimal /tb/u_video_out/w_h_en_start
add wave -noupdate -radix hexadecimal /tb/u_video_out/w_h_en_end
add wave -noupdate -radix hexadecimal /tb/u_video_out/w_v_en_start
add wave -noupdate -radix hexadecimal /tb/u_video_out/w_v_en_end
add wave -noupdate -radix hexadecimal /tb/u_video_out/w_hs_start
add wave -noupdate -radix hexadecimal /tb/u_video_out/w_hs_end
add wave -noupdate -radix hexadecimal /tb/u_video_out/w_vs_start
add wave -noupdate -radix hexadecimal /tb/u_video_out/w_vs_end
add wave -noupdate -radix hexadecimal /tb/u_video_out/w_display_en
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {695 ns} 0}
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
WaveRestoreZoom {1129136 ns} {1129773 ns}
