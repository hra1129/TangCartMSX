vlib work
vlog psram_memory_interface_2ch_stub.sv
vlog ..\ip_psram.v
vlog tb.sv
vsim -c -t 1ps -do run.do tb
move transcript log.txt
pause
