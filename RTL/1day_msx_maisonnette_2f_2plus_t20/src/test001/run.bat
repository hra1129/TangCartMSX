rmdir /S /Q work
vlib work
vlog ..\debugger\ip_debugger.v
vlog ..\debugger\vram_image_rom.v

vlog MT48LC2M32B2.v

vlog ..\..\..\modules\sdram\ip_sdram.v
rem vlog ..\..\..\modules\sdram\ip_sdram_dummy.v
rem vlog ..\..\..\modules\sdram\ip_sdram_dummy2.v

vlog ..\..\..\modules\v9958\vdp_ram256.v
vlog ..\..\..\modules\v9958\vdp_colordec.v
vlog ..\..\..\modules\v9958\vdp_command.v
vlog ..\..\..\modules\v9958\vdp_doublebuf.v
vlog ..\..\..\modules\v9958\vdp_graphic123m.v
vlog ..\..\..\modules\v9958\vdp_graphic4567.v
vlog ..\..\..\modules\v9958\vdp_interrupt.v
vlog ..\..\..\modules\v9958\vdp_linebuf.v
vlog ..\..\..\modules\v9958\vdp_register.v
vlog ..\..\..\modules\v9958\vdp_spinforam.v
vlog ..\..\..\modules\v9958\vdp_sprite.v
vlog ..\..\..\modules\v9958\vdp_ssg.v
vlog ..\..\..\modules\v9958\vdp_text12.v
vlog ..\..\..\modules\v9958\vdp_lcd.v
vlog ..\..\..\modules\v9958\vdp_wait_control.v
vlog ..\..\..\modules\v9958\vdp.v
vlog ..\..\..\modules\v9958\vdp_inst.v
vlog gowin_pll_dummy.v
vlog ..\tang20cart_msx.v
vlog tb.sv
pause
vsim -c -t 1ns -do run.do tb
move transcript log.txt
pause
