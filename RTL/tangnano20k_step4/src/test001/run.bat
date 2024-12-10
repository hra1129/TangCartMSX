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
vlog ..\..\..\modules\v9958\vdp.v
vlog ..\..\..\modules\v9958\vdp_color_bus.v
vlog ..\..\..\modules\v9958\vdp_color_decoder.v
vlog ..\..\..\modules\v9958\vdp_command.v
vlog ..\..\..\modules\v9958\vdp_double_buffer.v
vlog ..\..\..\modules\v9958\vdp_graphic123m.v
vlog ..\..\..\modules\v9958\vdp_graphic4567.v
vlog ..\..\..\modules\v9958\vdp_inst.v
vlog ..\..\..\modules\v9958\vdp_interrupt.v
vlog ..\..\..\modules\v9958\vdp_lcd.v
vlog ..\..\..\modules\v9958\vdp_ram_256byte.v
vlog ..\..\..\modules\v9958\vdp_ram_line_buffer.v
vlog ..\..\..\modules\v9958\vdp_ram_palette.v
vlog ..\..\..\modules\v9958\vdp_register.v
vlog ..\..\..\modules\v9958\vdp_spinforam.v
vlog ..\..\..\modules\v9958\vdp_sprite.v
vlog ..\..\..\modules\v9958\vdp_ssg.v
vlog ..\..\..\modules\v9958\vdp_text12.v
vlog ..\..\..\modules\v9958\vdp_wait_control.v
vlog ..\..\..\modules\sdram\ip_sdram_tangnano20k.v
vlog gowin_pll_dummy.v
vlog MT48LC2M32B2.v
vlog ..\tangnano20k_step4.v
vlog tb.sv
vsim -c -t 1ps -do run.do tb
move transcript log.txt
pause
