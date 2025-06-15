vlib work

vlog ..\ip_ws2812_led.v
vlog tb.sv
vsim -c -t 1ns -do run.do tb
move transcript log.txt
pause
