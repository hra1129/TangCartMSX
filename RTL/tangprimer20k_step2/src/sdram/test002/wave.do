onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/reset_n
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/clk
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/clk_n
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/sdram_init_busy
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/sdram_busy
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/mreq_n
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/address
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/wr_n
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/rd_n
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/rfsh_n
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/wdata
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/rdata
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/rdata_en
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/ddr3_rst_n
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/ddr3_clk
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/ddr3_clk_n
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/ddr3_cke
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/ddr3_cs_n
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/ddr3_ras_n
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/ddr3_cas_n
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/ddr3_we_n
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/ddr3_dq
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/ddr3_addr
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/ddr3_ba
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/ddr3_dm_tdqs
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/ddr3_dqs
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/ddr3_dqs_n
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/ddr3_tdqs_n
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/ddr3_odt
add wave -noupdate -radix unsigned /tb/u_sdram_controller/ff_main_state
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/ff_main_timer
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/ff_no_refresh
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/w_end_of_main_timer
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/ff_ddr_rst_n
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/ff_ddr_cke
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/ff_ddr_odt
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/ff_ddr_ready
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/ff_accessing
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/ff_do_refresh
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/ff_ddr_command
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/ff_ddr_ba
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/ff_ddr_address
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/ff_ddr_write_data
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/ff_ddr_dq_mask
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/ff_ddr_read_data
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/ff_ddr_read_data_en
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/ff_req
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/ff_rd_n
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/ff_wr_n
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/ff_rd_wr_accept
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/ff_rfsh_accept
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/ff_is_write
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/ff_wdata
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/ff_address
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/w_busy
add wave -noupdate -radix hexadecimal /tb/u_sdram_controller/w_has_request_latch
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {721824021 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 283
configure wave -valuecolwidth 56
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
WaveRestoreZoom {721792167 ps} {721847221 ps}
