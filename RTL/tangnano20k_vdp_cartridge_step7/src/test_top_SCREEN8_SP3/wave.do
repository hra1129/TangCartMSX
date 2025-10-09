onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_screen_mode/reset_n
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_timing_control/u_screen_mode/clk
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_vram_interface/cpu_vram_address
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_vram_interface/cpu_vram_valid
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_vram_interface/cpu_vram_ready
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_vram_interface/cpu_vram_write
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_vram_interface/cpu_vram_wdata
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_vram_interface/cpu_vram_rdata
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_vram_interface/cpu_vram_rdata_en
add wave -noupdate /tb/u_vdp_cartridge/u_v9958/u_vram_interface/vram_refresh
add wave -noupdate /tb/u_vdp_cartridge/u_v9958/u_vram_interface/w_vram_refresh
add wave -noupdate /tb/u_vdp_cartridge/u_v9958/u_vram_interface/ff_vram_refresh
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_vram_interface/h_count
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {100462573 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 327
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
WaveRestoreZoom {100465599 ns} {100465920 ns}
