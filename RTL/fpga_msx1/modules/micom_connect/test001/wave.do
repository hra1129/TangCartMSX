onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /tb/u_micom_connect/reset_n
add wave -noupdate -radix hexadecimal /tb/u_micom_connect/clk
add wave -noupdate -radix hexadecimal /tb/u_micom_connect/spi_cs_n
add wave -noupdate -radix hexadecimal /tb/u_micom_connect/spi_clk
add wave -noupdate -radix hexadecimal /tb/u_micom_connect/spi_mosi
add wave -noupdate -radix hexadecimal /tb/u_micom_connect/spi_miso
add wave -noupdate -radix hexadecimal /tb/u_micom_connect/msx_reset_n
add wave -noupdate -radix hexadecimal /tb/u_micom_connect/cpu_freeze
add wave -noupdate -radix hexadecimal /tb/u_micom_connect/matrix_y
add wave -noupdate -radix hexadecimal /tb/u_micom_connect/matrix_x
add wave -noupdate -radix hexadecimal /tb/u_micom_connect/address
add wave -noupdate -radix hexadecimal /tb/u_micom_connect/req_n
add wave -noupdate -radix hexadecimal /tb/u_micom_connect/wdata
add wave -noupdate -radix hexadecimal /tb/u_micom_connect/sdram_busy
add wave -noupdate -radix hexadecimal /tb/u_micom_connect/ff_spi_cs_n
add wave -noupdate -radix hexadecimal /tb/u_micom_connect/ff_spi_clk
add wave -noupdate -radix hexadecimal /tb/u_micom_connect/ff_spi_mosi
add wave -noupdate -radix hexadecimal /tb/u_micom_connect/ff_state
add wave -noupdate -radix hexadecimal /tb/u_micom_connect/ff_serial_state
add wave -noupdate -radix hexadecimal /tb/u_micom_connect/ff_bit
add wave -noupdate -radix hexadecimal /tb/u_micom_connect/ff_recv_data
add wave -noupdate -radix hexadecimal /tb/u_micom_connect/ff_send_data
add wave -noupdate -radix hexadecimal /tb/u_micom_connect/ff_command
add wave -noupdate -radix hexadecimal /tb/u_micom_connect/ff_address
add wave -noupdate -radix hexadecimal /tb/u_micom_connect/ff_msx_reset_n
add wave -noupdate -radix hexadecimal /tb/u_micom_connect/ff_cpu_freeze
add wave -noupdate -radix hexadecimal /tb/u_micom_connect/ff_operand1
add wave -noupdate -radix hexadecimal /tb/u_micom_connect/ff_matrix_x
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 240
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
WaveRestoreZoom {4819682708 ps} {4822393367 ps}
