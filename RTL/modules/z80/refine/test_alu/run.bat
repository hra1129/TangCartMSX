vlib work
vcom t80_alu.vhd
vlog ..\cz80_alu.v
vlog tb.sv
pause
vsim -c -t 1ns -do run.do tb
move transcript log.txt
pause
