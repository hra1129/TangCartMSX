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

echo T1FONT
zcc +msx -subtype=msxdos2 -I../v9968lib/ test001_t1font.c v9968_common.o v9968_mode.o v9968_font.o -o T1FONT.COM

echo T1VSCR
zcc +msx -subtype=msxdos2 -I../v9968lib/ test002_t1vscr.c v9968_common.o v9968_mode.o v9968_font.o -o T1VSCR.COM

echo T1HSCR
zcc +msx -subtype=msxdos2 -I../v9968lib/ test003_t1hscr.c v9968_common.o v9968_mode.o v9968_font.o -o T1HSCR.COM

echo T1ADJ
zcc +msx -subtype=msxdos2 -I../v9968lib/ test004_t1adj.c v9968_common.o v9968_mode.o v9968_font.o -o T1ADJ.COM

pause
