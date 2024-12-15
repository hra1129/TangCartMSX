vlib work
vlog ..\micom_connect.v
vlog tb.sv
pause
vsim -c -t 1ps -do run.do tb
move transcript log.txt
pause
