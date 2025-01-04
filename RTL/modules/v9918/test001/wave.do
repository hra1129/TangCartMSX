onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/u_vdp/clk
add wave -noupdate /tb/u_vdp/u_v9918_core/enable
add wave -noupdate /tb/u_vdp/iorq_n
add wave -noupdate /tb/u_vdp/wr_n
add wave -noupdate /tb/u_vdp/rd_n
add wave -noupdate /tb/u_vdp/address
add wave -noupdate /tb/u_vdp/u_v9918_core/u_vdp_register/ff_wr_req
add wave -noupdate /tb/u_vdp/u_v9918_core/u_vdp_register/ff_rd_req
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9918_core/u_vdp_register/vdp_p1_data
add wave -noupdate /tb/u_vdp/u_v9918_core/u_vdp_register/vdp_p1_is_1st_byte
add wave -noupdate -radix hexadecimal /tb/u_vdp/p_dram_oe_n
add wave -noupdate -radix hexadecimal /tb/u_vdp/p_dram_we_n
add wave -noupdate -radix hexadecimal /tb/u_vdp/p_dram_address
add wave -noupdate -radix hexadecimal /tb/u_vdp/p_dram_rdata
add wave -noupdate -radix hexadecimal /tb/u_vdp/p_dram_wdata
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9918_core/u_vdp_register/rdata
add wave -noupdate /tb/u_vdp/u_v9918_core/u_vdp_register/rdata_en
add wave -noupdate -radix hexadecimal /tb/u_vram/clk
add wave -noupdate -radix hexadecimal /tb/u_vram/n_cs
add wave -noupdate -radix hexadecimal /tb/u_vram/n_wr
add wave -noupdate -radix hexadecimal /tb/u_vram/n_rd
add wave -noupdate -radix hexadecimal /tb/u_vram/address
add wave -noupdate -radix hexadecimal /tb/u_vram/wdata
add wave -noupdate -radix hexadecimal /tb/u_vram/rdata
add wave -noupdate -radix hexadecimal /tb/u_vram/rdata_en
add wave -noupdate -radix hexadecimal /tb/u_vram/ff_rdata
add wave -noupdate -radix hexadecimal /tb/u_vram/ff_rdata_en
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {492 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 232
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
WaveRestoreZoom {1712 ns} {3523 ns}
