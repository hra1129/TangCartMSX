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

rem echo G7FONT
rem zcc +msx -subtype=msxdos2 -I../v9968lib/ test001_g7font.c v9968_common.o v9968_mode.o v9968_font.o -o G7FONT.COM
rem 
rem echo G7VSCR
rem zcc +msx -subtype=msxdos2 -I../v9968lib/ test002_g7vscr.c v9968_common.o v9968_mode.o v9968_font.o -o G7VSCR.COM
rem 
rem echo G7HSCR
rem zcc +msx -subtype=msxdos2 -I../v9968lib/ test003_g7hscr.c v9968_common.o v9968_mode.o v9968_font.o -o G7HSCR.COM
rem 
rem echo G7ADJ
rem zcc +msx -subtype=msxdos2 -I../v9968lib/ test004_g7adj.c v9968_common.o v9968_mode.o v9968_font.o -o G7ADJ.COM
rem 
rem echo G7SP1
rem zcc +msx -subtype=msxdos2 -I../v9968lib/ test005_g7sp1.c v9968_common.o v9968_mode.o v9968_font.o -o G7SP1.COM
rem 
rem echo G7SP2
rem zcc +msx -subtype=msxdos2 -I../v9968lib/ test006_g7sp2.c v9968_common.o v9968_mode.o v9968_font.o -o G7SP2.COM
rem 
rem echo G7SP3
rem zcc +msx -subtype=msxdos2 -I../v9968lib/ test007_g7sp3.c v9968_common.o v9968_mode.o v9968_font.o -o G7SP3.COM
rem 
rem echo G7SP4
rem zcc +msx -subtype=msxdos2 -I../v9968lib/ test008_g7sp4.c v9968_common.o v9968_mode.o v9968_font.o -o G7SP4.COM

echo G7IMG1
zcc +msx -subtype=msxdos2 -I../v9968lib/ test009_g7img1.c v9968_common.o v9968_mode.o v9968_font.o -o G7IMG1.COM

echo G7IMG2
zcc +msx -subtype=msxdos2 -I../v9968lib/ test009_g7img2.c v9968_common.o v9968_mode.o v9968_font.o -o G7IMG2.COM

echo G7IMG3
zcc +msx -subtype=msxdos2 -I../v9968lib/ test009_g7img3.c v9968_common.o v9968_mode.o v9968_font.o -o G7IMG3.COM

pause
