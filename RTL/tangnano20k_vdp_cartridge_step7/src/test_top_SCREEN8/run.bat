rmdir /S /Q work
vlib work
vlog MT48LC2M32B2.v
vlog dummy.v
vlog ..\msx_slot\msx_slot.v
vlog ..\sdram\ip_sdram_tangnano20k_c.v
vlog ..\th9958\vdp_upscan_line_buffer.v
vlog ..\th9958\vdp_upscan.v
vlog ..\th9958\vdp_video_ram_line_buffer.v
vlog ..\th9958\vdp_video_double_buffer.v
vlog ..\th9958\vdp_video_out_bilinear.v
vlog ..\th9958\vdp_video_out.v
vlog ..\th9958\vdp_sprite_info_collect.v
vlog ..\th9958\vdp_sprite_makeup_pixel.v
vlog ..\th9958\vdp_sprite_select_visible_planes.v
vlog ..\th9958\vdp_timing_control_ssg.v
vlog ..\th9958\vdp_timing_control_screen_mode.v
vlog ..\th9958\vdp_timing_control_sprite.v
vlog ..\th9958\vdp_timing_control.v
vlog ..\th9958\vdp_vram_interface.v
vlog ..\th9958\vdp_cpu_interface.v
vlog ..\th9958\vdp_color_palette_ram.v
vlog ..\th9958\vdp_color_palette.v
vlog ..\th9958\vdp_vram_interface.v
vlog ..\th9958\vdp_command.v
vlog ..\th9958\vdp.v
vlog ..\tangnano20k_vdp_cartridge.v
vlog tb.sv
vsim -c -t 1ns -do run.do tb
move transcript log.txt
pause
