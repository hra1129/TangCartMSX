vlib work
vlog ..\ip_uart.v
vlog tb.sv
vsim -c -t 1ps -do run.do tb
move transcript log.txt
pause
