onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/u_dut/u_v9918/u_v9918_core/initial_busy
add wave -noupdate /tb/u_dut/u_v9918/u_v9918_core/clk
add wave -noupdate /tb/u_dut/u_v9918/u_v9918_core/enable
add wave -noupdate /tb/u_dut/u_v9918/u_v9918_core/iorq_n
add wave -noupdate /tb/u_dut/u_v9918/u_v9918_core/wr_n
add wave -noupdate /tb/u_dut/u_v9918/u_v9918_core/rd_n
add wave -noupdate /tb/u_dut/u_v9918/u_v9918_core/u_vdp_register/ff_wr_req
add wave -noupdate /tb/u_dut/u_v9918/u_v9918_core/u_vdp_register/ff_rd_req
add wave -noupdate /tb/u_dut/u_v9918/u_v9918_core/u_vdp_register/vdp_p1_is_1st_byte
add wave -noupdate -radix hexadecimal /tb/u_dut/u_v9918/u_v9918_core/u_vdp_register/reg_r7_frame_col
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {345493728215 ps} 0} {{Cursor 2} {2341669550400 ps} 0} {{Cursor 3} {861950732357 ps} 0} {{Cursor 4} {1000009949838 ps} 0} {{Cursor 5} {2341530268287 ps} 0}
quietly wave cursor active 3
configure wave -namecolwidth 270
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
WaveRestoreZoom {595599544861 ps} {595602794845 ps}
