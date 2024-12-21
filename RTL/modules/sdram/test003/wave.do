onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/reset_n
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/clk
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/clk_sdram
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/sdram_busy
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/merq_n
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/address
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/wr_n
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/rd_n
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/wdata
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/rdata
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/rdata_en
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/O_sdram_clk
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/O_sdram_cke
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/O_sdram_cs_n
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/O_sdram_ras_n
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/O_sdram_cas_n
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/O_sdram_wen_n
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/IO_sdram_dq
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/O_sdram_addr
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/O_sdram_ba
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/O_sdram_dqm
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/ff_main_state
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/ff_main_timer
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/w_end_of_main_timer
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/ff_sdr_ready
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/ff_do_main_state
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/ff_do_refresh
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/ff_sdr_command
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/ff_sdr_address
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/ff_sdr_write_data
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/ff_sdr_dq_mask
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/ff_sdr_read_data
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/ff_sdr_read_data_en
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/ff_req
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/ff_is_write
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/ff_wdata
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/ff_address
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/w_refresh
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/ff_refresh_timer
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 0
configure wave -namecolwidth 275
configure wave -valuecolwidth 65
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
WaveRestoreZoom {0 ns} {22866 ns}
