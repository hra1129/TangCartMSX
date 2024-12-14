onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /tb/u_micom_connect/reset_n
add wave -noupdate -radix hexadecimal /tb/u_micom_connect/clk
add wave -noupdate -radix hexadecimal /tb/u_micom_connect/spi_cs_n
add wave -noupdate -radix hexadecimal /tb/u_micom_connect/spi_clk
add wave -noupdate -radix hexadecimal /tb/u_micom_connect/spi_mosi
add wave -noupdate -radix hexadecimal /tb/u_micom_connect/spi_miso
add wave -noupdate -radix hexadecimal /tb/u_micom_connect/msx_reset_n
add wave -noupdate -radix hexadecimal /tb/u_micom_connect/matrix_y
add wave -noupdate -radix hexadecimal /tb/u_micom_connect/matrix_x
add wave -noupdate -radix hexadecimal /tb/u_micom_connect/address
add wave -noupdate -radix hexadecimal /tb/u_micom_connect/req
add wave -noupdate -radix hexadecimal /tb/u_micom_connect/wdata
add wave -noupdate -radix hexadecimal /tb/u_micom_connect/ff_state
add wave -noupdate -radix hexadecimal /tb/u_micom_connect/ff_serial_state
add wave -noupdate -radix hexadecimal /tb/u_micom_connect/ff_bit
add wave -noupdate -radix hexadecimal /tb/u_micom_connect/ff_recv_data
add wave -noupdate -radix hexadecimal /tb/u_micom_connect/ff_send_data
add wave -noupdate -radix hexadecimal /tb/u_micom_connect/ff_data
add wave -noupdate -radix hexadecimal /tb/u_micom_connect/ff_connect_req
add wave -noupdate -radix hexadecimal /tb/u_micom_connect/ff_command
add wave -noupdate -radix hexadecimal /tb/u_micom_connect/ff_do_command
add wave -noupdate -radix hexadecimal /tb/u_micom_connect/w_command_req
add wave -noupdate -radix hexadecimal /tb/u_micom_connect/ff_command_end
add wave -noupdate -radix hexadecimal /tb/u_micom_connect/ff_address
add wave -noupdate -radix hexadecimal /tb/u_micom_connect/w_address
add wave -noupdate -radix hexadecimal /tb/u_micom_connect/ff_msx_reset_n
add wave -noupdate -radix hexadecimal /tb/u_micom_connect/ff_y
add wave -noupdate -radix hexadecimal /tb/u_micom_connect/ff_bank
add wave -noupdate -radix hexadecimal /tb/u_micom_connect/ff_wdata
add wave -noupdate -radix hexadecimal /tb/u_micom_connect/ff_req
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 241
configure wave -valuecolwidth 62
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
WaveRestoreZoom {0 ps} {1747746 ps}
