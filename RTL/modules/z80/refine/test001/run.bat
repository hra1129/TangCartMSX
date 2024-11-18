vlib work
vcom ..\t80_pack.vhd
vcom ..\t80_reg.vhd
vcom ..\t80_mcode.vhd
vcom ..\t80_alu.vhd
vcom ..\t80.vhd
vcom ..\t80_inst.vhd
vlog tb.sv
vsim -c -t 1ns -do run.do tb
move transcript log.txt
pause
