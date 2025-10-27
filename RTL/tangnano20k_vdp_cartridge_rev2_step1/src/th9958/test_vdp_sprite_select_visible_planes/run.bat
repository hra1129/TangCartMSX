rmdir /S /Q work
vlib work
vlog ..\vdp_sprite_select_visible_planes.v
vlog tb.sv
vsim -c -t 1ns -do run.do tb
move transcript log.txt
pause
