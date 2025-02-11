rmdir /S /Q work
vlib work
vlog ..\video_ram_line_buffer.v
vlog ..\video_double_buffer.v
vlog ..\video_out_bilinear.v
vlog ..\video_out_sigmoid.v
vlog ..\video_out_hmag.v
vlog tb.sv
vsim -c -t 1ns -do run.do tb
move transcript log.txt
pause
