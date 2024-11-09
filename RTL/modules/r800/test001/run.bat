vlib work
vcom ..\t800_pack.vhd
vcom ..\t800_reg.vhd
vcom ..\t800_mcode.vhd
vcom ..\t800_alu.vhd
vcom ..\t800.vhd
vcom ..\t800_inst.vhd
vlog tb.sv
vsim -c -t 1ns -do run.do tb
move transcript log.txt
pause
