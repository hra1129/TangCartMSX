vlib work
vlog ..\model\iddr.v
vlog ..\model\oddr.v
vlog ..\ip_psram.v
vlog tb.sv
vsim -c -t 1ps -do run.do tb
move transcript log.txt
pause
