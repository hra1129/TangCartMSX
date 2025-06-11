onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /tb/t80_mcode/IR
add wave -noupdate -radix hexadecimal /tb/t80_mcode/ISet
add wave -noupdate -radix hexadecimal /tb/t80_mcode/MCycle
add wave -noupdate -radix hexadecimal /tb/t80_mcode/F
add wave -noupdate -radix hexadecimal /tb/t80_mcode/NMICycle
add wave -noupdate -radix hexadecimal /tb/t80_mcode/IntCycle
add wave -noupdate -radix hexadecimal /tb/t80_mcode/XY_State
add wave -noupdate -radix hexadecimal /tb/t80_mcode/Read_To_Reg
add wave -noupdate -radix hexadecimal /tb/u_cz80_mcode/read_to_reg
add wave -noupdate -radix hexadecimal /tb/err
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 0
configure wave -namecolwidth 196
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
WaveRestoreZoom {0 ns} {1041640 ns}
