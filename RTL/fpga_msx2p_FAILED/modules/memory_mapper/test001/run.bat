vlib work
vlog ..\memory_mapper.v
vlog ..\memory_mapper_inst.v
vlog tb.sv
vsim -c -t 1ns -do run.do tb
move transcript log.txt
pause
