vlib work
vlog ..\megarom.v
vlog tb.sv
vsim -c -t 1ns -do run.do tb
move transcript log.txt
pause
