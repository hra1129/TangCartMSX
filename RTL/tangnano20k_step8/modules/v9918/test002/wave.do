onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider IP_VIDEO
add wave -noupdate -radix hexadecimal /tb/u_video/video_de
add wave -noupdate -radix hexadecimal /tb/u_video/video_hs
add wave -noupdate -radix hexadecimal /tb/u_video/video_vs
add wave -noupdate -radix hexadecimal /tb/u_video/video_r
add wave -noupdate -radix hexadecimal /tb/u_video/video_g
add wave -noupdate -radix hexadecimal /tb/u_video/video_b
add wave -noupdate -radix unsigned /tb/u_video/w_h_counter
add wave -noupdate -radix unsigned /tb/u_video/w_v_counter
add wave -noupdate -radix unsigned /tb/u_video/ff_v_counter
add wave -noupdate -divider V9918
add wave -noupdate /tb/u_vdp/u_v9918_core/u_vdp_lcd/enable
add wave -noupdate /tb/u_vdp/pvideo_data_en
add wave -noupdate /tb/u_vdp/pvideohs_n
add wave -noupdate /tb/u_vdp/pvideovs_n
add wave -noupdate -radix hexadecimal /tb/u_vdp/pvideor
add wave -noupdate -radix hexadecimal /tb/u_vdp/pvideog
add wave -noupdate -radix hexadecimal /tb/u_vdp/pvideob
add wave -noupdate -radix unsigned /tb/u_vdp/u_v9918_core/u_vdp_lcd/vcounterin
add wave -noupdate -radix unsigned /tb/u_vdp/u_v9918_core/u_vdp_lcd/ff_h_cnt
add wave -noupdate /tb/u_vdp/u_v9918_core/u_vdp_lcd/w_h_pulse_start
add wave -noupdate /tb/u_vdp/u_v9918_core/u_vdp_lcd/w_h_pulse_end
add wave -noupdate /tb/u_vdp/u_v9918_core/u_vdp_lcd/w_h_back_porch_end
add wave -noupdate /tb/u_vdp/u_v9918_core/u_vdp_lcd/w_h_active_end
add wave -noupdate /tb/u_vdp/u_v9918_core/u_vdp_lcd/w_h_front_porch_end
add wave -noupdate /tb/u_vdp/u_v9918_core/u_vdp_lcd/w_h_line_end
add wave -noupdate /tb/u_vdp/u_v9918_core/u_vdp_lcd/w_h_vdp_active_start
add wave -noupdate /tb/u_vdp/u_v9918_core/u_vdp_lcd/w_h_vdp_active_end
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1683 ns} 0} {{Cursor 2} {13610399 ns} 0}
quietly wave cursor active 2
configure wave -namecolwidth 216
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
WaveRestoreZoom {13595274 ns} {13626282 ns}
