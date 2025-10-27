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

rem echo G5FONT
rem zcc +msx -subtype=msxdos2 -I../v9968lib/ test001_g5font.c v9968_common.o v9968_mode.o v9968_font.o -o G5FONT.COM
rem 
rem echo G5VSCR
rem zcc +msx -subtype=msxdos2 -I../v9968lib/ test002_g5vscr.c v9968_common.o v9968_mode.o v9968_font.o -o G5VSCR.COM
rem 
rem echo G5HSCR
rem zcc +msx -subtype=msxdos2 -I../v9968lib/ test003_g5hscr.c v9968_common.o v9968_mode.o v9968_font.o -o G5HSCR.COM
rem 
rem echo G5ADJ
rem zcc +msx -subtype=msxdos2 -I../v9968lib/ test004_g5adj.c v9968_common.o v9968_mode.o v9968_font.o -o G5ADJ.COM
rem 
rem echo G5SP1
rem zcc +msx -subtype=msxdos2 -I../v9968lib/ test005_g5sp1.c v9968_common.o v9968_mode.o v9968_font.o -o G5SP1.COM
rem 
rem echo G5SP2
rem zcc +msx -subtype=msxdos2 -I../v9968lib/ test006_g5sp2.c v9968_common.o v9968_mode.o v9968_font.o -o G5SP2.COM
rem 
rem echo G5SP3
rem zcc +msx -subtype=msxdos2 -I../v9968lib/ test007_g5sp3.c v9968_common.o v9968_mode.o v9968_font.o -o G5SP3.COM
rem 
rem echo G5SP4
rem zcc +msx -subtype=msxdos2 -I../v9968lib/ test008_g5sp4.c v9968_common.o v9968_mode.o v9968_font.o -o G5SP4.COM

echo G5IMG
zcc +msx -subtype=msxdos2 -I../v9968lib/ test009_g5img.c v9968_common.o v9968_mode.o v9968_font.o -o G5IMG.COM

pause
