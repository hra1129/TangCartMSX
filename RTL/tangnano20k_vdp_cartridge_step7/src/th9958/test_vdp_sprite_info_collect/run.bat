rmdir /S /Q work
vlib work
vlog ..\vdp_sprite_info_collect.v
vlog tb.sv
vsim -c -t 1ns -do run.do tb
move transcript log.txt
pause
