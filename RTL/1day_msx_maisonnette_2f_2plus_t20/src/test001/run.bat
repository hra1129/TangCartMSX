rmdir /S /Q work
vlib work
vlog ..\debugger\ip_debugger.v
vlog MT48LC2M32B2.v
vlog ..\sdram\ip_sdram.v
vcom ..\v9958clone\ram.vhd
vcom ..\v9958clone\vdp_package.vhd
vcom ..\v9958clone\vdp_colordec.vhd
vcom ..\v9958clone\vdp_command.vhd
vcom ..\v9958clone\vdp_doublebuf.vhd
vcom ..\v9958clone\vdp_graphic123m.vhd
vcom ..\v9958clone\vdp_graphic4567.vhd
vcom ..\v9958clone\vdp_hvcounter.vhd
vcom ..\v9958clone\vdp_interrupt.vhd
vcom ..\v9958clone\vdp_linebuf.vhd
vcom ..\v9958clone\vdp_ntsc_pal.vhd
vcom ..\v9958clone\vdp_register.vhd
vcom ..\v9958clone\vdp_spinforam.vhd
vcom ..\v9958clone\vdp_sprite.vhd
vcom ..\v9958clone\vdp_ssg.vhd
vcom ..\v9958clone\vdp_text12.vhd
vcom ..\v9958clone\vdp_vga.vhd
vcom ..\v9958clone\vdp_wait_control.vhd
vcom ..\v9958clone\vdp.vhd
vlog gowin_pll_dummy.v
vlog tang20cart_msx.v
vlog tb.sv
vsim -c -t 1ps -do run.do tb
move transcript log.txt
pause
