vlib work
vlog MT48LC2M32B2.v
vlog ..\sdram.v
vlog ..\ip_sdram.v
vlog tb.sv
vsim -c -t 1ps -do run.do tb
move transcript log.txt
pause
