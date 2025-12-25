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

echo G6SP1
zcc +msx -subtype=msxdos2 -I../v9968lib/ test001_sp1.c v9968_common.o v9968_mode.o v9968_font.o -o G6SP1.COM

rem echo G6VSCR
rem zcc +msx -subtype=msxdos2 -I../v9968lib/ test002_g6vscr.c v9968_common.o v9968_mode.o v9968_font.o -o G6VSCR.COM
rem 
rem echo G6HSCR
rem zcc +msx -subtype=msxdos2 -I../v9968lib/ test003_g6hscr.c v9968_common.o v9968_mode.o v9968_font.o -o G6HSCR.COM
rem 
rem echo G6ADJ
rem zcc +msx -subtype=msxdos2 -I../v9968lib/ test004_g6adj.c v9968_common.o v9968_mode.o v9968_font.o -o G6ADJ.COM
rem 
rem echo G6SP1
rem zcc +msx -subtype=msxdos2 -I../v9968lib/ test005_g6sp1.c v9968_common.o v9968_mode.o v9968_font.o -o G6SP1.COM
rem 
rem echo G6SP2
rem zcc +msx -subtype=msxdos2 -I../v9968lib/ test006_g6sp2.c v9968_common.o v9968_mode.o v9968_font.o -o G6SP2.COM
rem 
rem echo G6SP3
rem zcc +msx -subtype=msxdos2 -I../v9968lib/ test007_g6sp3.c v9968_common.o v9968_mode.o v9968_font.o -o G6SP3.COM
rem 
rem echo G6SP4
rem zcc +msx -subtype=msxdos2 -I../v9968lib/ test008_g6sp4.c v9968_common.o v9968_mode.o v9968_font.o -o G6SP4.COM

echo G6IMG
zcc +msx -subtype=msxdos2 -I../v9968lib/ test009_g6img.c v9968_common.o v9968_mode.o v9968_font.o -o G6IMG.COM
echo G6A1
zcc +msx -subtype=msxdos2 -I../v9968lib/ test010_a1.c v9968_common.o v9968_mode.o v9968_font.o -o G6A1.COM

pause
