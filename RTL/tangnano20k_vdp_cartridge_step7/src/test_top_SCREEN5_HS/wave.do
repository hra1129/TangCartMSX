onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_cpu_interface/bus_address
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_cpu_interface/bus_ioreq
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_cpu_interface/bus_write
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_cpu_interface/bus_valid
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_cpu_interface/bus_ready
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_cpu_interface/bus_wdata
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_cpu_interface/bus_rdata
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/u_cpu_interface/bus_rdata_en
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_v9958/vram_refresh
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_sdram/bus_address
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_sdram/bus_valid
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_sdram/bus_write
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_sdram/bus_refresh
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_sdram/bus_wdata
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_sdram/bus_wdata_mask
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_sdram/bus_rdata
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_sdram/bus_rdata_en
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_sdram/ff_main_state
add wave -noupdate -radix hexadecimal /tb/u_vdp_cartridge/u_sdram/ff_do_refresh
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 0
configure wave -namecolwidth 225
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
WaveRestoreZoom {0 ns} {12218183 ns}
