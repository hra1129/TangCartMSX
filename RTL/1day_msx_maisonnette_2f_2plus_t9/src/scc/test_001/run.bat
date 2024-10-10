vlib work
vlog ..\scc_ram.v
vlog ..\scc_selector.v
vlog ..\scc_tone_generator_5ch.v
vlog ..\scc_channel_volume.v
vlog ..\scc_register.v
vlog ..\scc_channel_mixer.v
vlog ..\ip_scc.v
vlog tb.sv
vsim -c -t 1ps -do run.do tb
move transcript log.txt
pause
