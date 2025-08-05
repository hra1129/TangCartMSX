rmdir /S /Q work
vlib work
vlog ..\vdp_sprite_info_collect.v
vlog ..\vdp_sprite_makeup_pixel.v
vlog ..\vdp_sprite_select_visible_planes.v
vlog ..\vdp_timing_control_ssg.v
vlog ..\vdp_timing_control_screen_mode.v
vlog ..\vdp_timing_control_sprite.v
vlog ..\vdp_timing_control.v
vlog tb.sv
vsim -c -t 1ns -do run.do tb
move transcript log.txt
pause
