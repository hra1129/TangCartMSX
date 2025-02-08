rmdir /f work
vlib work
vlog MT48LC2M32B2.v
vlog ..\ip_sdram_tangnano20k_c.v
vlog tb.sv
vsim -c -t 1ns -do run.do tb
move transcript log.txt
pause
