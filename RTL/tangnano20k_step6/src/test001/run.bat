vlib work

vlog ..\ram\ip_ram.v
vlog ..\rom\ip_hello_world_rom.v
vlog ..\uart\ip_uart.v
vlog ..\uart\ip_uart_inst.v
vlog ..\..\..\modules\ppi\ppi.v
vlog ..\..\..\modules\ppi\ppi_inst.v
vlog ..\..\..\modules\ssg\ssg.v
vlog ..\..\..\modules\secondary_slot\secondary_slot_inst.v
vlog ..\..\..\modules\cz80\cz80_mcode.v
vlog ..\..\..\modules\cz80\cz80_reg.v
vlog ..\..\..\modules\cz80\cz80_alu.v
vlog ..\..\..\modules\cz80\cz80.v
vlog ..\..\..\modules\cz80\cz80_inst.v
vlog ..\..\..\modules\v9918\vdp.v
vlog ..\..\..\modules\v9918\vdp_color_bus.v
vlog ..\..\..\modules\v9918\vdp_color_decoder.v
vlog ..\..\..\modules\v9918\vdp_double_buffer.v
vlog ..\..\..\modules\v9918\vdp_graphic123m.v
vlog ..\..\..\modules\v9918\vdp_inst.v
vlog ..\..\..\modules\v9918\vdp_interrupt.v
vlog ..\..\..\modules\v9918\vdp_lcd.v
vlog ..\..\..\modules\v9918\vdp_ram_256byte.v
vlog ..\..\..\modules\v9918\vdp_ram_line_buffer.v
vlog ..\..\..\modules\v9918\vdp_register.v
vlog ..\..\..\modules\v9918\vdp_spinforam.v
vlog ..\..\..\modules\v9918\vdp_sprite.v
vlog ..\..\..\modules\v9918\vdp_ssg.v
vlog ..\..\..\modules\v9918\vdp_text12.v
vlog ..\..\..\modules\sdram\ip_sdram_tangnano20k_c.v
vlog ..\..\..\modules\micom_connect\micom_connect.v
vlog gowin_pll_dummy.v
vlog MT48LC2M32B2.v
vlog ..\tangnano20k_step6.v
vlog tb.sv
pause
vsim -c -t 1ps -do run.do tb
move transcript log.txt
pause
