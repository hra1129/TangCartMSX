@echo off
echo ***************************************************************************
echo  library
echo ***************************************************************************
if exist v9968_common.o del v9968_common.o
if exist v9968_mode.o del v9968_mode.o
if exist v9968_font.o del v9968_font.o

zcc -c +msx -subtype=msxdos2 -I../v9968lib/ ../v9968lib/v9968_common.c -o v9968_common.o
zcc -c +msx -subtype=msxdos2 -I../v9968lib/ ../v9968lib/v9968_mode.c -o v9968_mode.o
zcc -c +msx -subtype=msxdos2 -I../v9968lib/ ../v9968lib/v9968_font.c -o v9968_font.o

echo ***************************************************************************
echo  test pattern
echo ***************************************************************************

echo G1FONT
zcc +msx -subtype=msxdos2 -I../v9968lib/ test001_g1font.c v9968_common.o v9968_mode.o v9968_font.o -o G1FONT.COM

echo G1VSCR
zcc +msx -subtype=msxdos2 -I../v9968lib/ test002_g1vscr.c v9968_common.o v9968_mode.o v9968_font.o -o G1VSCR.COM

echo G1HSCR
zcc +msx -subtype=msxdos2 -I../v9968lib/ test003_g1hscr.c v9968_common.o v9968_mode.o v9968_font.o -o G1HSCR.COM

echo G1ADJ
zcc +msx -subtype=msxdos2 -I../v9968lib/ test004_g1adj.c v9968_common.o v9968_mode.o v9968_font.o -o G1ADJ.COM

echo G1SP1
zcc +msx -subtype=msxdos2 -I../v9968lib/ test005_g1sp1.c v9968_common.o v9968_mode.o v9968_font.o -o G1SP1.COM

echo G1SP2
zcc +msx -subtype=msxdos2 -I../v9968lib/ test006_g1sp2.c v9968_common.o v9968_mode.o v9968_font.o -o G1SP2.COM

echo G1SP3
zcc +msx -subtype=msxdos2 -I../v9968lib/ test007_g1sp3.c v9968_common.o v9968_mode.o v9968_font.o -o G1SP3.COM

echo G1SP4
zcc +msx -subtype=msxdos2 -I../v9968lib/ test008_g1sp4.c v9968_common.o v9968_mode.o v9968_font.o -o G1SP4.COM

pause
