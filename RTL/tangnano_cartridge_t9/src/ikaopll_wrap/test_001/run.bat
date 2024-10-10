vlib work
vlog ..\ikaopll_wrap.v
vlog ..\..\ikaopll\IKAOPLL.v
vlog ..\..\ikaopll\IKAOPLL_modules\IKAOPLL_dac.v
vlog ..\..\ikaopll\IKAOPLL_modules\IKAOPLL_eg.v
vlog ..\..\ikaopll\IKAOPLL_modules\IKAOPLL_lfo.v
vlog ..\..\ikaopll\IKAOPLL_modules\IKAOPLL_op.v
vlog ..\..\ikaopll\IKAOPLL_modules\IKAOPLL_pg.v
vlog ..\..\ikaopll\IKAOPLL_modules\IKAOPLL_primitives.v
vlog ..\..\ikaopll\IKAOPLL_modules\IKAOPLL_reg.v
vlog ..\..\ikaopll\IKAOPLL_modules\IKAOPLL_timinggen.v
vlog tb.sv
vsim -c -t 1ps -do run.do tb
move transcript log.txt
pause
