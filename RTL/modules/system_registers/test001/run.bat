vlib work
vlog ..\system_registers.v
vlog ..\system_registers_inst.v
vlog tb.sv
vsim -c -t 1ns -do run.do tb
move transcript log.txt
pause
