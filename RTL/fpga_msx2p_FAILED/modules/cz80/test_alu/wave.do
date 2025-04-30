onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/err
add wave -noupdate -radix hexadecimal /tb/u_cz80_alu/arith16
add wave -noupdate -radix hexadecimal /tb/u_cz80_alu/z16
add wave -noupdate -radix hexadecimal /tb/u_cz80_alu/alu_cpi
add wave -noupdate -radix hexadecimal /tb/u_cz80_alu/alu_op
add wave -noupdate -radix hexadecimal /tb/u_cz80_alu/ir
add wave -noupdate -radix hexadecimal /tb/u_cz80_alu/iset
add wave -noupdate -radix hexadecimal /tb/u_cz80_alu/busa
add wave -noupdate -radix hexadecimal /tb/u_cz80_alu/busb
add wave -noupdate -radix hexadecimal /tb/u_cz80_alu/f_in
add wave -noupdate -color Cyan -radix hexadecimal /tb/u_cz80_alu/q
add wave -noupdate -color Violet -radix hexadecimal /tb/u_t80_alu/Q
add wave -noupdate -color Cyan -radix hexadecimal -childformat {{{/tb/u_cz80_alu/f_out[7]} -radix hexadecimal} {{/tb/u_cz80_alu/f_out[6]} -radix hexadecimal} {{/tb/u_cz80_alu/f_out[5]} -radix hexadecimal} {{/tb/u_cz80_alu/f_out[4]} -radix hexadecimal} {{/tb/u_cz80_alu/f_out[3]} -radix hexadecimal} {{/tb/u_cz80_alu/f_out[2]} -radix hexadecimal} {{/tb/u_cz80_alu/f_out[1]} -radix hexadecimal} {{/tb/u_cz80_alu/f_out[0]} -radix hexadecimal}} -expand -subitemconfig {{/tb/u_cz80_alu/f_out[7]} {-color Cyan -height 15 -radix hexadecimal} {/tb/u_cz80_alu/f_out[6]} {-color Cyan -height 15 -radix hexadecimal} {/tb/u_cz80_alu/f_out[5]} {-color Cyan -height 15 -radix hexadecimal} {/tb/u_cz80_alu/f_out[4]} {-color Cyan -height 15 -radix hexadecimal} {/tb/u_cz80_alu/f_out[3]} {-color Cyan -height 15 -radix hexadecimal} {/tb/u_cz80_alu/f_out[2]} {-color Cyan -height 15 -radix hexadecimal} {/tb/u_cz80_alu/f_out[1]} {-color Cyan -height 15 -radix hexadecimal} {/tb/u_cz80_alu/f_out[0]} {-color Cyan -height 15 -radix hexadecimal}} /tb/u_cz80_alu/f_out
add wave -noupdate -color Violet -radix hexadecimal -childformat {{/tb/u_t80_alu/F_Out(7) -radix hexadecimal} {/tb/u_t80_alu/F_Out(6) -radix hexadecimal} {/tb/u_t80_alu/F_Out(5) -radix hexadecimal} {/tb/u_t80_alu/F_Out(4) -radix hexadecimal} {/tb/u_t80_alu/F_Out(3) -radix hexadecimal} {/tb/u_t80_alu/F_Out(2) -radix hexadecimal} {/tb/u_t80_alu/F_Out(1) -radix hexadecimal} {/tb/u_t80_alu/F_Out(0) -radix hexadecimal}} -expand -subitemconfig {/tb/u_t80_alu/F_Out(7) {-color Violet -height 15 -radix hexadecimal} /tb/u_t80_alu/F_Out(6) {-color Violet -height 15 -radix hexadecimal} /tb/u_t80_alu/F_Out(5) {-color Violet -height 15 -radix hexadecimal} /tb/u_t80_alu/F_Out(4) {-color Violet -height 15 -radix hexadecimal} /tb/u_t80_alu/F_Out(3) {-color Violet -height 15 -radix hexadecimal} /tb/u_t80_alu/F_Out(2) {-color Violet -height 15 -radix hexadecimal} /tb/u_t80_alu/F_Out(1) {-color Violet -height 15 -radix hexadecimal} /tb/u_t80_alu/F_Out(0) {-color Violet -height 15 -radix hexadecimal}} /tb/u_t80_alu/F_Out
add wave -noupdate -radix hexadecimal /tb/u_cz80_alu/w_daa_ql
add wave -noupdate -radix hexadecimal /tb/u_cz80_alu/w_daa_sub
add wave -noupdate -radix hexadecimal /tb/u_cz80_alu/w_daa_q
add wave -noupdate -radix hexadecimal /tb/u_t80_alu/ff_daa_q
add wave -noupdate -radix hexadecimal /tb/u_cz80_alu/w_busb_l
add wave -noupdate -radix hexadecimal /tb/u_cz80_alu/w_busb_m
add wave -noupdate -radix hexadecimal /tb/u_cz80_alu/w_busb_h
add wave -noupdate -radix hexadecimal /tb/u_cz80_alu/w_carry_l
add wave -noupdate -radix hexadecimal /tb/u_cz80_alu/w_carry_m
add wave -noupdate -radix hexadecimal /tb/u_cz80_alu/w_carry_h
add wave -noupdate -radix hexadecimal /tb/u_cz80_alu/w_addsub_l
add wave -noupdate -radix hexadecimal /tb/u_cz80_alu/w_addsub_m
add wave -noupdate -radix hexadecimal /tb/u_cz80_alu/w_addsub_h
add wave -noupdate -radix hexadecimal /tb/u_cz80_alu/w_addsub_s
add wave -noupdate -radix hexadecimal /tb/u_cz80_alu/w_q_t
add wave -noupdate -radix hexadecimal /tb/u_cz80_alu/w_usecarry
add wave -noupdate -radix hexadecimal /tb/u_cz80_alu/w_carry7
add wave -noupdate -radix hexadecimal /tb/u_cz80_alu/w_overflow
add wave -noupdate -radix hexadecimal /tb/u_cz80_alu/w_halfcarry
add wave -noupdate -radix hexadecimal /tb/u_cz80_alu/w_carry
add wave -noupdate -radix hexadecimal /tb/u_cz80_alu/w_q
add wave -noupdate -radix hexadecimal /tb/u_cz80_alu/w_q_cpi
add wave -noupdate -radix hexadecimal /tb/u_cz80_alu/w_bitmask
add wave -noupdate -radix hexadecimal /tb/u_t80_alu/Arith16
add wave -noupdate -radix hexadecimal /tb/u_t80_alu/Z16
add wave -noupdate -radix hexadecimal /tb/u_t80_alu/ALU_cpi
add wave -noupdate -radix hexadecimal /tb/u_t80_alu/ALU_Op
add wave -noupdate -radix hexadecimal /tb/u_t80_alu/IR
add wave -noupdate -radix hexadecimal /tb/u_t80_alu/ISet
add wave -noupdate -radix hexadecimal /tb/u_t80_alu/BusA
add wave -noupdate -radix hexadecimal /tb/u_t80_alu/BusB
add wave -noupdate -radix hexadecimal /tb/u_t80_alu/F_In
add wave -noupdate -radix hexadecimal /tb/u_t80_alu/UseCarry
add wave -noupdate -radix hexadecimal /tb/u_t80_alu/Carry7_v
add wave -noupdate -radix hexadecimal /tb/u_t80_alu/Overflow_v
add wave -noupdate -radix hexadecimal /tb/u_t80_alu/HalfCarry_v
add wave -noupdate -radix hexadecimal /tb/u_t80_alu/Carry_v
add wave -noupdate -radix hexadecimal /tb/u_t80_alu/Q_v
add wave -noupdate -radix hexadecimal /tb/u_t80_alu/Q_cpi
add wave -noupdate -radix hexadecimal /tb/u_t80_alu/BitMask
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {28846066 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 196
configure wave -valuecolwidth 42
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
WaveRestoreZoom {28415601 ns} {29289364 ns}
