vlib work
vlog ..\ip_line_buffer.v
vlog ..\ip_pallete.v
vlog ..\ip_video.v
vlog tb.sv
vsim -c -t 1ps -do run.do tb
move transcript log.txt
pause
