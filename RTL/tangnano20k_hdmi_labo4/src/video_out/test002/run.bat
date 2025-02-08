rmdir /f work
vlib work
vlog ..\video_out_bilinear.v
vlog tb.sv
vsim -c -t 1ns -do run.do tb
move transcript log.txt
pause
