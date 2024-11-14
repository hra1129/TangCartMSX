vlib work
vlog ..\ssg.v
vlog ..\ssg_inst.v
vlog tb.sv
vsim -c -t 1ns -do run.do tb
move transcript log.txt
pause
