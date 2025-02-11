onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /tb/u_video_out_hmag/clk
add wave -noupdate -radix hexadecimal /tb/u_video_out_hmag/reset_n
add wave -noupdate -radix hexadecimal /tb/u_video_out_hmag/enable
add wave -noupdate -radix hexadecimal /tb/u_video_out_hmag/vdp_hcounter
add wave -noupdate -radix hexadecimal /tb/u_video_out_hmag/vdp_vcounter
add wave -noupdate -radix hexadecimal /tb/u_video_out_hmag/h_cnt
add wave -noupdate -radix hexadecimal /tb/u_video_out_hmag/vdp_r
add wave -noupdate -radix hexadecimal /tb/u_video_out_hmag/vdp_g
add wave -noupdate -radix hexadecimal /tb/u_video_out_hmag/vdp_b
add wave -noupdate -radix hexadecimal /tb/u_video_out_hmag/video_r
add wave -noupdate -radix hexadecimal /tb/u_video_out_hmag/video_g
add wave -noupdate -radix hexadecimal /tb/u_video_out_hmag/video_b
add wave -noupdate -radix hexadecimal /tb/u_video_out_hmag/reg_left_offset
add wave -noupdate -radix unsigned /tb/u_video_out_hmag/reg_denominator
add wave -noupdate -radix unsigned /tb/u_video_out_hmag/reg_normalize
add wave -noupdate -radix unsigned /tb/u_video_out_hmag/w_x_position_w
add wave -noupdate -radix unsigned /tb/u_video_out_hmag/ff_numerator
add wave -noupdate -radix unsigned /tb/u_video_out_hmag/w_next_numerator
add wave -noupdate -radix decimal /tb/u_video_out_hmag/w_sub_numerator
add wave -noupdate -radix hexadecimal /tb/u_video_out_hmag/w_hold
add wave -noupdate -radix unsigned /tb/u_video_out_hmag/ff_x_position_r
add wave -noupdate -radix unsigned /tb/u_video_out_hmag/w_normalized_numerator
add wave -noupdate -radix unsigned /tb/u_video_out_hmag/ff_coeff
add wave -noupdate -radix unsigned /tb/u_video_out_hmag/w_sigmoid
add wave -noupdate -radix unsigned /tb/u_video_out_hmag/w_pixel_r
add wave -noupdate -radix unsigned /tb/u_video_out_hmag/u_bilinear_r/ff_tap0
add wave -noupdate -radix unsigned /tb/u_video_out_hmag/u_bilinear_r/ff_tap1
add wave -noupdate -radix unsigned /tb/u_video_out_hmag/u_bilinear_r/ff_tap1_delay
add wave -noupdate -radix unsigned /tb/u_video_out_hmag/u_bilinear_r/ff_out
add wave -noupdate -radix hexadecimal /tb/u_video_out_hmag/ff_active
add wave -noupdate -radix hexadecimal /tb/u_video_out_hmag/w_active_start
add wave -noupdate -radix hexadecimal /tb/u_video_out_hmag/w_active_end
add wave -noupdate -radix hexadecimal /tb/u_video_out_hmag/w_is_odd
add wave -noupdate -radix hexadecimal /tb/u_video_out_hmag/w_we_buf
add wave -noupdate -radix hexadecimal /tb/u_video_out_hmag/w_pixel_g
add wave -noupdate -radix hexadecimal /tb/u_video_out_hmag/w_pixel_b
add wave -noupdate -radix hexadecimal /tb/u_video_out_hmag/ff_hold0
add wave -noupdate -radix hexadecimal /tb/u_video_out_hmag/ff_hold1
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 0
configure wave -namecolwidth 291
configure wave -valuecolwidth 40
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
WaveRestoreZoom {165390 ns} {166151 ns}
