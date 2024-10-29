rmdir /S /Q work
vlib work
vlog ..\debugger\ip_debugger.v
vlog ..\debugger\vram_image_rom.v

vlog MT48LC2M32B2.v

vlog ..\sdram\ip_sdram.v
rem vlog ..\sdram\ip_sdram_dummy.v
rem vlog ..\sdram\ip_sdram_dummy2.v

vlog ..\v9958clone\vdp_ram256.v
vcom ..\v9958clone\vdp_package.vhd
vlog ..\v9958clone\vdp_colordec.v
vcom ..\v9958clone\vdp_command.vhd
vlog ..\v9958clone\vdp_doublebuf.v
vlog ..\v9958clone\vdp_graphic123m.v
vcom ..\v9958clone\vdp_graphic4567.vhd
vcom ..\v9958clone\vdp_hvcounter.vhd
vlog ..\v9958clone\vdp_interrupt.v
vlog ..\v9958clone\vdp_linebuf.v
vlog ..\v9958clone\vdp_register.v
vcom ..\v9958clone\vdp_spinforam.vhd
vcom ..\v9958clone\vdp_sprite.vhd
vlog ..\v9958clone\vdp_ssg.v
vcom ..\v9958clone\vdp_text12.vhd
vlog ..\v9958clone\vdp_lcd.v
vlog ..\v9958clone\vdp_wait_control.v
vcom ..\v9958clone\vdp.vhd
vlog gowin_pll_dummy.v
vlog ..\tang20cart_msx.v
vlog tb.sv
pause
vsim -c -t 1ns -do run.do tb
move transcript log.txt
pause
