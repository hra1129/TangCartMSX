onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_color_palette/palette_valid
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_color_palette/palette_num
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_color_palette/palette_r
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_color_palette/palette_g
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_color_palette/palette_b
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_color_palette/ff_display_color
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_color_palette/ff_display_color_oe
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_color_palette/w_display_r16
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_color_palette/w_display_g16
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_color_palette/w_display_b16
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 0
configure wave -namecolwidth 237
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
WaveRestoreZoom {0 ns} {400348446 ns}
