rmdir /S /Q work
vlib work
vlog ..\debugger\ip_debugger.v
vlog ..\debugger\vram_image_rom.v

vlog MT48LC2M32B2.v

vlog ..\sdram\ip_sdram.v
rem vlog ..\sdram\ip_sdram_dummy.v
rem vlog ..\sdram\ip_sdram_dummy2.v

vlog ..\v9958\vdp_ram256.v
vcom ..\v9958\vdp_package.vhd
vlog ..\v9958\vdp_colordec.v
vcom ..\v9958\vdp_command.vhd
vlog ..\v9958\vdp_doublebuf.v
vlog ..\v9958\vdp_graphic123m.v
vlog ..\v9958\vdp_graphic4567.v
vlog ..\v9958\vdp_hvcounter.v
vlog ..\v9958\vdp_interrupt.v
vlog ..\v9958\vdp_linebuf.v
vlog ..\v9958\vdp_register.v
vlog ..\v9958\vdp_spinforam.v
vlog ..\v9958\vdp_sprite.v
vlog ..\v9958\vdp_ssg.v
vlog ..\v9958\vdp_text12.v
vlog ..\v9958\vdp_lcd.v
vlog ..\v9958\vdp_wait_control.v
vcom ..\v9958\vdp.vhd
vlog gowin_pll_dummy.v
vlog ..\tang20cart_msx.v
vlog tb.sv
pause
vsim -c -t 1ns -do run.do tb
move transcript log.txt
pause
