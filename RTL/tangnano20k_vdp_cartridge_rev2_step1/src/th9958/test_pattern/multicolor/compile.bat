@echo off
echo ***************************************************************************
echo  library
echo ***************************************************************************
zcc -c +msx -subtype=msxdos2 -I../v9968lib/ ../v9968lib/v9968_common.c -o v9968_common.o
zcc -c +msx -subtype=msxdos2 -I../v9968lib/ ../v9968lib/v9968_mode.c -o v9968_mode.o
zcc -c +msx -subtype=msxdos2 -I../v9968lib/ ../v9968lib/v9968_font.c -o v9968_font.o

echo ***************************************************************************
echo  test pattern
echo ***************************************************************************

rem echo MLFONT
rem zcc +msx -subtype=msxdos2 -I../v9968lib/ test001_mlfont.c v9968_common.o v9968_mode.o v9968_font.o -o MLFONT.COM
rem 
rem echo MLVSCR
rem zcc +msx -subtype=msxdos2 -I../v9968lib/ test002_mlvscr.c v9968_common.o v9968_mode.o v9968_font.o -o MLVSCR.COM
rem 
rem echo MLHSCR
rem zcc +msx -subtype=msxdos2 -I../v9968lib/ test003_mlhscr.c v9968_common.o v9968_mode.o v9968_font.o -o MLHSCR.COM
rem 
rem echo MLADJ
rem zcc +msx -subtype=msxdos2 -I../v9968lib/ test004_mladj.c v9968_common.o v9968_mode.o v9968_font.o -o MLADJ.COM
rem 
rem echo MLSP1
rem zcc +msx -subtype=msxdos2 -I../v9968lib/ test005_mlsp1.c v9968_common.o v9968_mode.o v9968_font.o -o MLSP1.COM
rem 
rem echo MLSP2
rem zcc +msx -subtype=msxdos2 -I../v9968lib/ test006_mlsp2.c v9968_common.o v9968_mode.o v9968_font.o -o MLSP2.COM
rem 
rem echo MLSP3
rem zcc +msx -subtype=msxdos2 -I../v9968lib/ test007_mlsp3.c v9968_common.o v9968_mode.o v9968_font.o -o MLSP3.COM
rem 
rem echo MLSP4
rem zcc +msx -subtype=msxdos2 -I../v9968lib/ test008_mlsp4.c v9968_common.o v9968_mode.o v9968_font.o -o MLSP4.COM

echo MLIMG
zcc +msx -subtype=msxdos2 -I../v9968lib/ test009_mlimg.c v9968_common.o v9968_mode.o v9968_font.o -o MLIMG.COM

pause
