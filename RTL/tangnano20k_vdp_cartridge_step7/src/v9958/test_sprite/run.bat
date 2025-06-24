rmdir /S /Q work
vlib work
vlog ..\vdp_spinforam.v
vlog ..\vdp_ram_256byte.v
vlog ..\vdp_sprite.v
vlog tb.sv
vsim -c -t 1ns -do run.do tb
move transcript log.txt
pause
