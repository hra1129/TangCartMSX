rmdir /S /Q work
vlib work
vlog ..\msx_slot.v
vlog tb.sv
vsim -c -t 1ns -do run.do tb
move transcript log.txt
pause
