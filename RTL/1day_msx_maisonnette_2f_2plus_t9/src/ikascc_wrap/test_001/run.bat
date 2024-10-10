vlib work
vlog ..\ip_ikascc_wrap.v
vlog ..\..\ikascc\IKASCC.v
vlog ..\..\ikascc\IKASCC_modules\IKASCC_player_a.v
vlog ..\..\ikascc\IKASCC_modules\IKASCC_player_s.v
vlog ..\..\ikascc\IKASCC_modules\IKASCC_primitives.v
vlog ..\..\ikascc\IKASCC_modules\IKASCC_vrc_a.v
vlog ..\..\ikascc\IKASCC_modules\IKASCC_vrc_s.v
vlog tb.sv
vsim -c -t 1ps -do run.do tb
move transcript log.txt
pause
