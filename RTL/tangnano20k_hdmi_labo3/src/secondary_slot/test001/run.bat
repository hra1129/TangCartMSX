vlib work
vlog ..\secondary_slot_inst.v
vlog tb.sv
vsim -c -t 1ns -do run.do tb
move transcript log.txt
pause
