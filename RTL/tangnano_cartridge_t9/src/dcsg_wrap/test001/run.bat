vlib work
vcom ..\..\dcsg\sn76489_audio.vhd
vlog ..\dcsg_wrap.v
vlog tb.sv
vsim -c -t 1ns -do run.do tb
move transcript log.txt
pause
