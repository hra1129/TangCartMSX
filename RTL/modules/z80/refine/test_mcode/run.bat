vlib work
vcom t80_mcode.vhd
vlog ..\cz80_mcode.v
vlog tb.sv
pause
vsim -c -t 1ns -do run.do tb
move transcript log.txt
pause