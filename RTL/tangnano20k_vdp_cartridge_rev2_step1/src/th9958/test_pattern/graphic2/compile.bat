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

echo G2SP1
zcc +msx -subtype=msxdos2 -I../v9968lib/ test005_g2sp1.c v9968_common.o v9968_mode.o v9968_font.o -o G2SP1.COM

echo G2SP2
zcc +msx -subtype=msxdos2 -I../v9968lib/ test006_g2sp2.c v9968_common.o v9968_mode.o v9968_font.o -o G2SP2.COM

echo G2SP3
zcc +msx -subtype=msxdos2 -I../v9968lib/ test007_g2sp3.c v9968_common.o v9968_mode.o v9968_font.o -o G2SP3.COM

echo G2SP4
zcc +msx -subtype=msxdos2 -I../v9968lib/ test008_g2sp4.c v9968_common.o v9968_mode.o v9968_font.o -o G2SP4.COM

echo G2IMG
zcc +msx -subtype=msxdos2 -I../v9968lib/ test009_g2img.c v9968_common.o v9968_mode.o v9968_font.o -o G2IMG.COM

pause
