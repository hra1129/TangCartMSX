vlib work

vlog ..\ram\ip_ram.v
vlog ..\rom\ip_hello_world_rom.v
vlog ..\uart\ip_uart.v
vlog ..\uart\ip_uart_inst.v
vlog ..\..\..\modules\cz80\cz80_mcode.v
vlog ..\..\..\modules\cz80\cz80_reg.v
vlog ..\..\..\modules\cz80\cz80_alu.v
vlog ..\..\..\modules\cz80\cz80.v
vlog ..\..\..\modules\cz80\cz80_inst.v
vlog gowin_pll_dummy.v
vlog ..\tangnano20k_step2_z80test.v
vlog tb.sv
vsim -c -t 1ps -do run.do tb
move transcript log.txt
pause
