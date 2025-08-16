# Wave configuration for vdp_command_cache testbench with flush functionality
# This file can be used to set up specific signal viewing in ModelSim

# Add clock and reset
add wave -noupdate -divider {Clock and Reset}
add wave -noupdate /tb/clk
add wave -noupdate /tb/reset_n
add wave -noupdate /tb/start
add wave -noupdate /tb/cache_flush_start
add wave -noupdate /tb/cache_flush_end

# Add VDP command interface signals
add wave -noupdate -divider {VDP Command Interface}
add wave -noupdate -radix hexadecimal /tb/cache_vram_address
add wave -noupdate /tb/cache_vram_valid
add wave -noupdate /tb/cache_vram_ready
add wave -noupdate /tb/cache_vram_write
add wave -noupdate -radix hexadecimal /tb/cache_vram_wdata
add wave -noupdate -radix hexadecimal /tb/cache_vram_rdata
add wave -noupdate /tb/cache_vram_rdata_en

# Add VRAM interface signals
add wave -noupdate -divider {VRAM Interface}
add wave -noupdate -radix hexadecimal /tb/command_vram_address
add wave -noupdate /tb/command_vram_valid
add wave -noupdate /tb/command_vram_ready
add wave -noupdate /tb/command_vram_write
add wave -noupdate -radix hexadecimal /tb/command_vram_wdata
add wave -noupdate -radix binary /tb/command_vram_wdata_mask
add wave -noupdate -radix hexadecimal /tb/command_vram_rdata
add wave -noupdate /tb/command_vram_rdata_en

# Add internal DUT signals (if accessible)
add wave -noupdate -divider {DUT Internal Signals}
add wave -noupdate -radix hexadecimal /tb/u_dut/ff_last0_read_address
add wave -noupdate -radix hexadecimal /tb/u_dut/ff_last0_read_data
add wave -noupdate /tb/u_dut/ff_last0_read_en
add wave -noupdate -radix hexadecimal /tb/u_dut/ff_last1_read_address
add wave -noupdate -radix hexadecimal /tb/u_dut/ff_last1_read_data
add wave -noupdate /tb/u_dut/ff_last1_read_en
add wave -noupdate -radix hexadecimal /tb/u_dut/ff_last0_write_address
add wave -noupdate -radix hexadecimal /tb/u_dut/ff_last0_write_data
add wave -noupdate -radix binary /tb/u_dut/ff_last0_write_mask
add wave -noupdate /tb/u_dut/ff_last0_write_en
add wave -noupdate -radix hexadecimal /tb/u_dut/ff_last1_write_address
add wave -noupdate -radix hexadecimal /tb/u_dut/ff_last1_write_data
add wave -noupdate -radix binary /tb/u_dut/ff_last1_write_mask
add wave -noupdate /tb/u_dut/ff_last1_write_en

# Add test control signals
add wave -noupdate -divider {Test Control}
add wave -noupdate /tb/vram_delay_counter
add wave -noupdate /tb/timeout_counter

configure wave -namecolwidth 250
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2

TreeUpdate [SetDefaultTree]
WaveRestoreZoom {0 ns} {10000 ns}
