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

echo G2FONT
zcc +msx -subtype=msxdos2 -I../v9968lib/ test001_g2font.c v9968_common.o v9968_mode.o v9968_font.o -o G2FONT.COM

echo G2VSCR
zcc +msx -subtype=msxdos2 -I../v9968lib/ test002_g2vscr.c v9968_common.o v9968_mode.o v9968_font.o -o G2VSCR.COM

echo G2HSCR
zcc +msx -subtype=msxdos2 -I../v9968lib/ test003_g2hscr.c v9968_common.o v9968_mode.o v9968_font.o -o G2HSCR.COM

echo G2ADJ
zcc +msx -subtype=msxdos2 -I../v9968lib/ test004_g2adj.c v9968_common.o v9968_mode.o v9968_font.o -o G2ADJ.COM

pause
