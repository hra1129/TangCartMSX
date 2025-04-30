rmdir /S /Q work
vlib work
vlog ..\vdp_ssg.v
vlog tb.sv
pause
vsim -c -t 1ns -do run.do tb
move transcript log.txt
pause
