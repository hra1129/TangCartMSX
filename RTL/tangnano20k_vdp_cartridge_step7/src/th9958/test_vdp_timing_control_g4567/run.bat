rmdir /S /Q work
vlib work
vlog ..\vdp_timing_control_g4567.v
vlog tb.sv
vsim -c -t 1ns -do run.do tb
move transcript log.txt
pause
