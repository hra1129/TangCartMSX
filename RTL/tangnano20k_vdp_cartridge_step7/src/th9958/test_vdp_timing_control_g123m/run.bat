rmdir /S /Q work
vlib work
vlog ..\vdp_timing_control_g123m.v
vlog tb.sv
vsim -c -t 1ns -do run.do tb
move transcript log.txt
pause
