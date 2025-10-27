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

echo T2FONT
zcc +msx -subtype=msxdos2 -I../v9968lib/ test001_t2font.c v9968_common.o v9968_mode.o v9968_font.o -o T2FONT.COM

echo T2VSCR
zcc +msx -subtype=msxdos2 -I../v9968lib/ test002_t2vscr.c v9968_common.o v9968_mode.o v9968_font.o -o T2VSCR.COM

echo T2HSCR
zcc +msx -subtype=msxdos2 -I../v9968lib/ test003_t2hscr.c v9968_common.o v9968_mode.o v9968_font.o -o T2HSCR.COM

echo T2ADJ
zcc +msx -subtype=msxdos2 -I../v9968lib/ test004_t2adj.c v9968_common.o v9968_mode.o v9968_font.o -o T2ADJ.COM

pause
