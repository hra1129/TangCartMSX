vlib work
vlog ..\kanji_rom.v
vlog ..\kanji_rom_inst.v
vlog tb.sv
vsim -c -t 1ns -do run.do tb
move transcript log.txt
pause
