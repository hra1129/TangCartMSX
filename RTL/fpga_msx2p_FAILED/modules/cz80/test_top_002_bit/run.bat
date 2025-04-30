rmdir /f work
vlib work
vlog ..\cz80_reg.v
vlog ..\cz80_mcode.v
vlog ..\cz80_alu.v
vlog ..\cz80.v
vlog ..\cz80_inst.v
vlog tb.sv
vsim -c -t 1ns -do run.do tb
move transcript log.txt
pause
