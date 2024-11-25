onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /tb/u_msxbus/n_reset
add wave -noupdate -radix hexadecimal /tb/u_msxbus/clk
add wave -noupdate -radix hexadecimal /tb/u_msxbus/adr
add wave -noupdate -radix hexadecimal /tb/u_msxbus/i_data
add wave -noupdate -radix hexadecimal /tb/u_msxbus/o_data
add wave -noupdate -radix hexadecimal /tb/u_msxbus/is_output
add wave -noupdate -radix hexadecimal /tb/u_msxbus/n_sltsl
add wave -noupdate -radix hexadecimal /tb/u_msxbus/n_rd
add wave -noupdate -radix hexadecimal /tb/u_msxbus/n_wr
add wave -noupdate -radix hexadecimal /tb/u_msxbus/n_ioreq
add wave -noupdate -radix hexadecimal /tb/u_msxbus/bus_address
add wave -noupdate -radix hexadecimal /tb/u_msxbus/bus_read_data
add wave -noupdate -radix hexadecimal /tb/u_msxbus/bus_read_data_en
add wave -noupdate -radix hexadecimal /tb/u_msxbus/bus_write_data
add wave -noupdate -radix hexadecimal /tb/u_msxbus/bus_io_req
add wave -noupdate -radix hexadecimal /tb/u_msxbus/bus_memory_req
add wave -noupdate -radix hexadecimal /tb/u_msxbus/bus_ack
add wave -noupdate -radix hexadecimal /tb/u_msxbus/bus_write
add wave -noupdate -radix hexadecimal /tb/u_msxbus/ff_n_sltsl
add wave -noupdate -radix hexadecimal /tb/u_msxbus/ff_n_rd
add wave -noupdate -radix hexadecimal /tb/u_msxbus/ff_n_wr
add wave -noupdate -radix hexadecimal /tb/u_msxbus/ff_n_ioreq
add wave -noupdate -radix hexadecimal /tb/u_msxbus/w_wr_req
add wave -noupdate -radix hexadecimal /tb/u_msxbus/w_rd_req
add wave -noupdate -radix hexadecimal /tb/u_msxbus/w_n_io_req
add wave -noupdate -radix hexadecimal /tb/u_msxbus/w_n_memory_req
add wave -noupdate -radix hexadecimal /tb/u_msxbus/ff_io_req
add wave -noupdate -radix hexadecimal /tb/u_msxbus/ff_memory_req
add wave -noupdate -radix hexadecimal /tb/u_msxbus/ff_access_hold
add wave -noupdate -radix hexadecimal /tb/u_msxbus/ff_bus_address
add wave -noupdate -radix hexadecimal /tb/u_msxbus/ff_bus_write_data
add wave -noupdate -radix hexadecimal /tb/u_msxbus/ff_bus_read_data
add wave -noupdate -radix hexadecimal /tb/u_msxbus/ff_bus_read_data_en
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 214
configure wave -valuecolwidth 50
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
WaveRestoreZoom {0 ps} {42619005 ps}
