rmdir /S /Q work
vlib work
vlog ..\vdp_video_ram_line_buffer.v
vlog ..\vdp_video_double_buffer.v
vlog ..\vdp_video_out_bilinear.v
vlog ..\vdp_video_out.v
vlog tb.sv
vsim -c -t 1ns -do run.do tb
move transcript log.txt
pause
