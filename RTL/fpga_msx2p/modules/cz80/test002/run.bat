vlib work
vlog tb.sv
pause
vsim -c -t 1ns -do run.do tb
move transcript log.txt
pause
