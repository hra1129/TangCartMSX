onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /tb/u_dut/u_z80/reset_n
add wave -noupdate -radix hexadecimal /tb/u_dut/u_z80/clk_n
add wave -noupdate -radix hexadecimal /tb/u_dut/u_z80/enable
add wave -noupdate -radix hexadecimal /tb/u_dut/u_z80/wait_n
add wave -noupdate -radix hexadecimal /tb/u_dut/u_z80/int_n
add wave -noupdate -radix hexadecimal /tb/u_dut/u_z80/nmi_n
add wave -noupdate -radix hexadecimal /tb/u_dut/u_z80/busrq_n
add wave -noupdate -radix hexadecimal /tb/u_dut/u_z80/m1_n
add wave -noupdate -radix hexadecimal /tb/u_dut/u_z80/mreq_n
add wave -noupdate -radix hexadecimal /tb/u_dut/u_z80/iorq_n
add wave -noupdate -radix hexadecimal /tb/u_dut/u_z80/rd_n
add wave -noupdate -radix hexadecimal /tb/u_dut/u_z80/wr_n
add wave -noupdate -radix hexadecimal /tb/u_dut/u_z80/rfsh_n
add wave -noupdate -radix hexadecimal /tb/u_dut/u_z80/halt_n
add wave -noupdate -radix hexadecimal /tb/u_dut/u_z80/busak_n
add wave -noupdate -radix hexadecimal /tb/u_dut/u_z80/a
add wave -noupdate -radix hexadecimal /tb/u_dut/u_z80/d
add wave -noupdate -radix hexadecimal /tb/u_dut/u_z80/ff_reset_n
add wave -noupdate -radix hexadecimal /tb/u_dut/u_z80/w_intcycle_n
add wave -noupdate -radix hexadecimal /tb/u_dut/u_z80/w_iorq
add wave -noupdate -radix hexadecimal /tb/u_dut/u_z80/w_noread
add wave -noupdate -radix hexadecimal /tb/u_dut/u_z80/w_write
add wave -noupdate -radix hexadecimal /tb/u_dut/u_z80/ff_mreq
add wave -noupdate -radix hexadecimal /tb/u_dut/u_z80/ff_mreq_inhibit
add wave -noupdate -radix hexadecimal /tb/u_dut/u_z80/ff_ireq_inhibit
add wave -noupdate -radix hexadecimal /tb/u_dut/u_z80/ff_req_inhibit
add wave -noupdate -radix hexadecimal /tb/u_dut/u_z80/ff_rd
add wave -noupdate -radix hexadecimal /tb/u_dut/u_z80/w_mreq_n_i
add wave -noupdate -radix hexadecimal /tb/u_dut/u_z80/ff_iorq_n_i
add wave -noupdate -radix hexadecimal /tb/u_dut/u_z80/w_rd_n_i
add wave -noupdate -radix hexadecimal /tb/u_dut/u_z80/ff_wr_n_i
add wave -noupdate -radix hexadecimal /tb/u_dut/u_z80/w_wr_n_j
add wave -noupdate -radix hexadecimal /tb/u_dut/u_z80/w_rfsh_n_i
add wave -noupdate -radix hexadecimal /tb/u_dut/u_z80/w_busak_n_i
add wave -noupdate -radix hexadecimal /tb/u_dut/u_z80/w_a_i
add wave -noupdate -radix hexadecimal /tb/u_dut/u_z80/w_di
add wave -noupdate -radix hexadecimal /tb/u_dut/u_z80/w_do
add wave -noupdate -radix hexadecimal /tb/u_dut/u_z80/ff_di_reg
add wave -noupdate -radix hexadecimal /tb/u_dut/u_z80/ff_dinst
add wave -noupdate -radix hexadecimal /tb/u_dut/u_z80/ff_wait_n
add wave -noupdate -radix hexadecimal /tb/u_dut/u_z80/w_m_cycle
add wave -noupdate -radix hexadecimal /tb/u_dut/u_z80/w_t_state
add wave -noupdate -radix hexadecimal /tb/u_dut/u_z80/w_m1_n
add wave -noupdate /tb/u_dut/button
add wave -noupdate -radix hexadecimal /tb/u_dut/u_gpio/gpo
add wave -noupdate -radix hexadecimal /tb/u_dut/u_gpio/reset_n
add wave -noupdate -radix hexadecimal /tb/u_dut/u_gpio/clk
add wave -noupdate -radix hexadecimal /tb/u_dut/u_gpio/iorq_n
add wave -noupdate -radix hexadecimal /tb/u_dut/u_gpio/address
add wave -noupdate -radix hexadecimal /tb/u_dut/u_gpio/rd_n
add wave -noupdate -radix hexadecimal /tb/u_dut/u_gpio/wr_n
add wave -noupdate -radix hexadecimal /tb/u_dut/u_gpio/d
add wave -noupdate -radix hexadecimal /tb/u_dut/u_gpio/q
add wave -noupdate -radix hexadecimal /tb/u_dut/u_gpio/q_en
add wave -noupdate -radix hexadecimal /tb/u_dut/u_gpio/gpo
add wave -noupdate -radix hexadecimal /tb/u_dut/u_gpio/gpi
add wave -noupdate -radix hexadecimal /tb/u_dut/u_gpio/w_gpio_dec
add wave -noupdate -radix hexadecimal /tb/u_dut/u_gpio/ff_gpo
add wave -noupdate -radix hexadecimal /tb/u_dut/u_gpio/ff_iorq_n
add wave -noupdate -radix hexadecimal /tb/u_dut/u_gpio/ff_wr_n
add wave -noupdate -radix hexadecimal /tb/u_dut/u_gpio/ff_rd_n
add wave -noupdate -radix hexadecimal /tb/u_dut/u_gpio/w_wr
add wave -noupdate -radix hexadecimal /tb/u_dut/u_gpio/w_rd
add wave -noupdate -radix hexadecimal /tb/u_dut/u_gpio/ff_q_en
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {301344371 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 174
configure wave -valuecolwidth 51
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
WaveRestoreZoom {300458758 ps} {301496911 ps}