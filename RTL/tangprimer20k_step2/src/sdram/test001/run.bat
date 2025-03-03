rmdir /S /Q work
vlib work

rem ************************************************************************************************
rem  TangPrimer20K ÇÃèÍçáÅADDR3-SDRAM ÇÕÅASK hynix H5TQ1G63EFR-PBC 64MB x16
rem    den1024Mb .... 1Gbit = 128MB
rem    sg125 ........ DDR3 1600 11-11-11
rem    x16 .......... DQ 16bit
rem ************************************************************************************************
vlog -sv +define+den1024Mb +define+sg125 +define+x16 +define+MAX_MEM +incdir+..\ddr3-sdram-verilog-model ..\ddr3-sdram-verilog-model\ddr3.v ..\ddr3-sdram-verilog-model\ddr3_module.v

vlog ..\ip_sdram_tangprimer20k_c.v
vlog tb.sv
vsim -c -t 1ps +model_data+./tmp -do run.do tb
move transcript log.txt
pause
