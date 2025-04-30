onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /tb/u_dut/u_vram/clk
add wave -noupdate -radix hexadecimal /tb/u_dut/u_vram/n_wr
add wave -noupdate -radix hexadecimal /tb/u_dut/u_vram/n_rd
add wave -noupdate -radix hexadecimal /tb/u_dut/u_vram/address
add wave -noupdate -radix hexadecimal /tb/u_dut/u_vram/wdata
add wave -noupdate -radix hexadecimal /tb/u_dut/u_vram/rdata
add wave -noupdate -radix hexadecimal /tb/u_dut/u_vram/rdata_en
add wave -noupdate -radix hexadecimal /tb/u_dut/ff_vram_rdata
add wave -noupdate -radix hexadecimal /tb/u_dut/ff_vram_rdata1
add wave -noupdate -radix hexadecimal /tb/u_dut/ff_vram_rdata2
add wave -noupdate -radix hexadecimal /tb/u_dut/u_sdram/vdp_access
add wave -noupdate -radix hexadecimal /tb/u_dut/u_sdram/vdp_address
add wave -noupdate -radix hexadecimal /tb/u_dut/u_sdram/vdp_wr_n
add wave -noupdate -radix hexadecimal /tb/u_dut/u_sdram/vdp_rd_n
add wave -noupdate -radix hexadecimal /tb/u_dut/u_sdram/vdp_wdata
add wave -noupdate -radix hexadecimal /tb/u_dut/u_sdram/vdp_rdata
add wave -noupdate -radix hexadecimal /tb/u_dut/u_sdram/vdp_rdata_en
add wave -noupdate /tb/u_dut/u_v9958/u_v9958_core/u_vdp_color_bus/enable
add wave -noupdate /tb/u_dut/u_v9958/u_v9958_core/u_vdp_color_bus/dot_state
add wave -noupdate -radix unsigned /tb/u_dut/u_v9958/u_v9958_core/u_vdp_color_bus/eight_dot_state
add wave -noupdate -radix hexadecimal /tb/u_dut/u_v9958/u_v9958_core/u_vdp_graphic123m/w_pattern_name_address
add wave -noupdate -radix hexadecimal /tb/u_dut/u_v9958/u_v9958_core/u_vdp_graphic123m/w_pattern_generator_address
add wave -noupdate -radix hexadecimal /tb/u_dut/u_v9958/u_v9958_core/u_vdp_graphic123m/w_color_address
add wave -noupdate -radix hexadecimal /tb/u_dut/u_v9958/u_v9958_core/u_vdp_graphic123m/ff_vram_address
add wave -noupdate -radix unsigned /tb/u_dut/u_v9958/u_v9958_core/u_vdp_color_bus/vram_access/ff_color_bus_state
add wave -noupdate /tb/u_dut/u_v9958/u_v9958_core/u_vdp_color_bus/p_prewindow
add wave -noupdate -radix hexadecimal /tb/u_dut/u_v9958/u_v9958_core/u_vdp_color_bus/p_vram_address_cpu
add wave -noupdate -radix hexadecimal /tb/u_dut/u_v9958/u_v9958_core/u_vdp_color_bus/p_vram_address_sprite
add wave -noupdate -radix hexadecimal /tb/u_dut/u_v9958/u_v9958_core/u_vdp_color_bus/p_vram_address_text12
add wave -noupdate -radix hexadecimal /tb/u_dut/u_v9958/u_v9958_core/u_vdp_color_bus/p_vram_address_graphic123m
add wave -noupdate -radix hexadecimal /tb/u_dut/u_v9958/u_v9958_core/u_vdp_color_bus/p_vram_address_graphic4567
add wave -noupdate -radix hexadecimal /tb/u_dut/u_v9958/u_v9958_core/u_vdp_color_bus/p_vdpcmd_vram_address
add wave -noupdate -radix hexadecimal /tb/u_dut/u_v9958/u_v9958_core/u_vdp_color_bus/ff_vram_access_address
add wave -noupdate -radix hexadecimal /tb/u_dut/u_v9958/u_v9958_core/u_vdp_color_bus/vram_access/ff_vram_access_address_pre
add wave -noupdate -radix hexadecimal /tb/u_dut/u_v9958/u_v9958_core/u_vdp_color_bus/ff_dram_address
add wave -noupdate -radix hexadecimal /tb/u_dut/u_v9958/u_v9958_core/u_vdp_color_bus/ff_dram_rdata
add wave -noupdate -radix hexadecimal /tb/u_dut/u_v9958/u_v9958_core/u_vdp_graphic123m/p_ram_dat
add wave -noupdate -radix hexadecimal /tb/u_dut/u_v9958/u_v9958_core/u_vdp_graphic123m/ff_ram_dat
add wave -noupdate -radix hexadecimal /tb/u_dut/u_v9958/u_v9958_core/u_vdp_graphic123m/ff_pre_pattern_num
add wave -noupdate -radix hexadecimal /tb/u_dut/u_v9958/u_v9958_core/u_vdp_graphic123m/ff_pre_pattern_generator
add wave -noupdate -radix hexadecimal /tb/u_dut/u_v9958/u_v9958_core/u_vdp_graphic123m/ff_pre_color
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {236701374830 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 303
configure wave -valuecolwidth 55
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
WaveRestoreZoom {236698786056 ps} {236704997472 ps}
