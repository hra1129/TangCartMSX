onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider CPU
add wave -noupdate -radix hexadecimal /tb/u_dut/u_z80/u_cz80/sp
add wave -noupdate -radix hexadecimal /tb/u_dut/u_z80/u_cz80/pc
add wave -noupdate -radix hexadecimal /tb/u_dut/u_z80/d
add wave -noupdate -radix hexadecimal /tb/u_dut/u_z80/a
add wave -noupdate /tb/u_dut/u_z80/m1_n
add wave -noupdate /tb/u_dut/u_z80/rd_n
add wave -noupdate /tb/u_dut/u_z80/wr_n
add wave -noupdate -divider PPI
add wave -noupdate -radix hexadecimal /tb/u_dut/u_ppi/u_ppi/ff_port_a
add wave -noupdate -divider VDP
add wave -noupdate -radix hexadecimal /tb/u_dut/u_v9918/int_n
add wave -noupdate -radix hexadecimal /tb/u_dut/u_v9918/iorq_n
add wave -noupdate -radix hexadecimal /tb/u_dut/u_v9918/rd_n
add wave -noupdate -radix hexadecimal /tb/u_dut/u_v9918/wr_n
add wave -noupdate -radix hexadecimal /tb/u_dut/u_v9918/address
add wave -noupdate -divider {SDRAM Controller}
add wave -noupdate -radix hexadecimal /tb/u_dut/u_sdram/rd_n
add wave -noupdate -radix hexadecimal /tb/u_dut/u_sdram/wr_n
add wave -noupdate -radix hexadecimal /tb/u_dut/u_sdram/rfsh_n
add wave -noupdate -radix hexadecimal /tb/u_dut/u_sdram/address
add wave -noupdate -radix hexadecimal /tb/u_dut/u_sdram/wdata
add wave -noupdate -radix hexadecimal /tb/u_dut/u_sdram/O_sdram_dqm
add wave -noupdate -radix hexadecimal /tb/u_dut/u_sdram/rdata
add wave -noupdate -radix hexadecimal /tb/u_dut/u_sdram/rdata_en
add wave -noupdate -radix hexadecimal /tb/u_dut/u_sdram/ff_main_state
add wave -noupdate /tb/u_dut/u_sdram/ff_rd_n
add wave -noupdate /tb/u_dut/u_sdram/ff_do_refresh
add wave -noupdate -divider DEBUG
add wave -noupdate /tb/u_dut/w_debug_signal
add wave -noupdate -divider {CPU Registers}
add wave -noupdate -radix hexadecimal /tb/u_dut/u_z80/u_cz80/u_regs/reset_n
add wave -noupdate -radix hexadecimal /tb/u_dut/u_z80/u_cz80/u_regs/clk
add wave -noupdate -radix hexadecimal /tb/u_dut/u_z80/u_cz80/u_regs/cen
add wave -noupdate -radix hexadecimal /tb/u_dut/u_z80/u_cz80/u_regs/we_h
add wave -noupdate -radix hexadecimal /tb/u_dut/u_z80/u_cz80/u_regs/we_l
add wave -noupdate -radix hexadecimal /tb/u_dut/u_z80/u_cz80/u_regs/address_a
add wave -noupdate -radix hexadecimal /tb/u_dut/u_z80/u_cz80/u_regs/address_b
add wave -noupdate -radix hexadecimal /tb/u_dut/u_z80/u_cz80/u_regs/address_c
add wave -noupdate -radix hexadecimal /tb/u_dut/u_z80/u_cz80/u_regs/wdata_h
add wave -noupdate -radix hexadecimal /tb/u_dut/u_z80/u_cz80/u_regs/wdata_l
add wave -noupdate -radix hexadecimal /tb/u_dut/u_z80/u_cz80/u_regs/rdata_ah
add wave -noupdate -radix hexadecimal /tb/u_dut/u_z80/u_cz80/u_regs/rdata_al
add wave -noupdate -radix hexadecimal /tb/u_dut/u_z80/u_cz80/u_regs/rdata_bh
add wave -noupdate -radix hexadecimal /tb/u_dut/u_z80/u_cz80/u_regs/rdata_bl
add wave -noupdate -radix hexadecimal /tb/u_dut/u_z80/u_cz80/u_regs/rdata_ch
add wave -noupdate -radix hexadecimal /tb/u_dut/u_z80/u_cz80/u_regs/rdata_cl
add wave -noupdate -radix hexadecimal /tb/u_dut/u_z80/u_cz80/u_regs/reg_b0
add wave -noupdate -radix hexadecimal /tb/u_dut/u_z80/u_cz80/u_regs/reg_d0
add wave -noupdate -radix hexadecimal /tb/u_dut/u_z80/u_cz80/u_regs/reg_h0
add wave -noupdate -radix hexadecimal /tb/u_dut/u_z80/u_cz80/u_regs/reg_ixh
add wave -noupdate -radix hexadecimal /tb/u_dut/u_z80/u_cz80/u_regs/reg_b1
add wave -noupdate -radix hexadecimal /tb/u_dut/u_z80/u_cz80/u_regs/reg_d1
add wave -noupdate -radix hexadecimal /tb/u_dut/u_z80/u_cz80/u_regs/reg_h1
add wave -noupdate -radix hexadecimal /tb/u_dut/u_z80/u_cz80/u_regs/reg_iyh
add wave -noupdate -radix hexadecimal /tb/u_dut/u_z80/u_cz80/u_regs/reg_c0
add wave -noupdate -radix hexadecimal /tb/u_dut/u_z80/u_cz80/u_regs/reg_e0
add wave -noupdate -radix hexadecimal /tb/u_dut/u_z80/u_cz80/u_regs/reg_l0
add wave -noupdate -radix hexadecimal /tb/u_dut/u_z80/u_cz80/u_regs/reg_ixl
add wave -noupdate -radix hexadecimal /tb/u_dut/u_z80/u_cz80/u_regs/reg_c1
add wave -noupdate -radix hexadecimal /tb/u_dut/u_z80/u_cz80/u_regs/reg_e1
add wave -noupdate -radix hexadecimal /tb/u_dut/u_z80/u_cz80/u_regs/reg_l1
add wave -noupdate -radix hexadecimal /tb/u_dut/u_z80/u_cz80/u_regs/reg_iyl
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {345493728215 ps} 0} {{Cursor 2} {2341669550400 ps} 0} {{Cursor 3} {345512308320 ps} 0} {{Cursor 4} {2218999920480 ps} 0} {{Cursor 5} {2341530268287 ps} 0}
quietly wave cursor active 2
configure wave -namecolwidth 187
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
WaveRestoreZoom {2094494272367 ps} {2094693269123 ps}
