vlib work

vlog ..\ram\ip_ram.v
vlog ..\rom\ip_rom.v
vlog ..\gpio\ip_gpio.v
vlog ..\cz80\cz80_mcode.v
vlog ..\cz80\cz80_reg.v
vlog ..\cz80\cz80_alu.v
vlog ..\cz80\cz80.v
vlog ..\cz80\cz80_inst.v
vlog ..\sdram\ip_sdram_tangnano20k_c.v
vlog gowin_pll_dummy.v
vlog MT48LC2M32B2.v
vlog ..\testpattern.v
vlog dvi_tx_dummy.v
vlog ..\tangnano20k_hdmi_labo.v
vlog tb.sv
pause
vsim -c -t 1ps -do run.do tb
move transcript log.txt
pause
