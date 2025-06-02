rmdir /S /Q work
vlib work
vlog ..\vdp.v
vlog ..\vdp_color_bus.v
vlog ..\vdp_color_decoder.v
vlog ..\vdp_graphic123m.v
vlog ..\vdp_inst.v
vlog ..\vdp_interrupt.v
vlog ..\vdp_ram_256byte.v
vlog ..\vdp_register.v
vlog ..\vdp_spinforam.v
vlog ..\vdp_sprite.v
vlog ..\vdp_ssg.v
vlog ..\vdp_text12.v
vlog ..\vdp_wait_control.v
vlog ..\..\ram\ip_ram.v
vlog tb.sv
vsim -c -t 1ns -do run.do tb
move transcript log.txt
pause
