vlib work

vcom ..\dcsg\sn76489_audio.vhd
vlog ..\dcsg_wrap\dcsg_wrap.v

vlog ..\ikaopll\IKAOPLL_modules\IKAOPLL_dac.v
vlog ..\ikaopll\IKAOPLL_modules\IKAOPLL_eg.v
vlog ..\ikaopll\IKAOPLL_modules\IKAOPLL_lfo.v
vlog ..\ikaopll\IKAOPLL_modules\IKAOPLL_op.v
vlog ..\ikaopll\IKAOPLL_modules\IKAOPLL_pg.v
vlog ..\ikaopll\IKAOPLL_modules\IKAOPLL_primitives.v
vlog ..\ikaopll\IKAOPLL_modules\IKAOPLL_reg.v
vlog ..\ikaopll\IKAOPLL_modules\IKAOPLL_timinggen.v
vlog ..\ikaopll\IKAOPLL.v
vlog ..\ikaopll_wrap\ikaopll_wrap.v
vlog ..\ikaopll_wrap\ip_msxmusic_rom.v

vlog ..\ikaopm\IKAOPM_modules\IKAOPM_acc.v
vlog ..\ikaopm\IKAOPM_modules\IKAOPM_eg.v
vlog ..\ikaopm\IKAOPM_modules\IKAOPM_lfo.v
vlog ..\ikaopm\IKAOPM_modules\IKAOPM_noise.v
vlog ..\ikaopm\IKAOPM_modules\IKAOPM_op.v
vlog ..\ikaopm\IKAOPM_modules\IKAOPM_pg.v
vlog ..\ikaopm\IKAOPM_modules\IKAOPM_primitives.v
vlog ..\ikaopm\IKAOPM_modules\IKAOPM_reg.v
vlog ..\ikaopm\IKAOPM_modules\IKAOPM_timer.v
vlog ..\ikaopm\IKAOPM_modules\IKAOPM_timinggen.v
vlog ..\ikaopm\IKAOPM.v
vlog ..\ikaopm_wrap\ikaopm_wrap.v

vlog ..\ikascc\IKASCC_modules\IKASCC_player_a.v
vlog ..\ikascc\IKASCC_modules\IKASCC_player_s.v
vlog ..\ikascc\IKASCC_modules\IKASCC_primitives.v
vlog ..\ikascc\IKASCC_modules\IKASCC_vrc_a.v
vlog ..\ikascc\IKASCC_modules\IKASCC_vrc_s.v
vlog ..\ikascc\IKASCC.v
vlog ..\ikascc_wrap\ip_ikascc_wrap.v
vlog ..\ikascc_wrap\ip_ram.v

vlog ..\msx_midi\i8251.v
vlog ..\msx_midi\i8251_clk_en.v
vlog ..\msx_midi\i8251_receiver.v
vlog ..\msx_midi\i8251_transmitter.v
vlog ..\msx_midi\i8253.v
vlog ..\msx_midi\i8253_clk_en.v
vlog ..\msx_midi\i8253_control.v
vlog ..\msx_midi\i8253_counter.v
vlog ..\msx_midi\tr_midi.v
vlog ..\msx_midi\tr_midi_inst.v

vlog ..\ssg\ssg.v
vlog ..\ssg\ssg_inst.v

vlog ..\pwm\ip_pwm.v

vlog ..\tangcart_msx.v

vlog gowin_pll_dummy.v
vlog tb.sv
vsim -c -t 1ns -do run.do tb
move transcript log.txt
pause
