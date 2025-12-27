rmdir /S /Q work
vlib work
vlog ..\..\ram\ip_ram.v
vlog ..\ip_fifo.v
vlog tb.sv
vsim -c -t 1ns -do run.do tb
move transcript log.txt
pause
