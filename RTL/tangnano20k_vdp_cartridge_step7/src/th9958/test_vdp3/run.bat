rmdir /S /Q work
vlib work
vlog MT48LC2M32B2.v
vlog ..\..\sdram\ip_sdram_tangnano20k_c.v
vlog ..\vdp_upscan_line_buffer.v
vlog ..\vdp_upscan.v
vlog ..\vdp_video_ram_line_buffer.v
vlog ..\vdp_video_double_buffer.v
vlog ..\vdp_video_out_bilinear.v
vlog ..\vdp_video_out.v
vlog ..\vdp_sprite_info_collect.v
vlog ..\vdp_sprite_makeup_pixel.v
vlog ..\vdp_sprite_select_visible_planes.v
vlog ..\vdp_timing_control_ssg.v
vlog ..\vdp_timing_control_screen_mode.v
vlog ..\vdp_timing_control_sprite.v
vlog ..\vdp_timing_control.v
vlog ..\vdp_vram_interface.v
vlog ..\vdp_cpu_interface.v
vlog ..\vdp_color_palette_ram.v
vlog ..\vdp_color_palette.v
vlog ..\vdp_vram_interface.v
vlog ..\vdp_command.v
vlog ..\vdp.v
vlog tb.sv
vsim -c -t 1ns -do run.do tb
move transcript log.txt
pause
